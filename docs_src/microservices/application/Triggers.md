Triggers determine how the app functions pipeline begins execution. In the simple example provided above, an HTTP trigger is used. The trigger is determine by the `configuration.toml` file located in the `/res` directory under a section called `[Binding]`. Check out the [Configuration Section](#configuration) for more information about the toml file.

## Message Bus Trigger

A message bus trigger will execute the pipeline every time data is received off of the configured topic.  

### Type and Topic configuration 
Here's an example:
```toml
Type="messagebus" 
SubscribeTopic="events"
PublishTopic=""
```
The `Type=` is set to "messagebus". [EdgeX Core Data]() is publishing data to the `events` topic. So to receive data from core data, you can set your `SubscribeTopic=` either to `""` or `"events"`. You may also designate a `PublishTopic=` if you wish to publish data back to the message bus.
`edgexcontext.Complete([]byte outputData)` - Will send data back to back to the message bus with the topic specified in the `PublishTopic=` property
### Message bus connection configuration
The other piece of configuration required are the connection settings:
```toml
[MessageBus]
Type = 'zero' #specifies of message bus (i.e zero for ZMQ)
    [MessageBus.PublishHost]
        Host = '*'
        Port = 5564
        Protocol = 'tcp'
    [MessageBus.SubscribeHost]
        Host = 'localhost'
        Port = 5563
        Protocol = 'tcp'
```
By default, `EdgeX Core Data` publishes data to the `events`  topic on port 5563. The publish host is used if publishing data back to the message bus. 
>**Important Note:** Publish Host **MUST** be different for every topic you wish to publish to since the SDK will bind to the specific port. 5563 for example cannot be used to publish since `EdgeX Core Data` has bound to that port. Similarly, you cannot have two separate instances of the app functions SDK running publishing to the same port. 

## HTTP Trigger

Designating an HTTP trigger will allow the pipeline to be triggered by a RESTful `POST` call to `http://[host]:[port]/trigger/`. The body of the POST must be an EdgeX event. 

`edgexcontext.Complete([]byte outputData)` - Will send the specified data as the response to the request that originally triggered the HTTP Request. 