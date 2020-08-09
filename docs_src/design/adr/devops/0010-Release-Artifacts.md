# Release Artifacts

## Status

In Review 06/10/2020

## Context

During the Geneva release of EdgeX Foundry the DevOps WG transformed the CI/CD process with new Jenkins pipeline functionality. After this new functionality was added we also started adding release automation. This new automation is outlined in ADR 0007 Release Automation. However, in [ADR 0007 Release Automation](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/devops/0007-Release-Automation.md) only three release artifact types are outlined. This document is meant to be a living document to try to outlines all currently supported artifacts associated with an EdgeX Foundry release, and should be updated if/when this list changes.

## Release Artifact Types

### Docker Images

*Tied to Code Release?* Yes

Docker images are released for every named release of EdgeX Foundry. During development the community releases images to the `docker.staging` repository in [Nexus](http://nexus3.edgexfoundry.org). At the time of release we promote the last tested image from `docker.staging` to `docker.release`. In addition to that we will publish the docker image on [DockerHub](https://hub.docker.com/orgs/edgexfoundry).

#### Nexus Retention Policy

##### docker.snapshots
Retention Policy: 90 days since last download

Contains: Docker images that are not expected to be released. This contains images to optimize the builds in the CI infrastructure. The definitions of these docker images can be found in the [edgexfoundry/ci-build-images](https://github.com/edgexfoundry/ci-build-images) Github repository.

Docker Tags Used: Version, Latest

##### docker.staging
Retention Policy: 180 days since last download

Contains: Docker images built for potential release and testing purposes during development.

Docker Tags Used: Version (ie: v1.x), Release Branch (master, fuji, etc), Latest

##### docker.release
Retention Policy: No automatic removal. Requires TSC approval to remove images from this repository.

Contains: Officially released docker images for EdgeX. 

Docker Tags Used:•Version (ie: v1.x), Latest 

[Nexus Cleanup Policies Reference](https://help.sonatype.com/repomanager3/repository-management/cleanup-policies)

### Docker Compose Files

*Tied to Code Release?* Yes

Docker compose files are released alongside the docker images for every release of EdgeX Foundry. During development the community maintains compose files a folder named `nightly-build`. These compose files are meant to be used by our testing frameworks. At the time of release the community makes compose files for that release in a folder matching it's name. (ie: `geneva`)

### Github Page: EdgeX Docs

*Tied to Code Release?* No

EdgeX Foundry releases a set of documentation for our project at [http://docs.edgexfoundry.org](http://docs.edgexfoundry.org). This page is a Github page that is managed by the [edgex/foundry/edgex-docs](https://github.com/edgexfoundry/edgex-docs/) Github repository. As a community we make our best effort to keep these docs up to date. On this page we are also versioning the docs with the semantic versions of the named releases. As a community we try to version our documentation site shortly after the official release date but documentation changes are addressed as we find them throughout the release cycle.

### GitHub Tags

*Tied to Code Release?* Yes, for the final semantic version

Github tags are used to track the releases of EdgeX Foundry. During development the tags are incremented automatically for each commit using a development suffix (ie: `v1.1.1-dev.1` -> `v1.1.1-dev.2`). At the time of release we release a tag with the final semantic version (ie: `v1.1.1`).

### Snaps

*Tied to Code Release?* Yes

Snaps are released for every named release of EdgeX Foundry. During development the community stages snaps to the `latest/edge` channel of the [Snapcraft Store](https://snapcraft.io/search?q=edgexfoundry). At the time of code freeze we will promote the snaps from `latest/edge` to the `latest/beta` amd `latest/candidate` channels as beta release. This beta release is to trigger validation of the release candidate. At the time of release we will promote the snaps from `latest/beta` to `latest/stable`. In addition we also create a named release track for the release. (ie: `geneva/stable`).

### SwaggerHub API Docs

*Tied to Code Release?* No

In addition to our documentation site EdgeX foundry also releases our API specifications on Swaggerhub.

### Testing Framework

*Tied to Code Release?* Yes

The EdgeX Foundry community has a set of tests we maintain to do regression testing during development this framework is tracking the `master` branch of the components of EdgeX. At the time of release we will update the testing frameworks to point at the released Github tags and add a version tag to the testing frameworks themselves. This creates a snapshot of testing framework at the time of release for validation of the official release.

### Known Build Dependencies for EdgeX Foundry

There are some internal build dependencies within the EdgeX Foundry organization. When building artifacts for validation or a release you will need to take into the account the build dependencies to make sure you build them in the correct order.

![Known EdgeX Foundry Build Dependencies](0010/known-build-dependencies.png)

 - Edgex-go Snap: Has dependencies on app-service-configurable, device-virtual-go and support-rulesengine because they are included in the snap.
 - Application services have a dependency on the Application services SDK.
 - Go Device services have a dependency on the Go Device SDK.
 - C Device services have a dependency on the C Device SDK.

## Decision

## Consequences

This document is meant to be a living document of all the release artifacts of EdgeX Foundry. With this ADR we would have a good understanding on what needs to be released and when they are released. Without this document this information will remain tribal knowledge within the community.