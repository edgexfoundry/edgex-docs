# Common Command Line Options

This section describes the command line options that are common to all EdgeX services. Some services have addition command line options which are documented in the specific sections for those services.

## ConfDir 

`-cd/--configDir`

!!! edgey "EdgeX 3.0"
    The `-c/--confdir` command line option is replaced by `-cd/--configDir` in EdgeX 3.0.


Specify local configuration directory. Default is `./res`

Can be overridden with [EDGEX_CONFIG_DIR](./CommonEnvironmentVariables.md#edgex_config_dir) environment variable.

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONF_DIR` environment variable is replaced by `EDGEX_CONFIG_DIR` in EdgeX 3.0.

## File

`-cf/--configFile <name>`

!!! edgey "EdgeX 3.0"
    The `-f/--file` command line option is replaced by `-cf/--configFile` in EdgeX 3.0.


Indicates the name of the local configuration file. Default is `configuration.yaml`

Can be overridden with [EDGEX_CONFIG_FILE](./CommonEnvironmentVariables.md#edgex_config_file) environment variable.

## Config Provider

`-cp/ --configProvider`

Indicates to use Configuration Provider service at specified URL. URL Format: `{type}.{protocol}://{host}:{port}`. Default is `consul.http://localhost:8500`

Can be overridden with [EDGEX_CONFIG_PROVIDER](./CommonEnvironmentVariables.md#edgex_config_provider) environment variable.

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONFIGURATION_PROVIDER` environment variable is replaced by `EDGEX_CONFIG_PROVIDER` in EdgeX 3.0.

## Common Config

`-cc/ --commonConfig`

Takes the location where the common configuration is loaded from when not using the Configuration Provider. Default is blank.

Can be overridden with [EDGEX_COMMON_CONFIG](./CommonEnvironmentVariables.md#edgex_common_config) environment variable.

!!! edgey "EdgeX 3.0"
    The Common Config flag is new to EdgeX 3.0

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

!!! cation "Use with cation" 
   This will clobber existing settings in provider, problematic if those settings were edited by hand intentionally. Typically only used during development.

## Help

`-h/--help`

Show the help message



