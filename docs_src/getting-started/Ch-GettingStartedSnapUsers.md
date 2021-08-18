# Getting Started with EdgeX Snaps

## Introduction
[Snaps](https://snapcraft.io/docs) are a hybrid of traditional Linux packages and containers. Snaps can be installed on any
Linux distro with snap support enabled, although full confinement currently requires some flavor of Ubuntu (Desktop/Server
or [Core](https://ubuntu.com/core/docs)).

Canonical publishes snaps (amd64 & arm64) for each release of EdgeX to the Snap Store. In contrast to docker deployment, all core,
security, support, and runtime dependencies are provided in a single snap called [edgexfoundry](https://snapcraft.io/edgexfoundry).
Additional snaps are available for App Service Configurable (https://snapcraft.io/edgex-app-service-configurable), as well as the
standard set of EdgeX reference device services (see list below). The edgexfoundry snap also includes Device Virtual to allow users
to experiment with EdgeX without installing additional snaps.

TODO: should we include an embeddable card instead of a hyperlink to the snap store page?

## Installing EdgeX Foundry Ireland snaps
The Snap Store allows multiple versions of a snap to be published to version-specific tracks. If not specified, snaps are installed
from the 'latest' track. As of the Ireland release of EdgeX, the snaps published to the 'latest' track are still based on Hanoi
(1.3.x).

You can see the current snap tracks and revisions available for your machine's architecture by running the command:

```
$ snap info edgexfoundry
```

In order to install Ireland versions of the EdgeX snaps, you need to specify the `--channel=2.0` command-line option:

```
$ sudo snap install edgexfoundry --channel=2.0
```

!!! Note
    The snap has only been tested on Ubuntu Desktop/Server LTS 18.04/20.04, as well as Ubuntu Core versions 18 and 20.

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

    - app-service-configurable (required for eKuiper)
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
The EdgeX snaps support configuration overrides via snap configure hooks which generate service-specific .env files which are used to
provide a custom environment to the service, overriding the default configuration provided by the service's ```configuration.toml```
file. If a configuration override is made after a service has already started, then the service must be **restarted** via command-line
(e.g. ```snap restart edgexfoundry.<service>```), or snapd's REST API. If the overrides are provided via the snap configuration defaults
capability of a gadget snap, the overrides will be picked up when the services are first started.

The following syntax is used to specify service-specific configuration overrides for the edgexfoundry snap:

```env.<service>.<stanza>.<config option>```

For instance, to setup an override of Core Data's Port use:

```$ sudo snap set edgexfoundry env.core-data.service.port=2112```

And restart the service:

```$ sudo snap restart edgexfoundry.core-data```

**Note** - at this time changes to configuration values in the [Writable] section are not supported.

For details on the mapping of configuration options to Config options, please refer to [Service Environment Configuration Overrides](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#configuration-overrides). For details on configuration overrides for App Service Configurable or device service snaps, please refer to the snap documentation for each. Ex.

`https://github.com/edgexfoundry/device-camera-go/blob/main/snap/README.md`

## Viewing logs
To view the logs for all services in an EdgeX snap use the `snap log` command:

```bash
$ sudo snap logs edgexfoundry
```

Individual service logs may be viewed by specifying the service name:

```bash
$ sudo snap logs edgexfoundry.consul
```

Or by using the systemd unit name and `journalctl`:

```bash
$ journalctl -u snap.edgexfoundry.consul
```

These techniques can be used with any snap including application and device services snaps.

## Security services
The EdgeX snaps have security (Secret Store and API Gateway) enabled by default. As of Ireland, the security services in the
edgexfoundry snap consitute the following components:

    - kong
    - postgres
    - vault
    - security-bootstrapper-redis**
    - security-consul-bootstrapper**
    - security-secretstore-setup**
    - security-proxy-setup**

** these services are all 'oneshot' services, when listed using `snap services`, they show up as `enabled/inactive`.

Vault is known within EdgeX as the Secret Store, while Kong+PostgreSQL are used to provide the EdgeX API Gateway.

For more details please refer to the snap's [API Gateway](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md#api-gateway) documentation.

## Device service snaps
The following is the current list EdgeX 2.x device service snaps:

  * [Device Camera](https://github.com/edgexfoundry/device-camera-go/blob/main/snap/README.md)
  * [Device Modbus](https://github.com/edgexfoundry/device-modbus-go/blob/main/snap/README.md)
  * [Device MQTT](https://github.com/edgexfoundry/device-mqtt-go/blob/main/snap/README.md)
  * [Device REST](https://github.com/edgexfoundry/device-rest-go/blob/main/snap/README.md)
