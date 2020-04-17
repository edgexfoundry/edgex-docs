# Getting Started

## The Application Functions SDK

The SDK is built around the idea of a "Functions Pipeline". A functions pipeline is a collection of various functions that process the data in the order that you've specified. The functions pipeline is executed by the specified [trigger](../microservices/application/Triggers.md) in the `configuration.toml` . The first function in the pipeline is called with the event that triggered the pipeline (ex. `events.Model`). Each successive call in the pipeline is called with the return result of the previous function. Let's take a look at a simple example that creates a pipeline to filter particular device ids and subsequently transform the data to XML:
```go
package main

import (
	"fmt"
	"github.com/edgexfoundry/app-functions-sdk-go/appsdk"
	"github.com/edgexfoundry/app-functions-sdk-go/pkg/transforms"
	"os"
)

func main() {

	// 1) First thing to do is to create an instance of the EdgeX SDK, giving it a service key
	edgexSdk := &appsdk.AppFunctionsSDK{
		ServiceKey: "SimpleFilterXMLApp", // Key used by Registry (Aka Consul)
	}

	// 2) Next, we need to initialize the SDK
	if err := edgexSdk.Initialize(); err != nil {
		message := fmt.Sprintf("SDK initialization failed: %v\n", err)
		if edgexSdk.LoggingClient != nil {
			edgexSdk.LoggingClient.Error(message)
		} else {
			fmt.Println(message)
		}
		os.Exit(-1)
	}

	// 3) Shows how to access the application's specific configuration settings.
	deviceNames, err := edgexSdk.GetAppSettingStrings("DeviceNames")
	if err != nil {
		edgexSdk.LoggingClient.Error(err.Error())
		os.Exit(-1)
	}    

	// 4) This is our pipeline configuration, the collection of functions to
	// execute every time an event is triggered.
	if err = edgexSdk.SetFunctionsPipeline(
			transforms.NewFilter(deviceNames).FilterByDeviceName, 
			transforms.NewConversion().TransformToXML,
		); err != nil {
		edgexSdk.LoggingClient.Error(fmt.Sprintf("SDK SetPipeline failed: %v\n", err))
		os.Exit(-1)
	}

	// 5) Lastly, we'll go ahead and tell the SDK to "start" and begin listening for events to trigger the pipeline.
	err = edgexSdk.MakeItRun()
	if err != nil {
		edgexSdk.LoggingClient.Error("MakeItRun returned error: ", err.Error())
		os.Exit(-1)
	}

	// Do any required cleanup here

	os.Exit(0)
}
```

The above example is meant to merely demonstrate the structure of your application. Notice that the output of the last function is not available anywhere inside this application. You must provide a function in order to work with the data from the previous function. Let's go ahead and add the following function that prints the output to the console.

```go
func printXMLToConsole(edgexcontext *appcontext.Context, params ...interface{}) (bool,interface{}) {
  if len(params) < 1 { 
  	// We didn't receive a result
  	return false, errors.New("No Data Received")
  }
  println(params[0].(string))
  return true, nil
}
```
After placing the above function in your code, the next step is to modify the pipeline to call this function:

```go
edgexSdk.SetFunctionsPipeline(
  transforms.NewFilter(deviceNames).FilterByDeviceName, 
  transforms.NewConversion().TransformToXML,
  printXMLToConsole //notice this is not a function call, but simply a function pointer. 
)
```
After making the above modifications, you should now see data printing out to the console in XML when an event is triggered.
!!! note
    You can find this example called "Simple Filter XML" and more located in the [examples](../examples/AppServiceExamples.md) section.

Up until this point, the pipeline has been [triggered](#triggers) by an event over HTTP and the data at the end of that pipeline lands in the last function specified. In the example, data ends up printed to the console. Perhaps we'd like to send the data back to where it came from. In the case of an HTTP trigger, this would be the HTTP response. In the case of a message bus, this could be a new topic to send the data back to for other applications that wish to receive it. To do this, simply call `edgexcontext.Complete([]byte outputData)` passing in the data you wish to "respond" with. In the above `printXMLToConsole(...)` function, replace `println(params[0].(string))` with `edgexcontext.Complete([]byte(params[0].(string)))`. You should now see the response in your postman window when testing the pipeline.