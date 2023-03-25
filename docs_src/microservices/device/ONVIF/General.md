## Overview
The Open Network Video Interface Forum (ONVIF) Device Service is a microservice created to address the lack of standardization and automation of camera discovery and onboarding. EdgeX Foundry is a flexible microservice-based architecture created to promote the interoperability of multiple device interface combinations at the edge. In an EdgeX deployment, the ONVIF Device Service controls and communicates with ONVIF-compliant cameras, while EdgeX Foundry presents a standard interface to application developers. With normalized connectivity protocols and a vendor-neutral architecture, EdgeX paired with ONVIF Camera Device Service, simplifies deployment of edge camera devices. 


Use the ONVIF Device Service to streamline and scale your edge camera device deployment. 

## How It Works
The figure below illustrates the software flow through the architecture components.

![high-level-arch](ONVIFDeviceServiceArch.png)
<p align="left">
      <i>Figure 1: Software Flow</i>
</p>

1. **EdgeX Device Discovery:** Camera device microservices probe network and platform for video devices at a configurable interval. Devices that do not currently exist and that satisfy Provision Watcher filter criteria are added to Core Metadata.
2. **Application Device Discovery:** Query Core Metadata for devices and associated configuration.
3. **Application Device Configuration:** Set configuration and initiate device actions through a REST API representing the resources of the video device (e.g. stream URI, Pan-Tilt-Zoom position, Firmware Update).
4. **Pipeline Control:** The application initiates Video Analytics Pipeline through HTTP Post Request.
5. **Publish Inference Events/Data:** Analytics inferences are formatted and passed to the destination message bus specified in the request.
6.  **Export Data:** Publish prepared (transformed, enriched, filtered, etc.) and groomed (formatted, compressed, encrypted, etc.) data to external systems (be it analytics package, enterprise or on-premises application, cloud systems like Azure IoT, AWS IoT, or Google IoT Core, etc.


## Getting Started

A brief video demonstration of building and using the device service:

<iframe
    width="640"
    height="480"
    src="https://www.youtube.com/embed/vZqd3j2Zn2Y"
    frameborder="0"
    allow="autoplay; encrypted-media"
    allowfullscreen
>
</iframe>
[Get Started>](./Walkthrough/setup.md){: .md-button}

## Learn More 

### General
[Supported ONVIF features](./supplementary-info/ONVIF-protocol.md)  
[Auto discovery](./supplementary-info/auto-discovery.md)  
[Control-plane events](./supplementary-info/control-plane-events.md)  
[Utility Scripts](./supplementary-info/utility-scripts.md)


### Custom Features
[Custom Metadata](./doc/custom-metadata-feature.md)  
[Reboot Needed](./doc/custom-feature-rebootneeded.md)  
[Friendly Name and Mac Address](./doc/get-set-friendlyname-mac.md)  

### API Support
[API Analytic Handling](./doc/api-analytic-support.md)  
[API Event Handling](./doc/api-event-handling.md)  
[API User Handling](./doc/api-usage-user-handling.md)  

### Miscellaneous
[Postman](./doc/test-with-postman.md)  
[User Authentication](./doc/onvif-user-authentication.md)  

## Resources
[Learn more about EdgeX Core Metadata](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/2.1.0)  
[Learn more about EdgeX Core Command](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-command/2.1.0)


## References

- [ONVIF Website](http://www.onvif.org)  
- [EdgeX Foundry Project Wiki](https://wiki.edgexfoundry.org/)  
- [EdgeX Source Code](https://github.com/edgexfoundry)  
- [Edgex Developer Guide](https://docs.edgexfoundry.org/2.1/)
- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- [Docker Compose](https://docs.docker.com/compose/install/#install-compose)


## License

[Apache-2.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/main/LICENSE)