# Configuration and Registry Providers



![image](EdgeX_CoreRegConfig.png)

## Introduction

 The EdgeX registry and configuration service provides other EdgeX Foundry micro services with information about associated services within EdgeX Foundry (such as location and status) and  configuration properties (i.e. - a repository of initialization and operating values).  Today, EdgeX Foundry uses [Consul by Hashicorp](https://www.consul.io/) as its reference implementation configuration and registry providers.  However, abstractions are in place so that these functions could be provided by an alternate implementation.  In fact, registration and configuration could be provided by different services under the covers.  For more, see the [Configuration Provider](ConfigurationAndRegistry.md#configuration-provider) and [Registry Provider](ConfigurationAndRegistry.md#registry-provider) sections in this page.

## Configuration

Please refer to the EdgeX Foundry [architectural decision record](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0005-Service-Self-Config.md) for details (and design decisions) behind the configuration in EdgeX.

### Local Configuration

Because EdgeX Foundry may be deployed and run in several different ways, it is important to understand how configuration is loaded and from where it is sourced. Referring to the cmd directory within the [edgex-go repository](https://github.com/edgexfoundry/edgex-go) , each service has its own folder. Inside each service folder there is a `res` directory
(short for "resource"). There you will find the configuration files in [TOML format](https://github.com/toml-lang/toml) that defines each service's configuration. A service may support several different configuration profiles, such as a App Service Configurable does. In this case, the configuration file located directly in the `res` directory should be considered the default configuration profile. Sub-directories will contain configurations appropriate to the respective profile.

As of the Geneva release, EdgeX recommends using environment variable overrides instead of creating profiles to override some subset of config values. App Service Configurable is an exception to this as this is how it defined unique instances using the same executable.

If you choose to use profiles as described above, the config profile can be indicated using one of the following command line flags:

`--profile / -p`

Taking the `Core Data` and `App Service Configurable` services as an examples:

-   `./core-data` starts the service using the default profile found locally
-   `./app-service-configurable --profile=rules-engine` starts the service using the `rules-engine` profile found locally

!!! Note
    Again, utilizing environment variables for configuration overrides is the recommended path. Config profiles, for the most part, are not used.

### Seeding Configuration

When utilizing the centralized configuration management for the EdgeX Foundry micro services, it is necessary to seed the required configuration before starting the services. Each service has the built-in capability to perform this seeding operation. A service will use its local configuration file to initialize the structure and relevant values, and then overlay any environment variable override values as specified. The end result will be seeded into the configuration provider if such is being used.

In order for a service to seed/load the configuration to/from the configuration provider, use one of the following flags:

`--configProvider / -cp`

Again, taking the `core-data` service as an example:

`./core-data -cp=consul.http://localhost:8500` will start the service using configuration values found in the provider or seed them if they do not exist. 

!!! note
    Environment overrides are also applied after the configuration is loaded from the configuration provider. 

### Configuration Structure

Configuration information is organized into a hierarchical structure allowing for a logical grouping of services, as well as versioning, beneath an "edgex" namespace at root level of the configuration tree.
The root namespace separates EdgeX Foundry-related configuration information from other applications that may be using the same configuration provider. Below the root, sub-nodes facilitate grouping of device services, core/support/security services, app services, etc. As an example, the top-level nodes shown when one views the configuration registry might be as follows:

- edgex *(root namespace)*
    -   core *(core/support/security services)*
    -   devices *(device services)*
    -   appservices (*application services*)

### Versioning

Incorporating versioning into the configuration hierarchy looks like this.

- edgex *(root namespace)*
    -   core *(core/support/security services)*
        -   2.0
            -   core-command
            -   core-data
            -   core-metadata
            -   support-notifications
            -   support-scheduler
            -   sys-mgmt-agent
        -   30
    - devices *(device services)*
        -   2.0
            -   device-mqtt
            -   device-virtual
            -   device-modbus
        -   3.0
    - appservices *(application services)*
        - 2.0
            - app-rules-engine
        - 3.0

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the version number in the path is now `2.0` and the service keys are now used for the service names.

The versions shown correspond to major versions of the given services. For all minor/patch versions associated with a major version, the respective service keys live under the major version in configuration
(such as 2.0). Changes to the configuration structure that may be required during the associated minor version development cycles can only be additive. That is, key names will not be removed or changed once set in a major version.  Furthermore, sections of the configuration tree cannot be moved from one place to another. In this way, backward compatibility for the lifetime of the major version is maintained.

An advantage of grouping all minor/patch versions under a major version involves end-user configuration changes that need to be persisted during an upgrade. A service on startup will not overwrite existing configuration when it runs unless explicitly told to do so via the `--overwrite / -o` command line flag. Therefore if a user leaves their configuration provider running during an EdgeX Foundry upgrade any customization will be left in place. Environment variable overrides such as those supplied in the docker-compose for a given release will always override existing content in the configuration provider.

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

> <https://www.consul.io/intro/getting-started/ui.html>

### Running on Docker

For ease of use to install and update, the microservices of EdgeX Foundry are published as Docker images onto Docker Hub and compose files that allow you to run EdgeX and dependent service such as Consul. These compose files can be found here in the [edgex-compose repository](https://github.com/edgexfoundry/edgex-compose/tree/ireland). See the [Getting Started with Docker](../../getting-started/Ch-GettingStartedUsers/#introduction) section for more details.

Once the EdgeX stack is running in docker verify Consul is running by going to  <http://localhost:8500/ui> in your browser.

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
