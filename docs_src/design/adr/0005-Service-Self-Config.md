# Service Self Config Init & Config Seed Removal  

## Status 

under review - for Geneva release

## Context 
Since its debut, EdgeX has had a configuration seed service (config-seed) that, on start of EdgeX, deposits configuration for all the services into Consul (our configuration/registry service).  For development purposes, or for those resource cosntrained platforms, Consul would not be running, the config-seed would not run or if it did run would obviously not deposit configuration, and services would use a configuration file in proximity to the service in order to get their needed configuration.

While this process has nominally worked for several releases of EdgeX, there has always been some issues with this extra initialization process (config-seed), not least of which are:
- race conditions on the part of the services, as they bootstrap, coming up before the config-seed completes its deposit of configuration into Consul
- how to deal with "overrides" such as environmental variable provided configuration overrides. As the override is often specific to a service but has to be in place for config-seed in order to take effect.
- need for an additional service that is only there for init and then dies (confusing to users)

The design/architectural proposal, therefore, is:
- removal of the config-seed service (putting the current config-seed repositories in archive)
- have each EdgeX micro service "self seed" - that is seed Consul with their own required configuration on bootstrap of the service.  Details of that bootstrapping process are below.

### Operational parameters
Operational parameters (op params for the rest of this document) are properties set by a service's command line arguements.  These include profile, configuration filename, configuration file directory, configuration provider URL, and overwrite flag.  The operational parameters are not set by any configuration (local file or Consul).  Op params include:

- --configProvider or -cp (the configuration provider location URL)
- --overwrite or -o (overwrite the configuration in the configuration provider)
- --file or -f (the configuration filename)
- --profile or -p (the profile name of configuration)
- --confidir (the directory where the configuration file is found)
- --registry or -r (use the registry)

The distinction of op params versus configuration will be important later in this ADR.

Two op params (-o for overwrite and -r for registry) are not overridable by environmental variables.

### Configuration Initialization
Going forward, each service would have a local configuration file.  On intialization of the service (aka bootstrap of the service), the service would use the configuration to populate the configuration service (Consul) with data read from the configuration file.  In this way, each service self-seeds the configuration service.

Details of the proposed process are as follows:
- Service initializes and determines whether it should get its configuration from a local configuration file or from a configuration service by way of 
  
  a) the -cp / --configProvider op param

  b) the edgex_configuration_provider environmental variable which overrides the op param above
  
- If the service is to use the local file, it reads the file associated with the profile, config filename and config file directory op params or environmental variables) and does not contact the configuration service (Consul) for any configuration information.
- If the service is to use the configuration service, then the service will:
  
  1) call on Consul and check the root in Consul to see if it is already populated with configuration information provided by the service.  If so, the service will load and use the Consul provided configuration for that service.
  2) If the root in Consul is not populated with configuration information provided by the service, the service will read the local configuration file and populate Consul with the configuration contents in that file.

NOTE:  As the services now self seed and the profile allows for the appropriate seeding to occur in the service itself, it will no longer be necessary to have a Docker configuration file in each of the service directories (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml).  See Consequences below.

### Overrides
Environmental variables override configuration or op param values in the following ways
- Environmental variables override configuration values as they are pushed (self seeded) into the configuration service (Consul).  This override only occurs once (as the values are pushed / seeded into Consul from the service).  Once pushed, configuration values are used from Consul and any environmental value is ignored unless the -o/--overwrite flag is on.  The name of the environmental variable must match the path names in Consul.
- Environmental variables can override op params (except the -o overwrite and -r registry op params).  Op params specify operation of the service and are configuration that is not ever in Consul. 

NOTES:
- Environmental variables do not override any local configuration; that is when configuration for a service is obtained from the local config file but not from the configuration service, the environmental variables are ignored.
- Environmental variable overrides remove the need to change the "docker" profile in the res/docker/configuration.toml files - Allowing removal of 50% of the existing configuration.toml files.

All values overriden get logged (indicating which configuration value or op param and the new value).  

## Decision 

This features has been implemented (with some minor changes to be done) for consideration here:  https://github.com/edgexfoundry/go-mod-bootstrap/compare/master...lenny-intel:SelfSeed2

The implementation for self-seeding services and environmental overrides is already implemented (for Fuji) per this document in the application services and device services (and instituted in the SDKs of each).
 
## Consequences 

- Docker compose files will need to be changed to remove config seed.  
- Config seed repo(s) all to be archived
- Any service specific environmental overrides currently on config seed need to be moved to the specific service(s)
- The Docker configuration files and directory (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml) that are used to populate the config seed for Docker containers can be eliminated from all the services.
- Documentation would need to reflect removal of config seed and "self seeding" process.
- Removes any potential issue with race conditions as each service is now responsible for its own configuration.
- Removes some confusion on the part of users as to why a service (config-seed) starts and immediately exits.
- Minimal impact to development cycles and release schedule 
- Docker files will need to be modified to remove setting profile=docker
- Docker compose files will need to be changed to add environmental overrides for removal of docker profiles. These should go in the global environment section of the compose files for those overrides that apply to all services.  Example:
~~~~~
# all common shared environment variables defined here:
x-common-env-variables: &common-variables
  EDGEX_SECURITY_SECRET_STORE: "false"
  edgex_configuration_provider: consul.http://edgex-core-consul:8500
  Clients_CoreData_Host: edgex-core-data
  Clients_Logging_Host: edgex-support-logging
  Logging_EnableRemote: "true"
~~~~~

 

 

 