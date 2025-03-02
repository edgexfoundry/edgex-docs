---
title: App SDK - Pipeline Function APIs
---

# App Functions SDK for Python - Pipeline Function APIs

As mentioned, an Application Service is built around the idea of functions pipelines. The SDK provides a set of built-in pipeline functions that can be used to build a pipeline. These functions are designed to be used in a pipeline to perform common tasks such as filtering, transforming, and exporting data. Additionally, developers can implement their own custom pipeline functions and add those to their Application Service functions pipeline(s).

Each pipeline function must be a python function and must conform to following signature:

```python
Callable[[AppFunctionContext, Any], Tuple[bool, Any]]
```
For most of the built-in pipelines functions, the common practice is to define a type and a factory function which is used to initialize an instance of the type with the required options. The instances returned by these factory functions give access to their appropriate pipeline function reference when setting up the function pipeline.

!!! example
    ```python
    new_filter_for([] {"Device1", "Device2"}).filter_by_device_name
    ```

## Batching

Included in the SDK is an in-memory batch function that will hold on to your data before continuing the pipeline. There are three functions provided for batching each with their own strategy.

| Factory Method                                                                      | Description                                                                                                                                                                                                                                                                                                                                                                                            |
|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_batch_by_time(time_interval: str) -> BatchConfig                                | This function returns a `BatchConfig` instance with time being the strategy that is used for determining when to release the batched data and continue the pipeline. `time_interval` is the duration to wait (i.e. `10s`). The time begins after the first piece of data is received. If no data has been received no data will be sent forward.                                                       |
| new_batch_by_count(batch_threshold: int) -> BatchConfig                             | This function returns a `BatchConfig` instance with count being the strategy that is used for determining when to release the batched data and continue the pipeline. `batch_threshold` is how many events to hold on to (i.e. `25`). The count begins after the first piece of data is received and once the threshold is met, the batched data will continue forward and the counter will be reset.  |
| new_batch_by_time_and_count(time_interval:str, batch_threshold: int) -> BatchConfig | This function returns a `BatchConfig` instance with a combination of both time and count being the strategy that is used for determining when to release the batched data and continue the pipeline. Whichever occurs first will trigger the data to continue and be reset.                                                                                                                            |

!!! example "Examples"
    ```python
	new_batch_by_time("10s").batch
    new_batch_by_count(10).batch
    new_batch_by_time_and_count("30s", 10).batch
    ```

| Property      | Description                                                                                                                                                                      |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| is_event_data | The `is_event_data` flag, when true, lets this function know that the data being batched is `Events` and to un-marshal the data a `[]Event` prior to returning the batched data. |
| merge_on_send | The `merge_on_send` flag, when true, will merge the `list[bytes]` data to a single`bytes` prior to sending the data to the next function in the pipeline.                        |

!!! example "Batch with `is_event_data` flag set to true."
    ```
    batch := new_batch_by_time_and_count("30s", 10)
    batch.is_event_data = True
    ...
    batch.batch
    ```

!!! example "Batch with `merge_on_send` flag set to true."
    ```
    batch := new_batch_by_time_and_count("30s", 10)
    batch.merge_on_send = true
    ...
    batch.batch
    ```
### Batch

`batch` - This pipeline function will apply the selected strategy in your pipeline. By default, the batched data returned by this function is `list[bytes]`. This is because this function doesn't need to know the type of the individual items batched. It simply marshals the items to JSON if the data isn't already a `bytes`.

!!! warning
    Keep memory usage in mind as you determine the thresholds for both time and count. The larger they are the more memory is required and could lead to performance issue. 

## Compression

There are two compression types included in the SDK that can be added to your pipeline. These transforms return a base64 encoded string as `bytes`.

| Factory Method                    | Description                                                                                              |
|-----------------------------------|----------------------------------------------------------------------------------------------------------|
| new_compression() -> Compression  | This factory function returns a `Compression` instance that is used to access the compression functions. |

### GZIP

`compress_with_gzip`  - This pipeline function will GZIP compresses the receiving data, converts result to base64 encoded string, which is returned as a `bytes` to the pipeline.

!!! example
    ```python
    new_compression().compress_with_gzip
    ```

### ZLIB

`compress_with_zlib` - This pipeline function will ZLIB compresses the receiving data, converts result to base64 encoded string, which is returned as a `bytes` to the pipeline.

