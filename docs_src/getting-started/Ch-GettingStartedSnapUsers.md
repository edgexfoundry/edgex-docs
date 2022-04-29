# Getting Started using Snaps

## Introduction

[Snaps](https://snapcraft.io/docs) are application packages that are easy to install and update while being 
secure, cross‐platform and self-contained.
Snaps can be installed on any Linux distribution with [snap support](https://snapcraft.io/docs/installing-snapd).

### Installation
When using the snap CLI, the installation is possible by simply executing:
```bash
snap install <snap-name>
```

This is similar to setting `--channel=latest/stable` or shorthand `--stable` and will install the latest stable release of a snap. In this case, `latest/stable` is the [channel](https://snapcraft.io/docs/channels), composed of `latest` track and `stable` risk level.

To install a specific version with long term support (LTS), or to install a beta
or development release, refer to the store page for the snap, choose install, and
then pick the desired channel.
The store page also provides instructions for installation on different Linux distributions as well as the list of supported CPU architectures.

For the list of EdgeX snaps, please refer [here](#edgex-snaps).

### Configuration
EdgeX snaps are packaged with default service configuration files. In certain cases, few configuration fields are overridden within the snap for snap-specific deployment requirements.

#### Configuration files
The default configuration files are typically placed at `/var/snap/<snap>/current/config`. Upon startup, the server configurations files are uploaded to Consul by default. The configuration file can be modified and applied only if the modifications happen before initial startup. 

#### Configuration registry
The configurations that are uploaded to Consul can be modified using Consul's UI or [kv REST API](https://www.consul.io/api/kv). Changes to configurations are loaded by the service at startup, except for the writable settings which are loaded at runtime. Please refer to the documentation of microservices for details. 

#### Configuration provider snaps
Most EdgeX snaps have a [content interface](https://snapcraft.io/docs/content-interface) which allows another snap to seed the snap with configuration files.
This is useful when replacing entire configuration files via another snap, packaged with the deployment-specific configurations.

Please refer to [edgex-config-provider](https://github.com/canonical/edgex-config-provider), for an example.

#### Configuration overrides
!!! edgey "EdgeX 2.2"
    The snaps now provide an interface to set any environment variable for supported services.
    We call these the *config options* because they use a `config` prefix for the variable names.
    The config options are **disabled by default**.

    This functionality supersedes for the snap *env options* (with `env.` prefix) which allows setting certain configurations. Please refer to EdgeX 2.1 (Jakarta) snap READMEs and documentation for details on the deprecated options.

    The env options are deprecated and have incomplete configuration coverage. Existing options will continue to work until the next major EdgeX release. At that point, the config options will become **enabled by default**.

The EdgeX services allow overriding server configurations using environment variables. Moreover, the services read EdgeX [Common Environment Variables](../../microservices/configuration/CommonEnvironmentVariables/) to change configurations that aren't defined in config files.
The EdgeX snaps provide an interface via [snap configuration options](https://snapcraft.io/docs/configuration-in-snaps) to set environment variables for the services.
We call these the *config options* because they a have `config` prefix for the variable names.

The snap options for setting environment variable uses the the following format:

* `apps.<app>.config.<env-var>`: setting an app-specific value (e.g. `apps.core-data.config.service-port=1000`).
* `config.<env-var>`: setting a global value (e.g. `config.service-host=localhost` or `config.writable-loglevel=DEBUG`

where:

* `<app>` is the name of the app (service, executable)
* `<env-var>` is a lowercase, dash-separated mapping to uppercase, underscore-separate environment variable name (e.g. `x-y`->`X_Y`). The reason for such mapping is that uppercase and underscore characters are not supported as config keys for snaps.

Mapping examples:

| Snap config key        | Environment Variable     | Service configuration TOML                          |
|------------------------|--------------------------|-----------------------------------------------------|
| service-port           | SERVICE_PORT             | [Service]<br>Port                                   |
| clients-core-data-host  | CLIENTS_CORE_DATA_HOST  | [Clients]<br>--[Clients.core-data]<br>--Host        |
| edgex-startup-duration | [EDGEX_STARTUP_DURATION] | -                                                   |
| add-secretstore-tokens | [ADD_SECRETSTORE_TOKENS] | -                                                   |

[EDGEX_STARTUP_DURATION]: ../../microservices/configuration/CommonEnvironmentVariables/#edgex_startup_duration
[ADD_SECRETSTORE_TOKENS]: ../../security/Ch-Configuring-Add-On-Services/#configure-the-services-secret-store-to-use

!!! Note
    The config options are supported as of EdgeX 2.2 and are disabled by default!

    Setting `config-enabled=true` is necessary to enable their support.

For example, to change the service port of the core-data service on `edgexfoundry` snap to 8080:
```bash
snap set config-enabled=true
snap set edgexfoundry apps.core-data.service-port=8080
```

### Control services
The services of a snap can be started/stopped/restarted using the snap CLI.
When starting/stopping, you can additionally set them to enable/disable which configures whether or not the service should also start on boot.

To list the services and check their status:
```bash
snap services <snap>
```

To start and enable services:
```bash
# all services
snap start --enable <snap>

# one service
snap start --enable <snap>.<app>
```

<!-- For controlling the default service startup from a gadget snap, see [TBA](tba). -->

### Debugging
The service logs can be queried using the `snap log` command.

For example, to query 100 lines and follow:
```bash
# all services
snap logs -n=100 -f <snap>

# one service
snap logs -n=100 -f <snap>.<app>
```
Check `snap logs --help` for details.

To query not only the service logs, but also the snap logs (incl. hook apps such as install and configure), use `journalctl`:
```bash
sudo journalctl -n 100 -f | grep <snap>
```

## EdgeX Snaps
The following snaps are maintained by the EdgeX working groups.
To find all EdgeX snaps on the public Snap Store, [search by keyword](https://snapcraft.io/search?q=edgex).

### Platform Snap
[![Get it from the Snap Store][badge]][edgexfoundry]

The main platform snap, simply called
[edgexfoundry] contains
all reference core services along with several other security, supporting, application, and device services.

#### Services

Upon installation, the following EdgeX services are automatically and immediately started:

- consul (Registry)
- core-command
- core-data
- core-metadata
- kong-daemon (API Gateway a.k.a. Reverse Proxy)
- postgres (kong's database)
- redis (default Message Bus and database backend for core-data and core-metadata)
- security-bootstrapper-redis (oneshot service)
- security-consul-bootstrapper (oneshot service)
- security-proxy-setup (oneshot service)
- security-secretstore-setup (oneshot service)
- vault (Secret Store)

The following services are disabled by default:

- support-notifications
- support-scheduler
- sys-mgmt-agent - deprecated
- device-virtual
- kuiper (Rules Engine) - deprecated; see 
- app-service-configurable (used to filter events for kuiper)




The disabled services can be manually enabled and started; see [Control services](#control-services).

#### Configuring individual services

All default configuration files are shipped with the snap inside `$SNAP/config`, however because `$SNAP` isn't writable, 
all of the config files are copied during snap installation to `$SNAP_DATA/config`.

!!! Tip
    `$SNAP` resolves to the path `/snap/edgexfoundry/current/` and `$SNAP_DATA` resolves to `/var/snap/edgexfoundry/current`.

The preferred way to change the configuration is to use [Configuration Overrides](#configuration-overrides) section below. 
It is also possible to change configuration directly via Consul's [UI](http://localhost:8500/ui/) or [kv REST API](https://www.consul.io/api/kv). 
Changes made to configuration in Consul require services to be restarted in order for the changes to take effect; 
the one exception are changes made to configuration items in a service's `[Writable]` section. 
Services that aren't started by default (see [Using the EdgeX snap](#using-the-edgex-snap) section above) 
*will* pickup any changes made to their config files when started.

Also it should be noted that use of Consul is enabled by default in the snap. It is not possible at this time to run the EdgeX services in
the snap with Consul disabled.


#### Configuration Overrides
!!! Note
    Deprecated. To be replaced with new scheme allowing env injection.

The EdgeX snap supports configuration overrides via its configure and install hooks which generate service-specific .env files 
which are used to provide a custom environment to the service, overriding the default configuration provided by the service's `configuration.toml` file. 
If a configuration override is made after a service has already started, then the service must be **restarted** via command-line 
(e.g. `snap restart edgexfoundry.<service>`), or [snapd's REST API](https://snapcraft.io/docs/snapd-api). 
If the overrides are provided via the snap configuration defaults capability of a gadget snap, 
the overrides will be picked up when the services are first started.

The following syntax is used to specify service-specific configuration overrides:

`env.<service>.<stanza>.<config option>`

For instance, to setup an override of Core Data's port use:

```bash
sudo snap set edgexfoundry env.core-data.service.port=2112
```

And restart the service:

```bash
sudo snap restart edgexfoundry.core-data
```

**Note** - at this time changes to configuration values in the [Writable] section are not supported.

For details on the mapping of configuration options to config options, 
please refer to [Service Environment Configuration Overrides](#service-environment-configuration-overrides) section.


#### Security services

Currently, The EdgeX snap has security (Secret Store and API Gateway) enabled by default. The security services constitute the following components:

- kong-daemon (API Gateway a.k.a. Reverse Proxy)
- postgres (kong's database)
- vault (Secret Store)

Oneshot services which perform the necessary security setup and stop, when listed using `snap services`, they show up as `enabled/inactive`:

- security-proxy-setup (kong setup)
- security-secretstore-setup (vault setup)
- security-bootstrapper-redis (secure redis setup)
- security-consul-bootstrapper (secure consul setup)

Vault is known within EdgeX as the Secret Store, while Kong+PostgreSQL are used to provide the EdgeX API Gateway.

For more details please refer to the snap's [Secret Store](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#secret-store) and [API Gateway](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#api-gateway) documentation.



#### API Gateway user setup

Before the API Gateway can be used, a user and group must be created and a JWT access token generated.

1. The first step is to create a public/private keypair for the new user, which can be done with

```bash
# Create private key:
openssl ecparam -genkey -name prime256v1 -noout -out private.pem

# Create public key:
openssl ec -in private.pem -pubout -out public.pem
```

2. The next step is to create the user. The easiest way to create a single API gateway user is to use `snap set` to set two values as follows:

```bash
# set user=username,user id,algorithm (ES256 or RS256)
sudo snap set edgexfoundry env.security-proxy.user=user01,USER_ID,ES256

# set public-key to the contents of a PEM-encoded public key file
sudo snap set edgexfoundry env.security-proxy.public-key="$(cat public.pem)"
```

To create multiple users, use the secrets-config command. You need to provide the following:

- The username
- The public key
- The API Gateway Admin JWT token
- (optionally) ID. This is a unique string identifying the credential. It will be required in the next step to
create the JWT token. If you don't specify it,
then an autogenerated one will be output by the secrets-config command
```bash

# get API Gateway/Kong token
JWT_FILE=/var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt
JWT=`sudo cat ${JWT_FILE}`

# use secrets-config to add user
edgexfoundry.secrets-config proxy adduser --token-type jwt --user user01 --algorithm ES256 --public_key public.pem --id USER_ID --jwt ${JWT}
```

3. Finally, you need to generate a token using the user ID which you specified:

```bash
# get token
TOKEN=`edgexfoundry.secrets-config proxy jwt --algorithm ES256 --private_key private.pem --id USER_ID --expiration=1h`

# Keep this token in a safe place for future reuse as the same token cannot be regenerated or recovered using the secret-config CLI
echo $TOKEN
```

Alternatively , you can generate the token on a different device using a bash script:

```bash
header='{
    "alg": "ES256",
    "typ": "JWT"
}'

TTL=$((EPOCHSECONDS+3600)) 

payload='{
    "iss":"USER_ID",
    "iat":'$EPOCHSECONDS', 
    "nbf":'$EPOCHSECONDS',
    "exp":'$TTL' 
}'

JWT_HEADER=`echo -n $header | openssl base64 -e -A | sed s/\+/-/ | sed -E s/=+$//`
JWT_PAYLOAD=`echo -n $payload | openssl base64 -e -A | sed s/\+/-/ | sed -E s/=+$//`
JWT_SIGNATURE=`echo -n "$JWT_HEADER.$JWT_PAYLOAD" | openssl dgst -sha256 -binary -sign private.pem  | openssl asn1parse -inform DER  -offset 2 | grep -o "[0-9A-F]\+$" | tr -d '\n' | xxd -r -p | base64 -w0 | tr -d '=' | tr '+/' '-_'`
TOKEN=$JWT_HEADER.$JWT_PAYLOAD.$JWT_SIGNATURE
```

4. Once you have the token you can access the API Gateway as follows:

The JWT token must be included
via an HTTP `Authorization: Bearer <access-token>` header on any REST calls used to access EdgeX services via the API Gateway. 

Example:

```bash
curl -k -X GET https://localhost:8443/core-data/api/v2/ping? -H "Authorization: Bearer $TOKEN"
```


#### API Gateway TLS certificate setup

By default Kong is configured with a self-signed TLS certificate (which you find in `/var/snap/edgexfoundry/current/kong/ssl/kong-default-ecdsa.crt`). 
It is also possible to install your own TLS certificate to be used by the gateway. The steps to do so are as follows:

1. Start by provisioning a TLS certificate to use. You can use a number of tools for that, such as `openssl` or the `edgeca` snap:

```bash
sudo snap install edgeca
edgeca gencsr --cn localhost --csr csrfile --key csrkeyfile
edgeca gencert -o localhost.cert -i csrfile -k localhost.key
```

2. Then install the certificate:

```bash
sudo snap set edgexfoundry env.security-proxy.tls-certificate="$(cat localhost.cert)"
sudo snap set edgexfoundry env.security-proxy.tls-private-key="$(cat localhost.key)"
```

3. Specify the EdgeCA Root CA certificate with `--cacert` for validation of the new certificate:

```bash
curl -v --cacert /var/snap/edgeca/current/CA.pem -X GET https://localhost:8443/core-data/api/v2/ping? -H "Authorization: Bearer $TOKEN"
```

Optionally, to specify a server name other than `localhost`, set the `tls-sni` configuration setting first. Example:

```bash
# generate certificate and private key
edgeca gencsr --cn server01 --csr csrfile --key csrkeyfile
edgeca gencert -o server.cert -i csrfile -k server.key

# To set the certificate again, you first need to clear the current values by setting them to an empty string:
sudo snap set edgexfoundry env.security-proxy.tls-certificate=""
sudo snap set edgexfoundry env.security-proxy.tls-private-key=""

# set tls-sni
sudo snap set edgexfoundry env.security-proxy.tls-sni="server01"

# and then provide the certificate and key
sudo snap set edgexfoundry env.security-proxy.tls-certificate="$(cat server.cert)"
sudo snap set edgexfoundry env.security-proxy.tls-private-key="$(cat server.key)"

# connect
curl -v --cacert /var/snap/edgeca/current/CA.pem -X GET https://server01:8443/core-data/api/v2/ping? -H "Authorization: Bearer $TOKEN"
```


#### Disabling security
!!! TODO:
    MOVE TO COMMON SECTION AND EXTEND WITH SERVICE ENV TO DISABLE

!!! Warning
    Disabling security is NOT recommended, unless for demonstration purposes, or when there are other means to secure the services.
!!! Warning
    The snap will NOT allow the Secret Store to be re-enabled. The only way to re-enable the Secret Store is to re-install the snap.
    
The Secret Store is used by EdgeX for secret management (e.g. certificates, keys, passwords). Use of the Secret Store by all services can be disabled globally, but doing so will also disable the API Gateway, as it depends on the Secret Store.

Thus the following command will disable both:

```bash
sudo snap set edgexfoundry security-secret-store=off
```

All services in the snap except for the API Gateway are restricted by default to listening on localhost (127.0.0.1).
The API Gateway proxies external requests to internal services.
Since disabling the Secret Store also disables the API Gateway, the service endpoint will no longer be accessible from other systems.
They will be still accessible on the local machine for demonstration and testing.

If you really need to make an insecure service accessible remotely, the `Service.ServerBindAddr` of each service needs be changed to the IP address of that networking interface on the local machine. If you trust all your interfaces and want the services to accept connections from all, set it to `0.0.0.0`.

### EdgeX UI
[![Get it from the Snap Store][badge]][edgex-ui]

The EdgeX GUI snap is a development tool called to help you get started with EdgeX,
whether you've deployed other components natively, using Docker containers, or
with snaps. For installation instructions, refer to [edgex-ui].

- Configuration
  - Snap
  - Snap+docker
- Additional edgexfoundry snap config for UI

For usage instructions, please refer to the [Graphical User Interface (GUI)](../../getting-started/tools/Ch-GUI/) guide.

### EdgeX CLI
[![Get it from the Snap Store][badge]](https://snapcraft.io/edgex-cli)

[edgex-cli]

<!-- sorted alphabetically -->
### App Service Configurable
[edgex-app-service-configurable]

### App RFID LLRP Inventory
[edgex-app-rfid-llrp-inventory]

### Device Camera
[edgex-device-camera]
### Device GPIO
[edgex-device-gpio]
### Device Grove
[edgex-device-grove]
### Device Modbus
[edgex-device-modbus]
### Device MQTT
[edgex-device-mqtt]
### Device REST
[edgex-device-rest]
### Device RFID LLRP
[](https://snapcraft.io/edgex-device-rfid-llrp)
### Device SNMP
[edgex-device-snmp](https://snapcraft.io/edgex-device-snmp)
### eKuiper
[edgex-ekuiper]






<!-- Store Links -->
[badge]: https://snapcraft.io/static/images/badges/en/snap-store-white.svg
[edgexfoundry]: https://snapcraft.io/edgexfoundry
[edgex-ui]: https://snapcraft.io/edgex-ui
[edgex-cli]: https://snapcraft.io/edgex-cli
[edgex-app-service-configurable]: https://snapcraft.io/edgex-app-service-configurable
[edgex-app-rfid-llrp-inventory]: https://snapcraft.io/edgex-app-rfid-llrp-inventory
[edgex-device-camera]: https://snapcraft.io/edgex-device-camera
[edgex-device-gpio]: https://snapcraft.io/edgex-device-gpio
[edgex-device-grove]: https://snapcraft.io/edgex-device-grove
[edgex-device-modbus]: https://snapcraft.io/edgex-device-modbus
[edgex-device-mqtt]: https://snapcraft.io/edgex-device-mqtt
[edgex-device-rest]: https://snapcraft.io/edgex-device-rest
[edgex-device-rfid-llrp]: https://snapcraft.io/edgex-device-rfid-llrp
[edgex-device-snmp]: https://snapcraft.io/edgex-device-snmp
[edgex-ekuiper]: https://snapcraft.io/edgex-ekuiper