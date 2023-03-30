# Getting Started using Snaps

## Introduction

[Snaps](https://snapcraft.io/docs) are application packages that are easy to install and update while being 
secure, cross‐platform and self-contained.
Snaps can be installed on any Linux distribution with [snap support](https://snapcraft.io/docs/installing-snapd).

### Quick Start

Spinning up EdgeX with snaps is extremely easy.
For demonstration purposes, let's install the platform, along with the virtual device service and EdgeX UI.

1) Install the [platform snap], [Device Virtual](#device-virtual) and [EdgeX UI](#edgex-ui):
```bash
snap install edgexfoundry --edge
snap install edgex-device-virtual --edge
snap install edgex-ui --edge
```
!!! danger
    The above examples use the latest development versions of EdgeX snaps.
    This should be replaced by the latest stable v3, once available.

EdgeX has security enabled by default. But for simplicity, we'll disable it here.
If not disabled, you could skip to step 3 and additionally add a user and authenticate as described [here](#adding-api-gateway-users). To access the UI, you need to generate a JWT.

2) Disable security in each of the installed snaps:
```bash
snap set edgexfoundry security=false
snap set edgex-device-virtual config.edgex-security-secret-store=false
snap set edgex-ui config.edgex-security-secret-store=false
```
Refer to [disabling security] for details.

3) Start the device and UI services:
```bash
snap start edgex-device-virtual
snap start edgex-ui
```
This is because those services disabled and not started by default.

You should now be able to access the UI using a browser at [http://localhost:4000](http://localhost:4000)

![EdgeX UI](EdgeX-GettingStartedSnapUsersUI.png)

---

The following sub-sections provide generic instructions for [installation], [configuration], and [managing services] using snaps. 

For the list of EdgeX snaps and specific instructions, please refer to the **[EdgeX Snaps](#edgex-snaps)** section.

### Installation
[installation]: #installation

When using the snap CLI, the installation is possible by simply executing:
```bash
snap install <snap>
```

This is similar to setting `--channel=latest/stable` or shorthand `--stable` and will install the latest stable release of a snap. In this case, `latest/stable` is the [channel](https://snapcraft.io/docs/channels), composed of `latest` track and `stable` risk level.

To install a specific version with long term support (e.g. 2.1), or to install a beta or development release, refer to the store page for the snap, choose install, and then pick the desired channel.
The store page also provides instructions for installation on different Linux distributions as well as the list of supported CPU architectures.

### Configuration
[configuration]: #configuration

EdgeX snaps are packaged with default service configuration files. In certain cases, few configuration fields are overridden within the snap for snap-specific deployment requirements.

There are a few ways to configure snapped services. In simple cases, it should be sufficient to modify the default config files before starting the services for the first time and use config overrides to change supported settings afterwards. Please refer below to learn about the different configuration methods.

#### Config files
The default configuration files are typically placed at `/var/snap/<snap>/current/config`. Upon a successful startup of an EdgeX service, the server configuration file (typically named `configuration.yaml`) is uploaded to the [Registry](../../microservices/configuration/ConfigurationAndRegistry/#registry-provider) by default. After that, the local server configuration file will no longer be read and any modifications will not be applied. At this point, the configurations can be only changed via the Registry or by setting environment variables. Refer to [config registry](#config-registry) or [config overrides](#config-overrides) for details.

For device services, the Device and Device Profile files are submitted to [Core Metadata](../../microservices/core/metadata/Ch-Metadata) upon initial startup. Refer to the documentation of [Device Services](../../microservices/device/Ch-DeviceServices/) for details.

#### Config registry
The configurations that are uploaded to the Registry (i.e. Consul by default) can be modified using Consul's UI or [kv REST API](https://www.consul.io/api/kv). The Registry is a Core services, part of the [Platform Snap](#platform-snap).

Changes to configurations in Registry are loaded by the service at startup. If the service has already started, a restart is required to load new configurations. Configurations that are in the writable section get loaded not only at startup, but also during the runtime. In other words, changes to the writable configurations are loaded automatically without a restart.

Please refer to 
[Common Configuration](../../microservices/configuration/CommonConfiguration/) and 
[Configuration and Registry Providers](../../microservices/configuration/ConfigurationAndRegistry/) for more information.

#### Config provider snap
[config-provider-snap]: #config-provider-snap

Most EdgeX snaps have a [content interface](https://snapcraft.io/docs/content-interface) which allows another snap to seed it with configuration files.
This is useful for replacing all the configuration files in a service snap via a config provider snap without manual user interaction.

A config provider snap could be a standalone package with all the necessary configurations for multiple snaps. It will expose and one or more [interface](https://snapcraft.io/docs/interface-management) *slots* to allow connections from consumer *plugs*. The config provider snap can be released to the store just like any other snap. 
Upon a connection between consumer and provider snaps, the packaged config files get mounted inside the consumer snap, to be used by services.

Please refer to [edgex-config-provider](https://github.com/canonical/edgex-config-provider), for an example.

#### Config overrides
??? Tip "EdgeX snap options scheme"
    Since EdgeX v2.2, the snaps use the following scheme for the snap configuration options:
    ```
    apps.<app>.<type>.<key>
    ```
    where:

    - `<app>` is the name of the app (service, executable)
    - `<type>` is the type of option with respect to the app
    - `<key>` is key for the option. It could contain a path to set a value inside an object, e.g. `x.y=z` sets `{"x": {"y": "z"}}`.
    
    We call these *app options* because of the `apps.<app>` prefix which is used to apply configurations to specific services. This prefix can be dropped to apply the configuration globally to all apps within a snap!
    
    This scheme is used for config overrides (described in this section) as well as autostart described in [managing services], among others.
    
    To know more about snap configuration, refer [here](https://snapcraft.io/docs/configuration-in-snaps).

The EdgeX services allow overriding server configurations using environment variables. Moreover, the services read [EdgeX Common Environment Variables](../../microservices/configuration/CommonEnvironmentVariables/) that override configurations that are hardcoded in source code or set as command-line options.

The EdgeX snaps provide an mechanism that reads stored key-value options and internally export environment variables to specific services and apps.

The snap options for setting environment variable uses the the following format:

* `apps.<app>.config.<env-var>`: setting an app-specific value (e.g. `apps.core-data.config.service-port=1000`).
* `config.<env-var>`: setting a global value (e.g. `config.service-host=localhost` or `config.writable-loglevel=DEBUG`)

where:

* `<app>` is the name of the app (service, executable)
* `<env-var>` is a lowercase, dash-separated mapping from the uppercase, underscore-separate environment variable name (e.g. `X_Y`->`x-y`). The reason for such mapping is that uppercase and underscore characters are not supported as config keys for snaps.

Mapping examples:

| Snap config key        | Environment Variable     | Service configuration YAML                       |
|------------------------|--------------------------|-----------------------------------------------------|
| service-port           | SERVICE_PORT             | Service:<br>--Port:                             |
| clients-core-data-host  | CLIENTS_CORE_DATA_HOST  | Clients:<br>--core-data:<br>----Host:   |
| edgex-startup-duration | [EDGEX_STARTUP_DURATION] | -                                                   |
| add-secretstore-tokens | [ADD_SECRETSTORE_TOKENS] | -                                                   |

[EDGEX_STARTUP_DURATION]: ../../microservices/configuration/CommonEnvironmentVariables/#edgex_startup_duration
[ADD_SECRETSTORE_TOKENS]: ../../security/Ch-Configuring-Add-On-Services/#configure-the-services-secret-store-to-use

!!! Example 
    To change the service port of the `core-data` service on `edgexfoundry` snap to 8080:
    ```bash
    snap set edgexfoundry apps.core-data.config.service-port=8080
    ```
​    This would internally export `SERVICE_PORT=8080` to `core-data` service.

!!! Note
    The services load the set configuration on startup. If a service has already started, a restart will be necessary to load the configurations.

#### Examples
##### Disabling security
[disabling security]: #disabling-security

!!! Warning
    Disabling security is NOT recommended, unless for demonstration purposes, or when there are other means to secure the services.

    The [platform snap] snap does NOT allow the security to be re-enabled. The only way to re-enable it is to re-install the snap.

Disabling security involves two steps:

1. Stopping the security services and disabling them so that they don't run again.
2. Configuring EdgeX services to NOT use the Secret Store by setting [EDGEX_SECURITY_SECRET_STORE](../../microservices/configuration/CommonEnvironmentVariables/#edgex_security_secret_store) to false. The services include Core Data, Core Command, Core Metadata, EdgeX UI, device services, app services, and any other service that uses EdgeX's [go-mod-bootstrap](https://github.com/edgexfoundry/go-mod-bootstrap).

The [platform snap] includes all the reference security components. The security components are enabled by default. The platform snap provides a convenience way to perform both of the above by setting `security=false`:
```bash
snap set edgexfoundry security=false
```

The above command results in stopping and disabling the security components as well as setting `config.edgex-security-secret-store=false` internally so that core services stop using the Secret Store. The services are automatically restarted to pick up the new configuration.

After disabling the security on the platform, the external services should be similarly configured by setting `config.edgex-security-secret-store=false` such that they don't attempt to initialize the security.

!!! Example
    To disable security for the [edgex-ui] snap:
    ```bash
    snap set edgex-ui config.edgex-security-secret-store=false
    snap restart edgex-ui
    ```

!!! Note
    All snapped services except for the API Gateway are restricted by default to listening on localhost (127.0.0.1).
    On the [platform snap], the API Gateway proxies external requests to internal services.
    Since disabling security on the platform snap disables the API Gateway, the service endpoints will no longer be accessible from other systems.
    They will be still accessible on the local machine and reachable by other local services.

    If you need to make an insecure service accessible remotely, set the bind address of the service to the IP address of that networking interface on the local machine. If you trust all your interfaces and want the services to accept connections from all, set it to `0.0.0.0`.
    ??? Example
        By default, `core-data` listens on `127.0.0.1:59880`:
        ```
        $ sudo lsof -nPi :59880
        COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
        core-data 30944 root   12u  IPv4 198726      0t0  TCP 127.0.0.1:59880 (LISTEN)
        ```
    
        To set the bind address of `core-data` in the platform snap to `0.0.0.0`:
        ```bash
        snap set edgexfoundry apps.core-data.config.service-serverbindaddr="0.0.0.0"
        ```
    
        Now, core data is listening an all interfaces (`*:59880`):
        ```
        $ sudo lsof -nPi :59880
        COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
        core-data 30548 root   12u  IPv6 185059      0t0  TCP *:59880 (LISTEN)
        ```
    
        To set it for all services inside the platform snap:
        ```bash
        snap set edgexfoundry config.service-serverbindaddr="0.0.0.0"
        ```



##### Using MQTT message bus
The default message bus for EdgeX services is Redis Pub/Sub. If you prefer to use MQTT instead of Redis, change the [message bus configurations](../../microservices/general/messagebus/#configuration-changes) using snap options.

!!! example
    To switch to an insecure MQTT message bus for all core services (inside the platform snap) and the Device Virtual using snap options, set the following:
    ```bash
    snap set edgexfoundry config.messagequeue-protocol="mqtt" \
                          config.messagequeue-port=1883 \
                          config.messagequeue-type="mqtt" \
                          config.messagequeue-authmode="none"

    snap set edgex-device-virtual config.messagequeue-protocol="mqtt" \
                                  config.messagequeue-port=1883 \
                                  config.messagequeue-type="mqtt" \
                                  config.messagequeue-authmode="none"
    ```

##### Disabling registry and config provider
Consul is the default Registry and Config Provider in EdgeX. To disable both, it would be sufficient to disable 
Consul and configure the services not to use Registry and Config Provider.

!!! example
    To disable Consul and configure all services (inside the platform snap) not to use Registry and Config provider 
    using snap options, set the following:
    ```bash
    snap set edgexfoundry apps.consul.autostart=false
    snap set edgexfoundry config.edgex-use-registry=false 
    snap set edgexfoundry config.edgex-configuration-provider=none
    ```

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

!!! Note
    The [service autostart](#service-autostart) overrides the status and startup setting of the services. In other words, if autostart is set explicitly to true/false, it will apply that setting every time the snap is re-configured, e.g. by executing `snap set|unset`.

To restart services, e.g. to load the configurations:
```bash
# all services
snap restart <snap>

# one service
snap restart <snap>.<app>
```

#### Service autostart
The EdgeX snaps provide a mechanism to change the default startup of services (e.g. enabled instead of disabled).

The EdgeX snaps allows the change using snap options following the below scheme: 

* `apps.<app>.autostart=true|false`: changing the default startup of one app
* `autostart=true|false`: changing the default startup of all apps
  

where `<app>` is the name of the app which can run as a service.


??? Example
    Disable the autostart of support-scheduler on the [platform snap]:
    ```bash
    snap set edgexfoundry apps.support-scheduler.autostart=false
    ```

    Enable the autostart of all [Device USB Camera](#device-usb-camera) services:
    ```bash
    snap set edgex-device-virtual autostart=true
    ```

The autostart options are also useful for changing the startup behavior when seeding the snap from a [Gadget](https://snapcraft.io/docs/gadget-snap) on [Ubuntu Core](https://ubuntu.com/core).

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
    The verbosity of service logs is INFO by default. This can be changed by overriding the log level using the `WRITABLE_LOGLEVEL` environment variable using snap config overrides `apps.<app>.config.writable-loglevel` or globally as `config.writable-loglevel`.

## EdgeX Snaps
The following snaps are maintained by the EdgeX working groups:

- [Platform Snap](#platform-snap) - containing all core and security services along with few supporting and application services.
- Tools
    - [EdgeX UI](#edgex-ui)
    - [EdgeX CLI](#edgex-cli)
- Supporting Services
    - [EdgeX eKuiper](#edgex-ekuiper)
- Application Services
    - [App Service Configurable](#app-service-configurable)
    - [App RFID LLRP Inventory](#app-rfid-llrp-inventory)
- Device Services
    - [Device GPIO](#device-gpio)
    - [Device Modbus](#device-modbus)
    - [Device MQTT](#device-mqtt)
    - [Device REST](#device-rest)
    - [Device RFID LLRP](#device-rfid-llrp)
    - [Device SNMP](#device-snmp)
    - [Device USB Camera](#device-usb-camera)
    - [Device Virtual](#device-virtual)
    - [Device ONVIF Camera](#device-onvif-camera)

To find all EdgeX snaps on the public Snap Store, [search by keyword](https://snapcraft.io/search?q=edgex).

### Platform Snap
[platform snap]: #platform-snap
| [Installation][edgexfoundry] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/edgex-go/tree/main/snap) |

The main platform snap, simply called `edgexfoundry` contains
all reference core and security services along with a few supporting and application services.

Upon installation, the following EdgeX services are automatically started:

- consul (Registry)
- core-command
- core-data
- core-metadata
- nginx (API Gateway / Reverse Proxy)
- redis (default Message Bus and database backend for core-data and core-metadata)
- security-bootstrapper-redis (oneshot service to setup secure Redis)
- security-consul-bootstrapper (oneshot service to setup secure Consul)
- security-proxy-auth (performs authentication on behalf of the API gateway)
- security-proxy-setup (oneshot service to setup API gateway)
- security-secretstore-setup (oneshot service to setup Vault)
- vault (Secret Store)

The following services are disabled by default:

- support-notifications
- support-scheduler
- sys-mgmt-agent - *deprecated EdgeX component*

The disabled services can be manually enabled and started; see [managing services].

For the configuration of services, refer to [configuration].

Most services are exposed and accessible on localhost without access control. However, the access from outside is restricted to authorized users.

#### Adding API Gateway users
The API gateway will pass any request that authenticates using a
[signed identity token from the EdgeX secret store](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#introspect-a-signed-id-token).

The baseline implementation in EdgeX 3.0 uses Vault identity and the 'userpass' authentication engine to create users,
though EdgeX adopters are free to add their own Vault identities using authentication methods of their choice.
To add a new user locally, use the snapped `edgexfoundry.secrets-config` utility.

To get the usage help:
```bash
edgexfoundry.secrets-config proxy adduser -h
```
You may also refer to the [secrets-config proxy](../../security/secrets-config-proxy/) documentation.


!!! example "Creating an example user"
    Use secrets-config to add a user `example` (note: always specify `--useRootToken` for the snap deployment of EdgeX):
    ```bash
    edgexfoundry.secrets-config proxy adduser --user example --useRootToken
    ```
    On success, the above command prints a JSON object containing `username` and `password` fields.
    If the "adduser" command is run multiple times,
    each run will overwrite the password from the previous run
    with a new random password.

!!! example "Generating a JWT token for the example user"
    Some additional work is required to generate a JWT that is usable for API gateway authentication.

    ```bash
    username=example
    password=password-from-above
    
    vault_token=$(curl -ks "http://localhost:8200/v1/auth/userpass/login/${username}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')
    
    id_token=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/token/${username}" | jq -r '.data.token')
    
    echo "${id_token}" > user-jwt.txt
    ```

Once you have the token, you can access the services via the API Gateway (the vault token can be discarded).
To obtain a new JWT token once the current one is expired, repeat the above snippet of code.

!!! example "Calling an API on behalf of example user"

    ```bash
    curl --insecure https://localhost:8443/core-data/api/v2/ping -H "Authorization: Bearer $(cat user-jwt.txt)"
    ```
    Output: `{"apiVersion":"v2","timestamp":"Mon May  2 12:14:17 CEST 2022","serviceName":"core-data"}`

#### Accessing Consul
Consul API and UI can be accessed using the consul token (Secret ID). For the snap, token is the value of `SecretID` typically placed in a JSON file at `/var/snap/edgexfoundry/current/secrets/consul-acl-token/mgmt_token.json`.

!!! example
    To get the token:
    ```bash
    sudo cat /var/snap/edgexfoundry/current/secrets/consul-acl-token/mgmt_token.json | jq -r '.SecretID' | tee consul-token.txt
    ```
    The output is printed out and written to `consul-token.txt`. Example output: `ee3964d0-505f-6b62-4c88-0d29a8226daa`

    Try it out locally:
    ```bash
    curl --insecure --silent http://localhost:8500/v1/kv/edgex/core/2.0/core-data/Service/Port -H "X-Consul-Token:$(cat consul-token.txt)"
    ```
    
    Through the API Gateway:  
    We need to pass both the Consul token and Secret Store token obtained in [Adding API Gateway users](#adding-api-gateway-users) examples.
    ```bash
    curl --insecure --silent https://localhost:8443/consul/v1/kv/edgex/core/2.0/core-data/Service/Port -H "X-Consul-Token:$(cat consul-token.txt)" -H "Authorization: Bearer $(cat user-jwt.txt)"
    ```

#### Changing TLS certificates
The API Gateway setup generates a self-signed certificate with a short expiration by default.

The default certificate is stored at `/var/snap/edgexfoundry/current/nginx/nginx.crt`.

The default private key is stored at `/var/snap/edgexfoundry/current/nginx/nginx.key`.

The JWT authentication token that is consumed by the proxy is sensitive and it is important that
measures are taken to ensure that clients do not disclose the JWT to unauthorized parties.
For this reason, the default certificate and key should be replaced
with a certificate and key that is trusted by connecting clients.
(This can be done a `sudo cp` command or equivalent.)


!!! example
    Given the following files created outside the scope of this document:
    
    * `nginx.crt` user-provided certificate (replacing the default)
    * `nginx.key` user-provided private key (replacing the default)
    * `ca.pem` certificate authority file (that signed `nginx.crt`, directly or indirectly)
    
    Try it out:
    ```bash
    curl --cacert ca.pem https://localhost:8443/core-data/api/v2/ping
    ```
    Output: `{"message":"Unauthorized"}`  
    This means that TLS is setup correctly, but the request is not authorized.  
    Set the `-v` command for diagnosing TLS issues.  
    The `--cacert` can be omitted if the CA is available in root certificates (e.g. CA-signed or pre-installed CA certificate).


??? tip "Seeding a custom TLS certificate using snap options"
    To spin up an EdgeX instance with a custom certificate, the snap provides the following configuration options:
    
    * `apps.secrets-config.proxy.tls.cert`
    * `apps.secrets-config.proxy.tls.key`
    
    This is particularly useful when seeding the snap from a [Gadget](https://snapcraft.io/docs/gadget-snap) on an [Ubuntu Core](https://ubuntu.com/core) system.

<!-- DO NOT CHANGE THE TITLE. READMEs reference the anchor -->
#### Secret Store token
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
    The [TOKENFILEPROVIDER_DEFAULTTOKENTTL](../../microservices/configuration/CommonEnvironmentVariables/#tokenfileprovider_defaulttokenttl-security-secretstore-setup-service) environment variable can be set to override the default time to live (TTL) of the Secret Store tokens.
    This is useful when the microservice consumers of the tokens are expected to start after a delay that is longer than the default TTL.

    This can be achieved in the snap by setting the equivalent `tokenfileprovider-defaulttokenttl` config option:
    ```bash
    sudo snap set edgexfoundry app-options=true
    sudo snap set edgexfoundry apps.security-secretstore-setup.config.tokenfileprovider-defaulttokenttl=72h
    
    # Re-start the oneshot setup service to re-generate tokens:
    sudo snap start edgexfoundry.security-secretstore-setup
       
    ```

### EdgeX UI
| [Installation][edgex-ui] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/edgex-ui-go/tree/main/snap) |

For usage instructions, please refer to the [Graphical User Interface (GUI)](../tools/Ch-GUI/) guide.

The service is **not started** by default. Please refer to [configuration] and [managing services].

Once started, the UI will be reachable locally and by default at:
[http://localhost:4000](http://localhost:4000)

A valid JWT token is required to access the UI; follow [Adding API Gateway users](#adding-api-gateway-users) steps to generate a token.
In development environments, the UI access control can be disabled as described in [disabling security].

To enable all the functionalities of the UI, the following services should be running:

* Support Scheduler
* Support Notifications
* [EdgeX eKuiper](#edgex-ekuiper)
* System Management Agent (deprecated)

For example, to start/install the support services:
```
sudo snap start edgexfoundry.support-scheduler
sudo snap start edgexfoundry.support-notifications
sudo snap install edgex-ekuiper
```

### EdgeX CLI
| [Installation][edgex-cli] | [Source](https://github.com/edgexfoundry/edgex-cli/tree/main/snap) |

For usage instructions, refer to [Command Line Interface (CLI)](../tools/Ch-CommandLineInterface/) guide.

### EdgeX eKuiper
| [Installation][edgex-ekuiper] | [Managing Services] | [Debugging] | [Source](https://github.com/canonical/edgex-ekuiper-snap) |

!!! edgey "EdgeX 2.2"
    This version of EdgeX introduces a standalone EdgeX eKuiper snap.
    The new snap is the supported way of using eKuiper with other EdgeX snaps.

For the documentation of the standalone EdgeX eKuiper snap, visit the [README](https://github.com/canonical/edgex-ekuiper-snap).

<!-- sorted alphabetically -->
### App Service Configurable
| [Installation][edgex-app-service-configurable] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/app-service-configurable/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-app-service-configurable/current/config/
└── res
    ├── external-mqtt-trigger
    │   └── configuration.yaml
    ├── functional-tests
    │   └── configuration.yaml
    ├── http-export
    │   └── configuration.yaml
    ├── metrics-influxdb
    │   └── configuration.yaml
    ├── mqtt-export
    │   └── configuration.yaml
    ├── push-to-core
    │   └── configuration.yaml
    └── rules-engine
        └── configuration.yaml
```

??? example "Filtering devices using snap options"
    App service configurable provides various event filtering options.
    For example, to [filter by device names](../../microservices/application/AppServiceConfigurable/#filterbydevicename) `Random-Integer-Device` and `Random-Binary-Device` using snap options:
    ```
    snap set edgex-app-service-configurable config.writable-pipeline-executionorder="FilterByDeviceName, SetResponseData"
    snap set edgex-app-service-configurable config.writable-pipeline-functions-filterbydevicename-parameters-devicenames="Random-Integer-Device, Random-Binary-Device"
    snap set edgex-app-service-configurable config.writable-pipeline-functions-filterbydevicename-parameters-filterout=true
    ```

Please refer to [App Service Configurable](../../microservices/application/AppServiceConfigurable/) guide for detailed usage instructions.

**Profile**

Before you can start the service, you must select one of available profiles, 
using snap options.

For example, to set `mqtt-export` profile using the snap CLI:
```bash
sudo snap set edgex-app-service-configurable profile=mqtt-export
```

### App RFID LLRP Inventory
| [Installation][edgex-app-rfid-llrp-inventory] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/app-rfid-llrp-inventory/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-app-rfid-llrp-inventory/current/config/
└── app-rfid-llrp-inventory
    └── res
        └── configuration.yaml
```

**Aliases**

The aliases need to be provided for the service to work.  See [Setting the Aliases](https://github.com/edgexfoundry/app-rfid-llrp-inventory/blob/main/README.md#setting-the-aliases).

For the snap, this can either be by:

- using a [config-provider-snap] to provide a `configuration.yaml` file with the correct aliases, before startup
- setting the values manually in Consul during or after deployment

### Device GPIO
| [Installation][edgex-device-gpio] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-gpio/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-gpio/current/config
└── device-gpio
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── device.custom.gpio.yaml
        └── profiles
            └── device.custom.gpio.yaml
```

**GPIO Access**

This snap is strictly confined which means that the access to interfaces are subject to various security measures.

On a Linux distribution without snap confinement for GPIO (e.g. Raspberry Pi OS 11), the snap may be able to access the GPIO directly, without any snap interface and manual connections.

On Linux distributions with snap confinement for GPIO such as Ubuntu Core, the GPIO access is possible via the [gpio interface](https://snapcraft.io/docs/gpio-interface), provided by a gadget snap. 
The official [Raspberry Pi Ubuntu Core](https://ubuntu.com/download/raspberry-pi-core) image includes that gadget.
It is NOT possible to use this snap on Linux distributions that have the GPIO confinement but not the interface (e.g. Ubuntu Server 20.04), unless for development purposes.

In development environments, it is possible to install the snap in dev mode (using `--devmode` flag which disables security confinement and automatic upgrades) to allow direct GPIO access.

The `gpio` interface provides slots for each GPIO channel. The slots can be listed using:
```bash
$ sudo snap interface gpio
name:    gpio
summary: allows access to specific GPIO pin
plugs:
  - edgex-device-gpio
slots:
  - pi:bcm-gpio-0
  - pi:bcm-gpio-1
  - pi:bcm-gpio-10
  ...
```

The slots are not connected automatically. For example, to connect GPIO-17:
```
$ sudo snap connect edgex-device-gpio:gpio pi:bcm-gpio-17
```

Check the list of connections:
```
$ sudo snap connections
Interface        Plug                            Slot              Notes
gpio             edgex-device-gpio:gpio          pi:bcm-gpio-17    manual
…
```

### Device Modbus
| [Installation][edgex-device-modbus] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-modbus-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-modbus/current/config/
└── device-modbus
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── modbus.test.devices.yaml
        └── profiles
            └── modbus.test.device.profile.yml
```


### Device MQTT
| [Installation][edgex-device-mqtt] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-mqtt-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-mqtt/current/config/
└── device-mqtt
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── mqtt.test.device.yaml
        └── profiles
            └── mqtt.test.device.profile.yaml
```

### Device REST
| [Installation][edgex-device-rest] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-rest-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-rest/current/config/
└── device-rest
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── sample-devices.yaml
        └── profiles
            ├── sample-image-device.yaml
            ├── sample-json-device.yaml
            └── sample-numeric-device.yaml

```

### Device RFID LLRP
| [Installation][edgex-device-rfid-llrp] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-rfid-llrp-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-rfid-llrp/current/config/
└── device-rfid-llrp
    └── res
        ├── configuration.yaml
        ├── devices
        ├── profiles
        │   ├── llrp.device.profile.yaml
        │   └── llrp.impinj.profile.yaml
        └── provision_watchers
            ├── impinj.provision.watcher.yaml
            └── llrp.provision.watcher.yaml
```

**Subnet setup**

The `DiscoverySubnets` setting needs to be provided before a device discovery can occur. This can be done in a number of ways:

- Using `snap set` to set your local subnet information. Example:

    ```bash
    sudo snap set edgex-device-rfid-llrp apps.device-rfid-llrp.config.app-custom.discovery-subnets="192.168.10.0/24"
    
    curl -X POST http://localhost:59989/api/v2/discovery
    ```

- Using a [config-provider-snap] to set device configuration


- Using the `auto-configure` command. 
  
    This command finds all local network interfaces which are online and non-virtual and sets the value of `DiscoverySubnets` 
    in Consul. When running with security enabled, it requires a Consul token, so it needs to be run as follows:

    ```bash
    # get Consul ACL token
    CONSUL_TOKEN=$(sudo cat /var/snap/edgexfoundry/current/secrets/consul-acl-token/bootstrap_token.json | jq ".SecretID" | tr -d '"') 
    echo $CONSUL_TOKEN 
    
    # start the device service and connect the interfaces required for network interface discovery
    sudo snap start edgex-device-rfid-llrp.device-rfid-llrp 
    sudo snap connect edgex-device-rfid-llrp:network-control 
    sudo snap connect edgex-device-rfid-llrp:network-observe 
    
    # run the nework interface discovery, providing the Consul token
    edgex-device-rfid-llrp.auto-configure $CONSUL_TOKEN
    ```

### Device SNMP
| [Installation][edgex-device-snmp] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-snmp-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-snmp/current/config/
└── device-snmp
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── device.snmp.trendnet.TPE082WS.yaml
        └── profiles
            ├── device.snmp.patlite.yaml
            ├── device.snmp.switch.dell.N1108P-ON.yaml
            └── device.snmp.trendnet.TPE082WS.yaml
```

### Device USB Camera
| [Installation][edgex-device-usb-camera] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-usb-camera/tree/main/snap) |

This snap includes two services:

- Device USB Camera service
- [Simple RTSP Server](https://github.com/aler9/rtsp-simple-server) - used as the default RTSP server by Device USB Camera service

The services are **not started** by default. Please refer to [configuration] and [managing services].

The snap uses the [camera interface](https://snapcraft.io/docs/camera-interface) to access local USB camera devices. The [interface management](https://snapcraft.io/docs/interface-management) document describes how Snap interfaces are used to control the access to resources.

The default configuration files are installed at:
```
/var/snap/edgex-device-usb-camera/current/config
├── device-usb-camera
│   └── res
│       ├── configuration.yaml
│       ├── devices
│       │   ├── general.usb.camera.yaml.example
│       │   └── hp.w200.yaml.example
│       ├── profiles
│       │   ├── general.usb.camera.yaml
│       │   ├── hp.w200.yaml.example
│       │   └── jinpei.general.yaml.example
│       └── provision_watchers
│           └── generic.provision.watcher.yaml
└── rtsp-simple-server
    └── config.yml
```

### Device Virtual
| [Installation][edgex-device-virtual] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-virtual-go/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-virtual/current/config
└── device-virtual
    └── res
        ├── configuration.yaml
        ├── devices
        │   └── devices.yaml
        └── profiles
            ├── device.virtual.binary.yaml
            ├── device.virtual.bool.yaml
            ├── device.virtual.float.yaml
            ├── device.virtual.int.yaml
            └── device.virtual.uint.yaml
```

### Device ONVIF Camera
| [Installation][edgex-device-onvif-camera] | [Configuration] | [Managing Services] | [Debugging] | [Source](https://github.com/edgexfoundry/device-onvif-camera/tree/main/snap) |

The service is **not started** by default. Please refer to [configuration] and [managing services].

The default configuration files are installed at:
```
/var/snap/edgex-device-onvif-camera/current/config
└── device-onvif-camera
    └── res
        ├── configuration.yaml
        ├── devices
        │   ├── camera.yaml.example
        │   └── control-plane-device.yaml
        ├── profiles
        │   ├── camera.yaml
        │   └── control-plane.profile.yaml
        └── provision_watchers
            └── generic.provision.watcher.yaml
```

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
[edgex-device-modbus]: https://snapcraft.io/edgex-device-modbus
[edgex-device-mqtt]: https://snapcraft.io/edgex-device-mqtt
[edgex-device-rest]: https://snapcraft.io/edgex-device-rest
[edgex-device-rfid-llrp]: https://snapcraft.io/edgex-device-rfid-llrp
[edgex-device-snmp]: https://snapcraft.io/edgex-device-snmp
[edgex-device-usb-camera]: https://snapcraft.io/edgex-device-usb-camera
[edgex-device-virtual]: https://snapcraft.io/edgex-device-virtual
[edgex-device-onvif-camera]: https://snapcraft.io/edgex-device-onvif-camera
[edgex-ekuiper]: https://snapcraft.io/edgex-ekuiper
