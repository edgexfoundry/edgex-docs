# Devaultification of EdgeX

## Submitters

- Bryon Nevis (Intel Corporation)

## Changelog

- [proposed](about:blank) (2023-09-13)

## Referenced Use Case(s)

- [OSI Approved Licenses UCR](about:blank)

## Context

EdgeX may require replacement of the functionality made possible with
[HashiCorp Vault](https://www.vaultproject.io/).
This need was spurred by a recent
[license change affecting HashiCorp products](https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license)
to a
[non-OSI approved license](https://opensource.org/licenses/).

Vault is currently REQUIRED for the following functions:

- Root of Trust
- Service Identity
- Secure Secret Store
- Microservice API Authentication
- API Gateway Authentication

This ADR will break down the current functionality of HashiCorp Vault
and recommend alternatives for a Vault-less EdgeX.

### Root of Trust

Vault is the one component in EdgeX that is most capable of keeping a secret.
When EdgeX is running with security features enabled,
Vault functions as EdgeX's root of trust.
By this, we mean that Vault is the core service
from which other EdgeX security features are bootstrapped.
Whereas most configuration for EdgeX can be fetched
dynamically from EdgeX's configuration service,
service location information for Vault is statically provided,
and each EdgeX microservice is seeded with a Vault token
to connect to Vault for obtaining credentials for other microservices,
such as the EdgeX database,
the EdgeX service registry,
the EdgeX configuration provider,
the EdgeX message bus,
and credentials for microservice peer authentication.


### Service Identity Use Case

We want each EdgeX microservice to have its own identity
so that all microservice interactions can be authenticated.

Vault supports
[identity](https://developer.hashicorp.com/vault/docs/concepts/identity)
that is supported by an
[identity secrets engine](https://developer.hashicorp.com/vault/docs/secrets/identity).
EdgeX assigns a name to each microservice,
provides a means to authenticate and assume that identity,
and requests
[OIDC-compatible identity tokens](https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token)
from Vault.
Vault-based identity has been used in the
[OpenZiti](https://openziti.io/)
prototype to onboard each EdgeX microservice
into the OpenZiti zero-trust network.

Any viable alternative to Vault for service identity must be able
to issue a JWT token that provides
some mechanism to identify the subject.
(For example, a JWT
["sub"](https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.2)
claim.)

A viable alternative must also have a relatively small footprint,
which disqualifies most Java-based identity providers.


### Secure Secret Store Use Case

Vault supports a
[key-value secrets engine](https://developer.hashicorp.com/vault/docs/secrets/kv)
that encrypts data at rest,
exposes a path-based REST API to those secrets,
and features a robust authentication model.
EdgeX also provides a hook to encrypt the Vault Master Key
with a key retrieved from hardware-backed storage.
EdgeX uses the secret store to seed secrets for the EdgeX database (`redisdb`)
and the EdgeX message bus (`messagebus`),
which are the only built-in secrets.
Individual microservices may also store and retrieve
microservice-specific secrets from the store.
If carefully coded,
EdgeX microservices can dynamically update secret values.

Viable alternatives to Vault for a secure secret store must:

- Encrypt data at rest and in transit.
- Have a robust authorization model and auditing capability.
- Provide a REST-based, path-oriented access API
- Must support bare-metal offline deployment.


### Microservice API Authentication Use Case

Every EdgeX microservice has a Vault-issued identity.
For API authentication use cases,
Vault can issue an 
[OIDC-compatible JWT](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#generate-a-signed-id-token)
for any Vault identity,
and provides a
[introspection endpoint](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#introspect-a-signed-id-token)
to validate these tokens.

The EdgeX API gateway and the EdgeX microservices,
upon receiving a JWT,
will validate it using the introspection endpoint.
If the JWT token is valid
(meaning, was issued by Vault, is not-expired,
and has the correct issuer and audience claims)
then the client is authorized to call the API.


### API Gateway Authentication Use Case

For API gateway authentication use cases,
EdgeX ships with a command-line tool to create custom identities in Vault
that assigns random strong passwords to such identities.
The Vault endpoints to authenticate and obtain an ID token are also exposed
via the API gateway.

The existing gateway authentication functionality will be broken
by the removal of Vault identity,
and the removal of Vault's pluggable authentication handlers.


## Proposed Design

### Root of Trust

Without a software component specifically designed to keep secrets,
EdgeX ultimately has to trust the underlying runtime environment.
This can mean any of the following things:

- Linux user, group, and process isolation (bare-metal use cases),
  or the above plus runtime confinement (snaps).
  
- Container runtimes (containerd, crio) and
  container orchestration software (Docker, Kubernetes)
  
EdgeX currently does not provide reference samples for bare-metal deployment
(for example, as systemd services with per-service user identity).
This is a possible future improvement.

### Service Identity

EdgeX already has optional support for the
[SPIFFE identity standard](https://spiffe.io/)
and ships with a version of the
[SPIRE reference implementation](https://spiffe.io/docs/latest/spire-about/).
SPIFFE is a
[CNCF Graduated project](https://www.cncf.io/announcements/2022/09/20/spiffe-and-spire-projects-graduate-from-cloud-native-computing-foundation-incubator/),
which is the most mature CNCF status.

SPIFFE relies on workload attestation to identify the running workload
and issues a SPIFFE Verifiable Identities (SVIDs) to the workload.
Workload attestation in a practical sense means querying
Kubernetes, Docker, systemd, or the Linux kernel
for metadata about the requesting process.
This metadata is then looked up in a pre-populated table,
and a pre-defined SPIFFE ID is issued to the workload
that is encapsulated in an SVID.

This ADR recommends replacing Vault-based identity with SPIFFE-based identity
and co-enabling it with the reference JWT authentication solution.

In the reference deployment,
SPIFFE/SPIRE trust will be bootstrapped from a static certificate authority
that is unique to the EdgeX deployment.
The SPIFFE/SPIRE components will be an opt-in feature,
but are prerequisites for local JWT-based authentication.


### Microservice Authentication

JWT-based microservice authentication is an optional feature
that can be used standalone
or in conjunction with zero-trust networking.

#### Inbound Authentication

JWT authentication is the most flexible API authentication method.

To validate a JWT locally we need to know four things:

1. The key used to validate the JWT signature.
   The easiest way to discover these keys is to query
   a well-known URL (`/.well-known/openid-configuration`)
   of the JWT issuer, and read the `jwks_uri` to obtain the keyset.
   This keyset is cacheable.
   
2. A static allow list to validate the `iss` (issuer) claim.

3. A static allow list to validate the `aud` (audience) claim.

4. The current time, for validating JWT timestamp claims.

The JWT issuer can be local,
or hosted in a public, private, or enterprise cloud
to share across EdgeX deployments,
and use of an OIDC discovery URL makes this solution compatible
with a wide variety of open-source
and commercially available identity solutions.

Enterprises with their own OIDC-capable identity providers
can choose to point EdgeX microservices at their enterprise solution.
This offers the greatest flexibility for EdgeX adopters.

This ADR recommends adding common configuration parameters
to specify the OIDC discovery URL, issuer allow-list,
and audience allow-list JWT validation parameters.
This ADR further recommends to run the
[SPIRE OIDC Discovery Provider](https://github.com/spiffe/spire/blob/main/support/oidc-discovery-provider/README.md)
alongside the SPIRE server component
in the EdgeX reference deployment,
and to provide appropriate default values
for the JWT validation parameters.

The current `EDGEX_DISABLE_JWT_VALIDATION` environment variable
will be replaced with an configuration-based enable/disable option.


#### Outbound Authentication

So as to not tie microservice authentication into SPIFFE directly,
the process of obtaining a JWT authentication token
must be similarly abstracted.

The proposed configuration parameters are:

- An enable/disable switch for outbound authentication
- Token algorithm (`oauth2` or `spiffe` (default))
- If `spiffe` algorithm is selected,
  the EdgeX microservice will use a JWT-SVID directly for authentication.
- If `oauth2` algorithm is selected, the following are additionally required
  * Token endpoint URL (required)
  * OAuth2 grant type (`client_credentials`)
  * OAuth2 client_id (required)
  * OAuth2 client_secret (optional)
  * OAuth2 scopes (optional)

It is expected that EdgeX adopters would use the `client_credentials`
flow to integrate with pre-existing OAuth 2.0 infrastructure.
EdgeX adopters using their own token infrastructure
would not be required to deploy the SPIFFE infrastructure components.


### Secure Secret Store

It has been exceptionally difficult to find a secret store replacement
that meets all of EdgeX's requirements.

A lowest-common-denominator secret management methodology
that is compatible with all kinds of microservice architectures
is to store secrets in files.

For example,
```
/var/run/secrets/edgex/redisdb/username
/var/run/secrets/edgex/redisdb/password
```

Where `edgex` is a secrets namespace,
`redisdb` is the name of the secret,
`username` and `password` are keys in a secret key-value map,
and the actual username and password
are in the contents of their respective files.

In Docker, a secret can be backed a docker volume containing files for key-value pairs
that is mapped into containers that need it.
In Docker, the docker volume would be writable.
Docker volumes are not automatically replicated across cluster nodes.

In Kubernetes, a secret would map to a `Secret` resource
that is mapped into the container filesystem.
Secrets are updatable dynamically in Kubernetes,
and automatically distributed in multi-node configurations.

EdgeX does not current support Docker Swarm Secrets,
and Docker Swarm Secrets are not dynamically updatable.

The `EDGEX_SECURITY_SECRET_STORE` environment variable will be removed.


### API Gateway Authentication

EdgeX adopters using their own token infrastructure
will not have any trouble with API gateway authentication,
as there will be an adopter-established method to obtain
a JWT that EdgeX would accept.

The default SPIFFE-based identity solution will create problems.
This is because SPIFFE identity is based on workload attestation.
API gateway clients are unlikely to have
SPIFFE attestation infrastructure installed locally, and
SPIFFE is designed to authenticate processes, not users.

Therefore, this ADR proposes to create an authentication bridge
exposed via the API gateway to exchange one JWT for another.
After first validating the incoming JWT,
it would call a SPIFFE privileged admin API
to generate a matching SPIFFE-based JWT using a derived SPIFFE ID,
thereby attesting the client on its behalf.
(Technical: Invoke `SVIDClient.MintJWTSVID()` from
[spire-api-sdk](https://github.com/spiffe/spire-api-sdk/blob/4601723317a85afed588f0114e85ea3fb62b50bd/proto/spire/api/server/svid/v1/svid_grpc.pb.go#L19)
or use
[delegated identity API](https://spiffe.io/docs/latest/deploying/spire_agent/#delegated-identity-api).)

The SPIFFE ID must be pre-registered in the SPIRE database
in order to limit the privileges of the authentication bridge
such that it can only attest known entities.

The bridge would take the following configuration parameters:

- A static public key to validate the incoming JWT,
  or an OIDC well-known discovery URL (`/.well-known/openid-configuration`)
  from which it can dynamically read the `jwks_uri` to obtain the JWT keyset.

- A static allow list to validate the `iss` (issuer) claim.

- A static allow list to validate the `aud` (audience) claim.

- A claim used to derive the SPIFFE ID, for example, the `sub` (subject) claim.

The resulting JWT would be trusted
based upon the default inbound JWT authentication parameters
specified in "Inbound Authentication" above.

A mechanism to pre-register external entities would also be provided.



## Considerations

The snap-based EdgeX deployment does not currently support the SPIFFE identity components.
Support for SPIFFE would need to be added to the snap-based EdgeX deployment.

With removal of Vault and the transition to SPIFFE workload attestation for identity,
there is no longer a requirement to seed each EdgeX microservice with a Vault token.
Thus, the `/tmp/edgex/secrets` directory hierarchy used in Docker
for passing these bootstrapping secrets would be removed.

The set of bootstrapping services needed by EdgeX is largely unchanged by this proposal.
There is still a need for a bootstrapper component to sequence component initialization,
a secretstore-setup component needed to provision database and message bus credentials,
and a proxy authentication service needed by the API gateway.
In the proposal, a bridge service replaces Vault
to facilitate JWT authentication via the API gateway.

The EdgeX service registry and configuration store will also be affected
by the HashiCorp license change.  This change is out-of-scope for this ADR.

### Considerations for EdgeX on Kubernetes

A Vault-less EdgeX is much simpler in a Kubernetes-based deployment.
Point for point:

- Root of Trust.

  Bootstrapping secrets are provided by the Kubernetes runtime platform.

- Service Identity.

  In Kubernetes, service identity is a platform feature.
  In stock Kubernetes,
  every pod be associated with a Kubernetes service account.
  In a SPIFFE/SPIRE enhanced Kubernetes,
  workloads can directly request SPIFFE SVIDs from the workload API,
  or use an optional cert-manager component,
  [csi-driver-spiffe](https://cert-manager.io/docs/projects/csi-driver-spiffe/)
  to have an SVID directly injected into the pod with no code required.

- Secure Secret Store.

  The Kubernetes platform provides
  [native support for secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
  using environment variable or filesystem-based injection.
  This choice does not preclude direct access
  to an enterprise secret store using code,
  or use of Kubernetes sidecars to automatically inject secrets
  fetched from an enterprise secret store.
  
- Microservice API Authentication.

  Although the built-in JWT authentication mechanism provided by EdgeX would work in Kubernetes,
  service meshes can provide equivalent for better functionality.
  For example,
  adopters that elect to deploy EdgeX into an Istio-enabled cluster
  can take advantage of 
  [Istio fine-grained authorization policies](https://istio.io/latest/docs/reference/config/security/authorization-policy/#Operation)
  as well as
  [JWT authorization policies](https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/)
  to exercise granular control of EdgeX's REST APIs.

- API Gateway Authentication.

  In Kubernetes, the choice of API gateway is local.
  There are many available choices.
  As an example,
  an adopter that used an the Istio service mesh product
  could take advantage of an
  [Istio Ingress Gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/).
  

### Adopter Opportunities to Continue Using Vault

This proposal is compatible with the
[Bring Your Own Vault UCR](../../ucr/Bring-Your-Own-Vault.md)
in the following ways:

- In Kubernetes-based deployments,
  EdgeX adopters could use a
  [Vault Sidecar Agent Injector or Vault CSI Provider](https://developer.hashicorp.com/vault/docs/platform/k8s/injector-csi)
  to pre-seed Vault-based secrets into a Kubernetes pod.

- There is an existing documentation on how to build a
  [SPIFFE-Vault integration] (https://spiffe.io/docs/latest/keyless/vault/readme/).
  This functionality enables EdgeX adopters
  to query a Vault-based secret store directly from service code.

Released from the requirement to install, configure, and pre-seed Vault secrets,
custom Vault integrations are easier to do.


## Decision

Adopt design as proposed for EdgeX Odessa release.


## Alternatives

### OAuth2 and OpenID Connect Alternative

One must ask whether moving towards a OpenID Connect standards-based
identity and authentication model is a good path forward.

Towards that end, there is a nicely written 
[stack overflow Q&A](https://stackoverflow.com/a/45130768)
that explains the difference between OAuth2 and JWT-based authentication.
Auth0's blog also has a well-written article explaining
[the difference between an OAuth2 access token and and OIDC ID token](https://auth0.com/blog/id-token-access-token-what-is-the-difference/).
A [hackernoon post](https://hackernoon.com/you-probably-dont-need-oauth2openid-connect-heres-why) gives a similar story.
The gist of these articles is that OAuth2/OIDC does not fit the EdgeX use case.
OAuth2/OIDC is designed around "access delegation"
where a user of the system delegates to a third-party system
to call APIs on behalf of the user.
An example might be:
authorizing a online scheduling system
to to interact with a user's contact management software.
This is not the EdgeX use case.

Open source tools that fall into this space include:

- [Keycloak](https://github.com/keycloak/keycloak) (Apache-2.0).
  A full-featured OIDC server written in Java.
- [Ory Hydra](https://github.com/ory/hydra) (Apache-2.0).
  An OpenID Certified OAuth 2.0 Server and OpenID Connect Provider
  written in Go that does not have identity provider functionality.
- [MITREid Connect](https://github.com/mitreid-connect/) (Apache-2.0)
  A full-featured OIDC server written in Java.
- [Dex IDP](https://github.com/dexidp/dex) (Apache-2.0).
  An identity broker written in Go that federates identity
  with external identity providers.


### Service Identity Alternative

Not chosen candidates in the service identity space include:

- OIDC-compliant identity providers (see above).
  Several of these providers either don't support a
  [OAuth2 client credentials flow](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4)
  or do support the flow but can't issue OIDC ID tokens
  to clients authenticated using this mechanism.

- [Openstack Keystone](https://docs.openstack.org/keystone/latest/).
  Keystone JWT tokens are opaque and do not identify the token subject.


### Secure Secret Store Alternative

Not chosen candidates in the secret store space include:

- [CryptoMove](https://github.com/CryptoMove).
  This was a secret store that protected it data by constantly
  [moving it around](https://techcrunch.com/2017/09/19/cryptomove-protects-sensitive-data-by-fragmenting-it-and-moving-it-around).
  Sadly, CryptoMove no longer exists as a company.

- [Openstack Barbican](https://docs.openstack.org/barbican/latest/).
  Barbican does not have a path-based access API,
  and also requires use of Openstack Keystone,
  which was previously rejected.
  
- [Mozilla SOPS](https://github.com/getsops/sops).
  SOPS is a framework to store encrypted values in YAML.
  To effectively use it, one must also solve a key distribution problem.
  
- Myriad cloud-hosted secret stores, because they do not support offline usage.


### API Authentication Alternative

Not chosen candidates in the API authentication space include:

- API Keys (bespoke).
  This is the simplest authentication option,
  as it requires simply a long random string
  and a database of hashed strings to compare against.
  EdgeX already has a database where we can store and look up API keys.
  It is also possible to write a simple authorization server
  that can validate API keys
  and also issue API keys to EdgeX microservices
  when presented with a valid SPIFFE SVID.
  The limitation with API keys is that there are no standards
  for federating API keys--each EdgeX deployment would be unique.

- [OAuth 2.0-compliant authorization](https://datatracker.ietf.org/doc/html/rfc6749).
  OAuth 2.0-compliant tokens tend to be opaque and
  tend to not include identity information.
  This means the the resource server (providing the API)
  must contact the authorization server (that issued the token)
  to figure out what to do with it.
  This would mean that EdgeX would need to bundle an authorization server
  to replace Vault.
  
- [Openstack Keystone](https://docs.openstack.org/keystone/latest/).
  Keystone might actually do a fine job as an authorization server,
  but given that other Openstack components were rejected for other uses,
  there are easier ways to get the job done.

- [HTTP Basic Authentication](https://datatracker.ietf.org/doc/html/rfc7617).
  While fairly universal, this authentication mechanism introduces
  problems that EdgeX does not want to deal with. For example:
  
  * Secure password storage ala PBKDF2, bcrypt, argon2id, et cetera.  
  * Potential requirements for password complexity and rotation.  
  * Exposure to a wide variety of password-related attacks.


## Other Related ADRs


## References

- [OSI Approved Licenses UCR](about:blank)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [HashiCorp license change announcement](https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license)
- [OSI approved license list](https://opensource.org/licenses/)
- [OpenZiti](https://openziti.io/)

