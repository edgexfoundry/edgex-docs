# Seeding Service Secrets

!!! edgey "EdgeX 2.1"
    New for EdgeX 2.1 is the ability to seed service specific secrets during the service's start-up. 

All EdgeX services now have the capability to specify a JSON file that contains the service's secrets which are seeded into the service's `SecretStore` during service start-up. This allows the secrets to be present in the service's `SecretStore` when the service needs to use them.

!!! note
    The service must already have a `SecretStore` configured. This is done by default for the Core/Support services. See [Configure the service's Secret Store](../Ch-Configuring-Add-On-Services/#configure-the-services-secret-store-to-use) section for details for add-on App and Device services 

The new `SecretsFile` setting on the `SecretStore` configuration allows the service to specify the fully-qualified path to the location of the service's secrets file. Normally this setting is left blank when a service has no secrets to be seeded.

!!! example "Example setting SecretsFilePath in TOML"

    ```toml
    [SecretStore]
    Type = "vault"
    ...
    SecretsFile = "/tmp/my-service/secrets.json"
    ...
    ```

This setting can also be overridden with the `SECRETSTORE_SECRETSFILE` environment variable. When EdgeX is deployed using Docker/docker-compose the setting can be overridden in the docker-compose file and the file can be volume mounted into the service's container.

!!! example "Example setting SecretsFile via environment override"
    ```yaml
    environment:
      SECRETSTORE_SECRETSFILE: "/tmp/my-service/secrets.json"
      ...
    volumes:
    - /tmp/my-service/secrets.json:/tmp/my-service/secrets.json
    ```

During service start-up, after `SecretStore` initialization, the service's secrets JSON file is read, validated, and the secrets stored into the service's `SecretStore`. The file is then rewritten without the sensitive secret data that was successfully stored. 

!!! Example "Example of initial service secrets JSON"
    ```json
    {
        "secrets": [
            {
                "path": "credentials001",
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
                "path": "credentials002",
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

!!! Example "Example of re-written service secrets JSON after seeding complete"
    ```json
    {
        "secrets": [
            {
                "path": "credentials001",
                "imported": true,
                "secretData": []
            },
            {
                "path": "credentials002",
                "imported": true,
                "secretData": []
            }
        ]
    }
    ```

The secrets marked with `imported=true` are ignored the next time the service starts up since they are already in the the service's `SecretStore`.  If the Secret Store service's persistence is cleared, the original version of service's secrets file will need to be provided for the next time the service starts up.

