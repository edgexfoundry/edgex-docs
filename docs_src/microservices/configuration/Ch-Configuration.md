# Configuration and Registry

![image](EdgeX_RegistryHighlighted.png)

## Introduction

 The EdgeX registry and configuration service provides other EdgeX Foundry micro services with information about associated services within EdgeX Foundry (such as location and status) and  configuration properties (i.e. - a repository of initialization and operating values).  Today, EdgeX Foundry uses [Consul by Hashicorp](https://www.consul.io/) as its reference implementation configuration and registry service.  However, abstractions are in place so that these functions could be provided by an alternate implementation.  In fact, registration and configuration could be provided by different services under the covers.  For more, see the [Configuration Provider](./Ch-Configuration.md#configuration-provider) and [Registry Provider](./Ch-Configuration.md#registry-provider) sections in this page.

## Configuration

Please refer to the EdgeX Foundry [architectural decision record](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0005-Service-Self-Config.md) for details (and design decisions) behind the configuration in EdgeX.

### Local Configuration

Because EdgeX Foundry may be deployed and run in several different ways,
it is important to understand how configuration is loaded and from where
it is sourced. Referring to the cmd directory within the [edgex-go repository](https://github.com/edgexfoundry/edgex-go) , each service has
its own folder. Inside each service folder there is a `res` directory
(short for "resource"). There you will find the configuration files in
[TOML format](https://github.com/toml-lang/toml) that defines each
service's configuration. A service may support several different
configuration profiles, such as a "docker" profile. In this case, the
configuration file located directly in the `res` directory should be
considered the default configuration profile. Sub-directories will
contain configurations appropriate to the respective profile.

As of the Geneva release, EdgeX recommends using environment variable
overrides instead of creating profiles to override some subset of config
values. You can see examples of this in the related [docker-compose files](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/geneva/compose-files).

If you choose to use profiles as described above, the config profile
can be indicated using one of the following command line flags:

`--profile / -p`

Taking the `core-data` service as an example:

-   `./core-data` starts the service using the default profile found locally
-   `./core-data --profile=docker` starts the service using the docker profile found locally

!!! Note
    Again, utilizing environment variables for configuration overrides is the recommended path. Config profiles have been deprecated and will be removed in a future release.

### Seeding Configuration

When utilizing the registry to provide centralized configuration
management for the EdgeX Foundry micro services, it is necessary to seed
the required configuration before starting the services. Each service
has the built-in capability to perform this seeding operation. A service
will use its local configuration file to initialize the structure and
relevant values, and then overlay any environment variable override values as specified. The end result will be seeded into the configuration provider if such is being used.

In order for a service to now load the
configuration from the configuration provider, use one of the following flags:

`--configProvider / -cp`

Again, taking the `core-data` service as an example:

`./core-data -cp=http://localhost:8500` will start the service using configuration values found in the provider

### Configuration Structure

Configuration information is organized into a hierarchical structure
allowing for a logical grouping of services, as well as versioning,
beneath an "edgex" namespace at root level of the configuration tree.
The root namespace separates EdgeX Foundry-related configuration
information from other applications that may be using the same registry.
Below the root, sub-nodes facilitate grouping of device services, EdgeX
core services, security services, etc. As an example, the top-level
nodes shown when one views the configuration registry might be as
follows:

- edgex *(root namespace)*
    -   core *(edgex core services)*
    -   devices *(device services)*

### Versioning

Incorporating versioning into the configuration hierarchy looks like
this.

- edgex *(root namespace)*
    -   core *(edgex core services)*
        -   1.0
            -   edgex-core-command
            -   edgex-core-data
            -   edgex-core-metadata
        -   2.0
    - devices *(device services)*
        -   1.0
            -   mqtt-c
            -   mqtt-go
            -   modbus-go
        -   2.0
    - appservices *(application services)*
        - 1.0
            - AppService-rules-engine
        - 2.0

The versions shown correspond to major versions of the given services.
For all minor/patch versions associated with a major version, the
respective service keys live under the major version in configuration
(such as 1.0). Changes to the configuration structure that may be
required during the associated minor version development cycles can only
be additive. That is, key names will not be removed or changed once set
in a major version.  Futhermore, sections of the configuration tree cannot be moved
from one place to another. In this way, backward compatibility for the
lifetime of the major version is maintained.

An advantage of grouping all minor/patch versions under a major version
involves end-user configuration changes that need to be persisted during
an upgrade. A service on startup will not overwrite existing configuration when it runs unless explicitly told to do so via the `--overwrite / -o` command line flag. Therefore if a user leaves their
configuration provider running during an EdgeX Foundry upgrade any customization will be left in place. Environment variable overrides such as those supplied in the docker-compose for a given release will always override existing content in the configuration provider.

## Configuration Properties

The following tables document configuration properties that are common to all services in the EdgeX Foundry platform. Service-specific properties can be found on the respective documentation page for each service.

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider=<url>` flag|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored.|
 === "Service"
    |Property|Default Value|Description|
    |---|---|---|
    |||these keys represent the core service-level configuration settings|
    |MaxResultCount|50000|Read data limit per invocation|
    |BootTimeout     |300000                        |Heart beat time in milliseconds|
    |StartupMsg      |Logging Service heart beat    |Heart beat message|
    |Port            |48061                         |Micro service port number|
    |Host            |localhost                     |Micro service host name|
    |Protocol        |http                          |Micro service host protocol|
    |ClientMonitor   |15000                         |The interval in milliseconds at which any service clients will refresh their endpoint information from the service registry (Consul)|
    |CheckInterval   |10s                           | The interval in seconds at which the service registry(Consul) will conduct a health check of this service.|
    |Timeout         |5000                          | Specifies a timeout (in milliseconds) for handling requests|
=== "Logging"
    |Property|Default Value|Description|
    |---|---|---|
    |||configuration governing logging behavior. With the default values below, all logging will be written to StdOut.|
    |EnableRemote | false   | Facilitates delegation of logging via REST to the support-logging service |
    |File     |       \[empty string\]    |File path to save logging entries. Empty by default.|
=== "Databases/Databases.Primary"
    |Property|Default Value|Description|
    |---|---|---|
    |||configuration that govern database connectivity and the type of database to use. While not all services require DB connectivity, most do and so this has been included in the common configuration docs.|
    |Username      |\[empty string\]               |DB user name                                           |
    |Password       |\[empty string\]               |DB password|
    |Host |localhost                      |DB host name|
    |Port |6379                         |DB port number|
    |Name      |coredata                       |Database or document store name            |
    |Timeout      |5000                           |DB connection timeout                                              |
    |Type |redisdb                        |DB type.  Alternate is mongodb which is being deprecated|
=== "Registry"
    |Property|Default Value|Description|
    |---|---|---|
    |||this configuration only takes effect when connecting to the registry for configuration info|
    |Host           |localhost                      |Registry host name|
    |Port           |8500                           |Registry port number|
    |Type           |consul                         |Registry implementation type|
=== "Clients/[Service name like Metadata]"
    |Property|Default Value|Description|
    |---|---|---|
    ||||example of how service clients are configured. These will of necessity be different in each config because each service has a different set of dependencies, each of which requires a client.|
    |Protocol | http  | The protocol to use when building a URI to local the service endpoint|
    |Host | localhost  | The host name or IP address where the service is hosted |
    |Port | 48081  | The port exposed by the target service|
=== "Startup"
    |Property|Default Value|Description|
    |---|---|---|
    ||||config values that govern the StartupTimer created at boot for ensuring the service starts in a timely fashion|
    |Duration| 30  | The maximum amount of time (in seconds) the service is given to complete the bootstrap phase.|
    |Interval| 1  | The amount of time (in seconds) to sleep between retries on a failed dependency such as DB connection|
=== "SecretStore"
    |Property|Default Value|Description|
    |---|---|---|
    |||these config values are used when security is enabled and Vault access is required for obtaining secrets, such as database credentials|
    |Host | localhost  | The host name or IP address associated with Vault|
    |Port | 8200  | The configured port on which Vault is listening|
    |Path | /v1/secret/edgex/coredata/  | The service-specific path where the secrets are kept. This path will differ according to the given service|
    |Protocol | https  | The protocol to be used when communicating with Vault|
    |RootCaCertPath | /vault/config/pki/EdgeXFoundryCA/ EdgeXFoundryCA.pem  | The default location of the certificate used to communicate with Vault over a secure channel|
    |ServerName | localhost  | The name of the server where Vault is located.|
    |TokenFile | /vault/config/assets/resp-init.json  | Fully-qualified path to the location of the Vault root token.|
    |AdditionalRetryAttempts | 10  | Number of attemtps to retry retrieving secrets before failing to start the service|
    |RetryWaitPeriod | 1s  | Amount of time to wait before attempting another connection to Vault|
    |Authentication AuthType | X-Vault-Token  | A header used to indicate how the given service will authenticate with Vault|

### Readable vs Writable Settings

Within a given service's configuration, there are keys whose values can
be edited and change the behavior of the service while it is running
versus those that are effectively read-only. These writable settings are
grouped under a given service key. For example, the top-level groupings
for edgex-core-data are:

- /edgex/core/1.0/edgex-core-data/Clients
- /edgex/core/1.0/edgex-core-data/Databases
- /edgex/core/1.0/edgex-core-data/Logging
- /edgex/core/1.0/edgex-core-data/MessageQueue
- /edgex/core/1.0/edgex-core-data/Registry
- /edgex/core/1.0/edgex-core-data/SecretStore
- /edgex/core/1.0/edgex-core-data/Service
- **/edgex/core/1.0/edgex-core-data/Writable**

Any configuration settings found in the `Writable` section shown above
may be changed and affect a service's behavior without a restart. Any
modifications to the other settings (read-only configuration) would require a restart.

!!! Note
    As of the Geneva release, the support-logging service is deprecated. In the Readable section of each service's configuration there is currently a Logging section shown below. The recommendation is that you not change the default values in this section unless you have a specific reason for doing so.

``` YAML
# Remote and file logging disabled so only stdout logging is used
[Logging]  
EnableRemote = false  
File = ''
```

## Configuration Provider

You can supply and manage configuration in a centralized manner by utilizing the `-cp/--configProvider=<url>` flag when starting a service. If the flag is provided and pointed to an application such as [HashiCorp's Consul](https://www.consul.io/), the service will bootstrap its configuration into Consul if it doesn't exist. If configuration does already exist, it will load the content from the given location applying any environment variables overrides of which the service is aware. Integration with the configuration provider is handled through the
[go-mod-configuration](https://github.com/edgexfoundry/go-mod-configuration) module referenced by all services.

## Registry Provider

The registry refers to any platform you may use for service discovery. For the EdgeX Foundry reference implementation, the default provider for this responsibility is Consul. Integration with the registry is handled through the [go-mod-registry](https://github.com/edgexfoundry/go-mod-registry) module referenced by all services.

### Introduction to Registry

The objective of the registry is to enable micro services to find and to
communicate with each other. When each micro service starts up, it
registers itself with the registry, and the registry continues checking
its availability periodically via a specified health check endpoint.
When one micro service needs to connect to another one, it connects to
the registry to retrieve the available host name and port number of the
target micro service and then invokes the target micro service. The
following figure shows the basic flow.

![image](EdgeX_ConfigurationRegistry.png)

Consul is the default registry implementation and provides native
features for service registration, service discovery, and health
checking. Please refer to the Consul official web site for more
information:

> <https://www.consul.io>

Physically, the "registry" and "configuration" management services
are combined and running on the same Consul server node.

### Web User Interface

A web user interface is also provided by Consul. Users can view
the available service list and their health status through the web user
interface. The web user interface is available at the /ui path on the
same port as the HTTP API. By default this is
<http://localhost:8500/ui>. For more detail, please see:

> <https://www.consul.io/intro/getting-started/ui.html>

### Running on Docker

For ease of use to install and update, the micro services of EdgeX
Foundry are published as Docker images onto Docker Hub, including
Registry:

> <https://hub.docker.com/r/edgexfoundry/docker-core-consul/>

After the Docker engine is ready, users can download the latest Consul
image by the docker pull command:

``` bash
docker pull edgexfoundry/docker-core-consul
```

Then, startup Consul using Docker container by the Docker run command:

``` bash
docker run -p 8400:8400 -p 8500:8500 -p 8600:8600 \--name edgex-core-consul \--hostname edgex-core-consul -d edgexfoundry/docker-core-consul
```

These are the command steps to start up Consul and import the default
configuration data:

1.  login to Docker Hub:

    ``` bash
    docker login
    ```

2.  A Docker network is needed to enable one Docker container to
    communicate with another. This is preferred over use of \--links
    that establishes a client-server relationship:

    ``` bash
    docker network create edgex-network
    ```

3.  Create a Docker volume container for EdgeX Foundry:

    ``` bash
    docker run -it --name edgex-files --net=edgex-network -v /data/db -v /edgex/logs -v /consul/config -v /consul/data -d edgexfoundry/docker-edgex-volume
    ```

4.  Create the Consul container:

    ``` bash
    docker run -p 8400:8400 -p 8500:8500 -p 8600:8600 --name edgex-core-consul --hostname edgex-core-consul --net=edgex-network --volumes-from edgex-files -d edgexfoundry/docker-core-consul
    ```

5.  Verify the result: <http://localhost:8500/ui>

### Running on Local Machine

To run Consul on the local machine, following these steps:

1.  Download the binary from Consul official website:
    <https://www.consul.io/downloads.html>. Please choose the correct
    binary file according to the operation system.
2.  Set up the environment variable. Please refer to
    <https://www.consul.io/intro/getting-started/install.html>.
3.  Execute the following command:

    ``` bash
    consul agent -data-dir \${DATA_FOLDER} -ui -advertise 127.0.0.1 -server -bootstrap-expect 1

    # ${DATA_FOLDER} could be any folder to put the data files of Consul and it needs the read/write permission.
    ```

4.  Verify the result: <http://localhost:8500/ui>
