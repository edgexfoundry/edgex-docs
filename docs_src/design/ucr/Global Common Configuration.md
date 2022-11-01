## Global Common Configuration 
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [pending](URL of PR) (2022-11-??)

### Market Segments
- All

### Motivation
Currently the configuration for each of the EdgeX services have many common settings.  Most of these common settings have the same value for every service deployed in a single EdgeX based solution and possible across identical deployments of the same solution. The motivation for the UCR is to reduce this redundancy allowing for better manageability of service configuration across EdgeX services.

### Target Users
- Service Provider
- Software Developer
- Software Deployer
- Software Integrator

### Description
See [Common Configuration](../../../microservices/configuration/CommonConfiguration/#configuration-properties) for complete list of common configuration sections. As stated above most of the values for these common settings are the same across all the EdgeX Services. Below are a couple examples.

!!! example - "Example - Common configuration - **Service** & **Registry**"
    ```toml
    [Service]
    HealthCheckInterval = "10s"
    Host = "localhost" <overriden in compose file for service specific>
    Port = <Service Specific>
    ServerBindAddr = "" # Leave blank so default to Host value unless different value is needed.
    StartupMsg = <Service Specific>
    MaxResultCount = 1024
    MaxRequestSize = 0 # Not curently used. Defines the maximum size of http request body in bytes
    RequestTimeout = "5s"
      [Service.CORSConfiguration]
      EnableCORS = false
      CORSAllowCredentials = false
      CORSAllowedOrigin = "https://localhost"
      CORSAllowedMethods = "GET, POST, PUT, PATCH, DELETE"
      CORSAllowedHeaders = "Authorization, Accept, Accept-Language, Content-Language, Content-Type, X-Correlation-ID"
      CORSExposeHeaders = "Cache-Control, Content-Language, Content-Length, Content-Type, Expires, Last-Modified, Pragma, X-Correlation-ID"
      CORSMaxAge = 3600
    
    ...
    
    [Registry]
    Host = "localhost" <override in compose file same for every service>
    Port = 8500
    Type = "consul"
    ```

In the above example only the  **Port** and **StartupMsg** settings have unique values to that of the default EdgeX deployment values. 


In the Levski release with the addition common security metrics all services must have the **Writable.Telemetry** and **MessageQueue** and sections.

!!! example - "Example - Common configuration -  **Writable.Telemetry** and **MessageQueue**"
    ```toml
      ...
      [Writable.Telemetry]
      Interval = "30s"
      PublishTopicPrefix  = "edgex/telemetry" # /<service-name>/<metric-name> will be added to this Publish Topic prefix
        [Writable.Telemetry.Metrics] # All service's metric names must be present in this list.
        # Service Specifc Metrics
        <Service Specific metric name> = false
        ...
        # Common Security Service Metrics
        SecuritySecretsRequested = false
        SecuritySecretsStored = false
        SecurityConsulTokensRequested = false
        SecurityConsulTokenDuration = false
        [Writable.Telemetry.Tags] # Contains the service level tags to be attached to all the service's metrics
    #    Gateway="my-iot-gateway" # Tag must be added here or via Consul Env Override can only chnage existing value, not added new ones.
    ...
    [MessageQueue]
    Protocol = "redis"
    Host = "localhost" <override in compose file same for every service>
    Port = 6379
    Type = "redis"
    AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
    SecretName = "redisdb"
    PublishTopicPrefix = <Service Specific>
    SubscribeEnabled = <Service Specific>
    SubscribeTopic = <Service Specific>
      [MessageQueue.Topics]
      <service specific name> = <Service specific value>
      ...
      [MessageQueue.Optional]
      # Default MQTT Specific options that need to be here to enable evnironment variable overrides of them
      ClientId = <Service Specific>
      Qos =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
      KeepAlive = "10" # Seconds (must be 2 or greater)
      Retained = "false"
      AutoReconnect = "true"
      ConnectTimeout = "5" # Seconds
      SkipCertVerify = "false"
      # Additional Default NATS Specific options that need to be here to enable evnironment variable overrides of them
      Format = "nats"
      RetryOnFailedConnect = "true"
      QueueGroup = ""
      Durable = ""
      AutoProvision = "true"
      Deliver = "new"
      DefaultPubRetryAttempts = "2"
      Subject = "edgex/#" # Required for NATS Jetstram only for stream autoprovsioning
    ```
In the above example only the **PublishTopicPrefix**, **SubscribeTopic**, **SubscribeEnabled**, **MessageQueue.Topics** and **ClientId** settings have unique values to that of the default EdgeX deployment values. 

!!! note
    In Levski release App Services don't have the **MessageQueue** section and Core Command's is **MessageQueue.Internal**. These inconstancies will be rectified in EdgeX 3.0 so all EdgeX services have the same **MessageQueue** section specified in the same manner. Also in EdgeX 3.0, the **PublishTopicPrefix** and **SubscribeTopic** settings will be replaced by entries in **MessageQueue.Topics**.

There are other similar common sections not shown shown above. As can be seen from the two examples above there is much duplication of configuration settings across all the EdgeX services. This gives rise to the need to have all these common duplicate configuration settings in a single global source. 

### Existing solutions
There are no existing solutions for global configuration for EdgeX since the current configuration implementation is specific to EdgeX.

### Requirements

#### General

- Services shall be able reference a global common configuration in a manner that is flexible for use with and without the Service Provider
- Common environment overrides shall be applied to global common configuration settings only once before the services receive the setting values

    - This avoids the need for duplicate environment overrides on each service in the docker compose files

- Services must be able to override any of the global common configuration settings with local service specific TOML values

    !!! example - "Example Core Data specific **Writable.Telemetry** and **Service** configuration settings in local TOML file"
        ```toml
          [Writable.Telemetry]
            [Writable.Telemetry.Metrics] # All service's metric names must be present in this list.
            EventsPersisted = false
            ReadingsPersisted = false

        ...
        
        [Service]
        Port = 59880
        StartupMsg = "This is the Core Data Microservice"
        ```

- Environment variable overrides shall be applied in the same manner as they are today. 
    - After loaded from file (prior to pushing into the the Configuration Provider) 
    - After loaded from the Configuration Provider

#### With Configuration Provider

- Global common configuration shall be pre-loaded into the Configuration Provider where it is pulled from by each service.
    - How and where the configuration is loaded into the Configuration Provider is left to design
- Pre-loading of global common configuration must have a mechanism to indicate that the configuration pre-load is complete 
- Each service must wait until the global common configuration pre-load is complete.
- Each service's full configuration, global common and local TOML overrides, shall be pushed into the Configuration Provider
    - Once initially loaded the service's full configuration is solely referenced from the Configuration Provider as it is today
- The services shall be notified when a setting in the **Writeable** section of global common configuration has changed. Each service shall consume the updated setting into its on `Writable` section and push the update back into the Configuration Provider under the service's own full configuration
- On subsequent startups each service shall load the global common configuration from the Configuration Provider and merge it with the service's previous complete configuration from the Configuration Provider and push resulting configuration back to service's full configuration in the Configuration Provider

#### Without Configuration Provider

- Services shall have some manner to load a global common configuration TOML file via a URI
    - How to specify the URI is left to design
- Services shall on every start-up create the service's full configuration by merging the global common configuration with the service's local TOML overrides. 
- Services shall **not** be informed when global common configuration has changed and must be restarted to consume the changes.

### Other Related Issues

- TBD UCR for URI for files (Units or Measurements, Config, Profiles, etc.)

### References
- [0001-Registry-Refactor](../../adr/0001-Registy-Refactor/)
- [0005-Service-Self-Config](../../adr/0005-Service-Self-Config/)