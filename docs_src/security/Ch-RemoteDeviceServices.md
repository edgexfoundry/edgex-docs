# Remote Device Services in Secure Mode

This page describes the remote device service example in the
`edgex-examples` GitHub repository.

Running a remote device service poses several problems
when EdgeX is running in secure mode:

- Network traffic between the primary EdgeX node and the remote
  device service node is unencrypted.
   
- The remote device service will not have a Consul authentication token
  that allows it to talk to the registry and configuration services.

- The remote device service will not have a secret store token that
  allows access to the EdgeX secret store (which is also needed to
  obtain a Consul authentication token).

This example will resolve the above complications by

1. Creating secure SSH network tunnel between nodes to encrypt
   network communication.

2. Use the delayed start feature introduced in EdgeX Kamakura to
   lasily obtain a secret store token that will grant the device
   service access to the EdgeX secret store, EdgeX registry service,
   and EdgeX configuration service.

## Running the Example

First, clone the `edgex-examples repository`, checkout `{{latest_released_version}}` and change to the
`security/remote_devices/spiffe_and_ssh` directory.

Next, run the `generate_keys.sh` script to generate an SSH
keypair for the SSH tunnel.
This keypair is used only for the SSH tunnel
and should have no other privileges.

Once the `generate_keys.sh` script has been run,
copy the `remote` folder to the remote device service machine.

### On the Local Machine

Change directories to the `local` folder.

Edit `docker-compose.yml` and change the `TUNNEL_HOST`
environment variable to the IP address of the remote node.

Run

```shell
$ docker-compose build
$ docker-compose up -d
```

After the framework has been built and is running,
check the `device-ssh-proxy` service

```shell
$ docker ps -a | grep device-ssh-proxy
a92ff2d6999c device-ssh-proxy:latest "/edgex-init…"   2 minutes ago   Restarting (1) 16 seconds ago edgex-device-ssh-proxy
$ docker logs device-ssh-proxy
+ scp -p -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -P 2223 /srv/spiffe/remote-agent/agent.key 192.168.122.193:/srv/spiffe/remote-agent/agent.key
ssh: connect to host 192.168.122.193 port 2223: Connection refused
lost connection
```

The SSH connection will continue to fail until the remote node is brought up.

Next, authorize the workload running on the remote node.

```shell
$ ./add-server-entry.sh
Entry ID         : f62bfec6-b19c-43ea-94b8-975f7e9a258e
SPIFFE ID        : spiffe://edgexfoundry.org/service/device-virtual
Parent ID        : spiffe://edgexfoundry.org/spire/agent/x509pop/cn/remote-agent
Revision         : 0
TTL              : default
Selector         : docker:label:com.docker.compose.service:device-virtual
DNS name         : edgex-device-virtual
```

That is all to be done on the local node.


### On the Remote Machine

Change directories to the `remote` folder and run

```shell
$ docker-compose build
$ docker-compose up -d
```

After the framework has been built and is running for about a minute,
check the `device-virtual` service

