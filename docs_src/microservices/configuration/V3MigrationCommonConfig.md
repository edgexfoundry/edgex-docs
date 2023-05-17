# V3 Migration of Common Configuration 
Changed database configuration from `Databases map[string]bootstrapConfig.Database` to `Database bootstrapConfig.Database`

!!! exmaple "Example V3 Database configuration"
    ```
    Database:
      Host: "localhost"
      Port: 6379
      Timeout: "5s"
      Type: "redisdb"
    ```
