---
title: App SDK - Application Service API
---

# App Functions SDK for Python - Application Service API

The `ApplicationService` API is the central API for creating an EdgeX Application Service.

The new `ApplicationService` API is as follows:

```python
AppFunction = Callable[[AppFunctionContext, Any], Tuple[bool, Any]]

class FunctionPipeline:
    """
    Represents a pipeline of functions to be executed in sequence.

    Attributes:
        pipelineid (str): The unique identifier for the pipeline.
        topics (List[str]): A list of topics associated with the pipeline.
        transforms (List[AppFunction]): A list of functions to be executed in the pipeline.
    """
    def __init__(self, pipelineid: str, topics: List[str], *transforms: AppFunction):
        self.id = pipelineid
        self.transforms = transforms
        self.topics = topics
        self.hash = calculate_pipeline_hash(*transforms)
        self.message_processed = meters.Counter("")
        self.message_processing_time = meters.Timer("")
        self.processing_errors = meters.Counter("")

class ApplicationService(ABC):
    """
    An abstract base class that defines the interface for an application service.
    """

    @abstractmethod
    def app_done_event(self) -> threading.Event:
    
    @abstractmethod
    def add_custom_route(self, route: str, use_auth: bool, handler: Callable, methods: Optional[List[str]] = None):
    
    @abstractmethod
    def logger(self) -> Logger:

    @abstractmethod
    def application_settings(self) -> Dict[str, str]:
    
    @abstractmethod
    def get_application_setting(self, key: str) -> str:
    
    @abstractmethod
    def get_application_setting_strings(self, key: str) -> [str]:
    
    @abstractmethod
    def set_default_functions_pipeline(self, *functions: AppFunction):
    
    @abstractmethod
    def add_functions_pipeline_for_topics(self, pipeline_id: str, topics: List[str], functions: List[AppFunction]):
        
    @abstractmethod
    def remove_all_function_pipelines(self):
        
    @abstractmethod
    async def run(self):
        
    @abstractmethod
    def setup_trigger(self, trigger_info: TriggerInfo) -> Trigger:
        
    @abstractmethod
    def register_custom_trigger_factory(self, name: str, factory: Callable[[TriggerConfig], Trigger]):
        
    @abstractmethod
    def registry_client(self) -> Client:
        
    @abstractmethod
    def event_client(self) -> EventClientABC:
        
    @abstractmethod
    def reading_client(self) -> ReadingClientABC:
        
    @abstractmethod
    def command_client(self) -> CommandClientABC:
        
    @abstractmethod
    def device_service_client(self) -> DeviceServiceClientABC:
        
    @abstractmethod
    def device_profile_client(self) -> DeviceProfileClientABC:
        
    @abstractmethod
    def device_client(self) -> DeviceClientABC:
        
    @abstractmethod
    def secret_provider(self) -> SecretProvider:
        
    @abstractmethod
    def publish(self, data: Any, content_type: str):
        
    @abstractmethod
    def publish_with_topic(self, topic: str, data: Any, content_type: str):
        
    @abstractmethod
    def load_custom_config(self, custom_config: Any, section_name: str):
        
    @abstractmethod
    def listen_for_custom_config_changes(self, config: Any, section_name: str, changed_callback: Callable[[Any], None]):
        
    @abstractmethod
    def dic(self) -> Container:
        
    @abstractmethod
    def get_service_config(self) -> ConfigurationStruct:
        
```

## Factory Functions

The App Functions SDK provides a factory function for creating an `ApplicationService`

### new_app_service

`def new_app_service(service_key: str, target_type: Any = None) -> (ApplicationService, bool):`

This factory function returns an `ApplicationService` instance initialized with the passed in `target_type`. If the `target_type` is None, the app service will use Event() as the default target type. The second `bool` return parameter will be `true` if successfully initialized, otherwise it will be `false` when error(s) occurred during initialization. All error(s) are logged so the caller just needs to call `os._exit(-1)` if `false` is returned.

!!! example "Example - new_app_service with None target_type"

    ```python
    service_key = "app-myservice"
    ...
    
    service, ok = new_app_service(service_key)
    if ok is False:
        os._exit(-1)
    ```

!!! example "Example - new_app_service with customized target_type"

    ```python
    service_key = "app-myservice"
    ...

    class Person:
    def __init__(self):
        self.FirstName = ""
        self.LastName = ""
    
    service, ok = new_app_service(service_key, Person())
    if ok is False:
        os._exit(-1)
    ```

