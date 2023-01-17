# Common Configuration

The tables in each of the tabs below document configuration properties that are common to all services in the EdgeX Foundry platform. Service-specific properties can be found on the respective documentation page for each service.

## Configuration Properties

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It has default values which can be overridden with environment variables. See the [SecretStore Overrides](../CommonEnvironmentVariables/#secretstore-overrides) section for more details.

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
    ||SecurityConsulTokensRequested = false| Enable/Disable reporting of number of Consul token requested  |
    ||SecurityConsulTokenDuration = false| Enable/Disable reporting of duration for obtaining Consul token  |
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
    |Protocol | http | The protocol to use when building a URI to local the service endpoint|
    |Host | localhost | The host name or IP address where the service is hosted|
    |Port | 598xx | The port exposed by the target service|
    |UseMessageBus | false | indicate whether to use Messaging version of client |
    |Topics |  | holds the MessageBus Topics used by the client to communicate to the service|
    || CommandRequestTopicPrefix = edgex/core/command/request | for publishing the internal command request|
    || CommandResponseTopic = edgex/core/command/response/# | for subscribing the internal command response|
    || QueryRequestTopic = edgex/core/commandquery/request | for publishing the internal command query request|
    || QueryResponseTopic = edgex/core/commandquery/response | for subscribing the internal command query response|
    
    !!! edgey "Edgex 2.0"
        For EdgeX 2.0 the map keys have changed to be the service's service-key, i.e. `Metadata` changed to `core-metadata`
    
    !!! edgey "Edgex 2.3"
        The `UseMessageBus` and `Topics` fields are only viable for Command client

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

Any configuration settings found in a service's `Writable` section may be changed and affect a service's behavior without a restart. Any
modifications to the other settings (read-only configuration) would require a restart.

