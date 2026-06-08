# EdgeX Foundry STRIDE Threat Model

STRIDE is an acroymn standing for:

- Spoofing
- Tampering
- Repudiation
- Information disclosure (which means privacy breach or data leaks)
- Denial of service
- Elevation of privilege

STRIDE is a type of security threat modeling to identify security vulnerabilities and risks associated with IT systems and then put methods (mitigation) in place to protect against the vulnerabilities and risks.  Specifically, the STRIDE approach to threat modeling looks for common threats as represented in the acroymn in a consistent and methodical way.

## Report

- [STRIDE Threat Model Report](./EdgeX-V4-ThreatReport.md)
- [STRIDE Threat Model Report (in HTML)](./EdgeX-V4-ThreatReport.htm)

## Tooling

There are many tools to help create STRIDE threat models.  Many of these tools will allow the developer to visually diagram the system and then automatically analyze the diagram and generate STRIDE risks which the developer must then explore and mitigate.

This EdgeX STRIDE model was created using [Microsoft's Threat Modeling Tool (MTMT)](https://aka.ms/threatmodelingtool).  It is available for free.  Documentation on the product is available [here](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool).

If you wish to use the tool, make changes and/or generate your own reports you will need to import the following files into the Microsoft TMT:

- [Model file (tm7 format)](./EdgeXFoundryThreatModel_V4.tm7)
- [Template file (tb7 format)](./IoTDefault.tb7)
