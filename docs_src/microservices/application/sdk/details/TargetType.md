---
title: App SDK - Target Type
---

# App Functions SDK - Target Type

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
