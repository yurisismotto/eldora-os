# Decision Register

The Decision Register is the central index of every question that requires
a Project Owner decision, of every type. Question types, resolution
artifacts, states, transitions and the `Q → RES → record` linking rules are
defined in
[`../project/DECISION-LIFECYCLE.md`](../project/DECISION-LIFECYCLE.md).

Resolution artifacts: ARCHITECTURE → ADR ([`README.md`](README.md));
GOVERNANCE → GDR, LEGAL / LICENSING → LDR, BRAND / TRADEMARK → BDR
([`../decisions/README.md`](../decisions/README.md)).

Founding premises that are not questions are recorded as
[Owner Baselines](../project/OWNER-BASELINES.md).

| ID | Topic | Type | Status | Wave | Research | Resolution | Notes |
|---|---|---|---|---|---|---|---|
| Q-0001 | V1 base-system composition within the Fedora ecosystem | ARCHITECTURE | OPEN QUESTION | 0.1 | — | — | Fedora-derived is OB-0004; the composition approach is open. |
| Q-0002 | Desktop environment / compositor and Wayland foundation | ARCHITECTURE | OPEN QUESTION | 0.2 | — | — | Wayland is a direction to validate. No DE/compositor preselected. |
| Q-0003 | Application model, distribution and application updates | ARCHITECTURE | OPEN QUESTION | 0.3 | — | — | Application updates only; system updates are Q-0008. |
| Q-0004 | Validation of the working-hypothesis platform architecture | ARCHITECTURE | OPEN QUESTION | 0.4 | — | — | Validate or refute the layers before assuming them. |
| Q-0005 | Repository strategy (monorepo / multi-repo / hybrid) | ARCHITECTURE | OPEN QUESTION | 0.5 | — | — | Must be decided before significant implementation. |
| Q-0006 | Open-source license | LEGAL / LICENSING | OPEN QUESTION | 0.6 | — | — | No license selected. |
| Q-0007 | Contribution licensing (DCO / CLA / other) | LEGAL / LICENSING; GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Required before external contributions open. May need an LDR and a GDR. |
| Q-0008 | System/base-image update and rollback architecture | ARCHITECTURE | OPEN QUESTION | 0.1 | — | — | Researched together with Q-0001. |
| Q-0009 | UI toolkit | ARCHITECTURE | OPEN QUESTION | 0.2 | — | — | SDK implications are considered in Waves 0.3–0.4. |
| Q-0010 | Brand and trademark clearance (name, tagline, symbol/visual identity) | BRAND / TRADEMARK | OPEN QUESTION | 0.6 | — | — | TRADEMARK CLEARANCE: PENDING. |
| Q-0011 | Definitive Code of Conduct | GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Current Code of Conduct is a placeholder. |
| Q-0012 | Security vulnerability disclosure process and reporting channel | GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Reporting channel configuration is a Project Owner action. |
