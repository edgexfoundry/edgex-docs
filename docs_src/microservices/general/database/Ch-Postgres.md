# PostgreSQL

EdgeX Foundry uses PostgreSQL as the persistence database by default.

PostgreSQL is an open-source object-relational database system (licensed under the PostgreSQL License) that offers exceptional scalability and performance, with support for both relational and document (JSON) data models.

## Pre-Defined Users with Privileges

Each EdgeX service that connects to PostgreSQL uses different users depending on whether it's operating in secure or non-secure mode.

In non-secure mode, all services use the default `postgres` user to access the PostgreSQL database.

In secure mode, each EdgeX service is assigned a unique username and password, with limited privileges. These users are restricted to accessing only the table schemas owned by their respective services. 
For instance, the Core Data service owns the `core_data` schema and is permitted to use the `core_data` user to access the database. This `core_data` user is granted privileges specific to the tables within the `core_data` schema.

## EdgeX Services Using PostgreSQL for Data Storage

The following EdgeX services depend on PostgreSQL for data storage and operate using predefined database schemas:

- Core Data
- Core Metadata
- Core Keeper
- Support Notifications
- Support Schedulers
- Security Proxy Auth
- App Services (specifically for the Store and Forward feature)

## Numeric Data Type Support

To reduce disk consumption, numeric values are stored as `numeric` data type instead of `text` data type. For example, storing the number `128` as a string takes `3` bytes, whereas storing it as a numeric type takes only `2` bytes. See [Character Types][1] and [Numeric Types][2] for more details.

The following data types are supported for storage as numeric values:

- Int8, Int16, Int32, Int64, 
- Uint8, Uint16, Uint32, Uint64
- Float32, Float64

Check if Core Data stores the value in the `numeric_value` column:
```shell
$ docker exec  edgex-postgres psql -U postgres -d edgex_db -a -c "SELECT event_id, origin, value, numeric_value from core_data.reading order by origin DESC limit 10"
SELECT event_id, origin, value, numeric_value from core_data.reading order by origin DESC limit 10
               event_id               |       origin        | value |    numeric_value     
--------------------------------------+---------------------+-------+----------------------
 00f57c72-35c6-424f-afc1-f63e835e49c4 | 1756204540891284500 |       |                  161
 440b6a52-e193-4c8e-8fb1-0005a7d181b4 | 1756204540891235000 |       |           2870254211
 f83c826d-3f07-4d31-8dc7-c2b8e41d8f64 | 1756204540891147000 |       |                36326
 d0a9a4b1-1418-4913-a624-4e9aac9fb619 | 1756204540891081500 |       |  2170898694295277922
 945b6e5a-bc9c-4cdb-b55d-f67682d0dc31 | 1756204540890949600 | false |                     
 e2b3c3f3-5df6-494c-bbeb-f8dcb8d51cb3 | 1756204535891338500 |       |                15215
 f8571377-2268-4b69-8496-cd03e3e5dd5a | 1756204535891121000 |       |                    8
 febbe9c4-1e3c-40df-ab6f-ae123255a355 | 1756204535891041300 |       | -2798122935355531774
 467da520-29b6-4674-b523-16091687cdc8 | 1756204535890933500 |       |          -1128978172
 3e10eeae-0667-48aa-811f-9c303ccc4725 | 1756204530890796000 | false |                     
(10 rows)
```

!!! edgey - "EdgeX 4.1"
    Numeric Data Type Support is new in EdgeX 4.1

## PostgreSQL Table Schema Migration

The EdgeX services create and manage their own database schemas in PostgreSQL.
The table schema migration is handled by the services themselves, which means that the services will automatically create and alter the necessary tables and indexes when they are started.
If you are a Go developer/contributor who is interested in how table schema migration works in EdgeX services, please refer to `internal/<layer>/<service>/embed/schema.go` of each service to understand the table schema migration policy.

## (Optional) Configure add-on services to access PostgreSQL

This section introduces how to configure add-on services to access PostgreSQL database in secure mode.

For more information about add-on services, see [Configuring Add-on Service](../../../security/Ch-Configuring-Add-On-Services.md).

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

[1]: https://www.postgresql.org/docs/current/datatype-character.html
[2]: https://www.postgresql.org/docs/current/datatype-numeric.html
