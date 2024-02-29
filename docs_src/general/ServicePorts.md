# Default Service Ports
The following tables (organized by type of service) capture the default service ports.  These default ports are also used in the EdgeX provided service routes defined in the Kong API Gateway for access control.

=== "Core"
    |Services Name|	Port Definition|
    |---|---|
    |core-data|	59880|
    |core-metadata	|59881|
    |core-command	|59882|
    |redis|6379|
    |consul|8500|
=== "Supporting"
    |Services Name|	Port Definition|
    |---|---|
    |support-notifications	|59860|
    |support-scheduler|	59861|
    |rules engine / eKuiper|59720|
    |system management agent (deprecated)|58890|
=== "Application"
    |Services Name|	Port Definition|
    |---|---|
    |app-sample|59700|
    |app-service-rules|59701|
    |app-push-to-core|59702|
    |app-mqtt-export|59703|
    |app-http-export|59704|
    |app-functional-tests|59705|
    |app-external-mqtt-trigger|59706|
    |app-metrics-influxdb|59707|
    |app-rfid-llrp-inventory|59711|
=== "Device"
    |Services Name|	Port Definition|
    |---|---|
    |device-virtual	|59900|
    |device-modbus	|59901|
    |device-bacnet  |59980|
    |device-mqtt	|59982|
    |device-usb-camera |59983|
    |device-onvif-camera |59984|
    |device-camera  |59985|
    |device-rest    |59986|
    |device-coap    |59988|
    |device-rfid-llrp    |59989|
    |device-grove   |59992|
    |device-snmp	|59993|
    |device-gpio    |59910|
    |device-s7      |59994|
=== "Security"
    |Services Name|	Port Definition|
    |---|---|
    |vault	                        |8200|
    |nginx	                        |8000, 8443|
    |security-spire-server          |59840|
    |security-spiffe-token-provider |59841|
    |security-proxy-auth            |59842|
=== "Miscellaneous"
    |Services Name|	Port Definition|
    |---|---|
    |ui|4000|
    |Modbus simulator|1502|
    |MQTT broker| 1883|
