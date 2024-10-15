# Register your device service

Our next task in this walkthrough is to have the device service register or define
itself in EdgeX. That is, it can proclaim to EdgeX that "I have arrived
and am functional."

## Register with Core Configuration and Registration

Part of that registration process of the device service, indeed any
EdgeX micro service, is to register itself with the [core configuration &
registration](../microservices/configuration/ConfigurationAndRegistry.md). In this process, the micro service provides its location
to the Config/Reg micro service and picks up any new/latest
configuration information from this central service. Since there is no
real device service in this walkthrough demonstration, this part of the inter-micro
service exchange is not explored here.

## Device Service

See [core metadata API](../../api/core/Ch-APICoreMetadata) for more details.

At this point in your walkthrough, the device service must create a representative instance of itself in core
metadata. It is in this registration that the device service is
given an address that allows core command or any EdgeX service to communicate with it. 

The name of the device service must be unique across all of EdgeX.  When registering a device service, the initial admin state can be provided. The administrative state (aka admin state) provides control of the device service by man or other systems.
It can be set to `LOCKED` or `UNLOCKED`. When a device service is set to
`LOCKED`, it is not suppose to respond to any command requests nor send
data from the devices. See [Admin State documentation](../microservices/device/details/DeviceDiscovery.md#admin-state) for more details.

### Walkthrough - Device Service

> **Note**: The `camera-control-device-service` mentioned below is used for demonstration purposes. In a real-world scenario, make sure that this device service is running or replace it with an appropriate device service from your environment.

Use either the Postman or Curl tab below to walkthrough creating the `DeviceService`.

=== "Postman"

    Make a POST request to `http://localhost:59881/api/{{api_version}}/deviceservice` with the following body:

    ``` json
    {
        "apiVersion" : "{{api_version}}",
        "service": {
        "name": "camera-control-device-service",
        "description": "Manage human and dog counting cameras",
        "adminState": "UNLOCKED",
        "labels": [
            "camera",
            "counter"
        ],
        "baseAddress": "camera-device-service:59990"
        }
    }
    ```

    > **Important**: If the `camera-control-device-service` is not available, you can replace it with a service running in your environment (e.g., `example-device-service`).

=== "Curl"

    Make a curl POST request as shown below.

    ``` shell

    curl -X 'POST' 'http://localhost:59881/api/{{api_version}}/deviceservice' -d '[{"apiVersion" : "{{api_version}}","service": {"name": "camera-control-device-service","description": "Manage human and dog counting cameras", "adminState": "UNLOCKED", "labels": ["camera","counter"], "baseAddress": "camera-device-service:59990"}}]'

    ```

    > **Tip**: Replace `camera-control-device-service` with the appropriate service that is available in your environment.
