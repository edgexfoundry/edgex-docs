---
title: Device Service SDK - Secrets
---

# Device Service SDK - Secrets

## Configuration

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It has default values which can be overridden with environment variables. See the [SecretStore Overrides](../CommonEnvironmentVariables/#secretstore-overrides) section for more details.

All instances of Device Services running in secure mode require a `SecretStore` to be created for the service by the Security Services. See [Configuring Add-on Service](../../../security/Ch-Configuring-Add-On-Services) for details on configuring a `SecretStore` to be created for the Device Service. With the use of `Redis Pub/Sub` as the default EdgeX MessageBus all Device Services need the `redisdb` known secret added to their `SecretStore` so they can connect to the Secure EdgeX MessageBus. See the [Secure MessageBus](../../../security/Ch-Secure-MessageBus) documentation for more details.

Each Device Service also has detailed configuration to enable connection to it's exclusive `SecretStore`

## Storing Secrets

### Secure Mode

When running an Device Service in secure mode, secrets can be stored in the SecretStore by making an HTTP `POST` call to the `/api/{{api_version}}/secret` API route on the Device Service. The secret data POSTed is stored to the service's secure`SecretStore` . Once a secret is stored, only the service that added the secret will be able to retrieve it.  See the [Secret API Reference](../../sdk/details/Secrets.md) for more details and example.

### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration.yaml file. Insecure secrets and their paths can be configured as below.

!!! example "Example - InsecureSecrets Configuration"
    ```yaml
    Writable:
      InsecureSecrets:    
        DB:
         SecretName: "redisdb"
         SecretData:
           username: ""
           password: ""
        MQTT:
          SecretName: "credentials"
        SecretData:
           username: "mqtt-user"
           password: "mqtt-password"
    ```

## Retrieving Secrets

The Go Device SDK provides the `SecretProvider.GetSecret()` API to retrieve the Device Services secrets.  See the [Device MQTT Service](https://github.com/edgexfoundry/device-mqtt-go/blob/{{edgexversion}}/internal/driver/config.go#L118) for an example of using the `SecretProvider.GetSecret()` API. Note that this code implements a retry loop allowing time for the secret(s) to be push into the service's `SecretStore` via the /secret endpoint. See [Storing Secrets](../../microservices/device/Ch-DeviceServices/#storing-secrets) section for more details.
