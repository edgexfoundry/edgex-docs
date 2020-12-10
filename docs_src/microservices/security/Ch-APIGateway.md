# API Gateway

The security API gateway is the single point of entry for all EdgeX REST
traffic. It is the barrier between external clients and the EdgeX
microservices preventing unauthorized access to EdgeX REST APIs. The API
gateway accepts client requests, verifies the identity of the clients,
redirects the requests to correspondent microservice and relays the
results back to the client.

The API Gateway provides an HTTP REST interface for administration
management. The administrative management offers the means to configure
API routing, as well as client authentication and access control. This
configuration is store in an embedded database.

KONG (<https://konghq.com/>) is the product underlying the API gateway.
The EdgeX community has added code to initialize the KONG environment,
set up service routes for EdgeX microservices, and add various
authentication/authorization mechanisms including JWT authentication,
OAuth2 authentication and ACL.

## Start the API Gateway

Start the API gateway with Docker Compose and a Docker Compose manifest
file (the Docker Compose file named `docker-compose.yml` (or -arm64 variants) found at
<https://github.com/edgexfoundry/edgex-compose/tree/master>,
on a branch appropriate for the release of EdgeX that you are using).
This Compose file starts all of EdgeX including the security services.
The command to start EdgeX inclusive of API gateway related services is:
:

    docker-compose -p edgex -f docker-compose.yml up -d

For debugging purpose, the API gateway services can be started
individually with these commands used in sequence after secret store
starts successfully. Lines starts with \# are comments to explain the
purpose of the command. :

    docker-compose -p edgex -f docker-compose.yml up -d kong-db
    # start up backend database for API gateway

    docker-compose -p edgex -f docker-compose.yml up -d kong-migrations
    # initialize the backend database for API gateway

    docker-compose -p edgex -f docker-compose.yml up -d kong
    # start up KONG the major component of API gateway

    docker-compose -p edgex -f docker-compose.yml up -d edgex-proxy
    # initialize KONG, configure proxy routes, apply certificates to routes, and enable various authentication/ACL features. 

If the last command returns an error message for any reason (such as
incorrect configuration file), the API gateway may be in an unstable
status. The following command can be used to stop and remove the
containers. :

    docker-compose -p edgex -f docker-compose.yml down
    # stop and remove the containers

After stopping and removing the containers, you can attempt to recreate
and start them again. Alternatively you can use the command to reset the
API gateway as shown below: :

    docker run –network=edgex-network edgexfoundry/docker-edgex-proxy-go --reset=true 

After issuing the reset command, attempt to start and reinitialize with
the command below. :

    docker run –network=edgex-network edgexfoundry/docker-edgex-proxy-go --init=true 

You can learn more about these commands, to include some additional
options by running: :

    docker run –network=edgex-network edgexfoundry/docker-edgex-proxy-go –h 

On successfully starting EdgeX with the API Gateway services, the list
of running containers should close follow the listing shown below. Note
key security service containers like kong, kong-db, edgex-vault are
listed.

![image](Running.Security.png)

## Configuring API Gateway

The API gateway supports two different forms of authentication: JSON Web
Token (JWT) or OAuth2 Authentication. Only one authentication method can
be enabled at a time. The API Gateway also supports an Access Control
List (ACL) which can be enabled with one of the authentication methods
mentioned earlier for fine control among the groups. The authentication
and ACL need to be specified in the API gateway's configuration file.
Setup of authentication and access control occurs automatically as part
of API gateway initialization. The configuration file can be found at
<https://github.com/edgexfoundry/edgex-go/blob/master/cmd/security-proxy-setup/res/configuration.toml>

**Configuration of JWT Authentication for API Gateway**

When using JWT Authentication, the \[KongAuth\] section needs to be
specified in the configuration file as shown below. :

    [KongAuth]
    Name = "jwt"

**Configuration of OAuth2 Authentication for API Gateway**

When using OAuth2 Authentication, the \[KongAuth\] section needs to
specify oauth2 in the configuration file as shown below. Note, today
EdgeX only supports "client credential" authentication (specified in
"granttype") currently for OAuth.

    [kongauth]
    name = "oauth2"
    scopes = "email,phone,address"
    mandatoryscope = "true"
    enableclientcredentials = "true"
    clientid = "test"
    clientsecret = "test"
    redirecturi = "http://edgex.com"
    granttype = "client_credentials"
    scopegranted = "email"
    resource = "coredata"

**Configuration of ACL for API Gateway**

Access control is also specified in the configuration file as shown
below. Note, users that belong to the whitelist will have access to the
resources of EdgeX, and users not belonging to the group listed here
will be denied when trying to access resources through the API Gateway.
:

    [kongacl]
    name = "acl"
    whitelist = "admin,user"

**Configuration of Adding Microservices Routes for API Gateway**

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

**\<RoutePrefix\>.\<TargetRouteURL\>**

where **RoutePrefix** is the name of service which requests to create proxy Kong route and it is case insensitive; it is the docker network hostname of the service that want to add the proxy Kong route in the docker-compose file if running from docker-compose, for example, `myApp` in this case.

**TargetRouteURL** is the full qualified URL for the target service, like `http://my-app:56789`

So as an example, for a single service, the value of `ADD_PROXY_ROUTE` would be:  "`myApp.http://my-app:56789`".

Once `ADD_PROXY_ROUTE` is configured and composed-up successfully, the proxy route then can be accessed the app's REST API via Kong as `http://localhost:8000/myApp/api/v1/...` in the same way you would access the edgex service in which you will also need an access token and it is using default access role if not specified in the TOML configuration file as well.

## Using API Gateway

**Resource Mapping between EdgeX Microservice and API gateway**

If the EdgeX API gateway is not in use, a client can access and use any
REST API provided by the EdgeX microservices by sending an HTTP request
to the service endpoint. E.g., a client can consume the ping endpoint of
the Core Data microservice with curl command like this: :

    curl http://<core-data-microservice-ip>:48080/api/v1/ping

Once the API gateway is started and initialized successfully, and all
the common ports for EdgeX microservices are blocked by disabling the
exposed external ports of the EdgeX microservices through updating the
docker compose file, the EdgeX microservice will be behind the gateway.
At this time both the microservice host/IP Address
(\<core-data-microservice-ip\> in the example) as well as the service
port (48080 in the example) are not available to external access. EdgeX
uses the gateway as a single entry point for all the REST APIs. With the
API gateway in place, the curl command to ping the endpoint of the same
Core Data service, as shown above, needs to change to : :

    curl https://<api-gateway-host-ip>:8443/coredata/api/v1/ping

Comparing these two curl commands you may notice several differences.

-   "Http" is switched to "https" as we enable the SSL/TLS for secure
    communication. This applies to any client side request.
-   The EdgeX microservice IP address where the request is sent changed
    to the host/IP address of API gateway service (recall the API
    gateway becomes the single entry point for all the EdgeX micro
    services). The API gateway will eventually lateral the request to
    the Core Data service if the client is authorized.
-   The port of the request is switched from 48080 to 8443, which is the
    default SSL/TLS port for API gateway (versus the micro service
    port). This applies to any client side request.
-   The "/coredata/" path in the URL is used to identify which EdgeX
    micro service the request is routed to. As each EdgeX micro service
    has a dedicated service port open that accepts incoming requests,
    there is a mapping table kept by the API gateway that maps paths to
    micro service ports. A partial listing of the map between ports and
    URL paths is shown in the table below.

------------------------------------------------------------------------

  ------------------------- ------------- ----------------
  EdgeX microservice Name   Port number   Partial URL

  coredata                  48080         coredata

  metadata                  48081         metadata

  command                   48082         command

  notifications             48060         notifications

  supportlogging            48061         supportlogging
  ------------------------- ------------- ----------------

------------------------------------------------------------------------

**Creating Access Token for API Gateway Authentication**

The API gateway is configured to require authentiation prior to
passing a request to a back-end microservice.

It is necessary to create an API gateway user in order to
satify the authentication requirement.  Gateway users
are created using the proxy subcommand of the
[secrets-config](secrets-config-proxy.1.md)
utility.

There are two ways to create a user, depending on how the API
gateway is configured.

**OAuth2 method**

Before we begin, we need the JWT used to authenticate to Kong--this JWT
was written to host-based secrets area when the framework was started.
(Note the backtick to capture the output.)

    KONGJWT=`sudo cat /tmp/edgex/secrets/security-proxy-setup/kong-admin-jwt`

For OAuth2, a client ID and client secret are required:

    docker-compose -p edgex -f docker-compose.yml run --rm --entrypoint "/edgex/secrets-config" proxy-setup -- proxy adduser --token-type oauth2 --user _SOME_USERNAME_ --client_id _SOME_IDENTIFIER_ --client_secret _VERY_LONG_PASSWORD_ --group gateway --jwt "$KONGJWT"

User creation need only be done once.  Afterwards,
an access token can be generated from the token endpoint on
the API gateway.

    curk -k https://localhost:8443/{service}/oauth2/token -d "grant_type=client_credentials" -d "scope=" -d "client_id=_SOME_IDENTIFIER_" -d "client_secret=_VERY_LONG_PASSWORD_"

The secrets-config utility also contains a helper function
to do the above:

    docker-compose -p edgex -f docker-compose.yml run --rm --entrypoint /edgex/secrets-config edgex-proxy proxy oauth2 --client_id _SOME_IDENTIFIER_ --client_secret _VERY_LONG_PASSWORD_

The token is output to standard output.  For example:

    MNsBh6jDDSxaECzUtimW1nDSvI2v0xsZ

The access token is used in the Authorization header of the request
(see details below).

To de-authorize or delete the user:

    docker-compose -p edgex -f docker-compose.yml run --rm --entrypoint "/edgex/secrets-config" proxy-setup -- proxy deluser --user _SOME_USERNAME_ --jwt "$KONGJWT"

**JWT method (default)**

By default, the API gateway is configured for JWT authentication.

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

    docker-compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy adduser --token-type jwt --id "$ID" --algorithm ES256 --public_key /host/ec256.pub --user _SOME_USERNAME_ --group gateway --jwt "$KONGJWT"

Lastly, generate a valid JWT.  Any JWT library should work,
but secrets-config provides a convenient utility:

    docker-compose -p edgex -f docker-compose.yml run --rm -v `pwd`:/host:ro -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy jwt --id "$ID" --algorithm ES256 --private_key /host/ec256.key

The command will output a long alphanumeric sequence of the format

    <alphanumeric> '.' <alphanumeric> '.' <alphanumeric>

The access token is used in the Authorization header of the request
(see details below).

To de-authorize or delete the user:

    docker-compose -p edgex -f docker-compose.yml run --rm -u "$UID" --entrypoint "/edgex/secrets-config" proxy-setup -- proxy deluser --user _SOME_USERNAME_ --jwt "$KONGJWT"


**Using API Gateway to Proxy Existing EdgeX Microservices**

Once the resource mapping and access token to API gateway are in place,
a client can use the access token to use the protected EdgeX REST API
resources behind the API gateway. Again, without the API Gateway in
place, here is the sample request to hit the ping endpoint of the EdgeX
Core Data microservice using curl: :

    curl http://<core-data-microservice-ip>:48080/api/v1/ping

With the security service and JWT authentication is enabled, the command
changes to: :

    curl -k --resolve kong:8443:127.0.0.1 -H 'Authorization: Bearer <JWT>' https://kong:8443/coredata/api/v1/ping

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

The format for OAuth2 authentication is similar. For OAuth2 use the
bearer token from OAuth2 authentication instead of the JWT token. Here
is an example of the curl command using OAuth2: :

    curl -k --resolve kong:8443:127.0.0.1 -H 'Authorization: Bearer <access-token>' https://kong:8443/coredata/api/v1/ping

**Using a bring-your-own external TLS certificate for API gateway**

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
