## Hybrid App-Device Services
This UCR describes Use Cases for an approach that is useful for some analytic, utility, and north-bound services 
which are formed from a hybrid of EdgeX App and Device Services.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pulls) (2022-07-18)


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

We find several problems with clean separation of Device and Application Services as we design microservices
for our industrial products:
- Our north-bound microservices respond to external, as well as internal, stimuli, and need to maintain
persistent connections to external actors or to listen persistently for external requests.
- For analytic or north-bound services managing large amounts of data from south-bound devices, the scale does 
not permit the use of per-resource rules to describe how each resource is handled; instead, it is necessary to 
code the rules and let the bulk or batch handling be described by something just like device profiles. 
These are the 95-98% case, where the coded rules are relatively simple (eg, for interval trending or alarm 
generation); for the remainder, the complex rule cases, the existing EdgeX means of rule handling (triggers and 
eKuiper rules) are a good solution.
- Static configuration of analytic and north-bound services with respect to the device data that they must handle
has proven insufficient; instead, these services need something just like the dynamic provisioning of Device Services.
- These analytic, utility, and north-bound services almost always need to add (Device) Resources to manage their
configuration, transforms, and status reporting. These Resources are often needed on a per-Device basis (rather than
just overall service configuration or status), sometimes extending (adding to) the data of the original south-bound devices.

While it is possible to address some of these points by creating specific APIs for each service to configure
and get status, it seems that much of development would be spent in creating and maintaining these bespoke APIs
which, in the end, reduce to Getting and Setting internal resource points inside the service. 
So the simpler approach is to present them as Device Resources to be managed with the well-known primitive
Get and Set commands, provided that these Resources are well-described.

And this, finally, is where the notion of the "Hybrid App-Device Service" comes in; these analytic, utility, and
north-bound services are truly Application Services, but they are better supported by the facilities of the
EdgeX Device Service SDKs and APIs than by those of the EdgeX Application Services SDKs and APIs.

### Target Users
- Product Developers
- Device Owner
- Device User
- Device Maintainer
- Cloud User
- Service Provider
- Software Integrator

### Description
Let us consider the needs common to five representative Application Services as the single Use Case in this
proposal: two analytic (Trending and Alarming), one utility (NTP client), and two north-bound (BACnet/IP and Cloud Service). 
I believe these are better viewed side-by-side here rather than as separate UCRs, where the
commonality would be lost from view. These are not complete descriptions of these services, just excerpts focusing on
configuration, management, and status reporting.

#### Trending Service
The Trending or Data Historian Service computes simple statistical measures (eg, Minimum, Average, Maximum) for each 
indicated Resource over a specified Interval and archives the results at the end of each interval. This is commonly
done for 1/3 to 1/2 of the Resources produced by each south-bound device, though the user may choose to Trend more
or less of the Resources of any given Device, or choose not to Trend a Device at all. 

Besides the overall configuration of this service (Interval size, depth of history to retain), it is necessary to configure which Resources from each Device of interest should be Trended, if any, and which statistical measures to use for each. 

*Possible Resource Configuration Example*
```yaml
# The Device Profile, for device to be added to EdgeX system and owned by the Trending service
name: "Energy-Meter-Trending-Profile-01"
manufacturer: "Eaton"
model: "Energy Meter"
id: "c655b09e-bc8b-11e6-a4a6-cec0c932cd05"
labels:
- "trending-app-example"
description: "A Device Profile which configures Trending of Resources"
deviceResources:
-
  # Trend Interval for this Device
  name: "TrendInterval"
  description: "The Trend Interval, in seconds"
  isHidden: false
  properties:
    valueType: "Int32"
    readWrite: "RW"
    minimum: "-1"
    maximum: "86400"
    # Defaults to 5 minutes
    defaultValue: "300"
    units: "seconds"
  attributes:
    # "rtype" names the Resource Type for this Cloud service
    rtype: "TrendInterval"
-
  # The 'name' specifies the Trending Algorithm
  name: "minAvgMax"
  description: "Comma-separated List of Resources that are Trended as Minimum, Average, and Maximum"
  isHidden: false
  properties:
    valueType: "String"
    readWrite: "RW"
    defaultValue: "mPercentLoad,mACVAN"
  attributes:
    rtype: "TrendList"
    # "uses" tells which Resource sets the Trend Interval for this group
    uses: "TrendInterval"
```


#### Alarming Service
The Alarming Service monitors Device Resources (from Devices that belong to south-bound Services) and applies 
Alarm Rules to detect when a given Resource has entered or exited an Alarming state. 
(Consider just the simple case of an Alarm Rule applied to one Resource at a time, which is the major Use Case 
for Alarm Rules.) 

