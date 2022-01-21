# Service Registry

<!--ts-->

- [Status](#status)
- [Context](#context)
- [Existing Behavior](#existing-behavior)
  * [Device Services](#device-services)
    + [Registry Client Interface Usage](#registry-client-interface-usage)
  * [Core and Support Services](#core-and-support-services)
  * [Security Proxy Setup](#security-proxy-setup)
- [History](#history)
- [Problem Statement](#problem-statement)
- [Decision](#decision)
- [References](#references)

<!--te-->

## Status

**Approved** (by TSC vote on 3/25/21)

## Context

An EdgeX system may be run with an optional service registry, the use of which (see the related ADR 0001-Registry-Refactor [1]) can be controlled
on a per-service basis via the ```-r/-registry``` commmand line options. For the purposes of this ADR, a base assumption is that the registry has been
enabled for all services. The default service registry used by EdgeX is Consul [2] from Hashicorp. Consul is also the default configuration provider
for EdgeX.

This ADR is meant to address the current usage of the registry by EdgeX services, and in particular whether the EdgeX services
are using the registry to determine the location of peer services vs. using static per-service configuration.
The reason this is being investigated is that there has been a proposal that EdgeX do away with the registry functionality, as the
current implementation is not considered _secure_, due to the current configuration of Consul as used by the latest version of EdgeX
(Hanoi/1.3.0).

According to the original Service Name Design document (v6) [3] written during the California (0.6) release of EdgeX, all EdgeX Foundry microservices
should be able to accomplish the following tasks:

 * Register with the configuration/registration (referred to simply as “the registry” for the rest of this document) provider (today Consul)
 * Respond to availability requests
 * Respond to shutdown requests by:
   * Cleaning up resources in an orderly fashion
   * Unregistering itself from the registry
 * _Get the address (host & port) of another EdgeX microservice by service name through the registry (when enabled)_

The purpose of this design is to ensure that services themselves advertise their location to the rest of the system by first self-
registering. Most service registries (including Consul) implement some sort of health check mechanism. If a service is failing one
or more health checks, the registry will stop reporting its availability when queried.

*Note* - the design specifically excludes device services from this service lookup, as Core Metadata maintains a persistent store of
DeviceService objects which provide service location for device services.

## Existing Behavior
This section documents the existing behavior in the Hanoi (1.3.x) version of EdgeX.

### Device Services
Device Virtual's behavior was first tested using the edgexfoundry snap (which is configured to always use the registry) by doing the following:

$ sudo snap install edgexfoundry
$ cp /var/snap/edgexfoundry/current/config/device-virtual/res/configuration.toml .

I edited the file, removing the ```[Client.Data]``` section completely and copied the
file back into place. Next I enabled device-virtual while monitoring the journal output.

```
$ sudo cp configuration.toml /var/snap/edgexfoundry/current/config/device-virtual/res/
$ sudo snap set edgexfoundry device-virtual=on
```

The following error was seen in the journal:

```
level=INFO app=device-virtual source=httpserver.go:94 msg="Web server starting (0.0.0.0:49990)"
error: fatal error; Host setting for Core Data client not configured
```

Next I followed the same steps, but instead of completely removing the client, I instead set the client ports to invalid
values. In this case the service logged the following errors and exited:

```
level=ERROR app=device-virtual source=service.go:149 msg="DeviceServicForName failed: Get \"http://localhost:3112/api/v1/deviceservice/name/device-virtual\": dial tcp 127.0.0.1:3112: connect: connection refused"
level=ERROR app=device-virtual source=init.go:45 msg="Couldn't register to metadata service: Get \"http://localhost:3112/api/v1/deviceservice/name/device-virtual\": dial tcp 127.0.0.1:3112: connect: connection refused\n"
```

**Note** - in order to run this second test, the easiest way to do so is to remove and reinstall the snap vs. manually wiping
out device-virtual's configuration in Consul. I could have also stopped the service, modified the configuration directly in Consul,
and restarted the service.

#### Registry Client Interface Usage
Next the service's usage of the go-mod-registry ```Client``` interface was examined:

```
type Client interface {
        // Registers the current service with Registry for discover and health check
        Register() error

        // Un-registers the current service with Registry for discover and health check
        Unregister() error

        // Simply checks if Registry is up and running at the configured URL
        IsAlive() bool

        // Gets the service endpoint information for the target ID from the Registry
        GetServiceEndpoint(serviceId string) (types.ServiceEndpoint, error)

        // Checks with the Registry if the target service is available, i.e. registered and healthy
        IsServiceAvailable(serviceId string) (bool, error)
}
```

#### Summary

If a device service is started with the registry flag set:

 - Both Device SDKs register with the registry on startup, and unregister from the registry on normal shutdown.
 - The Go SDK (device-sdk-go) queries the registry to check dependent service availability and health (via ```IsServiceAvailable```) on startup. Regardless of the registry setting, the Go SDK always sources the addresses of its dependent services from the Client* configuration stanzas.
 - The C SDK queries the registry for the addresses of its dependent services. It pings the services directly to determine their availbility and health.

### Core and Support Services
The same approach was used for Core and Support services (i.e. reviewing the usage of go-mod-bootstrap's ```Client``` interface), and ironically,
the SMA seems to be the only service in edgex-go that actually queries the registry for service location:

```
./internal/system/agent/getconfig/executor.go:		ep, err := e.registryClient.GetServiceEndpoint(serviceName)
./internal/system/agent/direct/metrics.go:		e, err := m.registryClient.GetServiceEndpoint(serviceName)
```

In summary, other than the SMA's configuration and metrics logic, the Core and Support services behave in the same manner as device-sdk-go.

**Note** - the SMA also has a longstanding issue [#2486](https://github.com/edgexfoundry/edgex-go/issues/2486) where it continuousy logs errors if one (or more) of the Support Services are not running. As described in the issue, this could be avoided if the SMA used the registry to determine if the services were actually available. See related issue [#1662](https://github.com/edgexfoundry/edgex-go/issues/1662) ('Look at Driving "Default Services List" via Configuration').

### Security Proxy Setup
The security-proxy-setup service also relies on static service address configuration to configure the server routes for each
of the services accessible through the API Gateway (aka Kong). Although it uses the same TOML-based client config keys as the
other services, these configuration values are only ever read from the security-proxy-setup's local configuration.toml file,
as the security services have never supported using our configuration provider (aka Consul).

**Note** - Another point worth mentioning with respect to security services is that in the Geneva and Hanoi releases the service health checks
registered by the services (and the associated ```IsServiceAvailable``` method) are used to orchestrate the ordered startup of the security
services via a set of Consul scripts. This additional orchestration is only performed when EdgeX is deployed via docker, and is slated to
to be removed as part of the Ireland release.

## History
After a bit of research reaching as far back as the California (0.6.1) release of EdgeX, I've managed to piece together why the
current implementation works the way it does. This history focues solely on the core and support services.

The California release of EdgeX was released in June of 2018 and was the first to include services written using Go. This version
of EdgeX as well as versions through the Fuji release all relied on a bootstrapping service called core-config-seed which was
responsible for seeding the configuration of all of the core and support services into Consul prior to any of the services being
started.

This release actually preceded usage of TOML for configuration files, and instead just used a flat key/value format,
with keys converted from legacy Java property names (e.g. meta.db.device.url ) to Camel[Pascal]/Case (e.g. MetaDeviceServiceURL).

I chose the config key mentioned above on purpose:

```
MetaDeviceURL = "http://edgex-core-metadata:48081/api/v1/device"
```

Not only did this config key provide the address of core metadata, it also provided the path of a specific REST endpoint. In later releases
of EdgeX, the address of the service and the specific endpoint paths were de-coupled. Instead of following the Service Name design (which
was finalized two months earlier), the initial implementation followed the legacy Java implementation and initialized its service clients
for each required REST endpoint (belonging to another EdgeX service) directly from the associated *URL config key read from Consul (if
enabled) or directly from the configuration file.

The shared client initialization code also created an Endpoint monitor goroutine and passed it a go channel channel used by the service
to receive updates to the REST API endpoint URL. This monitor goroutine effectively polled Consul every 15s (this became configurable in
later versions) for the client's service address and if a change was detected, would write the updated endpoint URL to the given channel,
effectively ensuring that the service started using the new URL.

It wasn't till late in the Geneva development cycle that I noticed log messages which made me aware of the fact that every one of our
services was making a REST call to check the address of a service endpoint every 15s, for **every** REST endpoint it used! An issue was
filed (https://github.com/edgexfoundry/edgex-go/issues/2594), and the client monitoring was removed as part of the Geneva 1.2.1 release.

## Problem Statement
The fundamental problem with the existing implementations (as decribed above), is that there is too much duplication of configuration across
services. For instance, Core Data's service port can easily be changed by passing the environment variable SERVICE_PORT to the service on
startup. This overrides the configuration read from the configuration provider, and will cause Core Data to listen on the new port,
however it has no impact on any services which use Core Data, as the client config for each is read from the configuration provider (excluding
security-proxy-setup).

This means in order to change a service port, environment variable overrides (e.g. CLIENTS_COREDARA_PORT) need to set for every client service as well as security-proxy-setup (if required).

## Decision
Update the core, support, and security-proxy-setup services to use go-mod-registry's ```Client.GetServiceEndpoint``` method (if started with the
```--registry``` option) to determine (a) if a service dependency is available and (b) use the returned address information to initialize client endpoints
(or setup the correct route in the case of proxy-setup). The same changes also need to be applied to the App Functions SDK and Go Device SDK, with
only minor changes required in the C Device SDK (see previous commments re: the current implementation).

**Note** - this design only works if service registration occurs _before_ the service initializes its clients. For instance, Core Data and Core Metadata
both depend on the other, and thus if both defer service registration till after client initialization, neither will be able to successfully lookup
the address of the other service.

## Consquences
One impact of this decision is that since the security-proxy-setup service currently runs _before_ any of the core and support services are
started, it would not be possible to implement this proposal without also modifying the service to use a lazy initialization of the API Gateway's
routes. As such, the implementation of this ADR will require more design work with respect to security-proxy-setup. Some of the issues include:

  * Splitting the configuration of the API Gateway from the service route intialization logic, either by making the service long-running or splitting
    route initialization into it's own service.
  * Handling registry and non-registry scenarios (i.e. add ```--registry``` command-line support to security-proxy-setup).
  * Handling changes to service address information (i.e. dynamically update API Gateway routes if/when service addresses change).
  * Finally the proxy-setup's configuration needs to be updated so that its ```Route``` entries use service-keys instead of arbitrary names (e.g.
    (```Route.core-data``` vs. ```Route.CoreData```).

## References
 * [1] [ADR 0001-Registry-Refactor](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0001-Registy-Refactor.md)
 * [2] [Consul](https://github.com/hashicorp/consul)
 * [3] [Service Name Design v6](https://wiki.edgexfoundry.org/display/FA/Architecture+Issues+and+Decisions?preview=%2F7602423%2F12124493%2FServiceNameDesign-v6.pdf)


