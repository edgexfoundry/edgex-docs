# Getting Started - C Developers

## Introduction ![image](gcc-logo.png)

These instructions are for C Developers and Contributors to get, run and otherwise work with C-based EdgeX Foundry
micro services. Before reading this guide, review the general [developer requirements](./Ch-GettingStartedDevelopers.md#what-you-need).

If you want to get the EdgeX platform and run it (but do not intend to change or add to the existing code base now) then you are considered a "User". Users should read:
[Getting Started as a User](./Ch-GettingStartedUsers.md))

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

You can install these on Debian 11 (Bullseye) by running:
``` bash
sudo apt-get install libcurl4-openssl-dev libmicrohttpd-dev libyaml-dev libcbor-dev libpaho-mqtt-dev uuid-dev libhiredis-dev
```
Some of these supporting packages have dependencies of their own, which will be automatically installed when using package managers such as *APT*, *DNF* etc.

`libpaho-mqtt-dev` is not included in Ubuntu prior to Groovy (20.10). IOTech provides a package for Focal (20.04 LTS) which may be installed as follows:

``` bash
sudo curl -fsSL https://iotech.jfrog.io/artifactory/api/gpg/key/public -o /etc/apt/trusted.gpg.d/iotech-public.asc
sudo echo "deb https://iotech.jfrog.io/iotech/debian-release $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/iotech.list
sudo apt-get update
sudo apt-get install libpaho-mqtt
```

CMake is required to build the SDKs.  Version 3 or better is required.  You can install CMake on Debian by running:
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

### Installing IOT utilities

From EdgeX version 3.0, the C utilities used by the SDK must be installed as a pre-requisite package,
rather than being downloaded and built with the SDK itself as in previous versions. Note that if re-using
an old build tree, the `src/c/iot` and `include/iot` directories must be removed as these will be
outdated.

All commands shown are to be run as the root user.

#### Debian and Ubuntu

Management of package signing keys is changed in newer versions. For Debian 11 and Ubuntu 22.04:

```
apt-get install lsb-release apt-transport-https curl gnupg
curl -fsSL https://iotech.jfrog.io/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/iotech.gpg
echo "deb [signed-by=/usr/share/keyrings/iotech.gpg] https://iotech.jfrog.io/iotech/debian-release $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/iotech.list
apt-get update
apt-get install iotech-iot-1.5-dev
```

For earlier versions:

```
apt-get install lsb-release apt-transport-https curl gnupg
curl -fsSL https://iotech.jfrog.io/artifactory/api/gpg/key/public | apt-key add -
echo "deb https://iotech.jfrog.io/iotech/debian-release $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/iotech.list
apt-get update
apt-get install iotech-iot-1.5-dev
```

#### Alpine

```
wget https://iotech.jfrog.io/artifactory/api/security/keypair/public/repositories/alpine-release -O /etc/apk/keys/alpine.dev.rsa.pub
echo "https://iotech.jfrog.io/artifactory/alpine-release/v3.16/main" >> /etc/apk/repositories
apk update
apk add iotech-iot-1.5-dev
```

Note: If not using Alpine 3.16, replace v3.16 in the above commands with the correct version.

## Next Steps
To explore how to create and build EdgeX device services in C, head to the [Device Services, C SDK guide](../microservices/device/sdk/devicesdk-getting-started/GettingStartedSDK-C.md).
