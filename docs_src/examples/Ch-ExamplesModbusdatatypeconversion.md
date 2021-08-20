# Modbus - Data Type Conversion

In use cases where the device resource uses an integer data type with a
float scale, precision can be lost following transformation.

For example, a Modbus device stores the temperature and humidity in an
Int16 data type with a float scale of 0.01. If the temperature is 26.53,
the read value is 2653. However, following transformation, the value is 26.

To avoid this scenario, the device resource data type must differ from
the value descriptor data type. This is achieved using the optional
`rawType` attribute in the device profile to define the binary data read
from the Modbus device, and a `valueType` to indicate what data type
the user wants to receive.

If the `rawType` attribute exists, the device service parses the binary
data according to the defined `rawType`, then casts the value according
to the `valueType` defined in the `properties` of the device resources.

The following extract from a device profile defines the `rawType` as
Int16 and the `valueType` as Float32:

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the device profile has many changes. Please see [Device Profile](../microservices/device/profile/Ch-DeviceProfile.md) section for more details.

!!! example "Example - Device Profile"

    ``` yaml
    deviceResources:
      - name: "humidity"
        description: "The response value is the result of the original value multiplied by 100."
        attributes:
          { primaryTable: "HOLDING_REGISTERS", startingAddress: "1", rawType: "Int16" }
        properties:
          valueType: "Float32"
          readWrite: "R"
          scale: "0.01"
          units: "%RH"
    
      - name: "temperature"
        description: "The response value is the result of the original value multiplied by 100."
        attributes:
          { primaryTable: "HOLDING_REGISTERS", startingAddress: "2", rawType: "Int16" }
        properties:
          valueType: "Float32"
          readWrite: "R"
          scale: "0.01"
          units: "degrees Celsius"
    ```
## Read Command

A Read command is executed as follows:

1.  The device service executes the Read command to read binary data
2.  The binary reading data is parsed as an Int16 data type
3.  The integer value is cast to a Float32 value

![Modbus Read Command](ModbusReadConversion.png)

## Write Command

A Write command is executed as follows:

1.  The device service cast the requested Float32 value to an integer
    value
2.  The integer value is converted to binary data
3.  The device service executes the Write command

![Modbus Write Command](ModbusWriteConversion.png)

## When to Transform Data

You generally need to transform data when scaling readings between a
16-bit integer and a float value.

The following limitations apply:

-  `rawType` supports only Int16 and Uint16 data types
-  The corresponding `valueType` must be Float32 or Float64

If an unsupported data type is defined for the `rawType` attribute, the
device service throws an exception similar to the following:

```
Read command failed. Cmd:temperature err:the raw type Int32 is not supported
```

## Supported Transformations

The supported transformations are as follows:
  
  |From `rawType`               |To `valueType`|
  |---------------------------- |------------------------------------------|
  |Int16                        |Float32|
  |Int16                        |Float64|
  |Uint16                       |Float32|
  |Uint16                       |Float64|
