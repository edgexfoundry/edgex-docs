# Securing access to Consul

## Status

** Approved **

## Context

This ADR defines the motiviation and approach used to secure access
to the Consul component in the EdgeX architecture
for *security-enabled configurations only*.
Non-secure configuations continue to use Consul in
anonymous read-write mode.
As this Consul security feature requires Vault to function,
if `EDGEX_SECURITY_SECRET_STORE=false` and Vault is not present,
the legacy behavior (unauthenticated Consul access) will be preserved.

Consul provides several services for the EdgeX architecture:

- Service registry (see ADR in references below)
- Service health monitoring
- Mutable configuration data

Use of the services provided by Consul is optional on a service-by-service basis.
Use of the registry is controlled by the `-r` or `--registry` flag provided to an EdgeX service.
Use of mutable configuration data is controlled by the `-cp` or `--configProvider` flag provided to an EdgeX service.
When Consul is enabled as a configuration provider,
the `configuration.toml` is parsed into individual settings
and seeded into the Consul key-value store on the first start of a service.
Configuration reads and writes are then done to Consul if it is specified as the configuration provider,
otherwise the static `configuration.toml` is used.
Writes to the `[Writable]` section in Consul trigger per-service callbacks
notifying the application of the changed data.
Updates to non-`[Writable]` sections are parsed only once at startup
and require a service restart to take effect.

Since configuration data can affect the runtime behavior of services,
compensating controls must be introduced in order to mitigate the risks introduced
by moving configuration from a static file into to an HTTP-accessible service with mutable state.

The current practice is that Consul is exposed via unencrypted HTTP in anonymous read/write mode
to all processes and EdgeX services running on the host machine.

## Decision

Consul will be configured with access control list (ACL) functionality enabled,
and each EdgeX service will utilize a Consul access token to authenticate to Consul.
Consul access tokens will be requested from the Vault Consul secrets engine
(to avoid introducing additional bootstrapping secrets).

DNS will be disabled via configuration as it is not used in EdgeX.

**Consul Access Via API Gateway**

In security enabled EdgeX, the API gateway will be configured to
proxy the Consul service over the `/consul` path,
using the `request-transformer` plugin
to add the global management token to incoming requests
via the `X-Consul-Token` HTTP header.
Thus, ability to access remote APIs also grants the ability
to modify Consul's key-value store.
At this time, service access via API gateway is all-or-nothing,
but this does not preclude future fine-grained authorization
at the API gateway layer to specific microservices, including Consul.

Proxying of the Consul UI is problematic and there is no current solution,
which would involve proper balacing of the externally-visible URL,
the path-stripping effect (or not) of the proxy,
Consul's `ui_content_path`,
and UI authentication
(the `request-transfomer` does not work on the UI).


## Consequences

Full implementation of this ADR will deny Consul access to all existing Consul clients.
To limit the impacts of the change, deployment will take place in phases.
Phase 1 is basic plumbing work and leaves Consul configured in a permissive mode
and thus is not a breaking change.
Phase 2 will affect the APIs of Go modules and will change the default policy to "deny",
both of which are breaking changes.
Phase 3 is a refinement of access control; presuming the existing services
are "well-behaved", that is, they do not access configuration of other services,
Phase 3 will not introduce any breaking changes on top of the Phase 2 breaking changes.

### Phase 1 (completed in Ireland release)

- Vault bootstrapper will install Vault Consul secrets engine.
- Secretstore-setup will create a Vault token for consul secrets engine configuration.
- Consul will be started with Consul ACLs enabled with persistent agent tokens and a default "allow" policy.
- Consul bootstrapper will create a bootstrap management token
  and use the provided Vault token to (re)configure the Consul secrets engine in Vault.
- Do to a [quirk in Consul's ACL behavior](https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl_default_policy)
  that inverts the meaning of an ACL in default-allow mode,
  in phase 1 the Consul bootstrapper will create an agent token
  with the global-management policy and install it into the agent.
  During phase 2, it will be changed to a specific, limited, policy.
  (This change should not be visible to Consul API clients.)
- The bootstrap management token will also be stored persistently
  to be used by the API gateway for proxy authentication,
  and will also be needed for local access to Consul's web user interface.
- (Docker-only) Open a port to signal that Consul bootstrapping is completed.
  (Integrate with `ready_to_run` signal.)

### Phase 2 (completed in Ireland release)

- Consul bootstrapper will install a role in Vault that creates global-management tokens in Consul with no TTL.
- Registry and configuration client libraries will be modified to accept a Consul access token.
- go-mod-bootstrap will have contain the necessary glue logic to
  request a service-specifc Consul access token from Vault
  every time the service is started.
- Consul configuration will be changed to a default "deny" policy
  once all services have been changed to authenticated access mode.
- The agent tokens' policy will be changed to a specific agent policy
  instead of the global-management policy.

### Phase 3 (for Jakarta release)

- Introduce per-service roles and ACL policies that give each service
  access to its own subset of the Consul key-value store
  and to register in the service registry.
- Consul access tokens will be scoped to the needs of the particular service
  (ability to update that service's registry data, an access that services's KV store).
- Create a separate management token (non-bootstrap) for API gateway proxy authentication
  and Consul UI access that is different from boostrap management token stored in Vault.
  This token will need to be requested outside of Vault in order for it to be non-expiring.
- Glue logic will ensure that expired Consul tokens are replaced with fresh ones
  (token freshness can be pre-checked by a request made to `/acl/token/self`).

### Unintended consequences and mitigation (for Jakarta stabilization release)

- Consul token lifetime will be tied to the Vault token lifetime.
  Vault deliberately revokes any Consul tokens that it issues
  in order to ensure that they don't outlive the parent token's lifetime.
  If Consul is not fully initialized when token revokation is attempted,
  Vault will be unable to revoke these tokens.

  Migtigations:

  + Consul will be started concurrently with Vault to give time for Consul to fully initialize.
  + secretstore-setup will delay starting until Consul has completed leader election.
  + secretstore-setup will be modified to less aggressively revoke tokens.
    Alternatives include
    [revoke-and-orphan](https://developer.hashicorp.com/vault/api-docs/auth/token#revoke-token-and-orphan-children)
    which should leave the Consul tokens intact if the secret store is restarted
    but may leave garbage tokens in the Consul database, or
    [tidy-tokens](https://developer.hashicorp.com/vault/api-docs/auth/token#tidy-tokens)
    which cleans up invalid entries in the token database, or
    simply leave Vault to its own devices and let Vault clean itself up.
    Testing will be performed and an appropriate mechanism selected.


## References

- [ADR for secret creation and distribution](./0008-Secret-Creation-and-Distribution.md)
- [ADR for secure bootstrapping](./0009-Secure-Bootstrapping.md)
- [ADR for service registry](https://github.com/edgexfoundry/edgex-docs/pull/283)
- [Hashicorp Vault](https://www.vaultproject.io/)
