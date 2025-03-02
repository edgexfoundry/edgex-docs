---
title: App SDK - Target Type
---

# App Functions SDK for Python - Target Type

The target type is the object type of the incoming data that is sent to the first function in the function pipeline. By default, this is an EdgeX `Event` since typical usage is receiving `Events` from the EdgeX MessageBus. 

There are scenarios where the incoming data is not an EdgeX `Event`. One example scenario is two application services are chained via the EdgeX MessageBus. The output of the first service is inference data from analyzing the original `Event`data, and published back to the EdgeX MessageBus. The second service needs to be able to let the SDK know the target type of the input data it is expecting.

For usages where the incoming data is not `events`, the `TargetType` of the expected incoming data can be set when the `ApplicationService` instance is created using the `NewAppServiceWithTargetType()` factory function.

!!! example "Example - Set and use custom Target Type"

    ``` python
    from typing import Any, Tuple
    from app_functions_sdk_py.factory import new_app_service
    from app_functions_sdk_py.interfaces import AppFunctionContext

    class Person:
        def __init__(self):
            self.FirstName = ""
            self.LastName = ""
        
    service, result = new_app_service(self.service_key, Person())  
    ```    
    
    `TargetType` must be set to an instance of your target type such as `Person()`. The first function in your function pipeline will be passed an instance of your target type. In the example above, the first function in the pipeline would start something like:
    
    ``` python
    def my_person_function(ctx: AppFunctionContext, data: Any) -> Tuple[bool, Any]:
        
        ctx.logger().debug("my_person_function executing")
        
        if data is None:
            return False, ValueError("no data received to my_person_function")
        
        if not isinstance(data, Person):
            return False, ValueError("data is not of type Person")
        
        ctx.logger().info(f"Person data received: {vars(data)}")
        
        # ... do something with the data

        return True, data
    ```

The SDK supports un-marshaling JSON encoded data into an instance of the target type. If your incoming data is not JSON encoded, you then need to set the `TargetType` to `bytes()`.

If the target type is set to `bytes()` the incoming data will not be un-marshaled. The content type, if set, will be set on the `interfaces.AppFunctionContext` and can be access via the `input_content_type()` API. Your first function will be responsible for decoding the data or not.
