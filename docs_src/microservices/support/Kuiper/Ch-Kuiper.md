# Kuiper Rules Engine

![image](EdgeX_KuiperRulesEngine.png)

## Overview

EMQ X Kuiper is the new EdgeX reference implementation rules engine (or [edge analytcs](../../../general/Definitions.md#edge-analytics)) implementation (replacing the Support Rules Engine - which wrapped the Java Drools engine).

## What is EMQ X Kuiper?

EMQ X Kuiper is a lightweight open source software (Apache 2.0 open source license agreement) package for IoT edge analytics and stream processing implemented in Go lang, which can run on various resource constrained edge devices. Users can realize fast data processing on the edge and write rules in SQL. The Kuiper rules engine is based on three components `Source`, `SQL` and `Sink`.

- Source: Source of stream data, such as data from an MQTT server. For EdgeX, the data source is an EdgeX message bus, which can be implemented by ZeroMQ or MQTT;
- SQL: SQL is where the specified business logic is processed. Kuiper provides SQL statements to extract, filter, and transform data;
- Sink: Used to send the analysis result to a specific target, such as sending the analysis results to EdgeX's Command service, or an MQTT broker in the cloud;

The relationship among Source, SQL and Sink in Kuiper is shown below.

![](arch.png)

Kuiper runs very efficiently on resource constrained edge devices. For common IoT data processing, the throughput can reach 12k per second. Readers can refer to [here](https://github.com/emqx/kuiper#performance-test-result) to get more performance benchmark data for Kuiper.

## Kuiper rules engine of EdgeX

An extension mechanism allows Kuiper to be customized to analyze and process data from different data sources. By default for the EdgeX configuration, Kuiper analyzes data coming from the EdgeX [message bus](https://github.com/edgexfoundry/go-mod-messaging). EdgeX provides an abstract message bus interface, and implements the ZeroMQ and MQTT protocols respectively to support information exchange between different micro-services. The integration of Kuiper and EdgeX mainly includes the following:

- Extend an EdgeX message bus source to support receiving data from the EdgeX message bus. By default, Kuiper listens to the port `5566` on which the Application Service publishes messages. After the data from the Core Data Service is processed by the Application Service, it will flow into the Kuiper rules engine for processing.
- Read the data type definition from Core Contract Service, convert EdgeX data to Kuiper data type, and process  it according to the rules specified by the user.
- Kuiper supports sending analysis results to different Sink:
  - The users can choose to send the analysis results to Command Service to control the equipment;
  - The analysis results can be sent to the EdgeX message bus sink for further processing by other micro-services.

![](arch_light.png)

## Learn more

- [EdgeX Kuiper Rules Engine Tutorial](https://github.com/emqx/kuiper/blob/master/docs/en_US/edgex/edgex_rule_engine_tutorial.md): A 10-minute quick start tutorial, readers can refer to this article to start trying out the rules engine.
- [Control the device with the EdgeX Kuiper rules engine](https://github.com/emqx/kuiper/blob/master/docs/en_US/edgex/edgex_rule_engine_command.md): This article describes how to use the Kuiper rule engine in EdgeX to control the device based on the analysis results.
- Read [EdgeX Source](https://github.com/emqx/kuiper/blob/master/docs/en_US/rules/sources/edgex.md) to get more detailed information, and type conversions.
- [How to use the meta function to extract more information sent in the EdgeX message bus?](https://github.com/emqx/kuiper/blob/master/docs/en_US/edgex/edgex_meta.md) When the device service sends data to the bus, some additional information is also sent, such as creation time and id. If you want to use this information in SQL statements, please refer to this article.
- [EdgeX Message Bus Sink](https://github.com/emqx/kuiper/blob/master/docs/en_US/rules/sinks/edgex.md): This document describes how to use the EdgeX message bus sink. If you want to send the analysis results to the message bus, you may be interested in this article.

For more information on the EMQ X Kuiper project, please refer to the following resources.

- [Kuiper Github Code library](https://github.com/emqx/kuiper/)
- [Kuiper Reference](https://github.com/emqx/kuiper/blob/master/docs/en_US/reference.md)
