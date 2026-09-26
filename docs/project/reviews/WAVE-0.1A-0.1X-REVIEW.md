# Wave 0.1A and 0.1X — Project Owner Review Record

| Field | Value |
|---|---|
| Reviewed stages | Wave 0.1A — Fedora Ecosystem & Base-System Composition Models; Wave 0.1X — Base Distribution Challenge (extraordinary) |
| Reviewed reports | [RES-0001](../../research/wave-0/RES-0001-fedora-base-system-composition-models.md), [RES-0002](../../research/wave-0/RES-0002-base-distribution-challenge.md) |
| Reviewer | Project Owner (human review) |
| Review date | 2026-09-26 |
| Recorded by | Agent (Claude Code), on explicit Project Owner instructions (decisions D13–D20) given to agent sessions on 2026-09-26 |
| Approval evidence | The first commit made by the Project Owner that contains this file |

This record exists so that the Project Owner's review and decisions do not
live only in chat history. Decision numbering continues the sequence used in
[`WAVE-0.0-AUDIT.md`](WAVE-0.0-AUDIT.md) (D1–D12).

## Research report review

| Report | Transition | Result |
|---|---|---|
| RES-0001 | DRAFT → IN REVIEW → REVIEWED (submitted to and reviewed by the Project Owner on 2026-09-26) | REVIEWED |
| RES-0002 | DRAFT → IN REVIEW → REVIEWED (submitted to and reviewed by the Project Owner on 2026-09-26) | REVIEWED |

REVIEWED reports are not reopened; material changes require a new report
that supersedes them ([`DECISION-LIFECYCLE.md`](../DECISION-LIFECYCLE.md)).

## Project Owner decisions

- **D13 — OB-0004 confirmed.** After human review of RES-0001 and RES-0002,
  the Project Owner confirms OB-0004: Eldora OS V1 is Fedora-derived. The
  RES-0002 recommendation (CONFIRM, provisional) is accepted. "Fedora-derived"
  designates the base family/ecosystem for V1 only. It does **not** select
  or imply any of: package-based composition, rpm-ostree, OSTree, bootc, OCI
  system images, filesystem layout, update mechanism, installer, compositor,
  desktop environment, toolkit, or package/application model. These remain
  open questions.
- **D14 — Fedora base risks to track during the Foundation phase:**
  R-FEDORA-01 to R-FEDORA-04, since migrated to RISK-0001 to RISK-0004 in
  [`RISK-REGISTER.md`](../RISK-REGISTER.md) (D18).
- **D15 — Probe classification** (none executed): PX1 HIGH PRIORITY /
  FUTURE GATE; PX3 HIGH PRIORITY / HARDWARE GATE; PX6 MEDIUM PRIORITY /
  DOCUMENTARY VALIDATION; PX2, PX4, PX5, PX7, PX8, PX9 PROPOSED. Recorded in
  [`CURRENT-STATE.md`](../CURRENT-STATE.md#proposed-probes).
- **D16 — GNOME OS / freedesktop-sdk** (ALTERNATIVE DISCOVERED in RES-0002)
  remains recorded as an architectural reference for future investigation
  only. It is not a fourth V1 candidate, does not reopen OB-0004, starts no
  new research, and does not expand the scope of Wave 0.1.

## Outcome of Wave 0.1A (research stage)

Wave 0.1A is complete as a research stage. Its completion does not select a
composition model. The reviewed investigation outcome of RES-0001 is:

| Model | Status after review |
|---|---|
| M3 — bootc / OCI image | CANDIDATE — principal candidate for detailed investigation (not SELECTED) |
| M1 — package-based | CANDIDATE — mandatory fallback/candidate (not discarded) |
| M2 — OSTree / rpm-ostree | Not a preferred target for a new architecture; remains relevant technical evidence and reference |

DECISION on composition (Q-0001) and on update/rollback (Q-0008): NOT TAKEN.

## Outcome of Wave 0.1X (extraordinary)

Wave 0.1X is complete. It was an extraordinary investigation triggered by
the review of an Owner Baseline and does not create a new numbering
convention. The administrative block on Wave 0.1B that existed only
pending human review of 0.1X is removed: Wave 0.1B is authorized for
preparation and has not started.

## Q-0013 resolution

Q-0013 (review of OB-0004) was first left at `RECOMMENDED` because the
Decision Register lifecycle had no transition for a question resolved by an
Owner Baseline. The Project Owner closed that gap with D17 (below). Q-0013
is now `DECIDED`; its resolution is OB-0004, confirmed for Eldora OS V1 by
the Project Owner after review of RES-0001 and RES-0002 (D13). No ADR or
other decision record was created, and none is required.

## Administrative normalization (D17–D20)

- **D17 — Questions resolved by an Owner Baseline.** A question may reach
  `DECIDED` when its formal resolution is an Owner Baseline explicitly
  created, confirmed, changed, superseded or retired by the Project Owner,
  provided the evidence is recorded, the Decision Register points to the
  Owner Baseline, and the question is not used to bypass an ADR required
  for a new architectural decision. Recorded in
  [`DECISION-LIFECYCLE.md`](../DECISION-LIFECYCLE.md#questions-resolved-by-an-owner-baseline)
  and applied to Q-0013.
- **D18 — Minimal risk tracking.** Convention `RISK-NNNN` with statuses
  `OPEN`, `MITIGATING`, `ACCEPTED`, `CLOSED`, recorded in
  [`RISK-REGISTER.md`](../RISK-REGISTER.md); R-FEDORA-01 to R-FEDORA-04
  migrated to RISK-0001 to RISK-0004 with meaning preserved.
  `CURRENT-STATE.md` keeps only a summary and link.
- **D19 — Responsible human** of RES-0001 and RES-0002: "Project Owner".
- **D20 — Meaning of "Fedora-derived".** Fedora is the principal upstream
  family/ecosystem of the Eldora OS V1 base; CentOS Stream and EPEL are not
  the base and are not selected; related projects may be used only when a
  later decision justifies it; a different principal base family requires
  explicit review of OB-0004. Recorded in
  [`OWNER-BASELINES.md`](../OWNER-BASELINES.md#ob-0004-interpretation-2026-09-26).

## Follow-up items

The follow-up items raised in the first version of this record (Q-0013
lifecycle gap, risk-tracking convention, "Responsible human" fields, and
whether OB-0004 includes CentOS Stream/EPEL) are resolved by D17–D20.