The algorithm for these simple monitoring Rules is the same for all, but the per-Resource configuration sets 
different thresholds, hysteresis, delay, and severity levels; sometimes these configurations are shared (eg, all 3 
phases of voltage  measures are normally treated alike). Multiple threshold configurations may be grouped into
an Alarm Group, so that a single Alarm lifecycle may flow through escalating severities (rather than disconnected 
Alarm Events). The owner determines which Resources are monitored, and at what levels.

*Possible Device Profile Example (extract)*
```yaml
# The Device Profile, for device to be added to EdgeX system and owned by the Alarming service
name: "Energy-Meter-Alarming-Profile-01"
manufacturer: "Eaton"
model: "Energy Meter"
id: "c655b09e-bc8b-11e6-a4a6-cec0c932a1a3"
labels:
- "alarming-app-example"
description: "A Device Profile which configures Alarm Rules for Resource Monitoring"
deviceResources:
-
  # The 'name' specifies one Alarm Trigger Rule
  name: "lowUpperVoltageLimit"
  description: "Comma-separated List of Resources that are monitored by this Trigger Rule for exceeding a voltage threshold (lower/first level)"
  isHidden: false
  properties:
    valueType: "String"
    readWrite: "RW"
    defaultValue: "mACVAN,mACVBN,mACVCN"
  attributes:
    rtype: "AlarmRule:RisingThreshold"
    threshold: 130
    severityLevel: 2
    message: "Exceeded lower Voltage Threshold"
-
  # The 'name' specifies an Alarm Rule Group, consisting of Alarm Trigger Rule(s)
  name: "upperVoltageLimitGroup"
  description: "Comma-separated List of Trigger(s) for one Alarm Rule Group, for exceeding Voltage Threshold(s)"
  isHidden: false
  properties:
    valueType: "String"
    readWrite: "RW"
    defaultValue: "lowUpperVoltageLimit,highUpperVoltageLimit"
  attributes:
    rtype: "AlarmRuleGroup"
    isLatching: true
```


#### NTP Client Service
The NTP Client Service uses the NTP protocol to get an accurate time from external NTP servers. These servers may be configured statically by the owner or obtained from DHCP. It also necessary for this service to report its status 
(eg, when it has synced with the NTP servers). A command to "sync now" is a common user-convenience feature; 
otherwise, the service needs to check periodically with the NTP servers and see if the system clock needs to
be updated.

*Possible Device Profile Example (extract)*
```yaml
# The Device Profile, for device to be added to EdgeX system and owned by the NTP service
name: "NTP-Client-Service-Profile-01"
manufacturer: "Eaton"
id: "c655b09e-bc8b-11e6-a4a6-cec0c9320123"
labels:
- "ntp-example"
description: "A Device Profile for managing the NTP Client Service"
deviceResources:
-
  # First NTP Server to try to contact
  name: "NtpServer01"
  description: "First NTP Server - name or IP address"
  isHidden: false
  properties:
    type: "String"
    readWrite: "RW"
    defaultValue: ""
-
  name: "NtpStatus"
  description: "Status of the NTP Service"
  isHidden: false
  properties:
    type: "String"
    readWrite: "R"
    defaultValue: "Unknown"
```

#### BACnet/IP Service
The north-bound BACnet/IP service (for a gateway) represents itself to incoming BACnet requests as a system
consisting of a BACnet Router (the gateway Device) and one or more Virtual BACnet routes to BACnet Devices (the other 
EdgeX Devices). Each BACnet Device typically contains one BACnet object for each Device Resource of interest, so the
per-Resource configuration indicates the object type, object ID, writability, Change-of-Value configuration, etc.

*Possible Device Profile Example (extract)*
```yaml
# The Device Profile, for device to be added to EdgeX system and owned by the BACnet/IP service
name: "Energy-Meter-BACnet-Profile-01"
manufacturer: "Eaton"
model: "Energy Meter"
id: "c655b09e-bc8b-11e6-a4a6-cec0c932bac0"
labels:
- "bacnet-app-example"
description: "A BACnet Profile which maps Device Resources to BACnet Objects"
deviceResources:
-
  # The 'name' gives the name of the Device Resource from the south-bound device to be mapped to a BACnet Object
  name: "mPercentLoad"
  description: "Percent Load configuration for BACnet"
  # Hidden because core-command does not access this Resource via this service
  isHidden: true
  properties:
    readWrite: "R"
  attributes:
    # Mapping to the BACnet properties:
    objectId: "1020304"
    objectType: "AnalogInput"
```

