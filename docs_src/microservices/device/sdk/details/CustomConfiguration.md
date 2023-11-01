---
title: Device Service SDK - Custom Configuration
---

# Device Service SDK - Custom Configuration

## C Device Service SDK - Custom Structured Configuration
C Device Services support structured custom configuration as part of the `[Driver]` section in the configuration.yaml file.

View the `main` function of `template.c`. The `confparams` variable is initialized with default values for three test parameters. These values may be overridden by entries in the configuration file or by environment variables in the usual way. The resulting configuration is passed to the `init` function when the service starts.

Configuration parameters `X`, `Y/Z` and `Writable/Q` correspond to configuration file entries as follows:
```
[Writable]
  [Writable.Driver]
    Q = "foo"

[Driver]
  X = "bar"
  [Driver.Y]
    Z = "baz"
```

Entries in the writable section can be changed dynamically if using the registry; the `reconfigure` callback will be invoked with the new configuration when changes are made.

In addition to strings, configuration entries may be integer, float or boolean typed. Use the different `iot_data_alloc_` functions when setting up the defaults as appropriate.

## Go Device Service SDK - Custom Structured Configuration

Go Device Services can now define their own custom structured configuration section in the `configuration.yaml` file. Any additional sections in the configuration file are ignored by the SDK when it parses the file for the SDK defined sections. 

This feature allows a Device Service to define and watch it's own structured section in the service's configuration file.

The `SDK` API provides the follow APIs to enable structured custom configuration:

- `LoadCustomConfig(config UpdatableConfig, sectionName string) error`
  
    Loads the service's custom configuration from local file or the Configuration Provider (if enabled). The Configuration Provider will also be seeded with the custom configuration the first time the service is started, if service is using the Configuration Provider. The `UpdateFromRaw` interface will be called on the custom configuration when the configuration is loaded from the Configuration Provider.

- `ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error`
  
    Starts a listener on the Configuration Provider for changes to the specified section of the custom configuration. When changes are received from the Configuration Provider the UpdateWritableFromRaw interface will be called on the custom configuration to apply the updates and then signal that the changes occurred via changedCallback.

See the [Device MQTT Service](https://github.com/edgexfoundry/device-mqtt-go/tree/{{edgexversion}}) for an example of using the new Structured Custom Configuration capability.

- [See here for defining the structured custom configuration](https://github.com/edgexfoundry/device-mqtt-go/blob/{{edgexversion}}/internal/driver/config.go#L21-L72)
- [See here for custom section on the configuration.yaml file](https://github.com/edgexfoundry/device-mqtt-go/blob/{{edgexversion}}/cmd/res/configuration.yaml#L28-L50)
- [See here for loading, validating and watching the configuration](https://github.com/edgexfoundry/device-mqtt-go/blob/{{edgexversion}}/internal/driver/driver.go#L53-L67)
