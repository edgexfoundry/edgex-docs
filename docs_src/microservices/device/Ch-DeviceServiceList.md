# Supported Device Services List

The following table lists the EdgeX device services and protocols they support.

| Device Service Repository                                                                                    | Protocol | Status | Comments | Documentation |
|--------------------------------------------------------------------------------------------------------------|----------|--------|----------| ------------- |
| [device-onvif-camera](https://github.com/edgexfoundry/device-onvif-camera/tree/{{version}})                  | ONVIF | Active | Full implementation of ONVIF spec. Note that not all cameras implement the complete ONVIF spec. | [device-onvif-camera docs](./supported/device-onvif-camera/General.md) |
| [device-usb-camera](https://github.com/edgexfoundry/device-usb-camera/tree/{{version}})      | USB | Active | USB using V4L2 API. ONLY works on Linux with kernel v5.10 or higher. Includes RTSP server for video streaming. | [device-usb-camera docs](./supported/device-usb-camera/General.md) |
| [device-camera-go]( https://github.com/edgexfoundry/device-camera-go/tree/v2.2.0)                            | ONVIF | **Deprecated** | **Deprecated - use the new Device ONVIF Camera service** | |
| [device-rest-go]( https://github.com/edgexfoundry/device-rest-go/tree/{{version}})           | REST | Active| provides one-way communications only.  Allows posting of binary and JSON data via REST.  Events are single reading only.| |
| [device-rfid-llrp-go]( https://github.com/edgexfoundry/device-rfid-llrp-go/tree/{{version}}) | LLRP | Active| Communications with RFID readers via LLRP. | |
| [device-snmp-go]( https://github.com/edgexfoundry/device-snmp-go/tree/{{version}})           | SNMP | Active| Basic implementation of SNMP protocol.  Async callbacks and traps not currently supported. | |
| [device-virtual-go]( https://github.com/edgexfoundry/device-virtual-go/tree/{{version}})     | | Active| Simulates sensor readings of type binary, Boolean, float, integer and unsigned integer | [device-virtual docs](./supported/device-virtual/Ch-VirtualDevice.md) |
| [device-mqtt-go]( https://github.com/edgexfoundry/device-mqtt-go/tree/{{version}})           | MQTT | Active |  Two way communications via multiple MQTT topics | |
| [device-modbus-go]( https://github.com/edgexfoundry/device-modbus-go/tree/{{version}})       | Modbus | Active | Supports Modbus over TCP or RTU | |
| [device-gpio]( https://github.com/edgexfoundry/device-gpio/tree/{{version}})                 | GPIO | Active | Linux only; uses sysfs ABI | |
| [device-grove-c](https://github.com/edgexfoundry/device-grove-c/tree/v1.3.1)                                 | | **2.x TBD** | Connects the Grove sensor on Grove Raspberry Pi using libmraa library; Linux and ARM only | |
| [device-bacnet-c]( https://github.com/edgexfoundry/device-bacnet-c/tree/v1.3.1)                              | BACnet | **2.x TBD** | Supports BACnet via ethernet (IP) or serial (MSTP).  Uses the Steve Karag BACnet stack | |
| [device-coap-c]( https://github.com/edgexfoundry/device-coap-c/tree/v2.1.0)                                  | CoAP | Active (**2.2.0 TBD**) | This service is in the process of being redeveloped and expanded for upcoming release for Kamakura – and will support Thread as a subset of functionality.  Currently supports CoAP-based REST and is one way communications (read-only) | |
| [device-uart]( https://github.com/edgexfoundry-holding/device-uart)                                          | UART | **in Development** | Linux only; for connecting serial UART devices to EdgeX | |

!!! note
    Check the above Device Service README(s) for known devices that have been tested with the Device Service. Not all Device Service READMEs will have this information.
