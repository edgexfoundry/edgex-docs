# V3 Security Migration Guide

## What's Changed in EdgeX 3.0 Security

EdgeX 3.0 ("Minnesota") release implements a significant change to its security architecture.

In EdgeX "Fuji" release, EdgeX introduced an opt-in secure mode that featured
a secret store capability based on Hashicorp Vault and a API gateway based on Kong.
The API gateway served to separate the outside Internet-facing network, which was "untrusted",
from the internally-facing network, which was a "trusted".

EdgeX 3.0 takes significant steps to put limits on that trust.
Whereas in EdgeX 1.0 and 2.0, microservice security was enforced at the API gateway,
in EdgeX 3.0 microservice security is now also enforced at the individual microservice level.
EdgeX 2.0 already enabled authentication for third-party components such as the EdgeX database,
the EdgeX registry, the EdgeX configuration store, the EdgeX secret store, the EdgeX API gateway,
and the EdgeX message bus, but the EdgeX microservices themselves did not require authentication
if the request originated from behind the API gateway.
In EdgeX 3.0, even internal calls to EdgeX microservices now require an authentication token.

Compared to EdgeX 2.0, the security footprint of EdgeX 3.0 is reduced
through the removal of the third-party Postgres and Kong components
and using a minimally-configured NGINX gateway instead.
Measurements taken before and after show a ~300 MB savings in downloaded Docker images
in the container version of EdgeX,
and a ~150 MB reduction in memory usage.
Achieving these impressive improvements to the EdgeX footprint unfortunately means
that there are some breaking changes to API gateway authentication that will be detailed later.

Although not a functional change,
a significant addition to EdgeX 3.0 has been made in the form of a
[STRIDE Threat Model](https://docs.edgexfoundry.org/3.0/threat-models/stride-model/EdgeX-STRIDE/)
contributed by IOTech.
This threat model takes an outside-in view of EdgeX,
treating the EdgeX services together as a unit.
The STRIDE threat model should serve as a good starting point for EdgeX adopters own threat models
in which EdgeX is a component in the overall architecture.
It should be noted, however, that since EdgeX services are taken together as a unit,
the impact of the recent microservice authentication changes,
which primarily affect EdgeX internals, is not reflected in the threat model.

## API Gateway Breaking Authentication Changes

In EdgeX 2.0, the `secrets-config` utility was used to create a user account in the API gateway (Kong)
and associate it to a user-specified public key.
A user would then self-create a JWT, and use it for authentication against the API gateway.
These tokens were opaque to EdgeX microservices because their contents were controlled by the user,
and only the API gateway had the information needed to validate them.

In EdgeX 3.0, the `secrets-config` utility is still used to create a user account,
but instead of creating it in the API gateway,
the user account is created in the EdgeX secret store,
and the Vault identity secrets engine is used to generate and verify JWT's.
All EdgeX services implicitly trust the EdgeX secret store
and have a secret store token issued to them at startup
that can be used to request a JWT from Vault.

Externally-originated requests are performed similarly to how they were done before:
provide the JWT in the `Authorization` header
and direct the request at the API gateway with a path prefix denoting the desired service.
The key difference is in obtaining the JWT.
In EdgeX 2.0, the client simply generated the JWT using its private key.
In EdgeX 3.0, obtaining a JWT is a two-step process.
First, authenticate to the EdgeX secret store (Vault) to obtain a secret store token.
Second, exchange the secret store token for a JWT.
This process is described in detail in the
[authenticating chapter](https://docs.edgexfoundry.org/3.0/security/Ch-Authenticating/)
of the EdgeX documentation.
Due to these changes, the `secrets-config proxy jwt` helper command has been removed.
This same chapter also explains that, similar to Kong,
Vault has an extensible authentication mechanism,
although only username/password (with a randomized strong password)
is enabled out of the box.

As was before, all requests (with the exception of a passthrough for Vault authentication)
are checked at the API gateway prior to forwarding to the backend service for fulfillment.

## Microservice-level Breaking Authentication Changes

EdgeX microservices in EdgeX 3.0 will now require authentication on a per-route basis,
even for requests that originate behind the API gateway.
Peer-to-peer service requests (such as a device service calling core-metadata,
or core-command forwarding a request to a device service) are authenticated automatically.
This new behavior may create compatibility issues for custom components
that worked fine in EdgeX 2.0 that may suddenly experience authentication failures in EdgeX 3.0.
This new behavior may also create issues for 3rd party components,
such as the eKuiper rules engine,
because of its ability to issue ad-hoc HTTP requests in response to certain events.

To revert to legacy EdgeX 2.0 behavior--no authentication at the microservice level--
set the environment variable `EDGEX_DISABLE_JWT_VALIDATION` to `true`.
JWT validation must be disabled on a per-microservice basis.
This will not stop EdgeX microservices from sending JWT's
to peer EdgeX microservices--it will only disable validation on the receiving side,
allowing unauthenticated requests.

For sending JWTs, custom EdgeX services have two basic choices.
The first is to use one of the pre-built service clients in `go-mod-core-contracts`.
The other is to to use the `GetSelfJWT()` method of the `SecretProviderExt` interface.
The
[authenticating chapter](https://docs.edgexfoundry.org/3.0/security/Ch-Authenticating/)
of the EdgeX documentation
explains in greater detail how to use these two methods.

## Breaking Changes to API Gateway TLS Configuration

Some minor changes have been made to the `secrets-config proxy tls` command.
For starters, the `--snis` argument is no longer supported--the
supplied TLS certificate and key will be used for all TLS connections.
Other minor changes include renaming `--incert` to `--inCert`
and `--inkey` to `--inKey`, for example.


## References

- [Microservice Authentication Use-Case Requirements](https://docs.edgexfoundry.org/3.0/design/ucr/Microservice-Authentication/)
- [Microservice Authentication Architectural Design Record for Token-Based Authentication](https://docs.edgexfoundry.org/3.0/design/adr/security/0028-authentication/)
- [EdgeX STRIDE Threat Model](https://docs.edgexfoundry.org/3.0/threat-models/stride-model/EdgeX-STRIDE/)
