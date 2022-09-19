# Secret Provider API

## Introduction

The SecretProvider API is available to custom Application and Device Services to access the service's Secret Store. This API is available in both secure and non-secure modes. When in secure mode, it provides access to the service's Secret Store in Vault, otherwise it uses the service's `[InsecureSecrets]` configuration section as the Secret Store. See [InsecureSecrets](../../microservices/configuration/CommonConfiguration/#configuration-properties) section here for more details.

## API

### Interface definition

```go
type SecretProvider interface {
	StoreSecret(path string, secrets map[string]string) error
	GetSecret(path string, keys ...string) (map[string]string, error)
	HasSecret(path string) (bool, error)
	ListSecretPaths() ([]string, error)
	SecretsLastUpdated() time.Time
    SecretsUpdated()
	GetAccessToken(tokenType string, serviceKey string) (string, error)
}
```

### StoreSecret

`StoreSecret(path string, secrets map[string]string) error`

Stores new secrets into the service's SecretStore at the specified path (aka secret name). An error is returned if the secrets can not be stored.

!!! note 
    This API is only valid to call when in secure mode. It will return an error when in non-secure mode. Insecure Secrets should be added/updated directly in the configuration file or via the Configuration Provider (aka Consul).

### GetSecret

`GetSecret(path string, keys ...string) (map[string]string, error)`

Retrieves the secrets from the service's SecretStore for the specified path (aka secret name). The list of keys is optional and limits the secret data returned to just those keys specified, otherwise all keys are returned. An error is returned if the path doesn't exist in the service's Secret Store or if one or more of the optional keys specified are not present.

### HasSecret 

`HasSecret(path string) (bool, error)`

Returns true if the service's Secret Store contains a secret at the specified path  (aka secret name) . An error is retuned if the Secret Store can not be accessed.

### ListSecretPaths 

`ListSecretPaths() ([]string, error)`

Returns a list of paths (aka secret names) from the current service's Secret Store. An error is retuned if the Secret Store can not be accessed.

### SecretsLastUpdated 

`SecretsLastUpdated() time.Time`

Returns the timestamp for last time when the service's secrets were updated in its Secret Store. This is useful when using external client that is initialized with the secret and needs to be recreated if the secret has changed. 

### SecretsUpdated - Do not use

`SecretsUpdated()`

Sets the service's secrets last updated time to current time. 

!!! note
    This function is used internally when secrets are update either via `StoreSecret` function or when the writable `InscureSecrets` have been update in the Configuration Provider (aka Consul). **Not useful for an Application or Device service to use and will be hidden in future EdgeX 3.0 release.**

### GetAccessToken  - Do not use

`GetAccessToken(tokenType string, serviceKey string) (string, error)`

Returns an access token for the Configuration Provider or Registry Provider for the specified token type and service key. 

!!! note
    This is used by the internal bootstrapping code and is not useful for an Application or Device service to use. **This API will be hidden in future EdgeX 3.0 release.****

### 
