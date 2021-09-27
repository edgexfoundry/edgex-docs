# API Gateway

## Introduction

The security API gateway is the single point of entry for all EdgeX REST
traffic. It is the barrier between external clients and the EdgeX
microservices preventing unauthorized access to EdgeX REST APIs. The API
gateway accepts client requests, verifies the identity of the clients,
redirects the requests to correspondent microservice and relays the
results back to the client.  Internally, no authentication is required
for one EdgeX microservice to call another.

The API Gateway provides two HTTP REST management interfaces.
The first (insecure) interface is exposed only to `localhost`:
in snaps, this means it is exposed to any local process.
In Docker, this insecure interface is bound to the Docker container,
and is not reachable from outside of the container.
The second (secure) interface is exposed outside of cluster
on an administative URL sub-path, `/admin` and requires a
specifically-crafted JWT to access.
The management interface offers the means to configure
API routing, as well as client authentication and access control. This
configuration is stored in an embedded database.

KONG (<https://konghq.com/>) is the product underlying the API gateway.
The EdgeX community has added code to initialize the KONG environment,
set up service routes for EdgeX microservices, and add various
authentication/authorization mechanisms including JWT authentication and ACL.

## Start the API Gateway

The API gateway is started by default when using 
the secure version of the Docker Compose files found at
<https://github.com/edgexfoundry/edgex-compose/tree/ireland>.

The command to start EdgeX inclusive of API gateway related services is:

    git clone -b ireland https://github.com/edgexfoundry/edgex-compose
    make run

or

    git clone -b ireland https://github.com/edgexfoundry/edgex-compose
    make run arm64

The API gateway is not started if EdgeX is started with security
features disabled by appending `no-secty` to the previous commands.
This disables **all** EdgeX security features, not just the API gateway.

The API Gateway is provided by the `kong` service.
The `proxy-setup` service is a one-shot service that configures the proxy and then terminates.
`proxy-setup` docker image also contains the `secrets-config` utility to assist
in common configuration tasks.

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

Also, for purposes of the example, the external DNS name of
the API gateway is assumed to be `edge001.example.com`.
The API gateway requires client to support Server Name
Identification (SNI) and that the client connects to the
API gateway using a DNS host name.  The API gateway uses
the host name supplied by the client to determine which
certificate to present to the client.  The API gateway
will continue to serve the default (untrusted) certificate
if clients connect via IP address or do not provide
SNI at all.

Run the following command to install a custom certficate
using the assumptions above:

    docker-compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro --entrypoint /edgex/secrets-config edgex-proxy proxy tls --incert /host/cert.pem --inkey /host/key.pem --snis edge001.example.com

The utility will always add the internal host names,
"localhost" and "kong" to the specified SNI list.

The following command can verify the certificate installation
was successful.

    echo "GET /" | openssl s_client -showcerts -servername edge001.example.com -connect 127.0.0.1:8443


### Configuration of JWT Authentication for API Gateway

When using JWT Authentication, the \[KongAuth\] section needs to be
specified in the configuration file as shown below.  This is the default.

    [KongAuth]
    Name = "jwt"

!!! edgey "EdgeX 2.0"
    The "oauth2" authentication method has been removed in EdgeX 2.0 as JWT-based authentication is resistant to brute-force attacks and does not require storage of a secret in the Kong database.

### Configuration of Adding Microservices Routes for API Gateway

For the current pre-existing Kong routes, they are configured and initialized statically through configuration TOML file specified in `security-proxy-setup` application. This is not sufficient for some other new additional microservices like application services, for example.  Thus, adding new proxy Kong routes are now possibly achieved via the environment variable, `ADD_PROXY_ROUTE`, of service `edgex-proxy` in the docker-compose file.  Here is an example:

```yaml
edgex-proxy:
      ...
    environment:
      ...
      ADD_PROXY_ROUTE: "myApp.http://my-app:56789"
      ...

...

my-app:
   ...
   container_name: myApp
   hostname: myApp
   ...
  
```

The value of `ADD_PROXY_ROUTE` takes a comma-separated list of one or more (at least one) paired additional service name and URL for which to create proxy Kong routes.   The paired specification is given as the following:

    <RoutePrefix>.<TargetRouteURL>

where **RoutePrefix** is the name of service which requests to create proxy Kong route and it is case insensitive; it is the docker network hostname of the service that want to add the proxy Kong route in the docker-compose file if running from docker-compose, for example, `myApp` in this case.

**TargetRouteURL** is the full qualified URL for the target service, like `http://myapp:56789` as it is known on on the network
on which the API gateway is running.  For Docker,
the hostname should match the hostname specified in the
`docker-compose` file.

So as an example, for a single service, the value of `ADD_PROXY_ROUTE` would be:  "`myApp.http://myapp:56789`".

Once `ADD_PROXY_ROUTE` is configured and composed-up successfully, the proxy route then can be accessed the app's REST API via Kong as `https://localhost:8443/myApp/api/v2/...` in the same way you would access the EdgeX service.
You will also need an access token obtained using the documentation below.

## Using API Gateway

### Resource Mapping between EdgeX Microservice and API gateway

If the EdgeX API gateway is not in use, a client can access and use any
REST API provided by the EdgeX microservices by sending an HTTP request
to the service endpoint. E.g., a client can consume the ping endpoint of
the Core Data microservice with curl command like this:

    curl http://<core-data-microservice-ip>:59880/api/v2/ping

Once the API gateway is started and initialized successfully, and all
the common ports for EdgeX microservices are blocked by disabling the
exposed external ports of the EdgeX microservices through updating the
docker compose file, the EdgeX microservice will be behind the gateway.
At this time both the microservice host/IP Address
(\<core-data-microservice-ip\> in the example) as well as the service
port (59880 in the example) are not available to external access. EdgeX
uses the gateway as a single entry point for all the REST APIs. With the
API gateway in place, the curl command to ping the endpoint of the same
Core Data service, as shown above, needs to change to:

    curl https://<api-gateway-host>:8443/core-data/api/v2/ping

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
    Note that for Kong to serve the proper TLS certificate,
    a DNS host name must be used as SNI does not support
    IP addresses. This is a standards-compliant behavior,
    not a limitation of Kong.
-   The port of the request is switched from 48080 to 8443, which is the
    default SSL/TLS port for API gateway (versus the micro service
    port). This applies to any client side request.
-   The `/core-data/` path in the URL is used to identify which EdgeX
    micro service the request is routed to. As each EdgeX micro service
    has a dedicated service port open that accepts incoming requests,
    there is a mapping table kept by the API gateway that maps paths to
    micro service ports. A partial listing of the map between ports and
    URL paths is shown in the table below.

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

The API gateway is configured to require authentiation prior to
passing a request to a back-end microservice.

It is necessary to create an API gateway user in order to
satify the authentication requirement.  Gateway users
are created using the proxy subcommand of the
[secrets-config](secrets-config-proxy.md)
utility.

#### JWT authentication

JWT authentication is based on a public/private keypair,
where the public key is registered with the API gateway,
and the private key is kept secret.  This method does not
require exposing any secret to the API gateway and
allows JWTs to be generated offline.

Before using the JWT authentiation method,
it is necessary to create a public/private keypair.
This example uses ECDSA keys, but RSA key can be used as well.

    openssl ecparam -name prime256v1 -genkey -noout -out ec256.key
    openssl ec -out ec256.pub < ec256.key

Next, generate and save a unique ID that will be used in
any issued JWTs to look up the public key to be used for validation.
Also we need the JWT used to authenticate to Kong--this JWT
was written to host-based secrets area when the framework was started.
(Note the backtick to capture the uuidegen output.)

    ID=`uuidgen`
    KONGJWT=`sudo cat /tmp/edgex/secrets/security-proxy-setup/kong-admin-jwt`

Register a user for that key:

    docker-compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy adduser --token-type jwt --id "$ID" --algorithm ES256 --public_key /host/ec256.pub --user _SOME_USERNAME_ --jwt "$KONGJWT"

Lastly, generate a valid JWT.  Any JWT library should work,
but secrets-config provides a convenient utility:

    docker-compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy jwt --id "$ID" --algorithm ES256 --private_key /host/ec256.key

The command will output a long alphanumeric sequence of the format

    <alphanumeric> '.' <alphanumeric> '.' <alphanumeric>

The access token is used in the Authorization header of the request
(see details below).

To de-authorize or delete the user:

    docker-compose -p edgex -f docker-compose.yml run --rm -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy deluser --user _SOME_USERNAME_ --jwt "$KONGJWT"


### Using API Gateway to Proxy Existing EdgeX Microservices

Once the resource mapping and access token to API gateway are in place,
a client can use the access token to use the protected EdgeX REST API
resources behind the API gateway. Again, without the API Gateway in
place, here is the sample request to hit the ping endpoint of the EdgeX
Core Data microservice using curl:

    curl http://<host-system-ip>:59880/api/v2/ping

With the security service and JWT authentication is enabled, the command
changes to:

    curl -k --resolve kong:8443:127.0.0.1 -H 'Authorization: Bearer <JWT>' https://kong:8443/core-data/api/v2/ping

(Note the above `--resolve` line forces "kong" to resolve to 127.0.0.1.
This is just for illustrative purposes to force SNI. In practice,
the TLS certificate would be registered under the external host name.)

In summary the difference between the two commands are listed below:

-   --resolve tells curl to resolve https://kong:8443 to
    the loopback address.  This will cause curl to use the
    hostname `kong` as the SNI, but connect to the specified IP
    address to make the connection.
    -k tells curl to ignore certificate errors. This is for
    demonstration purposes. In production, a known certificate that
    the client trusts be installed on the proxy and this parameter omitted.
-   --H "host: edgex" is used to indicate that the request is for
    EdgeX domain as the API gateway could be used to take requests for
    different domains.
-   Use the https versus http protocol identifier for SSL/TLS secure
    communication.
-   The service port 8443 is the default TLS service port of API gateway
-   Use the URL path "coredata" to indicate which EdgeX microservice
    the request is routed to
-   Use header of -H "Authorization: Bearer \<access-token\>" to
    specify the access token associated with the client that was
    generated when the client was added.


### Adjust Kong worker processes to optimize the performance

The number of the Kong worker processes would impact the memory consumption and the API Gateway performance.  
In order to reduce the memory consumption, the default value of it in EdgeX Foundry is one instead of auto (the original default value). 
This setting is defined in the environment variable section of the docker-compose file.
```
KONG_NGINX_WORKER_PROCESSES: '1'
```
Users can adjust this value to meet their requirement, or remove this environment variable to adjust it automatically.
Read the references for more details about this setting: 

-   <https://docs.konghq.com/gateway-oss/2.5.x/configuration/#nginx_worker_processes>
-   <http://nginx.org/en/docs/ngx_core_module.html#worker_processes>

