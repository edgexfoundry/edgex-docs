# Available Device Services List

The following table lists the EdgeX device services and protocols they support.

| Device Service Repository                                                                         | Protocol | Status | Comments | Documentation                                                |
|---------------------------------------------------------------------------------------------------|----------|--------|----------|--------------------------------------------------------------|
| [device-bacnet-c]( https://github.com/edgexfoundry/device-bacnet-c/tree/{{edgexversion}})         | BACnet | Active | Supports BACnet via ethernet (IP) or serial (MSTP).  Uses the Steve Karag BACnet stack | [device-bacnet docs](./device-bacnet.md)                     |
| [device-coap-c]( https://github.com/edgexfoundry/device-coap-c/tree/{{edgexversion}})             | CoAP | Active |  EdgeX device service for CoAP-based REST protocol | [device-coap docs](./device-coap.md)                         |                                                             |
| [device-gpio]( https://github.com/edgexfoundry/device-gpio/tree/{{edgexversion}})                 | GPIO | Active | Linux only; uses sysfs ABI | [device-gpio docs](./device-gpio.md)                         |
| [device-modbus-go]( https://github.com/edgexfoundry/device-modbus-go/tree/{{edgexversion}})       | Modbus | Active | Supports Modbus over TCP or RTU | [device-modbus docs](./device-modbus.md)                     |
| [device-mqtt-go]( https://github.com/edgexfoundry/device-mqtt-go/tree/{{edgexversion}})           | MQTT | Active |  Two way communications via multiple MQTT topics | [device-mqtt docs](./device-mqtt.md)                         | 
| [device-onvif-camera](https://github.com/edgexfoundry/device-onvif-camera/tree/{{edgexversion}})  | ONVIF | Active | Full implementation of ONVIF spec. Note that not all cameras implement the complete ONVIF spec. | [device-onvif-camera docs](./device-onvif-camera/General.md) |
| [device-rest-go]( https://github.com/edgexfoundry/device-rest-go/tree/{{edgexversion}})           | REST | Active| provides one-way communications only.  Allows posting of binary and JSON data via REST.  Events are single reading only.| [device-rest docs](./device-rest.md)                         |
| [device-rfid-llrp-go]( https://github.com/edgexfoundry/device-rfid-llrp-go/tree/{{edgexversion}}) | LLRP | Active| Communications with RFID readers via LLRP. | [device-rfid-llrp docs](./device-rfid-llrp.md)               |
| [device-snmp-go]( https://github.com/edgexfoundry/device-snmp-go/tree/{{edgexversion}})           | SNMP | Active| Basic implementation of SNMP protocol.  Async callbacks and traps not currently supported. | [device-snmp docs](./device-snmp.md)                         |
| [device-uart]( https://github.com/edgexfoundry/device-uart/tree/{{edgexversion}})                 | UART |Active| Linux only; for connecting serial UART devices to EdgeX | [device-urt docs](./device-uart.md)                          |
| [device-usb-camera](https://github.com/edgexfoundry/device-usb-camera/tree/{{edgexversion}})      | USB | Active | USB using V4L2 API. ONLY works on Linux with kernel v5.10 or higher. Includes RTSP server for video streaming. | [device-usb-camera docs](./device-usb-camera/General.md)     |
| [device-virtual-go]( https://github.com/edgexfoundry/device-virtual-go/tree/{{edgexversion}})     | | Active| Simulates sensor readings of type binary, Boolean, float, integer and unsigned integer | [device-virtual docs](./device-virtual/Ch-VirtualDevice.md)  |

!!! note
    Check the above Device Service README(s) for known devices that have been tested with the Device Service. Not all Device Service READMEs will have this information.
