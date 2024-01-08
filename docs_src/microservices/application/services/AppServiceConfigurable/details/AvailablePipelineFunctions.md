---
title: App Service Configurable - Available Pipeline Functions
---

# App Service Configurable - Available Pipeline Functions

Below are the functions that are available to use in the `Writable.Pipeline` section of the configuration. 
The function names below can be added to the `Writable.Pipeline.ExecutionOrder` setting (comma separated list) and 
must also be present or added to the `Writable.Pipeline.Functions` section as `{FunctionName}`. 
The functions will also have the `{FunctionName}.Parameters:` section where the function's parameters are configured. 
Please refer to the [Getting Started](../../../GettingStarted.md) section for an example.

!!! note
    The `Parameters` section for each function is a key/value map of `string` values. So even tough the parameter is referred to as an Integer or Boolean, it has to be specified as a valid string representation, e.g. "20" or "true".

Please refer to the function's detailed documentation by clicking the function name below.

## [AddTags](../../../sdk/api/BuiltInPipelineFunctions.md#tags)

**Parameters**

| Name | Description                                                                                                |
|------|------------------------------------------------------------------------------------------------------------|
| tags | String containing comma separated list of tag key/value pairs. The tag key/value pairs are colon separated |

!!! example
    ```yaml
    AddTags:
      Parameters:
        tags: "GatewayId:HoustonStore000123,Latitude:29.630771,Longitude:-95.377603"
    ```

## [Batch](../../../sdk/api/BuiltInPipelineFunctions.md#batching)

**Parameters**

| Name           | Description                                                                                                                                                                                        |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Mode           | The batch mode to use. can be 'bycount', 'bytime' or 'bytimecount'                                                                                                                                 |
| BatchThreshold | Number of items to batch before sending batched items to the next function in the pipeline. Used with  'bycount' and 'bytimecount' modes                                                           |
| TimeInterval   | Amount of time to batch before sending batched items to the next function in the pipeline. Used with  'bytime' and 'bytimecount' modes                                                             |
| IsEventData    | If true, specifies that the data being batched is `Events` and to un-marshal the batched data to `[]Event` prior to returning the batched data. By default the batched data returned is `[][]byte` |
| MergeOnSend    | If true, specifies that the data being batched is to be merged to a single `[]byte` prior to returning the batched data. By default the batched data returned is `[][]byte`                        |

!!! example
    ```yaml
    Batch:
      Parameters:
        Mode: "bytimecount" # can be "bycount", "bytime" or "bytimecount"
        BatchThreshold: "30"
        TimeInterval: "60s"
        IsEventData: "false"
        MergeOnSend: "false"     
    or
    Batch:
      Parameters:
        Mode: "bytimecount" # can be "bycount", "bytime" or "bytimecount"
        BatchThreshold: "30"
        TimeInterval: "60s"
        IsEventData: "true"
        MergeOnSend: "false"    
    or
    Batch:
      Parameters:
        Mode: "bytimecount" # can be "bycount", "bytime" or "bytimecount"
        BatchThreshold: "30"
        TimeInterval: "60s"
        IsEventData: "false"
        MergeOnSend: "true"
    ```

## [Compress](../../../sdk/api/BuiltInPipelineFunctions.md#compression)

**Parameters**

| Name      | Description                                            |
|-----------|--------------------------------------------------------|
| Algorithm | Compression algorithm to use.  Can be 'gzip' or 'zlib' |

!!! example
    ```yaml
    Compress:
      Parameters:
        Algorithm: "gzip"
    ```

## [Encrypt](../../../sdk/api/BuiltInPipelineFunctions.md#data-protection)

**Parameters**

| Name           | Description                                                                  |
|----------------|------------------------------------------------------------------------------|
| Algorithm      | Always set to `AES256`                                                       |
| SecretName     | Name of the secret in the `Secret Store` where the encryption key is located |
| SecretValueKey | Key of the secret data for the encryption key in the secret's data           |

!!! example
    ```yaml
    # Encrypt with key pulled from Secret Store
    Encrypt:
      Parameters:
        Algorithm: "aes256"
        SecretName: "aes"
        SecretValueKey: "key"
    ```

## [FilterByDeviceName](../../../sdk/api/BuiltInPipelineFunctions.md#by-device-name)

**Parameters**

