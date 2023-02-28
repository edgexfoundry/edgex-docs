# Application Services 

The App Functions SDK is provided to help build Application Services by assembling triggers, pre-existing functions and custom functions of your making into a functions pipeline. This functions pipeline processes messages received by the configured trigger.  See [Application Functions SDK](../../microservices/application/ApplicationFunctionsSDK.md) for more details on this SDK.

The App Functions SDK provides a RESTful API that all Application Services inherit from the SDK.

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the App Functions SDK has changed to use DTOs (Data Transfer Objects) for all responses and for POST requests. One exception is the `/api/v2/trigger` endpoint that is enabled when the Trigger is configured to be `http`. This endpoint accepts any data POSTed to it.

---

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/app-functions-sdk-go/{{dev_version}}/openapi/{{api_version}}/app-functions-sdk.yaml"/>
