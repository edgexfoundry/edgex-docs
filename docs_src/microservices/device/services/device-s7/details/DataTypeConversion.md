# Device S7 - Data Type Conversion

In use cases where the S7 device resource uses a `WORD` data type with a `Int16` number, a `WORD` has two bytes, should converts to a integer.

The following extract from a device profile defines the `NodeName` DB4.DBW2 as `valueType` Int16:

!!! example "Example - Device Profile"
    ```yaml
    name: S7-Device
    manufacturer: YIQISOFT
    description: Example of S7 Device
    model: Siemens S7
    labels: [ISO-on-TCP]
    deviceResources:
        - name: word
        description: PLC word
        isHidden: false
        properties:
            valueType: Int16
            readWrite: RW
        attributes:
            NodeName: DB4.DBW2
    ```

## Read Command

A Read Command is executed as follows:

1. The Client executes a Read Command;
1. The device service sends the Read Command to read a `WORD` data;
1. The S7 Device returns a two byte data;
1. The device service parses the data;
1. The device service cast the data to a Int16 value;
1. The device service returns returns json format to the Client.

![data type conversion read](./s7_data_type_conersion_read.png)

[commnet]: <> (```mermaid)
[commnet]: <> (graph LR)
[commnet]: <> (  A[Client] -->|1. Execute Read Command| B[Device Service])
[commnet]: <> (  B -->|2. Send Request - WORD| C[S7 Device])
[commnet]: <> (  C -->|3. Return 2 bytes| B)
[commnet]: <> (  B -->|4. Parse bytes| B)
[commnet]: <> (  B -->|5. Cast to Int16| B)
[commnet]: <> (  B -->|6. Return json| A)
[commnet]: <> (```)

## Write Command

A Write Command is executed as follows:

1. The Client executes a Write Command to write a In16 value;
1. The device service cast Int16 value to a two bytes;
1. The device service convert to binary;
1. The device service send write a request to the S7 device;
1. The device service returns result json to the Client.

![data type conversion write](./s7_data_type_conersion_write.png)

[commnet]: <> (```mermaid)
[commnet]: <> (graph LR)
[commnet]: <> (  A[Client] -->|1. Execute Write Command| B[Device Service])
[commnet]: <> (  B -->|2. Cast to Int16| B)
[commnet]: <> (  B -->|3. Convert to binary| B)
[commnet]: <> (  B -->|4. Send Request - WORD| C[S7 Device])
[commnet]: <> (  B -->|5. Return json| A)
[commnet]: <> (```)

## When to Transform Data

You generally need to transform data in any time, because S7 devive only receives its particular data type.

## Supported Transformations

The supported transformations are as follows:

| From `NodeName` | Bit(s) | To `valueType` | Address Sample |
| --------------- | ------ | -------------- | -------------- |
| Bool            | 1      | Bool           | DB1.DBX0.0     |
| Byte            | 8      | Uint           | DB1.DBB1       |
| Word            | 16     | Int16          | DB1.DBW2       |
| DWord           | 32     | Int32          | DB1.DBD4       |
| Int             | 16     | Int16          | DB1.DBW6       |
| DInt            | 32     | Int32          | DB1.DBD8       |
| Real            | 32     | Float32        | DB1.DBD20      |
