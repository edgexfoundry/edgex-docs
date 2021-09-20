# Getting Started - C Developers

## Introduction ![image](gcc-logo.png)

These instructions are for C Developers and Contributors to get, run and otherwise work with C-based EdgeX Foundry
micro services. Before reading this guide, review the general [developer requirements](./Ch-GettingStartedDevelopers.md#what-you-need).

If you want to get the EdgeX platform and run it (but do not intend to change or add to the existing code base now) then you are considered a "User". Users should read:
[Getting Started Users](./Ch-GettingStartedUsers.md))

## What You Need For C Development
Many of EdgeX device services are built in C.  In the future, other services could be built in C.  In additional to the hardware and software listed in the [Developers
guide](./Ch-GettingStartedDevelopers.md), to build EdgeX C services, you will need the following:

-   libmicrohttpd
-   libcurl
-   libyaml
-   libcbor
-   paho
-   libuuid
-   hiredis

You can install these on Ubuntu (20.04 LTS) by running:
``` bash
sudo apt-get install libcurl4-openssl-dev libmicrohttpd-dev libyaml-dev libcbor-dev libpaho-mqtt uuid-dev libhiredis-dev
```
Some of these supporting packages have dependencies of their own, which will be automatically installed when using package managers such as *APT*, *DNF* etc.

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the C SDK now supports MQTT and Redis implementations of the EdgeX MessageBus

CMake is required to build the SDKs.  Version 3 or better is required.  You can install CMake on Ubuntu by running:
``` bash
sudo apt-get install cmake
```

Check that your C development environment includes the following:

- a version of GCC supporting C11
- CMake version 3 or greater
- Development libraries and headers for:
    - curl (version 7.56 or later)
    - microhttpd (version 0.9)
    - libyaml (version 0.1.6 or later)
    - libcbor (version 0.5)
    - libuuid (from util-linux v2.x)
    - paho (version 1.3.x)
    - hiredis (version 0.14)

## Next Steps
To explore how to create and build EdgeX device services in C, head to the [Device Services, C SDK guide](Ch-GettingStartedSDK-C.md).
