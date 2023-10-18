---
title: App Record Replay - API Reference
---

# App Record and Replay - API Reference

Control of this service is accomplished via the following REST API. In addition, 
this service does inherit the [common APIs](../../../../api/Ch-APIIntroduction.md/) and 
the [Trigger API](../../Triggers.md/#http-trigger) from the SDK.


<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/app-record-replay/{{edgexversion}}/openapi/{{api_version}}/app-record-replay.yaml"/>

## Postman Collection

A sample Postman collection can be found [here](https://github.com/edgexfoundry/app-record-replay/blob/{{edgexversion}}/Record%20and%20Reply.postman_collection.json).

!!! note
    Use the Postman `Send and Download` option for the `Export recording - JSON` request so that the response can be saved to file. The `Send and Download` option is on the `Send` button.

!!! note
    Postman automatically decompresses the responses when requesting GZIB or ZLIB compression. Use the following curl command to save the compressed response to file.

    ```text
    curl localhost:59712/api/{{api_version}}/data?compression=gzip -o test.gz
    curl localhost:59712/api/{{api_version}}/data?compression=zlib -o test.zlib
    ```
