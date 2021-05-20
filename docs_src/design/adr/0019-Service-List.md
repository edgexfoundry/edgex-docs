# EdgeX Service List

## Status
**Draft as of April 25, 2021**
Proposed for Jakarta or later release.

## Context

Several EdgeX Foundry services today require a list of the services that are part of an EdgeX deployment.  That is to say, that several EdgeX services need to know the names and locations of other EdgeX services that are or will be part of the EdgeX.

The current list of needs include:

- Security bootstrapping (found in security-secretstore-setup service) requires a list of services in order to know which services need a file token for Vault access and to add shared secrets to Vault.
- Consul bootstrapping service requires a list of services in order to generate an appropriate per-service Consul ACL as well as to configure Vault to allow the service to request a Consul token with that ACL.
- System management agent service requires a list of services in order to know which services it can provide status, configuration and metrics for client requestors.  The SMA also needs to know which services to include in any start/stop/restart operations.
- The user interface needs to know which services, specifically device and application services, are available in order to provide interaction with those services, and potentially to display some metrics on operational services.
- The CLI could refer to a dynamic list of which services are operational and which device services and application services to include in start/stop operations.  *Note: Alternatively, the CLI could simply issue a command to a service and if the service is not available, issue an error response.  However, if a new service was added (such as a new device service), the CLI would not know about it unless it had access to some dynamic list of services.*
- Security proxy setup requires a list of services for which a reverse proxy route should be established.  This is a subset of the full list of EdgeX services.
- Core Metadata must maintain a list of device-type services.  This list is used to validate device additions (i.e., any new device definition must include a valid named device service which it is going to be associated with).  This list is also used when routing commands (via core command) to the appropriate device service.

In the future, there may be other internal or 3rd party needs to what services comprise an EdgeX deployment.

### Current Situation

Currently, the list of services is haphazardly managed by the needing service.

- The security bootstrapping services use a combination of staic lists for known EdgeX services and environment variables for services that are not statically known.  (This list is needed for both Vault and Consul to setup appropriate access control lists.)
- The user interface and CLI do not deal with service lists today and assume all services are operational (with known service host and port defined in configuration).
- The SMA has a static/hardcoded list built into the codebase.  Clearly the least desirable means of dealing with the list of services as this not only requires a restart of the service, but also code changes and redeployment.

### Requirements

1. It is desired that the service list be addressed in a consistent manner.  It is further desired that there be one single, authoritative source of the service list information for all EdgeX services and 3rd party requestors.  While the source of the service list may change under certain runtime circumstances (for example – whether operating with or without security), once EdgeX is running the authoritative source remains the same for all services.

2. Any changes to the list of services must adhere to ACID transactional properties.  That is, any change to the list of services must be atomic, consistent, isolated and durable with regard to any operations on the service list.  In other words, if a service A makes a change to the list of services, service B should see that change and now have the same list as service A (once the change has been made in some sort of transactional boundry).  No two services should ever be able to get a different list of services when making a request of EdgeX for the list of services **at the same time**

3. EdgeX services may be added or removed (either intentionally or unintentionally due to failures) all the time.  The list of services should reflect the current list of EdgeX services – that is be dynamic and not a static list at the start/bootstrap of the EdgeX instance.  In particular, new device services and application services are likely to be added to the EdgeX instance after the system is started.

4. Additions and deletions from the EdgeX services to the service list need to be done securely.

5. While Consul is often used as the registry service, EdgeX was constructed to use the local configuration as the means to understand the location of services in the absence of the central registry service (for development purposes or in order to reduce the resource needs of the platform).  The service list need should be provided for when either a central registry service like Consul is in place or when services operate off local configuration to understand what services are in place.  Per #1 above, all services should get the service list information in the same way, but that may change depending on the existence of a central configuration/registration service.

### Considerations

