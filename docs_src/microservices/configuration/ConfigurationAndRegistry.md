# Configuration and Registry Providers



![image](EdgeX_CoreRegConfig.png)

## Introduction

!!! Note
    Consul will be deprecated in EdgeX 4.0, and core-keeper will become the new registry and configuration provider.
    
 The EdgeX registry and configuration service provides other EdgeX Foundry micro services with information about associated services within EdgeX Foundry (such as location and status) and  configuration properties (i.e. - a repository of initialization and operating values).  Today, EdgeX Foundry uses [Consul by Hashicorp](https://www.consul.io/) as its reference implementation configuration and registry providers.  However, abstractions are in place so that these functions could be provided by an alternate implementation.  In fact, registration and configuration could be provided by different services under the covers.  For more, see the [Configuration Provider](ConfigurationAndRegistry.md#configuration-provider) and [Registry Provider](ConfigurationAndRegistry.md#registry-provider) sections in this page.

## Configuration

Please refer to the following EdgeX Foundry ADRs for details (and design decisions) behind the configuration in EdgeX

- [Service Self Config Seeding](../../../design/adr/0005-Service-Self-Config)
- [Common Configuration](../../../design/adr/0026-Common%20Configuration/)

### Common Configuration

!!! edgey - "EdgeX 3.0"
    Common configuration in single location is new in Edgex 3.0

Many of EdgeX service's configuration settings are the same as all other services. 
These common configuration settings have been consolidated into a single common configuration location which is seeded by the **core-common-config-bootstrapper** service.
This service seeds the configuration provider with the common configuration from its local file located in the `cmd/res/configuration.yaml`.
See the [Common Configuration](../CommonConfiguration/) for list of all the common configuration settings.

### Local Configuration

Because EdgeX Foundry may be deployed and run in several different ways, 
it is important to understand how configuration is loaded and from where it is sourced. 
Referring to the cmd directory within the [edgex-go repository](https://github.com/edgexfoundry/edgex-go), each service has its own folder. 
Inside each service's folder there is a `res` directory (short for "resource").
There the configuration files in [YAML format](https://en.wikipedia.org/wiki/YAML) define each service's configuration. 
A service may support several different configuration profiles, such as a App Service Configurable does. 
In this case, the configuration file located directly in the `res` directory should be considered the default configuration profile. 
Sub-directories will contain configurations appropriate to the respective profile.

As of the Geneva release, EdgeX recommends using environment variable overrides instead of creating profiles to override some subset of config values. 
App Service Configurable is an exception to this as this is how it defined unique instances using the same executable.

If you choose to use profiles as described above, the config profile can be indicated using one of the following command line flags:

`--profile / -p`

Taking the `Core Data` and `App Service Configurable` services as an examples:

-   `./core-data` starts the service using the default profile found locally
-   `./app-service-configurable --profile=rules-engine` starts the service using the `rules-engine` profile found locally

!!! Note
    Again, utilizing environment variables for configuration overrides is the recommended path. Config profiles, for the most part, are not used.

### Seeding Configuration

!!! edgey - "EdgeX 3.0"
    Seeding of the new separate common configuration is new in Edgex 3.0

When utilizing the centralized configuration management for the EdgeX Foundry microservices, 
it is necessary to seed the required configuration before starting the services.
The new **core-common-config-bootstrapper** is responsible for seeding the common configuration that all services now depend on.
Each service has the built-in capability to perform the seeding operation for its private configuration. 
A service will use its local configuration file to seeded into the configuration provider if such is being used.

In order for a service to seed/load the configuration to/from the configuration provider, use one of the following flags:

`--configProvider / -cp`

Again, taking the `core-data` service as an example:

`./core-data -cp=consul.http://localhost:8500` will start the service using configuration values found in the provider or seed them if they do not exist. 

!!! edgey - "EdgeX 3.0"
    In EdgeX 3.0, the common environment variable overrides are applied to this common configuration prior to pushing the configuration into the configuration provider. This dramatically reduces the number of duplicate environment variable overrides in the Docker compose files.

### Configuration Structure

!!! edgey - "EdgeX 3.0"
    In EdgeX 3.0, the configuration is no longer organized into a hierarchical structure grouped by service types.

The root namespace separates EdgeX Foundry related configuration information from other applications that may be using the same configuration provider. 
Below the root is the configuration version and then all the individual services in a flat list. 
As an example, the nodes shown when one views the configuration provider might be as follows:

!!! example - "Example configuration structure"
    ```
    **edgex/{{api_version}}** (root namespace)
        - app-* (app services)
        - core-* (core services which includes common config)
        - devices-* (device services)
        - security-* (security services)
        - support-* (support services)
    ```
### Versioning

The version is now part of the root namespace , i.e. `edgex/{{api_version}}`

An advantage of grouping all minor/patch versions under a major version involves end-user configuration changes that need to be persisted during an upgrade. 
A service on startup will not overwrite existing configuration when it runs unless explicitly told to do so via the `--overwrite / -o` command line flag. 
Therefore, if a user leaves their configuration provider running during an EdgeX Foundry upgrade any customization will be left in place. 
Environment variable overrides such as those supplied in the docker-compose for a given release will always override existing content in the configuration provider.

## Configuration Provider

You can supply and manage configuration in a centralized manner by utilizing the `-cp/--configProvider` flag when starting a service. If the flag is provided and points to an application such as [HashiCorp's Consul](https://www.consul.io/), the service will bootstrap its configuration into the provider, if it doesn't exist. If configuration does already exist, it will load the content from the given location applying any environment variables overrides of which the service is aware. Integration with the configuration provider is handled through the [go-mod-configuration](https://github.com/edgexfoundry/go-mod-configuration) module referenced by all services.

## Registry Provider

The registry refers to any platform you may use for service discovery. For the EdgeX Foundry reference implementation, the default provider for this responsibility is Consul. Integration with the registry is handled through the [go-mod-registry](https://github.com/edgexfoundry/go-mod-registry) module referenced by all services.

### Introduction to Registry

The objective of the registry is to enable micro services to find and to communicate with each other. When each micro service starts up, it registers itself with the registry, and the registry continues checking
its availability periodically via a specified health check endpoint. When one micro service needs to connect to another one, it connects to the registry to retrieve the available host name and port number of the
target micro service and then invokes the target micro service. The following figure shows the basic flow.

![image](EdgeX_ConfigurationRegistry.png)

Consul is the default registry implementation and provides native features for service registration, service discovery, and health checking. Please refer to the Consul official web site for more information:

> <https://www.consul.io>

Physically, the "registry" and "configuration" management services are combined and running on the same Consul server node.

### Web User Interface

A web user interface is also provided by Consul. Users can view the available service list and their health status through the web user interface. The web user interface is available at the /ui path on the same port as the HTTP API. By default this is <http://localhost:8500/ui>. For more detail, please see:

> <https://developer.hashicorp.com/consul/tutorials/certification-associate-tutorials/get-started-explore-the-ui>

### Running on Docker

For ease of use to install and update, the microservices of EdgeX Foundry are published as Docker images onto Docker Hub and compose files that allow you to run EdgeX and dependent service such as Consul. These compose files can be found here in the [edgex-compose repository](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}). See the [Getting Started using Docker](../../../getting-started/Ch-GettingStartedDockerUsers) for more details.

Once the EdgeX stack is running in docker verify Consul is running by going to  <http://localhost:8500/ui> in your browser.

### Running on Local Machine

To run Consul on the local machine, following these steps:

1.  Download the binary from Consul official website:
    <https://developer.hashicorp.com/consul/downloads>. Please choose the correct
    binary file according to the operation system.
2.  Set up the environment variable. Please refer to
    <https://developer.hashicorp.com/consul/tutorials/get-started-vms/virtual-machine-gs-deploy>.
3.  Execute the following command:

    ``` bash
    consul agent -data-dir \${DATA_FOLDER} -ui -advertise 127.0.0.1 -server -bootstrap-expect 1

    # ${DATA_FOLDER} could be any folder to put the data files of Consul and it needs the read/write permission.
    ```

4.  Verify the result: <http://localhost:8500/ui>
