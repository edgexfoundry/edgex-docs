---
title: Device Service SDK - Custom REST APIs
---

# Device Service SDK - Custom REST APIs

You can customize your own REST APIs when building a Device Service but a few routes are reserved and cannot be used:

- /api/{{api_version}}/version
- /api/{{api_version}}/ping
- /api/{{api_version}}/config
- /api/{{api_version}}/trigger
- /api/{{api_version}}/secret

To add your own route, use the `AddCustomRoute()` API provided on the `DeviceService` interface. 

!!! example  "Example - Add Custom REST route"

    ``` go      
    AddCustomRoute(route string, authentication Authentication, handler func(e echo.Context) error, methods ...string) error
    ```    

Under the hood, this simply adds the provided route, handler, and method to the `echo` router used in the SDK. For more information on `echo` you can check out the GitHub repo [here](https://github.com/labstack/echo). 
You can access the `interfaces.DeviceService` API for resources such as the logging client by pulling it from the context as shown above -- this is useful for when your routes might not be defined in your `main.go`  where you have access to the ``interfaces.DeviceService`` instance.
