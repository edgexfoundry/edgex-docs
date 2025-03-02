---
title: App SDK - Custom REST APIs
---

# App Functions SDK for Python - Custom REST APIs

It is not uncommon to require your own custom REST APIs when building an Application Service. Rather than spin up your own webserver inside your app (alongside the already existing running webserver), we've exposed a method that allows you to add your own routes to the existing webserver. A few routes are reserved and cannot be used:

- /api/{{api_version}}/version
- /api/{{api_version}}/ping
- /api/{{api_version}}/config
- /api/{{api_version}}/trigger
- /api/{{api_version}}/secret

To add your own route, use the `add_custom_route(route: str, use_auth: bool, handler: Callable, methods: Optional[List[str]] = None)` API provided on the `ApplicationService` interface. 

!!! example  "Example - Add Custom REST route"

    ``` python
    service, result := pkg.NewAppService(serviceKey)   
    
    def my_handler(req: Request, resp: Response):
        service.logger().info("Hello from my_handler")
        resp.status_code = 200
        return {"message": "hello"}

    service.add_custom_route("/myroute", False, my_handler, methods=["GET"])  
    ```

Under the hood, this simply adds the provided route, handler, and method to the `fastapi` router used in the SDK. For more information on `fastapi` you can check out the GitHub repo [here](https://github.com/fastapi/fastapi). 
You can access the `interfaces.ApplicationService` API for resources such as the logging client as shown above.

- [See here for a complete example](https://github.com/IOTechSystems/app-functions-sdk-python/blob/main/examples/custom-rest-api)
- [See here for further information on the ApplicationService API](../api/ApplicationServiceAPI.md)
