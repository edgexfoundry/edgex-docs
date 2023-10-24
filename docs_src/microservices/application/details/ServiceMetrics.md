---
title: App Services - Service Metrics
---

# Application Services - Service Metrics

All application services have the following built-in metrics:

| Metric Name                   | Type      | Description                                                  |
| ----------------------------- | --------- | ------------------------------------------------------------ |
| MessagesReceived              | counter   | Counts the number of messages received by the application service. Includes invalid messages |
| InvalidMessagesReceived       | counter   | Counts the number of invalid messages received by the application service |
| HttpExportSize                | histogram | Collects the size of data exported via the built-in [HTTP Export pipeline function](../sdk/api/BuiltInPipelineFunctions.md#http-export). The metric data is tagged with the specific URL. |
| HttpExportErrors              | counter   | Counts the number of errors encountered when exporting via HTTP.  The metric data is tagged with the specific URL. |
| MqttExportSize                | histogram | Collects the size of data exported via the built-in [MQTT Export pipeline function](../sdk/api/BuiltInPipelineFunctions.md#mqtt-export). The metric data is tagged with the specific broker address and topic. |
| MqttExportErrors              | counter   | Counts the number of errors encountered when exporting via MQTT. The metric data is tagged with the specific broker address and topic. |
| PipelineMessagesProcessed     | counter   | Counts the number of messages processed by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for. |
| PipelineProcessingErrors      | counter   | Counts the number of errors returned by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for. |
| PipelineMessageProcessingTime | timer     | Tracks the amount of time taken to process messages by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the timer is for. The time tracked for this metric is only for the function pipeline processing time. The overhead of receiving the messages and handing them to the appropriate function pipelines is not included. Accounting for this overhead may be added as another **timer** metric in a future release. |

!!! edgey - "Edgex 3.1"
    HttpExportErrors & MqttExportErrors metrics are new in EdgeX 3.1

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

See [Custom Service Metrics](../sdk/details/CustomServiceMetrics.md) page for details on creating additional service metrics in a custom application service.