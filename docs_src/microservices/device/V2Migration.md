# V2 Migration Guide

!!! edgey "EdgeX 2.0"
For the EdgeX 2.0 (Ireland) release there are many backward breaking changes. These changes require custom Device Services and custom device profiles to be migrated. This section outlines the necessary steps for this migration.

## Custom Device Services

### Configuration

The migration of any Device Service's configuration starts with migrating configuration common to all EdgeX services. See the [V2 Migration of Common Configuration](../../configuration/V2MigrationCommonConfig) section for details. The remainder of this section focuses on configuration specific to Device Services.

#### Device
1. Remove `ImitCmd`, `ImitCmdArgs`, `RemoveCmd` and `RemoveCmdArgs`
2. Add `UseMessageBus` to determine events should be published to MessageBus or sent by REST call.
3. Add `DevicesDir` and `ProfilesDir` as an indication of where to load the device profiles and pre-defined devices. Convention is to put them under `/res` folder:
   
!!! example "Example configuration"
    ```toml
    [Device] 
    DevicesDir = './res/devices'
    ProfilesDir = './res/profiles'
    ... 
    ```
 
!!! example "Example Project Structure"
    ```
    +- res
    |  +- devices
    |    +- device1.toml
    |    +- device2.toml
    |  +- profiles
    |    +- profile1.yml
    |    +- profile2.yml
    |  +- configuration.toml
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
Protocol = 'redis'
Host = 'localhost'
Port = 6379
Type = 'redis'
AuthMode = 'usernamepassword'  # required for redis messagebus (secure or insecure).
SecretName = "redisdb"
PublishTopicPrefix = 'edgex/events/device' # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
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

### Code

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

### Device Profiles
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

### Pre-defined Devices
In V2 pre-defined devices are in their own file, SDK allows both TOML and JSON format.

!!! example "Pre-defined devices"
    ```toml
    [[DeviceList]]
    Name = 'Simple-Device01'
    ProfileName = 'Simple-Device'
    Description = 'Example of Simple Device'
    Labels = [ 'industrial' ]
      [DeviceList.Protocols]
        [DeviceList.Protocols.other]
        Address = 'simple01'
        Port = '300'
      [[DeviceList.AutoEvents]]
      Interval = '10s'
      OnChange = false
      SourceName = 'Switch'
      [[DeviceList.AutoEvents]]
      Interval = '30s'
      OnChange = false
      SourceName = 'Image'
    ```

Notice that we renamed some fields:  

- `Profle` is renamed to `ProfileName`  
- `Frequency` is renamed to `Interval`  
- `Resource` is renamed to `SourceName`  