# Is EdgeX Foundry Cloud Native?

This is a question we get in the EdgeX Community quite often; along with other related or extended questions like:

- Can EdgeX run in [Kubernetes](https://kubernetes.io/) (K8s)?
- Which of EdgeX services can and should I [cluster](https://www.vmware.com/topics/glossary/content/kubernetes-cluster.html)?
- Does EdgeX support [high availability (HA)](https://en.wikipedia.org/wiki/High_availability)?
- Can EdgeX run in a distributed environment?
- Does EdgeX abide by [12 factor app](https://12factor.net/) methodology?

As a simple (perhaps over simplified) answer to these questions, EdgeX was designed to run in/on minimal platforms ("edge platforms") with little compute, memory and network connectivity.  Cloud native applications are, for the most part, designed to run in resource rich enterprise / cloud environments.  Limited resources and other considerations greatly impact the design and operation of edge applications.

Before answering these questions in more detail, its important to understand the definition of cloud native systems.  Where did "cloud native" come from and what is its purpose?  How do all these other questions relate and what are people really asking?

## Defining Cloud Native

### Origins

The origins of cloud native computing are right there in the name.  Cloud native originated in the realm of **cloud** computing.  Cloud native communities like to say their approach was "born in the cloud."  Cloud native computing and architectures emerged from organizations learning how to build and run applications in the cloud.  Specifically, how to build and run applications that could scale (up and down) easily, remain functioning in the face of inevitable failures (resiliency), and could operate in the dynamic (or elastic) and distributed resource environments that exist in public, private or even hybrid clouds.

![image](CNCF-logo.png)

The origins of cloud native computing obviously come from the emergence of cloud technology, but many point specifically to 2015 and the creation of the Cloud Native Computing Foundation (launched by Google, IBM, Intel, VMWare and others with ties in the Cloud industry) as the event that started to galvenize cloud native concepts and steer the direction of Kubernetes (an important and typical ingredient in cloud native systems - see more below) used in cloud native applications.

### Defining

So the origins are in cloud computing, but what exactly is cloud native computing?  While debatable, most cloud native computing experts would agree that cloud native computing is about building and running applications in the cloud using methodologies, techniques and technologies that help applications be resilient, easy to manage, and easy to observe.  "Resilient, manageable, and observable" are the mantra of cloud native experts.  Why?  Because applications that are resilient, manageable and observable make it easier for developers to make "high impact" code changes, at frequent rates, and with predicable impacts and minimal work.  Simply put, the cloud native approach allows people to rapidly grow (iterate?) on an application and deploy it easily and with few or no outages.

### Ingredients
How is this accomplished? The list of technologies and techniques of cloud native applications include:

- containers (or containerized applications - as initially exemplified by Docker)
- micro services (and well defined service APIs)
- serverless functions
- immutable infrastructure (Never upgrade in place - only replace.  E.g. - never try to upgrade a server)
- Kubernetes (for deploying, orchestrating and observing/monitoring all those containers on cloud infrastructure)
- continuous integration / continuous delivery (with strong devops)
- an Agile methodology
- and of course, running it all on a cloud platform (public, private or hybrid)

Again, the list above is not official (and debatable on some of its points), but the product of the cloud native approach using these technologies create, say cloud native proponents, applications that exist in the cloud that are:

- more independent or loosely coupled based on services
- packaged up as self-contained and lightweight services (via containers)
- portable
- easily scaled in or out / up or down (based on demand)
- isolated from infrastructure

### Applicability at the Edge

You might be thinking - "Wow! with all that goodness, why shouldn't all software applications be manufactured using the cloud native approach?"  Indeed, many of the principles of cloud native computing are now applied to all sorts of software development.  cloud native computing has expanded beyond the cloud.  Additional methodologies (e.g. 12 factor apps), tools (e.g. Prometheus) and techniques (e.g., service discovery and service mesh mechanisms) have emerged to refine (some might say improve) the cloud native approach.  Most, if not all, of what is labelled as cloud native computing technology can and has been used in general software development and deployment environments that don't operate in the cloud.

That includes use in edge or IoT computing.

There are, however, important differences between the edge and cloud.  They are on opposite ends of the computing spectrum.  These natural differences require, in many cases, that edge / IoT applications be constructed and run a little different.

!!! Note
    The continuum of edge computing is vast.  One often needs to define "edge" before making too many generalizations.  Running MCUs and PLCs in a factory is at one end of the edge spectrum versus rather large and powerful ruggedized server in a retail store versus a rack of servers at the base of a cell phone tower at the other end of the spectrum - yet all these qualify as "edge computing".  In this light, as EdgeX Foundry was generally built for the more resource constrained, farther reaches of the edge (although it can be used in larger edge environments), this reference explores how cloud native computing applies under some of the lowest common denominator environments of the edge/IoT space. 

So while it would be great if cloud native computing could be directly and wholly applied to the edge and IoT space - and by association then EdgeX Foundry - the constraints of the edge / IoT environment often allow only some of the the cloud native computing approach (tools, technology, etc.) to be applied.  This reference attempts to explain where cloud native computing principals have been applied to EdgeX, and where (and why) some challenges exist.  It also identifies where future work and improvements in EdgeX (and the edge) and products from CNCF may help bring EdgeX more in line with cloud native computing.

### Edge Native

The EdgeX community likes to think of EdgeX as **"Edge Native"**.  Born at the edge and adhering to some well established needs of the edge and IoT environments.  Edge Native shares many of the principals of Cloud Native, but there are differences and one cannot (should not) blanketly try to apply cloud native to edge native realms just as the reverse (applying edge native to cloud native realms) would also be wrong.

![image](CN-EN.png)

## EdgeX and Cloud Native Computing

While EdgeX is not cloud native, it has adopted quite a bit of cloud native principals and technologies.  The lists below discuss where EdgeX does, does partially, and does not apply cloud native.

### Incorporated Cloud Native Ingredients In EdgeX

**Micro Services**

EdgeX has fully embraced micro services.  From the beginning of the project, micro services offered a means to provide an edge/IoT application platform based on loosely coupled capabilities with well defined APIs. A micro service architecture allows the adopter to pick and choose which services are important to their use case and drop the others (critical in a resource constrained environment).  It allows EdgeX services to be more easily improved upon and replaced (often by 3rd parties and commercially driven implementers) as better solutions emerge over time.  It allows services to be written in alternate programming languages or using technologies best suited to the job.  The benefit of micro services can be very beneficial where flexibility is a driving force as it is in cloud and edge computing.

**APIs**

Each EdgeX micro service has a well defined API set.  This API set is what allows replacement services to be created and inserted with ease.  It allows for applications on top of EdgeX to be more easily created.  Over the course of its existence, this API set has seen only one major revision (and most of that revision was based on the inclusion of standard communication elements such as correlation ids, pagination, and standard error messaging versus a change to the functional APIs).  This speaks to how well the APIs are performing in the face of EdgeX requirements.  Furthermore, the REST API definitions are even serving as the foundation for EdgeX service communication in other protocols (such as message oriented middleware).  This is not unique as cloud native computing systems are also starting to embrace the use of service communications in alternate protocols as well as REST.

**CI/CD**

Through the efforts of some very talented, experienced and dedicated devops community members, EdgeX has enjoyed world class continuous integration/continuos development (CI/CD) since day one of the project.  The EdgeX devops team has provided the project with automated builds, tests, and creation of project artifacts (like containers) that run with each pull request, nightly (for check of the days work), or on a regular schedule (such as performance checks monthly to ensure the platform remains within expected parameters as it is developed).  As shown in cloud native environments, well developed CI/CD pipelines make sure EdgeX is able to "make 'high impact' code changes, at frequent rates, and with predicable impacts and minimal work."


### Sometimes Incorporated Cloud Native Ingredients in EdgeX
The following elements of cloud native are often, but not always applied in EdgeX.

**Containers**

EdgeX supports (even embraces) containers, but does not require their use.  The EdgeX community produces Docker containers with each release - along with Docker Compose and Helm Charts for orchestration and deployment assistance.  Containers provide a convenient mechanism to package up a micro service with all of its dependencies, configuration, etc.  They are a convenient software unit that makes deploying, orchestrating and monitoring the services of an application easier.  However, there are environments where EdgeX runs that do not support container (or other containerized) runtimes.  Resource constraints (memory, storage, CPU, etc.), environmental situations (such as hardware architecture or OS), legacy infrastructure (old hardware or OS) and security constraints are just some of the reasons why EdgeX supports but does not dictate the use of containers.  Further, and perhaps most importantly, EdgeX often provides the middleware between operational technology (OT) - like physical equipment and sensors - and information technology (IT).  In the world of OT, there are physical connections and hardware specific touch points that need to be accommodated that make using a container in that instance very difficult.  Its not uncommon to see EdgeX adopters apply a hybrid approach whereby some of its services are containerized while other services are running "bare metal" or outside of any containerization runtime.

**Agile**

EdgeX has not adopted the [Agile Manifesto](https://agilemanifesto.org/), but the project does operate on Agile principals.  The community formally releases twice a year, but development of the product is ongoing constantly and any change (new feature, bug fix, refactor, etc.) is tested and integrated into the product continuously and immediately (through the CI/CD process mentioned above).  Formal releases are more stakes in the ground with regard to higher-level stability and agreed upon timelines for significant features.  The community has adopted a philosophy of "crawl, walk, run" to grow new features that support a requirements base - but with an understanding (even an expectation) that requirements will change and/or be more fully understood as the feature evolves and gets used.  While face-to-face meetings between community members are difficult given the global nature of an open source project, regular and frequent communications between the community developers/architects in and about the code is favored above lots of formal and comprehensive document exchange.  Developers are free to use the tools and processes that suit them best so long as the resulting code fulfils requirements and satisfies the CI/CD process.

**Distributed**

EdgeX is a micro service architecture.  Services communicate with each other via REST or message bus and that communication can occur across nodes (aka machines, hosts, etc.).  Services have even been built to wait and continue to attempt to communicate with a dependent service - allowing for some resiliency.  As such, EdgeX is, at its core, distributable. It was designed such that the services could operate largely independently and on top of whatever limited resources are available at the edge.  As an example deployment, an EdgeX device service could run on a Raspberry Pi or smaller compute platform that is directly connected by GPIO to a physical sensor, while the core services are run on an edge gateway, and the application and analytic services (rules engine) run on an edge service.  This would allow each service to maximize the available resources available to the solution.  Having said that, there are some complexities around real world distributed solutions that adopters would still need to solve depending on their use case and environment.  For example, while services can communicate across a distributed set of nodes, the communications between EdgeX services are not secure by default (as would be provided via something like a cloud native service mesh).  Adopters would need to provide for their own means to secure all traffic between services in most production environments.  Service discovery is not fully implemented.  EdgeX services do register with a service registry (Consul) but the services do not use that registry to locate other services.  If a service changed location, other services would need to have their configuration changed in order to know and use the service at its new location.  Finally, latency is a real concern in edge systems.  In addition to service to service communications, most services use stores of information (Redis for data, Vault for secrets, Consul for configuration) which could also be distributed.  These are referred to as backing services in cloud native terminology.  Even if the communications were secure, if these stores or other services are all distributed, then the additional latency to constantly communicate with services and stores may not be conducive to the edge use case it supports.  Each "hop" on a network of distributed services costs and that cost adds up when building solutions that operate and manage physical edge capability.

### Cloud Native Ingredients Not In EdgeX (and why)

**Kubernetes**

EdgeX provides example Helm Charts to assist adopters that want to run EdgeX in a Kubernetes environment.  However, EdgeX was not designed to fully operate in a multi-cluster environment and take advantage of a full K8s environment.  Our example Helm Charts, for example, allow a single instance of each EdgeX service to be deployed/orchestrated and monitored, but it would not allow K8s to fully manage and scale EdgeX services.  Why?  First and foremost Kubernetes is large compared to the resource constraints of some edge platforms.  While smaller Kubernetes environments are being developed for the edge (see *Futures* below), a whole host of challenges such as resource constraints, environment, infrastructure, etc. (as mentioned under *Containers* above) may not allow K8s to operate at the edge.  Kubernetes is, for the most part, about the ability to load balance, distribute traffic, and scale (up or down) workloads so that an application remains stable.  But on an edge platform, where would Kubernetes find the resources to balance and distribute and scale?  Because edge nodes are static and often times physically connected to the sensors they collect data from, there is not the means to grow and/or shift the workloads.  Portions of EdgeX might be able to scale up or down (those not physically tied to an edge sensor), but the platform as a whole is often rooted to the physical world it is connected to.

There are benefits (and challenges) to the use of Kubernetes that must be considered - whether used at the edge or in the enterprise..

*Some of the Benefits of Kubernetes*
- It provides a "central pane of glass" for placing workloads at the edge, monitoring them, and being able to easily upgrade them, more easily than a native, or Docker-based deployment.
- It allows people to more easily deploy workloads that span from the cloud to the edge by using familiar tools that allow users to place their workloads in a more appropriate place.
- Kubernetes is often choosen over Docker alone for container orchestration, with lots of commercially supported Kubernetes distributions for doing so.
- Despite the fact that edge resources are not elastic, Kubernetes can make better scheduling decisions in a complex edge environment, where computational accelerators may be available on some nodes and not others, and Kubernetes can help place those workloads where they will run most efficiently.

*Some of the Challenges of Using Kubernetes at the Edge*
- Edge resources are not elastic
- Some devices are physically connected to nodes using non-routable or non-Internet protocols, which reduces the value of the Kubernetes scheduler
- Storage is a sticking point - unless there is enough infrastructure at the edge to make storage highly available, separation of the storage from the workload mathematically reduces availability (i.e: 0.9 x 0.9 = 0.81 !)
- Available network bandwidth and latency can be a concern: a Kubernetes cluster generates a lot of background network and CPU activity.

**Serverless Functions**

EdgeX is not built on a serverless execution model.  Unlike the compute and infrastructure resources of the cloud (which can almost be thought of as infinitely available and scaled up or down as needed), edge compute resources and infrastructure are not scaled up or down based on demand.  An edge gateway, running on a light pole of a smart city for example, is not dynamic.  The gateway must be provisioned based on the expected highest demand of that platform.  The workload on the edge gateway must operate within those resource constraints.  EdgeX is designed to operate in some of the smaller of the static, resource constrained environments.

**Cloud**

Interestingly, we have been asked it EdgeX can run in the cloud.  Indeed, some services (such as application services or analytics packages like the rules engine) could run in the cloud (most of the services are platform agnostic), but EdgeX was designed to serve as the middleware between the edge and the cloud.  At the lowest level - EdgeX services are meant to connect the physical edge (IoT senors and devices of the OT world) to IT worlds.  EdgeX connects things that don't always speak TCP/IP based IT protocols.  EdgeX is meant to explore data at the edge in order to reduce latency of communication (making decisions closer to where the decision is turned into action) with the physical edge and reduce the amount of data that needs to be back-hauled to the world of IT (reducing the transportation and storage of unimportant edge data).  Even if physical sensors or devices are able to connect and talk to the cloud directly (perhaps because they have Wifi or 5G capability allowing them to connect via TCP/IP), the latency needs and cost to transport all the data directly to the cloud is typically prohibitive.

!!! Note
    There are some edge use case where a sensor-to-cloud architecture is warranted.  Where the sensor speaks well known IT protocols (TCP/IP REST, MQTT, etc.), the edge data collection rates are small, and there is no need to make quick decisions at the edge, a simple sensor to cloud architecture makes sense and would likely negate the need for EdgeX in that situation.

### Other Cloud Native Aspects
Here are some  other aspects or thoughts associated to the cloud native approach (directly or by loose association) and how they apply to EdgeX. 

**OS is separate**

As highly abstracted, containerized applications, cloud native apps do not have a dependency on any specific operating system or individual machine.  EdgeX is, for the most part, platform agnostic and able to run on any hardware, OS or connect to any type of sensor or cloud system (whether using EdgeX containers or running on bare metal).  However, there are some sensors/devices that require OS or hardware specific drivers or protocol support.  These specific services (typically device services) are OS dependent.

**High Availability**

While not strictly a cloud native principal, cloud native container apps are typically said to provide high availability (HA) - avoiding downtime (scheduled or unscheduled), often by taking advantage of cloud native infrastructure like Kubernetes to keep multiple instances of a service running when HA is paramount.  EdgeX does not offer HA out of the box.  Services are built to be resilient (for example, recovering from anticipated errors or waiting for dependent services to come up or return when they are not detected), but they are not guaranteed to be HA.  When EdgeX services are run in some environments the environment may detect service issues and launch a new instance of the service to prevent downtime, but these are features of the underlying runtime environments and not of EdgeX services directly.  HA often requires a certain amount of redundancy; that is keeping multiple instances of a service running (or at the ready) and using something like Kubernetes to route traffic appropriately given the condition of a service.  EdgeX does not have this infrastructure built in, and even if it did, it would have difficulty since some services are again tied to physical senors/devices.  If a device service connected to a Modbus device, for example, was to go down, then a backup/redundant service would be of little use without re-provisioning the sensor or device to the backup device service.  In order to provide true HA uptime with an edge solution that includes EdgeX, one would need to scale out not up.  That is, one would need to setup redundant hardware (sensors, gateway, etc.) with the edge application (EdgeX in this instance) connected to its copy of the sensors and devices and each transmitting back to the IT enterprise such that the enterprise could compare and detect when one of the copies was likely having issues.

Would EdgeX ever explore buiding more HA capability into its services (or even some of its services)?  This is unlikely in the near term for the following reasons:

- The lack of clear use cases where adopters are demanding redundancy of capability all the way down to sensors
- the lack of clear use cases where the devices are active components in the system and the adopter is worried about missing data due to inability to capture and process it
- It is not cost-effective to manually code HA; the HA requirement would necessarily require building on a compute infrastructure like Kubernetes that is designed for HA, and eschewing support for native processes, and Docker that weren't designed HA.
- From a control perspective, there are challenges in having multiple components in the system the have the ability to make decisions (what if the multiple components make opposite and conflicting decisions)?

**Benefitting from Elastic Infrastructure**

Cloud native applications take advantage of shared infrastructure (hardware, software, etc.) provided by the cloud platform in an "elastic manner" - that is expanding or shrinking its use of infrastructure based on need (and not really availability which can be considered near infinite).  As previously mentioned, edge platforms rarely, if ever, provide this type of infrastructure.  Therefore, EdgeX is not built to benefit from it.  If an EdgeX service was to begin to receive more and more hits on its APIs, the service would eventually fail.  There is not EdgeX provided capability to scale out additional copies of the service.

**12 factor app**

EdgeX and its services are not [12 factor apps](https://12factor.net/).  EdgeX does try to abide by many of the twelve factors (one codebase, declared and isolated dependencies, external config, isolated and configurable backing services, separate build, release and run stages, etc.).  But some of the 12 factors, such as concurrency (scale out via the process model), are not possible with each EdgeX service as already mentioned above.

**Observable**

Perhaps one of the greatest contributions of the CNCF community to cloud native computing is providing all sorts of tools and technologies to observe and analyze cloud native applications in the cloud.  Tools like [Prometheus](https://prometheus.io/) make monitoring cloud native containers and their resource utilization a breeze.  EdgeX does not come with native observability capabilities.  When using EdgeX containers tools like Prometheus for observability and analytics can be used to monitor EdgeX services.  Likewise, on some platforms and OS, there are ingredients (like Linux process status or system monitor) that can be used to help facilitate some level of monitoring.  But these are not provided by EdgeX, usually require additional work by an adopter, and may not provide the level of inspection detail required.  EdgeX is, with the Kamakura release, starting to provide more system level data (versus sensor data), metrics and events via message bus that an adopter can subscribe to in order to do more observing/analyzing of the EdgeX services.  This, however is raw data, to which some additional tooling will be required to provide either human or machine monitoring of the data on top to make sense of it.

## The Future of Cloud Native and EdgeX
As cloud native computing technology and principals expands to more levels of our software realms and as the edge begins to become more indistinguishable from any other part of our computing network, it is inevitable that EdgeX will become more cloud native like.  Or perhaps put more precisely, cloud native and edge native are tending toward each other.  Edge computing environments are becoming less resource constrained in many places.  The CNCF is looking to bring cloud native technology and tools (like Kubernetes) to the edge.  Additionally, there are places where EdgeX improvements can help to bridge the cloud native | edge native divide. 

**Kubernetes Support**

As lighter weight Kubernetes infrastructure becomes available (e.g. K3s, KubeEdge, Minikube, etc. - see a [comparison](https://www.itprotoday.com/cloud-computing-and-edge-computing/lightweight-kubernetes-showdown-minikube-vs-k3s-vs-microk8s) for context) and are improved upon, and/or as more edge computing environments get more resources, one of the chief cloud native technologies - that is Kubernetes - or its close cousin will emerge to better facilitate deployment, orchestration, and monitoring (observability) of container based workloads at the edge.  EdgeX must be prepared to support and embrace it as it has containers - yet still recognize that the lowest common denominator of edge platforms may only support "bare metal" (only OS and not hypervisor or container infrastructure) type deployments for the foreseeable future.

**Better Use of the Service Registry**

EdgeX services can and should use the service registry to locate dependent services.  This will allow services to be more easily distributed and even allow for use of load balancing and redundant services in some cases.

**Secure Service-to-Service Communications**

Where warranted, the inclusion of secure communication between services and potentially the inclusion of an optional service mesh will allow for more easily distributed services.
