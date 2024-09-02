# Supporting Services

![image](EdgeX_SupportingServices.png)

The supporting services encompass a wide range of micro services to include [edge analytics](../../general/Definitions.md#edge-analytics) (also known as local analytics). Micro services in the supporting services layer perform normal software application duties such as scheduler, and notifications/alerting .

These services often need some amount of core services to function.  In all cases, consider supporting service optional. Leave these services out of an EdgeX deployment depending on use case needs and system resources.

Supporting services include:

- [Rules Engine](./eKuiper/Ch-eKuiper.md):  the reference implementation edge analytics service that performs if-then conditional [actuation](../../general/Definitions.md#actuate) at the edge based on sensor data collected by the EdgeX instance.  Replace or augment this service with use case specific analytics capability.
- [Support Scheduler](./scheduler/Purpose.md):  an internal EdgeX “clock” that can kick off operations in any EdgeX service.  At a configuration specified time, the service will call on any EdgeX service API URL via REST to trigger an operation.  For example, at appointed times, the scheduler service calls on core data APIs to expunge old sensed events already exported out of EdgeX.
- [Support Cron Scheduler](./cronScheduler/Purpose.md):  provides a mechanism that can kick off operations in any EdgeX service. At a configuration specified time or a crontab expression scheduled time, the service calls on any EdgeX service via REST, EdgeX Message Bus, or Device Control to trigger an operation.  For example, at appointed times, the scheduler service calls on core data APIs to expunge old sensed events already exported out of EdgeX.
- [Support Notifications](./notifications/Purpose.md):  provides EdgeX services with a central facility to send out notifications.  These are notices sent to another system or to a person monitoring the EdgeX instance (internal service communications are often handled more directly).
