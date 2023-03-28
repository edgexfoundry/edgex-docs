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

Vault provides a unified interface to any secret, while providing tight access control and multiple authentication mechanisms (token, LDAP, etc.). Additionally, Vault supports pluggable "secrets engines". EdgeX uses three secrets engines today:  key-value secrets engine, Consul secrets engine, and identity secrets engine.  EdgeX uses the Consul secrets engine to allow Vault to issue Consul access tokens to EdgeX microservices. See [EdgeX Secret Store](https://docs.edgexfoundry.org/3.0/security/Ch-SecretStore/) for more details.

Today, when the secret store is in place and used as the EdgeX secret store, EdgeX requires adopters to use a new instance of Vault provided by the deployment options offered by the EdgeX community (i.e. Docker Compose files, Kubernetes examples, Snaps, etc.).  In other words, EdgeX must totally own the Vault install.

In some edge environments where EdgeX may run, Vault is already in place and could be shared by EdgeX.  Additionally, adopters may find several applications running at the edge and want these applications to share a single instance of Vault.  However, having an existing or new instance of Vault that EdgeX uses but does not instantiate and run (a concept the community has called “bringing your own Vault”) is not straightforward.

If an adopter wishes to use an instance of Vault that they stand up or pre-exists in their environment, the EdgeX project does not provide any guidance or recipe for how to do this.  While technically possible, it would require a lot of work on the part of the adopter. See the original [issue](https://github.com/edgexfoundry/edgex-go/issues/1944) driving this requirement for a potential list of changes that would be required. In short, this is some tedious work and work that is not documented well (or in some cases at all).  It would require an adopter to study the secretstore-setup code and rework or replace the secretstore-setup service with new code to use the existing Vault instance.

Therefore, the motivation for this EdgeX change is to make it easier to allow adopters to “bring their own Vault” instance and have EdgeX use that instance without any changes to the overall function of the EdgeX platform.

## Target Users

Any adopter that runs EdgeX in secure mode and with a pre-existing Vault or intention to share a Vault instance among edge applications.

## Description

Adopters running EdgeX in an environment that has (or will have) an existing Vault instance not setup by EdgeX:

- do not want EdgeX to create its own EdgeX
- want secrets added to the existing instance (the BYOV instance)
- want the EdgeX micro services (including EdgeX 3rd party services such as the database, API Gateway, etc.) to get their secrets from the existing instance (the BYOV instance)

## Existing solutions

There are no existing solutions for BYOV.

## Requirements

The basic requirements are straightforward:

1. Allow EdgeX to seed secrets in a pre-existing or non-EdgeX provided Vault (i.e. the BYO Vault) instance
2. Allow EdgeX services to get/read secrets from the pre-existing or non-EdgeX provided Vault (i.e. the BYO Vault) instance

## Other Related Issues

## References

- [Issue 1944](https://github.com/edgexfoundry/edgex-go/issues/1944)
- [Vault Project](https://www.vaultproject.io/)
- [EdgeX Secret Store docs](https://docs.edgexfoundry.org/3.0/security/Ch-SecretStore/)
- [EdgeX Secret Store Setup](https://github.com/edgexfoundry/edgex-go/tree/main/cmd/security-secretstore-setup)
