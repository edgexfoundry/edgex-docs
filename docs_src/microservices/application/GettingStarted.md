# Application Services - Getting Started

## Types of Application Services

There are two flavors of Applications Service which are `configurable` and `custom`. This section will describe how and when each flavor should be used.

### Configurable

The `App Functions SDK` has a full suite of built-in pipeline functions that are accessible via configuration when using the `App Service Configurable` service. This service is built using the `App Functions SDK` and uses  configuration profiles to define separate distinct instances of the service. The service comes with a few built in profiles for common use cases, but custom profiles can also be used. If your use case needs can be meet with the built-in functionality then the `App Service Configurable` service is right for you. See the [App Service Configurable](services/AppServiceConfigurable/Purpose.md) section for more details.

### Custom

Custom Application Services are needed when use case needs can not be meet with just the built-in functionality. This is when you must develop you own custom Application Service using the **App Functions SDK**. Typically, this is triggered by the use case needing a custom pipeline function to process the data in a way not provided by the **App Functions SDK**. See the [App Functions SDK](sdk/Purpose.md) section for all the details on the features your custom Application Service can take advantage of.

## Template

To help accelerate the creation of your new custom Application Service the **App Functions SDK** contains a template for new custom Application Services. This template has TODOs in the code and a README that walk you through the creation of your new custom Application Service. See the template [README](https://github.com/edgexfoundry/app-functions-sdk-go/tree/{{edgexversion}}/app-service-template#readme) for more details.

## Triggers

`Triggers` are common to both `Configurable` and `Custom` Application Services. They are the next logical area to get familiar with. See the [Triggers](sdk/details/Triggers.md) section for more details.

## Configuration

Service configuration is very important to understand for both **Configurable** and **Custom** Application Services. The application service configuration documentation is broken into three parts. First is the configuration that is common to all EdgeX services, second is the configuration that is common to all Application Services and third is the configuration for **App Service Configurable**. See the following sections for more details on each: 

- [EdgeX Common Configuration](../configuration/CommonConfiguration.md) 
- [Application Service Common Configuration](Configuration.md)
- [App Service Configurable Configuration](services/AppServiceConfigurable/Configuration.md)

## Examples

The are many example custom application services that are a great place to start getting familiar with Application Services. See [Application Service Examples](../../examples/AppServiceExamples.md) for the complete list a links. The include an example profile for App Service Configurable.
