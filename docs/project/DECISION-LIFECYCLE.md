# Decision Lifecycle

This document defines identifiers, question types, resolution artifacts,
links and lifecycles for the Decision Register, Research reports, decision
records (ADR, GDR, LDR, BDR) and SPECs. Decision authority is defined in
[`GOVERNANCE.md`](GOVERNANCE.md).

## Identifiers and locations

| Artifact | ID format | Location |
|---|---|---|
| Owner Baseline | `OB-NNNN` | [`OWNER-BASELINES.md`](OWNER-BASELINES.md) |
| Question | `Q-NNNN` | [`../adr/DECISION-REGISTER.md`](../adr/DECISION-REGISTER.md) |
| Research report | `RES-NNNN` | `docs/research/<phase-dir>/RES-NNNN-<slug>.md` (see [`../research/README.md`](../research/README.md)) |
| Architecture Decision Record | `ADR-NNNN` | `docs/adr/ADR-NNNN-<slug>.md` |
| Governance Decision Record | `GDR-NNNN` | `docs/decisions/GDR-NNNN-<slug>.md` |
| Project/Legal Decision Record | `LDR-NNNN` | `docs/decisions/LDR-NNNN-<slug>.md` |
| Brand Decision/Status Record | `BDR-NNNN` | `docs/decisions/BDR-NNNN-<slug>.md` |
| SPEC | `SPEC-NNNN` | `docs/specs/SPEC-NNNN-<slug>.md` |

`NNNN` is a zero-padded, sequential number per artifact type. Numbers are
never reused, including for withdrawn or rejected artifacts. `<slug>` is a
short lowercase kebab-case description.

## Question types and resolution artifacts

The Decision Register is the central index of relevant questions. Each
question has one or more types, and each type has its own resolution
artifact:

| Type | Resolution artifact | Template |
|---|---|---|
| ARCHITECTURE | ADR (normally) | [`../adr/ADR-TEMPLATE.md`](../adr/ADR-TEMPLATE.md) |
| GOVERNANCE | Governance Decision Record (GDR) | [`../decisions/DECISION-RECORD-TEMPLATE.md`](../decisions/DECISION-RECORD-TEMPLATE.md) |
| LEGAL / LICENSING | Project/Legal Decision Record (LDR) | [`../decisions/DECISION-RECORD-TEMPLATE.md`](../decisions/DECISION-RECORD-TEMPLATE.md) |
| BRAND / TRADEMARK | Brand Decision/Status Record (BDR) | [`../decisions/DECISION-RECORD-TEMPLATE.md`](../decisions/DECISION-RECORD-TEMPLATE.md) |

ADRs are reserved for architectural decisions. A non-architectural decision
must not be turned into an ADR merely to close a question. A question that
crosses categories may reference more than one resolution artifact; it is
`DECIDED` only when every required record is `ACCEPTED`.

## Links

The chain is `Q-xxxx → RES-xxxx → resolution record` (ADR, GDR, LDR or BDR),
with SPECs downstream of ADRs:

- every question in the Decision Register lists its type(s), research
  reports and resolution records;
- every research report lists the questions it addresses
  (`Related questions`);
- every resolution record lists the questions it resolves and the research
  it relies on;
- every SPEC lists the ADRs and questions it depends on;
- a question may have several research reports; a record may cite several
  research reports.

Links must be kept bidirectional: when an artifact is added, the artifacts
it references are updated in the same change.

## Decision Register (questions)

| State | Meaning |
|---|---|
| `OPEN QUESTION` | Question identified; no research started. |
| `IN RESEARCH` | At least one research report is in progress. |
| `RESEARCHED` | Research is REVIEWED; no recommendation yet. |
| `RECOMMENDED` | A reviewed research report contains a recommendation. |
| `PROPOSED` | A resolution record in state PROPOSED exists for the question. |
| `DECIDED` | Every required resolution record is ACCEPTED. |
| `WITHDRAWN` | The question is no longer relevant (terminal). |
| `REOPENED` | A decided or proposed question must be revisited. |

Valid transitions:

| From | To | Who |
|---|---|---|
| OPEN QUESTION | IN RESEARCH | anyone |
| IN RESEARCH | RESEARCHED, RECOMMENDED | anyone, once the research is REVIEWED |
| RESEARCHED | RECOMMENDED, IN RESEARCH | anyone |
| RECOMMENDED | PROPOSED | anyone (by creating a resolution record in PROPOSED) |
| RECOMMENDED | IN RESEARCH | anyone |
| PROPOSED | DECIDED | Project Owner (by accepting the required records) |
| PROPOSED | REOPENED | Project Owner (record rejected or withdrawn) |
| DECIDED | REOPENED | Project Owner |
| REOPENED | IN RESEARCH, PROPOSED | anyone, after reopening |
| any non-terminal state | WITHDRAWN | Project Owner |

A recommendation never moves a question to `DECIDED`.

## Research reports

| State | Meaning |
|---|---|
| `DRAFT` | Being written. |
| `IN REVIEW` | Submitted to a human reviewer. |
| `REVIEWED` | A human reviewer confirmed it meets the research policy. Not a decision. |
| `SUPERSEDED` | Replaced by a newer research report (terminal). |
| `WITHDRAWN` | Abandoned or invalid (terminal). |

Valid transitions: `DRAFT → IN REVIEW`; `IN REVIEW → DRAFT` (changes
requested) or `REVIEWED`; `REVIEWED → SUPERSEDED`; `DRAFT`, `IN REVIEW` or
`REVIEWED → WITHDRAWN`.

A REVIEWED report is not reopened. Material changes produce a new report
that supersedes it, so that the evidence cited by decision records stays
stable.

## Decision records (ADR, GDR, LDR, BDR)

All decision record types share one lifecycle.

| State | Meaning |
|---|---|
| `PROPOSED` | Awaiting Project Owner decision; may be revised. |
| `ACCEPTED` | Approved by the Project Owner. |
| `REJECTED` | Declined by the Project Owner (terminal). |
| `WITHDRAWN` | Retracted before a decision (terminal). |
| `SUPERSEDED` | Replaced by a later ACCEPTED record of the same type (terminal). |

Valid transitions:

| From | To | Who |
|---|---|---|
| PROPOSED | ACCEPTED | Project Owner only; `Approved by`, `Approval date` and `Approval evidence` must be filled |
| PROPOSED | REJECTED | Project Owner |
| PROPOSED | WITHDRAWN | author or Project Owner |
| ACCEPTED | SUPERSEDED | Project Owner, only when a new record superseding it is ACCEPTED |

Decision records are not reopened. Revisiting a decision happens by
reopening the question in the Decision Register and writing a new record.

## SPECs

| State | Meaning |
|---|---|
| `DRAFT` | Being written. |
| `IN REVIEW` | Under human review. |
| `APPROVED` | Approved by the Project Owner as the basis for implementation. |
| `REOPENED` | An approved SPEC is being revised. |
| `SUPERSEDED` | Replaced by a newer SPEC (terminal). |
| `WITHDRAWN` | Abandoned (terminal). |

Valid transitions: `DRAFT → IN REVIEW`; `IN REVIEW → DRAFT` or `APPROVED`
(Project Owner only); `APPROVED → REOPENED` (Project Owner) or `SUPERSEDED`;
`REOPENED → IN REVIEW`; any non-terminal state `→ WITHDRAWN`.

Participants and agents may create, review and recommend SPECs, but only the
Project Owner may approve them during the current phase.

A SPEC must not introduce an architectural decision that requires an ADR.
If it would, the SPEC stays in review until the ADR is ACCEPTED.
