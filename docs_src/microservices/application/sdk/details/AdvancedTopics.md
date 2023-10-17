# App Functions SDK - Advanced Topics

The following items discuss topics that are a bit beyond the basic use cases of the Application Functions SDK when interacting with EdgeX.

## Configurable Functions Pipeline

This SDK provides the capability to define the functions pipeline via configuration rather than code by using the **app-service-configurable** application service. See the [App Service Configurable](../../services/AppServiceConfigurable/Purpose.md) section for more details.

## Custom REST Endpoints

It is not uncommon to require your own custom REST endpoints when building an Application Service. Rather than spin up your own webserver inside your app (alongside the already existing running webserver), we've exposed a method that allows you to add your own routes to the existing webserver. A few routes are reserved and cannot be used:

- /api/{{api_version}}/version
- /api/{{api_version}}/ping
- /api/{{api_version}}/config
- /api/{{api_version}}/trigger
- /api/{{api_version}}/secret

To add your own route, use the `AddCustomRoute()` API provided on the `ApplicationService` interface. 

!!! example  "Example - Add Custom REST route"

    ``` go      
    myhandler := func(c echo.Context) error {
      service.LoggingClient().Info("TEST")     
      c.Response().WriteHeader(http.StatusOK)
      c.Response().Write([]byte("hello"))   
    }    
    
    service := pkg.NewAppService(serviceKey)    
    service.AddCustomRoute("/myroute", service.Authenticated, myHandler, "GET")    
    ```    

