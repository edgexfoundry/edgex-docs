---
title: Device Service SDK - C SDK API
---

# Device Service SDK - C SDK API

## Introduction

This page provides detail on the API provided by the C SDK. A device service implementation will define a number of callback functions, and a `main` function which registers these functions with the SDK and uses the SDK lifecycle methods to start the service and shut it down. The implementation may also use some of the helper functions which the SDK provides.

In various places information is passed between the SDK and the DS implementation using the `iot_data_t` type. This is a holder for data of different types, and its use is described in its own page : [Use of iot_data_t](CUtilities.md)

## Types

### devsdk_service_t

This struct represents a running device service. An instance of it is created by calling `devsdk_service_new`, and this instance should be passed in subsequent sdk function calls.

### devsdk_callbacks

This struct type holds pointers to the various callback functions which the device service implementor needs to define in order to do the device-specific work of the service

### devsdk_address_t

This is an alias to `void*`. Implementations should define their own structure for device addresses and cast `devsdk_address_t*` to pointers to that structure.

### devsdk_resource_attr_t

This is an alias to `void*`. Implementations should define their own structure for device resource information and cast `devsdk_resource_attr_t*` to pointers to that structure.

### devsdk_protocols

This is an opaque structure which holds protocol properties. The `devsdk_protocols_properties` function is used to find the properties for a particular protocol.

### devsdk_error

This structure is used to pass errors back from the device service startup and shutdown functions

Field | Type | Content
------|------|--------
code  | uint32_t | A numeric code indicating the error. Zero is used for success
reason | const char * | A string describing the error

An instance of devsdk_error with the code field set to zero should be passed by reference when calling startup and shutdown functions

### devsdk_device_t

Specifies a device

Field | Type | Content
------|------|--------
name | char* | The device's name (for logging purposes)
address | devsdk_address_t | Address of the device in parsed form

### devsdk_resource_t

Specifies a resource on a device

Field | Type | Content
------|------|--------
name | char* | The resource name (for logging purposes)
attrs | devsdk_resource_attr_t | Resource attributes in parsed form
type | iot_typecode_t | Expected type of values read from or written to the resource

### devsdk_commandrequest

Specifies a resource in a get or put request

Field | Type | Content
------|------|--------
resource | devsdk_resource_t* | The resource definition
mask | uint64_t | Mask to be applied (put requests only)

### devsdk_commandresult

Holds a value which has been read from a resource

Field | Type | Content
------|------|--------
value | iot_data_t* | The value which has been read
origin | uint64_t | Timestamp of the value

The timestamp is specified in nanoseconds past the epoch. It should only be set if one is provided by the device itself. Otherwise the timestamp should be left at zero and the SDK will use the current time.

### devsdk_device_resources

A list of device resources available on a device

Field | Type | Content
------|------|--------
resname | char* | Name of the resource
attributes | iot_data_t* | String-keyed map of the resource attributes
type | iot_typecode_t | Type of the data which may be read or written
readable | bool | Whether this resource is readable
writable | bool | Whether this resource is writable
next | devsdk_device_resources* | The next resource in the list, or NULL if this is the last

### devsdk_devices

A description of a device or a list of such descriptions

Field | Type | Content
------|------|--------
device | devsdk_device_t* | The device's name and addressing information
resources | devsdk_device_resources* | Information on the device's resources
next | devsdk_devices* | The next device in the list, or NULL if this is the last

## Callbacks

Callback functions that a device service needs to execute which depends on its protocol.

Note that each of the callback functions has as its first parameter a `void*` pointer. This pointer is specified by the implementation when the device service is created, and is passed to all callbacks. It may therefore be used to hold whatever state is required by the implementation.

### Required callback functions

#### devsdk_initialize

This function is called during the service start operation. Its purpose is to supply the implementation with a logger and configuration.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
lc   | iot_logger_t* | A logging client for the device service
config | iot_data_t* | A string-keyed map containing the configuration specified in the service's "Driver" section

The function should return true to indicate that initialization was successful, or false to abort the service startup - eg if the supplied configuration was invalid or resources were not available

#### devsdk_create_address

This function should take the protocol properties that were specified for a device, and create an object representing the device's address in a form suitable for subsequent access.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
protocols | const devsdk_protocols* | The protocol properties for the device
exception | iot_data_t** | Additional information in the event of an error

If the supplied protocol properties are valid (ie, mandatory elements are supplied and have valid values), the function should return an allocated structure representing the address. Otherwise the function should return NULL, and set `*exception` to a string (using eg. `iot_data_alloc_string`) containing an error message.

#### devsdk_free_address

