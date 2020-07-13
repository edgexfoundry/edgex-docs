# Working in a Hybrid Environment

In some cases, as a [developer or contributor](../general/Definitions.md#contributordeveloper), you want to work on a particular micro service. Yet, you don't want to have to download all the source code, and then build and run for all the micro services. In this case, you can download and run the EdgeX Docker containers for all the micro services you need and run your single micro service (the one you are presumably working on) natively or from a developer tool of choice outside of a container. Within EdgeX, we call this a "hybrid" environment - where part of your EdgeX platform is running from a development environment, while other parts are running from the Dockerized containers. This page outlines how to do hybrid development.

As an example of this process, let's say you want to do coding work with/on the Virtual Device service. You want the rest of the
EdgeX environment up and running via Docker containers. How would you set up this hybrid environment? Let's take a look.

## Get and Run the EdgeX Docker Containers

1.  Per [Getting Started Users](./Ch-GettingStartedUsers.md), get
    Docker, Docker Compose setup and then pull the EdgeX docker
    containers.
2.  Since you plan to work with the virtual device service, you probably don't
    need or want to run all the micro services. You just need the few
    that the Virtual Device will be communicating with or that will be
    required to run a minimal EdgeX environment. So you will need to run
    Consul, Redis, Core Data, Core Metadata, Support Notifications, and Core Command. 

    Based on the instructions found in the [Getting Started with Docker](Ch-GettingStartedUsers.md#Get-Run-EdgeX-Foundry), locate and download the appropriate Docker Compose file for your development environment.  Next, issue the following commands to start this set of EdgeX containers - providing a minimal functioning EdgeX environment. 
    ``` bash
    docker-compose up -d consul
    docker-compose up -d redis
    docker-compose up -d notifications
    docker-compose up -d metadata
    docker-compose up -d data
    docker-compose up -d command

    ```

    !!! Note
        These notes assme you are working with the EdgeX Genva release.  Some versions of EdgeX may require other or additional containers to run.
    
3.  Run **docker-compose ps** to confirm that all the
containers have started.

## Get, Build and Run the Service
With the EdgeX containers running, you can now download, build and run natively (outside of a container) the service you want to work on.  In this example, the virtual device service is used to exemplify the steps necessary to get, build and run the native service with the EdgeX containerized services.  However, the practice could be applied to any service.

1.  Get the service code
    Per [Getting Started Go Developers](./Ch-GettingStartedGoDevelopers.md#Get-the-code), pull the micro service code you want to work on from GitHub. In
    this example, we assume you want to get the device-virtual-go.
    ``` bash
    git clone https://github.com/edgexfoundry/device-virtual-go.git
    ```
2.  Build the service code
    At this time, you can add or modify the code to make the service changes you need.  Once ready, you must compile and build the service into an executable.  Change folders to the cloned micro service directory and build the service.
    ```
    cd device-virtual-go/
    make build
    ```

    ![image](EdgeX_GettingStartedHybridBuild.png)

3.  Change the configuration
    Depending on the service you are working on, you may need to change the configuration of the service to point to and use the other services that are containerized (running in Docker).  In particular, if the service you are working on is not on the same host as the Docker Engine running the containerized services, you will likely need to change the configuration.
    Examine the configuration.toml file in the cmd/res folder of the device-virtual-go. Note that the Registry (located in the \[Registry\] section of the configuration) and all the "clients" (located in the \[clients\] section of the configuration file) suggest that the "Host" of these services is "localhost".  These and other host configuration elements need to change when the services are not running on the same host.  If you do have to change the configuration, save the configuration.toml file after making changes.

4.  Run the service code natively.  The executable created by the make command is usally found in the cmd folder of the service.
    ``` bash
    cd cmd
    ./device-virtual
    ```

    ![image](EdgeX_GettingStartedHybridRun.png)

5.  Check the results
    At this time, your virtual device micro service should be communicating with the other EdgeX micro services running in
    their Docker containers. Give the virtual device a few seconds or so to
    initialize itself and start sending data to Core Data. To check that it
    is working properly, open a browser and point your browser to Core Data
    to check that events are being deposited. You can do this by calling on
    the Core Data API that checks the count of events in Core Data
    http://[host].48080/api/v1/event/count.

    ![image](EdgeX_GettingStartedHybridResults.png)

!!! Note
    If you choose, you can also import the service into GoLand and then code and run the service from GoLand.  Follow the instructions in the [Getting Started - Go Developers ](Ch-GettingStartedGoDevelopers#edgex-foundry-in-goland) to learn how to import, build and run a service in GoLand.

    ![image](EdgeX_GettingStartedHybridGoLand.png)