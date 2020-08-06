# Background

The secret management components comprise a very small portion of the EdgeX framework.  Many components of an actual system are out-of-scope including the underlying hardware platform, the operating system on which the framework is running, the applications that are using it, and even the existence of workload isolation technologies, although the reference code does support deployment as Docker containers or Snaps.

The goal of the EdgeX secret store is to provide general-purpose secret management to EdgeX core services and applications.

![Secret Management In Context](arch-in-context.jpg)

## Motivation

The EdgeX Foundry security roadmap is published on the Security WG Wiki:

* https://wiki.edgexfoundry.org/display/FA/Security+Working+Group
* https://wiki.edgexfoundry.org/download/attachments/329467/EdgeX%20Security%20Architecture%20Roadmap.pptx?version=1&modificationDate=1536753478000&api=v2

The security roadmap establishes the requirement for a secret storage engine at the edge, and that furthermore that hardware secure storage should be supported:

> Initial EdgeX secrets (needed to start Vault/Kong) will be encrypted on  the file system using a secure storage abstraction layer – allowing other implementations to store these in hardware stores (based on hardware root of trust systems)

* https://www.edgexfoundry.org/blog/2018/11/15/edgex-foundry-releases-delhi-and-plans-for-edinburgh/
* https://wiki.edgexfoundry.org/display/FA/Edinburgh+Release

The current state of secret storage is described in the [Hardware Secure Storage Draft](https://docs.google.com/document/d/1MsTNdwtZp3zA-nPhCC3COakL3e5mrhJuFByy6ja5OxU/edit).

The AS-IS architecture resembles the following diagram:

![AS-IS](arch-as-is.jpg)

As the diagram notes, the critical secrets for securing the entire on-device infrastructure sit unencrypted on bulk storage media. While the deptiction that the Vault contents are encrypted is true,
the key needed to decrypt it is in plaintext nearby.

The Hardware Secure Storage Draft proposes the following future state:

![Proposed future state](arch-proposed.jpg)

This future state proposes a security service that can encrypt the currently unencrypted data items.

A number of problems must be resolved to make this future state a reality:

* Initialization order of containers: containers must block until their prerequisites have been satisfied. It is not sufficient to have only start-ordering, as initialization can take a variable amount of time, and the initialization tasks of a previous step are not necessarily completed before the next step is initiated.

* Allowing for variability in the hardware encryption component.  A simple bulk encryption/decryption interface does not allow for interesting scenarios based on local attestation, for example.

* Distribution of Vault tokens to services.


## General Requirements for Vault on the Edge

When using Vault at the edge, there are a number of general problems that must be solved as illustrated in the below diagram:

![General requirements](general_requirements.jpg)

Working top to bottom and left to right:

* Vault requires TLS to protect secrets in transit. This introduces a requirement to establish an on-device PKI, and the consequent need to prevent compromise of TLS private keys and unauthorized issuance of TLS certificates. It is difficult to dynamically trust a new certificate authority as the trusted list of certificate authorities is often set at build time not runtime. An alternative is to trust a particular CA at build time, and to pre-populate the PKI during device provisioning.
* Vault requires a master encryption key to encrypt its database. This master key is generated when the vault is initialized and must be resupplied when Vault is restarted to "unlock" the vault. The implementation must ensure the confidentiality, integrity, and availability of the Vault master key. Normally the vault is manually unsealed using a human process. In IoT scenarios, the vault must be unsealed automatically, which presents additional challenges.
* Services need to talk to Vault to retrieve their secrets. Thus, the service location mechanism that clients use to establish that connection must be trustworthy / non-spoofable. One option is to hard-code "localhost" or use DNS provided by container orchestration software. The problem is significantly harder if using an outsource service locator, like the Consul service location, as the trust in Consul then needs to be established.
* There is a general bootstrapping problem for the services themselves: clients need a Vault token to authenticate to Vault. The confidentiality, integrity, and availability of this token needs to be protected, and the token somehow needs to be distributed to the service.  If the client tries to pull the token from somewhere, there must be an preexisting mechanism to authenticate the request. Alternatively, the token could be pushed to the service before it is started: environment variable or files are common approaches.  Lastly, there could be an agent that sends the token to a service after it starts, such as by an HTTP API. (Reference: [Cubbyhole authentication principles](https://www.hashicorp.com/blog/cubbyhole-authentication-principles).)   In addition, the previously mentioned PKI problem applies here.
* The Vault storage itself must be protected against integrity and availability threats. Confidentiality is provided through the Vault master key.

The secret management design for EdgeX can be said to be finished when there is a sufficiently secure solution to the above challenges for the supported execution models.

## Next Steps for EdgeX

All parts of the system must collaborate to in order to ensure a robust secret management design. What is needed is a systematic approach to secret management that will close the gaps between the AS-IS and TO-BE future state.  This systematic approach is based on formal threat model with the aim that the system will meet some critical security objectives. The threat model is built against a proposed design and validates the security architecture of the design.  Through threat modeling, we can identify assets, adversaries, threats, and mitigations against those threats.  We can then make a prioritized implementation plan to address those threats.  More importantly, for someone adopting EdgeX, the documented threat model outlines the threats that the framework has been designed to protect against and by omission, the threats that it has not.

