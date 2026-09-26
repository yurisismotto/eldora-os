# Eldora OS V1 — Product Vision

Status: WORKING VISION

Eldora OS V1 aims to demonstrate that Linux can be presented as a coherent,
modern Eldora platform without unnecessarily rebuilding mature Linux
infrastructure.

## Owner requirement

- Eldora OS V1 is Fedora-derived (Owner Baseline OB-0004, see
  [`../../project/OWNER-BASELINES.md`](../../project/OWNER-BASELINES.md)).
  The composition approach within the Fedora ecosystem is not selected
  (Q-0001).

## Directions requiring validation

- Wayland desktop;
- distinctive Eldora desktop experience;
- dock;
- launcher;
- top bar / potential global-menu experience;
- Control Center;
- Notification Center;
- workspaces;
- Settings;
- Files;
- Software / Apps experience;
- onboarding;
- simple application installation and removal.

## Dependent on the architecture hypothesis

The following items depend on the working-hypothesis architecture recorded
in [`../../project/CURRENT-STATE.md`](../../project/CURRENT-STATE.md). They
apply only if Wave 0.4 (Q-0004) retains the corresponding layers:

- initial real Eldora Platform APIs;
- initial Broker / System Services / Linux Adapter boundaries.

## Not prescribed

These items do not prescribe their technical implementation.

Base-system composition, system update mechanism, desktop environment,
compositor, toolkit, application packaging, application update mechanism
and other implementation technologies remain open questions in the
[Decision Register](../../adr/DECISION-REGISTER.md).
