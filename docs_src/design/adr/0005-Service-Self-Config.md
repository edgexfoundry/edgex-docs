# Service Self Config Init & Config Seed Removal  

## Status 

under review - for Geneva release

## Context 
Since its debut, EdgeX has had a configuration seed service (config-seed) that, on start of EdgeX, deposits configuration for all the services into Consul (our configuration/registry service).  For development purposes, or for those resource cosntrained platforms, Consul would not be running, the config-seed would not run or if it did run would obviously not deposit configuration, and services would use a configuration file in proximity to the service in order to get their neede configuration.

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

### Configuration Initializaiton
Going forward, each service would have a local configuration file.  On intialization of the service (aka bootstrap of the service), the service would use the configuration to populate the configuration service (Consul) with data read from the configuration file.  In this way, each service self-seeds the configuration service.

Details of the proposed process are as follows:
- Service initializes and determines whether it should get its configuration from a local configuration file or from a configuration service by way of 
  
  a) the -cp / --configProvider op param

  b) the edgex_configuration_provider environmental variable which overrides the op param above
  
- If the service is to use the local file, it reads the file associated with the profile, config filename and config file directory op params or environmental variables) and does not contact the configuration service (Consul) for any configuration information.
- If the service is to use the configuration service, then the service will:
  
  1) call on Consul and check the root in Consul to see if it is already populated with configuration information provided by the service.  If so, the service will load and use the Consul provided configuration for that service.
  2) If the root in Consul is not populated with configuration information provided by the service, the service will read the local configuration file and populate Consul with the configuration contents in that file.

NOTE: as the services now self seed and the profile allows for the appropriate seeding to occur in the service itself, it will no longer be necessary to have a Docker configuration file in each of the service directories (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml).  See Consequences below.

### Overrides
Environmental variable overrides of configuration or op param values can occur in one of two ways
- Environmental variables can override configuration values provided by Consul.  The name of the environmental variable must match the path names in Consul.  NOTE:  environment variable overrides do not get pushed into Consul.  They only override a value read from Consul on bootstrap.
- Environmental variables can override op params.  Op params specify opreation of the service and are configuration that is not ever in Consul. 

All values overriden get logged (indicating which configuration value or op param and the new value).  

## Decision 

This features has been implemented (with some minor changes to be done) for consideration here:  https://github.com/edgexfoundry/go-mod-bootstrap/compare/master...lenny-intel:SelfSeed2
 
## Consequences 

- Docker compose files will need to be changed to remove config seed
- Config seed repo(s) all to be archived
- The Docker configuration files and directory (example:  https://github.com/edgexfoundry/edgex-go/blob/master/cmd/core-data/res/docker/configuration.toml) that are used to populate the config seed for Docker containers can be eliminated from all the services.
- Documentation would need to reflect removal of config seed and "self seeding" process.
- Removes any potential issue with race conditions as each service is not responsible for its own configuration.
- Removes some confusion on the part of users as to why a service (config-seed) starts and immediately exits.
- Minimal impact to development cycles and release schedule 

 

 

 