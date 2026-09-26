# Eldora OS V1 Foundation Roadmap

Phase: Foundation (Wave 0)

Each wave has explicit, verifiable exit criteria. A wave closes only when
all of its exit criteria are met and the Project Owner records the closure.

Wave statuses: `PLANNED`, `IN PROGRESS`, `READY FOR OWNER REVIEW`,
`READY FOR OWNER CLOSURE`, `CLOSED`.

- `READY FOR OWNER CLOSURE` — every exit criterion except the Project
  Owner's closure is verified.
- `CLOSED` — set only by the Project Owner, who fills `Closed by` and
  `Closure date` for the wave and commits the change. The Project Owner's
  commit that sets the status to `CLOSED` is the closure evidence.

Research-only waves produce research, recommendations and, optionally,
PROPOSED ADRs. No product implementation should begin merely because a
research wave has produced a recommendation.

Common exit criteria for research waves (0.1–0.4 and 0.6):

- C1. Every research report for the wave follows
  [`../research/README.md`](../research/README.md) and is `REVIEWED`.
- C2. Every externally verifiable claim cites a source with an access date.
- C3. Every meaningful alternative within scope is compared, or its
  exclusion is justified.
- C4. The wave's questions in the Decision Register are at `RECOMMENDED` or
  later, with links to their research reports.
- C5. The Project Owner has recorded a disposition for each recommendation:
  resolution record (ADR, GDR, LDR or BDR, as the question type requires)
  PROPOSED or ACCEPTED, rejected, or explicitly deferred.
- C6. Open questions discovered during the wave are added to the Decision
  Register and assigned to a wave.

## Wave 0.0 — Project Governance & Research Foundation

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.

Scope: repository governance, agent rules, research discipline, templates,
decision lifecycle, Owner Baselines and the Decision Register.

Exit criteria:

- E0.1. `AGENTS.md`, `CLAUDE.md`, `README.md`, `CONTRIBUTING.md`,
  `SECURITY.md`, `CODE_OF_CONDUCT.md` and the documents under `docs/project/`
  exist and are mutually consistent.
- E0.2. Research, ADR, non-architectural decision record (GDR/LDR/BDR) and
  SPEC templates exist with the metadata required by
  [`DECISION-LIFECYCLE.md`](DECISION-LIFECYCLE.md).
- E0.3. Every question in the Decision Register has a type and is assigned
  to a wave.
- E0.4. All findings of the Wave 0.0 audit are resolved or explicitly
  accepted as remaining by the Project Owner
  ([`reviews/WAVE-0.0-AUDIT.md`](reviews/WAVE-0.0-AUDIT.md)).
- E0.5. All internal repository references resolve, and `git diff --check`
  reports no problems.
- E0.6. No `LICENSE` or `COPYING` file exists and no decision record (ADR,
  GDR, LDR, BDR) is `ACCEPTED`.
- E0.7. The Project Owner has reviewed the Foundation and closed Wave 0.0:
  the Project Owner commits the Wave 0.0 files and, in that commit or a
  later one, sets this wave's status to `CLOSED` with `Closed by` and
  `Closure date` filled in.

## Wave 0.1 — Fedora-derived Base System Composition

Status: PLANNED (authorized for preparation; not started)
Questions: Q-0001, Q-0008
Baseline: OB-0004 (Eldora OS V1 is Fedora-derived)

Research question: within the Fedora ecosystem, which base-system
composition approach best meets Eldora OS V1 requirements, and how do
system/base-image updates and rollback relate to that composition?

Scope:

- identify the composition alternatives available within the Fedora
  ecosystem (candidates are identified during the research, not in this
  roadmap, and none is assumed in advance);
- derive the V1 requirements that the composition must satisfy;
- how an Eldora derivative relates to upstream Fedora (derivation
  mechanics, release cadence, rebasing, maintenance burden);
- system/base-image update and rollback models and their relationship to
  each composition alternative (Q-0008);
- composition and build tooling implications;
- security baseline implications of each alternative;
- requirements that Fedora imposes on derivatives (for example trademark
  and branding guidelines), as research input only.

Out of scope:

- comparing Fedora against non-Fedora bases (for example Ubuntu, Debian,
  Arch);