!!! example
    ```python
    new_compression().compress_with_zlib
    ```

## Conversion

There are two conversions included in the SDK that can be added to your pipeline. These transforms return a `string`.

| Constructor Method | Description                                                                                                |
|--------------------|------------------------------------------------------------------------------------------------------------|
| Conversion()       | This constructor function returns a `Conversion` instance that is used to access the conversion functions. |

### JSON

`transform_to_json` - This pipeline function receives an `Event` type as defined in app_functions_sdk_py.contracts.dtos.event module and converts it to JSON format and returns the JSON string to the pipeline.

!!! example
    ```python
    Conversion().transform_to_json
    ```

### XML

`transform_to_xml`  - This pipeline function receives an `Event` type as defined in app_functions_sdk_py.contracts.dtos.event module, converts it to XML format and returns the XML string to the pipeline. 

!!! example
    ```python
    Conversion().transform_to_xml
    ```
## Event

This enables the ability to wrap data into an Event/Reading

| Factory Method                                                                                                             | Description                                                                                                                                                                  |
|----------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_event_wrapper_simple_reading(profile_name: str, device_name: str, resource_name: str, value_type: str) -> EventWrapper | This factory function returns an `EventWrapper` instance configured to push a `Simple` reading. The`EventWrapper` instance returned  is used to access core data functions.  |
| new_event_wrapper_binary_reading(profile_name: str, device_name: str, resource_name: str, media_type: str) -> EventWrapper | This factory function returns an `EventWrapper` instance configured to push a `Binary` reading. The `EventWrapper` instance returned  is used to access core data functions. |
| new_event_wrapper_object_reading(profile_name: str, device_name: str, resource_name: str) -> EventWrapper                  | This factory function returns an `EventWrapper` instance configured to push an `Object` reading. The `EventWrapper` instance returned is used to access core data functions. |


### Wrap Into Event

`wrap` - This pipeline function provides the ability to Wrap data in an Event/Reading. The data passed into this function from the pipeline is wrapped in an EdgeX Event with the Event and Reading metadata specified from the factory function options. The function returns the new EdgeX Event with ID populated.

!!! example
    ```python
    new_event_wrapper_simple_reading("my-profile", "my-device", "my-resource", "string").wrap
    ```


## Data Protection

There are two transforms included in the SDK that can be added to your pipeline for data protection. 

### AESProtection

| Constructor Method                                     | Description                                                                                                                      |
|--------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| AESProtection(secret_name: str, secret_value_key: str) | This constructor function returns a `AESProtection` instance initialized with the passed in `secret_name` and `secret_value_key` |

It requires a 64-byte key from secrets which is split in half, the first half used for encryption, the second for generating the signature.

`encrypt`: This pipeline function will encrypt the receiving data using AES256 encryption, signs it with a SHA256 hash and returns a Base64 encode `bytes` of the encrypted data.

!!! example    
    ```python
        AESProtection(secret_name, secret_value_key).encrypt(ctx, data)
    ```

Reading data protected with this function is a multistep process:

- base64 decode
- extract MAC authentication tag from payload (last 32 bytes)
- validate tag - if this step fails decryption should not be attempted
- decrypt ciphertext + remove padding

!!! example "Payload Decryption"
    ```python
    from Cryptodome.Cipher import AES
    from Cryptodome.Hash import HMAC, SHA256
    from Cryptodome.Util.Padding import unpad   
    ...
    def decrypt(encrypted_data, key):
        hex_data = bytes.fromhex(key)
        aes_key = hex_data[0:32]
        hmac_key = hex_data[-32:]
    
        try:
            base64_decoded = base64.b64decode(encrypted_data)
    
            tag = base64_decoded[-32:]
            # the library creates a 11 bytes random nonce
            nonce = base64_decoded[0:11]
            ciphertext = base64_decoded[11:-32]
    
            # Validate the MAc authentication tag, if it fails raise an error
            HMAC.new(hmac_key, digestmod=SHA256).update(nonce + ciphertext).verify(tag)
    
            cipher = AES.new(aes_key, AES.MODE_CCM, nonce=nonce)
            decoded_data = unpad(cipher.decrypt(ciphertext), AES.block_size)
        except (ValueError, KeyError) as e:
            raise ValueError(f"Incorrect decryption") from e
    
        return decoded_data
    ```

## Export

There are two export functions included in the SDK that can be added to your pipeline. 

### HTTP Export

