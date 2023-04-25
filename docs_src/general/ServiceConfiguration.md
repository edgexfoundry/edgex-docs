# Service Configuration

Each EdgeX micro service requires configuration (i.e. - a repository of initialization and operating values).  The configuration is initially provided by a [YAML](https://en.wikipedia.org/wiki/YAML) file but a service can utilize the centralized configuration management provided by EdgeX for its configuration. 

See the [Configuration and Registry documentation](../microservices/configuration/ConfigurationAndRegistry.md) for more details about initialization of services and the use of the configuration service.  

Please refer to the EdgeX Foundry [architectural decision record](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0005-Service-Self-Config.md) for details (and design decisions) behind the configuration in EdgeX.

Please refer to the general [Common Configuration documentation](../microservices/configuration/CommonConfiguration.md) for configuration properties common to all services.  Find service specific configuration references in the tabs below.

=== "Core"
    |Service Name|Configuration Reference|
    |---|---|
    |core-data|	[Core Data Configuration](../microservices/core/data/Ch-CoreData.md#configuration-properties)|
    |core-metadata	|[Core Metadata Configuration](../microservices/core/metadata/Ch-Metadata.md#configuration-properties)|
    |core-command	|[Core Command Configuration](../microservices/core/command/Ch-Command.md#configuration-properties)|
=== "Supporting"
    |Service Name|Configuration Reference|
    |---|---|
    |support-notifications	|[Support Notifications Configuration](../microservices/support/notifications/Ch-AlertsNotifications.md#configuration-properties)|
    |support-scheduler|	[Support Scheduler Configuration](../microservices/support/scheduler/Ch-Scheduler.md#configuration-properties)|
=== "Application & Analytics"
    |Services Name|	Configuration Reference|
    |---|---|
    |app-service|[General Application Service Configuration](../microservices/application/GeneralAppServiceConfig.md)|
    |app-service-configurable|[Configurable Application Service Configuration](../microservices/application/AppServiceConfigurable.md#getting-started)|
    |eKuiper rules engine/eKuiper|[Basic eKuiper Configuration](https://github.com/lf-edge/ekuiper/blob/7ef3a19366ee1f4537747fdc2e574389225f5d51/docs/en_US/operation/config/configuration_file.md)|
=== "Device"
    |Services Name|	Configuration Reference|
    |---|---|
    |device-service	|[General Device Service Configuration](../microservices/device/Ch-DeviceServices.md#configuration-properties)|
    |device-virtual	|[Virtual Device Service Configuration](../microservices/device/supported/device-virtual/Ch-VirtualDevice.md#configuration-properties)|
=== "Security"
    |Services Name|	Configuration Reference|
    |---|---|
    |API Gateway|[API Gateway Configuration](../security/Ch-APIGateway.md#configuring-api-gateway)|
    |Add-on Services |[Configuring Add-on Service](../security/Ch-Configuring-Add-On-Services.md)|
