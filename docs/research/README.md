# Research

Research documents inform decisions but do not make decisions by themselves.
Decisions are recorded only in decision records (ADR, GDR, LDR, BDR)
accepted by the Project Owner.

Every research report must clearly distinguish facts, hypotheses,
requirements, alternatives, recommendations, risks, and unresolved questions.

## Identifiers and location

- Each report has an ID `RES-NNNN`: zero-padded, sequential across the whole
  project, never reused (including withdrawn reports).
- File name: `RES-NNNN-<slug>.md`, where `<slug>` is short lowercase
  kebab-case.
- Location: all Foundation (Wave 0.x) reports live in
  [`wave-0/`](wave-0/); the specific wave is recorded in the report
  metadata. Directories for later phases are defined when those phases are
  planned.
- Every report starts from [`RESEARCH-TEMPLATE.md`](RESEARCH-TEMPLATE.md).
- The report lifecycle (`DRAFT`, `IN REVIEW`, `REVIEWED`, `SUPERSEDED`,
  `WITHDRAWN`) and the links to the Decision Register and decision records are defined
  in [`../project/DECISION-LIFECYCLE.md`](../project/DECISION-LIFECYCLE.md).

## Mandatory metadata

| Field | Rule |
|---|---|
| ID | `RES-NNNN` |
| Title | Short descriptive title |
| Status | One of the research lifecycle states |
| Wave | For example `0.1` |
| Related questions | One or more `Q-NNNN` |
| Author(s) | Humans and/or agents who wrote the report |
| Responsible human | The human accountable for the report |
| Agent assistance | `none`, or the agents used and their role |
| Reviewer(s) | Human reviewer(s); required before `REVIEWED` |
| Created | `YYYY-MM-DD` |
| Last updated | `YYYY-MM-DD` |
| Review date | `YYYY-MM-DD`, when reviewed |
| Confidence | `HIGH`, `MEDIUM` or `LOW` (see below) |
| Supersedes / Superseded by | `RES-NNNN` or `—` |

Every source listed in a report records its **access date** (`YYYY-MM-DD`)
and its source tier.

## Confidence levels

- **HIGH** — key claims are supported by Tier 1 sources or reproducible
  local evidence, and no material contradictions remain.
- **MEDIUM** — key claims are supported, but some rely on Tier 2–3 sources,
  are extrapolated, or have unresolved minor contradictions.
- **LOW** — key claims rely on limited, indirect or conflicting evidence.

Confidence may also be stated per claim or per alternative.

## Source quality and priority

Prefer the highest available tier.

| Tier | Source type |
|---|---|
| 1 — Primary / authoritative | Official project documentation, specifications, source code, official release notes and announcements, standards documents, official legal texts and guidelines. |
| 2 — Maintainer / scholarly | Public statements by the project's maintainers (mailing lists, issue trackers, talks), peer-reviewed publications. |
| 3 — Reputable secondary | Established technical press and independent analyses with identifiable authors. |
| 4 — Community | Blogs, forums, Q&A sites, community wikis. Corroboration only. |

Rules:

- every externally verifiable claim cites at least one source;
- a key claim must not rely only on Tier 4 sources;
- AI-generated text, unattributed claims and unverified marketing material
  are not acceptable evidence;
- record the version, release or date that a claim applies to;
- document contradictions between sources rather than silently choosing one;
- local experiments count as evidence only when the environment, exact
  steps and outputs are recorded;
- physical hardware claims require physical hardware evidence;
- research on legal topics informs the Project Owner and is not legal
  advice.
