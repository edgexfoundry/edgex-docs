# Security for EdgeX Stack

This page shows how to secure communication between core EdgeX services and various device services by utilizing docker swarm to create an encrypted overlay network between two hosts.  We are showcasing two interesting concepts here.  

1) Securing the traffic between core and device services
2) Setting up an EdgeX Stack cross platform using docker swarm

## Docker Swarm Overlay Network

Docker's overlay network driver is a software abstraction on top of physical networking hardware to link multiple nodes together in a distributed network. This allows nodes/containers running on the network to communicate securely, if encryption is in enabled. Overlay network encryption is not supported on Windows.

We created two docker swarm nodes for this example a manager node and a worker node.  The manager node is running all of the core EdgeX services and the worker node runs the device services.  Using the docker daemon's overlay network abstraction and enabling security we can have secure communication between these nodes.

![image](overlay-network.png)


## Reference implementation example

The reference implementation example can be found in this repository:
[Reference example device-service docker-swarm overlay network](https://github.com/edgexfoundry/edgex-examples/tree/swarm/security/remote_devices/docker-swarm)

### Setup remote running Virtual Machine

In this example setup, similar to the the [SSH example](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/security/Ch-SSH-Tunneling-HowToSecureDeviceServices.md), `vagrant` is used on the top of `Virtual Box` to set up the secondary/remote VM.

Download vagrant from Hashicorp website or if you're on Ubuntu via `sudo apt install virtualbox` and `sudo apt install vagrant`.  We have a simple vagrant file used for this tutorial [here](https://github.com/edgexfoundry/edgex-examples/blob/swarm/security/docker-swarm/docker-swarm/Vagrantfile)

This vagrant file sets the hostname for the new VM and installs docker.

### Getting the VM running

- Launch the worker node or VM if it is not yet running:

This will create the VM select your network interface and let the prompt continue.  Once the prompt finishes, ignore the VMs popup window, we will be login in via SSH in the next step.

```sh
vagrant up
```

- ssh into the worker node via from your host's terminal:

```sh
vagrant ssh
```

This will give you a terminal prompt in the worker node where you will run the `sudo docker swarm join` command in a few steps.

### Connecting the swarm nodes

With the VM up and running we need to connect the two nodes using docker swarm.

This guide assumes that your account is a member of the 'docker' group. If not, run

```sh
sudo usermod -a -G docker $USER
```

Then log out and log back in to take on the new group.


The following command initializes a docker swarm and is to be ran on the host machine: 

```sh
docker swarm init --advertise-addr <your host ip address>
```

The previous command will output a token use this token in the following join command.  This joins the worker node to the cluster, to be ran your vagrant VM (worker-node):

```sh
docker swarm join --token <token> <manager ip address>:2377
```

Next, I will walk-through the changes we made to the `docker-compose.yml`
file to convert the EdgeX compose file into a docker swarm stack file.
(A snapshot of the original is stored as `docker-compose.yml.original` in the examples.)

### Setting up the docker-stack-edgex.yml file

All of the following changes are already done in the examples repo.  I will just outline the necessary changes to go from a compose file to stack file.

First, remove 'restart' command from compose file; 'restart' is not a valid command in docker swarm.
The default is to always restart.
One exception is `proxy-setup` service,
which is a single-shot job that should only restart on failure:

```yaml
    deploy:
      restart_policy:
        condition: on-failure
```

Next, we convert from a bridged network to an encrypted overlay network.
Network encryption is critical, since the EdgeX assumes a single-host deployment
by default where network protections are not required.

```
<     driver: bridge
---
>     driver: overlay
>     driver_opts:
>       encrypted: ""
```

Next, we define constraints that the edgex core services must not run on the worker node add this section of yml to the 'docker-stack-edgex.yml'.  We will do the inverse for the device-service to ensure it does run on the worker node thus ensuring it uses the overlay network to communicate with the other services.  Note that this is already done in the example directory.

```yaml
    deploy: 
      placement: 
        constraints: 
          - node.hostname != worker-node
```
Here is the inverse of the previous yml block. This gets added to the device services in the stack file. 

```yaml
    deploy: 
      placement: 
        constraints: 
          - node.hostname == worker-node
```

These work because we set the 'hostname = worker-node' in the Vagrantfile.

### Volumes

In secure mode, a shared volume, such as might be provided by NFS or GlusterFS,
is needed to distribute the secret store token for the device service.
Volumes defined using the default Docker Swarm driver are local to the node,
and cannot be remotely accessed.

For simplicity, we will just make a secrets volume that holds all of
the microservice secrets for the primary node.
A production deployment should have a secrets volume per-microservice.

Here is an example substitution:

```text
<     - /tmp/edgex/secrets/core-command:/tmp/edgex/secrets/<service-name>:ro,z
---
>     - edgex-secrets:/tmp/edgex/secrets
```

Without using a network file system,
the only secrets volume will be populated will be the one
that exists on the node where security-secretstore-setup runs.
The example will work around this limitation for demo purposes.

The following syntax is not supported and is removed:
- Localhost port mappings
- `security_opt`
- `container_name`

Host port mappings are slightly different,
needing to use a long port syntax:

For example:

```text
<     container_name: edgex-core-something
<     ports:
<     - 127.0.0.1:59###:59###/tcp
<     - 8443:8443/tcp
<     security_opt:
<     - no-new-privileges:true
---
>     - published: 8443
>       target: 8443
>       mode: host
```

The next and final change in the stack yml file is to ensure the EdgeX services are binding to the correct host.  Since Geneva we do this by adding a common variable `Service_ServerBindAddr: "0.0.0.0"` to ensure that the service will bind to any host and not be limited to the hostname. 

The above discussion covers most but not all of the changes.

The full docker-stack file is included here:

[docker-stack-edgex.yml file](https://github.com/edgexfoundry/edgex-examples/security/remote_devices/docker-swarm/docker-stack-edgex.yml)

 
### Running the docker stack file

With all of these changes in place we are ready to run the stack file.

```sh
docker stack deploy --compose-file docker-stack-edgex.yml edgex
```

Once the stack is up you can run the following command to view the running services: 

```sh
docker stack services edgex
```

In the example, you will notice the `device-virtual` is in a restart loop
due to an inability to obtain a secret store token.
A production solution would use a network file system to share the secret.

The workaround is a pair of helper scripts:

On the main node:

```sh
$ ./gettoken.sh 
{"auth":{"accessor":"oam6cHfpyLCMO1p4KzpKuj1u","client_token":"s.<redacted>","entity_id":"","lease_duration":3600,"metadata":{"edgex-service-name":"device-virtual"},"orphan":true,"policies":["default","edgex-service-device-virtual"],"renewable":true,"token_policies":["default","edgex-service-device-virtual"],"token_type":"service"},"data":null,"lease_duration":0,"lease_id":"","renewable":false,"request_id":"ec42b65c-c878-34a6-4903-8b01f6a999b3","warnings":null,"wrap_info":null}
```

Copy the output and then on the remote node:

```sh
$ ./puttoken.sh
<paste the output of gettoken.sh>
```

If done within an hour of bringing up the stack,
this should enable `device-virtual` to run.


### Confirming results

To ensure the device service is running on the worker node you can run the `docker stack ps edgex` command. Now check that you see the device service running on the `worker-node` while all of the other services are running on your host.

We have encryption enabled but how to we confirm that the overlay network is encrypting our data?  

We can use `tcpdump` with a protocol filter for ESP (Encapsulating Security Payload) traffic on the worker node this allows us to sniff and ensure the traffic is coming over the expected encrypted protocol. Adding a `-A` flag would also highlight that the data is not in the HTTP protocol format.

`sudo tcpdump -p esp`

### Tearing everything down

To remove the stack run the command:

```sh
docker stack rm edgex
```

This will remove the volumes and the stack.

To remove the swarm itself run: on the worker node `docker swarm leave`  and on the host machine `docker swarm leave --force`.

To remove the vagrant VM run `vagrant destroy` on the host.