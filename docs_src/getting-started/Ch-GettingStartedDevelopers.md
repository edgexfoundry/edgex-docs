# Getting Started as a Developer

## Introduction

These instructions are for Developers and Contributors to get and run
EdgeX Foundry. If you want to get the EdgeX platform and run it (but do not intend to change or add to the existing code base now) then you are considered a "User". Users should read:
[Getting Started as a User](./Ch-GettingStartedUsers.md))

EdgeX is a collection of more than a dozen micro services that are deployed to provide a minimal edge platform capability. 
EdgeX consists of a collection of reference implementation services and SDK tools. The micro services and SDKs are written in Go or C. 
These documentation pages provide a developer with the information and
instructions to get and run EdgeX Foundry in development mode - that is
running natively outside of containers and with the intent of adding to
or changing the existing code base.

## What You Need

### Hardware

EdgeX Foundry is an operating system (OS) and hardware (HW)-agnostic edge software platform. 
See the reference page for [platform requirements](../../general/PlatformRequirements). These provide guidance on a minimal platform to run the EdgeX platform.  However, as a developer, you may find that additional memory, disk space, and improved CPU are essential to building and debugging.

### Software

Developers need to install the following software to get,
run and develop EdgeX Foundry micro services:

#### Git
Use this free and open source version control (SVC) system to
download (and upload) the EdgeX Foundry source code from the project's
GitHub repositories. See <https://git-scm.com/downloads> for download and
install instructions. Alternative tools (Easy Git for example) could be
used, but this document assumes use of git and leaves how to use
alternative SVC tools to the reader.

#### Redis
By default, EdgeX Foundry uses Redis (version 5 starting with the Geneva release)
as the persistence mechanism for sensor data as well as metadata about the devices/sensors that are 
connected. See [Redis Documentation](https://redis.io/) for download and installation
instructions.

#### MongoDB
As an alternative, EdgeX Foundry allows use of MongoDB (version 4.2 as of
Geneva) as the alternative persistence mechanism in place of Redis for sensor data as well as
metadata about the connected devices/sensors. See [Mongo's Documentation](https://www.mongodb.com/download-center?jmp=nav#community) for download
and installation instructions.

!!! Warning
    Use of MongoDB is deprecated with the Geneva release.  EdgeX will remove MongoDB support in a future
    release.  Developers should start to migrate to Redis in all development efforts targeting
    future EdgeX releases. 

#### ZeroMQ
Several EdgeX Foundry services depend on ZeroMQ for
communications by default.  See the installation for your OS.

=== "Linux/Unix"
    The easiest way to get and install ZeroMQ on
    Linux is to use this setup script:
    <https://gist.github.com/katopz/8b766a5cb0ca96c816658e9407e83d00>. 

    !!! Note
        The 0MQ install script above assumes bash is available on your system and the
        bash executable is in /usr/bin. Before running the script at the
        link, run
        ``` bash
        which bash
        ```
        at your Linux terminal to insure that bash is in /usr/bin. If
        not, change the first line of the script so that it points to the
        correct location of bash. 

=== "MacOS"
    For MacOS, use brew to install ZeroMQ.
    ``` bash
    brew install zeromq
    ```

=== "Windows"
    For directions installing ZeroMQ on Windows, please see the Windows
    documentation:
    <https://github.com/edgexfoundry/edgex-go/blob/master/ZMQWindows.md>

#### Docker (Optional)
If you intend to create Docker images for your updated or newly created EdgeX services, you need to install Docker. See https://docs.docker.com/install/ to learn how to install Docker. If you are new to Docker, the same web site provides you educational information.

### Additional Programming Tools and Next Steps
Depending on which part of EdgeX you work on, you need to install one or more programming languages (Go, C, etc.) and associated tooling.
These tools are covered under the documentation specific to each type of development.

- [Go (Golang)](./Ch-GettingStartedGoDevelopers.md)
- [C](./Ch-GettingStartedCDevelopers.md)

## Versioning

Please refer to the EdgeX Foundry [versioning policy](https://wiki.edgexfoundry.org/pages/viewpage.action?pageId=21823969) for information on how EdgeX services are released and how EdgeX services are compatible with one another.  Specifically, device services (and the associated SDK), application services (and the associated app functions SDK), and client tools (like the EdgeX CLI and UI) can have independent minor releases, but these services must be compatible with the latest major release of EdgeX.

## Long Term Support

Please refer to the EdgeX Foundry [LTS policy](https://wiki.edgexfoundry.org/pages/viewpage.action?pageId=69173332) for information on support of EdgeX releases. The EdgeX community does not offer support on any non-LTS release outside of the latest release.