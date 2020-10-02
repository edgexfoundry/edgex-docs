# Definitions
The following glossary provides terms used in EdgeX Foundry.  The definition are based on how EdgeX and its community use the term versus any strict technical or industry definition.

## Actuate
To cause a machine or device to operate.  In EdgeX terms, to command a device or sensor under management of EdgeX to do something (example: stop a motor) or to reconfigure itself (example: set a thermostat's cooling point).

## Brownfield and Greenfield
Brownfield refers to older legacy equipment (nodes, devices, sensors) in an edge/IoT deployment, which typically uses older protocols.  Greenfield refers to, typically, new equipment with modern protocols.

## Containerized
EdgeX micro services and infrastructure (i.e. databases, registry, etc.) are built as executable programs, put into Docker images, and made available via Docker Hub (and Nexus repository for nightly builds).  A service (or infrastructure element) that is available in Docker Hub (or Nexus) is said to be containerized.  Docker images can be quickly downloaded and new Docker containers created from the images.

## Contributor/Developer
If you want to change, add to or at least build the existing EdgeX code base, then you are a "Developer". "Contributors" are developers that further wish to contribute their code back into the EdgeX open source effort.

## Created time stamp
The Created time stamp is the time the data was created in the database and is unchangeable. The Origin time stamp is the time the data is created on the device, device services, sensor, or object that collected the data before the data was sent to EdgeX Foundry and the database.

Usually, the Origin and Created time stamps are the same, or very close to being the same. On occasion the sensor may be a long way from the gateway or even in a different time zone, and the Origin and Created time stamps may be quite different.

If persistence is disable in core-data, the time stamp will default to 0.

## Device
In EdgeX parlance, "device" is used to refer to a sensor, actuator, or IoT "thing".  A sensor generally collects information from the physical world - like a temperature or vibration sensor.  Actuators are machines that can be told to do something.  Actuators move or otherwise control a mechanism or system - like a value on a pump.  While there may be some technical differences, for the purposes of EdgeX documentation, device will refer to a sensor, actuator or "thing".

## Edge Analytics
The terms edge or local analytics (the terms are used interchangeably and have the same meaning in this context) for the purposes of edge computing (and EdgeX), refers to an “analytics” service is that:
- Receives and interprets the EdgeX sensor data to some degree; some analytics services are more sophisticated and able to provide more insights than others
- Make determinations on what actions and actuations need to occur based on the insights it has achieved, thereby driving actuation requests to EdgeX associated devices or other services (like notifications)

The analytics service could be some simple logic built into an app service, a rules engine package, or an agent of some artificial intelligence/machine learning system.  From an EdgeX perspective, actionable intelligence generation is all the same.  From an EdgeX perspective, edge analytics = seeing the edge data and be able to make requests to act on what is seen.  While EdgeX provides a rules engine service as its reference implementation of local analytics, app services and its data preparation capability allow sensor data to be streamed to any analytics package.

Because of EdgeX’s micro service architecture and distributed nature, the analytics service would not necessarily have to run local to the devices / sensors.  In other words, it would not have to run at the edge.  App services could deliver the edge data to analytics living in the cloud.  However, in these scenarios, the insight intelligence would not be considered local or edge in context.  Because of latency concerns, data security and privacy needs, intermittent connectivity of edge systems, and other reasons, it is often vital for edge platforms to retain an analytic capability at the edge or local.

## Gateway
An IoT gateway is a compute platform at the farthest ends of an edge or IoT network.  It is the host or “box” to which physical sensors and devices connect and that is, in turn, connected to the networks (wired or wirelessly) of the information technology realm.

![image](./EdgeX_gateway.png)

IoT or edge gateways are compute platforms that connect “things” (sensors and devices) to IT networks and systems.

## Micro service
In a micro service architecture, each component has its own process.  This is in contrast to a monolithic architecture in which all components of the application run in the same process.

![image](./EdgeX_microservice_arch.png)

Benefits of micro service architectures include:
- Allow any one service to be replaced and upgraded more easily
- Allow services to be programmed using different programming languages and underlying technical solutions (use the best technology for each specific service)
    - Ex: services written in C can communicate and work with services written in Go
- This allows organizations building solutions to maximize available developer resources and some legacy code
- Allow services to be distributed across host compute platforms - allowing better utilization of available compute resources
- Allow for more scalable solutions by adding copies of services when needed

## Origin time stamp
The Origin time stamp is the time the data is created on the device, device services, sensor, or object that collected the data before the data is sent to EdgeX Foundry and the database. The Created time stamp is the time the data was created in the database.

Usually, the Origin and Created time stamps are the same or very close to the same. On occasion the sensor may be a long way from the gateway or even in a different time zone, and the Origin and Created time stamps may be quite different.

## Reference Implementation
Default and example implementation(s) offered by the EdgeX community.  Other implementations may be offered by 3rd parties or for specialization.

## Rules Engine
Rules engines are important to the IoT edge system.

A rules engine is a software system that is connected to a collection of data (either database or data stream). The rules engine examines various elements of the data and monitors the data, and then triggers some action based on the results of the monitoring of the data it. 

A rules engine is a collection of "If-Then" conditional statements. The "If" informs the rules engine what data to look at and what ranges or values of data must match in order to trigger the "Then" part of the statement, which then informs the rules engine what action to take or what external resource to call on, when the data is a match to the "If" statement. 

Most rules engines can be dynamically programmed meaning that new "If-Then" statements or rules, can be provided while the engine is running. The rules are often defined by some type of rule language with simple syntax to enable non-Developers to provide the new rules.

Rules engines are one of the simplest forms of "edge analytics" provided in IoT systems. Rules engines enable data picked up by IoT sensors to be monitored and acted upon (actuated). Typically, the actuation is accomplished on another IoT device or sensor. For example, a temperature sensor in an equipment enclosure may be monitored by a rules engine to detect when the temperature is getting too warm (or too cold) for safe or optimum operation of the equipment. The rules engine, upon detecting temperatures outside of the acceptable range, shuts off the equipment in the enclosure.

## Software Development Kit
In EdgeX, a software development kit (or SDK) is a library or module to be incorporated into a new micro service.  It provides a lot of the boilerplate code and scaffolding associated with the type of service being created.  The SDK allows the developer to focus on the details of the service functionality and not have to worry about the mundane tasks associated with EdgeX services.

## South and North Side
South Side: All IoT objects, within the physical realm, and the edge of
the network that communicates directly with those devices, sensors, 
actuators, and other IoT objects, and collects the data from them, is
known collectively as the "south side."

North Side: The cloud (or enterprise system) where data is collected, 
stored, aggregated, analyzed, and turned into information, and the part
of the network that communicates with the cloud, is referred to as the
"north side" of the network.

EdgeX enables data to be sent "north, " "south, " or laterally as
needed and as directed.

## "Snappy" / Ubuntu Core & Snaps
A Linux-based Operating System provided by Ubuntu - formally called [Ubuntu Core](https://ubuntu.com/core) but often referred to as "Snappy". The packages are called 'snaps' and the tool for using them 'snapd', and works for phone, cloud, internet of things, and desktop computers. The "Snap" packages are self-contained and have no dependency on external stores. "Snaps" can be used to create command line tools, background services, and desktop applications.

## User
If you want to get the EdgeX platform and run it (but do not intend to change or add to the existing code base now) then you are considered a "User".