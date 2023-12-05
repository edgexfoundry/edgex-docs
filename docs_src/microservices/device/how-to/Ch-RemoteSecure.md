---
title: Device Service - Remote deployment secure mode
---

# Device Service - Remote deployment secure mode

In some use cases, devices are connected to nodes where core EdgeX services are not running. In these cases the appropriate device service
needs to run on the remote nodes where it can connect to the device(s) and communicate to the host node where the rest of the EdgeX services are running.

This page provides an example of configuring and deploying multiple instances of [device-usb-camera](../services/device-usb-camera/General.md)
service using multiple nodes in EdgeX secure mode. This example is applicable to any device service.

## Example
This example uses 3 nodes for remote deployment. One of the nodes (host) is used to run all EdgeX core services in Docker and the other nodes (remote)
for running the device-usb-camera service in Docker. This example can be further extended to run multiple instances of device-usb-camera
service in multiple nodes.

## Pre-requisites
- 3 machines running Ubuntu 20.04 or newer OS, with docker installed.
    - 1 `local` system for deploying all edgex core services in secure mode with docker
    - 2 `remote` nodes for deploying USB service in secure mode with docker
- All dependencies such as docker, git, curl etc. installed on all 3 systems to run
  edgex and usb services
- Local and remote nodes needs to be on the same network

!!! Note
    This document assumes a network configuration without any VPN and/or proxy configuration. If your network environment
    requires any proxy and/or VPN, then that needs to be configured appropriately and the below steps adjusted for your environment.

This example assumes the following values; replace them as needed with your own values:

- `local` node IP: `192.168.4.103`
- `remote` node 1 IP: `192.168.4.104`
- `remote` node 2 IP: `192.168.4.105`
- Instance numbers for the services are `1` and `2`. (i.e. `device-usb-camera_1` and `device-usb-camera_2`)

## Local system setup (EdgeX Core)
This section will go over setting up the local node to run all the EdgeX Core services

!!! Info
    Refer to sample [device virtual service deployment in secure mode](../../../security/Ch-RemoteDeviceServices.md) for a general understanding of remote device services.


1. Set up the `local` node to be ready for deployment. Refer to [USB Service Setup](../services/device-usb-camera/walkthrough/setup.md)
   for system requirements and dependencies such as Git, Docker, Docker Compose, etc.

2. Next step is to install [EdgeX compose][edgex-compose] in the host node which will be used to run all EdgeX core services. So clone the `edgex-compose`
   repository:

     ```bash
     git clone https://github.com/edgexfoundry/edgex-compose.git
     ```

3. Navigate to the `edgex-compose` directory:
    ```bash
    cd edgex-compose
    ```

4. Checkout the compatible release ({{edgexversion}}):
      ```bash
      git checkout {{edgexversion}}
      ```

### Generate SSH key pair for SSH tunnel
1. Clone the EdgeX Examples repository:
    ```bash
    git clone https://github.com/edgexfoundry/edgex-examples.git
    ```

2. Navigate to the `edgex-examples` directory:
    ```bash
    cd edgex-examples
    ```

3. Checkout the compatible release ({{edgexversion}}):
    ```shell
    git checkout {{edgexversion}}
    ```

4. Navigate to [`edgex-examples/security/remote_devices/spiffe_and_ssh`][spiffe_and_ssh] on your local machine.
5. Run `generate_keys.sh` script
6. (Optional) Copy the entire `remote` sub-folder to somewhere on each remote node's filesystem at this point. If you prefer, you can wait until [Remote Node Setup](#remote-node-setup) to perform this step.

### Edit docker-compose file
!!! Note
    Below instructions explain how to run 2 instances of the `device-usb-camera` service: instance 1 (`device-usb-camera_1`) and instance 2 (`device-usb-camera_2`).

1. Navigate to [`edgex-examples/security/remote_devices/spiffe_and_ssh/local`][spiffe_and_ssh_local] and edit
   [`docker-compose.yml`][local_compose] file

