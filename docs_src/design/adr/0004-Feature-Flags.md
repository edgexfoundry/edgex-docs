# Feature Flag Proposal 

## Status 

Accepted 

## Context 

Out of the proposal for releasing on time, the community suggested that we take a closer look at feature-flags.  

Feature-flags are typically intended for users of an application to turn on or off new or unused features. This gives user more control to adopt a feature-set at their own pace – i.e disabling store and forward in App Functions SDK without breaking backward compatibility. 

It can also be used to indicate to developers the features that are more often used than others and can provided valuable feedback to enhance and continue a given feature. To gain that insight of the use of any given feature, we would require not only instrumentation of the code but a central location in the cloud (i.e a TIG stack) for the telemetry to be ingested and in turn reported in order to provide the feedback to the developers. This becomes infeasible primarily because the cloud infrastructure costs, privacy concerns, and other unforeseen legal reasons for sending “Usage Metrics” of an EdgeX installation back to a central entity such as the Linux Foundation, among many others. Without the valuable feedback loop, feature-flags don’t provide much value on their own and they certainly don’t assist in increasing velocity to help us deliver on time.  

Putting aside one of the major value propositions listed above, feasibility of a feature flag “module” was still evaluated. The simplest approach would be to leverage configuration following a certain format such as FF_[NewFeatureName]=true/false. This is similar to what is done today. Turning on/off security is an example, turning on/off the registry is another. Expanding this further with a module could offer standardization of controlling a given feature such as `featurepkg.Register(“MyNewFeature”)` or `featurepkg.IsOn(“MyNewFeature”)`. However, this really is just adding complexity on top of the underlying configuration that is already implemented. If we were to consider doing something like this, it lends it self to a central management of features within the EdgeX framework—either its own service or possibly added as part of the SMA. This could help address concerns around feature dependencies and compatibility. Feature A on Service X requires Feature B and Feature C on Service Y. Continuing down this path starts to beget a fairly large impact to EdgeX for value that cannot be fully realized.  

## Decision 

The community should NOT pursue a full-fledged feature flag implementation either homegrown or off-the-shelf. 

However, it should be encouraged to develop features with a wholistic perspective and consider leveraging configuration options to turn them on/off. In other words, once a feature compiles, can work under common scenarios, but perhaps isn’t fully tested with edge cases, but doesn’t impact any other functionality, should be encouraged.  

## Consequences 

Allows more focus on the many more competing priorities for this release. 

Minimal impact to development cycles and release schedule 

 

 

 