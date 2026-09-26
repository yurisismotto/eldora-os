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
| Q-0001 | V1 base-system composition within the Fedora ecosystem | ARCHITECTURE | DECIDED | 0.1 | [RES-0001](../research/wave-0/RES-0001-fedora-base-system-composition-models.md) (REVIEWED); [RES-0002](../research/wave-0/RES-0002-base-distribution-challenge.md) (REVIEWED, context); [RES-0003](../research/wave-0/RES-0003-system-image-rootfs-package-ownership.md) (REVIEWED); [RES-0004](../research/wave-0/RES-0004-composition-validation-probes.md) (REVIEWED); [RES-0005](../research/wave-0/RES-0005-composition-final-validation.md) (REVIEWED) | [ADR-0001](ADR-0001-v1-base-composition-bootc-oci.md) (ACCEPTED 2026-09-26) | Decided by the Project Owner on 2026-09-26: M3 — Fedora-derived image-based system using bootc/OCI — SELECTED FOR V1; M1 fallback/contingency; M2/M2b reference. Lifecycle: IN RESEARCH → RECOMMENDED (RES-0005 REVIEWED) → PROPOSED (ADR-0001 PROPOSED) → DECIDED (ADR-0001 ACCEPTED). Conditions C1–C9 in ADR-0001. Wave 0.1B CLOSED. |
| Q-0002 | Desktop environment / compositor and Wayland foundation | ARCHITECTURE | OPEN QUESTION | 0.2 | — | — | Wayland is a direction to validate. No DE/compositor preselected. |
| Q-0003 | Application model, distribution and application updates | ARCHITECTURE | OPEN QUESTION | 0.3 | — | — | Application updates only; system updates are Q-0008. |
| Q-0004 | Validation of the working-hypothesis platform architecture | ARCHITECTURE | OPEN QUESTION | 0.4 | — | — | Validate or refute the layers before assuming them. |
| Q-0005 | Repository strategy (monorepo / multi-repo / hybrid) | ARCHITECTURE | OPEN QUESTION | 0.5 | — | — | Must be decided before significant implementation. |
| Q-0006 | Open-source license | LEGAL / LICENSING | OPEN QUESTION | 0.6 | — | — | No license selected. |
| Q-0007 | Contribution licensing (DCO / CLA / other) | LEGAL / LICENSING; GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Required before external contributions open. May need an LDR and a GDR. |
| Q-0008 | System/base-image update and rollback architecture | ARCHITECTURE | IN RESEARCH | 0.1 | [RES-0001](../research/wave-0/RES-0001-fedora-base-system-composition-models.md) (REVIEWED, survey level); [RES-0003](../research/wave-0/RES-0003-system-image-rootfs-package-ownership.md) (REVIEWED, structural consequences only); [RES-0004](../research/wave-0/RES-0004-composition-validation-probes.md) (REVIEWED, lab probes); [RES-0005](../research/wave-0/RES-0005-composition-final-validation.md) (REVIEWED, final validation); [RES-0006](../research/wave-0/RES-0006-update-state-machine-failure-semantics.md) (REVIEWED, Wave 0.1C-A); [RES-0007](../research/wave-0/RES-0007-update-policy-trust-freshness-semantics.md) (REVIEWED, Wave 0.1C-B) | — | Not decided. Constrained by ADR-0001 (M3 selected) and its conditions C1–C9; update/rollback/recovery decisions belong to Wave 0.1C. |
| Q-0009 | UI toolkit | ARCHITECTURE | OPEN QUESTION | 0.2 | — | — | SDK implications are considered in Waves 0.3–0.4. |
| Q-0010 | Brand and trademark clearance (name, tagline, symbol/visual identity) | BRAND / TRADEMARK | OPEN QUESTION | 0.6 | — | — | TRADEMARK CLEARANCE: PENDING. |
| Q-0011 | Definitive Code of Conduct | GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Current Code of Conduct is a placeholder. |
| Q-0012 | Security vulnerability disclosure process and reporting channel | GOVERNANCE | OPEN QUESTION | 0.6 | — | — | Reporting channel configuration is a Project Owner action. |
| Q-0013 | Review of OB-0004: V1 base distribution family (Fedora × Ubuntu × Debian) | ARCHITECTURE | DECIDED | 0.1X | [RES-0002](../research/wave-0/RES-0002-base-distribution-challenge.md) (REVIEWED); [RES-0001](../research/wave-0/RES-0001-fedora-base-system-composition-models.md) (REVIEWED) | [OB-0004](../project/OWNER-BASELINES.md) — confirmed for Eldora OS V1 by the Project Owner after review of RES-0001 and RES-0002 (D13). No ADR: resolved by an Owner Baseline per DECISION-LIFECYCLE (D17). | Evidence: [review record](../project/reviews/WAVE-0.1A-0.1X-REVIEW.md) and the Project Owner's next commit containing this entry. The confirmation fixes the base family only; composition remains open under Q-0001. |
