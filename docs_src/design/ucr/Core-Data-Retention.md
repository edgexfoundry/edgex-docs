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
Today, core data will persist all data sent to it.  The scheduler can be used to “clean” older data (data collected with a timestamp exceeding a specific timeframe).  However, there is no way to retain only X number or latest readings.  Query methods do not, by default, provide a simple way to query for “latest” readings.  On most core data query methods, one could set the *limit* parameter = 1 (or some other number) and thereby return the latest event or reading since the results are sorted based on origin.  On most core data query methods, one could set the *limit* parameter = 1 (or some other number) and thereby return the latest event or reading since the results are sorted based on origin.

### Requirements

- The current requirement is to "ensure a minimum nuber of available entries."  Entries here meaning readings.  
- Because keeping a "hard cap" on the number of readings is considered computationally expensive, there needs to be a configurable purging interval and a high watermark.  
- The purging interval defines when the database should be rid of readings above the high watermark.
- The high watermark defines where the total count of readings should be returned to during purging.  For rexample, if the high watermark was 2, then the desire is to have 2 readings in the database.  But during periods between the purges, the count may grow above 2 until the next successful purge returns it to just 2 readings.
- Queries of core data should allow for returning the latest X number of readings per resource name. 

### Other Related Issues


### References
- [Core data API reference](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-data/2.1.0)
- [Prior Core Data Cache ADR]( https://github.com/edgexfoundry/edgex-docs/pull/723)