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


Indicates the name of the local configuration file or the [URI](../general/index.md#uri-for-files) of the private configuration. Default is `configuration.yaml`.

Can be overridden with [EDGEX_CONFIG_FILE](./CommonEnvironmentVariables.md#edgex_config_file) environment variable.

!!! edgey "EdgeX 3.1"
    Support for use of **either** a local private configuration file or URI of a private configuration.

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

Takes the location where the common configuration is loaded from - either a local file path or a [URI](../general/index.md#uri-for-files) when not using the Configuration Provider. Default is blank.

Can be overridden with [EDGEX_COMMON_CONFIG](./CommonEnvironmentVariables.md#edgex_common_config) environment variable.

!!! edgey "EdgeX 3.1"
    Support for use of **either** a local common configuration file or URI of a common configuration.

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



