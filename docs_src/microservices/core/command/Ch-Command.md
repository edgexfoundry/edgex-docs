# Command

![image](EdgeX_Command.png)

## Introduction

The command micro service (often called the command
and control micro service) enables the issuance of commands or actions to
[devices](../../../general/Definitions.md#device) on behalf of:

-   other micro services within EdgeX Foundry (for example, an [edge
    analytics](../../../general/Definitions.md#edge-analytics) or rules engine micro service)
-   other applications that may exist on the same system with EdgeX
    Foundry (for example, a management agent that needs to
    shutoff a sensor)
-   To any external system that needs to command those devices (for
    example, a cloud-based application that determined the need to
    modify the settings on a collection of devices)

The command micro service exposes the commands in a common, normalized
way to simplify communications with the devices. There are two types of commands that can be sent to a device.

- a GET command requests data from the device.  This is often used to request the latest sensor reading from the device.
- SET commands request to take action or [actuate](../../../general/Definitions.md#actuate) the device or to set some configuration on the device.

In most cases, GET commands are simple requests for the latest sensor reading from the device.  Therefore, the request is often parameter-less (requiring no parameters or body in the request).  SET commands require a request body where the body provides a key/value pair array of values used as parameters in the request (i.e. `{"additionalProp1": "string", "additionalProp2": "string"}`).

!!! edgey "EdgeX 2.1"
    v2.1 supports a new value type, `Object`, to present the structral value instead of encoding it as string for both SET and GET commands, for example, the SET command parameter might be `{"Location": {"latitude": 39.67872546666667, "longitude": -104.97710646666667}}`.

The command micro service gets its knowledge about the devices from the metadata service. The command service always relays commands (GET or SET) to the devices through the device service.  The command service never communicates directly to a device. Therefore, the command micro service is a proxy service for command or action requests from the north side of EdgeX (such as analytic or application services) to the protocol-specific device service and associated device.

While not currently part of its duties, the command service could provide a layer of protection around device.  Additional security could be added that would not allow unwarranted interaction with the devices (via device service).  The command service could also regulate the number of requests on a device do not overwhelm the device - perhaps even caching responses so as to avoid waking a device unless necessary.

## Data Model

![image](EdgeX_CoreCommandModel.png)

!!! edgey "EdgeX 2.0"
    While the general concepts of core command's GET/PUT requests are the same, the core command request/response models has changed significantly in EdgeX 2.0.  Consult the API documentation for details.

## Data Dictionary

=== "DeviceProfile"
    |Property|Description|
    |---|---|
    |Id|uniquely identifies the device, a UUID for example|
    |Description||
    |Name|Name for identifying a device|
    |Manufacturer| Manufacturer of the device|
    |Model|Model of the device|
    |Labels|Labels used to search for groups of profiles|
    |DeviceResources|deviceResource collection|
    |DeviceCommands|collect of deviceCommand|
=== "DeviceCoreCommand"
    |Property|Description|
    |---|---|
    |DeviceName|reference to a device by name|
    |ProfileName|reference to a device profile by name|
    |CoreCommands|array of core commands|
=== "CoreCommand"
    |Property|Description|
    |---|---|
    |Name||
    |Get|bool indicating a get command|
    |Set|bool indicating a set command|
    |Path||
    |Url||
    |Parameters|array of core command parameters|
=== "CoreCommandParameters"
    |Property|Description|
    |---|---|
    |ResourceName||
    |ValueType||

## High Level Interaction Diagrams

The two following High Level Diagrams show:

-   Issue a PUT command
-   Get a list of devices and the available commands

**Command PUT Request**

![image](EdgeX_CommandPutRequest.png)

**Request for Devices and Available Commands**

![image](EdgeX_CommandRequestForDevices.png)

## Configuration Properties

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration properties common to all services. Core Command no longer has any additional settings.

### V2 Configuration Migration Guide

Refer to the [Common Configuration Migration Guide](../../../configuration/V2MigrationCommonConfig) for details on migrating the common configuration sections such as `Service`.

## API Reference

[Core Command API Reference](../../../api/core/Ch-APICoreCommand.md)
