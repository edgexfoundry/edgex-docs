# Getting Started with Snap

## Introduction
Just like Docker containers, the EdgeX project creates and publishes a snap for each release to the [snap store](https://snapcraft.io/edgexfoundry).  The snap currently supports running on both amd64 and arm64 platforms.  See [snap documents](https://snapcraft.io/docs/installing-snapd) for help on using or installing snap.

## Installing EdgeX Foundry as a snap

The snap is published in the snap store at https://snapcraft.io/edgexfoundry. You can see the current revisions available for your machine's architecture by running the command:

```
$ snap info edgexfoundry
```
The snap can be installed using snap install. To install the snap from the edge channel:

```
$ sudo snap install edgexfoundry --edge
```
You can install a specific release using the --channel option. For example to install the Fuji release of the snap:

```
$ sudo snap install edgexfoundry --channel=fuji
```
Lastly, on a system supporting it, the snap may be installed using GNOME (or Ubuntu) Software Center by searching for edgexfoundry.

!!! Note
    The snap has only been tested on Ubuntu Desktop/Server versions 18.04 and 16.04, as well as Ubuntu Core versions 16 and 18.

!!! Warning
    Running the EdgeX snap on a machine setup for EdgeX development can create conflicts and result in the platform errors/issues.

## Using the EdgeX snap

Upon installation, the following EdgeX services are automatically and immediately started:

    - consul
    - redis
    - core-data
    - core-command
    - core-metadata
    - security-services (see note below)

The following services are disabled by default:

    - app-service-configurable (required for Kuiper and support-rulesengine)
    - device-virtual
    - kuiper
    - support-logging
    - support-notifications
    - support-rulesengine (deprecated)
    - support-scheduler
    - sys-mgmt-agent

Any disabled services can be enabled and started up using snap set:

```
$ sudo snap set edgexfoundry support-notifications=on
```
To turn a service off (thereby disabling and immediately stopping it) set the service to off:

```
$ sudo snap set edgexfoundry support-notifications=off
```

All services which are installed on the system as systemd units, which if enabled will automatically start running when the system boots or reboots.

## Configuring individual services

All default configuration files are shipped with the snap inside $SNAP/config, however because $SNAP isn't writable, all of the config files are copied during snap installation (specifically during the install hook, see snap/hooks/install in this repository) to $SNAP_DATA/config.

```
$ sudo snap restart edgexfoundry
```
## Viewing logs

Currently, all log files for the snap's can be found inside $SNAP_COMMON, which is usually /var/snap/edgexfoundry/common. Once all the services are supported as daemons, you can also use sudo snap logs edgexfoundry to view logs.

Additionally, logs can be viewed using the system journal or snap logs. To view the logs for all services in the edgexfoundry snap use:

```
$ sudo snap logs edgexfoundry
```
Individual service logs may be viewed by specifying the service name:

```
$ sudo snap logs edgexfoundry.consul
```
Or by using the systemd unit name and journalctl:

```
$ journalctl -u snap.edgexfoundry.consul
```
## Security services

Currently, the security services are enabled by default. The security services consitute the following components:

    - Kong
    - PostgreSQL
    - Vault
    - security-secrets-setup
    - security-secretstore-setup
    - security-proxy-setup

Vault is used for secret management, and Kong is used as an HTTPS proxy for all the services.

Kong can be disabled by using the following command:

```
$ sudo snap set edgexfoundry security-proxy=off
```

Vault can be also be disabled, but doing so will also disable Kong, as it depends on Vault. Thus the following command will disable both:

```
$ sudo snap set edgexfoundry security-secret-store=off
```
!!! Note
    Kong is currently not supported in the snap when installed on an arm64-based device, so it will be disabled on install.