## URIs for files
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [approved](https://github.com/edgexfoundry/edgex-docs/pull/938) (2023-01-25)

### Market Segments
- All

### Motivation
Deployment at scale, i.e. identical or almost identical deployments across many locations, would benefit from the ability to load service files from a central location. This would allow the maintainer to make changes once to a shared file and have them apply to all or a subset of deployments. The following are some EdgeX service files that would benefit for this capability:

- [Unit of Measure](https://github.com/edgexfoundry/edgex-go/blob/v2.3.0/cmd/core-metadata/res/uom.toml) file used by Core Metadata

    - Location of this file is specified in configuration [here](https://github.com/edgexfoundry/edgex-go/blob/v2.3.0/cmd/core-metadata/res/configuration.toml#L50) 

- Service Configuration files
    - Location of these files are currently defaulted to be `./res/configuration.toml`, but can be overridden  via -cf/--configFile command line flag.
    - The Common Configuration ADR adds a new [common configuration file](https://docs.edgexfoundry.org/3.0/design/adr/0026-Common%20Configuration/#specifying-the-common-configuration-location) specified via the future -cc/--commonConfig command line flag.

- [Token Configuration](https://github.com/edgexfoundry/edgex-go/blob/v2.3.0/cmd/security-file-token-provider/res/token-config.json) file for Security File Token Provider 

    - This file specifies the list of services to generate Vault tokens for. 

- Device Profiles, Device Definition and Provision Watchers

    - These files can reside in a device services local file system and are pushed to Core Metadata the first time the service starts. Example [here](https://github.com/edgexfoundry/device-onvif-camera/tree/v2.3.0/cmd/res)

    - These files are found by scanning the folders specified in configuration [here](https://github.com/edgexfoundry/device-sdk-go/blob/v2.3.0/example/cmd/device-simple/res/configuration.toml#L119-120)

    !!! note 
        These files are only pushed to Core Metadata the first time the device service is loaded. They are not currently re-pushed once they exist in Core Metadata even when the files have changed locally. Thus updating the files locally or in a shared location will not result in changing the contents of these files in Core Metadata. They still benefit from this capability during initial deployment and when new files are added.  


Currently all files loaded by services are expected to be on the local file system, thus are duplicated many times when deploying at scale.

### Target Users
- Software Deployer
- Software Integrator

### Description
This UCR proposes to enhance loading of files in EdgeX by allowing the location of the file to be optionally specified as an URI.

### Existing solutions
Loading shared files via a URI is not new in the software industry. Here is the Wiki page for [Uniform Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) 

### Requirements
- Single EdgeX service files shall optionally be loaded via a specified URI. 
- Sets of EdgeX service files (i.e. device service files) shall optionally be loaded via a URI. Details on how are left to the ADR.
- The URIs specified shall follow the [Uniform Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) spec when authentication not required or using **basic-auth** in plain text in the URI,  i.e. `username:password@`
  - Only the `http` and `https` schemes from the above spec shall be supported as well as `plain paths` as is today
  - The `file` scheme shall not be supported as it doesn't allow for relative paths
  
- The URI spec shall be extended to allow the specifying of EdgeX service secrets from the service's Secret Store in order to avoid credentials in plain text. Details on how are left to the ADR.

### Other Related Issues
- [Common Configuration ADR](https://docs.edgexfoundry.org/3.0/design/adr/0026-Common%20Configuration/): This ADR specifies that the common configuration file specified by the `-cc/--commonConfig` flag can be a URI to a remote files. The implementation of this portion of the ADR is dependent on the UCR and following ADR.

### References
- None
