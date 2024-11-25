# Platform Requirements

EdgeX Foundry is an operating system (OS)-agnostic and hardware (HW)-agnostic IoT edge platform. At this time the following platform minimums are recommended:

=== "Memory"
    Memory: minimum of 1 GB
    When considering memory for your EdgeX platform, take into account your database choice - PostgreSQL is the default in EdgeX 4.0. PostgreSQL is a powerful, open-source relational database management system that offers robust data storage, query capabilities, and performance optimization. PostgreSQL stores data on disk and leverages advanced caching strategies to enhance performance.

    For more information about PostgreSQL's memory utilization and optimization techniques, refer to the following resources:

    - [PostgreSQL Documentation: Resource Consumption](https://www.postgresql.org/docs/current/runtime-config-resource.html)
    - [Tuning PostgreSQL Memory Parameters](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)
    
=== "Storage"
    Hard drive space: minimum of 3 GB of space to run the EdgeX Foundry containers, but you may want more depending on how long sensor and device data is to be retained.  Approximately 32GB of storage is minimally recommended to start.
=== "Operating Systems"
    EdgeX Foundry has been run successfully on many systems, including, but not limited to the following systems

    * Windows 7 and higher
    * Ubuntu Desktop/Server 14 and higher
    * Ubuntu Core 16 and higher
    * Mac OS X

!!! Info
    EdgeX Foundry runs on various distributions and / or versions of Linux, Unix, MacOS, Windows, etc. However, the community only supports the platform on `amd64` (x86-64) and `arm64` architectures.

    EdgeX Foundry releases pre-built artifacts as Docker images. Please refer to [Getting Started](../../getting-started) for details.
    
    EdgeX can run on `armhf` architecture but that requires users to build their own executables from source. EdgeX does not officially support `armhf`.
