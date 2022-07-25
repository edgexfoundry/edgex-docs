## Extending Device Data
This UCR describes the Use Case for Application Services Extending Device Data for a given south-bound Device.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/800) (2022-07-25)


### Market Segments
Any that deploy EdgeX systems with analytic, utility, or north-bound microservices that add new Device Resources
that are extensions of the original south-bound or service-based Device data.

### Motivation
We find a consistent need as we design microservices for our industrial products:
The new analytic, utility, and north-bound microservices almost always need to add Device Resources to manage their configuration, transforms, and status reporting. These Resources are usually needed on a per-Device basis (rather than just overall service configuration or status), which can be seen as extending (adding to) the data of the original south-bound devices.

Adding configuration and status via Devices that extend the original south-bound Device, and new Device Resources,
make this configuration and status data easily accessible and translatable to other Application Services and to the UI via REST;
we think that this general solution is better than disparate solutions which add custom APIs in each Application Service to Get and Set this data.

What is needed is a common means of showing the relationship between these added Resources and their
original south-bound Device; that is, to indicate that these Resources "extend" the original Device.

It is desirable that the means of conveying this information become standardized for those EdgeX microservices
which provide and use it, hence proposing here that there be a common EdgeX way defined to do this.

### Target Users
- Product Developers
- Device Owner
- Device User
- Device Maintainer
- Cloud User
- Service Provider
- Software Integrator

### Description
Picture the extremely simple case of a south-bound sensor device that just measures Temperature and Humidity and provides these as Device Resources. If we then add analytic and north-bound microservices:
- A Trending service that has Device Resources to indicate that Temperature and Humidity are trended for, eg, Minimum, Average, and Maximum over a 1 hour trend interval.
- An Alarming service that has Device Resources to describe the Alarm Rules used to monitor Temperature and Humidity, plus a device-level InAlarm status.
- A Cloud service that reports not just the Temperature and Humidity but also their Trend configuration and Alarm Rule Resources. 
In addition, the Cloud service adds its own Resources to direct the Cadence with which this Device's data is reported.

Now scale this up to 100 such Temperature/Humidity sensors, and it grows difficult to match all of the added
Resources to their original sensor data. And add the requirement that all these resources must be able to be seen 
and managed locally via REST or Message Bus, and potentially from north-bound services like Modbus/TCP, and from 
the Cloud (because everybody wants to control everything from the Cloud). 

Furthermore, from the end user's point of view, the Trend configuration, Alarm Rules, and Cloud Cadence that are added for a given Device are all seen as aspects of the Temperature/Humidity Device, as is common 
for Digital Twin representations, and not as separated, free-standing entities. 
So there must be some means to relate the extended Device Resources to the original south-bound Device and its
Device Resources.


### Existing solutions
In Eaton's legacy products, these configuration and status extensions could be added to the channels of the Device in the central data store, exist as channel metadata, or be stored in separate data objects. This was fine and 
efficient for a self-contained, monolithic solution, but is awkward when dividing the monolith into decoupled
microservices.

In EdgeX today, Devices and Resources can be added that are not related to the south-bound Device or to each other, 
except perhaps by well-chosen Labels or Tags.


### Requirements
1. Standard EdgeX means exists to relate configuration and status Resources for Application Services to the
originating south-bound Device data, on a per-Device basis.
2. The configuration and status Resources for Application Services can be viewed as "extending" the originating
south-bound Device data.
3. Application Services, including a REST-based UI, can find and use these configuration and status Resources 
from other Application Services in addition to the orignal south-bound Device data.

Not a requirement: means of using or combining Resources from multiple 

### Discussion

If this UCR is approved, before an ADR can be written, we must choose one of two paths forward toward a solution.

One path (the ideal one) is to add the extended resources to the south-bound device and its device profile.
1. Pros:
    - One source of truth in core-data and core-metadata for all Resources related to each Device.
    - No special properties have to be added to relate the extended to the original Device Resources.
2. Cons:
    - The south-bound Device Service could become confused by Resource entries in its Device Profile that it ought to ignore, so it would not be backwards compatible.
    - Potential contention as multiple Application Services try to update the Device Profile, adding their Resources.
    - Would have to add some notation so that core-command could determine which service to address to Get or Set
    the Device Resources (original and extended), so not backwards compatible.

The alternative path is to create an "Extended" Device under each Application Service, which holds its extended configuration and status Resources.
1. Pros:
    - Good decoupling of these extended Resources under each Application Service.
    - Core-command can use conventional means to know which Service to reach for Get and Set of these Resources.
    - No changes necessary to south-bound Device Services, who don't know about these extended Resources.
2. Cons:
    - Need to add some means to each extended Device to indicate which south-bound Device it extends.
    - Need to add or modify some core API(s), or their query options, to allow lookup of the original south-bound Device and all of its extended Devices.
    - Application Services need to do extra work to pull in the extended Resources in addition to the south-bound Device Resources.

### Other Related Issues
Potentially related to Use Case for Device Parent-Child Relationships [0002 Device Parent-Child Relationships](./0002-Device-Parent-Child-Relationships.md), if the "alternative path" solution is chosen here.


### References



