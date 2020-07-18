# Golang SDK

In this guide, you create a simple device service that generates a
random number as a means to simulate getting getting data from an actual device. In this way, you explore some the SDK framework and work necessary to complete a device service without actually having a device to talk to.

## Install dependencies

See the [Getting Started - Go Developers](Ch-GettingStartedGoDevelopers.md) guide to install the necessary tools and infrastructure needed to develop a GoLang service.

## Get the EdgeX Device SDK for Go

Follow these steps to create a folder on your file system,
download the [Device SDK](../../microservices/device/sdk/Ch-DeviceSDK), and get the GoLang device service SDK to your system.

1.  Create a collection of nested folders, ~/go/src/github.com/edgexfoundry on your file system. This folder will eventually hold your new Device Service. In Linux, this can be done with a single mkdir command
    ``` bash
    mkdir -p ~/go/src/github.com/edgexfoundry
    ```

2. In a terminal window, change directories to the folder just created and pull down the SDK in Go with the commands as shown.
    ``` bash
    cd ~/go/src/github.com/edgexfoundry
    git clone https://github.com/edgexfoundry/device-sdk-go.git
    ```

    ![image](EdgeX_GettingStartedSDKClone.png)

3.  Create a folder that will hold the new device service.  The name of the folder is also the name you want to give your new device service. Standard practice in EdgeX is to prefix the name of a device service with `device-`.  In this example, the name 'device-simple` is used.
    ``` bash
    mkdir ~/go/src/github.com/edgexfoundry/device-simple
    ```

4.  Copy the example code from **device-sdk-go** to **device-simple**:
    ``` bash
    cd ~/go/src/github.com/edgexfoundry
    cp -rf ./device-sdk-go/example/* ./device-simple/
    ```

5.  Copy Makefile to device-simple:
    ``` bash
    cp ./device-sdk-go/Makefile ./device-simple
    ```
6. Copy version.go to device-simple:
    ``` bash
    cp ./device-sdk-go/version.go ./device-simple/
    ```

After completing these steps, your device-simple folder should look like the listing below.

![image](EdgeX_GettingStartedSDKCopyFiles.png)

## Start a new Device Service

With the device service application structure in place, time now to program the service to act like a sensor data fetching service.

1.  Open main.go file in the cmd/device-simple folder with your favorite text editor. Modify the
    import statements.  Replace `github.com/edgexfoundry/device-sdk-go/example/driver` with `github.com/edgexfoundry/device-simple/driver` in the import statements. Also replace `github.com/edgexfoundry/device-sdk-go` with `github.com/edgexfoundry/device-simple`. Save the file when you have finished editing.

    ![image](EdgeX_GettingStartedSDKReplaceImports.png)

2.  Open Makefile found in the base folder (~/go/src/github.com/edgexfoundry/device-simple) in your favorite text editor and make the following
    changes

    -   Replace:

            MICROSERVICES=example/cmd/device-simple/device-simple

        with:

            MICROSERVICES=cmd/device-simple/device-simple

    -   Modify:

            GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-sdk-go.Version=$(VERSION)"

        to refer to the new service with:

            GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-simple.Version=$(VERSION)"

    -   Modify:

            example/cmd/device-simple/device-simple:
              $(GO) build $(GOFLAGS) -o $@ ./example/cmd/device-simple

        to:

            cmd/device-simple/device-simple:
              $(GO) build $(GOFLAGS) -o $@ ./cmd/device-simple

3.  Save the file.

4.  Enter the following command to create the initial module definition
    and write it to the go.mod file:

        GO111MODULE=on go mod init

    ![image](EdgeX_GettingStartedGoModInit.png)

## Build your Device Service

To ensure that the code you have moved and updated still works, build
the device service.

1.  In a terminal window, change directories to the device-simple folder
    (the folder containing the Makefile).

2.  Build the service by issuing the following command:

        make build

3.  If there are no errors, your service is ready for you to add
    customizations to generate data values as if there was a sensor
    attached. If there are errors, retrace your steps to correct the
    error and try to build again. Ask you instructor for help in finding
    the issue if you are unable to locate it given the error messages
    you receive from the build process.

## Customize your Device Service

The Device Service you are creating isn't going to talk to a real
device. Instead, it is going to generate a random number where the
service would make a call to get sensor data from the actual device. By
so doing, you see where the EdgeX Device Service would make a call to a
local device (using its protocol and device drivers under the covers) to
provide EdgeX with its sensor readings:

