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

    * Windows (ver 7 - 10)
    * Ubuntu Desktop (ver 14-20)
    * Ubuntu Server (ver 14-20)
    * Ubuntu Core (ver 16-18)
    * Mac OS X 10

!!! Info
    EdgeX is agnostic with regards to hardware (x86 and ARM), but only release artifacts for x86 and ARM 64 systems.  EdgeX has been successfully run on ARM 32 platforms but has required users to build their own executable from source.  EdgeX does not officially support ARM 32.
