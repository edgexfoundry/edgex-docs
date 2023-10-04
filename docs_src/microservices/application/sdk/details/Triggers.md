# App Functions SDK - Triggers

## Introduction

Triggers determine how the App Functions Pipeline begins execution. The trigger is determined by the `[Trigger]` configuration section in the  `configuration.yaml` file.   

!!! edgey "Edgex 2.0"
    For Edgex 2.0 the `[Binding]` configuration section has been renamed to `[Trigger]`. The  `[MessageBus]` section has been renamed to `EdgexMessageBus` and moved under the `[Trigger]` section. The `[MqttBroker]` section has been renamed to `ExternalMqtt` and moved under the `[Trigger]` section.

There are 4 types of `Triggers` supported in the App Functions SDK which are discussed in this document

1. **[EdgeX Message Bus](#edgex-messagebus-trigger)** - Default Trigger for most use cases as this is how the App Services receive Events from EdgeX Core Data and/or Devices Services
2. **[External MQTT](#external-mqtt-trigger)** - Useful when receiving commands from an external/Cloud MQTT broker.
3. **[HTTP](#http-trigger)** - Useful during development and testing of custom functions. 
4. **[Custom](#custom-triggers)** - Allows custom Application Services to implement their own Custom Trigger

## EdgeX MessageBus Trigger

An EdgeX MessageBus trigger will execute the pipeline every time data is received from the configured Edgex MessageBus `SubscribeTopics`.  The EdgeX MessageBus is the central message bus internal to EdgeX and has a specific message envelope that wraps all data published to this message bus.

There currently are four implementations of the EdgeX MessageBus available to be used. Two of these are available out of the box: `Redis Pub/Sub`(default) and `MQTT`. Additionally NATS (both core and JetStream) options can be made available with the build flag mentioned above.  The implementation type is selected via the `[Trigger.EdgexMessageBus]` configuration described below.

### Type Configuration 

!!! example - "Example Trigger Configuration"
    ```yaml
    Trigger:
      Type: "edgex-messagebus"
    ```
In the above example `Type` is set to `edgex-messagebus` trigger type so data will be received from the EdgeX MessageBus
and may be Published to the EdgeX MessageBus, if configured.

### Subscribe/Publish Topics

#### SubscribeTopics
The SubscribeTopics configuration specifies the comma separated list of topics the service will subscribe to.

!!! note
    The default `SubscribeTopics` configuration is set in the [App Services Common Trigger Configuration](..GeneralAppServiceConfig/#not-writable).

#### PublishTopic
The PublishTopic configuration specifies the topic published to when the `ResponseData` is set via the `ctx.SetResponseData([]byte outputData)` API.
Nothing will be published if the PublishTopic is not set or the `ResponseData` is never set

!!! note
    The default `PublishTopic` configuration is set in the [App Services Common Trigger Configuration](../GeneralAppServiceConfig/#not-writable).

### MessageBus Connection Configuration

See the [EdgeX MessageBus section](../../general/messagebus) for complete details.

!!! edgey "Edgex 3.0"
    For Edgex 3.0 the MessageBus configuration settings are set in the [Common MessageBus Configuration](../../configuration/CommonConfiguration/#configuration-properties).

### Filter By Topics

App services now have the capability to filter by EdgeX MessageBus topics rather than using Filter functions in the functions pipeline. Filtering by topic is more efficient since the App Service never receives the data off the MessageBus. Core Data and/or Device Services now publish to multi-level topics that include the `profilename`, `devicename` and `sourcename` . Sources are the `commandname` or `resourcename` that generated the Event. The publish topics now look like this:

```
# From Core Data
edgex/events/core/<device-service>/<profile-name>/<device-name>/<source-name>

# From Device Services
edgex/events/device/<device-service>/<profile-name>/<device-name>/<source-name>
```

This with App Services capability to have multiple subscriptions allows for multiple filters by subscriptions. The `SubscribeTopics` setting takes a comma separated list of subscribe topics.

 Here are a few examples of how to configure the `SubscribeTopics` setting under the `Trigger.EdgexMessageBus.SubscribeHost` section to filter by subscriptions using the `profile`, `device` and `source` names from the SNMP Device Service file [here](https://github.com/edgexfoundry/device-snmp-go/tree/{{edgexversion}}/cmd/res):

- Filter for all Events (default in common Trigger configuration)

  ```yaml
  Trigger:
    SubscribeTopics: "events/#"
  ```

- Filter for Events only from a single class of devices (device profile defines a class of device)

  ```yaml
  Trigger:
    SubscribeTopics: "events/+/+/trendnet/#"
  ```

- Filter for Events only from a single actual device

  ```yaml
  Trigger:
    SubscribeTopics: "edgex/events/+/+/+/trendnet01/#"
  ```

- Filter for Events from two specific actual devices

  ```yaml
  Trigger:
    SubscribeTopics: "edgex/events/+/+/+/trendnet01/#, edgex/events/+/+/+/trendnet02/#"
  ```

- Filter for Events from two specific sources. 

  ```yaml
  Trigger:
    SubscribeTopics: "edgex/events/+/+/+/+/Uptime, edgex/events/+/+/+/+/MacAddress"
  ```

## External MQTT Trigger

An External MQTT trigger will execute the pipeline every time data is received from an external MQTT broker on the configured `SubscribeTopics`.  

!!! note
    The data received from the external MQTT broker is not wrapped with any metadata known to EdgeX. The data is handled as JSON or CBOR. The data is assumed to be JSON unless the first byte in the data is **not** a `{`  or a `[`, in which case it is then assumed to be CBOR.

!!! note
    The data received, encoded as JSON or CBOR, must match the `TargetType` defined by your application service. The default  `TargetType` is an `Edgex Event`. See [TargetType](../AdvancedTopics/#target-type) for more details.

### Type Configuration
!!! example - "Example Trigger Configuration"
    ```yaml
    Trigger:
      Type: "external-mqtt"
      SubscribeTopics: "external/#"
      PublishTopic: ""
      ...
    ```

The `Type` is set to `external-mqtt`. To receive data from the external MQTT Broker you must set your `SubscribeTopics` to the
appropriate topic(s) that the external publisher is using. You may also designate a `PublishTopic` if you wish to publish data 
back to the external MQTT Broker. The Context function `ctx.SetResponseData([]byte outputData)` stores the data to send back to 
the external MQTT Broker on the topic specified by the `PublishTopic` setting.

the `PublishTopic` can have placeholders. See [Publish Topic Placeholders](#publish-topic-placeholders) section below for more details

### External MQTT Broker Configuration
The other piece of configuration required are the MQTT Broker connection settings:
```yaml
Trigger:
  ...
  ExternalMqtt:
    Url: "tls://test.mosquitto.org:8884"
    ClientId: "app-external-mqtt-trigger"
    Qos: 0
    KeepAlive: 10
    Retained: false
    AutoReconnect: true
    ConnectTimeout: "30s"
    SkipCertVerify: true
    AuthMode: "clientcert"
    SecretName: "external-mqtt"
    RetryDuration: 600
    RetryInterval: 5
```

## HTTP Trigger

Designating an HTTP trigger will allow the pipeline to be triggered by a RESTful `POST` call to `http://[host]:[port]/api/{{api_version}}/trigger/`. 

### Type Configuration

!!! example - "Example Trigger Configuration"
    ```yaml
    Trigger:
      Type: "http" 
    ```

The `Type=` is set to `http`. This will enable listening to the `api/{{api_version}}/trigger/` endpoint. No other configuration is required. The Context function `ctx.SetResponseData([]byte outputData)` stores the data to send back as the response to the requestor that originally triggered the HTTP Request. 

!!! note
    The HTTP trigger uses the `content-type` from the HTTP Header to determine if the data is JSON or CBOR encoded and the optional `X-Correlation-ID` to set the correlation ID for the request.

!!! note
    The data received, encoded as JSON or CBOR, must match the `TargetType` defined by your application service. The default  `TargetType` is an `Edgex Event`. See [TargetType](../AdvancedTopics/#target-type) for more details.

## Custom Triggers

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
	MessageReceived  TriggerMessageHandler
	ConfigLoader     TriggerConfigLoader
}
```

This type carries a pointer to the internal edgex logger, along with three functions:

- `ContextBuilder` builds an `interfaces.AppFunctionContext` from a message envelope you construct.
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

!!! example - "Example Trigger Configuration"
    ```yaml
    Trigger:
      Type: "custom-stdin" 
    ```

Now the custom trigger is configured to be used rather than one of the built-in triggers.

A complete working example can be found [**here**](https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/application-services/custom/custom-trigger)

## Publish Topic Placeholders

Both the `EdgeX MessageBus`and the `External MQTT` triggers support the new **Publish Topic Placeholders** capability. The configured `PublishTopic` for either of these triggers can contain placeholders for runtime replacements. The placeholders are replaced with values from the new `Context Storage` whose key match the placeholder name. Function pipelines can add values to the `Context Storage` which can then be used as replacement values in the publish topic. If an EdgeX Event is received by the configured trigger the Event's `profilename`, `devicename` and `sourcename` as well as the will be seeded into the `Context Storage`. See the [Context Storage](../api/AppFunctionContextAPI.md#context-storage) documentation for more details.

The **Publish Topic Placeholders** format is a simple `{<key-name>}` that can appear anywhere in the topic multiple times. An error will occur if a specified placeholder does not exist in the  `Context Storage`. 

### Example

```yaml
PublishTopic: "data/{profilename}/{devicename}/{custom}"
```

## Received Topic

The topic the data was received on for `EdgeX MessageBus` and the `External MQTT` triggers is now stored in the new `Context Storage` with the key `receivedtopic`. This makes it available to pipeline functions via the `Context Storage` .
