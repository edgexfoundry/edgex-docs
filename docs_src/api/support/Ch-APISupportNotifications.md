# Support Notifications

When a person or a system needs to be informed of something discovered on the node by another microservice on the node, EdgeX Foundry's Support Notifications microservice delivers that information. Examples of Alerts and Notifications that other services might need to broadcast include sensor data detected outside of certain parameters, usually detected by a Rules Engine service, or a system or service malfunction usually detected by system management services.  See [Support Notifications](../../microservices/support/notifications/Ch-AlertsNotifications.md) for more details about this service.

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Support Notifications has changed to use DTOs (Data Transfer Objects) for all responses and for all POST/PUT/PATCH requests. All query APIs (GET) which return multiple objects, such as /all, provide `offset` and `limit` query parameters.

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/edgex-go/{{dev_version}}/openapi/{{api_version}}/support-notifications.yaml"/>