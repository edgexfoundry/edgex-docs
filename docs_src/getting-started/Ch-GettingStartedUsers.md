# Getting Started with Docker

## Introduction

These instructions are for Users to get and run EdgeX Foundry.
(Developers should read:
[Getting Started Developers](./Ch-GettingStartedDevelopers.md))

EdgeX is a collection of more than a dozen micro services that
are deployed to provide a minimal edge platform capability. You can download EdgeX 
micro service source code and build your own micro services.  However, if you do not have a need to change or add to EdgeX, then you do not need to download source code.

Instead, Users run EdgeX micro service Docker containers. The EdgeX community builds and creates Docker container images with each release.

## Get & Run EdgeX Foundry

### Install Docker & Docker Compose

To run Dockerized EdgeX, you need to install Docker. See
<https://docs.docker.com/install/> to learn how to install
Docker. If you are new to Docker, the same web site provides you
educational information. The following short video is also very
informative <https://www.youtube.com/watch?time_continue=3&v=VhabrYF1nms>

Use Docker Compose to orchestrate the fetch (or pull), install,
and start the EdgeX micro service containers.  Also use Docker Compose to stop the micro service containers. See: <https://docs.docker.com/compose/> to learn more about Docker
Compose.

You do not need to be an expert with Docker (or Docker Compose) to get and run EdgeX. This guide provides the steps to get EdgeX running in your environment. Some knowledge of Docker and Docker Compose are nice to have, but not required. Basic Docker and Docker Compose commands provided here enable you to run, update, and diagnose issues within EdgeX.

### Select a EdgeX Foundry Compose File

After installing Docker and Docker Compose, you need a EdgeX Docker Compose file.  EdgeX Foundry has over a dozen micro services, each deployed in its own Docker container.  This file is a manifest of all the EdgeX Foundry micro services to run.  The Docker Compose file provides details about how to run each of the services.  Specifically, a Docker Compose file is a manifest file, which lists:

- The Docker container images that should be downloaded,
- The order in which the containers should be started,
- The parameters (such as ports) under which the containers should be run

