# API Gateway

## Introduction

!!! edgey "EdgeX 3.0"
    This content is completely new for EdgeX 3.0.
    EdgeX 3.0 uses a brand new API gateway solution
    based on NGINX and Hashicorp Vault instead of Kong and Postgres.
    The new solution means that EdgeX 3.0 will be
    able to run in security enabled mode on more resource-constrained devices.

API gateways are used in microservice architectures
that expose HTTP-accessible APIs to create a
security layer that separates internal and external callers.
An API gateway accepts client requests,
authenticates the client,
forwards the request to a backend microservice,
and relays the results back to the client.

Although authentication is done at the microservice layer in EdgeX 3.0,
EdgeX Foundry as elected to continue to use an API gateway for the
following reasons:

1. It provides a convenient choke point and policy enforcement point
   for external HTTP requests and enables EdgeX adopters to
   easily replace the default authentication logic.

2. It defers the urgency of implementing fine-grained authorization at
   the microservice layer.

3. It provides defense-in-depth against microservice authentication bugs
   and other technical debt that might otherwise put EdgeX
   microservices at risk.

The API gateway listens on two ports:

* 8000: This is an unencrypted HTTP port exposed to localhost-only
  (also exposed to the edgex-network Docker network).
  When EdgeX is running in security-enabled mode,
  the EdgeX UI uses port 8000 for authenticated
  local microservice calls.

* 8443: This is a TLS 1.3 encrypted HTTP port exposed via
  the host's network interface to external clients.
  The default TLS certificate on this port is untrusted
  by default and should be replaced with a trusted
  certificate for production usage.

EdgeX 3.0 uses NGINX as the API gateway implementation
and delegates to EdgeX's secret store (powered by Hashicorp Vault)
for user and JWT authentication.


## Start the API Gateway

The API gateway is started by default in either
the snap-based EdgeX deployment
or the Docker-based EdgeX deployment
using the Docker Compose files found at
<https://github.com/edgexfoundry/edgex-compose/>.

In Docker, the command to start EdgeX inclusive of API gateway related services is
(where "somerelease" denotes the EdgeX release, such as "jakarta" or "minnesota"):

    git clone -b somerelease https://github.com/edgexfoundry/edgex-compose
    cd edgex-compose
    make run

or

    git clone -b somerelease https://github.com/edgexfoundry/edgex-compose
    cd edgex-compose
    make run arm64

The API gateway is not started if EdgeX is started with security
features disabled by appending `no-secty` to the previous `make` commands.
This disables **all** EdgeX security features, not just the API gateway.


## Configuring API Gateway

### Using a bring-your-own external TLS certificate for API gateway

The API gateway will generate a default self-signed TLS certificate
that is used for external communication.
Since this certificate is not trusted by client software,
it is commonplace to replace this auto-generated certificate
with one generated from a known certificate authority,
such as an enterprise PKI, or a commercial certificate authority.

The process for obtaining a certificate is out-of-scope
for this document.  For purposes of the example,
the X.509 PEM-encoded certificate is assumed to be called `cert.pem`
and the unencrypted PEM-encoded private key is called `key.pem`.
Do not use an encrypted private key as the API gateway
will hang on startup in order to prompt for a password.

Run the following command to install a custom certificate
using the assumptions above:

    docker compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro --entrypoint /edgex/secrets-config proxy-setup proxy tls --inCert /host/cert.pem --inKey /host/key.pem

The following command can verify the certificate installation was successful.

    echo "GET /" | openssl s_client -showcerts -servername edge001.example.com -connect 127.0.0.1:8443

(where `edgex001.example.com` is the hostname by which the client is externally reachable)

The TLS certificate installed in the previous step should be among the output of the `openssl` command.


### Configuration of Adding Microservices Routes for API Gateway

A standard set of routes are configured statically via the `security-proxy-setup` microservice.
Additional routes can be added via the `EDGEX_ADD_PROXY_ROUTE` environment variable.
Here is an example:

```yaml
security-proxy-setup:
      ...
    environment:
      ...
      EDGEX_ADD_PROXY_ROUTE: "app-myservice.http://edgex-app-myservice:56789"
      ...

...

app-myservice:
   ...
   container_name: app-myservice-container
   hostname: edgex-app-myservice
   ...
  
```

The value of `EDGEX_ADD_PROXY_ROUTE` takes a comma-separated list
of one or more paired additional prefix and URL
for which to create proxy routes.
The paired specification is given as the following:

    <RoutePrefix>.<TargetRouteURL>

where **RoutePrefix** is the base path that will be created off of the root
of the API gateway to route traffic to the target.
This should typically be the service key that the app uses to register
with the EdgeX secret store and configuration provider,
as the name of the service in the docker-compose file has
security implications when using delayed-start services.

**TargetRouteURL** is the fullly qualified URL for the target service,
like `http://edgex-app-myservice:56789` as it is known on on the network on which the API gateway is running.
For Docker, the hostname should match the hostname specified in the `docker-compose.yml` file.

For example, using the above `docker-compose.yml`:

```
EDGEX_ADD_PROXY_ROUTE: "app-myservice.http://edgex-app-myservice:56789"
```