- constraints on Eldora OS versions after V1;
- desktop environment, compositor and toolkit (Wave 0.2);
- application distribution and application updates (Wave 0.3);
- Eldora platform layers (Wave 0.4);
- implementation, and accepting ADRs on anyone's behalf.

Deliverables:

- one or more research reports `RES-NNNN` in `docs/research/wave-0/`,
  linked to Q-0001 and/or Q-0008;
- a recommendation (not a decision) for each question;
- updated Decision Register entries;
- optionally, ADRs in state PROPOSED.

Exit criteria: C1–C6.

## Wave 0.2 — Desktop / Wayland Foundation

Status: PLANNED
Questions: Q-0002, Q-0009

Research question: which desktop environment, compositor, Wayland
foundation and UI toolkit alternatives best meet the Eldora V1 desktop
experience requirements?

Scope: desktop environment and compositor alternatives, Wayland foundation
validation, UI toolkit alternatives, their compatibility with the Wave 0.1
recommendation, and fit with the V1 vision.

Out of scope: application distribution (Wave 0.3), platform layers
(Wave 0.4), implementation.

No desktop environment or compositor is preselected.

Deliverables: research reports linked to Q-0002 and Q-0009;
recommendations; updated register entries.

Exit criteria: C1–C6.

## Wave 0.3 — Application & Distribution Model

Status: PLANNED
Questions: Q-0003

Research question: how are applications identified, packaged, installed,
sandboxed, distributed, updated and removed on Eldora OS V1?

Scope: application identity, packaging, installation and removal,
sandboxing, distribution, application updates, and the Software/Apps
experience.

Out of scope: system/base-image updates (Wave 0.1), implementation.

Deliverables: research reports linked to Q-0003; recommendation; updated
register entry.

Exit criteria: C1–C6.

## Wave 0.4 — Platform Architecture Validation

Status: PLANNED
Questions: Q-0004

Research question: does Eldora OS V1 require the working-hypothesis layers
(Platform/Capability APIs, System Broker, Eldora System Services, Linux
Adapter Layer)? If a layer is retained, what is the minimum real subset
required for V1?

Scope: validate or refute each hypothesis layer against V1 requirements,
including the alternative that a layer is unnecessary, merged or replaced;
define minimum boundaries only for retained layers.

Out of scope: implementation.

Deliverables: research reports linked to Q-0004; recommendation; updated
register entry.

Exit criteria: C1–C6, plus: each hypothesis layer is explicitly marked as
retained, merged, replaced or rejected in the recommendation.

## Wave 0.5 — V1 Architecture Baseline

Status: PLANNED
Questions: Q-0005

Consolidate accepted ADRs into the V1 implementation baseline and decide
the repository strategy.

Exit criteria:

- every architectural question for V1 in the Decision Register is `DECIDED`
  or explicitly deferred by the Project Owner;
- `docs/architecture/` describes the V1 baseline derived only from ACCEPTED
  ADRs;
- Q-0005 is `DECIDED`;
- the Project Owner has recorded the closure of the wave.

## Wave 0.6 — Open Project Readiness

Status: PLANNED
Questions: Q-0006, Q-0007, Q-0010, Q-0011, Q-0012

License, contribution licensing (DCO/CLA/other), brand and trademark
clearance, the definitive Code of Conduct, and the security disclosure
process.

This wave may progress in parallel with Waves 0.1–0.5 where there is no
logical dependency. Its mandatory exit criteria must be met before:

- external contributions are officially opened;
- the project is declared legally open source;
- a public release that depends on these policies is made.

Research in this wave informs the Project Owner and is not legal advice.

Exit criteria: C1–C6, plus:

- Q-0006 is `DECIDED` through an ACCEPTED LDR;
- Q-0007 is `DECIDED` through an ACCEPTED LDR and, if contribution process
  rules are affected, an ACCEPTED GDR;
- Q-0011 and Q-0012 are `DECIDED` through ACCEPTED GDRs;
- the Q-0010 clearance outcome is recorded in an ACCEPTED BDR and reflected
  in [`../product/vision/BRAND-STATUS.md`](../product/vision/BRAND-STATUS.md);
- the security reporting mechanism has been configured by the Project Owner
  and documented in `SECURITY.md`.
