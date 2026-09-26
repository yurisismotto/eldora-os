# AGENTS.md — Eldora OS

This document defines vendor-neutral rules for human and AI agents working
on Eldora OS.

The current, mutable project state (phase, Owner Baselines, open questions,
working hypotheses, brand and license status) is recorded in
[`docs/project/CURRENT-STATE.md`](docs/project/CURRENT-STATE.md). Read it
before performing any work. This file contains rules, not state.

## Source of truth

The Git repository is the source of truth.

Chat history and prompts are temporary working context and must not replace
project documentation.

Important permanent knowledge must be represented as documentation, ADRs,
SPECs, tests, code, issues, or other repository artifacts.

## Decision discipline

Always distinguish:

- FACT
- HYPOTHESIS
- REQUIREMENT
- ALTERNATIVE
- RECOMMENDATION
- DECISION

A recommendation is not a decision.

Architectural decisions must not silently become accepted.

Permanent architectural decisions require explicit Project Owner approval
and an ADR. Governance, legal/licensing and brand/trademark decisions use
their own decision records (GDR, LDR, BDR), not ADRs. During the Foundation
phase only the Project Owner may accept a decision record or approve a SPEC;
agents may research and propose, never accept or approve. See
[`docs/project/GOVERNANCE.md`](docs/project/GOVERNANCE.md) and
[`docs/project/DECISION-LIFECYCLE.md`](docs/project/DECISION-LIFECYCLE.md).

Owner Baselines ([`docs/project/OWNER-BASELINES.md`](docs/project/OWNER-BASELINES.md))
are founding premises set by the Project Owner. Agents must not create,
change or cite Owner Baselines to bypass the ADR process.

## Research

Research must:

- separate facts from assumptions;
- compare meaningful alternatives;
- document trade-offs and risks;
- prefer primary and authoritative sources;
- provide sources for externally verifiable claims;
- identify uncertainty explicitly.

Research follows the conventions and source policy in
[`docs/research/README.md`](docs/research/README.md).

Do not invent APIs, capabilities, compatibility claims, benchmarks, or facts.

## Implementation integrity

Never:

- silently change architecture;
- silently change scope;
- remove or disable tests merely to obtain PASS;
- represent TODOs, placeholders, mocks, or stubs as completed implementation;
- claim physical hardware testing without physical hardware evidence;
- declare PASS without evidence;
- weaken security for convenience;
- introduce dependencies without justification.

## GitHub and remote authority

Agents must not impersonate the Project Owner or act as the Project Owner.

**Any action that contacts GitHub or any Git remote, or that acts on behalf
of the Project Owner, requires explicit authorization from the Project Owner
for that specific action.** Authorization for one action does not extend to
other actions, and authorization in one task does not carry over to another.
Future authorizations may be granted explicitly and limited to a specific
task.

This applies to read-only operations as well. It includes, without being
limited to:

- running `gh`, calling any GitHub API, or automating the GitHub web UI;
- `git clone`, `git fetch`, `git pull`, `git ls-remote`, `git push` or any
  other command that contacts a remote;
- adding, removing or changing Git remotes;
- creating, deleting or changing organizations or repositories, including
  visibility and settings;
- opening, closing, editing or commenting on issues, pull requests or
  discussions;
- creating, updating or merging pull requests;
- creating or changing labels, milestones, projects, webhooks, apps or
  Actions configuration;
- creating releases or publishing tags;
- publishing packages;
- changing branch protection or security settings;
- changing secrets, or creating credentials or tokens;
- accepting licenses, terms or legal agreements on behalf of the owner.

Agents may prepare local files, suggested commands, PR descriptions, issue
text, release notes, and other artifacts for human review.

Local Git operations that do not contact a remote are allowed when requested
by the task, subject to the attribution rules below.

The Project Owner performs identity-bearing and publication actions.

## Authorship and attribution

Agents must follow the authorship and attribution policy in
[`docs/project/GOVERNANCE.md`](docs/project/GOVERNANCE.md#authorship-and-attribution-of-agent-assisted-work).
In summary: disclose agent assistance, never change the Git identity or
signing configuration, never add sign-off, signature or approval lines on
behalf of a human, and never present agent work as the Project Owner's own
statement or approval.

## AI

Fundamental Eldora OS functionality must not require AI services.

AI may complement the platform in the future but must not be required for
core operation.

## Repository architecture

Do not create additional repositories merely because a conceptual component
exists.

Monorepo, multi-repo, and hybrid strategies must be evaluated before
significant implementation (Q-0005).

## License and contributions

Do not select or create a LICENSE until the license research and Project
Owner decision are complete (Q-0006).

Do not represent the repository as open-source software. Eldora OS is
intended to be an open-source project. Licensing is pending.

External contributions are not open.
