# Default Service Ports
The following tables (organized by type of service) capture the default service ports.  These default ports are also used in the EdgeX provided service routes defined in the Kong API Gateway for access control.

=== "Core"
    |Services Name|	Port Definition|
    |---|---|
    |core-data|	59880|
    | 	|5563|
    |core-metadata	|59881|
    |core-command	|59882|
=== "Supporting"
    |Services Name|	Port Definition|
    |---|---|
    |support-notifications	|59860|
    |support-scheduler|	59861|
=== "Application & Analytics"
    |Services Name|	Port Definition|
    |---|---|
    |app-service-rules|59701|
    |rules engine/Kuiper|59720|
    |app-rfid-llrp-inventory|59711|
=== "Device"
    |Services Name|	Port Definition|
    |---|---|
    |device-virtual	|59900|
    |device-mqtt	|59982|
    |device-rest    |59986|
    |device-modbus	|59901|
    |device-bacnet  |59980|
    |device-snmp	|59993|
    |device-camera  |59985|
    |device-coap    |59988|
    |device-gpio    |59994|
    |device-grove   |59992|
    |device-llrp    |59989|
=== "Security"
    |Services Name|	Port Definition|
    |---|---|
    |vault	|8200|
    |kong-db	|5432|
    |kong	|8000|
    | 	|8100|
    | 	|8443|
=== "Miscellaneous"
    |Services Name|	Port Definition|
    |---|---|
    |consul	|8500|
    |redis|6379|
    |system	management|58890|
    |Modbus simulator|1502|
    |MQTT broker| 1883|
