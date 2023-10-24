---
title: App SDK - Pipeline Per Topics
---

# App Functions SDK - Pipeline Per Topics

The `Pipeline Per Topics` feature allows for multiple function pipelines to be defined. Each will execute only when one of the specified pipeline topics matches the received topic. The pipeline topics can have wildcards (`+` and `#`) allowing the topic to match a variety of received topics. Each pipeline has its own set of functions (transforms) that are executed on the received message. If the `#` wildcard is used by itself for a pipeline topic, it will match all received topics and the specified functions pipeline will execute on every message received.

!!! note
    The `Pipeline Per Topics` feature is targeted for EdgeX MessageBus and External MQTT triggers, but can be used with Custom or HTTP triggers. When used with the HTTP trigger the incoming topic will always be `blank`, so the pipeline's topics must contain a single topic set to the `#` wildcard so that all messages received are processed by the pipeline.

!!! example "Example pipeline topics with wildcards"
    ```
    "#"                             - Matches all messages received
    "edegex/events/#"               - Matches all messages received with the based topic `edegex/events/`
    "edegex/events/core/#"          - Matches all messages received just from Core Data
    "edegex/events/device/#"        - Matches all messages received just from Device services
    "edegex/events/+/my-profile/#"  - Matches all messages received from Core Data or Device services for `my-profile`
    "edegex/events/+/+/my-device/#" - Matches all messages received from Core Data or Device services for `my-device`
    "edegex/events/+/+/+/my-source" - Matches all messages received from Core Data or Device services for `my-source`
    ```

Refer to the [Filter By Topics](../../details/Triggers.md#filter-by-topics) section for details on the structure of the received topic.

All pipeline function capabilities such as Store and Forward, Batching, etc. can be used with one or more of the multiple function pipelines. Store and Forward uses the Pipeline's ID to find and restart the pipeline on retries.

!!! example "Example - Adding multiple function pipelines"
    This example adds two pipelines. One to process data from the `Random-Float-Device` device and one to process data from the `Int32` and `Int64` sources.

    ```go
        sample := functions.NewSample()
        err = service.AddFunctionsPipelineForTopics(
    			"Floats-Pipeline", 
    			[]string{"edgex/events/+/+/Random-Float-Device/#"}, 
    			transforms.NewFilterFor(deviceNames).FilterByDeviceName,
    			sample.LogEventDetails,
    			sample.ConvertEventToXML,
    			sample.OutputXML)
        if err != nil {
            ...
            return -1
        }
        
        err = app.service.AddFunctionsPipelineForTopics(
    			"Int32-Pipleline", 
    			[]string{"edgex/events/+/+/+/Int32", "edgex/events/+/+/+/Int64"},
    		    transforms.NewFilterFor(deviceNames).FilterByDeviceName,
    		    sample.LogEventDetails,
    		    sample.ConvertEventToXML,
    		    sample.OutputXML)
        if err != nil {
        	...
            return -1
        }
    ```