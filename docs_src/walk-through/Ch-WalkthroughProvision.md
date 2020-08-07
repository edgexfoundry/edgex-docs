# Provision a device

In the last act of setup, a device service often provisions discovers and
provisions devices (either [statically or dynamically](../microservices/device/Ch-DeviceServices.md#device-discovery-and-provision-watchers)) and that it is going to manage on the part of
EdgeX. Note the word "often" in the last sentence. Not all device
services will discover new devices or provision them right away.
Depending on the type of device and how the devices communicate, it is
up to the device service to determine how/when to provision a device. In
some cases, the provisioning may be triggered by a human request of
the device service once everything is in place and once the human can
provide the information the device service needs to physically connected
to the device.

## Device

See [core metadata API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/1.2.0) for more details.

For the sake of this demonstration, the call to core metadata will
provision the human/dog counting monitor camera as if the device service
discovered it (by some unknown means) and provisioned the device as part
of some startup process. To create a `Device`, it must be associated to a
[`DeviceProfile`](./Ch-WalkthroughDeviceProfile.md), a
[`DeviceService`](./Ch-WalkthroughDeviceService.md), and
contain one or more [Protocols](./Ch-WalkthroughData.md#addressables)
defining its address. 

### Walkthrough - Device

Use either the Postman or Curl tab below to walkthrough creating the `Device`.

=== "Postman"

    Make a POST request to `http://localhost:48081/api/v1/device` with the following body:

    ``` json
    BODY: {"name":"countcamera1","description":"human and dog counting camera #1","adminState":"unlocked","operatingState":"enabled","protocols":{"camera protocol":{"camera address":"camera 1"}},"labels": ["camera","counter"],"location":"","service":{"name":"camera control device service"},"profile":{"name":"camera monitor profile"}}
    ```

    Be sure that you are POSTing **raw** data, not form-encoded data.  If your API call is successful, you will get a generated ID (a UUID) for your new `DeviceService` in the response area.

    !!! Note
        The `camera monitor profile` was created by the device profile uploaded in a previous walkthrough step. The `camera control device service` was created in the last walkthough step.

=== "Curl"

    Make a curl POST request as shown below.

    ``` shell
    curl -X POST -d '{"name":"countcamera1","description":"human and dog counting camera #1","adminState":"unlocked","operatingState":"enabled","protocols":{"camera protocol":{"camera address":"camera 1"}},"labels": ["camera","counter"],"location":"","service":{"name":"camera control device service"},"profile":{"name":"camera monitor profile"}}' localhost:48081/api/v1/device
    ```

    If your API call is successful, you will get a generated ID (a UUID) for your new `Device`.

#### Test the GET API

Ensure the monitor camera is among the devices known to core metadata.  If you make a GET call to the `http://localhost:48081/api/v1/device` URL (with Postman or curl) you will get a listing (in JSON) of all the device services currently defined of devices in your instance of EdgeX that should include the one you just added.

There are many additional APIs on core metadata to retrieve a `Device`, `DeviceService`, etc. As an example, here is one to find
all devices associated to a given `DeviceProfile`.

    ``` shell
    curl -X GET http://localhost:48081/api/v1/device/profilename/camera+monitor+profile | json_pp
    ```

[<Back](Ch-WalkthroughDeviceService.md){: .md-button } [Next>](Ch-WalkthroughCommands.md){: .md-button }
