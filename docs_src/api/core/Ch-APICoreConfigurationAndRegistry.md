# Configuration and Registry

EdgeX uses the 3rd party Consul microservice as the implementations for Configuration and Registry. The RESTful APIs are provided by Consul directly, and several communities supply Consul client libraries for different programming languages, including Go (official), Python, Java, PHP, Scala, Erlang/OTP, Ruby, Node.js, and C\#.

!!! edgey "EdgeX 2.0"
    New for Edgex 2.0 is Secure Consul when running EdgeX in secure mode. See the [Secure Consul](../../../security/Ch-Secure-Consul) section for more details.

For the client libraries of different languages, please refer to the
list on this page:

> <https://www.consul.io/downloads_tools.html>

## Configuration Management

For the current API documentation, please refer to the official Consul
web site:

> <https://www.consul.io/intro/getting-started/kv.html>
> <https://www.consul.io/docs/agent/http/kv.html>

## Service Registry

For the current API documentation, please refer to the official Consul
web site:

> <https://www.consul.io/intro/getting-started/services.html>
> <https://www.consul.io/docs/agent/http/catalog.html>
> <https://www.consul.io/docs/agent/http/agent.html>
> <https://www.consul.io/docs/agent/checks.html>
> <https://www.consul.io/docs/agent/http/health.html>

**Service Registration**

While each microservice is starting up, it will connect to Consul to
register its endpoint information, including microservice ID, address,
port number, and health checking method. After that, other microservices
can locate its URL from Consul, and Consul has the ability to monitor
its health status. The RESTful API of registration is described on the
following Consul page:

> <https://www.consul.io/docs/agent/http/agent.html#agent_service_register>

**Service Deregistration**

Before microservices shut down, they have to deregister themselves from
Consul. The RESTful API of deregistration is described on the following
Consul page:

> <https://www.consul.io/docs/agent/http/agent.html#agent_service_deregister>

**Service Discovery**

Service Discovery feature allows client micro services to query the
endpoint information of a particular microservice by its microservice
IDor list all available services registered in Consul. The RESTful API
of querying service by microservice IDis described on the following
Consul page:

> <https://www.consul.io/docs/agent/http/catalog.html#catalog_service>

The RESTful API of listing all available services is described on the
following Consul page:

> <https://www.consul.io/docs/agent/http/agent.html#agent_services>

**Health Checking**

Health checking is a critical feature that prevents using services that
are unhealthy. Consul provides a variety of methods to check the health
of services, including Script + Interval, HTTP + Interval, TCP +
Interval, Time to Live (TTL), and Docker + Interval. The detailed
introduction and examples of each checking methods are described on the
following Consul page:

> <https://www.consul.io/docs/agent/checks.html>

The health checks should be established during service registration.
Please see the paragraph on this page of Service Registration section.

## Consul UI

Consul has UI which allows you to view the health of registered services and view/edit services' individual configuration. Learn more about the UI on the following Consul page:

> [https://learn.hashicorp.com/tutorials/consul/get-started-explore-the-ui](https://learn.hashicorp.com/tutorials/consul/get-started-explore-the-ui)

!!! edgey "EdgeX 2.0"
    Please note that as of EdgeX 2, Consul can be secured.  When EdgeX is running in secure mode with [secure Consul](https://docs.edgexfoundry.org/2.0/security/Ch-Secure-Consul/), you must provide  Consul's access token to get to the UI referenced above.  See [How to get Consul ACL token](https://docs.edgexfoundry.org/2.0/security/Ch-Secure-Consul/#how-to-get-consul-acl-token) for details.

