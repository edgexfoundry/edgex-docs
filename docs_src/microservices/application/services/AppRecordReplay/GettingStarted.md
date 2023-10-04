# App Record and Replay

## Getting Started

### Overview

When using the  App Record and Replay service the following EdgeX services are required to be running:

1. Source device service(s). These are the device service(s) generating the events that will be recorded. 
    - This guide uses Device Virtual as the source device service. In a real use case the source device service(s) will be connected to actual devices. 
2. Core EdgeX services
3. Application or Supporting service that will process the Events
    - This guide uses the standard App Rules Engine as the app service which is processing the events.

### Running Services

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window 

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty ds-virtual as-record-replay
    ```

This runs, in non-secure mode, all the standard EdgeX services along with the Device Virtual and App Record Replay services.  App Rules Engine is part of the standard services and is used in this guide for processing the events.

### Postman

A sample Postman collection is provided to simplify controlling this service via its REST API. See the [Postman Collection](../ApiReference/#postman-collection) section for more details.

### Debug Logging

Optionally, the debug logging can be enabled on the **App Record Replay** service. This is accomplished by setting `LogLevel` value via the Consul UI at [http://localhost:8500/ui/dc1/kv/edgex/v3/app-record-replay/Writable/LogLevel/edit](http://localhost:8500/ui/dc1/kv/edgex/v3/app-record-replay/Writable/LogLevel/edit) to `DEBUG`

App service debug logging is very verbose, so when viewing the logs for this service, it is useful to filter the log messages for those that start with "ARR ". If you are using **Portainer** to view the service logs, simply place the "ARR " text in the `search` text box.

To see that the replayed events are being "processed" we also need to enable debug logging for **App Rules Engine**. Set the `LogLevel` value via the Consul UI at [http://localhost:8500/ui/dc1/kv/edgex/v3/app-rules-engine/Writable/LogLevel/edit](http://localhost:8500/ui/dc1/kv/edgex/v3/app-rules-engine/Writable/LogLevel/edit) to `DEBUG`

For **App Rules Engine** we want to filter for messages showing the events received. Filtering the log messages for "match the incoming topic" text will accomplish this.

### Recording a Session

#### Start a Recording

Before starting a recording session first review the **Start Recording** POST API in the [API Reference](ApiReference.md) section. Be sure to view both examples.

The source device service(s) need to be producing events prior to or shortly after the recording is starting. In this guide, Device Virtual is already producing events. So all that is need is to start the recording session by using the `Start Recording` request from the Postman collection referenced above. Edit the `RecordRequest` to set the `duration` and/or `eventLimit` and optionally any of the filters. The existing example filters can be removed so that all events are recorded.

After above is completed simply press `Send` in Postman to start the recording session .

!!! example - "Example Debug Messages for Recording Session"
    ```
    level=DEBUG ts=2023-10-02T18:21:36.311518009Z app=app-record-replay source=manager.go:116 msg="ARR Start Recording: Filter for profile names [Random-Integer-Device Random-Float-Device Random-UnsignedInteger-Device] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311552809Z app=app-record-replay source=manager.go:122 msg="ARR Start Recording: Filter out profile names [Random-Binary-Device Random-Boolean-Device] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311561009Z app=app-record-replay source=manager.go:128 msg="ARR Start Recording: Filter for device names [Random-Float-Device Random-Integer-Device Random-UnsignedInteger-Device] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311565609Z app=app-record-replay source=manager.go:134 msg="ARR Start Recording: Filter out device names [Random-Binary-Device Random-Boolean-Device] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311570208Z app=app-record-replay source=manager.go:140 msg="ARR Start Recording: Filter for source names [UInt8 Int8 Float32] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311574708Z app=app-record-replay source=manager.go:146 msg="ARR Start Recording: Filter out source names [UInt16 Int16 Float64] function added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311581508Z app=app-record-replay source=manager.go:170 msg="ARR Start Recording: CountEvents, Batch and ProcessBatchedData functions added to the functions pipeline"
    level=DEBUG ts=2023-10-02T18:21:36.311655007Z app=app-record-replay source=manager.go:181 msg="ARR Start Recording: Recording of Events has started with EventLimit=10 and Duration=1m0s"
    level=DEBUG ts=2023-10-02T18:21:42.25263302Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 1"
    level=DEBUG ts=2023-10-02T18:21:42.329114999Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 2"
    level=DEBUG ts=2023-10-02T18:21:57.336936895Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 3"
    level=DEBUG ts=2023-10-02T18:22:12.253729459Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 4"
    level=DEBUG ts=2023-10-02T18:22:12.335495342Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 5"
    level=DEBUG ts=2023-10-02T18:22:27.337831668Z app=app-record-replay source=manager.go:651 msg="ARR Event Count: received event to be recorded. Current event count is 6"
    level=DEBUG ts=2023-10-02T18:22:42.254128347Z app=app-record-replay source=manager.go:673 msg="ARR Process Recorded Data: Recording of Events has ended and functions pipeline has been removed"
    level=DEBUG ts=2023-10-02T18:22:42.254513348Z app=app-record-replay source=manager.go:696 msg="ARR Process Recorded Data: 6 events in 1m5.942835741s have been saved for replay"
    ```

!!! warning
    Since the storage model is simple in-memory storage, restarting the service will result in loss of recorded data. See [Export a Recorded Session](#export-a-recorded-session) section below for details on how to save recoded data for later usage.

#### Check Recording Status

The status of a recording session can be checked while it is running or after is has completed. Review the **Recording Status** GET API in the [API Reference](ApiReference.md) section and use the **Recording Status** request from the Postman collection referenced above. Press `Send` in Postman to get the recording status.

!!! example - "Example Recording Status responses"
    ```json
    
    Recording currently running response:
    {
        "inProgress": true,
        "eventCount": 1,
        "duration": 10057080770
    }
    
    Recording completed response:
    {
        "inProgress": false,
        "eventCount": 6,
        "duration": 65942835741
    }
    ```

#### Cancel Recording 

A recording session can be canceled while it is running. Review the **Cancel Recording** DELETE API in the [API Reference](ApiReference.md) section and use the **Cancel Recording** request from the Postman collection referenced above. Press `Send` in Postman to cancel the recording session.

!!! note
    This API will return a **202 - Accepted** response if the recording can be canceled, otherwise it will return an error such as "***failed to cancel recording: no recording currently running***"

### Replaying a Session

#### Start Replay

To start a replay session first review the **Start Replay** POST API in the [API Reference](ApiReference.md) section and then use the `Start Replay` request from the Postman collection referenced above. 

Set the `replayRate` to desired value. Value must be greater than zero. Values less than 1 replay slower and values greater than 1 replay faster than originally recorded. Value of 1 replays at the originally recorded rate.

!!! warning
    Actual replay rates are not exact and will vary depending on OS load.

Optionally set the `repeatCount` which determines how many times to replay the recorded session. Defaults to once if not set or set to 0.

The source device services should be stopped from producing any new events prior to starting the replay session. In a real use case where the devices are no longer available, the device service(s) would not have any actual devices connected to generate events. In this guide we simply stop the **Device Virtual** container, which can be done from Portainer or with a docker CLI command.

!!! example - "Example stopping Device Virtual container"
    ```
    docker stop edgex-device-virtual
    ```

After above is completed simply press `Send` in Postman to start the replay session .

#### Check Replay Status

The status of a replay session can be checked while it is running or after is has completed. Review the **Replay Status** GET API in the [API Reference.md](ApiReference) section and use the **Replay Status** request from the Postman collection referenced above. Press `Send` in Postman to get the replay status.

!!! note
    This API will always return a **202 - Accepted** response. If there were issues with the replay, the message field will contain the reason.

!!! example - "Example Replay Status responses"
    ```json
    Replay currently running response:
    {
        "running": true,
        "eventCount": 5,
        "duration": 2773407921,
        "repeatCount": 0,
        "Message": ""
    }
    
    ```

    Replay completed response:
    {
        "running": false,
        "eventCount": 20,
        "duration": 20015604050,
        "repeatCount": 2,
        "Message": ""
    }
    
    Replay canceled response::
    {
        "running": false,
        "eventCount": 2,
        "duration": 0,
        "repeatCount": 0,
        "Message": "replay canceled"
    }
    
    No Replay response:
    {
        "running": false,
        "eventCount": 0,
        "duration": 0,
        "repeatCount": 0,
        "Message": "no replay running or previously run"
    }
    ```

