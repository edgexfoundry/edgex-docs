# C SDK

In this guide, you create a simple device service that generates a
random number as a means to simulate getting data from an actual device. In this way, you explore some of the SDK framework and work necessary to complete a device service without actually having a device to talk to.

## Install dependencies

See the [Getting Started - C Developers](./Ch-GettingStartedCDevelopers.md) guide to install the necessary tools and infrastructure needed to develop a C service.

## Get the EdgeX Device SDK for C

The next step is to download and build the EdgeX device service SDK for C.

1.  First, clone the device-sdk-c from Github:
    ``` bash
    git clone -b v2.0.0 https://github.com/edgexfoundry/device-sdk-c.git
    cd ./device-sdk-c
    ```

    ![image](EdgeX_GettingStartedSDKCloneC.png)

    !!! Note
        The clone command above has you pull v2.0.0 of the C SDK which is the version compatible with the Ireland release.

2.  Then, build the device-sdk-c:
    ``` bash
    make
    ```

## Starting a new Device Service

For this guide, you use the example template provided by the
C SDK as a starting point for a new device service.  You modify the device service to generate random integer
values.

Begin by copying the template example source into a new directory
    named `example-device-c`:
    ``` bash
    mkdir -p ../example-device-c/res/profiles
    mkdir -p ../example-device-c/res/devices
    cp ./src/c/examples/template.c ../example-device-c
    cd ../example-device-c
    ```

![image](EdgeX_GettingStartedSDKCopyFilesC.png)

## Build your Device Service

Now you are ready to build your new device service using the C SDK you
compiled in an earlier step.

1.  Tell the compiler where to find the C SDK files:
    ``` bash
    export CSDK_DIR=../device-sdk-c/build/release/_CPack_Packages/Linux/TGZ/csdk-2.0.0
    ```

    !!! Note
        The exact path to your compiled CSDK_DIR may differ depending on the tagged version number on the SDK.  The version of the SDK can be found in the VERSION file located in the ./device-sdk-c/VERSION file.  In the example above, the Ireland release of 2.0.0 is used.

2.  Now build your device service executable:

    ``` bash
    gcc -I$CSDK_DIR/include -L$CSDK_DIR/lib -o device-example-c template.c -lcsdk
    ```

    If everything is working properly, a `device-example-c` executable will be created in the directory.

    ![image](EdgeX_GettingStartedSDKCompileC.png)

## Customize your Device Service

Up to now you've been building the example device service provided by
the C SDK. In order to change it to a device service that generates
random numbers, you need to modify your `template.c` method
**template\_get\_handler**.  Replace the following code:

``` c
for (uint32_t i = 0; i < nreadings; i++)
{
    /* Log the attributes for each requested resource */
    iot_log_debug (driver->lc, "  Requested reading %u:", i);
    dump_attributes (driver->lc, requests[i].resource->attrs);
    /* Fill in a result regardless */
    readings[i].value = iot_data_alloc_string ("Template result", IOT_DATA_REF);
}
return true;
```

with this code:

``` c
for (uint32_t i = 0; i < nreadings; i++)
{
    const char *rdtype = iot_data_string_map_get_string (requests[i].resource->attrs, "type");
    if (rdtype)
    {
        if (strcmp (rdtype, "random") == 0)
        {
        /* Set the reading as a random value between 0 and 100 */
        readings[i].value = iot_data_alloc_i32 (rand() % 100);
        }
        else
        {
        *exception = iot_data_alloc_string ("Unknown sensor type requested", IOT_DATA_REF);
        return false;
        }
    }
    else
    {
        *exception = iot_data_alloc_string ("Unable to read value, no \"type\" attribute given", IOT_DATA_REF);
        return false;
    }
}
return true;
```

Here the reading value is set to a random signed integer. Various `iot_data_alloc_` functions are defined in the `iot/data.h` header allowing readings of different types to be generated.

## Creating your Device Profile

A device profile is a YAML file that describes a class of device to
EdgeX. General characteristics about the type of device, the data these devices provide, and how to command the device are all in a device profile.   The device profile tells the device service what data gets collected from the the device and how to get it. 

Follow these steps to create a device profile for the simple random number generating device service.

1.  Explore the files in the device-sdk-c/src/c/examples/res/profiles folder.   Note the example TemplateProfile.json device profile that is already in this folder.  Open the file with your favorite editor and explore its contents.  Note how `deviceResources` in the file represent properties of a device (properties like SensorOne, SensorTwo and Switch).

    ![image](EdgeX_SampleDeviceProfile_DeviceResourcesC.png)

