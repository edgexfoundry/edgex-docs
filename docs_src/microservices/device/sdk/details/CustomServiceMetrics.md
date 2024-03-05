---
title: Device Service SDK - Go Services Metrics
---

# Device Service SDK - Go Services Metrics

### Built-In

The following built-in device service metrics are collected by the Device SDK

1. **EventSent** - Number of Events that have been sent from the Device Service
2. **ReadingsSent** - Number of Reading that have been sent from the Device Service 
3. **Common Metrics** - Set of service metrics common to all EdgeX Services. See Common Service Metrics(Link TBD) for list of all these metrics.

See [Device Service Configuration Properties](../../../device/Configuration.md) for detail on configuring device service metrics

### Custom

The Custom Device Service Metrics capability allows for device service developers to define, collect and report their own service metrics beyond the common built-in service metrics supplied by the Device SDK. 

The following are the steps to collect and report service metrics:

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

4. Register your metric(s) with the MetricsManager from the `sdk`reference. See [Device SDK API](../../sdk/api/GoDeviceSDK/GoDeviceSDKAPI.md) for more details:

   - `service.MetricsManager().Register("MyCounterName", myCounter, nil)`

5. Collect the metric
    - `myCounter.Inc(someIntvalue)`
    - `myCounter.Dec(someIntvalue)`
    - `myGauge.Update(someIntvalue)`
    - `myGaugeFloat64.Update(someFloatvalue)`
    - `myTimer.Update(someDuration)`
    - `myTimer.Time(func { do sometime})`
    - `myTimer.UpdateSince(someTimeValue)`
    - `myHistogram.Update(someIntvalue)`

6. Configure reporting of the service's metrics. See `Writable.Telemetry` configuration details in the [Common Configuration](../../../configuration/CommonConfiguration.md) section for more detail.

!!! example "Example - Service Telemetry Configuration"
    ```yaml
    Writable:
      Telemetry
        Interval: "30s"
        Metrics: # All service's metric names must be present in this list.
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
