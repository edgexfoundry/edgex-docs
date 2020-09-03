# Random Integer Device Service

## Introduction
The Random Integer device service is a simple device service that works quickly and easily with EdgeX. It simulates a single device (`Random-Integer-Generator01`) that generates a collection of random integer numbers every 20 seconds by default.  It initializes with a pre-defined device profile, device, and auto events schedule.

## EdgeX APIs related to Random Integer Device Service

Once the Random Integer device service is started, the table below provides a list of various EdgeX APIs that can be explored to learn more about the device service, the device, its commands and see the data the simulated device generates.
  
|Core Service |API	URL	|Description|
| --- | --- | --- |
|Core Metadata	|http://[host]:48081/api/v1/deviceservice/name/device-random	|Device Service created|
|Core Metadata	|http://[host]:48081/api/v1/deviceprofile/name/Random-Integer-Generator	|Device profile created|
|Core Metadata	|http://[host]:48081/api/v1/device/name/Random-Integer-Generator01	|Device created|
|Core Data  	|http://[host]:48080/api/v1/event |Events created by the random integer generator device|
|Core Command	|http://[host]:48082/api/v1/device/name/Random-Integer-Generator01 |Commands for the random integer generator device|

## Running Commands

Use the examples below to exercise the Random Integer device service's command set against the simulated device - the `Random-Integer-Generator01` device.

