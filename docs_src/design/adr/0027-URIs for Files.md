# URIs for Files ADR
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [approved ](https://github.com/edgexfoundry/edgex-docs/pull/949) (2023-02-14)

## Referenced Use Case(s)
- [URIs for Files UCR](https://docs.edgexfoundry.org/3.0/design/ucr/URIs-for-Files/)

## Context
Currently, in the Levski and earlier releases services can only load configuration, units of measurements, device profiles, device definitions, provision watches, etc. from the local file system. As outlined in the reference UCR, there is a need to be able to load files from a remote locations using URIs to specify the locations. 

## Proposed Design
This ADR proposes a new helper function for loading files be added to `go-mod-bootstrap`. This function will provide the logic for loading a file either from local file system (as is today) or from a remote location. As stated in the UCR, only **HTTP** and **HTTPS** URIs will be supported. For **HTTPS**, certificate validation will be performed using the system's built-in trust anchors. The docker images for all services will have the CA certs installed as is done here in App Service Configurable's [Dockerfile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.3.0/Dockerfile#L46).

### Authentication 

#### username-password in URI

While not recommended, users will be able to specify **username-password** (`<username>:<password>@`) in the URI in plain text. While this is ok network wise when using HTTPS, it isn't good practice to have these credentials specified in configuration or other service files where the URI is specified.

!!! example - "Example plain text `username-password` in URI located in configuration"
    ```toml
    [UoM]
    UoMFile = "https://myuser:mypassword@example.com/uom.yaml"
    ```

#### Secure Credentials

In order to provide a secure way for users to specify credentials, the `edgexSecretName` query parameter can be specified on the URI. This parameter specifies a Secret Name from the service's Secret Store where the credentials reside and will be processed by the new helper function.

!!! example - "Example URI with `edgexSecretName` query parameter"
    ```toml
    [UoM]
    UoMFile = "https://example.com/uom.yaml?edgexSecretName=mySecretName"
    ```    

The type of authentication as well as the credentials will be contained in the secret data specified by the Secret Name. Only one type of authentication will be supported initially, which is `httpheader`. The `httpheader`type  will accommodate various forms of authorization placed in the header. Others types can be added in the future when need is determined.

!!! note
    Digest Auth will not be supported at this time. It can be added in the future based on feedback indicating its need.
    
- When `httpheader` is specified as the type in the secret data, the header name and contents from the secret data  will be placed in the HTTP header. 

    !!! example - "Example secret data - `Basic Auth` using  `httpheader`"
        ```
        type=httpheader
        headername=Authorization
        headercontents=Basic bXl1c2VyOm15cGFzc3dvcmQ=
        ```
        For a request header set as:
        ```
        GET https://example.com/uom.yaml HTTP/1.1
        Authorization: Basic bXl1c2VyOm15cGFzc3dvcmQ=
        ```
    
    !!! example - "Example secret data - `API-Key` using  `httpheader`"
        ```
        type=httpheader
        headername=X-API-KEY
        headercontents=abcdef12345
        ```
        For a request header set as:
        ```
        GET https://example.com/uom.yaml HTTP/1.1
        X-API-KEY: abcdef12345
        
        ```
    
    !!! example - "Example secret data - `Bearer` using `httpheader`"
        ```
        type=httpheader
        headername=Authorization
        headercontents=Bearer eyJhbGciO...
        ```
        For a request header set as:
        ```
        GET https://example.com/uom.yaml HTTP/1.1
        Authorization: Bearer eyJhbGciO...
        ```

### Services/Files Impacted

- **All Services** will be impacted for enabling the loading the **common configuration** and **private configuration** files using URIs. This will be handled in `go-mod-bootstrap's` processing of the `-cc/--commonConfig` and `-cf/--configFile` command line flags.

- **Core Metadata's** loading of the **UOM file** will be adjusted to use the new file load function.

- **Device Service's** loading of **device profiles**, **device definitions** and **provision watchers** files will be adjusted to load an index file specified by a URI in place of the configured folder name. The contents of the index file will be used to load the individual files by URI  by appending the filenames to the original URI. Any authentication specified in the original URI will be used in the subsequent URIs. 

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
- Debug logging of URI must obscure the credentials when **username-password** is used in the URI.

## Decision

Implement as designed above

## Other Related ADRs
- None

## References
- [Uniform Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) 