```shell
$ docker logs -f edgex-device-virtual
level=INFO ts=2022-05-05T14:28:30.005673094Z app=device-virtual source=config.go:391 msg="Loaded service configuration from ./res/configuration.yaml"
level=INFO ts=2022-05-05T14:28:30.006211643Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.Port' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_PORT=59841"
level=INFO ts=2022-05-05T14:28:30.006286584Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.Protocol' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_PROTOCOL=https"
level=INFO ts=2022-05-05T14:28:30.006341968Z app=device-virtual source=variables.go:352 msg="Variables override of 'Clients.core-metadata.Host' by environment variable: CLIENTS_CORE_METADATA_HOST=edgex-core-metadata"
level=INFO ts=2022-05-05T14:28:30.006382102Z app=device-virtual source=variables.go:352 msg="Variables override of 'MessageQueue.Host' by environment variable: MESSAGEQUEUE_HOST=edgex-redis"
level=INFO ts=2022-05-05T14:28:30.006416098Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.EndpointSocket' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_ENDPOINTSOCKET=/tmp/edgex/secrets/spiffe/public/api.sock"
level=INFO ts=2022-05-05T14:28:30.006457406Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.RequiredSecrets' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_REQUIREDSECRETS=redisdb"
level=INFO ts=2022-05-05T14:28:30.006495791Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.Enabled' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED=true"
level=INFO ts=2022-05-05T14:28:30.006529808Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.Host' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_HOST=edgex-security-spiffe-token-provider"
level=INFO ts=2022-05-05T14:28:30.006575741Z app=device-virtual source=variables.go:352 msg="Variables override of 'Clients.core-data.Host' by environment variable: CLIENTS_CORE_DATA_HOST=edgex-core-data"
level=INFO ts=2022-05-05T14:28:30.006617026Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.Host' by environment variable: SECRETSTORE_HOST=edgex-vault"
level=INFO ts=2022-05-05T14:28:30.006650922Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.Port' by environment variable: SECRETSTORE_PORT=8200"
level=INFO ts=2022-05-05T14:28:30.006691769Z app=device-virtual source=variables.go:352 msg="Variables override of 'SecretStore.RuntimeTokenProvider.TrustDomain' by environment variable: SECRETSTORE_RUNTIMETOKENPROVIDER_TRUSTDOMAIN=edgexfoundry.org"
level=INFO ts=2022-05-05T14:28:30.006729711Z app=device-virtual source=variables.go:352 msg="Variables override of 'Service.Host' by environment variable: SERVICE_HOST=edgex-device-virtual"
level=INFO ts=2022-05-05T14:28:30.006764754Z app=device-virtual source=variables.go:352 msg="Variables override of 'Registry.Host' by environment variable: REGISTRY_HOST=edgex-core-consul"
level=INFO ts=2022-05-05T14:28:30.006904867Z app=device-virtual source=secret.go:55 msg="Creating SecretClient"
level=INFO ts=2022-05-05T14:28:30.006953018Z app=device-virtual source=secret.go:62 msg="Reading secret store configuration and authentication token"
level=INFO ts=2022-05-05T14:28:30.006994824Z app=device-virtual source=secret.go:165 msg="runtime token provider enabled"
level=INFO ts=2022-05-05T14:28:30.007064786Z app=device-virtual source=methods.go:138 msg="using Unix Domain Socket at unix:///tmp/edgex/secrets/spiffe/public/api.sock"
```

If the workload was not authorized on the local side,
the output will stop as shown above.
The service would be hung waiting for a SPIFFE authentication token.

Since the local site was stuck in a retry loop trying to establish an
SSH connection to the remote, the service may stay stuck in this state
for several minutes until the network tunnels are established.

Otherwise the log would continue as follows:

