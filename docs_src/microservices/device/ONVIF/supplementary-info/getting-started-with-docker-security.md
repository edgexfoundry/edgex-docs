# Getting Started With Docker (Security Mode)

This section describes how to run **device-onvif-camera** with **docker** and **EdgeX security mode**.

## 1. Build docker image
Build docker image named edgex/device-onvif-camera:0.0.0-dev with the following command:
```shell
make docker
```

## 2. Prepare edgex-compose/compose-builder
1. Download the [edgex-compose](https://github.com/edgexfoundry/edgex-compose)
2. Change directory to the `edgex-compose/compose-builder`

## 3. Deploy services with the following command:
```shell
make run ds-onvif-camera
```

### 3.1 Check whether the services are running from Consul
1. Get the consul token for Consul Login
```shell
$ make get-consul-acl-token
14891947-51b3-603d-9e35-628fb82993f4
```
2. Navigate to `http://localhost:8500/`

![Consul](images/getting-started-with-docker-consul.jpg)

## 4. Add the Username and Password for the Onvif Camera
```shell
curl --location --request POST 'http://0.0.0.0:59984/api/v2/secret' \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiVersion":"v2",
    "secretName": "bosch",
    "secretData":[
        {
            "key":"username",
            "value":"administrator"
        },
        {
            "key":"password",
            "value":"Password1!"
        },
        {
            "key":"mode",
            "value":"digest"
        }
    ]
}'
```


## 5. Add the device profile to EdgeX
Change directory back to the `device-onvif-camera` and add the device profile to core-metadata service with the following command:
```shell
curl http://localhost:59881/api/v2/deviceprofile/uploadfile \
  -F "file=@./cmd/res/profiles/camera.yaml"
```

## 6. Add the device to EdgeX
Add the device data to core-metadata service with the following command:
```shell
curl -X POST -H 'Content-Type: application/json'  \
  http://localhost:59881/api/v2/device \
  -d '[
          {
            "apiVersion": "v2",
            "device": {
                "name":"Camera003",
                "serviceName": "device-onvif-camera",
                "profileName": "onvif-camera",
                "description": "My test camera",
                "adminState": "UNLOCKED",
                "operatingState": "UNKNOWN",
                "protocols": {
                    "Onvif": {
                        "Address": "192.168.12.148",
                        "Port": "80",
                        "AuthMode": "digest",
                        "SecretName": "bosch"
                    }
                }
            }
          }
  ]'
```

Check the available commands from core-command service:
```shell
$ curl http://localhost:59882/api/v2/device/name/Camera003 | jq .
{
   "apiVersion" : "v2",
   "deviceCoreCommand" : {
      "coreCommands" : [
         {
            "get" : true,
            "set" : true,
            "name" : "DNS",
            "parameters" : [
               {
                  "resourceName" : "DNS",
                  "valueType" : "Object"
               }
            ],
            "path" : "/api/v2/device/name/Camera003/DNS",
            "url" : "http://edgex-core-command:59882"
         },
         ...
         {
            "get" : true,
            "name" : "StreamUri",
            "parameters" : [
               {
                  "resourceName" : "StreamUri",
                  "valueType" : "Object"
               }
            ],
            "path" : "/api/v2/device/name/Camera003/StreamUri",
            "url" : "http://edgex-core-command:59882"
         }
      ],
      "deviceName" : "Camera003",
      "profileName" : "onvif-camera"
   },
   "statusCode" : 200
}
```

## 7. Execute a Get Command
```shell
$ curl http://0.0.0.0:59882/api/v2/device/name/Camera003/Users | jq .
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "Camera003",
      "id" : "c0826f49-2840-421b-9474-7ad63a443302",
      "origin" : 1639525215434025100,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "d4dc823a-d75f-4fe1-8ee4-4220cc53ddc6",
            "objectValue" : {
               "User" : [
                  {
                     "UserLevel" : "Operator",
                     "Username" : "user"
                  },
                  {
                     "UserLevel" : "Administrator",
                     "Username" : "service"
                  },
                  {
                     "UserLevel" : "Administrator",
                     "Username" : "administrator"
                  }
               ]
            },
            "origin" : 1639525215434025100,
            "profileName" : "onvif-camera",
            "resourceName" : "Users",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "Users"
   },
   "statusCode" : 200
}
```
