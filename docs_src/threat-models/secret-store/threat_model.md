# Threat Model

## Assumptions

The EdgeX Framework is a API-based software framework that strives to be platform and architecture-independent. Although very little is knowable about the actual runtime, the reference code supports the following runtime environments "out of box":

* A containerized implementation based on Docker.
* A containerized implementation based on Snaps.

The threat model presented in this document analyzes the secret management subsystem of EdgeX, and has considerations for both of the above runtime environments, both of which implement protections beyond a stock user/process runtime environment.  In generic terms, the secret management threat model assumes:

* Services do not have unfettered access to the host file system.
* Services are protected from each other and communicate only through defined IPC mechanisms.
* The service location mechanism is trustworthy/non-spoofable.
* Services do not run with privilege except where noted.
* There are no unauthorized privileged administrators operating on the device (privileged administrator can bypass all access controls).
* The framework may be deployed on a device with inbound and outbound Internet connectivity. This is a pessimistic assumption to introduce an anonymous network adversary.
* The framework may be deployed on a device with limited physical security. This is a pessimistic assumption to introduce simple hardware attacks such as disk cloning.

Any particular of implementation of Edge-X should perform its own threat modeling activity as part of securing the implementation, and may use this document to supplement analysis of the secret management subsystem of EdgeX.

## Recommended Hardening 

Physical security and hardening of the underlying platform is out-of-scope for implementation by the EdgeX reference code.  But since the privileged administrator can bypass all access controls, such hardening is nevertheless recommended: the threat model assumes that there are no unauthorized privileged administrators.  One should look to industry standard hardening guides, such as [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/) for hardening operating system and container runtimes.  Additionally, typical EdgeX base platforms are likely to support the following types of hardening out-of-the-box(1), and these should be enabled where possible.

* Verified/secure boot with a hardware root of trust.  This refers to a trust chain that starts at power-on, verifying the system firmware, boot loaders, drivers, and the core components of the operating system.  Verified boot helps to ensure that an attacker cannot obtain a privileged administrator role during the boot process.
* File system integrity (e.g. dm-verity) and/or full disk encryption (e.g. LUKS).  Verified/secure boot typically does not apply to user-mode process started after the kernel has booted.  File system integrity checking and/or encryption is an easy way to reduce exposure to off-line tampering such such as resetting the administrator password or installing a back door.

The EdgeX secret store provides hooks for utilizing hardware secure storage to ensure that secrets stored on the device can only be decrypted on that device.  Implementations should use hardware security features where a suitable plug-in is available.  For maximum benefit, hardware security should be combined verified/secure boot, file system protection, and other software-level hardening.

Lastly, due consideration should be given to the security of the software supply chain: it is important to ensure that code deployed to a device is what is expected and free of known vulnerabilities.
This implies an ability to update a device in the field to ensure that it remains free of known vulnerabilities.

Footnotes:

(1) Most Linux distributions support verified/secure boot.  Microsoft Windows enables verified/secure boot by default, and can automatically use TPM hardware if full disk encryption is enabled and will fail to decrypt if verified/secure boot is disabled.

## Protections afforded by supported runtime environments

The EdgeX reference code supports Docker-based and Snap-based deployments.  Each of these deployment environments offer sandboxing protections that go beyond a standard Unix user and process model.  As mentioned  earlier, the threat model assumes the sandboxing protections:

* Prevent one service from accessing the protected files of the host or another service.
* Prevent one service from inspecting the protected memory of another service or processes on the host.
* Restrict interprocess communication (IPC) mechanisms to a defined set.
* Allow for private scratch spaces, preferably on a RAMdisk.