2.  A pre-created device profile for the random number device is provided in this documentation.  This is supplied in the alternative file format .yaml. Download **[random-generator.yaml](random-generator.yaml)** and save the file to the `./res/profiles` folder.

3.  Open the random-generator.yaml file in a text editor. In this device profile, the device described has a deviceResource:  `RandomNumber`.  Note how the association of a type to the deviceResource.  In this case, the device profile informs EdgeX that `RandomNumber` will be a Int32.  In real world IoT situations, this deviceResource list could be extensive and filled with many deviceResources all different types of data.

## Creating your Device

Device Service accepts pre-defined devices to be added to EdgeX during device service startup.

Follow these steps to create a pre-defined device for the simple random number generating device service.

1.  Explore the files in the cmd/device-simple/res/devices folder.   Note the example simple-device.json that is already in this folder.  Open the file with your favorite editor and explore its contents.  Note how the file contents represent an actual device with its properties (properties like Name, ProfileName, AutoEvents).

2.  A pre-created device for the random number device is provided in this documentation.  Download **[random-generator-devices.yaml](random-generator-devices.yaml)** and save the file to the `~/edgexfoundry/device-simple/cmd/device-simple/res/devices` folder.

3.  Open the random-generator-devices.yaml file in a text editor. In this example, the device described has a profileName:  `RandNum-Device`.  In this case, the device informs EdgeX that it will be using the device profile we created in [Creating your Device Profile](./Ch-GettingStartedSDK-C.md#creating-your-device-profile)


## Configuring your Device Service

Now update the configuration for the new device service.    This documentation provides a new configuration.yaml file.  This configuration file:
- changes the port the service operates on so as not to conflict with other device services

Download  **[configuration.yaml](https://github.com/edgexfoundry/device-sdk-go/blob/{{version}}/example/cmd/device-simple/res/configuration.yaml)** and save the file to the ./res folder.

### Custom Structured Configuration

C Device Services support structured custom configuration as part of the `[Driver]` section in the configuration.yaml file.

View the `main` function of `template.c`. The `confparams` variable is initialized with default values for three test parameters. These values may be overridden by entries in the configuration file or by environment variables in the usual way. The resulting configuration is passed to the `init` function when the service starts.

Configuration parameters `X`, `Y/Z` and `Writable/Q` correspond to configuration file entries as follows:
```
[Writable]
  [Writable.Driver]
    Q = "foo"

[Driver]
  X = "bar"
  [Driver.Y]
    Z = "baz"
```

Entries in the writable section can be changed dynamically if using the registry; the `reconfigure` callback will be invoked with the new configuration when changes are made.

In addition to strings, configuration entries may be integer, float or boolean typed. Use the different `iot_data_alloc_` functions when setting up the defaults as appropriate.

## Rebuild your Device Service

Now you have your new device service, modified to return a random
number, a device profile that will tell EdgeX how to read that random
number, as well as a configuration file that will let your device
service register itself and its device profile with EdgeX, and begin
taking readings every 10 seconds.

Rebuild your Device Service to reflect the changes that you have made:

``` bash
gcc -I$CSDK_DIR/include -L$CSDK_DIR/lib -o device-example-c template.c -lcsdk
```

## Run your Device Service

Allow your newly created Device Service, which was formed out of the
Device Service C SDK, to create sensor mimicking data which it then
sends to EdgeX.

1.  Follow the [Getting Started using Docker](./Ch-GettingStartedDockerUsers.md) guide to start all of EdgeX. From
    the folder containing the docker-compose file, start EdgeX with the
    following call:

    ``` bash
    docker compose up -d
    ```

2.  Back in your custom device service directory, tell your device
    service where to find the `libcsdk.so`:

    ``` bash
    export LD_LIBRARY_PATH=$CSDK_DIR/lib
    ```

3.  Run your device service:

    ``` bash
    ./device-example-c
    ```

4.  You should now see your device service having its /Random command
    called every 10 seconds. You can verify that it is sending data into
    EdgeX by watching the logs of the `edgex-core-data`
    service:

    ``` bash
    docker logs -f edgex-core-data
    ```

    Which would print an event record every time your device service is called.

5.  You can manually generate an event using curl to query the device
    service directly:

    ``` bash
    curl 0:59992/api/{{api_version}}/device/name/RandNum-Device01/RandomNumber
    ```

6.  Using a browser, enter the following URL to see the event/reading
    data that the service is generating and sending to EdgeX:

    <http://localhost:59880/api/{{api_version}}/event/device/name/RandNum-Device01?limit=100>

    This request asks core data to provide the last 100 events/readings associated to the RandNum-Device-01.

