---
title: App SDK - Custom Service Metrics
---

# App Functions SDK for Python - Custom Service Metrics

The Custom Service Metrics capability allows for custom application services to define, collect and report their own custom service metrics.

 The following are the steps to collect and report custom service metrics:

1. Determine the metric type that needs to be collected
    - `counter` - Track the integer count of something
    - `gauge` - Track the integer value of something  
    - `gaugeFloat64` - Track the float64 value of something 
    - `timer` - Track the time it takes to accomplish a task
    - `histogram` - Track the integer value variance of something
    
2. Create instance of the metric type from `github.com/Lightricks/pyformance` and `app_functions_sdk_py.bootstrap.metrics`:
    - `myCounter = meters.Counter("")`
    - `myGauge = meters.SimpleGauge("")`
    - `myGaugeFloat64 = GaugeFloat64("")`
    - `myTimer = meters.Timer("")`
    - `myHistogram = meters.Histogram("", sample=UniformSample(<reservoir size>))`

    !!! note
        The `key` parameter in the above metric type constructors does not have any significance in the context of EdgeX.
        The MetricsReporter implementation in the App Functions SDK for Python uses the metric name provided during metric registration to report the metric.

    !!! note
        `gaugeFloat64` is an extended metric type as implemented by app_functions_sdk_py to support float64 values.
    
3. Determine if there are any tags to report along with your metric. Not common so `None` is typically passed for the `tags Optional[dict]` parameter in the next step.

4. Register your metric(s) with the MetricsManager from the `service` or `pipeline function context` reference. See [Application Service API](../api/ApplicationServiceAPI.md#metricsmanager) and [App Function Context API](../api/AppFunctionContextAPI.md#metrics_manager) for more details:
    - `service.metrics_manager().register("MyCounterName", myCounter, None)`
    - `ctx.metrics_manager().register("MyCounterName", myCounter, None)`

5. Collect the metric
    - `myCounter.inc(someIntvalue)`
    - `myCounter.dec(someIntvalue)`
    - `myGauge.set_value(someIntvalue)`
    - `myGaugeFloat64.set_value(someFloatvalue)`
    - `myTimer.time()` - time() returns a timer context instance that will time the block of code within the `with` statement.
    - `myHistogram.add(someIntvalue)`
    
6. Configure reporting of the service's metrics. See `Writable.Telemetry` configuration details in the [Application Service Configuration](https://docs.edgexfoundry.org/3.1/microservices/application/Configuration/#writable) section for more detail.

    !!! example "Example - Service Telemetry Configuration"
        ```yaml
        Writable:
          Telemetry:
            Interval: "30s"
            Metrics:
              MyCounterName: true
              MyGaugeName: true
              MyGaugeFloat64Name: true
              MyTimerName: true
              MyHistogram: true
            Tags: # Contains the service level tags to be attached to all the service's metrics
              Gateway: "my-iot-gateway" # Tag must be added here or via Consul Env Override can only change existing value, not added new ones.
        ```
    
    !!! note
        The metric names used in the above configuration (to enable or disable reporting of a metric) must match the metric name used when the metric is registered. A partial match of starts with is acceptable, i.e. the metric name registered starts with the above configured name.
