# Get and Set Friendly Name and MAC Address

Friendly name and MAC address can be set and retrieved for each camera added to the service.


## Preset FriendlyName
`FriendlyName` is an element in the `Onvif ProtocolProperties` device field. It is initialized to be empty or `<Manufacturer+Model>`
if credentials are provided on discovery. The user can also pre-define this field in a camera.toml file.

If you add pre-defined devices, set up the `FriendlyName` field as shown in the
[camera.toml.example file](../cmd/res/devices/camera.toml.example).

```toml
# Pre-defined Devices
[[DeviceList]]
Name = "Camera001"
ProfileName = "onvif-camera"
Description = "onvif conformant camera"
  [DeviceList.Protocols]
    [DeviceList.Protocols.Onvif]
    Address = "192.168.12.123"
    Port = "80"
    FriendlyName = "Home camera"
    [DeviceList.Protocols.CustomMetadata]
    Location = "Front door"
```

## Set Friendly Name

Friendly name can also be set via Edgex device command.
FriendlyName device resource is used to set `FriendlyName` of a camera.

1. Use this command to set FriendlyName field.

```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/<device name>/FriendlyName' \
    --header 'Content-Type: application/json' \
    --data-raw '{
            "FriendlyName":"Home camera"
    }' | jq .
```
2. The response from the curl command.
```
{
    "apiVersion": "v2",
    "statusCode": 200
}
```
>Note: ensure all data is properly formatted json, and that all special characters are escaped if necessary


## Get Friendly Name

Use the FriendlyName device resource to retrieve `FriendlyName` of a camera.

1. Use this command to return FriendlyName field.

```shell
curl http://localhost:59882/api/v2/device/name/<device name>/FriendlyName | jq .
```
2. Response from the curl command. FriendlyName value can be found under `value` field in the json response.
```shell
{
  "apiVersion": "v2",
  "statusCode": 200,
  "event": {
    "apiVersion": "v2",
    "id": "5b924351-31c7-469e-a9ba-dea063fdbf3a",
    "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-cc32e5000688",
    "profileName": "onvif-camera",
    "sourceName": "FriendlyName",
    "origin": 1658441317910501400,
    "readings": [
      {
        "id": "62a0424b-a3c1-45ea-b640-58c7aa3ea476",
        "origin": 1658441317910501400,
        "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-cc32e5000688",
        "resourceName": "FriendlyName",
        "profileName": "onvif-camera",
        "valueType": "String",
        "value": "Home camera"
      }
    ]
  }
}
```

## Preset MACAddress
`MACAddress` is an element in the `Onvif ProtocolProperties` device field. It will be set to empty string if no value is provided, or
it will be set with the MAC address value of the camera if valid credentials are provided.
The user can pre-define this field in a camera.toml file.



If you add pre-defined devices, set up the `MACAddress` field as shown in the
[camera.toml.example file](../cmd/res/devices/camera.toml.example).

## Set MAC Address

MACAddress can also be set via Edgex device command.This is useful for setting the MAC Address for devices which do not contain 
the MAC Address in the Endpoint Reference Address, or have been added manually without a MAC Address. 
Since the MAC is used to map credentials for cameras, it is important to have this field filled out.

> Note: When a camera successfully becomes `UpWithAuth`, the MAC Address is automatically queried and overridden by the system if available.
Device resource MACAddress is used to set `MACAddress` of a camera.

1. Use this command to set MACAddress field.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/<device name>/MACAddress' \
    --header 'Content-Type: application/json' \
    --data-raw '{
            "MACAddress":"11:22:33:44:55:66"
    }' | jq .
```
2. The response from the curl command.
```
{
    "apiVersion": "v2",
    "statusCode": 200
}
```
>Note: ensure all data is properly formatted json, and that all special characters are escaped if necessary.


## Get MAC Address

Use the MACAddress device resource to retrieve `MACAddress` of a camera.

1. Use this command to return MACAddress field.

```shell
curl http://localhost:59882/api/v2/device/name/<device name>/MACAddress | jq .
```
2. Response from the curl command. MACAddress value can be found under `value` field in the json response.
```shell
{
  "apiVersion": "v2",
  "statusCode": 200,
  "event": {
    "apiVersion": "v2",
    "id": "c13245b0-397f-47c0-84b2-4de3d2fb891d",
    "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-1027f5ea8888",
    "profileName": "onvif-camera",
    "sourceName": "MACAddress",
    "origin": 1658441498356294000,
    "readings": [
      {
        "id": "7a7735ed-3b61-4426-84df-5e9a524e4022",
        "origin": 1658441498356294000,
        "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-1027f5ea8888",
        "resourceName": "MACAddress",
        "profileName": "onvif-camera",
        "valueType": "String",
        "value": "11:22:33:44:55:66"
      }
    ]
  }
}
```
