---
title: Device MQTT - Configuration
---

# Device MQTT - Configuration

MQTT Device Service has the following configurations to implement the MQTT protocol.

| Configuration                                 | Default Value                      | Description                                                                                                         |
|-----------------------------------------------|------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| MQTTBrokerInfo.Schema                         | tcp                                | The URL schema                                                                                                      |
| MQTTBrokerInfo.Host                           | localhost                          | The URL host                                                                                                        |
| MQTTBrokerInfo.Port                           | 1883                               | The URL port                                                                                                        |
| MQTTBrokerInfo.Qos                            | 0                                  | Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once)                                          |
| MQTTBrokerInfo.KeepAlive                      | 3600                               | Seconds between client ping when no active data flowing to avoid client being disconnected. Must be greater then 2  |
| MQTTBrokerInfo.ClientId                       | device-mqtt                        | ClientId to connect to the broker with                                                                              |
| MQTTBrokerInfo.CredentialsRetryTime           | 120                                | The retry times to get the credential                                                                               |
| MQTTBrokerInfo.CredentialsRetryWait           | 1                                  | The wait time(seconds) when retry to get the credential                                                             |
| MQTTBrokerInfo.ConnEstablishingRetry          | 10                                 | The retry times to establish the MQTT connection                                                                    |
| MQTTBrokerInfo.ConnRetryWaitTime              | 5                                  | The wait time(seconds) when retry to establish the MQTT connection                                                  |
| MQTTBrokerInfo.AuthMode                       | none                               | Indicates what to use when connecting to the broker. Must be one of "none" , "usernamepassword"                     |
| MQTTBrokerInfo.CredentialsPath                | credentials                        | Name of the path in secret provider to retrieve your secrets. Must be non-blank.                                    |
| MQTTBrokerInfo.IncomingTopic                  | DataTopic (incoming/data/#)        | IncomingTopic is used to receive the async value                                                                    |
| MQTTBrokerInfo.ResponseTopic                  | ResponseTopic (command/response/#) | ResponseTopic is used to receive the command response from the device                                               |
| MQTTBrokerInfo.UseTopicLevels                 | false (true)                       | Boolean setting to use multi-level topics                                                                           |
| MQTTBrokerInfo.Writable.ResponseFetchInterval | 500                                | ResponseFetchInterval specifies the retry interval(milliseconds) to fetch the command response from the MQTT broker |

!!! note
    **Using Multi-level Topic:** Remember to change the defaults in parentheses in the table above.

## Overriding with Environment Variables

The user can override any of the above configurations using  `environment:`  variables in the compose file to meet their requirement, for example:

```yaml
# docker-compose.override.yml

  version: '3.7'

  services:
    device-mqtt:
      environment:
        MQTTBROKERINFO_CLIENTID: "my-device-mqtt"
        MQTTBROKERINFO_CONNRETRYWAITTIME: "10"
        MQTTBROKERINFO_USETOPICLEVELS: "false"
```