#### Cloud Service
The Cloud Service establishes and maintains a connection to the Cloud, and publishes data updates on a configurable
cadence (where the owner uses the cadence settings to balance ingestion costs against timeliness of the data updates).
The owner selects which Resources to publish, and at what cadence; there commonly is also a need to transform the
identification of each Resource from EdgeX to the Cloud-native ID.

The Cloud Service needs to communicate the Trend and Alarm configuration and results, and users need to be able
to change those configurations from the Cloud side.

*Possible Device Profile Example (extract)*
```yaml
# The Device Profile, for device to be added to EdgeX system and owned by the Cloud service
name: "Energy-Meter-Cloud-Profile-01"
manufacturer: "Eaton"
model: "Energy Meter"
id: "c655b09e-bc8b-11e6-a4a6-cec0c932ce01"
labels:
- "device-cloud-example"
description: "A Cloud Profile which shows which Device Resources are published, and at what Cadence"
deviceResources:
-
  # The 'name' gives the name of the Device Resource from the south-bound device to be published to the Cloud
  name: "mPercentLoad"
  description: "Percent Load configuration for cloud publishing"
  # Hidden because core-command does not access this Resource via this service
  isHidden: true
  properties:
    readWrite: "R"
  attributes:
    # Mapping to the Cloud Identity and Type:
    iotTag: "596"
    vtype: "Float32"
-
  # Cadence rate for the realtime updates
  name: "Cadence-Moderate"
  description: "The Moderate Cadence Rate, in seconds"
  isHidden: false
  properties:
    valueType: "Int32"
    readWrite: "RW"
    minimum: "-1"
    maximum: "86400"
    # Defaults to 5s
    defaultValue: "5"
    units: "seconds"
  attributes:
    # "rtype" names the Resource Type for this Cloud service
    rtype: "CadenceRate"
    # Mapping to the Cloud Identity and Type, so it can be changed from the Cloud side
    iotTag: "10013602"
    vtype: "Int32"
    writable: "true"
-
  name: "Cadence-Group-Moderate"
  description: "Cadence Group using the Cadence-Moderate, comma-separated list of Resource names"
  isHidden: false
  properties:
    valueType: "String"
    readWrite: "RW"
    defaultValue: "mPercentLoad,mACVAN"
  attributes:
    rtype: "CadenceGroup"
    # "uses" tells which Resource sets the Cadence rate for this group
    uses: "Cadence-Moderate"
    iotTag: "10013603"
    vtype: "String"
    writable: "true"
```

*Possible Provision Watcher Example (extract)*
The key is to match an EdgeX Device's "profileName",
so the Device Resources will align with the cloud profile.
```json
{
  "requestId": "fb34e122-84d6-4c4c-a0ba-ac181021dc6b",
  "apiVersion": "v2",
  "provisionwatcher": {
    "name": "Energy-Meter-Watcher-Cloud-01",
    "labels": [
      "cloud"
    ],
    "identifiers": {
      "profileName": "Energy-Meter-Profile"
    },
    "blockingidentifiers": {
    },
    "profileName": "Energy-Meter-Cloud-Profile-01",
    "serviceName": "cloud-service",
    "adminState": "UNLOCKED"
  }
}
```

### Existing solutions
Since the services being considered are properly thought of as Application Services (existing on the north side), 
the Application Service SDK would be the first thing to consider. However, it supports only a few standard APIs, none
of which address the configuration requirements listed above. So if starting with that SDK, the developers would
have to add many APIs which would look just like the ones already supported in the Device Service SDK.

The other major design decision is whether to implement the per-Resource configuration 
- via custom GET/POST/PUT/DELETE APIs, or 
- via the commands to Get and Set Device Resources listed in Device Profiles.

### Extensions
Application Services could, alternatively, implement using the Device Service SDK and APIs but not rely on
the Device Profiles for descriptions of how Resources are managed. In this alternative Use Case, the service 
would have to provide custom APIs to configure and manage Resources, and provide status. If such a Service
still wanted to use Dynamic Device Provisioning, it would have to have at least one (minimal) profile to
refer to for the ProvisionWatcher configuration.

### Requirements
Considering the service examples listed above, there are three requirements that point toward the need for the 
Hybrid App-Device Service, using the Device Service SDK and APIs and Device Profiles for configuration:

1. The requirement that the user can choose ("provision", at run-time) which Devices participate, 
and which Resources within those Devices.
2. The need for a means for the user to configure aspects of how each Resource is managed in the service.
3. The need to detect and match ("discover") EdgeX devices to their service configurations.



### Other Related Issues
None known.

### References



