# V3 Migration Guide

!!! warning
Updates to this migration guide for V3 are still pending. Content/structure below is from V2

## Device Files

## Device Profile Files

## Provision Watcher files

## Custom Device Services

### Configuration

!!! warning
    Updates to this migration guide for V3 are still pending. Content/structure below is from V2

The migration of any Device Service's configuration starts with migrating configuration common to all EdgeX services. See the [V2 Migration of Common Configuration](../../configuration/V2MigrationCommonConfig) section for details. The remainder of this section focuses on configuration specific to Device Services.

#### Device
1. Remove `ImitCmd`, `ImitCmdArgs`, `RemoveCmd` and `RemoveCmdArgs`
2. Add `UseMessageBus` to determine events should be published to MessageBus or sent by REST call.
3. For C-based Device Services (eg, BACnet, Grove, CoAP): `UpdateLastConnected`, `MaxCmdOps`, `DataTransform`, `Discovery` and `MaxCmdResultLen` are dynamic settings - move these to `[Writable.Device]`
4. Add `DevicesDir` and `ProfilesDir` as an indication of where to load the device profiles and pre-defined devices. Convention is to put them under `/res` folder:
   

!!! example "Example configuration"
    ```toml
    [Device] 
    DevicesDir = "./res/devices"
    ProfilesDir = "./res/profiles"
    ... 
    ```

!!! example "Example Project Structure"
    ```
    +- res
    |  +- devices
    |    +- device1.yaml
    |    +- device2.yaml
    |  +- profiles
    |    +- profile1.yml
    |    +- profile2.yml
    |  +- configuration.yaml
    |  +- ...
    +- main.go
    +- device-service-binary
    ```

#### MessageQueue
Device Service is capable of pushing Events to Message Bus instead of sending it via REST call.
A `MessageQueue` section is added in configuration to specify the detail of it.

!!! example "MessageQueue Example"
```toml
[MessageQueue]
Protocol = "redis"
Host = "localhost"
Port = 6379
Type = "redis"
AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
SecretName = "redisdb"
PublishTopicPrefix = "edgex/events/device" # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
  [MessageQueue.Optional]
  # Default MQTT Specific options that need to be here to enable environment variable overrides of them
  # Client Identifiers
  ClientId = "device-simple"
  # Connection information
  Qos = "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
  KeepAlive = "10" # Seconds (must be 2 or greater)
  Retained = "false"
  AutoReconnect = "true"
  ConnectTimeout = "5" # Seconds
  SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
```

