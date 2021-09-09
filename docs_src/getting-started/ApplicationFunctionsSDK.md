# Getting Started

## The Application Functions SDK

The SDK is built around the idea of a "Functions Pipeline". A functions pipeline is a collection of various functions that process the data in the order that you've specified. The functions pipeline is executed by the specified [trigger](../microservices/application/Triggers.md) in the `configuration.toml` . The first function in the pipeline is called with the event that triggered the pipeline (ex. `dtos.Event`). Each successive call in the pipeline is called with the return result of the previous function. Let's take a look at a simple example that creates a pipeline to filter particular device ids and subsequently transform the data to XML:
```go
package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/edgexfoundry/app-functions-sdk-go/v2/pkg"
	"github.com/edgexfoundry/app-functions-sdk-go/v2/pkg/interfaces"
	"github.com/edgexfoundry/app-functions-sdk-go/v2/pkg/transforms"
)

const (
	serviceKey = "app-simple-filter-xml"
)

func main() {
	// turn off secure mode for examples. Not recommended for production
	_ = os.Setenv("EDGEX_SECURITY_SECRET_STORE", "false")

	// 1) First thing to do is to create an new instance of an EdgeX Application Service.
	service, ok := pkg.NewAppService(serviceKey)
	if !ok {
		os.Exit(-1)
	}
    
	// Leverage the built in logging service in EdgeX
	lc := service.LoggingClient()

	// 2) shows how to access the application's specific configuration settings.
	deviceNames, err := service.GetAppSettingStrings("DeviceNames")
	if err != nil {
		lc.Error(err.Error())
		os.Exit(-1)
	}
    
	lc.Info(fmt.Sprintf("Filtering for devices %v", deviceNames))

	// 3) This is our pipeline configuration, the collection of functions to
	// execute every time an event is triggered.
	if err := service.SetFunctionsPipeline(
		transforms.NewFilterFor(deviceNames).FilterByDeviceName,
		transforms.NewConversion().TransformToXML
	); err != nil {
		lc.Errorf("SetFunctionsPipeline returned error: %s", err.Error())
		os.Exit(-1)
	}

	// 4) Lastly, we'll go ahead and tell the SDK to "start" and begin listening for events
	// to trigger the pipeline.
	err = service.MakeItRun()
	if err != nil {
		lc.Errorf("MakeItRun returned error: %s", err.Error())
		os.Exit(-1)
	}

	// Do any required cleanup here

	os.Exit(0)
}
```

The above example is meant to merely demonstrate the structure of your application. Notice that the output of the last function is not available anywhere inside this application. You must provide a function in order to work with the data from the previous function. Let's go ahead and add the following function that prints the output to the console.

```go
func printXMLToConsole(ctx interfaces.AppFunctionContext, data interface{}) (bool, interface{}) {
	// Leverage the built in logging service in EdgeX
	lc := ctx.LoggingClient()

	if data == nil {
		return false, errors.New("printXMLToConsole: No data received")
	}

	xml, ok := data.(string)
	if !ok {
		return false, errors.New("printXMLToConsole: Data received is not the expected 'string' type")
	}

  println(xml)
  return true, nil
}
```
After placing the above function in your code, the next step is to modify the pipeline to call this function:

```go
if err := service.SetFunctionsPipeline(
		transforms.NewFilterFor(deviceNames).FilterByDeviceName,
		transforms.NewConversion().TransformToXML,
        printXMLToConsole //notice this is not a function call, but simply a function pointer. 
	); err != nil {
    ...
}
```
Set the Trigger type to `http` in [res/configuration.toml](https://github.com/edgexfoundry/edgex-examples/blob/main/application-services/custom/simple-filter-xml/res/configuration.toml)

```toml
[Trigger]
Type="http"
```

Using PostMan or curl send the following JSON to `localhost:<port>/api/v2/trigger`

```json
{
    "requestId": "82eb2e26-0f24-48ba-ae4c-de9dac3fb9bc",
    "apiVersion": "v2",
    "event": {
        "apiVersion": "v2",
        "deviceName": "Random-Float-Device",
        "profileName": "Random-Float-Device",
        "sourceName" : "Float32",
        "origin": 1540855006456,
        "id": "94eb2e26-0f24-5555-2222-de9dac3fb228",
        "readings": [
            {
                "apiVersion": "v2",
                "resourceName": "Float32",
                "profileName": "Random-Float-Device",
                "deviceName": "Random-Float-Device",
                "value": "76677",
                "origin": 1540855006469,
                "ValueType": "Float32",
                "id": "82eb2e36-0f24-48aa-ae4c-de9dac3fb920"
            }
        ]
    }
}
```

After making the above modifications, you should now see data printing out to the console in XML when an event is triggered.

!!! note
    You can find this complete example "[Simple Filter XML](https://github.com/edgexfoundry/edgex-examples/tree/main/application-services/custom/simple-filter-xml)" and more examples located in the [examples](../examples/AppServiceExamples.md) section.

Up until this point, the pipeline has been [triggered](../microservices/application/Triggers.md) by an event over HTTP and the data at the end of that pipeline lands in the last function specified. In the example, data ends up printed to the console. Perhaps we'd like to send the data back to where it came from. In the case of an HTTP trigger, this would be the HTTP response. In the case of  EdgeX MessageBus, this could be a new topic to send the data back to the MessageBus for other applications that wish to receive it. To do this, simply call `ctx.SetResponseData(data []byte)` passing in the data you wish to "respond" with. In the above `printXMLToConsole(...)` function, replace `println(xml)` with `ctx.SetResponseData([]byte(xml))`. You should now see the response in your postman window when testing the pipeline.