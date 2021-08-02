# System Management Agent (SMA)

![image](../EdgeX_SystemManagement.png)
!!! Warning
    The System Management services (inclusive of the Agent) are deprecated with the Ireland (EdgeX 2.0) release.  See the notes on the [System Management Microservice](../Ch_SystemManagement.md) page.  Use this functionality with caution.

## Introduction

The SMA serves as the connection point of management control for an EdgeX instance.  

### Management Architecture

The SMA serves as the proxy for management requests.  Some management requests (metrics requests and operations to start, stop and restart services) are routed to an executor for execution.  Other requests (for service configuration) are routed to the services for a response.  Configuration information is only available by asking each service for its current configuration.  Metrics and operations (tasks to start, stop, restart) typically need to be performed by some other software that can perform the task best under the platform / deployment environment.  When running EdgeX in a Docker Engine, Docker can provide service metrics like memory and CPU usage to the requestor.  If EdgeX services were running non-containerized in a Linux environment, the request may be best performed by some Linux shell script or by sysd.  An executor encapsulates the implementation for the metrics gathering and start, stop, restart operations.  That implementation of the executor can vary based on OS, platform environment, etc.  EdgeX defines the system management executor interface and a reference implementation which utilizes Docker (for situations when EdgeX is run in Docker) to responsd to metrics and start, stop, and restart operations.

![image](../EdgeX_SysMgmtArch.png)

### Examples of API Calls

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the SMA API URIs, request body and request response all have considerable changes.

To get an appreciation for some SMA API calls in action, it is instructive to look at what responses the SMA provides to the caller,
for the respective calls.  The tabs below provide the API path and corresponding response for each of the system management capabilities.

!!! Info
    Consult the API Swagger documentation for status codes and message information returned by the SMA in error situations.

=== "Metrics of a service"

    Example request: /api/v2/system/metrics?services=core-command,core-data

    Corresponding response, in JSON format:

    ``` json
    [
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "core-command",
            "metrics": {
                "cpuUsedPercent": 0.01,
                "memoryUsed": 7524581,
                "raw": {
                    "block_io": "7.18MB / 0B",
                    "cpu_perc": "0.01%",
                    "mem_perc": "0.05%",
                    "mem_usage": "7.176MiB / 15.57GiB",
                    "net_io": "192kB / 95.4kB",
                    "pids": "13"
                }
            }
        },
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "core-data",
            "metrics": {
                "cpuUsedPercent": 0.01,
                "memoryUsed": 9142534,
                "raw": {
                    "block_io": "10.8MB / 0B",
                    "cpu_perc": "0.01%",
                    "mem_perc": "0.05%",
                    "mem_usage": "8.719MiB / 15.57GiB",
                    "net_io": "1.24MB / 1.49MB",
                    "pids": "13"
                }
            }
        }
    ]
    ```

=== "Configuration of a service"

    Example request: /api/v2/system/config?services=core-command,core-data

    Corresponding response, in JSON format:

    ``` json
    [
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "core-command",
            "config": {
                "apiVersion": "v2",
                "config": {
                    "Clients": {
                        "core-metadata": {
                            "Host": "edgex-core-metadata",
                            "Port": 59881,
                            "Protocol": "http"
                        }
                    },
                    "Databases": {
                        "Primary": {
                            "Host": "edgex-redis",
                            "Name": "metadata",
                            "Port": 6379,
                            "Timeout": 5000,
                            "Type": "redisdb"
                        }
                    },
                    "Registry": {
                        "Host": "edgex-core-consul",
                        "Port": 8500,
                        "Type": "consul"
                    },
                    "SecretStore": {
                        "Authentication": {
                            "AuthToken": "",
                            "AuthType": "X-Vault-Token"
                        },
                        "Host": "localhost",
                        "Namespace": "",
                        "Path": "core-command/",
                        "Port": 8200,
                        "Protocol": "http",
                        "RootCaCertPath": "",
                        "ServerName": "",
                        "TokenFile": "/tmp/edgex/secrets/core-command/secrets-token.json",
                        "Type": "vault"
                    },
                    "Service": {
                        "HealthCheckInterval": "10s",
                        "Host": "edgex-core-command",
                        "MaxRequestSize": 0,
                        "MaxResultCount": 50000,
                        "Port": 59882,
                        "RequestTimeout": "45s",
                        "ServerBindAddr": "",
                        "StartupMsg": "This is the Core Command Microservice"
                    },
                    "Writable": {
                        "InsecureSecrets": {
                            "DB": {
                                "Path": "redisdb",
                                "Secrets": {
                                    "password": "",
                                    "username": ""
                                }
                            }
                        },
                        "LogLevel": "INFO"
                    }
                }
            }
        },
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "core-data",
            "config": {
                "apiVersion": "v2",
                "config": {
                    "Clients": {
                        "core-metadata": {
                            "Host": "edgex-core-metadata",
                            "Port": 59881,
                            "Protocol": "http"
                        }
                    },
                    "Databases": {
                        "Primary": {
                            "Host": "edgex-redis",
                            "Name": "coredata",
                            "Port": 6379,
                            "Timeout": 5000,
                            "Type": "redisdb"
                        }
                    },
                    "MessageQueue": {
                        "AuthMode": "usernamepassword",
                        "Host": "edgex-redis",
                        "Optional": {
                            "AutoReconnect": "true",
                            "ClientId": "core-data",
                            "ConnectTimeout": "5",
                            "KeepAlive": "10",
                            "Password": "",
                            "Qos": "0",
                            "Retained": "false",
                            "SkipCertVerify": "false",
                            "Username": ""
                        },
                        "Port": 6379,
                        "Protocol": "redis",
                        "PublishTopicPrefix": "edgex/events/core",
                        "SecretName": "redisdb",
                        "SubscribeEnabled": true,
                        "SubscribeTopic": "edgex/events/device/#",
                        "Type": "redis"
                    },
                    "Registry": {
                        "Host": "edgex-core-consul",
                        "Port": 8500,
                        "Type": "consul"
                    },
                    "SecretStore": {
                        "Authentication": {
                            "AuthToken": "",
                            "AuthType": "X-Vault-Token"
                        },
                        "Host": "localhost",
                        "Namespace": "",
                        "Path": "core-data/",
                        "Port": 8200,
                        "Protocol": "http",
                        "RootCaCertPath": "",
                        "ServerName": "",
                        "TokenFile": "/tmp/edgex/secrets/core-data/secrets-token.json",
                        "Type": "vault"
                    },
                    "Service": {
                        "HealthCheckInterval": "10s",
                        "Host": "edgex-core-data",
                        "MaxRequestSize": 0,
                        "MaxResultCount": 50000,
                        "Port": 59880,
                        "RequestTimeout": "5s",
                        "ServerBindAddr": "",
                        "StartupMsg": "This is the Core Data Microservice"
                    },
                    "Writable": {
                        "InsecureSecrets": {
                            "DB": {
                                "Path": "redisdb",
                                "Secrets": {
                                    "password": "",
                                    "username": ""
                                }
                            }
                        },
                        "LogLevel": "INFO",
                        "PersistData": true
                    }
                }
            }
        }
    ]
    ```

