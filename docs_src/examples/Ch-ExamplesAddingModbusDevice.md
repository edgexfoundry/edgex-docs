# Modbus

EdgeX - Delhi Release

PowerScout 3037 Power Submeter

<https://shop.dentinstruments.com/products/powerscout-3037-ps3037>
<https://www.dentinstruments.com/hs-fs/hub/472997/file-2378482732-pdf/Pdf_Files/PS3037_Manual.pdf>

![PowerScout 3037 Power Submeter](powerscout.png)

In this example, we simulate the PowerScout meter instead of using a
real device. This provides a straight-forward way to test the
device-modbus features.

![Modbus Simulator](simulator.png)

## Environment

You can use any operating system that can install docker and
docker-compose. In this example, we use Photon OS to delpoy EdgeX using
docker. The system requirements can be found at
<https://docs.edgexfoundry.org/Ch-GettingStartedUsers.html#what-you-need>.

![Photon Operating System](PhotonOS.png)

![Version Information](PhotonOSversion.png)

## Modbus Device (Simulator)

<http://modbuspal.sourceforge.net/>

To simulate sensors, such as temperature and humidity, do the following:

1.  Add two mock devices:

![Add Mock Devices](addmockdevices.png)

2.  Add registers according to the device manual:

![Add Registers](addregisters.png)

3.  Add the ModbusPal support value auto-generator, which can bind to
    registers:

![Add Device Value Generators](addvaluegen.png)

![Bind Value Generator](bindvalue.png)

## Set Up Before Starting Services

