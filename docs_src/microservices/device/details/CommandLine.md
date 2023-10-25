---
title: Device Service - Running multiple instances
---

# Device Service - Command-line Options

See the [Common Command Line Options](../../configuration/CommonCommandLineOptions.md) for the set of command line options common to all EdgeX services. The following command line options are specific to Device Service.

### Running multiple instances

`--instance` or `-i`

This allows for running multiple instances of a device service in an EdgeX deployment, by giving them different names. For example, running `device-modbus -i 1` results in a service named `device-modbus_1`, ie the parameter given to the `instance` argument is added as a suffix to the device service name. The same effect may be obtained by setting the `EDGEX_INSTANCE_NAME` environment variable.

