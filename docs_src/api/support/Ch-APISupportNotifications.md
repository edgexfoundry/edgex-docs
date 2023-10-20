# Support Notifications

When a person or a system needs to be informed of something discovered on the node by another microservice on the node, EdgeX Foundry's Support Notifications microservice delivers that information. Examples of Alerts and Notifications that other services might need to broadcast include sensor data detected outside of certain parameters, usually detected by a Rules Engine service, or a system or service malfunction usually detected by system management services.  See [Support Notifications](../../microservices/support/notifications/Ch-AlertsNotifications.md) for more details about this service.

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/edgex-go/{{edgexversion}}/openapi/{{api_version}}/support-notifications.yaml"/>