In the Linux environment, most of these protections are based on a combination of two technologies: [Linux namespaces](https://lwn.net/Articles/531114/) and mandatory access control (MAC) based on [Linux Security Module (LSM)](https://www.kernel.org/doc/html/v4.15/admin-guide/LSM/index.html).

### Docker-based runtimes

All services running within a single container are assumed to be within the same trust boundary.
Docker-based runtimes are expected to provide the following properties:

#### General protections

* The `root` user in a container is subject to namespace constraints and restricted set of [capabilities](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

#### File system protections

* Containers by default has no visibility to the host's file system and run with their own root file system that is supplied with the container. The container's file system can be augmented with docker volumes and bind mounts to the host file system to allow specific data sharing scenarios.
* Containers can be started with tmpfs volumes that are local to that container instance. By default, all files in a container are remapped to an overlay file system stored as files under `/var/lib/docker` where they are observable on the host and stored persistently.
* The root file system of a container can be mounted read-only.  For writable root file systems, each container gets a fresh copy of the root file system.
* Content that must be persisted across container restarts must be stored in Docker volumes.
* Docker volumes can be shared across multiple containers; however, the default "local" driver can only do such sharing when the containers are co-located on the same host.

#### Interprocess communication protections

* Docker containers do not share the host's network interface by default and instead is based on virtual ethernet adapters and bridges.  Network connectivity is strictly controlled via the docker-compose definition.
* There are networking differences when running Docker on Windows or MacOS machines, due to the use of a hidden Linux virtual machine to actually run Docker.
* There are few if any IPC restrictions between processes running in the same container due to lack of mandatory access controls.  Each service must run in its own container to ensure maximum service isolation.

### Snap-based runtimes

All services running within a single snap are assumed to be within the same trust boundary.  However, even in a snap, due to the use of mandatory access control, there are stronger-than-normal process isolation policies in place, as documented below.

#### General protections

* The `root` user in a snap is subject to namespace constraints and MAC rules enforced by Linux Security Modules (LSMs) configured as part of the snap.

#### File system protections

* Snaps run inside their own mount namespace, which is a [confined](https://github.com/snapcore/snapd/wiki/Snap-Execution-Environment) view of the host's file system where access to most paths is restricted. This includes sysfs and procfs.  Note: File system paths inside of the snap are homomorphic with the host's view of the file system - any files written in the snap are visible on the host.
* All of the files in the snap are read-only with the exception if the below noted paths.  The contents of the snap itself are mounted read-only from a squashfs file system.
* Snaps can write small temporary files to a tmpfs pointed to by `$XDG_RUNTIME_DIR` which is a [user-private user-writable-directory](https://www.freedesktop.org/software/systemd/man/pam_systemd.html) that is also per-snap. Snaps can write persistent data local to the snap to the `$SNAP_DATA` folder.
* Snaps do not have the [CAP_SYS_ADMIN](http://man7.org/linux/man-pages/man7/capabilities.7.html), `mount(2)`, capability.
* [Content interface snaps](https://docs.snapcraft.io/the-content-interface/1074) can be used to allow one snap to share code or data with another snap.

#### Interprocess communication protections

* Snaps can send signals only to processes running inside of the snap.
* Snaps share the host's network interface rather than having a virtual network interface card.
* Snaps may have multiple processes running in them and they are allowed to communicate with each other.
* Snaps may connect to IP sockets opened by processes running outside of the snap.
* Snaps are not allowed to access `/proc/mem` or to `ptrace(2)` other processes.

## High-level Security Objectives

### Security Objectives

The security objectives call out the security goals of the architecture/design.  They are:

* Ensure confidentiality, integrity, and availability of application secrets.
  * Reduce plain text exposure of sensitive data.
  * Design-in hooks for hardware secure storage.

## Assets

### Primary Assets

Primary assets are the assets at the level of the conceptual data model of the system and primarily represent "real-world" things.

| AssetId | Name                | Description                         | Attack Points                  |
| ------- | ------------------- | ----------------------------------- | ------------------------------ |
| P-1     | Application secrets | The things we are trying to protect | In use, in transit, in storage |

### Secondary Assets

Secondary assets are assets are used to support or protect the primary assets and are usually implementation details versus being part of the conceptual data model.


| AssetId | Name                      | Description                                                  | Attack Points                       |
| ------- | ------------------------- | ------------------------------------------------------------ | ----------------------------------- |
| S-1     | Vault service token       | Vault service tokens are issued per-service and used by services to authenticate to vault and retrieve per-service application secrets. | In-flight via API, at rest          |
| S-3     | Vault token-issuing-token | Used by the token issuing service to create vault service tokens for other services. (Called out separately from S-1 due to its high privilege.) | In-flight via API, at rest          |
| S-4     | Vault root token          | A special token created at Vault initialization time that has all capabilities and never expires. | In-flight via API, at rest          |
| S-5     | Vault master key          | A root secret that encrypts all of Vault's other secrets.    | In-flight via API, at rest, in-use. |
| S-6     | Vault data store          | A data store encrypted with the Vault master key that contains the contents of the vault. | In storage                          |
| S-7     | Consul data store         | Back-end storage engine for vault data store.                | In storage                          |
| S-8     | CA key                    | Private keys for on-device PKI certificate authority.        | In use, in transit, in storage      |
| S-9     | Issuing CA key            | Private keys for on-device PKI issuing authorities.          | In use, in transit, in storage      |
| S-10    | Leaf TLS key              | Private keys for TLS server authentication for on-device services (e.g. Vault service, Consul service) | In use, in transit, in storage      |
| S-13    | IKM                       | Initial keying material as input to HMAC KDF                 | In use, in transit, in storage      |

Note that asset S-9 (issuing CA key) is not currently implemented:
in all current EdgeX releases all TLS leaf certificates are derived from the root CA.

## Attack Surfaces

This table lists components in the system architecture that have assets of potential value to an attacker and how a potential attacker may attempt to gain access to those components.

| System Element             | Compromise Type | Assets Exposed                                               | Attack Method                                                |
| -------------------------- | --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Consul API                 | IA              | Vault data store, service location data/registry, settings   | Data modification, DoS against API
| Vault API                  | CIA             | All application secrets, all vault tokens                    | Data channel snooping or data modification, DoS against API  |
| Host file system           | CIA             | PKI private keys, Vault tokens, Vault master key, Vault store, Consul store | Snooping or data modification, deletion of critical files    |
| PKI initiazation agent     | CI              | Private keys for on-device PKI                               | Snooping generation of assets or forcing predictable PKI     |
| Vault initialization agent | CI              | Vault master key, Vault root token, token-issuing-token, encryption key for Vault master key | Snooping generation of assets or tampering with assets       |
| Token server API           | CIA             | Token issuing token, service tokens                          | Data channel snooping, tampering with asset policies, or forcing service down |
| Process memory             | CIA             | Most assets excluding hardware and  storage media            | Read or modify process memory through /proc or related IPC mechanisms |

## Adversaries

The adversary model is use-case specific, but for the sake of discussion assume the following simplistic list:

| Persona                                    | Motivation                                                   | Starting Access  | Skill / Effort |
| ------------------------------------------ | ------------------------------------------------------------ | ---------------- | -------------- |
| Thief (Larceny)                            | Quick cash by reselling stolen components.                   | None             | Low            |
| Remote hacker                              | Financial gain by harvesting resellable information or performing ransomware attacks via exploitable vulnerabilities. | Network          | Medium         |
| Malicious administrator                    | Out of scope. Cannot defend against attacks originating at level of system software. | N/A              | N/A            |
| Malicious non-privileged service           | Escalation of privilege and data exfiltration. Malicious services includes software supply chain attackers. | User mode access | Medium         |
| Industrial espionage / Malicious developer | Financial gain or harm by obtaining access to back-end systems and/or competitive data. | Unknown          | High           |

The malicious administrator is out of scope: the threat model assumes that there are no unauthorized privileged administrators on the device. This must be ensured through hardening of the underlying platform, which is out of scope.

Malicious non-privileged services are a concern. This can occur through a wide variety of software supply chain attacks, as well as implementation bugs that permit a service to exhibit unintended functionality.

The industrial espionage or malicious developer adversary deserves some explanation.  Whereas the remote hacker adversary is primarily motivated by a one-time attack, the industrial espionage attacker seeks to maintain a persistent foothold or to insert back-doors into an entire fleet of devices.  Making each device unique (e.g. device-unique secrets) helps to mitigate against break-once-run-everywhere (BORE) attacks.

## Threat Matrix

The threat matrix indicates what assets are at risk for the various attack surfaces in the system.

|                     | Consul API | Vault API | Host FS | PKI agent | Vault agent | Token svc | /proc /mem |
| ------------------- | ---------- | --------- | ------- | --------- | ----------- | --------- | ---------- |
| Application secrets |            | *a        |         |           |             |           | *p         |
| Vault service token |            | *bd       | *b      |           |             | *bd       | *p         |
| Token-issuing-token |            | *e        | *e      |           | *e          | *e        | *p         |
| Vault root token    |            | *f        | *f      |           | *f          |           | *p         |
| Vault master key    |            | *g        | *g      |           | *g          |           | *p         |
| Vault DS            | *hi        |           |         |           |             |           |            |
| Consul DS           | *j         |           | *j      |           |             |           |            |
| PKI CA              |            |           | *m      | *k        |             |           | *p         |
| PKI intermediate    |            |           | *m      | *l        |             |           | *p         |
| PKI leaf            |            |           | *m      | *m        |             |           | *p         |
| IKM                 |            |           | *q      |           |             |           | *p         |

## Threats and Mitigations

Format:

**(identifier) Threat name**

- Mitigation 1
- Mitigation 2
- et cetera

#### (a1) Loss of confidentiality of application secrets in-flight by MITM attack against the Vault API.

- DNS name resolution is assumed trustworthy (hard-coded localhost, or Docker-supplied DNS).
- Vault API is protected by TLS verified against a CA certificate.
- Vault TLS private key is protected by host file system (_SECRETSLOC_).
- **Unmitigated:** Service location information is trustworthy.

#### (a2) Loss of confidentiality of application secrets by querying Vault API.

- Vault API is protected by TLS verified against a CA certificate.
- Application secrets are protected by Vault service token.
- Each service has a unique token with restricted visibility.

#### (b1) Loss of confidentiality of Vault service token in-flight by MITM attack against the Vault API.

- Vault service token is protected by host file system (_SECRETSLOC_).
- Vault service token has limited lifespan and must be periodically renewed.
- Vault API is protected by TLS verified against a CA certificate.

#### (b2) Loss of confidentiality of Vault service token in-flight by MITM attack against the token provider.

- The file-based token provider does not expose an API.
- The file-based token provider configuration information comes from a trusted source (configuration file bundled with the service).

#### (b3) Loss of confidentiality of Vault service token at-rest by file system inspection/monitoring.

* Container/Snap protections prevent services from reading other services' tokens off of disk.
* Revoke previously generated tokens on every reboot.

#### (d1) Loss of availability of Vault service token token via intentional Vault service crash.

* Service tokens are created as persistent orphans (survive Vault restarts).
* Services needing long-lived Vault access can renew their own token.
* **Unmitigated:** Automatic restart and re-unsealing of Vault daemon.

#### (d2) Loss of availability of Vault service token token via intentional token provider crash.

- File-based token provider is a one-shot service.

#### (e1) Loss of confidentiality of token-issuing-token in-flight by MITM attack against the Vault API.

- See mitigations for threat (b1) above.

#### (e2) Loss of confidentiality of token-issuing-token at-rest by file system inspection/monitoring.

* Container/Snap provided file system protections.
* Token-issuing token in stored in private tmpfs area in execution environments that support it.
* Token-issuing token is passed via private channel inside of security service.
* Token-issuing token for file-based token provider is revoked after use.

#### (e3) Loss of availability of token-issuing token via intentional service crash.

- Not applicable: file-based token provider is a single-shot process

#### (f1) Loss of confidentiality of Vault root token in-flight by MITM attack against the Vault API.

- See mitigations for threat (a1) above.

#### (f2) Loss of confidentiality of Vault root token by other means.

* The root token is never persisted to disk and revoked immediately after performing necessary setup during vault initialization (the root token can be regenerated on-demand with the master key).

#### (g1) Loss of confidentiality of Vault master key in-flight by MITM attack against the Vault API.

- See mitigations for threat (a1) above.

#### (g2) Loss of confidentiality of Vault master key at-rest by file system inspection/monitoring.

* Container/Snap provided file system protections.
* Vault master key is encrypted with AES-256-GCM using a HMAC-KDF derived-key with KDF input coming from a configurable source.
* Threat model recommends use of hardware secure storage for the input key material.

#### (g3) Loss of availability of Vault master key by malicious deletion.

* Container/Snap provided file system protections.
* Hardware-based solutions are out of scope for the reference design, but may offer additional protections.

#### (h) Lost of confidentiality of Vault data store at-rest by file system inspection/monitoring.

* Vault data store is encrypted using Vault master key before being stored.

#### (i) Lost of availability of Vault data store due to intentional service crash of Consul.

* Vault data store is implemented on top of Consul, which is a fault-tolerant-capable data store.
* In Docker-based environments, Consul can be configured to automatically restart on failure.

#### (j1) Loss of confidentiality of Consul data store at-rest by file system inspection/monitoring.

* Consul data store is assumed to be non-confidential and thus there is no threat. Vault data is encrypted prior to be passed to Consul for storage.

#### (j2) Loss of integrity or availability of Consul data store at-rest by file system tampering or malicious deletion.

* Container/Snap provided file system protections.

#### (j3) Loss of availability of Consul data store at runtime due to intentional service crash.

* In Docker-based environments, Consul can be configured to automatically restart on failure.
* Threat may be further mitigated by running Consul in High Availability mode (not done in reference implementation).

#### (k1) Loss of confidentiality of PKI CA at-rest by file system inspection/monitoring.

* Container/Snap provided file system protections.
* Secure deletion of CA private key after PKI generation.

#### (k2) Loss of integrity of PKI CA by malicious replacement.

* Container/Snap provided file system protections.

#### (k3) Loss of availability of PKI CA (public certificate) by malicious deletion.

* Container/Snap provided file system protections.

#### (l1) Loss of confidentiality of PKI intermediate at-rest by file system inspection/monitoring.

* Container/Snap provided file system protections.
* Secure deletion of CA intermediate private key after PKI generation.

#### (l2) Loss of integrity of PKI intermediate by malicious replacement.

* Identical to threat (k3): CA would have to be maliciously replaced as well.

#### (l3) Loss of availability of PKI intermediate (public certificate) by malicious deletion.

* Container/Snap provided file system protections.

#### (m1) Loss of confidentiality of PKI leaf at-rest by file system inspection/monitoring.

* Container/Snap provided file system protections.
* Note that server TLS private keys must be delivered to services unencrypted due to limitations of dependent services.

#### (m2) Loss of integrity of PKI leaf by malicious replacement.

* Identical to threat (k3/l3): CA or intermediate would have to be maliciously replaced as well.

#### (m3) Loss of availability of PKI leaf by malicious deletion.

* Container/Snap provided file system protections.

#### (p) Disclosure, tampering, or deletion of secrets through /proc/mem or ptrace() by malicous or compromised microservice

- Container/Snap provided memory protections.

#### (q) Lost of confidentiality of input key material (IKM)

- IKM is secured by vendor-defined hardware-mechanism.
- IKM is passed to key derivation function via IPC pipe (stdout).


## Known vulnerabilites

**Service location tampering vulnerability:**
Services use configuration information to connect to the secret store and other services.
The configuration information in all current EdgeX releases is provided
by Consul and bootstrapped by a `configuration.toml` file in each service.
Consul is currently run as a public service (no encryption, authentication, or access control)
and configuration information is therefore prone to malicious tampering.
This vulnerability will be addressed in a future design proposal