## Custom Configuration APIs

The following `ApplicationService` APIs allow your service to access their custom configuration from the configuration file and/or Configuration Provider. See the [Custom Configuration](../details/CustomConfiguration.md) advanced topic for more details.

### application_settings

`application_settings() -> Dict[str, str]`

This API returns the complete key/value map of custom settings

!!! example "Example - ApplicationSettings"

    ```yaml
    ApplicationSettings:
      Greeting: "Hello World"
    ```
    
    ```python
    app_settings = service.application_settings()
    greeting = app_settings["Greeting"]
    service.logger().info(greeting)
    ```

### get_application_setting

`get_application_setting(key: str) -> str`

This API is a convenience API that returns a single setting from the `[ApplicationSettings]` section of the service configuration. An ValueError is raised if the specified setting is not found.

!!! example "Example - GetAppSetting"

    ```yaml
    ApplicationSettings:
     Greeting: "Hello World"
    ```
    
    ```python
    try:
        greeting = service.get_application_setting("NonExistent")
        service.logger().info(greeting)
    except ValueError as e:
        service.logger().warn(f"{e}")
    ```

### get_application_setting_strings

`get_application_setting_strings(key: str) -> [str]`

This API is a convenience API that parses the string value for the specified custom application setting as a comma separated list. It returns the list of strings. An ValueError is raised if the specified setting is not found.

!!! example "Example - GetAppSettingStrings"

    ```yaml
    ApplicationSettings:
     Greetings: "Hello World, Welcome World, Hi World"
    ```
    
    ```python
    try:
        greetings = service.get_application_setting_strings("Greetings")
        for greeting in greetings:
            service.logger().info(greeting)
    except ValueError as e:
        service.logger().warn(f"{e}")
    ```

### load_custom_config

`load_custom_config(custom_config: Any, section_name: str)`

This API loads the service's Structured Custom Configuration from local file or the Configuration Provider (if enabled). The Configuration Provider will also be seeded with the custom configuration if service is using the Configuration Provider. See [Custom Configuration](../details/CustomConfiguration.md) for more details. 

### listen_for_custom_config_changes

`listen_for_custom_config_changes(config: Any, section_name: str, changed_callback: Callable[[Any], None])`

This API starts a listener on the Configuration Provider for changes to the specified section of the custom configuration. When changes are received from the Configuration Provider the Application Service will update the config object to apply the updates and then signal that the changes occurred via the `changed_callback` function. See [Custom Configuration](../details/CustomConfiguration.md) for more details.

## Function Pipeline APIs

The following `ApplicationService` APIs allow your service to set the Functions Pipeline and start and stop the Functions Pipeline.

### AppFunction

`AppFunction = Callable[[AppFunctionContext, Any], Tuple[bool, Any]]`

This AppFunction as declared in app_functions_sdk_py.interfaces module defines the signature that all pipeline functions must implement.

### FunctionPipeline

This FunctionPipeline class as defined in app_functions_sdk_py.interfaces module represents the metadata for a functions pipeline instance.

### set_default_functions_pipeline

`set_default_functions_pipeline(*functions: AppFunction)`

This API sets the default functions pipeline with the specified list of Application Functions.  This pipeline is executed for all messages received from the configured trigger. Note that the functions are executed in the order provided in the list.  An error is returned if the list is empty.

