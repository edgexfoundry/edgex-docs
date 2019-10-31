NAME
====

security-secrets-setup — Creates an on-device public-key infrastructure (PKI) to secure microservice secret management

SYNOPSIS
========

| security-secrets-setup generate [-confdir <confdir>] [-p|--profile <name>]
| security-secrets-setup cache [-confdir <confdir>] [-p|--profile <name>]
| security-secrets-setup import [-confdir <confdir>] [-p|--profile <name>]
| security-secrets-setup [-h|--help]


DESCRIPTION
===========

The Vault secret management component of EdgeX Foundry requires TLS encryption
of secrets over the wire via a pre-created PKI.
security-secrets-setup is responsible for creating a certificate authority
and any needed TLS leaf certificates in order to secure the EdgeX security services.
security-secrets-setup supports several modes of operation as defined in the OPTIONS section.

As the PKI is security-sensitive,
this tool takes a number of precautions to safeguard the PKI:

* The PKI can be deployed to transient storage to address potential attacks to the PKI at-rest.

* The PKI is deployed such that each service has its own assets folder, which is amenable to security controls imposed by container runtimes such as mandatory access controls or file system namespaces.

* The private key of the certificate authority (CA) is shredded (securely erased) prior to caching or deployment to block issuance of new CA descendants (this is most relevant in caching mode).


Modes of operation
------------------

  generate
    Causes a PKI to be generated afresh every time and deployed.
    Typically, this will be whenever the framework is started.

  cache
    Causes a PKI to be generated exactly once and then copied
    to a designated cache location for future use.
    The PKI is then deployed from the cached location.

  import
    This option is similar to ``cache`` in that it deploys a PKI
    from *CacheDir* to *DeployDir*, but it forces an error if
    *CacheDir* is empty instead of triggering PKI generation.
    This enables usage models for deploying a pre-populated PKI
    such as a Kong certificate signed by an external certificate authority
    or TLS keys signed by an offline enterprise certificate authority.


OPTIONS
=======

  \-h, \--help
    Display help text

  \--confdir <confdir>
    Look in this directory for configuration.toml instead.

  \-p, \--profile <name>
    Indicate configuration profile other than default


FILES
=====

pkisetup-vault.json, pkisetup-kong.json
---------------------------------

Configuration files for certificate parameters.
These files conform to the following schema:

::

    {
        "create_new_rootca": "true|false",
        "working_dir": "./config",
        "pki_setup_dir": "pki",
        "dump_config": "true",
        "key_scheme": {
            "dump_keys": "false",
            "rsa": "false",
            "rsa_key_size": "4096",
            "ec": "true",
            "ec_curve": "384"
        },
        "x509_root_ca_parameters": {
            "ca_name": "EdgeXFoundryCA",
            "ca_c": "US",
            "ca_st": "CA",
            "ca_l": "San Francisco",
            "ca_o": "EdgeXFoundry"
        },
        "x509_tls_server_parameters": {
            "tls_host": "edgex-vault|edgex-kong",
            "tls_domain": "local",
            "tls_c": "US",
            "tls_st": "CA",
            "tls_l": "San Francisco",
            "tls_o": "Kong"
        }
    }

When generating or caching,
the utility hard-codes the names of the configuration files
and always processes ``pkisetup-vault.json`` first
and ``pkisetup-kong.json`` second.
This will be configurable in the future; at that time
the basename of the file would correspond to a directory under *DeployDir*.


configuration.toml
------------------
Configuration file for configurable directories that the options use.
This file conforms to the following schema:

::

    [SecretsSetup]
    WorkDir = "/path/to/temp/files"
    CacheDir = "/path/to/cached-or-importing/pki"
    DeployDir = "/path/to/deployed/pki"

WorkDir
~~~~~~~
A work area (preferably on a ramdisk) to place working files during certificate generation.
If not supplied, temporary files will be generated to a subdirectory
(``/edgex/security-secrets-setup``) of ``$XDG_RUNTIME_DIR``.
If ``$XDG_RUNTIME_DIR`` is undefined, uses ``/tmp`` instead.

DeployDir
~~~~~~~~~
Points to the base directory for the final deployment location of the PKI.
If not specified, defaults to ``/run/edgex/secrets/``.
For example, if *DeployDir* was set to ``/edgex`` and the service name was
``edgex-vault`` then the following files would be placed in
``/edgex/edgex-vault/``:

* ``server.crt`` for a PEM-encoded end-entity TLS certificate and
* ``server.key`` for the corresponding private key
* ``.security-secrets-setup.complete`` is a sentinel file created after assets are deployed

CacheDir
~~~~~~~~
Points to a base directory to hold the cached PKI.
Identical in structure to that created in *DeployDir*.
Defaults to ``/etc/edgex/pki`` if not specified. 
The PKI is deployed from here when the tool is run in
caching or importing.


ENVIRONMENT
===========

XDG_RUNTIME_DIR

  Used as default value for *WorkDir* if not otherwise specified.


NOTES
=====

As security-secrets-setup is a helper utility to ensure that a PKI is created on first launch, 
it is intended that security-secrets-setup is always invoked with the same command.

* Changing from ``cache`` to ``generate`` will cause the cache to be ignored when deploying a PKI and changing it back will cause a reversion to a stale CA.

* Changing from ``cache`` to ``import`` mode of operation is not noticeable by the tool: the PKI that is in the cache will be the one deployed.

To force regeneration of the PKI cache after the first launch,
the PKI cache must be manually cleaned.
The easiest way in Docker would be to delete the Docker volume holding the cached PKI.
