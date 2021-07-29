# Common Command Line Options

This section describes the command line options that are common to all EdgeX services. Some services have addition command line options which are documented in the specific sections for those services.

## ConfDir 

`-c/--confdir`

Specify local configuration directory. Default is `./res`

Can be overridden with [EDGEX_CONF_DIR](./CommonEnvironmentVariables.md#edgex_conf_dir) environment variable.

## File

`-f/--file <name>`

Indicates the name of the local configuration file. Default is `configuration.toml`

Can be overridden with [EDGEX_CONFIG_FILE](./CommonEnvironmentVariables.md#edgex_config_file) environment variable.

## Config Provider

`-cp/ --configProvider`

Indicates to use Configuration Provider service at specified URL. URL Format: `{type}.{protocol}://{host}:{port} ex: consul.http://localhost:8500`

Can be overridden with [EDGEX_CONFIGURATION_PROVIDER](./CommonEnvironmentVariables.md#edgex_configuration_provider) environment variable.

## Profile

`-p/--profile <name>`

Indicates configuration profile other than default. Default is no profile name resulting in using `./res/configuration.toml` if `-f` and `-c` are not used.

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



