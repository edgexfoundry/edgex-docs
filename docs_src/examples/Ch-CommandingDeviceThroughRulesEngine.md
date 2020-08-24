# Command Devices with Kuiper Rules Engine

## Overview

This document describes how to actuate a [device](../general/Definitions.md#device) with rules trigger by the Kuiper rules engine. To make the example simple, the virtual device [device-virtual](https://github.com/edgexfoundry/device-virtual-go) is used as the actuated device.  The Kuiper rules engine analyzes the data sent from device-virtual services, and then sends a command to virtual device based a rule firing in Kuiper based on that analysis.  It should be noted that an [application service](../microservices/application/ApplicationServices.md) is used to route core data through the rules engine.

### Use Case Scenarios

Rules will be created in Kuiper to watch for two circumstances:

1. monitor for events coming from the `Random-UnsignedInteger-Device` device (one of the default virtual device managed devices), and if a `uint8` reading value is found larger than `20` in the event, then send a command to `Random-Boolean-Device` device to start generating random numbers (specifically - set random generation bool to true).
2. monitor for events coming from the `Random-Integer-Device` device (another of the default virtual device managed devices), and if the average for `int8` reading values (within 20 seconds) is larger than 0, then send a command to `Random-Boolean-Device` device to stop generating random numbers (specifically - set random generation bool to false).

These use case scenarios do not have any real business meaning, but easily demonstrate the features of EdgeX automatic actuation accomplished via the Kuiper rule engine.

### Prerequisite Knowledge

This document will not cover basic operations of EdgeX or EMQ X Kuiper.  Readers should have basic knowledge of:

- Get and start EdgeX.  Refer to [Quick Start](../getting-started/quick-start/index.md) for how to get and start EdgeX with the virtual device service.
- Run the Kuiper Rules Engine.  Refer to [EdgeX Kuiper Rule Engine Tutorial](../microservices/support/Kuiper/Ch-Kuiper.md) to understand the basics of Kuiper and EdgeX. 

## Start Kuiper and Create an EdgeX Stream

Make sure you read the [EdgeX Kuiper Rule Engine Tutorial](https://github.com/emqx/kuiper/blob/master/docs/en_US/edgex/edgex_rule_engine_tutorial.md) and successfully run Kuiper with EdgeX. 

First create a stream that can consume streaming data from the EdgeX application service (rules engine profile). This step is not required if you already finished the [EdgeX Kuiper Rule Engine Tutorial](https://github.com/emqx/kuiper/blob/master/docs/en_US/edgex/edgex_rule_engine_tutorial.md). 

``` bash
curl -X POST \
  http://$kuiper_docker:48075/streams \
  -H 'Content-Type: application/json' \
  -d '{"sql": "create stream demo() WITH (FORMAT=\"JSON\", TYPE=\"edgex\")"}'
```

## Get and Test the Command URL

Since both use case scenario rules will send commands to the `Random-Boolean-Device` virtual device, use the curl request below to get a list of available commands for this device.

``` bash
curl http://localhost:48082/api/v1/device/name/Random-Boolean-Device | jq
```

It should print results like those below.

``` json
{
  "id": "9b051411-ca20-4556-bd3e-7f52475764ff",
  "name": "Random-Boolean-Device",
  "adminState": "UNLOCKED",
  "operatingState": "ENABLED",
  "labels": [
    "device-virtual-example"
  ],
  "commands": [
    {
      "created": 1589052044139,
      "modified": 1589052044139,
      "id": "28d88bb3-e280-46f7-949f-37cc411757f5",
      "name": "Bool",
      "get": {
        "path": "/api/v1/device/{deviceId}/Bool",
        "responses": [
          {
            "code": "200",
            "expectedValues": [
              "Bool"
            ]
          },
          {
            "code": "503",
            "description": "service unavailable"
          }
        ],
        "url": "http://edgex-core-command:48082/api/v1/device/bcd18c02-b187-4f29-8265-8312dc5d794d/command/d6d3007d-c4ce-472f-a117-820b5410e498"
      },
      "put": {
        "path": "/api/v1/device/{deviceId}/Bool",
        "responses": [
          {
            "code": "200"
          },
          {
            "code": "503",
            "description": "service unavailable"
          }
        ],
        "url": "http://edgex-core-command:48082/api/v1/device/bcd18c02-b187-4f29-8265-8312dc5d794d/command/d6d3007d-c4ce-472f-a117-820b5410e498",
        "parameterNames": [
          "Bool",
          "EnableRandomization_Bool"
        ]
      }
    }
  ]
}
```

From this output, look for the URL associated to the `PUT` command (the second URL listed).  This is the command Kuiper will used to call on the device. There are two parameters for this command:

- `Bool`: Set the returned value when other services want to get device data. The parameter will be used only when `EnableRandomization_Bool` is set to false.
- `EnableRandomization_Bool`: Enable/disable the randomization generation of bool values. If this value is set to true, then the 1st parameter will be ignored.

You can test calling this command with its parameters using curl as shown below.

``` bash
curl -X PUT \
  http://edgex-core-command:48082/api/v1/device/bcd18c02-b187-4f29-8265-8312dc5d794d/command/d6d3007d-c4ce-472f-a117-820b5410e498 \
  -H 'Content-Type: application/json' \
  -d '{"Bool":"true", "EnableRandomization_Bool": "true"}'
```

!!! Warning
    The URL used in this example will not be the same as the URL for you command service.  EdgeX provides a different UUID for each command.  The example above shows you what to look for and how to make the request, but the URL will be unique to your system.

## Create rules

Now that you have EdgeX and Kuiper running, the EdgeX stream defined, and you know the command to actuate `Random-Boolean-Device`, it is time to build the Kuiper rules.

### The first rule

Again, the 1st rule is to monitor for events coming from the `Random-UnsignedInteger-Device` device (one of the default virtual device managed devices), and if a `uint8` reading value is found larger than `20` in the event, then send the command to `Random-Boolean-Device` device to start generating random numbers (specifically - set random generation bool to true).  Given the URL and parameters to the command, below is the curl command to declare the first rule in Kuiper.

``` bash
curl -X POST \
  http://$kuiper_server:48075/rules \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "rule1",
  "sql": "SELECT uint8 FROM demo WHERE uint8 > 20",
  "actions": [
    {
      "rest": {
        "url": "http://edgex-core-command:48082/api/v1/device/bcd18c02-b187-4f29-8265-8312dc5d794d/command/d6d3007d-c4ce-472f-a117-820b5410e498",
        "method": "put",
        "dataTemplate": "{\"Bool\":\"true\", \"EnableRandomization_Bool\": \"true\"}",
        "sendSingle": true
      }
    },
    {
      "log":{}
    }
  ]
}'
```

### The second rule

The 2nd rule is to monitor for events coming from the `Random-Integer-Device` device (another of the default virtual device managed devices), and if the average for `int8` reading values (within 20 seconds) is larger than 0, then send a command to `Random-Boolean-Device` device to stop generating random numbers (specifically - set random generation bool to false).  Here is the curl request to setup the second rule in Kuiper.  The same command URL is used as the same device action (`Random-Boolean-Device's PUT bool command`) is being actuated, but with different parameters.

``` bash
curl -X POST \
  http://$kuiper_server:48075/rules \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "rule2",
  "sql": "SELECT avg(int8) AS avg_int8 FROM demo WHERE int8 != nil GROUP BY  TUMBLINGWINDOW(ss, 20) HAVING avg(int8) > 0",
  "actions": [
    {
      "rest": {
        "url": "http://edgex-core-command:48082/api/v1/device/bcd18c02-b187-4f29-8265-8312dc5d794d/command/d6d3007d-c4ce-472f-a117-820b5410e498",
        "method": "put",
        "dataTemplate": "{\"Bool\":\"false\", \"EnableRandomization_Bool\": \"false\"}",
        "sendSingle": true
      }
    },
    {
      "log":{}
    }
  ]
}'
```

## Watch the Kuiper Logs

Both rules are now created in Kuiper.  Kuiper is busy analyzing the event data coming for the virtual devices looking for readings that match the rules you created.  You can watch the edgex-kuiper container logs for the rule triggering and command execution.

``` bash
docker logs edgex-kuiper
```

## Explore the Results

You can also explore the Kuiper analysis that caused the commands to be sent to the service.  To see the the data from the analysis, use the SQL below to query Kuiper filtering data.

``` sql
SELECT int8, "true" AS randomization FROM demo WHERE uint8 > 20
```

The output of the SQL should look similar to the results below.

``` json
[{"int8":-75, "randomization":"true"}]
```

## Extended Reading

Use these resouces to learn more about the features of EMQ X Kuiper.

- [Kuiper Github code repository](https://github.com/emqx/kuiper/)
- [Kuiper reference guide](https://github.com/emqx/kuiper/blob/edgex/docs/en_US/reference.md)
