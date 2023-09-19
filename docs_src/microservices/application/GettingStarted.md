# Getting Started with Application Services

## Types of Application Services

There are two flavors of Applications Service which are `configurable` and `custom`. This section will describe how and when each flavor should be used.

### Configurable

The `App Functions SDK` has a full suite of built-in features that are accessible via configuration when using the `App Service Configurable` service. This service is built using the `App Functions SDK` and uses  configuration profiles to define separate distinct instances of the service. The service comes with a few built in profiles for common use cases, but custom profiles can also be used. If your use case needs can be meet with the built-in functionality then the `App Service Configurable` service is right for you. See the [App Service Configurable](services/AppServiceConfigurable.md) section for more details.

### Custom

Custom Application Services are needed when use case needs can not be meet with just the built-in functionality. This is when you must develop you own custom Application Service use the `App Functions SDK`. Typically this is triggered by the use case needing an custom `Pipeline Function` . See the [App Functions SDK](./ApplicationFunctionsSDK.md) section for all the details on the features you custom Application Service can take advantage of.

### Template

To help accelerate the creation of your custom Application Service the `App Functions SDK` contains a template for new custom Application Services. This template has TODO's in the code and a README that walk you through the creation of your new custom Application Service. See the template [README](https://github.com/edgexfoundry/app-functions-sdk-go/tree/{{edgexversion}}/app-service-template#readme) for more details.

## Triggers

`Triggers` are common to both `Configurable` and `Custom` Application Services. The are the next logical area to get familiar with. See the [Triggers](./Triggers.md) section for more details.

## Configuration

Finally service configuration is very important to understand for both `Configurable` and `Custom` Application Services. The service configuration documentation is broken into two parts. First is the configuration that is common to all EdgeX services and the second is the configuration that is specific to Application Services. See the [Common Configuration](../configuration/CommonConfiguration.md) and [Application Service Configuration](./GeneralAppServiceConfig.md) sections for more details.