- In some cases, the list of services is needed before the services are up (security needs to know so appropriate tokens can be generated and handed out when the services bootstrap).
- In some cases, a service may be “disabled” at runtime because of resource constraints (example: notification service is turned off as it is not used and there is a need to operate with limited memory and CPU capability).  Security would still need to know about disabled services in order to create a token for such services that may be enabled later.  However, the other services (or 3rd party applications) may need to know that they are disabled vs enabled.
- In the case that the services are distributed (especially when device services run on different hosts - as is likely), access to a distributed file system or volume mount becomes more of an issue and requires additional technology.  *Note: distributing device services while in secure mode is now more complex due to the fact that all services require Vault access and the services get their Vault token from file.  Distributed device services in secure mode would therefore would require a distributed file system.*
- The service list would have to be a list of services and service locations (URI).  Therefore, the service list will really be a map of service names (keys) and the location of the services URIs (values) and potentially other information such as `known secrets` as used by the secret store setup (`redisdb` is the only `known secret` to date).  This will help support things like the API gateway setup as well.  In some cases, just a list of the service names is needed (in security token setup for example).  In this latter case, the service would just pick off the service keys.
- Generation of security tokens for the new services under most of the conceived alternatives is complex.  In the current security bootstrapping, secret store setup will require a restart of all the services in order to add or remove a service.  The ORRA project and some adopters are clear that they would like to have the ability to add/remove services dynamically at runtime.  *Note: in some circumstances, services can be added/removed dynamically today, but not when EdgeX security services are enabled.  CLI and UI also do not allow for the addition/remove of services - such as device or application services.*
- From a security perspective, being able to add/remove new services dynamically opens up a rather large attack surface.
- If operating without a registry (like Consul), satisfying all the requirements above may be difficult (or not possible) and require more hands-on configuration resulting in more system brittleness. 
- In actuality, there is a need for two separate service lists: a list of `potential` services that are going to be running (used by secuirty to provide tokens, etc.) and a list of running services (used by the other services once the system is up and running) 

### Implementation Alternative Discussion

