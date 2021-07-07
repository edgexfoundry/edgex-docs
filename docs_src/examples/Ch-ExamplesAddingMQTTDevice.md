# MQTT

EdgeX - Ireland Release

## Overview

In this example, we use the simulator instead of real device. This
provides a straight-forward way to test the device-mqtt features.

![MQTT Overview](MQTT_Example_Overview.png)

## Run an MQTT Broker

Eclipse Mosquitto is an open source (EPL/EDL licensed) message broker
that implements the MQTT protocol versions 5.0, 3.1.1 and 3.1.

Run Mosquitto using the following docker command:

    docker run -d --rm --name broker -p 1883:1883 eclipse-mosquitto:1.6

## Run an MQTT Device Simulator

![MQTT Device Service](EdgeX_ExamplesMQTTDeviceSimulator.png)

This simulator has three behaviors:

1.  Publish random number data every 15 seconds.
    
    The simulator publishes the data to the MQTT broker with topic `DataTopic` and the message is similar to the following:
    ```
    {"name":"MQTT-Test-Device", "cmd":"randnum", "method":"get", "randnum":4161.3549}
    ```
    
2.  Receive the reading request, then return the response.

    1. The simulator receives the request from the MQTT broker, the topic is `CommandTopic` and the message is similar to the following:
        ```   
        {"cmd":"randnum", "method":"get", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f"}
        ```
    2. The simulator returns the response to the MQTT broker, the topic is `ResponseTopic` and the message is similar to the following:
        ```   
        `{"cmd":"randnum", "method":"get", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f", "randnum":42.0}
        ```
3.  Receive the put request, then change the device value.

    1. The simulator receives the request from the MQTT broker, the topic is `CommandTopic` and the message is similar to the following:
        ```   
        {"cmd":"message", "method":"set", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f", "message":"test message..."}
        ```
    2. The simulator changes the device value and returns the response to the MQTT broker, the topic is `ResponseTopic` and the message is similar to the following:
        ```   
        `{"cmd":"message", "method":"set", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f"}

To simulate the MQTT device, create a javascript, named `mock-device.js`, with the
following content:
```
function getRandomFloat(min, max) {
    return Math.random() * (max - min) + min;
}

const deviceName = "MQTT-Test-Device";
let message = "test-message";

// DataSender sends async value to MQTT broker every 15 seconds
schedule('*/15 * * * * *', ()=>{
    let body = {
        "name": deviceName,
        "cmd": "randnum",
        "randnum": getRandomFloat(25,29).toFixed(1)
    };
    publish( 'DataTopic', JSON.stringify(body));
});

// CommandHandler receives commands and sends response to MQTT broker
// 1. Receive the reading request, then return the response
// 2. Receive the put request, then change the device value
subscribe( "CommandTopic" , (topic, val) => {
    var data = val;
        if (data.method == "set") {
        message = data[data.cmd]
    }else{
        switch(data.cmd) {
            case "ping":
              data.ping = "pong";
              break;
            case "message":
              data.message = message;
              break;
            case "randnum":
                data.randnum = 12.123;
                break;
          }
    }
    publish( "ResponseTopic", JSON.stringify(data));
});
```

To run the device simulator, enter the commands shown below with the
following changes:

- Replace the `/path/to/mqtt-scripts` in the example mv command with the
    correct path
```
$ mv mock-device.js /path/to/mqtt-scripts
$ docker run -d --restart=always --name=mqtt-scripts \
    -v /path/to/mqtt-scripts:/scripts  \
    dersimn/mqtt-scripts --url mqtt://172.17.0.1 --dir /scripts
```
> The address `172.17.0.1` is point to the host of MQTT broker via the docker bridge network.

## Prepare the Custom Configuration 

In this section, we create folders that contains files required for deployment:
```
- custom-config
  |- profiles
     |- mqtt.test.device.profile.yml
  |- devices
     |- mqtt.test.device.config.toml
```

### Device Profile

The DeviceProfile defines the device's values and operation method,
which can be Read or Write.

Create a device profile, named `mqtt.test.device.profile.yml`, with the
following content:
```
name: "MQTT-Test-Device-Profile"
manufacturer: "iot"
model: "MQTT-DEVICE"
description: "Test device profile"
labels:
  - "mqtt"
  - "test"
deviceResources:
  -
    name: randnum
    isHidden: true
    description: "device random number"
    properties:
      valueType: "Float32"
      readWrite: "R"
  -
    name: ping
    isHidden: true
    description: "device awake"
    properties:
      valueType: "String"
      readWrite: "R"
  -
    name: message
    isHidden: false
    description: "device message"
    properties:
      valueType: "String"
      readWrite: "RW"

deviceCommands:
  -
    name: values
    readWrite: "R"
    isHidden: false
    resourceOperations:
        - { deviceResource: "randnum" }
        - { deviceResource: "ping" }
        - { deviceResource: "message" }
```

### Device Service Configuration

Use this configuration file to define devices and schedule jobs.
device-mqtt generates a relative instance on start-up.

Create the device configuration file, named `mqtt.test.device.config.toml`, as shown below:

```
# Pre-define Devices
[[DeviceList]]
  Name = 'MQTT-Test-Device'
  ProfileName = 'MQTT-Test-Device-Profile'
  Description = 'MQTT device is created for test purpose'
  Labels = [ 'MQTT', 'test' ]
  [DeviceList.Protocols]
    [DeviceList.Protocols.mqtt]
       CommandTopic = 'CommandTopic'
    [[DeviceList.AutoEvents]]
       Interval = '30s'
       OnChange = false
       SourceName = 'message'
```

- `CommandTopic` is used to publish the GET or SET command request

## Prepare docker-compose file

1. Clone edgex-compose
```
$ git clone git@github.com:edgexfoundry/edgex-compose.git
$ git checkout ireland
```
2. Generate the docker-compose.yml file
```
$ cd edgex-compose/compose-builder
$ make gen ds-mqtt
```
Check the generated file
```
$ ls | grep 'docker-compose.yml'
docker-compose.yml
```

### Mount the custom-config

Open the `docker-compose.yml` file and then add volumes path and environment as shown below:

- Replace the `/path/to/custom-config` in the example with the correct path

```
 device-mqtt:
    ...
    environment:
      ...
      DEVICE_DEVICESDIR: /custom-config/devices
      DEVICE_PROFILESDIR: /custom-config/profiles
      MQTTBROKERINFO_HOST: 172.17.0.1
    volumes:
    ...
    - /path/to/custom-config:/custom-config
```

> The address `172.17.0.1` is point to the MQTT broker via the docker bridge network.

## Start EdgeX Foundry on Docker

Deploy EdgeX using the following commands:
```
$ cd edgex-compose/compose-builder
$ docker-compose pull
$ docker-compose up -d
```

## Execute Commands

Now we're ready to run some commands.

### Find Executable Commands

Use the following query to find executable commands:

```
$ curl http://localhost:59882/api/v2/device/all | json_pp

{
   "deviceCoreCommands" : [
      {
         "profileName" : "MQTT-Test-Device-Profile",
         "deviceName" : "MQTT-Test-Device",
         "coreCommands" : [
            {
               "url" : "http://edgex-core-command:59882",
               "parameters" : [
                  {
                     "resourceName" : "randnum",
                     "valueType" : "Float32"
                  },
                  {
                     "resourceName" : "ping",
                     "valueType" : "String"
                  },
                  {
                     "resourceName" : "message",
                     "valueType" : "String"
                  }
               ],
               "get" : true,
               "name" : "values",
               "path" : "/api/v2/device/name/MQTT-Test-Device/values"
            },
            {
               "url" : "http://edgex-core-command:59882",
               "parameters" : [
                  {
                     "valueType" : "String",
                     "resourceName" : "message"
                  }
               ],
               "get" : true,
               "set" : true,
               "path" : "/api/v2/device/name/MQTT-Test-Device/message",
               "name" : "message"
            }
         ]
      }
   ],
   "apiVersion" : "v2",
   "statusCode" : 200
}
```

### Execute SET Command

Execute a SET command according to the url and parameterNames, replacing
\[host\] with the server IP when running the SET command.

```
$ curl http://localhost:59882/api/v2/device/name/MQTT-Test-Device/message \
    -H "Content-Type:application/json" -X PUT  \
    -d '{"message":"Hello!"}'
```

### Execute GET Command

Execute a GET command as follows:

```
$ curl http://localhost:59882/api/v2/device/name/MQTT-Test-Device/message | json_pp

{
   "event" : {
      "origin" : 1624417689920618131,
      "readings" : [
         {
            "resourceName" : "message",
            "binaryValue" : null,
            "profileName" : "MQTT-Test-Device-Profile",
            "deviceName" : "MQTT-Test-Device",
            "id" : "a3bb78c5-e76f-49a2-ad9d-b220a86c3e36",
            "value" : "Hello!",
            "valueType" : "String",
            "origin" : 1624417689920615828,
            "mediaType" : ""
         }
      ],
      "sourceName" : "message",
      "deviceName" : "MQTT-Test-Device",
      "apiVersion" : "v2",
      "profileName" : "MQTT-Test-Device-Profile",
      "id" : "e0b29735-8b39-44d1-8f68-4d7252e14cc7"
   },
   "apiVersion" : "v2",
   "statusCode" : 200
}

```

## Schedule Job

The schedule job is defined in the `[[DeviceList.AutoEvents]]` section of the device configuration file:

```
    [[DeviceList.AutoEvents]]
       Interval = '30s'
       OnChange = false
       SourceName = 'message'
```

After the service starts, query core-data's reading API. The results
show that the service auto-executes the command every 30 secs, as shown
below:

```
$ curl http://localhost:59880/api/v2/reading/resourceName/message | json_pp

{
   "statusCode" : 200,
   "readings" : [
      {
         "value" : "test-message",
         "id" : "e91b8ca6-c5c4-4509-bb61-bd4b09fe835c",
         "mediaType" : "",
         "binaryValue" : null,
         "resourceName" : "message",
         "origin" : 1624418361324331392,
         "profileName" : "MQTT-Test-Device-Profile",
         "deviceName" : "MQTT-Test-Device",
         "valueType" : "String"
      },
      {
         "mediaType" : "",
         "binaryValue" : null,
         "resourceName" : "message",
         "value" : "test-message",
         "id" : "1da58cb7-2bf4-47f0-bbb8-9519797149a2",
         "deviceName" : "MQTT-Test-Device",
         "valueType" : "String",
         "profileName" : "MQTT-Test-Device-Profile",
         "origin" : 1624418330822988843
      },
      ...
   ],
   "apiVersion" : "v2"
}


```

## Async Device Reading

The `device-mqtt` subscribes to a `DataTopic`, which is wait for the [real device to send value to MQTT broker](#run-an-mqtt-device-simulator), then `device-mqtt`
parses the value and forward to the northbound.

The data format contains the following values:

-   name = device name
-   cmd = deviceResource name
-   method = get or put
-   cmd = device reading

The following results show that the mock device sent the reading every
15 secs:

```
$ curl http://localhost:59880/api/v2/reading/resourceName/randnum | json_pp

{
   "readings" : [
      {
         "origin" : 1624418475007110946,
         "valueType" : "Float32",
         "deviceName" : "MQTT-Test-Device",
         "id" : "9b3d337e-8a8a-4a6c-8018-b4908b57abb8",
         "binaryValue" : null,
         "resourceName" : "randnum",
         "profileName" : "MQTT-Test-Device-Profile",
         "mediaType" : "",
         "value" : "2.630000e+01"
      },
      {
         "deviceName" : "MQTT-Test-Device",
         "valueType" : "Float32",
         "id" : "06918cbb-ada0-4752-8877-0ef8488620f6",
         "origin" : 1624418460007833720,
         "mediaType" : "",
         "profileName" : "MQTT-Test-Device-Profile",
         "value" : "2.570000e+01",
         "resourceName" : "randnum",
         "binaryValue" : null
      },
      ...
   ],
   "statusCode" : 200,
   "apiVersion" : "v2"
}
```

## MQTT Device Service Configuration

MQTT Device Service has the following configurations to implement the MQTT protocol.

| Configuration                        | Default Value | Description                                                  |
| ------------------------------------ | ------------- | ------------------------------------------------------------ |
| MQTTBrokerInfo.Schema                | tcp           | The URL schema |
| MQTTBrokerInfo.Host                  | 0.0.0.0       | The URL host |
| MQTTBrokerInfo.Port                  | 1883          | The URL port |
| MQTTBrokerInfo.Qos                   | 0             | Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once) |
| MQTTBrokerInfo.KeepAlive             | 3600          | Seconds between client ping when no active data flowing to avoid client being disconnected. Must be greater then 2 |
| MQTTBrokerInfo.ClientId              | device-mqtt   | ClientId to connect to the broker with |
| MQTTBrokerInfo.CredentialsRetryTime  | 120           | The retry times to get the credential |
| MQTTBrokerInfo.CredentialsRetryWait  | 1             | The wait time(seconds) when retry to get the credential  |
| MQTTBrokerInfo.ConnEstablishingRetry | 10            | The retry times to establish the MQTT connection    | 
| MQTTBrokerInfo.ConnRetryWaitTime     | 5             | The wait time(seconds) when retry to establish the MQTT connection   |
| MQTTBrokerInfo.AuthMode              | none          | Indicates what to use when connecting to the broker. Must be one of "none" , "usernamepassword" |
| MQTTBrokerInfo.CredentialsPath       | credentials   | Name of the path in secret provider to retrieve your secrets. Must be non-blank. |\
| MQTTBrokerInfo.IncomingTopic         | DataTopic     | IncomingTopic is used to receive the async value |
| MQTTBrokerInfo.responseTopic         | ResponseTopic | ResponseTopic is used to receive the command response from the device |
| MQTTBrokerInfo.Writable.ResponseFetchInterval | 500  | ResponseFetchInterval specifies the retry interval(milliseconds) to fetch the command response from the MQTT broker |

The user can override these configurations by `environment variable` to meet their requirement, for example:

```
# docker-compose.yml

 device-mqtt:
    ...
    environment:
      ...
      MQTTBROKERINFO_HOST: 172.17.0.1
```
