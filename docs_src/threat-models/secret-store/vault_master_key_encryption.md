# Vault Master Key Encryption Feature

## Introduction

The EdgeX secret store threat model calls out a particular aspect
of the Vault-based secret store architecture
upon which the whole EdgeX secret store depends: the Vault master key.
Because plaintext storage of the Vault master key at rest would be
a known [security weakness](https://cwe.mitre.org/data/definitions/313.html),
the high level design calls for the Vault master key to be encrypted on storage.

One way of doing this would be to simply encrypt the whole drive
upon which the Vault master key is stored.
This is a good solution:
it would encrypt not only the Vault master key,
but also other part of the system to harden them against
offline tampering and information disclosure risks.
This solution also has drawbacks as well:
whole volume encryption may slow down boot times
and have a runtime performance impact on constrained
devices without hardware-accelerated crypto.

The Vault Master Key Encryption feature of EdgeX enables
a system designer to specifically target encryption of the Vault master key,
and enables a variety of flexible use cases that are not tied to volume encryption
such as key escrow (where a key is stored on another machine on the network),
smart cards or USB HSMs (where a key us stored in a dongle or chip card),
or TPM (security hardware found on many PC-class motherboards).

## Internal design

As stated in the high level design,
an [RFC-5869](https://tools.ietf.org/html/rfc5869) key derivation function (KDF)
is used to produce a set of wrapping keys
that are used by the vault-worker process to encrypt the Vault master key.

An RFC-5869 KDF requires three inputs.
A change to any input results in a different output key:

* **Input keying material (IKM).**
  It need not (but should be) cryptographically strong, and is the "secret" part of the KDF.

* **A salt.**  A non-secret random number that adds to the strength of the KDF.

* **An "info" argument.**
  The info argument allows multiple keys to be generated from the same IKM and salt.
  This allows the same KDF to generate multiple keys each used for a different purpose.
  For instance, the same KDF can be used to generate an encryption key to protect the PKI at-rest.

The Vault Master Key Encryption feature
consumes the IKM from a Unix-style pipe.
The IKM is provided by a vendor-defined mechanism,
and is intended to be tied into security hardware on the device,
be device-unique,
and explicitly not stored in the file system.

To further strengthen the solution,
an implementation could choose to engineer a solution whereby the IKM
is only released a configurable number of times per boot,
so that malware that runs on the system post-boot cannot retrieve it.

## IKM HOOK

The Vault Master Key Encryption feature is embedded
into the EdgeX `security-secretsetore-setup` utility.
It is enabled by setting an environment variable,
`IKM_HOOK`, containing the path to an executable
that implements the IKM interface, described below,
when the `security-secretstore-setup` executable
is run in early boot to initialize or unseal
the EdgeX secret store.

When this feature is enabled,
the Vault master key is encrypted at rest,
and cannot be recovered unless the same
IKM is provided as when the secretstore was initialized.


## IKM interface

### NAME
ikm - Return input key material for a hash-based KDF.

### SYNOPSIS
ikm

### DESCRIPTION

ikm outputs initial keying material to stdout as a lowercase hex string to be used for the default EdgeX software implementation of an RFC-5869 KDF.

The ikm can output any number of octets. Typically, the KDF will pad the ikm if it is shorter than hashlen, and hash the ikm if it is longer than hashlen. Thus, if ikm returns variable-length output it is advantageous to ensure that the output is always greater than hashlen, where hashlen depends on the hash function used by the KDF.

### EXAMPLE

```
ikm
64acd82883269a5e46b8b0426d5a18e2b006f7d79041a68a4efa5339f25aba80
```

## Sample implementations

This section lists example implementations of the EdgeX Hardware Security Hook.

### Tutorial: Configuring EdgeX Hardware Security Hooks to use a TPM on Intel® Developer Zone

There is a
[tutorial](https://software.intel.com/content/www/us/en/develop/articles/tutorial--configuring-edgex-hardware-security-hooks-to-use-a-tpm.html)
published on Intel® Developer Zone
that uses TPM hardware through a device driver interface
to encrypt the Vault master key shares.
The sample uses TPM-based local attestation to attest the system state
prior to releasing the IKM.
The sample is based on the tpm2-software project in GitHub
and is specifically designed to run as a statically-linked executable
that could be injected into a Docker container.
Although not a complete solution,
it is an illustrative sample that demonstrates
in concrete terms how to use the TSS C API to access TPM functionality.
