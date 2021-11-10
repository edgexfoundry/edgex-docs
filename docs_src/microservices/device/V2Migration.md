# V2 Migration Guide

!!! edgey "EdgeX 2.0"
For the EdgeX 2.0 (Ireland) release there are many backward breaking changes. These changes require custom Device Services and custom device profiles to be migrated. This section outlines the necessary steps for this migration.

## Custom Device Services

### Configuration

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

## Device MQTT

The Device MQTT service specific `[Driver]` and `[DeviceList.Protocols.mqtt]` sections have changed for V2. The MQTT Broker connection configuration has been consolidated to just one MQTT Client and now supports SecretStore for the authentication credentials.

### Driver => MQTTBrokerInfo

The `[Driver]` section has been replaced with the new `[MQTTBrokerInfo]`structured custom configuration section. The setting under `[MQTTBrokerInfo.Writable]`can be dynamically updated from Consul without needing to restart the service.

!!! example "Example - V1 Driver configuration"
    ```toml
    # Driver configs
    [Driver]
    IncomingSchema = 'tcp'
    IncomingHost = '0.0.0.0'
    IncomingPort = '1883'
    IncomingUser = 'admin'
    IncomingPassword = 'public'
    IncomingQos = '0'
    IncomingKeepAlive = '3600'
    IncomingClientId = 'IncomingDataSubscriber'
    IncomingTopic = 'DataTopic'
    ResponseSchema = 'tcp'
    ResponseHost = '0.0.0.0'
    ResponsePort = '1883'
    ResponseUser = 'admin'
    ResponsePassword = 'public'
    ResponseQos = '0'
    ResponseKeepAlive = '3600'
    ResponseClientId = 'CommandResponseSubscriber'
    ResponseTopic = 'ResponseTopic'
    ConnEstablishingRetry = '10'
    ConnRetryWaitTime = '5'
    ```

!!! example "Example - V2 MQTTBrokerInfo configuration section"
    ```toml
    [MQTTBrokerInfo]
    Schema = "tcp"
    Host = "0.0.0.0"
    Port = 1883
    Qos = 0
    KeepAlive = 3600
    ClientId = "device-mqtt"
    
    CredentialsRetryTime = 120 # Seconds
    CredentialsRetryWait = 1 # Seconds
    ConnEstablishingRetry = 10
    ConnRetryWaitTime = 5
    
    # AuthMode is the MQTT broker authentication mechanism. 
    # Currently, "none" and "usernamepassword" is the only AuthMode
    # supported by this service, and the secret keys are "username" and "password".
    AuthMode = "none"
    CredentialsPath = "credentials"
    
    IncomingTopic = "DataTopic"
    responseTopic = "ResponseTopic"
    
        [MQTTBrokerInfo.Writable]
        # ResponseFetchInterval specifies the retry 
        # interval(milliseconds) to fetch the command response from the MQTT broker
        ResponseFetchInterval = 500
    ```

### DeviceList.Protocols.mqtt

Now that there is a single MQTT Broker connection, the configuration in `[DeviceList.Protocols.mqtt]` for each device has been greatly simplified to just the CommandTopic the device is subscribed. Note that this topic needs to be a unique topic for each device defined.

!!! example "Example - V1 DeviceList.Protocols.mqtt device configuration section"
    ```toml
    [DeviceList.Protocols]
      [DeviceList.Protocols.mqtt]
       Schema = 'tcp'
       Host = '0.0.0.0'
       Port = '1883'
       ClientId = 'CommandPublisher'
       User = 'admin'
       Password = 'public'
       Topic = 'CommandTopic'
    ```

!!! example "Example - V2 DeviceList.Protocols.mqtt device configuration section"
    ```toml
      [DeviceList.Protocols]
        [DeviceList.Protocols.mqtt]
           CommandTopic = 'CommandTopic'
    ```

### SecretStore

#### Secure

