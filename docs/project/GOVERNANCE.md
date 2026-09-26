# Eldora OS Governance

Status: ACTIVE (Foundation phase)
Last updated: 2026-09-25

This document defines who may decide what during the Foundation phase.
Governance may evolve later; any change to this document requires explicit
Project Owner approval.

## Roles

- **Project Owner** — the human who owns the Eldora OS repository and
  project. The Project Owner performs identity-bearing and publication
  actions.
- **Participants** — humans invited by the Project Owner to research,
  review or propose changes.
- **Agents** — AI or automated agents operating under `AGENTS.md`.

## Decision authority

During the Foundation phase:

- Only the Project Owner may promote an architectural decision (ADR) to
  `ACCEPTED`. The same applies to governance, legal/licensing and
  brand/trademark decision records (GDR, LDR, BDR).
- Only the Project Owner may promote a SPEC to `APPROVED`.
- Only the Project Owner may reject or supersede a decision record, add or
  retire an Owner Baseline, reopen a decided question, or withdraw a
  question.
- Participants and agents may research, recommend and propose decision
  records, and may create, review and recommend SPECs. They must not accept
  decisions or approve SPECs, and they must not record an approval on the
  Project Owner's behalf without an explicit, referenced instruction from
  the Project Owner.

Governance may delegate these authorities in the future. Any delegation
must be formalized through a Governance Decision Record ACCEPTED by the
Project Owner or by the governance authority valid at that time.

The lifecycles and valid transitions are defined in
[`DECISION-LIFECYCLE.md`](DECISION-LIFECYCLE.md).

## Owner Baselines

An Owner Baseline is a founding premise explicitly established by the
Project Owner. Owner Baselines do not require a retroactive ADR merely to
justify their existence.

Owner Baselines must not be used to bypass the ADR process:

- a new Owner Baseline may only be created by explicit Project Owner
  instruction and must be a founding premise, not a substitute for an
  architectural decision that requires research;
- choices made *within* an Owner Baseline (for example, which composition
  approach is used inside the Fedora ecosystem) follow the normal
  Decision Register → Research → decision record process;
- later architectural changes follow the normal process.

The register of Owner Baselines, including the rule for their approval
evidence, is [`OWNER-BASELINES.md`](OWNER-BASELINES.md).

## External contributions

External contributions are **not open** during the current phase.

Eldora OS is intended to be an open-source project. Licensing is pending.
No license has been selected, and the repository must not be represented as
open-source software until a license has been selected and applied.

The license and the contribution-licensing policy (for example DCO, CLA or
another mechanism) must be researched and decided before external
contributions open. See Q-0006 and Q-0007 in the
[Decision Register](../adr/DECISION-REGISTER.md).

The mandatory exit criteria of Wave 0.6 — Open Project Readiness
([`FOUNDATION-ROADMAP.md`](FOUNDATION-ROADMAP.md#wave-06--open-project-readiness))
must be met before:

- external contributions are officially opened;
- the project is declared legally open source;
- a public release that depends on these policies is made.

## Authorship and attribution of agent-assisted work

Agents must never impersonate the Project Owner or any other person.

For content (documents, research, decision records, SPECs):

- agent assistance must be disclosed in the document metadata
  (`Agent assistance` field in the templates);
- a responsible human must be named for every research report, ADR and
  SPEC, and an author for every GDR, LDR and BDR;
- reviewers must be humans; an agent may not be the sole reviewer.

For commits:

- agents may create local commits only when the task explicitly requests it;
- agents must not change the configured Git identity (`user.name`,
  `user.email`) or signing configuration;
- agent-assisted commits must include a trailer disclosing the assistance
  (for example `Co-Authored-By: <agent name> <address>` or
  `Assisted-by: <agent name>`);
- agents must not add sign-off, signature or approval lines on behalf of
  any human (for example `Signed-off-by`, GPG/SSH signatures, `Approved-by`);
- the human who commits or publishes agent-assisted work remains
  responsible for it and must review, understand and be able to explain it.

The exact contribution-licensing mechanism (DCO/CLA/other) is not yet
selected (Q-0007); these attribution rules apply regardless.
