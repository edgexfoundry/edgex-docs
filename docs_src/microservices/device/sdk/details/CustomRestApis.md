---
title: Device Service - Custom REST APIs
---

# Device Service - Custom REST APIs

All device services have the following built-in metrics:

| Metric Name                   | Type      | Description                                                  |
| ----------------------------- | --------- | ------------------------------------------------------------ |
| EventsSent                    | bool      | Enable/disable reporting of the built-in **EventsSent** metric |
| ReadingsSent                  | bool      | Enable/disable reporting of the built-in **ReadingsSent** metric |
| LastConnected                 | bool      | Enable/disable reporting of the built-in **LastConnected** metric|
| <CustomMetric>                | bool      | Enable/disable reporting of custom device service's custom metric. See Custom Device Service Metrics for more details. |

See [Custom Service Metrics](../sdk/details/CustomServiceMetrics.md) page for details on creating additional service metrics in a custom device service.
