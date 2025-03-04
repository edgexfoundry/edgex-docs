---
title: Device REST - Testing
---

# Device REST - Testing

## Running Service

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty ds-rest
    ```

This runs, in non-secure mode, all the standard EdgeX services along with the Device Rest service.

## Async

The best way to test this service with simulated data is to use **PostMan** to send data to the following endpoints defined for the above device profiles.

- http://localhost:59986/api/v3/resource/sample-image/jpeg

    - POSTing a JPEG binary image file will result in the `BinaryValue` of the `Reading` being set to the JPEG image data posted.
    - Example test JPEG to post:
        - Select any JPEG file from your computer or the internet

- http://localhost:59986/api/v3/resource/sample-image/png

    - POSTing a PNG binary image file will result in the `BinaryValue` of the `Reading` being set to the PNG image data posted.
    - Example test PNG to post:
        - Select any PNG file from your computer or the internet

- http://localhost:59986/api/v3/resource/sample-json/json

    - POSTing a JSON string value will result in the  `Value` of the `Reading` being set to the JSON string value posted.

      *Note: Currently there isn't a JSON data type, thus there is no validation that the string value is valid JSON. It is up to the Application Service using the JSON to first validate it.*

    - Example test JSON value to post:

      ```json
      {
          "id" : "1234",
          "name" : "test data",
          "payload" : "test payload"
      }
      ```

- http://localhost:59986/api/v3/resource/sample-numeric/int
    - POSTing a text integer value will result in the  `Value` of the `Reading` being set to the string representation of the value as an `Int64`. The POSTed value is verified to be a valid `Int64` value.

    - A 400 error will be returned if the POSTed value fails the `Int64` type verification.

    - Example test `int` value to post:

      ```
      1001
      ```

- http://localhost:59986/api/v3/resource/sample-numeric/float
    - POSTing a text float value will result in the  `Value` of the `Reading` being set to the string representation of the value as an `Float64`. The POSTed value is verified to be a valid `Float64` value.

    - A 400 error will be returned if the POSTed value fails the `Float64` type verification.

    - Example test `float` value to post:

      ```
      500.568
      ```

## Commands

This device service supports commanding functionality with a sample profile for the data types as shown in below table.

| Data Type | GET   | PUT   |
|-----------|-------|-------|
| Binary    | **Y** | **N** |
| Object    | **Y** | **Y** |
| Bool      | **Y** | **Y** |
| String    | **Y** | **Y** |
| Uint8     | **Y** | **Y** |
| Uint16    | **Y** | **Y** |
| Uint32    | **Y** | **Y** |
| Uint64    | **Y** | **Y** |
| Int8	     | **Y** | **Y** |
| Int16     | **Y** | **Y** |
| Int32     | **Y** | **Y** |
| Int64     | **Y** | **Y** |
| Float32   | **Y** | **Y** |
| Float64   | **Y** | **Y** |

Using `curl` command-line utility or `PostMan` we can send GET/PUT request to EdgeX. 
These commands are explained in `GET Command` section below. End device can be anything, For example `nodejs based REST emulator` is used as end device for testing commanding functionaity of the REST device service. Example end device code is mentioned in `End Device` section below.

### Simulated End Device

Example simulated end device code using `nodejs` is as shown below. 
This example code has endpoint for `int8` resource. 
To test GET/SET commands for other resources, this code needs to be expanded in the same way for other device resources also.

```js
///////////////////BUILD AND RUN INSTRUCTIONS/////////////////////
// Install node, npm, express module in target machine
// Run using "node end-device.js"
/////////////////////////////////////////////////////////////////

var express = require('express');
var bodyParser = require('body-parser')
var app = express();

var textParser = bodyParser.text({type: '*/*'})

//-128 to 127
var int8 = 111

// GET int8
app.get('/api/int8', function (req, res) {
console.log("Get int8 request");
res.end(int8.toString());
})

