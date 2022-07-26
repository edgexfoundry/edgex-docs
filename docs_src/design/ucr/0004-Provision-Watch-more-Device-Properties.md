## Provision Watch more Device Properties
This UCR describes the Use Case for Provision Watching via Additional Device Properties,
beyond the protocol properties currently used exclusively for matching in Provision Watchers.

### Submitters
- Tom Brennan (Eaton)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pulls) (2022-07-26)


### Market Segments
Any that deploy EdgeX systems with analytic, utility, or north-bound microservices that must "discover"
Devices added to the EdgeX core-metadata by south-bound Device Services.

### Motivation
The autodiscovery of Devices using Provision Watchers is a useful feature of Device Services; currently,
the Provision Watcher implementation in the two Device SDKs uses the protocol properties of a discovered
Device to match against the "identifiers" specified in the Provision Watcher metadata. The 
implementations use regular expression matching against the "identifiers", and also filter out any 
Devices whose protocol properties match the "blockingIdentifiers" of the Provision Watcher metadata.

We are finding that [Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pulls) *later (./0005-Hybrid-App-Device-Services.md)* also want to 
use Provision Watchers, so that they can be configured at run-time to work with new Devices, but these 
do not need or want to match the protocol properties of a Device; instead, they want to match or exclude
based on Device properties such as the "profileName" (as a proxy for Device Model Name), "name", and "labels".

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

For example, consider the case where each of three Hybrid App-Device Services (a Trending Service, an Alarm Monitoring Service, and a Cloud Service) want to handle the data originating in a south-bound
Modbus service for any "Watt-o-Meter" (Model Name) Device. So each service is configured with a Provision Watcher that will try to match the "profileName" of "Watt-o-Meter-Modbus-Profile-01", and, if the match is found, add a new "extended" Device to each service using the appropriate Device Profile (eg, "Watt-o-Meter-Trends-Profile-01" for the Trending Service), and giving the new extended Device a name based on the original and the service (eg, "Meter-333-Trending").

### Extensions
Other Device properties appear to be good candidates to allow here as well:
- name: The Device name may be good for regular expression matching, eg "name":"Meter-*"
- labels: Since this one is free-form and open to the owner to add labels of their choosing, 
this one should be good for both matching and the exclusion list. 
Eg, if a Devic had "labels": "meter, basement, energy", then it could be matched or excluded for "labels":"basement".

### Existing solutions
In EdgeX today, as noted, Provision Watchers match only the protocol properties, using regular expression matching and excluding. The example given for the REST API is a good one:
```json
"identifiers": {
        "address": "localhost",
        "port": "3[0-9]{2}"
      },
```
Note its use of regular expression matching for the port number. 
The documentation should be clearer that the key-value pairs for "identifiers" and "blockingidentifiers" are only from the protocol properties, and that regular expression matching is supported.


### Requirements
1. Standard EdgeX means exists for the Provision Watcher to match or exclude based on other Device properties besides the protocol properties:
    - "profileName"
    - "name"
    - "labels"
2. Support regular expression matching for these matching and exclusion patterns.

### Other Related Issues
- Related to Use Case for describing a hybrid of App and Device Services [0005 Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pulls).


### References
- [Hybrid App-Device Services](https://github.com/edgexfoundry/edgex-docs/pulls) *later (./ucr/0005-Hybrid-App-Device-Services.md)*
