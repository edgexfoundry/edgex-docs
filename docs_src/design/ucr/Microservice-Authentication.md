## Microservice Authentication

### Submitters

- Bryon Nevis (Intel)

### Change Log

- [approved](https://github.com/edgexfoundry/edgex-docs/pull/920) (2023-01-12)

### Market Segments

- All.  Security is a cross-cutting concern.

### Motivation

Modern cybersecurity standards for IoT
require peer-to-peer authentication of software components.
Representative IoT security standards make explicit reference
to authentication of both human and non-human interactions between components:

- ISA/IEC 62443-4-2, "Technical security requirements for control components and industrial automation"

  _CR 1.2 (Requirement): Components shall provide the capability to
  identify itself and authenticate with any other component
  (software application, embedded device, host device and network devices),
  according to ISA-62443-3-3 SR 1.2._

- ISA/IEC 62443-3-3, "System Security Requirements and Security Levels"

  _SR 1.2 (Requirement): The control system shall provide the capability to
  identify and authenticate all software processes and devices. This capability
  shall enforce such identification and authentication on all interfaces which
  provide access to the control system to support least privilege in accordance
  with applicable security policies and procedures._

- [Critical Manufacturing Sector Cybersecurity Framework Implementation Guidance](https://www.cisa.gov/sites/default/files/publications/Critical_Manufacturing_Sector_Cybersecurity_Framework_Implementation_Guidance_FINAL_508.pdf)

  _PR.AC-1: Identities and credentials are issued, managed, verified,
  revoked, and audited for authorized devices, users, and processes._


### Target Users
- Device Owner
- Device User
- Device Maintainer
- Service Provider

### Description

Microservice authentication provides the following benefits,
which are potentially valuable to all of the listed target users:

- Provides a defense against malware running on the device,
  as currently there is no mechanism to ensure that only
  authorized users or processes are allowed to invoke EdgeX services.

- Provides greater auditability as to who initiated a particular
  action on the device.

- Depending on implementation, may provide a way to revoke
  access that was previously granted,
  or allow customers to tie in to enterprise
  identity management systems.

For purposes of this UCR, microservice authentication implies
that the receiving microservice has access to the identity
of the caller and can write program logic based on that identity.


### Existing solutions

Microservice authentication is currently implemented around two primary vectors:

- Token-based authentication schemes.

  Initiator sends an identifier along with a request to the receiver.
  The identifier is cryptographically validated using a key trusted by
  the receiver, or the receiver asks a trusted third party to verify the identifier.

  A benefit of token-based authentication schemes is identity delegation,
  whereby the identifier can be passed through a chain of calls to
  preserve the identity of the original initiator.
  The identifier can often be tunneled through other protocols.
  Another benefit of token-based authentication is that
  it flows easily through a web application firewall.

  A drawback of token-based authentication is that due to MITM threats,
  token-based authentication over an unencrypted network is insecure.
  Another drawback of token-based authentication is that it is unidirectional:
  the receiver can authenticate the initiator, but not vice-versa.

- End-to-end encryption (E2EE) schemes.

  End-to-end encryption implies that only the original sender 
  and the final intended receiver ever see the unencrypted message contents.
  If a message is simply encrypted from process-to-process or machine-to-machine,
  where an intermediary can decrypt the message,
  even if the entire flow encrypted point-to-point,
  then the message is simply said to be "encrypted in-transit."
  If the architecture of the system requires a server-based intermediary between two clients,
  then in a E2EE system, only the two communicating clients have access the unencrypted data.

### Requirements

- When an EdgeX service is running in secure mode,
  unauthenticated inbound requests shall be rejected.

- When an EdgeX service is running in secure mode
  and initiating an outbound request to a peer EdgeX service,
  the outbound request shall be authenticated.

- Authentication shall work in the context of bare-metal deployments,
  docker-based deployments, and Kubernetes-based deployments.

This UCR does not prescribe what layer in the software stack performs authentication.

### Other Related Issues

- Including identity and access management in EdgeX system
  ([edgex-go#3845](https://github.com/edgexfoundry/edgex-go/issues/3845)):
  Expresses the desire to integrate human identity into the EdgeX system.
  The BSI presentation to EdgeX TSC also explicitly mentions Auth0 integration.

- Investigate alternatives to Kong that have better platform support and use less memory
  ([edgex-go#3747](https://github.com/edgexfoundry/edgex-go/issues/3747)):
  Expresses the concern over the size of the Kong+Postgres implementation,
  and a desire to find something more efficient.


### References

None