!!! example "Example - set_default_functions_pipeline"
    ```python
    import asyncio
    import os
    from typing import Any, Tuple
    from app_functions_sdk_py.contracts import errors
    from app_functions_sdk_py.functions import filters, conversion
    from app_functions_sdk_py.factory import new_app_service
    from app_functions_sdk_py.interfaces import AppFunctionContext
    
    service_key = "app-simple-filter-xml"

    def print_xml_to_console(ctx: AppFunctionContext, data: Any) -> Tuple[bool, Any]:
        """
        Print the XML data to the console
        """
        if data is None:
            return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,"print_xml_to_console: No Data Received")
    
        if isinstance(data, str):
            print(data)
            return True, None
        return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,"print_xml_to_console: Data received is not the expected 'str' type")
    
    if __name__ == "__main__":
        # turn off secure mode for examples. Not recommended for production
        os.environ["EDGEX_SECURITY_SECRET_STORE"] = "false"
    
        # 1) First thing to do is to create a new instance of an EdgeX Application Service.
        service, result = new_app_service(service_key)
        if result is False:
            os._exit(-1)
    
        # Leverage the built-in logging service in EdgeX
        lc = service.logger()
    
        try:
            # 2) shows how to access the application's specific configuration settings.
            device_names = service.get_application_setting_strings("DeviceNames")
            lc.info(f"Filtering for devices {device_names}")
            # 3) This is our pipeline configuration, the collection of functions to execute every time an event is triggered.
            service.set_default_functions_pipeline(
                filters.new_filter_for(filter_values=device_names).filter_by_device_name,
                conversion.Conversion().transform_to_xml,
                print_xml_to_console
            )
            # 4) Lastly, we'll go ahead and tell the SDK to "start" and begin listening for events to trigger the pipeline.
            asyncio.run(service.run())
        except Exception as e:
            lc.error(f"{e}")
            os._exit(-1)
    
        os._exit(0)
    ```

### add_functions_pipeline_for_topics

`add_functions_pipeline_for_topics(pipeline_id: str, topics: List[str], *functions: AppFunction)`

This API adds a functions pipeline with the specified unique `pipeline_id` and list of functions (AppFunction) to be executed when the received topic matches one of the specified pipeline topics. See the [Pipeline Per Topic](../details/PipelinesPerTopics.md) section for more details.

<!-- As App Service Configurable is not implemented with Python SDK, the following API is temporarily commented out
### load_configurable_function_pipelines

`load_configurable_function_pipelines() -> dict[str, FunctionPipeline]`

This API loads the function pipelines (default and per topic) from configuration. An error is raised if the configuration is not valid, i.e. missing required function parameters, invalid function name, etc.

!!! note
    This API is only useful if pipeline is always defined in configuration as is with App Service Configurable.

!!! example "Example - LoadConfigurableFunctionPipelines"
    ```go
    configuredPipelines, err := service.LoadConfigurableFunctionPipelines()
    if err != nil {
        ...
        os.Exit(-1)
    }
    
    ...
    
    for _, pipeline := range configuredPipelines {
        switch pipeline.Id {
        case interfaces.DefaultPipelineId:
            if err = service.SetDefaultFunctionsPipeline(pipeline.Transforms...); err != nil {
                ...
                os.Exit(-1)
            }
        default:
            if err = service.AddFunctionsPipelineForTopic(pipeline.Id, pipeline.Topic, pipeline.Transforms...); err != nil {
                ...
                os.Exit(-1)
            }
        }
    }
    ```
-->
### remove_all_function_pipelines

`remove_all_function_pipelines()`

This API removes all existing functions pipelines previously added via `SetDefaultFunctionsPipeline`, or `AddFunctionsPipelineForTopics`

### run

`run()`

