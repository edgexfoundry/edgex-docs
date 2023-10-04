# Core Data

## Events and Readings

Data collected from sensors is marshalled into EdgeX event and reading objects (delivered as JSON objects or a binary object encoded as [CBOR](../../../general/Definitions.md#cbor) to core data).
An event represents a collection of one or more sensor readings.  
The number of readings depends on the connected device/sensor.

An event must have at least one reading. 
Events are associated with a sensor or device – the “thing” that sensed the environment and produced the readings. 
Readings are a component an event. Readings are a simple key/value pair  where the key ([ResourceName](../../../general/Definitions.md#resource)) is the metric sensed and the value is the actual data sensed.  
A reading may include other bits of information to provide more context (for example, the data type of the value) for the users of that data.
Consumers of the reading data could include things like user interfaces, data visualization systems and analytics tools.

!!! example 
    The event coming from the “motor123” device has two readings (or sensed values). 
    The first reading indicates that the motor123 device reported the pressure of the motor was 1300 (the unit of measure might be something like PSI).
    
    ![image](EdgeX_Event-Reading.png)
    
    The value type property (shown as type above) on the reading lets the consumer of the information know that the value is an integer, base 64.  The second reading indicates that the motor123 device also reported the temperature of the motor was 120 at the same time it reported the pressure (perhaps in degrees Fahrenheit).
