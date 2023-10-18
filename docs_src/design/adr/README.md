# Architecture Decision Records Folder
This folder contains the EdgeX Foundry architectural decision records (ADR).

At the root of this folder are decisions that are relevant to multiple parts of the project (aka. *cross cutting concerns*).  Sub folders under the ADR folder contain decisions relevant to the specific area of the project and essentially set up along working group lines (security, core, application, etc.).

## Naming and Formatting
ADR documents should follow the RFC (request for comments) naming standard.  Specifically, approved ADRs should have a sequentially increasing integer (or serial number) and then the architectural design topic as file names (sequence_number-My-Topic.md). Example: 0001-Separate-Configuration-Interface. The sequence is a global sequence for all EdgeX ADR.  
Per RFC and Michael Nygard [suggestions](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locales/en/templates/decision-record-template-by-michael-nygard/index.md) the makeup of the ADR document should generally include:

-	Title
-	Status (proposed, accepted, rejected, deprecated, superseded, etc.)
-	Context and Proposed Design
-	Decision
-	Consequences/considerations
-	References
-	Document history is maintained via Github history.

EdgeX ADRs should use the [template.md](template) file available in this directory.

## Ownership
EdgeX WG chairman own the sub folder and included documents associated to their work group.  The EdgeX TSC chair/vice chair are responsible for the root level, cross cutting concern documents.

## Table of Contents
A README with a table of contents for current documents is located [here](../TOC.md). Document authors are asked to keep the TOC updated with each new document entry.

Legacy designs have their own Table of Contents and are located [here](../legacy-design).