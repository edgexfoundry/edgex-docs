# EdgeX Container Names
The following table provides the list of the default EdgeX Docker image names to the Docker container name and Docker Compose names.

=== "Core"
    |Docker image name|Docker container name|Docker network hostname | Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/core-data|edgex-core-data|edgex-core-data|core-data|
    |edgexfoundry/core-metadata|edgex-core-metadata| edgex-core-metadata|core-metadata|
    |edgexfoundry/core-command|edgex-core-command| edgex-core-command | core-command|
    |edgexfoundry/core-common-config-bootstrapper|edgex-core-common-config-bootstrapper| edgex-core-common-config-bootstrapper | core-common-config-bootstrapper|

=== "Supporting"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/support-notifications|edgex-support-notifications|edgex-support-notifications|support-notifications|
    |edgexfoundry/support-scheduler|edgex-support-scheduler|edgex-support-scheduler| support-scheduler|
=== "Application & Analytics"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/app-rfid-llrp-inventory|edgex-app-rfid-llrp-inventory|edgex-app-rfid-llrp-inventory | app-rfid-llrp-inventory |
    |edgexfoundry/app-service-configurable|edgex-app-rules-engine|edgex-app-rules-engine | app-rules-engine|
    |edgexfoundry/app-service-configurable|edgex-app-http-export|edgex-app-http-export | app-http-export|
    |edgexfoundry/app-service-configurable|edgex-app-mqtt-export|edgex-app-mqtt-export | app-mqtt-export|
    |edgexfoundry/app-service-configurable|edgex-app-metrics-influxdb|edgex-app-metrics-influxdb | app-metrics-influxdb|
    |edgexfoundry/app-service-configurable|edgex-app-sample|edgex-app-sample | app-sample| 
    |edgexfoundry/app-service-configurable|edgex-app-external-mqtt-trigger|edgex-app-external-mqtt-trigger | app-external-mqtt-trigger|
    |emqx/kuiper|edgex-kuiper|edgex-kuiper|rulesengine|
=== "Device"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/device-virtual|edgex-device-virtual|edgex-device-virtual|device-virtual|
    |edgexfoundry/device-mqtt|edgex-device-mqtt|edgex-device-mqtt|device-mqtt|
    |edgexfoundry/device-rest|edgex-device-rest|edgex-device-rest|device-rest|
    |edgexfoundry/device-modbus|edgex-device-modbus|edgex-device-modbus|device-modbus|
    |edgexfoundry/device-snmp|edgex-device-snmp|edgex-device-snmp|device-snmp|
    |edgexfoundry/device-bacnet|edgex-device-bacnet|edgex-device-bacnet|device-bacnet|
    |edgexfoundry/device-onvif-camera|edgex-device-onvif-camera|edgex-device-onvif-camera|device-onvif-camera|
    |edgexfoundry/device-usb-camera|edgex-device-usb-camera|edgex-device-usb-camera|device-usb-camera|
    |edgexfoundry/device-coap|edgex-device-coap|edgex-device-coap|device-coap|
=== "Security"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |openbao|edgex-secret-store|edgex-secret-store|secret-store|
    |nginx|edgex-nginx|edgex-nginx|nginx|
    |edgexfoundry/security-proxy-auth|edgex-proxy-auth|edgex-proxy-auth|security-proxy-auth|
    |edgexfoundry/security-proxy-setup|edgex-security-proxy-setup|edgex-security-proxy-setup|security-proxy-setup|
    |edgexfoundry/security-secretstore-setup|edgex-security-secretstore-setup|edgex-security-secretstore-setup|security-secretstore-setup|
    |edgexfoundry/security-bootstrapper|edgex-security-bootstrapper|edgex-security-bootstrapper|security-bootstrapper|
=== "Miscellaneous"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |postgres|edgex-postgres|edgex-postgres|database|