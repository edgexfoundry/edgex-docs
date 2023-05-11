# Deployment
Follow this guide to deploy and run the service.

=== "Docker"

    1. Navigate to the Edgex compose directory.

        ```shell
        cd ~/edgex/edgex-compose/compose-builder
        ```

    2. Run EdgeX with the microservice:  

        - For non secure mode
            ```
            make gen ds-usb-camera no-secty
            ```
        - For secure mode 
            ```
            make gen ds-usb-camera
            ```
        - Docker Compose start command
            ```
            docker-compose -p edgex up -d
            ```

        - Docker Compose clean command
            ```bash
            make clean
            ```  

=== "Native"
    1. Build the executable  
    ```shell
    make build
    ```

        <details>
            <summary>[Optional] Build with NATS Messaging</summary>
            Currently, the NATS Messaging capability (NATS MessageBus) is opt-in at build time. To build using NATS, run make build-nats:
            ```bash
            make build-nats
            ```    
        </details>

    2. Deploy the service
    ```
    cd cmd && EDGEX_SECURITY_SECRET_STORE=false ./device-usb-camera
    ```

## Verify Service, Device Profiles, and Device

1. Check the status of the container:

    ```bash 
    docker ps -f name=device-usb-camera
    ```

    The status column will indicate if the container is running and how long it has been up.

    Example Output:

    ```docker
    CONTAINER ID   IMAGE                                         COMMAND                  CREATED       STATUS          PORTS                                                                                         NAMES
    f0a1c646f324   edgexfoundry/device-usb-camera:0.0.0-dev                        "/docker-entrypoint.…"   26 hours ago   Up 20 hours   127.0.0.1:8554->8554/tcp, 127.0.0.1:59983->59983/tcp                         edgex-device-usb-camera                                                                   edgex-device-onvif-camera
    ```

1. Check that the device service is added to EdgeX:

    ```bash
    curl -s http://localhost:59881/api/v3/deviceservice/name/device-usb-camera | jq .
    ```

    Successful:
    ```json
    {
        "apiVersion": "v3",
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
        "apiVersion": "v3",
        "message": "fail to query device service by name device-usb-camera",
        "statusCode": 404
    }
    ```                              
 
1. Verify device(s) have been successfully added to core-metadata.

    ```bash
    curl -s http://localhost:59881/api/v3/device/all | jq -r '"deviceName: " + '.devices[].name''
    ```

    Example Output: 
    ```bash
    deviceName: NexiGo_N930AF_FHD_Webcam_NexiG-20201217010
    ```
    
    !!! Note 
        The `jq -r` option is used to reduce the size of the displayed response. The entire device with all information can be seen by removing `-r '"deviceName: " + '.devices[].name'', and replacing it with '.'`

## Manage Devices

!!! Note 
    This section only needs to be performed if discovery is disabled.

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
   
    !!! example - "Example Command"
        ```bash
        curl -X POST -H 'Content-Type: application/json'  \
        http://localhost:59881/api/v3/device \
        -d '[
            {
            "apiVersion": "v3",
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
    [{"apiVersion":"v3","statusCode":201,"id":"fb5fb7f2-768b-4298-a916-d4779523c6b5"}]
    ```


[Learn how to use the device service>](./general-usage.md){: .md-button}
