# System Events ADR
### Submitters
- Lenny Goodell (Intel)

## Change Log
- [approved](https://github.com/edgexfoundry/edgex-docs/pull/795) (2022-07-12)

## Referenced Use Case(s)
- [System Events for Devices ](https://docs.edgexfoundry.org/2.3/design/ucr/0001-System-Events-for-Devices/)

## Context
System Events, aka Control Plane Events (CPE), are new to EdgeX. This ADR addresses the [System Events for Devices](https://docs.edgexfoundry.org/2.3/design/ucr/0001-System-Events-for-Devices/) use case with an extensible design that can address other System Event use cases that may be identified in the future. This extensible design approach and the fact that System Events are produced and consumed by different EdgeX services makes it architecturally significant warranting this ADR.

## Proposed Design
To address the [System Events for Devices](https://docs.edgexfoundry.org/2.3/design/ucr/0001-System-Events-for-Devices/) use case, Core Metadata will publish a new `SystemEvent` DTO to the EdgeX MessageBus when a device is added, updated or deleted. Consumers of these System Events will subscribe to the MessageBus to receive the new `SystemEvent` DTO .

#### Data Transfer Object (DTO)

This new `SystemEvent` DTO will contain the following data describing the System Event:

- Source - Publisher of the System Event, i.e. core-metadata
- Type - Type of System Event, i.e. device
- Action - The Action that triggered the System Event, i.e. add/update/delete
- Timestamp - Creation date/time for the System Event
- Owner - Owner the data for the System Event, i.e device-onvif-camera as the device owner
    - Optional based on the Type
- Tags - Key  value pairs to add addition context to the System Event, i.e. device-profile=onvif-camera
    - Optional based on the Type and/or Action
- Details - Data details important to the System Event,  i.e. Device DTO of added/updated/deleted device
    - Optional object which varies based on the Type and/or Action
    - This an object similar to `ObjectValue` in `Reading` DTO

!!! note
    As defined, this DTO should suffice for future System Event use cases.  

#### MessageBus 

Services that publish System Events (Core Metadata) must connect to the EdgeX MessageBus and have MessageBus configuration similar to that of Core Data's [here](https://github.com/edgexfoundry/edgex-go/blob/v2.2.0/cmd/core-data/res/configuration.toml#L53-L74). This design assumes that Core Metadata will have this capability and configuration due to planned implementation of Service Metrics. 

The `PublishTopicPrefix` property in Core Metadata's `MessageQueue` configuration will be used for System Events and set to `edgex/system-event`.

#### MessageBus Topic

The new `SystemEvent` DTO will be published to a multi-level topic allowing subscribers to filter by topic. The format of this topic for **System Events** will be:

​		`{PublishTopicPrefix}/{source}/{type}/{action}`

where 

- `{source}` = Publisher of the System Event, i.e. `core-metadata`
- `{type}` = Type of System Event, i.e. `device`
- `{action}` = The Action that triggered the System Event, i.e. `add`

Specific use cases may add additional levels as needed. The **Device System Events** use case will add the following levels

- `{owner}` =  Owner the data for the System Event, i.e `device-onvif-camera` as the device owner`
- `{profile}` = Device profile associated with the Device, i.e `onvif-camera`

!!! example - "Example - System Event subscription topics"
    ```
    edgex/system-event/# - All system events
    edgex/system-event/core-metadata/# - only system events from Core Metadata
    edgex/system-event/core-metadata/device/# - only device system events from Core Metadata
    edgex/system-event/core-metadata/device/add/device-onvif-camera/# - only add device system events for device-onvif-camera
    edgex/system-event/core-metadata/device/#/#/onvif-camera - only device system events for devices created for the onvif-camera device profile
    ```

#### Consumers

Consumers of Device System Events will likely be custom application services as described in [System Events for Devices ](https://docs.edgexfoundry.org/2.3/design/ucr/0001-System-Events-for-Devices/). No changes are required to the App Functions SDK since it already supports processing of different types via the [Target Type](https://docs.edgexfoundry.org/2.2/microservices/application/AdvancedTopics/#target-type) capability. Developers of custom application services  that consume System Events will need to do the following:

- Set the Target Type to `&dtos.SystemEvent{}` when creating an instance of `ApplicationService` using the [NewAppServiceWithTargetType](https://docs.edgexfoundry.org/2.2/microservices/application/ApplicationServiceAPI/#newappservicewithtargettype) factory function.
- Write custom pipeline function that expects the new `SystemEvent` DTO and process it accordingly.  Similar to how the [ToLineProtocol](https://docs.edgexfoundry.org/2.2/microservices/application/BuiltIn/#tolineprotocol) pipeline function expects the Metric DTO.

### Services/Modules impacted

- Core Metadata service
    - This service is the single point for device Add/Update/Delete and will be the producer of Device System Events.
- Core Contracts module
    - The new `SystemEvent` DTO will be added to this repository
- Camera Management App Service Example
    - Once Device System Events are implemented, the [Camera Management](https://github.com/edgexfoundry/edgex-examples/tree/main/application-services/custom/camera-management) example can be updated to consume them.
- Device SDK/Service (future)
    - Once Device System Events are implemented, the Device SDKs can switch to receiving them via MesssageBus rather than the REST callbacks from Core Metadata. Anything beyond recognizing this future enhancement, it is out-of-scope for this ADR.


## Considerations
- This design approach can be used for future use cases, such as **System Events for Device Profiles** and **System Events for Device Services** when/if they are deemed needed.
-  Another design approach that was considered is to use Support Notifications to send the System Events via REST. This would require consumers to create subscriptions to receive the Systems Events via REST to some endpoint on the consuming service. This subscription would be created using the existing Support Notifications [subscription](https://app.swaggerhub.com/apis/EdgeXFoundry1/support-notifications/2.2.0#/default/post_subscription) REST API. Likely each subscription would be for a specific Event Type. System Events would be Published by POSTing them to Support Notification [notification](https://app.swaggerhub.com/apis/EdgeXFoundry1/support-notifications/2.2.0#/default/post_notification) REST API, which would them forward them via REST POST to each service subscribed to the particular System Event. The System Event DTO would still be used, just sent via the REST. This approach is more complex, requires consumer services to have new REST endpoint(s) to receive the System Events and relies on REST rather than messaging, thus this approach was not chosen.

## Decision
This design will satisfy the  [System Events for Devices](https://docs.edgexfoundry.org/2.3/design/ucr/0001-System-Events-for-Devices/) use case as well as possibly other future System Event use cases.

## Other Related ADRs
- [Metric Collection ADR](https://docs.edgexfoundry.org/2.2/design/adr/0006-Metrics-Collection/) - Use of EdgeX MessageBus to publish and subscribe service metrics
- [North-South Messaging ADR](https://docs.edgexfoundry.org/2.2/design/adr/0023-North-South-Messaging/) - Use of EdgeX MessageBus to publish and subscribe commands/responses

## References
- Control Plane Events (CPE) (aka System Events) were initially proposed as part of the metrics collection ADR as early as March 2020. You may find discussions relevant to CPE in these ADR and other design/architecture discussions since March 2020.
  - [initial ADR on EdgeX service level metrics collection for Hanoi](https://github.com/edgexfoundry/edgex-docs/pull/97)