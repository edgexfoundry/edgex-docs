---
title: Device Service - Environment Variables
---

# Device Service - Environment Variables

See the [Common Environment Variables](../../configuration/CommonEnvironmentVariables.md) section for the list of environment variables common to all EdgeX Services. The remaining in this section are specific to Device Service.

### Running multiple instances

`--instance` or `-i`

This allows for running multiple instances of a device service in an EdgeX deployment, by giving them different names. For example, running `device-modbus -i 1` results in a service named `device-modbus_1`, ie the parameter given to the `instance` argument is added as a suffix to the device service name. The same effect may be obtained by setting the `EDGEX_INSTANCE_NAME` environment variable.

