# Secret Provider for All

- [Status](#status)
- [Context](#context)
  * [Existing Implementations](#existing-implementations)
    + [What is a Secret?](#what-is-a-secret)
    + [Service Exclusive vs Service Shared Secrets](#service-exclusive-vs-service-shared-secrets)
    + [Known and Unknown Services](#known-and-unknown-services)
    + [Static Secrets and Runtime Secrets](#static-secrets-and-runtime-secrets)
    + [Interfaces and factory methods](#interfaces-and-factory-methods)
      - [Bootstrap's current implementation](#bootstraps-current-implementation)
        * [Interfaces](#interfaces)
        * [Factory and bootstrap handler methods](#factory-and-bootstrap-handler-methods)
      - [App SDK's current implementation](#app-sdks-current-implementation)
        * [Interface](#interface)
        * [Factory and bootstrap handler methods](#factory-and-bootstrap-handler-methods)
    + [Secret Store for non-secure mode](#secret-store-for-non-secure-mode)
      - [InsecureSecrets Configuration](#insecuresecrets-configuration)
- [Decision](#decision)
  * [Only Exclusive Secret Stores](#only-exclusive-secret-stores)
  * [Abstraction Interface](#abstraction-interface)
  * [Implementation](#implementation)
    + [Factory Method and Bootstrap Handler](#factory-method-and-bootstrap-handler)
    + [Caching of Secrets](#caching-of-secrets)
    + [Insecure Secrets](#insecure-secrets)
      - [Handling on-the-fly changes to `InsecureSecrets`](#handling-on-the-fly-changes-to-insecuresecrets)
    + [Mocks](#mocks)
    + [Where will `SecretProvider` reside?](#where-will-secretprovider-reside)
      - [Go Services](#go-services)
      - [C Device Service](#c-device-service)
  * [Consequences](#consequences)

## Status

**Approved**

## Context

This ADR defines the new `SecretProvider` abstraction that will be used by all EdgeX services, including Device Services. The Secret Provider is used by services to retrieve secrets from the Secret Store. The Secret Store, in secure mode, is currently Vault. In non-secure mode it is configuration in some form, i.e. `DatabaseInfo` configuration or `InsecureSecrets` configuration for Application Services.

### Existing Implementations

The Secret Provider abstraction defined in this ADR is based on the Secret Provider abstraction implementations in the Application Functions SDK (App SDK) for Application Services and the one in go-mod-bootstrap (Bootstrap) used by the Core, Support & Security services in edgex-go. Device Services do not currently use secure secrets. The App SDK implementation was initially based on the Bootstrap implementation.

The similarities and differences between these implementations are:

- Both wrap the `SecretClient` from go-mod-secrets
- Both initialize the `SecretClient` based on the `SecretStore` configuration(s)
- Both have factory methods, but they differ greatly
- Both implement the `GetDatabaseCredentials` API
- Bootstrap's uses split interfaces definitions (`CredentialsProvider` & `CertificateProvider`) while the App SDK's use a single interface (`SecretProvider`) for the abstraction 
- Bootstrap's includes the bootstrap handler while the App SDK's has the bootstrap handler separated out
- Bootstrap's implements the `GetCertificateKeyPair` API, which the App SDK's does not
- App SDK's implements the following, which the Bootstrap's does not
  - `Initialize` API (Bootstrap's initialization is done by the bootstrap handler)
  - `StoreSecrets` API 
  - `GetSecrets` API
  - `InsecureSecretsUpdated` API
  - `SecretsLastUpdated` API
  - Wraps a second `SecretClient` for the Application Service instance's exclusive secrets.
    - Used by the `StoreSecrets` & `GetSecrets` APIs
  - The standard `SecretClient` is considered the shared client for secrets that all Application Service instances share. It is only used by the `GetDatabaseCredentials` API
  - Configuration based secret store for non-secure mode called `InsecureSecrets`
  - Caching of secrets
    - Needed so that secrets used by pipeline functions do not cause call out to Vault for every Event processed

#### What is a Secret?

A secret is a collection of key/value pairs stored in a `SecretStore` at specified path whose values are sensitive in nature. Redis database credentials are an example of a `Secret` which contains the `username` and `password` key/values stored at the `redisdb` path.

#### Service Exclusive vs Service Shared Secrets

**Service Exclusive** secrets are those that are exclusive to the instance of the running service. An example of exclusive secrets are the HTTP Auth tokens used by two running instances of app-service-configurable (http-export) which export different device Events to different endpoints with different Auth tokens in the HTTP headers.  Service Exclusive secrets are seeded by POSTing the secrets to the `/api/vX/secrets` endpoint on the running instance of each Application Service.

**Service Shared** secrets are those that all instances of a class of service, such a Application Services, share. Think of Core Data as it own class of service. An example of shared secrets are the database credentials for the single database instance for Store and Forward data that all Application Services may need to access. Another example is the database credentials for each of instance the Core Data. It is shared, but only one instance of Core Data is currently ever run. Service Shared secrets are seeded by security-secretstore-setup using static configuration for static secrets for known services. Currently database credentials are the only shared secrets. In the future we may have Message Bus credentials as shared secrets, but these will be truly shared secrets for all services to securely connect to the Message Bus, not just shared between instances of a service.

Application Services currently have the ability to configure `SecretStores` for **Service Exclusive** and/or **Service Shared** secrets depending on their needs.

#### Known and Unknown Services 

- **Known Services** are those identified in the static configuration by security-secretstore-setup
  
  - These currently are Core Data, Core Metadata, Support Notifications, Support Scheduler and Application Service (class)
  
- **Unknown Services** are those not known in the static configuration that become known when added to the Docker compose file or Snap. 

  - Application Service (instance) are examples of these services. 

  - Service exclusive `SecretStore` can be created for these services by adding the services' unique name , i.e. appservice-http-export, to the `EDGEX_ADD_SECRETSTORE_TOKENS` environment variable for security-secretstore-setup

    ```
    EDGEX_ADD_SECRETSTORE_TOKENS: "appservice-http-export, appservice-mqtt-export"
    ```

    This creates an exclusive secret store token for each service listed. The name provided for each service must be used in the service's `SecretStore` configuration and Docker volume mount  (if applicable). Typically the configuration is set via environment overrides or is already in an existing configuration profile (***http-export*** profile for app-service-configurable). 

    Example docker-compose file entries:

    ```yaml
    environment:
        ...
    	SecretStoreExclusive_Path: "/v1/secret/edgex/appservice-http-export/"
    	TokenFile: "/tmp/edgex/secrets/appservice-http-export/secrets-token.json"
    	
    volumes:
    	...
    	- /tmp/edgex/secrets/appservice-http-export:/tmp/edgex/secrets/appservice-http-export:ro,z
    ```

#### Static Secrets and Runtime Secrets

- **Static Secrets** are those identified by name in the static configuration whose values are randomly generated at seed time. These secrets are seeded on start-up of EdgeX.
  - Database credentials are currently the only secrets of this type

- **Runtime Secrets** are those not known in the static configuration and that become known during run time. These secrets are seeded at run time via the Application Services `/api/vX/secrets` endpoint
  -  HTTP header authorization credentials for HTTP Export are types of these secrets

#### Interfaces and factory methods

##### Bootstrap's current implementation

###### Interfaces

```go
type CredentialsProvider interface {
	GetDatabaseCredentials(database config.Database) (config.Credentials, error)
}
```

and

```go
type CertificateProvider interface {
	GetCertificateKeyPair(path string) (config.CertKeyPair, error)
}
```

###### Factory and bootstrap handler methods

```go
type SecretProvider struct {
	secretClient pkg.SecretClient
}

func NewSecret() *SecretProvider {
	return &SecretProvider{}
}

func (s *SecretProvider) BootstrapHandler(
	ctx context.Context,
	_ *sync.WaitGroup,
	startupTimer startup.Timer,
	dic *di.Container) bool {
    ...
    Intializes the SecretClient and adds it to the DIC for both interfaces.
    ...
}
```

##### App SDK's current implementation

###### Interface

```go
type SecretProvider interface {
	Initialize(_ context.Context) bool
	StoreSecrets(path string, secrets map[string]string) error
	GetSecrets(path string, _ ...string) (map[string]string, error)
	GetDatabaseCredentials(database db.DatabaseInfo) (common.Credentials, error)
	InsecureSecretsUpdated()
	SecretsLastUpdated() time.Time
}
```

###### Factory and bootstrap handler methods

```go
type SecretProviderImpl struct {
	SharedSecretClient    pkg.SecretClient
	ExclusiveSecretClient pkg.SecretClient
	secretsCache          map[string]map[string]string // secret's path, key, value
	configuration         *common.ConfigurationStruct
	cacheMuxtex           *sync.Mutex
	loggingClient         logger.LoggingClient
	//used to track when secrets have last been retrieved
	LastUpdated time.Time
}

func NewSecretProvider(
    loggingClient logger.LoggingClient, 
    configuration *common.ConfigurationStruct) *SecretProviderImpl {
	sp := &SecretProviderImpl{
		secretsCache:  make(map[string]map[string]string),
		cacheMuxtex:   &sync.Mutex{},
		configuration: configuration,
		loggingClient: loggingClient,
		LastUpdated:   time.Now(),
	}

	return sp
}
```

```go
type Secrets struct {
}

func NewSecrets() *Secrets {
	return &Secrets{}
}

func (_ *Secrets) BootstrapHandler(
	ctx context.Context,
	_ *sync.WaitGroup,
	startupTimer startup.Timer,
	dic *di.Container) bool {
    ...
    Creates NewNewSecretProvider, calls Initailizes() and adds it to the DIC
    ...
}
```

#### Secret Store for non-secure mode

Both Bootstrap's and App SDK's implementation use the `DatabaseInfo` configuration for `GetDatabaseCredentials` API in non-secure mode. The App SDK only uses it, for backward compatibility,  if the database credentials are not found in the new `InsecureSecrets` configuration section. For Ireland it was planned to only use the new `InsecureSecrets` configuration section in non-secure mode.

> *Note: Redis credentials are `blank` in non-secure mode*

Core Data

```toml
[Databases]
  [Databases.Primary]
  Host = "localhost"
  Name = "coredata"
  Username = ""
  Password = ""
  Port = 6379
  Timeout = 5000
  Type = "redisdb"
```

Application Services

```toml
[Database]
Type = "redisdb"
Host = "localhost"
Port = 6379
Username = ""
Password = ""
Timeout = "30s"
```

##### InsecureSecrets Configuration

The App SDK defines a new `Writable` configuration section called `InsecureSecrets`. This structure mimics that of the secure `SecretStore` when `EDGEX_SECURITY_SECRET_STORE`environment variable is set to `false`. Having the `InsecureSecrets` in the `Writable`  section allows for the secrets to be updated without restarting the service. Some minor processing must occur when the `InsecureSecrets ` section is updated. This is to call the `InsecureSecretsUpdated` API. This API simply sets the time the secrets were last updated. The `SecretsLastUpdated` API returns this timestamp so pipeline functions that use credentials for exporting know if their client needs to be recreated with new credentials, i.e MQTT export.

```go
type WritableInfo struct {
	LogLevel        string
	...
	InsecureSecrets InsecureSecrets
}

type InsecureSecrets map[string]InsecureSecretsInfo

type InsecureSecretsInfo struct {
	Path    string
	Secrets map[string]string
}
```

```toml
[Writable.InsecureSecrets]
    [Writable.InsecureSecrets.DB]
    	path = "redisdb"
    	[Writable.InsecureSecrets.DB.Secrets]
            username = ""
            password = ""
    [Writable.InsecureSecrets.mqtt]
    	path = "mqtt"
    	[Writable.InsecureSecrets.mqtt.Secrets]
            username = ""
            password = ""
            cacert = ""
            clientcert = ""
            clientkey = ""
```

## Decision

The new `SecretProvider` abstraction defined by this ADR is a combination of the two implementations described above in the [Existing Implementations](#existing-implementations) section.

### Only Exclusive Secret Stores

To simplify the `SecretProvider` abstraction, we need to reduce to using only exclusive `SecretStores`. This allows all the APIs to deal with a single `SecretClient`, rather than the split up way we currently have in Application Services. This requires that the current Application Service shared secrets (database credentials) must be copied into each Application Service's exclusive `SecretStore` when it is created.

The challenge is how do we seed static secrets for unknown services when they become known.  As described above in the [Known and Unknown Services](#known-and-unknown-services) section above,  services currently identify themselves for exclusive `SecretStore` creation via the `EDGEX_ADD_SECRETSTORE_TOKENS` environment variable on security-secretstore-setup. This environment variable simply takes a comma separated list of service names.

```yaml
EDGEX_ADD_SECRETSTORE_TOKENS: "<service-name1>,<service-name2>"
```

If we expanded this to add an optional list of static secret identifiers for each service, i.e.  `appservice/redisdb`, the exclusive store could also be seeded with a copy of static shared secrets. In this case the Redis database credentials for the Application Services' shared database. The environment variable name will change to `ADD_SECRETSTORE` now that it is more than just tokens.

```yaml
ADD_SECRETSTORE: "app-service-xyz[appservice/redisdb]"
```

> *Note: The secret identifier here is the short path to the secret in the existing **appservice**  `SecretStore`. In the above example this expands to the full path of `/secret/edgex/appservice/redisdb`*

The above example results in the Redis credentials being copied into app-service-xyz's `SecretStore` at `/secret/edgex/app-service-xyz/redis`.

Similar approach could be taken for Message Bus credentials where a common `SecretStore` is created with the Message Bus credentials saved. The services request the credentials are copied into their exclusive `SecretStore` using `common/messagebus` as the secret identifier.

Full specification for the environment variable's value is a comma separated list of service entries defined as:

```
<service-name1>[optional list of static secret IDs sperated by ;],<service-name2>[optional list of static secret IDs sperated by ;],...
```

Example with one service specifying IDs for static secrets and one without static secrets 

```yaml
ADD_SECRETSTORE: "appservice-xyz[appservice/redisdb; common/messagebus], appservice-http-export"
```

When the `ADD_SECRETSTORE` environment variable is processed to create these `SecretStores`, it will copy the specified saved secrets from the initial `SecretStore` into the service's `SecretStore`. This all depends on the completion of database or other credential bootstrapping and the secrets having been stored prior to the environment variable being processed. security-secretstore-setup will need to be refactored to ensure this sequencing.

### Abstraction Interface

The following will be the new `SecretProvider` abstraction interface used by all Edgex services

```go
type SecretProvider interface {
    // Stores new secrets into the service's exclusive SecretStore at the specified path.
    StoreSecrets(path string, secrets map[string]string) error
    // Retrieves secrets from the service's exclusive SecretStore at the specified path.
    GetSecrets(path string, _ ...string) (map[string]string, error)
    // Sets the secrets lastupdated time to current time. 
    SecretsUpdated()
    // Returns the secrets last updated time
    SecretsLastUpdated() time.Time
}
```

> *Note: The `GetDatabaseCredentials` and `GetCertificateKeyPair` APIs have been removed. These are no longer needed since insecure database credentials will no longer be stored in the `DatabaseInfo` configuration and certificate key pairs are secrets like any others. This allows these secrets to be retrieved via the `GetSecrets` API.*

### Implementation

#### Factory Method and Bootstrap Handler

The factory method and bootstrap handler will follow that currently in the Bootstrap implementation with some tweaks. Rather than putting the two split interfaces into the DIC, it will put just the single interface instance into the DIC. See details in the [Interfaces and factory methods](#interfaces-and-factory-methods) section above under **Existing Implementations**.

#### Caching of Secrets

Secrets will be cached as they are currently in the Application Service implementation

#### Insecure Secrets

Insecure Secrets will be handled as they are currently in the Application Service implementation. `DatabaseInfo` configuration will no longer be an option for storing the insecure database credentials. They will be stored in the `InsecureSecrets` configuration only.

```toml
[Writable.InsecureSecrets]
    [Writable.InsecureSecrets.DB]
    	path = "redisdb"
    	[Writable.InsecureSecrets.DB.Secrets]
            username = ""
            password = ""
```

##### Handling on-the-fly changes to `InsecureSecrets`

All services will need to handle the special processing when `InsecureSecrets` are changed on-the-fly via Consul. Since this will now be a common configuration item in `Writable` it can be handled in `go-mod-bootstrap` along with existing log level processing. This special processing will be taken from App SDK.

#### Mocks

Proper mock of the `SecretProvider` interface will be created with `Mockery` to be used in unit tests. Current mock in App SDK is hand written rather then generated with `Mockery`.

#### Where will `SecretProvider` reside?

##### Go Services

The final decision to make is where will this new `SecretProvider` abstraction reside? Originally is was assumed that it would reside in `go-mod-secrets`, which seems logical. If we were to attempt this with the implementation including the bootstrap handler, `go-mod-secrets` would have a dependency on `go-mod-bootstrap` which will likely create a circular dependency. 

Refactoring the existing implementation in `go-mod-bootstrap` and have it reside there now seems to be the best choice.

##### C Device Service

The C Device SDK will implement the same `SecretProvider` abstraction, InsecureSercets configuration and the underling `SecretStore` client.

### Consequences

- All service's will have `Writable.InsecureSecrets` section added to their configuration
- `InsecureSecrets` definition will be moved from App SDK to go-mod-bootstrap
- Go Device SDK will add the SecretProvider to it's bootstrapping 
- C Device SDK implementation could be big lift?
- ` SecretStore`configuration section will be added to all Device Services
- edgex-go services will be modified to use the single `SecretProvider` interface from the DIC in place of current usage of the `GetDatabaseCredentials` and `GetCertificateKeyPair` interfaces.
  - Calls to `GetDatabaseCredentials` and `GetCertificateKeyPair` will be replaced with calls to `GetSecrets` API and appropriate processing of the returned secrets will be added. 
- App SDK will be modified to use `GetSecrets` API in place of the `GetDatabaseCredentials` API
- App SDK will be modified to use the new `SecretProvider` bootstrap handler
- app-service-configurable's configuration profiles as well as all the Application Service examples configurations will be updated to remove the `SecretStoreExclusive` configuration and just use the existing `SecretStore` configuration
- security-secretstore-setup will be enhanced as described in the [Only Exclusive Secret Stores](#only-exclusive-secret-stores) section above
- Adding new services that need static secrets added to their `SecretStore` requires stopping and restarting all the services. The is because security-secretstore-setup has completed but not stopped. If it is rerun without stopping the other services, there tokens and static secrets will have changed. The planned refactor of `security-secretstore-setup` will attempt to resolve this.
- Snaps do not yet support setting the environment variable for adding SecretStore. It is planned for Ireland release.
