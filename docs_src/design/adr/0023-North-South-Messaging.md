# North-South Messaging

## Status

**Proposed**
(as of 12/21/21)

## Context and Proposed Design

Today, data flowing from sensors/devices (the “southside”) through EdgeX to enterprise applications, databases and cloud-based systems (the “northside”) can be accomplished via REST or Message bus.  That is, sensor or device data collected by a device service can be sent via REST or message bus to core data.  Core data then relays the data to application services via message bus, but the sensor data can also be sent directly from device services to application services via message bus (by passing core data).  The message bus is implemented via Redis Pub/Sub (default) or via MQTT.  From the application services, data can be sent to northside endpoints in any number of ways – including via MQTT.

So, in summary, data can be collected from a sensor or device and be sent from the southside to the northside entirely using message bus technology when desired.

!!! Note
    The message bus may also be implemented in Zero MQ but with some limitations.  As Zero MQ is being deprecated in EdgeX, it will not be considered further in this ADR.

Today, communications from a 3rd party system (enterprise application, cloud application, etc.) to EdgeX in order to acuate a device or get the latest information from a sensor is accomplished via REST.  The 3rd party system makes a REST call of the command service which then relays a request to a device service also using REST.  There is no built in means to make a message-based request of EdgeX or the devices/sensors it manages.

In a future release of EdgeX, there is a desire to allow 3rd party systems to make requests of the southside via message bus.  Specifically, a 3rd party system will send a command request via message to the command service via the allowed message bus implementations (which could be MQTT or Redis Pub/Sub today).  The command service would then relay the message request via message bus to the managing device service.  (The command service would also perform any translations on the request as it does for REST requests today.) The device service would use the message to trigger action on the device/sensor as it does when it receives a REST request today and respond via message bus back to the command service.  In turn, the command service would respond to the 3rd party system via message bus.

!!! Note
    For the purposes of this initial north-to-south message bus communications, external 3rd party communications to the command service will be limited to use of MQTT.  MQTT is more commonly adopted and in order for a 3rd party to use the EdgeX Redis Pub/Sub message bus, they would need access to the EdgeX internal message bus or spin up their own external instance of Redis Pub/Sub.  So for the purpose of this initial north-south messaging implementation, **only MQTT will be used by external 3rd party systems to communicate with EdgeX services.**  Future implementations can explore use of alternate message bus technology such as Redis Pub/Sub.

### Core Command as Message Bus Bridge

The core command service will serve as the EdgeX entry point for external, north-to-south message bus requests to the south side.

![image](command-msg.png)

3rd party systems should not be granted access to the EdgeX internal message bus.  Therefore, in order to implement north to south communications via message bus (specifically MQTT), the command service needs to take messages from the 3rd party or external MQTT topics and pass them internally onto the EdgeX internal message bus where they can eventually be routed to the device services and then on to the devices/sensors (southside).

In reverse, response messages from the southside will also be sent through the internal EdgeX message bus to the command service where they can then be bridged to the external MQTT topics and respond to the 3rd party system requester.

!!! Note
    If command did not serve as this external to internal (and vice versa) bridge, then each device service would need to be able to serve as their own external MQTT topic to internal message bus bridge which is inefficient.  Also note that eKuiper is allowed access directly to the internal EdgeX message bus.  This is a special circumstance of 3rd party external system communication as eKuiper is a sister project that is deemed the EdgeX reference implementation rules engine.  In future releases of EdgeX, even eKuiper may be routed through an external to internal message bus bridge for better decoupling and security.

### Message Bus Subscriptions and Publishing

The command service will require the means to publish messages to device services via the EdgeX message bus (**internal message bus**).  It would use the messaging client (go-mod-messaging) to create a new MessageClient, connect to the message bus, and publish to designated request message topics (see topic configuration below).

The command service will also need to subscribe to the EdgeX message bus (**internal message bus**) in order to receive responses from the device services after a request by message bus has been made.  Again, core command will use the go-mod-messaging MessageClient to subscribe and receive response messages from the device services.

In a similar fashion, device services will need to both subscribe and publish to the EdgeX message bus (**internal message bus**) to get command requests and push back any responses to the command service.  Go lang device services will, like the command service, use the go-mod-messaging module and MessagingClient to get command requests and send command responses to and from the EdgeX message bus.  C based device services will use a C alternative to subscribe and publish to the EdgeX message bus (**internal message bus**)

