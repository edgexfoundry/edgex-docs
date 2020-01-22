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
Data persistence can be provided by any of multiple implementations, namely **Redis** and **MongoDB** today in EdgeX.
Current all EdgeX Foundry micro-services work with one database only - Mongo or Redis, predefined in the docker-compose file. 
To assist mostly developers, it is useful to have a mechanism to clear the data, across all services at once.

## Proposed Design 
This could be accomplished by adding database `purge` functionality, in each persistent provider currently: `docker-edgex-mongo` and `edgex-redis` (still in implementation state).
This functionality will directly erase the data from the database, without making multiple services API calls.

In the future we could have "mixed database solution" - different micro-services could use different type of databases that best suit their need.
If such use case rise, we could add a wrapper endpoint in `system-management` micro-service that will encapsulate the `purge` functionality throughout all the different database providers available, and thus the client will not care what are the underling databases.

### MONGO
[docker-edgex-mongo](https://github.com/edgexfoundry/docker-edgex-mongo) has been developed to replace the old way of initializing mongo database (using [init_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/init_mongo.js)) and to introduce security features.  <br />
Currently, docker-edgex-mongo is single purpose application, because it is responsible only for `initializing` all the data inside mongo. <br />
It runs the mongo server, creates all the databases with the appropriate collections inside and create the relevant users.<br />
Users credentials are taken from the secret store or from the configuration.toml file.  

From Mongo point of view, the implementation of the proposed design, means another executable to be added inside `docker-edgex-mongo`, that for the time being will bring up only `/purge` endpoint - responsible to purge all the data inside all the collections (thus, replacing the [clean_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/clean_mongo.js)) <br />
It will erase only the data and will keep the already specified structure (databases and collections definitions).
The existing `Admin` user will be granted with `root` privileges. This means that this user will be able to read/write in all databases inside mongo

Prerequisites: mongo needs to be UP.

Steps for achieving the goal:
- get the usernames and passwords for the `admin` (from secret store/ configuration.toml file)
- open a session with using the `admin`.
- erase collections data throughout all databases

### REDIS
Unlike Mongo, Redis works in secure disabled environment. That is why Redis, does not need to work with credentials.
`Edgex-redis` (still in implementation state) will also bring-up `/purge` endpoint that will execute `FLUSHALL`. 

### Clients

#### CLI
Nowadays, EdgeX CLI contains a command for purging all the data by calling multiple EdgeX microservices API endpoints.

The proposed `purge` functionality will be accessible from all the clients, including `EdgeX CLI`<br />
A new command could be added inside EdgeX CLI, that will make a call to the appropriate `purge` endpoint provided by the underling database provider - `docker-edgex-mongo` or `edgex-redis`.
The knowledge of the current database provider will be taken from the configuration file similar to how all the other microservices know what is the underling database.
If "mixed database solution" is present (in the future), CLI will make call to the future `system-management` endpoint.

At all, both commands, the current existing purge command and the proposed new one should be used with caution, should be hidden, without auto-complete enabled and mostly used by developers or administrators.
  
#### CI and BlackBox tests
The proposed endpoints could fit CI and black-box testing needs as well.

#### Developers
The developers usually have the need to easily cleanup their databases to recover their work. <br />
They are free to use the CLI. In addition to meet their needs a new rule `purge_data` could be added in docker-edgex-mongo [Make](https://github.com/edgexfoundry/docker-edgex-mongo/blob/master/Makefile) file or a new bashscript could be created in `developers-script` that will make a call to the `purge` endpoint on their behalf. 

Because Redis is working only in none-secure environment, the developers could easily enter in redis-cli and execute FLUSHALL command. `>redis-cli flushall` . That is why, in case Redis is used, there is no needed to implement anything special.

## Decision

Pending ...

## Consequences
Unclear:  <b>What could be the consequences if the database is cleared while EdgeX is running? `Device-service` caches data ? What about the Application Services? Should we add more restrictions `when` this endpoint could be called? </b>

## References


