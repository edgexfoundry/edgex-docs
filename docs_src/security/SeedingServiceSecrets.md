# Seeding Service Secrets

All EdgeX services now have the capability to specify a JSON file that contains the service's secrets which are seeded into the service's `SecretStore` during service start-up. This allows the secrets to be present in the service's `SecretStore` when the service needs to use them.

!!! note
    The service must already have a `SecretStore` configured. This is done by default for the Core/Support services. See [Configure the service's Secret Store](../Ch-Configuring-Add-On-Services/#configure-the-services-secret-store-to-use) section for details for add-on App and Device services 

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It has default values which can be overridden with environment variables. See the [SecretStore Overrides](../../microservices/configuration/CommonEnvironmentVariables/#secretstore-overrides) section for more details.

## Secrets File

The new `SecretsFile` setting on the `SecretStore` configuration allows the service to specify the fully-qualified path to the location of the service's secrets file. Normally this setting is left blank when a service has no secrets to be seeded.

This setting can overridden with the `SECRETSTORE_SECRETSFILE` environment variable. When EdgeX is deployed using Docker/docker-compose the setting can be overridden in the docker-compose file and the file can be volume mounted into the service's container.

!!! example "Example - Setting SecretsFile via environment override"
    ```yaml
    environment:
      SECRETSTORE_SECRETSFILE: "/tmp/my-service/secrets.json"
      ...
    volumes:
    - /tmp/my-service/secrets.json:/tmp/my-service/secrets.json
    ```
During service start-up, after `SecretStore` initialization, the service's secrets JSON file is read, validated, and the secrets stored into the service's `SecretStore`. The file is then scrubbed of the secret data, i.e rewritten without the sensitive secret data that was successfully stored. See [Disable Scrubbing](#disable-scrubbing) section below for detail on disabling the scrubbing of the secret data

!!! example "Example - Initial service secrets JSON"
    ```json
    {
        "secrets": [
            {
                "secretName": "credentials001",
                "imported": false,
                "secretData": [
                    {
                        "key": "username",
                        "value": "my-user-1"
                    },
                                    {
                        "key": "password",
                        "value": "password-001"
                    }
                ]
            },
            {
                "secretName": "credentials002",
                "imported": false,
                "secretData": [
                    {
                        "key": "username",
                        "value": "my-user-2"
                    },
                                    {
                        "key": "password",
                        "value": "password-002"
                    }
                ]
            }
        ]
    }
    ```

!!! example "Example - Re-written service secrets JSON after seeding complete"
    ```json
    {
        "secrets": [
            {
                "secretName": "credentials001",
                "imported": true,
                "secretData": []
            },
            {
                "secretName": "credentials002",
                "imported": true,
                "secretData": []
            }
        ]
    }
    ```

The secrets marked with `imported=true` are ignored the next time the service starts up since they are already in the the service's `SecretStore`.  If the Secret Store service's persistence is cleared, the original version of service's secrets file will need to be provided for the next time the service starts up.

!!! note
    The secrets file must be have write permissions for the file to be scrubbed of the secret data. If not the service with fail to start-up with an error re-writing the file.

## Disable Scrubbing 

Scrubbing of the secret data can be disabled by setting `SecretStore.DisableScrubSecretsFile` to `true`. This can be done in the by using the `SECRETSTORE_DISABLESCRUBSECRETSFILE` environment variable override. 


!!! example "Example - Set DisableScrubSecretsFile via environment variable"
    ```yaml
    environment:
      SECRETSTORE_DISABLESCRUBSECRETSFILE: "true"
    ```
