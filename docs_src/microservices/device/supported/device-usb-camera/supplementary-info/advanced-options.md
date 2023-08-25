# Advanced Options

## RTSP Authentication
The device service allows for rtsp stream authentication using the [rtsp-simple-server](https://github.com/aler9/mediamtx). Authentication is enabled by default.

### Secret Configuration
To configure the username and password for rtsp authentication when building your own images, edit the fields in the 'configuration.yaml'. 

!!! note 
    This should only be used when you are in non-secure mode.

!!! warning
    Be careful when storing any potentially important information in cleartext on files in your computer. In this case, the credentials for the stream are stored in cleartext in the `configuration.yaml` file on your system.
    `InsecureSecrets` is for non-production use only.
    
!!! note 
    Leaving the fields blank will **NOT** disable authentication. The stream will not be able to be authenticated until credentials are provided.

!!! example - "Snippet from configuration.yaml"
    ```yaml
    ...
    Writable:
        LogLevel: "INFO"
        InsecureSecrets:
            rtspauth:
                SecretName: rtspauth
                SecretData:
                    username: "<enter-username>"
                    password: "<enter-password>"
    ```

### Authentication Server Configuration
- You can configure the authentication server to run from a different port by editing the externalAuthenticationURL value in the [Dockerfile](https://github.com/edgexfoundry/device-usb-camera/blob/{{version}}/Dockerfile).
- To disable authentication entirely, comment out the externalAuthenticationURL line in the [Dockerfile](https://github.com/edgexfoundry/device-usb-camera/blob/{{version}}/Dockerfile).

!!! example - "externalAuthenticationURL line from the Dockerfile"
    ```Dockerfile
    RUN sed -i 's,externalAuthenticationURL:,externalAuthenticationURL: http://localhost:8000/rtspauth,g' rtsp-simple-server.yml
    ```

## Set Device Configuration Parameters
### Set frame rate
This command sets the frame rate for the capture device.

1. Before setting the frame rate first execute the `DataFormat` command to see the available frame rates of a device for any of its video streaming path
   or stream format:

    !!! example - "Example DataFormat Command with `path_index` query parameter"
        ```bash
        curl http://localhost:59882/api/{{api_version}}/device/name/<device name>/DataFormat?PathIndex=<path_index>
        ```
        
    OR
    
    !!! example - "Example DataFormat Command with `stream_format` query parameter"
        ```bash
        curl http://localhost:59882/api/{{api_version}}/device/name/<device name>/DataFormat?StreamFormat=<stream_format>
        ```
   
    !!! Note
        The `path_index` refers to the index of the device video streaming path from the path list. For example if a usb device has one
        video streaming path such as /dev/video0 the `path_index` value will be 0. In case of Intel&#8482; RealSense&#174; cameras there are three video 
        streaming paths, hence the user will have 3 options for `path_index` which are 0, 1 and 2. The default value is 0 if no `path_index`
        input is provided. `stream_format` refers to different video streaming formats and the formats currently supported by the service
        are `RGB`, `Depth` or `Greyscale`.
    
    !!! example - "Example DataFormat Response"
        ```json
        {
            "apiVersion": "v3",
            "statusCode": 200,
            "event": {
                "apiVersion": "v3",
                "id": "bf48b7c6-5e94-4831-a7ba-cea4e9773ae1",
                "deviceName": "C270_HD_WEBCAM-8184F580",
                "profileName": "USB-Camera-General",
                "sourceName": "DataFormat",
                "origin": 1689621129335558590,
                "readings": [
                    {
                        "id": "7f4918ca-31c9-4bcf-9490-a328eb62beab",
                        "origin": 1689621129335558590,
                        "deviceName": "C270_HD_WEBCAM-8184F580",
                        "resourceName": "DataFormat",
                        "profileName": "USB-Camera-General",
                        "valueType": "Object",
                        "value": "",
                        "objectValue": {
                            "/dev/video6": {
                                "BytesPerLine": 1280,
                                "Colorspace": "sRGB",
                                "Field": "none",
                                "FrameRates": [
                                    {
                                        "Denominator": 1,
                                        "Numerator": 30
                                    },
                                    {
                                        "Denominator": 1,
                                        "Numerator": 24
                                    },
                                    {
                                        "Denominator": 1,
                                        "Numerator": 20
                                    },
                                    {
                                        "Denominator": 1,
                                        "Numerator": 15
                                    },
                                    {
                                        "Denominator": 1,
                                        "Numerator": 10
                                    },
                                    {
                                        "Denominator": 2,
                                        "Numerator": 15
                                    },
                                    {
                                        "Denominator": 1,
                                        "Numerator": 5
                                    }
                                ],
                                "Height": 480,
                                "PixelFormat": "YUYV 4:2:2",
                                "Quantization": "Limited range",
                                "SizeImage": 614400,
                                "Width": 640,
                                "XferFunc": "Rec. 709",
                                "YcbcrEnc": "ITU-R 601"
                        }
                    }
                ]
            }
        }
        ```

1. Use one of the supported `FrameRates` value from the previous command output to set the frame rate based on `path_index`
    or `stream_format`.

    !!! example - "Example Set FrameRate Command"
        ```bash
        curl -X PUT -d '{
                "FrameRate": {
                "FrameRateValueDenominator": "1"
                "FrameRateValueNumerator": "10",
                }
            }' http://localhost:59882/api/{{api_version}}/device/name/<device name>/FrameRate?PathIndex=<path_index>
        ``` 

    !!! example - "Example Set FrameRate Response"
        ```bash
        {
          "apiVersion": "v3",
          "statusCode": 200
        } 
        ``` 

1. The newly set framerate can be verified using a GET request:

    !!! example - "Example Get FrameRate command"
        ```bash
        curl -X GET http://localhost:59882/api/{{api_version}}/device/name/<device name>/FrameRate?PathIndex=<path_index>
        ```
       
    !!! example - "Example Get FrameRate response"
        ```json
           {
            "apiVersion": "v3",
            "statusCode": 200,
            "event": {
                 "apiVersion": "v3",
                 "id": "8ee12059-fed6-401c-b268-992fede19840",
                 "deviceName": "C270_HD_WEBCAM-8184F580",
                 "profileName": "USB-Camera-General",
                 "sourceName": "FrameRate",
                 "origin": 1692730015347762386,
                 "readings": [{
                     "id": "b991d703-b7ac-4139-a598-87e0f190d617",
                     "origin": 1692730015347762386,
                     "deviceName": "C270_HD_WEBCAM-8184F580",
                     "resourceName": "FrameRate",
                     "profileName": "USB-Camera-General",
                     "valueType": "Object",
                     "value": "",
                     "objectValue": {
                         "/dev/video6": {
                             "Denominator": 1,
                             "Numerator": 10
                         }
                     }
                 }]
            }
           }
        ```

    !!! warning
         3rd party applications such as vlc or ffplay may overwrite your chosen frame rate value, so make sure to keep that in mind when using other applications.

### Set Pixel Format
This command sets the desired pixel format for the capture device.

1. Before setting the pixel format `ImageFormats` command can be executed to see the available pixel formats for a camera for any of its video streaming path
   or stream format (RGB, Greyscale or Depth)

    !!! example - "Example Get ImageFormats Command"
        ```bash
        curl -X GET http://localhost:59882/api/{{api_version}}/device/name/<device name>/ImageFormats?PathIndex=<path_index>
        ```

1. Use one of the supported `PixelFormat` values to set the pixel format based on `path_index`
   or `stream_format`.

    !!! Note
        `PixelFormat` has to be specified in the set request with a specific code which is acceptable by the v4l2 driver.
         This service currently supports the formats whose codes are `YUYV`,`GREY`,`MJPG`,`Z16`,`RGB`,`JPEG`,`MPEG`,`H264`,`MPEG4`,`UYVY`,`BYR2`,`Y8I`,`Y12I`.
         Refer [V4l2 Image Formats](https://www.kernel.org/doc/html/latest/userspace-api/media/v4l/pixfmt.html) for more info. The service only supports setting of height, width or
         pixel format.

    !!! example - "Example Set PixelFormat Command"
        ```bash
        curl -X PUT -d '{
              "PixelFormat": {
                 "Width":"640",
                 "Height":"480",
                 "PixelFormat": "YUYV"
               }
        }' http://localhost:59882/api/{{api_version}}/device/name/<device name>/PixelFormat?PathIndex=<path_index>
        ```

    !!! example - "Example Set PixelFormat Response"
        ```bash
        {
           "apiVersion": "v3",
           "statusCode": 200
        }
        ```

1. The newly set pixel format can be verified using a GET request:

    !!! example - "Example Get PixelFormat command"
        ```bash
        curl -X GET http://localhost:59882/api/{{api_version}}/device/name/<device name>/PixelFormat?PathIndex=<path_index>
        ``` 

    !!! example - "Example Get PixelFormat Response"
        ```json
        {
         "apiVersion": "v3",
         "statusCode": 200,
         "event": {
            "apiVersion": "v3",
            "id": "03cc2182-6a48-4869-ac00-52f968850452",
            "deviceName": "C270_HD_WEBCAM-8184F580",
            "profileName": "USB-Camera-General",
            "sourceName": "PixelFormat",
            "origin": 1692728351448270645,
            "readings": [
                {
                    "id": "ded64ad7-955a-4979-9acd-ff5f1cbc9e9c",
                    "origin": 1692728351448270645,
                    "deviceName": "C270_HD_WEBCAM-8184F580",
                    "resourceName": "PixelFormat",
                    "profileName": "USB-Camera-General",
                    "valueType": "Object",
                    "value": "",
                    "objectValue": {
                        "BytesPerLine": 1280,
                        "Colorspace": "sRGB",
                        "Field": "none",
                        "Flags": 0,
                        "HSVEnc": "Default",
                        "Height": 480,
                        "PixelFormat": "YUYV 4:2:2",
                        "Priv": 4276996862,
                        "Quantization": "Default",
                        "SizeImage": 614400,
                        "Width": 640,
                        "XferFunc": "Default",
                        "YcbcrEnc": "Default"
                    }
                }
            ]
         }
        }
        ```

## Video options
There are two types of options:

- The options starting with `Input` prefix are used for the camera, such as specifying the image size and pixel format.  
- The options starting with `Output` prefix are used for the output video, such as specifying aspect ratio and quality.  

These options can be passed in through object value when calling the `StartStreaming` command.

Query parameter:  
- `device name`: The name of the camera

!!! example - "Example StartStreaming Command"
    ```shell
    curl -X PUT -d '{
        "StartStreaming": {
        "InputImageSize": "640x480",
        "OutputVideoQuality": "5"
        }
    }' http://localhost:59882/api/{{api_version}}/device/name/<device name>/StartStreaming
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

!!! Example - "Snippet from device.yaml"
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

!!! Note
    It's **NOT** recommended to set default video options in the 'cmd/res/profiles/general.usb.camera.yaml' as they may not be supported by every camera.


## Keep the paths of existing cameras up to date
The paths (/dev/video*) of the connected cameras may change whenever the cameras are re-connected or the system restarts.
To ensure the paths of the existing cameras are up to date, the device service scans all the existing cameras to check whether their serial numbers match the connected cameras.
If there is a mismatch between them, the device service will scan all paths to find the matching device and update the existing device with the correct path.

This check can also be triggered by using the Device Service API `/refreshdevicepaths`.
```shell
curl -X POST http://localhost:59983/api/{{api_version}}/refreshdevicepaths
```

It's recommended to trigger a check after re-plugging cameras.

## Configurable RTSP server hostname and port

Enable/Disable RTSP server and set hostname and port of the RTSP server to which the device service publishes video streams can be configured in the [Driver] section of the service configuration located in the `cmd/res/configuration.yaml` file. RTSP server is enabled by default.

!!! example - "Snippet from configuration.yaml"
    ```yaml
    Driver:
        EnableRtspServer: "true"
        RtspServerHostName: "localhost"
        RtspTcpPort: "8554"
        RtspAuthenticationServer: "localhost:8000"
    ```


## CameraStatus Command
Use the following query to determine the status of the camera.
URL parameter:

- **DeviceName**: The name of the camera  
- **InputIndex**: indicates the current index of the video input (if a camera only has one source for video, the index needs to be set to '0')  
!!! example - "Example CameraStatus Command"
    ```
    curl -X GET http://localhost:59882/api/{{api_version}}/device/name/<DeviceName>/CameraStatus?InputIndex=0 | jq -r '"CameraStatus: " + (.event.readings[].value|tostring)'
    ```

Example Output: 
```
CameraStatus: 0
```

**Response meanings**:

| Response   | Description |
| ---------- | ----------- |
| 0          | Ready |
| 1 | No Power |
| 2 | No Signal |
| 3 | No Color |    
