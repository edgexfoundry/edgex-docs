# Golang SDK

In this guide, you create a simple device service that generates a
random number as a means to simulate getting data from an actual device. In this way, you explore some the SDK framework and work necessary to complete a device service without actually having a device to talk to.

## Install dependencies

See the [Getting Started - Go Developers](Ch-GettingStartedGoDevelopers.md) guide to install the necessary tools and infrastructure needed to develop a GoLang service.

## Get the EdgeX Device SDK for Go

Follow these steps to create a folder on your file system,
download the [Device SDK](../../microservices/device/sdk/Ch-DeviceSDK), and get the GoLang device service SDK on your system.

1.  Create a collection of nested folders, `~/go/src/github.com/edgexfoundry` on your file system. This folder will hold your new Device Service. In Linux, create a directory with a single mkdir command
    ``` bash
    mkdir -p ~/go/src/github.com/edgexfoundry
    ```

2. In a terminal window, change directories to the folder just created and pull down the SDK in Go with the commands as shown.
    ``` bash
    cd ~/go/src/github.com/edgexfoundry
    git clone --depth 1 --branch v1.2.2 https://github.com/edgexfoundry/device-sdk-go.git
    ```

    ![image](EdgeX_GettingStartedSDKClone.png)

    !!! Note
        The clone command above has you pull v1.2.2 of the Go SDK which is the version associated to Geneva.  There are later releases of EdgeX.  While backward compatible, it is always a good idea to pull and use the latest version associated with the major version of EdgeX you are using.  You may want to check for the latest released version by going to https://github.com/edgexfoundry/device-sdk-go and look for the latest release.

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

1.  Change folders to the device-simple directory.

    ``` bash
    cd ~/go/src/github.com/edgexfoundry/device-simple
    ```

2.  Open main.go file in the cmd/device-simple folder with your favorite text editor. Modify the
    import statements.  Replace `github.com/edgexfoundry/device-sdk-go/example/driver` with `github.com/edgexfoundry/device-simple/driver` in the import statements. Also replace `github.com/edgexfoundry/device-sdk-go` with `github.com/edgexfoundry/device-simple`. Save the file when you have finished editing.

    ![image](EdgeX_GettingStartedSDKReplaceImports.png)

3.  Open Makefile found in the base folder (~/go/src/github.com/edgexfoundry/device-simple) in your favorite text editor and make the following
    changes

    -   Replace:

            MICROSERVICES=example/cmd/device-simple/device-simple

        with:

            MICROSERVICES=cmd/device-simple/device-simple

    -   Change:

            GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-sdk-go.Version=$(VERSION)"

        to refer to the new service with:

            GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-simple.Version=$(VERSION)"

    -   Change:

            example/cmd/device-simple/device-simple:
              $(GO) build $(GOFLAGS) -o $@ ./example/cmd/device-simple

        to:

            cmd/device-simple/device-simple:
              $(GO) build $(GOFLAGS) -o $@ ./cmd/device-simple

4.  Save the file.

5.  Enter the following command to create the initial module definition
    and write it to the go.mod file:

        GO111MODULE=on go mod init

    ![image](EdgeX_GettingStartedGoModInit.png)