```shell
level=INFO ts=2022-05-05T14:29:25.078483584Z app=device-virtual source=methods.go:150 msg="workload got X509 source"
level=INFO ts=2022-05-05T14:29:25.168325689Z app=device-virtual source=methods.go:120 msg="successfully got token from spiffe-token-provider!"
level=INFO ts=2022-05-05T14:29:25.169095621Z app=device-virtual source=secret.go:80 msg="Attempting to create secret client"
level=INFO ts=2022-05-05T14:29:25.172259336Z app=device-virtual source=secret.go:91 msg="Created SecretClient"
level=INFO ts=2022-05-05T14:29:25.172359472Z app=device-virtual source=secret.go:96 msg="SecretsFile not set, skipping seeding of service secrets."
level=INFO ts=2022-05-05T14:29:25.172539631Z app=device-virtual source=secrets.go:276 msg="kick off token renewal with interval: 30m0s"
level=INFO ts=2022-05-05T14:29:25.172433598Z app=device-virtual source=config.go:551 msg="Using local configuration from file (14 envVars overrides applied)"
level=INFO ts=2022-05-05T14:29:25.172916142Z app=device-virtual source=httpserver.go:131 msg="Web server starting (edgex-device-virtual:59900)"
level=INFO ts=2022-05-05T14:29:25.172948285Z app=device-virtual source=messaging.go:69 msg="Setting options for secure MessageBus with AuthMode='usernamepassword' and SecretName='redisdb"
level=INFO ts=2022-05-05T14:29:25.174321296Z app=device-virtual source=messaging.go:97 msg="Connected to redis Message Bus @ redis://edgex-redis:6379 publishing on 'edgex/events/device' prefix topic with AuthMode='usernamepassword'"
level=INFO ts=2022-05-05T14:29:25.174585076Z app=device-virtual source=init.go:135 msg="Check core-metadata service's status by ping..."
level=INFO ts=2022-05-05T14:29:25.176202842Z app=device-virtual source=init.go:54 msg="Service clients initialize successful."
level=INFO ts=2022-05-05T14:29:25.176377929Z app=device-virtual source=clients.go:124 msg="Using configuration for URL for 'core-metadata': http://edgex-core-metadata:59881"
level=INFO ts=2022-05-05T14:29:25.176559116Z app=device-virtual source=clients.go:124 msg="Using configuration for URL for 'core-data': http://edgex-core-data:59880"
level=INFO ts=2022-05-05T14:29:25.176806351Z app=device-virtual source=restrouter.go:55 msg="Registering v2 routes..."
level=INFO ts=2022-05-05T14:29:25.192658275Z app=device-virtual source=service.go:230 msg="device service device-virtual exists, updating it"
level=INFO ts=2022-05-05T14:29:25.195403199Z app=device-virtual source=profiles.go:54 msg="Loading pre-defined profiles from /res/profiles"
level=INFO ts=2022-05-05T14:29:25.197297762Z app=device-virtual source=profiles.go:88 msg="Profile Random-Binary-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.240099318Z app=device-virtual source=profiles.go:88 msg="Profile Random-Boolean-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.24221092Z app=device-virtual source=profiles.go:88 msg="Profile Random-Float-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.245516797Z app=device-virtual source=profiles.go:88 msg="Profile Random-Integer-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.250310838Z app=device-virtual source=profiles.go:88 msg="Profile Random-UnsignedInteger-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.250961547Z app=device-virtual source=devices.go:49 msg="Loading pre-defined devices from /res/devices"
level=INFO ts=2022-05-05T14:29:25.252216571Z app=device-virtual source=devices.go:85 msg="Device Random-Boolean-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.252274853Z app=device-virtual source=devices.go:85 msg="Device Random-Integer-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.252290321Z app=device-virtual source=devices.go:85 msg="Device Random-UnsignedInteger-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.252297541Z app=device-virtual source=devices.go:85 msg="Device Random-Float-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.252304305Z app=device-virtual source=devices.go:85 msg="Device Random-Binary-Device exists, using the existing one"
level=INFO ts=2022-05-05T14:29:25.252698155Z app=device-virtual source=autodiscovery.go:33 msg="AutoDiscovery stopped: disabled by configuration"
level=INFO ts=2022-05-05T14:29:25.252726349Z app=device-virtual source=autodiscovery.go:42 msg="AutoDiscovery stopped: ProtocolDiscovery not implemented"
level=INFO ts=2022-05-05T14:29:25.252736451Z app=device-virtual source=message.go:50 msg="Service dependencies resolved..."
level=INFO ts=2022-05-05T14:29:25.252804946Z app=device-virtual source=message.go:51 msg="Starting device-virtual {{latest_released_version}} "
level=INFO ts=2022-05-05T14:29:25.252817404Z app=device-virtual source=message.go:55 msg="device virtual started"
level=INFO ts=2022-05-05T14:29:25.252880346Z app=device-virtual source=message.go:58 msg="Service started in: 55.248960914s"
```

