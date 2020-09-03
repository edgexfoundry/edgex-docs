# Service Self Config Init & Config Seed Removal  

## Status 

**approved** - TSC vote on 3/25/20 for Geneva release

> NOTE:  this ADR does not address high availability considerations and concerns.  EdgeX, in general, has a number of unanswered questions with regard to HA architecture and this design adds to those considerations.

## Context 
Since its debut, EdgeX has had a configuration seed service (config-seed) that, on start of EdgeX, deposits configuration for all the services into Consul (our configuration/registry service).  For development purposes, or on  resource constrained platforms, EdgeX can be run without Consul with services simply reading configuration from the filesystem.

While this process has nominally worked for several releases of EdgeX, there has always been some issues with this extra initialization process (config-seed), not least of which are:
- race conditions on the part of the services, as they bootstrap, coming up before the config-seed completes its deposit of configuration into Consul
- how to deal with "overrides" such as environmental variable provided configuration overrides. As the override is often specific to a service but has to be in place for config-seed in order to take effect.
- need for an additional service that is only there for init and then dies (confusing to users)

NOTE - for historical purposes, it should be noted that config-seed only writes configuration into the configuration/registry service (Consul) once on the first start of EdgeX.  On subsequent starts of EdgeX, config-seed checks to see if it has already populated the configuration/registry service and will not rewrite configuration again (unless the --overwrite flag is used).

The design/architectural proposal, therefore, is:
- removal of the config-seed service (removing cmd/config-seed from the edgex-go repository)
- have each EdgeX micro service "self seed" - that is seed Consul with their own required configuration on bootstrap of the service.  Details of that bootstrapping process are below.

### Command Line Options
All EdgeX services support a common set of command-line options, some combination of which are required on startup for a service to interact with the rest of EdgeX. Command line options are not set by any configuration.  Command line options include:

- --configProvider or -cp (the configuration provider location URL - prefixed with `consul.` - for example:  `-cp=consul.http://localhost:8500`)
- --overwrite or -o (overwrite the configuration in the configuration provider)
- --file or -f (the configuration filename - configuration.toml is used by default if the configuration filename is not provided)
- --profile or -p (the name of a sub directory in the configuration directory in which a profile-specific configuration file is found. This has no default. If not specified, the configuration file is read from the configuration directory)
- --confdir or -c (the directory where the configuration file is found - ./res is used by default if the confdir is not specified, where "." is the convention on Linux/Unix/MacOS which means current directory) 
- --registry or -r (string indicating use of the registry)

The distinction of command line options versus configuration will be important later in this ADR.

Two command line options (-o for overwrite and -r for registry) are not overridable by environmental variables.

NOTES: Use of the --overwrite command line option should be used sparingly and with expert knowledge of EdgeX; in particular knowledge of how it operates and where/how it gets its configuration on restarts, etc.  Ordinarily, --overwrite is provided as a means to support development needs.  Use of --overwrite permanently in production enviroments is highly discouraged.

### Configuration Initialization
Each service has (or shall have if not providing it already) a local configuration file.  The service may use the local configuration file on initialization of the service (aka bootstrap of the service) depending on command line options and environmental variables (see below) provided at startup.

**Using a configuration provider**

When the configuration provider _is_ specified, the service will call on the configuration provider (Consul) and check if the top-level (root) namespace for the service exists.  If configuratation at the top-level (root) namespace exists, it indicates that the service has already populated its configuration into the configuration provider in a prior startup.

If the service finds the top-level (root) namespace is already populated with configuration information it will then read that configuration information from the configuration provider under namespace for that service (and ignore what is in the local configuration file).

If the service finds the top-level (root) namespace is not populated with configuration information, it will read its local configuration file and populate the configuration provider (under the namespace for the service) with configuration read from the local configuration file.

A configuration provider can be specified with a command line argument (the -cp / --configProvider) or environment variable (the EDGEX_CONFIGURATION_PROVIDER environmental variable which overrides the command line argument).
> NOTE:  the environmental variables are typically uppercase but there have been inconsistencies in environmental variable casing (example:  edgex_registry).  This should be considered and made consistent in a future major release.

**Using the local configuration file**

When a configuration provider _isn't_ specified, the service just uses the configuration in its local configuration file.  That is the service uses the configuration in the file associated with the profile, config filename and config file directory command line options or environmental variables.  In this case, the service does not contact the configuration service (Consul) for any configuration information.
  
