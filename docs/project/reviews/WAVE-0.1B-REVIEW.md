# Wave 0.1B — Project Owner Review Record

| Field | Value |
|---|---|
| Reviewed stage | Wave 0.1B — System Image / Root Filesystem / Package Ownership |
| Reviewed report | [RES-0003](../../research/wave-0/RES-0003-system-image-rootfs-package-ownership.md) |
| Reviewer | Project Owner (human review) |
| Review date | 2026-09-26 |
| Recorded by | Agent (Claude Code), on explicit Project Owner instruction given to an agent session on 2026-09-26 |
| Approval evidence | The first commit made by the Project Owner that contains this file |

## Research report review

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| RES-0003 | DRAFT → IN REVIEW → REVIEWED (submitted to and reviewed by the Project Owner on 2026-09-26) | REVIEWED | Accepted as research evidence |

The review outcome does not decide the composition model (Q-0001) or the
update/rollback model (Q-0008).

## Project Owner review outcome

- **Q19 = MORE EVIDENCE REQUIRED** is accepted.
- **M3 (bootc/OCI)** remains the LEADING CANDIDATE, not SELECTED.
- **M1 (package-based)** remains the REQUIRED FALLBACK/CANDIDATE.
- **M2 (rpm-ostree/OSTree)** remains a technical reference.
- **M2b (rpm-ostree client over OCI)** must not be discarded prematurely and
  must not be promoted automatically to an equivalent candidate.
- **Composition model:** NOT DECIDED.
- A controlled experimental sub-stage, **Wave 0.1B-P — Composition
  Validation Probes**, is to be executed before any composition decision.

## Working principles for investigation (Foundation)

These are working architectural principles for the Foundation phase. They
are not a choice of composition model, not an ADR, and may be revised if
probe evidence contradicts them.

- **P1.** System/vendor defaults should preferably reside in `/usr`; local
  configuration is treated as an override.
- **P2.** Prefer drop-ins and compositional mechanisms to replacing complete
  configuration files.
- **P3.** Prefer appropriate declarative mechanisms, including
  sysusers/tmpfiles where applicable, to arbitrary scripts that mutate host
  state.
- **P4.** Eldora components that are part of the system should preferably be
  delivered as versioned, signed artifacts, including RPMs where that is the
  appropriate mechanism.
- **P5.** A downstream fork is not the default. Prefer upstream
  contribution; patches and forks require justification.
- **P6.** Separate conceptually: SYSTEM CONTENT, MACHINE STATE, USER STATE,
  APPLICATION STATE.

## Risks accepted from RES-0003

The Project Owner accepted the three candidate risks identified in RES-0003
(RC-A, RC-B, RC-C). They are recorded as RISK-0005, RISK-0006 and RISK-0007
in [`RISK-REGISTER.md`](../RISK-REGISTER.md). No existing risk is closed.

## Review of RES-0004 (Wave 0.1B-P)

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| [RES-0004](../../research/wave-0/RES-0004-composition-validation-probes.md) | DRAFT → IN REVIEW → REVIEWED (Project Owner, 2026-09-26) | REVIEWED | Accepted as experimental evidence |

- Q19 remains **MORE EVIDENCE REQUIRED** (confidence MEDIUM).
- M3 remains LEADING CANDIDATE; M1 remains REQUIRED FALLBACK/CANDIDATE; M2
  remains TECHNICAL REFERENCE; composition model NOT DECIDED. The review
  does not select M3.
- The two candidate risks RC-D and RC-E from RES-0004 are accepted and
  recorded as RISK-0008 and RISK-0009.
- A final controlled experimental sub-stage, **Wave 0.1B-F — Composition
  Final Validation**, is to address evidence gaps E1–E5 identified by
  RES-0004.

## Review of RES-0005 (Wave 0.1B-F) and Project Owner decision

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| [RES-0005](../../research/wave-0/RES-0005-composition-final-validation.md) | DRAFT → IN REVIEW → REVIEWED (Project Owner, 2026-09-26) | REVIEWED | Accepted as final Wave 0.1B research evidence |

- The Project Owner considered the Wave 0.1B research (RES-0003, RES-0004,
  RES-0005; PB1–PB5; E1–E5) sufficient for a human decision.
- **Decision:** for Eldora OS V1, M3 — Fedora-derived image-based system
  using bootc/OCI — is **SELECTED FOR V1**; M1 is the documented
  fallback/contingency (not rejected); M2/M2b are technical references only.
  Recorded in [ADR-0001](../../adr/ADR-0001-v1-base-composition-bootc-oci.md)
  (ACCEPTED 2026-09-26) with conditions C1–C9. The decision applies to V1
  and may be revisited through the formal architectural process.
- Q-0001 → DECIDED (via ADR-0001). Q-0008 remains not decided (Wave 0.1C).
- New risks RISK-0010 (RC-F, **release blocker for M3**) and RISK-0011
  (RC-G) recorded; no risk closed.
- Wave 0.1B-P, Wave 0.1B-F and Wave 0.1B closed by the Project Owner on
  2026-09-26. Closure evidence: the Project Owner's next commit containing
  this record and the corresponding artefacts. Wave 0.1C is authorized for
  preparation and not started.

