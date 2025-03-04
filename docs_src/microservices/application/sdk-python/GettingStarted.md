---
title: App SDK for Python - Getting Started
---

# App Functions SDK for Python - Getting Started

## Introduction
The SDK is built around the concept of a "Functions Pipeline". 
A functions pipeline is a collection of various functions that process the data in the defined order. 
The functions pipeline is executed by the specified [trigger](../details/Triggers.md) in the `configuration.yaml` . 
The initial function in the pipeline is called with the event that triggered the pipeline (ex. `dtos.Event`). 
Each successive call in the pipeline is called with the return result of the previous function.
This document will guide you through the process of creating a simple application service using the App Functions SDK for Python.
This simple application service will filter particular device ids and subsequently transform the data to XML.

## Prerequisites
- Python 3.10
- [git](https://git-scm.com/downloads/linux)
- [Postman](https://www.postman.com/) or [curl](https://curl.se/)

## SDK Installation
The App Functions SDK for Python can be installed using pip. Follow the steps below to install the SDK:

1. Clone the SDK repository from GitHub:
    ```bash
    git clone https://github.com/edgexfoundry/app-functions-sdk-python.git
    ```
2. Change to the `app-functions-sdk-python` directory:
    ```bash
    cd app-functions-sdk-python
    ```
3. Create a virtual environment based on python3.10 in the root of the repository in your local environment:
    ```bash
    python3.10 -m venv venv
    ```
4. Activate the virtual environment:
    ```bash
    source ./venv/bin/activate
    ```
5. Install the dependencies for the App Functions Python SDK in the virtual environment:
    ```bash
    pip install -r requirements.txt
    ```
6. Install the App Functions Python SDK in the virtual environment:
    ```bash
    pip install -e .
    ```

## Create a Simple Application Service
The following steps will guide you through the process of creating a simple application service using the App Functions SDK for Python.

1. Create a new folder named `sample` in the root of the repository.
2. Create a new Python file named `app-simple-filter-xml.py` under `sample` folder.
3. Add the following code to the `sample/app-simple-filter-xml.py` file:
    ```python
    import asyncio
    import os
    from typing import Any, Tuple
    
    from app_functions_sdk_py.contracts import errors
    from app_functions_sdk_py.functions import filters, conversion
    from app_functions_sdk_py.factory import new_app_service
    from app_functions_sdk_py.interfaces import AppFunctionContext
    
    service_key = "app-simple-filter-xml"
    
    if __name__ == "__main__":
        # turn off secure mode for examples. Not recommended for production
        os.environ["EDGEX_SECURITY_SECRET_STORE"] = "false"
    
        # 1) First thing to do is to create a new instance of an EdgeX Application Service.
        service, result = new_app_service(service_key)
        if result is False:
            os._exit(-1)
    
        # Leverage the built-in logging service in EdgeX
        lc = service.logger()
    
        try:
            # 2) shows how to access the application's specific configuration settings.
            device_names = service.get_application_setting_strings("DeviceNames")
            lc.info(f"Filtering for devices {device_names}")
            # 3) This is our pipeline configuration, the collection of functions to execute every time an event is triggered.
            service.set_default_functions_pipeline(
                filters.new_filter_for(filter_values=device_names).filter_by_device_name,
                conversion.Conversion().transform_to_xml
            )
            # 4) Lastly, we'll go ahead and tell the SDK to "start" and begin listening for events to trigger the pipeline.
            asyncio.run(service.run())
        except Exception as e:
            lc.error(f"{e}")
            os._exit(-1)
    
        # Do any required cleanup here
        os._exit(0)
    
    ```
    The above code is intended to simply demonstrate the structure of your application. It's important to note that the output of the final function is not accessible within the application itself. You must provide a function in order to work with the data from the previous function.

4. Add the following function that prints the output to the console.
    ```python
    def print_xml_to_console(ctx: AppFunctionContext, data: Any) -> Tuple[bool, Any]:
        """
        Print the XML data to the console
        """
        # Leverage the built-in logging service in EdgeX
        if data is None:
            return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,"print_xml_to_console: No Data Received")
    
        if isinstance(data, str):
            print(data)
            return True, None
        return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,"print_xml_to_console: Data received is not the expected 'str' type")
    ```
    The above code defines a function `print_xml_to_console` that prints the XML data to the console. The `print_xml_to_console` function must conform to the signature of [`AppFunction` callable](api/ApplicationServiceAPI.md#appfunction), which takes two parameters: `ctx` and `data`. The `ctx` parameter is an instance of the `AppFunctionContext` class, which provides access to the logger and other services. The `data` parameter is the data that is passed to the function from the previous function in the pipeline. The function checks if the data is of type `str` and then prints the data to the console. If the data is not of type `str`, the function returns an error.

5. After placing the above function in your code, the next step is to modify the pipeline to call this function:

    ```python
            # 3) This is our pipeline configuration, the collection of functions to execute every time an event is triggered.
            service.set_default_functions_pipeline(
                filters.new_filter_for(filter_values=device_names).filter_by_device_name,
                conversion.Conversion().transform_to_xml,
                print_xml_to_console
            )
    ```

    At this step, you have created a simple application service that filters data from specific devices and transforms the data to XML. The final function in the pipeline prints the XML data to the console. The next step is to configure the service to run.

6. Create a `res` folder under `sample` folder, and compose a `sample/res/configuration.yaml` file with content as shown below:

    ```yaml 
    Writable:
      LogLevel: INFO
      Telemetry:
        Interval: ""
    
    Service:
      Host: localhost
      Port: 59780 # Adjust if running multiple examples at the same time to avoid duplicate port conflicts
      StartupMsg: "This is a sample Filter/XML Transform Application Service"
    
    MessageBus:
      Disabled: true  # Set to true if not using edgex-messagebus Trigger below and don't want Metrics
      Optional:
        ClientId: app-simple-filter-xml
    
    Trigger:
      Type: http
    
    # App Service specific simple settings
    # Great for single string settings. For more complex structured custom configuration
    # See https://docs.edgexfoundry.org/latest/microservices/application/AdvancedTopics/#custom-configuration
    ApplicationSettings:
      DeviceNames: "Random-Float-Device, Random-Integer-Device"
    ```
    The above `configuration.yaml` file specifies the configuration settings for the application service. The `DeviceNames` setting specifies the device names that the application service will filter for. The `Trigger` section specifies the trigger type for the application service. In this case, the application service will be triggered by an HTTP POST request. 

7. Now start the service under `sample` folder by running the following command:

    ```bash
    python app-simple-filter-xml.py
    ```

8. Using Postman or curl to send an HTTP POST request with following JSON to `localhost:59780/api/{{api_version}}/trigger`

    ```json
    {
        "requestId": "82eb2e26-0f24-48ba-ae4c-de9dac3fb9bc",
        "apiVersion" : "{{api_version}}",
        "event": {
            "apiVersion" : "{{api_version}}",
            "deviceName": "Random-Float-Device",
            "profileName": "Random-Float-Device",
            "sourceName" : "Float32",
            "origin": 1540855006456,
            "id": "94eb2e26-0f24-5555-2222-de9dac3fb228",
            "readings": [
                {
                    "apiVersion" : "{{api_version}}",
                    "resourceName": "Float32",
                    "profileName": "Random-Float-Device",
                    "deviceName": "Random-Float-Device",
                    "value": "76677",
                    "origin": 1540855006469,
                    "valueType": "Float32"
                }
            ]
        }
    }
    ```
    The above JSON is an example of an EdgeX event that triggers the application service. The EdgeX event specifies the device name, profile name, source name, origin, and readings. The device name is set to `Random-Float-Device`, which is one of the device names specified in the `DeviceNames` setting in the `configuration.yaml` file. The readings contain the value of the reading, the origin, and the value type.
    After executing the above command, you should now see data printing out to the console in XML:

    ```bash
    <?xml version="1.0" encoding="utf-8"?>
    <Event><Id>94eb2e26-0f24-5555-2222-de9dac3fb228</Id><DeviceName>Random-Float-Device</DeviceName><ProfileName>Random-Float-Device</ProfileName><SourceName>Float32</SourceName><Origin>1540855006456</Origin><Readings><Id>82eb2e36-0f24-48aa-ae4c-de9dac3fb920</Id><Origin>1540855006469</Origin><DeviceName>Random-Float-Device</DeviceName><ResourceName>Float32</ResourceName><ProfileName>Random-Float-Device</ProfileName><ValueType>Float32</ValueType><Value>76677</Value><Units></Units><BinaryValue></BinaryValue><ObjectValue></ObjectValue><Tags></Tags><MediaType></MediaType></Readings><Tags></Tags></Event>
    INFO:     127.0.0.1:36410 - "POST /api/v3/trigger HTTP/1.1" 200 OK
    ```

!!! note
    You can find more examples located in the [examples](https://github.com/edgexfoundry/app-functions-sdk-python/tree/main/examples) section.

!!! note
    The App Functions SDK contains a quick start template for creating new custom application services. See [app-service-template README documentation](https://github.com/edgexfoundry/app-functions-sdk-python/blob/main/app-service-template/README.md) for more information.
