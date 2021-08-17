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

1. Publish random number data every 15 seconds.
    The simulator publishes the data to the MQTT broker with topic `DataTopic` and the message is similar to the following:

    ```
    {"name":"MQTT-test-device", "cmd":"randfloat32", "method":"get", "randfloat32":4161.3549}
    ```
2. Receive the reading request, then return the response.

    1. The simulator receives the request from the MQTT broker, the topic is `CommandTopic` and the message is similar to the following:
        ```
        {"cmd":"randfloat32", "method":"get", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f"}
        ```
    2. The simulator returns the response to the MQTT broker, the topic is `ResponseTopic` and the message is similar to the following:
        ```
        {"cmd":"randfloat32", "method":"get", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f", "randfloat32":42.0}
        ```
3. Receive the set request, then change the device value.

    1. The simulator receives the request from the MQTT broker, the topic is `CommandTopic` and the message is similar to the following:
        ```   
        {"cmd":"message", "method":"set", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f", "message":"test message..."}
        ```
    2. The simulator changes the device value and returns the response to the MQTT broker, the topic is `ResponseTopic` and the message is similar to the following:
         ```   
         {"cmd":"message", "method":"set", "uuid":"293d7a00-66e1-4374-ace0-07520103c95f"}
         ```
          To simulate the MQTT device, create a javascript, named `mock-device.js`, with the
          following content:
```javascript
function getRandomFloat(min, max) {
    return Math.random() * (max - min) + min;
}

const deviceName = "MQTT-test-device";
let message = "test-message";

// DataSender sends async value to MQTT broker every 15 seconds
schedule('*/15 * * * * *', ()=>{
    let body = {
        "name": deviceName,
        "cmd": "randfloat32",
        "randfloat32": getRandomFloat(25,29).toFixed(1)
    };
    publish( 'DataTopic', JSON.stringify(body));
});

// CommandHandler receives commands and sends response to MQTT broker
// 1. Receive the reading request, then return the response
// 2. Receive the set request, then change the device value
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
            case "randfloat32":
                data.randfloat32 = 12.32;
                break;
            case "randfloat64":
                data.randfloat64 = 12.64;
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
- |- devices
     |- mqtt.test.device.toml
  |- profiles
     |- mqtt.test.device.profile.yml
```

### Device Profile

The DeviceProfile defines the device's values and operation method,
which can be Read or Write.

Create a device profile, named `mqtt.test.device.profile.yml`, with the
following content:
```yaml
name: "Test-Device-MQTT-Profile"
manufacturer: "Dell"
model: "MQTT-2"
labels:
  - "test"
description: "Test device profile"
deviceResources:
  -
    name: randfloat32
    isHidden: true
    description: "random 32 bit float"
    properties:
      valueType: "Float32"
      readWrite: "RW"
      defaultValue: "0.00"
      minimum: "0.00"
      maximum: "100.00"
  -
    name: randfloat64
    isHidden: true
    description: "random 64 bit float"
    properties:
      valueType: "Float64"
      readWrite: "RW"
      defaultValue: "0.00"
      minimum: "0.00"
      maximum: "100.00"
  -
    name: ping
    isHidden: true
    description: "device awake"
    properties:
      valueType: "String"
      readWrite: "R"
      defaultValue: "oops"
  -
    name: message
    isHidden: true
    description: "device notification message"
    properties:
      valueType: "String"
      readWrite: "RW"
      scale: ""
      offset: ""
      base: ""

deviceCommands:
  -
    name: testrandfloat32
    readWrite: "R"
    isHidden: false
    resourceOperations:
      - { deviceResource: "randfloat32" }
  -
    name: testrandfloat64
    readWrite: "R"
    isHidden: false
    resourceOperations:
      - { deviceResource: "randfloat64" }
  -
    name: testping
    readWrite: "R"
    isHidden: false
    resourceOperations:
      - { deviceResource: "ping" }
  -
    name: testmessage
    readWrite: "RW"
    isHidden: false
    resourceOperations:
      - { deviceResource: "message" }
  -
    name: randfloat32andfloat64
    readWrite: "RW"
    isHidden: false
    resourceOperations:
      - { deviceResource: "randfloat32" }
      - { deviceResource: "randfloat64" }

```

### Device Configuration

Use this configuration file to define devices and schedule jobs.
device-mqtt generates a relative instance on start-up.

Create the device configuration file, named `mqtt.test.device.toml`, as shown below:

```toml
# Pre-define Devices
[[DeviceList]]
  Name = 'MQTT-test-device'
  ProfileName = 'Test-Device-MQTT-Profile'
  Description = 'MQTT device is created for test purpose'
  Labels = [ 'MQTT', 'test' ]
  [DeviceList.Protocols]
    [DeviceList.Protocols.mqtt]
       CommandTopic = 'CommandTopic'
#  [[DeviceList.AutoEvents]]
#    Interval = '20s'
#    OnChange = false
#    SourceName = 'testrandfloat32'
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

```yaml
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

