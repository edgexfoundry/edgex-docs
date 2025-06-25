# Getting Started as a Developer

## Introduction

These instructions are for Developers and Contributors to get and run
EdgeX Foundry. If you want to get the EdgeX platform and run it (but do not intend to change or add to the existing code base now) then you are considered a "User". Users should read:
[Getting Started as a User](./Ch-GettingStartedUsers.md)

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

#### Docker (Optional)
If you intend to create Docker images for your updated or newly created EdgeX services, you need to install Docker. See https://docs.docker.com/install/ to learn how to install Docker. If you are new to Docker, the same web site provides you educational information.

### Additional Programming Tools and Next Steps
Depending on which part of EdgeX you work on, you need to install one or more programming languages (Go, C, etc.) and associated tooling.
These tools are covered under the documentation specific to each type of development.

- [Go (Golang)](./Ch-GettingStartedGoDevelopers.md)
- [C](./Ch-GettingStartedCDevelopers.md)

## Versioning

Please refer to the EdgeX Foundry [versioning policy](https://lf-edgexfoundry.atlassian.net/wiki/spaces/FA/pages/11668318/Releases) for information on how EdgeX services are released and how EdgeX services are compatible with one another.  Specifically, device services (and the associated SDK), application services (and the associated app functions SDK), and client tools (like the EdgeX CLI and UI) can have independent minor releases, but these services must be compatible with the latest major release of EdgeX.

## Long Term Support

Please refer to the EdgeX Foundry [LTS policy](https://lf-edgexfoundry.atlassian.net/wiki/spaces/FA/pages/11676227/Long+Term+Support) for information on support of EdgeX releases. The EdgeX community does not offer support on any non-LTS release outside of the latest release.