## Hybrid App-Device Services
This UCR describes Use Cases for an approach that is useful for some analytic, utility, and north-bound services 
which are formed from a hybrid of EdgeX App and Device Services.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pulls) (2022-07-26)


### Market Segments
Any that deploy EdgeX systems with analytic, utility, or north-bound microservices that run persistently
and rely on device profiles to describe their handling of data from either south-bound devices or 
service-based devices.


### Motivation
The EdgeX docs describe a nice, clean framework wherein there are south-bound Device Services that communicate with
external devices and import their data, and north-bound Application Services that transform that
device data for external actors; there are separate SDKs for Device and Application Services, and
there are separate sets of APIs associated with Device and Application Services. In this view, the work of 
Application Services is triggered by internal EdgeX events (API calls or Message Bus events).

In our implementations, we find several problems with clean separation of Device and Application Services as we 
design microservices for our industrial products:
- Our north-bound microservices respond to external, as well as internal, stimuli, and need to maintain
persistent connections to external actors or to listen persistently for external requests.
- For analytic or north-bound services managing large amounts of data from south-bound devices, the scale does 
not permit the use of per-resource rules to describe how each resource is handled; instead, it is necessary to 
code the rules and let the bulk or batch handling be described by something just like device profiles. 
These are the 95-98% case, where the coded rules are relatively simple (eg, for interval trending or alarm 
monitoring); for the remainder, the complex rule cases, the existing EdgeX means of rule handling (triggers and 
eKuiper rules) are a good solution.
- Static configuration of analytic and north-bound services with respect to the device data that they must handle
has proven insufficient; instead, these services need something just like the dynamic provisioning of Device Services.
- For our analytic, utility, and north-bound services, we almost always choose to add (Device) Resources as the 
means to manage their configuration, transforms, and status reporting. These Resources are often needed on a 
per-Device basis (rather than just overall service configuration or status), sometimes extending (adding to) the 
data of the original south-bound devices.
- The lack of a C/C++ Application Services SDK, for developers not familiar with Go and for north-bound protocol 
libraries which lack a Go implementation.

While we could choose to address some of these points by creating specific APIs for each service to configure
and get status, it seems that much of development would be spent in creating and maintaining these bespoke APIs
which, in the end, reduce to Getting and Setting internal resource points inside the service. 
So the simpler approach is to present them as Device Resources to be managed with the well-known core-command
GET and PUT commands, provided that these Resources are well-described in their Device Profiles.

And this, finally, is where the notion of the "Hybrid App-Device Service" comes in; these analytic, utility, and
north-bound services are truly Application Services, but they are better supported by the facilities of the
EdgeX Device Service SDKs and APIs than by those of the EdgeX Application Services SDKs and APIs.

### Target Users
- Product Developers
- Device User
- Cloud User
- Service Provider

