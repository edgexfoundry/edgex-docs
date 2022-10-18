## Core Data Cache

### Submitters
Jim White (IOTech Systems)


## Change Log

### Market Segments
Any/All

### Motivation
Reduction in the amount of data that is persisted at the edge.  Reduction in the amount of data sent to the north.  Reduction in the amount of data sent to edge analytics (rules engines, etc.).

### Target Users
- Device Manufacturer
- Device Owner
- Device User
- Device Maintainer
- Cloud Provider
- Service Provider
- Network Operator
- Software Developer
- Software Deployer
- Software Integrator

### Description
In cases where there is a need to store data at the edge and that data is subsequently sent to the “north” (cloud or enterprise systems, rules engines, AI/ML, etc.), there may be a need to keep (persist) only the latest readings.  “Latest” should be configurable and defined by the user – allowing for a cache of so many readings for a particular device resource.  Queries of core data should also allow for requesting the “latest” N readings as well.

For example, as a temperature sensor may report the current temperature (the device resource) very frequently (say once every 5 seconds), that data may only be sent to other services or systems every minute.  The user may wish to have only the last two readings persisted and subsequently sent north during the minute interval (batch and send).  Thus, core data becomes a kind of cache for a certain number of readings.

### Existing solutions
Today, core data will persist all data sent it.  The scheduler can be used to “clean” older data (data collected with a timestamp exceeding a specific timeframe).  But there is no way to only retain only X number or latest readings.  There is also no way to query for the “latest” readings.

### Requirements

- Cap the number of a particular device’s readings are kept/persisted in core data.
- The number of persisted device readings is configurable
- Queries of core data should allow for returning the latest X number of readings 

### Other Related Issues


### References
- [Core data API reference](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-data/2.1.0)
- [Prior Core Data Cache ADR]( https://github.com/edgexfoundry/edgex-docs/pull/723)