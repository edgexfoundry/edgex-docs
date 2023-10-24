---
title: App SDK - Custom REST APIs
---

# App Functions SDK - Custom REST APIs

It is not uncommon to require your own custom REST APIs when building an Application Service. Rather than spin up your own webserver inside your app (alongside the already existing running webserver), we've exposed a method that allows you to add your own routes to the existing webserver. A few routes are reserved and cannot be used:

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
