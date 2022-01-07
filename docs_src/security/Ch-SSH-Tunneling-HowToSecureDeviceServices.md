# Security for EdgeX Stack

This page describes one of many options to secure the EdgeX software stack with running remote device services like device-virtual, device-rest, device-mqtt, and so on, via secure two-way SSH-tunnelings.

## Basic SSH-Tunneling

In this option to secure the EdgeX software stack, SSH tunneling is utilized. The basic idea is to create a secure SSH connection between a local machine and a remote machine in which some micro-services or applications can be relayed.   In this particular example, the local machine as the primary host is running the whole EdgeX core services including core services and security services but **without** any device service.  The device services are running in the remote machine.  

The communication is secure because SSH port forwarding connection is encrypted by default.

The SSH communication is established by introducing some extra SSH-related services:

1) `device-ssh-proxy`: this is the service with ssh client opening up the SSH communication between the local machine and the remote one

2) `device-ssh-remote`: this is actually the SSH server or daemon service together with device services running on the remote machine

The high-level diagram is shown as follows:

![image](ssh-tunneling_device.png)

"Top level diagram for SSH tunneling for device services"

In the local machine, the SSH tunneling handshake is initiated by `device-ssh-proxy` service to the remote running device services.  The dependencies that remote device services needed are reversely tunneling back from the local machine.

## Reference implementation example

The whole reference implementation example can be found in this repository:
<https://github.com/edgexfoundry/edgex-examples/tree/main/security/remote_devices/ssh-tunneling>

### Setup remote running Virtual Machine

In the example setup, `vagrant` is used on the top of `Virtual Box` to set up as the secondary/remote VM. The network port for ssh standard port 22 is mapped into 2222 for `vagrant ssh` itself and the forwarded port is also mapped on the VM network for port 2223 to the host machine port 2223.  This port 2223 is used for the ssh daemon Docker container that will be introduced later on below.

Once you have downloaded the vagrant from Hashicorp website, typical vagrant setup for the first time can be done via command `./vagrant init` and it will generate the Vagrant configuration file.

The `Vagrantfile` can be found in the aforementioned GitHub repository.

### SSH Tunneling: Setup the SSH server on the remote machine

For an example of how to run a SSH server in Docker, checkout <https://docs.docker.com/engine/examples/running_ssh_service/> for detailed instructions.

Running `sshd` in Docker is a container anti-pattern,
as one can enter a container for remote administration
using `docker exec`.
In this use case, however,
we are not using `sshd` for remote administration,
but instead to set up a network tunnel.

The `generate-keys.sh` helper script generates an RSA keypair,
and copies the `authorized_keys` file into the
`remote/sshd-remote` folder.
The sample's `Dockerfile` will then build this key into the the
remote `sshd` container image and use it for authentication.


### SSH Tunneling: Local Port Forwarding

In this use case, we want to impersonate a device service
that is running on a remote machine.
We use local port forwarding to receive inbound requests
on the device service's port,
and ask that the traffic be forwarded
through the ssh tunnel
to a remote host and a remote port.
The -L flag of ssh command is important here.

```sh
  ssh -N \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -L *:$SERVICE_PORT:$SERVICE_HOST:$SERVICE_PORT \
    -p $TUNNEL_SSH_PORT \
    $TUNNEL_HOST 
```

where environment variables are:

- `TUNNEL_HOST` is the remote host name or IP address that SSH daemon or server is running on;

- `TUNNEL_SSH_PROT` is the port number to be used on the SSH tunnel communication between the local machine and the remote machine

- `SERVICE_PORT` is the port number from the local or the primary to be forwared to the remote machine; without lose of generality, the port number on the remote machine is the same as the local one

- `SERVICE_HOST` is the service host name or IP address of the Docker containers that are running on the remote machine;

### SSH Reverse Tunneling: Remote Port Forwarding

This step is to show the reverse direction of SSH tunneling: from the remote back to the local machine.

The reverse SSH tunneling is also needed because the device services depends on the core services like `core-data`, `core-metadata`, Redis (for message queuing), Vault (for the secret store), and Consul (for registry and configuration).
These core services are running on the local machine and should be **reverse** tunneled back from the remote machine.
Essentially, the `sshd` container will impersonate these services
on the remote side.
This can be achieved by using `-R` flag of ssh command.