| Name        | Description                                                                                     |
|-------------|-------------------------------------------------------------------------------------------------|
| DeviceNames | Comma separated list of device names or regular expressions for filtering                       |
| FilterOut   | Boolean indicating if the data matching the device names should be filtered out or filtered for |

!!! example
    ```yaml
    FilterByDeviceName:
      Parameters:
        DeviceNames: "Random-Float-Device,Random-Integer-Device"
        FilterOut: "false"
    or
    FilterByDeviceName:
      Parameters:
        DeviceNames: "[a-zA-Z-]+(Integer-)[a-zA-Z-]+"
        FilterOut: "true"
    ```

## [FilterByProfileName](../../../sdk/api/BuiltInPipelineFunctions.md#by-profile-name)

**Parameters**

| Name         | Description                                                                                      |
|--------------|--------------------------------------------------------------------------------------------------|
| ProfileNames | Comma separated list of profile names or regular expressions for filtering                       |
| FilterOut    | Boolean indicating if the data matching the profile names should be filtered out or filtered for |

!!! example
    ```yaml
    FilterByProfileName:
      Parameters:
        ProfileNames: "Random-Float-Device, Random-Integer-Device"
        FilterOut: "false"
    or
    FilterByProfileName:
      Parameters:
        ProfileNames: "(Random-)[a-zA-Z-]+"
        FilterOut: "false"
    ```

## [FilterByResourceName](../../../sdk/api/BuiltInPipelineFunctions.md#by-resource-name)

**Parameters**

| Name          | Description                                                                                        |
|---------------|----------------------------------------------------------------------------------------------------|
| ResourceNames | Comma separated list of resource names or regular expressions for filtering                        |
| FilterOut     | Boolean indicating if the data matching the resource  names should be filtered out or filtered for |

!!! example
    ```yaml
    FilterByResourceName:
      Parameters:
        ResourceNames: "Int8, Int64"
        FilterOut: "true"
    or
    FilterByResourceName:
      Parameters:
        ResourceNames: "(Int)[0-9]+"
        FilterOut: "false"
    ```

## [FilterBySourceName](../../../sdk/api/BuiltInPipelineFunctions.md#by-source-name)

**Parameters**

| Name        | Description                                                                                                                                                          |
|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SourceNames | Comma separated list of source names or regular expressions for filtering. Source name is either the device command name or the resource name that created the Event |
| FilterOut   | Boolean indicating if the data matching the source names should be filtered out or filtered for                                                                      |

!!! example
    ```yaml
    FilterBySourceName:
      Parameters:
        SourceNames: "Bool, BoolArray"
        FilterOut: "false"
    ```

## [HTTPExport](../../../sdk/api/BuiltInPipelineFunctions.md#http-export)

**Parameters**

| Name                | Description                                                                                                      |
|---------------------|------------------------------------------------------------------------------------------------------------------|
| Method              | HTTP Method to use. Can be `post` or `put`                                                                       |
| Url                 | HTTP endpoint to POST/PUT the data                                                                               |
| PersistOnError      | Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true" |
| ContinueOnSendError | For chained multi destination exports. If true continues after send error so next export function executes       |
| ReturnInputData     | For chained multi destination exports. If true, passes the input data to next export function                    |
| MimeType            | (**Optional**) mime type for the data. Defaults to `application/json` if not set                                 |
| HeaderName          | (**Optional**) Name of the header key to add to the HTTP he                                                      |
| SecretName          | (**Optional**) Name of the secret in the `Secret Store` where the header value is stored                         |
| SecretValueKey      | (**Optional**) Key for the header value in the secret data                                                       |
| HttpRequestHeaders  | (**Optional**) HTTP Request header parameters in json format                                                     |

