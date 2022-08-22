## Device Parent-Child Relationships
This UCR describes Use Cases for new Device metadata for Parent to Child Relationships for a given Device.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/800) (2022-08-22)


### Market Segments
Any that deploy EdgeX systems to manage multiple devices.
In particular, Industrial Gateway systems that connect to multiple south-bound devices
and provide their data to north-bound services.

### Motivation
It is frequently important to north-bound services to establish the parent-child relationships
of the devices found in an EdgeX system. 
This information is generally used for either protocol data constructs or for display purposes.
If not know or provided by the south-bound Device Service, this information might be added 
to the Device instance's metadata by the north-bound or analytics services, or by the user.

It is desirable that the means of conveying this information become standardized for those systems
which provide and use it, hence proposing here that there be a common definition and usage of this metadata.

### Target Users
- Product Developers
- Device Owner
- Device User
- Device Maintainer
- Cloud User
- Service Provider
- Software Integrator

### Description
Some north-bound protocols and some UI designs present the system devices in a hierarchial manner, 
where it is necessary to know which devices are parents and which are their children.

These considerations are most important for gateways that are implemented with the EdgeX framework,
since there are potentially many south-bound devices connected to a system.

Examples are
* BACnet - where only one "main" device is present at the point of external connection (eg, UDP port 0xBAC0) and all other devices must be presented as "virtually routed devices" connected to that main "virtual router" device.
* Azure IoT Hub - where the normal connection for IoT Plug and Play / Digital Twin is for a single device, and any other devices need to somehow fall under that device (eg, with Device Twin "Modules")
* UI device presentation - where child devices are grouped under their parent, often rolled up until they are expanded to show their data
* Multi-tenant deployments of multi-point energy meters - where a main meter has up to 80 Branch Circuit Monitoring (BCM) points connected to it, each BCM modeled as a Device consisting of the same 6 or so energy channels (Device Resources), and each BCM is assigned to a particular tenant. Tenants will be given access to the data from their BCM point(s) but not those of other tenants. A gateway may connect more than one of these multi-point energy meters.

Since there are multiple similar uses for this relationship information on the north side, it is proposed to locate
this relationship metadata in the Device object as accessed from core-metadata by all services, rather than to 
locate it in each north-bound service (which would be particularly problematic for the UI, which gets its data through REST APIs).

The south-bound Device Service that creates a Device is ideally the service which establishes this relationship data, though it is possible that it is unaware of the parent-child relationship. It should be permitted, therefore, for this relationship information to also be set by north-bound services (most likely the UI) and simply ignored by the south-bound Device Service.

It is also necessary to indicate which device is the "main" or "publisher" device (ie, the gateway device), 
as any devices without a configured relationship can be inferred to be children of that device.

It is frequently a pattern in data servers to "walk the device tree", starting with the main device, then 
recursively processing its direct child devices, and then the child devices (if any) of those devices, until
all devices have been processed. This is normally part of the initialization of device data for a server,
since the parent must be processed and initialized before its child devices. Consequently, there is a need
for a means to answer the question "What are the child devices (if any) of device x.y.z?"; this is commonly done
either with the device structure listing its children, or by providing a query that can answer this question.

### Extensions to the main Use Case
1. Some services add "devices" which have no physical counterpart, eg, for an NTP client service where the "device" 
serves simply as a container for the Resources necessary to configure and report the status of the service.
In these cases, it would be helpful for the other services if it described itself as something like a "system" device,
meaning one that doesn't have a physical (south-bound or hardware) counterpart.
2. Multi-level systems, such as a "gateway of gateways", which aggregate a large number of devices. The parent
property will be useful for assisting to arrange the devices in a hierarchy that corresponds to their physical hierarchy. 
In this situation, the parent property of a lower-level gateway will indicate the upper gateway it is connected to.

### Existing solutions
The Device structure in Eaton's legacy products indicated this parent-child relationship bidirectionally: each device indicated its parent device (if any) with one field, and its child devices (if any) with a list of IDs.

The Device structure in Eaton's cloud solution is a "DeviceTree", which is a recursive, hierarchial structure of the connected devices, starting with the "publisher" device and its first-level child devices.

There is the BACnet "virtual routed devices" model, but I would not recommend it, as it is too artificial for this  simple relationship.

The existing EdgeX UIs group devices by their Device Service, which is a good approach for simple devices without children of their own, but fails if those devices have child devices too.

### Requirements
1. Each device should have a property to indicate which other device is its parent device.
2. In a gateway configuration, with multiple devices, there should be one "main" or "publisher" device, 
and it should indicate this via a special property instead of a property to indicate a parent device (since it has no parent).
3. These parent-child requirements do not apply for the case of a single device configuration.
4. If a device does not indicate which is its parent device, then it shall be inferred that its parent is the main device. (This helps with backwards compatability.)
5. Though it is preferred that the owning service set a device's parent property, this property can also be set
by other services via the core-metadata PATCH devices API. The owning service can ignore this update if it does
not use the parent property.
6. Some means provided to answer the question, "What are the child devices (if any) of device x.y.z?".
7. Some standard means to indicate which devices are "system" devices, ie, those without a physical counterpart.
8. There can be multiple levels (eg, child devices of a child device).
9. Each child device can only have one parent device.
10. It is up to the Device Service which manages a parent device to remove all of its child devices if the parent is removed.

Not a requirement: inheritance of device status via the parent-child relationship. Apparently this was a point
over which past consideration of parent-child relationships in EdgeX foundered, but it seems complicated
for independent services, and can generally be inferred by other services anyway.

### Other Related Issues
Use Case for Application Services Extending Device Data [Extending Device Data](./Extending-Device-Data.md) may be related, 
as, depending on its solution, it may have to indicate a different Device Relationship ("Extends").

### References
- [Azure IoT Edge Gateways and Child Devices](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-connect-downstream-iot-edge-device?view=iotedge-2020-11&tabs=azure-portal)

- BACnet Virtual Devices: The full BACnet spec is paywalled by ASHRAE. But the relevant snippet
is from Annex H, section **H.1.1.2 Multiple "Virtual" BACnet Devices in a Single Physical Device**:

> A BACnet device is one that possesses a Device object and communicates using the procedures specified in this
standard. In some instances, however, it may be desirable to model the activities of a physical building automation 
and control device through the use of more than one BACnet device. Each such device will be referred to as a virtual 
BACnet device. This can be accomplished by configuring the physical device to act as a router to one or more virtual 
BACnet networks. The idea is that each virtual BACnet device is associated with a unique DNET and DADR pair, 
i.e. a unique BACnet address. The physical device performs exactly as if it were a router between physical BACnet 
networks.


