# Wave 0.1C — Project Owner Review Record

| Field | Value |
|---|---|
| Reviewed stages | Wave 0.1C-A — Update State Machine & Failure Semantics; Wave 0.1C-B — Update Policy, Trust & Freshness Semantics; Wave 0.1C-C — Health, Known-Good, Rollback & Recovery Semantics (parent Wave 0.1C — Update / Rollback / Recovery) |
| Reviewed reports | [RES-0006](../../research/wave-0/RES-0006-update-state-machine-failure-semantics.md) (0.1C-A); [RES-0007](../../research/wave-0/RES-0007-update-policy-trust-freshness-semantics.md) (0.1C-B); [RES-0008](../../research/wave-0/RES-0008-health-known-good-rollback-recovery-semantics.md) (0.1C-C) |
| Reviewer | Project Owner (human review) |
| Review date | 2026-09-26 |
| Recorded by | Agent (Claude Code), on explicit Project Owner instruction given to an agent session on 2026-09-26 |
| Approval evidence | The first commit made by the Project Owner that contains this file |

## Review of RES-0006 (Wave 0.1C-A)

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| RES-0006 | DRAFT → IN REVIEW → REVIEWED (submitted to and reviewed by the Project Owner on 2026-09-26) | REVIEWED | APPROVED WITH EDITORIAL CORRECTIONS |

The review outcome does not decide the update/rollback architecture
(Q-0008) and does not reopen ADR-0001.

### Editorial corrections applied

Applied by the agent on Project Owner instruction before the report was
marked REVIEWED:

1. **"Confidence and limitations"** rewritten: Fedora documentation was
   partially unavailable (docs.fedoraproject.org access restrictions);
   GitHub was intentionally not consulted in the first research pass; the
   Project Owner later explicitly authorized a read-only second pass over
   the official bootc and ostreedev/ostree issue trackers exclusively for
   RISK-0010, represented by U1–U9 / S49–S59; the authority of tracker
   evidence is stated (Tier 2, does not establish code behaviour); source
   code and other unread material remain UNVERIFIED where applicable. The
   stale statement that "GitHub and Fedora docs were unavailable" was
   removed.
2. **Q13 (`/etc` semantics)** rewritten, consistent with Part 8: a local
   `/etc` override can propagate through the three-way merge into
   subsequently created deployments; an already-existing rollback
   deployment retains its own `/etc` snapshot and is not retroactively
   modified; rollback can therefore hide a later edit; rolling forward to a
   deployment whose `/etc` snapshot contains that edit can make it
   reappear. The Part 8 `/etc` row was aligned.
3. **F13** reworded to "Abrupt power loss / hard reset after staging,
   before finalization"; an orderly shutdown or reboot runs finalization
   and is covered by F14/F15. Minimal consistency edits in the Part 1 state
   diagram, Q1, Q9, the Part 11 policy table and RC-H.
4. Wave 0.1C sub-stage scope recorded as confirmed (below); "assumed"
   wording removed from Part 2, Part 11 and "Questions for later
   sub-stages".
5. Probe scheduling recorded (below); a broken cross-reference to a
   non-existent "Part 13" in Part 5 was pointed at the probes section.
6. RC-H to RC-L annotated with their registered RISK IDs.

## Project Owner decisions recorded

### Wave 0.1C decomposition (scope definition)

The Project Owner confirms the following decomposition of Wave 0.1C. This
is a scope definition, not an architectural or product-policy decision.

- **0.1C-A** — Update State Machine & Failure Semantics;
- **0.1C-B** — Update Policy, Trust & Freshness Semantics;
- **0.1C-C** — Health, Known-Good, Rollback & Recovery Semantics;
- **0.1C-F** — Experimental Validation & Failure Injection.

### Probe scheduling

- **P-01** is promoted to an **EARLY FACT-FINDING PROBE**, because it
  resolves the H-L1/H-L2 factual uncertainty directly related to
  RISK-0010.
- **P-02 to P-16** remain planned for **0.1C-F**, unless later research
  provides a documented reason to re-order them.
- No probe, including P-01, was executed in 0.1C-A or in this review. No VM
  was started.

### Risks

The five candidate risks from RES-0006 are registered as new `OPEN` risks
in [`RISK-REGISTER.md`](../RISK-REGISTER.md), with meaning preserved:

