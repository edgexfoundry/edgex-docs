# Device Services

The EdgeX Foundry Device Service Software Development Kit (SDK) takes the Developer through the step-by-step process to create an EdgeX Foundry Device Service microservice. See [Device Service SDK](../../microservices/device/sdk/Ch-DeviceSDK.md) for more details on this SDK.

The Device Service SDK provides a RESTful API that all Device Services inherit from the SDK.

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Device Service SDK has changed to use DTOs (Data Transfer Objects) for all responses and for all POST/PUT requests. 

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/device-sdk-go/{{dev_version}}/openapi/{{api_version}}/device-sdk.yaml"/>
