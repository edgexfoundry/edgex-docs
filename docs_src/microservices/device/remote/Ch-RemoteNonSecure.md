# Non-Secure Mode

## Remote deployment of device services in non-secure mode
Usually microservices are deployed using multiple nodes for scalability, availability and performance 
instead of running all services in one node.

This page provides an example of remote deployment of `device-usb-camera` service using multiple nodes in non-secure mode.
The deployment can be done by running the service `natively` or by running it in `docker`.

## Example
This example uses 2 nodes for remote deployment. One node (remote) is used to run all Edgex core services in docker and the other node (host)
for running the device-usb-camera service natively or in docker. Both the nodes are on the same network.
This example can be further expanded to run multiple instances of device-usb-camera service in multiple nodes.

## Running of the example

1. Set up the two nodes to be ready for remote deployment. Refer [USB Service Setup](../supported/device-usb-camera/walkthrough/setup.md)
   for system requirements and dependencies such as Git, Docker, Docker compose, etc. Additional to this Golang needs to be installed
   in the host node where the device-usb-camera service will be built and run natively.

1. Next step is to install Edgex compose in the remote node which will be used to run all Edgex core services. So clone the `edgex-compose`
   repository:

     ```bash
     git clone https://github.com/edgexfoundry/edgex-compose.git
     ```

1. Checkout the required version:

      ```bash
      git checkout {{version}}
      ```

1. Update the `docker-compose-no-secty.yml` file by changing the `host_ip` address of all the Edgex core services to the remote node ip address.
   Non-Edgex core services such as device-rest, device-virtual, app-rules-engine, etc. can be removed or commented out if needed.

1. Run Edgex core services:

      ```bash
      make run no-secty
      ```

   1. Verify the services are up and running:

      ```bash
      docker ps 
      ```

1. Follow this guide to run the `device-usb-camera` service in docker or natively.

=== "Docker"

    Todo

=== "Native"

    1. Clone the `device-usb-camera` service repository

        ```bash
        git clone https://github.com/edgexfoundry/device-usb-camera.git
        ```
    
    1. Checkout the required version

         ```bash
         git checkout {{version}}
         ```

    1. cd into `/cmd/res` directory
         
         ```bash
         cd /cmd/res
         ```

    1. Modify the `configuration.yml` file in the repo to run natively. Uncomment out the required parts as directed in the file.
       Update the yml file with the `Host` and `Remote` node ip addresses.All the 
       localhosts in the yml file need to be replaced by the applicable host and remote ip addresses.

    1. cd back into `cmd` directory
   
         ```bash
         cd..
         ```

    1. For RTSP streaming get [rtsp-simple-server](https://github.com/bluenviron/mediamtx/releases) binary
       and rtsp config yml file and copy them into the `cmd` directory 

    1. Build the service from the `main` directory.

         ```bash
         cd ..
         make build
         ```

    1. Run the service 

         ```bash
         EDGEX_SECURITY_SECRET_STORE=false ./cmd/device-usb-camera -cp=consul.http://<consul-ip-address>:8500 -o
         ```

        !!! note
            If multiple instances of the service has to be run then attach `-i` followed by the number of instances desired. E.g:
            ```bash
            EDGEX_SECURITY_SECRET_STORE=false ./cmd/device-usb-camera -cp=consul.http://<consul-ip-address>:8500 -o -i 2
            ```

    1. Make sure the service has no errors and it discovers connected usb devices after some time. 


    1. Verify device(s) have been successfully added to core-metadata.

         ```bash
         curl -s http://<core-metadata-ip-address>:59881/api/v3/device/all | jq -r '"deviceName: " + '.devices[].name''
         ```

         Example Output:

         ```bash
         deviceName: NexiGo_N930AF_FHD_Webcam_NexiG-20201217010
         ```
         
    1. Add credentials for RTSP streaming by referring to [RTSP Stream Credentials](../supported/device-usb-camera/walkthrough/deployment.md#add-credentials-for-the-rtsp-stream).
       Make sure to use correct host IP address in the POST request instead of localhost.

    1. Follow [USB Service API Guide](../supported/device-usb-camera/walkthrough/general-usage.md) to execute APIs such as Streaming. Again make sure to replace localhost with the applicable
       host or remote IP addresses.





