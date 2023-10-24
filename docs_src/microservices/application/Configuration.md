---
title: App Services - Configuration
---

# Application Services - Configuration

Similar to other EdgeX services, application service configuration is first determined by the `configuration.yaml` file in the `/res` folder. Once loaded any environment overrides are applied. If `-cp` is passed to the application on startup, the SDK will leverage the specific configuration provider (i.e. Consul) to push the configuration into the provider and monitor `Writable` configuration from there. Any environment overrides are applied prior to the values being pushed. You will find the configuration under the `edgex/{{api_version}}/` key in the provider (i.e. Consul). On re-restart the service will pull the configuration from the provider.

This section describes the configuration elements provided by the SDK that are unique to Application Services

Please first refer to the general [Configuration documentation](../configuration/CommonConfiguration.md) for configuration properties common across all EdgeX services.

!!! note
    `*`indicates the configuration value can be changed on the fly if using a configuration provider (like Consul).
    `**`indicates the configuration value can be changed but the service must be restarted.

### Writable
The tabs below provide additional entries in the **Writable** section which are applicable to Application Services.

=== "Writable.StoreAndForward"

    The section configures the **Store and Forward** capability. Please refer to [Store and Forward](sdk/details/StoreAndForward.md) documentation for more details.
    
    | Configuration | Default Value |                                                              |
    | :------------ | ------------- | ------------------------------------------------------------ |
    | Enabled       | false*        | Indicates whether the **Store and Forward** capability enabled or disabled |
    | RetryInterval | "5m"*         | Indicates the duration of time to wait before retries, aka *Forward* |
    | MaxRetryCount | 10*           | Indicates whether maximum number of retries of failed data. The failed data is removed after the maximum retries has been exceeded. A value of `0` indicates endless retries. |

=== "Writable.Pipeline"

    The section configures the Configurable Function Pipeline which is used only by App Service Configurable. Please refer to [App Service Configurable Configuration](services/AppServiceConfigurable/Configuration.md) section for more details

