# Core Data

EdgeX Foundry Core Data microservice includes the Events/Readings database collected from devices /sensors and APIs to expose this database to other services. Its APIs to provide access to Add, Query and Delete Events/Readings. See [Core Data](../../microservices/core/data/Ch-CoreData.md) for more details about this service.

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Core Data has changed to use DTOs (Data Transfer Objects) for all responses and for all POST requests. All query APIs (GET) which return multiple objects, such as /all, provide `offset` and `limit` query parameters.

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/edgex-go/{{dev_version}}/openapi/{{api_version}}/core-data.yaml"/>

