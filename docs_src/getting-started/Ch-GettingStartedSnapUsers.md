# Getting Started using Snaps

[![snap store badge](https://raw.githubusercontent.com/snapcore/snap-store-badges/master/EN/%5BEN%5D-snap-store-black-uneditable.png)](https://snapcraft.io/edgexfoundry)


## Introduction

[Snaps](https://snapcraft.io/docs) are a hybrid of traditional Linux packages and containers. Snaps can be installed on any
Linux distro with snap support enabled, although full confinement currently requires some flavor of Ubuntu (Desktop/Server
or [Core](https://ubuntu.com/core/docs)).

Canonical publishes snaps (amd64 & arm64) for each release of EdgeX to the Snap Store. In contrast to docker deployment, all core,
security, support, and runtime dependencies are provided in a single snap called [edgexfoundry](https://snapcraft.io/edgexfoundry).
Additional snaps are available for [App Service Configurable](https://snapcraft.io/edgex-app-service-configurable), as well as the
standard set of EdgeX reference device services (see [list](#device-service-snaps) below). The edgexfoundry snap also includes Device Virtual to allow users
to experiment with EdgeX without installing additional snaps.

## Installing EdgeX Foundry Jakarta Snaps

The Snap Store allows multiple versions of a snap to be published to version-specific tracks. If not specified, snaps are installed
from the `latest/stable` track. 

You can see the current snap tracks and revisions available for your machine's architecture by running the command:

```bash
snap info edgexfoundry
```

In order to install Jakarta versions of the EdgeX snaps, you need to specify the `--channel=2.1` command-line option:

```bash
sudo snap install edgexfoundry --channel=2.1
```

!!! Note
    The snap has only been tested on Ubuntu Desktop/Server LTS 18.04/20.04, as well as Ubuntu Core versions 18 and 20.

## Using the EdgeX Snap

Upon installation, the following EdgeX services are automatically and immediately started:

- consul
- vault
- redis
- kong
- postgres
- core-data
- core-command
- core-metadata
- security-services (see [Security Services section](#security-services) below)

The following services are disabled by default:

- app-service-configurable (required for eKuiper)
- device-virtual
- kuiper
- support-notifications
- support-scheduler
- sys-mgmt-agent

Any disabled services can be enabled and started up using `snap set`:

```bash
sudo snap set edgexfoundry support-notifications=on
```

To turn a service off (thereby disabling and immediately stopping it) set the service to off:

```bash
sudo snap set edgexfoundry support-notifications=off
```

All services which are installed on the system as systemd units, which if enabled will automatically start running when the system boots or reboots.

## Configuring individual services
The EdgeX snaps support configuration overrides via snap configure hooks which generate service-specific .env files which are used to
provide a custom environment to the service, overriding the default configuration provided by the service's `configuration.toml`
file. If a configuration override is made after a service has already started, then the service must be **restarted** via command-line
(e.g. `snap restart edgexfoundry.<service>`), or [snapd's REST API](https://snapcraft.io/docs/snapd-api). If the overrides are provided via the snap configuration defaults
capability of a gadget snap, the overrides will be picked up when the services are first started.

The following syntax is used to specify service-specific configuration overrides for the edgexfoundry snap:

```
env.<service>.<stanza>.<config option>
```

For instance, to setup an override of core data's port use:

```bash
sudo snap set edgexfoundry env.core-data.service.port=2112
```

And restart the service:

```bash 
sudo snap restart edgexfoundry.core-data
```

**Note** - at this time changes to configuration values in the `[Writable]` section are not supported.

For details on the mapping of configuration options to Config options, please refer to [Service Environment Configuration Overrides](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#configuration-overrides). 
For details on configuration overrides please refer to documentations for [app service configurable snap](https://github.com/edgexfoundry/app-service-configurable/blob/main/snap/README.md#using-the-edgex-app-service-configurable-snap) or [device service snaps](#device-service-snaps).

## Viewing logs
To view the logs for all services in an EdgeX snap use the `snap log` command:

```bash
sudo snap logs edgexfoundry
```

Individual service logs may be viewed by specifying the service name:

```bash
sudo snap logs edgexfoundry.consul
```

Or by using the systemd unit name and `journalctl`:

```bash
journalctl -u snap.edgexfoundry.consul
```

These techniques can be used with any snap including application snap and device services snaps.

## Security services

Currently, The EdgeX snap has security (Secret Store and API Gateway) enabled by default. The security services constitute the following components:

- kong-daemon (API Gateway a.k.a. Reverse Proxy)
- postgres (kong's database)
- vault (Secret Store)

Oneshot services which perform the necessary security setup and stop, when listed using `snap services`, they show up as `enabled/inactive`:

- security-proxy-setup (kong setup)
- security-secretstore-setup (vault setup)
- security-bootstrapper-redis (secure redis setup)
- security-consul-bootstrapper (secure consul setup)

Vault is known within EdgeX as the Secret Store, while Kong+PostgreSQL are used to provide the EdgeX API Gateway.

For more details please refer to the snap's [Secret Store](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#secret-store) and [API Gateway](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#api-gateway) documentation.

## Device Service Snaps
The following is the current list EdgeX 2.x device service snaps:

  * [Device Camera](https://snapcraft.io/edgex-device-camera)
  * [Device Modbus](https://snapcraft.io/edgex-device-modbus)
  * [Device MQTT](https://snapcraft.io/edgex-device-mqtt)
  * [Device REST](https://snapcraft.io/edgex-device-rest)
  * [Device SNMP](https://snapcraft.io/edgex-device-snmp)

## Development Tools
The following snaps can be used to assist the development and management of EdgeX:

  * [EdgeX UI](https://snapcraft.io/edgex-ui)
  * [EdgeX CLI](https://snapcraft.io/edgex-cli)

