# Logging

![image](EdgeX_SupportingServicesLogging.png)

## Deprecation Notice

Please note that the logging service has been **deprecated with the Geneva release (v1.2)**.  The EdgeX community feels that there are better log aggregation services available in the open source community or by deployment/orchestration tools.

Starting with the Geneva release, logging service will no longer be started as part of the reference implementations provided through the EdgeX Docker Compose files (the service is still available but commented out in those files).

By default, all services now log to standard out (EnableRemote is set to false and File is set to '').  If users wish to still use the central logging service, they must configure each service to use it (set EnableRemote=true).  Users can still alternately choose to have the services log to a file with additional configuration changes (set File to the appropriate file location).

The Support Logging Service will removed in a future release of EdgeX Foundry.

## Logging Service Documentation

For information on the logging service, see the Fuji release [logging service documentation](https://fuji-docs.edgexfoundry.org/Ch-Logging.html).