## Core Data Retention and Persistent Caps

### Submitters
Jim White (IOTech Systems)

## Change Log
Formerly referred to as Core Data Cache

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
In cases where there is a need to store data at the edge and that data is subsequently sent to the “north” (cloud or enterprise systems, rules engines, AI/ML, etc.), there may be a need to keep (persist) only the latest readings.  “Latest” should be configurable and defined by the user – allowing for a cap on the number of readings for a particular device resource.  Queries of core data should also allow for requesting the “latest” N readings as well.

For example, as a temperature sensor may report the current temperature (the device resource) very frequently (say once every 5 seconds), that data may only be sent to other services or systems every minute.  The user may wish to have only the last two readings persisted and subsequently sent north during the minute interval (batch and send).  Thus, a retention cap is placed on core data for a certain number of readings.

### Existing solutions
Today, core data will persist all data sent to it.  The scheduler can be used to “clean” older data (data collected with a timestamp exceeding a specific timeframe).  However, there is no way to retain only X number or latest readings.  Query methods do not, by default, provide a simple way to query for “latest” readings.  On most core data query methods, one could set the *limit* parameter = 1 (or some other number) and thereby return the latest event or reading since the results are sorted based on origin.  In implementation, should this UCR be aproved, one could envision providing a "convenence" query that just uses a default limit (limit=reading cap) parameter. This is a design decision to be addressed in a follow on ADR or at implementation time. 

### Requirements

- Cap the number of a device readings, per resource name, that are kept/persisted in core data. 
- The requirement is to keep the readings at a precise number (never going above that).  So for example, if the cap is set to 5, then there would never be more than 5 readings in the database.  When a new reading is captured and there are already 5 in the database, the oldest reading must be removed before the new reading is added.
- The number of persisted device readings is configurable, and this configuration setting applies to all resources on all devices in core-data.
- Queries of core data should allow for returning the latest X number of readings per resource name. 

### Other Related Issues


### References
- [Core data API reference](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-data/2.1.0)
- [Prior Core Data Cache ADR]( https://github.com/edgexfoundry/edgex-docs/pull/723)