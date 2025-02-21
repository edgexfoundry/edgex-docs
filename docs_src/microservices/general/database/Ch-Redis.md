# Redis

EdgeX Foundry's reference implementation database (for sensor data, metadata and all things that need to be persisted in a database) is Redis.

Redis is an open source (BSD licensed), in-memory data structure store, used as a database and message broker in EdgeX. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams. Redis is durable and uses persistence only for recovering state; the only data Redis operates on is in-memory.

## Memory Utilization

Redis uses a number of techniques to optimize memory utilization. Antirez and [Redis Labs](https://redislabs.com/) have written a number of articles on the underlying details (see the list below) and those strategies has continued to [evolve](http://antirez.com/news/128). When thinking about your system architecture, consider how long data will be living at the edge and consuming memory (physical or physical + virtual).

- [http://antirez.com/news/92](http://antirez.com/news/92)
- [https://redislabs.com/blog/redis-ram-ramifications-part-i/](https://redislabs.com/blog/redis-ram-ramifications-part-i/)
- [https://redis.io/topics/memory-optimization](https://redis.io/topics/memory-optimization)
- [http://antirez.com/news/128](http://antirez.com/news/128)

## On-disk Persistence

Redis supports a number of different levels of on-disk persistence. By default, the configuration includes multiple save intervals:

- After 1 hour, if at least 1 key has changed.
- After 5 minutes, if at least 100 keys have changed.
- After 1 minute, if at least 10,000 keys have changed.

This can be checked by running the command:
```shell
127.0.0.1:6379> CONFIG GET save
1) "save"
2) "3600 1 300 100 60 10000"
```

Beyond increasing the frequency of snapshots, append-only files that log every database write are also supported. See [Redis Persistence](https://redis.io/topics/persistence) for a detailed discussion on how to balance the options.

Redis supports setting a memory usage limit and a policy on what to do if memory cannot be allocated for a write. See the MEMORY MANAGEMENT section of [the Redis configuration file](https://raw.githubusercontent.com/antirez/redis/7.0/redis.conf) for the latest configuration options. Since EdgeX and Redis do not currently communicate on data evictions, you will need to use the EdgeX scheduler to control memory usage rather than a Redis eviction policy.