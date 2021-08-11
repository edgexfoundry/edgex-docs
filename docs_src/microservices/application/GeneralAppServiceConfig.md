
# Application Service Configuration

Similar to other EdgeX services, configuration is first determined by the `configuration.toml` file in the `/res` folder. Once loaded any environment overrides are applied. If `-cp` is passed to the application on startup, the SDK will leverage the specific configuration provider (i.e Consul) to push the configuration into the provider and monitor `Writeable` configuration from there. You will find the configuration under the `edgex/appservices/2.0/` key in the provider (i.e Consul). On re-restart the service will pull the configuration from the provider and apply any environment overrides.

This section describes the configuration elements that are unique to Application Services

Please first refer to the general [Configuration documentation](../../configuration/CommonConfiguration) for configuration properties common across all EdgeX services.

!!! note
    `*`indicates the configuration value can be changed on the fly if using a configuration provider (like Consul).
    `**`indicates the configuration value can be changed but the service must be restarted.

## Writable
The tabs below provide additional entries in the **Writable** section which are applicable to Application Services.

=== "Writable StoreAndForward"

    The section configures the **Store and Forward** capability. Please refer to [Store and Forward](../ApplicationFunctionsSDK/#store-and-forward) documentation for more details.

    | Configuration | Default Value |                                                              |
    | :------------ | ------------- | ------------------------------------------------------------ |
    | Enabled       | false*        | Indicates whether the **Store and Forward** capability enabled or disabled |
    | RetryInterval | "5m"*         | Indicates the duration of time to wait before retries, aka *Forward* |
    | MaxRetryCount | 10*           | Indicates whether maximum number of retries of failed data. The failed data is removed after the maximum retries has been exceeded. A value of `0` indicates endless retries. |

=== "Writable Pipeline"

    The section configures the Configurable Function Pipeline which is used only by App Service Configurable. Please refer to [App Service Configurable - Getting Started](../AppServiceConfigurable/#getting-started) section for more details

=== "Writable InsecureSecrets"

    This section defines Insecure Secrets that are used when running in non-secure mode, i.e. when Vault isn't available. This is a dynamic map of configuration, so can empty if no secrets are used or can have as many or few user define secrets. It simulates a Secret Store in non-secure mode. Below are a few examples that are need if using the indicated capabilities.

    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | **DB** | --- | This section defines a block of insecure secrets for database credentials when **Redis** is used for the MessageBus and/or when **Store and Forward** is enabled and running is non-secure mode. This section is not required if **Store and Forward** is not enabled and not using **Redis** for the MessageBus . |
    | path | redisdb* | Indicates the location in the simulated Secret Store where the DB secret resides. |
    | **DB Secrets** | --- | This section is the collection of **DB** secret data |
    | username | blank* | Indicates the value for the `username` when connecting to the database. When running in non-secure mode it is `blank`. |
    | password | blank* | Indicates the value for the `password` when connecting to the database. When running in non-secure mode it is `blank`. |
    | **http** | --- | This section defines a block of insecure secrets for HTTP Export, i.e `HTTPPost` function |
    | path | http* | Indicates the location in the simulated Secret Store where the HTTP secret resides. |
    | **http Secrets** | --- | This section is the collection of **HTTP** secret data.  See [Http Export](BuiltIn.md#http) documentation for more details on use of secret data. |
    | headervalue | undefined* | This indicates the name of the secret value to use as the value in the HTTP header. |
    | **mqtt** | --- | This section defines a block of insecure secrets for MQTT export, i.e. `MQTTSecretSend` function. |
    | path | mqtt* | Indicates the location in the simulated Secret Store where the MQTT secret reside. |
    | **mqtt Secrets** | --- | This section is the collection of MQTT secret data. See [Mqtt Export](BuiltIn.md#mqtt) documentation for more details on use of secret data. |
    | username | blank* | Indicates the value for the `username` when connecting to the MQTT broker using ` usernamepassword` authentication mode. Must be configured to the value the MQTT broker is expecting. |
    | password | blank* | Indicates the value for the `password` when connecting to the MQTT broker using ` usernamepassword` authentication mode. Must be configured to the value the MQTT broker is expecting. |
    | cacert | blank* | Indicates the value (contents) for the `CA Certificate` when connecting to the MQTT broker using ` cacert` authentication mode. Must be configured to the value the MQTT broker is expecting. |
    | clientcert | blank* | Indicates the value (contents) for the `Client Certificate` when connecting to the MQTT broker using ` clientcert` authentication mode. Must be configured to the value the MQTT broker is expecting. |
    | clientkey | blank* | Indicates the value (contents) for the `Client Key` when connecting to the MQTT broker using ` clientcert` authentication mode. Must be configured to the value the MQTT broker is expecting. |

## Not Writable
The tabs below provide additional configuration which are applicable to Application Services that require the service to be restarted after value(s) are changed.

=== "HttpServer"

    !!! edgey "EdgeX 2.0"
        New for EdgeX 2.0. These setting previously were in the `Service` configuration section specific to Application Services. Now the `Service` configuration is the same for all EdgeX services. See the general [Configuration documentation](../../configuration/CommonConfiguration) for more details on the common `Service` configuration.

    This section contains the configuration for the internal Webserver. Only need if configuring the Webserver for `HTTPS`

    | Configuration | Default Value | Description                                                  |
    | ------------- | ------------- | ------------------------------------------------------------ |
    | Protocol      | http**        | Indicates the protocol for the webserver to use              |
    | SecretName    | blank**       | Indicates the name of the secret in the Secret Store where the HTTPS secret data resides |
    | HTTPSCertName | blank**       | Indicates the key name in the HTTPS secret data that contains the `certificate data` to use for HTTPS |
    | HTTPSKeyName  | blank**       | Indicates the key name in the HTTPS secret data that contains the `key data` to use for HTTPS |

=== "Database"

    This section contains the connection information. It is required when using `redis` for the **MessageBus** (which is the default) and/or when the **Store and Forward** capability is enabled. Note that it has a slightly different format than the database section used in the core services configuration.

    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | Type | redisdb** | Indicates the type of database used. `redisdb` and `mongodb` are the only valid types. |
    | Host | localhost** | Indicates the hostname for the database |
    | Port | 6379** | Indicates the port number for the database |
    | Timeout | "30s"** | Indicates the connection timeout for the database |

=== "Clients"

    This section defines the connect information for the EdgeX Clients and is the same as that used by all EdgeX services, just which clients are needed differs. Please refer to the [Note about Clients](../ApplicationFunctionsSDK/#note-about-clients) section for more details.

=== "Trigger"

    This section defines the `Trigger` for incoming data. See the [Triggers](Triggers.md) documentation for more details on the inner working of triggers. 

    !!! edgey "EdgeX 2.0"
        For EdgeX 2.0 the `Binding` section has been renamed to `Trigger` .  

    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | Type | edgex-messagebus** | Indicates the `Trigger` binding type. valid values are `edgex-messagebus`, `external-mqtt` or `http` |

=== "Trigger EdgeXMessageBus"

    This section defines the message bus connect information.
    Only used for `edgex-messagebus` binding type

    !!! edgey "EdgeX 2.0"
        For EdgeX 2.0 the `MessageBus` section has been renamed to `EdgexMessageBus` and moved under the `Trigger` section. The `SubscribeTopic` setting has changed to `SubscribeTopics` and moved under the `SubscribeHost` section of `EdgexMessageBus` . The `PublishTopic` has been moved under the `PublishHost` section of `EdgexMessageBus`.

    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | Type | redis** | Indicates the type of MessageBus being used. Valid type are `redis`, `mqtt`,  or`zero` |
    | **SubscribeHost** | ... | This section defines the connection information for subscribing/publishing to the MessageBus |
    | Host | localhost** | Indicates the hostname for subscribing to the MessageBus |
    | Port | 6379** | Indicates the port number for subscribing to the MessageBus |
    | Protocol | redis** | Indicates the protocol number for subscribing to the MessageBus |
    | SubscribeTopics | edgex/events/#** | MessageBus topic(s) to subscribe to. This is a comma separated list of topics. Supports filtering by subscribe topics. See [EdgeXMessageBus](Triggers.md#edgex-message-bus) Trigger for more details. |
    | **PublishHost** | ... | This section defines the connection information for publishing to the MessageBus |
    | Host | "*" ** | Indicates the hostname for publishing to the Message Bus |
    | Port | 6379** | Indicates the port number for publishing to the Message Bus |
    | Protocol | redis** | Indicates the protocol number for publishing to the Message Bus |
    | PublishTopic | blank** | Indicates the topic in which to publish the function pipeline response data, if any. Supports dynamic topic places holders. See [EdgeXMessageBus](Triggers.md#edgex-message-bus) Trigger for more details. |
    | **Optional** | ... | This section is used for optional configuration specific to the MessageBus type used. Please refer to [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging/blob/master/README.md) for more details |

=== "Trigger ExternalMqtt"

    This section defines the external MQTT Broker connect information.
    Only used for `external-mqtt` trigger binding type

    !!! edgey "EdgeX 2.0"
        For EdgeX 2.0 the `MqttBroker` section has been renamed to `ExternalMqtt` and moved under the `Trigger` section. The `ExternalMqtt` section now has it's own `SubscribeTopics` and  `PublishTopic` settings. 

    !!! note
        `external-mqtt` is not the default Trigger type, so there are no default values for `ExternalMqtt` settings beyond those that the Go compiler gives to the empty struct. Some of those default values are not valid and must be specified, i.e. `Authmode`

    | Configuration   | Default Value | Description                                                  |
    | --------------------------------- | ------------- | ------------------------------------------------------------ |
    | Url | blank**       | Fully qualified URL to connect to the MQTT broker, i.e. `tcp://localhost:1883` |
    | SubscribeTopics | blank** | MQTT topic(s) to subscribe to. This is a comma separated list of topics |
    | PublishTopic | blank** | MQTT topic to publish the function pipeline response data, if any. Supports dynamic topic places holders. See [ExternalMqtt](Triggers.md#external-mqtt) Trigger for more details. |
    | ClientId | blank**       | ClientId to connect to the broker with |
    | ConnectTimeout | blank**       | Time duration indicating how long to wait before timing out                                                        broker connection, i.e "30s" |
    | AutoReconnect | false**       | Indicates whether or not to retry connection if disconnected |
    | KeepAlive | 0**           | Seconds between client ping when no active data flowing to avoid client being disconnected. Must be greater then 2 |
    | QOS | 0**           | Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once) |
    | Retain | false**       | Retain setting for MQTT Connection                           |
    | SkipCertVerify | false**       | Indicates if the certificate verification should be skipped  |
    | SecretPath | blank**       | Name of the path in secret provider to retrieve your secrets. Must be non-blank. |
    | AuthMode | blank**       | Indicates what to use when connecting to the broker. Must be one of "none", "cacert" , "usernamepassword", "clientcert". <br />If a CA Cert exists in the SecretPath then it will be used for all modes except "none". |

=== "Application Settings"

    `[ApplicationSettings]` - Is used for custom application settings and is accessed via the ApplicationSettings() API. The ApplicationSettings API returns a `map[string] string` containing the contents on the ApplicationSetting section of the `configuration.toml` file.

    ```toml
    [ApplicationSettings]
    ApplicationName = "My Application Service"
    ```

=== "Custom Structured Configuration"

    !!! edgey "EdgeX 2.0"
        New for EdgeX 2.0

    Custom Application Services can now define their own custom structured configuration section in the `configuration.toml` file. Any additional sections in the TOML are ignore by the SDK when it parses the file for the SDK defined sections. See the [Custom Configuration](ApplicationFunctionsSDK.md#custom-configuration) section of the SDK documentation for more details.

