# Getting Started using Snaps

## Introduction

[Snaps](https://snapcraft.io/docs) are application packages that are easy to install and update while being 
secure, cross‐platform and self-contained.
Snaps can be installed on any Linux distribution with [snap support](https://snapcraft.io/docs/installing-snapd).

### Installation
[installation]: #installation

When using the snap CLI, the installation is possible by simply executing:
```bash
snap install <snap>
```

This is similar to setting `--channel=latest/stable` or shorthand `--stable` and will install the latest stable release of a snap. In this case, `latest/stable` is the [channel](https://snapcraft.io/docs/channels), composed of `latest` track and `stable` risk level.

To install a specific version with long term support (e.g. 2.1), or to install a beta or development release, refer to the store page for the snap, choose install, and then pick the desired channel.
The store page also provides instructions for installation on different Linux distributions as well as the list of supported CPU architectures.

For the list of EdgeX snaps, please refer [here](#edgex-snaps).

### Configuration
[configuration]: #configuration

EdgeX snaps are packaged with default service configuration files. In certain cases, few configuration fields are overridden within the snap for snap-specific deployment requirements.


#### Config files
The default configuration files are typically placed at `/var/snap/<snap>/current/config`. Upon startup, the server configurations files are uploaded to Consul by default. Once the service starts without errors, the local configurations become obsolete and will no longer be read. Any modifications after the initial startup will not be applied. 

#### Config registry
The configurations that are uploaded to Consul can be modified using Consul's UI or [kv REST API](https://www.consul.io/api/kv). Changes to configurations in Consul are loaded by the service at startup. If the service has already started, a restart is required to load new configurations. Configurations that are in the writable section get loaded not only at startup, but also during the runtime. In other words, changes to the writable configurations are loaded automatically without a restart. Please refer to 
[Common Configuration](/microservices/configuration/CommonConfiguration/) and 
[Configuration and Registry Providers](../../microservices/configuration/ConfigurationAndRegistry/) for more information.

#### Config provider snap
Most EdgeX snaps have a [content interface](https://snapcraft.io/docs/content-interface) which allows another snap to seed the snap with configuration files.
This is useful when replacing entire configuration files via another snap, packaged with the deployment-specific configurations.

Please refer to [edgex-config-provider](https://github.com/canonical/edgex-config-provider), for an example.

#### Config overrides
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

!!! note
    The config options are supported as of EdgeX 2.2 and are disabled by default!

    Setting `config-enabled=true` is necessary to enable their support.

For example, to change the service port of the core-data service on `edgexfoundry` snap to 8080:
```bash
snap set config-enabled=true
snap set edgexfoundry apps.core-data.config.service-port=8080
```

The services load the set config options on startup. If the service has already started, a restart is necessary to load them.

#### Disabling security
!!! Warning
    Disabling security is NOT recommended, unless for demonstration purposes, or when there are other means to secure the services.

    The snap will NOT allow the Secret Store to be re-enabled. The only way to re-enable the Secret Store is to re-install the snap.
    
The Secret Store is used by EdgeX for secret management (e.g. certificates, keys, passwords). Use of the Secret Store by all services can be disabled globally. Note that doing so will also disable the API Gateway, as it depends on the Secret Store.

The following command disables the Secret Store and in turn the API Gateway:
```bash
sudo snap set edgexfoundry security-secret-store=off
```

All services in the snap except for the API Gateway are restricted by default to listening on localhost (127.0.0.1).
The API Gateway proxies external requests to internal services.
Since disabling the Secret Store also disables the API Gateway, the service endpoint will no longer be accessible from other systems.
They will be still accessible on the local machine for demonstration and testing.

If you really need to make an insecure service accessible remotely, set the bind address of the service to the IP address of that networking interface on the local machine. If you trust all your interfaces and want the services to accept connections from all, set it to `0.0.0.0`.

After disabling the Secret Store, the external services should be configured such that they don't attempt to initialize the security. For this purpose, [EDGEX_SECURITY_SECRET_STORE](../../microservices/configuration/CommonEnvironmentVariables/#edgex_security_secret_store) should be set to false, using the corresponding snap option: `config.edgex-security-secret-store`.

### Managing services
[managing services]: #managing-services

The services of a snap can be started/stopped/restarted using the snap CLI.
When starting/stopping, you can additionally set them to enable/disable which configures whether or not the service should also start on boot.

To list the services and check their status:
```bash
snap services <snap>
```

To start and optionally enable services:
```bash
# all services
snap start --enable <snap>

# one service
snap start --enable <snap>.<app>
```

Similarly, a service can be stopped and optionally disabled using `snap stop --disable`.

??? info "Snap options"
    To spin up an EdgeX instance with a different startup configuration (e.g. enabled instead of disabled), the `edgexfoundry` snap provides the following config options that accept values `"on"`/`"off"` to enable/disable a service by default:
    
    * `consul`
    * `redis`
    * `core-metadata`
    * `core-command`
    * `core-data`
    * `support-notifications`
    * `support-scheduler`
    * `device-virtual`
    * `security-secret-store`
    * `security-proxy`

    Device and app service snaps provide a similar functionality using the `auto-start` option.

    This is particularly useful when seeding the snap from a [Gadget](https://snapcraft.io/docs/gadget-snap) on an [Ubuntu Core](https://ubuntu.com/core) system.

To restart services, e.g. to load the configurations:
```bash
# all services
snap restart <snap>

# one service
snap restart <snap>.<app>
```

### Debugging
[debugging]: #debugging

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

!!! info
    The verbosity of service logs is INFO by default. This can be changed by overriding the log level using the `WRITABLE_LOGLEVEL` environment variable using snap config overrides.

## EdgeX Snaps
The following snaps are maintained by the EdgeX working groups.
To find all EdgeX snaps on the public Snap Store, [search by keyword](https://snapcraft.io/search?q=edgex).

### Platform Snap
| [Installation][edgexfoundry] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/edgex-go/tree/main/snap) |

The main platform snap, simply called `edgexfoundry` contains
all reference core services along with several other security, supporting, application, and device services.

Upon installation, the following EdgeX services are automatically started:

- consul (Registry)
- core-command
- core-data
- core-metadata
- kong-daemon (API Gateway / Reverse Proxy)
- postgres (kong's database)
- redis (default Message Bus and database backend for core-data and core-metadata)
- security-bootstrapper-redis (oneshot service to setup secure Redis)
- security-consul-bootstrapper (oneshot service to setup secure Consul)
- security-proxy-setup (oneshot service to setup Kong)
- security-secretstore-setup (oneshot service to setup Vault)
- vault (Secret Store)

The following services are disabled by default:

- support-notifications
- support-scheduler
- sys-mgmt-agent - *deprecated EdgeX component*
- device-virtual
- kuiper (Rules Engine / eKuiper) - *deprecated; use the standalone [EdgeX eKuiper snap](#edgex-ekuiper)*
- app-service-configurable (used to filter events for kuiper) - *deprecated; use the standalone [App Service Configurable snap](#app-service-configurable)*


The disabled services can be manually enabled and started; see [managing services].

For the configuration of services, refer to [configuration].

Most services are exposed and accessible on localhost without access control. However, the access from outside is restricted to authorized users.

#### Adding API Gateway users
The service endpoints can be accessed securely through the API Gateway. The API Gateway requires a JSON Web Token (JWT) to authorize requests. Please refer to [Adding EdgeX API Gateway Users Remotely](../../security/Ch-AddGatewayUserRemotely/) and use the snapped `edgexfoundry.secrets-config` utility.

To get the usage help:
```bash
edgexfoundry.secrets-config proxy adduser -h
```
You may also refer to the [secrets-config proxy](../../security/secrets-config-proxy/) documentation.


!!! example "Creating an example user"
    Create private and public keys:
    ```bash
    openssl ecparam -genkey -name prime256v1 -noout -out private.pem
    openssl ec -in private.pem -pubout -out public.pem

    ```

    Read the API Gateway token:
    ```bash
    KONG_ADMIN_JWT_FILE=`sudo cat /var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt`
    ```

    Use secrets-config to add a user `example` with id `1000`:
    ```bash
    edgexfoundry.secrets-config proxy adduser --token-type jwt --user example --algorithm ES256 --public_key public.pem --id 1000 --jwt $KONG_ADMIN_JWT
    ```
    On success, the above command prints the user id.

??? tip "Seeding an admin user using snap options"
    To spin up a pre-configured and securely accessible EdgeX instance, the snap provides a way to pass the public key of a single user with snap options. When requested, the user is created with user `admin`, id `1` and JWT signing algorithm `ES256`. The snap option for passing the public key is:
    `apps.secrets-config.proxy.admin.public-key`.

    This is particularly useful when seeding the snap from a [Gadget](https://snapcraft.io/docs/gadget-snap) on an [Ubuntu Core](https://ubuntu.com/core) system.

!!! example "Generating a JWT token for the example user"
    On success, a JWT token is printed out and written to user.jwt file.
    We use the user id `1000` as set in the previous example.
    ```bash
    edgexfoundry.secrets-config proxy jwt --algorithm ES256 --private_key private.pem --id 1000 --expiration=1h | tee user.jwt
    ```

It is also possible to create the JWT token using bash and openssl. But that is beyond the scope of this guide.

Once you have the token, you can access the services via the API Gateway.

!!! example "Calling an API on behalf of example user"

    ```bash
    curl --insecure https://localhost:8443/core-data/api/v2/ping -H "Authorization: Bearer $(cat user.jwt)"
    ```
    Output: `{"apiVersion":"v2","timestamp":"Mon May  2 12:14:17 CEST 2022","serviceName":"core-data"}`

#### Accessing Consul
Consul API and UI can be accessed using the consul token (Secret ID). For the snap, token is the value of `SecretID` typically placed in a JSON file at `/var/snap/edgexfoundry/current/secrets/consul-acl-token/bootstrap_token.json`.

!!! example
    To get the token:
    ```bash
    sudo cat /var/snap/edgexfoundry/current/secrets/consul-acl-token/bootstrap_token.json | jq '.SecretID'
    ```
    Output: `"ee3964d0-505f-6b62-4c88-0d29a8226daa"`

    Try it out locally:
    ```bash
    curl --insecure --silent http://localhost:8500/v1/kv/edgex/core/2.0/core-data/Service/Port -H "X-Consul-Token:17938174-059e-8b86-122a-9a08a99dcd1c"
    ```

    Through the API Gateway:  
    We need to pass both the Consul token and Secret Store token obtained in [Adding API Gateway users](#adding-api-gateway-users) examples.
    ```bash
    curl --insecure --silent https://localhost:8443/consul/v1/kv/edgex/core/2.0/core-data/Service/Port -H "X-Consul-Token:17938174-059e-8b86-122a-9a08a99dcd1c" -H "Authorization: Bearer $(cat user.jwt)"
    ```

#### Setting TLS certificates
The API Gateway setup generates a self-signed certificate by default. To replace that with your own certificate, refer to API Gateway guide: [Using a bring-your-own external TLS certificate for API gateway](../../security/Ch-APIGateway/#using-a-bring-your-own-external-tls-certificate-for-api-gateway) and use the snapped `edgexfoundry.secrets-config` utility.

To get the usage help:
```bash
edgexfoundry.secrets-config proxy tls -h
```
You may also refer to the [secrets-config proxy](../../security/secrets-config-proxy/) documentation.

!!! example 
    Given certificate `cert.pem`, private key `privkey.pem`, and certificate authority `ca.pem` files:

    Read the API Gateway token:
    ```bash
    KONG_ADMIN_JWT=`sudo cat /var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt`
    ```

    Add the certificate, using Kong Admin JWT to authenticate:
    ```bash
    edgexfoundry.secrets-config proxy tls --incert cert.pem --inkey privkey.pem --admin_api_jwt $KONG_ADMIN_JWT
    ```

    Try it out:
    ```bash
    curl --cacert ca.pem https://localhost:8443/core-data/api/v2/ping
    ```
    Output: `{"message":"Unauthorized"}`  
    This means that TLS is setup correctly, but the request is not authorized.  
    Set the `-v` command for diagnosing TLS issues.


??? tip "Snap options"
    To spin up an EdgeX instance with custom certificates, the snap provides the following configuration options:
    
    * `apps.secrets-config.proxy.tls.cert`
    * `apps.secrets-config.proxy.tls.key`
    * `apps.secrets-config.proxy.tls.snis` (comma-separated values)

    This is particularly useful when seeding the snap from a [Gadget](https://snapcraft.io/docs/gadget-snap) on an [Ubuntu Core](https://ubuntu.com/core) system.

#### Secret Store token interface
The services inside standalone snaps (e.g. device, app snaps) automatically receive a [Secret Store](../../security/Ch-SecretStore/) token when:

* The standalone snap is downloaded and installed from the store
* The platform snap is downloaded and installed from the store
* Both snaps are installed on the same machine
* The service is registered as an [add-on service](../../security/Ch-Configuring-Add-On-Services/)

The `edgex-secretstore-token` [content interface](https://snapcraft.io/docs/content-interface) provides the mechanism to automatically supply tokens to connected snaps.

Execute the following command to check the status of connections:
```bash
sudo snap connections edgexfoundry
```

To manually connect the edgexfoundry's plug to a standalone snap's slot:
```bash
snap connect edgexfoundry:edgex-secretstore-token <snap>:edgex-secretstore-token
```

Note that the token has a limited expiry time of 1h by default. The connection and service startup should happen within the validity period.

To better understand the snap connections, read the [interface management](https://snapcraft.io/docs/interface-management)

!!! tip "Extend the default Secret Store token TTL"
    Set [TOKENFILEPROVIDER_DEFAULTTOKENTTL](../../microservices/configuration/CommonEnvironmentVariables/#tokenfileprovider_defaulttokenttl-security-secretstore-setup-service) for security-secretstore-setup and restart:
    ```bash
    sudo snap set edgexfoundry config-enabled=true
    sudo snap set edgexfoundry apps.security-secretstore-setup.config.tokenfileprovider-defaulttokenttl=72h
    sudo snap restart edgexfoundry.security-secretstore-setup
    ```

### EdgeX UI
| [Installation][edgex-ui] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/edgex-ui-go/tree/main/snap) |

For usage instructions, please refer to the [Graphical User Interface (GUI)](../tools/Ch-GUI/) guide.

By default, the UI is reachable locally at:
[http://localhost:4000](http://localhost:4000)

A valid JWT token is required to access the UI; follow [Adding API Gateway users](#adding-api-gateway-users) steps to generate a token.

To enable all the functionalities of the UI, the following support services should be running:

* Support Scheduler
* Support Notifications
* System Management Agent
* [EdgeX eKuiper](#edgex-ekuiper)

For example, to start/install all:
```
sudo snap start edgexfoundry.support-scheduler
sudo snap start edgexfoundry.support-notifications
sudo snap start edgexfoundry.sys-mgmt-agent
sudo snap install edgex-ekuiper
```

### EdgeX CLI
| [Installation][edgex-cli] | [Source](https://github.com/edgexfoundry/edgex-cli/tree/main/snap) |

For usage instructions, refer to [Command Line Interface (CLI)](../tools/Ch-CommandLineInterface/) guide.

<!-- sorted alphabetically -->
### App Service Configurable
| [Installation][edgex-app-service-configurable] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/app-service-configurable/tree/main/snap) |

Please refer to [App Service Configurable](../../microservices/application/AppServiceConfigurable/) guide for detailed usage instructions.

Before you can start the service, you must select one of available profiles, 
using snap options.

For example, to set `mqtt-export` profile using the snap CLI:
```bash
sudo snap set edgex-app-service-configurable profile=mqtt-export
```

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
[edgex-device-rfid-llrp]
### Device SNMP
[edgex-device-snmp]
### EdgeX eKuiper
[edgex-ekuiper]

<!-- Store Links -->
[badge]: https://snapcraft.io/static/images/badges/en/snap-store-white.svg
[edgexfoundry]: https://snapcraft.io/edgexfoundry
[edgexfoundry-src]: https://github.com/edgexfoundry/edgex-go/tree/main/snap
[edgex-ui]: https://snapcraft.io/edgex-ui
[edgex-ui-src]: https://github.com/edgexfoundry/edgex-ui-go/tree/main/snap
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