Under the hood, this simply adds the provided route, handler, and method to the `echo` router used in the SDK. For more information on `echo` you can check out the GitHub repo [here](https://github.com/labstack/echo). 
You can access the `interfaces.ApplicationService` API for resources such as the logging client by pulling it from the context as shown above -- this is useful for when your routes might not be defined in your `main.go`  where you have access to the ``interfaces.ApplicationService`` instance.

### Target Type

The target type is the object type of the incoming data that is sent to the first function in the function pipeline. By default, this is an EdgeX `dtos.Event` since typical usage is receiving `Events` from the EdgeX MessageBus. 

There are scenarios where the incoming data is not an EdgeX `Event`. One example scenario is two application services are chained via the EdgeX MessageBus. The output of the first service is inference data from analyzing the original `Event`data, and published back to the EdgeX MessageBus. The second service needs to be able to let the SDK know the target type of the input data it is expecting.

For usages where the incoming data is not `events`, the `TargetType` of the expected incoming data can be set when the `ApplicationService` instance is created using the `NewAppServiceWithTargetType()` factory function.

!!! example "Example - Set and use custom Target Type"

    ``` go    
    type Person struct {    
      FirstName string `json:"first_name"`    
      LastName  string `json:"last_name"`    
    }    
        
    service := pkg.NewAppServiceWithTargetType(serviceKey, &Person{})    
    ```    
    
    `TargetType` must be set to a pointer to an instance of your target type such as `&Person{}` . The first function in your function pipeline will be passed an instance of your target type, not a pointer to it. In the example above, the first function in the pipeline would start something like:
    
    ``` go    
    func MyPersonFunction(ctx interfaces.AppFunctionContext, data interface{}) (bool, interface{}) {    
    
      ctx.LoggingClient().Debug("MyPersonFunction executing")
    
      if data == nil {
    	return false, errors.New("no data received to     MyPersonFunction")
      }
    
      person, ok := data.(Person)
      if !ok {
        return false, errors.New("MyPersonFunction type received is not a Person")
      }
    
    // ....
    ```

The SDK supports un-marshaling JSON or CBOR encoded data into an instance of the target type. If your incoming data is not JSON or CBOR encoded, you then need to set the `TargetType` to  `&[]byte`.

If the target type is set to `&[]byte` the incoming data will not be un-marshaled.  The content type, if set, will be set on the `interfaces.AppFunctionContext` and can be access via the `InputContentType()` API.   Your first function will be responsible for decoding the data or not.

## Command Line Options

See the [Common Command Line Options](../../../configuration/CommonCommandLineOptions.md) for the set of command line options common to all EdgeX services. The following command line options are specific to Application Services.

### Skip Version Check

`-s/--skipVersionCheck`

Indicates the service should skip the Core Service's version compatibility check.

### Service Key

`-sk/--serviceKey`

Sets the service key that is used with Registry, Configuration Provider and security services. The default service key is set by the application service. If the name provided contains the placeholder text `<profile>`, this text will be replaced with the name of the profile used. If profile is not set, the `<profile>` text is simply removed

Can be overridden with [EDGEX_SERVICE_KEY](#edgex_service_key) environment variable.

## Environment Variables

See the [Common Environment Variables](../../../configuration/CommonEnvironmentVariables.md) section for the list of environment variables common to all EdgeX Services. The remaining in this section are specific to Application Services.

### EDGEX_SERVICE_KEY

This environment variable overrides the [`-sk/--serviceKey` command-line option](#service-key) and the default set by the application service.

!!! note
    If the name provided contains the text `<profile>`, this text will be replaced with the name of the profile used.

!!! example "Example - Service Key"
    `EDGEX_SERVICE_KEY: app-<profile>-mycloud`    
    `profile: http-export`    
     then service key will be `app-http-export-mycloud`    

## Store and Forward

The Store and Forward capability allows for export functions to persist data on failure and for the export of the data to be retried at a later time. 

!!! note
    The order the data exported via this retry mechanism is not guaranteed to be the same order in which the data was initial received from Core Data

### Configuration

`Writable.StoreAndForward` allows enabling, setting the interval between retries and the max number of retries. If running with Configuration Provider, these setting can be changed on the fly via Consul without having to restart the service.

!!! example "Example - Store and Forward configuration"
    ```yaml
    Writable:
      StoreAndForward:
        Enabled: false
        RetryInterval: "5m"
        MaxRetryCount: 10
    ```

!!! note
    RetryInterval should be at least 1 second (e.g. '1s') or greater. If a value less than 1 second is specified, 1 second will be used. Endless retries will occur when MaxRetryCount is set to 0. If MaxRetryCount is set to less than 0, a default of 1 retry will be used.

Database configuration section describes which database type to use and the information required to connect to the database. This section is required if Store and Forward is enabled. It is optional if **not** using `Redis` for the EdgeX MessageBus which is now the default. 

!!! example "Example - Database configuration"
    ```yaml
    Database:
      Type: "redisdb"
      Host: "localhost"
      Port: 6379
      Timeout: "5s"
    ```

### How it works

When an export function encounters an error sending data it can call `SetRetryData(payload []byte)` on the `AppFunctionContext`. This will store the data for later retry. If the Application Service is stopped and then restarted while stored data hasn't been successfully exported, the export retry will resume once the service is up and running again.

!!! note
    It is important that export functions return an error and stop pipeline execution after the call to `SetRetryData`. See [HTTPPost](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/pkg/transforms/http.go) function in SDK as an example

When the `RetryInterval` expires, the function pipeline will be re-executed starting with the export function that saved the data. The saved data will be passed to the export function which can then attempt to resend the data. 

!!! note
    The export function will receive the data as it was stored, so it is important that any transformation of the data occur in functions prior to the export function. The export function should only export the data that it receives.

One of three outcomes can occur after the export retried has completed. 

1. Export retry was successful

    In this case, the stored data is removed from the database and the execution of the pipeline functions after the export function, if any, continues. 

2. Export retry fails and retry count `has not been` exceeded

    In this case, the stored data is updated in the database with the incremented retry count

3. Export retry fails and retry count `has been` exceeded

    In this case, the stored data is removed from the database and never retried again.

!!! note
    Changing Writable.Pipeline.ExecutionOrder will invalidate all currently stored data and result in it all being removed from the database on the next retry. This is because the position of the *export* function can no longer be guaranteed and no way to ensure it is properly executed on the retry.

### Custom Storage
The default backing store is redis.  Custom implementations of the `StoreClient` interface can be provided if redis does not meet your requirements.

```go
type StoreClient interface {
	// Store persists a stored object to the data store and returns the assigned UUID.
	Store(o StoredObject) (id string, err error)

	// RetrieveFromStore gets an object from the data store.
	RetrieveFromStore(appServiceKey string) (objects []StoredObject, err error)

	// Update replaces the data currently in the store with the provided data.
	Update(o StoredObject) error

	// RemoveFromStore removes an object from the data store.
	RemoveFromStore(o StoredObject) error

	// Disconnect ends the connection.
	Disconnect() error
}
```
A factory function to create these clients can then be registered with your service by calling [RegisterCustomStoreFactory](../api/ApplicationServiceAPI.md#registercustomstorefactory)

```go
service.RegisterCustomStoreFactory("jetstream", func(cfg interfaces.DatabaseInfo, cred config.Credentials) (interfaces.StoreClient, error) {
    conn, err := nats.Connect(fmt.Sprintf("nats://%s:%d", cfg.Host, cfg.Port))
    
    if err != nil {
        return nil, err
    }
    
    js, err := conn.JetStream()
    
    if err != nil {
        return nil, err
    }
    
    kv, err := js.KeyValue(serviceKey)
    
    if err != nil {
        kv, err = js.CreateKeyValue(&nats.KeyValueConfig{Bucket: serviceKey})
    }
    
    return &JetstreamStore{
        conn:       conn,
        serviceKey: serviceKey,
        kv:         kv,
    }, err
})
```

and configured using the registered name in the `Database` section:

!!! example "Example - Database configuration"
    ```yaml
    Database:
      Type: "jetstream"
      Host: "broker"
      Port: 4222
      Timeout: "5s"
    ```
## Secrets

### Configuration

All App Service instances running in secure mode require a SecretStore to be configured. With the use of `Redis Pub/Sub` as the default EdgeX MessageBus all App Services need the `redisdb` known secret added to their SecretStore, so they can connect to the Secure EdgeX MessageBus. See the [Secure MessageBus](../../../../security/Ch-Secure-MessageBus.md) documentation for more details.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It now has default values which can be overridden with environment variables. See the [SecretStore Overrides](../../../configuration/CommonEnvironmentVariables.md/#secretstore-configuration-overrides) section for more details.

### Storing Secrets

#### Secure Mode

When running an application service in secure mode, secrets can be stored in the service's secure SecretStore by making an HTTP `POST` call to the `/api/{{api_version}}/secret` API route in the application service. The secret data POSTed is stored and retrieved from the service's secure SecretStore . Once a secret is stored, only the service that added the secret will be able to retrieve it.  For secret retrieval see [Getting Secrets](#getting-secrets) section below.

!!! example "Example - JSON message body"
    ```json
    {
      "secretName" : "MySecret",
      "secretData" : [
        {
          "key" : "MySecretKey",
          "value" : "MySecretValue"
        }
      ]
    }
    ```

!!! note
    SecretName specifies the location of the secret within the service's SecretStore. 

#### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration file. Insecure secrets and their paths can be configured as below.

!!! example "Example - InsecureSecrets Configuration"
    ```yaml
    Writable:
      InsecureSecrets:    
        AWS:
          SecretName: "aws"
          SecretsData:
            username: "aws-user"
            password: "aws-pw"
        DB:
          SecretName: "redisdb"
          SecretsData:
           username: ""
            password: ""
    ```

### Getting Secrets

Application Services can retrieve their secrets from their SecretStore using the  [interfaces.ApplicationService.SecretProvider.GetSecret()](../api/ApplicationServiceAPI.md/#secretprovider) API or from the [interfaces.AppFunctionContext.SecretProvider.GetSecret()](../api/AppFunctionContextAPI.md#secretprovider) API  

When in secure mode, the secrets are retrieved from the service secure SecretStore. 

When running in insecure mode, the secrets are retrieved from the `Writable.InsecureSecrets` configuration.

## Background Publishing *DEPRECATED*

The background publisher API has been deprecated.  Any applications using it should migrate replacements available on the `ApplicationService` or `AppFunctionContext` APIs:

- [interfaces.ApplicationService.Publish](../api/ApplicationServiceAPI.md/#publish)
- [interfaces.ApplicationService.PublishWithTopic](../api/ApplicationServiceAPI.md/#publishwithtopic)
- [interfaces.AppFunctionContext.Publish](../api/AppFunctionContextAPI.md/#publish)
- [interfaces.AppFunctionContext.PublishWithTopic](../api/AppFunctionContextAPI.md/#publishwithtopic)

Application Services using the MessageBus trigger can request a background publisher using the AddBackgroundPublisher API in the SDK.  This method takes an int representing the background channel's capacity as the only parameter and returns a reference to a BackgroundPublisher.  This reference can then be used by background processes to publish to the configured MessageBus output.  A custom topic can be provided to use instead of the configured message bus output as well.

!!! example "Example - Background Publisher"
    ```go    
    func runJob (service interfaces.ApplicationService, done chan struct{}){
    	ticker := time.NewTicker(1 * time.Minute)
    	
        //initialize background publisher with a channel capacity of 10 and a custom topic
        publisher, err := service.AddBackgroundPublisherWithTopic(10, "custom-topic")
        
        if err != nil {
            // do something
        }
    	
    	go func(pub interfaces.BackgroundPublisher) {
     		for {
     			select {
     			case <-ticker.C:
     				msg := myDataService.GetMessage()
     				payload, err := json.Marshal(message)
     				
     				if err != nil {
     					//do something
     				}
     				
     				ctx := svc.BuildContext(uuid.NewString(), common.ContentTypeJSON)
     				
     				// modify context as needed
     				
     				err = pub.Publish(payload, ctx)
     				
     				if err != nil {
     					//do something
     				}
     			case <-j.done:
     				ticker.Stop()
     				return
     			}
     		}
     	}(publisher)
     }
     
     func main() {
     	service := pkg.NewAppService(serviceKey)
     	
     	done := make(chan struct{})
     	defer close(done)
     
     	//pass publisher to your background job
     	runJob(service, done)
     
     	service.SetDefaultFunctionsPipeline(
     		All,
     		My,
     		Functions,
     	)
     	
     	service.Run()
     
     	os.Exit(0)
      }		
    ```

## Stopping the Service

Application Services will listen for SIGTERM / SIGINT signals from the OS and stop the function pipeline in response.  The pipeline can also be exited programmatically by calling `sdk.Stop()` on the running `ApplicationService` instance.  This can be useful for cases where you want to stop a service in response to a runtime condition, e.g. receiving a "poison pill" message through its trigger.

## Received Topic

When messages are received via the EdgeX MessageBus or External MQTT triggers, the topic that the data was received on is seeded into the new Context Storage on the `AppFunctionContext` with the key `receivedtopic`. This make the `Received Topic` available to all functions in the pipeline. The SDK provides the `interfaces.RECEIVEDTOPIC` constant for this key. See the [Context Storage](../api/AppFunctionContextAPI.md#context-storage) section for more details on extracting values.

## Pipeline Per Topics

The `Pipeline Per Topics` feature allows for multiple function pipelines to be defined. Each will execute only when one of the specified pipeline topics matches the received topic. The pipeline topics can have wildcards (`+` and `#`) allowing the topic to match a variety of received topics. Each pipeline has its own set of functions (transforms) that are executed on the received message. If the `#` wildcard is used by itself for a pipeline topic, it will match all received topics and the specified functions pipeline will execute on every message received. 

!!! note
    The `Pipeline Per Topics` feature is targeted for EdgeX MessageBus and External MQTT triggers, but can be used with Custom or HTTP triggers. When used with the HTTP trigger the incoming topic will always be `blank`, so the pipeline's topics must contain a single topic set to the `#` wildcard so that all messages received are processed by the pipeline.

!!! example "Example pipeline topics with wildcards"
    ```
    "#"                             - Matches all messages received
    "edegex/events/#"               - Matches all messages received with the based topic `edegex/events/`
    "edegex/events/core/#"          - Matches all messages received just from Core Data
    "edegex/events/device/#"        - Matches all messages received just from Device services
    "edegex/events/+/my-profile/#"  - Matches all messages received from Core Data or Device services for `my-profile`
    "edegex/events/+/+/my-device/#" - Matches all messages received from Core Data or Device services for `my-device`
    "edegex/events/+/+/+/my-source" - Matches all messages received from Core Data or Device services for `my-source`
    ```

Refer to the [Filter By Topics](Triggers.md/#filter-by-topics) section for details on the structure of the received topic.

All pipeline function capabilities such as Store and Forward, Batching, etc. can be used with one or more of the multiple function pipelines. Store and Forward uses the Pipeline's ID to find and restart the pipeline on retries.

!!! example "Example - Adding multiple function pipelines"
    This example adds two pipelines. One to process data from the `Random-Float-Device` device and one to process data from the `Int32` and `Int64` sources. 

    ```go
        sample := functions.NewSample()
        err = service.AddFunctionsPipelineForTopics(
    			"Floats-Pipeline", 
    			[]string{"edgex/events/+/+/Random-Float-Device/#"}, 
    			transforms.NewFilterFor(deviceNames).FilterByDeviceName,
    			sample.LogEventDetails,
    			sample.ConvertEventToXML,
    			sample.OutputXML)
        if err != nil {
            ...
            return -1
        }
        
        err = app.service.AddFunctionsPipelineForTopics(
    			"Int32-Pipleine", 
    			[]string{"edgex/events/+/+/+/Int32", "edgex/events/+/+/+/Int64"},
    		    transforms.NewFilterFor(deviceNames).FilterByDeviceName,
    		    sample.LogEventDetails,
    		    sample.ConvertEventToXML,
    		    sample.OutputXML)
        if err != nil {
        	...
            return -1
        }
    ```



## Built-in Application Service Metrics

All application services have the following built-in metrics:

- `MessagesReceived` - This is a **counter** metric that counts the number of messages received by the application service. Includes invalid messages.

- `InvalidMessagesReceived ` -  This is a **counter** metric that counts the number of invalid messages received by the application service. 

- `HttpExportSize  ` -  This is a **histogram** metric that collects the size of data exported via the built-in [HTTP Export pipeline function](../api/BuiltInPipelineFunctions.md/#http-export). The metric data is not currently tagged due to breaking changes required to tag the data with the destination endpoint. This will be addressed in a future EdgeX 3.0 release.

- `HttpExportErrors` - **(New)** This is a **counter** metric that counts the number of errors encountered when exporting via HTTP. 

- `MqttExportSize  ` -  This is a **histogram** metric that collects the size of data exported via the built-in [MQTT Export pipeline function](../api/BuiltInPipelineFunctions.md/#mqtt-export). The metric data is tagged with the specific broker address and topic.

- `MqttExportErrors` -  **(New)** This is a **counter** metric that counts the number of errors encountered when exporting via MQTT. 

- `PipelineMessagesProcessed` - This is a **counter** metric that counts the number of messages processed by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for.

- `PipelineProcessingErrors ` -  This is a **counter** metric that counts the number of errors returned by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the count is for.

- `PipelineMessageProcessingTime` - This is a **timer** metric that tracks the amount of time taken to process messages by the individual function pipelines defined by the application service. The metric data is tagged with the specific function pipeline ID the timer is for.

    !!! note
        The time tracked for this metric is only for the function pipeline processing time. The overhead of receiving the messages and handing them to the appropriate function pipelines is not included. Accounting for this overhead may be added as another **timer** metric in a future release.

Reporting of these built-in metrics is disabled by default in the `Writable.Telemetry` configuration section. See `Writable.Telemetry` configuration details in the [Application Service Configuration](../../Configuration.md/#writable) section for complete detail on this section. If the configuration for these built-in metrics are missing, then the reporting of the metrics will be disabled.

!!! example "Example - Service Telemetry Configuration with all built-in metrics enabled for reporting"
    ```yaml
    Writable:
      Telemetry:
        Interval: "30s"
        Metrics:
          MessagesReceived: true
          InvalidMessagesReceived: true
          PipelineMessagesProcessed: true 
          PipelineMessageProcessingTime: true
          PipelineProcessingErrors: true 
          HttpExportSize: true 
          HttpExportErrors: true
          MqttExportSize: true 
          MqttExportErrors: true 
        Tags: # Contains the service level tags to be attached to all the service's metrics
        Gateway: "my-iot-gateway" # Tag must be added here or via Consul Env Override can only change existing value, not added new ones.
    ```

## Custom Application Service Metrics

The Custom Application Service Metrics capability allows for custom application services to define, collect and report their own custom service metrics.

 The following are the steps to collect and report custom service metrics:

1. Determine the metric type that needs to be collected
    - `counter` - Track the integer count of something
    - `gauge` - Track the integer value of something  
    - `gaugeFloat64` - Track the float64 value of something 
    - `timer` - Track the time it takes to accomplish a task
    - `histogram` - Track the integer value variance of something
    
2. Create instance of the metric type from `github.com/rcrowley/go-metrics`
    - `myCounter = gometrics.NewCounter()`
    - `myGauge = gometrics.NewGauge()`
    - `myGaugeFloat64 = gometrics.NewGaugeFloat64()`
    - `myTimer = gometrics.NewTime()`
    - `myHistogram = gometrics.NewHistogram(gometrics.NewUniformSample(<reservoir size))`
    
3. Determine if there are any tags to report along with your metric. Not common so `nil` is typically passed for the `tags map[strings]string` parameter in the next step.

4. Register your metric(s) with the MetricsManager from the `service` or `pipeline function context` reference. See [Application Service API](../api/ApplicationServiceAPI.md/#metricsmanager) and [App Function Context API](../api/AppFunctionContextAPI.md/#metricsmanager) for more details:
    - `service.MetricsManager().Register("MyCounterName", myCounter, nil)`
    - `ctx.MetricsManager().Register("MyCounterName", myCounter, nil)`

5. Collect the metric
    - `myCounter.Inc(someIntvalue)`
    - `myCounter.Dec(someIntvalue)`
    - `myGauge.Update(someIntvalue)`
    - `myGaugeFloat64.Update(someFloatvalue)`
    - `myTimer.Update(someDuration)`
    - `myTimer.Time(func { do sometime})`
    - `myTimer.UpdateSince(someTimeValue)`
    - `myHistogram.Update(someIntvalue)`
    
6. Configure reporting of the service's metrics. See `Writable.Telemetry` configuration details in the [Application Service Configuration](../../Configuration.md/#writable) section for more detail.

    !!! example "Example - Service Telemetry Configuration"
        ```yaml
        Writable:
          Telemetry:
            Interval: "30s"
            Metrics:
              MyCounterName: true
              MyGaugeName: true
              MyGaugeFloat64Name: true
              MyTimerName: true
              MyHistogram: true
            Tags: # Contains the service level tags to be attached to all the service's metrics
              Gateway: "my-iot-gateway" # Tag must be added here or via Consul Env Override can only change existing value, not added new ones.
        ```
    
    !!! note
        The metric names used in the above configuration (to enable or disable reporting of a metric) must match the metric name used when the metric is registered. A partial match of starts with is acceptable, i.e. the metric name registered starts with the above configured name.