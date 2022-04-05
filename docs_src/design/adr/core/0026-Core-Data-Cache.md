# Core Data Cache

## Status

**Draft**

proposed: 4/4/22

## Context
There is a desire to have core data serve more as a data cache - that is, keeping only the "latest" readings.  There is also a desire to allow for queries of core data to serve up the "latest" readings.  This ADR defines new operations and APIs to satisfy these needs.

### Queries to return "Latest"

Core data will add the following new operations (and externally visible APIs) to provide the means to get the `latest` readings.

- Query for the latest N readings by device name
    - API: *GET* /reading/device/name/{name}/latest/{N}
    - returns the last N readings for the specified device
    - N must be > 0
- Query for the latest N readings by device name and device resource
    - API: *GET* /reading/device/name/{name}/resourceName/{resourceName}/latest/{N}
    - returns the latest N readings for the specified device and specified device resource
    - N must be > 0

### Delete operations (to keep the number of readings to the "latest" or a database size limit)

Core data will add the following new delete operations.  Note that only one will be exposed externally via API.  The other will be used internally by the service (when configured to use it).

- Delete all but N readings (aka - the **Eaton Delete**; clean readings but preserve the latest readings)
    - API:  *DELETE* /reading/keep/{N}
    - if there are fewer than (or equal to) N readings in core data, then all readings would be kept and no readings would be removed
    - if there are more than N readings in core data, then delete the oldest readings, but keep the youngest N readings
    - N must be > 0 (N = 1 means keep only the latest reading)
    - this delete option will be triggered via API either:
        - manually by the adopter
        - or by the scheduling service (the adopter would set up a new IntervalAction with the scheduling service)

- Delete readings to keep the database at a certain size (aka - the **Tony Delete**; clean readings to preserve the number of readings in the database)
    - API:  none.  This operation is not visible via REST API
    - this operation, when called upon internally by core data, will remove readings (from oldest to newest) to keep the core data database within a specified size
    - a configuration setting (`CacheDelete` in configuration) will determine how readings will be removed by this operation:
        - option A (`CacheDelete="OnEach"`): remove one reading (the oldest reading) each time a new reading gets added
            - this operation would be called as part of the core data add event/reading operations
            - this option causes core data to operate like a real cache - keeping only the latest reading
        - option B (`CacheDelete="OnCount"`): remove a specified number (`DeleteSize` in configuration) of readings when the number of readings exceeds a specified limit (`CacheSize` in configuration)
            - this operation would be called as part of the core data add event/reading operations
            - this option causes core data to keep within a size range (between a max and min number of readings) 
            - examples: 
                - if there are 100 readings in the database and the `CacheSize` of the database readings is set to 100, then when the next reading is added to core data, a delete of the latest `DeleteSize` readings are removed (starting with the oldest readings) from core data.
                - if there are 80 readings in the database and the `CacheSize` of the database readings is set to 100, then when the next reading is added to core data, no delete occurs.  The reading gets added normally and the number of readings in the database is now 81.
            - this option reduces the add/delete thrashing.  It only deletes when the max size is hit or exceeded

!!! Question
        - On the Eaton delete - do we care to keep N readings per device or device resource?  Or we are just going to delete until we have only N readings and we don't care which ones we delete?

        - On the Tony delete option A, given the way we specified this, there would only be one reading in core data at all times.  Do we mean to say that we only want to keep one reading of each device or device/device resource?  Or should we first allow some arbitrary number of readings to be built up and then start deleting readings one-for-one?

        - Is the configuration for core data "cache" Writable or static?

### Configuration Additions

No new configuration is needed to satisfy the GET operations/APIs.

A new `Writable` category and set of configuration values are needed for the core data cache *delete* operation.

``` toml
[Writable]
    [Writable.CacheMode]
    CacheDelete="OnEach"    # or alternately could be "OnCount"
    CacheSize=100           # specifies the number of readings core data is allowed to have before a delete is triggered.  This configuration is only used when CacheDelete="OnCount"
    DeleteSize=10           # specifies the number of readings to remove when the cache size is exceeded.  This configuration is only used when CacheDelete="OnCount"
```
## Decision

## Consequences

One of the chief purposes of the core data cache and get latest mechanisms is to allow core command to when to query a device service and when to use existing captured sensor data.

Core command will be changed so that on any GET query operation, core command will be provided with a new query parameter (`UseCache`).  When `UseCache` is specified, core command will go to core data first to retrieve the latest reading values (versus hitting the device service for the reading).  If `UseCache` is not specified, then core command will go to the device service to get the reading value.

## References

- [Core data API reference](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-data/2.1.0)


