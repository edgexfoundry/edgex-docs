# Native Build and Run on Linux on x86/x64

This build and run guide shows you how to get, compile/build, execute and test base EdgeX (including the core and supporting services, the configurable application service, eKuiper rules engine and a virtual device service) on Linux on an x86 or x86_64 hardware (i.e., on Intel/AMD architecture).  Specifically, this guide was done using [Ubuntu 20.04](https://releases.ubuntu.com/20.04/).  For the most part, the guide should assist in building and running EdgeX in almost any Linux distribution, but some instructions will vary based on the nuances of the underlying distribution.

## Environment

Building and running EdgeX on Linux natively will require you have:

- Relatively modern Linux OS (this guide was written using Ubuntu 20.04)
- sudo access
- access from the host machine to the Internet to be able to get tools and source code (e.g., to clone code from GitHub)
- x86/x64 hardware platform (multiple CPUs are not necessary, but performance will vary greatly depending on resources)
- sufficient memory to build and run EdgeX micro services (EdgeX suggests 1GB minimum.)
  - This is sufficient memory to run all the required software as well as build/run EdgeX services listed below
- sufficient disk space to pull the required tools, libraries, code, etc. to build and run EdgeX (EdgeX suggests 10GB minimum )
  - This is inclusive of space needed to download and setup all the required software/tools as well as EdgeX

## Required Software

The following software is assumed to already be installed and available on the platform.  Follow the referenced guides if you need to install or setup this software.

- Go Lang, version 1.17 or later as of the Kamakura release
  - See [Go Download and install guide for help](https://go.dev/doc/install)
  - How to check for existence and version on your machine
    ![image](GoLangCheck.png)
- GCC Build Essentials (for C++)
  - See [How to Install GCC on Ubuntu 20.04](https://linuxize.com/post/how-to-install-gcc-on-ubuntu-20-04/)
  - How to check for existence and version on your machine
    ![image](BuildEssentialCheck.png)
  - Your installation process may vary based on Linux version/distribution
- Consul, version 1.10 or later as of the Kamakura release
  - See [Open Source Consul for help](https://www.consul.io/)
  - How to check for existence and version on your machine
    ![image](ConsulCheck.png)
- Redis,version 6.2 or later as of the Kamakura release
  - See [How to install and configure Redis on Ubuntu 20.04](https://linuxize.com/post/how-to-install-and-configure-redis-on-ubuntu-20-04/)
  - How to check for existence and version on your machine
    ![image](RedisCheck.png)
  - Your installation process may vary based on Linux version/distribution
- ZeroMQ
  - See [this guide for a script to install ZMQ](https://gist.github.com/katopz/8b766a5cb0ca96c816658e9407e83d00)
  - How to check for existence and version on your machine
    ![image](ZeroMQCheck.png)
- Git
  - Git is already installed with Ubuntu 20.04
  - If not already provided with your OS, see [Install Git on Linux](https://www.atlassian.com/git/tutorials/install-git#linux)
  - How to check for existence and version on your machine
    ![image](GitCheck.png)

## Prepare your environment

In this guide, you will be building and running EdgeX in "non-secure" mode.  That is, you will be building and running the EdgeX platform without the security services and security configuration.  An environmental variable, `EDGEX_SECURITY_SECRET_STORE`,  is set to indicate whether the EdgeX services are expected to initialize and use the secure secret store.  By default, this variable defaults to `true`.  Prior to building and running EdgeX, set this environment variable to false.

``` Shell
   export EDGEX_SECURITY_SECRET_STORE=false 
```

This can be done in the terminals from which you build and run EdgeX or you can set it in your user's profile to make an environment persist across terminal sessions.  See [How to Set Environment Variables in Linux](https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-set-environment-variables-in-linux/) for assistance.

## Download EdgeX Source

In order to build and run EdgeX micro services, you will first need to get the source code for the platform.  Using git, clone the following EdgeX repositories with the following command:

!!! Tip
    You may wish to create a new folder and then issue these git commands from that folder so that all EdgeX code is neatly stored in an easy to find place.

``` Shell
    git clone https://github.com/edgexfoundry/edgex-go.git
    git clone https://github.com/edgexfoundry/device-virtual-go.git
    git clone https://github.com/edgexfoundry/app-service-configurable.git
    git clone https://github.com/lf-edge/ekuiper.git
    git clone https://github.com/edgexfoundry/edgex-ui-go.git
```

Note that a new folder, named for the repository, gets created containing source code with each of the git clones above.

!!! Warning
    The git clone operations above pull from the main branch of the EdgeX repositories.  This is the current working branch in EdgeX development.  See the [git clone documentation](https://git-scm.com/docs/git-clone) for how to clone a specific named release or branch.

## Build EdgeX Services

With the source code available, you can now build the EdgeX services, GUI, as well as eKuiper - the rules engine.  

### Build Core and Supporting Services

Most of the services are in the `edgex-go` folder.  This folder contains the code for the [core](../../microservices/core/Ch-CoreServices.md) and [supporting](../../microservices/support/Ch-SupportingServices.md) services.  A single command in this repository will build several of the services.

Enter the `edgex-go` folder and issue the `make build` command as shown below.
![image](BuildEdgeXGoServices.png)

!!! Warning
    Depending on the amount of memory your system has, building the services in `edgex-go` can take several minutes.

### Build the Virtual Device Service

The [virtual device service](../../microservices/device/virtual/Ch-VirtualDevice.md) simulates devices/sensors sending data to EdgeX as if it was a "thing".  This guide uses the virtual device service to exemplify how other devices services can be built and run.

Enter the `device-virtual-go` folder and issue the `make build` command as shown below.
![image](BuildDeviceVirtual.png)

### Build the Configurable Application Service

The [configurable application service](../../microservices/application/AppServiceConfigurable.md) helps prepare device/sensor data for enterprise or cloud systems.  It also prepares data for use by the rules engine - [eKuiper](../../microservices/support/eKuiper/Ch-eKuiper.md)

Enter the `app-service-configurable` folder and issue the `make build` command as shown below.
![image](BuildAppServiceConf.png)

### Build eKuiper

Sister Linux Foundation, LF Edge project - [eKuiper](https://www.lfedge.org/projects/ekuiper/) - is the reference implementation rules engine for EdgeX.

Enter the `ekuiper` folder and issue the 'make build_with_edgex` command as shown below.
![image](BuildeKuiper.png)

### Build the GUI

EdgeX provides a [graphical user interface](../tools/Ch-GUI.md) for exploring a single instance of the EdgeX platform.  The GUI makes it easier to work with EdgeX and see sample data coming from sensors.  It provides a good means to insure your EdgeX system is running properly.

Enter the `edgex-ui-go` folder and issue the `make build` command as shown below.
![image](BuildGUI.png)

## Run EdgeX

Provided everything built correctly and without issue, you can now start your EdgeX services one at a time.  First make sure Redis Server is running.  If not, start it.  If it is running, you can now start each of the EdgeX services **in order** as listed below.

### Start Consul

Start Consul Agent with the command below.

``` Shell
    nohup consul agent -ui -bootstrap -server -client 0.0.0.0 -data-dir=tmp/consul &
```

The `nohup` is used to execute the command and ignore all SIGHUP (hangup) signals.  The `&` says to execute the process in the background.  Both `nohup` and `&` will be used to run each of the services so that the same terminal can be used and the output will be directed to a local nohup.out file.

If Consul is running correctly, you should be able to reach the Consul UI through a browser at http://(host address):8500
![image](RunConsulUI.png)

### Start Core Metadata

Each of core and supporting EdgeX services are located in the `edgex-go/cmd` under a subfolder by the service name.  In this case, core-metadate is located in `edgex-go/cmd/core-metadata`.  Change directories to the service subfolder and then run the executable found in the subfolder with `-cp` and `-registry` command line options as shown below.

``` shell
    cd edgex-go/cmd/core-metadata/
    nohup ./core-metadata -cp=consul.http://localhost:8500 -registry &
```

The `-cp=consul.http://localhost:8500` command line parameter tells core-metadata to use Consul and where to find Consul running.  The `-registry` command line parameter tells core-metadata to use (and register with) the registry service.  Both of these command line parameters will be use when launching all EdgeX services.

### Start the other Core and Supporting Services

In a similar fashion, enter each of the other core and supporting service folders in `edgex-go/cmd` and launch the services.

```Shell
    cd ../core-data
    nohup ./core-data -cp=consul.http://localhost:8500 -registry &
    cd ../core-command
    nohup ./core-command -cp=consul.http://localhost:8500 -registry &
    cd ../support-notifications/
    nohup ./support-notifications -cp=consul.http://localhost:8500 -registry &
    cd ../support-scheduler/
    nohup ./support-scheduler -cp=consul.http://localhost:8500 -registry &
```

!!! Tip
    If you still have the Consul UI up, you should see each of the EdgeX core and supporting services listed as running in the Services tab.

    ![image](CoreSupportingServicesRunning.png)

### Start Configurable Application Service

The configurable application service is located in the root of `app-service-configurable` folder.

![image](LocationConfigAppService.png)

The configurable application service is started in a similar way as the other EdgeX services.  The configurable application service is going to be used to route data to the rules engine.  Therefore, an additional command line parameter (`confdir`) is added to its launch command to tell it where to find the configuration for rules engine work. 

```Shell
    nohup ./app-service-configurable -cp=consul.http://localhost:8500 -registry -confdir=./res/rules-engine &
```

### Start eKuiper

### Start the Virtual Device Service

### Start the GUI

!!! Note
    Some elements of the GUI will not work as you do not have all available EdgeX services running.  Notably, the System Management service and its executor are not running so the System view of the GUI will display an error.  The System Management service and its executor operate by checking on the other services memory, CPU, etc. via Docker Stats by default.  In this case, since you are not running Docker containers, the System Management service would not function. 

## Test EdgeX
