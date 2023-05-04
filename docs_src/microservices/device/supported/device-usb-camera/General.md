# General

## Overview
The USB Device Service is a microservice created to address the lack of standardization and automation of camera discovery and onboarding. EdgeX Foundry is a flexible microservice-based architecture created to promote the interoperability of multiple device interface combinations at the edge. In an EdgeX deployment, the USB Device Service controls and communicates with USB cameras, while EdgeX Foundry presents a standard interface to application developers. With normalized connectivity protocols and a vendor-neutral architecture, EdgeX paired with USB Camera Device Service, simplifies deployment of edge camera devices.

Specifically, the device service uses V4L2 API to get camera metadata, FFmpeg framework to capture video frames and stream them to an [RTSP server](https://github.com/aler9/rtsp-simple-server), which is embedded in the dockerized device service. This allows the video stream to be integrated into the [larger architecture](#how-it-works).

Use the USB Device Service to streamline and scale your edge camera device deployment. 


## How It Works

The figure below illustrates the software flow through the architecture components.

![high-level-arch](./images/USBDeviceServiceArch.png)
<p align="left">
      <i>Figure 1: Software Flow</i>
</p>

1. **EdgeX Device Discovery:** Camera device microservices probe network and platform for video devices at a configurable interval. Devices that do not currently exist and that satisfy Provision Watcher filter criteria are added to `Core Metadata`.
2. **Application Device Discovery:** The microservices then query `Core Metadata` for devices and associated configuration.
3. **Application Device Configuration:** The configuration and triggering of device actions are done through a REST API representing the resources of the video device.
4. **Pipeline Control:** The application initiates the `Video Analytics Pipeline` through HTTP Post Request.
5. **Publish Inference Events/Data:** Analytics inferences are formatted and passed to the destination message bus specified in the request.
6. **Export Data:** Publish prepared (transformed, enriched, filtered, etc.) and groomed (formatted, compressed, encrypted, etc.) data to external systems (be it analytics package, enterprise or on-premises application, cloud systems like Azure IoT, AWS IoT, or Google IoT Core, etc.


# Getting Started

[Get Started>](./walkthrough/setup.md){: .md-button}


## References
- [ONVIF Website](https://www.onvif.org)  
- [EdgeX Foundry Project Wiki](https://wiki.edgexfoundry.org/)  
- [EdgeX Source Code](https://github.com/edgexfoundry)  
- [Edgex Developer Guide](https://docs.edgexfoundry.org/2.1/)
- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- [Docker Compose](https://docs.docker.com/compose/install/#install-compose)


# License
[Apache-2.0](https://github.com/edgexfoundry/device-usb-camera/blob/main/LICENSE)
