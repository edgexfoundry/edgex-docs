# Authenticating to EdgeX Microservices

!!! edgey "EdgeX 3.0"
    Microservice-level authentication is new for EdgeX 3.0.

## Introduction

Starting in EdgeX 3.0, when EdgeX is run in secure mode,
EdgeX microservices require an authentication token before
they will respond to requests issued over the REST API.
(These changes are detailed in the
[EdgeX microservice authentication ADR](../design/adr/security/0028-authentication.md)
and were introduced to mitigate against certain threats
that originate from behind the API gateway or have somehow bypassed the API gateway.)

Prior to EdgeX 3.0, requests that originated remotely
were authenticated at the API gateway via an HTTP `Authorization`
header that contained a JWT bearer token.
Internally-originated requests required no authentication.
In EdgeX 3.0, the `Authorization` header is **additionally** checked
at the microservice level on a per-route basis,
where the majority of URL paths require authentication.

## How to Make Authenticated EdgeX Calls

In order to make an authenticated EdgeX service call,
an EdgeX service must have a secret store token issued
by the EdgeX secret store.

The [Configuring Add-on Services](./Ch-Configuring-Add-On-Services.md)
chapter contains details on what is required to
enroll a new microservice into EdgeX,
for the purpose of obtaining a secret store token.

From this point forward, it is assumed that the calling code
has a valid secret store token obtained using the above process.

### Remotely - API Gateway

The [API gateway](./Ch-APIGateway.md) chapter explains how
to make authenticated requests through the API gateway.
While it is possible to make internal requests through the API gateway,
such requests must be made via TLS-encrypted HTTP,
which requires additional configuration on both the client and server side.
Specifically, the clients must know the external hostname of the API gateway,
which may be unique per EdgeX deployment,
and be configured to trust the API gateway TLS certificate.

In non-secure mode of EdgeX, the API gateway is not started.


### Authenticating to EdgeX Microservice - Full Flow using Curl CLI

Various use cases require hand-crafting
authenticated calls to EdgeX microservices
using command-line utilities such as `curl` or `postman`.

This example will walk through the following steps,
using `curl` as the example HTTP client:

1. Creating a user identity
2. Obtaining a JWT authentication token
3. Using the JWT to call an EdgeX API

The example will be done in the Docker environment.
The docker network architecture is illustrated below:

![Network diagram](authentication-network.jpg)

It is assumed for these examples that the caller is on the host network.
The API gateway is exposed to both internal an external callers.
The EdgeX secret store and some EdgeX service
are exposed on the docker network and on localhost,
and this directly callable from a host command prompt.

#### 1. Creating a User Identity

Let use first set a shell variable to hold a username:

```shell
username=exampleuser
```

Optional: Delete existing user

```shell
docker exec -ti edgex-security-proxy-setup ./secrets-config proxy deluser --user "${username}" --useRootToken
```

Create new user identity, capture the password.
In this example, the Vault token has a 60 second time-to-live (TTL),
and any JWTs that we create will have a 119 minute TTL.
This is set at the time of account creation.

```shell
password=$(docker exec -ti edgex-security-proxy-setup ./secrets-config proxy adduser --user "${username}" --tokenTTL 60 --jwtTTL 119m --useRootToken | jq -r '.password')
```

#### 2. Obtaining a JWT authentication token

Obtaining a JWT is a multi-step process.
First, obtain a secret store token using the username and password from the previous step.
Second, exchange the secret store token for a JWT.
The secret store token can be discarded or revoked after the JWT is obtained.
(Internally, EdgeX microservices renew their tokens when half of their TTL is remaining, and use the token repeatedly to obtain fresh JWTs.
This behavior is coded into go-mod-bootstrap.)


```shell
vault_token=$(curl -ks "http://localhost:8200/v1/auth/userpass/login/${username}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')

id_token=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/token/${username}" | jq -r '.data.token')

echo "${id_token}"
```

Optionally, if the secret store token (vault_token) isn't expired yet,
it can be used to check the validity of an arbitrary JWT.
This example checks the validity of the JWT that was issued above.
Any JWT that passes this check should be accepted by the API gateway
as well as any authenticated EdgeX microservice call.

```shell
introspect_result=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/introspect" -d "{\"token\":\"${id_token}\"}" | jq -r '.active')
echo "${introspect_result}"
```

#### 3. Using the JWT to call an EdgeX API

To call an EdgeX service directly from host context,
go directly to the service's localhost-mapped port:

