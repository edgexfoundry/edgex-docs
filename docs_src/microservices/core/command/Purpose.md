---
title: Core Command - Purpose
---

# Core Command - Purpose

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

The command micro service gets its knowledge about the devices from the metadata service. The command service always relays commands (GET or SET) to the devices through the device service.  The command service never communicates directly to a device. Therefore, the command micro service is a proxy service for command or action requests from the north side of EdgeX (such as analytic or application services) to the protocol-specific device service and associated device.

While not currently part of its duties, the command service could provide a layer of protection around device.  Additional security could be added that would not allow unwarranted interaction with the devices (via device service).  The command service could also regulate the number of requests on a device do not overwhelm the device - perhaps even caching responses so as to avoid waking a device unless necessary.