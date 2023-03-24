# ONVIF Device Service Custom Build Guide

Follow this guide to make custom configurations and build the device service image from the source.


## Table of Contents
   [Get the Source Code](#get-the-source-code)  
   [Configure the Pre-Defined Devices](#configure-the-pre-defined-devices)  
   [Configure the Device Profiles](#configure-the-device-profiles)  
   [Configure the Provision Watchers](#configure-the-provision-watchers)  
   [Build the Docker Image](#build-the-docker-image)  
   [Additional Configuration](#additional-configuration)  
   [Next Steps](#next-steps)


## Get the Source Code

1. Clone the device-onvif-camera repository.

   ```bash
   git clone https://github.com/edgexfoundry/device-onvif-camera.git
   ```

2. Navigate into the directory

   ```bash
   cd device-onvif-camera
   ```


## Configuration

### Configure the Pre-Defined Devices

Configuring pre-defined devices will allow the service to automatically provision them into core-metadata. Create a list of devices with the appropriate information as outlined below.

1. Make a copy of the `camera.toml.example`:  
   ```bash
   cp ./cmd/res/devices/camera.toml.example ./cmd/res/devices/camera.toml
   ```

1. Open the `cmd/res/devices/camera.toml` file using your preferred text editor and update the `Address` and `Port` fields to match the IP address of the Camera and port used for ONVIF services:

   ```toml
   [[DeviceList]]
   Name = "Camera001"                         # Modify as desired
   ProfileName = "onvif-camera"               # Default profile
   Description = "onvif conformant camera"    # Modify as desired
      [DeviceList.Protocols]
         [DeviceList.Protocols.Onvif]
         Address = "191.168.86.34"              # Set to your camera IP address
         Port = "2020"                          # Set to the port your camera uses
         SecretName = "credentials001"
         [DeviceList.Protocols.CustomMetadata]
         CommonName = "Outdoor camera"
   ```
   <p align="left">
      <i>Sample: Snippet from camera.toml</i>
   </p>

1. Optionally, modify the `Name` and `Description` fields to more easily identify the camera. The `Name` is the camera name used when using ONVIF Device Service Rest APIs. The `Description` is simply a more detailed explanation of the camera.

1. You can also optionally configure the `CustomMetadata` with custom fields and values to store any extra information you would like.

1. To add more pre-defined devices, copy the above configuration and edit to match your extra devices.


### Configure the Device Service
1. Open the [configuration.toml](./cmd/res/configuration.toml) file using your preferred text editor

1. Make sure `secret name` is set to match `SecretName` in `camera.toml`. In the sample below, it is `"credentials001"`. If you have multiple cameras, make sure the secret names match.

1. Under `secretName`, set `username` and `password` to your camera credentials. If you have multiple cameras copy the `Writable.InsecureSecrets` section and edit to include the new information.

```toml
[Writable]
    [Writable.InsecureSecrets.credentials001]
    secretName = "credentials001"
      [Writable.InsecureSecrets.credentials001.SecretData]
      username = "<Credentials 1 username>"
      password = "<Credentials 1 password>"
      mode = "usernametoken" # assign "digest" | "usernametoken" | "both" | "none"

    [Writable.InsecureSecrets.credentials002]
    secretName = "credentials002"
      [Writable.InsecureSecrets.credentials002.SecretData]
      username = "<Credentials 1 password>"
      password = "<Credentials 2 password>"
      mode = "usernametoken" # assign "digest" | "usernametoken" | "both" | "none"

```

<p align="left">
   <i>Sample: Snippet from configuration.toml</i>
</p>

### Additional Configuration Options
For optional configurations, see [here.](#additional-configuration)

## Build the Docker Image

1. In the `device-onvif-camera` directory, run make docker:

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

1. Verify the ONVIF Device Service Docker image was successfully created:

   ```bash
   docker images
   ```
   ```docker
   REPOSITORY                                 TAG          IMAGE ID       CREATED        SIZE
   edgexfoundry-holding/device-onvif-camera   0.0.0-dev    75684e673feb   6 weeks ago    21.3MB
   ```

1. Navigate to `edgex-compose` and enter the `compose-builder` directory.

   ```bash
   cd edgex-compose/compose-builder
   ```

1. Update `.env` file to add the registry and image version variable for device-onvif-camera:

   Add the following registry and version information:
   ```env
   DEVICE_ONVIFCAM_VERSION=0.0.0-dev
   ```

4. Update the `add-device-onvif-camera.yml` to point to the local image.

   ```yml
   services:
      device-onvif-camera:
         image: edgexfoundry/device-onvif-camera:${DEVICE_ONVIFCAM_VERSION}
   ```

## Additional Configuration

Here is some information on how to specially configure parts of the service beyond the provided defaults.  

### Configure the Device Profiles

The device profile contains general information about the camera and includes all of the device resources and commands that the device resources can use to manage the cameras. The default [profile](../cmd/res/camera.yaml) contains all possible resources a camera could implement. Enable and disable supported resources in this file, or create an entirely new profile. It is important to set up the device profile to match the capabilities of the camera. Information on the resources supported by specific cameras can be found [here](./ONVIF-protocol.md#tested-onvif-cameras). Learn more about device profiles in EdgeX [here.](https://docs.edgexfoundry.org/1.2/microservices/device/profile/Ch-DeviceProfile/)

```yaml
name: "onvif-camera" # general information about the profile
manufacturer:  "Generic"
model: "Generic ONVIF"
labels:
  - "onvif"
description: "EdgeX device profile for ONVIF-compliant IP camera."

deviceResources:
  # Network Configuration
  - name: "Hostname" # an example of a resource with get/set values
    isHidden: false
    description: "Camera Hostname"
    attributes:
      service: "Device"
      getFunction: "GetHostname"
      setFunction: "SetHostname"
    properties:
      valueType: "Object"
      readWrite: "RW"
```
<p align="left">
   <i>Sample: Snippet from camera.yaml</i>
</p>


### Configure the Provision Watchers

The provision watcher sets up parameters for EdgeX to automatically add devices to core-metadata. They can be configured to look for certain features, as well as block features. The default provision watcher is sufficient unless you plan on having multiple different cameras with different profiles and resources. Learn more about provision watchers [here](https://docs.edgexfoundry.org/2.2/microservices/core/metadata/Ch-Metadata/#provision-watcher).

```json
{
    "name":"Generic-Onvif-Provision-Watcher",
    "identifiers":{  // Use the identifiers to filter through specific features of the protocol
         "Address": ".",
         "Manufacturer": "Intel", // example of a feature to allow through 
         "Model": "DFI6256TE" 
    },
    "blockingIdentifiers":{
    },
    "serviceName": "device-onvif-camera",
    "profileName": "onvif-camera",
    "adminState":"UNLOCKED"
}
```
<p align="left">
   <i>Sample: Snippet from generic.provision.watcher.json</i>
</p>

## Next Steps
[Running and Verifying the device service](./running-guide.md)

## License

[Apache-1.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/main/LICENSE)
