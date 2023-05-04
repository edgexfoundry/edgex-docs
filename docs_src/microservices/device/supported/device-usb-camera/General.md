# USB Camera Device Service
[![Build Status](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/device-usb-camera/job/main/badge/icon)](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/device-usb-camera/job/main/) [![Code Coverage](https://codecov.io/gh/edgexfoundry/device-usb-camera/branch/main/graph/badge.svg?token=K4V4LAJYYW)](https://codecov.io/gh/edgexfoundry/device-usb-camera) [![Go Report Card](https://goreportcard.com/badge/github.com/edgexfoundry/device-usb-camera)](https://goreportcard.com/report/github.com/edgexfoundry/device-usb-camera) [![GitHub Latest Dev Tag)](https://img.shields.io/github/v/tag/edgexfoundry/device-usb-camera?include_prereleases&sort=semver&label=latest-dev)](https://github.com/edgexfoundry/device-usb-camera/tags) ![GitHub Latest Stable Tag)](https://img.shields.io/github/v/tag/edgexfoundry/device-usb-camera?sort=semver&label=latest-stable) [![GitHub License](https://img.shields.io/github/license/edgexfoundry/device-usb-camera)](https://choosealicense.com/licenses/apache-2.0/) ![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/edgexfoundry/device-usb-camera) [![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/edgexfoundry/device-usb-camera)](https://github.com/edgexfoundry/device-usb-camera/pulls) [![GitHub Contributors](https://img.shields.io/github/contributors/edgexfoundry/device-usb-camera)](https://github.com/edgexfoundry/device-usb-camera/contributors) [![GitHub Committers](https://img.shields.io/badge/team-committers-green)](https://github.com/orgs/edgexfoundry/teams/device-usb-camera-committers/members) [![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/edgexfoundry/device-usb-camera)](https://github.com/edgexfoundry/device-usb-camera/commits)


> **Warning**  
> The `main` branch contains work-in-progress development code for the upcoming EdgeX 3.0.0 release, **and is not guaranteed to be stable or working**. It is only compatible with the [main branch of edgex-compose](https://github.com/edgexfoundry/edgex-compose).
>
> **The current stable branch of device-usb-camera is [Levski](https://github.com/edgexfoundry/device-usb-camera/tree/levski).**

## Overview
The USB Device Service is a microservice created to address the lack of standardization and automation of camera discovery and onboarding. EdgeX Foundry is a flexible microservice-based architecture created to promote the interoperability of multiple device interface combinations at the edge. In an EdgeX deployment, the USB Device Service controls and communicates with USB cameras, while EdgeX Foundry presents a standard interface to application developers. With normalized connectivity protocols and a vendor-neutral architecture, EdgeX paired with USB Camera Device Service, simplifies deployment of edge camera devices.

Specifically, the device service uses V4L2 API to get camera metadata, FFmpeg framework to capture video frames and stream them to an [RTSP server](https://github.com/aler9/rtsp-simple-server), which is embedded in the dockerized device service. This allows the video stream to be integrated into the [larger architecture](#how-it-works).

Use the USB Device Service to streamline and scale your edge camera device deployment. 


## How It Works

The figure below illustrates the software flow through the architecture components.

![high-level-arch](./docs/images/USBDeviceServiceArch.png)
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

Learn how to configure and run the service by following these [instructions](./docs/setup.md). 

For a full walkthrough of using the default images, use this [guide.](./docs/guides/SimpleStartupGuide.md)  

For a full walkthrough of building custom images, use this [guide.](./docs/guides/CustomStartupGuide.md)  

# Learn More
[General Usage](./docs/general-usage.md)  
[Device Discovery](./docs/discovery.md)  
[Advanced Options](./docs/advanced-options.md)  
## Testing
[Postman Collection](./docs/USB-Camera-Collection.postman_collection.json)  
[Postman Collection Environment](./docs/USB_camera_env.postman_environment.json)  
## References
- EdgeX Foundry Project Wiki: https://wiki.edgexfoundry.org/
- EdgeX Source Code: https://github.com/edgexfoundry
- Edgex Developer Guide: https://docs.edgexfoundry.org/2.1/
- Docker Repos
   - Docker https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
   - Docker Compose https://docs.docker.com/compose/install/#install-compose


# License
[Apache-2.0](LICENSE)
