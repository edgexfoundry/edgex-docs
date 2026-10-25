---
title: Device OPC-UA - Configuration
---

# Device OPC-UA - Configuration

OPC-UA Device Service has the following configurations to implement the `OPCUAServer` protocol.

Example of OPCUAServer as shown below:

```yaml
# configuration.yml

OPCUAServer:
  DeviceName: SimulationServer
  Policy: None
  Mode: None
  CertFile: ''
  KeyFile: ''
  Writable:
    Resources: 'Counter,Random'
```

| Configuration      | Default Value     | Description                                                                                                                                      |
| ------------------ | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| DeviceName         | SimmulationServer | Device name of OPC-UA                                                                                                                            |
| Policy             | None              | Security Policy of OPC-UA<pre>- None<br>- Basic128Rsa15<br>- Basic256<br>- Basic256Sha256<br>- Aes128Sha256RsaOaep<br>- Aes256Sha256RsaPss</pre> |
| Mode               | None              | Security Mode of OPC-UA<pre>-None<br>- Sign<br>- SignAndEncrypt</pre>                                                                            |
| CertFile           | none              | Cert file of OPC-UA, path to cert.pem                                                                                                            |
| KeyFile            | none              | Key file of OPC-UA, path to private key.pem                                                                                                      |
| Writable.Resources | none              | Subscritions of OPC-UA                                                                                                                           |

`Policy` and `Mode` are the defaults for a device that does not set those protocol properties.
Username and password are not service configuration. A device sets `SecretName`, and the service reads `username` and `password` from the secret store with `SecretProvider.GetSecret`.
An empty `SecretName` selects an anonymous user token.
`CertFile` and `KeyFile` are required when the effective policy or mode is not `None`. They identify this device service, not an individual server.
