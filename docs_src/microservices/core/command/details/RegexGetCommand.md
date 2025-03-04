---
title: Core Command - Regex Get Command
---

# Core Command - Regex Get Command

!!! edgey "Edgex 3.0"
    Regex Get Command is new in EdgeX 3.0

Command service supports regex syntax for command name.
Regex syntax will match against all DeviceResources in the DeviceProfile.  

Consider the following example device profile:
```yaml
apiVersion: "v2"
name: "Simple-Device"
deviceResources:
  -
    name: "Xrotation"
    isHidden: true
    description: "X axis rotation rate"
    properties:
        valueType: "Int32"
        readWrite: "RW"
        units: "rpm"
  -
    name: "Yrotation"
    isHidden: true
    description: "Y axis rotation rate"
    properties:
        valueType: "Int32"
        readWrite: "RW"
        "units": "rpm"
  -
    name: "Zrotation"
    isHidden: true
    description: "Z axis rotation rate"
    properties:
        valueType: "Int32"
        readWrite: "RW"
        "units": "rpm"
```
regex command name `.rotation` will return event including `Xrotation`, `Yrotation` and `Zrotation` readings.

Note that the [RE2 syntax](https://github.com/google/re2/wiki/Syntax) accepted by Go's `regexp` package contains character like `.`, `*`, `+` ...etc.
These characters need to be URL-encoded before executing:
```shell
$ curl http://localhost:59882/api/{{api_version}}/device/name/Simple-Device01/%2Erotation

{
  "apiVersion" : "{{api_version}}",
  "statusCode": 200,
  "event": {
    "apiVersion" : "{{api_version}}",
    "id": "821f9a5d-e521-4ea7-83f9-f6bce6881dce",
    "deviceName": "Simple-Device01",
    "profileName": "Simple-Device",
    "sourceName": ".rotation",
    "origin": 1679464105224933600,
    "readings": [
      {
        "origin": 1679464105224933600,
        "deviceName": "Simple-Device01",
        "resourceName": "Xrotation",
        "profileName": "Simple-Device",
        "valueType": "Int32",
        "units": "rpm",
        "value": "0"
      },
      {
        "id": "7f38677a-aa1f-446b-9e28-4555814ea79d",
        "origin": 1679464105224933600,
        "deviceName": "Simple-Device01",
        "resourceName": "Yrotation",
        "profileName": "Simple-Device",
        "valueType": "Int32",
        "units": "rpm",
        "value": "0"
      },
      {
        "id": "ad72be23-1d0e-40a3-b4ec-2fa0fa5aba58",
        "origin": 1679464105224933600,
        "deviceName": "Simple-Device01",
        "resourceName": "Zrotation",
        "profileName": "Simple-Device",
        "valueType": "Int32",
        "units": "rpm",
        "value": "0"
      }
    ]
  }
}

```
