# Rootless Docker Environment

A rootless Docker environment enhances security by limiting the privileges
of the Docker daemon. This is achieved by running the Docker daemon as a non-root user.

Some advantages of a rootless Docker environment include:

* __Enhanced Security:__ Reduce risk of privilege escalation and provide user namespace isolation
* __Non-Privileged Access:__ Allows users to run Docker without root or sudo access
* __Flexibility:__ Suitable for environments without root access, such as shared servers
* __Improved File System Security:__ Containers do not have access to any non-root space folders on the host system

## Requirements
There are four requirements to run Edgex in a rootless Docker environment:

1. The host docker environment must be configured to run Docker in rootless mode (see [Docker Rootless Mode](https://docs.docker.com/engine/security/rootless/))

    If docker is installed, follow the instructions in the above link to move your environment over to
    a rootless docker environment. You will find that you can now run docker commands without sudo,
    and that the docker socket is now located in /run/user/{USERID}/docker.sock instead of /var/run/docker.sock.

2. Memory locking must be disabled for the Vault container:

    Vault locks memory by default to disable swapping to disk. While this is a more secure, it requires
    access to the mlock() sys call which requires root privileges.
    In order for us to run Vault in a rootless environment, we need to disable this feature.
    This is done by setting memory limits in the compose file and by adding `disable_mlock = true` to the local vault config.
    More can be found at the [Vault documentation](https://www.vaultproject.io/docs/configuration/storage/file).

3. Docker socket volume mappings must be mapped to non-root user docker installation location:

    In a default (rootful) docker installation, the docker socket is mapped to /var/run/docker.sock.
    When the docker installation is configured to be a rootless environment the location of the docker socket
    is moved to /run/user/{USERID}/docker.sock. The portainer and security-spire-agent containers both map in the
    docker socket to manage containers, so must be remapped to the new location.

4.  Serial port permissions need to be set to allow non-root user access to the serial port:

    A container running in a rootful docker environment can easily mount in serial ports on the host system,
    but this is not the case for a rootless docker environment. Serial ports are owned by the root user,
    so to access them in a rootless environment, we need to set the permissions to allow the non-root user to access them.

!!! Note
    Setting serial port permissions to 006 or 666 will allow the non-root user to access the serial port via
    volume mounting.

## Running EdgeX in a rootless Docker environment

### Install Rootless Docker Environment
Please refer to the [Docker Rootless Mode](https://docs.docker.com/engine/security/rootless/) documentation for instructions on how to configure a rootless docker environment.

### Run EdgeX

1.  In the root edgex-compose/compose-builder directory, run `make build` with the list of services you want to run.
2.  In the edgex-compose directory, run `make run`, and the rest has already been resolved for you.

!!! Note
    By default Vault has been configured to run in a rootless environment.
    The compose entries for Vault's memory limits are automatically resolved for the host system when
    you run `make build` in the `compose-builder` directory and written statically to the generated compose files.
    The compose entries for the docker socket volume mappings are automatically resolved for the
    host system when you add the `portainer` or `delayed-start` args to the `make run` command in the root edgex-compose directory.



