# Command Line Options

This section describes the command line options that are common to all EdgeX services. Some services have addition command line options which are documented in the specific sections for those services.

## Config Directory

`-cd/--configDir`

!!! edgey "EdgeX 3.0"
    The `-c/--confdir` command line option is replaced by `-cd/--configDir` in EdgeX 3.0.


Specify local configuration directory. Default is `./res`, but will be ignored if Config File parameter refers to a URI beginning with `http` or `https`.

Can be overridden with [EDGEX_CONFIG_DIR](./CommonEnvironmentVariables.md#edgex_config_dir) environment variable.

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONF_DIR` environment variable is replaced by `EDGEX_CONFIG_DIR` in EdgeX 3.0.

## Config File

`-cf/--configFile <name>`

!!! edgey "EdgeX 3.0"
    The `-f/--file` command line option is replaced by `-cf/--configFile` in EdgeX 3.0.


Indicates the name of the local configuration file or the URI of the private configuration. See the [URI for Files](../general/index.md#uri-for-files) section for more details. Default is `configuration.yaml`.

Can be overridden with [EDGEX_CONFIG_FILE](./CommonEnvironmentVariables.md#edgex_config_file) environment variable.

!!! edgey "EdgeX 3.1"
    Support for loading private configuration via URI is new in EdgeX 3.1.

## Config Provider

`-cp/ --configProvider`

Indicates to use Configuration Provider service at specified URL. URL Format: `{type}.{protocol}://{host}:{port}`. Default is `consul.http://localhost:8500`

Can be overridden with [EDGEX_CONFIG_PROVIDER](./CommonEnvironmentVariables.md#edgex_config_provider) environment variable.

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONFIGURATION_PROVIDER` environment variable is replaced by `EDGEX_CONFIG_PROVIDER` in EdgeX 3.0.

## Common Config

`-cc/ --commonConfig`

!!! edgey "EdgeX 3.0"
    The Common Config flag is new to EdgeX 3.0

Takes the location where the common configuration is loaded from - either a local file path or a URI when not using the Configuration Provider. See the [URI for Files](../general/index.md#uri-for-files) section for more details. Default is blank.

Can be overridden with [EDGEX_COMMON_CONFIG](./CommonEnvironmentVariables.md#edgex_common_config) environment variable.

!!! edgey "EdgeX 3.1"
    Support for loading common configuration via URI is new in EdgeX 3.1.

## Profile

`-p/--profile <name>`

Indicates configuration profile other than default. Default is no profile name resulting in using `./res/configuration.yaml` if `-f` and `-c` are not used.

Can be overridden with [EDGEX_PROFILE ](./CommonEnvironmentVariables.md#edgex_profile) environment variable.

## Registry

`-r/ --registry`

Indicates service should use the Registry. Connection information is pulled from the `[Registry]` configuration section.

Can be overridden with [EDGEX_USE_REGISTRY](./CommonEnvironmentVariables.md#edgex_use_registry) environment variable.

## Overwrite

`-o/--overwrite`

Overwrite configuration in provider with local configuration.

!!! caution "Use with caution" 
   This will clobber existing settings in provider, which is problematic if those settings were intentionally edited by hand. Typically only used during development.

## Remote Service Hosts

!!! edgey "EdgeX 3.1"
    New in EdgeX 3.1

`-rsh/--remoteServiceHosts <host names>`

!!! warning
    This command line option is intended to be used in non-secure EdgeX deployments that are run with in a secured network. See [Remote Device Services in Secure Mode](../../..//security/Ch-RemoteDeviceServices/) section for details of deploying remote EdgeX services in secure EdgeX deployments.

Sets the three host names required when running the service remotely so that it can connect to the core EdgeX services running on another system and also be connected to from those same core EdgeX services.

`<host names>` must contain and only contain the following three host names in a comma separated string

1. Host name of local system where the service is running

2. Host name of the system where the core EdgeX services are running

3. Host name to bind to for the internal WebServer for hosting the REST API

   This allows the service to be accessed from external network. When running native it can be set to the local system Hostname/IP or `0.0.0.0` When running in docker it must be set to `localhost` or `0.0.0.0` and use docker port mapping to expose the service to external network.

!!! note
    Each host name can be a known DNS host name or the IP address of the host

!!! example - "Example setting Remote Service Hosts"
    ```    
    --remoteServiceHosts 172.26.113.174,172.26.113.150,0.0.0.0
    or
    -rsh 172.26.113.174,172.26.113.150,localhost
    ```

Can be overridden with [EDGEX_REMOTE_SERVICE_HOSTS](http://localhost:8008/3.1/microservices/configuration/CommonEnvironmentVariables/#edgex_remote_service_hosts) environment variable.

## Developer Mode

!!! edgey "EdgeX 3.0"
    New in EdgeX 3.0

`-d/--dev`

Indicates service should run in developer mode. The allows the service running from command-line to properly communicate with other EdgeX services running in Docker (aka hybrid mode). This flag cause all `Host` configuration values pulled from common configuration via the Configuration Provider to be overridden with the value "localhost". 

!!! caution "Development Only"
    This flag should only be used for development purposes when running from command-line.

## Help

`-h/--help`

Show the help message



