# NAME

security-file-token-provider -- Generate Vault tokens for EdgeX services

# SYNOPSIS

security-file-token-provider \[-h\--configDir \<configDir\>\]
\[-p\|\--profile \<name\>\]

!!! edgey "EdgeX 3.0"
    The `--confdir` command line option is replaced by `--configDir` in EdgeX 3.0.

# DESCRIPTION

security-file-token-provider generates per-service Vault tokens for
EdgeX services so that they can make authenticated connections to Vault
to retrieve application secrets. security-file-token-provider implements
a generic secret seeding mechanism based on pre-created files and is
designed for maximum portability. security-file-token-provider takes a
configuration file that specifies the services for which tokens shall be
generated and the Vault access policy that shall be applied to those
tokens. security-file-token-provider assumes that there is some
underlying protection mechanism that will be used to prevent EdgeX
services from reading each other's tokens.

# OPTIONS

> -h, \--help
>
> :   Display help text
>
> -cd, \--configDir \<configDir\>
>
> :   Look in this directory for configuration.yaml instead.
>
> -p, \--profile \<name\>
>
> :   Indicate configuration profile other than default

!!! edgey "EdgeX 3.0"
    The `-c, --confdir` command line option is replaced by `-cd, --configDir` in EdgeX 3.0.

# FILES

## configuration.yaml

This file specifies the TCP/IP location of the Vault service and
parameters used for Vault token generation.

    SecretService:
      Scheme: "https"
      Server: "localhost"
      Port: 8200 

    TokenFileProvider:
      PrivilegedTokenPath: "/run/edgex/secrets/security-file-token-provider/secrets-token.json"
      ConfigFile: "token-config.json"
      OutputDir: "/run/edgex/secrets/"
      OutputFilename: "secrets-token.json"

## secrets-token.json

This file contains a token used to authenticate to Vault. The filename
is customizable via *OutputFilename*.

    {
      "auth": {
        "client_token": "s.wOrq9dO9kzOcuvB06CMviJhZ"
      }
    }

## token-config.json

This configuration file tells security-file-token-provider which tokens
to generate.

In order to avoid a directory full of `.hcl` files, this
configuration file uses the JSON serialization of HCL, documented at
<https://github.com/hashicorp/hcl/blob/master/README.md>.

Note that all paths are keys under the "path" object.

    {
      "service-name": {
        "edgex_use_defaults": true,
        "custom_policy": {
          "path": {
            "secret/non/standard/location/*": {
              "capabilities": [ "list", "read" ]
            }
          }
        },
        "custom_token_parameters": { }
      }
    }

When edgex-use-default is true (the default), the following is added to
the policy specification for the auto-generated policy. The
auto-generated policy is named `edgex-secrets-XYZ` where `XYZ` is
`service-name` from the JSON key above. Thus, the final policy created
for the token will be the union of the policy below (if using the
default policy) plus the `custom_policy` defined above.

    {
      "path": {
        "secret/edgex/service-name/*": {
          "capabilities": [ "create", "update", "delete", "list", "read" ]
        }
      }
    }

When edgex-use-default is true (the default), the following is inserted
(if not overridden) to the token parameters for the generated token.
(See
<https://openbao.org/api-docs/auth/token/#create-token>.)

    "display_name": token-service-name
    "no_parent":    true
    "policies":     [ "edgex-service-service-name" ]

Note that `display_name` is set by edgex secret store to be "token-" + the
specified display name. This is hard-coded in Vault from versions 0.6 to
1.2.3 and cannot be changed.

Additionally, a meta property, `edgex-service-name` is set to
`service-name`. The edgex-service-name property may be used by clients
to infer the location in the secret store where service-specific secrets
are held.

    "meta": {
      "edgex-service-name": service-name
    }

## {OutputDir}/{service-name}/{OutputFilename}

For example:
`/run/edgex/secrets/edgex-security-proxy-setup/secrets-token.json`

For each "service-name" in `{ConfigFile}`, a matching directory is
created under `{OutputDir}` and the corresponding Vault token is stored
as `{OutputFilename}`. This file contains the authorization token
generated to allow the indicated EdgeX service to retrieve its secrets.

# PREREQUISITES

`PrivilegedTokenPath` points to a non-expired Vault token that the
security-file-token-provider will use to install policies and create
per-service tokens. It will create policies with the naming convention
`"edgex-service-service-name"` where `service-name` comes from JSON keys
in the configuration file and the Vault policy will be configured to
allow creation and modification of policies using this naming
convention. This token must have the following policy
(`edgex-privileged-token-creator`) configured.

    path "auth/token/create" {
      capabilities = ["create", "update", "sudo"]
    }

    path "auth/token/create-orphan" {
      capabilities = ["create", "update", "sudo"]
    }

    path "auth/token/create/*" {
      capabilities = ["create", "update", "sudo"]
    }

    path "sys/policies/acl/edgex-service-*"
    {
      capabilities = ["create", "read", "update", "delete" ]
    }

    path "sys/policies/acl"
    {
      capabilities = ["list"]
    }

# AUTHOR

EdgeX Foundry \<<info@edgexfoundry.org>\>