- A service list could be made available in a configuration file in the file system (non-Docker) or volume mount (in a Docker situation).
  - All services would get the configuration in a consistent way (#1)
  - It would also mean that there is a single, authoritative list for all services.  Finding a file-based solution that is also supports ACID transactional would be a challenge - if even possible(#2 and #3).
  - The file would have to be validated whenever edited in order not to bring down all the services with bad contents.  Integrity of the configuration file could not be protected if someone edited the file by hand.
  - This alternative would solve the requirement that the solution operate with or without Consul (#4).  UI and CLI should have access to the same file or volume mount.
  - There is a question about who or what service would put this file into the file system or volume mount – especially since security bootstrapping would need it first but this file would be needed in non-secure runtime as well.
  - There isn’t a central service that would own the file – especially for dev/test.
  - It has to be a service that is always there (like core metadata), but also available from the start of all services (which metadata is not in the case of security services).  Ideally, this service should not require root user privileaes.
  - Services would have to monitor the file or volume for changes in order to be able to address the add/removal of services at runtime.
  - How would the security bootstrapping address the add/removal of services and get new tokens established?  The bootstrapping service isn’t even long running to do this. *Note: the secret store setup service could be made to run indefinitely rather easily (TokenProviderType could be set to "forking" vs "oneshot) and react to add/removal of services.*
- Have global configuration in Consul (or config/reg service) that everyone reads.
  - When Consul is used, there would be a single authoritative list of services provided to all requesting services through Consul. Updates to Consul would be transactional (ACID).
  - When Consul is not used, have a common service list in each service configuration.toml file that everyone reads.  Further, when Consul is not used, each service is using the same means (addressing #1 above) to get its service list (that is going to its config TOML file locally).  However, each service list in each configuration file could be different (leading to service list inconsistencies) and there is not a single, authoritative list when using local configuration (making ACID transactions to the service list per #3 above very difficult – especially if services and their configuration file holding the copy of the service list are distributed across hosts).
  - Using Consul would make sure that the service list is well formed (meaining adherence to format, but this does not mean that the service list necessarily adheres to any validity rules unless additional code interacting with Consul changes is checking for well formed-ness and validity) and that any change operation is ACID (but only with regard to Consul and the service list - this does not mean the transaction would incorporate additional needs such as the API Gateway updating new routes).
  - When using the local configuration, some of the same issues exist as listed in the first alternative (validation of the file, etc.).
  - Services would have to be notified by Consul if the service list changes or monitor the local config for a service list change in order to be able to address the add/removal of services at runtime.
  - Again, how would the security bootstrapping address the add/removal of services and get new tokens established?  The bootstrapping service isn’t even long running to do this.
  - We could use Consul for dynamic service needs and when Consul is not used resolve that the service list is static and requires a restart of the services.
  - There is a mutually inclusive event issue (aka chicken and egg problem) with this solution in that we have to secure Consul via the security bootstrapping providing it a token and a list of all the services, but Consul is the place where the security service would get the list of all services.  The circumstances prohibit both to be true.
- Use environment variables to provide the list of services.
  - Each micro service would use the same env var to get the list of services.
  - Use of an env var is a bit cumbersome in setup of all services – especially when the env var changes.  This is considered “unmanageable”.
  - Adding or removing a service at runtime get tricky under this alternative (you can’t change the env var after startup)
  - This would be a single, authoritative location for service list information.
  - ACID needs would be moot as the env var would not be changed post startup.
  - The env var value is a per-process thing, even though the env-var name is the same.  Unless using an OS/orchestration mechanism to ensure the value is the same for all processes, this alternate is not viable.
- Use core metadata as a simple registry.
  - Create/use a new API (or key-value store API) on core metadata to implement a simple registry.
  - This would require core metatdata to come up first (among services).
  - The benefit of this approach would help eliminate a lot of code that check if we haven't got a registry/config provider.

## Decision

At a high level, EdgeX intends to solve the service list needs with the following architectural design:

1. A new "seed script" (aka - seed service) will come up first before all other EdgeX services (whether in secure or unsecure mode). 
  a. This seed service populate Consul (or implemenation of the registry/configuration service) with a list of potential services that EdgeX will be running when the EdgeX instance is up.  The seed service will populate a "global" configuration area in the registry/configuration service with the list of potential services.
  b. In the event Consul is not running, the seed service will populate a shared volume or other shared file.  It is unlikely that EdgeX will implement this form of service list management, but it could be implemened by adopters if use of Consul is not desired or prohibited.  Using a shared volume or file would also create complexities in a distributed environment and would be left to the adopter to solve.
2. The original list of potential services used to populate Consul (or the shared volume/file) will come from a TOML configuration file provided to the seed service.
  a. Use of this TOML file to provide the seed service with the potential list of services allows environmental variables to be avoided in defining the list of potential services.
3. All services (security or otherwise) can query Consul (or the volume/shared file) for a list of potential services (during the bootstrapping / init phase) or actual running services (after bootstrapping/ init phase).  The registry API (defined by the EdgeX registry abstrction) will be augmented to provide the query capability.
  a. After seeding, Consul (or the shared volume/file) is the single point of authority/consistency for the list of services (potential or running).
  b. Additional registry APIs will be provided to add/remove services.
  c. Services can be removed but they can also be stopped or suffer a crash.  When a service is removed (via the API) it is no longer considered an EdgeX service (unless added back).  A service that is stopped (for example to make some sort of configuration update) or a service that crashes (and will eventually be restore) are still registered with and considered valid services so far as Consul (or the shared volume/file) is concerned.  In other words, crashed or stopped services is considered a temporary state. 
4. This implementation will allow some of the client configuration information defined in each service's configuration.toml to be reduced.
  a. The location of the any client service could be obtained throught a registry query of Consul (or the shared volume/file).  Therefore client service host, port can be removed from the service configuration files.
  b. This also removes/reduces redundant/conflicting sources of service list information

Issues to still be determined
- Where does the "seed script" live.  Is it a seed service or some existing service?  Metadata, Consul setup script, a security service, etc.?
- We must consider how this is implemented for both secure and non-secure mode (meaning using a security service to be the seed may not be appropriate) 

## Consequences

TBD

## References

- April '21 Monthly Architect's Meeting; [discussion of this topic](https://zoom.us/rec/share/8xTGpHTNzCJ0zuBUnHacJq8DmdfMEVzelTBW9eFSvjP3SvcV92BOnaz199kYWUxq.hAAFdvuUi7awZypD?startTime=1618851231000)
- EdgeX Foundry Registry ADR provides some context and information relavent to this ADR.  See https://docs/edgexfoundry.org/2.0/design/adr/0018-Service-Registry/.

