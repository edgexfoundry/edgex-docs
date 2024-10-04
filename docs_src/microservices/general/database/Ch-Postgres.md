# PostgreSQL

EdgeX Foundry also supports PostgreSQL as the persistence database.

PostgreSQL is an open-source object-relational database system (licensed under the PostgreSQL License) that offers exceptional scalability and performance, with support for both relational and document (JSON) data models.

## Pre-Defined Users with Privileges

Each EdgeX service that connects to PostgreSQL uses different users depending on whether it's operating in secure or non-secure mode.

In non-secure mode, all services use the default `postgres` user to access the PostgreSQL database.

In secure mode, each EdgeX service is assigned a unique username and password, with limited privileges. These users are restricted to accessing only the table schemas owned by their respective services. 
For instance, the Core Data service owns the `core_data` schema and is permitted to use the `core_data` user to access the database. This `core_data` user is granted privileges specific to the tables within the `core_data` schema.

## Using PostgreSQL Database

PostgreSQL database can be started and used as the persistence store in the Docker-based EdgeX deployment.

Please refer to [Use PostgreSQL as the persistence layer in EdgeX](https://github.com/edgexfoundry/edgex-compose?tab=readme-ov-file#use-postgresql-as-the-persistence-layer-in-edgex) for the instructions to run the EdgeX services along with PostgreSQL database.

## (Optional) Configure add-on services to access PostgreSQL

This section introduces how to configure add-on services to access PostgreSQL database in secure mode.

For more information about add-on services, see [Configuring Add-on Service](../../../security/Ch-Configuring-Add-On-Services/).

### Configure known secrets for add-on services

The `EDGEX_ADD_KNOWN_SECRETS` environment variable on `secretstore-setup` allows for known secrets
to be added to an add-on service's `Secret Store`.

The `known` secret for PostgreSQL is the `PostgreSQL credentials` identified by
the name `postgres`. Any add-on service needing access to the `PostgreSQL` such as
App Service HTTP Export with Store and Forward enabled will need the `PostgreSQL credentials`
put in its `Secret Store`.

Note that the steps needed for connecting add-on services to the `Secure MessageBus` are:

1. Utilizing the `security-bootstrapper` to ensure proper startup sequence
2. Creating the `Secret Store` for the add-on service
3. Adding the `postgres` known secret to the add-on service's `Secret Store`

and if the add-on service is not connecting to the PostgreSQL database, then this step can be skipped.

So given an example for service `myservice` to use the PostgreSQL database in secure mode,
we need to tell `secretstore-setup` to add the `postgres` known secret to `Secret Store` for `myservice`.
This can be done through the configuration of adding `postgres[myservice]` into the environment variable
`EDGEX_ADD_KNOWN_SECRETS` in `secretstore-setup` service's environment section, in which `postgres` is the name of
the `known secret` and `myservice` is the service key of the add-on service.

```yaml
...
  secretstore-setup:
    container_name: edgex-secretstore-setup
    depends_on:
    - security-bootstrapper
    - vault
    environment:
      EDGEX_ADD_SECRETSTORE_TOKENS: myservice
      EDGEX_ADD_KNOWN_SECRETS: postgres[myservice],message-bus[myservice],message-bus[device-virtual]
...

```

In the above `docker-compose` section of `secretstore-setup`, we specify the known secret of
`postgres` to add/copy the PostgreSQL database credentials to the `Secret Store` for the `myservice` service.

We can also use the alternative or simpler form of `EDGEX_ADD_KNOWN_SECRETS` environment variable's value like

```yaml
    EDGEX_ADD_KNOWN_SECRETS: postgres[myservice],message-bus[myservice],message-bus[device-virtual]
```

in which all add-on services are put together in a comma separated list associated with the
known secret `postgres`.
