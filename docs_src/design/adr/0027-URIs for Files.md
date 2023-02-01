# URIs for Files ADR
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [pending ](https://github.com/edgexfoundry/edgex-docs/pull/949) (2023-02-01)

## Referenced Use Case(s)
- [URIs for Files UCR](https://docs.edgexfoundry.org/3.0/design/ucr/URIs-for-Files/)

## Context
Currently, in the Levski and earlier releases services can only load configuration, units of measurements, device profiles, device definitions, provision watches, etc. from the local file system. As outlined in the reference UCR, there is a need to be able to load files from a remote locations using URIs to specify the locations. 

## Proposed Design
This ADR proposes a new helper function for loading files be added to `go-mod-bootstrap`. This function will provide the logic for loading a file either from local file system (as is today) or from a remote location. As stated in the UCR, only **HTTP** and **HTTPS** URIs will be supported. For **HTTPS**, certificate validation will be performed using the system's built-in trust anchors. The docker images for all services will have the CA certs installed as is done here in App Service Configurable's [Dockerfile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.3.0/Dockerfile#L46).

### Authentication 

While not recommended, users will be able to specify **basic-auth** (`<username>:<password>@`) in the URI in plain text. In order to provide a secure way for users to specify credentials, the URI scheme will be expanded to allow specifying a Secret Name from the service's Secret Store. This will take the form  `[secretName:<secret-name>]@`. The type of authentication as well as the credentials will be contained in the secret data specified by the Secret Name. Three types of authentication will be supported, which are `usernamepassword`, `apikey` and `bearertoken`. 

- When `usernamepassword` is specified as the type in the secret data, the `[secretName:<secret-name>]@` text in the URI will be replaced with `username:password@` using the **username** and **password** found in the secret data.

    !!! example - "Example secret data - `usernamepassword`"
        ```
        type=usernamepassword
        username=myuser
        password=mypassword
        ```

- When `apikey` is specified as the type in the secret data, the `[secretName:<secret-name>]@` text will be removed from the URI and the **API Key** will be placed in the HTTP header using `apikeyname` and `apikeyvalue`  from the secret data

    !!! example - "Example secret data - `apikey`"
        ```
        type=apikey
        apikeyvalue=mykeyvalue
        apikeyname=myname
        ```
    
- When `bearertoken` is specified as the type in the secret data, the `[secretName:<secret-name>]@` text will be removed from the URI and the **Bearer Token** will be placed in the HTTP header as  `Authorization` with value of `Bearer <token>`  where `token` is from the secret data. 

    !!! example - "Example secret data - `token`"
        ```
        type=bearertoken
        token=mytoken
        ```

### Services/Files Impacted

- **All Services** will be impacted for enabling the loading the **common configuration** and **private configuration** files using URIs. This will be handled in `go-mod-bootstrap's` processing of the `-cc/--commonConfig` and `-cf/--configFile` command line flags.

- **Core Metadata's** loading of the **UOM file** will be adjusted to use the new file load function.

- **Device Service's** loading of **device profiles**, **device definitions** and **provision watches** files will be adjusted to load an index file specified by a URI in place of the configured folder name. The contents of the index file will be used to load the individual files by URI  by appending the filenames to the original URI. Any authentication specified in the original URI will be used in the subsequent URIs. 

    !!! example - "Example DevicesDir configuration in service configuration" 
        ```toml
        [Device]
          ...
          ProfilesDir = "./res/profiles"
          DevicesDir = "http://example.com/devices/index.json"
          ProvisionWatchersDir = "./res/provisionwatchers"
          ...
        ```
    !!! example - "Example Device Index file `http://example.com/devices/index.json`"
        ```json
        [
            "device1.yaml", "device2.yaml"
        ]
        ```

    !!! example - "Example resulting device file URIs from above example"
        ```
        http://example.com/devices/device1.yaml
        http://example.com/devices/device2.yaml
        ```
## Considerations

- Other files (existing or future) not listed above may also be candidates for using this new URI capability. Those listed above are the most impactful for deployment at scale.

## Decision

Implement as designed above

## Other Related ADRs
- None

## References
- [Uniform Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) 
