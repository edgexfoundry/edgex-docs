# Default Service Ports
The following tables (organized by type of service) capture the default service ports.  These default ports are also used in the EdgeX provided service routes defined in the Kong API Gateway for access control.

=== "Core"
    |Services Name|	Port Definition|
    |---|---|
    |core-data|	48080|
    | 	|5563|
    |core-metadata	|48001|
    |core-command	|48082|
=== "Supporting"
    |Services Name|	Port Definition|
    |---|---|
    |support-notifications	|48060|
    |support-logging	|48061|
    |support-scheduler|	48085|
=== "Application & Analytics"
    |Services Name|	Port Definition|
    |---|---|
    |app-service-rules|48095|
    |rules engine/Kuiper|48075|
    |   |20498|
=== "Device"
    |Services Name|	Port Definition|
    |---|---|
    |device-virtual	|49990|
    |device-random	|49988|
    |device-mqtt	|49982|
    |device-rest    |49986|
    |device-modbus	|49991|
    |device-snmp	|49993|
=== "Security"
    |Services Name|	Port Definition|
    |---|---|
    |vault	|8200|
    |kong-db	|5432|
    |kong	|8000|
    | 	|8001|
    | 	|8443|
    | 	|8444|
=== "Miscellaneous"
    |Services Name|	Port Definition|
    |---|---|
    |consul	|8400|
    | 	|8500|
    | 	|8600|
    |mongo|27017|
    |redis|6379|
    |system	management|48090|
