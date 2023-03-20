# Bring Your Own Vault (BYOV) Use Case Requirements 

### Submitters

- Jim White (IOTech)

## Status

- Draft

## Change Log

- Initial draft – 3/5/23

## Market Segments

Any segments using EdgeX in secure mode (using Vault to secure EdgeX secrets) and wanting to incorporate their pre-existing or non-EdgeX Vault store.

## Motivation

[Hashicorp Vault](https://www.vaultproject.io/) is a secure store to manage and protect sensitive (secret) data.  Open-source Vault is used in EdgeX to secure any EdgeX micro service secret (API keys, passwords, database credentials, service credentials, tokens, certificates etc.).  The Vault secret store serves as the **central repository** to keep these secrets in an EdgeX deployment.

Vault provides a unified interface to any secret, while providing tight access control and multiple authentication mechanisms (token, LDAP, etc.). Additionally, Vault supports pluggable "secrets engines". EdgeX uses the Consul secrets engine to allow Vault to issue Consul access tokens to EdgeX microservices. In EdgeX, Vault's storage backend is the host file system.  See [EdgeX Secret Store](https://docs.edgexfoundry.org/3.0/security/Ch-SecretStore/) for more details.

The secret store is optionally used in EdgeX.  Adopters can choose to run in “unsecure” mode (when security features are disabled) without a secret store.  However, today, when the secret store is in place and used as the EdgeX secret store, EdgeX requires adopters to use a new instance of Vault provided by the deployment options offered by the EdgeX community (i.e. Docker Compose files, Kubernetes examples, Snaps, etc.).

In some edge environments where EdgeX may run, Vault is already in place and could be shared by EdgeX.  Additionally, adopters may find several applications running at the edge and want these applications to share a single instance of Vault.  However, having an existing or new instance of Vault that EdgeX uses but does not instantiate and run (a concept the community has called “bringing your own Vault”) is not straightforward.

If an adopter wishes to use an instance of Vault that they stand up or pre-exists in their environment, the EdgeX project does not provide any guidance or recipe for how to do this.  While technically possible, it would require a lot of work on the part of the adopter to:

- Remove any EdgeX initialization / unsealing of the EdgeX Vault data store
- Informs the existing Vault instance for EdgeX use
- Configure the secrets engine of the existing Vault (allowing EdgeX permissions to initialize the Consul secrets engine).
- Create policies, tokens, identities for all EdgeX services in the existing Vault
- Inform EdgeX micro services to use the existing Vault instance
- Populate existing Vault with EdgeX secrets

In short, this is some tedious work and work that is not documented well (or in some cases at all).  It would require an adopter to study the secretstore-setup code and rework or replace the secretstore-setup service with new code to use the existing Vault instance.

Therefore, the motivation for this EdgeX change is to make it easier to allow adopters to “bring their own Vault” instance and have EdgeX use that instance without any changes to the overall function of the EdgeX platform.

## Target Users

Any adopter that runs EdgeX in secure mode and with a pre-existing Vault or intention to share a Vault instance among edge applications.

## Description

Per the [issue](https://github.com/edgexfoundry/edgex-go/issues/1944) documented in the EdgeX GitHub edgex-go repository, the requirement is to:

1. “de-privilege” EdgeX’s use of Vault
2. Modularize security-secretstore-setup to allow portions to be replaced more easily with initialization / setup that uses an existing Vault instance
3. Provide proper tools (scripts, code, etc.), documentation and examples to make it easier to replace EdgeX Vault instance with a 3rd party Vault instance.

## Existing solutions

One “hack” suggested by the EdgeX security working group chairman would be to fork the security secretstore setup so that it doesn't try to initialize the Vault instance and only performs a few of the tasks currently done by the secretstore setup code.  This assumes that Vault is running already with TLS in place and the existing Vault is using a non-expiring root token.

The security of this alternative solution is very weak.

## Requirements

- Offer a “secure” EdgeX configuration deployment templates (via Docker Compose files, Snap/Snapcraft packaging, example Kubernetes Helm document, etc.) that uses a non-EdgeX established Vault instance (the Bring Your Own Vault or BYOV).
- Change the EdgeX setup/initialization code/scripts to instantiate EdgeX secrets in the BYOV instance
- Provide EdgeX micro services and other 3rd party service (i.e., Redis, Consul, etc.) configuration options to use the BYOV instance to get their secrets.
- Require no code changes in any other EdgeX micro service code (only configuration changes) to use the BYOV
- Provide sufficient documentation, tools, assistance to adopters to have a BYOV instance and easily use it with EdgeX with little or no coding (just configuration changes).

## Other Related Issues

## References

- https://github.com/edgexfoundry/edgex-go/issues/1944
- https://www.vaultproject.io/
- https://docs.edgexfoundry.org/3.0/security/Ch-SecretStore/
- https://github.com/edgexfoundry/edgex-go/tree/main/cmd/security-secretstore-setup