This function should free a structure that was previously allocated in the `devsdk_create_address` implementation.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
address | devsdk_address_t | The object to be freed.

#### devsdk_create_resource_attr

This function should take the attributes that were specified for a deviceResource, and create an object representing these attributes in a form suitable for subsequent access.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
attributes | const iot_data_t* | The attributes for the device
exception | iot_data_t** | Additional information in the event of an error

If the supplied attributes are valid (ie, mandatory elements are supplied and have valid values), the function should return an allocated structure representing the resource within the device. Otherwise the function should return NULL, and set `*exception` to a string (using eg. `iot_data_alloc_string`) containing an error message.

#### devsdk_free_resource_attr

This function should free a structure that was previously allocated in the `devsdk_create_resource_attr` implementation

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
resource | devsdk_resource_attr_t | The object to be freed

#### devsdk_handle_get

This function is called when a get (read) request on a deviceResource or deviceCommand is made. In the former case, the request is for a single reading and in the latter, for multiple readings. These readings will be packaged by the SDK into an Event.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
device | devsdk_device_t* | The name and address of the device to be queried
nreadings | uint32_t | The number of readings being requested
requests | devsdk_commandrequest* | Array containing details of the resources to be queried
readings | devsdk_commandresult* | Array that the function should populate, with results of this request
options | iot_data_t* | Any options which were specified in this request
exception | iot_data_t** | Additional information in the event of an error

The readings array will have been allocated in the SDK; the implementation should set the results into `readings[0]...readings[nreadings - 1]`.

`Options` will be a string-keyed map which contains any options set specifically on this request. In the current implementation these may have been set via query parameters in the URL used to make the request.

The function should return true if all of the requested resources were successfully read. Otherwise, `*exception` should be allocated with a string value indicating the problem (this will be logged and returned to the caller), and false returned.

#### devsdk_handle_put

This function is called when a put (write) request on a deviceResource or deviceCommand is made. In the former case, the request is for a single resource and in the latter, for multiple resources.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
device | devsdk_device_t* | The name and address of the device to be written to
nreadings | uint32_t | The number of resources to be written
requests | devsdk_commandrequest* | Array containing details of the resources to be written
values | iot_data_t*[] | Array of values to be written
options | iot_data_t* | Any options which were specified in this request
exception | iot_data_t** | Additional information in the event of an error

If the `mask` field in an element of the request array is nonzero, the implementation should implement the following:

```
new-value = (current-value & mask) | request-value
```

`Options` will be a string-keyed map which contains any options set specifically on this request. In the current implementation these may have been set via query parameters in the URL used to make the request.

The function should return true if all of the requested resources were successfully written. Otherwise, `*exception` should be allocated with a string value indicating the problem (this will be logged and returned to the caller), and false returned.

#### devsdk_stop

The implementation should perform any cleanup necessary before shutdown. At the time that this function is called, the service will be quiescent, ie there will be no new incoming requests.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
force | bool | An unclean shutdown may be performed if necessary. Long or indefinite timeouts should not occur.

### devsdk_callbacks_init

Call this function in order to create a devsdk_callbacks object containing the required callback functions. This may then be passed to the SDK when starting the service

Parameter | Type
----------|-----
init | devsdk_initialize
gethandler | devsdk_handle_get
puthandler | devsdk_handle_put
stop | devsdk_stop
create_addr | devsdk_create_address
free_addr | devsdk_free_address
create_res | devsdk_create_resource_attr
free_res | devsdk_free_resource_attr

### Optional callback functions

### devsdk_reconfigure

Implement this function in order to allow changes in the device-specific configuration to be made without restarting the service.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
config | iot_data_t* | The new configuration (contains all elements, not just those which have changed)

### devsdk_callbacks_set_reconfiguration

Call this to add your reconfiguration function to the callbacks structure

Parameter | Type | Description
----------|------|------------
cb | devsdk_callbacks* | structure to be modified
reconf | devsdk_reconfigure | function to add

### devsdk_discover

This function is called when a request for discovery is made. This may occur automatically at intervals or due to an external request. The SDK implements locking such that multiple invocations of this function will not be made in parallel.

Implementations should perform a scan for devices, and use the `devsdk_add_discovered_devices` function to register them.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
request_id | const char* | The discovery request ID

### devsdk_discovery_delete

This function is called when a delete request for discovery is made.

Implementations should perform logic for stopping a discovery request that is in progress. The implementation should return True on success or False for unsuccessful.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
request_id | const char* | The discovery request ID

### devsdk_describe

