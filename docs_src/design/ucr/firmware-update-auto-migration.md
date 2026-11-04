# Firmware Update Safe Auto-Migration of Configuration, Profiles, and Device Records

## Submitters
- Nilesh Dixit (Eaton)

## Changelog
- [pending](https://github.com/edgexfoundry/edgex-docs/pull/1496) (2026-09-15)

## Market Segments
- Manufacturing (industrial gateways, OT edge integration)
- Energy (power distribution, monitoring, protection)
- Public & Services (critical infrastructure operations)

## Motivation
In this use case, "firmware" means the software image or update package delivered to the EdgeX gateway or edge device host system. It does not mean firmware running inside a southbound field device managed by EdgeX. Whether that image/package is signed is deployment-specific and outside the core migration behavior defined here.

On many EdgeX gateways, the firmware image ships the EdgeX services together with their service resource files, while EdgeX runtime state (configuration in the configuration key/value store, device profiles and device records in metadata) is persisted separately and survives a firmware update. Here, "service resource files" means the packaged files consumed by an EdgeX service at startup: configuration files, device profile files, and device record files; they are not limited to device profiles alone.

Example: firmware v1.0 ships a device service whose device profile `Meter-A` defines the resources `Voltage` and `Current`. Firmware v1.1 ships the same service with a new configuration key and a new resource `PowerFactor` in `Meter-A`. After the update, the service finds its configuration and the `Meter-A` profile already persisted and, by default, does not load the new versions. The new key and `PowerFactor` never take effect without a manual migration or a factory reset. The same applies to container deployments when a service image is upgraded and its persisted data is kept.

As a result, configuration, device profiles, and device records shipped in a new image are not automatically reconciled with existing persisted state. This causes production risks:
- New required keys or device resources may not become active
- Deprecated values may remain and conflict with new behavior
- Operators may need manual reset/reseed steps that increase downtime and error risk

The use case goal is deterministic and safe migration of runtime state during firmware updates, without requiring factory reset or manual persistence cleanup.

## Target Users
- Device Manufacturer
- Device Owner
- Device Maintainer
- Software Developer
- Software Deployer
- Software Integrator
- Service Provider

## Description
An EdgeX host system receives a firmware image or software update package containing updated service resource files. After reboot into the updated firmware image, each EdgeX service that opts in should perform version-aware migration against persisted state.

Expected behavior:
- If incoming resource version is newer than stored version, migrate that category
- Support three independent categories:
  - Configuration (registry or configuration key/value store)
  - Device profiles (metadata)
  - Device records (metadata)
- Opt-in only: services and resource files that do not declare a version keep the current behavior
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
No standardized EdgeX-native approach that consistently handles configuration, profile, and device-record migration during firmware update while preserving operational safety.

## Requirements
- Introduce a standardized version-aware migration contract for service resource files:
  - Config version field for registry or configuration key/value-store migration
  - Profile version field for metadata profile migration
  - Device version field for metadata device-record migration
- Backward compatibility:
  - A service or resource file opts in only by declaring a version
  - Without a declared version, existing behavior is unchanged and existing resource files keep working without modification
- Migration trigger policy:
  - Migrate only when incoming version is greater than stored version
  - Skip when equal or lower
  - Support legacy adoption when the incoming file declares a version but no stored version exists
- Config migration behaviors:
  - Full overwrite mode
  - Additive merge mode
  - Explicit handling of removed keys to prevent zombie values
- Profile migration behaviors:
  - Replace/update existing profile on version bump
  - Support add/modify/delete of profile resources
- Device migration behaviors:
  - Update existing device record on version bump
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
- Firmware update migration for configuration, profile, and device-record state (tracked internally as LNXTK-35775)
- Production concern: rollback mismatch between firmware version and persisted migrated state
- Production concern: lifecycle handling for complete profile/device deletion

## References
- [EdgeX UCR Template](https://github.com/edgexfoundry/edgex-docs/blob/main/docs_src/design/ucr/template.md)
- [EdgeX Docs Repository](https://github.com/edgexfoundry/edgex-docs)
- [W3C WoT Use Cases and Requirements](https://www.w3.org/TR/wot-usecases)
- [IoT Market Segments Analysis](https://iot-analytics.com/iot-market-segments-analysis/)
