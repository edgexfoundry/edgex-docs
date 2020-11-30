# Use of encryption to secure in-cluster EdgeX communications


## Status

** Approved **


## Context

This ADR seeks to define the EdgeX direction on using encryption
to secure "in-cluster" EdgeX communications, that is,
internal microservice-to-microservice communication.

This ADR will seek to clarify the EdgeX direction
in several aspects with regard to:

- EdgeX services communicating within a single host
- EdgeX services communicating across multiple hosts
- Using encryption for confidentiality or integrity in communication
- Using encryption for authentication between microservices

This ADR will be used to triage EdgeX feature requests in this space.


## Background


### Why encrypt?

Why consider encryption in the first place?
Simple.
Encryption helps with the following problems:

- Client authentication of servers.
  The client knows that it is talking to the correct server.
  This is typically achieved using TLS server certificates
  that the client checks against a trusted root certificate authority.
  Since the client is not in charge of network routing,
  TLS server authentication provides a good assurance
  that the requests are being routed to the correct server.

- Server authentication of clients.
  The server knows the identity of the client that has connected to it.
  There are a variety of mechanims to achieve this,
  such as usernames and passwords, tokens, claims, et cetera,
  but the mechanism under consideration by this ADR
  is TLS client authentication
  using TLS client certificates.

- Confidentiality of messages exchanged between services.
  Confidentiality is needed to protect authentication data
  flowing between communicating microservices as well as
  to protect the message payloads if they contain nonpublic data.
  TLS provides communication channel confidentiality.

- Integrity of messages exchanged between services.
  Integrity is needed to ensure that messages between
  communicating microservices are not maliciously altered,
  such as inserting or deleting data in the middle of the exchange.
  TLS provides communication channel integrity.

A microservice architecture normally strives for all of the above protections.

Besides TLS, there are other mechanisms that can be used to provide some of the above properties.
For example, IPSec tunnels provide confidentity, integrity, and authentication of the hosts (network-level protection).
SSH tunnels provide confidentiality, integrity, and authentication of the tunnel endpoints (also network-level protection).
TLS, however, is preferred, because it operates in-process at the application level and provides better point-to-point security.

### Why to not encrypt?

In the case of TLS communications,
microservices depend on an asymmetric private key to prove their identity.
To be of value, this private key must be kept secret.
Applications typically depend on process-level isolation
and/or file system protections for the private key.
Moreover, interprocess communication using sockets is mediated by the
operating system kernel.
An attacker running at the privilege of the operating system
has the ability to compromise TLS protections,
such as by substituting a private key or certificate authority of their choice,
accessing the unencrypted data in process memory,
or intercepting the network communications that flow through the kernel.
Therefore, within a single host, TLS protections may slow down an attacker,
but are not likely to stop them.
Additionally, use of TLS requires management of additional
security assets in the form of TLS private keys.

Microservice communcation across hosts, however,
is vulnerable to intereception, and must be protected
via some mechanism such as, but not limited to:
IPSec or SSH tunnels, encrypted overlay networks,
service mesh middlewares, or application-level TLS.

Another reason to not encrypt is that TLS adds overhead to
microservice communication in the form of additional network
around-trips when opening connections
and performing cryptographic public key and symmetric key operations.


## Decision

At this time, EdgeX is primarily a single-node IoT application framework.
Should this position change, this ADR should be revisited.
Based on the single-node assumption:

- TLS will not be used for confidentiality and integrity of internal on-host microservice communication.
- TLS will be avoided as an authentication mechanism of peer microservices.
- Integrity and confidentiality of microservice communcations crossing host boundaries is required to secure EdgeX, but are an EdgeX customer responsibility.
- EdgeX customers are welcome to add extra security to their own EdgeX deployments.


## Consequences

This ADR if approved would close the following issues as will-not-fix.

- https://github.com/edgexfoundry/edgex-go/issues/1942
- https://github.com/edgexfoundry/edgex-go/issues/1941
- https://github.com/edgexfoundry/edgex-go/issues/2454
- https://github.com/edgexfoundry/developer-scripts/issues/240
- https://github.com/edgexfoundry/edgex-go/issues/2495

It would also close https://github.com/edgexfoundry/edgex-go/issues/1925
as there is no current need for TLS as a mutual authentication strategy.


## Alternatives

### Encrypted overlay networks

