# Secret Provider API

## Introduction

!!! Note
    Vault will be deprecated in EdgeX 4.0. OpenBao will be the default secret store for new implementations.

The SecretProvider API is available to custom Application and Device Services to access the service's Secret Store. This API is available in both secure and non-secure modes. When in secure mode, it provides access to the service's Secret Store in Vault, otherwise it uses the service's `[InsecureSecrets]` configuration section as the Secret Store. See [InsecureSecrets](../../microservices/configuration/CommonConfiguration/#configuration-properties) section here for more details.

## API

### Interface definition

```go
type SecretProvider interface {
	StoreSecret(secretName string, secrets map[string]string) error
	GetSecret(secretName string, keys ...string) (map[string]string, error)
    HasSecret(secretName string) (bool, error)
	ListSecretNames() ([]string, error)
	SecretsLastUpdated() time.Time	
    RegisterSecretUpdatedCallback(secretName string, callback func(secretName string)) error
	DeregisterSecretUpdatedCallback(secretName string)
}
```

### StoreSecret

`StoreSecret(secretName string, secrets map[string]string) error`

Stores new secrets into the service's SecretStore at the specified `secretName`. An error is returned if the secrets can not be stored.

!!! note 
    This API is only valid to call when in secure mode. It will return an error when in non-secure mode. Insecure Secrets should be added/updated directly in the configuration file or via the Configuration Provider (aka Consul).

### GetSecret

`GetSecret(secretName string, keys ...string) (map[string]string, error)`

Retrieves the secrets from the service's SecretStore for the specified `secretName`. The list of keys is optional and limits the secret data returned to just those keys specified, otherwise all keys are returned. An error is returned if the `secretName` doesn't exist in the service's Secret Store or if one or more of the optional keys specified are not present.

### HasSecret 

`HasSecret(secretName string) (bool, error)`

Returns true if the service's Secret Store contains a secret at the specified `secretName`. An error is returned if the Secret Store can not be accessed.

### ListSecretNames 

`ListSecretNames() ([]string, error)`

Returns a list of secret names from the current service's Secret Store. An error is returned if the Secret Store can not be accessed.

### SecretsLastUpdated 

`SecretsLastUpdated() time.Time`

Returns the timestamp for last time when the service's secrets were updated in its Secret Store. This is useful when using external client that is initialized with the secret and needs to be recreated if the secret has changed. 

### RegisterSecretUpdatedCallback

    RegisterSecretUpdatedCallback(secretName string, callback func(secretName string)) error

Registers a callback for when the specified `secretName` is added or updated. The `secretName` that changed is provided as an argument to the callback so that the same callback can be utilized for multiple secrets if desired.

!!! note
    The constant value `secret.WildcardName` can be used to register a callback for when _any_ secret has changed. The actual `secretName` that changed will be passed to the callback. Note that the callbacks set for a specific `secretName` are given a higher precedence over wildcard ones, and will be called _instead of_ the wildcard one if both are present.

!!! note
    This function will return an error if there is already a callback registered for the specified `secretName`. Please call `DeregisterSecretUpdatedCallback` first before attempting to register a new one.

### DeregisterSecretUpdatedCallback

    DeregisterSecretUpdatedCallback(secretName string)

Removes the registered callback for the specified `secretName`. If none exist, this is a no-op.