1.  Locate the simpledriver.go file in the /driver folder and open it
    with your favorite editor.

2.  In the import() area at the top of the file, add "math/rand" under
    "time".

3.  Locate the HandleReadCommands() function in this file. Notice the
    following line of code in this file:

        cv, _ := dsModels.NewBoolValue(reqs[0].DeviceResourceName, now, s.switchButton)

4.  Replace the two lines of code with the following:

        if reqs[0].DeviceResourceName == "randomnumber" {
            cv, _ := dsModels.NewInt32Value(reqs[0].DeviceResourceName, now, int32(rand.Intn(100)))

    The first line of code to confirmed request is for the customized
    resource "randomnumber". Also, the second line of code generates
    an integer (between 0 and 100) and uses that as the value the Device
    Service sends to EdgeX -- mimicking the collection of data from a
    real device. It is here that the Device Service would normally
    capture some sensor reading from a device and send the data to
    EdgeX. The line of code you just added is where you'd need to do
    some customization work to talk to the sensor, get the sensor's
    latest sensor values and send them into EdgeX.

5.  Save the simpledriver.go file

## Creating your Device Profile

A Device Profile is a YAML file that describes a class of device to
EdgeX. General characteristics about the type of device, the data these
devices provide, and how to command the device is all provided in a
Device Profile. Device Services use the Device Profile to understand
what data is being collected from the Device (in some cases providing
information used by the Device Service to know how to communicate with
the device and get the desired sensor readings). A Device Profile is
needed to describe the data to collect from the simple random number
generating Device Service.

Do the following:

1.  Explore the files in the cmd/device-simple/res folder. Take note of
    the example Device Profile YAML file that is already there
    (Simple-Driver.yml). You can explore the contents of this file to
    see how devices are represented by YAML. In particular, note how
    fields or properties of a sensor are represented by
    "deviceResources". Command to be issued to the device are
    represented by "deviceCommands".

2.  Download
    `random-generator-device.yaml <random-generator-device.yaml>`{.interpreted-text
    role="download"} to the cmd/device-simple/res folder.

3.  Open the random-generator-device.yaml file in a text editor. In this
    Device Profile, you define that the device you are describing to
    EdgeX has a single property (or deviceResource) that EdgeX needs to
    know about - in this case, the property is the "randomnumber". Note
    how the deviceResource is typed.

    In real world IoT situations, this deviceResource list could be
    extensive and be filled with all different types of data.

    Note also how the Device Profile describes REST commands that can be
    used by others to call on (or "get") the random number from the
    Device Service.

## Configuring your Device Service

Now update the configuration for your new Device Service -- changing the
port it operates on (so as not to conflict with other Device Services),
altering the auto event frequency of when the data is collected from the
Device Service (every 10 seconds in this example), and setting up the
initial provisioning of the random number generating device when the
service starts.

Download `configuration.toml <configuration.toml>`{.interpreted-text
role="download"} to the cmd/device-simple/res folder (this will
overwrite an existing file -- that's ok).

## Rebuild your Device Service

Just as you did before, you are ready to build the device-simple service
-- creating the executable program that is your Device Service:

1.  In a terminal window, change directories to the base device-simple
    folder (containing the Makefile).

2.  Build the Device Service by issuing the following command:

        make build

3.  If there are no errors, your service has now been created and is
    available in the cmd/device-simple folder (look for the
    device-simple file).

## Run your Device Service

Allow your newly created Device Service, which was formed out of the
Device Service Go SDK, to create sensor-mimicking data that it then
sends to EdgeX:

1.  As described in the `./Ch-GettingStartedUsers`{.interpreted-text
    role="doc"} guide, use Docker Compose to start all of EdgeX. From
    the folder containing the docker-compose file, start EdgeX with the
    following call:

        docker-compose up -d

2.  In a terminal window, change directories to the device-simple's
    cmd/device-simple folder. The executable device-simple is located
    there.

3.  Execute the Device Service with the ./device-simple command, as
    shown below:

    This starts the service and immediately displays log entries in the
    terminal.

4.  Using a browser, enter the following URL to see the Event/Reading
    data that the service is generating and sending to EdgeX:

    <http://localhost:48080/api/v1/event/device/RandNum-Device-01/100>

    This request asks for the last 100 Events/Readings from Core Data
    associated to the RandNum-Device-01.

    **Note**: If you are running the other EdgeX services somewhere
    other than localhost, use that hostname in the above URL.
