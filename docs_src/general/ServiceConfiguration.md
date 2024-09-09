# Service Configuration

Each EdgeX microservice requires configuration (i.e. - a repository of initialization and operating values).  The configuration is initially provided by a [YAML](https://en.wikipedia.org/wiki/YAML) file but a service can utilize the centralized configuration management provided by EdgeX for its configuration. 

See the [Configuration and Registry documentation](../microservices/configuration/ConfigurationAndRegistry.md) for more details about initialization of services and the use of the configuration service.  

Please refer to the EdgeX Foundry [architectural decision record](../design/adr/0005-Service-Self-Config.md) for details (and design decisions) behind the configuration in EdgeX.

Please refer to the general [Common Configuration documentation](../microservices/configuration/CommonConfiguration.md) for configuration properties common to all services.  Find service specific configuration references in the tabs below.

=== "Core"
    |Service Name|Configuration Reference|
    |---|---|
    |core-data|	[Core Data Configuration](../microservices/core/data/Configuration.md)|
    |core-metadata	|[Core Metadata Configuration](../microservices/core/metadata/Configuration.md)|
    |core-command	|[Core Command Configuration](../microservices/core/command/Configuration.md)|
=== "Supporting"
    |Service Name|Configuration Reference|
    |---|---|
    |support-notifications	|[Support Notifications Configuration](../microservices/support/notifications/Configuration.md)|
    |support-scheduler|	[Support Scheduler Configuration](../microservices/support/scheduler/Configuration.md)|
=== "Application & Analytics"
    |Service Name|	Configuration Reference|
    |---|---|
    |app-service|[General Application Service Configuration](../microservices/application/Configuration.md)|
    |app-service-configurable|[Configurable Application Service Configuration](../microservices/application/services/AppServiceConfigurable/Configuration.md)|
    |app-record-replay|[App Record Replay Configuration](../microservices/application/services/AppRecordReplay/Configuration.md)|
    |eKuiper rules engine/eKuiper|[Basic eKuiper Configuration](https://github.com/lf-edge/ekuiper/blob/7ef3a19366ee1f4537747fdc2e574389225f5d51/docs/en_US/operation/config/configuration_file.md)|
=== "Device"
    |Service Name|	Configuration Reference|
    |---|---|
    |device-service	|[General Device Service Configuration](../microservices/device/Configuration.md)|
    |device-virtual	|[Virtual Device Service Configuration](../microservices/device/services/device-virtual/Ch-VirtualDevice.md#configuration-properties)|
=== "Security"
    |Service Name|	Configuration Reference|
    |---|---|
    |API Gateway|[API Gateway Configuration](../security/Ch-APIGateway.md#configuring-api-gateway)|
    |Add-on Services |[Configuring Add-on Service](../security/Ch-Configuring-Add-On-Services.md)|