Encrypted overlay networks provide varying protection based on the product used.
Some can only encrypt data, such as an IPsec tunnel.
Some can encrypt and provide for network microsegmentation,
such as Docker Swarm networks with encryption enabled.
Some can encrypt and enforce network policy
such as restrictions on ingress traffic or restrictions on egress traffic.


### Service mesh middleware

Service mesh middleware is an alternative that should be investigated
if EdgeX decides to fully support a Kubernetes-based deployment
using distributed Kubernetes pods.

A service mesh typically achieves most of the security objectives
of security microservice commuication by intercepting microservice
communications and imposing a configuration-driven policy
that typically includes confidentiality and integrity protection.

These middlewares typically rely on the Kubernetes pod construct
and are difficult to support for non-Kubernetes deployments.


### EdgeX public key infrastructure

An EdgeX public key infrastructure that is natively supported
by the architecture should be considered if EdgeX
decides to support an out-of-box distributed deployment
on non-Kubernetes platforms.

Native support of TLS requires a significant amount of glue logic,
and exceeds the availble resources in the security working group
to implement this strategy.
The following text outlines a proposed strategy for supporting
native TLS in the EdgeX framework:

EdgeX will use Hashicorp Vault to secure the EdgeX PKI,
through the use of the Vault PKI secrets engine.
Vault will be configured with a root CA at initialization time,
and a Vault-based sub-CA for dynamic generation of TLS leaf certificates.
The root CA will be restricted to be used only by the Vault root token.

EdgeX microservices that are based on third-party containers
require special support unless they can talk natively to Vault for their secrets.
Certain tools, such as those mentioned in the
"Creation and Distribution of Secrets" ADR
(`envconsul`, `consul-template`, and others)
can be used to facilitiate third-party container integration.
These services are:

* **Consul**: Requires TLS certificate set by configuration file or command line, with a TLS certificate injected into the container.

* **Vault**: As Vault's database is encrypted, Vault cannot natively bootstrap its own TLS certificate.  Requires TLS certificate to be injected into container and its location set in a configuration file.

* **PostgreSQL**: Requires TLS certificate to be injected into '$PGDATA' (default: `/var/lib/postgresql/data`) which is where the writable database files are kept.

* **Kong (admin)**: Requires environment variable to be set to secure admin port with TLS, with a TLS certificates injected into the container.

* **Kong (external)**: Requires a bring-your-own (BYO) external certificate,
or as a fallback, a default one should be generated using a configurable external hostname.  (The Kong
[ACME plugin](https://docs.konghq.com/hub/kong-inc/acme/)
could possibly be used to automate this process.)

* **Redis (v6)**: Requires TLS certificate set by configuration file or command line, with a TLS certificate injected into the container.

* **Mosquitto**: Requires TLS certificate set by configuration file, with a TLS certificate injected into the container.

Additionally, every EdgeX *microservice consumer* will require access to the root CA
for certificate verification purposes,
and every EdgeX *microservice server* will need a TLS leaf certificate and private key.

Note that Vault bootstrapping its own PKI is tricky and not natively supported by Vault.
Expect that a non-trivial amount of effort will need to be put into starting Vault in
non-secure mode to create the CA hierarchy and a TLS certificate for Vault itself,
and then restarting Vault in a TLS-enabled configuration.
Periodic certificate rotation is a non-trivial challenge as well.

The Vault bootstrapping flow would look something like this:

1. Bring up vault on localhost with TLS disabled (bootstrapping configuration)
1. Initialize a blank Vault and immediately unseal it
1. Encrypt the Vault keyshares and revoke the root token
1. Generate a new root from the keyshares
1. Generate an on-device root CA (see https://learn.hashicorp.com/vault/secrets-management/sm-pki-engine)
1. Create an intermediate CA for TLS server authentication
1. Sign the intermediate CA using the root CA
1. Configure policy for intermediate CA
1. Generate and store leaf certificates for
   Consul,
   Vault,
   PostgreSQL,
   Kong (admin),
   Kong (external),
   Redis (v6),
   Mosquitto
1. Deploy the PKI to the respective services' secrets area
1. Write the production Vault configuration (TLS-enabled) to a Docker volume


There are no current plans for mutual auth TLS.
Supporting mutual auth TLS would require creation of a separate PKI hierarchy
for generation of TLS client certificates
and glue logic to persist the certificates in the service's key-value secret store
and provide them when connecting to other EdgeX services.