This API starts the configured trigger to allow the Functions Pipeline to execute when the trigger receives data. The internal webserver is also started. This API is implemented as a [native coroutines](https://docs.python.org/3.10/library/asyncio-task.html#coroutines) and must be run through `asyncio.run()`.

!!! example "Example - run"

    ```python
    import asyncio
    import os
    from typing import Any, Tuple
    from app_functions_sdk_py.contracts import errors
    from app_functions_sdk_py.functions import filters, conversion
    from app_functions_sdk_py.factory import new_app_service
    from app_functions_sdk_py.interfaces import AppFunctionContext
    
    ...

    service, result = new_app_service("app-simple")
    if result is False:
        os._exit(-1)

    # Leverage the built-in logging service in EdgeX
    lc = service.logger()

    try:
        service.set_default_functions_pipeline(
            filters.new_filter_for(filter_values=["Random-Integer-Device"]).filter_by_device_name,
            conversion.Conversion().transform_to_xml
        )
        asyncio.run(service.run())
    except Exception as e:
        lc.error(f"{e}")
        os._exit(-1)

    os._exit(0)
    ```

## Secrets APIs

The following `ApplicationService` APIs allow your service retrieve and store secrets from/to the service's SecretStore. <!--See the [Secrets](../details/Secrets.md) advanced topic for more details about using secrets.-->

### secret_provider

`secret_provider() -> SecretProvider`

This API returns reference to the SecretProvider instance. See [Secret Provider API](../../../../security/Ch-SecretProviderApi.md) section for more details.

## Client APIs

The following `ApplicationService` APIs allow your service access the various EdgeX clients and their APIs.

### logger

`logger() -> Logger`

This API returns the `Logger` instance which the service uses to log messages. 

!!! example "Example - logger"

    ```python
    service.logger().info("Hello World")
    service.logger().error(f"Some error occurred: {err}")
    ```

### registry_client

`registry_client() -> Client`

This API returns the Registry Client instance. Note the registry must have been enabled, otherwise this will return None.

### event_client

`event_client() -> EventClientABC`

This API returns the Event Client instance. Note if Core Data is not specified in the Clients configuration, this will return None. Useful for adding, deleting or querying Events.

### reading_client

`reading_client() -> ReadingClientABC`

This API returns the Reading Client instance. Note if Core Data is not specified in the Clients configuration, this will return None. Useful for querying Reading.

### command_client

`command_client() -> CommandClientABC`

This API returns the Command Client instance. Note if Core Command is not specified in the Clients configuration, this will return None. Useful for issuing commands to devices.

<!-- As both NotificationClient and SubscriptionClient are not supported with Python SDK, the following APIs are temporarily commented out
### NotificationClient

`NotificationClient() interfaces.NotificationClient`

This API returns the Notification Client. Note if Support Notifications is not specified in the Clients configuration, this will return nil. See the [Notification Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/notification.go#L17-L44) for more details. Useful for sending notifications.

### SubscriptionClient

`SubscriptionClient() interfaces.SubscriptionClient`

This API returns the Subscription client. Note if Support Notifications is not specified in the Clients configuration, this will return nil. See the [Subscription Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/subscription.go#L17-L35) for more details. Useful for creating notification subscriptions.
-->
### device_service_client

`device_service_client() -> DeviceServiceClientABC`

This API returns the Device Service Client instance. Note if Core Metadata is not specified in the Clients configuration, this will return None. Useful for querying information about a Device Service.

### device_profile_client

`device_profile_client() -> DeviceProfileClientABC`

This API returns the Device Profile Client instance. Note if Core Metadata is not specified in the Clients configuration, this will return None. Useful for querying information about a Device Profile such as Device Resource details.

### device_client

`device_client() -> DeviceClientABC`

This API returns the Device Client instance. Note if Core Metadata is not specified in the Clients configuration, this will return None. Useful for querying list of devices for a specific Device Service or Device Profile.

## Other APIs

### add_custom_route

`add_custom_route(self, route: str, use_auth: bool, handler: Callable, methods: Optional[List[str]] = None)`

This API adds a custom REST route to the application service's internal webserver.  If the route is marked authenticated (`use_auth` is True), it will require an EdgeX JWT when security is enabled.  A reference to the ApplicationService is added to the context that is passed to the handler, which can be retrieved using the `AppService` key. See [Custom REST Endpoints](../details/CustomRestApis.md) advanced topic for more details and example.

### register_custom_trigger_factory

`register_custom_trigger_factory(self, name: str, factory: Callable[[TriggerConfig], Trigger])`

This API registers a trigger factory for a custom trigger to be used. See the [Custom Triggers](https://github.com/IOTechSystems/app-functions-sdk-python/tree/main/examples/custom-trigger) for more details and example.

<!-- Custom Storage is not supported with Python SDK, the following API is temporarily commented out
### RegisterCustomStoreFactory

`RegisterCustomStoreFactory(name string, factory func(cfg DatabaseInfo, cred config.Credentials) (StoreClient, error)) error`

This API registers a factory to construct a custom store client for the [store & forward](../details/StoreAndForward.md) loop.
-->
### MetricsManager

`metrics_manager() MetricsManager`

This API returns the Metrics Manager used to register counter, gauge, gaugeFloat64 or timer metric types from github.com/Lightricks/pyformance

``` python
from pyformance import meters

myCounterMetricName = "MyCounter"
myCounter = meters.Counter("")
myTags = {"Tag1": "Value1"}
service.metrics_manager().register(myCounterMetricName, myCounter, myTags)
```

### publish

`publish(self, data: Any, content_type: str)`

This API pushes data to the EdgeX MessageBus using configured topic and raises an error if the EdgeX MessageBus is disabled in configuration

### publish_with_topic

`publish_with_topic(self, topic: str, data: Any, content_type: str)`

This API pushes data to the EdgeX MessageBus using a given topic and raises an error if the EdgeX MessageBus is disabled in configuration
