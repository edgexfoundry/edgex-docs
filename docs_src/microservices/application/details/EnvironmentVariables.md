---
title: App Services - Environment Variables
---

# Application Services - Environment Variables

See the [Common Environment Variables](../../configuration/CommonEnvironmentVariables.md) section for the list of environment variables common to all EdgeX Services. The remaining in this section are specific to Application Services.

### EDGEX_SERVICE_KEY

This environment variable overrides the [`-sk/--serviceKey` command-line option](CommandLine.md#service-key) and the default set by the application service.

!!! note
    If the name provided contains the text `<profile>`, this text will be replaced with the name of the profile used.

!!! example "Example - Service Key"
    `EDGEX_SERVICE_KEY: app-<profile>-mycloud`    
    `profile: http-export`    
     then service key will be `app-http-export-mycloud`    