The EdgeX development team provides Docker Compose files for each release.  Visit the project [GitHub](https://github.com/edgexfoundry/developer-scripts/tree/master/releases)  and locate the EdgeX Docker Compose file for the version of EdgeX you want to run.

![image](EdgeX_GettingStartedReleaseFolders.png)
*The EdgeX Developer Scripts repository contains a folder for each release.  In the folder, find the Docker Compose files for each release.*

!!! Note
    At the GitHub location specified above there is a folder for each EdgeX release.  The nightly-build folder contains Docker Compose files that use artifacts created from the latest code submitted by contributors.  Most end users should avoid using these Docker Compose files.  They are work-in-progress.  Users should use the Docker Compose files for the latest version of EdgeX. 

In each folder, you will find several Docker Compose files (all with a .yml extension).  The name of the file will suggest the type of EdgeX instance the Compose file will help setup.  The table below provides a list of the Docker Compose filenames for the latest release (Geneva).   Find the Docker Compose file that matches:

- your hardware (x86 or ARM)
- the database you want to use (Mongo or Redis)
- your desire to have security services on or off

|filename|Docker Compose contents|
|---|---|
|docker-compose-geneva-mongo-arm64.yml |Specifies ARM 64 containers, uses Mongo database for persistence, and includes security services|
|docker-compose-geneva-mongo-no-secty-arm64.yml|Specifies x86 containers, uses Mongo database for persistence, but does not include security services|
|docker-compose-geneva-mongo-no-secty.yml| Specifies x86 containers, uses Mongo database for persistence, but does not include security services|
|docker-compose-geneva-mongo.yml|Specifies x86 containers, uses Mongo database for persistence, and includes security services|
|docker-compose-geneva-redis-arm64.yml|Specifies x86 containers, uses Redis database for persistence, and includes security services|
|docker-compose-geneva-redis-no-secty-arm64.yml|Specifies ARM 64 containers, uses Redis database for persistence, but does not include security services|
|docker-compose-geneva-redis-no-secty.yml|Specifies x86 containers, uses Redis database for persistence, but does not include security services|
|docker-compose-geneva-redis.yml|Specifies x86 containers, uses Redis database for persistence, and includes security services|
|docker-compose-geneva-ui-arm64.|Specifies the EdgeX user interface extension to be used with the ARM 64 EdgeX platform|
|docker-compose-geneva-ui.yml|Specifies the EdgeX user interface extension to be used with the x86 EdgeX platform|
|docker-compose-portainer.yml|Specifies the Portainer user interface extension (to be used with the x86 or ARM EdgeX platform)|

!!! Info
    Unsure which Docker Compose file to use?  The EdgeX community recommends you use the Reds, no security Docker Compose file for your architecture to start.  As you learn about EdgeX, you can incorporate security elements.  The Mongo database is being archived with the next release. 

### Download a EdgeX Foundry Compose File
Once you have selected the EdgeX Compose file you want to use, download it using your favorite tool.  The examples below uses *wget* to fetch Docker Compose for the Geneva release, no security, Redis database.

=== "x86"
    ```
    wget https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/geneva/compose-files/docker-compose-geneva-redis-no-secty.yml -O docker-compose.yml
    ```
=== "ARM"
    ```
    wget https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/geneva/compose-files/docker-compose-geneva-mongo-no-secty-arm64.yml -O docker-compose.yml
    ```

!!! Note
    The commands above fetch the Docker Compose to a file named 'docker-compose.yml' in the current directory.  Docker Compose commands look for a file named 'docker-compose.yml' by default.  You can use an alternate file name but then must specify that file name when issuing Docker Compose commands.  See Compose [reference documentation](https://docs.docker.com/compose/reference/overview/) for help.  

### Run EdgeX Foundry

Now that you have the EdgeX Docker Compose file, you are ready
to run EdgeX. Follow these steps to get the container images and
start EdgeX!

In a command terminal, change directories to the location of your  docker-compose.yml.  Run the following command in the terminal to pull (fetch) and then start the EdgeX containers.

``` bash
docker-compose up -d
```

!!! Info
    If you wish, you can fetch the images first and then run them.  This allows you to make sure the EdgeX images you need are all available before trying to run.

    ``` bash
    docker-compose pull
    docker-compose up -d
    ```

!!! Note
    The -d option indicates you want the Docker Compose to run the EdgeX containers in detached mode - that is to run the containers in the background. Without -d, the containers will all start in the terminal and to use the terminal further you have to stop the containers.

### Verify EdgeX Foundry Running 

In the same terminal, run the process status command shown below to confirm that all the
containers downloaded and started.

``` bash
docker-compose ps
```

![image](EdgeX_GettingStartedUsrActiveContainers.png)
*If all EdgeX containers pulled and started correctly and without error, you should see a process status (ps) that looks similar to the image above.*

## Checking the Status of EdgeX Foundry
In addition to the process status of the EdgeX containers, there are a number of other tools to check on the healt and status of your EdgeX instance.

### EdgeX Foundry Container Logs

Use the command below to see log of any service.

``` bash
# see the logs of a service
docker-compose logs -f [compose-service-name]
# example - core data
docker-compose logs -f data
```

See [EdgeX Container Names](./quick-start/index.md#REFERENCE-EdgeX-Container-Names) for a list of the EdgeX Docker Compose service names.

![image](EdgeX_GettingStartedUsrLogs.png)
*A check of an EdgeX service log usually indicates if the service is running normally or has errors.* 

When you are done reviewing the content of the log, select **Control-c**
to stop the output to your terminal.

### Ping Check

Each EdgeX micro service has a built-in respond to a "ping" HTTP request. In networking environments, use a [ping request](https://techterms.com/definition/ping) to check the reach-ability of a network resource.  EdgeX uses the same concept to check the availability or reach-ability of a micro service. After the EdgeX micro service containers are running, you can "ping" any one of the micro services to check that it is running. Open a browser or HTTP REST client tool and use the service's ping address (outlined below) to check that is available.

```
http://localhost:[port]/api/v1/ping
```

See [EdgeX Device Service Ports](./quick-start/index.md#REFERENCE-Default-Service-Ports) for a list of the EdgeX default service ports.

![image](EdgeX_GettingStartedUsrPing.png)
*"Pinging" an EdgeX micro service allows you to check on its availability.  If the service does not respond to ping, the service is down or having issues.*

### Consul Registry Check

EdgeX uses the open source [Consul](https://www.consul.io/) project as its registry
service. All EdgeX micro services are expected to register with Consul as they start. Going to Consul's dashboard UI enables you to see which services are up. Find the Consul UI at
<http://localhost:8500/ui>.

![image](EdgeX_GettingStartedUsrConsul.png)