=== "Writable.InsecureSecrets"

    This section defines Insecure Secrets that are used when running in non-secure mode, i.e. when Vault isn't available. This is a dynamic map of configuration, so can empty if no secrets are used or can have as many or few user define secrets. It simulates a Secret Store in non-secure mode. Below are a few examples that are need if using the indicated capabilities.
    
    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | `<name>' | --- | This section defines a block of insecure secrets for some service specific need |
    | SecretName | `<name>` | Indicates the location in the simulated Secret Store where the secret resides. |
    | SecretData | --- | This section is the collection of secret data.  |
    | `key` | `value` | Secret data key value pairs |

=== "Writable.Telemetry"
    |Property|<Default Value|Description|
    |---|---|---|
    |||See `Writable.Telemetry` at [Common Configuration](../configuration/CommonConfiguration.md#common-configuration-properties) for the Telemetry configuration common to all services |
    |Metrics|     |Service metrics that the application service collects. Boolean value indicates if reporting of the metric is enabled. Custom metrics are also included here for custom application services that define custom metrics|
    |Metrics.MessagesReceived |  false |Enable/disable reporting of the built-in **MessagesReceived** metric|
    |Metrics.InvalidMessagesReceived | false |Enable/disable reporting of the built-in **InvalidMessagesReceived** metric|
    |Metrics.HttpExportSize   |  false| Enable/disable reporting of the built-in **HttpExportSize** metric|
    |Metrics.HttpExportErrors   |  false| Enable/disable reporting of the built-in **HttpExportErrors** metric|
    |Metrics.MqttExportSize   | false |Enable/disable reporting of the built-in **MqttExportSize** metric|
    |Metrics.MqttExportErrors   | false |Enable/disable reporting of the built-in **MqttExportErrors** metric|
    |Metrics.PipelineMessagesProcessed | false |Enable/disable reporting of the built-in **PipelineMessagesProcessed** metric|
    |Metrics.PipelineProcessingErrors | false | Enable/disable reporting of the built-in **PipelineProcessingErrors** metric|
    |Metrics.PipelineMessageProcessingTime | false |Enable/disable reporting of the built-in **PipelineMessageProcessingTime** metric|
    |Metrics.`<CustomMetric>`| false | (Service Specific) Enable/disable reporting of custom application service's custom metric. See [Custom Application Service Metrics](sdk/details/CustomServiceMetrics.md) for more detail|
    |Tags|`<empty>`|List of arbitrary service level tags to included with every metric that is reported. i.e. `Gateway="my-iot-gateway"` |

### Not Writable

The tabs below provide additional configuration which are applicable to Application Services that require the service to be restarted after value(s) are changed.

=== "HttpServer"

    This section contains the configuration for the internal Webserver. Only need if configuring the Webserver for `HTTPS`
    
    | Configuration | Default Value | Description                                                  |
    | ------------- | ------------- | ------------------------------------------------------------ |
    | Protocol      | http**        | Indicates the protocol for the webserver to use              |
    | SecretName    | blank**       | Indicates the name of the secret in the Secret Store where the HTTPS secret data resides |
    | HTTPSCertName | blank**       | Indicates the key name in the HTTPS secret data that contains the `certificate data` to use for HTTPS |
    | HTTPSKeyName  | blank**       | Indicates the key name in the HTTPS secret data that contains the `key data` to use for HTTPS |

=== "Clients"

    This service specific section defines the connection information for the EdgeX Clients and is the same as that used by all EdgeX services, just which clients are needed differs. 

    !!! note
        Clients that are used from code must be present in the configuration, otherwise a nil reference will occur. `core-metadata` is already present in the common configuration, so it is not needed in the local private configuration.
=== "Trigger"

    This section defines the `Trigger` for incoming data. See the [Triggers](details/Triggers.md) documentation for more details on the inner working of triggers. 
     
    |Configuration  |     Default Value     | Description |
    | --- | --- | -- |
    | Type | edgex-messagebus** | Indicates the `Trigger` binding type. valid values are `edgex-messagebus`, `external-mqtt`, `http`, or `<custom>` |
    | SubscribeTopics | events/#** | Topic(s) to subscribe to. This is a comma separated list of topics. Supports filtering by subscribe topics. Only set when using `edgex-messagebus` or `external-mqtt`. See [EdgeXMessageBus](details/Triggers.md#edgex-message-bus) Trigger for more details. |
    | PublishTopic | blank** | Indicates the topic in which to publish the function pipeline response data, if any. Supports dynamic topic places holders. Only set when using `edgex-messagebus` or `external-mqtt`. See [EdgeXMessageBus](details/Triggers.md#edgex-message-bus) Trigger for more details. |

=== "Trigger ExternalMqtt"

    This section defines the external MQTT Broker connect information.
    Only used for `external-mqtt` trigger binding type
    
    !!! note
        `external-mqtt` is not the default Trigger type, so there are no default values for `ExternalMqtt` settings beyond those that the Go compiler gives to the empty struct. Some of those default values are not valid and must be specified, i.e. `Authmode`
    
    | Configuration   | Default Value | Description                                                  |
    | --------------------------------- | ------------- | ------------------------------------------------------------ |
    | Url | blank**       | Fully qualified URL to connect to the MQTT broker, i.e. `tcp://localhost:1883` |
    | ClientId | blank**       | ClientId to connect to the broker with |
    | ConnectTimeout | blank**       | Time duration indicating how long to wait before timing out                                                        broker connection, i.e "30s" |
    | AutoReconnect | false**       | Indicates whether or not to retry connection if disconnected |
    | KeepAlive | 0**           | Seconds between client ping when no active data flowing to avoid client being disconnected. Must be greater then 2 |
    | QOS | 0**           | Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once) |
    | Retain | false**       | Retain setting for MQTT Connection                           |
    | SkipCertVerify | false**       | Indicates if the certificate verification should be skipped  |
    | SecretPath | blank**       | Name of the path in secret provider to retrieve your secrets. Must be non-blank. |
    | AuthMode | blank**       | Indicates what to use when connecting to the broker. Must be one of "none", "cacert" , "usernamepassword", "clientcert". <br />If a CA Cert exists in the SecretPath then it will be used for all modes except "none". |
    | RetryDuration | 600** | Indicates how long (in seconds) to wait timing out on the MQTT client creation |
    | RetryInterval | 5** | Indicates the time (in seconds) that will be waited between attempts to create MQTT client |
    | Will: Enabled | false** | Enables Last Will capability |
    | Will: Topic | blank** | Topic to publish the Last Will Payload when service disconnects from MQTT Broker |
    | Will: Payload | blank** | Will message to be sent to the Will Topic |
    | Will: Qos | blank** | QOS level for Will Topic |
    | Will: Retained | false** | Retained setting for Will Topic |

    !!! edgey "EdgeX 3.1"
        Last Will capability is new in EdgeX 3.1

    !!! note
        `Authmode=cacert` is only needed when client authentication (e.g. `usernamepassword`) is not required, but a CA Cert is needed to validate the broker's SSL/TLS cert.

=== "Application Settings"

    `[ApplicationSettings]` - Is used for custom application settings and is accessed via the ApplicationSettings() API. The ApplicationSettings API returns a `map[string] string` containing the contents on the ApplicationSetting section of the `configuration.yaml` file.
    
    ```yaml
    ApplicationSettings:
      ApplicationName: "My Application Service"
    ```

=== "Custom Structured Configuration"

    Custom Application Services can define their own custom structured configuration section in the `configuration.yaml` file. Any additional sections in the configuration file are ignored by the SDK when it parses the file for the SDK defined sections. See the [Custom Configuration](sdk/details/CustomConfiguration.md) section of the SDK documentation for more details.