2. Change `host_ip` to ip address of local system for `consul`, `core-metadata`, `database` and `vault`

    ```yaml
    services:
      consul:
        ports:
          - mode: ingress
            host_ip: 192.168.4.103  # insert local machine's host ip here
            target: 8500
            published: "8500"
            protocol: tcp
    
      core-metadata:
        ports:
          - mode: ingress
            host_ip: 192.168.4.103  # insert local machine's host ip here
            target: 59881
            published: "59881"
            protocol: tcp
      database:
        ports:
          - mode: ingress
            host_ip: 192.168.4.103  # insert local machine's host ip here
            target: 6379
            published: "6379"
            protocol: tcp
      vault:
        ports:
          - mode: ingress
            host_ip: 192.168.4.103  # insert local machine's host ip here
            target: 8200
            published: "8200"
            protocol: tcp
    ```
3. Add/edit environment variables for `consul`, `security-proxy-setup` and `security-secretstore-setup` services

    ```yaml
      services:
        consul:
          environment:
            EDGEX_ADD_REGISTRY_ACL_ROLES: "device-usb-camera_1,device-usb-camera_2"
    
        security-proxy-setup:
          environment:
            # insert the IP addresses of your remote nodes below!
            EDGEX_ADD_PROXY_ROUTE: "device-usb-camera_1.http://192.168.4.104:59983,device-usb-camera_2.http://192.168.4.105:59983"
            ROUTES_DEVICE_USB_CAMERAL_HOST: "device-usb-camera_1,device-usb-camera_2"
    
        security-secretstore-setup:
          environment:
            EDGEX_ADD_KNOWN_SECRETS: "redisdb[app-rules-engine],redisdb[device-usb-camera_1],message-bus[device-usb-camera_1],redisdb[device-usb-camera_2],message-bus[device-usb-camera_2]"
    ```

4. Add multiple `device-ssh-proxy` service and configure with remote node ips
    1. Copy `device-ssh-proxy` service and paste it again below itself
    2. Rename services to `device-ssh-proxy-1` and `device-ssh-proxy-2` respectively
    3. Modify the existing environment variables and other fields for `device-ssh-proxy-1`
        ```yaml
          services:
            device-ssh-proxy-1:
              container_name: edgex-device-ssh-proxy-1
              environment:
                SERVICE_HOST: edgex-device-usb-camera
                SERVICE_PORT: 59983
                TUNNEL_HOST: 192.168.4.104  # use ip address of the first remote node!
              hostname: edgex-device-ssh-proxy-1
              networks:
                edgex-network:
                  aliases:
                    - edgex-device-usb-camera-1
              ports:
                - 127.0.0.1:59983:59983/tcp
        ```
   4. Edit environment variables and other fields for `device-ssh-proxy-2`
        ```yaml
          services:
            device-ssh-proxy-2:
              container_name: edgex-device-ssh-proxy-2
              environment:
                SERVICE_HOST: edgex-device-usb-camera
                SERVICE_PORT: 59983
                TUNNEL_HOST: 192.168.4.105   # use ip address of the second remote node!
              hostname: edgex-device-ssh-proxy-2
              networks:
                edgex-network:
                  aliases:
                    - edgex-device-usb-camera-2
              ports:
                - 127.0.0.1:59984:59983/tcp   # notice the different port mapping to avoid conflicts
        ```

5. Update to latest docker image for `security-spiffe-token-provider`

    ```yaml
      services:
        security-spiffe-token-provider:
          image: nexus3.edgexfoundry.org:10004/security-spiffe-token-provider:latest
    ```

### Build and run services
1. Navigate to [`edgex-examples/security/remote_devices/spiffe_and_ssh/local`][spiffe_and_ssh_local]
2. Build and start the services
    ```bash
    docker compose build
    docker compose up -d
    ```
3. Run `docker ps -a` and ensure all containers started without crashing
    !!! Note
        `edgex-device-ssh-proxy-1` and `edgex-device-ssh-proxy-2` will keep restarting until services on remote node start

