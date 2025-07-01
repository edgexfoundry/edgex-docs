# Reducing Payload Size for Device Events

## Submitters
- Jude Hung (IOTech)

## Changelog
<!--
List the changes to the document, incl. state, date, and PR URL.
State is one of: pending, approved, amended, deprecated.
Date is an ISO 8601 (YYYY-MM-DD) string.
PR is the pull request that submitted the change, including information such as the diff, contributors, and reviewers.

E.g.:
- [approved](URL of PR) (2022-04-01)
- [amended](URL of PR) (2022-05-01)
-->
- [pending]() (2025-07-01) - Initial draft of the ADR to reduce payload size for device events.
## Referenced Use Case(s)
This ADR proposes optimizing the size of device events. Currently, a single event with just one reading results in an event payload of approximately 600~700 bytes, which is relatively large for resource-constrained embedded devices.
The existing device event payload contains numerous fields, some of which can be redundant in certain scenarios. This unnecessary data increases the payload size, which can negatively affect performance and efficiency, particularly for devices with limited resources.
To address this, this ADR aims to reduce the payload size by eliminating redundant fields from device events. This use case was approved during the Palau planning meeting on April 15, 2025.

## Context
This ADR is architecturally significant because it tackles the payload size of device events, which is a key factor in EdgeX’s overall performance and efficiency — particularly for devices with limited resources.
The device event payload plays a critical role in the EdgeX architecture, serving as the means of transferring data from devices to EdgeX core services and ultimately to applications.
By reducing payload size, we can improve performance and decrease network bandwidth usage.
This ADR proposes adding a new global configuration option to control whether device event payloads should be optimized by removing redundant fields when applicable.
Details of these redundant fields and the conditions under which they can be removed are described in the next section.

## Proposed Design
The proposal introduces a new global configuration option, `EDGEX_OPTIMIZE_EVENT_PAYLOAD`, within the `core-common-config-bootstrapper` service.
When `EDGEX_OPTIMIZE_EVENT_PAYLOAD` is set to true, the event payload will be optimized as follows:

1. The `id` field will be omitted from each reading since it isn’t used by other EdgeX services or stored in the database.
2. The `deviceName` and `profileName` fields will be removed from each reading because they always match their event-level values.
3. The `origin` field in a reading will be removed if it’s identical to the event-level `origin`. 
4. The `resourceName` field will be omitted from a reading when an event contains only one reading and the `resourceName` is identical to the event’s `sourceName`.
5. All empty and null fields will be stripped from the reading.

To maintain backward compatibility, `EDGEX_OPTIMIZE_EVENT_PAYLOAD` will be set to false by default, meaning no payload shrinkage will occur unless explicitly enabled.

This ADR does not introduce any new services but will affect the following services:

- **Device Service SDK (Go and C)**: When `EDGEX_OPTIMIZE_EVENT_PAYLOAD` is enabled, device event payloads will include only the necessary fields. Redundant fields will be removed before publishing events to the message bus.
- **Core Data**: This service will inspect each incoming device event and restore any missing fields that were removed by the optimization, using the event-level data before persisting to the database.
- **Application Service SDK (Go and Python)**: Application services will similarly fill in any missing fields from event-level values before handing off the event for processing.

This ADR will not affect the existing models, DTOs, or APIs.

## Considerations
<!--
Document alternatives, concerns, ancillary or related issues, questions that arose in debate of the ADR. Indicate if/how they were resolved or mollified.
-->
- **Backward Compatibility**: The proposed design is backward compatible, as the `EDGEX_OPTIMIZE_EVENT_PAYLOAD` is set to false by default. This means that existing applications and services will continue to work without any changes.

## Decision
<!--
Document any agreed upon important implementation detail, caveats, future considerations, remaining or deferred design issues.
Document any part of the requirements not satisfied by the proposed design.
-->

## Other Related ADRs
<!--
List any relevant ADRs - such as a design decision for a sub-component of a feature, a design deprecated as a result of this design, etc.

Format:
- [ADR Title](URL) - the relevance
-->
- None

## References
<!--
List additional references 

Format:
- [Title](URL)
-->
- None