See the [Device Service MessageQueue](../../design/adr/013-Device-Service-Events-Message-Bus.md#device-services) section for details.

### Code (Golang)

#### Dependencies
You first need to update the `go.mod` file to specify `go 1.16` and the V2 versions of the Device SDK and any EdgeX go-mods directly used by your service. Note the extra `/v2` for the modules.

!!! example "Example go.mod for V2"

    ```go
    module <your service>
    
    go 1.16
    
    require (
    	github.com/edgexfoundry/device-sdk-go/v2 v2.0.0
    	github.com/edgexfoundry/go-mod-core-contracts/v2 v2.0.0
        ...
    )
    ```

Once that is complete then the import statements for these dependencies must be updated to include the `/v2` in the path.

!!! example "Example import statements for V2"

    ```go
    import (
    	...
        
    	"github.com/edgexfoundry/device-sdk-go/v2/pkg/models"
    	"github.com/edgexfoundry/go-mod-core-contracts/v2/common"
    )
    ```

#### CommandValue
`CommandValue` is redesigned to be more simple and straightforward. A single `Value` with `interface{}` type is able to accommodate reading value of supported type.
As a result, you might notice the original API to create CommandValue is no longer working.
In V2 we refactor all those API functions to create CommandValue of different type to a generic function:

!!! example "Create CommandValue with string Type"
    ```go
    cv, err := models.NewCommandValue(deviceResourceName, v2.ValueTypeString, "foobar")
    if err != nil {
        ...
    }
    cv.Origin = time.Now().Unixnano()
    cv.Tags["foo"] = "bar"
    ```

The 3rd argument in the function must be able to cast into the Type defined in 2nd argument otherwise there will be error.
See [Data formats](../../design/adr/device-service/0011-DeviceService-Rest-API.md#data-formats) for supported data type in EdgeX.

Device Service also supports [Event Tagging](../general/index.md), the tags on the CommandValue will be copied to Event.

### Code (C)

#### Dependencies

The CSDK now has additional dependencies on the Redis client library (hiredis, hiredis-dev) and Paho MQTT (paho-mqtt-c-dev)

#### Attribute and Protocols processing

Four new callback functions are defined and implementations of them are required. Their purpose is to take the parsing of attributes and protocols out of the get/put handlers so that it is not done for every single request.

The device service implementation should define a structure to hold the attributes of a resource in a form suitable for use with whatever access library is being used to communicate with the devices. A function should then be written which allocates and populates this structure, given a set of resource attributes held in a string map. Another function should be written which frees an instance of the structure and any associated elements.

A similar pair of functions should be written to process ProtocolProperties to address a device.

```
devsdk_address_t xxx_create_address (void *impl, const devsdk_protocols *protocols, iot_data_t **exception);
void xxx_free_address (void *impl, devsdk_address_t address);
devsdk_resource_attr_t xxx_create_resource_attr (void *impl, const iot_data_t *attributes, iot_data_t **exception);
void xxx_free_resource_attr (void *impl, devsdk_resource_attr_t attr);
```

In the event of an attribute or protocol set being invalid, the create function should return `NULL` and allocate a string value into the exception parameter indicating the nature of the problem - this will be logged by the SDK.

#### Get and Put handlers

* The `devname` and `protocols` parameters are replaced by an object of type `devsdk_device_t`; this contains `name` (`char *`) and `address` (`devsdk_address_t` - see above) fields
* The resource `name`, `type` and `attributes` (the latter now represented as `devsdk_resource_attr_t`) in a `devsdk_commandrequest` are now held in a `devsdk_resource_t` structure
* `qparams` is renamed to `options` and is now an `iot_data_t` map (string/string)
* `options` is also added to the put handler parameters

#### Callback function list

The callback list structure has been made opaque. An instance of it to pass into the `devsdk_service_new` function is created by calling `devsdk_callbacks_init`. This takes as parameters the mandatory callback functions (init, get/set handlers, stop, create/free addr and create/free resource attr). Services which implement optional callbacks should set these using the relevant population functions:

```
* devsdk_callbacks_set_discovery
* devsdk_callbacks_set_reconfiguration
* devsdk_callbacks_set_listeners
* devsdk_callbacks_set_autoevent_handlers
```

#### Misc

* `edgex_free_device()` now takes the `devsdk_service_t` as its first parameter
* Reflecting changes in the device profile (see below), the `edgex_deviceresource` struct now contains an `edgex_propertyvalue` directly, rather than via an `edgex_profileproperty`. The `edgex_propertyvalue` contains a new field `char *units` which replaces the old `edgex_units` structure.

### Device Profiles

!!! warning
    Updates to this migration guide for V3 are still pending. Content/structure below is from V2

See [Device Profile Reference](profile/Ch-DeviceProfileRef.md) for details, SDK now allows both YAML and JSON format.

#### Device Resource
`properties` field is simplified in device resource:  

- `units` becomes a single string field and it's optional  
- `Float32` and `Float64` type are both only represented in eNotation. Base64 encoding is removed so there is no `floatEncoding` field anymore

V1:
```yaml
deviceResources:
  -
    name: "Xrotation"
    description: "X axis rotation rate"
    properties:
      value:
        { type: "Int32", readWrite: "RW" }
      units:
        { type: "string", readWrite: "R", defaultValue: "degrees/sec" }
```

V2:
```yaml
deviceResources:
  -
    name: "Xrotation"
    description: "X axis rotation rate"
    properties:
      valueType: "Int32"
      readWrite: "RW"
```

#### Device Command
`get` and `set` ResourceOperation field is replaced with a single `readWrite` field to eliminate the duplicate definition.

V1:
```yaml
deviceCommands:
  -
    name: "Rotation"
    get:
      - { operation: "get", deviceResource: "Xrotation" }
      - { operation: "get", deviceResource: "Yrotation" }
      - { operation: "get", deviceResource: "Zrotation" }
    set:
      - { operation: "set", deviceResource: "Xrotation", parameter: "0" }
      - { operation: "set", deviceResource: "Yrotation", parameter: "0" }
      - { operation: "set", deviceResource: "Zrotation", parameter: "0" }
```
V2:
```yaml
deviceCommands:
  -
    name: "Rotation"
    isHidden: false
    readWrite: "RW"
    resourceOperations:
      - { deviceResource: "Xrotation", defaultValue: "0" }
      - { deviceResource: "Yrotation", defaultValue: "0" }
      - { deviceResource: "Zrotation", defaultValue: "0" }
```

#### Core Command
`coreCommands` section is removed in V2. We use `isHidden` field in both deviceResource and deviceCommand to indicates
whether it is exposed to Command Service or not. `isHidden` default to false so all deviceResource
and deviceCommand is able to be called via Command Service REST API. Set `isHidden` to true if you don't want to expose them.

### Devices

!!! warning
    Updates to this migration guide for V3 are still pending. Content/structure below is from V2

#### State
In V2 the values of a device's operating state are changed from `ENABLED`/`DISABLED` to `UP`/`DOWN`. The additional state value `UNKNOWN` is added for future use.

#### Pre-defined Devices
In V2 pre-defined devices are in their own file, SDK allows both TOML and JSON format.

!!! example "Pre-defined devices"
    ```toml
    [[DeviceList]]
    Name = "Simple-Device01"
    ProfileName = "Simple-Device"
    Description = "Example of Simple Device"
    Labels = [ "industrial" ]
      [DeviceList.Protocols]
        [DeviceList.Protocols.other]
        Address = "simple01"
        Port = "300"
      [[DeviceList.AutoEvents]]
      Interval = "10s"
      OnChange = false
      SourceName = "Switch"
      [[DeviceList.AutoEvents]]
      Interval = "30s"
      OnChange = false
      SourceName = "Image"
    ```

Notice that we renamed some fields:  

- `Profle` is renamed to `ProfileName`  
- `Frequency` is renamed to `Interval`  
- `Resource` is renamed to `SourceName`

## Supported Device Services

## Device MQTT

TBD

### Metadata in MQTT Topics

## Device Profile Files

### Configuration

## Device ONVIF Camera

TBD

### Configuration

### Device Profile

## Device USB Camera

TBD

### Configuration

### Device Profile

