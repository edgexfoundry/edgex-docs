---
title: App SDK - Secrets
---

# App Functions SDK - Secrets

All App Service instances running in secure mode require a SecretStore to be configured. With the use of `Redis Pub/Sub` as the default EdgeX MessageBus all App Services need the `redisdb` known secret added to their SecretStore, so they can connect to the Secure EdgeX MessageBus. See the [Secure MessageBus](../../../../security/Ch-Secure-MessageBus.md) documentation for more details.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It now has default values in the code which can be overridden with environment variables. See the [SecretStore Overrides](../../../configuration/CommonEnvironmentVariables.md#secretstore-configuration-overrides) section for more details.

## Storing Secrets

### Secure Mode

When running an application service in secure mode, secrets can be stored in the service's secure SecretStore by making an HTTP `POST` call to the `/api/{{api_version}}/secret` API route in the application service. The secret data POSTed is stored and retrieved from the service's secure SecretStore . Once a secret is stored, only the service that added the secret will be able to retrieve it.  For secret retrieval see [Getting Secrets](#getting-secrets) section below.

!!! example "Example - JSON message body"
    ```json
    {
      "secretName" : "MySecret",
      "secretData" : [
        {
          "key" : "MySecretKey",
          "value" : "MySecretValue"
        }
      ]
    }
    ```

!!! note
    SecretName specifies the location of the secret within the service's SecretStore. 

### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration file. Insecure secrets and their paths can be configured as below.

!!! example "Example - InsecureSecrets Configuration"
    ```yaml
    Writable:
      InsecureSecrets:    
        AWS:
          SecretName: "aws"
          SecretsData:
            username: "aws-user"
            password: "aws-pw"
        DB:
          SecretName: "redisdb"
          SecretsData:
           username: ""
            password: ""
    ```

## Getting Secrets

Application Services can retrieve their secrets from their SecretStore using the  [interfaces.ApplicationService.SecretProvider.GetSecret()](../api/ApplicationServiceAPI.md#secretprovider) API or from the [interfaces.AppFunctionContext.SecretProvider.GetSecret()](../api/AppFunctionContextAPI.md#secretprovider) API  

When in secure mode, the secrets are retrieved from the service secure SecretStore. 

When running in insecure mode, the secrets are retrieved from the `Writable.InsecureSecrets` configuration.
