# Getting Started with EdgeX Snaps

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

## EdgeX Snaps

### Platform Snap
This is the main platform snap simply called `edgexfoundry`.
It contains all reference core services along with several other security, supporting, application, and device services.

Please refer to the jakarta [README](https://github.com/edgexfoundry/edgex-go/blob/jakarta/snap/README.md) for the documentation of this snap.

### Application Service Snaps
* [App RFID LLRP Inventory](https://github.com/edgexfoundry/app-rfid-llrp-inventory/blob/v2.1.0/snap/README.md)
* [App Service Configurable](https://github.com/edgexfoundry/app-service-configurable/blob/jakarta/snap/README.md)

### Device Service Snaps
* [Device Camera](https://github.com/edgexfoundry/device-camera-go/blob/v2.1.0/snap/README.md)
* [Device Modbus](https://github.com/edgexfoundry/device-modbus-go/blob/jakarta/snap/README.md)
* [Device MQTT](https://github.com/edgexfoundry/device-mqtt-go/blob/jakarta/snap/README.md)
* [Device REST](https://github.com/edgexfoundry/device-rest-go/blob/jakarta/snap/README.md)
* [Device RFID LLRP](https://github.com/edgexfoundry/device-rfid-llrp-go/blob/v2.1.0/snap/README.md)
* [Device SNMP](https://github.com/edgexfoundry/device-snmp-go/blob/jakarta/snap/README.md)
* [Device Grove](https://snapcraft.io/edgex-device-grove)

### Development Tools
* [EdgeX UI](https://github.com/edgexfoundry/edgex-ui-go/blob/v2.1.0/snap/README.md)
* [EdgeX CLI](https://github.com/edgexfoundry/edgex-cli/blob/v2.1.1-dev.1/snap/README.md)