### Find the `GET` and `PUT` Commands
The Random Integer device service is configured to send simulated data to core data every few seconds (20 seconds by default) - see the [configuration file](https://github.com/edgexfoundry/device-random/blob/master/cmd/res/configuration.toml for default details.  It will send three different deviceResources of data - Int8, Int16 and Int32.  You can excersice the `GET` and `PUT` requests on the command service to trigger the Random-Integer-Generator01 device to generate values for any one of the deviceResources or to set the min/max random number generated for any of the deviceResources.  

First, use the curl command below to exercise the command service API to get a list of commands (both `GET` and `PUT`) for the Random-Integer-Generator01 device.

``` bash
curl -X GET localhost:48082/api/v1/device/name/Random-Integer-Generator01 | json_pp
```

!!! Warning
    The example above assumes your core command service is available on `localhost` at the default service port of 48082.  
  
The result should look something like that displayed below.

``` json
{
   "name" : "Random-Integer-Generator01",
   "labels" : [
      "device-random-example"
   ],
   "adminState" : "UNLOCKED",
   "id" : "ec7a7586-875e-4bb4-aa46-836d9e04514b",
   "operatingState" : "ENABLED",
   "commands" : [
      {
         "id" : "7dc0478d-29dd-4f6e-945d-85e4ad848bb1",
         "put" : {
            "responses" : [
               {
                  "code" : "200"
               },
               {
                  "code" : "503",
                  "description" : "service unavailable"
               }
            ],
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/7dc0478d-29dd-4f6e-945d-85e4ad848bb1",
            "parameterNames" : [
               "Min_Int32",
               "Max_Int32"
            ],
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int32"
         },
         "created" : 1596666924062,
         "get" : {
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/7dc0478d-29dd-4f6e-945d-85e4ad848bb1",
            "responses" : [
               {
                  "expectedValues" : [
                     "RandomValue_Int32"
                  ],
                  "code" : "200"
               },
               {
                  "code" : "503",
                  "description" : "service unavailable"
               }
            ],
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int32"
         },
         "modified" : 1596666924062,
         "name" : "GenerateRandomValue_Int32"
      },
      {
         "put" : {
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int8",
            "parameterNames" : [
               "Min_Int8",
               "Max_Int8"
            ],
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/ab8e16f9-2e94-4c10-b600-858ea1087cdf",
            "responses" : [
               {
                  "code" : "200"
               },
               {
                  "description" : "service unavailable",
                  "code" : "503"
               }
            ]
         },
         "created" : 1596666924062,
         "get" : {
            "responses" : [
               {
                  "expectedValues" : [
                     "RandomValue_Int8"
                  ],
                  "code" : "200"
               },
               {
                  "description" : "service unavailable",
                  "code" : "503"
               }
            ],
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/ab8e16f9-2e94-4c10-b600-858ea1087cdf",
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int8"
         },
         "id" : "ab8e16f9-2e94-4c10-b600-858ea1087cdf",
         "modified" : 1596666924062,
         "name" : "GenerateRandomValue_Int8"
      },
      {
         "name" : "GenerateRandomValue_Int16",
         "id" : "cfa21103-8ec9-44a0-9c55-25f9cc653dc0",
         "get" : {
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/cfa21103-8ec9-44a0-9c55-25f9cc653dc0",
            "responses" : [
               {
                  "expectedValues" : [
                     "RandomValue_Int16"
                  ],
                  "code" : "200"
               },
               {
                  "description" : "service unavailable",
                  "code" : "503"
               }
            ],
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int16"
         },
         "put" : {
            "responses" : [
               {
                  "code" : "200"
               },
               {
                  "description" : "service unavailable",
                  "code" : "503"
               }
            ],
            "url" : "http://edgex-core-command:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/cfa21103-8ec9-44a0-9c55-25f9cc653dc0",
            "parameterNames" : [
               "Min_Int16",
               "Max_Int16"
            ],
            "path" : "/api/v1/device/{deviceId}/GenerateRandomValue_Int16"
         },
         "created" : 1596666924062,
         "modified" : 1596666924062
      }
   ]
}
```

!!! Note
    The identifiers and URLs will look different in your result as the unique identifiers for devices, commands, etc. will be different in each EdgeX instance.

### GET Command Example

Locate the `GET` URL for one of the deviceResources in your JSON produced by the curl command above.  Use another curl command to trigger a `GET` command against that URL for the Random-Integer-Generator01 device.  In the example below, a `GET` is called for the GenerateRandomValue\_Int16 deviceResource.

``` bash
curl -X GET localhost:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/cfa21103-8ec9-44a0-9c55-25f9cc653dc0 | json_pp
```

!!! Note
    Importantly, notice that the host name provided in the JSON is always `edgex-core-command`.  This is the host name of the command service when running in Docker.  Use `localhost` in your curl commands to exercise the APIs.  You are not running your curl command inside of Docker.

The curl command will fire a request to the core command service which will relay the request to the Random-Integer-Generator device and return results of the `GET` request.  The results should look similar to the JSON below (except that the random number generated will return a differnt value).  The random number is the 'value' property of the reading - `-14351` in this example. 

``` json
{
   "device" : "Random-Integer-Generator01",
   "EncodedEvent" : null,
   "origin" : 1596669607120457092,
   "readings" : [
      {
         "valueType" : "Int16",
         "origin" : 1596669607120421119,
         "value" : "-14351",
         "device" : "Random-Integer-Generator01",
         "name" : "RandomValue_Int16"
      }
   ]
}

```

### PUT Command Example

`PUT` commands can adjust the minimum and maximum values for future random readings, but they must be valid values for the data type. For example, the minimum value for GenerateRandomValue\_Int16 cannot be more than 32767 and less than -32768.  Below, the PUT command limits the future reading value of GenerateRandomValue\_Int16 to a range of -2 to 2:


``` bash
curl -X PUT -d '{"Min_Int16": "-2", "Max_Int16": "2"}' localhost:48082/api/v1/device/ec7a7586-875e-4bb4-aa46-836d9e04514b/command/cfa21103-8ec9-44a0-9c55-25f9cc653dc0
```

!!! Info
    Nothing will be returned by the `PUT` curl call above unless you have and error. 

After running the command above, if you rerun the `GET` request for the same deviceResource (`GenerateRandomValue\_Int16`) you should only get values between -2 and 2.

``` json
{
   "readings" : [
      {
         "device" : "Random-Integer-Generator01",
         "origin" : 1596670608709647108,
         "value" : "0",
         "name" : "RandomValue_Int16",
         "valueType" : "Int16"
      }
   ],
   "origin" : 1596670608709698016,
   "EncodedEvent" : null,
   "device" : "Random-Integer-Generator01"
}
```
