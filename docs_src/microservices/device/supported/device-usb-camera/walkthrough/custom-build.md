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

## Configurable RTSP server hostname and port
The hostname and port of the RTSP server can be configured in the `[Driver]` section of the `device-usb-camera/cmd/res/configuration.yaml` file. The default values can be used for this guide.

For example:
```yaml
Driver:
  RtspServerHostName: "localhost"
  RtspTcpPort: "8554"
```
<p align="left">
      <i>Sample: Snippet from configuration.yaml</i>
</p>

## Deploy EdgeX and USB Device Camera Microservice
### Building the docker image
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