```json
$ curl http://localhost:59882/api/v2/device/all | json_pp

{
   "apiVersion" : "v2",
   "deviceCoreCommands" : [
      {
         "profileName" : "Test-Device-MQTT-Profile",
         "deviceName" : "MQTT-test-device",
         "coreCommands" : [
            {
               "get" : true,
               "name" : "testping",
               "parameters" : [
                  {
                     "resourceName" : "ping",
                     "valueType" : "String"
                  }
               ],
               "url" : "http://edgex-core-command:59882",
               "path" : "/api/v2/device/name/MQTT-test-device/testping"
            },
            {
               "name" : "testmessage",
               "get" : true,
               "set" : true,
               "path" : "/api/v2/device/name/MQTT-test-device/testmessage",
               "parameters" : [
                  {
                     "resourceName" : "message",
                     "valueType" : "String"
                  }
               ],
               "url" : "http://edgex-core-command:59882"
            },
            {
               "parameters" : [
                  {
                     "valueType" : "Float32",
                     "resourceName" : "randfloat32"
                  }
               ],
               "url" : "http://edgex-core-command:59882",
               "path" : "/api/v2/device/name/MQTT-test-device/testrandfloat32",
               "get" : true,
               "name" : "testrandfloat32"
            },
            {
               "url" : "http://edgex-core-command:59882",
               "parameters" : [
                  {
                     "resourceName" : "randfloat64",
                     "valueType" : "Float64"
                  }
               ],
               "path" : "/api/v2/device/name/MQTT-test-device/testrandfloat64",
               "get" : true,
               "name" : "testrandfloat64"
            }
         ]
      }
   ],
   "statusCode" : 200
}
```

### Execute SET Command

Execute a SET command according to the url and parameterNames, replacing
\[host\] with the server IP when running the SET command.

```
$ curl http://localhost:59882/api/v2/device/name/MQTT-test-device/message \
    -H "Content-Type:application/json" -X PUT  \
    -d '{"message":"Hello!"}'
```

### Execute GET Command

Execute a GET command as follows:

```json
$ curl http://localhost:59882/api/v2/device/name/MQTT-test-device/message | json_pp

{
   "event" : {
      "origin" : 1629328938544996200,
      "apiVersion" : "v2",
      "deviceName" : "MQTT-test-device",
      "readings" : [
         {
            "origin" : 1629328938544991900,
            "valueType" : "String",
            "resourceName" : "message",
            "deviceName" : "MQTT-test-device",
            "value" : "Hello!",
            "id" : "49c1ec9a-146f-4b41-8b34-1b2e32505103",
            "profileName" : "Test-Device-MQTT-Profile"
         }
      ],
      "id" : "2d1a8b07-2ea9-47c1-a4b5-12e644fd0cb4",
      "profileName" : "Test-Device-MQTT-Profile",
      "sourceName" : "message"
   },
   "statusCode" : 200,
   "apiVersion" : "v2"
}
```

## Schedule Job

The schedule job is defined in the `[[DeviceList.AutoEvents]]` section of the device configuration file:

```toml
    [[DeviceList.AutoEvents]]
       Interval = "20s"
       OnChange = false
       SourceName = "message"
```

After the service starts, query core-data's reading API. The results
show that the service auto-executes the command every 30 secs, as shown
below:

```json
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
         "profileName" : "Test-Device-MQTT-Profile",
         "deviceName" : "MQTT-test-device",
         "valueType" : "String"
      },
      {
         "mediaType" : "",
         "binaryValue" : null,
         "resourceName" : "message",
         "value" : "test-message",
         "id" : "1da58cb7-2bf4-47f0-bbb8-9519797149a2",
         "deviceName" : "MQTT-test-device",
         "valueType" : "String",
         "profileName" : "Test-Device-MQTT-Profile",
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
-   method = get or set
-   cmd = device reading

The following results show that the mock device sent the reading every
15 secs:

```json
$ curl http://localhost:59880/api/v2/reading/resourceName/randfloat32 | json_pp

{
   "readings" : [
      {
         "origin" : 1629329115003569900,
         "id" : "c74243bd-1620-4472-a132-e53c6015d4b6",
         "profileName" : "Test-Device-MQTT-Profile",
         "value" : "2.830000e+01",
         "resourceName" : "randfloat32",
         "deviceName" : "MQTT-test-device",
         "valueType" : "Float32"
      },
      {
         "origin" : 1629329110514728800,
         "value" : "1.232000e+01",
         "id" : "e462449b-00c1-4720-8335-33d94387669d",
         "profileName" : "Test-Device-MQTT-Profile",
         "resourceName" : "randfloat32",
         "valueType" : "Float32",
         "deviceName" : "MQTT-test-device"
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
| MQTTBrokerInfo.CredentialsPath       | credentials   | Name of the path in secret provider to retrieve your secrets. Must be non-blank. |
| MQTTBrokerInfo.IncomingTopic         | DataTopic     | IncomingTopic is used to receive the async value |
| MQTTBrokerInfo.ResponseTopic        | ResponseTopic | ResponseTopic is used to receive the command response from the device |
| MQTTBrokerInfo.Writable.ResponseFetchInterval | 500  | ResponseFetchInterval specifies the retry interval(milliseconds) to fetch the command response from the MQTT broker |



The user can override these configurations by `environment variable` to meet their requirement, for example:

```yaml
# docker-compose.yml

 device-mqtt:
    ...
    environment:
      ...
      MQTTBROKERINFO_HOST: 172.17.0.1
```
