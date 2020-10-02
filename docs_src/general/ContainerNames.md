# EdgeX Container Names
The following table provides the list of the default EdgeX Docker image names to the Docker container name and Docker Compose names.

=== "Core"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |docker-core-data-go|edgex-core-data|data|
    |docker-core-metadata-go|edgex-core-metadata|metadata|
    |docker-core-command-go|edgex-core-command|command|
=== "Supporting"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |docker-support-notifications-go|edgex-support-notifications|notifications|
    |docker-support-logging-go|edgex-support-logging|logging|
    |docker-support-scheduler-go|edgex-support-scheduler|scheduler|
=== "Application & Analytics"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |docker-app-service-configurable|edgex-app-service-configurable-rules|app-service-rules|
    |emqx/kuiper|edgex-kuiper|rulesengine|
=== "Device"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |docker-device-virtual-go|edgex-device-virtual|device-virtual|
    |docker-device-random-go|edgex-device-random|device-random|
    |docker-device-mqtt-go|edgex-device-mqtt|device-mqtt|
    |docker-device-rest-go|edgex-device-rest|device-rest|
    |docker-device-modbus-go|edgex-device-modbus|device-modbus|
    |docker-device-snmp-go|edgex-device-snmp|device-snmp|
=== "Security"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |vault|edgex-vault|vault|
    |postgress|kong-db|kong-db|
    |kong|kong|kong|
    |docker-edgex-security-proxy-setup-go|edgex-proxy|edgex-proxy|
=== "Miscellaneous"
    |Docker image name|Docker container name|Docker Compose service name|
    |---|---|---|
    |docker-edgex-consul|edgex-core-consul|consul|
    |mongo|edgex-mongo|mongo|
    |redis|edgex-redis|redis|
    |docker-sys-mgmt-agent-go|edgex-sys-mgmt-agent|system|