# Platform Requirements

EdgeX Foundry is an operating system (OS)-agnostic and hardware (HW)-agnostic IoT edge platform. At this time the following platform minimums are recommended:

=== "Memory"
    Memory: minimum of 1 GB
    When considering memory for your EdgeX platform consider your use of database - Redis is the current default.  Redis is an open source (BSD licensed), in-memory data structure store, used as a database and message broker in EdgeX.  Redis is durable and uses persistence only for recovering state; the only data Redis operates on is in-memory.  Redis uses a number of techniques to optimize memory utilization. Antirez and Redis Labs have written a number of articles on the underlying details (see list below).  Those strategies has continued to [evolve](http://antirez.com/news/128). When thinking about your system architecture, consider how long data will be living at the edge and consuming memory (physical or physical + virtual).

    - [Antirez](http://antirez.com/news/92)
    - [Redis RAM Ramifications](https://redislabs.com/blog/redis-ram-ramifications-part-i/)
    - [Redis IO Memory Optimization](https://redis.io/topics/memory-optimization)
    
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

    EdgeX Foundry releases pre-built artifacts as Docker images and Snaps. Please refer to [Getting Started](../../getting-started) for details.
    
    EdgeX can run on `armhf` architecture but that requires users to build their own executables from source. EdgeX does not officially support `armhf`.
