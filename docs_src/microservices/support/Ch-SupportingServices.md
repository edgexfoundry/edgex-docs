# Supporting Services Microservices

![image](EdgeX_SupportingServices.png)

The supporting services encompass a wide range of micro services to include [edge analytics](../../general/Definitions.md#edge-analytics) (also known as local analytics). Micro services in the supporting services layer perform normal software application duties such as logging, scheduling, and notifications/alerting .

These services often need some amount of core services to function.  In all cases, consider supporting service optional. Leave these services out of an EdgeX deployment depending on use case needs and system resources.

Supporting services include:

- [Rules Engine](./rulesengine/Ch-RulesEngine.md):  the reference implementation edge analytics service that performs if-then conditional [actuation](../../general/Definitions.md#actuate) at the edge based on sensor data collected by the EdgeX instance.  Replace or augment this service with use case specific analytics capability.
- [Scheduling](./scheduler/Ch-Scheduling.md):  an internal EdgeX “clock” that can kick off operations in any EdgeX service.  At a configuration specified time, the service will call on any EdgeX service API URL via REST to trigger an operation.  For example, at appointed times, the scheduling service calls on core data APIs to expunge old sensed events already exported out of EdgeX.
- [Logging](./logging/Ch-Logging.md):  provides a central logging facility for EdgeX services.  Services send log entries into the logging facility via a REST API where log entries can be persisted in a database or log file.  
- [Alerts and Notifications](./notifications/Ch-AlertsNotifications.md):  provides EdgeX services with a central facility to send out an alert or notification.  These are notices sent to another system or to a person monitoring the EdgeX instance (internal service communications are often handled more directly).

    !!! Note
        Logging is being deprecated and will be removed in a future release.  Services will still be able to log using standard output or log to a file.  Most operating systems and logging facilities provide better logging aggregation then what EdgeX was providing through the logging service.

