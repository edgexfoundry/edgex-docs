# Support Scheduler

EdgeX Foundry's Support Scheduler microservice to schedule actions to occur on specific intervals. See
[Support Scheduler](../../microservices/support/scheduler/Ch-Scheduler.md) for more details about this service.

[Support Scheduler V2 API Swagger Documentation](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/support-scheduler/2.3.0)

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Support Scheduler has changed to use DTOs (Data Transfer Objects) for all responses and for all POST/PUT/PATCH requests. All query APIs (GET) which return multiple objects, such as /all, provide `offset` and `limit` query parameters.

