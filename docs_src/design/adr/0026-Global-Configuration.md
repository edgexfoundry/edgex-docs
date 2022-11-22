# Global Common Configuration ADR

## Status

**Draft**

This is a preliminary document outlining alternative design options for implementation of the Global Common Configuration.

## Submitters

- Jim White with community input

## Change Log

- N/A

## Referenced Use Case(s)

- [Global Common Configuration UCR – still to be approved]( https://github.com/edgexfoundry/edgex-docs/pull/892)

## Context

Per the UCR, there is a need to have global configuration so that common configuration is not repeated in each service’s configuration.  In other words, there is a goal to reduce redundancy in service configuration and allow for better management of the services configuration across all EdgeX services.

As there have been multiple design / implementation alternatives suggested in planning meetings to date, this draft ADR is meant to serve as a landing area for all proposed implementation options.

Options will be reduced to a single, selected design going forward and will serve as the basis of this ADR.  All other options will be relegated to the considerations section at that time.

## Proposed Design(s)
These are the alternate design/implementation options being considered along with pro/con discussions of each option

### Global overridden by Local Configuration Design (attributed to Lenny G)       

- Services reference both global or common configuration and a local (service specific) configuration (not unlike how a service is pointed to local configuration today)
    - A single public file from which all services get the configuration
- On bootstrap of a service, common or global configuration is pulled from global configuration first
- Service configuration is pulled from its “local” or service-specific TOML configuration file second (overriding the global or common configuration)
- Issues/Pros/Cons:
    - Where does common config reside once the service has consumed them?
        - When do you push the config to a config provider?
    - How do you handle updates to writables (reboot when common writable is changed?)?

### Consul Seed (attributed to Farshid T)

- Prepopulate Consul via configuration service (like EdgeX’s old config seed)
- Config service populates Consul with the global /common config (specified in common configuration file)
- When services start, they pull the common configuration from Consul
- Issues/Pros/Cons:
    -   Wouldn’t need to change any of the services.  They pull Consul for configuration as they do today
    - Only works with Consul
        - Is having common configuration without Consul a requirement or not?   At least as a first step?
        - Non-Consul implementation may be simpler

### Core Metadata as the seeding service (slight alternate to the Consul Seed idea)

- Use Core Metadata to “own” the common configuration file and seed Consul with the common configuration when it comes up.
- Issues/Pros/Cons:
    - TBD

## Decision

Do not use or update this section yet

## Consequences and Considerations

**Key consideration**: is the final design/implementation backward compatible (and

Do not use or update this section yet

## References