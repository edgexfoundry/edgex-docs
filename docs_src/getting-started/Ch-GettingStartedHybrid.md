# Working in a Hybrid Environment

In some cases, as a [developer or contributor](../general/Definitions.md#contributordeveloper), you want to work on a particular micro service. Yet, you don't want to have to download all the source code, and then build and run all the micro services. There is an alternative approach!  You can download and run the EdgeX Docker containers for all the micro services you need and run your single micro service (the one you are presumably working on) natively or from a developer tool of choice outside of a container. Within EdgeX, we call this a "hybrid" environment - where part of your EdgeX platform is running from a development environment, while other parts are running from Docker containers. This page outlines how to work in a hybrid development environment.

As an example of this process, let's say you want to do coding work with/on the Virtual Device service. You want the rest of the
EdgeX environment up and running via Docker containers. How would you set up this hybrid environment? Let's take a look.

## Get and Run the EdgeX Docker Containers

1.  If you haven't already, follow the [Getting Started using Docker](./Ch-GettingStartedDockerUsers.md) guide to set up your environment (Docker, Docker Compose, etc.) before continuing.
2.  Since we plan to work with the virtual device service in this example, you don't need or want to run the virtual device service. You will run all the other services via Docker Compose. 

    Based on the instructions found in the [Getting Started using Docker](Ch-GettingStartedDockerUsers.md#get-run-edgex-foundry), locate and download the appropriate Docker Compose file for your development environment.  Next, issue the following commands to start the EdgeX containers and then stop the virtual device service (which is the service you are working on in this example). 

    ``` bash
    docker-compose up -d 
    docker-compose stop device-virtual
    ```
    
    ![image](EdgeX_GettingStartedHybridRunContainers.png)
    *Run the EdgeX containers and then stop the service container that you are going to work on - in this case the virtual device service container.*

    !!! Note
        These notes assume you are working with the EdgeX Minnesota or later release.  It also assumes you have downloaded the appropriate Docker Compose file and have named it `docker-compose.yml` so you don't have to specify the file name each time you run a Docker Compose command.  Some versions of EdgeX may require other or additional containers to run.

    !!! Tip
        You can also use the EdgeX Compose Builder tool to create a custom Docker Compose file with just the services you want.  See the [Compose Builder documentation](./Ch-GettingStartedDockerUsers.md#generate-a-custom-docker-compose-file) on and checkout the [Compose Builder tool in GitHub](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder).
    
3.  Run the command below to confirm that all the containers have started and that the virtual device container is no longer running.
    ``` bash
    docker-compose ps
    ```

## Get, Build and Run the (non-Docker) Service

With the EdgeX containers running, you can now download, build and run natively (outside of a container) the service you want to work on.  In this example, the virtual device service is used to exemplify the steps necessary to get, build and run the native service with the EdgeX containerized services.  However, the practice could be applied to any service.

### Get the service code

Per [Getting Started Go Developers](./Ch-GettingStartedGoDevelopers.md#Get-the-code), pull the micro service code you want to work on from GitHub. In this example, we use the latest released tag for device-virtual-go as the micro service that is going to be worked on. The main branch is the development branch for the next release. The latest release tag should always be used so you are worked with the most recent stable code. The release tags can be found [here](https://github.com/edgexfoundry/device-virtual-go/tags). Release tags are those tags to do not have `-dev` in the name.

``` bash
git clone --branch <latest-release-tag> https://github.com/edgexfoundry/device-virtual-go.git
```

### Build the service code

At this time, you can add or modify the code to make the service changes you need.  Once ready, you must compile and build the service into an executable.  Change folders to the cloned micro service directory and build the service.

``` bash
cd device-virtual-go/
make build
```

![image](EdgeX_GettingStartedHybridBuild.png)
*Clone the service from Github, make your code changes and then build the service locally.*

### Run the service code natively.  

The executable created by the `make build` command is found in the cmd folder of the service.  Change folders to the location of the executable.  Set any environment variables needed depending on your EdgeX setup.  In this example, we did not start the security elements so we need to set `EDGEX_SECURITY_SECRET_STORE` to `false` in order to turn off security.   Finally, run the service right from a terminal.

``` bash
cd cmd
export EDGEX_SECURITY_SECRET_STORE=false
./device-virtual -cp -d -o
```

!!! note
    The `-cp` flag tells the service to use the Configuration Provider. This is required so that the service can pull the common configuration. The `-d` flag tells the service to run in developer mode (aka hybrid mode) so that any `Host` names in configuration for dependent services are automatically changed from their Docker network names to `localhost` allowing the service to find the dependent services. The `-o` flag tells the service to overwrite of configuration from local file into Config Provider (only need when service was previously run in Docker).

!!! edgey - "EdgeX 3.0"
    Common configuration is new in EdgeX 3.0. EdgeX services now have a reduced local configuration file that only contains the services' private configuration. All other configuration settings are now in the common configuration. See the [Service Configuration](../../microservices/configuration/CommonConfiguration) section for more details.

![image](EdgeX_GettingStartedHybridRun.png)
*Change folders to the service's cmd/ folder, set env vars, and then execute the service executable in the cmd folder.*

### Check the results

At this time, your virtual device micro service should be communicating with the other EdgeX micro services running in their Docker containers. Because Core Metadata callbacks do not work in the hybrid environment, the virtual device service will not receive the Add Device callbacks on the initial run after creating them in Core Metadata.  The simple work around for this issue is to stop (`Ctrl-c` from the terminal) and restart the virtual device service (again with `./device-virtual -cp -d` execution).

![image](EdgeX_GettingStartedHybridDeviceVirtualLog.png)
*The virtual device service log after stopping and restarting.*


Give the virtual device a few seconds or so to initialize itself and start sending data to Core Data. To check that it is working properly, open a browser and point your browser to Core Data
to check that events are being deposited. You can do this by calling on the Core Data API that checks the count of events in Core Data.

```
http://localhost:59880/api/{{api_version}}/event/count
```

![image](EdgeX_GettingStartedHybridResults.png)

*For this example, you can check that the virtual device service is sending data into Core Data by checking the event count.*

!!! Note
    If you choose, you can also import the service into GoLand and then code and run the service from GoLand.  Follow the instructions in the [Getting Started - Go Developers ](./Ch-GettingStartedGoDevelopers.md#edgex-foundry-in-goland) to learn how to import, build and run a service in GoLand.
