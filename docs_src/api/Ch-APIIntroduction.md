# Introduction

Each of the EdgeX services (core, supporting, management, device and application) implement a RESTful API. This section provides details about each service's API. You will see there is a common set of API's that all services implement, which are:

- Version
- Config
- Ping

Each Edgex Service's RESTful API is documented via Swagger. A link is provided to the swagger document in the service specific documentation. 

Also included in this API Reference are a couple 3rd party services (Configuration/Registry and Rules Engine). These services do not implement the above common APIs and don't not have swagger documentation. Links are provided to their appropriate documentation.

See the left side navigation for complete list of services to access their API Reference. 

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 all the EdgeX services use new DTOs (Data Transfer Objects) for all responses and for all POST/PUT/PATCH requests. All query APIs (GET) which return multiple objects, such as /all or /label/{label}, provide `offset` and `limit` query parameters.

