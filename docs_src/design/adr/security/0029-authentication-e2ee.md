# EdgeX Microservice Authentication (end-to-end security)

### Submitters

- Bryon Nevis (Intel)
- Clint Dovholuk (NetFoundry - OpenZiti)

## Change Log

- [proposed](https://github.com/edgexfoundry/edgex-docs/pull/935) (2023-01-28)
- [approved](https://github.com/edgexfoundry/edgex-docs/pull/1316) (2023-12-09)

## Referenced Use Case(s)

- [Microservice Authentication](https://docs.edgexfoundry.org/3.0/design/ucr/Microservice-Authentication/)


## Context

The AS-IS Architecture figure below depicts the current state of
microservice communication security as of EdgeX 3.0,
when security is enabled:

![AS-IS Architecture](0029-as-is.jpg)

As shown in the diagram,
EdgeX 3.0 components are secured as follows:

* Vault (EdgeX's secret store) is protected by an API key.

* Consul (EdgeX's service registry and configuration provider)
  is also protected by an API key
  (issued by way of the Vault Consul secrets engine).

* Redis (EdgeX's database) is protected by username/password.

* All other EdgeX microservices are protected by a JWT token,
  issued and validated by Vault, that EdgeX microservices already trust.

It is up to EdgeX adopters to secure network communication between nodes.

At the present time, HashiCorp has announced that the next version of
their open source products will be switching to a non-OSI-approved
Business Source License.
To more easily accommodate possible future changes,
the proposed design will refers to the functionality offered by
some of these components instead of the proper name of the component.


## Proposed Design

This ADR proposes an implementation of the
[Microservice Authentication UCR](../../ucr/Microservice-Authentication.md)
that uses an end-to-end authentication mechanism based on zero-trust networking.

In this authentication model,
EdgeX microservices connect directly to the zero-trust network overlay
and communicate with other EdgeX microservices in a manner
that is fully encrypted and
governed by a centrally managed network policy.
In this model, an EdgeX microservice API never "listens"
on a host-accessible network port.
Instead, EdgeX microservices make outgoing connections
to an OpenZiti router.
Compared to token-based authentication,
a zero-trust network secures network traffic by default,
and makes to possible to have a fully-distributed EdgeX implementation
that spans the edge to the cloud,
where multiple EdgeX deployments can be managed from anywhere.
In the token-based authentication ADR,
developers had to decide which routes were authenticated and which were not:
in the end-to-end encryption design,
the entire REST API of each microservice is secured in its entirety.

This ADR prescribes two methods of onboarding to the OpenZiti fabric:

1. A local EdgeX microservice,
   already having a claims-based identity (JWT) from an identity provider,
   supplies the JWT to the OpenZiti Router
   to establish a secure session
   and data plane connection to the zero-trust network.

2. A remote EdgeX microservice or remote administrator,
   having cached an OpenZiti identity (certificate and private key)
   through some sideband mechanism,
   connects directly to the OpenZiti router
   and becomes a member of the zero-trust network.

Under this ADR, EdgeX microservices will directly integrate with the OpenZiti SDK.
Integration with the OpenZiti SDK enables EdgeX microservices
to natively communicate on the OpenZiti zero-trust network.
However, to be fully functional,
and adopter must also run an OpenZiti controller,
one or more OpenZiti router components,
and zero or more OpenZiti tunnelers to support legacy applications.
Examples of a legacy applications include `curl` clients
and Postman running in a users' browsers.

In a zero-trust architecture, an API gateway is no longer required
for remote access to EdgeX microservice API's.
If an API gateway is still desired,
it is still possible to run the EdgeX 3.0 API gateway
in conjunction with an OpenZiti tunneler to onboard
API gateway traffic onto the zero-trust network on the backend.

The new TO-BE architecture is diagrammed in the following figure:

![TO-BE Architecture](0029-to-be.jpg)

This diagram conveys a lot of information in little space.
A little exposition on what this diagram is intending to show:

The yellow boxes,
showing the OpenZiti Controller, OpenZiti Router,
and OpenZiti Tunneler are the new OpenZiti components.
Two of these components, the controller and the router,
are in a dashed box, denoting that these components
have open ports on the network underlay.
The controller and the router could be Internet-accessible,
on a local docker network, or on the host network.
To permit off-host access to the zero-trust network,
either the OpenZiti router must be exposed externally on the host,
or there must be a connection to a peer router that
is itself accessible off-host.
"Zitified" clients can simply connect to an OpenZiti edge router
and join the zero-trust network.
Non-ziti-aware components such as browsers or command-line clients
must run on a host with an OpenZiti tunneler
that works similar to an SSH port-forwarder to
forward connections onto the zero-trust network.
There is some security risk in doing this,
as the OpenZiti Tunneler can't tell the difference between
a non-zitified client and malware running on the host.

The green boxes,
showing the EdgeX Identity Provider,
Redis,
and The EdgeX Configuration Store,
are existing third-party non-zitified components
that are already used by EdgeX.
These components have independent authentication mechanisms.
They are safe to use for kernel-mediated same-host access,
but not safe to access over the network without
additional network security.
The OpenZiti Router also has an outbound tunneler built-in,
allowing traffic to traverse the zero-trust network encrypted,
and exit unencrypted to communicate with services
listening on the docker network (zero-trust network access, ZTNA),
or listening on the host network (zero-trust host access, ZTHA).
These connections are indicated by the blue-violet arrows.

The EdgeX Identity Provider is a special case:
it also has a thick dashed border,
indicating that it also must have an exposed listening port.
This is because a JWT-based identity claim is required
to join the zero-trust network in the normal case,
and thus the identity provider must be available as a prerequisite
to the zero-trust network being available.

As security of the identity provider (IdP) is paramount,
secure network communication with the IdP must be possible,
even before the zero-trust network is brought up.
A non-exhaustive list of options, at the option of the adopter, includes:
* The IdP is itself TLS-enabled
* The IdP resides behind a TLS-enabled API gateway
* The IdP resides behind some kind of secure tunnel (e.g `stunnel`)
* The IdP is accessible via an encrypted VPN

Connections to exposed ports on the network underlay
are denoted with red arrows:
they always terminate at the boxes with thick dashed borders.
The IdP is special in that it also has an alias
on the zero-trust network to service internal requests,
such as obtaining fresh tokens for authentication purposes.

The gray boxes in the "zero-trust network" box are
the Zitified EdgeX services.
One might assume that connections between these services are peer-to-peer,
but this is not the case.
Instead, EdgeX services connect to the OpenZiti edge router
which perform packet routing functions.
The edge router applies network policies to the traffic,
controlling who can speak to whom,
and payloads to and from the router are encrypted.

### Feature overlaps with EdgeX JWT-based authentication

OpenZiti focuses on being a transport-level solution,
controlling access to remote services.
It does not provide application-level security.
The OpenZiti tunneler does not have the ability
to verify the original source of traffic,
be it a browser, a `curl` client, or other.
This tunneler provides a compatibility path for clients
that do not support the application-embedded approach.
When a tunneler is in play,
use of JWT authentication could be used to authenticate the true client.

A case where this is likely to apply is if an adopter elects to keep
an API gateway as part of the EdgeX deployment.
NGINX would either have to be configured to use an
[OpenZiti NGINX module](https://github.com/openziti/ngx_http_ziti_module)
to place backend traffic onto the zero-trust network,
or it would be necessary to point the backend traffic at an OpenZiti tunneler
to forward requests to backend microservices.
In general,
backend microservices would be better served
knowing the true client identified by an authentication token,
rather than knowing that the traffic originated
from an API gateway or OpenZiti tunneler.
As EdgeX today does not make fine-grained authorization decisions.
As such, so long as NGINX validates the JWT,
validating a JWT in the microservice itself is defense-in-depth.


### High-level list of changes

A proof of concept implementation required the following high-level list of changes:

- Add configuration options to enable use of OpenZiti. In the
  the `Service` blocks and `Clients.*` blocks, add a generic string map
  named `SecurityOptions`.  OpenZiti integration will be triggered via
  `Mode = zerotrust`.

- `go-mod-bootstrap` will break out the `ListenAndServe` call into two
  separate steps: (1) create an OpenZiti listener and (2) serve on it
  when `Mode = zerotrust`.  Outgoing connections made in `go-mod-bootstrap`
  will also use the OpenZiti integration.

- `go-mod-bootstrap` will have the common authentication handler changed to
  optionally accept the OpenZiti remote identity as authentication
  in lieu of JWT authentication. JWT authentication in addition
  to OpenZiti authentication will still be possible if needed for
  application-level authentication.
  
- `go-mod-bootstrap` will open up a second unauthenticated HTTP port
  on a separate port on the network underlay to serve the health check
  endpoint `/api/vX/ping`.  This is required for compatibility with
  Consul-based health checks as well as Kubernetes-based health checks.
  This can be optionally disabled.
  
- `go-mod-core-contracts` will modify `makeRequest()` to use
  OpenZiti's transport to make connections to EdgeX microservices via OpenZiti.

- `edgex-ui-go`, for connections proxied via its backend,
  will have similar adaptions as `go-mod-core-contracts`
  when `Mode = zerotrust`.

- `edgex-compose` will have added documentation that refers users
  to the EdgeX OpenZiti how-to documentation.

- `edgex-compose/compose-builder` will need new options to
  deploy an OpenZTI-enabled EdgeX stack.
  This should include some kind of TLS-encrypted means
  of accessing the identity provider from remote nodes, as described above.
  
- `edgex-docs` will have an added chapter on how to configure EdgeX
  for zero trust, with configuration examples.  The chapter will
  include information on how to keep the API gateway, if desired.

Some updates are also needed for third-party components:

- Add OpenZiti support to eKuiper so that the EdgeX rules engine
  and eKuiper can communicate natively with security and not expose listening ports.
  This would affect both the HTTP listener and outgoing connections.

### OpenZiti Bootstrapping

OpenZiti must be ready to accept EdgeX clients in advance of starting EdgeX.

- Adopters are expected to supply their own OpenZiti infrastructure
  that will exist before starting EdgeX, for example, by using CloudZiti
  or self-costing an OpenZiti controller and OpenZiti router.
  
- The adopter must create and enroll one identity per microservice
  (core-data, core-metadata, eKuiper, et cetera).

- The adopter must provision one-time enrollment tokens (OTT) for each
  microservice or configure an OpenZiti external JWT signer.
  External JWT signers allow EdgeX microservices
  to authenticate to trusted identity provider
  and receive a claims-based identity JWT that in turn that would
  authenticate the microservice to OpenZiti.
  
- The adopter must create an OpenZiti service per microservice.

- The adopter must create bind service policies to allow
  microservice identities to bind their corresponding service.
  
- The adopter must create dial service policies to allow
  microservice identities to make outbound connections to other services.

Example automation scripts will be provided in the user documentation.


## Decision

Authentication based on end-to-end encryption and zero-trust networking
is much more robust than token-based authentication schemes,
and is secure over the network by default.
A service that is "zitified" using the OpenZiti SDK
is better protected against local attackers as well,
due to lack of an exposed REST API on a host-accessible TCP/IP socket.

Zero-trust networking requires a paradigm shift and use of
unfamiliar tools such as the OpenZiti tunneler
to bridge traffic that is not zero-trust aware onto the network
and is significant departure from the reverse-proxy methodology.


## Considerations

### Disk and Memory Requirements for OpenZiti

The OpenZiti router uses ~30 MB of RAM and 
the OpenZiti controller uses ~70 MB of RAM.
The OpenZiti quickstart contains both the router and the controller,
leading to a rough estimate of 400MB additional container size.
(These numbers come from `docker stats` and `docker image`.)

Note that the OpenZiti use case normally assumes
that the router and controller are infrastructure
services hosted elsewhere and used by more than one application.


### Alternative: Consul Connect

Consul Connect is a service mesh product that integrates natively
with Consul and Vault, both of which are used by EdgeX.
This feature has been renamed as "Service Mesh Native App Integration"
and is no longer actively developed by Consul.
Moreover, only the golang SDK supports Consul Connect.


### Alternative: Kong Kuma Service Mesh

An earlier prototype was done with Kong Kuma 1.0 to see if
it would work on Docker and bare-metal.
The results of the experiment was that it doubled the
number of processes that needed to be run to support EdgeX
and was rejected due to the complexity of the solution.
It is unclear if Kuma 2.0 still supports bare-meta deployments.


### Alternative: mTLS Everywhere

One straightforward approach would be to use mutual-auth TLS (mTLS) everywhere
and eliminate the reverse proxy entirely.
There are several problems with this approach:

- Each EdgeX service would be exposed directly on the host,
  resulting in a more attractive attack target.

- mTLS would break Consul-based service health checks.

- Use of the Vault PKI secrets engine to allow issuance of
  client and server certificates would add a lot of code to EdgeX.

- Certificate and key rotation,
  as recommended by 
  [NIST SP 800-57 part 1](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final),
  would have to be solved,
  including live rotation of certificates for long-running processes.


### Alternative: SPIFFE-based mTLS

This approach is a variation on mTLS Everywhere
where SPIFFE-aware client libraries that
are specifically designed to support live rotation
of TLS credentials are compiled into applications.
This is an effective mitigation for NIST SP 800-57
recommended cryptoperiods.

Most third-party services without SPIFFE integration
assume that their TLS server certificates are long-lived.
One way of to accommodate these services would be
to issue a long-lived X.509 SVID to these services.
Alternatively, certificates to these services
could be delivered out-of-band.
However, in both scenarios, 
certificate and/or key rotation
would require a disruptive service restart.

Tools such as ghosttunnel could be used to proxy
services that are not TLS-aware, but in a bare-metal
environment the proxy could be easily bypassed.

While a SPIFFE-based mTLS solution solves some
of the problems with an mTLS Everywhere approach,
a significant amount of effort would need to be
spent dealing with corner cases and
third-party service integration.


## Other Related ADRs

- [Microservice Authentication ADR (token-based)](./0028-authentication.md)

## References

- [Microservice Authentication UCR](../../ucr/Microservice-Authentication.md)
- [ADR 0015 Encryption between microservices](./0015-in-cluster-tls.md) 
- [ADR 0020 Delay start services (SPIFFE/SPIRE)](./0020-spiffe.md)
- [ADR 0028 Microservice authentication via tokens](./0028-authentication/)
- [OpenZiti zero-trust networking fabric](https://openziti.github.io/)
- [SPIFFE](https://spiffe.io/)
