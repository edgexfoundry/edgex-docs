##############################
Getting Started - Developers
##############################

============
Introduction
============

These instructions are for Developers and Contributors to obtain and run EdgeX Foundry.  (Users should read: :doc:`../Ch-GettingStartedUsers`) 

EdgeX Foundry is a collection of more than a dozen microservices that can be deployed to provide a minimal edge platform capability.  EdgeX Foundry consists of a collection of microservices and SDK tools.  The microservices and SDKs are mostly written in Go or C with some legacy servcies written in Java (EdgeX was originally written in Java).  These documentation pages provide a developer with the information and instructions to get and run EdgeX Foundry in development mode - that is running natively outside of containers and with the intent of adding to or changing the existing code base.

=============
What You Need
=============

**Hardware**

EdgeX Foundry is an operating system (OS)-agnostic and hardware (HW)-agnostic edge software platform. Minimum platform requirements are being established. At this time use the following recommended characteristics:

* Memory:  minimum of 1 GB 
* Hard drive space:  minimum of 3 GB of space to run the EdgeX Foundry containers, but you may want more depending on how long sensor and device data is retained
* OS: EdgeX Foundry has been run successfully on many systems including, but not limited to the following systems
        * Windows (ver 7 - 10)
        * Ubuntu Desktop (ver 14-16)
        * Ubuntu Server (ver 14)
        * Ubuntu Core (ver 16)
        * Mac OS X 10

**Software**

Developers will need to install the following software in order to get, run and develop EdgeX Foundry microservices:

**git** - a free and open source version control (SVC) system used to download (and upload) the EdgeX Foundry source code from the project's GitHub repository.  See https://git-scm.com/downloads for download and install instructions.  Alternative tools (Easy Git for example) could be used, but this document assumes use of git and leaves how to use alternative SVC tools to the reader.

**MongoDB** - by default, EdgeX Foundry uses MongoDB (version 4.2 as of this writing) as the persistence mechanism for sensor data as well as metadata about the devices/sensors that are connected.  See https://www.mongodb.com/download-center?jmp=nav#community for download and installation instructions.  As an alternative to installing MongoDB directly, you can use a MongoDB on another server or in the cloud.  This document will explain how to setup MongoDB for use with your development environment.

**Redis** - is an alternate oper source (BSD Licensed) database that can be used with EdgeX in place of MongoDB for many services.  Starting with the Geneva release, Redis will be the default EdgeX persistence mechanism for sensor, metadata, etc.  EdgeX works with Redis 5.0 as of this writing.  See https://redis.io/ for download and installation instructions.

**ZeroMQ**
ZeroMQ - several EdgeX Foundry services depend on ZeroMQ for communications by default.  The easiest way to get and install ZeroMQ on Linux is to use this setup script: https://gist.github.com/katopz/8b766a5cb0ca96c816658e9407e83d00.  Do note that the script assumes bash is available on your system and the bash executable is located in /usr/bin.  Before running the script at the link, run 

        which bash

at your Linux terminal to insure that bash is located in /usr/bin.  If not, change the first line of the script so that it points to the correct location of bash.
For macOS, use brew to install ZeroMQ.

        brew install zeromq

For directions installing ZeroMQ on Windows, please see the Windows documentation: https://github.com/edgexfoundry/edgex-go/blob/master/ZMQWindows.md

.. toctree::
   :maxdepth: 1

   Ch-GettingStartedGoDevelopers
   #TODO - provide getting started for C Developers

  
