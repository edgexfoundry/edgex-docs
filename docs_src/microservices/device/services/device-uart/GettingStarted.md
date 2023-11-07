---
title: Device UART - Getting Started
---

# Device UART - Getting Started

## Overview

Device UART is a device service for connecting a UART serial device  EdgeX using the EdgeX Message Bus.

## Running Services with Device MQTT

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run ds-uart no-secty 
    ```
This runs, in non-secure mode, all the standard EdgeX services and the UART device service.