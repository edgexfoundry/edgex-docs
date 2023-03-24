# Custom Metadata

Custom metadata can be applied and retrieved for each camera added to the service.

## Usage

- The `CustomMetadata` map is an element in the `ProtocolProperties` device field. It is initialized to be empty on discovery, so the user can add their desired fields. Otherwise, the user can pre-define this field in a camera.toml file.

### Preset Custom Metadata

If you add pre-defined devices, set up the `CustomMetadata` object as shown in the [camera.toml.example file](../cmd/res/devices/camera.toml.example).

```toml
# Pre-defined Devices
[[DeviceList]]
Name = "Camera001"
ProfileName = "onvif-camera"
Description = "onvif conformant camera"
  [DeviceList.Protocols]
    ... 
    [DeviceList.Protocols.CustomMetadata]
    Location = "Front door"
    Color = "Black and white"
```


### Set Custom Metadata

Use the CustomMetadata resource to set the fields of `CustomMetadata`. Choose the key/value pairs to represent your custom fields.

1. Use this command to put the data in the CustomMetadata field.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/<device name>/CustomMetadata' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "CustomMetadata": {
            "Location":"Front Door",
            "Color":"Black and white",
            "Condition": "Good working condition"
        }
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


### Get Custom Metadata

Use the CustomMetadata resource to get and display the fields of `CustomMetadata`.

1. Use this command to return all of the data in the CustomMetadata field.

```shell
curl http://localhost:59882/api/v2/device/name/<device name>/CustomMetadata | jq .
```
2. The repsonse from the curl command.
```shell
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "3fa1fe68-b915-4053-a3e1-cc32e5000688",
      "id" : "ba3987f9-b45b-480a-b582-f5501d673c4d",
      "origin" : 1655409814077374935,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "3fa1fe68-b915-4053-a3e1-cc32e5000688",
            "id" : "cf96e5c0-bde1-4c0b-9fa4-8f765c8be456",
            "objectValue" : {
               "Color" : "Black and white",
               "Condition" : "Good working condition",
               "Location" : "Front Door"
            },
            "origin" : 1655409814077374935,
            "profileName" : "onvif-camera",
            "resourceName" : "CustomMetadata",
            "value" : "",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "CustomMetadata"
   },
   "statusCode" : 200
}
```


### Get Specific Custom Metadata

Pass the `CustomMetadata` resource a query to get specific field(s) in CustomMetadata. The query must be a base64 encoded json object with an array of fields you want to access.

1. Json object holding an array of fields you want to query.
```json
'[
    "Color",
    "Location"
]'
```

2. Use this command to convert the json object to base64.
```shell
echo '[
    "Color",
    "Location"
]' | base64
```

3. The response converted to base64.
```shell
WwogICAgIkNvbG9yIiwKICAgICJMb2NhdGlvbiIKXQo=
```

4. Use this command to query the fields you provided in the json object.
```shell
curl http://localhost:59882/api/v2/device/name/<device name>/CustomMetadata?jsonObject=WwogICAgIkNvbG9yIiwKICAgICJMb2NhdGlvbiIKXQo= | jq .

```

5. Curl response. 
```shell
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "3fa1fe68-b915-4053-a3e1-cc32e5000688",
      "id" : "24c3eb0a-48b1-4afe-b874-965aeb2e42a2",
      "origin" : 1655410556448058195,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "3fa1fe68-b915-4053-a3e1-cc32e5000688",
            "id" : "d0c26303-20b5-4ccd-9e63-fb02b87b8ebc",
            "objectValue" : {
               "Color": "Black and white",
               "Location" : "Front Door"
            },
            "origin" : 1655410556448058195,
            "profileName" : "onvif-camera",
            "resourceName" : "CustomMetadata",
            "value" : "",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "CustomMetadata"
   },
   "statusCode" : 200
}
```

### Additional Usage

Use the DeleteCustomMetadata resource to delete entries in custom metadata

1. Use this command to delete fields.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/<device name>/DeleteCustomMetadata' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "DeleteCustomMetadata": [
            "Color", "Condition"
        ]
    }' | jq .
```
2. The response from the curl command.
```
{
    "apiVersion": "v2",
    "statusCode": 200
}
```
