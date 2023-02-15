# EdgeX Microservice Authentication (token-based)

### Submitters

- Bryon Nevis (Intel)

## Change Log

- [proposed](https://github.com/edgexfoundry/edgex-docs/pull/659) (2021-12-28)

## Referenced Use Case(s)

- [Microservice Authentication](https://docs.edgexfoundry.org/3.0/design/ucr/Microservice-Authentication/)


## Context

The AS-IS Architecture figure below depicts the current state of
microservice communication security prior to EdgeX 3.0,
when security is enabled:

![AS-IS Architecture](0028-as-is.jpg)

As shown in the diagram,
many of the foundational services used by EdgeX Foundry
have already been secured:

* Communication with EdgeX's secret store, as implemented by
  Hashicorp Vault, is secured over a local HTTP socket with
  token-based authentication.  An access control list limits access
  to the keyspace of the key value store.

* Communication with EdgeX's service registry and configuration provider,
  as implemented by Hashicorp Consul, is secured over a local HTTP
  socket with token-based authentication,
  with the token being mediated by Hashicorp Vault.
  An access control list limits access to the keyspace of
  the configuration store.

* Communication with EdgeX's default database, Redis, is secured using
  username/password authentication, with the password stored
  in Hashicorp Vault.  An access control list limits the commands
  that clients are allowed to issue to the server.

External access to EdgeX microservices has also been secured.
EdgeX microservices only bind to local ports,
and are only exposed externally through a Kong API gateway.
This gateway is configured to use TLS 1.3,
using RS256 or ES256 JWT authentication (at the user's discretion).
All external requests are filtered at the API gateway.
URL rewriting is used to concentrate microservices
on a single HTTP-accessible port.

Behind the proxy, it is not possible to verify Kong
as the origin of local network traffic because mutual-auth TLS
is not supported in the open source version of Kong.
Although the Kong JWT plugin will set request headers
on the backend request that identify the caller,
there is no mechanism by which Kong can prove to a
backend service that it was the component that
performed the authentication step.
Even though the original JWT passes through the proxy,
the Kong authentication plugins do not expose
token introspection endpoints that the backend service
could use to check token validity independently.

The consequence of having an API gateway that performs
all microservice authentication is that communication
between EdgeX microservices running behind the API gateway
are not authenticated in any way.
EdgeX microservices are unable to distinguish
malicious traffic that has evaded the API gateway
from legitimate microservice traffic.

## Proposed Design

This ADR proposes an implementation of the
[Microservice Authentication UCR](../../ucr/Microservice-Authentication.md)
that uses a token-based authentication mechanism.

This ADR proposes to relieve the Kong API gateway of its
[JWT](https://www.rfc-editor.org/rfc/rfc7519) management responsibility,
and instead use Hashicorp Vault for this purpose,
which is already used as EdgeX's secret store.
This change requires minimal modification of existing
clients written to perform JWT-based authentication at the Kong gateway:
they simply use a Vault-issued JWT
instead of a Kong-issued JWT or a self-issued JWT.

This ADR proposes a layered authentication scheme,
with the reverse proxy performing an initial check for all external requests,
and EdgeX services themselves authenticating all internal and external requests.
The layered approach is required,
as some EdgeX endpoints such as `/api/v2/ping`
must be anonymous for health-checking purposes.

EdgeX microservices shall consult Vault to confirm JWT validity,
and an NGINX reverse proxy shall use the
[ngx_http_auth_request_module](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html)
to delegate confirmation of JWT validity to Vault,
as a mitigation for microservice-level implementation errors.
TLS termination at the reverse proxy shall be enabled by default
so as to be consistent with
[ADR 0015 - Encryption between microservices](./0015-in-cluster-tls.md).

Behind the proxy, there are two major changes:

1. Every EdgeX service, when security is enabled,
   requires a JWT be passed as part of the HTTP request
   that is validated using Vault's token introspection endpoint,
   or manually validated based on published signature keys.

2. Every EdgeX service, when security is enabled,
   uses a Vault-supplied JWT to authenticate
   outgoing calls to peer EdgeX services.
   The original caller's identity may be passed through
   at the developers' discretion for microservice chaining scenarios.

The new TO-BE architecture is diagrammed in the following figure:

![TO-BE Architecture](0028-to-be.jpg)


### Implementation pre-requisites

This ADR assumes a minor refactoring to the security bootstrapping
components use the Vault identity API and one or more authentication engines
to issue identity-based Vault tokens instead of raw Vault tokens.
Affected services include,
`go-mod-secrets` (configure identity, issue and validate JWT's),
`security-secretstore-setup`,
`security-file-token-provider`,
and `security-spiffe-token-provider`.

This refactoring results in several benefits:

* It de-privileges `security-secretstore-setup`'s use of Vault,
  which currently requires Vault "sudo" capability to issue raw Vault tokens.
  (This is a blocking issue for customers that want to bring their own Vault.)

* An external user identity could be authenticated by
  an external service, such as [Auth0](https://auth0.com).
  Alternatively, username/password or AppRole authentication
  could be used if an external source of identity is not available.
  This is viewed as beneficial, as downstream EdgeX deployments
  are already building their own similar integrations.

* An internal service identity could be authenticated by
  a Kubernetes service account token.  This could eliminate
  the requirement to pre-distribute Vault tokens to services
  via a shared filesystem volume, simplifying Kubernetes-based
  deployments of EdgeX.

* As an added bonus, Vault supports longer JWT key sizes than the Kong JWT plugin.

Additionally, `security-bootstrapper` will need to modified to not
block on availability of Postgres before issuing the ready-to-run signal.
(This change is already completed.)


### High-level list of changes

The following list of changes is derived from the proof of concept implementation
to actually effect the change (besides the prerequisite changes above):

- Kong and Postgres is removed from compose files and snaps.

- Add an NGINX reverse proxy with using the proxy auth module.

- Create a new `security-proxy-auth` service to check the incoming JWT for validity.
  (NGINX will be configured to delegate to this service for authentication checks.
  NGINX could also delegate to a minimal function like /api/v2/version,
  but the reason as to why the function was called wouldn't be as clear as
  having a separate authentication service.)

- The `security-proxy-setup` container remains, with the binary replaced
  with a small shell script to create a default TLS certificate and key.

- The `secrets-config` utility will create new users in Vault instead of Kong,
  and update TLS configuration for NGINX on disk instead of the Kong API.

- Modifications to `go-mod-core-contracts` to support an
  injectable authentication interface to add JWT's to outgoing HTTP requests.

- Modifications to `go-mod-bootstrap` to realize the `go-mod-secrets` changes,
  create common JWT authentication handlers,
  and inject JWT authentication to the core-contracts clients.

- Modifications to individual EdgeX services to authenticate selected routes
  (that is, every route except `/api/v2/ping`, which remains anonymous).

- Modifications to `security-bootstrapper` to build an entrypoint script for
  NGINX and a default NGINX configuration.

- Documentation updates.


## Decision

Token-based authentication is flexible and works in a wide variety of use cases,
but does not address issues of network security.

For scenarios where all EdgeX services are running on the same host,
or there is an existing solution to network security already in place,
such as an encrypted network overlay
as might be found in some Kubernetes deployments of EdgeX,
the token-based solution offers significant
memory and disk savings over the Kong-based solution
used in EdgeX releases prior to 3.0.

For scenarios where token-based authentication credentials can be exposed over a network,
an authentication solution based on end-to-end encryption would be more appropriate.


## Considerations

### Size and Space Impact of Kong + Postgres Versus Alternatives

#### Disk space

Kong + Postgres (docker images): 353MB

Alternatives:
 - HAProxy: 40 MB
 - NGINX: 12 MB - 41 MB depending on image selection (12 MB works for us)

#### Memory

Kong + Postgres: 160 MB (at startup)

Alternatives:
  - HAProxy: 80 MB
  - NGINX: 5 MB

### Alternative: Using Kong to Mediate EdgeX Internal Microservice Interactions

One approach that is seen in some microservice architectures
is to force all communication between microservices to go
through the external API gateway.
There are two problems with this approach:

- In the typical EdgeX runtime environment,
  there is no mechanism to block direct
  microservice-to-microservice communication.

- The external address of the API gateway
  may not be known to internal code,
  increasing implementation difficulty for the programmer.


### Alternative: Using Kong as a Service Identity Provider

Neither the JWT nor OAuth2 plugins offer a token introspection endpoint,
though it would be possible to create a fake service
that EdgeX microservices could call to validate a bearer token.
Using the Kong Admin API to obtain a public key for JWT
validation via database dump would be unnecessarily complex.
Validation of an opaque OAuth2 token would require direct access
to Kong's backend database and is also unnecessarily complex.


## Other Related ADRs

- [ADR 0015 Encryption between microservices](./0015-in-cluster-tls.md) 
- [ADR 0020 Delay start services (SPIFFE/SPIRE)](./0020-spiffe.md)
- [Microservice authentication based on end-to-end encryption](https://github.com/edgexfoundry/edgex-docs/pull/935)

## References

- [Microservice Authentication UCR](../../ucr/Microservice-Authentication.md)
- [OpenZiti zero-trust networking fabric](https://openziti.github.io/)
- [SPIFFE](https://spiffe.io/)
