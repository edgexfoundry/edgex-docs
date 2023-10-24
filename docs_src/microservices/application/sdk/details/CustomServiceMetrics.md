---
title: App SDK - Custom Service Metrics
---

# App Functions SDK - Custom Service Metrics

The Custom Service Metrics capability allows for custom application services to define, collect and report their own custom service metrics.

 The following are the steps to collect and report custom service metrics:

1. Determine the metric type that needs to be collected
    - `counter` - Track the integer count of something
    - `gauge` - Track the integer value of something  
    - `gaugeFloat64` - Track the float64 value of something 
    - `timer` - Track the time it takes to accomplish a task
    - `histogram` - Track the integer value variance of something
    
2. Create instance of the metric type from `github.com/rcrowley/go-metrics`
    - `myCounter = gometrics.NewCounter()`
    - `myGauge = gometrics.NewGauge()`
    - `myGaugeFloat64 = gometrics.NewGaugeFloat64()`
    - `myTimer = gometrics.NewTime()`
    - `myHistogram = gometrics.NewHistogram(gometrics.NewUniformSample(<reservoir size))`
    
3. Determine if there are any tags to report along with your metric. Not common so `nil` is typically passed for the `tags map[strings]string` parameter in the next step.

4. Register your metric(s) with the MetricsManager from the `service` or `pipeline function context` reference. See [Application Service API](../api/ApplicationServiceAPI.md#metricsmanager) and [App Function Context API](../api/AppFunctionContextAPI.md#metricsmanager) for more details:
    - `service.MetricsManager().Register("MyCounterName", myCounter, nil)`
    - `ctx.MetricsManager().Register("MyCounterName", myCounter, nil)`

5. Collect the metric
    - `myCounter.Inc(someIntvalue)`
    - `myCounter.Dec(someIntvalue)`
    - `myGauge.Update(someIntvalue)`
    - `myGaugeFloat64.Update(someFloatvalue)`
    - `myTimer.Update(someDuration)`
    - `myTimer.Time(func { do sometime})`
    - `myTimer.UpdateSince(someTimeValue)`
    - `myHistogram.Update(someIntvalue)`
    
6. Configure reporting of the service's metrics. See `Writable.Telemetry` configuration details in the [Application Service Configuration](../../Configuration.md#writable) section for more detail.

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