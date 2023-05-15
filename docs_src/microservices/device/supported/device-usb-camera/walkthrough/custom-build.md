# Custom Build

## Get the Device USB Camera Source Code

1. Change into the edgex directory:
   ```bash
   cd ~/edgex
   ```

2. Clone the device-usb-camera repository:
   ```bash
   git clone https://github.com/edgexfoundry/device-usb-camera.git
   ```

## Define the device profile

Each device resource should have a mandatory attribute named `command` to indicate what action the device service should take for it.

Commands can be one of two types:

* Commands starting with `METADATA_` prefix are used to get camera metadata.
!!! example - "Snippet from general.usb.device.yaml"
    ```yaml
    deviceResources:
    - name: "CameraInfo"
        description: >-
        Camera information including driver name, device name, bus info, and capabilities.
        See https://www.kernel.org/doc/html/latest/userspace-api/media/v4l/vidioc-querycap.html.
        attributes:
        { command: "METADATA_DEVICE_CAPABILITY" }
        properties:
        valueType: "Object"
        readWrite: "R"
    ```

* Commands starting with `VIDEO_` prefix are related to video stream.

!!! example - "Snippet from general.usb.device.yaml"
    ```yaml
    deviceResources:
    - name: "StreamURI"
        description: "Get video-streaming URI."
        attributes:
        { command: "VIDEO_STREAM_URI" }
        properties:
        valueType: "String"
        readWrite: "R"
    ```


For all supported commands, refer to the sample at [general.usb.camera.yaml](../cmd/res/profiles/general.usb.camera.yaml).
!!! Note 
    In general, this sample should be applicable to all types of USB cameras.
!!! Note
    You don't need to define device profile yourself unless you want to modify resource names or set default values for [video options](./advanced-options.md#video-options).

### Define the device

The device's protocol properties contain:
* `Path` is a file descriptor of camera created by OS. You can find the path of the connected USB camera through [v4l2-ctl](https://linuxtv.org/wiki/index.php/V4l-utils) utility.
* `AutoStreaming` indicates whether the device service should automatically start video streaming for cameras. Default value is false.

!!! example - "Snippet from general.usb.camera.yaml.example"
    ```yaml
    deviceList:
    - name: "example-camera"
    profileName: "USB-Camera-General"
    description: "Example Camera"
    labels: [ "device-usb-camera-example", ]
    protocols:
        USB:
        Path: "/dev/video0"
        AutoStreaming: "false"
    ```

See the examples at `cmd/res/devices`  
!!! Note 
    When a new device is created in Core Metadata, a callback function of the device service will be called to add the device card name and serial number to protocol properties for identification purposes. These two pieces of information are obtained through `V4L2` API and `udev` utility.

## Configurable RTSP server hostname and port
The hostname and port of the RTSP server can be configured in the `Driver` section of the `device-usb-camera/cmd/res/configuration.yaml` file. The default values can be used for this guide. The `RtspAuthenticationServer` value indicates the hostname and port on which the authentication server will run. If this value is changed, you will have to also change the [mediamtx configuration]() 
<!-- todo: find location for mediamtx configuration -->

!!! example - "Snippet from configuration.yaml"
    ```yaml
    Driver:
        RtspServerHostName: "localhost"
        RtspTcpPort: "8554"
        RtspAuthenticationServer: "localhost:8000"
    ```

## Configurable RTSP authentication
Set the username and password 
!!! example - "Snippet from configuration.yaml"
    ```yaml
    ...
    Writable:
        LogLevel: "INFO"
        InsecureSecrets:
            rtspauth:
            SecretName: rtspauth
            SecretData:
                username: "<set-username>"
                password: "<set-password>"
    ```

For more information on rtsp authentication, including how to disable it, see [here](../supplementary-info/advanced-options.md#rtsp-auth)

## Building the docker image
1. Change into newly created directory:
   ```bash
   cd ~/edgex/device-usb-camera
   ```

1. Build the docker image of the device-usb-camera service:
   ```bash
   make docker
   ```

   <details>
   <summary>[Optional] Build with NATS Messaging</summary>
      Currently, the NATS Messaging capability (NATS MessageBus) is opt-in at build time. This means that the published Docker image and Snaps do not include the NATS messaging capability. To build the docker image using NATS, run make docker-nats:
      ```bash
      make docker-nats
      ```
      See [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/main/compose-builder#gen) `nat-bus` option to generate compose file for NATS and local dev images.
   </details>

1. Navigate to the Edgex compose directory.

   ```shell
   cd ~/edgex/edgex-compose/compose-builder
   ```
   
1. Update `.env` file to add the registry and image version variable for device-usb-camera:

   Add the following registry and version information:
   ```env
   DEVICE_USBCAM_VERSION=0.0.0-dev
   ```

1. Update the `add-device-usb-camera.yml` to point to the local image:

   ```yml
   services:
   device-usb-camera:
      image: edgexfoundry/device-usb-camera${ARCH}:${DEVICE_USBCAM_VERSION}
   ```

[Deploy the device service>](./deployment.md){: .md-button } 
