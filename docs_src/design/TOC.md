# Use Cases and Design Records

## Use Case Records (UCRs)

!!! note 
    UCRs are listed in alphabetical order by title.

| Name/Link                                                                           | Short Description                                                   |
|-------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| [Bring Your Own Vault](./ucr/Bring-Your-Own-Vault.md)                               | Use Case for bringing your own Vault |
| [Common Configuration](./ucr/Common Configuration.md)                               | Use Case for having Common configuration used by all EdgeX services |
| [Core Data Retention and Persistent Cap](./ucr/Core-Data-Retention.md)              | Use Case for capping readings in Core Data                          |
| [Device Parent-Child Relationships](./ucr/Device-Parent-Child-Relationships.md)     | Use Case for Device Parent-Child Relationships                      |
| [Extending Device Data](./ucr/Extending-Device-Data.md)                             | Use Case for Extending of Device Data by Application Services       |
| [Provision Watch via Device Metadata](./ucr/Provision-Watch-via-Device-Metadata.md) | Use Case for Provision Watching via Additional Device Metadata      |
| [Record and Replay](./ucr/Record-and-Replay.md)                                     | Use Case for Recording and Replaying event/readings                 |
| [System Events for Devices](./ucr/System-Events-for-Devices.md)                     | Use Case for System Events for Device add/update/delete             |
| [Microservice Authentication](./ucr/Microservice-Authentication.md)                 | Use Case for Microservice Authentication                            |
| [URIs for files](.//ucr/URIs-for-Files.md)                                          | Use Case for loading service files from URIs                        |

## Architectural Design Records (ADRs)

!!! note
    ADRs are listed in chronological order by sequence number in title.

| Name/Link                                                                                    | Short Description                                                                       |
|----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| [0001 Registry Refactor](./adr/0001-Registy-Refactor.md)                                     | Separate out Registry and Configuration APIs                                            |
| [0002 Array Datatypes](./adr/device-service/0002-Array-Datatypes.md)                         | Allow Arrays to be held in Readings                                                     |
| [0003 V2 API Principles](./adr/core/0003-V2-API-Principles.md)                               | Principles and Goals of V2 API Design                                                   |
| [0004 Feature Flags](./adr/0004-Feature-Flags.md)                                            | Feature Flag Implementation                                                             |
| [0005 Service Self Config Init](./adr/0005-Service-Self-Config.md)                           | Service Self Config Init & Config Seed Removal                                          |
| [0006 Metrics Collection](./adr/0006-Metrics-Collection.md)                                  | Collection of service telemetry data                                                    |
| [0007 Release Automation](./adr/devops/0007-Release-Automation.md)                           | Overview of Release Automation Flow for EdgeX                                           |
| [0008 Secret Distribution](./adr/security/0008-Secret-Creation-and-Distribution.md)          | Creation and Distribution of Secrets                                                    |
| [0009 Secure Bootstrapping](./adr/security/0009-Secure-Bootstrapping.md)                     | Secure Bootstrapping of EdgeX                                                           |
| [0011 Device Service REST API](./adr/device-service/0011-DeviceService-Rest-API.md)          | The REST API for Device Services in EdgeX v2.x                                          |
| [0012 Device Service Filters](./adr/device-service/0012-DeviceService-Filters.md)            | Device Service event/reading filters                                                    |
| [0013 Device Service Events via Message Bus](./adr/013-Device-Service-Events-Message-Bus.md) | Device Services send Events via Message Bus                                             |
| [0014 Secret Provider for All](./adr/014-Secret-Provider-For-All.md)                         | Secret Provider for All EdgeX Services                                                  |
| [0015 Encryption between microservices](./adr/security/0015-in-cluster-tls.md)               | Details conditions under which TLS is or is not used                                    |
| [0016 Container Image Guidelines](./adr/security/0016-docker-image-guidelines.md)            | Documents best practices for security of docker images                                  |
| [0017 Securing access to Consul](./adr/security/0017-consul-security.md)                     | Access control and authorization strategy for Consul                                    |
| [0018 Service Registry](./adr/0018-Service-Registry.md)                                      | Service registry usage for EdgeX services                                               |
| [0019 EdgeX-CLI V2](./adr/core/0019-EdgeX-CLI-V2.md)                                         | EdgeX-CLI V2 Implementation                                                             |
| [0020 Delay start services (SPIFFE/SPIRE)](./adr/security/0020-spiffe.md)                    | Secret store tokens for delayed start services                                          |
| [0021 Device Profile Changes](./adr/core/0021-Device-Profile-Changes.md)                     | Rules on device profile modifications                                                   |
| [0022 Unit of Measure](./adr/core/0022-UoM.md)                                               | Unit of Measure                                                                         |
| [0023 North South Messaging](./adr/0023-North-South-Messaging.md)                            | Provide for messaging from north side systems through command down to device services   |
| [0024 System Events](./adr/0024-system-events.md)                                            | System Events (aka Control Plane Events) published to the MessageBus                    |
| [0025 Record and Replay](./adr/application/0025-Record-and-Replay.md)                        | Record data from various devices and play data back without devices present             |
| [0026 Common Configuration](./adr/0026-Common Configuration.md)                              | Separate out the common configuration setting into a single source for all the services |
| [0027 URIs for Files](./adr/0027-URIs for Files.md)                                          | Add capability to load service files from remote locations using URIs                   |
| [0028 Microservice communication security (token)](./adr/security/0028-authentication.md)    | Microservice communication security / authentication (token-based)                      |
| [0029 Microservice communication security (E2EE)](./adr/security/0029-authentication.md)     | Microservice communication security / authentication (end-to-end authentication)        |
| [0030 Performance Test Harness](./adr/0030-Performance-Test-Harness.md)                      | Run Performance Test and generate report        |
