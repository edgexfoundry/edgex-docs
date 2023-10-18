---
title: App Service Configurable - Getting Started
---

# App Service Configurable - Getting Started

To get started with App Service Configurable, you'll want to start by determining which functions are required in your pipeline. Using a simple example, let's assume you wish to use the following functions from the SDK:

1. [FilterByDeviceName](../details/AvailablePipelineFunctions/#filterbydevicename) -  to filter events for a specific device.
2. [Transform](../details/AvailablePipelineFunctions/#transform) - to transform the data to XML
3. [HTTPExport](../details/AvailablePipelineFunctions/#httpexport) - to send the data to an HTTP endpoint that takes our XML data   

Once the functions have been identified, we'll go ahead and build out the configuration in the `configuration.yaml` file under the `Writable.Pipeline` section.

!!! example "Example - Writable.Pipeline"
    ```yaml
    Writable:
      Pipeline:
        ExecutionOrder: "FilterByDeviceName, Transform, HTTPExport"
        Functions:
          FilterByDeviceName:
            Parameters:
              FilterValues: "Random-Float-Device, Random-Integer-Device"
          Transform:
            Parameters:
              Type: "xml"
          HTTPExport:
            Parameters:
              Method: "post" 
              MimeType: "application/xml" 
              Url: "http://my.api.net/edgexdata"
    ```

The first line of note is `ExecutionOrder: "FilterByDeviceName, Transform, HTTPExport"`. This specifies the order in which your functions are executed. Each function specified here must exist in the `Functions:` section. 

Next, each function and its required information is listed. Each function typically has associated Parameters that must be configured to properly execute the function as designated by `Parameters:` under `{FunctionName}`. Knowing which parameters are required for each function, can be referenced by taking a look at the [Available Pipeline Functions](../details/AvailablePipelineFunctions) section.

!!! note
    By default, the configuration provided is set to use `EdgexMessageBus` as a trigger. This means you must have EdgeX Running with devices sending data in order to trigger the pipeline. You can also change the trigger to be HTTP. For more details on triggers, view the `Triggers`documentation located in the [Triggers](../../sdk/details/Triggers.md) section.

That's it! Now we can run/deploy this service and the functions pipeline will process the data with functions we've defined.
