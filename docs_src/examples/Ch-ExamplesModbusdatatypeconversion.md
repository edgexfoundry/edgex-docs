# Modbus - Data Type Conversion

In use cases where the Device Resource uses an integer data type with a
float scale, precision can be lost following transformation.

For example, a Modbus device stores the temperature and humidity in an
INT16 data type with a float scale of 0.01. If the temperature is 26.53,
the read value is 2653. However, following transformation, the value is
26.

To avoid this scenario, the device resource data type must differ from
the value descriptor data type. This is achieved using the optional
`rawType` attribute in the device profile to define the binary data read
from the Modbus device, and a `value type` to indicate what data type
the user wants to receive.

If the `rawType` attribute exists, the Device Service parses the binary
data according to the defined `rawType`, then casts the value according
to the `value type` defined in the `properties` of the Device Resources
.

The following extract from a device profile defines the `rawType` as
INT16 and the `value type` as FLOAT32:
``` yaml
deviceResources:
  - name: "humidity"
    description: "The response value is the result of the original value multiplied by 100."
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "1", rawType: "INT16" }
    properties:
      value:
        { type: "FLOAT32", readWrite: "RW", scale: "0.01" }
      units:
        { type: "String", readWrite: "R", defaultValue: "%RH"}

  - name: "temperature"
    description: "The response value is the result of the original value multiplied by 100."
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "2", rawType: "INT16" }
    properties:
      value:
        { type: "FLOAT32", readWrite: "RW", scale: "0.01" }
      units:
        { type: "String", readWrite: "R", defaultValue: "degrees Celsius"}
```
## Read Command

A Read command is executed as follows:

1.  The Device Service executes the Read command to read binary data
2.  The binary reading data is parsed as an INT16 data type
3.  The integer value is cast to a FLOAT32 value

![Modbus Read Command](ModbusReadConversion.png)

## Write Command

A Write command is executed as follows:

1.  The Device Service cast the requested FLOAT32 value to an integer
    value
2.  The integer value is converted to binary data
3.  The Device Service executes the Write command

![Modbus Write Command](ModbusWriteConversion.png)

## When to Transform Data

You generally need to transform data when scaling readings between a
16-bit integer and a float value.

The following limitations apply:

-   `rawType` supports only INT16 and UINT16 data types
-   The corresponding `value type` must be FLOAT32 or FLOAT64

If an unsupported data type is defined for the `rawType` attribute, the
Device Service throws an exception similar to the following:

    Handler - execReadCmd: error for Device: Modbus-TCP-Device cmd: readAll, the raw type INT32 is not supported /api/v1/device/91f6430d-9268-43e3-88a6-19dbe7f98dad/readAll

### Supported Transformations

The supported transformations are as follows:

  
  |From `rawType`               |To `value type`|
  |---------------------------- |------------------------------------------|
  |INT16                        |FLOAT32|
  |INT16                        |FLOAT64|
  |UINT16                       |FLOAT32|
  |UINT16                       |FLOAT64|
