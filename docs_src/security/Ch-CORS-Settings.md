# CORS settings

The EdgeX microservices provide REST APIs and those services might be called from a GUI through a browser. Browsers prevent service calls from a different origin, making it impossible to host a management GUI on one domain that manages an EdgeX device on a different domain. Thus, EdgeX supports Cross-Origin Resource Sharing (CORS) since Jakarta release (v2.1), and this feature can be controlled by the configurations. The default behavior of CORS is disabled. Here is a good reference to understand [CORS](https://web.dev/cross-origin-resource-sharing/).

!!! Note
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

### Enabling CORS for Microservices

There are two different options to enable CORS. 

- Enable CORS for all services by environment variables override under `core-common-config-bootstrapper` service section on *docker-compose.file*. They can be set via `SERVICE_CORSCONFIGURATION_*` environment variables. 
Please refer to the following example:
!!! example "Example - Set `EnableCORS` to `true` by environment variables override"
    ```yaml
    core-common-config-bootstrapper:
      environment: 
        SERVICE_CORSCONFIGURATION_ENABLECORS: "true"
    ```

- Enable CORS for individual microservices
    1. Add `Service.CORSConfiguration.EnableCORS` via Consul for the targeted service and restart the service.
    2. Add `Service.CORSConfiguration.EnableCORS` to each services private configuration file.

Please refer to the [Common Configuration](../microservices/configuration/CommonConfiguration.md/#configuration-properties) page to learn the details.

### Enabling CORS for API Gateway

The default CORS settings for the API gateway come from the following section in `cat cmd/core-common-config-bootstrapper/res/configuration.yaml` in the `edgex-go` repository

```
all-services:
  Service:
    CORSConfiguration:
      EnableCORS: false
      CORSAllowCredentials: false
      CORSAllowedOrigin: "https://localhost"
      CORSAllowedMethods: "GET, POST, PUT, PATCH, DELETE"
      CORSAllowedHeaders: "Authorization, Accept, Accept-Language, Content-Language, Content-Type, X-Correlation-ID"
      CORSExposeHeaders: "Cache-Control, Content-Language, Content-Length, Content-Type, Expires, Last-Modified, Pragma, X-Correlation-ID"
      CORSMaxAge: 3600
```

In the Docker configuration if the `EDGEX_SERVICE_CORSCONFIGURATION_*` environment variables are set on the `security-proxy-setup` microservice,
the CORS configuration will be applied to **all** microservices (`EDGEX_SERVICE_CORSCONFIGURATION_ENABLECORS=true`).
There is not a way, when using the API gateway, to turn CORS on for one microservice but not another without writing a custom `security-proxy-setup` microservice.

!!! note
    The settings under the CORSConfiguration configuration section are the same as those under the Service.CORSConfiguration so please refer to the [Common Configuration](../microservices/configuration/CommonConfiguration.md/#configuration-properties) page to learn the details.  Note that these overrides are prefixed with `EDGEX_`.

!!! note
    The name of the configuration sections and environment variable overrides are intentionally different than the API gateway section, in alignment with the guidance that CORS should be enabled at the microservice level or the API gateway level, but not both.  Thus, the security-enabled overrides are accomplished with `EDGEX_SERVICE_CORSCONFIGURATION_*` overrides, and the no-security overrides with `SERVICE_CORSCONFIGURATION_*`.

