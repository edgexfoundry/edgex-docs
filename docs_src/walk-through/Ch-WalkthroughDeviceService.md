# Register your device service

Once the reference information is established by the device service in
core data and meta data, the device service can register or define
itself in EdgeX. That is, it can proclaim to EdgeX that "I have arrived
and am functional."

## Register with Core Configuration and Registration

Part of that registration process of the device service, indeed any
EdgeX micro service, is to register itself with the [core configuration &
registration](../microservices/configuration/Ch-Configuration.md). In this process, the micro service provides its location
to the Config/Reg micro service and picks up any new/latest
configuration information from this central service. Since there is no
real device service in this walkthrough demonstration, this part of the inter-micro
service exchange is not explored here.

## Device Service

See [core metadata API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/1.2.0) for more details.

At this point in your walkthrough, the device service must create a representative instance of itself in core
metadata. It is in this registration that the device service is
associated to the `Addressable` that was [created earlier in this walkthrough](./Ch-WalkthroughData.md#walk-through-addressables). 

The name of the device service must be unique across all of EdgeX. Note
the admin and operating states. The administrative state (aka admin
state) provides control of the device service by man or other systems.
It can be set to `locked` or `unlocked`. When a device service is set to
`locked`, it is not suppose to respond to any command requests nor send
data from the devices. 

The operating state (aka op state) provides an
indication on the part of EdgeX about the internal operating status of
the device service. The operating state is not set externally (as by
another system or man), it is a signal from within EdgeX (and
potentially the device service itself) about the condition of the
service. The operating state of the device service may be either `enabled`
or `disabled`. When the operating state of the device service is `disabled`,
it is either experiencing some difficulty or going through some process
(for example an upgrade) which does not allow it to function in its
normal capacity.

### Walkthrough - Device Service

Use either the Postman or Curl tab below to walkthrough creating the `DeviceService`.

=== "Postman"

    Make a POST request to `http://localhost:48081/api/v1/deviceservice` with the following body:

    ``` json
    BODY: {"name":"camera control device service","description":"Manage human and dog counting cameras","labels":["camera","counter"],"adminState":"unlocked","operatingState":"enabled","addressable":  
    {"name":"camera control"}}
    ```

    Be sure that you are POSTing **raw** data, not form-encoded data.  If your API call is successful, you will get a generated ID (a UUID) for your new `DeviceService` in the response area.

=== "Curl"

    Make a curl POST request as shown below.

    ``` shell
    curl -X POST -d '{"name":"camera control device service","description":"Manage human and dog counting cameras","labels":["camera","counter"],"adminState":"unlocked","operatingState":"enabled","addressable": {"name":"camera control"}}' localhost:48081/api/v1/deviceservice
    ```

    If your API call is successful, you will get a generated ID (a UUID) for your new `DeviceService`.

#### Test the GET API
If you make a GET call to the `http://localhost:48081/api/v1/deviceservice` URL (with Postman or curl) you will get a listing (in JSON) of all the device services currently defined
in your instance of EdgeX, including the one you just added.

[<Back](Ch-WalkthroughDeviceProfile.md){: .md-button } [Next>](Ch-WalkthroughProvision.md){: .md-button }
