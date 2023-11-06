# Use Case Title
Protocol-specific Attribute Values in Device

## Submitters
Darryl Mocek (Oracle Corporation)

## Changelog

## Market Segments
Any segments using EdgeX with device services that contain protocol-specific values in Device Profile attributes.

## Motivation
The Device Profile describes the device.  There are many different manufacturers of the same type of device (e.g. HVAC).  The Device Profile of a specific type of device could used be for many or all of the Devices of that type, reducing the need to duplicate a Device Profile just to account for differences in the protocol-specific attribute values.

## Target Users
Any users that create Device Profiles and Devices that have protocol-specific attribute values.

## Description
The Device Profile **describes** the device and its attributes, it's type.  Different manufacturers can build the same type of device using different protocols and the same device using the same protocol but different configuration (e.g. different Modbus HoldingRegister).  For example, two different manufacturers may build an HVAC using ModBus, and another may build an HVAC using SNMP.  In the case of two Modbus devices, there will need to be two different Device Profiles, even though the devices are the same and have the same attributes, because the protocol configurations (e.g. HoldingRegister) will conflict.  Device Profile 

If the protocol information resides in the Device, which describes a specific (instance of a) device only a single Device Profile is needed as all devices of the same type can use the same Device Profile.  This becomes more important as you have more devices, potentially increasing the number and management of Device Profiles when one will do.

## Existing solutions
<!--
How is the given use case currently implemented in the industry, with or without EdgeX?
List and describe each approach. Highlight possible gaps.
-->

## Requirements
The requirement is to support the protocol-specific attribute values (e.g. HoldingRegister) in the Device as well as the Device Profile (for backward compatibility).

- If only the Device contains a protocol-specific attribute, it is used for that device.
- If only the Device Profile contains a protocol-specific attribute, it is used for all Devices that have that Device Profile.
- If both the Device Profile and the Device contain a protocol-specific attribute, the entry in the Device overrides the one in the Device Profile.

## Related Issues

## References
- https://github.com/edgexfoundry/device-modbus/blob/master/src/main/resources/MBUS-RTH-LCD.profile.yaml