See the [Secret API reference](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/device-sdk/2.0.0#/default/post_secret) for injecting authentication credentials into a Device Service's secure SecretStore. 

!!! example - "Example - Authentication credentials injected via Device MQTT's `Secret` endpoint"
    ```bash
    curl -X POST http://localhost:59982/api/v2/secret  -H 'Content-Type: application/json' -d '{ "apiVersion": "v2", "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369", "path": "credentials", "secretData": [  {   "key": "username", "value": "mqtt-user"  }, {  "key": "password", "value": "mqtt-password" } ]}'  
    ```

!!! note
    The service has to be running for this endpoint to be available.  The following `[MQTTBrokerInfo]` settings from above allow a window of time to inject the credentials.
    ```toml
    CredentialsRetryTime = 120 # Seconds
    CredentialsRetryWait = 1 # Seconds
    ```

#### Non Secure

For non-secure mode the authentication credentials need to be added to the [InsecureSecrets] configuration section. 

!!! example - "Example - Authentication credentials in Device MQTT's `[InsecureSecrets]` configuration section"
    ```toml
    [Writable.InsecureSecrets]
      [Writable.InsecureSecrets.MQTT]
      path = "credentials"
        [Writable.InsecureSecrets.MQTT.Secrets]
        username = "mqtt-user"
        password = "mqtt-password"
    ```

## Device Camera

The Device Camera service specific `[Driver]` and `[DeviceList.Protocols.HTTP]` sections have changed for V2 due to the addition of the SecretStore capability and per camera credentials. The plain text camera credentials have been replaced with settings describing where to pull them from the SecretStore for each camera device specified.

### Driver

!!! example "Example V1 Driver configuration section"
    ```toml
    [Driver]
    User = 'service'
    Password = 'Password!1'
    # Assign AuthMethod to 'digest' | 'basic' | 'none'
    # AuthMethod specifies the authentication method used when
    # requesting still images from the URL returned by the ONVIF
    # "GetSnapshotURI" command.  All ONVIF requests will be
    # carried out using digest auth.
    AuthMethod = 'basic'
    ```

!!! example "Example V2 Driver configuration section"
    ```toml
    [Driver]
    CredentialsRetryTime = '120' # Seconds
    CredentialsRetryWait = '1' # Seconds
    ```

### DeviceList.Protocols.HTTP

!!! example "Example V1 DeviceList.Protocols.HTTP device configuration section"
    ```toml
    [DeviceList.Protocols]
      [DeviceList.Protocols.HTTP]
      Address = '192.168.2.105'
    ```

!!! example "Example V2 DeviceList.Protocols.HTTP device configuration section"
    ```toml
    [DeviceList.Protocols]
      [DeviceList.Protocols.HTTP]
      Address = '192.168.2.105'
      # Assign AuthMethod to 'digest' | 'usernamepassword' | 'none'
      # AuthMethod specifies the authentication method used when
      # requesting still images from the URL returned by the ONVIF
      # "GetSnapshotURI" command.  All ONVIF requests will be
      # carried out using digest auth.
      AuthMethod = 'usernamepassword'
      CredentialsPath = 'credentials001'
    ```

### SecretStore

#### Secure

See the [Secret API reference](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/device-sdk/2.0.0#/default/post_secret) for injecting authentication credentials into a Device Service's secure SecretStore. An entry is required for each camera that is configured with `AuthMethod = 'usernamepassword'`

!!! example - "Example - Authentication credentials injected via Device Camera's `Secret` endpoint"
    ```bash
    curl -X POST http://localhost:59985/api/v2/secret  -H 'Content-Type: application/json' -d '{ "apiVersion": "v2", "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369", "path": "credentials001", "secretData": [  {   "key": "username", "value": "camera-user"  }, {  "key": "password", "value": "camera-password" } ]}'  
    ```

!!! note
    The service has to be running for this endpoint to be available.  The following `[Driver]` settings from above allow a window of time to inject the credentials.

    ```toml
    CredentialsRetryTime = 120 # Seconds
    CredentialsRetryWait = 1 # Seconds
    ```

#### Non Secure

For non-secure mode the authentication credentials need to be added to the [InsecureSecrets] configuration section. An entry is required for each camera that is configured with `AuthMethod = 'usernamepassword'`

!!! example - "Example - Authentication credentials in Device Camera's `[InsecureSecrets]` configuration section"
    ```toml
    [Writable.InsecureSecrets.Camera001]
    path = "credentials001"
      [Writable.InsecureSecrets.Camera001.Secrets]
      username = "camera-user"
      password = "camera-password"
    ```
