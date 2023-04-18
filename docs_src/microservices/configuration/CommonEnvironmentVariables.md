# Environment Variables

There are three types of environment variables used by all EdgeX services. They are `standard`, `command-line overrides`  and `configuration overrides`. 

## Standard Environment Variables

This section describes the `standard` environment variables common to all EdgeX services. Standard environment variables do not override any command line flag or service configuration. Some services may have additional  `standard` environment variables which are documented in those service specific sections. See [Notable Other Standard Environment Variables](#notable-other-standard-environment-variables) below for list of these additional standard environment variables.

!!! note
    All `standard` environment variables have the `EDGEX_` prefix

### EDGEX_SECURITY_SECRET_STORE

This environment variables indicates whether the service is expected to initialize the secure SecretStore which allows the service to access secrets from Vault. Defaults to `true` if not set or not set to `false`. When set to `true` the EdgeX security services must be running. If running EdgeX in `non-secure` mode you then want this explicitly set to `false`.

!!! example "Example - Using docker-compose to disable secure SecretStore"
    ```yaml
    environment: 
      EDGEX_SECURITY_SECRET_STORE: "false"
    ```

### EDGEX_DISABLE_JWT_VALIDATION

This environment variable disables, at the microservice-level, validation of the `Authorization` HTTP header of inbound REST API requests.
(Microservice-level authentication was added in EdgeX 3.0.)

Normally, when `EDGEX_SECURITY_SECRET_STORE` is unset or `true`,
EdgeX microservices authenticate inbound HTTP requests by parsing the `Authorization` header,
extracting a JWT bearer token,
and validating it with the EdgeX secret store,
returning an HTTP 401 error if token validation fails.

If for some reason it is not possible to pass a valid JWT to an EdgeX microservice --
for example, the eKuiper rule engine making an unauthenticated HTTP API call, or other legacy code --
it may be necessary to disable JWT validation in the receiving microservice.

!!! example "Example - Using docker-compose environment variable to disable secure JWT validation"
    ```yaml
    environment: 
      EDGEX_DISABLE_JWT_VALIDATION: "true"
    ```

Regardless of the setting of this variable, the API gateway
(and related security-proxy-auth microservice)
will always validate the incoming JWT.


### EDGEX_STARTUP_DURATION

This environment variable sets the total duration in seconds allowed for the services to complete the bootstrap start-up. Default is 60 seconds.

!!! example "Example - Using docker-compose to set start-up duration to 120 seconds"
    ```yaml
    environment: 
      EDGEX_STARTUP_DURATION: "120"
    ```

### EDGEX_STARTUP_INTERVAL

This environment variable sets the retry interval in seconds for the services retrying a failed action during the bootstrap start-up. Default is 1 second.

!!! example "Example - Using docker-compose to set start-up interval to 3 seconds"
    ```yaml
    environment: 
      EDGEX_STARTUP_INTERVAL: "3"
    ```

## Notable Other Standard Environment Variables

This section covers other standard environment variables that are not common to all services.

### EDGEX_ADD_SECRETSTORE_TOKENS

This environment variable tells the Secret Store Setup service which add-on services to generate SecretStore tokens for. 
See [Configure Service's Secret Store](../../../security/Ch-Configuring-Add-On-Services/#configure-the-services-secret-store-to-use) section for more details.

### EDGEX_ADD_KNOWN_SECRETS

This environment variable tells the Secret Store Setup service which add-on services need which known secrets added to their Secret Stores. 
See [Configure Known Secrets](../../../security/Ch-Configuring-Add-On-Services/#optional-configure-known-secrets-for-add-on-services) section for more details.

### EDGEX_ADD_REGISTRY_ACL_ROLES

This environment variable tells the Consul service entry point script which add-on services need ACL roles created. 
See [Configure ACL Role](../../../security/Ch-Configuring-Add-On-Services/#optional-configure-the-acl-role-of-configurationregistry-to-use-if-the-service-depends-on-it) section for more details.

### EDGEX_ADD_PROXY_ROUTE

This environment variable tells the Proxy Setup Service which additional routes need to be added for add-on services. 
See [Configure API Gateway Route](../../../security/Ch-Configuring-Add-On-Services/#optional-configure-the-api-gateway-access-route-for-add-on-service) section for more details.

### EDGEX_IKM_HOOK 

This environment variable tells the Secret Store Setup service the path to an executable that implements the IKM interface. 
See [IKM HOOK](../../../threat-models/secret-store/vault_master_key_encryption/#ikm-hook) section for more details.

## Command-line Overrides

This section describes the command-line overrides that are common to most services.  These overrides allow the use of the specific command-line flag to be overridden each time a service starts up.

!!! note
    All `command-line overrides` also have the `EDGEX_` prefix.

#### EDGEX_CONFIG_DIR

This environment variable overrides the [`-cd/--configDir` command-line option](../CommonCommandLineOptions/#confdir). 

!!! note
     All EdgeX service Docker images have this option set to `/res`.

!!! example "Example - Using docker-compose to override the configuration folder name"
    ```yaml
    environment: 
      EDGEX_CONF_DIR: "/my-config"
    ```

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONF_DIR` environment variable is replaced by `EDGEX_CONFIG_DIR` in EdgeX 3.0.

#### EDGEX_CONFIG_FILE

This environment variable overrides the [`-cf/--configFile` command-line option](../CommonCommandLineOptions#file).

!!! example "Example - Using docker-compose to override the configuration file name used"
    ```yaml
    environment: 
      EDGEX_CONFIG_FILE: "my-config.yaml"
    ```

#### EDGEX_CONFIG_PROVIDER

This environment variable overrides the [`-cp/--configProvider` command-line option](../CommonCommandLineOptions#config-provider). 

Overriding with a value of `none` disables the use of the Configuration Provider.

!!! note
    All EdgeX service Docker images have this option set to `-cp=consul.http://edgex-core-consul:8500`.

!!! example "Example - Using docker-compose to override with different port number"
    ```yaml
    environment: 
      EDGEX_CONFIG_PROVIDER: "consul.http://edgex-consul:9500"
    
    or
    
    environment: 
      EDGEX_CONFIG_PROVIDER: "none"
    ```

!!! edgey "EdgeX 3.0"
    The `EDGEX_CONFIGURATION_PROVIDER` environment variable is replaced by `EDGEX_CONFIG_PROVIDER` in EdgeX 3.0.

#### EDGEX_COMMON_CONFIG

This environment variable overrides the [`-cc/--commonConfig` command-line option](../CommonCommandLineOptions#common-config).

!!! note
    The Common Config can only be specified when not using the Configuration Provider.

!!! example "Example - Override with a common configuration file at the command line"
    ```bash
    $ export EDGEX_COMMON_CONFIG=./my-common-configuration.yaml
    $ ./core-data
    ```

!!! edgey "EdgeX 3.0"
    The `EDGEX_COMMON_CONFIG` variable is new to EdgeX 3.0.
    

#### EDGEX_PROFILE

This environment variable overrides the [`-p/--profile` command-line option](../CommonCommandLineOptions#profile). When non-empty,  the value is used in the path to the configuration file. i.e. /res/my-profile/configuation.yaml.  This is useful when running multiple instances of a service such as App Service Configurable.

!!! example "Example - Using docker-compose to override the profile to use"
    ```yaml
    app-service-rules:
        image: edgexfoundry/docker-app-service-configurable:2.0.0
        environment: 
          EDGEX_PROFILE: "rules-engine"
        ...
    ```

This sets the `profile` so that the App Service Configurable uses the `rules-engine` configuration profile which resides at `/res/rules-engine/configuration.yaml`

#### EDGEX_USE_REGISTRY

This environment variable overrides the [`-r/--registry` command-line option](../CommonCommandLineOptions#registry). 

!!! note
    All EdgeX service Docker images have this option set to `--registry`.

!!! example "Example - Using docker-compose to override use of the Registry"
    ```yaml
    environment: 
      EDGEX_USE_REGISTRY: "false"
    ```

## Configuration Overrides

!!! edgex - "EdgeX 3.0"
    New in EdgeX 3.0. When used, the Configuration Provider is the **System of Record** for all configuration. Environment variable overrides no longer have the highest precedence. 

!!! important - "Configuration Provider is the **System of Record** for all configuration"
    When using the Configuration Provider,  it is the **System of Record** for all configuration. Environment variable overrides are only applied when configuration is read from file. The overridden values are used to seed the services' configuration into the Configuration Provider. Once the Configuration Provider has been seeded, service's always get their configuration from the Configuration Provider on start up. Any changes to configuration must be done via the Configuration Provider. Changing an environment variable override and restating the service will not impact the service's configuration.

### Service Configuration Overrides

Any configuration setting from a service's `configuration.yaml` file can be overridden by environment variables. The environment variable names have the following format:

```
<SECTION-NAME>_<KEY-NAME>
<SECTION-NAME>_<SUB-SECTION-NAME>_<KEY-NAME>
```

!!! example "Example - Environment Variable Overrides of Configuration"
    ```yaml   
    CONFIG  : Writable:    
               LogLevel: "INFO"    
    ENVVAR : WRITABLE_LOGLEVEL=DEBUG    
    
    CONFIG : Service:
               Host: "localhost"
    ENVVAR : SERVICE_HOST=edgex-core-data    
    ```

#### Application of Configuration Overrides

Service configuration overrides are applied at two levels, which are **common** and **private**.

##### Common Configuration Overrides

When using the Configuration Provider, the common configuration overrides are applied to the **core-common-config-bootstrapper** service. This service is solely responsible with seeding the Configuration Provider with the common configuration. These common configuration overrides are only applied when the **core-common-config-bootstrapper** service reads the common configuration from file and pushes the values in to the Configuration Provider. The  **core-common-config-bootstrapper** service only does this if the Configuration Provider doesn't already have the common configuration. 

When not using the Configuration Provider, the common configuration is provided from the file specified by [`-cc/--commonConfig` command line option](../CommonCommandLineOptions/#common-config). The common configuration overrides are applied when this file is loaded. This occurs on every time a service starts. These common overrides must be set on the individual services rather than a central service since each service is loading the common configuration file. 

##### Private Configuration Overrides

Each service has private configuration which is initially loaded from file. Private configuration overrides are only applied when the private configuration is load from file. These private configuration overrides must be set on the individual services since each service is loading its own private configuration file. 

When using the Configuration Provider,  the values are pushed to the service's private section in the Configuration Provider. Once the private file and overrides have been used to seed the Configuration Provider, they are no longer used. The services will pull their private configuration directly from the Configuration Provider on future start-ups.

When not using the Configuration Provider, the private overrides are applied when the configuration is load from this file and then used by the service. This occurs on every time a service starts.

!!! important
    Private configuration overrides are only applied to configuration settings that exist in the service's private configuration file.

### SecretStore Configuration Overrides

!!! edgey "EdgeX 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files and the Configuration Provider. It now has default values which can be overridden with [Configuration Overrides](#configuration-overrides).

The environment variables overrides for **SecretStore** configuration follow the same rules as the regular configuration overrides. The following are the **SecretStore** fields that are commonly overridden.

- SECRETSTORE_HOST
- SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED
- SECRETSTORE_RUNTIMETOKENPROVIDER_HOST

!!! example - "Example SecretStore Configuration Override"
    ```yaml
    CONFIG : SecretStore.Host
    ENVVAR : SECRETSTORE_HOST=edgex-vault
    ```

The  complete list of **SecretStore** fields and defaults can be found in the file [here](https://github.com/edgexfoundry/go-mod-bootstrap/blob/main/config/types.go). **TODO: Fix link to use release tag**
The defaults for the remaining fields typically do not need to be overridden, but may be overridden if needed using that same naming scheme as above.

### Notable Configuration Overrides

This section describes configuration overrides that have special utility, such as enabling a debug capability or facilitating code development.

#### TOKENFILEPROVIDER_DEFAULTTOKENTTL (security-secretstore-setup service)

This configuration override variable controls the TTL of the default SecretStore tokens that are created for EdgeX microservices by the 
Secret Store Setup service. This variable defaults to `1h` (one hour) if unspecified.
It is often useful when developing a new microservice to set this value to a higher value, such as `12h`.
This higher value will allow the secret store token to remain valid long enough
for a developer to get a new microservice working and into a state where it can renew its own token.
(All secret store tokens in EdgeX expire if not renewed periodically.)