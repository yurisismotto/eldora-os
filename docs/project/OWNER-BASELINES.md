# Owner Baselines

Owner Baselines are founding premises explicitly established by the Project
Owner. The concept, its authority and its limits are defined in
[`GOVERNANCE.md`](GOVERNANCE.md#owner-baselines).

Owner Baselines are not ADRs and must not be used to bypass the ADR process.
Implementation choices within a baseline are tracked in the
[Decision Register](../adr/DECISION-REGISTER.md).

## Lifecycle

`ACTIVE` → `RETIRED` or `SUPERSEDED` (by a later Owner Baseline or an
ACCEPTED ADR). Only the Project Owner may change an Owner Baseline.

## Register

Established by: Project Owner
Recorded: 2026-09-25
Basis: explicit Project Owner instructions (decisions D1 and D2) given to an
agent session on 2026-09-25.

| ID | Baseline | Scope | Status | Conditions / notes |
|---|---|---|---|---|
| OB-0001 | The initial kernel is Linux. | Eldora OS (initial) | ACTIVE | — |
| OB-0002 | The provisional project name is "Eldora OS". | Project | ACTIVE | Subject to brand/trademark clearance (Q-0010). TRADEMARK CLEARANCE: PENDING. |
| OB-0003 | The provisional tagline is "Simple. Powerful. Yours." | Project | ACTIVE | Subject to brand/trademark clearance (Q-0010). |
| OB-0004 | Eldora OS V1 is Fedora-derived (uses the Fedora ecosystem). | V1 only | ACTIVE | Not necessarily a permanent constraint for future versions. The composition approach within the Fedora ecosystem is not selected (Q-0001). |

## Approval evidence

The **first commit made by the Project Owner that contains this file** is
the permanent approval evidence for OB-0001, OB-0002, OB-0003 and OB-0004
(decision D12). It is the earliest commit authored by the Project Owner
in the output of:

```sh
git log --reverse --format='%H %an %ad' -- docs/project/OWNER-BASELINES.md
```

Owner Baselines added or changed later must record their own approval
evidence in this file.