This is a placeholder function for future use. Its purpose will be to allow automatic generation of device profiles. It is not used in current versions of EdgeX.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
dev | devsdk_device_t* | The device which is to be described
options | iot_data_t* | Service specific discovery options map. May be NULL
resources | devsdk_device_resources** | The operations supported by the device
exception | iot_data_t** | Additional information in the event of an error

Implementations should populate the `resources` parameter and return true if it is possible to automatically describe the device. Otherwise return false and set `exception`.

### devsdk_callbacks_set_discovery

Call this to add your discovery functions to the callbacks structure

Parameter | Type | Description
----------|------|------------
cb | devsdk_callbacks* | structure to be modified
discover | devsdk_discover | device discovery function
describe | devsdk_describe | device description function, may be NULL (currently unused)

### devsdk_callbacks_set_discovery_delete

Call this to add your discovery delete function to the callbacks structure

Parameter | Type | Description
----------|------|------------
cb | devsdk_callbacks* | structure to be modified
discover | devsdk_discovery_delete | device discovery delete function

### devsdk_add_device_callback

To be notified when a device is added to the system (and assigned to this device service), provide an implementation of this function

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
devname | char* | The name of the new device
protocols | devsdk_protocols* | The protocol properties that comprise the device's address
resources | devsdk_device_resources* | The operations supported by the device
adminEnabled | bool | Whether the device is administratively enabled

### devsdk_update_device_callback

To be notified when a device managed by this service is modified, provide an implementation of this function

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
devname | char* | The name of the updated device
protocols | devsdk_protocols* | The protocol properties that comprise the device's address
state | bool | Whether the device is administratively enabled

### devsdk_remove_device_callback

To be notified when a device managed by this service is removed, provide an implementation of this function

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
devname | char* | The name of the removed device
protocols | devsdk_protocols* | The protocol properties that comprise the device's address

### devsdk_callbacks_set_listeners

Call this to add your add, remove and/or update listener functions to the callbacks structure. Any of the functions may be NULL

Parameter | Type | Description
----------|------|------------
cb | devsdk_callbacks* | structure to be modified
device_added | devsdk_add_device_callback | device addition listener
device_updated | devsdk_update_device_callback | device update listener
device_removed | devsdk_remove_device_callback | device removal listener

### devsdk_autoevent_start_handler

Some device types may be configured to generate readings automatically at intervals. Such behavior may be enabled by providing implementations of this function and the stop handler described below. If "AutoEvents" have been defined for a device, this function will be called to request that automatic events should begin. The events when generated should be posted using the `devsdk_post_readings` function. In the absence of an implementation of this function, the SDK will poll the device via the get handler.

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
devname | char* | The name of the device to be queried
protocols | devsdk_protocols* | The address of the device to be queried
resource_name | char* | The resource on which autoevents have been configured
nreadings | uint32_t | The number of readings requested
requests | devsdk_commandrequest* | Array containing details of the resources to be queried
interval | uint64_t | The time between events, in milliseconds
onChange | bool | If true, events should only be generated if one or more readings have changed

The function should return a pointer to a data structure that will be provided in a subsequent call to the stop handler when this autoevent is t be stopped

### devsdk_autoevent_stop_handler

This function is called to request that automatic events should cease

Parameter | Type | Description
----------|------|------------
impl | void* | The context data passed in when the service was created
handle | void* | The data structure returned by a previous call to the start handler

### devsdk_callbacks_set_autoevent_handlers

Call this to add your autoevent management functions to the callbacks structure. Both start and stop handlers are required

Parameter | Type | Description
----------|------|------------
cb | devsdk_callbacks* | structure to be modified
ae_starter | devsdk_autoevent_start_handler | Autoevent start handler
ae_stopper | devsdk_autoevent_stop_handler | Autoevent stop handler

## Initialisation and Shutdown

These functions manage the lifecycle of the device service and should be called in the order presented here

### devsdk_service_new

This function creates a new device service

Parameter | Type | Description
----------|------|------------
defaultname | char* | The device service name, used in logging, metadata lookups and to scope configuration. This may be overridden via the commandline
version | char* | The version string for this service. This is for information only, and will be logged during startup
impldata | void* | An object pointer which will be passed back whenever one of the callback functions is invoked
implfns | devsdk_callbacks* | Structure containing the device implementation functions. The SDK will call these functions in order to carry out its various actions
argc | int* | A pointer to argc as passed into main(). This will be adjusted to account for arguments consumed by the SDK
argv | char** | argv as passed into main(). This will be adjusted to account for arguments consumed by the SDK
err | devsdk_error* | Nonzero reason codes will be set here in the event of errors

The newly created service is represented by an object of type devsdk_service_t, which is returned if the service is created successfully