```sh
  ssh -N \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -R 0.0.0.0:$SECRETSTORE_PORT:$SECRETSTORE_HOST:$SECRETSTORE_PORT \
    -R 0.0.0.0:6379:$MESSAGEQUEUE_HOST:6379 \
    -R 0.0.0.0:8500:$REGISTRY_HOST:8500 \
    -R 0.0.0.0:5563:$CLIENTS_CORE_DATA_HOST:5563 \
    -R 0.0.0.0:59880:$CLIENTS_CORE_DATA_HOST:59880 \
    -R 0.0.0.0:59881:$CLIENTS_CORE_METADATA_HOST:59881 \
    -p $TUNNEL_SSH_PORT \
    $TUNNEL_HOST 
```

where environment variables are:

- `TUNNEL_HOST` is the remote host name or IP address that SSH daemon or server is running on;

In the reverse tunneling, the service host names of dependent services are used like `edgex-core-data`, for example.

### Security: EdgeX Secret Store Token

One last detail that needs to be taken care of is to copy the EdgeX secret store token to the remote machine.
This is needed in order for the remote service to get access to the EdgeX secret store
as well as the registry and configuration provider.

This is done by copying the tokens over SSH to the remote machine
prior to initiating the port-forwarding describe above.

```sh
  scp -p \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -P $TUNNEL_SSH_PORT \
    /tmp/edgex/secrets/device-virtual/secrets-token.json $TUNNEL_HOST:/tmp/edgex/secrets/device-virtual/secrets-token.json
  ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -p $TUNNEL_SSH_PORT \
    $TUNNEL_HOST -- \
    chown -Rh 2002:2001 /tmp/edgex/secrets/device-virtual
```

### Put it all together

#### Remote host

If you don't have a remote host already,
and have Vagrant and VirtualBox installed,
you can use the Vagrant CLI to start a VM:

Launch the remote machine or VM if it is not yet:

```sh
~/vm/vagrant up
```

and ssh into the remote machine via `~/vm/vagrant ssh`


Make sure the `edgex-examples` repository is checked
out to both the local and remote machines.

In the local machine, run the `generate-keys.sh`
helper script to generate an `id_rsa` and `id_rsa.pub`
to the current directory.
Copy these files to the same relative location
on the remote machine as well
so that both machines have access to the same keypair,
and run `generate-keys.sh` on the remote machine as well.
The keypair won't be overwritten,
but an `authorized_keys` file for the remote side will
be generated and copied to the appropriate location.

On the remote machine,
change directories into the `remote` folder and
bring up the example stack:

```sh
$ cd security/remote_devices/ssh-tunneling/remote
$ docker-compose -f docker-compose.yml up --build -d
```

This command will build the remote sshd container,
with the public key embedded,
and start up the device-virtual service.
The device-virtual service will sit in a crash/retry
loop until the ssh tunnel is initiated from the local side.

It is interesting to note how the remote sshd
impersonates as several different hosts that
actualy exist on the local side.
This is where reverse tunneling comes in to play.

```yaml
  sshd-remote:
    image: edgex-sshd-remote:latest
    build:
      context: sshd-remote
    container_name: edgex-sshd-remote
    hostname: edgex-sshd-remote
    ports:
    - "2223:22"
    read_only: true
    restart: always
    security_opt:
    - no-new-privileges:true
    networks:
      edgex-network:
        aliases:
        - edgex-core-consul
        - edgex-core-data
        - edgex-core-metadata
        - edgex-redis
        - edgex-vault
    tmpfs:
    - /run
    volumes:
    - /tmp/edgex/secrets/device-virtual:/tmp/edgex/secrets/device-virtual
```



On the local machine,
change directories into the `local` folder and
bring up the example stack:

```sh
$ cd security/remote_devices/ssh-tunneling/local
$ docker-compose -f docker-compose.yml up --build -d
```

The `docker-compose.yml` is a modified version of
the orginal `docker-compose.original` with the
following modifications:

* The original device-virtual service is commented out
* A `device-ssh-proxy` service is started in its place.
  This new service appears as `edgex-device-virtual`
  on the local network.
  It's job is to initiate the remote tunnel and
  forward network traffic in both directions.

You will need to modify `TUNNEL_HOST`
in the `docker-compose.yaml` to be the IP address
of the remote host.


#### Test with the device-virtual APIs

Mainly run curl or postman directly from the local machine to the device-virtual APIs to verify the remote device virtual service can be accessible from the local host machine via two-way SSH tunneling. This can be checked from the console of the local machine:

the ping response of calling edgex-device-virtual's ping action:

```sh
jim@jim-NUC7i5DNHE:~/go/src/github.com/edgexfoundry/developer-scripts/releases/geneva/compose-files$ curl http://localhost:59900/api/v2/ping

1.2.0-dev.13j

```

or see the configuration of it via `curl` command:

```sh
jim@jim-NUC7i5DNHE:~/go/src/github.com/edgexfoundry/developer-scripts/releases/geneva/compose-files$ curl http://localhost:59900/api/v2/config
```

```json
{"Writable":{"LogLevel":"INFO"},"Clients":{"Data":{"Host":"localhost","Port":48080,"Protocol":"http"},"Logging":{"Host":"localhost","Port":48061,"Protocol":"http"},"Metadata":{"Host":"edgex-core-metadata","Port":48081,"Protocol":"http"}},"Logging":{"EnableRemote":false,"File":""},"Registry":{"Host":"edgex-core-consul","Port":8500,"Type":"consul"},"Service":{"BootTimeout":30000,"CheckInterval":"10s","ClientMonitor":15000,"Host":"edgex-device-virtual","Port":59900,"Protocol":"http","StartupMsg":"device virtual started","MaxResultCount":0,"Timeout":5000,"ConnectRetries":10,"Labels":[],"EnableAsyncReadings":true,"AsyncBufferSize":16},"Device":{"DataTransform":true,"InitCmd":"","InitCmdArgs":"","MaxCmdOps":128,"MaxCmdValueLen":256,"RemoveCmd":"","RemoveCmdArgs":"","ProfilesDir":"./res","UpdateLastConnected":false,"Discovery":{"Enabled":false,"Interval":""}},"DeviceList":[{"Name":"Random-Boolean-Device","Profile":"Random-Boolean-Device","Description":"Example of Device Virtual","Labels":["device-virtual-example"],"Protocols":{"other":{"Address":"device-virtual-bool-01","Port":"300"}},"AutoEvents":[{"frequency":"10s","resource":"Bool"}]},{"Name":"Random-Integer-Device","Profile":"Random-Integer-Device","Description":"Example of Device Virtual","Labels":["device-virtual-example"],"Protocols":{"other":{"Address":"device-virtual-int-01","Protocol":"300"}},"AutoEvents":[{"frequency":"15s","resource":"Int8"},{"frequency":"15s","resource":"Int16"},{"frequency":"15s","resource":"Int32"},{"frequency":"15s","resource":"Int64"}]},{"Name":"Random-UnsignedInteger-Device","Profile":"Random-UnsignedInteger-Device","Description":"Example of Device Virtual","Labels":["device-virtual-example"],"Protocols":{"other":{"Address":"device-virtual-uint-01","Protocol":"300"}},"AutoEvents":[{"frequency":"20s","resource":"Uint8"},{"frequency":"20s","resource":"Uint16"},{"frequency":"20s","resource":"Uint32"},{"frequency":"20s","resource":"Uint64"}]},{"Name":"Random-Float-Device","Profile":"Random-Float-Device","Description":"Example of Device Virtual","Labels":["device-virtual-example"],"Protocols":{"other":{"Address":"device-virtual-float-01","Protocol":"300"}},"AutoEvents":[{"frequency":"30s","resource":"Float32"},{"frequency":"30s","resource":"Float64"}]},{"Name":"Random-Binary-Device","Profile":"Random-Binary-Device","Description":"Example of Device Virtual","Labels":["device-virtual-example"],"Protocols":{"other":{"Address":"device-virtual-bool-01","Port":"300"}},"AutoEvents":null}],"Driver":{}}
```

One can also monitor the docker log messages of core-data on the local machine too see if it publishes the events to the bus:

