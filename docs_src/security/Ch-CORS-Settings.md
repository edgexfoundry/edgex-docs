# CORS settings

!!! edgey "EdgeX 2.1"
    New for EdgeX 2.1 is the ability to enable CORS access to EdgeX microservices through configuration. 

The EdgeX microservices provide REST APIs and those services might be called from a GUI through a browser. Browsers prevent service calls from a different origin, making it impossible to host a management GUI on one domain that manages an EdgeX device on a different domain. Thus, EdgeX supports Cross-Origin Resource Sharing (CORS) since Jakarta release (v2.1), and this feature can be controlled by the configurations. The default behavior of CORS is disabled. Here is a good reference to understand [CORS](https://web.dev/cross-origin-resource-sharing/).

!!! note
    C Device SDK doesn't support CORS, and enabling CORS in Device Services is not recommended because browsers should not access Device Services directly.

## Enabling CORS

There are two different ways to enable CORS depending on whether EdgeX is deployed in the security-enabled configuration.
In the non-security configuration, EdgeX microservices are directly exposed on host ports.
EdgeX microservices receive client requests directly in this configuration, and thus,
the EdgeX microservices themselves must respond to CORS requests.
In the security-enabled configuration,
EdgeX microservices are exposed behind an API gateway
that will receive CORS requests first.
Only authenticated calls will be forwarded to the EdgeX microservice,
but CORS pre-flight requests are always unauthenticated.

CORS can be enabled at the API gateway in a security-enabled configuration,
and at the individual microservice level in the non-security configuration.
However, implementers should choose one or the other, not both.

### Enabling CORS for Individual Microservices

Configure CORS in the `Service.CORSConfiguration` configuration section for each microservice to be exposed via CORS.  They can also be set via `Service_CORSConfiguration_*` environment variables.
Please refer to the [Common Configuration](../microservices/configuration/CommonConfiguration.md/#configuration-properties) page to learn the details.

### Enabling CORS for API Gateway

Configure CORS in the `CORSConfiguration` configuration section for the `security-proxy-setup` microservice.
They can also be set via `CORSConfiguration_*` environment variables.

!!! note
    The settings under the CORSConfiguration configuration section are the same as those under the Service.CORSConfiguration so please refer to the [Common Configuration](../microservices/configuration/CommonConfiguration.md/#configuration-properties) page to learn the details.

!!! note
    The name of the configuration sections and environment variable overrides are intentionally different than the API gateway section, in alignment with the guidance that CORS should be enabled at the microservice level or the API gateway level, but not both.