```shell
curl -H"Authorization: Bearer ${id_token}" "http://localhost:59xxx/api/v2/version"
```

It is also possible to call through the API gateway's external interface.
This is done via TLS, and `ca.crt` is the CA certificate that is
used to verify the TLS certificate presented by the API gateway.
Notably, the fault TLS certificate on the API gateway is not trusted
by default, and is assumed to have been replaced with a known certificate.
The text `SERVICENAME` below is the name of the EdgeX service
that is being proxied by the API gateway, such as `core-data`.

```shell
curl --cacert ca.crt -H"Authorization: Bearer ${id_token}" "https://`hostname --fqdn`:8443/SERVICENAME/api/v2/version"
```


### Local Service-to-Service - Using EdgeX Service Clients

The preferred method of making an authenticated
call to an EdgeX microservice is to use
the service proxies configured by go-mod-bootstrap.

Clients are retrieved from the dependency injection container
using the helper functions in 
[clients.go](https://github.com/edgexfoundry/go-mod-bootstrap/blob/main/bootstrap/container/clients.go)
in go-mod-bootstrap.
For example:

```go
import "github.com/edgexfoundry/go-mod-bootstrap/bootstrap/container"

// ... 

commandClient := container.CommandClientFrom(dic.Get)
```

EdgeX methods invoked via the service proxies
automatically authenticate to peer EdgeX microservices
with no additional work needed on the part of the developer.

If EdgeX is run in non-secure mode,
the built-in service clients that are configured in go-mod-bootstrap
gracefully degrade to non-authenticating clients.


### Local Service-to-Service - Using the SecretProvider interface

In the example where two user-provided services directly invoke one-another,
there will be no service client available.
In this case, it is necessary to use go-mod-bootstrap's `SecretProvider`
interface to obtain a JWT.

See the following pseudo-code to add an `Authorization` header
to an outgoing HTTP request, req.

```go

import (
	bootstrapContainer "github.com/edgexfoundry/go-mod-bootstrap/v3/bootstrap/container"
  clientInterfaces "github.com/edgexfoundry/go-mod-core-contracts/v3/clients/interfaces"
  "github.com/edgexfoundry/go-mod-bootstrap/v3/bootstrap/secret"
)


  // Get the SecretProvider from bootstrap's DI container.
  // Internally, this is a wrapper for go-mod-secret's GetSelfJWT()
  secretProvider := bootstrapContainer.SecretProviderFrom(dic.Get)

  // get an instance of the AuthenticationInjector helper
  var jwtSecretProvider clientInterfaces.AuthenticationInjector
  jwtSecretProvider = secret.NewJWTSecretProvider(m.secretProvider)

  // Call the AddAuthenticationData helper method
  // internally, this calls GetSelfJWT() on the SecretProvider
  // to obtain a JWT and adds an Authorization header to the HTTP request
  err := jwtSecretProvider.AddAuthenticationData(req);
```

### Remote Service-to-Service - Using API Gateway

This scenario is not currently supported,
as most services that a remote EdgeX service would need are blocked at the API gateway.
Additionally, the built-in service clients are not reverse-proxy-aware,
and would be dropped at the API gateway due to a lack of a service prefix in the URL.

Instead, adopters should investigate advanced network topologies such as
zero-trust networks, network overlays, network tunnels, or similar solutions
that can create a virtual local network.


## Implementation Notes

Internally, the receiving microservice will call the secret store's
[token introspection endpoint](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#introspect-a-signed-id-token)
to validate incoming JWT's.
Note that as in all things dealing with the EdgeX secret store,
calling the introspection endpoint is also an authenticated call,
and a service must have explicit authorization to invoke this API.

Similarly, explicit authorization is required for a calling microservice
to obtain a JWT to pass as an authentication token.
In the EdgeX implementation, microservices use the
[userpass login](https://developer.hashicorp.com/vault/api-docs/auth/userpass#login)
authentication method to obtain an initial secret store token.
This token is explicitly granted the ability to
[generate a JWT](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#generate-a-signed-id-token).

In the external user scenario of the API gateway,
clients must manually log in to the secret store,
and exchange the resulting token for JWT.
In the internal usage scenario,
EdgeX microservices are typically pre-seeded with a valid JWT,
and obtain a fresh JWT for each outbound microservice call.

There are obvious opportunities for caching to reduce round trips to the EdgeX secret store,
but none have been implemented at this time.
