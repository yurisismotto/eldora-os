# ADR-0001 — V1 base-system composition: Fedora-derived image-based system using bootc/OCI (M3)

| Field | Value |
|---|---|
| ID | ADR-0001 |
| Status | ACCEPTED |
| Date proposed | 2026-09-26 |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), recording the Project Owner's decision |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): drafted this record from the Project Owner's decision and RES-0001 to RES-0005; no decision taken by the agent |
| Related questions | Q-0001 (resolved by this ADR); Q-0008 (related, not resolved) |
| Related research | RES-0001, RES-0002, RES-0003, RES-0004, RES-0005 |
| Decision owner | Project Owner |
| Approved by | Project Owner |
| Approval date | 2026-09-26 |
| Approval evidence | Explicit Project Owner decision given to an agent session on 2026-09-26 ("DECISION: Para Eldora OS V1, selecionar M3 …"), recorded in [`../project/reviews/WAVE-0.1B-REVIEW.md`](../project/reviews/WAVE-0.1B-REVIEW.md); the permanent evidence is the first commit made by the Project Owner that contains this ADR with status `ACCEPTED`. |

Status history: `PROPOSED` (2026-09-26, recorded from the Project Owner's
decision) → `ACCEPTED` (2026-09-26, Project Owner). Recorded by an agent at
the Project Owner's explicit, referenced instruction (see `GOVERNANCE.md`).

## Status summary

| Item | Status |
|---|---|
| Fedora-derived (OB-0004) | CONFIRMED |
| M3 — Fedora-derived image-based system using bootc/OCI | **SELECTED FOR V1** |
| M1 — Fedora package-based mutable host | FALLBACK / CONTINGENCY |
| M2 / M2b — rpm-ostree/OSTree; rpm-ostree client over OCI | TECHNICAL REFERENCE |

## Context

Eldora OS V1 is Fedora-derived (OB-0004, confirmed by the Project Owner,
D13; interpreted D20: Fedora is the principal upstream family). The
composition of the V1 base system within the Fedora ecosystem was open
(Q-0001). Wave 0.1 researched it in four stages:

- RES-0001 (0.1A) surveyed Fedora composition models and tooling;
- RES-0003 (0.1B) analysed ownership, root filesystem, configuration,
  machine state and packages;
- RES-0004 (0.1B-P) ran controlled probes PB1–PB5 in disposable VMs;
- RES-0005 (0.1B-F) validated a real desktop workload, escape hatches,
  UEFI/Secure Boot, a Fedora 44 → 45 rebase for M1 and M3, and stable
  UID/GID.

RES-0005 answered Q19 ("sufficient evidence to promote M3 over M1?") with
YES, with conditions, at MEDIUM confidence. The Project Owner reviewed
RES-0003, RES-0004 and RES-0005 and considered the 0.1B research sufficient
for a human decision.

## Problem

Which Fedora-based composition model should the Eldora OS V1 base system
use, such that Eldora can own a distinct platform without maintaining a
whole distribution?

## Constraints

- OB-0001 (Linux kernel) and OB-0004 (Fedora-derived V1).
- Foundation working principles P1–P6 (review record 0.1B): vendor
  defaults in `/usr`; drop-ins; declarative sysusers/tmpfiles; Eldora
  components as versioned, signed artefacts; no fork by default; separation
  of system content, machine state, user state and application state.
- The decision covers the base-system composition only (see Scope).

## Scope

In scope: the composition model of the Eldora OS V1 base system.

Not decided by this ADR (remain open in their own questions or waves):
update, rollback and recovery policy (Q-0008, Wave 0.1C); image build,
boot and release pipeline, registry, CI, installer and bootloader
architecture (Wave 0.1D); desktop environment, compositor and toolkit
(Q-0002, Q-0009); application model (Q-0003); platform architecture
(Q-0004); repository strategy (Q-0005); the specific Fedora base image
(`fedora-bootc` content set or an Atomic desktop image); UID/GID policy;
the power-user extension product design.

## Considered Alternatives

- **M1 — Fedora package-based mutable host (RPM/DNF5).** Largest persistent
  escape hatch; no image or registry infrastructure; Fedora 44 → 45 via
  `dnf system-upgrade` needed no artefact changes (RES-0005). Against: no
  system-level atomic update or rollback; configuration drift signalled but
  not reconciled; dependency resolution on every client (RES-0003,
  RES-0004, RES-0005). **Status: FALLBACK / CONTINGENCY** — not rejected.
- **M2 — rpm-ostree/OSTree (classic delivery)** and **M2b — rpm-ostree
  client over OCI.** M2b offers persistent RPM layering that follows the
  channel and honours the signature policy, but blocks `bootc upgrade`;
  bootc upstream expects rpm-ostree compatibility to break; Fedora's
  direction for image-based variants is bootc/OCI (RES-0001, RES-0004,
  RES-0005). **Status: TECHNICAL REFERENCE.**
- **M3 — Fedora-derived image-based system using bootc/OCI.** Selected.

## Decision

For Eldora OS V1, the base system is composed as a **Fedora-derived
image-based system using bootc/OCI (M3)**: the OS is delivered as
bootable OCI images derived from Fedora base images and deployed with
bootc, with persistent machine state (`/etc`, `/var`) and user state
(`/home`) kept outside the image lifecycle.

This decision applies to V1 and may be revisited through the formal
architectural process if material future evidence justifies it (see
"Reversibility").

