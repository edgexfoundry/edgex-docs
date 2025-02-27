---
title: App SDK - Custom Configuration
---

# App Functions SDK for Python - Custom Configuration

Applications can specify custom configuration in the service's configuration file in two ways.

## Application Settings

The first simple way is to add items to the `ApplicationSettings` section. This is a dictionary of string key/value pairs, i.e. `dict[str, str]`. Use for simple string values or comma separated list of string values. The `ApplicationService` API provides the follow access APIs for this configuration section:

- `application_settings() Dict[str, str]`
    - Returns the whole list of application settings
- `get_application_setting(key: str) str`
    - Returns single entry from the dictionary whose key matches the passed in `key` value. An exception is raised if the `ApplicationSettings` is not defined in the service configuration or the specified key is not found in the `ApplicationSettings`.
- `get_application_setting_strings(key: str) [str]`
    - Returns list of strings for the entry whose key matches the passed in `key` value. The Entry is assumed to be a comma separated list of strings. An exception is raised if the `ApplicationSettings` is not defined in the service configuration or the specified key is not found in the `ApplicationSettings`.

## Structure Custom Configuration

The second is the more complex `Structured Custom Configuration` which allows the Application Service to define and watch its own structured section in the service's configuration file.

The `ApplicationService` API provides the following APIs to enable structured custom configuration:

- `load_custom_config(custom_config: Any, section_name: str) error`
    - Loads the service's custom configuration from local file or the Configuration Provider (if enabled). The Configuration Provider will also be seeded with the custom configuration the first time the service is started, if service is using the Configuration Provider.

- `listen_for_custom_config_changes(config: Any, section_name: str, changed_callback: Callable[[Any], None])`
    - Starts a listener on the Configuration Provider for changes to the specified section of the custom configuration. When changes are received from the Configuration Provider the Application Service will update the `config` object to apply the updates and then signal that the changes occurred via the `changed_callback` function.

See the [Application Service Template](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/examples/custom-config) for an example of using the new Structured Custom Configuration capability.

- [See here for defining the structured custom configuration](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/examples/custom-config/main.py#L12-L30)
- [See here for loading, validating and watching the configuration](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/examples/custom-config/main.py#L76-L96)