### Description
The proposal in this UCR is primarily just to add a description of this Hybrid App-Device Service approach in these 
[edgex-docs](https://github.com/edgexfoundry/edgex-docs) as a normal part of EdgeX systems.
This would probably be in a new section alongside, or else under, the existing one for 
[Application Services](https://github.com/edgexfoundry/edgex-docs/tree/main/docs_src/microservices/application).

The main points to be described for this Hybrid App-Device Service approach are:
- Use of the Device SDKs instead of the Application SDK
  - The lack of a C/C++ Application SDK is another driver for this approach
- Use of the Device SDK APIs
  - Including those for Discovery and Provision Watching, using the new Use Case for Provision Watching via 
  Additional Device Properties [0004 Provision Watch more Device Properties](https://github.com/edgexfoundry/edgex-docs/pulls) 
  *later (./0004-Provision-Watch-more-Device-Properties.md)*
  - Provision Watching is used to match EdgeX devices to their service configurations ("discovery") 
  - No Trigger API is needed for most of these services; a custom API can be added where there is a need.
- Use of the new Use Case for Application Services Extending Device Data, [0003 Extending Device Data](https://github.com/edgexfoundry/edgex-docs/pull/800) *later (./0003-Extending-Device-Data.md)* for associating the added Device
Resources with their corresponding south-bound Device
  - Allows the user to update the per-Device configuration at run-time
- Use of core-command to Get and Set the "extended" Device Resources
- Extensive use of individual Device Profiles to configure or map south-bound Devices into the Service on a 
per-Device basis

For detailed descriptions of some example Hybrid App-Device Services, see the Discussion section below.

### Existing solutions
Since the services being considered are properly thought of as Application Services (existing on the north side), 
the Application Service SDK would be the first thing to consider. However, it supports only a few standard APIs, none
of which address the configuration requirements described in the Discussion section below. 
So if starting with the Application Service SDK, the developers would
have to add many APIs which would look just like the ones already supported in the Device Service SDK.

The other major design decision is whether to implement the per-Resource configuration 
- via custom GET/POST/PUT/DELETE APIs, or 
- via core-command to GET and PUT Device Resources listed in Device Profiles.

### Extensions
Application Services could, alternatively, implement using the Device Service SDK and APIs but not rely on
Device Profiles for descriptions of how Resources are managed. In this alternative Use Case, the Service 
would have to provide custom APIs to configure and manage configuration, and to provide status. If such a Service
still wanted to use Dynamic Device Provisioning, it would have to have at least one (minimal) profile to
refer to for the ProvisionWatcher configuration.

### Requirements
- New section in edgex-docs describing how the Hybrid App-Device Service approach fits into the EdgeX framework

### Discussion and Example Hybrid App-Device Service Descriptions

To illustrate the use of this hybrid solution, consider the needs common to five representative 
Application Services as the single Use Case in this proposal: 
two analytic (Trending and Alarming), one utility (NTP client), and two north-bound (BACnet/IP and Cloud Service). 
I believe these are better viewed side-by-side here rather than as separate UCRs, where the
commonality would be lost from view. These are not complete descriptions of these services, just excerpts focusing on
configuration, management, and status reporting.

#### Trending Service
The Trending or Data Historian Service computes simple statistical measures (eg, Minimum, Average, Maximum) for each 
indicated Resource over a specified Interval and archives the results at the end of each interval. This is commonly
done for 1/3 to 1/2 of the Resources produced by each south-bound device, though the user may choose to change the 
configuration to Trend more or less of the Resources of any given Device, or choose not to Trend a Device at all. 

Besides the overall configuration of this service (Interval size, depth of history to retain), it is necessary to configure which Resources from each Device of interest should be Trended, if any, and which statistical measures to use for each. This can be done with a Device which "extends" the original south-bound Device data, as described in
the Use Case for Application Services Extending Device Data, [0003 Extending Device Data](https://github.com/edgexfoundry/edgex-docs/pull/800) *later (./0003-Extending-Device-Data.md)*; the Trending Service would add
new per-Device Resources to do this configuration.

#### Alarming Service
The Alarming Service monitors Device Resources from Devices that belong to south-bound Device Services and 
applies Alarm Rules to detect when a given Resource has entered or exited an Alarming state. 
(Consider just the simple case of an Alarm Rule applied to one Resource at a time, which is the major Use Case 
for Alarm Rules.) 

There are just a few algorithms used for these simple Alarm Monitoring Rules, but there is per-Resource configuration 
for different thresholds, hysteresis, delay, and severity levels; 
sometimes these configurations are shared (eg, all 3 phases of voltage  measures are normally treated alike). Multiple threshold configurations may be grouped into
an Alarm Group, so that a single Alarm lifecycle may flow through escalating severities (rather than disconnected 
Alarm Events). The owner determines which Resources are monitored, with which algorithm, and at what levels.

The design for this Alarming Service can also be done with Devices which "extend" each of the original south-bound 
Devices, using Object-type Resources for the (moderately complex) Alarm Rules and Groups.

#### NTP Client Service
The NTP Client Service uses the NTP protocol to get an accurate time from external NTP servers. These servers may be configured statically by the owner or obtained from DHCP. It also necessary for this service to report its status 
(eg, when it has synced with the NTP servers). A command to "sync now" is a common user-convenience feature; 
otherwise, the service needs to check periodically with the NTP servers and see if the system clock needs to
be updated.

This NTP Client Service would add a single new "System" Device (ie, one with no physical or hardware counterpart) 
containing the Resources for configuration and status.

#### BACnet/IP Service
The north-bound BACnet/IP service (for a gateway) represents itself to incoming BACnet requests as a system
consisting of a BACnet Router (the gateway Device) and one or more Virtual BACnet routes to BACnet Devices (the other 
EdgeX Devices). Each BACnet Device typically contains one BACnet object for each Device Resource of interest, so the
per-Resource configuration indicates the object type, object ID, writability, Change-of-Value configuration, etc.

The design for the BACnet/IP Service can use per-Device Profiles to configure the relatively constant aspects (eg,
object type, object ID, and writability) and adding Devices with Resources to configure the changeable aspects (eg, 
Change-of-Value configuration) that are Devices that "extend" the original south-bound Devices.

#### Cloud Service
The Cloud Service establishes and maintains a connection to the Cloud, and publishes data updates on a configurable
cadence (where the owner uses the cadence settings to balance ingestion costs against timeliness of the data updates).
The owner selects which Resources to publish, and at what cadence; there commonly is also a need to transform the
identification of each Resource from EdgeX to some Cloud-native ID.

The Cloud Service needs to communicate the Trend and Alarm configuration, status, and results, and users need to be 
able to change those configurations from the Cloud side.

The design for the Cloud Service can also be done with Devices which "extend" each of the original south-bound 
Devices, using per-Device Profiles to configure the relatively constant aspects (eg, mapping to Cloud IDs) 
and adding Device Resources to configure the changeable aspects like Cadence. 


### Other Related Issues
- Use Case for Application Services Extending Device Data, [0003 Extending Device Data](https://github.com/edgexfoundry/edgex-docs/pull/800) *later (./0003-Extending-Device-Data.md)*

- Use Case for Provision Watching via Additional Device Properties [0004 Provision Watch more Device Properties](https://github.com/edgexfoundry/edgex-docs/pulls) 
*later (./0004-Provision-Watch-more-Device-Properties.md)*

### References
- [Application Services in edgex-docs](https://github.com/edgexfoundry/edgex-docs/tree/main/docs_src/microservices/application)
