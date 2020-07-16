# Configuration and Registry

![image](EdgeX_CoreRegConfig.png)

## Introduction

The purpose of this section is to describe the configuration and service
registration capabilities of the EdgeX Foundry platform. In all cases
unless otherwise specified, the examples provided are based on the
reference architecture built using the [Go programming
language](https://golang.org/) .

### Configuration

An overview of the architectural decisions made with regard to how 
configuration works in EdgeX Foundry can be found [here](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0005-Service-Self-Config.md).

#### Local Configuration

Because EdgeX Foundry may be deployed and run in several different ways,
it is important to understand how configuration is loaded and from where
it is sourced. Referring to the cmd directory within the [edgex-go
repository](https://github.com/edgexfoundry/edgex-go) , each service has
its own folder. Inside each service folder there is a `res` directory
(short for "resource"). There you will find the configuration files in
[TOML format](https://github.com/toml-lang/toml) that defines each
service's configuration. A service may support several different
configuration profiles, such as a "docker" profile. In this case, the
configuration file located directly in the `res` directory should be
considered the default configuration profile. Sub-directories will
contain configurations appropriate to the respective profile.

As of the Geneva release, it is recommended to utilize environment variable
overrides rather than creating profiles to override some subset of config
values. You can see examples of this in the related docker-compose [files](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/geneva/compose-files).

If you choose to utilize profiles as described above, the config profile
can be indicated using one of the following command line flags:

`--profile / -p`

Taking the `core-data` service as an example:

-   `./core-data` starts the service using the default profile found
    locally
-   `./core-data --profile=<your profile>` starts the service using the docker
    profile found locally

* Again, utilizing environment variables for configuration overrides is
the recommended path. Config profiles have been deprecated and removed as of the Geneva release. *

#### Seeding Configuration

When utilizing the registry to provide centralized configuration
management for the EdgeX Foundry microservices, it is necessary to seed
the required configuration before starting the services. Each service
has the built-in capability to perform this seeding operation. A service
will use its local configuration file to initialize the structure and
relevant values, and then overlay any environment variable override values as specified. The end result will be seeded into the configuration provider if such is being used.

In order for a service to now load the
configuration from the configuration provider, we must use one of the following flags:

`--configProvider / -cp`

Again, taking the `core-data` service as an example:

`./core-data -cp=http://localhost:8500` will start the service using configuration values found in the provider

#### Configuration Structure

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

#### Versioning

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
in a major version, nor will sections of the configuration tree be moved
from one place to another. In this way backward compatibility for the
lifetime of the major version is maintained.

An advantage of grouping all minor/patch versions under a major version
involves end-user configuration changes that need to be persisted during
an upgrade. A service on startup will not overwrite existing configuration when it runs unless explicitly told to do so via the `--overwrite / -o` command line flag. Therefore if a user leaves their
configuration provider running during an EdgeX Foundry upgrade any customizations will be left in place. Environment variable overrides such as those supplied in the docker-compose for a given release will always override existing content in Consul.

## Configuration Properties

The following table documents configuration properties that are common to all services in the EdgeX Foundry platform. Service-specific properties can be found on the respective documentation page for each service.

  |Configuration  |     Default Value     |             Dependencies|
  | --- | --- | -- |
| **Entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider=<url>` flag** |
  |Writable LogLevel       |INFO \*                            |Logs messages set to a level of "INFO" or higher|
  |**The following keys represent the core service-level configuration settings**|
  |Service MaxResultCount  |50000 \*\*                        |Read data limit per invocation|
  |Service BootTimeout     |300000 \*\*                       |Heart beat time in milliseconds|
  |Service StartupMsg      |Logging Service heart beat \*\*   |Heart beat message|
  |Service Port            |48061 \*\*                        |Micro service port number|
  |Service Host            |localhost \*\*                    |Micro service host name|
  |Service Protocol        |http \*\*                         |Micro service host protocol|
  |Service ClientMonitor   |15000 \*\*                        |The interval in milliseconds at which any service clients will refresh their endpoint information from the service registry (Consul)|
  |Service CheckInterval   |10s \*\*                          | The interval in seconds at which the service registry(Consul) will conduct a health check of this service.|
  |Service Timeout         |5000 \*\*                         | Specifies a timeout (in milliseconds) for handling requests|
  |**The following keys govern logging behavior. With the default values below, all logging will simply be written to StdOut.**|
  |Logging EnableRemote | false \*\*  | Facilitates delegation of logging via REST to the support-logging service |
  |Logging File     |       \[empty string\] \*\*   |File path to save logging entries. Empty by default.|
  |**The following keys govern database connectivity and the type of database to use. While not all services require DB connectivity, most do and so this has been included in the common configuration docs.**|
  |Databases Primary Username      |\[empty string\] \*\*              |DB user name                                           |
  |Databases Primary Password       |\[empty string\] \*\*              |DB password|
  |Databases Primary Host |localhost \*\*                     |DB host name|
  |Databases Primary Port |6379 \*\*                        |DB port number|
  |Databases Primary Name      |coredata \*\*                      |Database or document store name            |
  |Databases Primary Timeout      |5000 \*\*                          |DB connection timeout                                              |
  |Databases Primary Type |redisdb \*\*                       |DB type|
  |**Following config only take effect when connecting to the registry for configuration info**|
  |Registry Host           |localhost \*\*                     |Registry host name|
  |Registry Port           |8500 \*\*                          |Registry port number|
  |Registry Type           |consul \*\*                        |Registry implementation type|
|**Following config is an example of how service clients are configured. These will of necessity be different in each config because each service has a different set of dependencies, each of which requires a client.**|
|Clients Metadata Protocol | http \*\* | The protocol to use when building a URI to local the service endpoint|
|Clients Metadata Host | localhost \*\* | The host name or IP address where the service is hosted |
|Clients Metadata Port | 48081 \*\* | The port exposed by the target service|
|**Following config values govern the StartupTimer created at boot for ensuring the service starts in a timely fashion**|
|Startup Duration| 30 \*\* | The maximum amount of time (in seconds) the service is given to complete the bootstrap phase.|
|Startup Interval| 1 \*\* | The amount of time (in seconds) to sleep between retries on a failed dependency such as DB connection|
|**Following config values are used when security is enabled and Vault access is required for obtaining secrets, such as database credentials**|
|SecretStore Host | localhost \*\* | The host name or IP address associated with Vault|
|SecretStore Port | 8200 \*\* | The configured port on which Vault is listening|
|SecretStore Path | /v1/secret/edgex/coredata/ \*\* | The service-specific path where the secrets are kept. This path will differ according to the given service|
|SecretStore Protocol | https \*\* | The protocol to be used when communicating with Vault|
|SecretStore RootCaCertPath | /vault/config/pki/EdgeXFoundryCA/ EdgeXFoundryCA.pem \*\* | The default location of the certificate used to communicate with Vault over a secure channel|
|SecretStore ServerName | localhost \*\* | The name of the server where Vault is located.|
|SecretStore TokenFile | /vault/config/assets/resp-init.json \*\* | Fully-qualified path to the location of the Vault root token.|
|SecretStore AdditionalRetryAttempts | 10 \*\* | Number of attemtps to retry retrieving secrets before failing to start the service|
|SecretStore RetryWaitPeriod | 1s \*\* | Amount of time to wait before attempting another connection to Vault|
|SecretStore Authentication AuthType | X-Vault-Token \*\* | A header used to indicate how the given service will authenticate with Vault|
 | | | |

\*means the configuration value can be changed on the fly if using a configuration provider (like Consul).

\*\*means the configuration value can be changed but the service must be restarted.

#### Readable vs Writable Settings

Within a given service's configuration, there are keys whose values can
be edited and change the behavior of the service while it is running
versus those that are effectively read-only. These writable settings are
grouped under a given service key. For example, the top-level groupings
for edgex-core-data are:

-   /edgex/core/1.0/edgex-core-data/Clients
-   /edgex/core/1.0/edgex-core-data/Databases
-   /edgex/core/1.0/edgex-core-data/Logging
-   /edgex/core/1.0/edgex-core-data/MessageQueue
-   /edgex/core/1.0/edgex-core-data/Registry
-   /edgex/core/1.0/edgex-core-data/SecretStore
-   /edgex/core/1.0/edgex-core-data/Service
-   /edgex/core/1.0/edgex-core-data/Writable

Any configuration settings found in the `Writable` section shown above
may be changed and affect a service's behavior without a restart. Any
modifications to the other settings would require a restart.

*NOTE: As of the Geneva release, the support-logging service is deprecated. In the Readable section of each service's configuration there is currently a Logging section shown below. The recommendation is that you not change the default values in this section unless you have a specific reason for doing so.*

```
# Remote and file logging disabled so only stdout logging is used
[Logging]  
EnableRemote = false  
File = ''
```

## Configuration Provider

You can supply and manage configuration in a centralized manner by utilizing the `-cp/--configProvider=<url>` flag when starting a service. If the flag is provided and pointed to an application such as HashiCorp's [Consul](https://www.consul.io/), the service will bootstrap its configuration into Consul if it doesn't exist. If configuration does already exist, it will load the content from the given location applying any environment variables overrides of which the service is aware. Integration with the configuration provider is handled through the
[go-mod-configuration](https://github.com/edgexfoundry/go-mod-configuration) module referenced by all services.

## Registry Provider

The registry refers to any platform you may use for service discovery. For the EdgeX Foundry reference implementation, the default provider for this responsibility is Consul. Integration with the registry is handled through the
[go-mod-registry](https://github.com/edgexfoundry/go-mod-registry)
module referenced by all services.

![image](./EdgeX_RegistryHighlighted.png)

### Introduction to Registry

The objective of the registry is to enable microservices to find and to
communicate with each other. When each microservice starts up, it
registers itself with the registry, and the registry continues checking
its availability periodically via a specified health check endpoint.
When one microservice needs to connect to another one, it connects to
the registry to retrieve the available host name and port number of the
target microservice and then invokes the target microservice. The
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

A web user interface is also provided by Consul natively. Users can view
the available service list and their health status through the web user
interface. The web user interface is available at the /ui path on the
same port as the HTTP API. By default this is
<http://localhost:8500/ui>. For more detail, please see:

> <https://www.consul.io/intro/getting-started/ui.html>

### Running on Docker

For ease of use to install and update, the microservices of EdgeX
Foundry are also published as Docker images onto Docker Hub, including
Registry:

> <https://hub.docker.com/r/edgexfoundry/docker-core-consul/>

After the Docker engine is ready, users can download the latest Consul
image by the docker pull command:

> docker pull edgexfoundry/docker-core-consul

Then, startup Consul using Docker container by the Docker run command:

> docker run -p 8400:8400 -p 8500:8500 -p 8600:8600 \--name
> edgex-core-consul \--hostname edgex-core-consul -d
> edgexfoundry/docker-core-consul

These are the command steps to start up Consul and import the default
configuration data:

1.  login to Docker Hub:

> \$ docker login

2.  A Docker network is needed to enable one Docker container to
    communicate with another. This is preferred over use of \--links
    that establishes a client-server relationship:

> \$ docker network create edgex-network

3.  Create a Docker volume container for EdgeX Foundry:

> \$ docker run -it \--name edgex-files \--net=edgex-network -v /data/db
> -v /edgex/logs -v /consul/config -v /consul/data -d
> edgexfoundry/docker-edgex-volume

4.  Create the Consul container:

> \$ docker run -p 8400:8400 -p 8500:8500 -p 8600:8600 \--name
> edgex-core-consul \--hostname edgex-core-consul \--net=edgex-network
> \--volumes-from edgex-files -d edgexfoundry/docker-core-consul

5.  Verify the result: <http://localhost:8500/ui>

### Running on Local Machine

To run Consul on the local machine, requires the following steps:

1.  Download the binary from Consul official website:
    <https://www.consul.io/downloads.html>. Please choose the correct
    binary file according to the operation system.
2.  Set up the environment variable. Please refer to
    <https://www.consul.io/intro/getting-started/install.html>.
3.  Execute the following command:

> \$ consul agent -data-dir \${DATA\_FOLDER} -ui -advertise 127.0.0.1
> -server -bootstrap-expect 1
>
> \${DATA\_FOLDER} could be any folder to put the data files of Consul,
> and it needs the read/write permission.

4.  Verify the result: <http://localhost:8500/ui>
