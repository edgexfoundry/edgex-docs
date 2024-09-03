---
title: Core Metadata - Device System Events
---

# Core Metadata - Device System Events

System Events are events triggered by the add, update or delete of device metadata objects (Device, DeviceProfile, etc.). A System Event DTO is published to the EdgeX MessageBus each time a new object is added, an existing object is updated or when an existing objects is deleted.

## System Event DTO

!!! edgey - "Edgex 3.0"
    System Event types `deviceservice`, `deviceprofile` and `provisionwatcher` are new in EdgeX 3.0

The System Event DTO has the following properties:

| Property  | Description                                   | Value                                                        |
| --------- | --------------------------------------------- | ------------------------------------------------------------ |
| Type      | Type of System Event                          | `device`, `deviceservice`,  `deviceprofile`, or `provisionwatcher`                                       |
| Action    | System Event action                           | `add`, `update`, or `delete` in this case                    |
| Source    | Source of the System Event                    | `core-metadata` in this case                                 |
| Owner     | Owner of the data in the System Event         | In this case it is the name of the device service that owns the device or `core-metadata` |
| Tags      | Key value map of additional data              | empty in this case                                           |
| Details   | The data object that trigger the System Event | the added, updated, or deleted Device/Device Profile/Device Service/Provision Watcher in this case           |
| Timestamp | Date and time of the System Event             | timestamp in nanoseconds                                     |

## Publish Topic

The System Event DTO for Device System Events is published to the topic specified by the `MessageQueue.PublishTopicPrefix` configuration setting  above, which has a default of `edgex/system-events`, plus the following data items, which are added to allow receivers to filter by subscription.

- source = core-metadata
- type = device
- action = add/update/delete
- owner = [device service name which owns the device]
- profile = [device profile name associated with the device]

!!! example - "Example Device System Event publish topics"
    ```
    edgex/system-events/core-metadata/device/add/device-onvif-camera/onvif-camera
    edgex/system-events/core-metadata/device/update/device-rest/sample-numeric
    edgex/system-events/core-metadata/device/delete/device-virtual/Random-Boolean-Device
    ```
