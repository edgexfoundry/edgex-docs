# Device Service REST API

## Status

**proposed**

## Context

This ADR details the REST API to be provided by Device Service implementations in EdgeX version 2.x. As such, it supercedes the equivalent sections of the earlier "Device Service Functional Requirements" document. These requirements should be implemented as far as possible within the Device Service SDKs, but they also apply to any Device Service implementation.

## Decision

### Common endpoints

The DS should provide the REST endpoints that are expected of all EdgeX microservices, specifically:

* *config*
* *metrics*
* *ping*
* *version*

### Callback

| Endpoint | Methods
| --- | ---
| *callback/device* | `PUT` and `POST`
| *callback/device/id/{id}* | `DELETE`
| *callback/profile* | `PUT` and `POST`
| *callback/profile/id/{id}* | `DELETE`
| *callback/watcher* | `PUT` and `POST`
| *callback/watcher/id/{id}* | `DELETE`

| parameter | meaning
| --- | ---
| *{id}* | a database-generated object id

These endpoints are used by the Core Metadata service to inform the device service of metadata updates. Endpoints are defined for each of the objects of interest to a device service, ie Devices, Device Profiles and Provision Watchers. On receipt of calls to these endpoints the device service should update its internal state accordingly.

#### Object deletion

When an object is deleted, the Metadata service makes a `DELETE` request to the relevant *callback/{type}/id/{id}* endpoint.

#### Object creation and updates

When an object is created or updated, the Metadata service makes a `POST` or `PUT` request respectively to the relevant *callback/{type}* endpoint. The payload of the request is the new or updated object.

### Device

| Endpoint | Methods
| --- | ---
| *device/name/{name}/{command}* | `GET` and `PUT`
| *device/{id}/{command}* | `GET` and `PUT`

| parameter | meaning
| --- | ---
| *{id}* | a database-generated device id *or*
| *{name}* | the name of the device
| *{command}* | the command name

The command specified must match a deviceCommand or deviceResource name in the device's profile

**body** (for `PUT`): An `application/json` SettingRequest, which is a set of key/value pairs where the keys are valid deviceResource names, and the values provide the command argument for that resource. Example: `{"AHU-TargetTemperature": "28.5", "AHU-TargetBand": "4.0"}`

| Return code | Meaning
| --- | ---
| **200** | the command was successful
| **404** | the specified device does not exist, or the command/resource is unknown
| **405** | attempted write to a read-only resource
| **423** | the specified device is locked (admin state) or disabled (operating state)
| **500** | the device driver is unable to process the request

**response body**: A successful `GET` operation will return a JSON-encoded Event, which contains one or more Readings. Example: `{"device":"Gyro","origin":1592405201763915855,"readings":[{"name":"Xrotation","value":"124","origin":1592405201763915855,"valueType":"int32"},{"name":"Yrotation","value":"-54","origin":1592405201763915855,"valueType":"int32"},{"name":"Zrotation","value":"122","origin":1592405201763915855,"valueType":"int32"}]}`

This endpoint is used for obtaining readings from a device, and for writing settings to a device.

#### Data formats

The values obtained when readings are taken, or used to make settings, are expressed as strings.

| Type | EdgeX types | Representation
| --- | --- | ---
| Boolean | `bool` | "true" or "false"
| Integer | `uint8-uint64`, `int8-int64` | Numeric string, eg "-132"
| Float | `float32`, `float64` | base64 encoded little-endian binary or decimal with exponent, eg "1.234e-5"
| String | `string` | string
| Binary | `bytes` | octet array
| Array | `boolarray`, `uint8array-uint64array`, `int8array-int64array`, `float32array`, `float64array` | JSON Array, eg "["1", "34", "-5"]"

Notes:
- The presence of a Binary reading will cause the entire Event to be encoded using CBOR rather than JSON
- The representation of a float is determined by the *"floatEncoding"* attribute of the device resource. *"base64"* is the default, *"eNotation"* will cause the float to be written as a decimal with exponent.

#### Readings and Events

A Reading represents a value obtained from a deviceResource. It contains the following fields

| Field name | Description
| --- | ---
| *name* | The name of the deviceResource
| *valueType* | The type of the data
| *origin* | A timestamp indicating when the reading was taken
| *value* | The reading value
| *mediaType* | (Only for Binary readings) The MIME type of the data
| *floatEncoding* | (Only for floats and arrays of floats) The float representation in use

