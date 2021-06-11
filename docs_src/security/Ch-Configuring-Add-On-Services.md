# Configuring Add-on Service

In the current EdgeX security serivces, we set up and configure all security related properties and environments
for the existing default serivces like `core-data`, `core-metadata`, `device-virtual`, and so on.

The settings and service environment variables are pre-wired and ready to run in secure mode without any update
or modification to the Docker-compose files.  However, there are some pre-built add-on services like `device-camera`,
`device-modbus` and some of application services (eg. `app-http-export`) are not pre-wired by default
and thus needs some deployment efforts to make them run in secure mode.

EdgeX provides a way for a user to add and configure those add-on services into EdgeX Docker
software stack running in secure mode.  This can be done vai Docker-compose files with a few addition of
environment variables and some modification of micro-service's Dockerfile.

One of the major security features in EdgeX Ireland release is to utilize the service `security-bootstrapper`
to ensure the right starting sequence so that the secrets are pre-seeded and in a more predictable starting order and
inter-dependencies between micro-services.

Currently EdgeX uses Vault as the default implementation for secret store and Consul as the configuration
and/or registry server if user chooses to do so.  There are some default services configured to generate
secret tokens by default like those EdgeX core services and device-virtual service. There will be time of
need to have EdgeX software stack generate the secret store token when end user wants to run the add-on
services like `device-camera`, `app-http-export`, what have you in a secure mode.  

In the following scenario, we assume the EdgeX services are running in Docker environments,
and thus the examples are given in terms of Docker-compose ways.  It should not be much or bigger
difference for `snap` running environment to apply the same steps or concepts if found to do so.

If a user wants to configure and set up an add-on service, e.g. `device-camera`,
he can do the steps of guidelines as follows to achieve that:

## Make add-on services security-bootstrapper compatible

To use the Docker entrypoint scripts of gating mechanism from `security-bootstrapper`,
the Dockerfile of `device-camera` should inherit shell scripting capability like `alpine`-based
as the base Docker image and should install `dumb-init`(see details in
[Why you need an init system](https://github.com/Yelp/dumb-init#why-you-need-an-init-system))
via `apk add --update` command.

Dockerfile example using alpine-base image and add `dumb-init`:

```dockerfile
......
FROM alpine:3.12

# dumb-init needed for injected secure bootstrapping entrypoint script when run in secure mode.
RUN apk add --update --no-cache dumb-init
......

```

and then in the service itself should add `/edgex-init/ready_to_run_wait_install.sh` as the entrypoint script
for the service in gating fashion and related Docker volumes from `edgex-init` and secretstore token which
will be outlined in the next section.

A good example of this will be like `app-serive-rules`:

```yaml
...
  app-service-rules:
    entrypoint: ["/edgex-init/ready_to_run_wait_install.sh"]
    command: "/app-service-configurable ${DEFAULT_EDGEX_RUN_CMD_PARMS}"
    volumes:
      - edgex-init:/edgex-init:ro,z
      - /tmp/edgex/secrets/app-rules-engine:/tmp/edgex/secrets/app-rules-engine:ro,z
    depends_on:
      - security-bootstrapper
...

```

## Configure the secret store to use

Make sure the TOML configuration file of add-on service like `device-camera` contains
the proper `[SecretStore]` section.

Example:

```toml
[SecretStore]
Type = 'vault'
Host = 'localhost'
Port = 8200
Path = 'my-service/'
Protocol = 'http'
RootCaCertPath = ''
ServerName = ''
TokenFile = '/tmp/edgex/secrets/my-service/secrets-token.json'
  [SecretStore.Authentication]
  AuthType = 'X-Vault-Token'
```

and then in the EdgeX service `secretstore-setup` environment section of `Docker-compose` file to add
the service key or hostname to the environment variable `ADD_SECRETSTORE_TOKENS`:

```yaml
...
  secretstore-setup:
    container_name: edgex-secretstore-setup
    depends_on:
    - security-bootstrapper
    - vault
    environment:
      ADD_SECRETSTORE_TOKENS: 'device-camera'
...

```

With that, `secretstore-setup` then can generate secretstore token from `Vault` and store it in
the `TokenFile` path specified in the TOML configuration file like the above example.

## Configure the secure Redis message bus to use

This can be done in the EdgeX service `secretstore-setup` environment section of
`Docker-compose` file to add the `redisdb` and the service key using it.

So an example will be like `redisdb[device-virtual]` in which `redisdb` is the database resource name
and the `device-virtual` is the service key or hostname and add that value into the environment variable
`ADD_KNOWN_SECRETS`:

```yaml
...
  secretstore-setup:
    container_name: edgex-secretstore-setup
    depends_on:
    - security-bootstrapper
    - vault
    environment:
      ADD_SECRETSTORE_TOKENS: 'device-camera, my-service'
      ADD_KNOWN_SECRETS: redisdb[app-rules-engine],redisdb[device-rest],redisdb[device-virtual]
...

```


## (Optional) Configure the ACL role of configuration/registry to use if the service depends on it

This is a new step coming from `securing Consul` security features as part of EdgeX Ireland release.

If the add-on service uses `Consul` as the configuration and/or registry service, then we also need to
configure the environment variable `ADD_REGISTRY_ACL_ROLES` to tell `security-bootstrapper` to generate
an ACL role for `Consul` to associate with its token.

An example of configuring acl roles of the registry `Consul` for the add-on services
`device-modbus` and `app-http-export` is like the following:

```yaml
...
  consul:
    container_name: edgex-core-consul
    depends_on:
    - security-bootstrapper
    - vault
    entrypoint:
    - /edgex-init/consul_wait_install.sh
    environment:
      ADD_REGISTRY_ACL_ROLES: app-http-export,device-modbus
...

```

## Configure the API gateway access route for add-on service

If it is desirable to let user or other application services outside EdgeX's Docker network access
the endpoint of the add-on service, then we can configure and add it via the environment variable of
service `proxy-setup`, `ADD_PROXY_ROUTE`.  `proxy-setup` adds those services listed in that environment
variable into the API gateway (aka Kong) route so that the endpoint can be accessible using Kong's proxy
endpoint.

One example of adding API gateway access route for service `device-camera` is give as follows:

```yaml
...
edgex-proxy:
      ...
    environment:
      ...
      ADD_PROXY_ROUTE: "device-camera.http://device-camera:59985"
      ...
...
```

where port number `59985` is the internal port used by service `device-camera`.

With that setup, we can then access the endpoints of `device-camera` from Kong's host like
`https://kong:8443/device-camera/{device-name}/name` assuming the caller can resolve `kong` from DNS server.

For more details on how the introduction to the API gateway and how it works,
please see [Ch-APIGateway documentation page](Ch-APIGateway.md).
