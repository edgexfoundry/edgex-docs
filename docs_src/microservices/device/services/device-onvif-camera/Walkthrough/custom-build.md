# Custom Build

Follow this guide to make custom configurations and build the device service image from the source.

!!! warning
      This is not the recommended method of deploying the service. To use the default images, see [here](./deployment.md).

## Get the Source Code

1. Clone the device-onvif-camera repository.
   ```bash
   git clone https://github.com/edgexfoundry/device-onvif-camera.git
   ```
   
2. Navigate into the directory
   ```bash
   cd device-onvif-camera
   ```

3. Checkout the latest release ({{edgexversion}}):
   ```bash
   git checkout {{edgexversion}}
   ```

## Configuration

### Configure the Pre-Defined Devices

Configuring pre-defined devices will allow the service to automatically provision them into core-metadata. Create a list of devices with the appropriate information as outlined below.

1. Make a copy of the `camera.yaml.example`:  
   ```bash
   cp ./cmd/res/devices/camera.yaml.example ./cmd/res/devices/camera.yaml
   ```

    !!! warning
        Be careful when storing any potentially important information in cleartext on files in your computer. Potentially sensitive information in this case could include the IP address of your ONVIF camera or any custom metadata you configure.

2. Open the `cmd/res/devices/camera.yaml` file using your preferred text editor and update the `Address` and `Port` fields to match the IP address of the Camera and port used for ONVIF services:
    
    !!! example - "Sample: Snippet from camera.yaml"
        ```yaml
        deviceList:
        - name: Camera001                         # Modify as desired
           profileName: onvif-camera              # Default profile
           description: onvif conformant camera   # Modify as desired
           protocols:
              Onvif:
                 Address: 191.168.86.34           # Set to your camera IP address
                 Port: '2020'                     # Set to the port your camera uses
              CustomMetadata:
                 CommonName: Outdoor camera
        ```

3. Optionally, modify the `Name` and `Description` fields to more easily identify the camera. The `Name` is the camera name used when using ONVIF Device Service Rest APIs. The `Description` is simply a more detailed explanation of the camera.
4. You can also optionally configure the `CustomMetadata` with custom fields and values to store any extra information you would like.

5. To add more pre-defined devices, copy the above configuration and edit to match your extra devices.


### Configure the Device Service
1. Open the `cmd/res/configuration.yaml` file using your preferred text editor

2. Make sure `secret name` is set to match `SecretName` in `camera.yaml`. In the sample below, it is `"credentials001"`. If you have multiple cameras, make sure the secret names match.
 
3. Under `secretName`, set `username` and `password` to your camera credentials. If you have multiple cameras copy the `Writable.InsecureSecrets` section and edit to include the new information.

    !!! warning
        Be careful when storing any potentially important information in cleartext on files in your computer. In this case, the credentials for the camera(s) are stored in cleartext in the `configuration.yaml` file on your system.
        `InsecureSecrets` is for non-production use only.

    !!! example - "Sample: Snippet from configuration.yaml"
        ```yaml
        Writable:
        LogLevel: INFO
        InsecureSecrets:
           credentials001:
              SecretName: credentials001
              SecretData:
                 username: <Credentials 1 username>
                 password: <Credentials 1 password>
                 mode: usernametoken   # assign "digest" | "usernametoken" | "both" | "none"
           credentials002:
              SecretName: credentials002
              SecretData:
                 username: <Credentials 2 username>
                 password: <Credentials 2 password>
                 mode: usernametoken    # assign "digest" | "usernametoken" | "both" | "none"
        ```

### Additional Configuration Options
For optional configurations, see [here.](#additional-configuration)

## Build the Docker Image

1. In the `device-onvif-camera` directory, run make docker:
      ```bash
      make docker
      ```
      <details>
      <summary>[Optional] Build with NATS Messaging</summary>
            Currently, the NATS Messaging capability (NATS MessageBus) is opt-in at build time. This means that the published Docker image does not include the NATS messaging capability. To build the docker image using NATS, run make docker-nats:
            ```bash
            make docker-nats
            ```
            See [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder#gen) `nat-bus` option to generate compose file for NATS and local dev images.
      </details>

2. Verify the ONVIF Device Service Docker image was successfully created:
      ```bash
      docker images
      ```
      ```docker
      REPOSITORY                                 TAG          IMAGE ID       CREATED        SIZE
      edgexfoundry-holding/device-onvif-camera   0.0.0-dev    75684e673feb   6 weeks ago    21.3MB
      ```   

3. Navigate to `edgex-compose` and enter the `compose-builder` directory.     
      ```bash
      cd edgex-compose/compose-builder
   ```

4. Update `.env` file to add the registry and image version variable for device-onvif-camera:
      Add the following registry and version information:
      ```env
      DEVICE_ONVIFCAM_VERSION=0.0.0-dev
      ```

5. Update the `add-device-onvif-camera.yml` to point to the local image.
      ```yml
      services:
         device-onvif-camera:
            image: edgexfoundry/device-onvif-camera:${DEVICE_ONVIFCAM_VERSION}
      ```

## Additional Configuration

Here is some information on how to specially configure parts of the service beyond the provided defaults.  

### Configure the Device Profiles

The device profile contains general information about the camera and includes all of the device resources and commands that the device resources can use to manage the cameras. The default profile found at `cmd/res/devices/camera.yaml` contains all possible resources a camera could implement. Enable and disable supported resources in this file, or create an entirely new profile. It is important to set up the device profile to match the capabilities of the camera. Information on the resources supported by specific cameras can be found [here](../supplementary-info/ONVIF-protocol.md#tested-onvif-cameras). Learn more about device profiles in EdgeX [here.](../../../../core/metadata/details/DeviceProfile.md)

!!! example - "Sample: Snippet from camera.yaml"
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

### Configure the Provision Watchers

The provision watcher sets up parameters for EdgeX to automatically add devices to core-metadata. They can be configured to look for certain features, as well as block features. The default provision watcher is sufficient unless you plan on having multiple different cameras with different profiles and resources. Learn more about provision watchers [here](../../../../core/metadata/GettingStarted.md#provision-watcher).
 
!!! example - "Sample: Snippet from generic.provision.watcher.yaml"
    ```yaml
    name: Generic-Onvif-Provision-Watcher
    identifiers:
      Address: .
    blockingIdentifiers: {}
    adminState: UNLOCKED
    discoveredDevice:
        serviceName: device-onvif-camera
        profileName: onvif-camera
        adminState: UNLOCKED
    ```

## Next Steps
[Deploy and Run the Service>](./deployment.md){: .md-button}

## License

[Apache-2.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/{{edgexversion}}/LICENSE)
