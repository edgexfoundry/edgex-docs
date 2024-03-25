# Device S7 - Protocol Properties

Device S7 defines the following Protocol Properties for ISO-on-TCP.

These properties reside under the `s7` key in the protocols section of each device definition.

| Properity   | Default value | Note                                |
| ----------- | ------------- | ----------------------------------- |
| Host        | N/A           | S7 ip address, e.g. 192.168.123.199 |
| Port        | N/A           | S7 port, e.g. 102                   |
| Rack        | N/A           | Rack number, e.g. 0                 |
| Slot        | N/A           | Slot number, e.g. 1                 |
| Timeout     | 30            | connect to S7 timeout, seconds      |
| IdleTimeout | 30            | connection idle timeout, seconds    |

!!! example "Example S7 Protocol Properties"
    ```json
    ...
    "protocols": {
        "s7": {
            "Host": "192.168.123.199",
            "Port": 102,
            "Rack": 0,
            "Slot": 1,
            "Timeout": 30,
            "IdleTimeout": 30
        }
    }
    ...
    ```
