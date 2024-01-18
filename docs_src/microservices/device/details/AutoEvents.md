---
title: Device Service - Auto Events
---

# Device Service - Auto Events
## Concept
![image](Auto_Events.png)
In the Operational Technology (OT) working field, there's a need to check/menitor the status of the actual device/sensor, for example, when the temperature reaches 30°C, the Air Conditioner will turn on itself. However, it is time-consuming to check sensor's status manually so edgex provides this functionality called <code>AutoEvents</code> to check their statuses automatically and periodically.

From the diagram above, <code>Autoevents</code> is used to define how often events/readings are collected to be sent to core data from the device service. This is an optional feature when creating a deviceso each device may or may not have multiple autoevents associated with it. An AutoEvent has the following fields:

- **resource**: the name of a deviceResource or deviceCommand indicating what to read.
- **frequency**: a string indicating the time to wait between reading events, expressed as an integer followed by units of ms, s, m or h.
- **onchange**: a boolean: if set to true, only generate new events if one or more of the contained readings has changed since the last event.

## Example and Usage

The AutoEvent is defined in the `autoEvents` section of the device definition file:
After service startup, query core-data's API. The results show that the service auto-executes the command every 30 seconds.

```yaml
deviceList:
  autoEvents:
    interval: "30s"
    onChange: false
    sourceName: "Temperature"
```
