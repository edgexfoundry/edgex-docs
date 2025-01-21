# Secure PostgreSQL

The superuser password of PostgreSQL will be generated randomly and securely stored in the secret store with security service enabled.

To retrieve the PostgreSQL superuser password, you can use the following methods:

### Obtaining superuser password using the OpenBao CLI

1. Follow the instructions from [Obtaining the OpenBao Root Token](Ch-SecretStore.md#obtaining-the-openbao-root-token) to get the OpenBao root token.
2. Follow the instructions from [Using the OpenBao CLI](Ch-SecretStore.md#using-the-openbao-cli) to launch the OpenBao CLI.
3. Retrieve the superuser password by executing the following command in the OpenBao CLI:
    ```
    edgex-secret-store:/# bao read secret/edgex/security-bootstrapper-postgres/postgres
    Key                 Value
    ---                 -----
    refresh_interval    168h
    password            EMletY2JCkOT6lEzZ72f2vo89/hpg/CIcj25Gdk3zMCt
    username            postgres
    ```

### Obtaining superuser password using the OpenBao REST API

1. Follow the instructions from [Obtaining the OpenBao Root Token](Ch-SecretStore.md#obtaining-the-openbao-root-token) to get the OpenBao root token.
2. Display (GET) the postgres credentials from the `security-bootstrapper-postgres` secret store by using the OpenBao API:
   ```
   curl -s -H 'X-Vault-Token: <OpenBao-Root-Token>' http://localhost:8200/v1/secret/edgex/security-bootstrapper-postgres/postgres | python -m json.tool
   {
       "request_id": "e4e8f2e2-3185-6955-92ed-be725c3387fc",
       "lease_id": "",
       "renewable": false,
       "lease_duration": 604800,
       "data": {
           "password": "EMletY2JCkOT6lEzZ72f2vo89/hpg/CIcj25Gdk3zMCt",
           "username": "postgres"
       },
       "wrap_info": null,
       "warnings": null,
       "auth": null
   }
   ```
