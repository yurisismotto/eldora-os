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

Status: IN PROGRESS (stages 0.1A, 0.1X and 0.1B CLOSED; Q-0001 DECIDED by ADR-0001; 0.1C IN PROGRESS — sub-stage 0.1C-A CLOSED; 0.1C-B, 0.1C-C, 0.1C-F PLANNED)
Questions: Q-0001, Q-0008
Baseline: OB-0004 (Eldora OS V1 is Fedora-derived; confirmed for V1 by the Project Owner on 2026-09-26, D13)

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

### Wave 0.1 research stages

Stages are research steps inside Wave 0.1; they use the wave statuses above.
The Wave 0.1 exit criteria (C1–C6) apply to the wave as a whole. Stage
closures were recorded on explicit Project Owner instruction (D13–D16,
2026-09-26); see
[`reviews/WAVE-0.1A-0.1X-REVIEW.md`](reviews/WAVE-0.1A-0.1X-REVIEW.md).

#### Wave 0.1A — Fedora Ecosystem & Base-System Composition Models

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Report: RES-0001 (REVIEWED)

Complete as a research stage. It does not select a composition model:
bootc/OCI (M3) is the principal candidate for investigation; package-based
(M1) is a mandatory fallback candidate; OSTree/rpm-ostree (M2) is not a
preferred target for a new architecture but remains relevant evidence.
Q-0001 and Q-0008 remain undecided.

#### Wave 0.1X — Base Distribution Challenge (extraordinary)

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Questions: Q-0013
Report: RES-0002 (REVIEWED)
Position: extraordinary investigation inserted between stages 0.1A and 0.1B.

Directed by the Project Owner on 2026-09-26 to challenge OB-0004 before
significant implementation. It explicitly compared Fedora, Ubuntu and
Debian; this was a Project Owner-directed exception to the Wave 0.1
out-of-scope item "comparing Fedora against non-Fedora bases" and does not
change that item for other Wave 0.1 research. "0.1X" is not a general
numbering pattern.

Outcome: the Project Owner confirmed OB-0004 for V1 (D13). The discovered
alternative GNOME OS / freedesktop-sdk is kept only as an architectural
reference for future investigation (D16). The block on Wave 0.1B that
existed only pending human review of 0.1X is removed.

#### Wave 0.1B — System Image / Root Filesystem / Package Ownership

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Reports: RES-0003, RES-0004, RES-0005 (all REVIEWED)
Outcome: Q-0001 DECIDED — [ADR-0001](../adr/ADR-0001-v1-base-composition-bootc-oci.md) selects M3 (Fedora-derived image-based system using bootc/OCI) for V1; M1 fallback/contingency; M2/M2b reference. Q-0008 not decided (Wave 0.1C).

Inputs: open questions forwarded by RES-0001 (0.1B list) and the
considerations in RES-0002; tracked risks RISK-0001 to RISK-0004
([`RISK-REGISTER.md`](RISK-REGISTER.md)).

#### Wave 0.1B-P — Composition Validation Probes

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Report: RES-0004 (REVIEWED)
Parent: Wave 0.1B

Controlled experimental sub-stage run before any composition decision:
probes PB2, PB3 and PB5 (priority), with PB1 and PB4 derived from the same
disposable laboratory environments. All mutable experiments run in
disposable VMs; the Project Owner's workstation is not modified. It does
not start Waves 0.1C or 0.1D.

#### Wave 0.1B-F — Composition Final Validation

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Report: RES-0005 (REVIEWED; accepted as final Wave 0.1B research evidence)
Parent: Wave 0.1B

Final controlled experimental sub-stage addressing RES-0004 evidence gaps
E1–E5 (desktop workload on bootc, persistent escape hatch, UEFI/Secure
Boot/bootloader, Fedora 44→45 rebase, stable UID/GID). Disposable VMs
only; the Project Owner's workstation is not modified. Ends with the final
0.1B decision gate (Q19, Q19-A/B/C); it does not select a composition
model and does not start Waves 0.1C or 0.1D.

#### Wave 0.1C — Update / Rollback / Recovery

Status: IN PROGRESS (sub-stage 0.1C-A CLOSED; 0.1C-B, 0.1C-C and 0.1C-F PLANNED, not started)
Review: [`reviews/WAVE-0.1C-REVIEW.md`](reviews/WAVE-0.1C-REVIEW.md)

Inputs: ADR-0001 conditions C1–C9; questions forwarded by RES-0003 to
RES-0005; RISK-0007, RISK-0008, RISK-0010, RISK-0011.

Decomposition confirmed by the Project Owner on 2026-09-26 (scope
definition, not an architectural or product-policy decision): 0.1C-A,
0.1C-B, 0.1C-C and 0.1C-F below.

#### Wave 0.1C-A — Update State Machine & Failure Semantics

Status: CLOSED
Closed by: Project Owner
Closure date: 2026-09-26
Closure evidence: the Project Owner's commit that sets this status to `CLOSED`.
Parent: Wave 0.1C
Report: [RES-0006](../research/wave-0/RES-0006-update-state-machine-failure-semantics.md) (REVIEWED; approved with editorial corrections)

Read-only architectural research: the real bootc/OSTree update state
machine, observability, failure semantics (F01–F26), re-analysis of
RISK-0010, success/boot-success semantics, persistent state, trust and
freshness boundaries. No failure-injection probes are executed in this
sub-stage; proposed probes are forwarded to a later sub-stage. It does not
start 0.1C-B, 0.1C-C, 0.1C-F or Wave 0.1D.

Outcome: Q-0008 remains IN RESEARCH (not decided); ADR-0001 not reopened;
RISK-0010 remains OPEN / release blocker for M3; RISK-0012 to RISK-0016
registered (OPEN). Probe P-01 promoted to an early fact-finding probe;
P-02 to P-16 planned for 0.1C-F. No probe executed.

#### Wave 0.1C-B — Update Policy, Trust & Freshness Semantics

Status: PLANNED
Parent: Wave 0.1C

Scope (from RES-0006, "Questions for later sub-stages"): update policy,
trust and freshness semantics. Not started.

#### Wave 0.1C-C — Health, Known-Good, Rollback & Recovery Semantics

Status: PLANNED
Parent: Wave 0.1C

Scope (from RES-0006, "Questions for later sub-stages"): health,
known-good, rollback and recovery semantics. Not started.

#### Wave 0.1C-F — Experimental Validation & Failure Injection

Status: PLANNED
Parent: Wave 0.1C

Scope: experimental validation and failure injection, including probes
P-02 to P-16 proposed in RES-0006. Not started.

#### Wave 0.1D — Image Build / Boot / Release Pipeline

Status: PLANNED

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
