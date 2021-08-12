# EdgeX Demonstration API Walk Through

!!! edgey "EdgeX 2.0"
    Warning! This API walk through tutorial has not yet been updated to the Ireland Release / EdgeX 2.  This tutorial is still based on Hanoi (EdgeX 1.x) release APIs and services.

In order to better appreciate the EdgeX Foundry micro services (what
they do and how they work), how they inter-operate with each other, and
some of the more important API calls that each micro service has to
offer, this demonstration API walk through shows how a device service
and device are established in EdgeX, how data is sent flowing through
the various services, and how data is then shipped out of EdgeX to the
cloud or enterprise system.

![image](EdgeX_WalkthroughDeployment.png)

Through this demonstration, you will play the part of various EdgeX
micro services by manually making REST calls in a way that mimics EdgeX
system behavior. After exploring this demonstration, and hopefully
exercising the APIs yourself, you should have a much better
understanding of how EdgeX Foundry works.

To be clear, this walkthrough is not the way you setup all your device services, devices, etc.
In this walkthrough, you manually call EdgeX APIs to perform the work that a device service would do to get a new device setup and to send data to/through EdgeX.  In other words, you are simulating the work of a device service does automatically by manually executing EdgeX APIs.  You will also exercise APIs to see the results of the work accomplished by the device service and all of EdgeX.

[Next>](Ch-WalkthroughSetup.md){: .md-button }


