# North-South Messaging

## Status

** Proposed **
(as of 12/21/21)

## Context and Proposed Design

Today, data flowing from sensors/devices (the "southside") through EdgeX to enterprise applications, databases and cloud-based systems (the "northside") can be accomplished via REST or Message bus.  That is, sensor or device data collected by a device service can be sent via REST or message bus to core data.  Core data then relays the data to application services via message bus, but the sensor data can also be sent directly from device services to application services via message bus (by passing core data).  The message bus is implemented via Redis Pub/Sub (default) or via MQTT.  From the application services, data can be sent to northside endpoints in any number of ways – including via MQTT.

So, in summary, data can be collected from a sensor or device and be sent from the southside to the northside entirely using message bus technology when desired.

!!! Note
    The message bus may also be implemented in Zero MQ but with some limitations.  As Zero MQ is being deprecated in EdgeX, it will not be considered further in this ADR.

Communications from a 3rd party system (enterprise application, cloud application, etc.) to EdgeX in order to acuate a device or get the latest information from a sensor is accomplished via REST.  The 3rd party system makes a REST call of the command service which then relays a request to a device service also using REST.  There is no built in means to make a message-based request of EdgeX or the devices/sensors it manages.

In a future release of EdgeX, there is a desire to allow 3rd party systems to make requests of the southside via message bus.  Specifically, a 3rd party system will send a command request via message to the command service via the allowed message bus implementations (which could be MQTT or Redis Pub/Sub today).  The command service would then relay the message request via message bus to the managing device service.  (The command service would also perform any translations on the request as it does for REST requests today.) The device service would use the message to trigger action on the device/sensor as it does when it receives a REST request today and respond via message bus back to the command service.  In turn, the command service would respond to the 3rd party system via message bus.

### Design

The command service requires the means to subscribe to the EdgeX or external (as a 3rd party may want to use their message bus to send commands) message bus.  It would use the messaging client (go-mod-messaging) to create a new MessageClient, connect to a message bus, and subscribe to a configured message topic.

The command service would also publish messages to device service topics using the go-mod-messaging MessageClient.  It would relay any command request to a designated topic for the device service which would be subscribed to the topic.

Likewise, the device services must use the messaging client (go-mod-messaging for Go services and C alternative for C services) to create a new MessageClient, connect to the message bus and subscribe to configured message topics to receive actuation messages from the command service.

Because any actuation request may require a response on the part of EdgeX, the command service must provide the means to receive an optional response message from the device services and publish a response back to the 3rd party caller via message bus as well.

The command message request messages should contain a correlation identifier which would be added to any response so that the 3rd party system would know to associate the responses to the original request.

The device service message command subscription, response publishing and general handling should be implemented in the SDKs versus individually in the device services.

!!! Note
    Message responses are not guaranteed (on the part of the device service to the command service or from the command service back to the originating command requester).  Both the command service and the original 3rd party system making the command request bear the burden to manage timeouts (and possibly resending the request) if there is no response.
    

![image](command-msg.png)

### Message Structure

The messages to the command service and those relayed to the device service would mimic their REST alternatives.  The difference is that the HTTP REST requests

- have a header which contain the correlation id. 

- have a path that contains the target device and command name

- are made via SET or PUT methods signaling get or set actions on the device.

The message bus and the messages on the bus need this additional information. To address this, the command requests must be embedded in a "wrapper message" structure that would contain the additional elements that would be present in the HTTP request messages.

![image](command-msg-structure.png)

Specifically, the message structure would look something like the following:

``` json
{
"correlation-id": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
"method": "SET",
"deviceName": "sensor01",
"command": "command01",
"request":
    {
        "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
        "AHU-TargetTemperature": "28.5",
        "AHU-TargetBand": "4.0",
        "AHU-TargetHumidity": {
        "Accuracy": "0.2-0.3% RH",
        "Value": 59
    }
}
```
Note, this message structure may not be complete as is meant to represent the general structure.  Additional fields may be added in order to align with the HTTP message structure. 

Response messages would be similarly wrapped so as to preserve the request id - if nothing else.

``` json
{
"correlation-id": "14a42ea6-c394-41c3-8bcd-a29b9f5e6835",
"response":
    {
        "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
        "apiVersion": "v2",
        "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
        "statusCode": 0,
        "message": "string"
    }
}
```

### Configuration

The configuration or the command service must provide the details in order to subscribe to command messages from any 3rd party system and publish to a response topic.  The subscription configuration would be similar to how core data is configured to subscribe to messages from any device service and publish to topics to get messages to application services.  However, the command service will actually need to have two sets of subscription and two sets of publishing topics.

The command service would subscribe to any command topic ("edgex/request/command/#") to receive requests from the 3rd party system.  It must then relay these messages (via publish) to the device service actuation topics.

As each device service will have a topic assigned to it, the device service name and device name will be added to the destination topic ("edgex/request/actuate/<device-service>/<device-name>") when command relays the actuation request messages to device services.

The command service must then subscribe to another topic ("edgex/response/actuate/#") to receive actuation responses from the device services.  It then relays those responses on to the 3rd party apps by publishing those responses to a response topic ("edgex/response/command").

![image](command-service-topics.png)

``` toml
[MessageQueue]
Protocol = "redis"
Host = "localhost"
Port = 6379
Type = "redis"
AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
SecretName = "redisdb"
SubscribeResponseActuateTopic = "edgex/response/actuate/#"
PublishActuateTopicPrefix = "edgex/actuate/ " # /<device-service>/<device-name> will be added to this Publish Topic prefix
SubscribeRequestCommandTopic = "edgex/request/command/#"
PublishCommandResponseTopic = "edgex/response/command"
```

Device services must similarly be configured for subscribing to actuation commands and responding to them by publishing to the response topic.

``` toml
[MessageQueue]
Protocol = "redis"
Host = "localhost"
Port = 6379
Type = "redis"
AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
SecretName = "redisdb"
SubscribeRequestActateTopic = "edgex/request/actuate/<device-service>/#"
PublishActuateResponseTopic = "edgex/response/actuate/<device-service>/"
```

Questions:
- Would we need multiple 3rd party response topics?  Or would one setup separate command services for each 3rd party?
- Do we need separate topics for all the devices or would one on the device service suffice?
  - Ans:  we have defined the deviceName in the payload, so one topic should be sufficient for Device Service- edgex/request/actuate/<device-service>

- Should the command service be allowed to subscribe to the external message broker from a 3rd party? If it subscribes to the EdgeX message bus (internally) only, we might need additional services to relay the data to EdgeX message bus from the external source (depending on security and accessibility to the external message bus).

- Dynamic configuration is not a user friendly operation. We might want to think about creating additional APIs for Adding/Updating/Deleting/Query the external subscription (and store them to the RedisDB).

- Is it acceptable for more than one response to be published by the device service on the same correlation ID? Eg, send back "Acknowledged", then "Scheduled", then "Starting", then "Done" statuses?
  - Ans:  it is not possible for REST requests today and so it is assumed that is not going to happen via messaging today.  

- Would it make sense to echo the command name into the response, as a reality check?
  - Ans:  adds length and complexity to the response today that one could say is handled by using the correlation id to track it to the original request.  Can revisit if necessary.

!!! INFO
        This ADR does not handle securing the message bus communications between services.  This need is to be covered universally in an upcoming ADR.

## Consequences

The implementation of north-to-south message bus communications could be accomplished in phases

1. Command service to receive and respond via message bus
2. Device services in Go receive and respond via message bus
3. Device services in C receive and respond via message bus

## References
