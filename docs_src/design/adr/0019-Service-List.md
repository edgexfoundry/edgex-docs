# EdgeX Service List

## Status
**Draft as of April 25, 2021**
Proposed for Jakarta or later release.

## Context

Several EdgeX Foundry services today require a list of the services that are part of an EdgeX deployment.  That is to say, that several EdgeX services need to know the names and locations of other EdgeX services that are or will be part of the EdgeX.

The current list of needs include:

- Security bootstrapping service requires a list of services in order to know which services need a file token for Vault access and to add shared secrets to Vault.
- Consul bootstrapping service requires a list of services in order to generate an appropriate per-service Consul ACL as well as to configure Vault to allow the service to request a Consul token with that ACL.
- System management agent service requires a list of services in order to know which services it can provide status, configuration and metrics for client requestors.  The SMA also needs to know which services to include in any start/stop/restart operations.
- The user interface needs to know which services, specifically device and application services, are available in order to provide interaction with those services, and potentially to display some metrics on operational services.
- The CLI needs to know which services are operational (for some interaction) and which device services and application services to include in start/stop operations.
- Security proxy setup requires a lot of services for which a reverse proxy route should be established.  This is a subset of the full list of EdgeX services.
- Core Metadata must maintain a list of device-type services.  This list is used to validate device additions (i.e., any new device definition must include a valid named device service which it is going to be associated with).  This list is also used when routing commands (via core command) to the appropriate device service.

In the future, there may be other internal or 3rd party needs to what services comprise an EdgeX deployment.

### Current Situation

Currently, the list of services is haphazardly managed by the needing service.

- The security bootstrapping services are being built to use an environment variable to provide it with a list of services at startup.  (This list is needed for both Vault and Consul to setup appropriate access control lists.)
- The user interface and CLI do not deal with service lists today and assume all services are operational (with known service host and port defined in configuration).
- The SMA has a static/hardcoded list built into the codebase.  Clearly the least desirable means of dealing with the list of services as this not only requires a restart of the service, but also code changes and redeployment.

### Requirements

1. It is desired that the service list be addressed in a consistent manner.  It is further desired that there be one single, authoritative source of the service list information for all EdgeX services and 3rd party requestors.  While the source of the service list may change under certain runtime circumstances (for example – whether operating with or without security), once EdgeX is running the authoritative source remains the same for all services.

2. Any changes to the list of services must adhere to ACID transactional properties.  That is, any change to the list of services must be atomic, consistent, isolated and durable with regard to any operations on the service list.  In other words, if a service A makes a change to the list of services, service B should see that change and now have the same list as service A (once the change has been made in some sort of transactional boundry).  No two services should ever be able to get a different list of services when making a request of EdgeX for the list of services.

3. EdgeX services may be added or removed (either intentionally or unintentionally due to failures) all the time.  The list of services should reflect the current list of EdgeX services – that is be dynamic and not a static list at the start/bootstrap of the EdgeX instance.  In particular, new device services and application services are likely to be added to the EdgeX instance after the system is started.

4. Additions and deletions from the EdgeX services to the service list need to be authenticated and authorized.

5. While Consul is often used as the configuration/registry service, EdgeX was constructed to operate off of local configuration in the absence of the central config/registry service (for development purposes or in order to reduce the resource needs of the platform).  The service list need should be provided when a central configuration/registry service like Consul is provided and even when services operate off local configuration.  Per #1 above, all services should get the service list information in the same way, but that may change depending on the existence of a central configuration/registration service.

### Considerations

- In some cases, the list of services is needed before the services are up (security needs to know so appropriate tokens can be generated and handed out when the services bootstrap).
- In some cases, a service may be “disabled” at runtime because of resource constraints (example: notification service is turned off as it is not used and there is a need to operate with limited memory and CPU capability).  Security would still need to know about disabled services in order to create a token for such services that may be enabled later.  However, the other services (or 3rd party applications) may need to know that they are disabled vs enabled.
- In the case that the services are distributed (especially when device services run on different hosts - as is likely), access to a distributed file system or volume mount becomes more of an issue and requires additional technology.
- The service list would have to be a list of services and service locations (URI).  Therefore, the service list will really be a map of service names (keys) and the location of the services URIs (values).  This will help support things like the API gateway setup as well.  In some cases, just a list of the service names is needed (in security token setup for example).  In this latter case, the service would just pick off the service keys.
- Generation of security tokens for the new services under most of the conceived alternatives is complex.  In the current security bootstrapping, secret store setup will require a restart of all the services in order to add or remove a service.  The ORRA project and some adopters are clear that they would like to have the ability to add/remove services dynamically at runtime.
- From a security perspective, being able to add/remove new services dynamically opens up a rather large attack surface.

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
  - How would the security bootstrapping address the add/removal of services and get new tokens established?  The bootstrapping service isn’t even long running to do this.
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

## Decision

To be determined as part of a TSC and monthly architect’s meeting.

## Consequences

A key factor in determining a solution is whether EdgeX will support dynamic addition of services.  If the list of services is static and requires a restart of all of EdgeX when the list changes, the solutions are many and implementation straightforward.

Adopters / users are requesting the ability to add/remove services at runtime (and operate in secure mode).

## References

- April '21 Monthly Architect's Meeting; [discussion of this topic](https://zoom.us/rec/share/8xTGpHTNzCJ0zuBUnHacJq8DmdfMEVzelTBW9eFSvjP3SvcV92BOnaz199kYWUxq.hAAFdvuUi7awZypD?startTime=1618851231000)
