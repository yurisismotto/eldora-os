# Eldora OS Current State

Last updated: 2026-09-26

This document holds the mutable state of the project. Rules for agents live
in [`AGENTS.md`](../../AGENTS.md); they do not duplicate this state.

## Phase

- **Phase:** Foundation (Wave 0)
- **Wave 0.0 — Project Governance & Research Foundation:** CLOSED
  (closed by the Project Owner on 2026-09-26)
- **Current stage:** Wave 0.1 — Fedora-derived Base System Composition:
  IN PROGRESS.
  - 0.1A — Fedora Ecosystem & Base-System Composition Models: CLOSED;
    [RES-0001](../research/wave-0/RES-0001-fedora-base-system-composition-models.md)
    REVIEWED. No composition model selected.
  - 0.1X — Base Distribution Challenge (extraordinary): CLOSED;
    [RES-0002](../research/wave-0/RES-0002-base-distribution-challenge.md)
    REVIEWED. OB-0004 confirmed for V1 by the Project Owner (D13).
  - 0.1B — System Image / Root Filesystem / Package Ownership: CLOSED
    (with sub-stages 0.1B-P and 0.1B-F, all CLOSED by the Project Owner on
    2026-09-26); RES-0003, RES-0004 and RES-0005 REVIEWED. Outcome:
    [ADR-0001](../adr/ADR-0001-v1-base-composition-bootc-oci.md) ACCEPTED.
    Review, working principles P1–P6 and decision:
    [`reviews/WAVE-0.1B-REVIEW.md`](reviews/WAVE-0.1B-REVIEW.md).
  - **Next:** 0.1C — Update / Rollback / Recovery: authorized for
    preparation; **not started**. 0.1D: not started.
  - Review and decisions D13–D16:
    [`reviews/WAVE-0.1A-0.1X-REVIEW.md`](reviews/WAVE-0.1A-0.1X-REVIEW.md).
- **Wave details:** see [`FOUNDATION-ROADMAP.md`](FOUNDATION-ROADMAP.md)

No production operating-system implementation exists.

## Owner Baselines

Founding premises established by the Project Owner are recorded in
[`OWNER-BASELINES.md`](OWNER-BASELINES.md):

- OB-0001 — initial kernel: Linux;
- OB-0002 — provisional name: Eldora OS (clearance pending);
- OB-0003 — provisional tagline: Simple. Powerful. Yours. (clearance pending);
- OB-0004 — Eldora OS V1 is Fedora-derived (V1 scope); confirmed by the
  Project Owner on 2026-09-26 (D13). This fixes the base family for V1
  only; it selects no composition, update, installer, desktop, toolkit or
  application-model technology. Interpretation (D20): Fedora is the
  principal upstream family; CentOS Stream/EPEL are not the base and are
  not selected.

## Accepted architecture decisions

- **Base composition:** M3 — Fedora-derived image-based system using
  bootc/OCI — **SELECTED FOR V1**
  ([ADR-0001](../adr/ADR-0001-v1-base-composition-bootc-oci.md), accepted by
  the Project Owner on 2026-09-26; resolves Q-0001). M1 (package-based) is
  the documented fallback/contingency; M2/M2b are technical references.
  Conditions C1–C9 apply; RISK-0010 is a release blocker for M3.
- Fedora-derived V1 (OB-0004): CONFIRMED.

## Not selected

Each item is an open question in the
[Decision Register](../adr/DECISION-REGISTER.md):

| Topic | Question | Wave |
|---|---|---|
| System/base-image update and rollback architecture (constrained by ADR-0001; to be researched in Wave 0.1C) | Q-0008 | 0.1 |
| Desktop environment / compositor (Wayland is a direction to validate) | Q-0002 | 0.2 |
| UI toolkit | Q-0009 | 0.2 |
| Application model, distribution and application updates | Q-0003 | 0.3 |
| Platform architecture (working hypothesis below) | Q-0004 | 0.4 |
| Repository strategy | Q-0005 | 0.5 |
| License | Q-0006 | 0.6 |
| Contribution licensing (DCO/CLA/other) | Q-0007 | 0.6 |
| Brand/trademark clearance | Q-0010 | 0.6 |
| Definitive Code of Conduct | Q-0011 | 0.6 |
| Security vulnerability disclosure process | Q-0012 | 0.6 |

## Tracked risks

Full register and convention: [`RISK-REGISTER.md`](RISK-REGISTER.md).
Active risks (all `OPEN`):

- RISK-0001 — Fedora cadence / no LTS rebase cost (probe PX1).
- RISK-0002 — NVIDIA + Secure Boot validation (probe PX3).
- RISK-0003 — desktop maturity of the image-based/bootc direction.
- RISK-0004 — avoiding unnecessary coupling to the base.
- RISK-0005 — configuration and user/group drift in image-based models (probe PB3).
- RISK-0006 — no supported persistent host extension in bootc (probe PB2).
- RISK-0007 — permissive default trust in the image update chain (probe PB5).
- RISK-0008 — no freshness/anti-rollback guarantee in the OCI update chain.
- RISK-0009 — insufficiently verified build inputs in signed images.
- RISK-0010 — silent loss of staged updates on UEFI (`/boot` automount); **release blocker for M3**.
- RISK-0011 — OS rollback does not roll back the boot chain.

## Proposed probes

Defined in RES-0002. **None has been executed.** Classification by the
Project Owner (D15, 2026-09-26):

| Probe | Subject | Classification | Condition |
|---|---|---|---|
| PX1 | Release-rebase cost | HIGH PRIORITY / FUTURE GATE | Execute before freezing irreversible composition, update or release-lifecycle decisions, once enough material exists for a representative test. |
| PX3 | NVIDIA + Secure Boot | HIGH PRIORITY / HARDWARE GATE | Execute before declaring the corresponding hardware support/certification. |
| PX6 | CVE fix latency | MEDIUM PRIORITY / DOCUMENTARY VALIDATION | May be executed during Foundation when needed for security/update policy decisions. |
| PX2, PX4, PX5, PX7, PX8, PX9 | See RES-0002 | PROPOSED | — |

## Architectural references for future investigation

- GNOME OS / freedesktop-sdk (ALTERNATIVE DISCOVERED in RES-0002): recorded
  as a reference only (D16). Not a V1 candidate; does not reopen OB-0004;
  no research started; does not expand Wave 0.1.

## Working hypothesis: conceptual architecture

The following stack is a **working hypothesis**, not an accepted design. It
is validated or refuted in Wave 0.4 (Q-0004). Any layer may be removed,
merged or replaced.

```text
Applications
→ Eldora SDK
→ Platform APIs / Capability APIs
→ System Broker
→ Eldora System Services
→ Linux Adapter Layer
→ Linux userspace
→ Linux Kernel
→ Hardware
```

## Brand and legal status

- **TRADEMARK CLEARANCE: PENDING** — name, tagline and symbol/visual
  identity are provisional. See
  [`../product/vision/BRAND-STATUS.md`](../product/vision/BRAND-STATUS.md).
- **License:** none selected. No `LICENSE` file exists. Eldora OS is intended
  to be an open-source project. Licensing is pending.
- **External contributions:** not open.
- **Security reporting:** no private reporting channel exists yet. See
  [`../../SECURITY.md`](../../SECURITY.md).

## AI

Fundamental Eldora OS functionality must not require AI services.
