---
title: Device GPIO - Getting Started
---

# Device GPIO - Getting Started

!!! note
    Since GPIO `sysfs` interface is **deprecated after Linux version 4.8**, two ABI interfaces are provided: the `sysfs` version and the new `chardev` version. By default, the interface is set to `sysfs`. It can be changed inside the `Driver` section of the service's configuration. For the `chardev` interface, you need to specify a selected chip. This is also under `Driver` section. See the [Configuration](./Configuration.md) section for more details

## Running the Service

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty ds-gpio
    ```
    This runs, in non-secure mode, all the standard EdgeX services along with the Device GPIO service.

## Sample Device Profile and Devices

This service contains the following sample device profiles and devices:

| Device Profile                                                                                                                        | Device                                                                                                                               | Description                                 |
|---------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|
| [device.custom.gpio.yaml](https://github.com/edgexfoundry/device-gpio/blob/{{edgexversion}}/cmd/res/profiles/device.custom.gpio.yaml) | [device.custom.gpio.yaml](https://github.com/edgexfoundry/device-gpio/blob/{{edgexversion}}/cmd/res/devices/device.custom.gpio.yaml) | Example for GPIO with Power, LED and Switch |
| [device.led.gpio.yaml](https://github.com/edgexfoundry/device-gpio/blob/{{edgexversion}}/cmd/res/profiles/device.led.gpio.yaml)       | [device.led.gpio.yaml](https://github.com/edgexfoundry/device-gpio/blob/{{edgexversion}}/cmd/res/devices/device.led.gpio.yaml)      | Example for GPIO with just LED              |

The device profiles are used to describe the actual GPIO hardware of a device and allow individual GPIOs to be given human-readable names/aliases.

## Example walk-thru

The following are step-by-step examples of using this device service. In these examples, we use Core Command RESTful API to interact with EdgeX rather than directly interact with GPIO device service.

!!! example - "Example - Query Core Command for device `GPIO-Device01` commands"
    ```shell
    curl http://localhost:59882/api/v3/device/name/GPIO-Device01
    ```
    ```json
    {
        "apiVersion": "v2",
        "statusCode": 200,
        "deviceCoreCommand": {
            "deviceName": "GPIO-Device01",
            "profileName": "Custom-GPIO-Device",
            "coreCommands": [
                {
                    "name": "Power",
                    "get": true,
                    "set": true,
                    "path": "/api/v3/device/name/GPIO-Device01/Power",
                    "url": "http://edgex-core-command:59882",
                    "parameters": [
                        {
                            "resourceName": "Power",
                            "valueType": "Bool"
                        }
                    ]
                },
                {
                    "name": "LED",
                    "set": true,
                    "path": "/api/v3/device/name/GPIO-Device01/LED",
                    "url": "http://edgex-core-command:59882",
                    "parameters": [
                        {
                            "resourceName": "LED",
                            "valueType": "Bool"
                        }
                    ]
                },
                {
                    "name": "Switch",
                    "get": true,
                    "path": "/api/v3/device/name/GPIO-Device01/Switch",
                    "url": "http://edgex-core-command:59882",
                    "parameters": [
                        {
                            "resourceName": "Switch",
                            "valueType": "Bool"
                        }
                    ]
                }
            ]
        }
    }
    ```
Use the `curl` response to get the command URLs (with device and command ids) to issue commands to the GPIO device via the command service as shown above. You can also use a tool like `Postman` instead of `curl` to issue the same commands.

### Direction setting with sysfs
When using sysfs, the operations to access (read or write) the GPIO pins are:

1. Export the pin
2. Set the direction (either IN or OUT)
3. Read the pin input or write the pin value based on the direction
4. Unexport the pin 

When using sysfs, setting the direction causes the value to be reset.  Therefore, this implementation only sets the direction on opening the line to the GPIO.  After that, it is assumed the same direction is used while the pin is in use and exported.

The direction is set by an optional attribute in the device profile called `defaultDirection`.  It can be set to either "in" or "out".  If it is not set, the default direction is assumed to be "out".

!!! example - "Example - GPIO resource in device profile"
    ``` yaml
      -
        name: "LED"
        isHidden: false
        description: "mocking LED"
        attributes: { line: 27, defaultDirection: "out" }
        properties:
          valueType: "Bool"
          readWrite: "W"
    ```

!!! note
    The direction should not be confused with the device profile's read/write property.  If you set the defaultDirection to `in` but then set the readWrite property to `RW` or `W`, any attempt to write to the pin will result in a "permission denied" error.  For consistency, when your defaultDirection is `in` set readWrite to `R` only.

### Write value to GPIO
Assume a GPIO device (used for power enable) connected to gpio17 on current system of raspberry pi 4b. When a value is written to GPIO, this GPIO will give a high voltage.

!!! example - "Example - Set commands to set `Power` resource on `GPIO-Device01`"
    ```shell
    # Set the 'Power' GPIO to high
    $ curl -X PUT -d   '{"Power":"true"}' http://localhost:59882/api/v3/device/name/GPIO-Device01/Power
    {"apiVersion":"v2","statusCode":200}
    $ cat /sys/class/gpio/gpio17/direction ; cat /sys/class/gpio/gpio17/value
    out
    1
    
    # Set the 'Power' GPIO to low
    $ curl -X PUT -d   '{"Power":"false"}' http://localhost:59882/api/v3/device/name/GPIO-Device01/Power
    {"apiVersion":"v2","statusCode":200}
    $ cat /sys/class/gpio/gpio17/direction ; cat /sys/class/gpio/gpio17/value
    out
    0
    
    Now if you test gpio17 of raspberry pi 4b , it is outputting high voltage.
    ```

### Read value from GPIO
Assume another GPIO device (used for button detection) connected to pin 22 on current system. When a value is read from GPIO, this GPIO will be exported and set direction to input.

!!! example - "Example - GET command for `Switch` resource on `GPIO-Device01`"
    ```shell
    $ curl http://localhost:59882/api/v3/device/name/GPIO-Device01/Switch
    ```
    ```json
    {
      "apiVersion": "v2",
      "statusCode": 200,
      "event": {
        "apiVersion": "v2",
        "id": "a6104256-92a4-41a8-952a-396cd3dabe25",
        "deviceName": "GPIO-Device01",
        "profileName": "Custom-GPIO-Device",
        "sourceName": "Switch",
        "origin": 1634221479227566300,
        "readings": [
          {
            "id": "240dc2ea-d69f-4229-94c4-3ad0507cf657",
            "origin": 1634221479227566300,
            "deviceName": "GPIO-Device01",
            "resourceName": "Switch",
            "profileName": "Custom-GPIO-Device",
            "valueType": "Bool",
            "value": "false"
          }
        ]
      }
    }
    ```