!!! example
    ```yaml
    # Simple HTTP Export
    HTTPExport:
      Parameters:
        Method: "post"
        MimeType: "application/xml"
        Url: "http://my.api.net/edgexdata"
    ```
    ```yaml
    # HTTP Export with multiple HTTP Request header Parameters
    HTTPExport:
      Parameters:
        Method: "post"
        MimeType: "application/xml"
        Url: "http://my.api.net/edgexdata"
        HttpRequestHeaders: "{"Connection": "keep-alive", "From": "[user@example.com](mailto:user@example.com)" }"
    ```
    ```yaml
    # HTTP Export with secret header data pull from Secret Store
    HTTPExport:
      Parameters:
        Method: "post"
        MimeType: "application/xml"
        Url: "http://my.api.net/edgexdata"
        HeaderName: "MyApiKey"
        SecretName: "http"
        SecretValueKey: "apikey"
    ```
    ```yaml
    # Http Export to multiple destinations
    Writable:
      Pipeline:
        ExecutionOrder: "HTTPExport1, HTTPExport2"
        Functions:
          HTTPExport1:
            Parameters:
              Method: "post"
              MimeType: "application/xml"
              Url: "http://my.api1.net/edgexdata2"
              ContinueOnSendError: "true"
              ReturnInputData: "true"
          HTTPExport2:
            Parameters:
              Method: "put"
              MimeType: "application/xml"
              Url: "http://my.api2.net/edgexdata2"
    ```

## [JSONLogic](../../../sdk/api/BuiltInPipelineFunctions.md#json-logic)

**Parameters**

| Name | Description                                                            |
|------|------------------------------------------------------------------------|
| Rule | The JSON formatted rule that with be executed on the data by JSONLogic |

!!! example
    ```yaml
    JSONLogic:
      Parameters:
        Rule: "{ \"and\" : [{\"<\" : [{ \"var\" : \"temp\" }, 110 ]}, {\"==\" : [{ \"var\" : \"sensor.type\" }, \"temperature\" ]} ] }"
    ```

## [MQTTExport](../../../sdk/api/BuiltInPipelineFunctions.md#mqtt-export)

**Parameters**