| Candidate | Risk | Meaning |
|---|---|---|
| RC-H | RISK-0012 | Abrupt crash / power loss after staging can silently lose update intent because upstream has no persistent attempt record. |
| RC-I | RISK-0013 | Booted is not equivalent to healthy/known-good; upstream bootc has no health gate. |
| RC-J | RISK-0014 | Rollback may run older code over forward-migrated persistent state in `/var` or `$HOME`. |
| RC-K | RISK-0015 | Automatic update mechanisms can re-apply a bad update after rollback, creating rollback/re-update loops. |
| RC-L | RISK-0016 | Both deployments, or the shared boot chain, can become unusable without an Eldora-defined recovery path. |

Severity and likelihood of RISK-0012 to RISK-0016 were proposed by the
agent from the cited evidence; the Project Owner may adjust them. No
existing risk is closed, downgraded or re-rated.

**RISK-0010** remains `OPEN` and a **RELEASE BLOCKER FOR M3**; severity
and likelihood unchanged (HIGH/HIGH). `systemd.gpt_auto=0` remains only a
LAB-VALIDATED WORKAROUND / MITIGATION, not the Eldora architecture.
C-R1 to C-R5 (RES-0006 Part 5) are kept as candidate blocker-lifting
criteria; lifting the blocker remains a Project Owner decision.

### Lifecycle outcome

- RES-0006 → REVIEWED.
- Wave 0.1C-A closed by the Project Owner on 2026-09-26. Closure evidence:
  the Project Owner's next commit containing this record and the
  corresponding artefacts.
- Q-0008 remains `IN RESEARCH`; **NOT DECIDED**.
- ADR-0001 remains `ACCEPTED`; it is not reopened.
- Wave 0.1C remains IN PROGRESS. Waves 0.1C-B, 0.1C-C and 0.1C-F are
  PLANNED and not started; this review does not start 0.1C-B.

## Review of RES-0007 (Wave 0.1C-B)

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| [RES-0007](../../research/wave-0/RES-0007-update-policy-trust-freshness-semantics.md) | DRAFT → REVIEWED (reviewed by the Project Owner on 2026-09-26) | REVIEWED | APPROVED AS RESEARCH |

Reviewer: Project Owner (human review), 2026-09-26. Recorded by: agent
(Claude Code), on explicit Project Owner instruction given to an agent
session on 2026-09-26. Approval evidence: the first commit made by the
Project Owner that contains this section.

The approval **does not** accept recommendations R1–R9 as final
architectural decisions, **does not** accept the candidate requirements of
RES-0007 (`R-…`, `HC-…`, `HD-…`) and **does not** authorise any
implementation. RES-0007's distinction between FACT, INFERENCE,
RECOMMENDATION, CANDIDATE REQUIREMENT and DECISION is preserved.

### Project Owner conclusions recorded

1. The separation between integrity, authenticity, authorization,
   freshness and anti-rollback is accepted.
2. H1 is accepted as **REFUTED**: OCI content addressing plus image
   signature verification alone are insufficient for Eldora's complete
   update trust model.
3. Eldora must own the semantics of channel authorization, freshness and
   anti-rollback. This **must not** be interpreted as authorization to
   invent a new Eldora-specific cryptographic protocol.
4. The concrete metadata framework remains **OPEN**: full TUF; an
   appropriate TUF profile/subset; or another established equivalent
   mechanism. Established, auditable security protocols/frameworks are
   preferred over custom cryptographic protocol design unless later
   evidence demonstrates a compelling reason otherwise. Final selection
   belongs to the appropriate ADR / Wave 0.1D work.
5. R2 is accepted as the **architectural direction for later decision**:
   automatic, privacy-minimal check → policy-gated fetch/verify/stage →
   user-initiated or user-scheduled apply/restart for personal devices.
   Unintended ordinary reboots must not silently acquire "apply update"
   semantics. Managed-device deadlines/windows remain a separate profile
   concern.
6. H4 is accepted as **REFUTED**. Release channels are Eldora
   authorization concepts. Mutable OCI tags may be aliases/discovery
   mechanisms but must not constitute the authoritative channel security
   state. Signed metadata binding channel → monotonic version → digest
   remains the working direction pending ADR.
