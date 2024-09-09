---
title: App Services - Command-line Options
---

# Application Services - Command-line Options

See the [Common Command Line Options](../../configuration/CommonCommandLineOptions.md) for the set of command line options common to all EdgeX services. The following command line options are specific to Application Services.

### Skip Version Check

`-s/--skipVersionCheck`

Indicates the service should skip the Core Service's version compatibility check.

### Service Key

`-sk/--serviceKey`

Sets the service key that is used with Registry, Configuration Provider and security services. The default service key is set by the application service. If the name provided contains the placeholder text `<profile>`, this text will be replaced with the name of the profile used. If profile is not set, the `<profile>` text is simply removed

Can be overridden with [EDGEX_SERVICE_KEY](EnvironmentVariables.md#edgex_service_key) environment variable.

