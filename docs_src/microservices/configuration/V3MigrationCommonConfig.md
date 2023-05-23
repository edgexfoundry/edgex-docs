# V3 Migration of Common Configuration 
As stated in the top level V3 Migration guide, common configuration has been separated out from each service's private configuration. See the [Service Configuration](../CommonConfiguration/) page for more details on the new **Common Configuration**.

There have also been changes to some sections of the common configuration in order to make them consistent and stream-lined for all EdgeX services 

## MessageBus

In EdgeX 3.0 the EdgeX MessageBus configuration has been refactored and renamed to be `MessageBus`. Prior to EdgeX 3.0, Core/Support Services and Device services had it as `MessageQueue` and Applications Services had it as `MessageBus` under the `Trigger` configuration. Now all services have it as top level `MessageBus`. In addition to the rename, the following fields have been add or removed:

### New Settings

- **Disabled** - Defaults to `false`. Set to `true` by Application Services that don't need the EdgeX MessageBus for Trigger or Metrics. When set to `false` this allows for Metrics to still be published to the EdgeX MessageBus when the Trigger is set to `http` or `external-mqtt`
- **BaseTopicPrefix** - Base topic prefix that is prepended to all the new topic constants. Defaults to `edgex` if not set.

### Removed Settings

- **PublishTopicPrefix** - Topics are no longer configurable, except for `BaseTopicPrefix`
- **SubscribeTopic** - Topics are no longer configurable, except for `BaseTopicPrefix`
- **Topics** - Topics are no longer configurable, except for `BaseTopicPrefix`
- **SubscribeEnabled** - No longer needed by Core Data. If Core Data's `PersistData` is set to`true` the Core Data will always subscribe to events from the EdgeX MessageBus

### Custom MessageBus configuration

If your deployment has customized any of the EdgeX provided service's `MessageBus` configuration, you will need to re-apply your customizations to the EdgeX 3.0 version of the service's `MessageBus` configuration in the new separated out common configuration.

!!! example - "Example V3 MessageBus configuration - Common"
    ```yaml
      MessageBus:
        Protocol: "redis"
        Host: "localhost"
        Port: 6379
        Type: "redis"
        AuthMode: "usernamepassword"  # required for redis MessageBus (secure or insecure).
        SecretName: "redisdb"
        BaseTopicPrefix: "edgex" # prepended to all topics as "edgex/<additional topic levels>
        Optional:
          # Default MQTT Specific options that need to be here to enable environment variable overrides of them
          Qos:  "0" # Quality of Service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
          KeepAlive: "10" # Seconds (must be 2 or greater)
          Retained: "false"
          AutoReconnect: "true"
          ConnectTimeout: "5" # Seconds
          SkipCertVerify: "false"
          # Additional Default NATS Specific options that need to be here to enable environment variable overrides of them
          Format: "nats"
          RetryOnFailedConnect: "true"
          QueueGroup: ""
          Durable: ""
          AutoProvision: "true"
          Deliver: "new"
          DefaultPubRetryAttempts: "2"
          Subject: "edgex/#" # Required for NATS JetStream only for stream auto-provisioning
    ```

With the separation of Common Configuration, each service needs set the `Optional.ClientId` in their private configuration to a unique value

!!! example - "Example V3 MessageBus configuration - Private"
    ```yaml
    MessageBus:
      Optional:
        ClientId: "core-data"
    ```

## Database

In EdgeX 3.0 the database configuration for Core/Support services has changed from `Databases map[string]bootstrapConfig.Database` to `Database bootstrapConfig.Database`. This aligns it with the database configuration used by Application Services

!!! example "Example V3 Database configuration"
    ```
    Database:
      Host: "localhost"
      Port: 6379
      Timeout: "5s"
      Type: "redisdb"
    ```

## SecretStore

In EdgeX 3.0 the `SecretStore` settings have been remove from the service configuration and are now controlled via default values and environment variable overrides. The environment variable override names have not changed. See [SecretStore Configuration Overrides](../CommonEnvironmentVariables/#secretstore-configuration-overrides) section for more details. 

If you have customized `SecretStore` configuration, simply remove the `SecretStore` section and use environment variable overrides to apply your customizations.

## InscureSecrets

In EdgeX 3.0 some `InsecureSecrets` configuration fields names have changed.

- **Path** - Renamed to `SecretName`
- **Secrets** - Renamed to `SecretData`

!!! example - "Example V3 InsecureSecrets configuration"
    ```yaml
        InsecureSecrets:
          DB:
            SecretName: "redisdb"
            SecretData:
              username: ""
              password: ""
    ```

### Custom InsecureSecrets

#### In File

If you have customized `InsecureSecrets` in the configuration file you will need to adjust the field names described above.

#### Via Environment Variable Overrides.

If you have used Environment Variable Overrides to customize `InsecureSecrets` , the Environment Variable names will need to change to account for the new field names above.

!!! example - "Example V3 Environment Variable Overrides for InsecureSecrets"
    ```yaml
    WRITABLE_INSECURESECRETS_<KEY>_SECRETNAME: mySecretName
    WRITABLE_INSECURESECRETS_<KEY>_SECRETDATA_<DATAKEY>: mySecretDataItem
    ```

