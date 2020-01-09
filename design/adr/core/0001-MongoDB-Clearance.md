# MongoDB Clearance

<!--ts-->

- [Status](#status)
- [Context](#context)
- [Proposed Design](#proposed-design)
- [Decision](#decision)
- [Consequences](#consequences)
- [References](#references)

<!--te-->

## Status

Proposed

## Context  
[docker-edgex-mongo](https://github.com/edgexfoundry/docker-edgex-mongo) has been developed to replace the old way of initializing mongo database (using [init_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/init_mongo.js)) and to introduce security features.  <br />
Currently, docker-edgex-mongo is single purpose application, because it is responsible only for `initializing` all the data inside mongo. <br />
It runs the mongo server, creates all the databases with the appropriate collections inside and create the relevant users.<br />
Users credentials are taken from the secret store or from the configuration.toml file.  

## Proposed Design 
The proposal is another executable to be added inside docker-edgex-mongo, that will bring up `/purge` endpoint - responsible to purge all the data inside all the collections (thus, replacing the [clean_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/clean_mongo.js)) <br />
It will erase only the data and will keep the already specified structure (databases and collections definitions).

Prerequisites: mongo needs to be UP.
- get the usernames and passwords needed for all the databases (from secret store/ configuration.toml file)
- open a session toward each mongo database with the relevant db credentials 
- erase collections data

In the future, another endpoints for other database needs could be added like database migration, validation and others.

### EdgeX CLI
Currently, EdgeX CLI contains a command for purging all the data by calling multiple EdgeX microservices API endpoints.
The proposed docker-edgex-mongo endpoint will be accessible from all the clients, including `EdgeX CLI`<br />
A new command could be added inside EdgeX CLI, that will make a call to docker-edgex-mongo `/purge` endpoint.
This command will be much more efficient, because it will directly erase the data from the database, without making multiple services API calls.
At all, both commands should be used with caution, should be hidden, without auto-complete enabled and mostly used by developers or administrators.
  
### CI and BlackBox tests
The proposed endpoint could fit CI and black-box testing needs as well.

###Developers
The developers usually have the need to easily cleanup their databases to recover their work. <br />
To meet their need a new rule `purge_data` could be added in docker-edgex-mongo [Make](https://github.com/edgexfoundry/docker-edgex-mongo/blob/master/Makefile) file or a new bashscript could be created in `developers-script`
repo.
## Decision

Pending ...

## Consequences


## References


