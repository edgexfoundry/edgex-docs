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
Edgex-Mongo has been developed in order to replace the old way of initializing mongo database (using [init_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/init_mongo.js)) and to introduce security features.  <br />
Currently, edgex-mongo is single purpose application, because it is responsible only for `initializing` all the data inside mongo. <br />
It runs the mongo server, creates all the databases with the appropriate collections inside and create the relevant users.
Users credentials are taken from the secret store or from configuration.toml file.   <br />
The proposal is to add another executable inside edgex-mongo, responsible for `clearing-up` all the data in the mongo databases, thus replacing the [clean_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/clean_mongo.js) <br />
The use-case of this executable is to be used internally - by developers only. It should be able to work in both security enabled and disabled environments. 


## Proposed Design 
The proposal is to add another executable in `edgex-mongo` responsible for clearing-up all the data in mongo databases, without exporting new endpoint accessible from all the clients (including Edgex CLI).
Currently EdgeX CLI have a command for purging all the data, but it requires EdgeX microservices to be up and running - my proposal is this to stay as it is now

Edgex-mongo clearance is supposed to be used by developers only.

Prerequisites: mongo needs to be UP.
- get the usernames and passwords needed for all the databases (from secret store/ configuration.toml file)
- remove the data from all databases collections. 

## Decision

Pending ...

## Consequences

This executable could be used from CI or black-box testing as well


## References


