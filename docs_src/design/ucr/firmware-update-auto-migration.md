# Firmware Update Safe Auto-Migration of Configuration, Profiles, and Devices

## Submitters
- Nilesh Dixit (Eaton)

## Changelog
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/1496) (2026-09-15)

## Market Segments
- Manufacturing (industrial gateways, OT edge integration)
- Energy (power distribution, monitoring, protection)
- Public & Services (critical infrastructure operations)

## Motivation
In this use case, "firmware" means the software image or update package delivered to the EdgeX gateway or host system. It does not mean firmware running inside a southbound field device managed by EdgeX.

Edge systems based on EdgeX commonly keep runtime state in persistence services, while service resource files are delivered in immutable firmware artifacts. Here, "service resource files" means the packaged files consumed by an EdgeX service at startup, such as configuration files, device profile files, and device definition files.

During firmware upgrades, configuration, device profiles, and device definitions shipped in the new image may not be automatically reconciled with existing persisted state. This causes production risks:
- New required keys or device resources may not become active
- Deprecated values may remain and conflict with new behavior
- Operators may need manual reset/reseed steps that increase downtime and error risk

The use case goal is deterministic and safe migration of runtime state during firmware updates, without requiring factory reset or manual DB cleanup.

## Target Users
- Device Manufacturer
- Device Owner
- Device Maintainer
- Software Developer
- Software Deployer
- Software Integrator
- Service Provider

## Description
An EdgeX gateway or host system receives a firmware image or software update package containing updated service resource files. These service resource files are the packaged startup artifacts for an EdgeX service, including configuration files, device profile files, and device definition files; they are not limited to device profiles alone.

After reboot into the updated firmware, each affected EdgeX service should perform version-aware migration against persisted state.

Expected behavior:
- If incoming resource version is newer than stored version, migrate that category
- Support three independent categories:
  - Configuration (registry/KVS)
  - Device profiles (metadata)
  - Device definitions (metadata)
- Preserve backward compatibility for unversioned files
- Avoid cross-service side effects
- Provide clear logs and auditability for all migration actions

Operational intent:
- Upgrade should not require factory reset
- Migration should run during startup before normal service workload
- Migration should be idempotent and safe to retry on restart

## Existing solutions
- Manual post-upgrade scripts:
  - Pros: Flexible and explicit control
  - Gaps: High operational burden, high human-error risk, hard to scale across services
- Full persistence wipe and reseed:
  - Pros: Guarantees new file values applied
  - Gaps: Destroys user/operator runtime changes, unacceptable for many production deployments
- Selective key overwrite flags:
  - Pros: Lightweight for config-only changes
  - Gaps: Does not fully address profile/device migration and deletion lifecycle

Gap summary:
No standardized EdgeX-native approach that consistently handles config/profile/device migration during firmware update while preserving operational safety.

## Requirements
- Introduce a standardized version-aware migration contract for service resource files:
  - Config version field for registry migration
  - Profile version field for metadata profile migration
  - Device version field for metadata device migration
- Migration trigger policy:
  - Migrate only when incoming version is greater than stored version
  - Skip when equal or lower
  - Support legacy adoption when stored version is absent
- Config migration behaviors:
  - Full overwrite mode
  - Additive merge mode
  - Explicit handling of removed keys to prevent zombie values
- Profile migration behaviors:
  - Replace/update existing profile on version bump
  - Support add/modify/delete of profile resources
- Device migration behaviors:
  - Update existing device definition on version bump
  - Support add/modify of relevant device fields
- Isolation and safety:
  - Scope operations per service namespace
  - Prevent impact on unrelated services
- Reliability:
  - Idempotent operations
  - Clear failure behavior and retry-on-restart strategy
- Observability:
  - Structured logs indicating decision path, versions compared, and actions taken
- Security and governance:
  - The migration design must work regardless of whether the deployment uses signed or unsigned update packages
  - No secrets written to logs during migration
- E2E rollback considerations:
  - Define expected behavior if firmware rolls back to an older version while persistence remains at a newer migrated version
- E2E deletion lifecycle:
  - Define standard mechanism for deleting entire profiles/devices removed by new firmware

## Related Issues
- Firmware update migration for config/profile/device state (internal tracking ticket): LNXTK-35775
- Production concern: rollback mismatch between firmware version and persisted migrated state
- Production concern: lifecycle handling for complete profile/device deletion

## References
- [EdgeX UCR Template](https://github.com/edgexfoundry/edgex-docs/blob/main/docs_src/design/ucr/template.md)
- [EdgeX Docs Repository](https://github.com/edgexfoundry/edgex-docs)
- [W3C WoT Use Cases and Requirements](https://www.w3.org/TR/wot-usecases)
- [IoT Market Segments Analysis](https://iot-analytics.com/iot-market-segments-analysis/)
