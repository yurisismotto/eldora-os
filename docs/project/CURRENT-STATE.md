# Eldora OS Current State

Last updated: 2026-09-26

This document holds the mutable state of the project. Rules for agents live
in [`AGENTS.md`](../../AGENTS.md); they do not duplicate this state.

## Phase

- **Phase:** Foundation (Wave 0)
- **Wave 0.0 — Project Governance & Research Foundation:** CLOSED
  (closed by the Project Owner on 2026-09-26)
- **Next stage, authorized for preparation:** Wave 0.1 — Fedora-derived
  Base System Composition. Wave 0.1 has not started; no Wave 0.1 research
  exists yet.
- **Wave details:** see [`FOUNDATION-ROADMAP.md`](FOUNDATION-ROADMAP.md)

No production operating-system implementation exists.

## Owner Baselines

Founding premises established by the Project Owner are recorded in
[`OWNER-BASELINES.md`](OWNER-BASELINES.md):

- OB-0001 — initial kernel: Linux;
- OB-0002 — provisional name: Eldora OS (clearance pending);
- OB-0003 — provisional tagline: Simple. Powerful. Yours. (clearance pending);
- OB-0004 — Eldora OS V1 is Fedora-derived (V1 scope).

## Not selected

Each item is an open question in the
[Decision Register](../adr/DECISION-REGISTER.md):

| Topic | Question | Wave |
|---|---|---|
| Base-system composition within the Fedora ecosystem | Q-0001 | 0.1 |
| System/base-image update and rollback architecture | Q-0008 | 0.1 |
| Desktop environment / compositor (Wayland is a direction to validate) | Q-0002 | 0.2 |
| UI toolkit | Q-0009 | 0.2 |
| Application model, distribution and application updates | Q-0003 | 0.3 |
| Platform architecture (working hypothesis below) | Q-0004 | 0.4 |
| Repository strategy | Q-0005 | 0.5 |
| License | Q-0006 | 0.6 |
| Contribution licensing (DCO/CLA/other) | Q-0007 | 0.6 |
| Brand/trademark clearance | Q-0010 | 0.6 |
| Definitive Code of Conduct | Q-0011 | 0.6 |
| Security vulnerability disclosure process | Q-0012 | 0.6 |

## Working hypothesis: conceptual architecture

The following stack is a **working hypothesis**, not an accepted design. It
is validated or refuted in Wave 0.4 (Q-0004). Any layer may be removed,
merged or replaced.

```text
Applications
→ Eldora SDK
→ Platform APIs / Capability APIs
→ System Broker
→ Eldora System Services
→ Linux Adapter Layer
→ Linux userspace
→ Linux Kernel
→ Hardware
```

## Brand and legal status

- **TRADEMARK CLEARANCE: PENDING** — name, tagline and symbol/visual
  identity are provisional. See
  [`../product/vision/BRAND-STATUS.md`](../product/vision/BRAND-STATUS.md).
- **License:** none selected. No `LICENSE` file exists. Eldora OS is intended
  to be an open-source project. Licensing is pending.
- **External contributions:** not open.
- **Security reporting:** no private reporting channel exists yet. See
  [`../../SECURITY.md`](../../SECURITY.md).

## AI

Fundamental Eldora OS functionality must not require AI services.
