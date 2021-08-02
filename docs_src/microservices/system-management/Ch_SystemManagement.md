# System Management Micro Services

![image](EdgeX_SystemManagement.png)

!!! Warning
    EdgeX System Management services are deprecated with the Ireland release.  The service will not be immediately removed (in Ireland or even Jakarta), but adopters should note that it has been tagged for eventual replacement.  The reasons for this include:

    - Deployment and orchestration systems (Docker Compose, Kubernetes, etc.) provide for the ability to start, stop, and restart the EdgeX services (making EdgeX system management capability redundant or not-aligned with the current deployment/orchestration tool/strategy).
    - Native start, stop and restart of services is highly dependent on the operating system and/or deployment mechanism.  EdgeX is only providing the Docker Linux "executor" for these today - which was redundant to the capability in Docker Compose.  The reference implementation was insufficient to assist in other native environments.
    - Configuration information is available from Consul (the configuration service) or the service directly.  System Management was not being used to provide this information or could be out of sync with the configuration service.
    - Metrics information provided by System Management is dependent on the underlying deployment means (e.g., Docker).  The metrics telemetry has information about the memory and CPU used by the service, but this data is readily available from the operating system tools or Docker environment (if containerized).  The telemetry really needed by adopters is EdgeX specific telemetry that outside-application tools/systems cannot provide (e.g., the number of events being created by a device service).
    -Because System Management was not made aware of the addition/removal of services (without a reset of its configuration and a restart of the service), its ability to perform any action with all services (for example stopping all services) was dependent on its static list of services configuration being kept up to date.
    
    In a future release (unnamed and unscheduled at this time), EdgeX will offer a better EdgeX facility to collect EdgeX specific metrics telemetry.  EdgeX facilitation/support for deployment/orchestration tools will continue to grow (to include integration with LF Edge projects like OpenHorizon or Baetyl) to support service start/stop/restart and allow these tools to better track generic container metrics (memory/CPU).  EdgeX configuration service (however implemented) will be the single source of truth regarding service configuration.  If there is a documented use case for the existing system management features not covered by other capability in the future, a new system management service may be provide but providing for the needs in a platform independent fashion.


System Management facilities provide the central point of contact for external management systems to start/stop/restart EdgeX services, get the configuration for a service, the status/health of a service, or get metrics on the EdgeX services (such as memory usage) so that the EdgeX services can be monitored.

## Facilitating Larger Management Systems

EdgeX is an edge platform.  It typically runs as close to the physical sensor/device world as it can in order to provide the fastest and most efficient collection and reaction to the data that it can.  In a larger solution deployment, there could be several instances of EdgeX each managing and controlling a subset of the “things” in the overall deployment.

![image](Ch_CentralManagementSystem.png)

In a very big deployment, a larger management system will want to manage the edge systems and resources of the overall deployment.  Just as there is a management system to control all the nodes and infrastructure within a cloud data center, and across cloud data centers, so too there will likely be management systems that will manage and control all the nodes (from edge to cloud) and infrastructure of a complete fog or IoT deployment.

EdgeX system management is not the larger control management system.  Instead, EdgeX system management capability is meant to facilitate the larger control management systems.  When a management system wants to start or stop the entire deployment, EdgeX system management capability is there to receive the command and start or stop the EdgeX platform and associated infrastructure of the EdgeX instance that it is aware of.

Likewise, when the larger central management system needs service metrics or configuration from EdgeX, it can call on the EdgeX system management services to provide the information it needs (thereby avoiding communications with each individual service).

![image](Ch_SystemManagement_Facilitates_Central.png)

## Use is Optional 

There are many control management systems today.  Each of these systems operates differently. Some solutions may not require the EdgeX management components.  For example, if your edge platform is large enough to support the use of something like [Kubernetes](https://kubernetes.io/) or [Swarm](https://docs.docker.com/engine/swarm/) to deploy, orchestrate and manage your containerized edge applications, you may not require the system management services provided with EdgeX Foundry.  Therefore, use of the system management services is considered optional.

## System Management Services

There are two services that provide the EdgeX system management capability.

- [System Management Agent](./agent/Ch_SysMgmtAgent.md): the micro service that other systems or services communicate with and make their management request (to start/stop/restart, get the configuration, get the status/health, or get metrics of the EdgeX service).  It communicates with the EdgeX micro services or executor (see below) to satisfy the requests. 
- [System Management Executor](./executor/Ch_SysMgmtExecutor.md): the excutable that performs the start, stop and restart of the services as well as metrics gathering from the EdgeX services.  While EdgeX provides a single reference implementation of the system management executor today (one for Docker environments), there may be many implementations of the executor in the future.
