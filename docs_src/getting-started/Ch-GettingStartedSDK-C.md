# C SDK

# Golang SDK

In this guide, you create a simple device service that generates a
random number as a means to simulate getting getting data from an actual device. In this way, you explore some the SDK framework and work necessary to complete a device service without actually having a device to talk to.

## Install dependencies

See the [Getting Started - C Developers](Ch-GettingStartedCDevelopers) guide to install the necessary tools and infrastructure needed to develop a GoLang service.

## Get the EdgeX Device SDK for C

The next step is to download and build the EdgeX device service SDK for C.

1.  First, clone the device-sdk-c from Github:
    ``` bash
    git clone https://github.com/edgexfoundry/device-sdk-c.git
    cd ./device-sdk-c
    ```

2.  Then, build the device-sdk-c:
    ``` bash
    make
    ```

## Starting a new Device Service

For this guide we're going to use the example template provided by the
C SDK as a starting point, and will modify it to generate random integer
values.

1.  Begin by copying the template example source into a new directory
    named `example-device-c`:
    ``` bash
    mkdir -p ../example-device-c/res
    cp ./src/c/examples/template.c ../example-device-c
    cd ../example-device-c
    ```

## Build your Device Service

Now you are ready to build your new device service using the C SDK you
compiled in an earlier step.

1.  Tell the compiler where to find the C SDK files:
    ``` bash
    export CSDK_DIR=../device-sdk-c/build/release/_CPack_Packages/Linux/TGZ/csdk-1.3.0
    ```

!!! Note
    The exact path to your compiled CSDK_DIR may differ, depending on the tagged version number on the SDK.  The version of the SDK can be found in the VERSION file located in the ./device-sdk-c/VERSION file.

2.  Now you can build your device service executable:

        gcc -I$CSDK_DIR/include -L$CSDK_DIR/lib -o device-example-c template.c -lcsdk

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
    dump_attributes (driver->lc, requests[i].attributes);
    /* Fill in a result regardless */
    readings[i].value = iot_data_alloc_string ("Template result", IOT_DATA_REF);
  }
  return true;
```

so that it reads as follows:

``` c
    for (uint32_t i = 0; i < nreadings; i++)
    {
        const edgex_nvpairs * current = requests[i].attributes;
        while (current!=NULL)
        {
            if (strcmp (current->name, "type") ==0 )
            {
                /* Set the resulting reading type as Uint64 */
                readings[i].type = Uint64;

                if (strcmp (current->value, "random") ==0 )
                {
                    /* Set the reading as a random value between 0 and 100 */
                    readings[i].value.ui64_result = rand() % 100;
                }
            }
            current = current->next;
        }
    }
    return true;
```

## Creating your Device Profile

A Device Profile is a YAML file that describes a class of device to
EdgeX. General characteristics about the type of device, the data these
devices provide, and how to command the device is all provided in a
Device Profile. Device Services use the Device Profile to understand
what data is being collected from the Device (in some cases providing
information used by the Device Service to know how to communicate with
the device and get the desired sensor readings). A Device Profile is
needed to describe the data that will be collected from the simple
random number generating Device Service.

1.  Explore the files in the src/c/examples/res folder. Take note of the
    example Device Profile YAML file that is already there
    (TemplateProfile.yaml). You can explore the contents of this file to
    see how devices are represented by YAML. In particular, note how
    fields or properties of a sensor are represented by
    "deviceResources". Commands to be issued to the device are
    represented by "coreCommands".
2.  Download this
    `random-generator-device.yaml <random-generator-device.yaml>`{.interpreted-text
    role="download"} into the ./res folder.

You can open random-generator-device.yaml in a text editor. In this
Device Profile, you are suggesting that the device you are describing to
EdgeX has a single property (or deviceResource) which EdgeX should know
about - in this case, the property is the "randomnumber". Note how the
deviceResource is typed.

> In more real world IoT situations, this deviceResource list could be
> extensive and could be filled with all different types of data.
>
> Note also how the Device Profile describes REST commands that can be
> used by others to call on (or "get") the random number from the Device
> Service.

## Configuring your Device Service

You will now update the configuration for your new Device Service --
changing the port it operates on (so as not to conflict with other
Device Services), altering the scheduled times of when the data is
collected from the Device Service (every 10 seconds), and setting up the
initial provisioning of the random number generating device when the
service starts.

-   Download this
    `configuration.toml <configuration.toml>`{.interpreted-text
    role="download"} to the ./res folder.

If you will be running EdgeX inside of Docker containers (which you will
at the bottom of this guide) you need to tell your new Device Service to
listen on the Docker host IP address (172.17.0.1) instead of
**localhost**. To do that, modify the configuration.toml file so that
the top section looks like this:

``` toml
[Service]
Host = "172.17.0.1"
Port = 49992
```

## Rebuild your Device Service

Now you have your new Device Service, modified to return a random
number, a Device Profile that will tell EdgeX how to read that random
number, as well as a configuration file that will let your Device
Service register itself and it's Device Profile with EdgeX, and begin
taking readings every 10 seconds.

1.  Rebuild your Device Service to reflect the changes that you have
    made:

        gcc -I$CSDK_DIR/include -L$CSDK_DIR/lib -o device-example-c template.c -lcsdk

## Run your Device Service

Allow your newly created Device Service, which was formed out of the
Device Service C SDK, to create sensor mimicking data which it then
sends to EdgeX.

1.  Follow the [Getting Started Users](./Ch-GettingStartedUsers.md)
    guide to start all of the EdgeX services in Docker. From the folder
    containing the docker-compose file, start EdgeX with a call to:

        docker-compose up -d

2.  Back in your custom Device Service directory, tell your device
    service where to find the `libcsdk.so`:

        export LD_LIBRARY_PATH=$CSDK_DIR/lib

3.  Run your device service:

        ./device-example-c

4.  You should now see your Device Service having it's /Random command
    called every 10 seconds. You can verify that it is sending data into
    EdgeX by watching the logs of the `edgex-core-data`
    service:

        docker logs -f edgex-core-data

Which would print an Event record every time your Device Service is
called.

1.  You can manually generate an event using curl to query the device
    service directly:

        curl 0:49992/api/v1/device/name/RandNum-Device01/Random

Note that the value of the "randomnumber" reading is an integer
between 0 and 100:
```json
{"device":"RandNum-Device01","origin":1559317102457,"readings":[{"name":"randomnumber","value":"63"}]}
```