// PUT int8
app.put('/api/int8', textParser, function (req, res) {
console.log("Put int8 request");
console.log(req.body);
int8 = req.body;
res.end(int8);
})

var server = app.listen(5000, function () {
var host = server.address().address
var port = server.address().port
console.log("Server listening at http://%s:%s", host, port)
})
```

### GET Command

Example Core Command GET request for `int8` device resource using curl command-line utility is as shown below.
```
   $ curl --request GET http://localhost:59882/api/v3/device/name/2way-rest-device/int8
```
Example Core Command GET request for `int8` device resource using **PostMan** is as shown below.
```
http://localhost:59882/api/v3/device/name/2way-rest-device/int8
```

`2way-rest-device` is the device name as defined in the [device file](https://github.com/edgexfoundry/device-rest-go/blob/main/cmd/res/devices/sample-devices.yaml).
!!! example - "Example expected success response from the end device"
    ```json
       {
       "apiVersion" : "v3",
       "event" : {
          "apiVersion" : "v3",
          "deviceName" : "2way-rest-device",
          "id" : "46baf3d5-98fd-4073-b52e-801660b01ce6",
          "origin" : 1670506568209119757,
          "profileName" : "sample-2way-rest-device",
          "readings" : [
             {
                "deviceName" : "2way-rest-device",
                "id" : "c7d4d4fe-13f5-423a-8d62-0e57f8dbc063",
                "origin" : 1670506568209111164,
                "profileName" : "sample-2way-rest-device",
                "resourceName" : "int8",
                "value" : "111",
                "valueType" : "Int8"
             }
          ],
          "sourceName" : "int8"
       },
       "statusCode" : 200
       } 
    ```

!!! note
    You may receive the error response as shown below:
    ```json
    {"apiVersion":"v3","message":"request failed, status code: 500, err: {\"apiVersion\":\"v3\",\"message\":\"error reading Regex DeviceResource(s) int8 for 2way-rest-device -\\u003e Get request failed\",\"statusCode\":500}","statusCode":500}
    ```
    This error response is due to the fact that the [device file](https://github.com/edgexfoundry/device-rest-go/blob/main/cmd/res/devices/sample-devices.yaml) defines the simulated 2way-rest-device with `127.0.0.1` ip address; however, the simulated 2way-rest-device is actually running in the host network, so that the device-rest service cannot access the simulated 2way-rest-device through `127.0.0.1`. 
    To resolve this issue, you will have to correct the ip address for the simulated 2way-rest-device through the following steps:

    1. Find the ip address of the `docker0` network by running the following command in the terminal:
        ```
        $ ifconfig docker0 | grep 'inet ' | awk '{print $2}'        
        ```
    2. Open a web browser and access to the edgex UI at `http://localhost:4000/en-US/#/metadata/device-center/device-list`
    3. Update the ip address of the simulated 2way-rest-device from `127.0.0.1` to the ip address of the `docker0` network

### SET Command

!!! example - "Example Core Command SET request to `int8` device resource using curl"
    ```
    $ curl -i -X PUT -H "Content-Type: application/json" -d '{"int8":12}' http://localhost:59882/api/v3/device/name/2way-rest-device/int8
    ```
!!! example - "Example Core Command SET request to `int8` device resource using **PostMan**"
    ```
    http://localhost:59882/api/v3/device/name/2way-rest-device/int8
    ```
    - Body with a text integer value "12" will result in the  `Value` of the `Command` being set to the string representation of the value as an `Int8`. The PUT value is verified to be a valid `Int8` value.
    - A 400 error will be returned if the PUTted value fails the `Int8` type verification.

`2way-rest-device` is the device name as defined in the device list.

!!! example - Example expected success response from the end device
    ```
    HTTP/1.1 200 OK
    Content-Type: application/json
    X-Correlation-Id: d208c432-0ee4-4d7e-b819-378bec45cbf6
    Date: Thu, 08 Dec 2022 14:02:14 GMT
    Content-Length: 37
    
    {"apiVersion":"v2","statusCode":200}
    ```
