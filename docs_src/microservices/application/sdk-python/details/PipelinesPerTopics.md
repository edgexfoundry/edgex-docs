---
title: App SDK - Pipeline Per Topics
---

# App Functions SDK for Python - Pipeline Per Topics

The `Pipeline Per Topics` feature allows for multiple function pipelines to be defined. Each will execute only when one of the specified pipeline topics matches the received topic. The pipeline topics can have wildcards (`+` and `#`) allowing the topic to match a variety of received topics. Each pipeline has its own set of functions (transforms) that are executed on the received message. If the `#` wildcard is used by itself for a pipeline topic, it will match all received topics and the specified functions pipeline will execute on every message received.

!!! note
    The `Pipeline Per Topics` feature is targeted for EdgeX MessageBus and External MQTT triggers, but can be used with Custom or HTTP triggers. When used with the HTTP trigger the incoming topic will always be `blank`, so the pipeline's topics must contain a single topic set to the `#` wildcard so that all messages received are processed by the pipeline.

!!! example "Example pipeline topics with wildcards"
    ```
    "#"                                - Matches all messages received
    "edgex/events/#"                   - Matches all messages received with the based topic `edegex/events/`
    "edgex/events/core/#"              - Matches all messages received just from Core Data
    "edgex/events/device/#"            - Matches all messages received just from Device services
    "edgex/events/+/+/my-profile/#"    - Matches all messages received from Core Data or Device services for `my-profile`
    "edgex/events/+/+/+/my-device/#"   - Matches all messages received from Core Data or Device services for `my-device`
    "edgex/events/+/+/+/+/my-source"   - Matches all messages received from Core Data or Device services for `my-source`
    ```

Refer to the [Filter By Topics](https://docs.edgexfoundry.org/3.1/microservices/application/details/Triggers/#filter-by-topics) section for details on the structure of the received topic.

All pipeline function capabilities such as Store and Forward, Batching, etc. can be used with one or more of the multiple function pipelines. Store and Forward uses the Pipeline's ID to find and restart the pipeline on retries.

!!! example "Example - Adding multiple function pipelines"
    This example adds two pipelines. One to process data from the `Random-Float-Device` device and one to process data from the `Int32` and `Int64` sources.

    ```python
        from app_functions_sdk_py.utils.factory.mqtt import MQTTClientConfig
        from app_functions_sdk_py.functions import mqtt

        mqtt_config = MQTTClientConfig(
            broker_address="localhost",
            client_id="test_client",
            topic="test_topic",
            secret_name="",
            auth_mode="none")

        try:
            service.add_functions_pipeline_for_topics(
                "Float-Pipeline",
                ["events/+/+/+/Random-Float-Device/#"],
                mqtt.new_mqtt_sender(mqtt_config=mqtt_config).mqtt_send
            )
        except Exception as e:
            ...
            return -1

        try:
            service.add_functions_pipeline_for_topics(
                "Int-Pipeline",
                ["events/+/+/+/+/Int32", "events/+/+/+/+/Int64"],
                mqtt.new_mqtt_sender(mqtt_config=mqtt_config).mqtt_send
            )
        except Exception as e:
            ...
            return -1
    ```

!!! note
    In EdgeX 3.0, the MessageBus configuration is now common to all services. 
    In addition, the internal MessageBus topic configuration has been replaced by internal constants. 
    The new BaseTopicPrefix setting has been added to allow customization of all topics under a common base prefix. See the new common MessageBus section below: https://docs.edgexfoundry.org/3.1/microservices/configuration/CommonConfiguration/#common-configuration-properties
    The default value for BaseTopicPrefix is `edgex`, and it will automatically be prepended to the topics specified in the `add_functions_pipeline_for_topics` function.