The following sections describe how to complete the set up before
starting the services. If you prefer to start the services and then add
the device, see [Set Up After Starting
Services](#set-up-after-starting-services)

### Set Up Device Profile

The DeviceProfile defines the device's values and operation method,
which can be Read or Write.

In the Modbus protocol, we must define attributes:

-   `primaryTable`: HOLDING\_REGISTERS, INPUT\_REGISTERS, COILS,
    DISCRETES\_INPUT

-   `startingAddress` specifies the address in Modbus device

![DeviceProfile Attributes](attributes.png)

The Property value type decides how many registers will be read. Like
Holding registers, a register has 16 bits. If the device manual
specifies that a value has two registers, define it as FLOAT32 or INT32
or UINT32 in the deviceProfile.

Once we execute a command, device-modbus knows its value type and
register type, startingAddress, and register length. So it can read or
write value using the modbus protocol.

![Properties](properties.png)


![Holding Registers](holdingregisters.png)


Create the device profile, as shown below:
```
name: "Network Power Meter"
manufacturer: "Dent Instruments"
model: "PS3037"
description: "Power Scout Meter"
labels:
  - "modbus"
  - "powerscout"
deviceResources:
  -
    name: "Current"
    description: "Average current of all phases"
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "9" }
    properties:
      value:
        { type: "UINT16", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "min"}
  -
    name: "Energy"
    description: "System Total True Energy"
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "4001" }
    properties:
      value:
        { type: "FLOAT32", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "min"}
  -
    name: "Power"
    description: "System Total True Power "
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "4003" }
    properties:
      value:
        { type: "UINT16", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "min"}
  -
    name: "Voltage"
    description: "Voltage Line to line (Volts) Average"
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "4017" }
    properties:
      value:
        { type: "UINT16", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "min"}
  -
    name: "DemandWindowSize"
    description: "Demand window size in minutes; default is 15 min"
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "4603" }
    properties:
      value:
        { type: "UINT16", readWrite: "R", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "min"}
  -
    name: "LineFrequency"
    description: "Line frequency setting for metering: 50=50 Hz, 60=60Hz"
    attributes:
      { primaryTable: "HOLDING_REGISTERS", startingAddress: "4609" }
    properties:
      value:
        { type: "UINT16", readWrite: "R", scale: "1"}
      units:
        { type: "String", readWrite: "R", defaultValue: "Hz"}
deviceCommands:
  -
    name: "Current"
    get:
      - { index: "1", operation: "get", deviceResource: "Current" }
  -
    name: "Values"
    get:
      - { index: "1", operation: "get", deviceResource: "Energy" }
      - { index: "2", operation: "get", deviceResource: "Power" }
      - { index: "3", operation: "get", deviceResource: "Voltage" }
  -
    name: "Configuration"
    set:
      - { index: "1", operation: "set", deviceResource: "DemandWindowSize" }
      - { index: "2", operation: "set", deviceResource: "LineFrequency" }
    get:
      - { index: "1", operation: "get", deviceResource: "DemandWindowSize" }
      - { index: "2", operation: "get", deviceResource: "LineFrequency" }
coreCommands:
  -
    name: "Current"
    get:
      path: "/api/v1/device/{deviceId}/Current"
      responses:
        -
          code: "200"
          description: "Get the Current"
          expectedValues: ["Current"]
        -
          code: "500"
          description: "internal server error"
          expectedValues: []
  -
    name: "Values"
    get:
      path: "/api/v1/device/{deviceId}/Values"
      responses:
        -
          code: "200"
          description: "Get the Values"
          expectedValues: ["Energy","Power","Voltage"]
        -
          code: "500"
          description: "internal server error"
          expectedValues: []
  -
    name: "Configuration"
    get:
      path: "/api/v1/device/{deviceId}/Configuration"
      responses:
        -
          code: "200"
          description: "Get the Configuration"
          expectedValues: ["DemandWindowSize","LineFrequency"]
        -
          code: "500"
          description: "internal server error"
          expectedValues: []
    put:
      path: "/api/v1/device/{deviceId}/Configuration"
      parameterNames: ["DemandWindowSize","LineFrequency"]
      responses:
        -
          code: "204"
          description: "Set the Configuration"
          expectedValues: []
        -
          code: "500"
          description: "internal server error"
          expectedValues: []
```

### Set Up Device Service Configuration

Use this configuration file to define devices and AutoEvent. The
device-modbus generates a relative instance on startup.

device-modbus offers two types of protocol, Modbus TCP and Modbus RTU, which can be defined as shown below:

  
  |protocol        | Name            | Protocol   | Address      | Port    | UnitID | BaudRate | DataBits | StopBits | Parity |
  |--------------- | --------------- | ---------- | -------------|---------| ------- | ------- |--------- | -------- | ------ |
  |Modbus TCP      | Gateway address | TCP        | 10.211.55.6  | 502     | 1      |          |          |          |        |
  |Modbus RTU      | Gateway address | RTU        | /tmp/slave   | 502     | 2      | 19200    | 8        | 1        | N      |
  

In the RTU protocol, Parity can be:
* N - None is 0
* O - Odd is 1 
* E - Even is 2, default is E

Create the configuration.toml file, as shown below:
```
[Writable]
LogLevel = 'DEBUG'

[Service]
BootTimeout = 30000
CheckInterval = '10s'
Host = 'localhost'
ServerBindAddr = ''  # blank value defaults to Service.Host value
Port = 49991
Protocol = 'http'
StartupMsg = 'device modbus started'
Timeout = 5000
ConnectRetries = 10
Labels = []
EnableAsyncReadings = true
AsyncBufferSize = 16

[Registry]
Host = 'localhost'
Port = 8500
Type = 'consul'

[Logging]
EnableRemote = false
File = ''

[Clients]
  [Clients.Data]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48080

  [Clients.Metadata]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48081

  [Clients.Logging]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48061

[Device]
  DataTransform = true
  InitCmd = ''
  InitCmdArgs = ''
  MaxCmdOps = 128
  MaxCmdValueLen = 256
  RemoveCmd = ''
  RemoveCmdArgs = ''
  ProfilesDir = './res/example'
  UpdateLastConnected = false

# Pre-define Devices
[[DeviceList]]
  Name = 'Modbus TCP test device'
  Profile = 'Test.Device.Modbus.Profile'
  Description = 'This device is a product for monitoring and controlling digital inputs and outputs over a LAN.'
  labels = [ 'Air conditioner','modbus TCP' ]
  [DeviceList.Protocols]
    [DeviceList.Protocols.modbus-tcp]
       Address = '0.0.0.0'
       Port = '1502'
       UnitID = '1'
  [[DeviceList.AutoEvents]]
    Frequency = '20s'
    OnChange = false
    Resource = 'Configuration'
  [[DeviceList.AutoEvents]]
    Frequency = '20s'
    OnChange = true
    Resource = 'Values'

[[DeviceList]]
  Name = 'Modbus RTU test device'
  Profile = 'Test.Device.Modbus.Profile'
  Description = 'This device is a product for monitoring and controlling digital inputs and outputs over a LAN.'
  labels = [ 'Air conditioner','modbus RTU' ]
  [DeviceList.Protocols]
    [DeviceList.Protocols.modbus-rtu]
       Address = '/tmp/slave'
       BaudRate = '19200'
       DataBits = '8'
       StopBits = '1'
       Parity = 'N'
       UnitID = '1'
```


### Add Device Service to docker-compose File

Because we deploy EdgeX using docker-compose, we must add the
device-modbus to the docker-compose file (
<https://github.com/edgexfoundry/edgex-compose/blob/geneva/docker-compose-geneva-redis.yml>
). If you have prepared configuration files, you can mount them using
volumes and change the entrypoint for device-modbus internal use.

![configuration.toml Updates](config_changes.png)

!!! Note
    This example uses the Geneva Release.  There are later EdgeX releases.

## Start EdgeX Foundry on Docker

Finally, we can deploy EdgeX in the Photon OS.

1.  Prepare configuration files by moving the files to the Photon OS

2.  Deploy EdgeX using the following commands:

        docker-compose pull
        docker-compose up -d

![Start EdgeX](startEdgeX.png)

3.  Check the consul dashboard

![Consul Dashboard](consul.png)

## Set Up After Starting Services

If the services are already running and you want to add a device, you
can use the Core Metadata API as outlined in this section. If you set up
the device profile and Service as described in [Set Up Before Starting
Services](#set-up-before-starting-services), you can skip this section.

To add a device after starting the services, complete the following
steps:

1. Upload the device profile above to metadata with a POST to
    <http://localhost:48081/api/v1/deviceprofile/uploadfile> and add the
    file as key "file" to the body in form-data format, and the created
    ID will be returned. The following example command uses curl to send the request:

    ```
    $ curl http://your-edgex-server-ip:48081/api/v1/deviceprofile/uploadfile \
      -F "file=@DENT.Mod.PS6037.profile.yaml"
    ```

2. Ensure the Modbus device service is running, adjust the service name
    below to match if necessary or if using other device services.

4.  Add the device with a POST to
    <http://localhost:48081/api/v1/device>, the body will look something
    like:
    ```
    $ curl http://your-edgex-server-ip:48081/api/v1/device -H "Content-Type:application/json" -X POST \
      -d '{ 
       "name" :"Modbus-TCP-Device-2",
       "description":"Power Submeter device.",
       "adminState":"UNLOCKED",
       "operatingState":"ENABLED",
       "protocols":{
          "modbus-tcp":{
             "Address" : "your-device-ip",
             "Port" : "1502",
             "UnitID" : "2"
          }
       },
       "labels":[ 
          "power submeter",
          "modbus TCP"
       ],
       "service":{"name":"edgex-device-modbus"},
       "profile":{"name":"Network Power Meter"},
       "autoEvents":[ 
          { 
             "frequency":"50s",
             "onChange":false,
             "resource":"Configuration"
          },
          { 
             "frequency":"5s",
             "onChange":true,
             "resource":"Values"
          }
       ]
    }'
    ```

    The service name must match/refer to the target device
    service, and the profile name must match the device profile name
    from Step 1.

## Execute Commands

Now we're ready to run some commands.

### Find Executable Commands

Use the following query to find executable commands:
```
$ curl http://your-edgex-server-ip:48082/api/v1/device | json_pp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1718  100  1718    0     0  14081      0 --:--:-- --:--:-- --:--:-- 14081
[
   {
      "id" : "56dcf3ad-52d8-4d12-a2d0-ae53c177ae3d",
      "commands" : [
         {
            "put" : {
               "url" : "http://edgex-core-command:48082/api/v1/device/56dcf3ad-52d8-4d12-a2d0-ae53c177ae3d/command/67b35f63-8f94-427b-a60c-188bf9e0633a",
               "parameterNames" : [
                  "DemandWindowSize",
                  "LineFrequency"
               ],
               "path" : "/api/v1/device/{deviceId}/Configuration"
            },
            "id" : "67b35f63-8f94-427b-a60c-188bf9e0633a",
            "get" : {
               "url" : "http://edgex-core-command:48082/api/v1/device/56dcf3ad-52d8-4d12-a2d0-ae53c177ae3d/command/67b35f63-8f94-427b-a60c-188bf9e0633a",
               "responses" : [
                  {
                     "description" : "service unavailable",
                     "code" : "503"
                  }
               ],
               "path" : "/api/v1/device/{deviceId}/Configuration"
            },
            ...
            "name" : "Configuration"
         }
      ],
      ...
   },
   {
      ....
   }
]
```

### Execute PUT command

Execute PUT command according to `url` and `parameterNames`, replacing [host] with the server IP when running the edgex-core-command. This can be done in either of the following ways:

```
$ curl http://your-edgex-server-ip:48082/api/v1/device/56dcf3ad-52d8-4d12-a2d0-ae53c177ae3d/command/67b35f63-8f94-427b-a60c-188bf9e0633a \
    -H "Content-Type:application/json" -X PUT  \
    -d '{"DemandWindowSize":"1122","LineFrequency":"1012"}'
```

Aside from using device id and command id in the URL, use the following API with device name and command is another approach.
Refer to [Core Command API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-command/1.2.1#/default/put_v1_device_name__name__command__commandname_) for more details.
```
$ curl "http://your-edgex-server-ip:48082/api/v1/device/name/Modbus-TCP-Device/command/Configuration" \
    -H "Content-Type:application/json" -X PUT  \
    -d '{"DemandWindowSize":"1122","LineFrequency":"1012"}'
```

Check the result from Modbus simulator:
![PUT ModbusPal](putModbusPal.png)

### Execute GET command

Replace *\<host\>* with the server IP when running the
edgex-core-command.

```
$ curl "http://your-edgex-server-ip:48082/api/v1/device/name/Modbus-TCP-Device/command/Configuration" | json_pp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   320  100   320    0     0  12800      0 --:--:-- --:--:-- --:--:-- 12307
{
   "device" : "Modbus-TCP-Device",
   "EncodedEvent" : null,
   "readings" : [
      {
         "device" : "Modbus-TCP-Device",
         "origin" : 1574314180435573491,
         "name" : "DemandWindowSize",
         "value" : "1122"
      },
      {
         "origin" : 1574314180435578175,
         "device" : "Modbus-TCP-Device",
         "value" : "1012",
         "name" : "LineFrequency"
      }
   ],
   "origin" : 1574314180435629113
}
```

## AutoEvent
The AutoEvent is defined in the [[DeviceList.AutoEvents]] section of the TOML configuration file:
```
# Pre-define Devices
[[DeviceList]]
  Name = 'Modbus TCP test device'
  Profile = 'Test.Device.Modbus.Profile'
  Description = 'This device is a product for monitoring and controlling digital inputs and outputs over a LAN.'
  labels = [ 'Air conditioner','modbus TCP' ]
  [DeviceList.Protocols]
    [DeviceList.Protocols.modbus-tcp]
       Address = '0.0.0.0'
       Port = '1502'
       UnitID = '1'
  [[DeviceList.AutoEvents]]
    Frequency = '20s'
    OnChange = false
    Resource = 'HVACValues'
```
After service startup, query core-data's reading API. The results show
that the service auto-executes the command every 20 seconds.

```
$ curl "http://your-edgex-server-ip:48080/api/v1/event/device/Modbus-TCP-Device/10" | json_pp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1997  100  1997    0     0   216k      0 --:--:-- --:--:-- --:--:--  216k
[
   {
      "origin" : 1574313452749054661,
      "id" : "a066d154-fe44-4572-9870-8790017b9c59",
      "created" : 1574313452750,
      "device" : "Modbus-TCP-Device",
      "readings" : [
         ...
      ]
   },
   {
      "device" : "Modbus-TCP-Device",
      "readings" : [
         ...
      ],
      "created" : 1574313457759,
      "id" : "25314175-d6f5-461e-8be4-94129fbf94c6",
      "origin" : 1574313457757445677
   },
   ...
]
```
