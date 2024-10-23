---
title: Device Service SDK - Device System Events
---

# Device Service SDK - Device System Events

The Device Service SDK offers [APIs](./api/GoDeviceSDK/GoDeviceSDKAPI.md) for publishing device system events, which provide updates on various device processes.
A System Event DTO is published to the EdgeX MessageBus to provide updates on the status of the device (device discovery progress, profile scan progress, etc.).

When these processes are initiated, the SDK publishes a system event with a status of 0, indicating that the operation has started.
When the process finishes successfully, the SDK publishes a system event with a status of 100, indicating the process has been finished without issues. 
If an error occurs, the SDK reports a system event with a status of -1 to show failure.

!!! note
    SDK provides `PublishDeviceDiscoveryProgressSystemEvent` API, allowing the Device Service implementation to publish `discovery` system events that include the number of discovered devices.

## System Event DTO

!!! edgey - "EdgeX 4.0"
    System Event actions `discovery`, and `profilescan` are new in EdgeX 4.0

The System Event DTO for the Device Service SDK APIs has the following properties:

| Property  | Description                                                           | Value                                                                                |
| --------- |-----------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| Type      | Type of System Event                                                  | `device`                                                                             |
| Action    | System Event action                                                   | `discovery`, `profilescan`, or or any custom user-defined actions                    |
| Source    | Source of the System Event                                            | the name of the device service                                                       |
| Owner     | Owner of the data in the System Event                                 | the name of the device service that owns the device                                  |
| Details   | The data object representing the device's status or the event details | the progress percentage (0 to 100) in this case. A value of `-1` indicates an error. |
| Timestamp | Date and time of the System Event                                     | timestamp in nanoseconds                                                             |

!!! example - "Example Device System Event"
    An example decoded from base64 format for the `discovery` event payload:
    ```json
    {
      "apiVersion":"v3",
      "type":"device",
      "action":"discovery",
      "source":"device-simple",
      "owner":"device-simple",
      "tags":null,
      "details":{
        "requestId":"86302e94-89dc-4a65-91fa-c4f393733a87",
        "progress":0
      },
      "timestamp":1725867193294918132
    }
    ```

## Publish Topic

The Device System Events is published to the topic specified by the `MessageQueue.PublishTopicPrefix` configuration setting above, which has a default of `edgex/system-events`, plus the following data items, which are added to allow receivers to filter by subscription.

- source = [device service name]
- type = device
- action = discovery/profilescan
- owner = [device service name which owns the device]

!!! example - "Example Device System Event publish topics"
    ```
    edgex/system-events/device-simple/device/discovery/device-simple
    edgex/system-events/device-simple/device/profilescan/device-simple
    ```
