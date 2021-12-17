# Core Command

EdgeX Foundry's Command microservice is a conduit for other services to
trigger action on devices and sensors through their managing Device
Services. See [Core Command](../../../microservices/core/command/Ch-Command/)  for more details about this service.

The service provides an API to get the list of commands that
can be issued for all devices or a single device. Commands are divided
into two groups for each device:

-   GET commands are issued to a device or sensor to get a current value
    for a particular attribute on the device, such as the current
    temperature provided by a thermostat sensor, or the on/off status of
    a light.
-   SET commands are issued to a device or sensor to change the current
    state or status of a device or one of its attributes, such as
    setting the speed in RPMs of a motor, or setting the brightness of a
    dimmer light.

[Core Command V2 API Swagger Documentation](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-command/2.1.0)

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the REST API provided by the Core Command has changed to use DTOs (Data Transfer Objects) for all responses and for all PUT requests. All query APIs (GET) which return multiple objects, such as /all, provide `offset` and `limit` query parameters.

