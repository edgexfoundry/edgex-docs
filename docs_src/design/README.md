# Architecture Decision Records Folder
This folder contains EdgeX Foundry decision records (ADR) and legacy design / requirement documents.

    /design
        /adr (architecture decision Records)
        /legacy-design (legacy design documents)
        /legacy-requirements (legacy requirement documents)

At the root of the ADR folder (/design/adr) are decisions that are relevant to multiple parts of the project (aka � *cross cutting concerns*).  Sub folders under the ADR folder contain decisions relevant to the specific area of the project and essentially set up along working group lines (security, core, application, etc.).


## Naming and Formatting
ADR documents are requested to follow RFC (request for comments) naming standard.  Specifically, authors should name their documents with a sequentially increasing integer (or serial number) and then the architectural design topic:  (sequence number - topic).  Example:  0001-SeparateConfigurationInterface.  The sequence is a global sequence for all EdgeX ADR.  
Per RFC and Michael Nygard [suggestions](https://github.com/joelparkerhenderson/architecture_decision_record/blob/master/adr_template_by_michael_nygard.md) the makeup of the ADR document should generally include:

-	Title
-	Status (proposed, accepted, rejected, deprecated, superseded, etc.)
-	Context and Proposed Design
-	Decision
-	Consequences/considerations
-	References
-	Document history is maintained via Github history.

## Ownership
EdgeX WG chairman own the sub folder and included documents associated to their work group.  The EdgeX TSC chair/vice chair are responsible for the root level, cross cutting concern documents.

## Legacy
A separate folder (/design/legacy-design) is used for legacy design/architecture decisions.
A separate folder (/design/legacy-requirements) is used for legacy requirements documents.
WG chairman take the responsibility for posting legacy material in to the applicable folders.

## Table of Contents
A READMe with a table of contents is provide in the the /adr, /legacy-design, and /legacy-requirements sub folders.  Document authors are asked to keep the TOC updated with each new document entry.