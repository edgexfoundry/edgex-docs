# Provision a device

In the last act of setup, a device service often discovers and provisions devices (either [statically or dynamically](../microservices/device/Ch-DeviceServices.md#device-discovery-and-provision-watchers)) and that it is going to manage on the part of
EdgeX. Note the word "often" in the last sentence. Not all device
services will discover new devices or provision them right away.
Depending on the type of device and how the devices communicate, it is
up to the device service to determine how/when to provision a device. In
some cases, the provisioning may be triggered by a human request of
the device service once everything is in place and once the human can
provide the information the device service needs to physically connected
to the device.

## Device

See [core metadata API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/2.0.0) for more details.

For the sake of this demonstration, the call to core metadata will
provision the human/dog counting monitor camera as if the device service
discovered it (by some unknown means) and provisioned the device as part
of some startup process. To create a `Device`, it must be associated to a
[`DeviceProfile`](./Ch-WalkthroughDeviceProfile.md), a
[`DeviceService`](./Ch-WalkthroughDeviceService.md), and
contain one or more `Protocols` that define how and where to communicate with the device (possibly providing its address). 

When creating a device, you specify both the admin state (just as you did for a device service) and an operating state. The operating state (aka op state) provides an indication on the part of EdgeX about the internal operating status of the device. The operating state is not set externally (as by another system or man), it is a signal from within EdgeX (and potentially the device service itself) about the condition of the device. The operating state of the device may be either `UP` or `DOWN` (it may alsy be `UNKNOWN` if the state cannot be determined). When the operating state of the device is `DOWN`, it is either experiencing some difficulty or going through some process (for example an upgrade) which does not allow it to function in its normal capacity.

### Walkthrough - Device

Use either the Postman or Curl tab below to walkthrough creating the `Device`.

=== "Postman"

    Make a POST request to `http://localhost:59881/api/v2/device` with the following body:

    ``` json
        [
            {
                "apiVersion": "v2",
                "device": {
                    "name": "countcamera1",
                    "description": "human and dog counting camera #1",
                    "adminState": "UNLOCKED",
                    "operatingState": "UP",
                    "labels": [
                        "camera","counter"
                    ],
                    "location": "{lat:45.45,long:47.80}",
                    "serviceName": "camera-control-device-service",
                    "profileName": "camera-monitor-profile",
                    "protocols": {
                        "camera-protocol": {
                            "camera-address": "localhost",
                            "port": "1234",
                            "unitID": "1"
                        }
                    }
                }
            }
        ]
    ```

    Be sure that you are POSTing **raw** data, not form-encoded data.  If your API call is successful, you will get a generated ID for your new `Device` in the response area.

    !!! Note
        The `camera-monitor-profile` was created by the device profile uploaded in a previous walkthrough step. The `camera-control-device-service` was created in the last walkthough step.  These names must match the previously created EdgeX objects in order to successfully provision your device.

    !!! edgey "EdgeX 2.0"
        As of Ireland/V2, device names may only contain unreserved characters which are ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_~


=== "Curl"

    Make a curl POST request as shown below.

    ``` shell
    curl -X 'POST' 'http://localhost:59881/api/v2/device' -d '[{"apiVersion": "v2", "device": {"name": "countcamera1","description": "human and dog counting camera #1","adminState": "UNLOCKED","operatingState": "UP","labels": ["camera","counter"],"location": "{lat:45.45,long:47.80}","serviceName": "camera-control-device-service","profileName": "camera-monitor-profile","protocols": {"camera-protocol": {"camera-address": "localhost","port": "1234","unitID": "1"}}}}]'
    ```

    If your API call is successful, you will get a generated ID (a UUID) for your new `Device`.

    !!! Note
        The `camera-monitor-profile` was created by the device profile uploaded in a previous walkthrough step. The `camera-control-device-service` was created in the last walkthough step.  These names must match the previously created EdgeX objects in order to successfully provision your device.

    !!! edgey "EdgeX 2.0"
        As of Ireland/V2, device names may only contain unreserved characters which are ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_~

#### Test the GET API

Ensure the monitor camera is among the devices known to core metadata.  If you make a GET call to the `http://localhost:59881/api/v2/device/all` URL (with Postman or curl) you will get a listing (in JSON) of all the devices currently defined in your instance of EdgeX that should include the one you just added.

There are many [additional APIs on core metadata](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-metadata/2.0.0) to retrieve a `DeviceProfile`, `Device`, `DeviceService`, etc. As an example, here is one to find
all devices associated to a given `DeviceProfile`.

``` shell
curl -X GET http://localhost:59881/api/v2/device/profile/name/camera-monitor-profile | json_pp
```

[<Back](Ch-WalkthroughDeviceService.md){: .md-button } [Next>](Ch-WalkthroughCommands.md){: .md-button }
