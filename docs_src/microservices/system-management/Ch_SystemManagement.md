# System Management Micro Services

![image](EdgeX_SystemManagement.png)

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
