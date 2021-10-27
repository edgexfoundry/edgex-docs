# Adding EdgeX API Gateway Users Remotely

!!! edgey "EdgeX 2.1"
    Want to know what's new in EdgeX 2.1 (Jakarta)?  If you are already familiar with EdgeX, look for the EdgeX 2.1 emoji (`Edgey` - the EdgeX mascot) throughout the documentation - [like the one on this page](#the-ireland-release) outlining what's in the Ireland release.  These sections will give you a summary of what's new in each area of the documentation.

Starting in EdgeX Ireland, the API gateway administrative interface is exposed by the `/admin` sub-URL of the gateway.
Using this interface, and a special admin-only JWT, it is possible to remotely add gateway users.
Support for this method in `secrets-config` was added in EdgeX Jakarta.

## Pre-requisite: Obtain a Kong Admin JWT

When EdgeX starts, the `security-secretstore-setup` utility creates a special administrative JWT
and writes a Kong configuration file to trust it.
The reasons why this is done here is explained in detail in
`https://github.com/edgexfoundry/edgex-go/blob/main/internal/security/secretstore/init.go`

For security reasons, the created JWT is transient in nature:
the private key used to create it is destroyed after the JWT is generated, 
and a new JWT using a new key is created each time the EdgeX framework is started.
This prevents exfiltration of a private key that could be used
to permanently compromise the security of a given EdgeX host.

If long-term access to the API gateway admin API is desired,
it is left as an excersise to the reader to seed the Kong database with
administrative public key whose private key is not known to the EdgeX framework
and will persist across reboots.
This could be done, for example, by creating a custom EdgeX
microservice that has access to `kong-admin-jwt`
and uses it to seed another user in the `admin` group.
Alternatively, one could override `kong-admin-config.template.yml`
to include an additional user and key.
It is advisable to make such a key unique to the machine (best)
or unique to the deployment (second best).
It is inadvisable to code such a key into source code such
that it would be shared across deployments.

For now, let us make a copy the `kong-admin-jwt`:

```
sudo cp /tmp/edgex/secrets/security-proxy-setup/kong-admin-jwt .
sudo chmod 400 kong-admin-jwt
sudo chown "${USER}:${USER}" kong-admin-jwt
```

## Create ID and Credential for the Gateway User

For the new user, create a unique ID and a public/private keypair to authenticate the user.

```
test -f gateway.id || uuidgen > gateway.id
test -f gateway.key || openssl ecparam -name prime256v1 -genkey -noout -out gateway.key 2> /dev/null
test -f gateway.pub || openssl ec -in gateway.key -pubout -out gateway.pub 2> /dev/null
```

Retain these files, `gateway.id`, `gateway.key`, and `gateway.pub` to create a JWT to access the proxy later.
The `gateway.id` file contains a unique value, in this case, a GUID,
that the gateway uses to look up the public key needed to validate the JWT.


## Create an proxy user and credential

First, let us extract the `secrets-config` utility from an existing EdgeX container.
The utility can also be built from source to the same effect.

```
CORE_EDGEX_VERSION=2.0.0 # Update to verion for Jakarta release
DEV=
PROXY_SETUP_CONTAINER="edgexfoundry/security-proxy-setup:${CORE_EDGEX_VERSION}${DEV}"

docker run --rm --entrypoint /bin/cat "${PROXY_SETUP_CONTAINER}" /edgex/secrets-config > secrets-config
chmod +x secrets-config
test -d res || mkdir res
docker run --rm --entrypoint /bin/cat "${PROXY_SETUP_CONTAINER}" /edgex/res/configuration.toml > res/configuration.toml
```

Then, let us add a user to the gateway.  Note: Currently one must use the string "gateway" as the group.

```
ID=`cat gateway.id`
ADMIN_JWT=`cat kong-admin-jwt`
GW_USER=gateway
GW_GROUP=gateway
export KONGURL_SERVER=<ip address of gateway>
./secrets-config proxy adduser --token-type jwt --id ${ID} --algorithm ES256 --public_key gateway.pub --user "${GW_USER}" --group "${GW_GROUP}" --jwt "${ADMIN_JWT}"
```

## Creating JWTs to access the gateway

The `secrets-config` utility has a helper method to create a JWT from the ID and private key:

By default, the resulting JWT is valid for only one hour.
This can be changed with the `--expiration` flag if needed.

```
ID=`cat gateway.id`
USER_JWT=`./secrets-config proxy jwt --algorithm ES256 --id ${ID} --private_key gateway.key`
```

Use the resulting JWT to call an EdgeX API method through the gateway:

```
curl -k -H "Authorization: Bearer ${USER_JWT}" "https://localhost:8443/core-data/api/v2/ping"
```

Output:
```
{"apiVersion":"v2","timestamp":"Fri Sep  3 00:33:58 UTC 2021"}
```
