# Application Services

![image](ApplicationServices.png)

Application Services are the means to extract, process/transform and
send event/reading data from EdgeX to an endpoint or process of your
choice.

Application Services are based on the idea of a "Functions Pipeline".
A functions pipeline is a collection of functions that process messages
(in this case EdgeX event/reading messages) in the order that you've
specified. The first function in a pipeline is a trigger. A trigger
begins the functions pipeline execution. A trigger is something like a
message landing in a watched message queue.

Any application built on top of the Application Functions SDK is considered an App Service. 
This SDK is provided to help build Application Services by assembling triggers, pre-existing 
functions and custom functions of your making into a pipeline.


**Note** Application Services has replaced Export Services in this
EdgeX release.
