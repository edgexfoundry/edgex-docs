# Configuration and Registry

EdgeX uses the Core Keeper microservice for Configuration and Registry functions. Core Keeper integrates Redis for data persistence and leverages EdgeX modules `go-mod-configuration` and `go-mod-registry` to implement these services within the EdgeX architecture.

## Configuration Management

For current Configuration Management, refer to the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

## Service Registry

For detailed API documentation on Core Keeper's service registry, refer to the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

**Service Registration**

When each microservice starts up, it connects to Core Keeper to register its endpoint details, including microservice ID, address, port, and health-check methods. Other microservices can then discover its URL through Core Keeper, which also monitors health status. API details for registration are provided in the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

**Service Deregistration**

Before shutting down, microservices must deregister from Core Keeper. The deregistration API is described in the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

**Service Discovery**

The Service Discovery feature enables client microservices to query endpoint information for specific microservices by their ID or to list all available services registered in Core Keeper. Refer to the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

**Health Checking**

Health checking ensures only healthy services are used. Core Keeper offers various health check methods such as Script + Interval, HTTP + Interval, TCP + Interval, TTL, and Docker + Interval. For more information and examples of each method, see the [Core Keeper API documentation](./Ch-APICoreKeeper.md).

Health checks should be established during service registration, as detailed in the Service Registration section.

## Core Keeper UI

Core Keeper does not have a user interface. All interactions are handled programmatically via its API.
