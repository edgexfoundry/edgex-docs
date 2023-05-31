# Go Device SDK API

The `DeviceServiceSDK` API provides the following APIs for the device service developer to use.

```go
type DeviceServiceSDK interface {
    AddDevice(device models.Device) (string, error)
    Devices() []models.Device
    GetDeviceByName(name string) (models.Device, error)
    UpdateDevice(device models.Device) error
    RemoveDeviceByName(name string) error
    AddDeviceProfile(profile models.DeviceProfile) (string, error)
    DeviceProfiles() []models.DeviceProfile
    GetProfileByName(name string) (models.DeviceProfile, error)
    UpdateDeviceProfile(profile models.DeviceProfile) error
    RemoveDeviceProfileByName(name string) error
    AddProvisionWatcher(watcher models.ProvisionWatcher) (string, error)
    ProvisionWatchers() []models.ProvisionWatcher
    GetProvisionWatcherByName(name string) (models.ProvisionWatcher, error)
    UpdateProvisionWatcher(watcher models.ProvisionWatcher) error
    RemoveProvisionWatcher(name string) error
    DeviceResource(deviceName string, deviceResource string) (models.DeviceResource, bool)
    DeviceCommand(deviceName string, commandName string) (models.DeviceCommand, bool)
    AddDeviceAutoEvent(deviceName string, event models.AutoEvent) error
    RemoveDeviceAutoEvent(deviceName string, event models.AutoEvent) error
    UpdateDeviceOperatingState(name string, state models.OperatingState) error
    DeviceExistsForName(name string) bool
    PatchDevice(updateDevice dtos.UpdateDevice) error
    Run() error
	Name() string
    Version() string
    AsyncReadingsEnabled() bool
    AsyncValuesChannel() chan *sdkModels.AsyncValues
    DiscoveredDeviceChannel() chan []sdkModels.DiscoveredDevice
    DeviceDiscoveryEnabled() bool
    DriverConfigs() map[string]string
    AddRoute(route string, handler func(http.ResponseWriter, *http.Request), methods ...string) error
    LoadCustomConfig(customConfig UpdatableConfig, sectionName string) error
    ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error
    LoggingClient() logger.LoggingClient
    SecretProvider() interfaces.SecretProvider
    MetricsManager() interfaces.MetricsManager
}
```

## APIs

### Auto Event

#### AddDeviceAutoEvent

`AddDeviceAutoEvent(deviceName string, event models.AutoEvent) error`

This API adds a new AutoEvent to the Device with given name. An error is returned if not able to add AutoEvent

#### RemoveDeviceAutoEvent 

`RemoveDeviceAutoEvent(deviceName string, event models.AutoEvent) error`

This API removes an AutoEvent from the Device with given name. An error is returned if not able to remove AutoEvent

### Device

#### AddDevice

`AddDevice(device models.Device) (string, error)`

This API adds a new Device to Core Metadata and device service's cache. Returns new Device id or an error.

#### UpdateDevice

`UpdateDevice(device models.Device) error`

This API updates the Device in Core Metadata and device service's cache. An error is returned if the Device can not be updated.

#### UpdateDeviceOperatingState

`UpdateDeviceOperatingState(deviceName string, state models.OperatingState) error`

This API updates the Device's operating state for the given name in Core Metadata and device service's cache. An error is return if the operating state can not be updated.

#### RemoveDeviceByName

`RemoveDeviceByName(name string) error`

This API removes the specified Device by name from Core Metadata and device service cache. An error is return if the Device can not be removed.

#### Devices

`Devices() []models.Device`

This API returns all managed Devices from the device service's cache

#### GetDeviceByName

`GetDeviceByName(name string) (models.Device, error)`

This API returns the Device by its name if it exists in the device service's cache, or returns an error.

#### PatchDevice

`PatchDevice(updateDevice dtos.UpdateDevice) error`  

This API patches the specified device properties in Core Metadata. Device name is required
to be provided in the UpdateDevice. 

!!! Note
    All properties of UpdateDevice are pointers and anything that is `nil` will not modify the device. In the case of Arrays and Maps, the whole new value
    must be sent, as it is applied as an overwrite operation.

!!! example - "Example - PatchDevice()"
    ```go
    service := interfaces.Service()
    locked := models.Locked
    return service.PatchDevice(dtos.UpdateDevice{
        Name:       &name,
        AdminState: &locked,
    })
    ```

#### DeviceExistsForName

`DeviceExistsForName(name string) bool`  

This API returns true if a device exists in cache with the specified name, otherwise it returns false.

### Device Profile

#### AddDeviceProfile

`AddDeviceProfile(profile models.DeviceProfile) (string, error)`

This API adds a new DeviceProfile to Core Metadata and device service's cache. Returns new DeviceProfile id or error

#### UpdateDeviceProfile

`UpdateDeviceProfile(profile models.DeviceProfile) error`

