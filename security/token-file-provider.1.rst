NAME
====
token-file-provider – Generate Vault tokens for EdgeX services


SYNOPSIS
========
token-file-provider [-h|-help] [-confdir confdir]


DESCRIPTION
===========
token-file-provider generates per-service Vault tokens for EdgeX services
so that they can make authenticated connections to Vault to retrieve
application secrets.
token-file-provider implements a generic secret seeding mechanism based
on pre-created files and is designed for maximum portability.
token-file-provider takes a configuration file that specifies the services
for which tokens shall be generated and the Vault access policy
that shall be applied to those tokens.
token-file-provider assumes that there is some underlying protection mechanism
that will be used to prevent EdgeX services from reading each other’s tokens.


OPTIONS
=======
  \-h
    Display help text

  \-help
    Display help text

  \-confdir confdir
    Look in this directory for configuration.toml instead.


FILES
=====

configuration.toml
------------------
This file specifies the TCP/IP location of the Vault service
and parameters used for Vault token generation.

::

  [SecretService]
  Server = "localhost"
  Port = 8200 

  [TokenFileProvider]
  PrivilegedTokenPath = /run/edgex/secrets/token-file-provider/vault-token.json
  ConfigFile = token-config.json
  OutputDir = /run/edgex/secrets/
  OutputFilename = vault-token.json


vault-token.json
----------------
This file contains a token use to authenticate to Vault.

::

  {
    "auth": {
      "client_token": "s.wOrq9dO9kzOcuvB06CMviJhZ"
    }
  }


token-config.json
-----------------
This configuration file tells token-file-provider which tokens to generate.

::

  {
    "service-name": {
      "edgex-use-defaults": true,
      "custom_policy": [
        {
          "path": {
            "secret/edgex/pki/tls/edgex-kong": {
              "capabilities": [ "list", "read" ]
            }
          }
        }
      ],
      "custom_token_parameters": { }
    }
  }


When edgex-use-default is true (the default),
the following is appended to the policy array for the generated token:

::

  {
    "path": {
      "secret/edgex/service-name/*": {
        "capabilities": [ "create", "update", "delete", "list", "read" ]
      }
    }
  }

When edgex-use-default is true (the default),
the following is inserted (if not overridden) to the token parameters for the generated token.
(See https://www.vaultproject.io/api/auth/token/index.html#create-token.)

::

  "display_name": service-name
  "no_parent":    true
  "policies":     [ "edgex-service-service-name" ]


{OutputDir}/{service-name}/{OutputFilename}
-------------------------------------------
For example: ``/run/edgex/secrets/edgex-kong/vault-token.json``

For each "service-name" in ``{ConfigFile}``,
a matching directory is created under ``{OutputDir}``
and the corresponding Vault token in stored as ``{OutputFilename}``.
This file contains the Vault token generated
to allow the indicated EdgeX service to retrieve its Vault secrets.


PREREQUISITES
=============
``PrivilegedTokenPath`` points to a non-expired Vault token that the token-file-provider
will use to install policies and create per-service tokens.
It will create policies with the naming convention ``"edgex-service-service-name"``
where ``service-name`` comes from JSON keys in the configuration file and the Vault policy
will be configured to allow creation and modification of policies using this naming convention.
This token must have the following policy (``edgex-privileged-token-creator``) configured.

::

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

AUTHOR
======
EdgeX Foundry <info@edgexfoundry.org>