7. R5 / RES-0007 Part 16 anti-rollback principles are accepted as
   **mandatory input to Wave 0.1C-C, not as a final ADR**:
   - anti-rollback applies to newly selected/fetched targets;
   - retained, already-verified deployments remain eligible for local
     rollback;
   - floor advancement depends on the 0.1C-C known-good decision;
   - security epoch/min-version remains distinct from the ordinary
     high-water mark;
   - below-floor recovery requires explicit local owner action;
   - rolled-back bad targets require suppression to avoid automatic
     re-application loops.
8. H5 is accepted **WITH CONDITIONS**: offline operation may preserve
   integrity, authenticity, authorization and counter-based anti-rollback,
   but absolute freshness/freeze detection cannot be claimed without fresh
   trusted metadata/time. Offline/stale freshness must therefore be
   explicit and owner-visible rather than silently treated as fresh.
9. Compromise recovery remains a **first-class 0.1D requirement**. A
   single online signing key must not be frozen as Eldora's final trust
   architecture. An offline/threshold root or an established equivalent
   recovery authority remains to be evaluated.
10. Explicitly deferred questions are preserved:
    - **0.1C-C** owns known-good/floor advancement, automatic rollback
      semantics, loop suppression, retention/pinning interactions,
      downgrade state compatibility and update-success semantics;
    - **0.1D** owns signing format/tooling, key custody/rotation/recovery,
      registry/mirrors, freshness publication operations,
      provenance/SBOM, installer trust bootstrap and related supply-chain
      operations;
    - **future SPECs** own user-facing update UX/policy surfaces.
11. No production implementation is authorized by this review.

### Items left undecided by this review

- Q-0008 remains `IN RESEARCH`; **NOT DECIDED**.
- ADR-0001 remains `ACCEPTED`; not reopened. No ADR is created or proposed.
- R1, R3, R4, R6, R7, R8 and R9 of RES-0007 are not dispositioned beyond
  the conclusions above; R2 and R5 are recorded only as direction/input as
  stated.
- The candidate risks RC-M to RC-S of RES-0007 are **not** registered;
  the Risk Register is unchanged. No existing risk is closed, downgraded
  or re-rated; RISK-0010 remains `OPEN` and a **RELEASE BLOCKER FOR M3**.
- The probes proposed in RES-0007 (P-17 to P-24, and the extensions of
  P-04, P-06, P-12, P-13 and PX6) are preserved, **not executed**, for
  0.1C-F unless the Project Owner schedules them otherwise. P-01 remains a
  pending EARLY FACT-FINDING PROBE, not executed. No VM was started.

### Lifecycle outcome

- RES-0007 → REVIEWED (approved as research).
- Wave 0.1C-B → READY FOR OWNER CLOSURE (research deliverable reviewed,
  Project Owner disposition recorded) → **CLOSED** by the Project Owner on
  2026-09-26 (Closed by: Project Owner; Closure date: 2026-09-26). Closure
  evidence: the Project Owner's commit that sets the stage status to
  `CLOSED` in [`FOUNDATION-ROADMAP.md`](../FOUNDATION-ROADMAP.md).
  Closure preserves RES-0007 = REVIEWED, Q-0008 = IN RESEARCH, all
  candidate requirements as candidates, all unresolved risks/questions,
  all probe deferrals and the 0.1C-C / 0.1C-F / 0.1D boundaries.
- Wave 0.1C remains IN PROGRESS. Waves 0.1C-C and 0.1C-F remain PLANNED
  and not started; Wave 0.1D remains PLANNED. This review does not start
  any of them.

## Review of RES-0008 (Wave 0.1C-C)

| Report | Transition | Result | Review outcome |
|---|---|---|---|
| [RES-0008](../../research/wave-0/RES-0008-health-known-good-rollback-recovery-semantics.md) | DRAFT → REVIEWED (reviewed by the Project Owner on 2026-09-26) | REVIEWED | APPROVED WITH REQUIRED SEMANTIC CORRECTIONS |

Reviewer: Project Owner (human review), 2026-09-26. Recorded by: agent
(Claude Code), on explicit Project Owner instruction given to an agent
session on 2026-09-26. Approval evidence: the first commit made by the
Project Owner that contains this section.

The approval does not decide Q-0008, does not create or accept an ADR,
does not authorise implementation and does not authorise any probe.

### Required semantic corrections applied

Applied by the agent on Project Owner instruction before the report was
marked REVIEWED (bounded; no new design):