An Event represents the result of a `GET` command. If the command names a deviceResource, the Event will contain a single Reading. If the command names a deviceCommand, the Event will contain as many Readings as there are deviceResources listed in the deviceCommand.

The fields of an Event are as follows:

| Field name | Description
| --- | ---
| *device* | The name of the Device from which the Readings are taken
| *origin* | The time at which the Event was created
| *readings* | An array of Readings

#### Query Parameters

Calls to the device endpoints may include a Query String in the URL. This may be used to pass parameters relating to the request to the device service. Individual device services may define their own parameters to control specific behaviors. Parameters beginning with the prefix `ds-` are reserved to the Device SDKs and the following parameters are defined for GET requests:

| Parameter | Valid Values | Default | Meaning
| --- | --- | --- | ---
| *ds-postevent* | "yes" or "no" | "no" | If set to yes, a successful `GET` will result in an event being posted to core-data
| *ds-returnevent* | "yes" or "no" | "yes" | If set to no, there will be no Event returned in the http response

#### Device States

A Device in EdgeX has two states associated with it: the Administrative state and the Operational state. The Administrative state may be set to `LOCKED` (normally `UNLOCKED`) to block access to the device for administrative reasons. The Operational state may be set to `DISABLED` (normally `ENABLED`) to indicate that the device is not currently working. In either case access to the device via this endpoint will be denied and HTTP 423 ("Locked") will be returned.

#### Data Transformations

A number of simple data transformations may be defined in the deviceResource. The table below shows these transformations in the order in which they are applied to outgoing data, ie Readings. The transformations are inverted and applied in reverse order for incoming data.

| Transform | Applicable reading types | Effect
| --- | --- | ---
**mask** | Integers | The reading is bitwise masked with the specified value.
**shift** | Integers | The reading is bit-shifted by the specified value. Positive values indicate right-shift, negative for left.
**base** | Integers and Floats | The reading is replaced by the specified value raised to the power of the reading.
**scale** | Integers and Floats | The reading is multiplied by the specified value.
**offset** | Integers and Floats | The reading is increased by the specified value.

The operation of the **mask** transform on incoming data (a setting) is that the value to be set on the resource is the existing value bitwise-anded with the complement of the mask, bitwise-ored with the value specified in the request.

ie, `new-value = (current-value & !mask) | request-value`

The combination of mask and shift can therefore be used to access data contained in a subdivision of an octet.

#### Assertions and Mappings 

Assertions are another attribute in a device resource's PropertyValue which specify a string value which the result is compared against. If the comparison fails, then the result is set to a string of the form *"Assertion failed for device resource: \<name>, with value: \<result>"*, this also has a side-effect of setting the device operatingstate to `DISABLED`. A 500 status code is also returned.

Mappings may be defined in a deviceCommand. These allow Readings of string type to be remapped. Mappings are applied after assertions are checked, and are the final transformation before Readings are created. Mappings are also applied, but in reverse, to settings (`PUT` request data).

#### lastConnected timestamp

Each Device has as part of its metadata a timestamp named `lastConnected`, this
indicates the most recent occasion when the device was successfully interacted
with. The device service should update this timestamp every time a GET or PUT
operation succeeds, unless it has been configured not to do so (eg for
performance reasons).

### Discovery

| Endpoint | Methods
| --- | ---
| *discovery* | `POST`

A call to this endpoint triggers the device discovery process, if enabled. See
[Discovery Design](../../legacy-design/device-service/discovery.md) for details.

## Consequences

### Changes from v1.x API

* The *callback* endpoint is split according to the type of object being updated
* Callbacks for new and updated objects take the object in the request body
* The *device/all* form is removed
* `GET` requests take parameters controlling what is to be done with resulting Events, and the default behavior does not send the Event to core-data

## References

OpenAPI definition of v2 API : https://github.com/edgexfoundry/device-sdk-go/blob/master/api/oas3.0/v2/device-sdk.yaml
Device Service Functional Requirements (Geneva) : https://wiki.edgexfoundry.org/download/attachments/329488/edgex-device-service-requirements-v11.pdf?version=1&modificationDate=1591621033000&api=v2
