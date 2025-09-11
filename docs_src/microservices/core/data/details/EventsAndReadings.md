---
title: Core Data - Events and Readings
---

# Core Data - Events and Readings

## Events and Readings Overview

Data collected from sensors is marshalled into EdgeX event and reading objects (delivered as JSON objects or a binary object encoded as [CBOR](../../../../general/Definitions.md#cbor) to core data).
An event represents a collection of one or more sensor readings.  
The number of readings depend on the connected device/sensor.

An event must have at least one reading. 
Events are associated with a sensor or device – the “thing” that sensed the environment and produced the readings. 
Readings are a component of an event. Readings are a simple key/value pair  where the key ([ResourceName](../../../../general/Definitions.md#resource)) is the metric sensed and the value is the actual data sensed.  
A reading may include other bits of information to provide more context (for example, the data type of the value) for the users of that data.
Reading data can be consumed by data visualization systems, analytics tools, etc.

!!! example 
    The event coming from the “motor123” device has two readings (or sensed values). 
    The first reading indicates that the motor123 device reported the pressure of the motor was 1300 (the unit of measure might be something like PSI).
    
    ![image](EdgeX_Event-Reading.png)
    
    The value type property (shown as type above) on the reading lets the consumer of the information know that the value is an integer, base 64.  The second reading indicates that the motor123 device also reported the temperature of the motor was 120 at the same time it reported the pressure (perhaps in degrees Fahrenheit).

## Reading Aggregations

To support retrieval of aggregated reading values, a new query parameter `aggregateFunc` has been added to the Reading query APIs.
This enhancement allows standard SQL aggregate functions to be applied directly through the API, minimizing additional client-side processing and calculations.

The supported SQL aggregate functions follow the definitions outlined [here](https://www.w3schools.com/sql/sql_aggregate_functions.asp):

- `MIN()`
- `MAX()`
- `COUNT()`
- `SUM()`
- `AVG()`

!!! edgey - "EdgeX 4.1"
    `aggregateFunc` query parameter was introduced in EdgeX 4.1

### Example Usage

Example request to the Core Data – Get All Readings API with `aggregateFunc`:

- Request:
    ``` shell
        curl http://<core-data-microservice-ip>:59880/api/v3/reading/all?aggregateFunc=MAX
    ```

- Response:
    ``` shell
    {
        "apiVersion": "v3",
        "statusCode": 200,
        "aggregateFunc": "MAX",
        "readings": [
            {
                "deviceName": "Test-Device",
                "resourceName": "Int16",
                "profileName": "Test-Device-Profile",
                "valueType": "Int64",
                "value": 32767
            },
            {
                "deviceName": "Test-Device",
                "resourceName": "Float32",
                "profileName": "Test-Device-Profile",
                "valueType": "Float64",
                "value": 79.123456
            }
        ]
    }
    ```

For more details about the `aggregateFunc` parameter, see the [Core Data API documentation](../../../../api/core/Ch-APICoredata.md).

!!! Note Info
    - `Aggregation` applies only to fields stored as `numeric` types in the database. See [Numeric Data Type Support](../../../general/database/Ch-Postgres.md#numeric-data-type-support) for more details.
    - The aggregate reading `value` is always represented as a numeric type rather than a string.
    - For non-numeric value types (e.g., String, Bool), the aggregate result will be empty. 

!!! Note Info
    The `valueType` of an aggregated reading may differ from the original `valueType` defined in the device profile, depending on the aggregate function used:

    - `COUNT()`: always returns a __Uint64__.
    - `AVG()`: always returns a __Float64__.
    - `SUM()`, `MIN()`, `MAX()`: 
        - If the original type is Float32 or Float64, the result is __Float64__.
        - If the original type is Int8, Int16, Int32 or Int64, the result is __Int64__.
        - If the original type is Uint8, Uint16, Uint32 or Uint64, the result is __Uint64__.
