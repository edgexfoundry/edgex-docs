## Provision Watch via Device Metadata
This UCR describes the Use Case for Provision Watching via Additional Device Metadata,
beyond the protocol properties currently used exclusively for matching in Provision Watchers.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/806) (2022-08-30)


### Market Segments
Any that deploy EdgeX systems with south-bound Device Services where Provisioning is dependent on device data
discovered in devices, not just their protocol properties.
Any that deploy EdgeX systems with analytics, utility, or north-bound microservices that must "discover"
Devices added to the EdgeX core-metadata by south-bound Device Services.

### Motivation
The autodiscovery of Devices using Provision Watchers is a useful feature of Device Services; currently,
the Provision Watcher implementation in the two Device SDKs uses only the protocol properties of a discovered
Device to match against the "identifiers" specified in the Provision Watcher metadata. The 
implementations use regular expression matching against the "identifiers", and also filter out any 
Devices whose protocol properties match the "blockingIdentifiers" of the Provision Watcher metadata.

Provisioning for south-bound services today must have a strict knowledge of the devices that will be discovered,
but some protocols (eg, BACnet) have discoverable device properties which can provide a further discrimination,
for example, to use the device's modelName to determine which Device Profile should be applied to it.
We would like that the metadata from the Device (not necessarily from core-metadata, but properties of the Device) 
can be selected to match for provisioning, and not limit the property names to a fixed set of properties.

We are finding that [Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pull/809) *later (./Hybrid-App-Device-Services.md)* also want to 
use Provision Watchers, so that they can be configured at run-time to work with new Devices, but these 
do not need or want to match the protocol properties of a Device; instead, they want to match or exclude
based on Device instance metadata properties such as the "modelName", "profileName", "name", and "labels".

This UCR describes the Use Case for using these additional properties for Provision Watching.

### Target Users
- Product Developers
- Device Owner
- Device User
- Device Maintainer
- Cloud User
- Service Provider
- Software Integrator

### Description
Application Services using the Device SDKs (ie, Hybrid App-Device Services) can take advantage of the
Provision Watching feature and APIs to "discover" new EdgeX devices from the south-bound Device 
Services, match them to app-specific Device Profiles, and handle their data with analysis or transforms.

A south-bound Device Service may discover devices across a range of protocol properties, and those devices may need different
Device Profiles depending upon metadata properties of the discovered devices, for example, the ModelName field of BACnet data. 
While the "modelName" is an obvious target, the Device Service may want to use other device metadata for Provisioning 
as well for inclusion or exclusion.

For another example, consider the case where each of three Hybrid App-Device Services (a Trending Service, an Alarm Monitoring Service, and a Cloud Service) want to handle the data originating in a south-bound
Modbus service for any "Watt-o-Meter" (Model Name) Device. So each service is configured with a Provision Watcher that will try to match that "modelName", or else "profileName" of "Watt-o-Meter-Modbus-Profile-01", of devices discovered in core-metadata
or shown as added via the control plane events and, if a match is found, add a new "extended" Device to each service using the appropriate Device Profile (eg, "Watt-o-Meter-Trends-Profile-01" for the Trending Service), and giving the new extended Device a name, for example based on the original and the service (eg, "Meter-333-Trending").

### Extensions
Other Device metadata properties appear to be good candidates for a user to choose from:
- name: The Device name may be good for regular expression matching, eg "name":"Meter-*"
- labels: Since this one is free-form and open to the owner to add labels of their choosing, 
this one should be good for both matching and the exclusion list. 
Eg, if a Device had "labels": "meter, basement, energy", then it could be matched or excluded for "labels":"basement".
- serial number: with regular expressions, this can be a powerful matching choice.
- MAC address: similar to serial number for a specific range of vendor devices.

The Device Service which discovers the Device will probably want to permit specific metadata properties to be used.

### Existing solutions
In EdgeX today, as noted, Provision Watchers match only the protocol properties, using regular expression matching and excluding. The example given for the REST API is a good one:
```json
"identifiers": {
        "address": "localhost",
        "port": "3[0-9]{2}"
      },
```
Note its use of regular expression matching for the port number. 


### Requirements
1. Standard EdgeX means exists for the Provision Watcher to match or exclude based on other Device metadata properties besides the protocol properties. For example, but not limited to:
    - "profileName" (for an existing device)
    - "modelName" (as discovered in the device data)
    - "name"
    - "labels"
2. Support regular expression matching for these matching and exclusion patterns.
3. This provisioning can be applied by both devices discovered by south-bound services and by analytics or north-bound
services using devices already added to EdgeX core-metadata.
4. Similar to the existing "identifiers" and "blockingidentifiers" for Provisioning, the matching and excluding patterns will be given as key-value pairs.
5. Provide means for south-bound Device Services to choose and use whatever fields of Device Metadata are appropriate to the Service, ie, not limited to a fixed set of key names or just the Device properties in core-metadata; for example, the Service might use serial number or MAC address data coming from the Device.

### Other Related Issues
- Related to Use Case for describing a hybrid of App and Device Services [Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pull/809) *later (./Hybrid-App-Device-Services.md)* .


### References
- [Add Provision Watcher API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/2.2.0#/default/post_provisionwatcher), with examples and schema
- [Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pull/809) *later (./ucr/Hybrid-App-Device-Services.md)*
