# Core Data

## Architecture Reference

For a description of the architecture, see
[Core-Data](../../microservices/core/data/Ch-CoreData.md)

## Introduction

EdgeX Foundry Core Data Service includes the device and sensor collected
data database and APIs to expose the database to other services as well
as north-bound integration. The database is secure. Direct access to the
database is restricted to the Core Data service APIs. Core Data also
provides the REST API to create and register a new device.

<https://github.com/edgexfoundry/edgex-go/blob/master/api/raml/core-data.raml>

[Core Data V1 API Swagger Documentation](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-data/1.1.0)
<!-- [Core Data API HTML Documentation](core-data.html) -->
