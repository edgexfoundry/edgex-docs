---
title: Device OPC-UA - Protocol Properties
---

# Device OPC-UA - Protocol Properties

Device OPC-UA defines the following Protocol Properties for `opcua`.

These properties reside under the `opcua` key in the protocols section of each device definition.

| Property   | Description                                                                                                      |
| ---------- | ---------------------------------------------------------------------------------------------------------------- |
| Endpoint   | The `Connection Address(UA TCP)` of OPC-UA server. Required.                                                     |
| Policy     | Optional security policy for this device. When omitted, `OPCUAServer.Policy` is used.                            |
| Mode       | Optional security mode for this device. When omitted, `OPCUAServer.Mode` is used.                                |
| SecretName | Optional secret-store name. The secret keys are `username` and `password`. When omitted, the session is anonymous. |

!!! example "Example opcua Protocol Properties"

    ```yaml
    ...
        protocols:
          opcua:
            Endpoint: "opc.tcp://jiekemacbookpro14.lan:53530/OPCUA/SimulationServer"
            Policy: "Basic256Sha256"
            Mode: "SignAndEncrypt"
            SecretName: "opcua/simulation"
    ```

`Policy` or `Mode` other than `None` requires `OPCUAServer.CertFile` and `OPCUAServer.KeyFile`.
Do not put the password in the device definition. Store it with `POST /api/v3/secret` on this device service.
Devices that use the same endpoint, policy, mode, and secret name share one OPC UA session.
The session closes when the last of those devices is removed, and when the service stops.
