# Common Configuration

The tables in each of the tabs below document configuration properties that are common to all services in the EdgeX Foundry platform. Service-specific properties can be found on the respective documentation page for each service.

## Configuration Properties

!!! edgey "Edgex 2.0"
    For EdgeX 2.0 the `Logging` and `Startup` sections have been removed. `Startup` has been replaced with the `EDGEX_STARTUP_DURATION` (default is 60 secs) and `EDGEX_STARTUP_INTERVAL` (default is 1 sec) environment variables.


=== "Writable"

    |Property|Default Value|Description|
    |---|---|---|
    |||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider` flag|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored.|
    |**InsecureSecrets**|---|This section a map of secrets which simulates the SecretStore for accessing secrets when running in non-secure mode. All services have a default entry for Redis DB credentials called `redisdb`|
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 the `Writable.InsecureSecrets` configuration section is new. 

=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |Interval| 30s|The interval in seconds at which to report the metrics currently being collected and enabled. **Value of 0s disables reporting**. |
    |PublishTopicPrefix|"edgex/telemetry"|The base topic in which to publish (report) metrics currently being collected and enabled. `/<service-name>/<metric-name>` will be added to this base topic prefix.|
    |Metrics||Boolean map of service metrics that are being collected. The boolean flag for each indicates if the metric is enabled for reporting. i.e. `EventsPersisted = true`. The metric name must match one defined by the service. |
    ||SecuritySecretsRequested = false| Enable/Disable reporting of number of secrets requested  |
    ||SecuritySecretsStored = false| Enable/Disable reporting of number of secrets stored  |
    ||`<Service dependent>`= false | Enable/Disable reporting of service defined metric |
    |Tags|`<Service dependent>`|String map of arbitrary tags to be added to every metric that is reported for the service. i.e. `Gateway="my-iot-gateway"`. The tag names are arbitrary. |

    !!! edgey "Edgex 2.2/2.3"
        Service Metrics have been added in EdgeX 2.2 and expanded in EdgeX 2.3.

=== "Service"

    |Property|Default Value|Description|
    |---|---|---|
    |HealthCheckInterval|10s|The interval in seconds at which the service registry(Consul) will conduct a health check of this service.|
    |Host|localhost|Micro service host name|
    |Port|---|Micro service port number (specific for each service)|
    |ServerBindAddr|'' (empty string)|The interface on which the service's REST server should listen. By default the server is to listen on the interface to which the `Host` option resolves (leaving it blank). A value of `0.0.0.0` means listen on all available interfaces. App & Device service do not implement this setting|
    |StartupMsg|---|Message logged when service completes bootstrap start-up|
    |MaxResultCount|1024*|Read data limit per invocation. *Default value is for core/support services. Application and Device services do not implement this setting. |
    |MaxRequestSize|0|Defines the maximum size of http request body in kilbytes. 0 represents default to system max.|
    |RequestTimeout         |5s                          | Specifies a timeout duration for handling requests |
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 `Protocol` and `BootTimeout`  have been removed. `CheckInterval` and  `Timeout ` have been renamed to `HealthCheckInterval` and `RequestTimeout` respectively. `MaxRequestSize` was added for all services.
    
    !!! edgey "Edgex 2.2"
        For EdgeX 2.2 Service MaxRequestSize has been implemented to all services, and the unit is kilobyte.

=== "Service.CORSConfiguration"

    |Property|Default Value|Description|
    |---|---|---|
    |||The settings of controling CORS http headers|
    |EnableCORS|false|Enable or disable CORS support.|
    |CORSAllowCredentials|false|The value of `Access-Control-Allow-Credentials` http header. It appears only if the value is `true`.|
    |CORSAllowedOrigin|"https://localhost"|The value of `Access-Control-Allow-Origin` http header.|
    |CORSAllowedMethods|"GET, POST, PUT, PATCH, DELETE"|The value of `Access-Control-Allow-Methods` http header.|
    |CORSAllowedHeaders|"Authorization, Accept, Accept-Language, Content-Language, Content-Type, X-Correlation-ID"|The value of `Access-Control-Allow-Headers` http header.|
    |CORSExposeHeaders|"Cache-Control, Content-Language, Content-Length, Content-Type, Expires, Last-Modified, Pragma, X-Correlation-ID"|The value of `Access-Control-Expose-Headers` http header.|
    |CORSMaxAge|3600|The value of `Access-Control-Max-Age` http header.|
    !!! edgey "Edgex 2.1"
        New for EdgeX 2.1 is the ability to enable CORS access to EdgeX microservices through configuration. 
    To understand more details about these HTTP headers, please refer to [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#the_http_response_headers), and refer to [CORS enabling](../../security/Ch-CORS-Settings.md) to learn more.

=== "Databases.Primary"

    |Property|Default Value|Description|
    |---|---|---|
    |||configuration that govern database connectivity and the type of database to use. While not all services require DB connectivity, most do and so this has been included in the common configuration docs.|
    |Host |localhost                      |DB host name|
    |Port |6379                         |DB port number|
    |Name      |----                       |Database or document store name (Specific to the service)            |
    |Timeout      |5000                           |DB connection timeout                                              |
    |Type |redisdb                        |DB type.  Redis is the only supported DB|
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 `mongodb` has been remove as a supported DB. The credentials `username` and `password` have been removed and are now in the `Writable.InsecureSecrets.DB` section.

=== "Registry"

    |Property|Default Value|Description|
    |---|---|---|
    |||this configuration only takes effect when connecting to the registry for configuration info|
    |Host           |localhost                      |Registry host name|
    |Port           |8500                           |Registry port number|
    |Type           |consul                         |Registry implementation type|

=== "Clients.[service-key]"

    |Property|Default Value|Description|
    |---|---|---|
    |||Each service has it own collect of Clients that it uses|
    |Protocol | http  | The protocol to use when building a URI to local the service endpoint|
    |Host | localhost  | The host name or IP address where the service is hosted |
    |Port | 598xx | The port exposed by the target service|
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 the map keys have changed to be the service's service-key, i.e. `Metadata` changed to `core-metadata`

=== "SecretStore"

    |Property|Default Value|Description|
    |---|---|---|
    |||these config values are used when security is enabled and `SecretStore` service access is required for obtaining secrets, such as database credentials|
    |Type | vault  | The type of the `SecretStore` service to use. Currenly only `vault` is supported.|
    |Host | localhost  | The host name or IP address associated with the `SecretStore` service|
    |Port | 8200  | The configured port on which the `SecretStore` service is listening|
    |Path | `<service-key>`/ | The service-specific path where the secrets are kept. This path will differ according to the given service. |
    |Protocol | http  | The protocol to be used when communicating with the `SecretStore` service|
    |RootCaCertPath | blank | Default is to not use HTTPS |
    |ServerName | blank | Not needed for HTTP |
    |TokenFile | /tmp/edgex/secrets/`<service-key>`/secrets-token.json | Fully-qualified path to the location of the service's `SecretStore` access token. This path will differ according to the given service. |
    |SecretsFile| blank | Fully-qualified path to the location of the service's JSON secrets file  contains secrets to seed at start-up. See [Seeding Service Secrets](../../security/SeedingServiceSecrets.md) section for more details on seed a service's secrets. |
    |DisableScrubSecretsFile| false | Controls if the secrets file is scrubbed (secret data remove) and rewritten after importing the secrets.|
    |Authentication AuthType | X-Vault-Token  | A header used to indicate how the given service will authenticate with the `SecretStore` service|
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 the `Protocol` default has changed to `HTTP` which no longer requires `RootCaCertPath` and `ServerName` to be set. `Path` has been reduce to the sub-path for the service since the based path is fixed. `TokenFile` default value has changed and requires the `service-key` be used in the path.

## Writable vs Readable Settings

Within a given service's configuration, there are keys whose values can be edited and change the behavior of the service while it is running
versus those that are effectively read-only. These writable settings are grouped under a given service key. For example, the top-level groupings
for edgex-core-data are:

- **/edgex/core/2.0/edgex-core-data/Writable**
- /edgex/core/2.0/edgex-core-data/Service
- /edgex/core/2.0/edgex-core-data/Clients
- /edgex/core/2.0/edgex-core-data/Databases
- /edgex/core/2.0/edgex-core-data/MessageQueue
- /edgex/core/2.0/edgex-core-data/Registry
- /edgex/core/2.0/edgex-core-data/SecretStore

Any configuration settings found in a service's `Writable` section may be changed and affect a service's behavior without a restart. Any
modifications to the other settings (read-only configuration) would require a restart.

