# Use Cases and Design Process
This document describes the EdgeX use case driven requirements engineering and design process.

Approved by consent of the TSC *TBD*

Supersedes the processes documented on the [EdgeX Wiki](https://wiki.edgexfoundry.org/pages/viewpage.action?pageId=73663048)

## Use Case Driven Approach to Requirements and Design
Designing an architecture is a very time consuming task. It is best to start that with a solid foundation. The obvious goal is to design an architecture that satisfies the functional requirements, while being secure, flexible, and robust. Requirements are very important factors when designing a system. They should be derived from established, validated, and most importantly, written use cases. To avoid feature creep, the architecture should focus on requirements that are backed by multiple use cases and in the meantime try to remain extensible.

The following figure outlines the EdgeX process around use cases, requirements capture, and architectural design.

![design process](Process.png)

## Use Cases and Requirements
In any software system, new needs of the software are encountered on a regular basis. Any need that is more than a request to fix a bug or make a minor addition/change to the software should be added as feature requests (on Github) and supported by written use cases. The use cases should be documented in an EdgeX Use Case Record (UCR). UCRs must be reviewed by domain experts and approved by the TSC per the process documented here.

### UCR template
UCRs should be submitted as pull requests against the [UCR area of edgex-docs](https://github.com/edgexfoundry/edgex-docs/tree/main/docs_src/design/ucr).
Use the [UCR template](ucr/template.md) provided with this documentation to help create the UCR document.

### UCR Review and Approval Process
The community can submit UCR. The use cases describe the use case, target users, data, hardware, privacy and security considerations. Each use case should also include a list of functional requirements, the list of existing tools (that satisfy those requirements) and gaps. Use cases and requirements may freely overlap. Submissions get peer reviewed by domain experts and TSC. The TSC approves UCR and allows design work to be conducted based on the requirements. They can be updated to address shortcomings and technological advancements. Once a stable implementation is available addressing all the requirements, the record gets classified as "supported".

## Designs
Issues and new requirements lead to design decisions. Design decisions are also made on a regular, if not daily, basis. Some of these decisions are big and impactful to all parts of the system. Other decisions are less significant but still important for everyone to know and understand.

EdgeX has two places to record design decisions.

- Any and all design/architectural decisions regardless of size or impact shall be captured on the [EdgeX Foundry Design Decisions project board](https://github.com/orgs/edgexfoundry/projects/45).
- **Significant architectural decisions** should be documented in an [architectural design record](https://docs.edgexfoundry.org/2.0/design/adr/0018-Service-Registry/) (ADR). ADRs must be reviewed and approved per the process outlined in this documentation.

*Note: ADRs should also be documented on the project board with a link to the ADR in edgex-docs in the project board card.*

### When to use an ADR

"Significant architectural decisions" are deemed those that:

    Impact more than one EdgeX service and often impact the entire system (such as the definition of a data transfer object used through the system, of a feature that must be supported by all services).
    Require a lot of manpower (more than two people working over the course of a release or more) to implement the feature outlined in the ADR.
    Requires implementation to be accomplished over multiple releases (either due to the complexity of the feature or dependencies).

ADRs must be proceeded by one or more approved UCRs in order to be approved by the TSC - allowing for the design to be implemented in the EdgeX software.

### ADR template
ADRs should be submitted as pull requests against the [ADR area of edgex-docs](https://github.com/edgexfoundry/edgex-docs/tree/main/docs_src/design/adr).
Use the [ADR template](adr/template.md) provided with this documentation to help create the ADR document.


### ADR Review and Approval Process
Designs are created to address one or more requirements across one or more use cases. The design would include architecture details as well as references to pre-approved use cases and requirements. The TSC review the proposed design from a technical perspective. Approved designs get added to the EdgeX archive as "approved" records. They may get "deprecated" before implementation if another design supersedes it or if the requirements become obsolete over time. Designs may also get demoted if experimental implementations prove that they are not suitable (e.g. due to security, performance, dependency deprecation, feasibility). The design, implementation, verification cycles can repeat many times before resulting in a stable release.

## Project Board Cards and Issues

All project design/architectural design decisions captured on the Design Decisions project board will be created as either a:

    Issue: for any design decision that will require code and a PR will be submitted against the issue.
    Card: for any design decision that is not itself going to result in code or may need to be broken down into multiple issues (which can be referenced on the card).

The template for project board cards documenting each decision is:

    When/Where: date of the decision and place where the decision was made (such as TSC meeting, working group meeting, etc.). This section is required.
    Decision Summary: quick write-up on the decision. This section is required.
    Notes/Considerations: any alternatives discussed, any impacts to other decisions or considerations to be considered in the future (which would negate the decision). This section is optional.

    Relevant links: link to the meeting recording (if available). Link to ADR if relevant. Link to PRs or Issues if relevant. Required if available.

Note there is a Template column on the project board with a single card that specifies this same structure.

### Project Board Columns

The Design Decisions project board will be permanent and never archived or deleted. For each release, a new column named for that release will be created to hold the decisions (in the form of cards or issues) for that release.

The release columns may be "frozen" at the end of a release, but should never be deleted so that all design decisions can be retained for the life of the project.

### Ownership and Card/Issue Creation

The TSC chair, vice-chair and product manager will have overall responsibility for the Design Decision project board. These people will also be responsible for capturing any decisions from TSC meetings or the Monthly Architect’s Meeting as cards/issues on the board.

Work Group chairs are responsible for adding new design decision cards/issues that come for their work group or related meetings.
