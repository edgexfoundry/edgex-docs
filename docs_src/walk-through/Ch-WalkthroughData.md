# Defining your data

When a new device service is first started in EdgeX, there are many many
tasks to perform - all in preparation for the device service to manage
one or more devices, which are yet unknown to EdgeX. In general, the
device service tasks when it first starts can be categorized into:

-   Establish the reference information around the device service and
    device.
-   Make the device service itself known to the rest of EdgeX
-   Provision the devices the device service will manage with EdgeX

Reference information includes things such as defining the address
(called an **Addressable**) of the device or
establishing the new unit of measure (called a **Value Descriptor** in
EdgeX) used by the device. The term "provision" is the way we talk
about establishing the initial connection to the physical device and
have it be known to and communication with EdgeX.

After the first run of a device service, these steps are not repeated.
For example, after its initial startup, a device service would not need
to re-establish the reference information into EdgeX. Instead, it would
simply check that these operations have been accomplished and do not
need to be redone.

## Creating Reference Information in EdgeX

There is a lot of background information that EdgeX needs to know about
the device and device service before it can start collecting data from
the device or send actuation commands to the device. Say, for example,
the camera device wanted to report its human and canine counts. If it
were to just start sending numbers into EdgeX, EdgeX would have no idea
of what those numbers represented or even where they came from. Further,
if someone/something wanted to send a command to the camera, it would
not know how to reach the camera without some additional information
like where the camera is located on the network.

This background or reference information is what a device service must
define in EdgeX when it first comes up. The API calls here give you a
glimpse of this communication between the fledgling device service and
the other EdgeX micro services.

By the way, the order in which these calls are shown may not be the
exact order that a real device service does them. As you become more familiar
with device services and the [device service SDK](../microservices/device/sdk/Ch-DeviceSDK.md), the small nuances and
differences will become clear.

## Addressables

See [core metadata API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/1.2.1) for more details.

The device service will often establish at least two `Addressable` objects
with the core metadata micro service. An `Addressable` is a flexible EdgeX
object that specifies a physical address of something - in this case the
physical address of the device service and the device (the camera).
While an `Addressable` could be created for a named MQTT pipe or other
protocol endpoint, for this example, we will assume that both the device
service and device are able to be reached via HTTP REST calls.

So in this case, the device service would make two calls to core
metadata, to create the `Addressable` for the device service and the `Addressable` for the device (the camera in this case).

### Walkthrough - Addressables

Use either the Postman or Curl tab below to begin your API walkthrough starting with setting up the `Addressable`s

=== "Postman"

    Make two (2) POST requests to `http://localhost:48081/api/v1/addressable` with the following bodies:

    ``` json
    BODY: {"name":"camera control","protocol":"HTTP","address":"localhost","port":49977,"path":"/api/v1/callback","publisher":"none","user":"none","password":"none","topic":"none"}
    BODY: {"name":"camera1 address","protocol":"HTTP","address":"localhost","port":49999,"path":"/camera1","publisher":"none","user":"none","password":"none","topic":"none"}
    ```

    Be sure that you are POSTing **raw** data, not form-encoded data (as shown below).

    ![image](EdgeX_WalkthroughPostmanPOST.png)

    If your API calls are successful, you will get a generated ID (a UUID) for your new `Addressable` that looks similar to this: `9a110e5a-1ceb-4b6f-82a3-a77810630b4e`

=== "Curl"

    Make two (2) curl POST requests as shown below.

    ``` shell
    curl -X POST -d '{"name":"camera control","protocol":"HTTP","address":"localhost","port":49977,"path":"/api/v1/callback","publisher":"none","user":"none","password":"none","topic":"none"}' localhost:48081/api/v1/addressable
    curl -X POST -d '{"name":"camera1 address","protocol":"HTTP","address":"localhost","port":49999,"path":"/camera1","publisher":"none","user":"none","password":"none","topic":"none"}' localhost:48081/api/v1/addressable
    ```

    If your API calls are successful, you will get a generated ID (a UUID) for your new `Addressable` that looks similar to this: `9a110e5a-1ceb-4b6f-82a3-a77810630b4e`

!!! Note
    For an `Addressable`, a unique name must be provided. Obviously, these address, port numbers, and paths are phony and made up for the purposes of this exercise. This is OK and it will still allow you to see how your device and device services will work going forward.

