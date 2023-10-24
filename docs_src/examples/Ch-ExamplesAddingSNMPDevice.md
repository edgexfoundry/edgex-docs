# SNMP

EdgeX - Ireland Release

## Overview

In this example, you add a new Patlite Signal Tower which communicates via SNMP.  This example demonstrates how to connect a device through the SNMP Device Service.

![image](EdgeX_Examples_Patlite.jpg)

Patlite Signal Tower, model NHL-FB2

## Setup

### Hardware needed

In order to exercise this example, you will need the following hardware

- A computer able to run EdgeX Foundry
- [A Patlite Signal Tower](https://www.patlite.com/) (NHL-FB2 model)
- Both the computer and Patlite must be connected to the same ethernet network

### Software needed

In addition to the hardware, you will need the following software

- Docker
- Docker Compose
- EdgeX Foundry V2 (Ireland release)
- curl to run REST commands (you can also use a tool like Postman)

If you have not already done so, proceed to [Getting Started using Docker](../getting-started/Ch-GettingStartedDockerUsers.md) for how to get these tools and run EdgeX Foundry.

### Add the SNMP Device Service to your docker-compose.yml

The EdgeX docker-compose.yml file used to run EdgeX must include the SNMP device service for this example.

Use the [EdgeX Compose Builder tool](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) to create your own custom docker-compose.yml file adding device-snmp.

!!! example - "Example Compose Builder command"
    make gen no-secty ds-snmp

See [Getting Started using Docker](../getting-started/Ch-GettingStartedDockerUsers.md#run-edgex-foundry) if you need assistance running EdgeX once you have your Docker Compose file.

## Add the SNMP Device Profile and Device

SNMP devices, like the Patlite Signal Tower, provide a set of managed objects to get and set property information on the associated device.  Each managed object has an address call an object identifier (or OID) that you use to interact with the SNMP device's managed object.  You use the OID to query the state of the device or to set properties on the device.  In the case of the Patlite, there are managed object for the colored lights and the buzzer of the device.  You can read the current state of a colored light (get) or turn the light on (set) by making a call to the proper OIDs for the associated managed object.

For example, on the NH series signal towers used in this example, a "get" call to the `1.3.6.1.4.1.20440.4.1.5.1.2.1.4.1` OID returns the current state of the `Red` signal light.  A return value of 1 would signal the light is off.  A return value of 2 says the light is on.  A return value of 3 says the light is flashing.  Read this [SNMP tutorial](https://www.manageengine.com/network-monitoring/what-is-snmp.html) to learn more about the basics of the SNMP protocol.  See the [Patlite NH Series User's Manual](https://www.patlite.com/support/enddata/manual/T95100146_G_EN.pdf) for more information on the SNMP OIDs and function calls and parameters needed for some requests.

### Add the Patlite Device Profile

A device profile has been created for you to get and set the signal tower's three colored lights and to get and set the buzzer.  The [`patlite-snmp` device profile](patlite-snmp.yml) defines three [device resources](../general/Definitions.md#resource) for each of the lights and the buzzer.

- Current State, a read request device resource to get the current state of the requested light or buzzer
- Control State, a write request device resource to set the current state of the light or buzzer
- Timer, a write request device resource used in combination with the control state to set the state after the number of seconds provided by the timer resource

Note that the attributes of each device resource specify the SNMP OID that the device service will use to make a request of the signal tower.  For example, the device resource YAML below (taken from the profile) provides the means to get the current `Red` light state.  Note that a specific OID is provided that is unique to the `RED` light, current state property.

``` YAML
-
  name: "RedLightCurrentState"
  isHidden: false
  description: "red light current state"
  attributes:
    { oid: "1.3.6.1.4.1.20440.4.1.5.1.2.1.4.1", community: "private" }  
  properties:
    valueType:  "Int32"
    readWrite: "R"
    defaultValue: "1"
```

Below is the device resource definitions for the `Red` light control state and timer.  Again, unique OIDs are provided as attributes for each property.

``` YAML
-
  name: "RedLightControlState"
  isHidden: true
  description: "red light state"
  attributes:
    { oid: "1.3.6.1.4.1.20440.4.1.5.1.2.1.2.1", community: "private" }  
  properties:
    valueType:  "Int32"
    readWrite: "W"
    defaultValue: "1"
-
  name: "RedLightTimer"
  isHidden: true
  description: "red light timer"
  attributes:
    { oid: "1.3.6.1.4.1.20440.4.1.5.1.2.1.3.1", community: "private" }  
  properties:
    valueType:  "Int32"
    readWrite: "W"
    defaultValue: "1"
```

In order to set the `Red` light on, one would need to send an SNMP request to set OID `1.3.6.1.4.1.20440.4.1.5.1.2.1.2.1` to a value of 2 (on state) along with a number of seconds delay to the time at OID `1.3.6.1.4.1.20440.4.1.5.1.2.1.3.1`.  Sending a zero value (0) to the timer would say you want to turn the light on immediately.

Because setting a light or buzzer requires both of the control state and timer OIDs to be set together (simultaneously), the device profile contains `deviceCommands` to set the light and timer device resources (and therefore their SNMP property OIDs) in a single operation.  Here is the device command to set the `Red` light.

``` YAML
-
  name: "RedLight"
  readWrite: "W"
  isHidden: false
  resourceOperations:
  - { deviceResource: "RedLightControlState" }
  - { deviceResource: "RedLightTimer" }
```

You will need to upload this profile into core metadata.  Download the [Patlite device profile](patlite-snmp.yml) to a convenient directory.  Then, using the following `curl` command, request the profile be uploaded into core metadata.

``` Shell
curl -X 'POST' 'http://localhost:59881/api/{{api_version}}/deviceprofile/uploadfile' --form 'file=@"/home/yourfilelocationhere/patlite-snmp.yml"'
```

!!! Alert
    Note that the curl command above assumes that core metadata is available at `localhost`.  Change `localhost` to the host address of your core metadata service.  
    Also note that you will need to replace the `/home/yourfilelocationhere` path with the path where the profile resides.


### Add the Patlite Device

With the Patlite device profile now in metadata, you can add the Patlite device in metadata.  When adding the device, you typically need to provide the name, description, labels and admin/op states of the device when creating it.  You will also need to associate the device to a device service (in this case the `device-snmp` device service).  You will ned to associate the new device to a profile - the patlite profile just added in the step above.  And you will need to provide the protocol information (such as the address and port of the device) to tell the device service where it can find the physical device.  If you wish the device service to automatically get readings from the device, you will also need to provide [AutoEvent](../design/legacy-requirements/device-service.md#autoevents) properties when creating the device.

The curl command to POST the new Patlite device (named `patlite1`) into metadata is provide below.  You will need to change the protocol `Address` (currently `10.0.0.14`) and `Port` (currently `161`) to point to your Patlite on your network.  In this request to add a new device, AutoEvents are setup to collect the current state of the 3 lights and buzzer every 10 seconds. Notice the reference to the current state device resources in setting up the AutoEvents.


``` Shell
curl -X 'POST' 'http://localhost:59881/api/{{api_version}}/device' -d '[{"apiVersion" : "{{api_version}}", "device": {"name": "patlite1","description": "patlite #1","adminState": "UNLOCKED","operatingState": "UP","labels": ["patlite"],"serviceName": "device-snmp","profileName": "patlite-snmp-profile","protocols": {"TCP": {"Address": "10.0.0.14","Port": "161"}}, "AutoEvents":[{"Interval":"10s","OnChange":true,"SourceName":"RedLightCurrentState"}, {"Interval":"10s","OnChange":true,"SourceName":"GreenLightCurrentState"}, {"Interval":"10s","OnChange":true,"SourceName":"AmberLightCurrentState"}, {"Interval":"10s","OnChange":true,"SourceName":"BuzzerCurrentState"}]}}]'
```

!!! Info
    Rather than making a REST API call into metadata to add the device, you could alternately provide device configuration files that define the device.  These device configuration files would then have to be provided to the service when it starts up.  Since you did not create a new Docker image containing the device configuration and just used the existing SNMP device service Docker image, it was easier to make simple API calls to add the profile and device.  However, this would mean the profile and device would need to be added each time metadata's database is cleaned out and reset.


## Test

If the device service is up and running and the profile and device have been added correctly, you should now be able to interact with the Patlite via the core command service (and SNMP under the covers via the SNMP device service).

### Get the Current State

To get the current state of a light (in the example below the `Green` light), make a curl request like the following of the command service.

``` Shell
curl 'http://localhost:59882/api/{{api_version}}/device/name/patlite1/GreenLightCurrentState' | json_pp
```

!!! Alert
    Note that the curl command above assumes that the core command service is available at `localhost`.  Change the host address of your core command service if it is not available at `localhost`.  

The results should look something like that below.

``` JSON
{
   "statusCode" : 200,
   "apiVersion" : "v2",
   "event" : {
      "origin" : 1632188382048586660,
      "deviceName" : "patlite1",
      "sourceName" : "GreenLightCurrentState",
      "id" : "1e2a7ba1-c273-46d1-b919-207aafbc60ba",
      "profileName" : "patlite-snmp-profile",
      "apiVersion" : "v2",
      "readings" : [
         {
            "origin" : 1632188382048586660,
            "resourceName" : "GreenLightCurrentState",
            "deviceName" : "patlite1",
            "id" : "a41ac1cf-703b-4572-bdef-8487e9a7100e",
            "valueType" : "Int32",
            "value" : "1",
            "profileName" : "patlite-snmp-profile"
         }
      ]
   }
}
```

!!! Info

    Note the `value` will be one of 4 numbers indicating the current state of the light

    | Value | Description |
    |-------|-------------|
    | 1 | Off |
    | 2 | On - solid and not flashing |
    | 3 | Flashing on |
    | 4 | Flashing quickly on |

### Set a light or buzzer on

To turn a signal tower light or the buzzer on, you can issue a PUT device command via the core command service.  The example below turns on the `Green` light.

``` Shell
curl --location --request PUT 'http://localhost:59882/api/{{api_version}}/device/name/patlite1/GreenLight' --header 'cont: application/json' --data-raw '{"GreenLightControlState":"2","GreenLightTimer":"0"}'
```

![image](EdgeX_Patlite_Green_On.jpg)

This command sets the light on (solid versus flashing) immediate (as denoted by the GreenLightTimer parameter is set to 0).  The timer value is the number of seconds delay in making the request to the light or buzzer.  Again, the control state can be set to one of four values as listed in the table above. 

!!! Alert
    Again note that the curl command above assumes that the core command service is available at `localhost`.  Change the host address of your core command service if it is not available at `localhost`. 


## Observations

Did you notice that EdgeX obfuscates almost all information about SNMP, and managed objects and OIDs?  The power of EdgeX is to abstract away protocol differences so that to a user, getting data from a device or setting properties on a device such as this Patlite signal tower is as easy as making simple REST calls into the command service.  The only place that protocol information is really seen is in the device profile (where the attributes specify the SNMP OIDs).  Of course, the device service must be coded to deal with the protocol specifics and it must know how to translate the simple command REST calls into protocol specific requests of the device.  But even device service creation is made easier with the use of the SDKs which provide much of the boilerplate code found in almost every device service regardless of the underlying device protocol.
