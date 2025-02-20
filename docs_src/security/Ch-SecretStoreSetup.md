# Secret Store Setup

## Introduction

In an EdgeX deployment, the security-secretstore-setup service initializes the secret store, generates tokens for each EdgeX service to access it, and securely stores their respective secrets and credentials within the secret store.

The secret store token is periodically renewed to maintain seamless access to the secret store for each service. However, renewal occurs only if the corresponding EdgeX service is actively running and responsive.
If the secret store token expires, the only way to regenerate it is by restarting the security-secretstore-setup service for the respective EdgeX service.

Starting in EdgeX 4.0, the security-secretstore-setup service transitions to a long running service, introducing a new **regenerate token** REST API that enables the regeneration of secret store tokens for EdgeX services upon expiration.
If an EdgeX service's secret store token expires, restarting the service will automatically trigger the **regenerate token** API, allowing the service to successfully regain access to the secret store.

!!! edgey "EdgeX 4.0"
    security-secretstore-setup **regenerate token** API is new for EdgeX 4.0.

## Secret Store Setup - API Reference

<swagger-ui src="https://raw.githubusercontent.com/edgexfoundry/edgex-go/{{edgexversion}}/openapi/security-secretstore-setup.yaml"/>
