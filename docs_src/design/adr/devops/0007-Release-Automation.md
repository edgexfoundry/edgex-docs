# Release Automation

## Status

Approved by TSC 04/08/2020

## Context

EdgeX Foundry is a framework composed of microservices to ease development of IoT/Edge solutions. With the framework getting richer, project growth, the number of artifacts to be released has increased. This proposal outlines a method for automating the release process for the base artifacts.

## Requirements

### Release Artifact Definition

For the scope of Hanoi release artifact types are defined as:

- GitHub tags in the repositories.
- Docker images in our Nexus repository and Docker hub.
- *Snaps in the Snapcraft store.

This list is likely to expand in future releases.

*The building and publishing of snaps was removed from community scope in September 2020 and is managed outside the community by Canonical.

### General Requirements

As the EdgeX Release Czar I gathered the following requirements for automating this part of the release.

1. The release automation needs a manual trigger to be triggered by the EdgeX Release Czar or the Linux Foundation Release Engineers. The goal of this automation is to have a "push button" release mechanism to reduce human error in our release process.
2. Release artifacts can come from one or more GitHub repositories at a time.
3. GitHub repositories can have one or more release artifact types to release.
4. GitHub repositories can have one or more artifacts of a specific type to release. (For example: The mono repository, edgex-go, has more than 20 docker images to release.)
5. GitHub repositories may be released at different times. (For example: Application and Device service repositories can be released on a different day than the Core services in the mono repository.)
6. Ability to track multiple release streams for the project.
7. An audit trail history for releases.

## Location

The code that will manage the release automation for EdgeX Foundry will live in a repository called `cd-management`. This repository will have a branch named `release` that will track the releases of artifacts off the `main` branch of the EdgeX Foundry repositories.

### Multiple Release Streams

EdgeX Foundry has this idea of multple release streams that basically coincides with different named branches in GitHub. For the majority of the main releases we will be targeting those off the `main` branch. In our `cd-management` repository we will have a `release` branch that will track the `main` branches EdgeX repositories. In the future we will mark a specific release for long term support (LTS). When this happens we will have to branch off `main` in the EdgeX repositories and create a separate release stream for the LTS. The suggestion at that point will be to branch off the `release` branch in `cd-management` as well and use this new release branch to track the LTS branches in the EdgeX repositories.

## Release Flow

### Go Modules, Device and Application SDKs

#### During Development

![Merge Actions](0007/gomods_mergeactions.png)

Go modules, Application and Device SDKs only release a GitHub tag as their release. Go modules, Application and Device SDKs are set up to automatically increment a developmental version tag on each merge to `main`. (IE: 1.0.0-dev.1 -> 1.0.0-dev.2)

#### Release

![Release Actions](0007/gomods_releaseactions.png)

The release automation for Go Modules, Device and Application SDKs is used to set the final release version git tag. (IE: 1.0.0-dev.X -> 1.0.0)
For each release, the Go Modules, Device and Application SDK repositories will be tagged with the release version.

### Core Services (Including Security and System Management services), Application Services, Device Services and Supporting Docker Images

#### During Development

![Merge Actions](0007/mergeactions.png)

For the Core Services, Application Services, Device Services and Supporting Docker Images we release Github tags and docker images. On every merge to the `main` branch we will do the following; increment a developmental version tag on GitHub, (IE: 1.0.0-dev.1 -> 1.0.0-dev.2), stage docker images in our Nexus repository (docker.staging).

#### Release

![Release Actions](0007/releaseactions.png)

The release automation will need to do the following:

1. Set version tag on GitHub. (IE: 1.0.0-dev.X -> 1.0.0)
2. Promote docker images in our Nexus repository from docker.staging to docker.release and public Docker hub.

### Supporting Assets (e.g. edgex-cli)

#### During Development

For supporting release assets (e.g. edgex-cli) we release GitHub tags on every merge to the `main` branch. For every merge to `main` we will do the following; increment a developmental version tag on GitHub, (IE: 1.0.0-dev.1 -> 1.0.0-dev.2) and store the build artifacts in our Nexus repository.

#### Release

For EdgeX releases the release automation will set the final release version by creating a git tag (e.g. 1.0.0-dev.X -> 1.0.0) and produce a Github Release containing the binary assets targeted for release.