#### Cancel Replay

A replay session can be canceled while it is running. Review the **Cancel Replay** DELETE API in the [API Reference](ApiReference.md) section and use the **Cancel Replay** request from the Postman collection referenced above. Press `Send` in Postman to cancel the replay session.

!!! note
    This API will return a **202 - Accepted** response if the replay can be canceled, otherwise it will return an error such as "***failed to cancel replay: no replay currently running***"

### Export a Recorded Session

The current recorded session can be exported so that data can be saved to the file system. Review the **Export** GET API in the [API Reference](ApiReference.md) section and use the **Export Recording** requests from the Postman collection referenced above.

This API exports all the events, related devices and device profiles. It has an optional `compression` query parameter. Valid values are `none`, `gzip` and `zlib` . Defaults to `none` if not specified. 

!!! note
    Use the Postman `Send and Download` option for the `Export recording - JSON` request so that the response can be saved to file. The `Send and Download` option is on the `Send` button.

!!! note
    Postman automatically will decompress the responses when requesting GZIB or ZLIB compression. Use the following curl commands to save the compressed response to file.
    
    ```text
    curl localhost:59712/api/{{api_version}}/data?compression=gzip -o recording.gz
    curl localhost:59712/api/{{api_version}}/data?compression=zlib -o recording.zlib
    ```

### Import a Record Session

This API allows a previously exported recording to be imported back into the service. Review the **Import** POST API in the [API Reference](ApiReference.md) section and use the **Import Recording** requests from the Postman collection referenced above.

This API has a the optional `overwrite` query parameter, which specifies to overwrite existing Devices and Device Profiles or not. Defaults to true if not set.

!!! note
    Only one recording is save in memory at a time. Importing will overwrite the current recoding if one exists.

!!! warning
    The source device service(s) must be running will importing and the `overwite` parameter above is `true`. This is because the device service(s) are sent messages when the devices and profiles in the imported data are added to the system.
