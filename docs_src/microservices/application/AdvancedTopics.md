# Advanced Topics

The following items discuss topics that are a bit beyond the basic use cases of the Application Functions SDK when interacting with EdgeX.

### Configurable Functions Pipeline

This SDK provides the capability to define the functions pipeline via configuration rather than code by using the **app-service-configurable** application service. See the [App Service Configurable](./AppServiceConfigurable.md) section for more details.

### Using The Webserver

It is not uncommon to require your own API endpoints when building an app service. Rather than spin up your own webserver inside of your app (alongside the already existing running webserver), we've exposed a method that allows you add your own routes to the existing webserver. A few routes are reserved and cannot be used:

- /api/version
- /api/v1/ping
- /api/v1/metrics
- /api/v1/config
- /api/v1/trigger
- /api/v1/secrets

To add your own route, use the `AddRoute(route string, handler func(nethttp.ResponseWriter, *nethttp.Request), methods ...string) error` function provided on the SDK. Here's an example:

```go
edgexSdk.AddRoute("/myroute", func(writer http.ResponseWriter, req *http.Request) {
    context := req.Context().Value(appsdk.SDKKey).(*appsdk.AppFunctionsSDK) 
		context.LoggingClient.Info("TEST") // alternative to edgexSdk.LoggingClient.Info("TEST")
		writer.Header().Set("Content-Type", "text/plain")
		writer.Write([]byte("hello"))
		writer.WriteHeader(200)
}, "GET")
```
Under the hood, this simply adds the provided route, handler, and method to the gorilla `mux.Router` we use in the SDK. For more information on `gorilla mux` you can check out the github repo [here](https://github.com/gorilla/mux). 
You can access the resources such as the logging client by accessing the context as shown above -- this is useful for when your routes might not be defined in your main.go where you have access to the `edgexSdk` instance.

### Target Type

The target type is the object type of the incoming data that is sent to the first function in the function pipeline. By default this is an EdgeX `Event` since typical usage is receiving `events` from Core Data via Message Bus. 

For other usages where the data is not `events` coming from Core Data, the `TargetType` of the accepted incoming data can be set when the SDK instance is created. There are scenarios where the incoming data is not an EdgeX `Event`. One example scenario is 2 application services are chained via the Message Bus. The output of the first service back to the Message Bus is inference data from analyzing the original input `Event`data.  The second service needs to be able to let the SDK know the target type of the input data it is expecting.

For usages where the incoming data is not `events`, the `TargetType` of the excepted incoming data can be set when the SDK instance is created. 

Example:

``` go
type Person struct {
    FirstName string `json:"first_name"`
    LastName  string `json:"last_name"`
}

edgexSdk := &appsdk.AppFunctionsSDK {
	ServiceKey: serviceKey, 
	TargetType: &Person{},
}
```

`TargetType` must be set to a pointer to an instance of your target type such as `&Person{}` . The first function in your function pipeline will be passed an instance of your target type, not a pointer to it. In the example above, the first function in the pipeline would start something like:

``` go
func MyPersonFunction(edgexcontext *appcontext.Context, params ...interface{}) (bool, interface{}) {

	edgexcontext.LoggingClient.Debug("MyPersonFunction")

	if len(params) < 1 {
		// We didn't receive a result
		return false, nil
	}

	person, ok := params[0].(Person)
	if !ok {
        return false, errors.New("type received is not a Person")
	}
	
	// ....
```

The SDK supports un-marshaling JSON or CBOR encoded data into an instance of the target type. If your incoming data is not JSON or CBOR encoded, you then need to set the `TargetType` to  `&[]byte`.

If the target type is set to `&[]byte` the incoming data will not be un-marshaled.  The content type, if set, will be passed as the second parameter to the first function in your pipeline.  Your first function will be responsible for decoding the data or not.

### Command Line Options

The following command line options are available

```
  -c=<path>
  --confdir=<path>
        Specify an alternate configuration directory.
        
  -p=<profile>
  --profile=<profile>
        Specify a profile other than default.
  -f, 
  --file <name>               
  		Indicates name of the local configuration file. Defaults to configuration.toml

  -cp=<url>
  --configProvider=<url>           
  		Indicates to use Configuration Provider service at specified URL.
        URL Format: {type}.{protocol}://{host}:{port} ex: consul.http://localhost:8500
        No url, i.e. -cp, defaults to consul.http://localhost:8500
  -o    
  -overwrite
        Force overwrite configuration in the Configuration Provider with local values.
        
  -r    
  --registry
        Indicates the service should use the service Registry.
                
  -s    
  -skipVersionCheck
        Indicates the service should skip the Core Service's version compatibility check.
    
  -sk
  --serviceKey                
        Overrides the service key used with Registry and/or Configuration Providers.
        If the name provided contains the text `<profile>`, this text will be 
        replaced with the name of the profile used. 
```

Examples:

``` bash
simple-filter-xml -c=./res -p=http-export
```

or

``` bash
simple-filter-xml --confdir=./res -p=http-export -cp=consul.http://localhost:8500 --registry
```

### Environment Variable Overrides

All the configuration settings from the configuration.toml file can be overridden by environment variables. The environment variable names have the following format:

```toml
<TOML KEY>
<TOML SECTION>_<TOML KEY>
<TOML SECTION>_<TOML SUB-SECTION>_<TOML KEY>
```

!!! note
    With the Geneva release CamelCase environment variable names are deprecated. Instead use all uppercase environment variable names as in the example below.

Examples:

```toml
TOML   : FailLimit = 30
ENVVAR : FAILLIMIT=100

TOML   : [Logging]
		 EnableRemote = false
ENVVAR : LOGGING_ENABLEREMOTE=true

TOML   : [Clients]
  			[Clients.CoreData]
  			Host = 'localhost'
ENVVAR : CLIENTS_COREDATA_HOST=edgex-core-data
```

#### EDGEX_SERVICE_KEY

This environment variable overrides the service key used with the Configuration and/or Registry providers. Default is set by the application service. Also overrides any value set with the -sk/--serviceKey command-line option.

!!! note
    If the name provided contains the text `<profile>`, this text will be replaced with the name of the profile used.

!!! example
    `EDGEX_SERVICE_KEY: AppService-<profile>-mycloud` and if `profile: http-export` then service key will be "AppService-http-export-mycloud"


### EDGEX_CONFIGURATION_PROVIDER

This environment variable overrides the Configuration Provider connection information. The value is in the format of a URL.

```
EDGEX_CONFIGURATION_PROVIDER=consul.http://edgex-core-consul:8500

This sets the Configration Provider information fields as follows:
    Type: consul
    Host: edgex-core-consul
    Port: 8500
```

#### edgex_registry (DEPRECATED)

This environment variable overrides the Registry connection information and occurs every time the application service starts. The value is in the format of a URL.

!!! note
    This environment variable override has been deprecated in the Geneva Release. Instead, use configuration overrides of **REGISTRY_PROTOCOL** and/or **REGISTRY_HOST** and/or **REGISTRY_PORT**

```
EDGEX_REGISTRY=consul://edgex-core-consul:8500

This sets the Registry information fields as follows:
    Type: consul
    Host: edgex-core-consul
    Port: 8500
```

#### edgex_service (DEPRECATED)

This environment variable overrides the Service connection information. The value is in the format of a URL.

!!! note
    This environment variable override has been deprecated in the Geneva Release. Instead, use configuration overrides of **SERVICE_PROTOCOL** and/or **SERVICE_HOST** and/or **SERVICE_PORT**

```
EDGEX_SERVICE=http://192.168.1.2:4903

This sets the Service information fields as follows:
    Protocol: http
    Host: 192.168.1.2
    Port: 4903
```

#### EDGEX_PROFILE

This environment variable overrides the command line `profile` argument. It will set the `profile` or replace the value passed via the `-p` or `--profile`, if one exists. This is useful when running the service via docker-compose.

!!! note
    The lower case version has been deprecated in the Geneva release. Instead use upper case version **EDGEX_PROFILE**

Using docker-compose:

```
  app-service-configurable-rules:
    image: edgexfoundry/docker-app-service-configurable:1.1.0
    environment: 
      - EDGEX_PROFILE : "rules-engine"
    ports:
      - "48095:48095"
    container_name: edgex-app-service-configurable
    hostname: edgex-app-service-configurable
    networks:
      edgex-network:
        aliases:
          - edgex-app-service-configurable
    depends_on:
      - data
      - command
```

This sets the `profile` so that the application service uses the `rules-engine` configuration profile which resides at `/res/rules-engine/configuration.toml`

!!! note
    EdgeX services no longer use docker profiles. They use Environment Overrides in *the docker compose file to make the necessary changes to the configuration for running in Docker. See the **Environment Variable Overrides For Docker** section in the [App Service Configurable](./AppServiceConfigurable.md#environment-variable-overrides-for-docker) section for more details and an example.

#### EDGEX_STARTUP_DURATION

This environment variable overrides the default duration, 30 seconds, for a service to complete the start-up, aka bootstrap, phase of execution

#### EDGEX_STARTUP_INTERVAL

This environment variable overrides the retry interval or sleep time before a failure is retried during the start-up, aka bootstrap, phase of execution.

#### EDGEX_CONF_DIR

This environment variable overrides the configuration directory where the configuration file resides. Default is `./res` and also overrides any value set with the `-c/--confdir` command-line option.

#### EDGEX_CONFIG_FILE

This environment variable overrides the configuration file name. Default is `configutation.toml` and also overrides any value set with the -f/--file command-line option.

### Store and Forward

The Store and Forward capability allows for export functions to persist data on failure and for the export of the data to be retried at a later time. 

!!! note
    The order the data exported via this retry mechanism is not guaranteed to be the same order in which the data was initial received from Core Data

#### Configuration

Two sections of configuration have been added for Store and Forward.

`Writable.StoreAndForward` allows enabling, setting the interval between retries and the max number of retries. If running with Configuration Provider, these setting can be changed on the fly without having to restart the service.

```toml
  [Writable.StoreAndForward]
  Enabled = false
  RetryInterval = '5m'
  MaxRetryCount = 10
```

!!! note
    RetryInterval should be at least 1 second (eg. '1s') or greater. If a value less than 1 second is specified, 1 second will be used. Endless retries will occur when MaxRetryCount is set to 0. If MaxRetryCount is set to less than 0, a default of 1 retry will be used.

Database describes which database type to use, `mongodb` (DEPRECATED) or `redisdb`, and the information required to connect to the database. This section is required if Store and Forward is enabled, otherwise it is currently optional.

```toml
[Database]
Type = "redisdb"
Host = "localhost"
Port = 6379
Timeout = '30s'
Username = ""
Password = ""
```

#### How it works

When an export function encounters an error sending data it can call `SetRetryData(payload []byte)` on the Context. This will store the data for later retry. If the application service is stopped and then restarted while stored data hasn't been successfully exported, the export retry will resume once the service is up and running again.

!!! note
    It is important that export functions return an error and stop pipeline execution after the call to `SetRetryData`. See [HTTPPost](https://github.com/edgexfoundry/app-functions-sdk-go/blob/master/pkg/transforms/http.go) function in SDK as an example

When the `RetryInterval` expires, the function pipeline will be re-executed starting with the export function that saved the data. The saved data will be passed to the export function which can then attempt to resend the data. 

!!! note
    The export function will receive the data as it was stored, so it is important that any transformation of the data occur in functions prior to the export function. The export function should only export the data that it receives.

One of three out comes can occur after the export retried has completed. 

1. Export retry was successful

    In this case, the stored data is removed from the database and the execution of the pipeline functions after the export function, if any, continues. 

2. Export retry fails and retry count `has not been` exceeded

    In this case, the stored data is updated in the database with the incremented retry count

3. Export retry fails and retry count `has been` exceeded

    In this case, the stored data is removed from the database and never retried again.

!!! note
    Changing Writable.Pipeline.ExecutionOrder will invalidate all currently stored data and result in it all being removed from the database on the next retry. This is because the position of the *export* function can no longer be guaranteed and no way to ensure it is properly executed on the retry.

### Secrets

#### Configuration

All instances of App Services share the same database and database credentials. However, there are secrets for each App Service that are exclusive to the instance running. As a result, two separate configurations for secret store clients are used to manage shared and exclusive application service secrets.

The GetSecrets() and StoreSecrets() calls  use the exclusive secret store client to manage application secrets.

An example of configuration settings for each secret store client is below:

```toml
# Shared Secret Store
[SecretStore]
    Host = 'localhost'
    Port = 8200
    Path = '/v1/secret/edgex/appservice/'
    Protocol = 'https'
    RootCaCertPath = '/tmp/edgex/secrets/ca/ca.pem'
    ServerName = 'edgex-vault'
    TokenFile = '/tmp/edgex/secrets/edgex-appservice/secrets-token.json'
    # Number of attempts to retry retrieving secrets before failing to start the service.
    AdditionalRetryAttempts = 10
    # Amount of time to wait before attempting another retry
    RetryWaitPeriod = "1s"

	[SecretStore.Authentication]
		AuthType = 'X-Vault-Token'	

# Exclusive Secret Store
[SecretStoreExclusive]
    Host = 'localhost'
    Port = 8200
    Path = '/v1/secret/edgex/<app service key>/'
    Protocol = 'https'
    ServerName = 'edgex-vault'
    TokenFile = '/tmp/edgex/secrets/<app service key>/secrets-token.json'
    # Number of attempts to retry retrieving secrets before failing to start the service.
    AdditionalRetryAttempts = 10
    # Amount of time to wait before attempting another retry
    RetryWaitPeriod = "1s"

    [SecretStoreExclusive.Authentication]
    	AuthType = 'X-Vault-Token'
```

#### Storing Secrets

##### Secure Mode

When running an application service in secure mode, secrets can be stored in the secret store (Vault) by making an HTTP `POST` call to the secrets API route in the application service, `http://[host]:[port]/api/v1/secrets`. The secrets are stored and retrieved from the secret store based on values in the *SecretStoreExclusive* section of the configuration file. Once a secret is stored, only the service that added the secret will be able to retrieve it.  For secret retrieval see [Getting Secrets](#getting-secrets).

An example of the JSON message body is below.  

```json
{
  "path" : "MyPath",
  "secrets" : [
    {
      "key" : "MySecretKey",
      "value" : "MySecretValue"
    }
  ]
}
```

!!! note
    Path specifies the type or location of the secrets to store. It is appended to the base path from the SecretStoreExclusive configuration. An empty path is a valid configuration for a secret's location.

##### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration toml file. Insecure secrets and their paths can be configured as below.

```toml
   [Writable.InsecureSecrets]    
      [Writable.InsecureSecrets.AWS]
        Path = 'aws'
        [Writable.InsecureSecrets.AWS.Secrets]
          username = 'aws-user'
          password = 'aws-pw'
      
      [Writable.InsecureSecrets.DB]
        Path = 'redisdb'
        [Writable.InsecureSecrets.DB.Secrets]
          username = ''
          password = ''
```

!!! note
    An empty path is a valid configuration for a secret's location 

#### Getting Secrets

Application Services can retrieve their secrets from the underlying secret store using the [GetSecrets()](#.GetSecrets()) API in the SDK. 

If in secure mode, the secrets are retrieved from the secret store based on the *SecretStoreExclusive* configuration values. 

If running in insecure mode, the secrets are retrieved from the *Writable.InsecureSecrets* configuration.

### Registry Client

**After initialization**, the configured registry client used by the SDK can be retrieved from the sdk instance at .RegistryClient.  It is important to note that sdk.RegistryClient may be nil - either if the SDK is not yet initialized, or if the registry option (-r/--registry) is not specified on start.  Once retrieved the client can be used to look up host information for other services, or perform other operations supported by the registry.Client type in [go-mod-registry](https://github.com/edgexfoundry/go-mod-registry).  For example, to retrieve the URL for a given service:

```go
func(sdk *appsdk.AppFunctionsSDK, serviceKey string) (string, error) {
	if sdk.RegistryClient == nil {
		return "", errors.New("Registry client is not available")
	}

	details, err := sdk.RegistryClient.GetServiceEndpoint(serviceKey)

	if err != nil {
		return "", err
	}

	return fmt.Sprintf("http://%s:%d", details.Host, details.Port), nil
}
```
!!! note Known Service Keys
    Service keys for known EdgeX services can be found under clients in [go-mod-core-contracts](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/constants.go#L58-L72)
		
