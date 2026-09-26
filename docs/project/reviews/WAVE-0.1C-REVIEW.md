# Wave 0.1C — Project Owner Review Record

| Field | Value |
|---|---|
| Reviewed stage | Wave 0.1C-A — Update State Machine & Failure Semantics (parent Wave 0.1C — Update / Rollback / Recovery) |
| Reviewed report | [RES-0006](../../research/wave-0/RES-0006-update-state-machine-failure-semantics.md) |
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
