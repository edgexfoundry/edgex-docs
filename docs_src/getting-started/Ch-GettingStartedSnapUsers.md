# Getting Started with EdgeX Snaps

## Introduction

[Snaps](https://snapcraft.io/docs) are application packages that are easy to install and update while being 
secure, cross‐platform and self-contained.
Snaps can be installed on any Linux distribution with [snap support](https://snapcraft.io/docs/installing-snapd).

Snap packages of EdgeX services are published on the [Snap Store](https://snapcraft.io).

The main platform snap is called the [edgexfoundry](https://snapcraft.io/edgexfoundry). It contains
all reference core services along with several other security, supporting, application, and device services.

The list of all EdgeX snaps is available [below](#edgex-snaps).

## EdgeX Snaps
The following snaps are maintained by the EdgeX working groups:

Platform snap:

- [EdgeX Foundry](https://snapcraft.io/edgexfoundry)

Development tools:

- [EdgeX UI](https://snapcraft.io/edgex-ui)
- [EdgeX CLI](https://snapcraft.io/edgex-cli)

Application services:

- [App Service Configurable](https://snapcraft.io/edgex-app-service-configurable)

Device services:

- [Device Camera](https://snapcraft.io/edgex-device-camera)
- [Device Modbus](https://snapcraft.io/edgex-device-modbus)
- [Device MQTT](https://snapcraft.io/edgex-device-mqtt)
- [Device REST](https://snapcraft.io/edgex-device-rest)
- [Device SNMP](https://snapcraft.io/edgex-device-snmp)
- [Device Grove](https://snapcraft.io/edgex-device-grove)

Other EdgeX snaps do exist on the public Snap Store ([search by keyword](https://snapcraft.io/search?q=edgex)) or private stores under brand accounts.

## Installing the `edgexfoundry` snap

The Snap Store allows access to multiple versions of the snap using [channels](https://snapcraft.io/docs/channels). If not specified, snaps are installed
from the default `latest/stable` channel. 

You can see the current snap channels available for your machine's architecture by running the command:

```bash
snap info edgexfoundry
```

In order to install a specific version of the snap by setting the `--channel` flag.
For example, to install the Jakarta (2.1) release:

```bash
sudo snap install edgexfoundry --channel=2.1
```

To install the latest beta:
```bash
sudo snap install edgexfoundry --channel=latest/beta
# or using the shorthand
sudo snap install edgexfoundry --beta
```

Replace `beta` with `edge` to get the latest nightly build!

Upon installation, the following internal EdgeX services are automatically started:

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

### Configuring individual services
This snap supports configuration overrides via snap configure hooks which generate service-specific .env files which are used to
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

!!! Note
    At this time changes to configuration values in the `[Writable]` section are not supported.

For details on the mapping of configuration options to Config options, please refer to [Service Environment Configuration Overrides](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#configuration-overrides). 

### Viewing logs
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

### Security services

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
