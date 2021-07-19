# Default Service Ports
The following tables (organized by type of service) capture the default service ports.  These default ports are also used in the EdgeX provided service routes defined in the Kong API Gateway for access control.

=== "Core"
    |Services Name|	Port Definition|
    |---|---|
    |core-data|	59880|
    |ZMQ - to be deprecated in a future release|5563|
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
    |app-sample|59700|
    |app-service-rules|59701|
    |app-push-to-core|59702|
    |app-mqtt-export|59703|
    |app-http-export|59704|
    |app-functional-tests|59705|
    |app-rfid-llrp-inventory|59711|
    |rules engine/eKuiper|59720|
=== "Device"
    |Services Name|	Port Definition|
    |---|---|
    |device-virtual	|59900|
    |device-modbus	|59901|
    |device-bacnet  |59980|
    |device-mqtt	|59982|
    |device-camera  |59985|
    |device-rest    |59986|
    |device-coap    |59988|
    |device-llrp    |59989|
    |device-grove   |59992|
    |device-snmp	|59993|
    |device-gpio    |59994|
=== "Security"
    |Services Name|	Port Definition|
    |---|---|
    |kong-db|5432|
    |vault	|8200|
    |kong	|8000|
    | 	|8100|
    | 	|8443|
=== "Miscellaneous"
    |Services Name|	Port Definition|
    |---|---|
    |Modbus simulator|1502|
    |MQTT broker| 1883|
    |redis|6379|
    |consul	|8500|
    |system	management|58890|
