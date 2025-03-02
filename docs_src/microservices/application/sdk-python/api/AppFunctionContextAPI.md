---
title: App SDK - App Function Context API
---

# App Functions SDK for Python - App Function Context API

The context parameter passed to each function/transform provides operations and data associated with each execution of the pipeline. 

Let's take a look at its API:

```python
class AppFunctionContext(ABC):
    """
    An abstract base class that defines the interface for an application function context.

    This class provides an interface for cloning the context, getting and setting response data and
    content type, triggering retry for failed data, getting the secret provider, and getting the
    logger.

    Methods:
        clone() -> 'AppFunctionContext': Clones the context.
        correlation_id() -> str: Gets the correlation ID.
        input_content_type() -> str: Gets the input content type.
        set_response_data(data: bytes): Sets the response data.
        response_data() -> bytes: Gets the response data.
        set_response_content_type(content_type: str): Sets the response content type.
        response_content_type() -> str: Gets the response content type.
        set_retry_data(data: bytes): Sets the retry data.
        trigger_retry_failed_data(): Triggers retry for failed data.
        secret_provider() -> SecretProvider: Gets the secret provider.
        logger() -> 'Logger': Gets the logger.
    """

    @abstractmethod
    def clone(self) -> 'AppFunctionContext':
        """
        Clones the context.

        Returns:
            A clone of the context.
        """

    @abstractmethod
    def correlation_id(self) -> str:
        """
        Gets the correlation ID.

        Returns:
            The correlation ID.
        """

    @abstractmethod
    def set_correlation_id(self, correlation_id: str):
        """
        Sets the correlation ID.
        """

    @abstractmethod
    def input_content_type(self) -> str:
        """
        Gets the input content type.

        Returns:
            The input content type.
        """

    @abstractmethod
    def set_input_content_type(self, input_content_type: str):
        """
        Sets the input content type.
        """

    @abstractmethod
    def set_response_data(self, data: bytes):
        """
        Sets the response data.

        Args:
            data: The response data.
        """

    @abstractmethod
    def response_data(self) -> bytes:
        """
        Gets the response data.

        Returns:
            The response data.
        """

    @abstractmethod
    def set_response_content_type(self, content_type: str):
        """
        Sets the response content type.

        Args:
            content_type: The response content type.
        """

    @abstractmethod
    def response_content_type(self) -> str:
        """
        Gets the response content type.

        Returns:
            The response content type.
        """

    @abstractmethod
    def set_retry_data(self, data: bytes):
        """
        Sets the retry data.

        Args:
            data: The retry data.
        """

    @abstractmethod
    def retry_data(self) -> bytes:
        """
        Gets the retry data.
        """

    @abstractmethod
    def trigger_retry_failed_data(self):
        """
        Triggers retry for failed data.
        """

    @abstractmethod
    def secret_provider(self) -> SecretProvider:
        """
        Gets the secret provider.

        Returns:
            The secret provider.
        """

    @abstractmethod
    def logger(self) -> 'Logger':
        """
        Gets the logger.

        Returns:
            The logger.
        """

    @abstractmethod
    def pipeline_id(self) -> str:
        """
        Gets the pipeline ID.

        Returns:
            The pipeline ID.
        """

    @abstractmethod
    def add_value(self, key: str, value: str):
        """
        Adds the key and value to context_data.

        Returns:
            The pipeline ID.
        """

    @abstractmethod
    def remove_value(self, key: str):
        """
        Deletes a value stored in the context at the given key
        """

    @abstractmethod
    def get_value(self, key: str) -> Tuple[str, bool]:
        """
        Attempts to retrieve a value stored in the context at the given key
        """

    @abstractmethod
    def get_values(self) -> dict:
        """
        GetAllValues returns a read-only copy of all data stored in the context
        """

    @abstractmethod
    def apply_values(self, str_format: str) -> str:
        """
        apply_values looks in the provided string for placeholders of the form
        '{any-value-key}' and attempts to replace with the value stored under
        the key in context storage.  An error will be returned if any placeholders
        are not matched to a value in the context.
        """

    @abstractmethod
    def event_client(self) -> EventClientABC:
        """
        event_client returns the event client instance
        """

    @abstractmethod
    def reading_client(self) -> ReadingClientABC:
        """
        reading_client returns the reading client instance
        """

    @abstractmethod
    def command_client(self) -> CommandClientABC:
        """
        command_client returns the command client instance
        """

    @abstractmethod
    def device_service_client(self) -> DeviceServiceClientABC:
        """
        device_service_client returns the device service client instance
        """
```

## Response Data

### set_response_data
`set_response_data(data: bytes)`

This API sets the response data that will be returned to the trigger when pipeline execution is complete.

### response_data
`response_data() -> bytes`

This API returns the data that will be returned to the trigger when pipeline execution is complete.

### set_response_content_type
`set_response_content_type(content_type: str)`

This API sets the content type that will be returned to the trigger when pipeline execution is complete.

### response_content_type
`response_content_type() -> str`

This API returns the content type that will be returned to the trigger when pipeline execution is complete.