### Update server entries
Edit and run `add-server-entry.sh` script for each usb service

1. Navigate to [`edgex-examples/security/remote_devices/spiffe_and_ssh/local`][spiffe_and_ssh_local] and edit `add-server-entry.sh` script like below.

    !!! Example - "Example for first device service"
    ```bash
    docker exec -ti edgex-security-spire-config spire-server entry create \
        -socketPath /tmp/edgex/secrets/spiffe/private/api.sock  \
        -parentID spiffe://edgexfoundry.org/spire/agent/x509pop/cn/  \
        remote-agent -dns "edgex-device-usb-camera" \
        -spiffeID  spiffe://edgexfoundry.org/service/device-usb-camera_1 \
        -selector "docker:label:com.docker.compose.service:device-usb-camera_1"
    ```

2. Save and then run `./add-server-entry.sh`

3. Repeat previous steps for each additional device service

    !!! Example - "Example for second device service"
    ```bash
    docker exec -ti edgex-security-spire-config spire-server entry create \
        -socketPath /tmp/edgex/secrets/spiffe/private/api.sock  \
        -parentID spiffe://edgexfoundry.org/spire/agent/x509pop/cn/  \
        remote-agent -dns "edgex-device-usb-camera" \
        -spiffeID  spiffe://edgexfoundry.org/service/device-usb-camera_2 \
        -selector "docker:label:com.docker.compose.service:device-usb-camera_2"
    ```
4. Save and then run `./add-server-entry.sh` again
5. Repeat these steps as needed for each additional remote node

## Remote Node Setup

!!! note
    These steps will need to be repeated for **every single remote node**!

