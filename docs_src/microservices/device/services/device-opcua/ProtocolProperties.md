---
title: Device OPC-UA - Protocol Properties
---

# Device OPC-UA - Protocol Properties

Device OPC-UA defines the following Protocol Properties for `opcua`.

These properties reside under the `opcua` key in the protocols section of each device definition.

| Property | Description                                       |
| -------- | ------------------------------------------------- |
| Endpoint | The `Connection Address(UA TCP)` of OPC-UA server |

!!! example "Example opcua Protocol Properties"

    ```yaml
    ...
        protocols:
        opcua:
            Endpoint: "opc.tcp://jiekemacbookpro14.lan:53530/OPCUA/SimulationServer"
    ```
