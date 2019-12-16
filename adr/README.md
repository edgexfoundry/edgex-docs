# Architecture Decision Records Folder
This folder contains EdgeX Foundry architecture decision records (ADR).  At the root of the folder are decisions that are relevant to multiple parts of the project (aka – *cross cutting concerns*).  Sub folders contain decisions relevant to the specific area of the project and essentially set up along working group lines (security, core, application, etc.).
## Naming and Formatting
ADR documents are requested to follow [RFC]( https://tools.ietf.org/html/rfc2026) (request for comments) naming standard.  Specifically, authors should name their documents with a sequentially increasing integer (or serial number).  
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
A separate folder (legacy-design) is used for legacy design/architecture decisions.
A separate folder (legacy-requirements) is used for legacy requirements documents.
WG chairman take the responsibility for posting legacy material in to the applicable folders.
