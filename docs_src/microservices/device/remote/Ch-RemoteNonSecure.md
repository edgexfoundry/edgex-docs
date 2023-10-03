# Remote deployment of device services in non-secure mode

In some use cases, devices are connected to nodes where core EdgeX services are not running. In these cases the appropriate device service 
needs to run on the remote nodes where it can connect to the device(s) and communicate to the host node where the rest of the EdgeX services are running.

This page provides an example of remote deployment of [device-usb-camera](../services/device-usb-camera/General.md) service using multiple nodes in non-secure mode.
The deployment can be done by running the service `natively` or by running it in `Docker`.

## Example
This example uses 2 nodes for remote deployment. One of the nodes (host) is used to run all EdgeX core services in Docker and the other node (remote)
for running the device-usb-camera service either natively or in Docker. Both the nodes are on the same network.
This example can be further extended to run multiple instances of device-usb-camera service in multiple nodes.

## Running of the example

1. Set up the two nodes to be ready for remote deployment. Refer to [USB Service Setup](../services/device-usb-camera/walkthrough/setup.md)
   for system requirements and dependencies such as Git, Docker, Docker Compose, etc. Additionally Golang needs to be installed
   in the remote node if the device-usb-camera service will be built and run natively.

1. Next step is to install [EdgeX compose](https://github.com/edgexfoundry/edgex-compose) in the host node which will be used to run all EdgeX core services. So clone the `edgex-compose`
   repository:

     ```bash
     git clone https://github.com/edgexfoundry/edgex-compose.git
     ```

1. Checkout the required version:

      ```bash
      git checkout {{edgexversion}}
      ```

1. Update the [docker-compose-no-secty.yml](https://github.com/edgexfoundry/edgex-compose/blob/{{edgexversion}}/docker-compose-no-secty.yml) file by removing the `host_ip` section of all the EdgeX core services. E.g.
      ```bash
      host_ip: 127.0.0.1
      ```
   The example line provided above should be removed from the services, the host_ip will be provided while running the usb service.
   Non-EdgeX core services such as device-rest, device-virtual, app-rules-engine, etc. can be removed or commented out if needed.

1. Run EdgeX core services:

      ```bash
      make run no-secty
      ```

   1. Verify the services are up and running:

      ```bash
      docker ps 
      ```

   1. Follow the guide below to run the `device-usb-camera` service in Docker or natively.

=== "Docker"

    1. Create `docker-compose.yml` file from anywhere in the remote node to run the device service in Docker. Copy the content below into the compose file and edit with approriate values:

        ```bash
        name: edgex
        services:
            device-usb-camera:
            container_name: edgex-device-usb-camera
            device_cgroup_rules:
            - c 81:* rw
            environment:
              EDGEX_SECURITY_SECRET_STORE: "false"
              EDGEX_REMOTE_SERVICE_HOSTS: "<remote-node-ip-address>,<host-node-ip-address>,<service-bind-address>"
              #E.g.EDGEX_REMOTE_SERVICE_HOSTS: "172.118.1.92,172.118.1.167,0.0.0.0"
              DRIVER_RTSPSERVERHOSTNAME: "<remote-node-ip-address>"
              DRIVER_RTSPAUTHENTICATIONSERVER: "<service-bind-address>:8000"
            hostname: edgex-device-usb-camera
            image: <published docker image of device-usb-camera>
            ports:
            - "59983:59983"
            - "8554:8554"
            read_only: true
            restart: always
            security_opt:
            - no-new-privileges:true
            user: root:root
            volumes:
            - type: bind
              source: /dev
              target: /dev
              bind:
                create_host_path: true
            - type: bind
              source: /run/udev
              target: /run/udev
              read_only: true
              bind:
                create_host_path: true
        ```
        
        !!! note
            If multiple instances of the service have to be run, then add `EDGEX_INSTANCE_NAME` environment variable above with a value of number of instances desired.


    1. Run `docker-compose.yml`:
      
         ```bash
         docker compose up -d
         ```

=== "Native"

    1. Clone the [device-usb-camera](https://github.com/edgexfoundry/device-usb-camera) service repository:
   
          ```bash
          git clone https://github.com/edgexfoundry/device-usb-camera.git
          ```

    1. Checkout the required version:
   
         ```bash
         git checkout {{edgexversion}}
         ```

    1. For RTSP streaming get [rtsp-simple-server](https://github.com/bluenviron/mediamtx/releases) binary
       and rtsp config yml file and copy them into the [cmd](https://github.com/edgexfoundry/device-usb-camera/tree/{{edgexversion}}/cmd) directory.

    1. Build the service from the `main` directory:

         ```bash
         make build
         ```

    1. Run the service. Use appropriate ip addresses for the `rsh` flag parameter. Refer to [Remote Service Hosts](../../configuration/CommonCommandLineOptions.md#remote-service-hosts)
       for more info.

         ```bash
         EDGEX_SECURITY_SECRET_STORE=false ./cmd/device-usb-camera -cp -r -rsh=<remote-node-ip-address>,<host-node-ip-address>,<service-bind-address>
         ```

        !!! note
            If multiple instances of the service have to be run, then attach `-i` followed by the number of instances desired. E.g:
            ```bash
            EDGEX_SECURITY_SECRET_STORE=false ./cmd/device-usb-camera -cp -r -rsh=172.26.113.174,172.26.113.150,0.0.0.0 -i 2
            ```

## Verify Service, Device(s) and next steps

1. Make sure the service has no errors and check whether the service is added to EdgeX i.e. to core-metadata (running in host node):

    ```bash
    curl -s http://<host-node-ip-address>:59881/api/{{api_version}}/deviceservice/name/device-usb-camera | jq .
    ```

    Successful:
    ```json
    {
        "apiVersion" : "{{api_version}}",
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
        "apiVersion" : "{{api_version}}",
        "message": "fail to query device service by name device-usb-camera",
        "statusCode": 404
    }
    ```       

1. Verify device(s) have been successfully added:

    ```bash
    curl -s http://<host-node-ip-address>:59881/api/{{api_version}}/device/all | jq -r '"deviceName: " + '.devices[].name''
    ```

    Example Output:

    ```bash
    deviceName: NexiGo_N930AF_FHD_Webcam_NexiG-20201217010
    ```
         
1. Add credentials for RTSP streaming by referring to [RTSP Stream Credentials](../services/device-usb-camera/walkthrough/deployment.md#add-credentials-for-the-rtsp-stream).
   Make sure to replace localhost with the host node IP address.

    !!! note
        The remote node used for rtsp streaming should have FFMPEG version of 5.0 atleast.

1. Follow [USB Service API Guide](../services/device-usb-camera/walkthrough/general-usage.md) to execute APIs such as Streaming. Again make sure to replace localhost with the applicable
   host or remote node IP addresses.