| Factory Method                                                                  | Description                                                                                                                    |
|---------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| new_http_sender(url: str, mime_type: str, persist_on_error: bool) -> HTTPSender | This factory function returns a `HTTPSender` instance initialized with the passed in url, mime type and persistOnError values. |
| new_http_sender_with_options(options: HTTPSenderOptions) -> HTTPSender          | This factory function returns a `HTTPSender`using the passed in `options` to configure it.                                     |

```python
class HTTPSenderOptions:
    """ HTTPSenderOptions is used hold the HTTP request configuration """

    def __init__(self, url: str = "", mime_type: str = "", persist_on_error: bool = False,
                 http_header_name: str = "", secret_name: str = "",
                 secret_value_key: str = "",
                 url_formatter: StringValuesFormatter = default_string_value_formatter,
                 continue_on_send_error: bool = False, return_input_data: bool = False):
        # url specifies the URL of destination
        self.url = url
        # mime_type specifies MimeType to send to destination
        self.mime_type = mime_type
        # persist_on_error enables use of store & forward loop if true
        self.persist_on_error = persist_on_error
        # http_header_name to use for passing configured secret
        self.http_header_name = http_header_name
        # secret_name is the name of the secret in the SecretStore
        self.secret_name = secret_name
        # secret_value_key is the key for the value in the secret data from the SecretStore
        self.secret_value_key = secret_value_key
        # url_formatter specifies custom formatting behavior to be applied to configured URL.
        # If nothing specified, default behavior is to attempt to replace placeholders in the
        # form '{some-context-key}' with the values found in the context storage.
        self.url_formatter = url_formatter  # Assuming StringValuesFormatter is defined elsewhere
        # continue_on_send_error allows execution of subsequent chained senders after errors if true
        self.continue_on_send_error = continue_on_send_error
        # return_input_data enables chaining multiple HTTP senders if true
        self.return_input_data = return_input_data
```

#### HTTP POST

`http_post` - This pipeline function receives data from the previous function in the pipeline and posts the data to the configured endpoint and returns the HTTP response. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the post fails and `persist_on_error=True` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](../details/StoreAndForward.md) for more details. If `return_input_data=True`  the function will return the data that it received instead of the HTTP response. This allows the following function in the pipeline to be another HTTP Export which receives the same data but is configured to send to a different endpoint. When chaining for multiple HTTP Exports you need to decide how to handle errors. Do you want to stop execution of the pipeline or continue so that the next HTTP Export function can attempt to export to its endpoint? This is where `continue_on_send_error` comes in. If set to `True` the error is logged and the function returns the received data for the next function to use. `continue_on_send_error=True` can only be used when `return_input_data=True` and cannot be use when `persist_on_error=True`.

!!! example
    **POST**              
    new_http_sender("https://myendpoint.com","application/json",False).http_post 

    **PUT**                   
    new_http_sender("https://myendpoint.com","application/json",False).http_put 

#### HTTP PUT

`http_put` - This pipeline function operates the same as `http_post` but uses the `PUT` method rather than `POST`. 

#### URL Formatting

