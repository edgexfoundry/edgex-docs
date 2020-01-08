###############
Getting Started
###############

To get started you need to obtain EdgeX Foundry either as a User or as a Developer/Contributor.  

**User**

If you simply want to obtain the EdgeX platform and run it (but do not intend to modify or add to the existing code base at this time) then you are considered a "User".  You will want to follow the :doc:`../Ch-GettingStartedUsers` guide.  The Getting Started Users guide will take you through the process of getting the latest release EdgeX Docker Containers from Docker Hub.  If you wish to get the latest EdgeX containers (those built from the current ongoing development efforts prior to release), then see :doc:'../Ch-GettingStartedUsersNexus'.  **WARNING** - containers used from Nexus are considered "work in progess".  There is no guarantee that these containers will function properly or function properly with other containers from the current release.

**Contributor/Developer**

If you want to modify, add to or at least build the existing EdgeX code base, then you are considered a "Developer".  "Contributors" are developers that further wish to contribute their code back into the EdgeX open source effort.  You will want to follow the :doc:`../Ch-GettingStartedDevelopers` guide.

**Hybrid**

See :doc:`../Ch-GettingStartedHybrid` if you are developing or working on a particular micro service, but want to run the other micro services via Docker Containers.  When working on something like an analytics service (as a developer or contributor) you may not wish to download, build and run all the EdgeX code - you only want to work with the code of your service.  Your new service may still need to communicate with other services while you test your new service.  Unless you want to get and build all the services, developers will often get and run the containers for the other EdgeX micro services and run only their service natvely in a development environment.  The EdgeX community refers to this as Hybrid development.

**Device Service Developer**

As a developer, if you intend to connect IoT objects (device, sensor or other "thing") that are not currently connected to EdgeX Foundry, you may also want to obtain the Device Service Software Development Kit (DS SDK) and create new device services.  The DS SDK creates all the scaffolding code for a new EdgeX Foundry device service; allowing you to focus on the details of interfacing with the device in its native protocol.  See :doc:`../Ch-GettingStartedSDK` for help on using the DS SDK to create a new device service.  Learn more about Device Services and the Device Service SDK at :doc:`../Ch-DeviceServices`.

**Application Service Developer**

As a developer, if you intend to get EdgeX sensor data to external systems (be that an enterprise application, on-prem server or Cloud platform like Azure IoT Hub, AWS IoT, Google Cloud IOT, etc.), you will likely want to obtain the Application Functions SDK (App Func SDK) and create new application services.  The App Func SDK creates all the scaffolding code for a new EdgeX Foundry application service; allowing you to focus on the details of data transformation, filtering, and otherwise prepare the sensor data for the external endpoint.  Learn more about Application Services and the Application Functions SDK at :doc:`../Ch-ApplServices`.

.. toctree::
   :maxdepth: 1

   Ch-GettingStartedUsers
   Ch-GettingStartedDevelopers
   Ch-GettingStartedSDK
   #TODO - Ch-GettingStartedAppFuncSDK
   Ch-GettingStartedHybrid
   Ch-GettingStartedUsersNexus
  
