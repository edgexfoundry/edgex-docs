# USB Camera Device Service RTSP Streaming Guide
## Overview
The EdgeX usb device service is designed for communicating with USB cameras attached to Linux OS platforms. This guide will help configure and build the usb device service and start streaming video from the USB camera.

This service provides the following capabilities:
- API to get camera metadata
- Camera status
- Video stream reference
- FFmpeg framework to capture video frames and stream them to an RTSP server
- An embedded [RTSP server](https://github.com/aler9/rtsp-simple-server)
## System Requirements

- Intel&#8482; Core&#174; processor
- Ubuntu 20.04.4 LTS
- USB-compliant Camera

**Time to Complete**

10-20 minutes

**Other Requirements**

You must have administrator (sudo) privileges to execute the user guide commands.

## Tested Devices
The following devices have been tested with EdgeX USB Camera Device Service:  
Note: Results may vary based on camera hardware/firmware version and operating system support.
<!-- sorted alphabetically -->
- AUKEY PC-LM1E Webcam
- HP w200 Webcam
- Jinpei JW-01B USB FHD Web Computer Camera
- Logitech Brio 4K
- Logitech C270 HD Webcam
- Logitech StreamCam

## Dependencies
The software has dependencies, including Git, Docker, Docker Compose, and assorted command line tools. Follow the instructions linked here to install any dependency that is not already installed [see here](https://github.com/edgexfoundry/device-usb-camera/blob/main/docs/setup.md).

### Install additional Tools
Install the media utility tool:

   ```bash
   sudo apt install mplayer v4l-utils
   ```

- `mplayer` is used to view the video stream
- `v4l-utils` is used to determine the video stream path of a usb camera

## Download and Run EdgeX Services
###  Download EdgeX Compose Repository (if not already downloaded)

1. Create a directory for the EdgeX compose repository:
   ```bash
   mkdir ~/edgex
   ```

2. Change into newly created directory:
   ```bash
   cd ~/edgex
   ```

3. Clone the EdgeX compose repository
   ```bash
   git clone https://github.com/edgexfoundry/edgex-compose.git
   ```


### Run the Service

1. Navigate to the Edgex compose directory.

   ```shell
   cd ~/edgex/edgex-compose/compose-builder
   ```

2. Run EdgeX with the microservice:  
  - For non secure mode
    ```
    make run ds-usb-camera no-secty
    ```
  - For secure mode 
    ```
    make run ds-usb-camera
    ```

## Verify Service and Device Profiles

1. Check the status of the container:

   ```bash 
   docker ps
   ```

   The status column will indicate if the container is running and how long it has been up.

   Example Output:

   ```docker
   CONTAINER ID   IMAGE                                         COMMAND                  CREATED       STATUS          PORTS                                                                                         NAMES
   f0a1c646f324   edgexfoundry/device-usb-camera:0.0.0-dev                        "/docker-entrypoint.…"   26 hours ago   Up 20 hours   127.0.0.1:8554->8554/tcp, 127.0.0.1:59983->59983/tcp                         edgex-device-usb-camera                                                                   edgex-device-onvif-camera
   ```

2. Check that the device service is added to EdgeX:

   ```bash
   curl -s http://localhost:59881/api/v2/deviceservice/name/device-usb-camera | jq .
   ```
   
   Successful:
   ```json
   {
      "apiVersion": "v2",
      "statusCode": 200,
      "service": {
         "created": 1658769423192,
         "modified": 1658872893286,
         "id": "04470def-7b5b-4362-9958-bc5ff9f54f1e",
         "name": "device-usb-camera",
         "baseAddress": "http://edgex-device-usb-camera:59983",
         "adminState": "UNLOCKED"
      }
   }
   ```
   Unsuccessful:
   ```json
   {
      "apiVersion": "v2",
      "message": "fail to query device service by name device-usb-camera",
      "statusCode": 404
   }
   ```
## Adding Devices using REST API
Devices can either be added to the service by defining them in a static configuration file, discovering devices dynamically, or with the REST API. For this example, the device will be added using the REST API.

1. Run the following command to determine the `Path` to the usb camera for video streaming:
   ```bash
   v4l2-ctl --list-devices
   ```

   The output should look similar to this:
   ```
   NexiGo N930AF FHD Webcam: NexiG (usb-0000:00:14.0-1):
        /dev/video6
        /dev/video7
        /dev/media2
   ```

   For this example, the `Path` is `/dev/video6`.


1. Edit the information to appropriately match the camera. The device's protocol properties contain:
   * `name` is the name of the device. For this example, the name is `Camera001`
   * `Path` is a file descriptor of camera created by the OS. Use the `Path` determined in the previous step.
   * `AutoStreaming` indicates whether the device service should automatically start video streaming for cameras. Default value is false.
   
   ```bash
   curl -X POST -H 'Content-Type: application/json'  \
   http://localhost:59881/api/v2/device \
   -d '[
{
  "apiVersion": "v2",
  "device": {
    "name": "Camera001",
    "serviceName": "device-usb-camera",
    "profileName": "USB-Camera-General",
    "description": "My test camera",
    "adminState": "UNLOCKED",
    "operatingState": "UP",
    "protocols": {
      "USB": {
        "CardName": "NexiGo N930AF FHD Webcam: NexiG",
        "Path": "/dev/video6",
        "AutoStreaming": "false"
      }
    }
  }
}
   ]'
   ```

   Example Output: 
   ```bash
   [{"apiVersion":"v2","statusCode":201,"id":"fb5fb7f2-768b-4298-a916-d4779523c6b5"}]
   ```

## Start Video Streaming
Unless the device service is configured to stream video from the camera automatically, a `StartStreaming` command must be sent to the device service.

There are two types of options:
- The options start with `Input` prefix are used for the camera, such as specifying the image size and pixel format.
- The options start with `Output` prefix are used for the output video, such as specifying aspect ratio and quality.

These options can be passed in through Object value when calling StartStreaming.

Query parameter:
- `device name`: The name of the camera

For example:
```shell
curl -X PUT -d '{
    "StartStreaming": {
      "InputImageSize": "640x480",
      "OutputVideoQuality": "5"
    }
}' http://localhost:59882/api/v2/device/name/<device name>/StartStreaming
```

Supported Input options:
- `InputFps`: Ignore original timestamps and instead generate timestamps assuming constant frame rate fps. (default - same as source)
- `InputImageSize`: Specifies the image size of the camera. The format is `wxh`, for example "640x480". (default - automatically selected by FFmpeg)
- `InputPixelFormat`: Set the preferred pixel format (for raw video). (default - automatically selected by FFmpeg)

Supported Output options:
- `OutputFrames`: Set the number of video frames to output. (default - no limitation on frames)
- `OutputFps`: Duplicate or drop input frames to achieve constant output frame rate fps. (default - same as InputFps)
- `OutputImageSize`: Performs image rescaling. The format is `wxh`, for example "640x480". (default - same as InputImageSize)
- `OutputAspect`: Set the video display aspect ratio specified by aspect. For example "4:3", "16:9". (default - same as source)
- `OutputVideoCodec`: Set the video codec. For example "mpeg4", "h264". (default - mpeg4)
- `OutputVideoQuality`: Use fixed video quality level. Range is a integer number between 1 to 31, with 31 being the worst quality. (default - dynamically set by FFmpeg)


### Determine Stream Uri of Camera
The device service provides a way to determine the stream URI of a camera.

Query parameter:
- `device name`: The name of the camera

```bash
curl -s http://localhost:59882/api/v2/device/name/<device name>/StreamURI | jq -r '"StreamURI: " + '.event.readings[].value''
```

The response to the above call should look similar to the following:

```
StreamURI: rtsp://localhost:8554/stream/NexiGo_N930AF_FHD_Webcam__NexiG-20201217010
```

### Play the RTSP stream. 

   mplayer can be used to stream. The command follows this format: 
   
   `mplayer rtsp://<IP address>:<port>/<streamname>`.

   Using the `streamURI` returned from the previous step, run mplayer:
   
   ```bash
   mplayer rtsp://localhost:8554/stream/NexiGo_N930AF_FHD_Webcam__NexiG-20201217010
   ```

  - To shut down mplayer, use the ctrl-c command.
### Stop Video Streaming
To stop the usb camera from live streaming, use the following command:

Query parameter:
- `device name`: The name of the camera

For example:
```shell
curl -X PUT -d '{
    "StopStreaming": "true"
}' http://localhost:59882/api/v2/device/name/<device name>/StopStreaming
```
## Shutting Down
To stop all EdgeX services (containers), execute the `make down` command:

1. Navigate to the `edgex-compose/compose-builder` directory.

   ```shell
   cd ~/edgex/edgex-compose/compose-builder
   ```
1. Run this command
   ```bash
   make down
   ```
1. To shut down and delete all volumes, run this command
   ```bash
   make clean
   ```
## Optional
### Configuration Options
### Configurable RTSP server hostname and port
The hostname and port of the RTSP server can be configured in the `[Driver]` section of the `/cmd/res/configuration.toml` file. The default vaules can be used for this guide.

For example:
```yaml
[Driver]
  RtspServerHostName = "localhost"
  RtspTcpPort = "8554"
```
<p align="left">
      <i>Sample: Snippet from configuration.toml</i>
</p>

## Troubleshooting
### StreamingStatus
To verify the usb camera is set to stream video, use the command below. 

Query parameter:
- `device name`: The name of the camera

```bash
curl http://localhost:59882/api/v2/device/name/<device name>/StreamingStatus | jq -r '"StreamingStatus: " + (.event.readings[].objectValue.IsStreaming|tostring)'
```

If the StreamingStatus is false, the camera is not configured to stream video. Please try the Start Video Streaming section again.
