# Core Metadata

## 

The Core Metadata microservice includes the device/sensor metadata database
and APIs to expose this database to other services. In particular, the
device provisioning service deposits and manages device metadata through
this service's API. See [Core Metadata](../../microservices/core/metadata/Ch-Metadata.md) for more details about this service.

[Core Metadata V2 API Swagger Documentation](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata)

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Core Metadata has changed to use DTOs (Data Transfer Objects) for all responses and for all POST/PUT/PATCH requests. 