6. Use an editor to open and edit the go.mod file created in ~/go/src/github.com/edgexfoundry/device-simple.  Add the code highlighted below to the bottom of the file.  This code indicates which version of the device service SDK and the associated EdgeX contracts module to use.

    ``` go
    require (
        github.com/edgexfoundry/device-sdk-go v1.2.2
        github.com/edgexfoundry/go-mod-core-contracts v0.1.58
    )
    ```
    ![image](EdgeX_GettingStartedSDKGoMod.png)

    !!! Note
        You should always check the **[go.mod](https://github.com/edgexfoundry/device-sdk-go/blob/master/go.mod)** file in the latest released version SDK for the correct versions of the Go SDK and go-mod-contracts to use in your go.mod.

## Build your Device Service

To ensure that the code you have moved and updated still works, build
the device service. In a terminal window, make sure you are still in the device-simple folder (the folder containing the Makefile).  Build the service by issuing the following command:

``` bash
make build
```

If there are no errors, your service is ready for you to add
custom code to generate data values as if there was a sensor
attached.

## Customize your Device Service

The device service you are creating isn't going to talk to a real
device. Instead, it is going to generate a random number where the
service would ordinarily make a call to get sensor data from the actual device.

1.  Locate the simpledriver.go file in the /driver folder and open it
    with your favorite editor.

    ![image](EdgeX_GettingStartedLocateDriver.png)

2.  In the import() area at the top of the file, add "math/rand" under "time".

    ![image](EdgeX_GettingStartedSDKGoAddImports.png)

3.  Locate the HandleReadCommands() function in this same file (simpledriver.go). Find the
    following lines of code in this file (around line 87):

    ``` go
    if reqs[0].DeviceResourceName == "SwitchButton" {
			cv, _ := dsModels.NewBoolValue(reqs[0].DeviceResourceName, now, s.switchButton)
			res[0] = cv
	}
    ```

    Add the conditional (if-else) code in front of the above conditional:

    ``` go
    if reqs[0].DeviceResourceName == "randomnumber" {
		   cv, _ := dsModels.NewInt32Value(reqs[0].DeviceResourceName, now, int32(rand.Intn(100)))
		   res[0] = cv
	} else
    ```

    ![image](EdgeX_GettingStartedSDKGoGenNumber.png)

    The first line of code checks that the current request is for a resource called "randomnumber". The second line of code generates
    an integer (between 0 and 100) and uses that as the value the device
    service sends to EdgeX -- mimicking the collection of data from a
    real device. It is here that the device service would normally
    capture some sensor reading from a device and send the data to
    EdgeX. The HandleReadCommands is where you'd need to do
    some customization work to talk to the device, get the
    latest sensor values and send them into EdgeX.

4.  Save the simpledriver.go file

## Creating your Device Profile

A device profile is a YAML file that describes a class of device to
EdgeX. General characteristics about the type of device, the data these devices provide, and how to command the device are all in a device profile.   The device profile tells the device service what data gets collected from the the device and how to get it. 

Follow these steps to create a device profile for the simple random number generating device service.

1.  Explore the files in the cmd/device-simple/res folder.   Note the example Simple-Driver.yaml device profile that is already in this folder.  Open the file with your favorite editor and explore its contents.  Note how `deviceResources` in the file represent properties of a device (properties like SwitchButton, X, Y and Z rotation).  Similarly, `coreCommands` specify commands that get issued to the device.

    ![image](EdgeX_SampleDeviceProfile_DeviceResources.png)

2.  A pre-created device profile for the random number device is provided in this documentation.  Download **[random-generator-device.yaml](random-generator-device.yaml)** and save the file to the `~/go/src/github.com/edgexfoundry/device-simple/cmd/device-simple/res` folder.

3.  Open the random-generator-device.yaml file in a text editor. In this device profile, the device described has a deviceResource:  `randomnumber`.  Note how the association of a type to the deviceResource.  In this case, the device profile informs EdgeX that randomnumber will be a INT32.  In real world IoT situations, this deviceResource list could be extensive.  Rather than a single deviceResource, you might find this section filled with many deviceResources and each deviceResource associated to a different type.  Note also how the device profile describes a REST command (GET Random) to call to get the random number from the device service.

## Configuring your Device Service

Now update the configuration for the new device service.    This documentation provides a new configuration.toml file.  This configuration file:

- changes the port the service operates on so as not to conflict with other device services
- alters the the auto event frequency, which determines when the device service collects data from the simulated device (every 10 seconds)
- sets up the initial provisioning of the random number generating device when the service starts

Download  **[configuration.toml](configuration.toml)** and save the file to the `~/go/src/github.com/edgexfoundry/device-simple/cmd/device-simple/res` folder (overwrite the existing configuration file).  Change the host address of the device service to your system's IP address.

!!! Warning
    In the configuration.toml, change the host address (around line 7) to the IP address of the system host.  This allows core metadata to callback to your new device service when a new device is created.  Because the rest of EdgeX, to include core metadata, will be running in Docker, the IP address of the host system on the Docker network must be provided to allow metadata in Docker to call out from Docker to the new device service running on your host system.

## Rebuild your Device Service

Just as you did in the [Build your Device Service](./Ch-GettingStartedSDK-Go.md#build-your-device-service) step above, build the device-simple service, which creates the executable program that is your device service.  In a terminal window, make sure you are in the device-simple folder (the folder containing the Makefile).  Build the service by issuing the following command:

``` bash
cd ~/go/src/github.com/edgexfoundry/device-simple
make build
```
![image](EdgeX_GettingStartedSDKBuild.png)

If there are no errors, your service is created and put in the 
`~/go/src/github.com/edgexfoundry/device-simple/cmd/device-simple` folder.  Look for the `device-simple` executable in the folder.

## Run your Device Service

Allow the newly created device service, which was formed out of the
Device Service Go SDK, to create sensor-mimicking data that it then
sends to EdgeX:

1.  Follow the [Getting Started with Docker](./Ch-GettingStartedUsers.md) guide to start all of EdgeX. From
    the folder containing the docker-compose file, start EdgeX with the
    following call:

    ``` bash
    docker-compose up -d
    ```

2.  In a terminal window, change directories to the device-simple's
    cmd/device-simple folder and run the new device-simple service.

    ``` bash
    cd ~/go/src/github.com/edgexfoundry/device-simple/cmd/device-simple
    ./device-simple
    ```

    This starts the service and immediately displays log entries in the
    terminal.

3.  Using a browser, enter the following URL to see the event/reading
    data that the service is generating and sending to EdgeX:

    <http://localhost:48080/api/v1/event/device/RandNum-Device01/100>

    This request asks core data to provide the last 100 events/readings associated to the RandNum-Device-01.

