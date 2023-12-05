---
title: Device Modbus - Protocol Properties
---

# Device Modbus - Protocol Properties

Device Modbus defines the following Protocol Properties for Modbus-TCP and Modbus-RTU.

- Modbus TCP Device
    - These properties reside under the `modbus-tcp` key in the `protocols` section of each device definition.

| Property     | Description                                        |
|--------------|----------------------------------------------------|
| Address      | The IP address or host name of Modbus TCP          |
| Port         | The port used for communication across Modbus TCP  |
| UnitID       | The Modbus station or slave identifier             |
| Timeout      | The timeout when connecting or reading Device Modbus Service to device-modbus |
| IdleTimeout  | Idle timeout(seconds) to close the connection      |

!!! example - "Example Modbus TCP Protocol Properties"

    ```json
    "protocols": {
      "modbus-tcp": {
        "Address": "172.17.0.1",
        "Port": "1502",
        "UnitID": "1"
    }}
    ```
- Modbus RTU Device
    - These properties reside under the `modbus-rtu` key in the `protocols` section of each device definition.

| Property     | Description                                        |
|--------------|----------------------------------------------------|
| Address      | The IP address or host name of Modbus TCP          |
| UnitID       | The Modbus station or slave identifier             |
| BaudRate     | The baud rate for a serial device, which must match for devices using the same address |
| DataBits     | The number of bits of data                         |
| StopBits     | The number of stop bits                            |
| Parity       | The parity value: N for no parity /E for even parity/ O for odd parity |          
| Timeout      | The timeout when connecting or reading Device Modbus Service to device-modbus |
| IdleTimeout  | Idle timeout(seconds) to close the connection     |

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