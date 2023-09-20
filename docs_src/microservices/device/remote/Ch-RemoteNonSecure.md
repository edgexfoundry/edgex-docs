# Remote deployment of device services in non-secure mode

Usually microservices are deployed using multiple nodes for scalability, availability and performance 
instead of running all services in one node.

This page provides an example of remote deployment of [device-usb-camera](../services/device-usb-camera/General.md) service using multiple nodes in non-secure mode.
The deployment can be done by running the service `natively` or by running it in `Docker`.

## Example
This example uses 2 nodes for remote deployment. One of the nodes (host) is used to run all EdgeX core services in Docker and the other node (remote)
for running the device-usb-camera service either natively or in Docker. Both the nodes are on the same network.
This example can be further extended to run multiple instances of device-usb-camera service in multiple nodes.

## Running of the example

1. Set up the two nodes to be ready for remote deployment. Refer to [USB Service Setup](../services/device-usb-camera/walkthrough/setup.md)
   for system requirements and dependencies such as Git, Docker, Docker Compose, etc. Additionally Golang needs to be installed
   in the remote node where the device-usb-camera service will be built and run natively.

1. Next step is to install [EdgeX compose](https://github.com/edgexfoundry/edgex-compose) in the host node which will be used to run all EdgeX core services. So clone the `edgex-compose`
   repository:

     ```bash
     git clone https://github.com/edgexfoundry/edgex-compose.git
     ```

1. Checkout the required version:

      ```bash
      git checkout {{edgexversion}}
      ```

1. Update the [docker-compose-no-secty.yml](https://github.com/edgexfoundry/edgex-compose/blob/main/docker-compose-no-secty.yml) file by removing the `host_ip` section of all the Edgex core services. E.g.
      ```bash
      host_ip: 127.0.0.1
      ```
   The example line provided above should be removed from the services, the host_ip will be provided while running the usb service.
   Non-Edgex core services such as device-rest, device-virtual, app-rules-engine, etc. can be removed or commented out if needed.

1. Run Edgex core services:

      ```bash
      make run no-secty
      ```

   1. Verify the services are up and running:

      ```bash
      docker ps 
      ```

1. Follow this guide to run the `device-usb-camera` service in Docker or natively.

=== "Docker"

    Todo

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
       and rtsp config yml file and copy them into the [cmd](https://github.com/edgexfoundry/device-usb-camera/tree/main/cmd) directory.

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
            If multiple instances of the service has to be run then attach `-i` followed by the number of instances desired. E.g:
            ```bash
            EDGEX_SECURITY_SECRET_STORE=false ./cmd/device-usb-camera -cp -r -rsh=172.26.113.174,172.26.113.150,0.0.0.0 -i 2
            ```

    1. Make sure the service has no errors and it discovers connected usb devices after some time. 


    1. Verify device(s) have been successfully added to core-metadata (running in host node).

         ```bash
         curl -s http://<core-metadata-ip-address>:59881/api/v3/device/all | jq -r '"deviceName: " + '.devices[].name''
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