## Rationale

Experimental evidence (RES-0004, RES-0005):

- **Reproducible system model:** `/usr` is identified by an image digest;
  the same signed Eldora-lab RPM served both M1 and M3 (PB1).
- **Image-based deployments with rollback/roll-forward:** OS-side rollback
  was clean, including users and groups, across updates and a major
  version (PB3, E1, E4).
- **Separation of system content and persistent state:** `/etc`, `/var`,
  `/home`, machine identity and host keys persisted across update,
  rollback and image replacement (PB4, E1, E4).
- **Fedora 44 → 45 validated:** BUILD, DEPLOYMENT, BOOT and DESKTOP
  success; zero changes to the lab artefacts other than the base reference;
  rollback to 44 and roll-forward to 45 worked (E4).
- **Real desktop validated:** a Fedora Silverblue–derived GNOME workload
  (representative only) installed, booted, logged in, updated, rolled back
  and upgraded, with core desktop services and user state intact (E1).
- **UEFI and Secure Boot validated:** Secure Boot enabled, kernel lockdown
  `integrity`, kernel change and EFI shim/grub update under Secure Boot
  (E3).
- **Direction alignment:** Fedora's stated end state for image-based
  variants is bootable OCI artefacts built with the bootc toolchain
  (RES-0001), and M3 fits the Eldora goal of owning a coherent platform
  image.

## Consequences

### Positive

- Atomic, image-level updates with OS rollback and roll-forward.
- A versioned, digest-identified system image that Eldora owns; Fedora
  content consumed without forks.
- Structural separation of system content from machine and user state.
- Major Fedora rebases concentrated in the image build (RES-0005 E4),
  reducing field variability (RISK-0001 reduced, not closed).
- Signature enforcement is available and was effective when configured
  (RES-0004 PB5).

### Negative

- Eldora must operate image build, registry, image signing and update
  distribution infrastructure (RES-0003 Q14; RES-0004 PB1).
- Persistent host extension is limited: `/usr/local` + `/etc` covers only
  simple tools and local services; a local derived image covers everything
  but needs rebuilds to follow upstream and is deployed unverified; M2b is
  bootc-incompatible (RES-0005 E2).
- Larger update downloads (~2.4 GB layers for a desktop major upgrade;
  ~160 MB for a small revision) (RES-0005).
- Several silent failure modes exist and must be engineered away (see
  Conditions and Risks).

### Risks

Open risks that apply to this decision (none is closed or accepted by this
ADR): RISK-0001, RISK-0002, RISK-0003, RISK-0004, RISK-0005, RISK-0006,
RISK-0007, RISK-0008, RISK-0009, RISK-0010 (**release blocker for M3**),
RISK-0011. See [`../project/RISK-REGISTER.md`](../project/RISK-REGISTER.md).

## Conditions

This decision does not mean all risks are accepted or resolved. The
following are architectural conditions of the decision:

- **C1.** Eldora must prevent silent loss of staged updates.
- **C2.** The UEFI / systemd GPT auto-generator / OSTree `/boot` finding
  (RES-0005; RISK-0010) must be resolved before release.
  `systemd.gpt_auto=0` is only a **LAB-VALIDATED MITIGATION** and is not
  the final solution.
- **C3.** The update trust chain must be explicitly defined and enforced by
  Eldora (RISK-0007).
- **C4.** Freshness / anti-rollback remains an open problem (RISK-0008).
- **C5.** Build inputs must have a verification strategy (RISK-0009).
- **C6.** The UID/GID allocation and collision policy must be defined
  (RISK-0005).
- **C7.** Eldora must provide a supported experience for power users; the
  `/usr/local` + `/etc` result is useful evidence but not a universal
  solution for host extension (RISK-0006).
- **C8.** Rollback of the system image does not imply full rollback of the
  boot chain (RISK-0011).
- **C9.** M3 must continue to allow `/etc`, `/var`, `/home` and other
  appropriate local state to remain under the control of the machine
  owner.

## Security Impact

Positive: read-only, image-owned `/usr`; enforceable image signature
policy; Secure Boot validated in the laboratory. Negative or open: default
container trust is permissive and must be hardened (C3); no freshness
guarantee (C4); build inputs and locally built images are not verified by
default (C5); `/etc` and `/var` persist and can carry executable
configuration (RES-0003). Physical hardware and third-party drivers were
not validated (RISK-0002).

## Compatibility Impact

Applications and user tools are expected to live outside the OS image
(application model: Q-0003). Host package installation via DNF is not
persistent on deployed systems; development workloads are expected to use
containers or user-level tooling, with a supported power-user path to be
designed (C7). Fedora release cadence continues to apply (RISK-0001).

## Reversibility

Reconsideration triggers (any of these justifies reopening Q-0001 through
the formal process):

- C1/C2 cannot be satisfied before release;
- the update trust chain (C3–C5) cannot be enforced with acceptable
  usability;
- no acceptable supported power-user experience can be provided (C7);
- physical hardware or driver validation (RISK-0002) shows M3-specific
  blockers;
- Fedora materially changes or abandons its bootc/OCI direction;
- operating the image pipeline proves unsustainable for the team
  (RISK-0001).

M1 remains the documented fallback. Before users exist, switching model is
comparatively cheap; after release, a model change implies a rebase or
reinstall for users (RES-0002).

## Related SPECs

None.

## Supersedes

None.

## Superseded By

None.
