# Changes to Device Profiles

## Status
** Proposed **
(as of 1/20/22)

Please see a [prior PR](https://github.com/edgexfoundry/edgex-docs/pull/605) on this topic that detailed much of the debate and context on this issue.  For clarity and simplicity, that PR was closed in favor of this simpler ADR.

## Context
While the device profile has always been the way to describe a device/sensor and template its communications to the rest of the EdgeX platform, over the course of EdgeX evolution there have been changes in what could change in a profile (often based on its associations to other EdgeX objects).  This document is meant to address the issue of change surrounding device profiles in EdgeX going forward – specifically when can a device profile (or its sub-elements such as device resources) be added, modified or removed.

### Summary of Device Profile Rules
These rules will be implemented in core metadata on device profile API calls.

- A device profile can be added anytime
- Device resources or device commands can be added to a device profile anytime
- Attributes and properties can be added to a device profile anytime
- A device profile can be modified when the device profile is not associated to a device or provision watcher
    - this includes modifying any properties (except identifiers like names and ids)
    - this includes changes to the array of device resources, device commands
    - this includes changes to attributes and properties (of device resources)
    - even when a device profile is associated to a device or provision watcher, properties of the device profile or device resource can be modified when the property change will not affect the behavior of the system (example: the description property has no effect on the system).
- A device profile cannot be removed when it is associated to a device or provision watcher.
- A device profile can be removed or modified even when associated to an event or reading unless configuration options (see New Configuration Settings below) are set prohibiting removal or modification when associated to an event/reading
    - the rationale behind this is that events and readings are generally considered short lived (ephemeral) objects and already contain the necessary device profile information that are needed by the system during their short life without having to refer to the device profile
    - see note below in Consequences that a new Units property must be added to the Reading object in order to support this rule and the need for all relevant profile data to be in the event/reading.

### Ancillary Rules associated to Device Profiles
- Identifying or “key” fields for device profiles, device resources, etc. cannot be modified and can never be null.
- A device profile can begin life “empty” - meaning that it has no device resources or device commands.

### New APIs

The following APIs would be added to the metadata REST service in order to meet the design specified above.

- Add Profile General Property PATCH API (allow to modify profile properties except name and id)
- Add Profile Device Resource POST API
- Add Profile Device Resource PATCH API (allow to modify Description and IsHidden only)
- Add Profile Device Resource DELETE API (allow as described above)
- Add Profile Device Command POST API
- Add Profile Device Command PATCH API (allow as described above)
- Add Profile Device Command DELETE API (allow as described above)

### New Configuration Settings

Some adopters may not view event/reading data as ephemeral or short lived.  These adopters may choose not to allow device profiles to be modified or removed when associated to an event or reading.
For this reason, two new configuration options will be added to metadata configuration that are used to reject modifications or deletions.

- AllowEventAssociatedDeviceProfileModifications (set to true by default)
- AllowEventAssociatedDeviceProfileDeletes (set to true by default)

When either of these config settings are set to false, metadata would accordingly reject changes to or removal of profiles when the profile is associated to any event/reading.

## Consequences/Considerations
In order to allow device profiles to be updated or removed even when associated to an EdgeX event/reading, a new property needs to be added to the reading object.

- Readings will now contain a “Units” (string) property.  This property will indicate the units of measure for the Value in the Reading and will be populated based on the Units for the device resource.
- This allows the event/reading to contain all relevant information from the device profile that is needed by the system during the course of the event/reading’s life.
- This allows the device profile to be modified or even removed even when there are events/readings in the system that were created from information in the device profile.

## References

- [Metadata API](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-metadata/2.1.0)
- [Device Service SDK Required Functionality](https://docs.edgexfoundry.org/2.1/design/legacy-requirements/device-service/)