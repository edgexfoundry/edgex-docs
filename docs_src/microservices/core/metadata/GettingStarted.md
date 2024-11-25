---
title: Core Metadata - Getting Started
---

# Core Metadata - Getting Started

## Data Models

To understand metadata, its important to understand the EdgeX data objects it manages.  Metadata stores its knowledge in a local persistence database. [PostgreSQL](https://www.postgresql.org/) is used by default, but a database abstraction layer allows for other databases to be used.

### Device Profile

Device profiles define general characteristics about devices, the data they provide, and how to command them. Think of a device profile as a template of a type or classification of device. For example, a device profile for BACnet thermostats provides general characteristics for the types of data a BACnet thermostat sends, such as current temperature and humidity level. It also defines which types of commands or actions EdgeX can send to the BACnet thermostat.  Examples might include actions that set the cooling or heating point.  Device profiles are typically specified in YAML file and uploaded to EdgeX.  More details are provided below.

#### Device Profile Details

![image](EdgeX_MetadataModel_Profile.png)
*Metadata device profile object model*

=== "General Properties"

    A device profile has a number of high level properties to give the profile context and identification. Its name field is required and must be unique in an EdgeX deployment. Other fields are optional - they are not used by device services but may be populated for informational purposes:
    
    - Description
    - Manufacturer
    - Model
    - Labels
    
    Here is an example general information section for a sample KMC 9001 BACnet thermostat device profile provided with the BACnet device service (you can find the [profile](https://github.com/edgexfoundry/device-bacnet-c/blob/{{edgexversion}}/sample-profiles/BAC-9001.json) in Github) .  Only the name is required in this section of the device profile.  The name of the device profile must be unique in any EdgeX deployment.  The manufacturer, model and labels are all optional bits of information that allow better queries of the device profiles in the system.
    
    ``` YAML
    name: "BAC-9001"
    manufacturer: "KMC"
    model: "BAC-9001"
    labels: 
        - "B-AAC"
    description: "KMC BAC-9001 BACnet thermostat"
    ``` 
    
    Labels provided a way to tag, organize or categorize the various profiles.  They serve no real purpose inside of EdgeX.

=== "Device Resources"

    A device resource (in the deviceResources section of the YAML file) specifies a sensor value within a device that may be read from or written to either individually or as part of a device command (see below).  Think of a device resource as a specific value that can be obtained from the underlying device or a value that can be set to the underlying device.  In a thermostat, a device resource may be a temperature or humidity (values sensed from the devices) or cooling point or heating point (values that can be set/actuated to allow the thermostat to determine when associated heat/cooling systems are turned on or off).  A device resource has a name for identification and a description for informational purposes.
    
    The properties section of a device resource has also been greatly simplified.  See details below.
    
    Back to the BACnet example, here are two device resources.  One will be used to get the temperature (read) the current temperature and the other to set (write or actuate) the active cooling set point.  The device resource name must be provided and it must also be unique in any EdgeX deployment.
    
    ``` YAML
    name: Temperature
    description: "Get the current temperature"
    isHidden: false
    
    name: ActiveCoolingSetpoint
    description: "The active cooling set point"
    isHidden: false
    ```
    
    !!! Note
        While made explicit in this example, `isHidden` is false by default when not specified.  `isHidden` indicates whether to expose the device resource to the core command service.
    
    The device service allows access to the device resources via REST endpoint.  Values specified in the device resources section of the device profile can be accessed through the following URL patterns:
    
    -  http://<device-service>:<port>/api/{{api_version}}/device/name/<DeviceName>/<DeviceResourceName>

=== "Attributes"

    The attributes associated to a device resource are the specific parameters required by the device service to access the particular value.   In other words, attributes are “inward facing” and are used by the device service to determine how to speak to the device to either read or write (get or set) some of its values. Attributes are detailed protocol and/or device specific information that informs the device service how to communication with the device to get (or set) values of interest.
    
    Returning to the BACnet device profile example, below are the complete device resource sections for Temperature and ActiveCoolingSetPoint – inclusive of the attributes – for the example device.
    
    ``` YAML
    -
        name: Temperature
        description: "Get the current temperature"
        isHidden: false
        attributes: 
            { type: "analogValue", instance: "1", property: "presentValue", index: "none"  }
    -
        name: ActiveCoolingSetpoint
        description: "The active cooling set point"
        isHidden: false
        attributes:
            { type: "analogValue", instance: "3", property: "presentValue", index: "none"  }
    ```

=== "Properties"

    The properties of a device resource describe the value obtained or set on the device.  The properties can optionally inform the device service of some simple processing to be performed on the value.  Again, using the BACnet profile as an example, here are the properties associated to the thermostat's temperature device resource.
    
    ``` YAML
    name: Temperature
    description: "Get the current temperature"
    attributes: 
        { type: "analogValue", instance: "1", property: "presentValue", index: "none"  }
    properties: 
        valueType: "Float32"
        readWrite: "R"
        units: "Degrees Fahrenheit"
    ```
    
    The 'valueType' property of properties gives more detail about the value collected or set.  In this case giving the details of the temperature value to be set.  The value provides details such as the type of the data collected or set, whether the value can be read, written or both.
    
    The following fields are available in the value property:
    
    - valueType - Required. The data type of the value. Supported types are Bool, Int8 - Int64, Uint8 - Uint64, Float32, Float64, String, Binary, Object and arrays of the primitive types (ints, floats, bool). Arrays are specified as eg. Float32Array, BoolArray etc.
    - readWrite - R, RW, or W indicating whether the value is readable or writable.
    - units - gives more detail about the unit of measure associated with the value. In this case, the temperature unit of measure is in degrees Fahrenheit.
    - min - minimum allowed value 
    - max - maximum allowed value
    - defaultValue - a value used for PUT requests which do not specify one.
    - base - a value to be raised to the power of the raw reading before it is returned.
    - scale - a factor by which to multiply a reading before it is returned.
    - offset - a value to be added to a reading before it is returned.
    - mask - a binary mask which will be applied to an integer reading.
    - shift - a number of bits by which an integer reading will be shifted right.
    
    The processing defined by base, scale, offset, mask and shift is applied in that order. This is done within the SDK. A reverse transformation is applied by the SDK to incoming data on set operations (NB mask transforms on set are NYI)


=== "Device Commands"

    Device commands (in the deviceCommands section of the YAML file) define access to reads and writes for multiple simultaneous device resources. Device commands are optional.  Each named device command should contain a number of get and/or set resource operations, describing the read or write respectively.
    
    Device commands may be useful when readings are logically related, for example with a 3-axis accelerometer it is helpful to read all axes (X, Y and Z) together.
    
    A device command consists of the following properties:
    
    - name - the name of the command
    - readWrite - R, RW, or W indicating whether the operation is readable or writable.
    - isHidden - indicates whether to expose the device command to the core command service (optional and false by default)
    - resourceOperations - the list of included device resource operations included in the command.
    
    Each resourceOperation will specify:
    
    - the deviceResource - the name of the device resource
    - defaultValue - optional, a value to return when the operation does not provide one
    - parameter - optional, a value that will be used if a PUT request does not specify one.
    - mappings - optional, allows readings of String type to be re-mapped.
    
    The device commands can also be accessed through a device service’s REST API in a similar manner as described for device resources.
    
    - http://<device-service>:<port>/api/{{api_version}}/device/name/<DeviceName>/<DeviceCommandName>
    
    If a device command and device resource have the same name, it will be the device command which is available.

=== "Core Commands"
 
    Device resources or device commands that are not hidden are seen and available via the EdgeX core command service.  
    
    Other services (such as the rules engine) or external clients of EdgeX, should make requests of device services through the core command service, and when they do, they are calling on the device service’s unhidden device commands or device resources.  Direct access to the device commands or device resources of a device service is frowned upon.  Commands, made available through the EdgeX command service, allow the EdgeX adopter to add additional security or controls on who/what/when things are triggered and called on an actual device.
    
    ![image](EdgeX_DS_Access.png)

### Device

Data about actual devices is another type of information that the metadata micro service stores and manages. Each device managed by EdgeX Foundry registers with metadata (via its owning device service.  Each device must have a unique name associated to it. 

Metadata stores information about a device (such as its address) against the name in its database. Each device is also associated to a device profile. This association enables metadata to apply knowledge provided by the device profile to each device. For example, a thermostat profile would say that it reports temperature values in Celsius.  Associating a particular thermostat (the thermostat in the lobby for example) to the thermostat profile allows metadata to know that the lobby thermostat reports temperature value in Celsius. 

![image](EdgeX_Metadata2.png)

### Device Service

Metadata also stores and manages information about the device services.  Device services serve as EdgeX's interfaces to the actual devices and sensors.

Device services are other micro services that communicate with devices via the protocol of that device.  For example, a Modbus device service facilitates communications among all types of Modbus devices.  Examples of Modbus devices include motor controllers, proximity sensors, thermostats, and power meters.  Device services simplify communications with the device for the rest of EdgeX.

When a device service starts, it registers itself with metadata.  When EdgeX provisions a new devices the device gets associated to its owning device service.  That association is also stored in metadata.

![image](EdgeX_Metadata3.png)

**Metadata Device, Device Service and Device Profile Model**

![image](EdgeX_MetadataModel.png)
*Metadata's Device Profile, Device and Device Service object model and the association between them* 

### Provision Watcher

Device services may contain logic to automatically provision new devices.  This can be done statically or dynamically.  In static device configuration (also known as static provisioning) the device service connects to and establishes a new device that it manages in EdgeX (specifically metadata) from configuration the device service is provided.  For example, a device service may be provided with the specific IP address and additional device details for a device (or devices) that it is to onboard at startup.  In static provisioning, it is assumed that the device will be there and that it will be available at the address or place specified through configuration.  The devices and the connection information for those devices is known at the point that the device service starts.

In dynamic discovery (also known as automatic provisioning), a device service is given some general information about where to look and general parameters for a device (or devices).  For example, the device service may be given a range of BLE address space and told to look for devices of a certain nature in this range.  However, the device service does not know that the device is physically there – and the device may not be there at start up.  It must continually scan during its operations (typically on some sort of schedule) for new devices within the guides of the location and device parameters provided by configuration. 

Not all device services support dynamic discovery.  If it does support dynamic discovery, the configuration about what and where to look (in other words, where to scan) for new devices is specified by a provision watcher.  A provision watcher, is specific configuration information provided to a device service (usually at startup) that gets stored in metadata.  In addition to providing details about what devices to look for during a scan, a provision watcher may also contain “blocking” indicators, which define parameters about devices that are not to be automatically provisioned.  This allows the scope of a device scan to be narrowed or allow specific devices to be avoided.  

![image](EdgeX_MetadataModel_ProvisionWatcher.png)
*Metadata's provision watcher object model*