=== "Start a service"

    Example request: /api/v2/system/operation

    Example (POST) body accompanying the "start" request:

    ``` json
    [{
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "apiVersion": "v2",
    "action": "start",
    "serviceName": "core-data"
    }]
    ```

    Corresponding response, in JSON format, on success:
    
    ``` json
    [{"apiVersion":"v2","requestId":"e6e8a2f4-eb14-4649-9e2b-175247911369","statusCode":200,"serviceName":"core-data"}]
    ```

=== "Stop a service"

    Example request: /api/v2/system/operation

    Example (POST) body accompanying the "stop" request:

    ``` json
    [{
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "apiVersion": "v2",
    "action": "stop",
    "serviceName": "core-data"
    }]
    ```

    Corresponding response, in JSON format, on success: 
    
    ``` json
    [{"apiVersion":"v2","requestId":"e6e8a2f4-eb14-4649-9e2b-175247911369","statusCode":200,"serviceName":"core-data"}]
    ```

=== "Restart a service"

    Example request: /api/v2/system/operation

    Example (POST) body accompanying the "restart" request:

    ``` json
    [{
    "requestId": "e6e8a2f4-eb14-4649-9e2b-175247911369",
    "apiVersion": "v2",
    "action": "restart",
    "serviceName": "core-data"
    }]
    ```

    Corresponding response, in JSON format, on success: 

    ``` json
    [{"apiVersion":"v2","requestId":"e6e8a2f4-eb14-4649-9e2b-175247911369","statusCode":200,"serviceName":"core-data"}]
    ```

=== "Health check on a service"

    Example request:
    /api/v2/system/health?services=device-virtual,core-data

    Corresponding response, in JSON format:

    ``` json
    [
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "device-virtual"
        },
        {
            "apiVersion": "v2",
            "statusCode": 200,
            "serviceName": "core-data"
        }
    ]
    ```

## Configuration Properties

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the Writable.ResendLimit Service.FormatSpecifier for metrics data output have been removed.

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration properties common to all services.

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||Writable properties can be set and will dynamically take effect without service restart|
    |ResendLimit|2|Number of attempts to perform a system management operation before raising an error|
=== "General"
    |Property|Default Value|Description|
    |---|---|---|
    |||general system management configuration properties|
    |ExecutorPath|'../sys-mgmt-executor/sys-mgmt-executor'|path to the executor to use for system management requests other than configuration|
    |MetricsMechanism|'direct-service'|either direct-service or executor to advise the SMA where to go for service metrics information|
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    |||these keys represent the system management service configuration settings|
    |FormatSpecifier|'%(\\d+\\$)?([-#+ 0(\\<]*)?(\\d+)?(\\.\\d+)?([tT])?([a-zA-Z%])'|metrics data output format specifier|

## API Reference
[System Management API Reference](../../../api/management/Ch-APISystemManagement.md)