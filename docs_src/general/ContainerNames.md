# EdgeX Container Names
The following table provides the list of the default EdgeX Docker image names to the Docker container name and Docker Compose names.

!!! edgey "EdgeX 2.0"
	For EdgeX 2.0 the EdgeX docker image names have been simplified and made consistent across all EdgeX services.

=== "Core"
    |Docker image name|Docker container name|Docker network hostname | Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/core-data|edgex-core-data|edgex-core-data|data|
    |edgexfoundry/core-metadata|edgex-core-metadata| edgex-core-metadata|metadata|
    |edgexfoundry/core-command|edgex-core-command| edgex-core-command | command|
=== "Supporting"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/support-notifications|edgex-support-notifications|edgex-support-notifications|notifications|
    |edgexfoundry/support-scheduler|edgex-support-scheduler|edgex-support-scheduler| scheduler|
=== "Application & Analytics"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |edgexfoundry/app-service-configurable|edgex-app-rules-engine|edgex-app-rules-engine | app-service-rules|
    |edgexfoundry/app-service-configurable|edgex-app-http-export|edgex-app-http-export | app-service-http-export|
    |edgexfoundry/app-service-configurable|edgex-app-mqtt-export|edgex-app-mqtt-export | app-service-mqtt-export|
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
    |edgexfoundry/device-camera|edgex-device-camera|edgex-device-camera|device-camera|
    |edgexfoundry/device-grove|edgex-device-grove|edgex-device-grove|device-grove|
    |edgexfoundry/device-coap|edgex-device-coap|edgex-device-coap|device-coap|
=== "Security"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |vault|edgex-vault|edgex-vault|vault|
    |postgress|edgex-kong-db|edgex-kong-db|kong-db|
    |kong|edgex-kong|edgex-kong|kong|
    |edgexfoundry/security-proxy-setup|edgex-security-proxy-setup|edgex-security-proxy-setup|proxy-setup|
    |edgexfoundry/security-secretstore-setup|edgex-security-secretstore-setup|edgex-security-secretstore-setup|secretstore-setup|
    |edgexfoundry/security-bootstrapper|edgex-security-bootstrapper|edgex-security-bootstrapper|security-bootstrapper|
=== "Miscellaneous"
    |Docker image name|Docker container name |Docker network hostname|Docker Compose service name|
    |---|---|---|---|
    |consul|edgex-core-consul|edgex-core-consul|consul|
    |redis|edgex-redis|edgex-redis|database|
    |edgexfoundry/sys-mgmt-agent|edgex-sys-mgmt-agent|edgex-sys-mgmt-agent|system|