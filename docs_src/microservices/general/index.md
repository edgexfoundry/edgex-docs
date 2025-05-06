# Cross Cutting Concerns

## Event Tagging

In an edge solution, it is likely that several instances of EdgeX are all sending edge data into a central location (enterprise system, cloud provider, etc.)

![image](MultipleInstances.png)

In these circumstances, it will be critical to associate the data to its origin.  That origin could be specified by the GPS location of the sensor, the name or identification of the sensor, the name or identification of some edge gateway that originally collected the data, or many other means.

EdgeX provides the means to “tag” the event data from any point in the system.  The Event object has a `Tags` property which is a key/value pair map that allows any service that creates or otherwise handles events to add custom information to the Event in order to help identify its origin or otherwise label it before it is sent to the [north side](../../general/Definitions.md#south-and-north-side).

For example, a device service could populate the `Tags` property with latitude and longitude key/value pairs of the physical location of the sensor when the Event is created to send sensed information to Core Data.

### Application Service Configurable

When the Event gets to the [Application Service Configurable](../application/services/AppServiceConfigurable/Purpose.md), for example, the service has an optional function (defined by `Writable.Pipeline.Functions.AddTags` in configuration) that will add additional key/value pair to the Event `Tags`.  The key and value for the additional tag are provided in configuration (as shown by the example below).  Multiple tags can be provide separated by commas.

```yaml
    AddTags:
      Parameters:
        tags: "GatewayId:HoustonStore000123,Latitude:29.630771,Longitude:-95.377603"
```

### Custom Application Service 

In the case, of a custom [application service](../application/ApplicationServices.md), an AddTags function can be used to 
add a collection of specified tags to the Event's Tags collection (see [Built in Transforms/Functions](../application/sdk/api/BuiltInPipelineFunctions.md#add-tags))

If the Event already has `Tags` when it arrives at the application service, then configured tags will be added to the `Tags` map.  If the configured tags have the same key as an existing key in the `Tags` map, then the configured key/value will override what is already in the Event `Tags` map.

## Service Metrics

All services have the ability to collect [Common Service Metrics](#common-service-metrics), only **Core Data**, **Application Services** and **Device Services** are collecting additional service specific metrics. Additional service metrics will be added to all services in future releases.  See `Writable.Telemetry` at [Common Configuration](../configuration/CommonConfiguration/#configuration-properties) for details on configuring the reporting of service metrics. 

See [Custom Application Service Metrics](../application/sdk/details/CustomServiceMetrics.md) for more detail on Application Services capability to collect their own custom service metrics via use of the App SDK API. 

See [Custom Device Service Metrics](../device/sdk/details/CustomServiceMetrics.md) for more detail on Go Device Services capability to collect their own custom service metrics via use of the Go Device SDK API. 

Each service defines (in code) a set of service metrics that it collects and optionally reports if configured. 
The names the service gives to its metrics are used in the service's `Telemetry` configuration to enable/disable the reporting of those metrics. See Core Data's `Writable.Telemetry` at [Core Data Configuration](../core/data/Configuration.md) as example of the names used for the service metrics that Core Data is currently collecting.

The following metric types are available to be used by the EdgeX services:

- **Counter**: Integer value that is incremented or decremented. Metric field name is `counter-count`
- **Gauge**: Integer value that is set to a specific value. Metric field name is `gauge-value`
- **GaugeFloat64**: Float value that is set to a specific value. Metric field name is `gaugeFloat64-value`
- **Timer**: Float value that is set to the amount of time an action takes. Metric field names are `timer-count` , `timer-min`, `timer-max`, `timer-mean`, `timer-stddev` and `timer-variance`
- **Histogram**: Integer value that is set to some value, i.e. number of bytes exported.  Metric field names are `histogram-count` , `histogram-min`, `histogram-max`, `histogram-mean`, `histogram-stddev` and `histogram-variance`

Service metrics which are enabled for reporting are published to the EdgeX MessageBug every configured interval using the configured `Telemetry` base topic. See `Writable.Telemetry` at [Common Configuration](../configuration/CommonConfiguration/#configuration-properties) for details on these configuration items. The `service name` and the `metric name` are added to the configured base topic. This allows subscribers to subscribe only for specific metrics or metrics from specific services. Each metric is published (reported) independently using the Metric DTO (Data Transfer Object) define in [go-mod-core-contracts](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/dtos/metric.go#L27).

The aggregation of these service metrics is left to adopters to implement as best suits their deployment(s).
This can be accomplished with a custom application service that sets the function pipeline `Target Type` to the `dtos.Metric` type. Then create a custom pipeline function which aggregates the metrics and provides them to the telemetry dashboard service of choice via push (export) or pull (custom GET endpoint). See [App Services](../application/details/Triggers.md) here for more details on `Target Type`.

!!! example "Example - DTO from Core Data in JSON format for the `EventsPersisted` metric as publish to the EdgeX MessageBus"
    ```json
    {
        "apiVersion" : "{{api_version}}",
        "name": "EventsPersisted",
        "fields": [
            {
                "name": "counter-count",
                "value": 276
            }
        ],
        "tags": [
            {
                "name": "service",
                "value": "core-data"
            }
        ],
        "timestamp": 1650301898926166900
    }
    ```
!!! note
    The service name is added to the tags for every metric reported from each service. Additional tags may be added via the service's Telemetry configuration. See the `Writable.Telemetry` at [Common Configuration](../configuration/CommonConfiguration/#configuration-properties) for more details. A service may also add metric specific tags via code when it collects the individual metrics.

### Common Service Metrics

All services have the ability to collect the following common service metrics

- **SecuritySecretsRequested** - Count of secrets requested from the service's Secret Store.
- **SecuritySecretsStored** - Count of secret stored to the service's Secret Store.
- **SecurityConsulTokensRequested** - Count of Consul tokens been requested.
- **SecurityConsulTokenDuration** - Duration of obtaining Consul token.

## URI for Files

!!! edgey "EdgeX 3.1"
    Support for loading files from a remote location via URI is new in EdgeX 3.1.

Different files like configurations, units of measurements, device profiles, device definitions, and provision watchers can be loaded either from the local file system or from a remote location.
For the remote location, HTTP and HTTPS URIs are supported. When using HTTPS, certificate validation is performed using the system's built-in trust anchors.

### Authentication

#### username-password in URI (not recommended)

Users can specify the username-password (`<username>:<password>@`) in the URI as plain text.
This is ok network wise when using HTTPS, but if the credentials are specified in configuration or other service files, this is not a good practice to follow.

!!! example "Example - configuration file with plain text `username-password` in URI"
    ```
        [UoM]
        UoMFile = "https://myuser:mypassword@example.com/uom.yaml"
    ```

#### Secure Credentials (preferred)

The `edgexSecretName` query parameter can be specified in the URI as a secure way for users to specify credentials.
When running in secure mode, this parameter specifies a Secret Name from the service's Secret Store where the credentials must be [seeded](../../security/SeedingServiceSecrets.md#seeding-service-secrets).
If insecure mode is running, `edgexSecretName` must be specified in the [InsecureSecrets](../configuration/CommonConfiguration.md#common-configuration-properties) section of the configuration.

!!! example "Example - configuration file with `edgexSecretName` query parameter"
    ```
    [UoM]
    UoMFile = "https://example.com/uom.yaml?edgexSecretName=mySecretName"
    ```

The authentication type and credentials are contained in the secret data specified by the Secret Name.
Only `httpheader` is currently supported. The `headername` specifies the authentication method (ie Basic Auth, API-Key, Bearer)

!!! example "Example - secret data using `httpheader`"
    ```
    type=httpheader
    headername=<name>
    headercontents=<contents>
    ```
    For a request header set as:
    ```
    GET https://example.com/uom.yaml HTTP/1.1
    <name>: <contents>
    ```


## Timestamp Precision

We have several data models with a timestamp field, but the precision varies, please refer to the following measurements and examples:

- `created` and `modified` field cross different data models are in <b>milliseconds</b>, see [Core Metadata API documentation][1] for more information.

    For example, the `created` and `modified` fields in the device object of the Core Metadata Service.

- `start` and `end` timestamp in the Cron Scheduler Service are in <b>milliseconds</b>, see [Cron Scheduler Service API documentation][2] for more information.

- `timestamp` in Metrics and System Events are in <b>nanoseconds</b>, see [Service Metrics][3] and [System Events DTO][4] for more information.

- `origin` in Event and Readings is in <b>nanoseconds</b>, see [Origin Timestamp][5] for more information.


## Reserved Character

Reserved characters are special characters that have predefined meanings in certain technical contexts—such as URLs, APIs, or configuration files. For example, in a URI (Uniform Resource Identifier), the character `/` is used to separate different parts of a path, while `?` introduces a query string. Because these characters serve specific functions, they are considered **reserved**.

However, users sometimes need to include these characters in metadata values—such as device names, resource name, or custom name fields—where the character is intended to be part of the data, not a control symbol. In such cases, these characters must be encoded to prevent misinterpretation. Encoding involves replacing the reserved character with a specific code (usually a percent sign % followed by two hexadecimal digits) so that systems can distinguish between data and control symbols, see [URL encoding][6] for more information.

If these characters are not properly encoded when used in places like URIs or configuration settings, systems may misread the data. This can lead to parsing errors, incorrect behavior, or failed requests, especially when the data is processed by APIs or web services that strictly follow URI standards.

To avoid these issues, it's important to identify which characters are reserved in the specific context you're working in and ensure they are handled appropriately when included in metadata or input values.

### Reserved Characters That Require Encoding

In EdgeX Foundry, certain characters in metadata (like device names, resource name or other name fields) must be encoded. These characters are reserved due to how EdgeX handles URIs and configuration. If not encoded, they can cause errors or misinterpretation during processing.

| Character | Description             | URL Encoded Value |
|-----------|-------------------------|--------------------|
| `#`       | Hash / Fragment Marker  | `%23`              |
| `$`       | Dollar Sign             | `%24`              |
| `&`       | Ampersand               | `%26`              |
| `?`       | Question Mark / Query   | `%3F`              |

#### Reserved Character Example
If your device name is `device#1`, which contains the special character `#`, and you try to call this device using the following API URL:

```json
curl http://localhost:59881/api/{{ api_version }}/device/name/device#1
```

You will receive a `404 Not Found` response because the `#`is not recognizeable:

```json
{
    "apiVersion": "{{ api_version }}",
    "message": "no device with name 'device' found",
    "statusCode": 404
}
```

To fix this, you must escape the `#` character using URL encoding `%23`, This will correctly match the device named device#1 in the system.

```json
curl http://localhost:59881/api/{{ api_version }}/device/name/device%231
```

#### Simplified Chinese Character Example
EdgeX Foundry supports Chinese characters directly, so there is no need to encode them in API calls or metadata. The system can handle these characters without any issues during processing.

Thus, if your device name is 温度感测器 (a Simplified Chinese character string), you can call this device using the following API URL without encoding:

```json
curl http://localhost:59881/api/{{ api_version }}/device/name/温度感测器
```

[1]: ../core/metadata/ApiReference.md
[2]: ../support/scheduler/ApiReference.md
[3]: #service-metrics
[4]: ../core/metadata/details/DeviceSystemEvents.md#system-event-dto
[5]: ../../walk-through/Ch-WalkthroughReading.md#origin-timestamp
[6]: https://en.wikipedia.org/wiki/Percent-encoding