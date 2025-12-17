---
title: Device Modbus - Protocol Properties
---

# Device Modbus - Protocol Properties

Device Modbus defines the following Protocol Properties for Modbus-TCP, Modbus-RTU and Modbus-ASCII.

- Modbus TCP Device
    - These properties reside under the `modbus-tcp` key in the `protocols` section of each device definition.

| Property                 | Description                                                                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Address                  | The IP address or host name of Modbus TCP                                                                                                        |
| Port                     | The port used for communication across Modbus TCP                                                                                                |
| UnitID                   | The Modbus station or slave identifier                                                                                                           |
| Timeout                  | The timeout when connecting or reading Device Modbus Service to device-modbus                                                                    |
| IdleTimeout              | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close) - default 0                              |
| LinkRecoveryTimeout      | Recovery timeout if tcp communication misbehaves - default 0                                                                                     |
| ProtocolRecoveryTimeout  | Recovery timeout if the protocol is malformed, e.g. wrong transaction ID - default 0                                                             |
| ConnectDelay             | Silent period after successful connection - default 0                                                                                            |

!!! example - "Example Modbus TCP Protocol Properties"

```json
"protocols": {
  "modbus-tcp": {
    "Address": "172.17.0.1",
    "Port": "1502",
    "UnitID": "1",
    "Timeout": "5s"
}}
```

> **_NOTE:_** About the timeout values: It can be a number (floating point) in which case it is interpreted as seconds. Or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.

- Modbus RTU Device
    - These properties reside under the `modbus-rtu` key in the `protocols` section of each device definition.

| Property                 | Description                                                                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Address                  | The IP address or host name of Modbus RTU                                                                                                        |
| UnitID                   | The Modbus station or slave identifier                                                                                                           |
| BaudRate                 | The baud rate for a serial device, which must match for devices using the same address                                                           |
| DataBits                 | The number of bits of data                                                                                                                       |
| StopBits                 | The number of stop bits                                                                                                                          |
| Parity                   | The parity value: N for no parity /E for even parity/ O for odd parity                                                                           |          
| Timeout                  | The timeout when connecting or reading Device Modbus Service to device-modbus                                                                    |
| IdleTimeout              | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close)                                          |

!!! example - "Example Modbus RTU Protocol Properties"

```json
"protocols": {
  "modbus-rtu": {
    "Address": "/dev/virtualport",
    "BaudRate": "19200",
    "DataBits": "8",
    "Parity": "N",
    "StopBits": "1",
    "UnitID": "1"
}}
```
- Modbus ASCII Device
  - These properties reside under the `modbus-ascii` key in the `protocols` section of each device definition.

| Property     | Description                                                                                                                                      |
|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Address      | The IP address or host name of Modbus ASCII                                                                                                      |
| UnitID       | The Modbus station or slave identifier                                                                                                           |
| BaudRate     | The baud rate for a serial device, which must match for devices using the same address                                                           |
| DataBits     | The number of bits of data                                                                                                                       |
| StopBits     | The number of stop bits                                                                                                                          |
| Parity       | The parity value: N for no parity /E for even parity/ O for odd parity                                                                           |
| Timeout      | The timeout when connecting or reading Device Modbus Service to device-modbus                                                                    |
| IdleTimeout  | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close)                                          |

!!! example - "Example Modbus ASCII Protocol Properties"

```json
"protocols": {
  "modbus-ascii": {
    "Address": "/dev/virtualport",
    "BaudRate": "19200",
    "DataBits": "8",
    "Parity": "N",
    "StopBits": "1",
    "UnitID": "1"
}}
```