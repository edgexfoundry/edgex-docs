# Developers Script - Clearing and Tagging

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

`Developer Script` repository contains helper scripts used by the EdgeX developers in their everyday work, docker-compose files for all the releases, and scripts for gathering project metrics. <br />
This repository have only one branch - `master`. 
While docker-compose files reside in different directories named appropriately for every specific release, this is not the case with the scripts in the main directory.
It is supposed that these scripts are ready to work with the latest version of the project, that could not be helpful for developers troubleshooting older versions. 
Actually, significant part of the scripts are currently outdated and not applicable even with the latest version. <br />
Here it comes the need of tagging `developers-script` repository to coincide with core services releases as well their theirs cleaning up and update.

## Proposed Design 

### Force using annotated tags

By using `annotated tags` git history will be marked with the time core service are released (usually this happens two time in the year).
Developers will have the knowledge which specific commit to use for specific EdgeX version/release. 
This will make the troubleshooting possible for both - the older and the current versions of the project.
The tagging procedure is going to start from now on, without adding older tags.
The tags will be automatically added by the CI in format `ReleaseCodeName` - examples: 'edinburgh', 'fuji', 'geneva'   


### Clearing Up and Update the scripts
Some of the scripts need to be updated in order to work with the latest version, other are not relevant at all and need to be removed.

##### Current available scripts 
```
MODULES*
clean_shell.bat
mongoshell.bat
init_shell.bat
startdb-no-auth.bat
startdb.bat
clean_mongo.js
init_mongo.js
linux_setup.sh*
mongoAdminOperStateUpdate.js
run-it.sh*
reset-dockers.sh*
prepare-environment.sh*
create-containers.sh*
update-packages.sh*
```

##### Proposed changes per script 
* [MODULES](https://github.com/edgexfoundry/developer-scripts/blob/master/MODULES) - **to be Updated** <br /> 
Still contains java bases modules. These needs to be replace with the latest go applications

* [mongoshell.bat](https://github.com/edgexfoundry/developer-scripts/blob/master/mongoshell.bat), 
    [init_shell.bat](https://github.com/edgexfoundry/developer-scripts/blob/master/init_shell.bat),
    [startdb-no-auth.bat](https://github.com/edgexfoundry/developer-scripts/blob/master/startdb-no-auth.bat),
    [startdb.bat](https://github.com/edgexfoundry/developer-scripts/blob/master/startdb.bat),
    [init_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/init_mongo.js),
    [linux_setup.sh](https://github.com/edgexfoundry/developer-scripts/blob/master/linux_setup.sh) - **to be Removed**. <br /> 
 All these scripts set up mongo database. Instead, go application [docker-edgex-mongo](https://github.com/edgexfoundry/docker-edgex-mongo) is supposed to be used.
* [clean_mongo.js](https://github.com/edgexfoundry/developer-scripts/blob/master/clean_mongo.js)  - **to be Removed** <br />
These file should be removed once a second executable is added in [docker-edgex-mongo](https://github.com/edgexfoundry/docker-edgex-mongo). Currently `docker-edgex-mongo` is single purpose application responsible for initializing mongo database (setting up users/passwords/privileges and creates databases and collections). In addition, executable for `purging` the entire database need to be added. It is supposed to work in both security enabled/disabled environments.
It could be used by Edgex CLI for purge the entire database (without the need to have all the microservices up and running).

* mongoAdminOperStateUpdate.js - **to be Removed** <br />
The script is not relevant anymore

* [prepare-environment.sh](https://github.com/edgexfoundry/developer-scripts/blob/master/prepare-environment.sh) -  **to be Modified** <br />
This script clone/update all or set of modules (based on `MODULES`) directly from `https://github.com/edgexfoundry`. 
    - add ability to clone both - main repository or developers forks. Usually developers work with `fork branches`. They do not modify the real repo by itself. 
    - Rename the script to ``get_modules.sh``

* [reset-dockers.sh](https://github.com/edgexfoundry/developer-scripts/blob/master/reset-dockers.sh) - **To be Optimized** <br />
Removes all containers and images from working environment. Useful for development, when reset everything from scratch is needed. 
    - Add optional parameter to specify compose file different from the default one.
    - If docker file does not exists in the current directory - script should exit with error 
    - Clean the volumes as well
    - make the script more efficient by using other commands

* [run-it.sh](https://github.com/edgexfoundry/developer-scripts/blob/master/run-it.sh) - **to be Removed**. 
    - instead of using/maintaining this script the suggestion id to use: `docker-compose -f docker-compose-file-name.yml up -d`.

* [update-packages.sh](https://github.com/edgexfoundry/developer-scripts/blob/master/update-packages.sh) -  **to be Removed** <br />
It pulls all the `MODULES` that exists in the working directory (shorter version of 'prepare-environment.sh')  
    - Because this script does not make anything different than `prepare-environment.sh`,  the suggestion is to be Removed. 

## Decision

Pending ...

## Consequences

When scripts responsible the mongo database initialization/cleaning are removed the documentation should be updated appropriately. [edgex-docs/getting-started/Ch-GettingStartedGoDevelopers.rst](https://github.com/edgexfoundry/edgex-docs/blob/master/getting-started/Ch-GettingStartedGoDevelopers.rst)


## References


