# Core Data Cache

## Status

**Draft**

Today, core data micro service serves as the local/edge persistent store.  However, the service does not offer any cache of the latest readings or events that the service collects and persists.  This ADR suggests changes in core data to allow it to serve as more of a cache for the "latest" sensor/device readings.

## Queries to return "Latest"

- addition of GET operations (and API) to return the `latest` events/readings or readings.  
    - query for latest N by device name
    - query for latest N by device resource

## Delete operation to keep only "Latest"

- addition of DELETE operations (and API) to remove all but the `latest` N events/reading from the persistent store
    - all this operation to be used by scheduler service to clean up the database on a scheduled interval

## Specifying "Latest"
`Latest` may be defined differently by organization, use case, etc.

### Questions

- Provide for a default N by configuration and override with parameters to operations?  Or just always provide by operation parameter
- Do we need other queries by other parameters (latest by device profile, by device service, ...)
- Do we want to add anything to scheduler to use the new DELETE