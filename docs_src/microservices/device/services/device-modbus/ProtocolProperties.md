---
title: Device Modbus - Protocol Properties
---

# Device Modbus - Protocol Properties

Device Modbus defines the following Protocol Properties for Modbus-TCP, Modbus-RTU and Modbus-ASCII.

- Modbus TCP Device
    - These properties reside under the `modbus-tcp` key in the `protocols` section of each device definition.

| Property                 | Description                                                                                                                                                                                                                                                                                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Address                  | The IP address or host name of Modbus TCP                                                                                                                                                                                                                                                                                                                    |
| Port                     | The port used for communication across Modbus TCP                                                                                                                                                                                                                                                                                                            |
| UnitID                   | The Modbus station or slave identifier                                                                                                                                                                                                                                                                                                                       |
| Timeout                  | The timeout when connecting or reading Device Modbus Service to device-modbus. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                                    |
| IdleTimeout              | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close) - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                              |
| LinkRecoveryTimeout      | Recovery timeout if tcp communication misbehaves - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                                                     |
| ProtocolRecoveryTimeout  | Recovery timeout if the protocol is malformed, e.g. wrong transaction ID - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                             |
| ConnectDelay             | Silent period after successful connection - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                                                            |
| SharedConnection         | Optional boolean, default false. When true, devices with the same Address and Port share one TCP connection across UnitIDs. |

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

**Sharing a TCP connection across UnitIDs**

Some Modbus TCP servers accept only one TCP connection. To access multiple UnitIDs
through such a server, enable `SharedConnection` on every device using that server.
When the property is omitted or set to `false`, each UnitID uses a separate TCP
connection.

Each device uses the same address and port and its own UnitID:

```yaml
protocols:
  modbus-tcp:
    Address: "192.0.2.10"
    Port: 502
    UnitID: 1
    SharedConnection: true
    IdleTimeout: -1
```

For each additional device, use the same `Address` and `Port` and a different
`UnitID`.

Set `IdleTimeout: -1` on every participating device to keep the connection open.
Enabling `SharedConnection` alone does not change the idle timeout behavior.

`Timeout`, `IdleTimeout`, `LinkRecoveryTimeout`, `ProtocolRecoveryTimeout`, and
`ConnectDelay` are taken from the first device that opens the shared session.
Use consistent settings across participating devices. A device with different
settings logs a warning and uses the existing session's settings.

Removing one UnitID does not close the connection while another UnitID still uses
it. Each unit client releases its reference to the shared connection once. The
connection closes when the last unit client is removed.

**Errors and reconnection**

A valid Modbus exception, such as "Illegal Data Address", leaves the shared
connection open. A transport failure or malformed protocol response resets the
socket; the next command reconnects through the same shared transport. The other
UnitID clients remain available. Local validation and value transformation errors
leave the connection intact.

**Changing or removing devices**

Device updates and removals are coordinated with commands already using that
device. Changing the endpoint or `SharedConnection` setting closes the old client
before the new configuration is used. Commands carrying stale connection settings,
or targeting a removed device, are rejected. Devices already present in metadata
are tracked when the service initializes.

**Stopping the device service**

A graceful stop rejects new commands and device changes, waits for admitted
operations to finish, and closes all shared transports. A forced stop cancels
queued commands and connection attempts. An in-flight network operation may still
run until its configured timeout. Once a shared transport is closed for shutdown,
it cannot reconnect.

- Modbus RTU Device
    - These properties reside under the `modbus-rtu` key in the `protocols` section of each device definition.

| Property                 | Description                                                                                                                                                                                                                                                                                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Address                  | The IP address or host name of Modbus RTU                                                                                                                                                                                                                                                                                                                    |
| UnitID                   | The Modbus station or slave identifier                                                                                                                                                                                                                                                                                                                       |
| BaudRate                 | The baud rate for a serial device, which must match for devices using the same address                                                                                                                                                                                                                                                                       |
| DataBits                 | The number of bits of data                                                                                                                                                                                                                                                                                                                                   |
| StopBits                 | The number of stop bits                                                                                                                                                                                                                                                                                                                                      |
| Parity                   | The parity value: N for no parity /E for even parity/ O for odd parity                                                                                                                                                                                                                                                                                       |
| Timeout                  | The timeout when connecting or reading Device Modbus Service to device-modbus. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                                    |
| IdleTimeout              | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close) - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                              |

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

| Property                 | Description                                                                                                                                                                                                                                                                                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Address                  | The IP address or host name of Modbus ASCII                                                                                                                                                                                                                                                                                                                  |
| UnitID                   | The Modbus station or slave identifier                                                                                                                                                                                                                                                                                                                       |
| BaudRate                 | The baud rate for a serial device, which must match for devices using the same address                                                                                                                                                                                                                                                                       |
| DataBits                 | The number of bits of data                                                                                                                                                                                                                                                                                                                                   |
| StopBits                 | The number of stop bits                                                                                                                                                                                                                                                                                                                                      |
| Parity                   | The parity value: N for no parity /E for even parity/ O for odd parity                                                                                                                                                                                                                                                                                       |
| Timeout                  | The timeout when connecting or reading Device Modbus Service to device-modbus. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                                                                    |
| IdleTimeout              | Idle timeout to close the connection (use 0 to dial for each request and negative value to never close) - default 0. It can be a number (floating point) in which case it is interpreted as seconds, or it can be a duration string such as "500ms", "2s" or "1.5m" representing milliseconds, seconds or minutes respectively.                              |

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
