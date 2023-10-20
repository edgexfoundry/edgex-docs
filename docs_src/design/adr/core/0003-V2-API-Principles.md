# Geneva API Guiding Principles

## Status

Accepted by EdgeX Foundry working groups as of Core Working Group meeting 16-Jan-2020

!!! Note
    This ADR was written pre-Geneva with an assumption that the V2 APIs would be available in Geneva.  In actuality, the full V2 APIs will be delivered in the Ireland release (Spring 2020)

## Context

A redesign of the EdgeX Foundry API is proposed for the Geneva release. This is understood by the community to warrant a 2.0 release that will not be backward compatible. The goal is to rework the API using solid principles that will allow for extension over the course of several release cycles, avoiding the necessity of yet another major release version in a short period of time.

Briefly, this effort grew from the acknowledgement that the current models used to facilitate requests and responses via the EdgeX Foundry API were legacy definitions that were once used as internal representations of state within the EdgeX services themselves. Thus if you want to add or update a device, you populate a full device model rather than a specific Add/UpdateDeviceRequest. Currently, your request model has the same definition, and thus validation constraints, as the response model because they are one and the same! It is desirable to separate and be specific about what is required for a given request, as well as its state validity, and the bare minimum that must be returned within a response.

Following from that central need, other considerations have been used when designing this proposed API. These will be enumerated and briefly explained below.

**1.) Transport-agnostic**
Define the request/response data transfer objects (DTO) in a manner whereby they can be used independent of transport. For example, although an OpenAPI doc is implicitly coupled to HTTP/REST, define the DTOs in such a way that they could also be used if the platform were to evolve to a pub/sub architecture.

**2.) Support partial updates via PATCH**
Given a request to, for example, update a device the user should be able to update only some properties of the device. Previously this would require an endpoint for each individual property to be updated since the "update device" endpoint, facilitated by a PUT, would perform a complete replacement of the device's data. If you only wanted to update the LastConnected timestamp, then a separate endpoint for that property was required. We will leverage PATCH in order to update an entity and only those properties populated on the request will be considered. Properties that are missing or left blank will not be touched. 

**3.) Support multiple requests at once**
Endpoints for the addition or updating of data (POST/PATCH) should accept multiple requests at once. If it were desirable to add or update multiple devices with one request, for example, the API should facilitate this.

**4.) Support multiple correlated responses at once**
Following from #3 above, each request sent to the endpoint must result in a corresponding response. In the case of HTTP/REST, this means if four requests are sent to a POST operation, the return payload will have four responses. Each response must expose a "code" property containing a numeric result for what occurred. These could be equivalent to HTTP status codes, for example. So while the overall call might succeed, one or more of the child requests may not have. It is up to the caller to examine each response and handle accordingly.

In order to correlate each response to its original request, each request must be assigned its own ID (in GUID format). The caller can then tie a response to an individual request and handle the result accordingly, or otherwise track that a response to a given request was not received. 

**5.) Use of 207 HTTP Status (Multi-Result)**
In the case where an endpoint can support multiple responses, the returned HTTP code from a REST API will be 207 (Multi-status)

**6.) Each service should provide a "batch" request endpoint**
In addition to use-case specific endpoints that you'd find in any REST API, each service should provide a "batch" endpoint that can take any kind of request. This is a generic endpoint that allows you to group requests of different types within a single call. For example, instead of having to call two endpoints to get two jobs done, you can call a single endpoint passing the specific requests and have them routed appropriately within the service. Also, when considering agnostic transport, the batch endpoint would allow for the definition and handling of "GET" equivalent DTOs which are now implicit in the format of a URL.

**7.) GET endpoints returning a list of items must support pagination**
URL parameters must be supported for every GET endpoint to support pagination. These parameters should indicate the current page of results and the number of results on a page.

## Decision

Commnunity has accepted the reasoning for the new API and the design principles outlined above. The approach will be to gradually implement the V2 API side-by-side with the current V1 APIs. We believe it will take more than a single release cycle to implement the new specification. Releases of that occur prior to the V2 API implementation completion will continue to be major versioned as 1.x. Subsequent to completion, releases will be major versioned as 2.x.

## Consequences

- Backward incompatibility with EdgeX Foundry's V1 API requires a major version increment (e.g. v2.x).
- Service-level testing (e.g. blackbox tests) needs to be rewritten.
- Specification-first development allows for different implementations of EdgeX services to be certified as "EdgeX Compliant" in reference to an objective standard.
- Transport-agnostic focus enables different architectural patterns (pub/sub versus REST) using the same data representation.