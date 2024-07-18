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
Ex: make gen ds-virtual ds-rest caddy_reverse_proxy
With that flag edgex will load Caddy config file. Caddy also supports Nginx config so current file can be use.
No other service will need to be modified since Caddy will use the same address and port as Nginx.
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

Advantages of Caddy:
 -Using Automatic HTTPS
  This is probably the most well-known thing about Caddy. It will switch all HTTP traffic to HTTPS and acquire and renew SSL/TLS certificates for your site automatically through Let's Encrypt.

 -The Easy Configuration:
  The Caddyfile is an easy-to-understand and-write configuration file used by Caddy. Because of this, configuring your server might be easier and faster.

 -Wide applicability:
  Plugins allow you to extend Caddy's capabilities as needed. Apart from the numerous pre-made plugins, you also have the choice to make your own.

 -Coded in the Go language:
  The speed and efficiency of Go are passed on to Caddy because it is written in Go. Additionally, there are no dependencies to be concerned about because it is statically linked.

Disadvantages of Caddy:
 -Less Mature
  Although Caddy offers numerous unique capabilities, it is still a relatively young project that lacks the experience and thorough testing of more established web servers.

 -The Limited Module Ecosystem
  Although Caddy's extensibility is a strong point, the module ecosystem is not as developed or extensive as it is for other servers, such as Apache or Nginx. The responsability fall on the user.

 -A Lesser Community Support
  Because of its smaller user base, obtaining community support and finding solutions to issues may be a bit more complicated than with more established web servers such as Apache or Nginx.

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
