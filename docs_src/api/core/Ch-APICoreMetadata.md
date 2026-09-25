# Core Metadata

The Core Metadata microservice includes the device/sensor metadata database
and APIs to expose this database to other services. In particular, the
device provisioning service deposits and manages device metadata through
this service's API. See [Core Metadata](../../microservices/core/metadata/Purpose.md) for more details about this service.

## Bypass device service validation when adding a device

The `POST /api/v3/device` endpoint accepts the optional `bypassValidation`
query parameter. It defaults to `false`. Set `?bypassValidation=true` to skip
the Device Service Validation API call when provisioning a device. Core
Metadata still checks the device service, profile, name, and capacity before
adding the device. The request body remains an array of device requests.

## Swagger

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/edgex-go/{{edgexversion}}/openapi/core-metadata.yaml"/>
