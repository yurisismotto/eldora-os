# RES-0005 laboratory plan — Wave 0.1B-F Composition Final Validation

> **RESEARCH ONLY — NOT PRODUCTION — NOT ELDORA IMPLEMENTATION.**
> The desktop used here (GNOME) is a **representative workload only**; it is
> not a selection of the Eldora desktop environment. Lab package and images
> ("eldora-lab") must never be reused as Eldora components.

Written before execution (2026-09-26). Deviations are recorded in RES-0005.

## Safety rules (unchanged from RES-0004)

- Disposable QEMU/KVM VMs started as an unprivileged user; all host-side
  files under `$L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5`; destroyed at the
  end.
- No host changes (packages, `/etc`, SELinux, firewall, libvirt, boot,
  Secure Boot, storage, users, registries, repositories). UEFI firmware is
  used read-only from `/usr/share/edk2/ovmf/`; the NVRAM template is
  **copied** into `$L`.
- Ephemeral keys only (generated inside VM-A). Local lab registry only,
  reachable through a loopback port forward. No publication or upload.

## Topology

| VM | Role | Firmware | Resources |
|---|---|---|---|
| VM-A | Builder + lab registry + LAB-M1 (E4 M1 rebase at the end) | BIOS (SeaBIOS) | 4 vCPU, 3 GiB, 100 GiB sparse + 40 GiB target disk |
| VM-D | LAB-M3 desktop (E1, E2, E3, E4-M3, E5) | **UEFI, Secure Boot enabled, Microsoft certificates enrolled** (`OVMF_CODE.secboot.fd` + copy of `OVMF_VARS.secboot.fd`), q35 with SMM | 4 vCPU, 5 GiB, virtio-vga, emulated HDA audio (null backend), 40 GiB |

VM-D reaches the lab registry as `labregistry:5000` (10.0.2.2 → host
loopback → VM-A). VM-D's HMP monitor is a UNIX socket in `$L` used only for
`screendump` (PNG screenshots as evidence of graphical state).

## Images

- **Desktop base (E1):** primary `quay.io/fedora/fedora-silverblue:44`
  (official Fedora Atomic Desktop OCI image, GNOME) **if** it is
  bootc-capable (`containers.bootc` label and `bootc` present). Fallback:
  `quay.io/fedora/fedora-bootc:44` plus a GNOME package set.
- **Lab images** (built in VM-A, signed with ephemeral sigstore key A,
  pushed to the lab registry):
  - `eldora-desk:44-v1` = desktop base 44 + `eldora-lab-config` v1;
  - `eldora-desk:44-v2` = desktop base 44 + `eldora-lab-config` v2;
  - `eldora-desk:45-v2` = desktop base 45 + `eldora-lab-config` v2 (E4);
  - E2 local derived images are built inside VM-D.
- **Lab package:** `eldora-lab-config` with **fixed** sysusers IDs (E5):
  v1 `u eldoralab 850`; v2 adds `u eldoralab2 851` and `g eldoralabextra
  852`.

## Trust

VM-D uses an explicit `policy.json`: default `reject`; the lab repository
requires sigstore signatures from key A (identity `matchRepository`);
`containers-storage` accepted (needed for local derived images — recorded
as weaker trust). The Fedora base images pulled by VM-A cannot be verified
by signature (no signatures observed in RES-0001/RES-0004) — recorded as a
laboratory trust limitation.

## Probes, hypotheses and PASS/FAIL criteria

| Probe | Hypothesis | PASS | FAIL |
|---|---|---|---|
| E1 desktop | A Fedora desktop image derived and delivered via bootc installs, boots graphically, logs in, updates, rolls back and rolls forward with user data/config intact and core desktop services working | graphical.target reached, display manager active, user session (Wayland) active, NetworkManager active, audio server running, portal running, after each transition; screenshots consistent | any transition leaves the desktop non-functional or loses user data/config |
| E2 escape hatch | At least one supported mechanism gives persistent host extension while following upstream updates | a mechanism rated SUPPORTED or SUPPORTED WITH LIMITATIONS answers yes to "persists" and "follows upstream" with documented upstream backing | no such mechanism (recorded explicitly) |
| E3 UEFI/SB | Install and all transitions work under UEFI with Secure Boot enforced; bootloader update works | `mokutil --sb-state` = enabled; boots after install/update/rollback/kernel change; bootloader update succeeds or is explained | boot failure under SB, or bootloader update failure without explanation |
| E4 rebase | 44→45 transition works for M3 (rebuild with new base) and M1 (dnf system-upgrade) with bounded intervention | transition + reboot + desktop/package checks; intervention count recorded; M3 rollback to 44 works | blocking failure; if Fedora 45 artefacts are unsuitable: BLOCKED BY UPSTREAM AVAILABILITY |
| E5 UID/GID | Fixed sysusers IDs keep IDs stable across v1→v2→rollback→roll-forward, fresh vs upgraded installs | identical IDs across images and machine; `/var` ownership consistent; conflicts documented | drift or silent misownership |
| Desktop + advanced user | A power-user extension (tool + system service) via the E2 mechanism survives an upstream update and behaves predictably on rollback | extension present after update and consistent on rollback | extension lost silently, update silently not followed, or system broken |

## Commands (planned)

Host scripts (`RES-0005-lab/scripts/`): fetch + verify Fedora Cloud 44 image;
start VM-A (BIOS) and VM-D (UEFI SB); SSH/copy/run helpers; reboot helper;
screenshot helper (HMP `screendump -f png`); destroy.
In-VM scripts (`RES-0005-lab/vm/`): builder setup; RPM build (fixed IDs);
desktop base inspection; image builds/signing/push; `bootc install to-disk
--filesystem xfs`; per-transition state collection (desktop services,
session, users/IDs, `/var` ownership, Secure Boot state, bootloader status,
boot artefacts); E2 mechanism tests; E4 rebuild/switch; M1 `dnf
system-upgrade` 44→45 in VM-A.

## Destruction

Stop QEMU processes, `rm -rf $L`, verify no lab processes remain and host
`/etc`, packages and `~/.ssh/known_hosts` unchanged.
