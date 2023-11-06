---
title: Device MQTT - Multi-Level Topics
---

# Device MQTT - Multi-Level Topics

In multi-level topics, the data in the published payload is the reading data. The names of the device and source are embedded into the topic. There are two ways multi-level topics are supported - async data and commands.

## Async Data

Asynchronous data is published to the topic `incoming/data/{device-name}/{source-name}` where:

- **device-name** is the name of the device sending the reading(s)
- **source-name** is the command or resource name for the published data

  - In the case where the **source-name** matches a **command** name, the published data must be a JSON object with the resource names specified in the command as field names.

    !!! example - "Example async published command data"
        Topic = `incoming/data/MQTT-test-device/allValues`
        ```json
        {
          "randfloat32" : 3.32,
          "randfloat64" : 5.54,
          "message"     : "Hi World"
        }
        ```

  - In the case where the **source-name** only matches a **resource** name, the published data can either be just the reading value for the resource or a JSON object with the resource name as the field name.

    !!! example - "Example async published resource data"
        Topic = `incoming/data/MQTT-test-device/randfloat32`
        ```json
        5.67
        ```
        or
        ```json
        {
        "randfloat32" : 5.67
        }
        ```

## Commanding

Commands sent to the device will be sent on the topic `command/{device-name}/{command-name}/{method}/{uuid}` where:

- **device-name** is the name of the device that will receive the command
- **command-name** is the name of the command being sent to the device
- **method** is the type of command, either `get` or `set`
- **uuid** is the unique identifier for the command request

### Set Command

If the command method is a `set`, then the published payload contains a JSON object with the resource names and the values to set those resources. In response, the device is expected to publish an empty response on the topic `command/response/{uuid}` where the **uuid** matches the unique identifier sent in the command request topic.

!!! example - "Example - Set Command"
    Publish Topic = `command/MQTT-test-device/randfloats/set/123`
    Publish Payload
    ```json
    {
      "randfloat32" : 3.32,
      "randfloat64" : 5.54
    }
    ```
    Response Topic = `command/response/123`
    Response Payload = `{}`

### Get Command

If the command method is a `get`, then the published payload is empty and the device is expected to publish a response to the topic `command/response/{uuid} where the **uuid** is the unique identifier sent in the command request topic. The published payload contains a JSON object with the resource names for the specified command and their values.

!!! example - "Example - Set Command"
    Publish Topic = `command/MQTT-test-device/randfloats/set/123`
    Publish Payload: `{}`
    Response Topic = `command/response/123`
    Response Payload
    ```json
    {
      "randfloat32" : 3.32,
      "randfloat64" : 5.54,
      "message"     : "Hi World"
    }
    ```