```sh

$ docker logs -f edgex-core-data

level=INFO ts=2020-06-10T00:49:26.579819548Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:26.579909649Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 4dc57d03-178e-49f5-a799-67813db9d85b "
level=INFO ts=2020-06-10T00:49:27.107028244Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:27.107128916Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 2a0fd8fa-bb16-4d1a-ba1b-c5e70e1a1cec "
level=INFO ts=2020-06-10T00:49:27.376915392Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:27.377084206Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 76d288e2-a2e8-4ed4-9265-986661b71bbe "
level=INFO ts=2020-06-10T00:49:27.718042678Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:27.718125128Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: f5412a38-0346-4bd3-b9da-69498e4edb9a "
level=INFO ts=2020-06-10T00:49:30.49407257Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:30.494162219Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: da54fcc9-4771-4e0f-9eff-e0d2067eac7e "
level=INFO ts=2020-06-10T00:49:31.204976003Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:31.205211102Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 08574f61-6ea3-49cf-a776-028876de7957 "
level=INFO ts=2020-06-10T00:49:31.778242016Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:31.778342992Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: f1630f13-6fa7-45a6-b6f6-6bbde159b414 "
level=INFO ts=2020-06-10T00:49:34.747901983Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:34.748045382Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: cf14c573-60b9-43cd-b95b-2c6ffe26ba20 "
level=INFO ts=2020-06-10T00:49:34.944758331Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:34.9449585Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 292b9ca7-a640-4ac8-8650-866b7c4a6d15 "
level=INFO ts=2020-06-10T00:49:37.421202715Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:37.421367863Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: bb7a34b1-c65f-4820-91a3-162903ac1e7a "
level=INFO ts=2020-06-10T00:49:42.290660694Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:42.290756356Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 8fff92c0-ef69-4758-bf8a-3492fb48cef2 "
level=INFO ts=2020-06-10T00:49:42.559019764Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:42.559105855Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 12947a42-4669-4bff-8720-d0e9fbeef343 "
level=INFO ts=2020-06-10T00:49:44.922764379Z app=edgex-core-data source=event.go:284 msg="Putting event on message queue"
level=INFO ts=2020-06-10T00:49:44.922848184Z app=edgex-core-data source=event.go:302 msg="Event Published on message queue. Topic: events, Correlation-id: 3c07ce76-203a-4bf5-ab89-b99a1fbbb266 "


```

and also do the docker log messages of device-virtual container on the remote:

```sh
vagrant@ubuntu-bionic:~/geneva$ docker logs -f edgex-device-virtual

level=INFO ts=2020-06-10T00:51:52.602154238Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=3d86a699-c089-412d-94f3-af6cd9093f28 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:53.358352349Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=9612b186-98cb-4dc5-887a-195ce7300978 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:57.649085447Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=da682ffb-9120-4286-9f33-aa0a9f2c0489 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:57.86899148Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=afc1fccf-de8a-46ce-9849-82c5e4e5837e msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:59.543754189Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=80ac32a0-3a9a-4b07-bf3f-b26ec159dc40 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:59.688746606Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=21501030-c07c-4ac4-a2d2-1243782cb4b8 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:51:59.853069376Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=3b2927db-e689-4fad-8d53-af6fe20239f8 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:00.055657757Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=a7698f2d-a115-4b46-af5f-3b8bf77e6ea4 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:04.460557145Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=602efd03-8e9d-441b-9a7d-45dbcb6b416f msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:07.696983268Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=88190186-6f93-4c6a-a1f6-d6a20a6e79e4 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:08.040474761Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=73c60159-f50c-480b-90da-ebe310fa2f6e msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:08.2091048Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=2d799509-dc1d-4075-b193-1e5da24cfa77 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:12.751717832Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=7611a188-23f4-44d0-bd12-f6574535be8d msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:13.553351482Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=a32067c8-adae-4778-b72d-0d8d7d11220f msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:15.20395683Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=41df0427-5998-4d1e-9c26-1f727912638b msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:15.686970839Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=c6a8bb2d-22ab-4932-bdd0-138f12f843b6 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:18.177810023Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=a49d663b-1676-4ecf-ba52-76e9ad7c501d msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:19.600220653Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=b6d2c2d1-5d5c-4f7a-9dd2-2067e732f018 msg="SendEvent: Pushed event to core data"
level=INFO ts=2020-06-10T00:52:19.990751025Z app=device-virtual source=utils.go:94 Content-Type=application/json correlation-id=1db5dde3-bb6b-4600-abbb-d01b3042c329 msg="SendEvent: Pushed event to core data"

```

Test to get random integer value of the remote device-virtual random integer device from the local machine using `curl` command like this:

```sh
jim@jim-NUC7i5DNHE:~/go/src/github.com/edgexfoundry/device-virtual-go$ curl -k http://localhost:59900/api/v2/device/name/Random-Integer-Device/Int8
{"device":"Random-Integer-Device","origin":1592432603445490720,"readings":[{"origin":1592432603404127336,"device":"Random-Integer-Device","name":"Int8","value":"11","valueType":"Int8"}],"EncodedEvent":null}
```
