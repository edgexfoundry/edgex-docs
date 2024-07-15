# Caddy Web Server as option

## Submitters
- Miguel Herrnsdorf

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

## Referenced Use Case(s)
<!--
List all relevant use case / requirements documents.
ADR requires at least one relevant, approved use case.

Format:
- [UC Name](URL of use case)

Add explanations if the ADR is not addressing all the requirements of a use case.
-->

## Context

Currently there is only one option to use as webserver with Edgex, Nginx. This proposal is to add Caddy as web server alternative of Nginx, leveraging the many advantages and easy to implement usage that Caddy offers out of the box. Also, there are many plugins available for most common use, but you can write your own if you have a specific requirements. And since is written in Go and with extensibility in mind, plugins can compile as native code, in a way that cannot be broken during deployments or by system upgrades.
<!--
Describe:
- how the design is architecturally significant - warranting an ADR (versus simple issue and PR to fix a problem)
- the high level design approach (details described in the proposed design below)
-->

## Proposed Design

A flag should be passed to let the system know that the user wants to use Caddy as a reverse-proxy instead of Nginx (like NATS). If flag is used, a new Caddy container will be created instead of the Nginx coantainer.
<!--
Details of the design (without getting into implementation where possible).
Outline:
- services/modules to be impacted (changed)
- new services/modules to be added
- model and DTO impact (changes/additions/removals)
- API impact (changes/additions/removals)
- general configuration impact (establishment of new sections, changes/additions/removals)
- devops impact
-->

## Considerations

Full Caddy features can found [here](https://caddyserver.com/features)
<!--
Document alternatives, concerns, ancillary or related issues, questions that arose in debate of the ADR. Indicate if/how they were resolved or mollified.
-->

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

## References
<!--
List additional references 

Format:
- [Title](URL)
-->
