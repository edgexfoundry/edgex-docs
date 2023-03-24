
# General Usage

This document will describe how to execute some of the most important types of commands used with the device service.

## Table of Contents

[Get the Available Commands](#get-the-available-commands)  
[Read a Single Resource](#execute-a-get-command---read-single-resource)  
[Read Multiple Resources](#execute-a-get-command---read-multiple-resources)  
[Set a Single Resource](#execute-a-set-command---write-single-resource)  
[Set Multiple Resources](#execute-a-set-command---write-multiple-resource)  
[Execute Commands Requiring Paramters](#execute-command-requiring-parameters)  
[Next Steps](#next-steps)  

## Get the Available Commands
1. Check the available commands from core-command service:
```shell
curl http://localhost:59882/api/v2/device/name/Camera001 | jq
```

Example Output:

```json
{
  "apiVersion": "v2",
  "statusCode": 200,
  "deviceCoreCommand": {
    "deviceName": "Camera001",
    "profileName": "onvif-camera",
    "coreCommands": [
        {
        "name": "NetworkDefaultGateway",
        "get": true,
        "set": true,
        "path": "/api/v2/device/name/Camera001/NetworkDefaultGateway",
        "url": "http://edgex-core-command:59882",
        "parameters": [
          {
            "resourceName": "NetworkDefaultGateway",
            "valueType": "Object"
          }
        ]
        },
        {
        "name": "AddMetadataConfiguration",
        "set": true,
        "path": "/api/v2/device/name/Camera001/AddMetadataConfiguration",
        "url": "http://edgex-core-command:59882",
        "parameters": [
          {
            "resourceName": "AddMetadataConfiguration",
            "valueType": "Object"
          }
        ]
        },
    ]
    }
}
```

>NOTE: This response has been shortened, most device profiles will have many resources.

## Execute a Get Command - Read Single Resource

Example Command:
```shell
curl http://0.0.0.0:59882/api/v2/device/name/Camera001/Hostname | jq
```
Example Output:

```json
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "Camera001",
      "id" : "6b46d058-d8e0-4095-ba80-4a6de1787510",
      "origin" : 1635749209227019000,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "Camera001",
            "id" : "a1b0d809-c88a-4889-920e-8ac64e6aa658",
            "objectValue" : {
               "HostnameInformation" : {
                  "FromDHCP" : false,
                  "Name" : "localhost"
               }
            },
            "origin" : 1635749209227019000,
            "profileName" : "onvif-camera",
            "resourceName" : "Hostname",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "Hostname"
   },
   "statusCode" : 200
}
```

## Execute a Get Command - Read Multiple Resources

Example Command:
```shell
curl http://0.0.0.0:59882/api/v2/device/name/Camera001/NetworkConfiguration | jq
```

Example Output:
```json
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "sourceName" : "NetworkConfiguration",
      "deviceName" : "Camera001",
      "id" : "24d5e391-0dcd-48f5-8706-6abb11797d29",
      "origin" : 1635868623002677000,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "Camera001",
            "id" : "87d0bcfd-aecf-4ab7-a871-2b85a3c90f00",
            "objectValue" : {
               "HostnameInformation" : {
                  "FromDHCP" : false,
                  "Name" : "localhost"
               }
            },
            "origin" : 1635868623002677000,
            "profileName" : "onvif-camera",
            "resourceName" : "Hostname",
            "valueType" : "Object"
         },
         {
            "deviceName" : "Camera001",
            "id" : "edfa8d6f-a96e-49a8-96c9-595905cbe170",
            "objectValue" : {
               "DNSInformation" : {
                  "DNSManual" : {
                     "IPv4Address" : "192.168.12.1",
                     "Type" : "IPv4"
                  },
                  "FromDHCP" : false
               }
            },
            "origin" : 1635868623002677000,
            "profileName" : "onvif-camera",
            "resourceName" : "DNS",
            "valueType" : "Object"
         },
         ...
      ]
   },
   "statusCode" : 200
}
```

## Execute a Set Command - Write Single Resource
Example Command:
```shell
curl -X PUT -H 'Content-Type: application/json' 'http://0.0.0.0:59882/api/v2/device/name/Camera001/Hostname' \
    -d '{
        "Hostname": {
            "Name": "localhost555"
        }
    }'
```

## Execute a Set Command - Write Multiple Resource
```shell
curl -X PUT -H 'Content-Type: application/json' 'http://0.0.0.0:59882/api/v2/device/name/Camera001/NetworkConfiguration' \
    -d '{
        "Hostname": {
            "Name": "localhost"
        },
        "DNS": {
            "FromDHCP": false,
            "DNSManual": {
                "Type": "IPv4",
                "IPv4Address": "192.168.12.1"
            }
        },
        "NetworkInterfaces": {
            "InterfaceToken": "eth0",
            "NetworkInterface": {
                "Enabled": true,
                "IPv4": {
                    "DHCP": false
                }
            }
            
        },
        "NetworkProtocols": {
            "NetworkProtocols": [ 
                {
                    "Name": "HTTP",
                    "Enabled": true,
                    "Port": 80
                }
            ]
        },
        "NetworkDefaultGateway": {
            "IPv4Address": "192.168.12.1"
        }
    }'
```

## Execute Command Requiring Parameters

In this example, the GetStreamURI will be used as the example command. Some commands require a URL query to be passed, which is a base 64 encoded json object. The information needed for each command differs on an individual basis. This will walk you through how to get information from the device to pass as one of these queries, and use it appropriately. See the Swagger documentation (not implemented) for more information.


1. Get the profile token by executing the `GetProfiles` command:

   ```bash
   curl http://0.0.0.0:59882/api/v2/device/name/Camera001/Profiles | jq 
   ```

   Example Output: 
   ```json
   {    
    "apiVersion": "v2",
    "statusCode": 200,
    "event": {
        "apiVersion": "v2",
        "id": "172bc5e6-cb6c-4c3d-aeb8-193cb968d304",
        "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-cc32e5000688",
        "profileName": "onvif-camera",
        "sourceName": "Profiles",
        "origin": 1657128504840230400,
        "readings": [
        {
            "id": "02e1c0cd-97f3-4846-85bf-dd5eff701e9f",
            "origin": 1657128504840230400,
            "deviceName": "TP-Link-C200-3fa1fe68-b915-4053-a3e1-cc32e5000688",
            "resourceName": "Profiles",
            "profileName": "onvif-camera",
            "valueType": "Object",
            "value": "",
            "objectValue": {
            "Profiles": [
                {
                "Extension": null,
                "Fixed": true,
                "MetadataConfiguration": null,
                "Name": "mainStream", 
                "PTZConfiguration": null,
                "Token": "profile_1",   
                },
            ]}
        }]
    }}
    ```
>NOTE: This output has been trimmed to only show a necessary section.

2. Convert the JSON input to Base64:

   >NOTE: Make sure to change the profile token to the one found in step 1. In this example, it is the string `profile_1`.

   ```json
   {
      "ProfileToken": "profile_1"
   }
   ```
   Example Output:

   ```bash
   echo -n '{
      "ProfileToken": "profile_1"
   }' | base64
   ewogICAgICAiUHJvZmlsZVRva2VuIjogInByb2ZpbGVfMSIKfQ==
   ```

3. Execute `GetStreamURI` command to get RTSP URI from the ONVIF device. Make sure to put the Base64 JSON data after *?jsonObject=* in the command.

   ```bash
   curl http://0.0.0.0:59882/api/v2/device/name/Camera001/StreamUri?jsonObject=ewogICAgICAiUHJvZmlsZVRva2VuIjogInByb2ZpbGVfMSIKfQ== | jq -r '"streamURI: " + '.event.readings[].objectValue.MediaUri.Uri''
   ```
   
   Example Output:

   ```bash
   streamURI: rtsp://192.168.86.34:554/stream1
   ``` 

4. Stream the RTSP stream: 

   Alternatively, ffplay can be used to stream. The command follows this format: 
   
   `ffplay -rtsp_transport tcp rtsp://'<user>':'<password>'@<IP address>:<port>/<streamname>`.

   Using the `streamURI` returned from the previous step, run ffplay:
   
   ```bash
   ffplay -rtsp_transport tcp rtsp://'admin':'Password123'@192.168.86.34:554/stream1
   ```
   >NOTE: While the `streamURI` returned did not contain the username and password, those credentials are required in order to correctly authenticate the request and play the stream. Therefore, it is included in both the VLC and ffplay streaming examples.  
   >NOTE: If the password uses special characters, you must use percent-encoding. 

5. To shut down ffplay, use the ctrl-c command.

## Next Steps
[Explore the Swagger documentation (not implemented)]()  
[Explore auto discovery](./auto-discovery.md)

Refer to the main [README](../README.md) to find links to the rest of the documents.

# License

[Apache-2.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/main/LICENSE)