1. **A1 — KNOWN_GOOD is historical evidence, not a revocable fact.** A
   deployment becoming KNOWN_GOOD records that, at a recorded time, it
   satisfied Eldora's known-good evidence criteria on this machine; that
   history is kept for audit, diagnostics and recovery reasoning. Later
   local regressions, a signed security floor (FORBIDDEN) or
   hardware/state changes affect only **current eligibility** (Part 1,
   R-KG5).
2. **A2 — Owner override must not fabricate KNOWN_GOOD evidence.** Owner
   actions (continue using, retry, boot a suppressed deployment, disable
   automatic rollback, accept risk, force a forbidden recovery target) are
   recorded as OWNER OVERRIDE / OWNER ACCEPTANCE: explicit, local, logged,
   under owner control; they do not by themselves advance the vendor
   high-water floor and do not clear FORBIDDEN (Parts 7, 27, R-KG6,
   R-OV1). No production state name selected.
3. **A3 — Profile requirements are absolute; the baseline is additional
   evidence.** The previous-known-good capability profile detects
   additional, machine-specific regressions and never demotes a
   capability intrinsically required by the selected profile (e.g. the
   basic graphical session on an interactive Desktop profile, networking
   on a declared kiosk profile) (Parts 3–4, R-HM3).
4. **A4 — Persistent-state migrations.** The rule is "do not destroy
   rollback compatibility before KNOWN_GOOD": operational migrations
   before KNOWN_GOOD are additive/expand-style, backward-compatible or
   otherwise readable by the retained rollback deployment;
   destructive/contract steps occur only after KNOWN_GOOD per the later
   state-contract architecture (Parts 1, 8, 16, R-KG3, R-ST1, R-ST2). No
   migration engine designed.
5. **A5 — Independent recovery path vs selecting external media.** V1
   requires an independent, verified, offline-capable recovery path that
   works when both deployments fail, when installed root/shared state is
   damaged and when the installed ESP/boot chain cannot boot (accepted as
   architectural direction). Verified, SBAT-current external media is the
   leading minimum-cost candidate, **not** an accepted architecture;
   on-disk recovery deployment, recovery partition, hybrid or
   firmware/network recovery remain a 0.1D-informed ADR decision
   (Parts 20–21, R-RC1).

Also applied: lifecycle/review metadata; registration annotations for
RC-U to RC-Z; dependent answers and recommendations aligned.

### Project Owner direction — RC-Y (ADR input, not a finalized ADR)

If the active/new deployment fails and every retained rollback deployment
is below the signed security floor (FORBIDDEN for automatic use):

1. Eldora must not automatically roll back below the signed security
   floor.
2. The machine enters RECOVERY_REQUIRED at the semantic level.
3. The legitimate local owner may explicitly choose a retained FORBIDDEN
   deployment as a recovery exception.
4. That owner action is local, explicit and logged; shows that the
   selected deployment is security-forbidden/stale; does not lower or
   clear the vendor security floor; does not clear the deployment's
   FORBIDDEN state; does not make automatic policy consider the
   deployment normally eligible; and does not automatically advance the
   vendor high-water floor.
5. Network metadata can never invoke this owner exception.
6. Recovery tooling must continue to offer a verified independent
   recovery path so the owner is not forced to choose the vulnerable
   deployment.

### Hypotheses H1–H8

Accepted as research results (not ADR decisions): H1 REFUTED; H2
REFUTED; H3 REFUTED; H4 REFUTED; H5 REFUTED; H6 REFUTED AS STATED — the
weaker requirement is SUPPORTED: V1 needs an independent recovery path,
not necessarily a dedicated on-disk recovery environment; H7 SUPPORTED
WITH CONDITIONS; H8 SUPPORTED WITH CONDITIONS.

### Candidate requirements

The semantic directions in R-HM\*, R-KG\*, R-RB\*, R-AT\*, R-LP\*,
R-FL\*, R-RT\*, R-ST\*, R-RC\*, R-OV\*, R-OB\* and R-PV\* are accepted as
**input / architectural direction** for later ADRs and implementation
planning, subject to the corrections above. They are **not** permanent
accepted requirements. Attempt count and dwell parameters remain
deliberately undecided; no numeric value is selected; they require
evidence from 0.1C-F.

### Reset / reinstall

