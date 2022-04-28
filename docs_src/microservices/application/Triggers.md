# Application Service Triggers

## Introduction

Triggers determine how the App Functions Pipeline begins execution. The trigger is determined by the `[Trigger]` configuration section in the  `configuration.toml` file.   

!!! edgey "Edgex 2.0"
    For Edgex 2.0 the `[Binding]` configuration section has been renamed to `[Trigger]`. The  `[MessageBus]` section has been renamed to `EdgexMessageBus` and moved under the `[Trigger]` section. The `[MqttBroker]` section has been renamed to `ExternalMqtt` and moved under the `[Trigger]` section.

There are 4 types of `Triggers` supported in the App Functions SDK which are discussed in this document

1. **[EdgeX Message Bus](#edgex-messagebus-trigger)** - Default Trigger for most use cases as this is how the App Services receive Events from EdgeX Core Data and/or Devices Services
2. **[External MQTT](#external-mqtt-trigger)** - Useful when receiving commands from an external/Cloud MQTT broker.
3. **[HTTP](#http-trigger)** - Useful during development and testing of custom functions. 
4. **[Custom](#custom-triggers)** - Allows custom Application Services to implement their own Custom Trigger

## EdgeX MessageBus Trigger

An EdgeX MessageBus trigger will execute the pipeline every time data is received from the configured Edgex MessageBus `SubscribeTopics`.  The EdgeX MessageBus is the central message bus internal to EdgeX and has a specific message envelope that wraps all data published to this message bus.

There currently are three implementations of the EdgeX MessageBus available to be used. These are `Redis Pub/Sub`(default), `MQTT` and `ZeroMQ`(ZMQ). The implementation type is selected via the `[Trigger.EdgexMessageBus]` configuration described below.

### Type Configuration 


!!! edgey "Edgex 2.0"
    For EdgeX 2.0 the `SubscribeTopic` has been renamed to `SubscribeTopics` and moved under the **EdgexMessageBus** `SubscribeHost` section. The `PublishTopic` has also been moved under the **EdgexMessageBus** `PublishHost` section. Also the legacy `type` of `messagebus` has been removed.

Here's an example:

```toml
[Trigger]
Type="edgex-messagebus"
```
The `Type=` is set to `edgex-messagebus` trigger type. The Context function `ctx.SetResponseData([]byte outputData)` stores the data to send back to the EdgeX MessageBus on the topic specified by the PublishHost `PublishTopic=` setting.

### MessageBus Connection Configuration
The other piece of configuration required are the connection settings:
```toml
[Trigger.EdgexMessageBus]
Type = "redis" # message bus type (i.e "redis`, `mqtt` or `zero` for ZeroMQ)
    [Trigger.EdgexMessageBus.SubscribeHost]
        Host = "localhost"
        Port = 6379
        Protocol = "redis"
        SubscribeTopics="edgex/events/#"
    [Trigger.EdgexMessageBus.PublishHost]
        Host = "localhost"
        Port = 6379
        Protocol = "redis"
        PublishTopic="" # optional if publishing response back to the MessageBus
```


!!! edgey "Edgex 2.0"
    For Edgex 2.0 the `PublishTopic` can now have placeholders. See [Publish Topic Placeholders](#publish-topic-placeholders) section below for more details

 As stated above there are three EdgeX MessageBus implementations you can choose from. These type values are as follows:

```
redis - for Redis Pub/Sub (Requires Redis running and Core Data and/or Device Services configure to use Redis Pub/Sub)
mqtt  - for MQTT (Requires a MQTT Broker running and Core Data and/or Device Services configure to use MQTT)
zero  - for ZeroMQ (No Broker/Service required. Core Data must be configured to use Zero and Device service configure to use REST to Core Data)
```

!!! edgey "Edgex 2.0"
    For Edgex 2.0 Redis is now the default EdgeX MessageBus implementation used. Also, the Redis implementation changed from `Redis streams` to `Redis Pub/Sub`, thus the type value changed from `redisstreams` to `redis`

!!! important
    When using ZMQ for the message bus, the Publish Host **MUST** be different for each publisher to since the they will bind to the specific port. 5563 for example cannot be used to publish since `EdgeX Core Data` has bound to that port. Similarly, you cannot have two separate instances of the app functions SDK running and publishing to the same port. This is why once Device services started publishing the the EdgeX MessageBus the default was changed to `Redis Pub/Sub`

!!! note
    When using MQTT for the message bus, there is additional configuration required for specifying the MQTT specific options. 

### Example Using MQTT

Here is example `EdgexMessageBus` configuration when using MQTT as the message bus:

```toml
[Trigger.EdgexMessageBus]
Type = "mqtt"
    [Trigger.EdgexMessageBus.SubscribeHost]
    Host = "localhost"
    Port = 1883
    Protocol = "tcp"
    SubscribeTopics="edgex/events/#"
    [Trigger.EdgexMessageBus.PublishHost]
    Host = "localhost"
    Port = 1883
    Protocol = "tcp"        
    PublishTopic="" # optional if publishing response back to the MessageBus
    [Trigger.EdgexMessageBus.Optional]
    # MQTT Specific options
    ClientId ="new-app-service"
    Qos            = "0" # Quality of Service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive      = "10" # Seconds (must be 2 or greater)
    Retained       = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "30" # Seconds
    SkipCertVerify = "false"
    authmode = "none"  # change to "usernamepassword", "clientcert", or "cacert" for secure MQTT messagebus.
    secretname = "mqtt-bus"

```



!!! edgey "EdgeX 2.0"
    New for EdgeX 2.0 is the Secure MessageBus when use the `Redis Pub/Sub` implementation. See the [Secure MessageBus](../../security/Ch-Secure-MessageBus.md) documentation for more details.

!!! edgey "EdgeX 2.0"
    Also new for EdgeX 2.0 is the MQTT MessageBus implementation now supports retrieving secrets from the `Secret Store` for secure MQTT connection, but there is not any facility yet to generate the credentials on first startup and distribute them to all services, as is done with `Redis Pub/sub`. This MQTT credentials generation and distribution is a future enhancement for EdgeX security services. 

### Filter By Topics

!!! edgey "EdgeX 2.0"
    New for EdgeX 2.0

App services now have the capability to filter by EdgeX MessageBus topics rather then using Filter functions in the functions pipeline. Filtering by topic is more efficient since the App Service never receives the data off the MessageBus. Core Data and/or Device Services now publish to multi-level topics that include the `profilename`, `devicename` and `sourcename` . Sources are the `commandname` or `resourcename` that generated the Event. The publish topics now look like this:

```
# From Core Data
edgex/events/core/<profile-name>/<device-name>/<source-name>

# From Device Services
edgex/events/device/<profile-name>/<device-name>/<source-name>
```

This with App Services capability to have multiple subscriptions allows for multiple filters by subscriptions. The `SubscribeTopics` setting takes a comma separated list of subscribe topics.

 Here are a few examples of how to configure the `SubscribeTopics` setting under the `Trigger.EdgexMessageBus.SubscribeHost` section to filter by subscriptions using the `profile`, `device` and `source` names from the SNMP Device Service file [here](https://github.com/edgexfoundry/device-snmp-go/tree/master/cmd/res):

- Filter for all Events 

  ```toml
  SubscribeTopics="edgex/events/#"
  ```

- Filter for Events only from a single class of devices (device profile defines a class of device)

  ```toml
  SubscribeTopics="edgex/events/#/trendnet/#"
  ```

- Filter for Events only from a single actual device

  ```toml
  SubscribeTopics="edgex/events/#/#/trendnet01/#"
  ```

- Filter for Events from two specific actual devices

  ```toml
  SubscribeTopics="edgex/events/#/#/trendnet01/#, edgex/events/#/#/trendnet02/#"
  ```

- Filter for Events from two specific sources. 

  ```toml
  SubscribeTopics="edgex/events/#/#/#/Uptime, edgex/events/#/#/#/MacAddress"
  ```

!!! note
    The above examples are for when Redis is used as the EdgeX MessageBus implementation, which is now the default. The Redis implementation uses the `#` wildcard character for multi-level and single level. The implementation actually converts all `#`'s to the `*`'s. The `*`is the actual wildcard character used by Redis Pub/Sub. In the first example (multi-level) the `#` is used at the end in the location for where Core Data's and Device Service's publish topics differ. This location will be `core` when coming from Core Data or `device` when coming from a Device Service. The additional use of `#` within the topic, not at the end, (single-level) allows for any `Profile`, `Device` or `Source` when specifying one of the others.

!!! note
    For the MQTT implementation of the EdgeX MessageBus, the `#` is also used for the multi-level wildcard, but the single-level wildcard is the `+` character. So the first and last examples above would be as follows for when using the MQTT implementation

    ````toml
    SubscribeTopics="edgex/events/#"
    SubscribeTopics="edgex/events/+/trendnet/#"
    SubscribeTopics="edgex/events/+/+/trendnet01/#"
    SubscribeTopics="edgex/events/+/+/trendnet01/#, edgex/events/+/+/trendnet02/#"
    SubscribeTopics="edgex/events/+/+/+/Uptime, edgex/events/+/+/+/MacAddress"
    ````



## External MQTT Trigger

An External MQTT trigger will execute the pipeline every time data is received from an external MQTT broker on the configured `SubscribeTopics`.  

!!! note
    The data received from the external MQTT broker is not wrapped with any metadata known to EdgeX. The data is handled as JSON or CBOR. The data is assumed to be JSON unless the first byte in the data is **not** a `{`  or a `[`, in which case it is then assumed to be CBOR.

!!! note
    The data received, encoded as JSON or CBOR, must match the `TargetType` defined by your application service. The default  `TargetType` is an `Edgex Event`. See [TargetType](../AdvancedTopics/#target-type) for more details.

### Type Configuration
Here's an example:
```toml
[Trigger]
Type="external-mqtt"
  [Trigger.externalmqtt]
  Url = "tls://test.mosquitto.org:8884"
  SubscribeTopics="edgex/#"
  ClientId ="app-external-mqtt-trigger"
  Qos            = 0
  KeepAlive      = 10
  Retained       = false
  AutoReconnect  = true
  ConnectTimeout = "30s"
  SkipCertVerify = true
  AuthMode = "clientcert"
  SecretPath = "external-mqtt"
  RetryDuration = 600
  RetryInterval = 5
```


!!! edgey "Edgex 2.0"
    For EdgeX 2.0 the `SubscribeTopic` has been renamed to `SubscribeTopics` and moved under the `ExternalMqtt` section. The `PublishTopic` has also been moved under the `ExternalMqtt` section.

The `Type=` is set to `external-mqtt`. To receive data from the external MQTT Broker you must set your `SubscribeTopics=` to the appropriate topic(s) that the external publisher is using. You may also designate a `PublishTopic=` if you wish to publish data back to the external MQTT Broker. The Context function `ctx.SetResponseData([]byte outputData)` stores the data to send back to the external MQTT Broker on the topic specified by the `PublishTopic=` setting.


!!! edgey "Edgex 2.2"
    Prior to EdgeX 2.2 if `AuthMode` is set to `usernamepassword`, `clientcert`, or `cacert` and App Service will be run in secure mode, the required credentials must be stored to Secret Store via [Vault CLI, REST API, or WEB UI](https://docs.edgexfoundry.org/2.2/security/Ch-SecretStore/#using-the-secret-store) before starting App Service. Otherwise App Service will fail to initialize the External MQTT Trigger and then shutdown because the required credentials do not exist in the Secret Store at the time service starts. Today, you can start App Service and store the required credentials using the [App Service API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/app-functions-sdk/2.2.0#/default/post_secret) afterwards. If the credentials found in Secret Store cannot satisfy App Service, it will retry for a certain duration and interval. See [Application Service Configuration](GeneralAppServiceConfig.md#not-writable) for more information on the configuration of this retry duration and interval. 

### External MQTT Broker Configuration
The other piece of configuration required are the MQTT Broker connection settings:
```toml
[Trigger.ExternalMqtt]
	Url = "tcp://localhost:1883" #  fully qualified URL to connect to the MQTT broker
	SubscribeTopics="SomeTopics"
	PublishTopic="" # optional if publishing response back to the the External MQTT Broker
	ClientId = "AppService" 
	ConnectTimeout = "5s" # 5 seconds
	AutoReconnect = true
	KeepAlive = 10 # Seconds (must be 2 or greater)
	QoS = 0 # Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once)
	Retain = true
	SkipCertVerify = false
	SecretPath = "mqtt-trigger" 
	AuthMode = "none" # Options are "none", "cacert" , "usernamepassword", "clientcert".
```


!!! edgey "Edgex 2.0"
    For Edgex 2.0 the `PublishTopic` can have placeholders. See [Publish Topic Placeholders](#publish-topic-placeholders) section below for more details

## HTTP Trigger

Designating an HTTP trigger will allow the pipeline to be triggered by a RESTful `POST` call to `http://[host]:[port]/api/v2/trigger/`. 

### Type Configuration

Here's an example:

```toml
[Trigger]
Type="http" 
```

The `Type=` is set to `http`. This will will enable listening to the `api/v2/trigger/` endpoint. No other configuration is required. The Context function `ctx.SetResponseData([]byte outputData)` stores the data to send back as the response to the requestor that originally triggered the HTTP Request. 

!!! note
    The HTTP trigger uses the `content-type` from the HTTP Header to determine if the data is JSON or CBOR encoded and the optional `X-Correlation-ID` to set the correlation ID for the request.

!!! note
    The data received, encoded as JSON or CBOR, must match the `TargetType` defined by your application service. The default  `TargetType` is an `Edgex Event`. See [TargetType](../AdvancedTopics/#target-type) for more details.

## Custom Triggers

!!! edgey "Edgex 2.0"
	New for EdgeX 2.0 

It is also possible to define your own trigger and register a factory function for it with the SDK.  You can then configure the trigger by registering a factory function to build it along with a name to use in the config file.  These triggers can be registered with:

```go
service.RegisterCustomTriggerFactory("my-trigger-name", myFactoryFunc) 
```

!!! note
    You can **NOT** override trigger names built into the SDK ( "edgex-messagebus", "external-mqtt", or "http") for a custom trigger.

The trigger factory function is bound to an instance of a trigger configuration struct that is provided by the SDK:

```go
type TriggerConfig struct {
	Logger           logger.LoggingClient
	ContextBuilder   TriggerContextBuilder
	// Deprecated: use MessageReceived
	MessageProcessor TriggerMessageProcessor
	MessageReceived  TriggerMessageHandler
	ConfigLoader     TriggerConfigLoader
}
```

This type carries a pointer to the internal edgex logger, along with three functions:

- `ContextBuilder` builds an `interfaces.AppFunctionContext` from a message envelope you construct.
- `MessageProcessor` (DEPRECATED) exposes a function that sends your message envelope and context built above into the default function pipeline.
- `MessageReceived` exposes a function that sends your message envelope and context to any pipelines configured in the EdgeX service.  It also takes a function that will be run to process the response for each successful pipeline.
!!! note
    The context passed in to `Received` will be cloned for each pipeline configured to run.  If a nil context is passed a new one will be initialized from the message.
- `ConfigLoader` exposes a function that loads your custom config struct.  By default this is done from the primary EdgeX configuration pipeline, and only loads root-level elements.



If you need to override these functions it can be done in the factory function registered with the service.

The custom trigger constructed here will then need to implement the trigger interface so that the SDK can invoke it:

```go
type Trigger interface {
	Initialize(wg *sync.WaitGroup, ctx context.Context, background <-chan BackgroundMessage) (bootstrap.Deferred, error)
}

type BackgroundMessage interface {
	Message() types.MessageEnvelope
	Topic() string
}
```

This leaves a lot of flexibility for how you want the trigger to behave (for example you could write a trigger to watch for file changes, or run on a timer).  Below is a sample implementation of a trigger that reads lines from os.Stdin and pass the captured string through the edgex function pipeline.  In this case the target type for the service is set to `&[]byte{}`.

```go
type stdinTrigger struct{
	tc appsdk.TriggerConfig
}

func (t *stdinTrigger) Initialize(wg *sync.WaitGroup, ctx context.Context, _ <-chan interfaces.BackgroundMessage) (bootstrap.Deferred, error) {
    msgs := make(chan []byte)

    receiveMessage := true
    
	responseHandler := func(ctx AppFunctionContext, pipeline *FunctionPipeline) {
		// do stuff
    }
	
    go func() {
        fmt.Print("> ")
        rdr := bufio.NewReader(os.Stdin)
        for receiveMessage {
            s, err := rdr.ReadString('\n')
            s = strings.TrimRight(s, "\n")

            if err != nil {
                t.tc.Logger.Error(err.Error())
                continue
            }

            msgs <- []byte(s)
        }
    }()

    go func() {
        for receiveMessage {
            select {
            case <-ctx.Done():
                receiveMessage = false

            case m := <-msgs:
                go func() {
                    env := types.MessageEnvelope{
                        Payload: m,
                    }

                    ctx := t.tc.ContextBuilder(env)

                    err := t.tc.MessageReceived(ctx, env, responseHandler)

                    if err != nil {
                        t.tc.Logger.Error(err.Error())
                    }
                }()
            }
        }
    }()

    return cancel, nil
}
```

This trigger can then be registered by calling:

```go
appService.RegisterCustomTriggerFactory("custom-stdin", func(config appsdk.TriggerConfig) (appsdk.Trigger, error) {
    return &stdinTrigger{
        tc: config,
    }, nil
})
```
### Type Configuration

Here's an example:

```toml
[Trigger]
Type="custom-stdin" 
```

Now the custom trigger is configured to be used rather than one of the built-in triggers.

A complete working example can be found [**here**](https://github.com/edgexfoundry/edgex-examples/tree/master/application-services/custom/custom-trigger)

## Publish Topic Placeholders

!!! edgey "Edgex 2.0"
	New for EdgeX 2.0 

Both the `EdgeX MessageBus`and the `External MQTT` triggers support the new **Publish Topic Placeholders** capability. The configured `PublishTopic` for either of these triggers can contain placeholders for runtime replacements. The placeholders are replaced with values from the new `Context Storage` whose key match the placeholder name. Function pipelines can add values to the `Context Storage` which can then be used as replacement values in the publish topic. If an EdgeX Event is received by the configured trigger the Event's `profilename`, `devicename` and `sourcename` as well as the will be seeded into the `Context Storage`. See the [Context Storage](AppFunctionContextAPI.md#context-storage) documentation for more details.

The **Publish Topic Placeholders** format is a simple `{<key-name>}` that can appear anywhere in the topic multiple times. An error will occur if a specified placeholder does not exist in the  `Context Storage`. 

### Example

```toml
PublishTopic = "data/{profilename}/{devicename}/{custom}"
```

## Received Topic

!!! edgey "Edgex 2.0"
	New for EdgeX 2.0 

The topic the data was received on for `EdgeX MessageBus` and the `External MQTT` triggers is now stored in the new `Context Storage` with the key `receivedtopic`. This makes it available to pipeline functions via the `Context Storage` .
