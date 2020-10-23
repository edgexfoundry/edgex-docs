% edgex-secrets-config-proxy(1) User Manuals edgex-secrets-config-proxy(1)

# NAME

edgex-secrets-config-proxy – Configure EdgeX API gateway service

# SYNOPSIS

**edgex-secrets-config proxy** SUBCOMMAND [OPTIONS]

# DESCRIPTION

Configures the EdgeX API gateway service.

This command is used to configure the TLS certificate for external connections, create authentication tokens for inbound proxy access, and other related utility functions.

Proxy configuration commands (listed below) require access to the secret store master key in order to generate temporary secret store access credentials.

# OPTIONS

  * **--confdir** _/path/to/directory/with/configuration.toml_ (optional)

    Points to directory containing a configuration.toml file.

# SUBCOMMANDS

  * **tls**

    Configure inbound TLS certificate. This command will provision the TLS secrets into the secret store and re-deploy them to Kong. Requires additional arguments:

    * **--incert** _/path/to/certchain.crt_ (required)

      Path to TLS leaf certificate (PEM-encoded x.509) (the file extension is arbitrary).
      If intermediate certificates are required to chain to a certificate authority,
      these should also be included.
      The root certificate authority should not be included.

    * **--inkey** _/path/to/private.key_ (required)

      Path to TLS private key (PEM-encoded).

  * **adduser**

    Create a API gateway user using specified token type. Requires additional arguments:

    * **--token-type** jwt | oauth2 (required)
    
      Create user using either the JWT or OAuth2 authentication plugin.
      This value must match the configured authentication plugin.

    * **--user** _username_ (required)

      Username of the user to add.

    * **--group** _group_ (optional)

      Group to which the user belongs, defaults to &quot;admin&quot;.
      This should be the group associated with the route ACL.
      This value can be changed by editing the `[KongACL]` section of configuration.toml.
      (Note that edgex-secrets-config shares the same configuration as securiry-proxy-setup
      as they both configure the EdgeX API gateway.)


    The following options are used when token-type == "jwt":

    * **--algorithm** RS256 | ES256 (required for JWT method)

      Algorithm used for signing the JWT.
      (See [RFC 7518](https://tools.ietf.org/html/rfc7518#section-3.1) for a list of signing algorithms.)

    * **--public\_key** _/path/to/public\_key.pem_ (required for JWT tokens)

      Public key (in PEM format) used to validate the JWT.
      (Not an x.509 certificate.)
      This key is assumed to have been pre-created using some external mechanism such as a TPM, HSM, openssl, or other method.

    * **--id** _key_ (optional)

      Optional user-specified &quot;key&quot; used for linkage with an incoming JWT via Kong&#39;s config.key\_claim\_name setting (defaults to &quot;iss&quot; field).
      See
      [Kong documentation for JWT plugin](https://docs.konghq.com/hub/kong-inc/jwt/#craft-a-jwt-with-publicprivate-keys-rs256-or-es256)
      for an example of how this parameter is used.


    The following options are used when token-type == "oauth2":

    * **--client\_id** (optional)

      Optional manually-specified OAuth2 client_id.  Will be generated if not present.  Equivalent to a username.

    * **--client\_secret** (optional)

      Optional manually-specified OAuth2 client_secret.  Will be generated if not present.  Equivalent to a password.

    * **--redirect\_uris** _url\_for\_browser\_redirection_ (required for oauth2 tokens)

      OAuth2 redirect URL for browser-based users.  Not currently used by EdgeX.


  * **deluser**

    Delete a API gateway user. Requires additional arguments:

    * **--token-type** jwt | oauth2 (required)
    
      Delete user using either the JWT or OAuth2 authentication plugin.
      This value must match the configured authentication plugin.

    * **--user** _username_ (required)

      Username of the user to delete.


  * **jwt**

    Utility function to create a JWT proxy authentication token from a supplied secret. This command does not require secret store access, but the values supplied must match those presented to the adduser command earlier. Requires additional arguments:

    * **--algorithm** `RS256` | `ES256` (required)

      Algorithm used for signing the JWT.
      (See [RFC 7518](https://tools.ietf.org/html/rfc7518#section-3.1) for a list of signing algorithms.)

    * **--id** _key_ (required)

      The &quot;key&quot; field from the &quot;adduser&quot; command.
      (This will be either the --id argument passed in, or the automatically generated identifier.)
      (This is not actually a cryptographic key, but a unique identifier such as would be used in a database.)

    * **--private\_key** _/path/to/private.key_ (required)

      Private key used to sign the JWT (PEM-encoded) with a key type corresponding to the above-supplied algorithm.

    * **--exp** _duration_ (optional)

      Duration of generated jwt expressed as a golang-parseable duration value. Use &quot;never&quot; to omit an expiration field in the JWT. Defaults to &quot;1h&quot; (one hour) if unspecified.

    
    The generated JWT will be the encoded representation of:

      <pre>
      {
        &quot;typ&quot;: &quot;JWT&quot;,
        &quot;alg&quot;: &quot;RS256 | ES256&quot;
      }
      {
        &quot;iss&quot;: &quot;_key_&quot;,
        &quot;exp&quot;: (calculated expiration time)
      }
      (signature)
      </pre>


  * **oauth2**

    Utility function to create an OAuth2 proxy authentication token using the client_credentials OAuth2 grant flow. This command does not require secret store access, but the values supplied must match those presented to the adduser command earlier. Requires additional arguments:

    * **--client\_id** (required)

      Optional manually-specified OAuth2 client_id.  Will be generated if not present.  Equivalent to a username.

    * **--client\_secret** (required)

      Optional manually-specified OAuth2 client_secret.  Will be generated if not present.  Equivalent to a password.



# CONFIGURATION

# ENVIRONMENT

  * **IKM\_HOOK**

    Enables decryption of an encrypted secret store master key by pointing at an executable that returns an encryption seed used that is formatted as a hex-encoded (typically 32-byte) string to its stdout.
    This optional feature, if enabled, requires pointing at the same executable that was used
    by security-secretstore-setup to provision and unlock the EdgeX the secret store.

# SEE ALSO

edgex-secrets-config(1)

EdgeX Foundry Last change: 2020
