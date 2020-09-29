# System Management Agent (SMA)

![image](../EdgeX_SystemManagement.png)

## Introduction

The SMA serves as the connection point of management control for an EdgeX instance.  

### Management Architecture

The SMA serves as the proxy for management requests.  Some management requests (metrics requests and operations to start, stop and restart services) are routed to an executor for execution.  Other requests (for service configuration) are routed to the services for a response.  Configuration information is only available by asking each service for its current configuration.  Metrics and operations (tasks to start, stop, restart) typically need to be performed by some other software that can perform the task best under the platform / deployment environment.  When running EdgeX in a Docker Engine, Docker can provide service metrics like memory and CPU usage to the requestor.  If EdgeX services were running non-containerized in a Linux environment, the request may be best performed by some Linux shell script or by sysd.  An executor encapsulates the implementation for the metrics gathering and start, stop, restart operations.  That implementation of the executor can vary based on OS, platform environment, etc.  EdgeX defines the system management executor interface and a reference implementation which utilizes Docker (for situations when EdgeX is run in Docker) to responsd to metrics and start, stop, and restart operations.

![image](../EdgeX_SysMgmtArch.png)

### Examples of API Calls

To get an appreciation for some SMA API calls in action, it is instructive to look at what responses the SMA provides to the caller,
for the respective calls.  The tabs below provide the API path and corresponding response for each of the system management capabilities.

!!! Info
    Notice, too, the error messages returned by the SMA, should it encounter a problem.

=== "Metrics of a service"

    Example request: /api/v1/metrics/edgex-core-command,edgex-core-data

    Corresponding response, in JSON format:

    ``` json
    {
    "Metrics":{
        "edgex-core-command":{
            "CpuBusyAvg":2.224995150836366,
            "Memory":{
                "Alloc":1403648,
                "Frees":1504,
                "LiveObjects":18280,
                "Mallocs":19784,
                "Sys":71891192,
                "TotalAlloc":1403648
            }
        },
        "edgex-core-data":{
            "CpuBusyAvg":2.854720153816541,
            "Memory":{
                "Alloc":929080,
                "Frees":1453,
                "LiveObjects":7700,
                "Mallocs":9153,
                "Sys":70451200,
                "TotalAlloc":929080
            }
        }
    }
    }
    ```

=== "Configuration of a service"

    Example request: /api/v1/config/device-simple,edgex-core-data

    Corresponding response, in JSON format:

    ``` json
    {
        "Configuration": {
            "device-simple": "device-simple service is not registered. Might not have started... ",
            "edgex-core-data": {
                "Clients": {
                    "Logging": {
                        "Host": "localhost",
                        "Port": 48061,
                        "Protocol": "http"
                    },
                    "Metadata": {
                        "Host": "localhost",
                        "Port": 48081,
                        "Protocol": "http"
                    }
                },
                "Databases": {
                    "Primary": {
                        "Host": "localhost",
                        "Name": "coredata",
                        "Password": "",
                        "Port": 27017,
                        "Timeout": 5000,
                        "Type": "mongodb",
                        "Username": ""
                    }
                },
                "Logging": {
                    "EnableRemote": false,
                    "File": "./logs/edgex-core-data.log"
                },
                "MessageQueue": {
                    "Host": "*",
                    "Port": 5563,
                    "Protocol": "tcp",
                    "Type": "zero"
                },
                "Registry": {
                    "Host": "localhost",
                    "Port": 8500,
                    "Type": "consul"
                },
                "Service": {
                    "BootTimeout": 30000,
                    "CheckInterval": "10s",
                    "ClientMonitor": 15000,
                    "Host": "localhost",
                    "Port": 48080,
                    "Protocol": "http",
                    "MaxResultCount": 50000,
                    "StartupMsg": "This is the Core Data Microservice",
                    "Timeout": 5000
                },
                "Writable": {
                    "DeviceUpdateLastConnected": false,
                    "LogLevel": "INFO",
                    "MetaDataCheck": false,
                    "PersistData": true,
                    "ServiceUpdateLastConnected": false,
                    "ValidateCheck": false
                }
            }
        }
    }
    ```

=== "Start a service"

    Example request: /api/v1/operation

    Example (POST) body accompanying the "start" request:

    ``` json
    {
    "action":"start",
    "services":[
        "edgex-core-data",
    ],
    "params":[
        "graceful"
        ]
    }
    ```

    Corresponding response, in JSON format, on success: "Done. Started the
    requested services."

    Corresponding response, in JSON format, on failure: "HTTP 500 -
    Internal Server Error"

=== "Stop a service"

    Example request: /api/v1/operation

    Example (POST) body accompanying the "stop" request:

    ``` json
    {
    "action":"stop",
    "services":[
        "edgex-support-notifications"
    ],
    "params":[
        "graceful"
        ]
    }
    ```

    Corresponding response, in JSON format, on success: "Done. Stopped the
    requested service."

    Corresponding response, in JSON format, on failure: "HTTP 500 -
    Internal Server Error"

=== "Restart a service"

    Example request: /api/v1/operation

    Example (POST) body accompanying the "restart" request:

    ``` json
    {
    "action":"restart",
    "services":[
        "edgex-support-notifications",
        "edgex-core-data",
    ],
    "params":[
        "graceful"
        ]
    }
    ```

    Corresponding response, in JSON format, on success: "Done. Restarted
    the requested services."

    Corresponding response, in JSON format, on failure: "HTTP 500 -
    Internal Server Error"

=== "Health check on a service"

    Example request:
    /api/v1/health/device-simple,edgex-core-data,support-notifications

    Corresponding response, in JSON format:

    ``` json
    {
        "device-simple": "device-simple service is not registered. Might not have started... ",
        "edgex-core-data": true,
        "support-notifications": true
    }
    ```

## Configuration Properties

Please refer to the general [Configuration documentation](../../configuration/Ch-Configuration.md#configuration-properties) for configuration properties common to all services.

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
[System Management API Reference](../../../api/Ch-APISystemManagement.md)