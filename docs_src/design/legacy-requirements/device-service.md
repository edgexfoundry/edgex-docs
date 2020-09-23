# Device SDK Required Functionality

## Overview

This document sets out the required functionality of a Device SDK other
than the implementation of its REST API (see [ADR 0011](../adr/device-service/0011-DeviceService-Rest-API.md))
and the Dynamic Discovery mechanism (see [Discovery](../legacy-design/device-service/discovery.md)).

This functionality is categorised into three areas - actions required at
startup, configuration options to be supported, and support for push-style
event generation.

## Startup

When the device service is started, in addition to any actions required to
support functionality defined elsewhere, the SDK must:

* Manage the device service's registration in metadata
* Provide initialization information to the protocol-specific implementation

### Registration

The core-metadata service maintains an extent of device service registrations
so that it may route requests relating to particular devices to the correct
device service. The SDK should create (on first run) or update its record
appropriately.
Device service registrations contain the following fields:

* `Name` - the name of the device service
* `Description` - an optional brief description of the service
* `Labels` - optional string labels
* `BaseAddress` - URL of the base of the service's REST API

The default device service `Name` is to be hardcoded into every device service
implementation. A suffix may be added to this name at runtime by means of
commandline option or environment variable. Service names must be unique in a
particular EdgeX instance; the suffix mechanism allows for running multiple
instances of a given device service.

The `Description` and `Labels` are configured in the `[Service]` section of the
device service configuration.

`BaseAddress` may be constructed using the `[Service]/Host` and `[Service]/Port`
entries in the device service configuration.

### Initialization

During startup the SDK must supply to the implementation that part of the
service configuration which is specific to the implementation. This
configuration is held in the `Driver` section of the configuration file or
registry.

The SDK must also supply a logging facility at this stage. This facility should
by default emit logs locally (configurable to file or to stdout) but instead
should use the optional logging service if the configuration element
`Logging/EnableRemote` is set `true`. *Note: the logging service is deprecated
and support for it will be removed in EdgeX v2.0*

The implementation on receipt of its configuration should perform any
necessary initialization of its own. It may return an error in the event of
unrecoverable problems, this should cause the service startup itself to fail.

## Configuration

Configuration should be supported by the SDK, in accordance with [ADR 0005](../adr/0005-Service-Self-Config.md)

### Commandline processing

The SDK should handle commandline processing on behalf of the device service.
In addition to the common EdgeX service options, the `--instance` / `-i` flag
should be supported. This specifies a suffix to append to the device service
name.

### Environment variables

The SDK should also handle environment variables. In addition to the common
EdgeX variables, `EDGEX_INSTANCE_NAME` should if set override the `--instance`
setting.

### Configuration file and Registry

The SDK should use (or for non-Go implementations, re-implement) the standard
mechanisms for obtaining configuration from a file or registry.

The configuration parameters to be supported are:

#### Service section

Option | Type | Notes
:--- | :--- | :---
Host | String | This is the hostname to use when registering the service in core-metadata. As such it is used by other services to connect to the device service, and therefore must be resolvable by other services in the EdgeX deployment.
Port | Int | Port on which to accept the device service's REST API. The assigned port for experimental / in-development device services is 49999.
Timeout | Int | Time (in milliseconds) to wait between attempts to contact core-data and core-metadata when starting up.
ConnectRetries | Int | Number of times to attempt to contact core-data and core-metadata when starting up.
StartupMsg | String | Message to log on successful startup.
CheckInterval | String | The checking interval to request if registering with Consul. Consul will ping the service at this interval to monitor its liveliness.
ServerBindAddr | String | The interface on which the service's REST server should listen. By default the server is to listen on the interface to which the `Host` option resolves. A value of `0.0.0.0` means listen on all available interfaces.

#### Clients section

Defines the endpoints for other microservices in an EdgeX system.
Not required when using Registry.

##### Data
Option | Type | Notes
:--- | :--- | :---
Host | String | Hostname on which to contact the core-data service.
Port | Int | Port on which to contact the core-data service.

##### Metadata

Option | Type | Notes
:--- | :--- | :---
Host | String | Hostname on which to contact the core-metadata service.
Port | Int | Port on which to contact the core-metadata service.

#### Device section

Option | Type | Notes
:--- | :--- | :---
DataTransform | Bool | For enabling/disabling transformations on data between the device and EdgeX. Defaults to true (enabled).
Discovery/Enabled | Bool | For enabling/disabling device discovery. Defaults to true (enabled).
Discovery/Interval | Int | Time between automatic discovery runs, in seconds. Defaults to zero (do not run discovery automatically).
MaxCmdOps | Int | Defines the maximum number of resource operations that can be sent to the driver in a single command.
MaxCmdResultLen | Int | Maximum string length for command results returned from the driver.
UpdateLastConnected | Bool | If true, update the LastConnected attribute of a device whenever it is successfully accessed (read or write). Defaults to false.

#### Logging section

Option | Type | Notes
:--- | :--- | :---
LogLevel | String | Sets the logging level. Available settings in order of increasing severity are: `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`.

#### Driver section

This section is for options specific to the protocol driver. Any configuration specified here will be passed to the driver implementation during initialization.

## Push Events

The SDK should implement methods for generating Events other than on
receipt of device GET requests. The AutoEvent mechanism provides for
generating Events at fixed intervals. The asynchronous event queue
enables the device service to generate events at arbitrary times,
according to implementation-specific logic.

### AutoEvents

Each device may have as part of its definition in Metadata a number of `AutoEvents` associated with it. An `AutoEvent` has the following fields:

* **resource**: the name of a deviceResource or deviceCommand indicating what to read.
* **frequency**: a string indicating the time to wait between reading events, expressed
as an integer followed by units of ms, s, m or h.
* **onchange**: a boolean: if set to true, only generate new events if one or more of the
contained readings has changed since the last event.

The device SDK should schedule device readings from the implementation according to these `AutoEvent` defininitions. It should use the same logic as it would if the readings were being requested via REST.

### Asynchronous Event Queue

The SDK should provide a mechanism whereby the implementation may submit device readings at any time without blocking. This may be done in a manner appropriate to the implementation language, eg the Go SDK provides a channel on which readings may be pushed, the C SDK provides a function which submits readings to a workqueue.