The command service will also need to subscribe to 3rd party MQTT topics (**external message bus**) in order to get command requests from the 3rd party system.  The command service will then relay command requests on to the appropriate device service via the internal message bus (forming the message bus to message bus bridge).  Likewise, the command service will accept responses from the device services on the EdgeX message bus (**internal message bus**) and then publish responses to the 3rd party system via the 3rd party MQTT topics (**external message bus**).

### Message Structure

In REST based command requests (and responses), the HTTP header is used to pass important information such as the path or target of the request, the HTTP method type (indicating a GET or PUT request), the correlation id and more.  On HTTP responses, the HTTP header provides the information such as the response code (ex: 200 for OK).  The body or payload of the HTTP message contains the request details (such as parameters to a device PUT call) or response information (such as events and associated readings from a GET call).  

In a message bus world, there is no HTTP header to carry request or response details.  Therefore, the message must be organized into an `envelope` and `payload` section to serve just like the HTTP header and body do in HTTP request/response messages.

The message topic names will, in many ways, serve as the HTTP paths and methods do in helping to specify the device receiver of any command request (see topic names below)

![image](command-msg-structure.png)

#### Message Envelope

Messages are just JSON text.  The outer most JSON object represents the message `envelope` for command request and response messages.  The `envelope` will contain a correlation identifier property which will be added to any relayed request message as well as the response message envelope so that the 3rd party system will know to associate the responses to the original request.

The `envelope` will also contain the API version (something provided in the HTTP path when using REST).

Command requests in HTTP may also contain ds-pushevent and ds-returnevent query parameters (for GET commands).  These will be optionally provided key/value pairs represented in the message `envelope`'s query parameters (and optionally allows for other parameters in the future).

``` JSON
{
    "Correlation-ID": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
    "API":"V2",
    "queryParms": {
        "ds-pushevent":"yes",
        "ds-returnevent":"yes",
     }
     ...
}
```

#### Message Payload

The **request** message `payload` to the command service and those relayed to the device service would mimic their HTTP/REST request body alternatives.  The `payload` provides details needed in executing the command at the south side.

In the example GET and PUT messages below, note the `envelope` wraps or encases the message `payload`.  The payload may be empty (as is typical of GET requests).

``` JSON
{
    "Correlation-ID": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
    "API":"v2",
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "queryParms": {
        "ds-pushevent":"yes",
        "ds-returnevent":"yes",
     }
    "payload": 
    {
    }
}

{
    "Correlation-ID": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
    "API":"v2",
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "payload": 
    {
        "AHU-TargetTemperature": "28.5",
        "AHU-TargetBand": "4.0",
        "AHU-TargetHumidity": {
            "Accuracy": "0.2-0.3% RH",
            "Value": 59
        }
    }
}

```

The **response** message `payload` would contain the response from the south side, which is typically EdgeX event/reading objects (in the case of GET requests) but would also include any status code, error or service response details.

Example response messages for a GET and PUT request are shown below.  Again, note that the message `envelope` wraps the response `payload`.

``` JSON
{
    "Correlation-ID": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
    "apiVersion": "v2",
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "statusCode": 0,
    "payload": 
    {
    "message": "string",
    "event": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "deviceName": "string",
        "profileName": "string",
        "created": 0,
        "origin": 0,
        "readings": [
            "string"
            ],
        "tags": {
            "Gateway-id": "HoustonStore-000123",
            "Latitude": "29.630771",
            "Longitude": "-95.377603"
            }
        }
    }
}

{
    "Correlation-ID": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
    "apiVersion": "v2",
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "statusCode": 0,
    "payload": 
    {
        "message": "string"
    }
}

```

!!! Alert
    Should API version be in the response at all?  Per @iain-anderson, would the API version be implied in that a V2 request would mean a V2 response?

### Topic Naming

![image](command-service-topics.png)

#### 3rd party system topics

The 3rd party system or application must publish command requests messages to its own MQTT topic (**external message bus**) and subscribe to responses from the same.  Messages topics would typically follow a standard such as:

- Publishing command request topic: `/my-app/command/request/<device-name>/<command-name>/<method>`
- Subscribing command response topic: `/my-app/command/response/#`

!!! Note
    Because EdgeX can suggest but not dictate the naming standard for 3rd party MQTT topics, these names are representative for clarity, but not required.

#### command service topics

The command service must subscribe to the request topics of the 3rd party (**external message bus**) MQTT topic to get command requests, publish those to a topic to send them to a device service via the EdgeX message bus (**internal message bus**), subscribe to response messages on topics from device services (**internal**), and then publish response messages to a topic on the 3rd party MQTT broker (**external**).  Message topics for the command service would follow the following standard:

- Subscribing to 3rd party command request topics: my-app/command/request/#
- Publishing to device service request topic: edgex/command/request/<device-service>/<device-name>/<command-name>/<method>
- Subscribing to device service command response topics: edgex/command/response/#
- Publishing to 3rd party command response topic: my-app/command/response

!!! Note
    Because EdgeX can suggest but not dictate the naming standard for 3rd party MQTT topics, the 3rd party topic names are representative for clarity, but not required.

#### device service topics

The device services must subscribe to the EdgeX command request topic (**internal message bus**) and publish response messages to an EdgeX command response topic.  The following naming standard will be applied to these topic names:

- Subscribing to command request topic: edgex/command/request/#
- Publishing to command response topic: edgex/command/response

### Configuration

Both the EdgeX command service and the device services must contain configuration needed to connect to and publish/subscribe to messages from topics on the EdgeX message bus (**internal**).  This includes configuration to access the message bus when secure or insecure.

The command service must also be provided configuration to connect to the 3rd party MQTT broker's topics (**external**).  Because the communications may be done in a secure or insecure fashion, the core command service will need to be provided access to the 3rd party MQTT broker (**external**)

Similar to EdgeX application services, the command service will have access to an external MQTT broker to get command requests and send 3rd parties a response.  This will require the command service to have two message queue configuration settings (internal and external).

#### command service configuration

Example command service configuration is provided below.

``` toml
[MessageQueue]
    [InternalMessageQueue]
    Protocol = "redis"
    Host = "localhost"
    Port = 6379
    Type = "redis"
    RequestTopicPrefix = "edgex/command/request/"  # <device-service>/<device-name>/<command-name>/<method> will be added to this publish topic prefix
    ResponseTopic = “edgex/command/response/#”
    AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
    SecretName = "redisdb"
    [ExternalMessageQueue]
    Protocol = "redis"
    Host = "localhost"
    Port = 6378
    Type = "redis"
    RequestTopic = my-app/command/request/#”
    ResponseTopicPrefix = “edgex/command/response/"  # /<device-name>/<command-name>/<method> will be added to this publish topic prefix
 publish topic prefix
    ResponseTopic =  my-app/command/response/#”
    AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
    SecretName = "redisdb"
```

#### device service configuration

Example device service configuration is provided below.

``` toml
[MessageQueue]
Protocol = "redis"
Host = "localhost"
Port = 6379
Type = "redis"
AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
SecretName = "redisdb"
CommandRequestTopic = "edgex/command/request/#"
CommandResponseTopicPrefix = “edgex/command/response/"
```

## Questions

- Do we need separate topics for all the devices or would one on the device service suffice?
    
    - Ans:  we have defined the deviceName in the parameterized topic, so one topic should be sufficient for Device Service- edgex/command/request/<device-name>...

- Would clients (non EdgeX services and applications) want to get a list of available commands via message (instead of calling REST)?

    - Ans:  this is a valid question and could be provided via later additions to the command service (or other service like metadata) in the future.  It does not have to be tackled immediately.  

- Dynamic configuration of the message subscription is not a user friendly operation today (requiring configuration changes).

    - Ans:  In the future, we might want to think about creating additional APIs for Adding/Updating/Deleting/Query the external subscription (and store them to the RedisDB).

- Is it acceptable for more than one response to be published by the device service on the same correlation ID? Eg, send back "Acknowledged", then "Scheduled", then "Starting", then "Done" statuses?
    
    - Ans:  No, the correlation id has a life span to/from the initial requester to the response back to the requester.

- Would it make sense to echo the command name into the response, as a reality check?
    - Ans: solved via topic naming.  Also, per @lenny-intel: "not needed as we don't do this in the HTTP response. The response topic doesn't need the extra path info. The request ID or correlation ID is all that is needed to match the response to the request. No need to make it more complex."

- Would sending/receiving binary data (e.g. CBOR) be supported in this north-south message implementation?
    
    - Ans:  today, command service and device services support CBOR get operations but not set (C SDK suppports both).  [Suggest getting feature parity](https://github.com/edgexfoundry/device-sdk-go/issues/488) in place between the SDKs before exploring CBOR support messaging binary/CBOR payloads.

- Use of the message bus communications (by the non-EdgeX 3rd party service or application) would bypass the API Gateway.

    - Ans:  not an issue since the command service is serving as external to internal message bus broker.

!!! INFO
        This ADR does not handle securing the message bus communications between services.  This need is to be covered universally in an upcoming ADR.

## Consequences

## References

- [Core Command API](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-command/2.1.0)