---
title: Device MQTT - Protocol Properties
---

# Device MQTT - Protocol Properties

This service defines the following Protocol Properties for each defined device that supports 2-way communications.  These properties reside under the `mqtt` key in the `protocols` section of each device definition.

| Property     | Description                                        |
|--------------|----------------------------------------------------|
| CommandTopic | Base MQTT topic for sending commands to the device |

!!! Note
    These Protocol Properties are not used/needed for MQTT devices if the data is sent asynchronously.

!!! example - "Example MQTT Protocol Properties"

    ```yaml
    protocols:
      mqtt:
       CommandTopic: "command/MQTT-test-device"
    ```

For more information on Commands see [Commanding](details/MultiLevelTopics.md#commanding).