At this point, the remote device service is up and running in secure mode.


## SSH Tunneling Explained

In this example, SSH port forwarding is used to establish an encrypted network channel
between the local and remote nodes.
The local machine as the primary host is running the whole EdgeX core services including core services and security services but **without** any device service.
The device services are running on the remote machine.  

The SSH communication is established by introducing some extra SSH-related services:

1) `device-ssh-proxy`.  This service runs on the local machine an is an SSH client that initiates communication with the remote node.  The `device-ssh-proxy` service has the private key needed to establish the network connection and also authorizes the network tunnels.

2) `sshd-remote`.  This service runs on the remote machine and provides an SSH server for the purposes of establishing network communcation with the remote device service.

Running `sshd` in Docker is a container anti-pattern,
as one can enter a container for remote administration
using `docker exec`.
In this use case, however,
we are not using `sshd` for remote administration,
but instead to set up a network tunnel.

For an example of how to run a SSH server in Docker, checkout the [SPIFFE and SHH example](https://github.com/edgexfoundry/edgex-examples/tree/main/security/remote_devices/spiffe_and_ssh) for detailed instructions.

The `generate-keys.sh` helper script generates an RSA keypair,
and copies the `authorized_keys` file into the
`remote/sshd-remote` folder.
The sample's `Dockerfile` will then build this key into the the
remote `sshd` container image and use it for authentication.
The private key remains on the local machine and is bind-mounted
to the host from the `device-ssh-proxy` service.

### Local Port Forwarding

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

- `SERVICE_HOST` is the service host name or IP address of the Docker containers that are running on the remote machine

In order to make the other containers aware of the port forwarding,
the `docker-compose.yml` is configured to so that the `device-ssh-proxy` service
impersonates `edgex-device-virtual` on the local docker network.

```yaml
  device-ssh-proxy:
    image: device-ssh-proxy:latest
    networks:
      edgex-network:
        aliases:
        - edgex-device-virtual
```

The port-forwarding is transparent to the EdgeX services running on the local machine.

### Remote Port Forwarding

This step is to show the reverse direction of SSH tunneling: from the remote back to the local machine.

The reverse SSH tunneling is also needed because the device services depends on the core services like `core-data`, `core-metadata`, Redis (for message queuing), Vault (for the secret store), and Consul (for registry and configuration).
These core services are running on the local machine and should be **reverse** tunneled back from the remote machine.
Essentially, the `sshd` container will impersonate these services
on the remote side.
This can be achieved by using `-R` flag of ssh command.
Extending the previous example:

```sh
  ssh -N \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -L *:$SERVICE_PORT:$SERVICE_HOST:$SERVICE_PORT \
    -R 0.0.0.0:$SECRETSTORE_PORT:$SECRETSTORE_HOST:$SECRETSTORE_PORT \
    -R 0.0.0.0:6379:$MESSAGEQUEUE_HOST:6379 \
    -R 0.0.0.0:8500:$REGISTRY_HOST:8500 \
    -R 0.0.0.0:5563:$CLIENTS_CORE_DATA_HOST:5563 \
    -R 0.0.0.0:59880:$CLIENTS_CORE_DATA_HOST:59880 \
    -R 0.0.0.0:59881:$CLIENTS_CORE_METADATA_HOST:59881 \
    -R 0.0.0.0:$SECURITY_SPIRE_SERVER_PORT:$SECURITY_SPIRE_SERVER_HOST:$SECURITY_SPIRE_SERVER_PORT \
    -R 0.0.0.0:$SECRETSTORE_RUNTIMETOKENPROVIDER_PORT:$SECRETSTORE_RUNTIMETOKENPROVIDER_HOST:$SECRETSTORE_RUNTIMETOKENPROVIDER_PORT \
    -p $TUNNEL_SSH_PORT \
    $TUNNEL_HOST 
```

As was done on the local side, the remote side does in reverse,
masquerading on the network as the core services needed by
device services:

```yaml
  sshd-remote:
    image: edgex-sshd-remote:latest
    networks:
      edgex-network:
        aliases:
        - edgex-core-consul
        - edgex-core-data
        - edgex-core-metadata
        - edgex-redis
        - edgex-security-spire-server
        - edgex-security-spiffe-token-provider
        - edgex-vault
```


## Security: EdgeX Secret Store Token

Beyond port forwarding,
extra steps need to be taken to enable the remote device service
to use SPIFFE/SPIRE to obtain a token for the EdgeX secret store.

### Local side

On the local machine side, the `device-ssh-proxy` service has
some initialization code inserted into its entrypoint script.
It is done this way to facilitate ease-of-use for the example.
In a production deployment this should be done out-of-band.

```shell
# Wait for agent CA creation

while test ! -f "/srv/spiffe/ca/public/agent-ca.crt"; do
    echo "Waiting for /srv/spiffe/ca/public/agent-ca.crt"
    sleep 1
done

# Pre-create remote agent certificate

if test ! -f "/srv/spiffe/remote-agent/agent.crt"; then
    openssl ecparam -genkey -name secp521r1 -noout -out "/srv/spiffe/remote-agent/agent.key"
    SAN="" openssl req -subj "/CN=remote-agent" -config "/usr/local/etc/openssl.conf" -key "/srv/spiffe/remote-agent/agent.key" -sha512 -new -out "/run/agent.req.$$"
    SAN="" openssl x509 -sha512 -extfile /usr/local/etc/openssl.conf -extensions agent_ext -CA "/srv/spiffe/ca/public/agent-ca.crt" -CAkey "/srv/spiffe/ca/private/agent-ca.key" -CAcreateserial -req -in "/run/agent.req.$$" -days 3650 -out "/srv/spiffe/remote-agent/agent.crt"
    rm -f "/run/agent.req.$$"
fi


while true; do
  scp -p \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -P $TUNNEL_SSH_PORT \
    /srv/spiffe/remote-agent/agent.key $TUNNEL_HOST:/srv/spiffe/remote-agent/agent.key
  scp -p \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -P $TUNNEL_SSH_PORT \
    /srv/spiffe/remote-agent/agent.crt $TUNNEL_HOST:/srv/spiffe/remote-agent/agent.crt
  scp -p \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -P $TUNNEL_SSH_PORT \
    /tmp/edgex/secrets/spiffe/trust/bundle $TUNNEL_HOST:/tmp/edgex/secrets/spiffe/trust/bundle    
  ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -p $TUNNEL_SSH_PORT \
    $TUNNEL_HOST -- \
    chown -Rh 2002:2001 /tmp/edgex/secrets/spiffe

  ...
```

The one-time setup is generating a new agent key from the agent
CA certificate.  This will enable the SPIRE server to trust the new agent.
There is also automation to copy the certificate and private key
to the remote node as part of SSH session establishment.
This entire flow could be done as an out-of-band process.

The last part, which is to copy the current trust bundle
to the remote node as part of SSH session establishment,
should be left as-is, as the trust bundle is on a temp
file system and might be cleaned between reboots.

### Remote side

On the remote side, the SPIRE agent looks mostly like
the local side SPIRE agent, except that the paths are different,
and there is a delay loop waiting for the agent key and certificate
to be copied to the node via the above process.

The requirements for the remote side are:

- The SPIRE server must be able to establish trust in the agent.
  There are many mechanisms available to do this.
  The example uses a public key infrastructure to establish trust.

- The SPIRE agent must have network connectivity with the SPIRE server.
  This is provided by the SSH reverse proxy tunnel.


## Testing

### Test with the device-virtual APIs

The easiest way to test the setup is to make a call
from the local machine to the remote `device-virtual` service:

```shell
$ curl -s http://127.0.0.1:59900/api/v2/config | jq
{
  "apiVersion": "v2",
  "config": {
    "Writable": {
      "LogLevel": "INFO",
      "InsecureSecrets": {
        "DB": {
          "Path": "redisdb",
          "Secrets": {
            "password": "",
            "username": ""
          }
        }
      },
      "Reading": {
        "ReadingUnits": true
      }
    },
    "Clients": {
      "core-data": {
        "Host": "edgex-core-data",
        "Port": 59880,
        "Protocol": "http"
      },
      "core-metadata": {
        "Host": "edgex-core-metadata",
        "Port": 59881,
        "Protocol": "http"
      }
    },
    "Registry": {
      "Host": "edgex-core-consul",
      "Port": 8500,
      "Type": "consul"
    },
    "Service": {
      "HealthCheckInterval": "10s",
      "Host": "edgex-device-virtual",
      "Port": 59900,
      "ServerBindAddr": "",
      "StartupMsg": "device virtual started",
      "MaxResultCount": 0,
      "MaxRequestSize": 0,
      "RequestTimeout": "5s",
      "CORSConfiguration": {
        "EnableCORS": false,
        "CORSAllowCredentials": false,
        "CORSAllowedOrigin": "https://localhost",
        "CORSAllowedMethods": "GET, POST, PUT, PATCH, DELETE",
        "CORSAllowedHeaders": "Authorization, Accept, Accept-Language, Content-Language, Content-Type, X-Correlation-ID",
        "CORSExposeHeaders": "Cache-Control, Content-Language, Content-Length, Content-Type, Expires, Last-Modified, Pragma, X-Correlation-ID",
        "CORSMaxAge": 3600
      }
    },
    "Device": {
      "DataTransform": true,
      "MaxCmdOps": 128,
      "MaxCmdValueLen": 256,
      "ProfilesDir": "./res/profiles",
      "DevicesDir": "./res/devices",
      "Discovery": {
        "Enabled": false,
        "Interval": "30s"
      },
      "AsyncBufferSize": 16,
      "EnableAsyncReadings": true,
      "Labels": [],
      "UseMessageBus": true
    },
    "Driver": {},
    "SecretStore": {
      "Type": "vault",
      "Host": "edgex-vault",
      "Port": 8200,
      "Path": "device-virtual/",
      "Protocol": "http",
      "Namespace": "",
      "RootCaCertPath": "",
      "ServerName": "",
      "Authentication": {
        "AuthType": "X-Vault-Token",
        "AuthToken": ""
      },
      "TokenFile": "/tmp/edgex/secrets/device-virtual/secrets-token.json",
      "SecretsFile": "",
      "DisableScrubSecretsFile": false,
      "RuntimeTokenProvider": {
        "Enabled": true,
        "Protocol": "https",
        "Host": "edgex-security-spiffe-token-provider",
        "Port": 59841,
        "TrustDomain": "edgexfoundry.org",
        "EndpointSocket": "/tmp/edgex/secrets/spiffe/public/api.sock",
        "RequiredSecrets": "redisdb"
      }
    },
    "MessageQueue": {
      "Type": "redis",
      "Protocol": "redis",
      "Host": "edgex-redis",
      "Port": 6379,
      "PublishTopicPrefix": "edgex/events/device",
      "SubscribeTopic": "",
      "AuthMode": "usernamepassword",
      "SecretName": "redisdb",
      "Optional": {
        "AutoReconnect": "true",
        "ClientId": "device-virtual",
        "ConnectTimeout": "5",
        "KeepAlive": "10",
        "Password": "(redacted)",
        "Qos": "0",
        "Retained": "false",
        "SkipCertVerify": "false",
        "Username": "redis5"
      },
      "SubscribeEnabled": false
    },
    "MaxEventSize": 0
  },
  "serviceName": "device-virtual"
}
```