No destructive default is selected. The distinction ROLLBACK / RECOVERY
/ REPAIR / RESET / REINSTALL is preserved. The preservation policy for
`/home`, machine identity, secrets, logs and `/var` during RESET and
REINSTALL is deferred to a later ADR/SPEC informed by 0.1D. Accepted
direction: any destructive action affecting owner data requires explicit
local owner confirmation, and data rescue should be offered when
feasible.

### Risk dispositions — RES-0008 candidates

Registered as new `OPEN` risks in [`RISK-REGISTER.md`](../RISK-REGISTER.md)
(next valid IDs after RISK-0016), with the Project Owner's initial
ratings:

| Candidate | Risk | Severity | Likelihood |
|---|---|---|---|
| RC-U | RISK-0017 — failed boots hang (Fedora defaults), defeating loader-level automatic rollback | HIGH | MEDIUM |
| RC-V | RISK-0018 — staging before known-good evicts the last known-good deployment | HIGH | MEDIUM |
| RC-W | RISK-0019 — monotonic SBAT revocation vs older boot chains/recovery media | HIGH | LOW |
| RC-X | RISK-0020 — no durable evidence for failures before `/var`/journal flush | MEDIUM | MEDIUM |
| RC-Y | RISK-0021 — signed security floor can forbid every retained rollback deployment | HIGH | LOW |
| RC-Z | RISK-0022 — GRUB/greenboot fallback to the second menu entry may not match the intended target | HIGH | LOW |

- **RC-T** — not registered. Disposition: **AVOIDED BY DESIGN
  DIRECTION** — Eldora must not use Fedora GRUB `boot_success` as its
  health/known-good authority. Finding and requirement R-HM6 kept.
- **RC-AA** — not registered. Disposition: **CONDITIONAL / DEFERRED** to
  the future TPM/measured-boot/sealed-secret architecture; preserved in
  RES-0008 and handed to the appropriate 0.1D/hardware work.

No existing risk is closed or re-rated. **RISK-0010** remains `OPEN` and
a **RELEASE BLOCKER FOR M3**.

### Disposition of RES-0007 candidates RC-M to RC-S

Recorded so that no RES-0007 candidate is left without an explicit
disposition. This is disposition, not deletion of research evidence; no
duplicate risk is created.

| Candidate | Disposition |
|---|---|
| RC-M | Absorbed by RISK-0005 plus the 0.1D trust-state design requirements. |
| RC-N | Covered by RISK-0007 / RISK-0008 and the 0.1D signing-format selection. |
| RC-O | Covered by RISK-0007 (enforcement coverage). |
| RC-P | CONDITIONAL — remains a design concern only if expiry/time-based freshness is selected; carried to the freshness ADR / 0.1D. |
| RC-Q | Absorbed by RISK-0015 and Eldora-owned update-policy/timer requirements. |
| RC-R | Carried as an explicit 0.1D offline-update/recovery requirement; no standalone risk at this stage. |
| RC-S | Carried as a mandatory 0.1D trust-root/compromise-recovery gate: the final architecture must not accidentally freeze a single-online-key model with no independent recovery authority. No separate risk yet, because the signing/root architecture has not been selected. |

### Probes

No probe is authorised by this review and none was executed. Preserved:
P-01 (pending EARLY FACT-FINDING PROBE); P-02 to P-24; P-25 to P-31 and
the extensions of P-08 and P-11 (RES-0008); the PX-series; and all
documented extensions. 0.1C-F remains the validation owner. Attempt
count, dwell parameters, Fedora GRUB/greenboot automatic fallback, boot
termination behaviour, pinning/retention behaviour, SBAT/recovery-media
behaviour and evidence survival remain probe-dependent where RES-0008
says so.

### Lifecycle outcome

- RES-0008 → REVIEWED (approved with required semantic corrections).
- Wave 0.1C-C → **CLOSED** by the Project Owner on 2026-09-26 (Closed
  by: Project Owner; Closure date: 2026-09-26). Closure evidence: the
  Project Owner's commit that sets the stage status to `CLOSED` in
  [`FOUNDATION-ROADMAP.md`](../FOUNDATION-ROADMAP.md).
- Q-0008 remains `IN RESEARCH`; **NOT DECIDED**.
- ADR-0001 remains `ACCEPTED`; not reopened. No ADR is created or
  proposed.
- Parent Wave 0.1C remains IN PROGRESS (0.1C-F not completed). Wave
  0.1C-F remains PLANNED / not started; Wave 0.1D remains PLANNED / not
  started. This review does not start either.
