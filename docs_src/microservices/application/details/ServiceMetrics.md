---
title: App Services - Service Metrics
---

# Application Services - Service Metrics

All application services have the following built-in metrics:

- `MessagesReceived` - This is a **counter** metric that counts the number of messages received by the application service. Includes invalid messages.

- `InvalidMessagesReceived ` -  This is a **counter** metric that counts the number of invalid messages received by the application service. 

- `HttpExportSize  ` -  This is a **histogram** metric that collects the size of data exported via the built-in [HTTP Export pipeline function](../sdk/api/BuiltInPipelineFunctions.md#http-export). The metric data is not currently tagged due to breaking changes required to tag the data with the destination endpoint. This will be addressed in a future EdgeX 3.0 release.

- `HttpExportErrors` - **(New)** This is a **counter** metric that counts the number of errors encountered when exporting via HTTP. 

- `MqttExportSize  ` -  This is a **histogram** metric that collects the size of data exported via the built-in [MQTT Export pipeline function](../sdk/api/BuiltInPipelineFunctions.md#mqtt-export). The metric data is tagged with the specific broker address and topic.

- `MqttExportErrors` -  **(New)** This is a **counter** metric that counts the number of errors encountered when exporting via MQTT. 

- `PipelineMessagesProcessed` - This is a **counter** metric that counts the number of messages processed by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for.

- `PipelineProcessingErrors ` -  This is a **counter** metric that counts the number of errors returned by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for.

- `PipelineMessageProcessingTime` - This is a **timer** metric that tracks the amount of time taken to process messages by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the timer is for.

    !!! note
        The time tracked for this metric is only for the function pipeline processing time. The overhead of receiving the messages and handing them to the appropriate function pipelines is not included. Accounting for this overhead may be added as another **timer** metric in a future release.

Reporting of these built-in metrics is disabled by default in the `Writable.Telemetry` configuration section. See `Writable.Telemetry` configuration details in the [Application Service Configuration](../Configuration.md#writable) section for complete detail on this section. If the configuration for these built-in metrics are missing, then the reporting of the metrics will be disabled.

!!! example "Example - Service Telemetry Configuration with all built-in metrics enabled for reporting"
    ```yaml
    Writable:
      Telemetry:
        Interval: "30s"
        Metrics:
          MessagesReceived: true
          InvalidMessagesReceived: true
          PipelineMessagesProcessed: true 
          PipelineMessageProcessingTime: true
          PipelineProcessingErrors: true 
          HttpExportSize: true 
          HttpExportErrors: true
          MqttExportSize: true 
          MqttExportErrors: true 
        Tags: # Contains the service level tags to be attached to all the service's metrics
        Gateway: "my-iot-gateway" # Tag must be added here or via Consul Env Override can only change existing value, not added new ones.
    ```

See [Custom Service Metrics](../sdk/details/CustomServiceMetrics.md) page for details on creating addtional service metrics in a custom application service.