NOTE:  As the services now self seed and deployment specific changes can be made via environment overrides, it will no longer be necessary to have a Docker profile configuration file in each of the service directories (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml).  See Consequences below.  It will still be possible for users to use the profile mechanism to specify a Docker configuration, but it will no longer be required and not the recommended approach to providing Docker container specific configuration.

### Overrides
Environment variables used to override configuration always take precedence whether configuration is being sourced locally or read from the config provider/Consul.

Note - this means that a configuration value that is being overridden by an environment variable will always be the source of truth, even if the same configuration is changed directly in Consul.

The name of the environmental variable must match the path names in Consul.

NOTES:
- Environmental variables overrides remove the need to change the "docker" profile in the res/docker/configuration.toml files - Allowing removal of 50% of the existing configuration.toml files.
- The override rules in EdgeX between environmental variables and command line options may be counter intuitive compared to other systems.  There appears to be no standard practice.  Indeed, web searching "Reddit & Starting Fights Env Variables vs Command Line Args" will layout the prevailing differences.
- Environment variables used for configuration overrides are named by prepending the the configuration element with the configuration section inclusive of sub-path, where sub-path's "."s are replaced with underscores. These configuration environment variable overrides must be specified using camel case.  Here are two examples:
~~~~~
Registry_Host  for
[Registry]
Host = 'localhost'

Clients_CoreData_Host for
[Clients]
  [Clients.CoreData]
  Host = 'localhost'
~~~~~
- Going forward, environmental variables that override command line options should be all uppercase.

All values overriden get logged (indicating which configuration value or op param and the new value).  

## Decision 

These features have been implemented (with some minor changes to be done) for consideration here:  https://github.com/edgexfoundry/go-mod-bootstrap/compare/master...lenny-intel:SelfSeed2.  This code branch will be removed once this ADR is approved and implemented on master.

The implementation for self-seeding services and environmental overrides is already implemented (for Fuji) per this document in the application services and device services (and instituted in the SDKs of each).

## Backward compatibility
Several aspects of this ADR contain backward compatibility issues for the device service and application service SDKs.  Therefore, for the upcoming minor release, the following guidelines and expections are added to provide for backward compatibility.

- --registry=<url> for Device SDKs
        
As earlier versions of the device service SDKs accepted a URI for --registry, if specified on the command line, use the given URI as the address of the configuration provider.  If both --configProvider and --registry specify URIs, then the service should log an error and exit.

- --registry (no ‘=’) and w/o --configProvider for both SDKs

If a configProvider URI isn't specified, but --registry (w/out a URI) is specified, then the service will use the Registry provider information from its local configuration file for both configuration and registry providers.

- Env Var: edgex_registry=<url> for all services (currently has been removed)

Add it back and use value as if it was EDGEX_CONFIGURATION_PROVIDER and enable use of registry with same settings in URL. Default to http as it is in Fuji.
 
## Consequences 

- Docker compose files will need to be changed to remove config seed. 
- The main Snap will need to be changed to remove config seed. 
- Config seed code (currently in edgex-go repo) is to be removed.
- Any service specific environmental overrides currently on config seed need to be moved to the specific service(s).
- The Docker configuration files and directory (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml) that are used to populate the config seed for Docker containers can be eliminated from all the services.  
- In cmd/security-secretstore-setup, there is only a docker configuration.toml.  This file will be moved rather than deleted.
- Documentation would need to reflect removal of config seed and "self seeding" process.
- Removes any potential issue with past race conditions (as experienced with the Edinburgh release) as each service is now responsible for its own configuration.
  > There are still high availability concerns that need to be considered and not covered in this ADR at this time.
- Removes some confusion on the part of users as to why a service (config-seed) starts and immediately exits.
- Minimal impact to development cycles and release schedule
- Configuration endpoints in all services need to ensure the environmental variables are reflected in the configuration data returned (this is a system management impact).
- Docker files will need to be modified to remove setting profile=docker
- Docker compose files will need to be changed to add environmental overrides for removal of docker profiles. These should go in the global environment section of the compose files for those overrides that apply to all services.  Example:
~~~~~
# all common shared environment variables defined here:
x-common-env-variables: &common-variables
  EDGEX_SECURITY_SECRET_STORE: "false"
  EDGEX_CONFIGURATION_PROVIDER: consul.http://edgex-core-consul:8500
  Clients_CoreData_Host: edgex-core-data
  Clients_Logging_Host: edgex-support-logging
  Logging_EnableRemote: "true"
~~~~~