## Clients

### logger

`logger() -> 'Logger'`

Returns a `Logger` to leverage logging libraries/service utilized throughout the EdgeX framework. The SDK has initialized everything, so it can be used to log `TRACE`, `DEBUG`, `WARN`, `INFO`, and `ERROR` messages as appropriate. 

!!! example "Example - Logger"
    ```python
    ctx.logger().info("Hello World")
    ctx.logger().error(f"Some error occurred: {err}")
    ```

### event_client

`event_client() -> EventClientABC`

Returns an `EventClient` to leverage Core Data's `Event` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/event.py) for more details. This client is useful for querying events. Note if Core Data is not specified in the Clients configuration, this will return None.

### reading_client

`reading_client() -> ReadingClientABC`

Returns an `ReadingClient` to leverage Core Data's `Reading` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/reading.py) for more details. This client is useful for querying readings. Note if Core Data is not specified in the Clients configuration, this will return None.

### command_client

`command_client() -> CommandClientABC`

Returns a `CommandClient`  to leverage Core Command's `Command` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/command.py) for more details. Useful for sending commands to devices. Note if Core Command is not specified in the Clients configuration, this will return None.

### device_service_client

`device_service_client() -> DeviceServiceClientABC`

Returns a `DeviceServiceClient` to leverage Core Metadata's `DeviceService` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/deviceservice.py) for more details. Useful for querying information about Device Services. Note if Core Metadata is not specified in the Clients configuration, this will return None. 

### device_profile_client

`device_profile_client() -> DeviceProfileClientABC`

Returns a `DeviceProfileClient` to leverage Core Metadata's `DeviceProfile` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/deviceprofile.py) for more details. Useful for querying information about Device Profiles and is used by the `GetDeviceResource` helper function below. Note if Core Metadata is not specified in the Clients configuration, this will return None. 

### device_client

`device_client() -> DeviceClientABC`

Returns a `DeviceClient` to leverage Core Metadata's `Device` API. See [interface definition](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/src/app_functions_sdk_py/contracts/clients/interfaces/device.py) for more details. Useful for querying information about Devices. Note if Core Metadata is not specified in the Clients configuration, this will return None. 

### Note about Clients

Each of the clients above is only initialized if the Clients section of the configuration contains an entry for the service associated with the Client API. If it isn't in the configuration the client will be `None`. Your code must check for `None` to avoid runtime error in case it is missing from the configuration. Only add the clients to your configuration that your Application Service will actually be using. The following is an example `Clients` section of a configuration.yaml with all supported clients specified:

!!! example "Example - Client Configuration Section"
    ```yaml
    Clients:
      core-data:
        Protocol: http
        Host: localhost
        Port: 59880
    
      core-command:
        Protocol: http
        Host: localhost
        Port: 59882
    ```

!!! note
    Core Metadata client is required and provided by the App Services Common Configuration, so it is not included in the above example.

## Context Storage
The context API exposes a dict-like interface that can be used to store custom data specific to a given pipeline execution.  This data is persisted for retry if needed.  Currently only strings are supported, and keys are treated as case-insensitive.  

There following values are seeded into the Context Storage when an Event is received:

- Profile Name (key to retrieve value is `profilename`)
- Device Name  (key to retrieve value is `devicename`)
- Source Name  (key to retrieve value is `sourcename`)
- Received Topic  (key to retrieve value is `receivedtopic`)

!!! note
    Received Topic only available when the message was received from the Edgex MessageBus or External MQTT triggers.

Storage can be accessed using the following methods:

### add_value
`add_value(key: str, value: str)`

This API stores a value for access within a pipeline execution

### remove_value
`remove_value(key: str)`

This API deletes a value stored in the context at the given key

### get_value
`get_value(key: str) -> Tuple[str, bool]`

This API attempts to retrieve a value stored in the context at the given key.  The return value is a tuple containing the value and a boolean indicating if the key was found in the context. If the given key is not found, an empty string and False will be returned.

### get_values
`get_values() -> dict`

This API returns a read-only copy of all data stored in the context

### apply_values
`apply_values(str_format: str) -> str`

This API will replace placeholders of the form `{context-key-name}` with the value found in the context with key `context-key-name`.  Note that key matching is case-insensitive.  An error will be raised if any placeholders in the provided string do NOT have a corresponding entry in the context storage dict.

## Secrets

### SecretProvider

`SecretProvider() interfaces.SecretProvider`