## Value Descriptors

See [core data API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-data/1.2.1) for more details.

Next, the device service needs to inform EdgeX about the type of data it
will be sending on the behalf of the devices. If you are given the
number 5, what does that mean to you? Nothing, without some context and
unit of measure. For example, if I was to say 5 feet is the scan depth
of the camera right now, you have a much better understanding about what
the number 5 represents. In EdgeX, `Value Descriptors` provide the context
and unit of measure for any data (or values) sent to and from a device.
As the name implies, a `Value Descriptor` describes a value - its unit of
measure, its min and max values (if there are any), the way to display
the value when showing it on the screen, and more. Any data obtained
from a device (we call this a `GET` from the device) or any data sent to
the device for actuation (we call this `SET` or `PUT` to the device)
requires a `Value Descriptor` to be associated with that data.

In this demo, there are four `Value Descriptors` required: human count,
canine count, scan depth, and snapshot duration. The device service
would make four POST requests to core data to establish these `Value
Descriptors` on initialization.

### Walkthrough - Value Descriptors

Use either the Postman or Curl tab below to walkthrough the addition of the `Value Descriptor`s

!!! Warning
    Pay attention to the port numbers. In the previous section you were calling the core metadata service (port 48081), in these you will be calling core data (port 48080).

=== "Postman"

    Make four (4) POST requests to `http://localhost:48080/api/v1/valuedescriptor` with the following bodies:

    ``` json
    BODY:  {"name":"humancount","description":"people count", "min":"0","max":"100","type":"Int16","uomLabel":"count","defaultValue":"0","formatting":"%s","labels":["count","humans"]}
    BODY:  {"name":"caninecount","description":"dog count", "min":"0","max":"100","type":"Int16","uomLabel":"count","defaultValue":"0","formatting":"%s","labels":["count","canines"]}
    BODY:  {"name":"depth","description":"scan distance", "min":"1","max":"10","type":"Int16","uomLabel":"feet","defaultValue":"1","formatting":"%s","labels":["scan","distance"]}
    BODY:  {"name":"duration","description":"time between events", "min":"10","max":"180","type":"Int15","uomLabel":"seconds","defaultValue":"10","formatting":"%s","labels":["duration","time"]}
    ```
    ![image](EdgeX_WalkthroughPostValueDescriptor.png)

=== "Curl"

    Make four (4) curl POST requests as shown below.

    ``` shell
    curl -X POST -d '{"name":"humancount","description":"people count", "min":"0","max":"100","type":"Int16","uomLabel":"count","defaultValue":"0","formatting":"%s","labels":["count","humans"]}' localhost:48080/api/v1/valuedescriptor
    curl -X POST -d '{"name":"caninecount","description":"dog count", "min":"0","max":"100","type":"Int16","uomLabel":"count","defaultValue":"0","formatting":"%s","labels":["count","canines"]}' localhost:48080/api/v1/valuedescriptor
    curl -X POST -d '{"name":"depth","description":"scan distance", "min":"1","max":"10","type":"Int16","uomLabel":"feet","defaultValue":"1","formatting":"%s","labels":["scan","distance"]}' localhost:48080/api/v1/valuedescriptor
    curl -X POST -d '{"name":"duration","description":"time between events", "min":"10","max":"180","type":"Int15","uomLabel":"seconds","defaultValue":"10","formatting":"%s","labels":["duration","time"]}' localhost:48080/api/v1/valuedescriptor
    ```

Again, the name of each `Value Descriptor` must be unique (within all of EdgeX). The type of a `Value Descriptor` indicates the type of the associated value (in the examples above, all integer 16).Formatting is used by UIs and should follow the printf formatting standard for how to represent the associated value.

#### Test the GET API

If you make a GET call to the `http://localhost:48080/api/v1/valuedescriptor` URL (with Postman or curl) you will get a listing (in JSON) of all the Value Descriptors currently defined
in your instance of EdgeX, including the ones you just added.

![image](EdgeX_WalkthroughGetValueDescriptors.png)

[<Back](Ch-WalkthroughUseCase.md){: .md-button } [Next>](Ch-WalkthroughDeviceProfile.md){: .md-button }