The SDK modifies the commandline argument parameters `argc` and `argv`, removing those arguments which it supports. The implementation may support additional arguments by inspecting these modified values after the create function has been called

### devsdk_service_start

Start the device service. Default values for the implementation-specific configuration are passed in here. These must be provided in a string-keyed iot_data_t map. A value named "X" may be over-ridden in the configuration file by an entry for X in the `[Driver]` section. For dynamically-updatable configuration, set a value for "Writable/X". This will correspond to a configuration file entry in the `[Writable.Driver]` section and updates may be received by implementing the `devsdk_reconfigure` function

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
driverdfls | iot_data_t* | Default configuration
err | devsdk_error* | Nonzero reason codes will be set here in the event of errors

### devsdk_service_stop

Stop the device service. Any automatic events will be cancelled and the REST API for the device service will be shut down

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
force | bool | Force stop. Currently unused but is passed through to the stop handler
err | devsdk_error* | Nonzero reason codes will be set here in the event of errors

### devsdk_service_free

This function disposes of the device service object and all associated resources

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service

## Additional functionality

### devsdk_usage

This function writes out the commandline options supported by the SDK. It may be useful if a `--help` option is to be implemented

### devsdk_protocols_properties

This function returns a map of properties (keyed on string) for the named protocol.

Parameter | Type | Description
----------|------|------------
prots | devsdk_protocols* | The protocols to search
name | char* | The name of the protocol to search for

### devsdk_protocols_new

This function creates a new protocols object, or adds a property set to an existing one.

Parameter | Type | Description
----------|------|------------
name | char* | The name of the new protocol
properties | iot_data_t* | The properties of the new protocol
list | devsdk_protocols* | The protocols object to extend, or NULL to create a new one

### devsdk_protocols_dup

This function duplicates a protocols object

Parameter | Type | Description
----------|------|------------
e | devsdk_protocols* | object to duplicate

### devsdk_protocols_free

This function disposes of the memory used by a protocols object

Parameter | Type | Description
----------|------|------------
e | devsdk_protocols* | object to free

### devsdk_get_secrets

This function returns secrets (credentials) for the service. In insecure mode these will be part of the service configuration, in secure mode they will be retrieved from the secret store (eg, Vault).

The secrets are returned as a string-keyed map. This should be disposed after use using `iot_data_free`

### devsdk_post_readings

This function posts readings to EdgeX. Depending on configuration this may be via REST to core-data or via the Message Bus to various upstream services. The readings are assembled into an Event and then posted

This function may be used in services which implement the autoevent handlers or by any other service where the natural operation is that readings are generated by the device rather than being explicitly requested

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
device_name | char* | Name of the device that has generated the readings
resource_name | char* | Name of the resource (or command) corresponding to this set of readings
values | devsdk_commandresult* | The readings to be posted

The cardinality of the `values` array will depend on the resource - if it is a `deviceResource` there should be a single reading; for a `deviceCommand` there may be several

### devsdk_add_discovered_devices

This function should be called in response to a request for device discovery, but may be called at any time if for a particular device class immediate automatic discovery is appropriate. The function takes an array of devices in order to allow for batching, but it may be called multiple times during the course of a single invocation of discovery if necessary

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
ndevices | uint32_t | Number of devices discovered
devices | devsdk_discovered_device* | Array of discovered devices

### devsdk_set_device_opstate

This function can be used to indicate that a device has become non-operational or non-responsive, or that a device has returned from such a state. The SDK will return errors for requests for a device marked non-operational without calling the get or set handler

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
devname | char* | The device that has changed state
operational | bool | The new operational state

### devsdk_get_devices

Returns a list of devices registered with this service

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service

The returned list should be disposed after use using `devsdk_free_devices`

### devsdk_get_device

Returns information on a device

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
name | char* | The device to query for

The returned device should be disposed after use using `devsdk_free_devices`

### devsdk_free_devices

Frees a devices structure returned by `devsdk_get_devices` or `devsdk_get_device`

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
d | devsdk_devices* | The device or device list

### devsdk_publish_discovery_event

Publish a system event for discovery. Events will be published to "edgex.system-event.(service-name).device.discovery".

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
request_id | const char* | The discovery request ID
progress | const int8 | Progress value
discovered_devices | uint64 | The number of discovered devices

### devsdk_publish_system_event

Publish a generic system event. Events will be published to "edgex.system-event.(service-name).device.(action)".

Parameter | Type | Description
----------|------|------------
svc | devsdk_service_t* | The device service
action | const char* | The action that triggered the event to be used in the topic name
details | iot_data_t* | A map of parameters to be published in the event details
