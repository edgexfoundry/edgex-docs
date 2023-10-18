---
title: App SDK - Custom Configuration
---

# App Functions SDK - Custom Configuration

Applications can specify custom configuration in the service's configuration file in two ways.

## Application Settings

The first simple way is to add items to the `ApplicationSetting` section. This is a map of string key/value pairs, i.e. `map[string]string`. Use for simple string values or comma separated list of string values. The `ApplicationService` API provides the follow access APIs for this configuration section:

- `ApplicationSettings() map[string]string`
    - Returns the whole list of application settings
- `GetAppSetting(setting string) (string, error)`
    - Returns single entry from the map whose key matches the passed in `setting` value
- `GetAppSettingStrings(setting string) ([]string, error)`
    - Returns list of strings for the entry whose key matches the passed in `setting` value. The Entry is assumed to be a comma separated list of strings.

## Structure Custom Configuration

The second is the more complex `Structured Custom Configuration` which allows the Application Service to define and watch its own structured section in the service's configuration file.

The `ApplicationService` API provides the following APIs to enable structured custom configuration:

- `LoadCustomConfig(config UpdatableConfig, sectionName string) error`
    - Loads the service's custom configuration from local file or the Configuration Provider (if enabled). The Configuration Provider will also be seeded with the custom configuration the first time the service is started, if service is using the Configuration Provider. The `UpdateFromRaw` interface will be called on the custom configuration when the configuration is loaded from the Configuration Provider.

- `ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error`
    - Starts a listener on the Configuration Provider for changes to the specified section of the custom configuration. When changes are received from the Configuration Provider the UpdateWritableFromRaw interface will be called on the custom configuration to apply the updates and then signal that the changes occurred via changedCallback.

See the [Application Service Template](https://github.com/edgexfoundry/app-functions-sdk-go/tree/{{edgexversion}}/app-service-template) for an example of using the new Structured Custom Configuration capability.

- [See here for defining the structured custom configuration](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/app-service-template/config/configuration.go#L36-L81)
- [See here for loading, validating and watching the configuration](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/app-service-template/main.go#L73-L97)