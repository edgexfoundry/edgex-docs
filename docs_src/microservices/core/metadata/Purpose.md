---
title: Core Metadata - Purpose
---

# Core Metadata - Purpose

The core metadata micro service has manages the knowledge about [devices](../../../general/Definitions.md#device) and sensors. This information is used by other services (Device, Command, etc) to communicate with them.

Specifically, metadata has the following abilities:

-   Manages information about the devices connected to, and operated by, EdgeX Foundry
-   Knows the type, and organization of data reported by the devices
-   Knows how to command the devices

Although metadata has the knowledge, it does not do the following activities:

-   It is not responsible for actual data collection from devices, which is performed by device services and core data
-   It is not responsible for issuing commands to the devices, which is performed by core command and device
    services

![image](EdgeX_Metadata.png)