1. Navigate to `edgex-examples/security/remote_devices/spiffe_and_ssh` on your local machine
2. Copy the entire `remote` sub-folder somewhere onto the remote node
3. Navigate into the `remote` folder on the remote node
4. Edit the [`docker-compose.yml`][remote_compose] file
5. Remove the entire `device-virtual` service
6. Add the `device-usb-service_X` service like below, updating it with the proper values for your configuration

    !!! tip
        Choose `Remote Node 1` to configure remote node 1, `Remote Node 2` to configure remote node 2, or `Remote Node Template` for any additional nodes.

    !!! example
        === "Remote Node 1"
        
            ```yaml
                device-usb-camera_1:  # device-usb-camera_<instance number>
                   # command: -cp -r -rsh <remote node ip>,<edgex system ip>,0.0.0.0 -i <instance number>
                   command: -cp -r -rsh 192.168.4.104,192.168.4.103,0.0.0.0 -i 1
                   container_name: edgex-device-usb-camera
                   device_cgroup_rules:
                      - c 81:* rw
                   depends_on:
                     - remote-spire-agent
                   environment:
                     EDGEX_SECURITY_SECRET_STORE: "true"
                     SECRETSTORE_HOST: 192.168.4.103     # <edgex core system ip address>
                     SECRETSTORE_PORT: "8200"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED: "true"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENDPOINTSOCKET: /tmp/edgex/secrets/spiffe/public/api.sock
                     SECRETSTORE_RUNTIMETOKENPROVIDER_HOST: edgex-security-spiffe-token-provider
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PORT: 59841
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PROTOCOL: https
                     SECRETSTORE_RUNTIMETOKENPROVIDER_REQUIREDSECRETS: redisdb
                     SECRETSTORE_RUNTIMETOKENPROVIDER_TRUSTDOMAIN: edgexfoundry.org
                     DEVICE_DISCOVERY_ENABLED: 'true' # enable or disable auto-discovery
                     DEVICE_DISCOVERY_INTERVAL: '5m'  # configure the auto-discovery interval
                   hostname: edgex-device-usb-camera
                   image: nexus3.edgexfoundry.org:10004/device-usb-camera:latest
                   networks:
                    edgex-network: {}
                   ports:
                     - "192.168.4.104:59983:59983/tcp"   # <remote node ip>:59983:59983/tcp
                     - "8554:8554"
                     - "8000:8000"
                   read_only: true
                   restart: always
                   security_opt:
                     - no-new-privileges:true
                   user: 'root:root'
                   volumes:
                     # - /tmp/edgex/secrets/device-usb-camera_<instance number>:/tmp/edgex/secrets/device-usb-camera_<instance number>:ro,z
                     - /tmp/edgex/secrets/device-usb-camera_1:/tmp/edgex/secrets/device-usb-camera_1:ro,z
                     - /tmp/edgex/secrets/spiffe/public:/tmp/edgex/secrets/spiffe/public:ro,z
                     - /dev:/dev:ro
                     - /run/udev:/run/udev:ro
            ```
        
        === "Remote Node 2"
        
            ```yaml
                device-usb-camera_2:  # device-usb-camera_<instance number>
                   # command: -cp -r -rsh <remote node ip>,<edgex system ip>,0.0.0.0 -i <instance number>
                   command: -cp -r -rsh 192.168.4.105,192.168.4.103,0.0.0.0 -i 2
                   container_name: edgex-device-usb-camera
                   device_cgroup_rules:
                      - c 81:* rw
                   depends_on:
                     - remote-spire-agent
                   environment:
                     EDGEX_SECURITY_SECRET_STORE: "true"
                     SECRETSTORE_HOST: 192.168.4.103     # <edgex core system ip address>
                     SECRETSTORE_PORT: "8200"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED: "true"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENDPOINTSOCKET: /tmp/edgex/secrets/spiffe/public/api.sock
                     SECRETSTORE_RUNTIMETOKENPROVIDER_HOST: edgex-security-spiffe-token-provider
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PORT: 59841
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PROTOCOL: https
                     SECRETSTORE_RUNTIMETOKENPROVIDER_REQUIREDSECRETS: redisdb
                     SECRETSTORE_RUNTIMETOKENPROVIDER_TRUSTDOMAIN: edgexfoundry.org
                     DEVICE_DISCOVERY_ENABLED: 'true' # enable or disable auto-discovery
                     DEVICE_DISCOVERY_INTERVAL: '5m'  # configure the auto-discovery interval
                   hostname: edgex-device-usb-camera
                   image: nexus3.edgexfoundry.org:10004/device-usb-camera:latest
                   networks:
                    edgex-network: {}
                   ports:
                     - "192.168.4.105:59983:59983/tcp"   # <remote node ip>:59983:59983/tcp
                     - "8554:8554"
                     - "8000:8000"
                   read_only: true
                   restart: always
                   security_opt:
                     - no-new-privileges:true
                   user: 'root:root'
                   volumes:
                     # - /tmp/edgex/secrets/device-usb-camera_<instance number>:/tmp/edgex/secrets/device-usb-camera_<instance number>:ro,z
                     - /tmp/edgex/secrets/device-usb-camera_1:/tmp/edgex/secrets/device-usb-camera_1:ro,z
                     - /tmp/edgex/secrets/spiffe/public:/tmp/edgex/secrets/spiffe/public:ro,z
                     - /dev:/dev:ro
                     - /run/udev:/run/udev:ro
            ```
        
        === "Remote Node Template"
        
            ```yaml
                device-usb-camera_<instance number>:  # todo
                   command: -cp -r -rsh <remote node ip>,<edgex system ip>,0.0.0.0 -i <instance number>   # todo
                   container_name: edgex-device-usb-camera
                   device_cgroup_rules:
                      - c 81:* rw
                   depends_on:
                     - remote-spire-agent
                   environment:
                     EDGEX_SECURITY_SECRET_STORE: "true"
                     SECRETSTORE_HOST: <edgex core system ip address>   # todo
                     SECRETSTORE_PORT: "8200"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED: "true"
                     SECRETSTORE_RUNTIMETOKENPROVIDER_ENDPOINTSOCKET: /tmp/edgex/secrets/spiffe/public/api.sock
                     SECRETSTORE_RUNTIMETOKENPROVIDER_HOST: edgex-security-spiffe-token-provider
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PORT: 59841
                     SECRETSTORE_RUNTIMETOKENPROVIDER_PROTOCOL: https
                     SECRETSTORE_RUNTIMETOKENPROVIDER_REQUIREDSECRETS: redisdb
                     SECRETSTORE_RUNTIMETOKENPROVIDER_TRUSTDOMAIN: edgexfoundry.org
                     DEVICE_DISCOVERY_ENABLED: 'true' # enable or disable auto-discovery
                     DEVICE_DISCOVERY_INTERVAL: '5m'  # configure the auto-discovery interval
                   hostname: edgex-device-usb-camera
                   image: nexus3.edgexfoundry.org:10004/device-usb-camera:latest
                   networks:
                    edgex-network: {}
                   ports:
                     - "<remote node ip>:59983:59983/tcp"  # todo
                     - "8554:8554"
                     - "8000:8000"
                   read_only: true
                   restart: always
                   security_opt:
                     - no-new-privileges:true
                   user: 'root:root'
                   volumes:
                     - /tmp/edgex/secrets/device-usb-camera_<instance number>:/tmp/edgex/secrets/device-usb-camera_<instance number>:ro,z  # todo
                     - /tmp/edgex/secrets/spiffe/public:/tmp/edgex/secrets/spiffe/public:ro,z
                     - /dev:/dev:ro
                     - /run/udev:/run/udev:ro
            ```

