# Service Configuration   

The configuration for EdgeX services is broken into multiple layers. The layers are as follows:

1. Common configuration for all services
2. Common configuration for Application or Device Services. 
3. Private configuration for each service 

Subsequent layers have higher precedence. As a result, the configuration values set in subsequent layers override those of underlying layers.

!!! edgey - "EdgeX 3.0"
    This layered configuration is new in EdgeX 3.0

## Common Configuration

!!! edgey - "EdgeX 3.0"
    Common configuration is new in Edgex 3.0 

The common configuration is divided into 3 sections:

- **All Services**- Configuration that is common to all EdgeX Services See below for details.

- **App Services** - Configuration that is common to just application services. See [App Service Configuration](../../application/GeneralAppServiceConfig) section for more details.
- **Device Services**- Configuration that is common to just devices services. See [Device Service Configuration](../../device/Ch-DeviceServices/#configuration-properties) section for more details.

When the Configuration Provider is used, the common configuration is seeded by the **core-common-config-bootstrapper** service, otherwise the common configuration comes from a file specified by the [`-cc/--commonConfig` command-line option](../CommonCommandLineOptions/#common-config).

!!! note
    Common environment variable overrides set on the **core-common-config-bootstrapper** service are applied to the common configuration prior to seeding the values into the Configuration Provider. See [Common Configuration Overrides](../CommonEnvironmentVariables/#common-configuration-overrides) section for more details.

### Common Configuration Properties

The tables in each of the tabs below document configuration properties that are common to all services in the EdgeX Foundry platform. 

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It now has default values which can be overridden with environment variables. See the [SecretStore Overrides](../CommonEnvironmentVariables/#secretstore-configuration-overrides) section for more details.

!!! edgey "Edgex 3.0"
    In EdgeX 3.0, the **MessageBus** configuration is now common to all services. In addition, the internal MessageBus topic configuration has been replaced by internal constants. The new **BaseTopicPrefix** setting has been added to allow customization of all topics under a common base prefix.  See the new common **MessageBus** section below.

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider` flag|
    |LogLevel|---|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  (specific for each service) |
    |**InsecureSecrets**|---|This section a map of secrets which simulates the SecretStore for accessing secrets when running in non-secure mode. All services have a default entry for Redis DB credentials called `redisdb`|
    

    !!! note
        LogLevel is included here for documentation purposes since all services have this setting. Since it should always be set at an individual service level it is not included in the new common configuration file and is present in all the individual service private configuration.

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

## Private Configuration

Each EdgeX service has a private configuration with values specific to that service. Some of these values may override values found in the common configuration layers described above. This private configuration is initially found in the service's `configuration.yaml` file. 

When the Configuration Provider is used, the EdgeX services will self-seed their private configuration, with environment variable overrides applied, into the Configuration Provider on first start-up. On restarts, the services will pull their private configuration from the Configuration Provider and apply it over the common configuration previously loaded from the Configuration Provider.

When the Configuration Provider is not used the service's private configuration will be applied over the common configuration loaded via the [`-cc/--commonConfig` command-line option](../CommonCommandLineOptions/#common-config).

!!! note
    The `-cc/--commonConfig` option is not required when the Configuration Provider is not used.  If it is not provided, the service's private configuration must be complete for its needs.  A complete configuration will have the private configuration settings as well as the necessary common configuration settings. Some of the Security services that do not use the Configuration Provider operate in this manner since they do not have common configuration like other EdgeX services.

The service specific private values and additional settings can be found on the respective documentation page for each service [here](http://localhost:8008/3.0/microservices/general/).

## Writable vs Readable Settings

Within each configuration layer, there are settings whose values can be edited via the Configuration Provider and change the behavior of the service while it is running.  These writable settings are grouped under `Writable` in each layer. Any configuration settings found in a common or private `Writable` section may be changed and affect a service's behavior without a restart. Any modifications to the other settings (read-only configuration) require a restart of the service(s).

!!! note
    Runtime changes to a common Writable setting will be ignored by services which have that setting overridden in a subsequent layer, i.e. app/device or private. This is to avoid changing values that have been explicitly overridden in a lower layer Writable section by changing the same setting in a higher layer Writable section. The setting value should be changed at the lowest layer in which it exists for a service.
