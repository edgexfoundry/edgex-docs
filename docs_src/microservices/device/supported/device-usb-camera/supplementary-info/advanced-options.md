# Advanced Options

## Contents
[Video Options](#video-options)  
[Camera Paths](#keep-the-paths-of-existing-camera-up-to-date)  
[RTSP Server](#configurable-rtsp-server-hostname-and-port)  
[CameraStatus Command](#camerastatus-command)  
[License](#license)  


## Video options
There are two types of options:
- The options start with `Input` prefix are used for the camera, such as specifying the image size and pixel format.
- The options start with `Output` prefix are used for the output video, such as specifying aspect ratio and quality.

These options can be passed in through object value when calling `StartStreaming`.

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

You can also set default values for these options by adding additional attributes to the device resource `StartStreaming`.
The attribute name consists of a prefix "default" and the option name.

For example:

```yaml
deviceResources:
  - name: "StartStreaming"
    description: "Start streaming process."
    attributes:
      { command: "VIDEO_START_STREAMING",
        defaultInputFrameSize: "320x240",
        defaultOutputVideoQuality: "31"
      }
    properties:
      valueType: "Object"
      readWrite: "W"
```

> NOTE: It's NOT recommended to set default video options in the [cmd/res/profiles/general.usb.camera.yaml](cmd/res/profiles/general.usb.camera.yaml) as they may not be supported by every camera.


## Keep the paths of existing camera up to date
The paths (/dev/video*) of the connected cameras may change whenever the cameras are re-connected or the system restarts.
To ensure the paths of the existing cameras are up to date, the device service scans all the existing cameras to check whether their serial numbers match the connected cameras.
If there is a mismatch between them, the device service will scan all paths to find the matching device and update the existing device with the correct path.

This check can also be triggered by using the Device Service API `/refreshdevicepaths`.
For example:
```shell
curl -X POST http://localhost:59983/api/v2/refreshdevicepaths
```

It's recommended to trigger a check after re-plugging cameras.

## Configurable RTSP server hostname and port

The hostname and port of the RTSP server to which the device service publishes video streams can be configured in the [Driver] section of the service configuration located in the [configuration.yaml](../cmd/res/configuration.yaml).

For example:
```yaml
Driver:
  RtspServerHostName: "localhost"
  RtspTcpPort: "8554"
```
## CameraStatus Command
Use the following query to determine the status of the camera.
URL parameter:
- **DeviceName**: The name of the camera
- **InputIndex**: indicates the current index of the video input (if a camera only has one source for video, the index needs to be set to '0')
```
curl -X GET http://localhost:59882/api/v2/device/name/<DeviceName>/CameraStatus?InputIndex=0 | jq -r '"CameraStatus: " + (.event.readings[].value|tostring)'
```
   Example Output: 
   ```
    CameraStatus: 0
   ```
   **Response meanings**:
| Response   | Description |
| ---------- | ----------- |
| 0 | Ready |
| 1 | No Power |
| 2 | No Signal |
| 3 | No Color |    

## License
[Apache-2.0](../LICENSE)