| Name                    | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| BrokerAddress           | URL specify the address of the MQTT Broker                   |
| Topic                   | Topic to publish the data                                    |
| ClientId                | Id to use when connecting to the MQTT Broker                 |
| Qos                     | MQTT Quality of Service (QOS) setting to use (0, 1 or 2). Please refer [**here**](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/qos.html) for more details on QOS values |
| AutoReconnect           | Boolean specifying if reconnect should be automatic if connection to MQTT broker is lost. |
| MaxReconnectInterval    | Time duration string that specifies the maximum duration to wait before trying to reconnect. Defaults to 60s if not specified. |
| Retain                  | Boolean  specifying if the MQTT Broker should save the last message published as the “Last Good Message” on that topic |
| SkipVerify              | Boolean indicating if the certificate verification should be skipped |
| PersistOnError          | Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true" |
| AuthMode                | Mode of authentication to use when connecting to the MQTT Broker. Valid values are: |
|                         | **none** - No authentication required                        |
|                         | **usernamepassword** - Use username and password authentication. The Secret Store (Vault or [InsecureSecrets](../../../Configuration.md#writable)) must contain the `username` and `password` secrets |
|                         | **clientcert** - Use Client Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../../../Configuration.md#writable)) must contain the `clientkey` and `clientcert` secrets |
|                         | **cacert** - Use CA Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../../../Configuration.md#writable)) must contain the `cacert` secret |
| SecretName              | Name of the  secret in the SecretStore where authentication secrets are stored |
| WillEnabled             | Enables Last Will Capability. See for [MQTT Last Will](https://cedalo.com/blog/mqtt-last-will-explained-and-example) more details. |
| WillTopic               | Topic Last Will messages is publish                          |
| WillPayload             | Last Will messages to be published when service disconnects from broker |
| WillRetain              | Boolean  specifying if the MQTT Broker should save the last message published as the “Last Good Message” on the Will topic |
| WillQos                 | MQTT Quality of Service (QOS) setting to use (0, 1 or 2) for Last Will Message. |
| PreConnect              | Boolean that indicates if the MQTT Broker connection should be established on initialization. Default is false which results in lazy connection when first data needs to be exported. |
| PreConnectRetryCount    | Specifies the number of times to attempt to pre-connect to the MQTT Broker. If connection is never made, MQTT export reverts to using lazy connect. Defaults to 6 if not specified. |
| PreConnectRetryInterval | Time duration string that specifies the amount of time to wait between pre-connect attempts. Defaults to 10s if not specified. |

!!! note
    `Authmode=cacert` is only needed when client authentication (e.g. `usernamepassword`) is not required, but a CA Cert is needed to validate the broker's SSL/TLS cert.

!!! edgey "EdgeX 3.1"
    Last Will capability is new in EdgeX 3.1

!!! example
    ```yaml
    # Simple MQTT Export
    MQTTExport:
      Parameters:
        BrokerAddress: "tcps://localhost:8883"
        Topic: "mytopic"
        ClientId: "myclientid"
    ```
    ```yaml
    # MQTT Export with auth credentials pull from the Secret Store
    MQTTExport:
      Parameters:
        BrokerAddress: "tcps://my-broker-host.com:8883"
        Topic: "mytopic"
        ClientId: "myclientid"
        Qos: "2"
        AutoReconnect: "true"
        Retain: "true"
        SkipVerify: "false"
        PersistOnError: "true"
        AuthMode: "usernamepassword"
        SecretName: "mqtt"
    ```
    ```yaml
    # MQTT Export with Will Options
    MQTTExport:
      Parameters:
        BrokerAddress: "tcps://my-broker-host.com:8883"
        Topic: "mytopic"
        ClientId: "myclientid"
        Qos: "2"
        AutoReconnect: "true"
        Retain: "true"
        SkipVerify: "false"
        PersistOnError: "true"
        AuthMode: "none"
        WillEnabled: "true"
        WillPayload: "serviceX has exited"
        WillQos: "2"
        WillRetained: "true"
        WillTopic: "serviceX/last/will"
    ```
    ```yaml
    # MQTT Export with pre-connect and MaxReconnectInterval
    MQTTExport:
      Parameters:
        BrokerAddress: "tcps://my-broker-host.com:8883"
        Topic: "mytopic"
        ClientId: "myclientid"
        Qos: "2"
        AutoReconnect: "true"
        MaxReconnectInterval: "15s"
        Retain: "true"
        SkipVerify: "false"
        PersistOnError: "true"
        AuthMode: "none"
        PreConnect: "true"
        PreConnectRetryCount: "10"
        PreConnectRetryInterval: "2s"
    ```

## [SetResponseData](../../../sdk/api/BuiltInPipelineFunctions.md#set-response-data)

**Parameters**

| Name                | Description                                                                                       |
|---------------------|---------------------------------------------------------------------------------------------------|
| ResponseContentType | (**Optional**) Used to specify content-type header for response. Default to JSON if not specified |

!!! example
    ```yaml
    SetResponseData:
      Parameters:
        ResponseContentType: "application/json"
    ```

## [Transform](../../../sdk/api/BuiltInPipelineFunctions.md#conversion)

**Parameters**

| Name | Description                                               |
|------|-----------------------------------------------------------|
| Type | Type of transformation to perform. Can be 'xml' or 'json' |

!!! example
    ```yaml
    Transform:
      Parameters:
        Type: "xml"
    ```

## [ToLineProtocol](../../../sdk/api/BuiltInPipelineFunctions.md#tolineprotocol)

**Parameters**

| Name | Description                                                                                            |
|------|--------------------------------------------------------------------------------------------------------|
| Tags | (**Optional**) Comma separated list of additional tags to add to the metric in to form "tag:value,..." |

!!! example
    ```yaml
    ToLineProtocol:
      Parameters:
        Tags: "" # optional comma separated list of additional tags to add to the metric in to form "tag:value,..."
    ```

!!! note
    The new `TargetType` setting must be set to "metric" when using this function. See the [Metric TargetType](../../../sdk/details/TargetType.md#metric-targettype) section above for more details.

## [WrapIntoEvent](../../../sdk/api/BuiltInPipelineFunctions.md#wrap-into-event)

**Parameters**

| Name         | Description                                                                                    |
|--------------|------------------------------------------------------------------------------------------------|
| ProfileName  | Profile name to use for the new Event                                                          |
| DeviceName   | Device name to use for  the new Event                                                          |
| ResourceName | Resource name name to use for  the new Event's `SourceName` and Reading's `ResourceName`       |
| ValueType    | Value type to use  the new Event Reading's value                                               |
| MediaType    | Media type to use the new Event Reading's value type. Required when the value type is `Binary` |

!!! example
    ```yaml
    WrapIntoEvent:
      Parameters:
        ProfileName: "MyProfile"
        DeviceName: "MyDevice"
        ResourceName: "SomeResource"
        ValueType: "String"
        MediaType: ""  # Required only when ValueType=Binary
    ```

## Multiple Instances of a Function

Multiple instances of the same configurable pipeline function can be specified,  configured differently and used together in the functions pipeline. The names specified only need to start with a built-in configurable pipeline function name. See the [HttpExport](#httpexport) section below for an example.