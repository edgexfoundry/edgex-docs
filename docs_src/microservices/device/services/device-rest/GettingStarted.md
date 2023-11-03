---
title: Device REST - Getting Started
---

# Device REST - Getting Started

## Running Service

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty ds-rest
    ```

This runs, in non-secure mode, all the standard EdgeX services along with the Device Rest service.

## Sample Device Profiles

The service contains the following sample Device Profiles as examples. 
This is where `Device Resources` and `Device Commands` are defined.

| Name                                                                                                                                               | Description                                                  |
|----------------------------------------------------------------------------------------------------------------------------------------------------| ------------------------------------------------------------ |
| [sample-numeric-device.yaml](https://github.com/edgexfoundry/device-rest-go/blob/{{edgexversion}}/cmd/res/profiles/sample-numeric-device.yaml)     | Example of device type which can POST values for numeric resources |
| [sample-json-device.yaml](https://github.com/edgexfoundry/device-rest-go/blob/{{edgexversion}}/cmd/res/profiles/sample-json-device.yaml)           | Example of device type which can POST values for object resources |
| [sample-image-device.yaml](https://github.com/edgexfoundry/device-rest-go/blob/{{edgexversion}}/cmd/res/profiles/sample-image-device.yaml)         | Example of device type which can POST values for image resources |
| [sample-2way-rest-device.yaml](https://github.com/edgexfoundry/device-rest-go/blob/{{edgexversion}}/cmd/res/profiles/sample-2way-rest-device.yaml) | Example of device type which supports commanding to read and set resources |

Use these samples to determine the best way to module your REST device with a new Device Profile. 
Also see the [Device Profiles](../../details/DeviceProfiles.md) section for more details about Device Profiles.

## Sample Devices

The service contains the [sample-devices.yaml](https://github.com/edgexfoundry/device-rest-go/blob/{{edgexversion}}/cmd/res/devices/sample-devices.yaml) devices as examples of device instances for the above Device Profiles.

This is where device instances are statically defined. Use these samples to determine the best way to define your 
REST Device instances.
Also see the [Device Definitions](../../details/DeviceProfiles.md) section for more details about Device Definitions.

## REST Endpoints

### Async

This device service creates the additional parametrized `REST` endpoint to receive async data.
See [API Reference](ApiReference.md) for additional details. End devices will push async data to this endpoint.

The data, `text` or `binary`,  posted to this endpoint is type validated and type cast (text data only) to the type defined by the specified `device resource`. 
The resulting value is then sent into EdgeX via the Device SDK's `async values` channel.

!!! note
    When binary data is used the EdgeX event/reading is `CBOR` encoded by the `Device SDK` and the binary value in the reading is`NOT` be stored in the database by `Core Data`. The `CBOR` encoded event/reading, with the binary value, is published to the `Message Bus` for `Application Services` to consume.

!!! note
    All non-binary data is consumed as text. The text is cast to the specific type of the specified `device resource` once it passes type validation.

See the [Async Testing](howto/Testing.md#async) section for example on sending async data to this service

### Device Commands

Device Commands received by this service are forwarded to the end device for processing. 
See then [Device Commands](../../details/DeviceCommands.md) section for details on Device Commands.

This device service reads the end device protocol parameters from the device's protocol properties to construct the URI in which to call on the end device.

!!! example - "Example REST protocol parameters found in definition"
    ```yaml
        protocols:
          REST:
            Host: 127.0.0.1
            Port: '5000'
            Path: api
    ```

The `commandName` is appended to the `Path` parameter (in example above) to construct the desired endpoint on the end device.

A GET command sends a new http GET request to the end device. The response received from end device is type validated and sent as the response to the GET command.

A SET command sends a new http PUT request to the end device containing the body from the received SET command. The end device response status code is sent in response to the SET command.

## AutoEvents

Auto events are supported for  resources on end devices that support commanding.
See [AutoEvents](../../details/AutoEvents.md) section for more details on enabling and using AutoEvents.