This API updates the DeviceProfile in Core Metadata and device service's cache. An error is returned if the DeviceProfile can not be updated.

#### RemoveDeviceProfileByName

`RemoveDeviceProfileByName(name string) error`

This API removes the specified DeviceProfile by name from Core Metadata and device service's cache. An error is return if the DeviceProfile can not be removed.

#### DeviceProfiles

`DeviceProfiles() []models.DeviceProfile`

This API returns all managed DeviceProfiles from device service's cache.

#### GetProfileByName

`GetProfileByName(name string) (models.DeviceProfile, error)`

This API returns the DeviceProfile by its name if it exists in the cache, or returns an error.

### Provision Watcher

#### AddProvisionWatcher

`AddProvisionWatcher(watcher models.ProvisionWatcher) (string, error)`

This API adds a new Watcher to Core Metadata and device service's cache. Returns new ProvisionWatcherid or error.

#### UpdateProvisionWatcher

`UpdateProvisionWatcher(watcher models.ProvisionWatcher) error`

This API updates the ProvisionWatcherin in Core Metadata and device service's cache. An error is returned if the ProvisionWatcher can not be updated.

#### RemoveProvisionWatcher

`RemoveProvisionWatcher(name string) error`

This API removes the specified ProvisionWatcherby name from Core Metadata and device service's cache. An error is return if the ProvisionWatcher can not be removed.

#### ProvisionWatchers

`ProvisionWatchers() []models.ProvisionWatcher`

This API returns all managed ProvisionWatchers from device service's cache.

#### GetProvisionWatcherByName

`GetProvisionWatcherByName(name string) (models.ProvisionWatcher, error)`

This API returns the ProvisionWatcher by its name if it exists in the device service's , or returns an error.

### Resource & Command

#### DeviceResource

`DeviceResource(deviceName string, deviceResource string) (models.DeviceResource, bool)`

This API retrieves the specific DeviceResource instance from device service's cache for the specified Device name and Resource name. Returns the DeviceResource and true if found in device service's cache or false if not found.

#### DeviceCommand

`DeviceCommand(deviceName string, commandName string) (models.DeviceCommand, bool)`

This API retrieves the specific DeviceCommand instance from device service's cache for the specified Device name and Command name. Returns the DeviceCommand  and true if found in device service's cache or false if not found.

### Custom Configuration

#### LoadCustomConfig

`LoadCustomConfig(customConfig service.UpdatableConfig, sectionName string) error`

This API attempts to load service's custom configuration. It uses the same command line flags to process the custom config in the same manner
 as the standard configuration. Returns an error is custom configuration can not be loaded. See [Custom Structured Configuration](../../../getting-started/Ch-GettingStartedSDK-Go/#custom-structured-configuration) section for more details.

#### ListenForCustomConfigChanges

`ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error`

This API attempts to start listening for changes to the specified custom configuration section. LoadCustomConfig API must be called before this API. See [Custom Structured Configuration](../../../getting-started/Ch-GettingStartedSDK-Go/#custom-structured-configuration) section for more details.

### Miscellaneous

#### Name

`Name() string`

This API returns the name of the Device Service.

####  Version

`Version() string`

This API returns the version number of the Device Service.

#### DriverConfigs

`DriverConfigs() map[string]string`

This API returns the driver specific configuration

#### AsyncReadingsEnabled

`AsyncReadingsEnabled() bool`

This API returns a bool value to indicate whether the asynchronous reading is enabled via configuration.

#### DeviceDiscoveryEnabled

`DeviceDiscoveryEnabled() bool`

This API returns a bool value to indicate whether the device discovery is enabled via configuration.

#### AddRoute

`AddRoute(route string, handler func(http.ResponseWriter, *http.Request), methods ...string) error`

This API allows leveraging the existing internal web server to add routes specific to the Device Service. Returns error is route could not be added.

#### LoggingClient

`LoggingClient() logger.LoggingClient`

This API returns the `LoggingClient` used to log messages.


#### SecretProvider

`SecretProvider() interfaces.SecretProvider`

This API returns the SecretProvider used to get/save the service secrets. See [Secret Provider API](../../../../security/Ch-SecretProviderApi/) section for more details.

#### MetricsManager

`MetricsManager () interfaces.MetricsManager`

This API returns the MetricsManager used to register custom service metrics. See [Service Metrics](../../../general/#service-metrics) for more details

#### AsyncValuesChannel

`AsyncValuesChannel() chan *sdkModels.AsyncValues`

This API returns a channel to allow developer send asynchronous reading back to SDK.

#### DiscoveredDeviceChannel

`DiscoveredDeviceChannel() chan []sdkModels.DiscoveredDevice`

This API returns a channel to allow developer send discovered devices back to SDK.

### Internal

#### Run

`Run() error`

This internal API call starts this Device Service. It should not be called directly by a device service.
Instead, call `startup.Bootstrap(...)`.
