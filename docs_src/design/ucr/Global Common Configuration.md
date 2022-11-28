## Global Common Configuration 
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/892) (2022-11-16)

### Motivation
Currently the configuration for all the EdgeX services have many common settings.  Most of these common settings have the same value for every service deployed in a single EdgeX based solution and possible across identical deployments of the same solution. The motivation for the UCR is to limit this redundancy allowing to have a the common settings set one in one location which are across all EdgeX services.

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

In the above example only the  **Port** and **StartupMsg** settings have unique values for each EdgeX Service. 


In the Levski release the additional common security metrics require all services must have the **Writable.Telemetry** and **MessageQueue** and sections.

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

There are other similar common sections not shown above. As can be seen from the two examples above there is much duplication of configuration settings across all the EdgeX services. This gives rise to the need to have all these common duplicate configuration settings in a single global source. 

In addition to the above common settings, Application services and Device services have their own common configuration settings that may have the same values across deployed application or devices services. For Application services these are the **Trigger**,  **Writable.Telemetry.Metrics** and **Clients.core-metadata** configuration sections. For Device services these are the **Device**, **Clients** and **Writable.Telemetry.Metrics** configuration sections.

### Existing solutions
There are no existing solutions for global configuration that would apply to EdgeX since the current configuration implementation is specific to EdgeX. See [0005-Service-Self-Config](../../adr/0005-Service-Self-Config/) for more details on current configuration design.

### Requirements.

#### General

- Services shall be able reference a global common configuration in a manner that is flexible for use with and without the Configuration Provider

- Services must be able to override any of the global common configuration settings with local service specific configuration values

    !!! example - "Example Core Data specific **Writable.Telemetry** and **Service** configuration settings in local configuration file"
        ```toml
          [Writable.Telemetry]
            [Writable.Telemetry.Metrics] # All service's metric names must be present in this list.
            EventsPersisted = false
            ReadingsPersisted = false
        ```

    ```
    
        ...
        
        [Service]
        Port = 59880
        StartupMsg = "This is the Core Data Microservice"
    ```

- Application services shall be able to load separate common configuration specific to Application services

- Device services shall be able to load separate common configuration specific to Device services

- Service shall have a common way to specify the global common configurations to load.

- Secret Store configuration shall no longer be part of the each services' standard configuration as it is needed prior to connecting to the Configuration Provider.

#### With Configuration Provider

- Global common configuration(s) shall be pre-loaded into the Configuration Provider where they are pulled by each service.
- Post bootstrapping, the only the service's private configuration is present in the Configuration Provider under the service specific area.
- The services shall be notified when **Writeable** section of global common configuration(s) have changed. 

#### With file based Configuration Provider

- Services shall have some manner to load global common configuration files via a URI (local file, file via HTTP or HTTPS). 
     HTTP and HTTPS shall be support authentication. 
- Services shall on every start-up create the service's full configuration by merging the global common configuration with the service's local configuration  in such a way the all local settings override any global common settings.
- Services shall **NOT** be informed when global common configuration settings have changed and must be restarted to consume the changes.

### Other Related Issues

- UCR for URI for files (Units or Measurements, Config, Profiles, etc.)
  - Once defined the same URI approach shall be used for loading the global common configuration files from file based Configuration Provider.


### References
- [0001-Registry-Refactor](../../adr/0001-Registy-Refactor/)
- [0005-Service-Self-Config](../../adr/0005-Service-Self-Config/)