This API returns reference to the SecretProvider instance with following APIs:
```python
class SecretProvider(ABC):
    """
    An abstract base class that defines the interface for a secret provider.

    This class provides an interface for storing and retrieving secrets, checking the last update
    time of secrets, listing secret names, checking the existence of secrets, and registering or
    deregistering secret update callbacks.

    Methods:
        store_secrets(secret_name: str, secrets: Secrets): Stores secrets.
        get_secrets(secret_name: str, *secret_keys: str) -> Secrets: Retrieves secrets.
        secrets_last_updated() -> datetime: Checks the last update time of secrets.
        list_secret_names() -> List[str]: Lists secret names.
        has_secrets(secret_name: str) -> bool: Checks the existence of secrets.
        register_secret_update_callback(secret_name: str, callback: Callable[[str], None]):
        Registers a secret update callback.
        deregister_secret_update_callback(secret_name: str): Deregisters a secret update callback.
    """

    @abstractmethod
    def store_secrets(self, secret_name: str, secrets: Secrets):
        """
        Stores secrets.

        Args:
            secret_name: The name of the secret.
            secrets: The secrets to be stored.
        """

    @abstractmethod
    def get_secrets(self, secret_name: str, *secret_keys: str) -> Secrets:
        """
        Retrieves secrets.

        Args:
            secret_name: The name of the secret.
            secret_keys: The keys of the secrets to be retrieved.

        Returns:
            The retrieved secrets.
        """

    @abstractmethod
    def secrets_last_updated(self) -> datetime:
        """
        Checks the last update time of secrets.

        Returns:
            The last update time of secrets.
        """

    @abstractmethod
    def list_secret_names(self) -> List[str]:
        """
        Lists secret names.

        Returns:
            A list of secret names.
        """

    @abstractmethod
    def has_secret(self, secret_name: str) -> bool:
        """
        Checks the existence of secrets.

        Args:
            secret_name: The name of the secret.

        Returns:
            True if the secret exists, False otherwise.
        """

    @abstractmethod
    def register_secret_update_callback(self, secret_name: str, callback: Callable[[str], None]):
        """
        Registers a secret update callback.

        Args:
            secret_name: The name of the secret.
            callback: The callback to be registered.
        """

    @abstractmethod
    def deregister_secret_update_callback(self, secret_name: str):
        """
        Deregisters a secret update callback.

        Args:
            secret_name: The name of the secret.
        """
```

## Store and Forward

The APIs in this section are related to the Store and Forward capability. See the [Store and Forward](../details/StoreAndForward.md) section for more details.

### set_retry_data

`set_retry_data(data: bytes)`

This method can be used to store data for later retry. This is useful when creating a custom export function that needs to retry on failure. The payload data will be stored for later retry based on `Store and Forward` configuration. When the retry is triggered, the function pipeline will be re-executed starting with the function that called this API. That function will be passed the stored data, so it is important that all transformations occur in functions prior to the export function. The `Context` will also be restored to the state when the function called this API. See [Store and Forward](../details/StoreAndForward.md) for more details.

!!! note
    `Store and Forward` must be enabled when calling this API, otherwise the data is ignored.

### trigger_retry_failed_data

`trigger_retry_failed_data()`

This method sets the flag to trigger retry of failed data once the current pipeline execution has completed. This method should only be called when the export of data was successful, which indicates that the recipient is accepting data. This allows the failed data to be retried as soon as the recipient is back on-line rather than waiting for the configured retry interval to expire.

!!! note
    `Store and Forward` must be enabled and failed data must be present, otherwise the call to this API is ignored.

## Miscellaneous

### clone

`clone() -> AppFunctionContext`

This method returns a copy of the context that can be mutated independently where appropriate.  This can be useful when running operations that take AppFunctionContext in parallel.

### correlation_id

`correlation_id() -> str`

This API returns the ID used to track the EdgeX event through entire EdgeX framework.

### pipeline_id

`pipeline_id() -> str`

This API returns the ID of the pipeline currently executing. Useful when logging messages from pipeline functions so the message contain the ID of the pipeline that executed the pipeline function.

### input_content_type

`input_content_type() -> str`

This API returns the content type of the data that initiated the pipeline execution. Only useful when the TargetType for the pipeline is []byte, otherwise the data will be the type specified by TargetType.

### get_device_resource
`get_device_resource(device_name: str, resource_name: str) -> DeviceResource`

This API retrieves the DeviceResource for the given profile / resource name. Results are cached to minimize HTTP traffic to core-metadata.

### metrics_manager

`metrics_manager() -> MetricsManager`

This API returns the Metrics Manager used to register various metric types, such as `counter`, `gauge`, `gaugeFloat64`, or `timer`.

!!! note
    Note that `counter`, `gauge`, and `timer` are metric types as implemented in [PyFormance](https://github.com/Lightricks/pyformance), and `gaugeFloat64` is an extended metric type as implemented by app_functions_sdk_py.

```python
from pyformance import meters
from app_functions_sdk_py.interfaces import AppFunctionContext

def register_my_counter_metric(ctx: AppFunctionContext):
    counter_metric_name = "MyCounter"
    my_counter = meters.Counter("")
    my_tags = {"Tag1": "Value1"}
    ctx.metrics_manager().register(counter_metric_name, my_counter, my_tags)
```


### publish

`publish(data: Any, content_type: str)`

This API pushes data to the EdgeX MessageBus using configured topic and raises an error if the EdgeX MessageBus is disabled in configuration

### publish_with_topic

`publish_with_topic(topic: str, data: Any, content_type: str)`

This API pushes data to the EdgeX MessageBus using a given topic and raises an error if the EdgeX MessageBus is disabled in configuration
