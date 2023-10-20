## Extending Device Data
This UCR describes the Use Case for Extending of Device Data by Application Services for a given south-bound Device.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [approved](https://github.com/edgexfoundry/edgex-docs/pull/845) (2022-10-19)


### Market Segments
Any that deploy EdgeX systems with analytics, utility, or north-bound microservices that add new Device Resources
that are extensions of the original south-bound or service-based Device data.

### Motivation
We find a consistent need as we design microservices for our industrial products:
The new analytics, utility, and north-bound microservices almost always need to add Device Resources to manage their configuration, transforms, and status reporting. These Resources are usually needed on a per-Device basis (rather than just overall service configuration or status), which can be seen as extending (adding to) the data of the original south-bound devices.

Adding configuration and status via Resources that **extend** the original south-bound Device
make this configuration and status data easily accessible and translatable to other Application Services and to the UI via REST;
we think that this general solution is better than disparate solutions which add custom APIs in each Application Service to Get and Set this data.

What is needed is a common means of showing the relationship between these added Resources, their owning service,
and the original south-bound Device Resources; that is, to indicate that these Resources "extend" the original Device data.

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
Picture the extremely simple case of a south-bound sensor device that just measures Temperature and Humidity and provides these as Device Resources. If we then add analytics and north-bound microservices:
- A Trending service that needs Device Resources to indicate that Temperature and Humidity are trended for, eg, Minimum, Average, and Maximum over a 1 hour trend interval.
- An Alarming service that needs Device Resources to describe the Alarm Rules used to monitor Temperature and Humidity, plus a device-level InAlarm status.
- A Cloud service that reports not just the Temperature and Humidity but also their Trend configuration and Alarm Rule Resources. In addition, the Cloud service adds its own Resources to direct the Cadence with which this Device's data is reported.

Now scale this up to 100 such Temperature/Humidity sensors, and, if not using extended devices as described here, 
it would grow difficult to match all of the free-standing (unassociated)
Resources to their original sensor data. And add the requirement that all these resources must be able to be seen 
and managed locally via REST or Message Bus, and potentially from north-bound services like Modbus/TCP, and from 
the Cloud (because everybody wants to control everything from the Cloud). 

Furthermore, from the end user's point of view, the Trend configuration, Alarm Rules, and Cloud Cadence that are added for a given Device are all seen as aspects of the Temperature/Humidity Device, as is common 
for Digital Twin representations, and not as separated, free-standing entities. 
So there must be some means to relate the extended Device Resources to the original south-bound Device and its
Device Resources.


### Existing solutions
In EdgeX today, Devices and their Resources such as those described in the last section can be added, but they are not
seen as related to the south-bound Device or to each other, except perhaps by well-chosen Labels or Tags.

The existing south-bound Device Profiles could be extended to simply add the new Resources, but nothing connects these
Resources to their owning Service (ie, so core-command could be used to manage them).


### Requirements
1. A means is defined to extend the Device metadata of a south-bound Device's profile with new resources that are 
added and managed by an upper-level service, such as an analytics, utility, or north-bound service.
2. The services which extend the device resources must manage the data for those extended resources on a per device instance basis.
3. Core-command must know to direct requests for these extended resources to the upper-level service that manages them.
4. The "Extended" Device Resources will extend all instances of the (south-bound) Device; 
the south-bound Device may be extended by Resources from multiple upper-level services.
5. Some service or other means must ensure that all extended resources are uniquely named; 
that is, no service can add a resource with an existing resource name.

Not a requirement: means of using or combining Resources from multiple south-bound Devices into one Extended Resource.

### Other Related Issues

### References



