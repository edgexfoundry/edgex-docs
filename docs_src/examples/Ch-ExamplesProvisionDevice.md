# Provison a Device - Modbus Example

For this example we will use the GS1-10P5 Modbus motor profile we have
available as reference [GS1
Profile](https://github.com/edgexfoundry/device-modbus/blob/master/src/main/resources/GS1-10P5.profile.yaml)
, device reference: Marathon Electric MicroMax motors via PLC
(<http://www.marathon-motors.com/Inverter-Vector-Duty-C-Face-Footed-TEFC-Micromax-Motor_c333.htm>)).
I would recommend using a tool like Postman for simplifying interactions
with the REST APIs (refer to the "Device and Device Service Setup (aka
Device Service Creation and Device Provisioning)" section for further
details at [API Demo Walkthrough](../walk-through/Ch-Walkthrough.md) , all REST
content is JSON). Also note that Postman is capable of importing RAML
documents for API framing (RAML docs for the EdgeX services may be found
in src/test/resources/raml or on the wiki). Note that this specific
example can be tweaked for use with the other Device Services.

1.  Upload the device profile above to metadata with a POST to
    <http://localhost:48081/api/v1/deviceprofile/uploadfile> and add the
    file as key "file" to the body
2.  Ensure the Modbus device service is running, adjust the service name
    below to match if necessary or if using other device services
3.  Add the device with a POST to
    <http://localhost:48081/api/v1/device>, the body will look something
    like:
``` json
{
  "name": "Variable Speed motor",
  "description": "MicroMax Variable Speed Motor",
  "adminState": "unlocked",
  "operatingState": "enabled",
  "protocols":{
    "modbus-tcp":{
       "host":"10.0.1.29",
       "port":"502",
       "unitID":"1"
    }
  },
  "labels": [],
  "location": null,
  "service": {
    "name": "edgex-device-modbus"
  },
  "profile": {
    "name": "GS1-VariableSpeedMotor"
  }
}
```
The service name must match/refer to the target device service, and
the profile name must match the device profile name from Step 1.

Further deep dives on the different microservices and layers can be
found in our EdgeX Tech Talks series ([EdgeX Tech
Talks](https://wiki.edgexfoundry.org/display/FA/EdgeX+Tech+Talks).)
where Jim and I cover some of the intricacies of various services. Of
particular relevance here is the Metadata Part 2 discussion covering
Device Profiles and Device Provisioning.
