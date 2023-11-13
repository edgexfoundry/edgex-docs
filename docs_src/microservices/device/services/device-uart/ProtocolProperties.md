---
title: Device UART - Protocol Properties
---

# Device UART - Protocol Properties

This service defines the following Protocol Properties for each defined UART device.  These properties reside under the `UART` key in the `protocols` section of each device definition.

| Property       | Description                                                              |
|----------------|--------------------------------------------------------------------------|
| deviceLocation | Linux path to the device                                                 |
| baudRate       | Rate information is transferred (bits/second) |

!!! example - "Example UART Protocol Properties"

    ```yaml
        protocols:
          UART:
            deviceLocation: "/dev/ttyAMA2"
            baudRate: 115200
    ```