When a request to the API gateway is received,
such as `GET https://localhost:8443/app-myservice/api/v3/ping`,
the API gateway will reissue the request as
`GET http://edgex-app-myservice:56789/api/v3/ping`.
Note that the route prefix is stripped
from the re-issued request.

## Using API Gateway

### Resource Mapping between EdgeX Microservice and API gateway

If the EdgeX API gateway is not in use, a client can access and use any
REST API provided by the EdgeX microservices by sending an HTTP request
to the service endpoint. E.g., a client can consume the ping endpoint of
the Core Data microservice with curl command like this:

    curl http://<core-data-microservice-ip>:59880/api/v3/ping

Where `<core-data-microservice-ip>` is the Docker IP address of
the container running the core-data microservice (if using Docker),
or additionally `localhost` in the default configuration for snaps and Docker.
This means that in the default configuration,
EdgeX microservices are only accessible to local host processes.

The API gateway serves as single external endpoint for all the REST APIs.
The curl command to ping the endpoint of the same
Core Data service, as shown above, needs to change to:

    curl https://<api-gateway-host>:8443/core-data/api/v3/ping

Comparing these two curl commands you may notice several differences.

-   `http` is switched to `https` as we enable the SSL/TLS for secure
    communication. This applies to any client side request.
    (If the certificate is not trusted, the `-k` option to `curl`
    may also be required.)
-   The EdgeX microservice IP address where the request is sent changed
    to the host/IP address of API gateway service (recall the API
    gateway becomes the single entry point for all the EdgeX micro
    services). The API gateway will eventually relay the request to
    the Core Data service if the client is authorized.
-   The port of the request is switched from 59880 to 8443, which is the
    default SSL/TLS port for API gateway (versus the micro service
    port). This applies to any client side request.
-   The `/core-data/` path in the URL is used to identify which EdgeX
    micro service the request is routed to. As each EdgeX micro service
    has a dedicated service port open that accepts incoming requests,
    there is a mapping table kept by the API gateway that maps paths to
    micro service ports. A partial listing of the map between ports and
    URL paths is shown in the table below.

Note that any such request issued will be met with an

    401 Not Authorized

response to the lack of an authentication token on the request.
Authentication will be explained later.

The EdgeX documentation maintains an up-to-date list
of [default service ports](../general/ServicePorts.md).


---

  | Microservice Host Name  | Port number | Partial URL           |
  |-------------------------|-------------|-----------------------|
  | edgex-core-data         | 59880       | core-data             |
  | edgex-core-metadata     | 59881       | core-metadata         |
  | edgex-core-command      | 59882       | core-command          |
  | edgex-support-notifications | 59860       | support-notifications |
  | edgex-support-scheduler | 59861       | support-scheduler     |
  | edgex-kuiper            | 59720       | rules-engine          |
  | device-virtual          | 59900       | device-virtual        |

---


### Creating Access Token for API Gateway Authentication

Authentication is more fully explained
in the [authentication chapter](./Ch-Authenticating.md).

The authentication chapter goes into detail on:

* How to create user accounts in the EdgeX secret store
* How to authenticate to the EdgeX secret store remotely
  and obtain a JWT token that will be accepted by the gateway.

The TL;DR version to get an API gateway token,
for development and test purposes, is

    make get-token

(in the edgex-compose repository, if using Docker).

The `get-token` target will return a JWT in the form

    eyJ.... "." base64chars "." base64chars


As a bearer token, it has a limited lifetime for security reasons.
The `get-token` process should be repeated to obtain fresh tokens periodically.
In the long form process described in the
[authentication chapter](./Ch-Authenticating.md),
this means re-authenticating to the EdgeX secret store and requesting a fresh JWT.

EdgeX versions prior to 3.0 used to support
registering a public key with the API gateway,
and allowing clients to self-generate their JWT
for API gateway authentication.
Regrettably, this "raw key JWT" authentication method is no longer supported.
As consolation, the EdgeX secret store backend, Hashicorp Vault,
supports [many other authentication backends](https://developer.hashicorp.com/vault/docs/auth).
EdgeX only enables the `userpass` auth engine by default,
and only passes the `userpass` auth endpoints through the API gateway by default.
Customizing an EdgeX implementation to use alternative authentication methods
is left as an exercise for the adopter.


### Using API Gateway to Proxy Existing EdgeX Microservices

Once the resource mapping and access token to API gateway are in place,
a client can use the access token to use the protected EdgeX REST API
resources behind the API gateway. Again, without the API Gateway in
place, here is the sample request to hit the ping endpoint of the EdgeX
Core Data microservice using curl:

    curl http://<core-data-microservice-ip>:59880/api/v3/ping

With the security service and JWT authentication is enabled, the command
changes to:

    curl -k -H 'Authorization: Bearer <JWT>' https://myhostname:8443/core-data/api/v3/ping


In summary the difference between the two commands are listed below:

-   `-k` tells curl to ignore certificate errors. This is for
    demonstration purposes. In production, a known certificate that
    the client trusts be installed on the proxy and this parameter omitted.
-   Use the https versus http protocol identifier for SSL/TLS secure
    communication.
-   The service port 8443 is the default TLS service port of API gateway
-   Use the URL path "core-data" to indicate which EdgeX microservice
    the request is routed to
-   Use header of `-H "Authorization: Bearer <JWT>"` to
    pass the authentication token as part of the request.