The configured URL is dynamically formatted prior to the POST/PUT request. The default formatter (used if `url_formatter` is not specified) simply replaces any placeholder text, `{key-name}`, in the configured URL with matching values from the new `Context Storage`. An error will occur if a specified placeholder does not exist in the `Context Storage`. See the [Context Storage](../AppFunctionContextAPI/#context-storage) documentation for more details on seeded values and storing your own values.

The `url_formatter` option allows you to override the default formatter with your own custom URL formatting scheme.

!!! example
    Export the Events to different endpoints base on their device name              
    `new_http_sender("http://myhost.com/edgex-events/{devicename}","application/json",False)` 

#### HTTP Request Header Parameters

| Method                                               | Description                                                                           |
|------------------------------------------------------|---------------------------------------------------------------------------------------|
| set_http_request_headers(http_request_headers: dict) | This function sets the request header parameters which will be passed in HTTP request |      


!!! example
    http_request_headers = { "Connection": "keep-alive", "From": "user@example.com" }
    `new_http_sender("https://myendpoint.com","application/json",False).set_http_request_headers(http_request_headers)`         

### MQTT Export

| Factory Method                                                                                                                                                        | Description                                                                                                                                                                                                                      |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_mqtt_sender(mqtt_config: MQTTClientConfig, topic_formatter: StringValuesFormatter = default_string_value_formatter, persist_on_error: bool = False) -> MQTTSender | This factory function returns a `MQTTSender` instance initialized with the options specified in the `mqtt_config`, `topic_formatter` and `persist_on_error`. See [Topic Formatting](#topic-formatting) below for more details.   |

To properly construct a MQTTSender using `new_mqtt_sender`, you will need to specify proper MQTT Broker configuration as `matt_config` with type `MQTTClientConfig` as defined in `app_functions_sdk_py.utils.factory.mqtt` module:

!!! example - "Construct a MQTT Sender"
    ```python
    @dataclass
    class MQTTClientConfig:
        """
        MQTTClientConfig is a data class that holds the configuration for an MQTT client.
        """
        # broker_address is the address of the MQTT broker i.e. "test.mosquitto.org"
        broker_address: str
        # topic is the MQTT topic to publish messages to
        topic: str
        # secret_name is the name of the secret in secret provider to retrieve the MQTT credentials
        secret_name: str
        # auth_mode indicates what to use when connecting to the broker. Options are "none", "cacert" , 
        # "usernamepassword", "clientcert". If a CA Cert exists in the secret_name data then it will be 
        # used for all modes except "none".
        auth_mode: str
        # client_id is the client id to use when connecting to the broker
        client_id: str
        # qos is the quality of service to use when publishing messages
        qos: int = 0
        # retain indicates whether the broker should retain messages
        retain: bool = False
        # auto_reconnect indicates whether the client should automatically reconnect to the broker
        auto_reconnect: bool = False
        # skip_verify indicates whether to skip verifying the server's certificate
        skip_verify: bool = False
        # keep_alive is the time in seconds to keep the connection alive
        keep_alive: int = 60  # default keep alive time is 60 seconds in paho mqtt
        # connect_timeout is the time in seconds to wait for the connection to be established
        connect_timeout: float = 5.0  # default connect timeout is 5 seconds in paho mqtt
        # max_reconnect_interval is the maximum time in seconds to wait between reconnections
        max_reconnect_interval: int = 120  # default max reconnect interval is 120 seconds in paho mqtt
        # will is the last will and testament configuration
        will: Optional[WillConfig] = None
    ```

Secrets in the Secret Store may be located at any secret_name however they must have some or all the follow keys at the specified in the secret data:

- `username` - username to connect to the broker
- `password` - password used to connect to the broker
- `clientkey`- client private key in PEM format
- `clientcert` - client cert in PEM format
- `cacert` - ca cert in PEM format

The `auth_mode` setting you choose depends on what secret values above are used. For example, if "none" is specified as auth mode all keys will be ignored. Similarly, if `auth_mode` is set to "clientcert" username and password will be ignored.

| Method                                                                                                         | Description                                                                                                                                                                      |
|----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pre_connect_to_broker(self, lc: Logger, sp: SecretProvider, pre_connect_retry_count: int, retry_interval: int) | Pre-connects to the external MQTT Broker that data will be exported. If this function is not called, then lazy connection will be made when the first data needs to be exported. |

!!! example - "Pre-Connecting to MQTT Broker"
    ```python
    from app_functions_sdk_py.functions import mqtt
    from app_functions_sdk_py.utils.factory.mqtt import MQTTClientConfig
    ...
    mqtt_config = MQTTClientConfig(
            broker_address="test.mosquitto.org",
            client_id="test_client",
            topic="test_topic",
            secret_name="",
            auth_mode="none")

    mqtt_sender = mqtt.new_mqtt_sender(mqtt_config=mqtt_config)
    mqtt_sender.pre_connect_to_broker(service.logger(), service.secret_provider(), 10 , 10)
    service.set_default_functions_pipeline(mqtt_sender.mqtt_send)
    ...
    ```

#### Topic Formatting

The configured Topic is dynamically formatted prior to publishing . The default formatter (used if `topic_formatter` is not specified) simply replaces any placeholder text, `{key-name}`, in the configured `Topic` with matching values from the new `Context Storage`. An error will occur if a specified placeholder does not exist in the `Context Storage`. See the [Context Storage](../AppFunctionContextAPI/#context-storage) documentation for more details on seeded values and storing your own values.

The `topic_formatter` option allows you to override the default formatter with your own custom topic formatting scheme.

## Filtering

There are four basic types of filtering included in the SDK to add to your pipeline. There is also an option to `Filter Out` specific items. These provided filter functions return a type of `Event` as defined in app_functions_sdk_py.contracts.dtos.event module. If filtering results in no remaining data, the pipeline execution for that pass is terminated. If no values are provided for filtering, then data flows through unfiltered.

| Factory Method                                     | Description                                                                                                                                                                                                                                                   |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_filter_for(filter_values: List[str]) -> Filter | This factory function returns a `Filter` instance initialized with the passed in filter values with `filter_out` set to `false`. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values. |
| new_filter_out(filter_values: List[str]) -> Filter | This factory function returns a `Filter` instance initialized with the passed in filter values with `filter_out` set to `true`. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values.  |

```python
class Filter:
    """ Filter houses various the parameters for which filter transforms filter on """
    def __init__(self, filter_values:  List[str], filter_out: bool):
        # Holds the values to be filtered
        self.filter_values = filter_values
        # Determines if items in FilterValues should be filtered out. If set to true all items found in the filter will be removed. If set to false all items found in the filter will be returned. If FilterValues is empty then all items will be returned.
        self.filter_out = filter_out
```

!!! Note
    Either strings or regular expressions are accepted as filter values.
    
### By Profile Name

`filter_by_profile_name` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified profiles names.  

!!! example
    ```python
    from app_functions_sdk_py.functions import filters
    ...
    filter = filters.new_filter_for(filter_values=["Profile1", "Profile2"])
    service.set_default_functions_pipeline(filter.filter_by_profile_name)
    ...
    filter_using_re = filters.new_filter_for(filter_values=["Profile[0-9]+"])
    service.set_default_functions_pipeline(filter_using_re.filter_by_profile_name)
    ...
    ```

### By Device Name

`filter_by_device_name` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified device names.  

!!! example
    ```python
    from app_functions_sdk_py.functions import filters
    ...
    filter = filters.new_filter_for(filter_values=["Device1", "Device2"])
    service.set_default_functions_pipeline(filter.filter_by_device_name)
    ...
    filter_using_re = filters.new_filter_for(filter_values=["Device[0-9]+"])
    service.set_default_functions_pipeline(filter_using_re.filter_by_device_name)
    ...
    ```

### By Source Name

`filter_by_source_name` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified source names.  Source name is either the `resource name` or `command name` responsible for the Event creation.

!!! example
    ```python
    from app_functions_sdk_py.functions import filters
    ...
    filter = filters.new_filter_for(filter_values=["Source1", "Source2"])
    service.set_default_functions_pipeline(filter.filter_by_source_name)
    ...
    filter_using_re = filters.new_filter_for(filter_values=["Source[0-9]+"])
    service.set_default_functions_pipeline(filter_using_re.filter_by_source_name)
    ...
    ```


### By Resource Name

`filter_by_resource_name` - This pipeline function will filter the Event's reading data down to **Readings** that either have (For) or don't have (Out) the specified resource names.  If the result of filtering is zero Readings remaining, the function terminates pipeline execution.

!!! example
    ```python
    from app_functions_sdk_py.functions import filters
    ...
    filter = filters.new_filter_for(filter_values=["Resource1", "Resource2"])
    service.set_default_functions_pipeline(filter.filter_by_resource_name)
    ...
    filter_using_re = filters.new_filter_for(filter_values=["Resource[0-9]+"])
    service.set_default_functions_pipeline(filter_using_re.filter_by_resource_name)
    ...
    ```


## JSON Logic
| Factory Method                                                        | Description                                                                                                                                                                                                                                                        |
|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_json_logic(rule: str) -> Tuple[JSONLogic, Optional[errors.EdgeX]] | This factory function returns a `JSONLogic` instance initialized with the passed in JSON rule. An `errors.EdgeX` will be returned if the `rule` passed in is not a correct JSON string conforming to the specification here: http://jsonlogic.com/operations.html. |

### Evaluate

`evaluate` - This is the pipeline function that will be used in the pipeline to apply the JSON rule to data coming in on the pipeline. If the condition of your rule is met, then the pipeline will continue and the data will continue to flow to the next function in the pipeline. If the condition of your rule is NOT met, then pipeline execution stops. 

!!! example
    ```python
    from app_functions_sdk_py.functions import jsonlogic
    ...
    jslogic = jsonlogic.new_json_logic('{"==": [1, 1]}')
    service.set_default_functions_pipeline(jslogic.evaluate)
    ...
    ```

!!! note
    Only operations that return true or false are supported. See http://jsonlogic.com/operations.html# for the complete list of operations paying attention to return values. Any operator that returns manipulated data is currently not supported. For more advanced scenarios checkout [LF Edge eKuiper](https://github.com/lf-edge/ekuiper).

!!! tip
    Leverage http://jsonlogic.com/play.html to get your rule right before implementing in code. JSON can be a bit tricky to get right in code with all the escaped double quotes.

## Response Data

There is one response data function included in the SDK that can be added to your pipeline. 

| Constructor Method                       | Description                                                                                                         |
|------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| ResponseData(response_content_type: str) | This constructor function returns a `ResponseData` instance initialized with the passed in `response_content_type`. |

### Content Type

`response_content_type` - This property is used to set the content-type of the response.

!!! example
    ```python
    from app_functions_sdk_py.functions import responsedata
    ...
    response_data = responsedata.ResponseData()
    response_data.response_content_type = "application/json"
    ...
    ```

### Set Response Data

`set_response_data` - This pipeline function will receive data sent from the previous function in the pipeline and sets the data as the response data that the pipeline returns to the configured trigger. If configured to use the`EdgeXMessageBus`trigger, the data will be published back to the EdgeX MessageBus as determined by the configuration. Similar, if configured to use the`ExternalMQTT` trigger, the data will be published back to the external MQTT Broker as determined by the configuration. If configured to use `HTTP` trigger the data is returned as the HTTP response. 

!!! note
    Calling `set_response_data` from the Context API in a custom function can be used in place of adding this function to your pipeline.

## Tags

There is one Tags transform included in the SDK that can be added to your pipeline. 

| Factory Method              | Description                                                                                                                                                                                                                                                                                                                     |
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_tags(tags: Any) -> Tags | This factory function returns a `Tags` instance initialized with the passed in collection of generic tag key/value pairs. This `Tags` instance is used to access the following Tags function that will use the specified collection of tag key/value pairs. This allows for generic complex types for the Tag values.           |


### Add Tags

`add_tags` - This pipeline function receives an Edgex `Event` type as defined in app_functions_sdk_py.contracts.dtos.event module and adds the collection of specified tags to the Event's `Tags` collection.

!!! example
    ```python
    from app_functions_sdk_py.functions import tags
    ...
    tags_to_add = {
        "GatewayId": "HoustonStore000123",
        "Coordinates": coordinates,
    }
    tags = tags.new_tags(tags_to_add)
    service.set_default_functions_pipeline(tags.add_tags)
    ...
    ```

## MetricsProcessor

`MetricsProcessor` contains configuration and functions for processing the new `dtos.Metrics` type. 

| Factory Method                                                                                  | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| new_metrics_processor(additional_tags: dict) -> Tuple[MetricsProcessor, Optional[errors.EdgeX]] | This factory function returns a `MetricsProcessor` instance initialized with the passed in collection of `additional_tags` (name/value pairs). This `MetricsProcessor` instance is used to access the following functions that will process a dtos.Metric instance. The `additional_tags` are added as metric tags to the processed data. An `errors.EdgeX` will be returned if any of the `additional_tags` have an invalid name. Currently must be non-blank. |

### ToLineProtocol

`to_line_protocol` - This pipeline function will transform the received `metric.Metric` as defined in app_functions_sdk_py.contracts.dtos to a `Line Protocol` formatted string. See https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/ for details on the `Line Protocol` syntax.

!!! note
    When `to_line_protocol` is the first function in the functions pipeline, the `TargetType` for the service must be set to `metric.Metric`. See [Target Type](../details/TargetType.md) section for details on setting the service's `TargetType`. The Trigger configuration must also be set so  `SubscribeTopics="edgex/telemetry/#"` in order to receive the `metric.Metric` data from other services.

!!! example
    ``` go
    mp, err := NewMetricsProcessor(map[string]string{"MyTag":"MyTagValue"})
    if err != nil {
        ... handle error
    }
    ...
    mp.ToLineProtocol
    ```

!!! warning
    Any service using the `MetricsProcessor` needs to disable its own Telemetry reporting to avoid circular data generation from processing. To do this set the services` Writeable.Telemetry` configuration to:
    ```
    [Writable.Telemetry]
    Interval = "0s" # Don't report any metrics as that would be cyclic processing.
    ```

