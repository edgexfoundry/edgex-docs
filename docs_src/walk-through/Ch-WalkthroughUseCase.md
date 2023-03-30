# Example Use Case

In order to explore EdgeX, its services and APIs and to generally understand how it works, it helps to see EdgeX under the context of a real use case.  While you exercise the APIs under a hypothetical situation in order to demonstrate how EdgeX works, the use case is very much a valid example of how EdgeX can be used to collect data from devices and actuate control of the sensed environment it monitors.  People (and animal) counting camera technology as highlighted in this walk through does exist and has been connected to EdgeX before.

## Object Counting Camera

Suppose you had a new device that you wanted to connect to EdgeX. The
device was a camera that took a picture and then had an on-board chip
that analyzed the picture and reported the number of humans and canines
(dogs) it saw.

![image](EdgeX_WalkthroughHumansCanine.png)

How often the camera takes a picture and reports its findings can be
configured. In fact, the camera device could be sent two actuation
commands - that is sent two requests for which it must respond and do
something. You could send a request to set its time, in seconds, between
picture snapshots (and then calculating the number of humans and dogs it
finds in that resulting image). You could also request it to set the
scan depth, in feet, of the camera - that is set how far out the camera
looks. The farther out it looks, the less accurate the count of humans
and dogs becomes, so this is something the manufacturer wants to allow
the user to set based on use case needs.

![image](EdgeX_WalkthroughSnapshotDepth.png)

## EdgeX Device Representation

In EdgeX, the camera must be represented by a `Device`. Each `Device` is
managed by a [device service](../microservices/device/Ch-DeviceServices.md). The device service
communicates with the underlying hardware - in this case the camera - in
the protocol of choice for that `Device`. The device service collects the
data from the devices it manages and passes that data into the rest of EdgeX.

!!! note
    A device service will, by default, publish data into a message bus which can be subscribed to by core data and/or application services.  You'll learn more about these later in this walkthrough.  Alternately, a device service can send data directly to core data.

In this case, the device service would be collecting the
count of humans and dogs that the camera sees. The device service also
serves to translate the request for actuation from EdgeX and the rest of
the world into protocol requests that the physical device would
understand. So in this example, the device service would take requests
to set the duration between snapshots and to set the scan depth and
translate those requests into protocol commands that the camera
understood.

![image](EdgeX_WalkthroughCameraCommands.png)

Exactly how this camera physically connects to the host machine running
EdgeX and how the device service works under the covers to communicate
with the camera Device is immaterial for the point of this
demonstration.

[<Back](Ch-WalkthroughSetup.md){: .md-button } [Next>](Ch-WalkthroughDeviceProfile.md){: .md-button }

