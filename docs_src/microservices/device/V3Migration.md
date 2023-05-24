# V3 Migration Guide

## All Device Services

This section is specific to changes made that impact only and **all device services**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX Services.

### Device Files

TBD

### Device Profile Files

TBD

### Provision Watcher files

TBD

### Other

TBD

## Custom Device Services

This section is specific to changes made that impact existing **custom device services**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services.  

### Go Device Services

TBD

### C Device Services

TBD

## Supported Device Services

### Device MQTT

This section is specific to changes made only to **Device MQTT**. 

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services. 

#### Metadata in MQTT Topics

For EdgeX 3.0, Device MQTT now only supports the multi-level topics. Publishing the metadata and command/reading data wrapped in a JSON object is no longer supported. The published payload is now always only the reading data. 

!!! example - "Example V2 JSON object wrapper no longer used"

    ```json
    {
       "name": "<device-name>",
       "cmd": "<source-name>",
       "<source-name>": Base64 encoded JSON containing
    		{
              "<resource1>" : value1,
              "<resource2>" : value2,
              ...
            }
    }
    ```

Your MQTT based device(s) must be migrated to use this new approach. See below for more details.

##### Async Data

A sync data is published to the `incoming/data/{device-name}/{source-name}` topic where:

- **device-name** is the name of the device sending the reading(s)

- **source-name** is the command or resource name for the published data
    - If the **source-name** matches a command name the published data must be JSON object with the resource names specified in the command as field names.

        !!! example - "Example async published command data"
            Topic=`incoming/data/MQTT-test-device/allValues`
            ```json
            {
              "randfloat32" : 3.32,
              "randfloat64" : 5.64,
              "message" : "Hi World"
            }
            ```

    - If the **source-name** only matches a resource name the published data can either be just the reading value for the resource or a JSON object with the resource name as the field name.

        !!! example - "Example async published resource data"
            Topic=`incoming/data/MQTT-test-device/randfloat32`
            ```json
            5.67

            or
            
            {
              "randfloat32" : 5.67
            }
            ```

##### Commanding

Commands send to the device will be sent on the`command/{device-name}/{command-name}/{method}/{uuid}` topic where:

- **device-name** is the name of the device which will receive the command
- **command-name** is the name of the command being set to the device
- **method** is the type of command, `get` or `set`
- **uuid** is a unique identifier for the command request

###### Set Command

If the command method is a `set`, the published payload contains a JSON object with the resource names and the values to set those resources.

!!! example - "Example Data for Set Command"
    ```json
    {
       "randfloat32" : 3.32,
       "randfloat64" : 5.64
    }
    ```

The device is expected to publish an empty response to the topic `command/response/{uuid}` where **uuid** is the unique identifier sent in command request topic. 

###### Get Command

If the command method is a `get`, the published payload is empty and the device is expected to publish a response to the topic `command/response/{uuid}` where **uuid** is the unique identifier sent in command request topic. The published payload contains a JSON object with the resource names for the specified command and their values.

!!! example - "Example Response Data for Get Command"
    ```json
    {
       "randfloat32" : 3.32,
       "randfloat64" : 5.64,
       "message" : "Hi World"
    }
    ```

### Device ONVIF Camera

This section is specific to changes made only to **Device ONVIF Camera**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services.  

TBD

#### Configuration

TBD

#### Device Profile

TBD

### Device USB Camera

This section is specific to changes made only to **Device USB Camera**

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services. . 

TBD

#### Configuration

TBD

#### Device Profile

TBD