7. Build and run services on the remote node
    1. Navigate to `remote` folder
    2. `docker compose build`
    3. `docker compose up -d`
    4.  Run `docker ps -a` to ensure all services started successfully
8. Wait for about 1 minute for ssh tunnel and communication between edgex server system and remote node to be established.
9. Run `docker logs edgex-device-usb-camera` to check usb service status. Ensure usb service started successfully and detected and added connected usb cameras (if any) to `edgex-core-metadata`.
10. Repeat all the [Remote Node Setup](#remote-node-setup) steps for each additional remote node you wish to deploy


!!! warning
    If EdgeX core services are restarted, then services on each remote node must also be restarted!

## Testing and execution of REST APIs
1. Download [get-api-gateway-token.sh][get-api-gateway-token] script
2. Navigate to [`edgex-examples/security/remote_devices/spiffe_and_ssh/local`][spiffe_and_ssh_local] and
   copy over the downloaded [`get-api-gateway-token.sh`][get-api-gateway-token] script
3. Run `./get-api-gateway-token.sh` to retrieve secure token to run rest apis
4. Run curl command to get all connected usb cameras on remote node
    ```bash
    curl --location --request GET 'http://<local system ip>:59881/api/v3/device/service/name/device-usb-camera_<instance number>' \
        --header 'Authorization: Bearer <secret token retrieved in above step>' \
        --data-raw ''
    ```
5. Run curl command to get specific camera info
    ```bash
    curl --location --request GET 'http://<local system ip>:59882/api/v3/device/name/<camera name>/CameraInfo' \
        --header 'Authorization: Bearer <security token>' \
        --data-raw ''
    ```

!!! Info
    You can download the full device-usb-camera Postman collection from [device-usb-service repo][ds-usb-docs] in order to explore and run other APIs


[ds-usb-docs]: https://github.com/edgexfoundry/device-usb-camera/tree/{{edgexversion}}/docs
[get-api-gateway-token]: https://github.com/edgexfoundry/edgex-compose/blob/{{edgexversion}}/compose-builder/get-api-gateway-token.sh
[edgex-compose]: https://github.com/edgexfoundry/edgex-compose
[spiffe_and_ssh]: https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/security/remote_devices/spiffe_and_ssh
[spiffe_and_ssh_remote]: https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/security/remote_devices/spiffe_and_ssh/remote
[spiffe_and_ssh_local]: https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/security/remote_devices/spiffe_and_ssh/local
[local_compose]: https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/security/remote_devices/spiffe_and_ssh/local/docker-compose.yml
[remote_compose]: https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/security/remote_devices/spiffe_and_ssh/remote/docker-compose.yml