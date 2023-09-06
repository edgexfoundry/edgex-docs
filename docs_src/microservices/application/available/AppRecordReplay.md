# App Record and Replay

## Introduction

This service is a developer testing tool which will record Events from the EdgeX MessageBus and replay them back to the EdgeX MessageBus at a later time. The value of this is a session with devices present can be recorded for later replay on a system which doesn't have the required devices. This allows for testing of services that receive and process the Events without requiring the devices to be present. 

!!! note
    The source device service must be running when data is imported since the devices and device profiles are captured 
    as part of the recorded data will be added to the system during import.


## Storage

Since this is targeted as a developer testing tool, the storage model is kept simple by using in-memory storage for the recorded data. This should be kept in mind when recording or importing a recoding on systems with limited resources.

## REST API

Control of this service is accomplished via the following REST API. 

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/app-record-replay/{{edgexversionmain}}/openapi/{{api_version}}/app-record-replay.yaml"/>

## Postman Collection

A sample Postman collection can be found [here](https://github.com/edgexfoundry/app-record-replay/blob/{{edgexversionmain}}/Record%20and%20Reply.postman_collection.json).

!!! note
    Use the Postman `Send and Download` option for the `Export recording - JSON` request so that the response can be saved to file. The `Send and Download` option is on the `Send` button.

!!! note
    Postman automatically un-compresses the responses when requesting GZIB or ZLIB compression. Use the following curl command to save the compressed response to file.
    
    ```text
    curl localhost:59712/api/{{api_version}}/data?compression=gzip -o test.gz
    curl localhost:59712/api/{{api_version}}/data?compression=zlib -o test.zlib
    ```
