# Common Environment Variables

There are two types of environment variables used by all EdgeX services. They are `standard` and `overrides`. The only difference is that the `overrides` apply to command-line options and service configuration settings where as `standard` do not have any corresponding command-line option or configuration setting.

## Standard Environment Variables

This section describes the `standard` environment variables common to all EdgeX services. Some service may have additional  `standard` environment variables which are documented in those service specific sections.

#### EDGEX_SECURITY_SECRET_STORE

This environment variables indicates whether the service is expected to initialize the secure SecretStore which allows the service to access secrets from Vault. Defaults to `true` if not set or not set to `false`. When set to `true` the EdgeX security services must be running. If running EdgeX in `non-secure` mode you then want this explicitly set to `false`.

!!! example "Example - Using docker-compose to disable secure SecretStore"
    ```yaml
    environment: 
      EDGEX_SECURITY_SECRET_STORE: "false"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 when running in secure mode Consul is secured,  which requires all services to have this environment variable be `true` so they can request their Consul access token from Vault. See the [Secure Consul](https://docs.edgexfoundry.org/2.0/security/Ch-Secure-Consul/) section for more details.

#### EDGEX_STARTUP_DURATION

This environment variable sets the total duration in seconds allowed for the services to complete the bootstrap start-up. Default is 60 seconds.

!!! example "Example - Using docker-compose to set start-up duration to 120 seconds"
    ```yaml
    environment: 
      EDGEX_STARTUP_DURATION: "120"
    ```
!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the deprecated lower case version `startup_duration` has been removed

#### EDGEX_STARTUP_INTERVAL

This environment variable sets the retry interval in seconds for the services retrying a failed action during the bootstrap start-up. Default is 1 second.

!!! example "Example - Using docker-compose to set start-up interval to 3 seconds"
    ```yaml
    environment: 
      EDGEX_STARTUP_INTERVAL: "3"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the deprecated lower case version `startup_interval` has been removed

## Environment Overrides

There are two types of environment overrides which are `command-line` and `configuration`. 

!!! important
    Environment variable overrides have precedence over all command-line, local configuration and remote configuration. i.e. configuration setting changed in Consul will be overridden after the service loads the configuration from Consul if that setting has an environment override.

### Command-line Overrides

#### EDGEX_CONF_DIR

This environment variable overrides the [`-c/--confdir` command-line option](../CommonCommandLineOptions/#confdir). 

!!! note
     All EdgeX service Docker images have this option set to `/res`.

!!! example "Example - Using docker-compose to override the configuration folder name"
    ```yaml
    environment: 
      EDGEX_CONF_DIR: "/my-config"
    ```

#### EDGEX_CONFIG_FILE

This environment variable overrides the [`-f/--file` command-line option](../CommonCommandLineOptions#file).

!!! example "Example - Using docker-compose to override the configuration file name used"
    ```yaml
    environment: 
      EDGEX_CONFIG_FILE: "my-config.toml"
    ```

#### EDGEX_CONFIGURATION_PROVIDER

This environment variable overrides the [`-cp/--configProvider` command-line option](../CommonCommandLineOptions#config-provider). 

!!! note
    All EdgeX service Docker images have this option set to `-cp=consul.http://edgex-core-consul:8500`.

!!! example "Example - Using docker-compose to override with different port number"
    ```yaml
    environment: 
      EDGEX_CONFIGURATION_PROVIDER: "consul.http://edgex-consul:9500"
    ```

#### EDGEX_PROFILE

This environment variable overrides the [`-p/--profile` command-line option](../CommonCommandLineOptions#profile). When non-empty,  the value is used in the path to the configuration file. i.e. /res/my-profile/configuation.toml.  This is useful when running multiple instances of a service such as App Service Configurable.

!!! example "Example - Using docker-compose to override the profile to use"
    ```yaml
    app-service-rules:
        image: edgexfoundry/docker-app-service-configurable:2.0.0
        environment: 
          EDGEX_PROFILE: "rules-engine"
        ...
    ```

This sets the `profile` so that the App Service Configurable uses the `rules-engine` configuration profile which resides at `/res/rules-engine/configuration.toml`

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the deprecated lower case version `edgex_profile` has been removed

#### EDGEX_USE_REGISTRY

This environment variable overrides the [`-r/--registry` command-line option](../CommonCommandLineOptions#registry). 

!!! note
    All EdgeX service Docker images have this option set to `--registry`.

!!! example "Example - Using docker-compose to override use of the Registry"
    ```yaml
    environment: 
      EDGEX_USE_REGISTRY: "false"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the deprecated lower case version `edgex_registry` has been removed

### Configuration Overrides

Any configuration setting from a service's `configuration.toml` file can be overridden by environment variables. The environment variable names have the following format:

```toml
<TOM-SECTION-NAME>_<TOML-KEY-NAME>
<TOML-SECTION-NAME>_<TOML-SUB-SECTION-NAME>_<TOML-KEY-NAME>
```

!!! edgey "EdgeX 2.0"
    With EdgeX 2.0 the use of CamelCase environment variable names is no longer supported. Instead the variable names must be all uppercase as in the example below. Also the using of dash `-` in the TOML-NAME is converted to an underscore `_` in the environment variable name.

!!! example "Example - Environment Overrides of Configuration"

~~~toml
``` toml   
TOML   : [Writable]    
		 LogLevel = "INFO"    
ENVVAR : WRITABLE_LOGLEVEL=DEBUG    

TOML   : [Clients]
  			[Clients.core-data]
  			Host = "localhost"
ENVVAR : CLIENTS_CORE_DATA_HOST=edgex-core-data    
```    
~~~
