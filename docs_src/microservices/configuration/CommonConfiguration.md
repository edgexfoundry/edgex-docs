# Common Configuration

The tables in each of the tabs below document configuration properties that are common to all services in the EdgeX Foundry platform. 
Service specific properties can be found on the respective documentation page for each service.

!!! edgey - "EdgeX 3.0"
    New in Edgex 3.0 the common configuration is now in a single location. The source file is loaded into the common section in the Configuration Provider. In prior releases the common configuration was duplicated in each service's configuration and in each service's section in the Configuration Provider.

The common configuration is managed by the **core-common-config-bootstrapper** service, which is divided into 3 sections:

- **All Services**- Configuration that is common to all EdgeX Services See below for details.

- **App Services** - Configuration that is common to just application services. See [App Service Configuration](../../application/GeneralAppServiceConfig) section for more details.
- **Device Services**- Configuration that is common to just devices services. See [Device Service Configuration](../../device/Ch-DeviceServices/#configuration-properties) section for more details.

## Configuration Properties

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It has default values which can be overridden with environment variables. See the [SecretStore Overrides](../CommonEnvironmentVariables/#secretstore-overrides) section for more details.

!!! edgey "Edgex 3.0"
    In EdgeX 3.0, the **MessageBus** configuration is now common to all services. In addition, the internal MessageBus topic configuration has been replaced by internal constants. The new **BaseTopicPrefix** setting has been added to allow customization of all topics under a common base prefix.  See the new common **MessageBus** section below.

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider` flag|
    |LogLevel|---|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  (specific for each service) |
    |**InsecureSecrets**|---|This section a map of secrets which simulates the SecretStore for accessing secrets when running in non-secure mode. All services have a default entry for Redis DB credentials called `redisdb`|
    

    !!! note
        LogLevel is included here for documentation purposes since all services have this setting. Since it should always be set at an individual service level it is not included in the new common configuration file and is present in all the individual service configuration files.

=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |Interval| 30s|The interval in seconds at which to report the metrics currently being collected and enabled. **Value of 0s disables reporting**. |
    |Metrics||Boolean map of service metrics that are being collected. The boolean flag for each indicates if the metric is enabled for reporting. i.e. `EventsPersisted = true`. The metric name must match one defined by the service. |
    |Metrics.SecuritySecretsRequested | false| Enable/Disable reporting of number of secrets requested  |
    |Metrics.SecuritySecretsStored | false| Enable/Disable reporting of number of secrets stored  |
    |Metrics.SecurityConsulTokensRequested | false| Enable/Disable reporting of number of Consul token requested  |
    |Metrics.SecurityConsulTokenDuration | false| Enable/Disable reporting of duration for obtaining Consul token  |
    |Tags|`<Common Tags>`|String map of arbitrary tags to be added to every metric that is reported for all services . i.e. `Gateway="my-iot-gateway"`. The tag names are arbitrary. |
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    |HealthCheckInterval|10s|The interval in seconds at which the service registry(Consul) will conduct a health check of this service.|
    |Host|localhost|Micro service host name|
    |Port|---|Micro service port number (specific for each service)|
    |ServerBindAddr|'' (empty string)|The interface on which the service's REST server should listen. By default the server is to listen on the interface to which the `Host` option resolves (leaving it blank). A value of `0.0.0.0` means listen on all available interfaces. App & Device service do not implement this setting. (specific for each service)|
    |StartupMsg|---|Message logged when service completes bootstrap start-up|
    |MaxResultCount|1024*|Read data limit per invocation. *Default value is for core/support services. Application and Device services do not implement this setting. |
    |MaxRequestSize|0|Defines the maximum size of http request body in kilbytes. 0 represents default to system max.|
    |RequestTimeout         |5s                          | Specifies a timeout duration for handling requests |
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
=== "Registry"
    |Property|Default Value|Description|
    |---|---|---|
    ||| configuration that govern how to connect to the registry to register for service registration |
    |Host           |localhost                      |Registry host name|
    |Port           |8500                           |Registry port number|
    |Type           |consul                         |Registry implementation type|
=== "Database"
    |Property|Default Value|Description|
    |---|---|---|
    |||configuration that govern database connectivity and the type of database to use. While not all services require DB connectivity, most do and so this has been included in the common configuration docs.|
    |Host |localhost                      |DB host name|
    |Port |6379                         |DB port number|
    |Name      |----                       |Database or document store name (Specific to the service)            |
    |Timeout      |5s           |DB connection timeout                                              |
    |Type |redisdb                        |DB type.  Redis is the only supported DB|
=== "MessageBus"
    |Property|Default Value|Description|
    |---|---|---|
    ||Entries in the MessageBus section of the configuration allow for connecting to the internal MessageBus and define a common base topic prefix|
    |Protocol | redis| Indicates the connectivity protocol to use when connecting to the bus.|
    |Host | localhost | Indicates the host of the messaging broker, if applicable.|
    |Port | 6379| Indicates the port to use when publishing a message.|
    |Type | redis| Indicates the type of messaging library to use. Currently this is Redis by default. Refer to the [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging) module for more information. |
    |AuthMode | usernamepassword| Auth Mode to connect to EdgeX MessageBus.|
    |SecretName | redisdb | Name of the secret in the Secret Store to find the MessageBus credentials.|
    |BaseTopicPrefix | edgex| Indicates the base topic prefix which is prepended to all internal MessageBus topics. |
=== "MessageQueue.Optional"
    |Property|Default Value|Description|
    |---|---|---|
    ||Configuration and connection parameters for use with MQTT or NATS message bus - in place of Redis|
    |ClientId| ---|Client ID used to put messages on the bus (specific for each service)|
    |Qos|'0'| Quality of Service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)|
    |KeepAlive |'10'| Period of time in seconds to keep the connection alive when there are no messages flowing (must be 2 or greater)|
    |Retained|false|Whether to retain messages|
    |AutoReconnect |true |Whether to reconnect to the message bus on connection loss|
    |ConnectTimeout|5|Message bus connection timeout in seconds|
    |SkipCertVerify|false|TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified|
    | | Additional Default NATS Specific options  |
    | Format | nats | Format of the actual message published. See [NATs](../../general/messagebus/#configuration_2) section of the MessageBus documentation. |
    | RetryOnFailedConnect | true | Retry on connection failure - expects a string representation of a boolean |
    | QueueGroup | blank | Specifies a queue group to distribute messages from a stream to a pool of worker services |
    | Durable | blank | Specifies a durable consumer should be used with the given name. Note that if a durable consumer with the specified name does not exist it will be considered ephemeral and deleted by the client on drain / unsubscribe (JetStream only) |
    | AutoProvision | true | Automatically provision NATS streams. (JetStream only) |
    | Deliver | new | Specifies delivery mode for subscriptions - options are "new", "all", "last" or "lastpersubject". See the [NATS documentation](https://docs.nats.io/nats-concepts/jetstream/consumers#deliverpolicy-optstartseq-optstarttime) for more detail (JetStream only) |
    | DefaultPubRetryAttempts | 2 | Number of times to attempt to retry on failed publish (JetStream only)|

## Writable vs Readable Settings

Within the three sections of common configuration and a each service's private configuration, there are settings whose values can be edited via the Configuration Provider and change the behavior of the service while it is running.  These writable settings are grouped under `Writable` in each section. For example, the Writable for common configuration and Core Data are:

- /edgex/v3/core-common-config-bootstrapper/all-services/Writable
- /edgex/v3/core-common-config-bootstrapper/app-services/Writable
- /edgex/v3/core-common-config-bootstrapper/device-services/Writable
- /edgex/v3/core-data/Writable

Any configuration settings found in a common or service's `Writable` section may be changed and affect a service's behavior without a restart. Any
modifications to the other settings (read-only configuration) require a restart.

!!! note
    Run time changes to a common Writable setting will be ignored for services which have that setting overridden in the service's private configuration. This is to avoid changing values that have been explicitly overridden in a service's private configuration. If the service's Writable setting needs to be changed,  it can be done directly in the service's private Writable section from the Configuration Provider.
