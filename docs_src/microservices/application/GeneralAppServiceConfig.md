
# General App Service Configuration

Similar to other EdgeX services, configuration is first determined by the `configuration.toml` file in the `/res` folder. If `-cp` is passed to the application on startup, the SDK will leverage the specific configuration provider (i.e Consul) to push configuration from the file into the registry and monitor configuration from there. You will find the configuration under the `edgex/appservices/1.0/` key. 

This section describes the configuration elements that are unique to Application Services

Please refer to the general [Configuration documentation](../../configuration/Ch-Configuration#configuration-properties) for configuration properties common across all services.

!!! note
    `*`indicates the configuration value can be changed on the fly if using a configuration provider (like Consul).
    `**`indicates the configuration value can be changed but the service must be restarted.

## Writable
The following are additional entries in the **Writable** section which are applicable to Application Services.

### Writable StoreAndForward
The section configures the **Store and Forward** capability. Please refer to [Store and Forward](../ApplicationFunctionsSDK/#store-and-forward) section for more details.

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
|Writable StoreAndForward `Enabled` | false* | Indicates whether the **Store and Forward** capability enabled or disabled |
| Writable StoreAndForward `RetryInterval`             | "5m"* | Indicates the duration of time to wait before retries, aka *Forward* |
| Writable StoreAndForward `MaxRetryCount`             | 10* | Indicates whether maximum number of retries of failed data. The failed data is removed after the maximum retries has been exceeded. A value of `0` indicates endless retries. |

### Writable Pipeline
The section configures the Configurable Function Pipeline which is used only by App Service Configurable. Please refer to [App Service Configurable - Getting Started](../AppServiceConfigurable/#getting-started) section for more details

### Writable InsecureSecrets
This section defines Insecure Secrets that are used when running is non-secure mode, i.e. when Vault isn't available. This is a dynamic map of configuration, so can empty if no secrets are used or can have as many or few user define secrets. Below are a few that are need if using the indicated capabilities.

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
| **Writable InsecureSecrets DB** | --- | This section defines a block of insecure secrets for database connection when **Store and Forward** is enabled and running is non-secure mode. This section is not required if **Store and Forward** is not enabled. |
| Writable InsecureSecrets DB `path` | redisdb* | Indicates the type of database the insecure secrets are for. `redisdb` id the DB type name used internally and used to look up the credentials. |
| **Writable InsecureSecrets DB Secrets** | --- | This section contains the Secrets key value pair map of database credentials |
| Writable InsecureSecrets DB Secrets `username` | blank* | Indicates the value for the `username` when connecting to the database. When running in non-secure mode it is `blank`. |
| Writable InsecureSecrets DB Secrets `password` | blank* | Indicates the value for the `password` when connecting to the database. When running in non-secure mode it is `blank`. |
| **Writable InsecureSecrets http** | --- | This section defines a block of insecure secrets for HTTP Export, i.e `HTTPPost` function |
| Writable InsecureSecrets http `path` | http* | Indicates the secrets path for HTTP Export. Must match the `secretpath` name configured for the `HTTPPost` function. |
| **Writable InsecureSecrets http Secrets** | --- | This section contains the Secrets key value pair map for the `HTTPPost` function |
| Writable InsecureSecrets http Secrets `[headername]` | undefined* | This indicates the HTTP header name and the value to set it to. I.e. the key name you choose is the actual HTTP Header name. The key name must match the `secretheadername` configured for `HTTPPost`. The value is what you need the header set to. |
| **Writable InsecureSecrets MQTT** | --- | This section defines a block of insecure secrets for MQTT export, i.e. `MQTTSecretSend` function. |
| Writable InsecureSecrets MQTT `path` | mqtt* | Indicates the secrets path for MQTT Export. Must match the `secretpath` name configured for the `MQTTSecretSend` function. |
| **Writable InsecureSecrets MQTT Secrets** | --- | This section contains the Secrets key value pair map for the `MQTTSecretSend` function |
| Writable InsecureSecrets MQTT Secrets `username` | blank* | Indicates the value for the `username` when connecting to the MQTT broker using ` usernamepassword` authentication mode. Must be configured to the value the MQTT broker is expecting. |
| Writable InsecureSecrets MQTT Secrets `password` | blank* | Indicates the value for the `password` when connecting to the MQTT broker using ` usernamepassword` authentication mode. Must be configured to the value the MQTT broker is expecting. |
| Writable InsecureSecrets MQTT Secrets `cacert` | blank* | Indicates the value (contents) for the `CA Certificate` when connecting to the MQTT broker using ` cacert` authentication mode. Must be configured to the value the MQTT broker is expecting. |
| Writable InsecureSecrets MQTT Secrets `clientcert` | blank* | Indicates the value (contents) for the `Client Certificate` when connecting to the MQTT broker using ` clientcert` authentication mode. Must be configured to the value the MQTT broker is expecting. |
| Writable InsecureSecrets MQTT Secrets `clientkey` | blank* | Indicates the value (contents) for the `Client Key` when connecting to the MQTT broker using ` clientcert` authentication mode. Must be configured to the value the MQTT broker is expecting. |

## Not Writable
The following are additional configuration which are applicable to Application Services that require the service to be restarted after value(s) are changed.

### Database
This optional section contains the connection information. It is only required when the **Store and Forward** capability is enabled. Note that it has a slightly different format that the database section used in the core services configuration.

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
| Database `Type` | redisdb** | Indicates the type of database used. `redisdb` and `mongodb` are the only valid types. |
| Database `Host` | localhost** | Indicates the hostname for the database |
| Database `Port` | 6379** | Indicates the port number for the database |
| Database `Timeout` | "30s"** | Indicates the connection timeout for the database |

### SecretStoreExclusive
This optional section defines the configuration for the `Exclusive` Secret Store (i.e. Vault) used to Put and Get secrets that are exclusive to the instance of the Application Service. Please refer to the [Secrets](../ApplicationFunctionsSDK/#secrets) section for more details.

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
| SecretStoreExclusive `Host` | localhost** | Indicates the hostname for the Secret Store |
| SecretStoreExclusive `Port` | 8200** | Indicates the port number for the Secret Store |
| SecretStoreExclusive `Path` | Depends on <br />profile used<br /> | Indicates the base path for the secrets with in the |
| SecretStoreExclusive `Protocol` | https** | Indicates the protocol used for the Secret Store |
| SecretStoreExclusive `RootCaCertPath` | /vault/config/pki/<br />EdgeXFoundryCA/<br />EdgeXFoundryCA.pem** | Indicates the path to the root CA Certificate for Vault |
| SecretStoreExclusive `ServerName` | localhost** | Indicates the server name for the Secret Store |
| SecretStoreExclusive `TokenFile` | /vault/config/<br />assets/<br />resp-init.json** | Indicates the path to the `exclusive` token for the service to connect to the Secret Store |
| SecretStoreExclusive `AdditionalRetryAttempts` | 10** | Indicates the maximum number of failed connection attempts allowed |
| SecretStoreExclusive `RetryWaitPeriod` | "1s"** | Indicates the wait time between failed connection attempts |
| **SecretStoreExclusive Authentication** | --- | The section defines the Secret Store Authentication |
| SecretStoreExclusive Authentication `AuthType` | X-Vault-Token** | Indicates the authentication type used when connecting to the Secret Store |

### Clients
This section defines the clients connect information. Please refer to the [Note about Clients](../ApplicationFunctionsSDK/#note-about-clients) section for more details.

### Binding
This section defines the `Trigger` binding for incoming data.

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
| Binding `Type` | messagebus** | Indicates the `Trigger` binding type. valid values are `messagebus` and `http` |
| Binding `SubscribeTopic` | events** | Only used for `messagebus  ` binding type<br />Indicates the subscribe topic to use to receive data from the Message Bus |
| Binding `PublishTopic` | blank** | Only used for `messagebus` binding type<br />Indicates the publish topic to use when sending data to the Message Bus |

### MessageBus
This section defines the message bus connect information.
Only used for `messagebus` binding type

|Configuration  |     Default Value     | Description |
| --- | --- | -- |
| MessageBus `Type` | zero** | Indicates the type of message bus being used. Valid type are `zero`, `mqtt` or `redisstreams` |
| **MessageBus SubscribeHost** | ... | This section defines the connection information for subscribing to the Message Bus |
| MessageBus SubscribeHost `Host` | localhost** | Indicates the hostname for subscribing to the Message Bus |
| MessageBus SubscribeHost `Port` | 5563** | Indicates the port number for subscribing to the Message Bus |
| MessageBus SubscribeHost `Protocol` | tcp** | Indicates the protocol number for subscribing to the Message Bus |
| **MessageBus PublishHost** | ... | This section defines the connection information for publishing to the Message Bus |
| MessageBus PublishHost`Host` | "*" ** | Indicates the hostname for publishing to the Message Bus |
| MessageBus SubscribeHost `Port` | 5565** | Indicates the port number for publishing to the Message Bus |
| MessageBus SubscribeHost `Protocol` | tcp** | Indicates the protocol number for publishing to the Message Bus |
| **MessageBus Optional** | ... | This section is used for optional configuration specific to the Message Bus type used. Please refer to [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging/blob/master/README.md) for more details |

### Application Settings 

`[ApplicationSettings]` - Is used for custom application settings and is accessed via the ApplicationSettings() API. The ApplicationSettings API returns a `map[string] string` containing the contents on the ApplicationSetting section of the `configuration.toml` file.

```toml
 [ApplicationSettings]
 ApplicationName = "My Application Service"
```
