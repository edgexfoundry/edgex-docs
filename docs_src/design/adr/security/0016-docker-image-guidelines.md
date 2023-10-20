# Docker image guidelines

## Status

Approved

## Context

When deploying the EdgeX Docker containers some security measures are recommended to ensure the integrity of the software stack.

## Decision

When deploying Docker images, the following flags should be set for heightened security.

- To avoid escalation of privileges each docker container should use the `no-new-privileges` option in their Docker compose file (example below). More details about this flag can be found [here](https://docs.docker.com/engine/reference/run/#security-configuration). This follows Rule #4 for Docker security found [here](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-4-add-no-new-privileges-flag).

```docker
security_opt:
      - "no-new-privileges:true"
```

> NOTE: Alternatively an AppArmor security profile can be used to isolate the docker container. More details about apparmor profiles can be found [here](https://docs.docker.com/engine/security/apparmor/)
```docker
security_opt:  [ "apparmor:unconfined" ]
```

- To further prevent privilege escalation attacks the user should be set for the docker container using the `--user=<userid>` or `-u=<userid>` option in their Docker compose file (example below). More details about this flag can be found [here](https://docs.docker.com/engine/reference/run/#user). This follows Rule #2 for Docker security found [here](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-2-set-a-user).

```docker
services:
  device-virtual:
    image: ${REPOSITORY}/docker-device-virtual-go${ARCH}:${DEVICE_VIRTUAL_VERSION}
    user: $CONTAINER-PORT:$CONTAINER-PORT # user option using an unprivileged user
    ports:
    - "127.0.0.1:49990:49990"
    container_name: edgex-device-virtual
    hostname: edgex-device-virtual
    networks:
      - edgex-network
    env_file:
      - common.env
    environment:
      SERVICE_HOST: edgex-device-virtual
    depends_on:
      - consul
      - data
      - metadata
```

> NOTE: exception
    Sometimes containers will require root access to perform their fuctions. For example the System Management Agent requires root access to control other Docker containers. In this case you would allow it run as default root user.

- To avoid a faulty or compromised containers from consuming excess amounts of the host of its resources `resource limits` should be set for each container. More details about `resource limits` can be found [here](https://docs.docker.com/config/containers/resource_constraints/). This follows Rule #7 for Docker security found [here](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-7-limit-resources-memory-cpu-file-descriptors-processes-restarts).

```docker
services:
  device-virtual:
    image: ${REPOSITORY}/docker-device-virtual-go${ARCH}:${DEVICE_VIRTUAL_VERSION}
    user: 4000:4000 # user option using an unprivileged user
    ports:
    - "127.0.0.1:49990:49990"
    container_name: edgex-device-virtual
    hostname: edgex-device-virtual
    networks:
      - edgex-network
    env_file:
      - common.env
    environment:
      SERVICE_HOST: edgex-device-virtual
    depends_on:
      - consul
      - data
      - metadata
    deploy:  # Deployment resource limits
      resources:
        limits:
          cpus: '0.001'
          memory: 50M
        reservations:
          cpus: '0.0001'
          memory: 20M
```

- To avoid attackers from writing data to the containers and modifying their files the `--read_only` flag should be set. More details about this flag can be found [here](https://docs.docker.com/compose/compose-file/#domainname-hostname-ipc-mac_address-privileged-read_only-shm_size-stdin_open-tty-user-working_dir). This follows Rule #8 for Docker security found [here](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-8-set-filesystem-and-volumes-to-read-only).

```docker
  device-rest:
    image: ${REPOSITORY}/docker-device-rest-go${ARCH}:${DEVICE_REST_VERSION}
    ports:
      - "127.0.0.1:49986:49986"
    container_name: edgex-device-rest
    hostname: edgex-device-rest
    read_only: true # read_only option
    networks:
      - edgex-network
    env_file:
      - common.env
    environment:
      SERVICE_HOST: edgex-device-rest
    depends_on:
      - data
      - command
```

> NOTE: exception
    If a container is required to have write permission to function, then this flag will not work. For example, the vault needs to run setcap in order to lock pages in memory. In this case the `--read_only` flag will not be used.

  NOTE: Volumes
    If writing persistent data is required then a volume can be used. A volume can be attached to the container in the following way

```docker
  device-rest:
    image: ${REPOSITORY}/docker-device-rest-go${ARCH}:${DEVICE_REST_VERSION}
    ports:
      - "127.0.0.1:49986:49986"
    container_name: edgex-device-rest
    hostname: edgex-device-rest
    read_only: true # read_only option
    networks:
      - edgex-network
    env_file:
      - common.env
    environment:
      SERVICE_HOST: edgex-device-rest
    depends_on:
      - data
      - command
    volumes:
      - consul-config:/consul/config:z
```

> NOTE: alternatives
    If writing non-persistent data is required (ex. a config file) then a temporary filesystem mount can be used to accomplish this goal while still enforcing `--read_only`. Mounting a `tmpfs` in Docker gives the container a temporary location in the host systems memory to modify files. This location will be removed once the container is stopped. More details about `tmpfs` can be found [here](https://docs.docker.com/storage/tmpfs/)

for additional docker security rules and guidelines please check the Docker security [cheatsheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)


## Consequences

Create a more secure Docker environment

## References

- Docker-compose reference <https://docs.docker.com/compose/compose-file>
- OWASP Docker Recommendations <https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html>
- CIS Docker Benchmark <https://workbench.cisecurity.org/files/2433/download/2786> (registration required)
