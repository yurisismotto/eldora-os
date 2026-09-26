# RES-0005 — Composition Final Validation (Wave 0.1B-F)

| Field | Value |
|---|---|
| ID | RES-0005 |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1B-F — Composition Final Validation, parent 0.1B) |
| Related questions | Q-0001, Q-0008 (evidence only) |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): laboratory design and execution in disposable VMs, documentary checks, drafting. No sub-agents. No human has reviewed this report yet. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: accepted as final Wave 0.1B research evidence — see [review record](../../project/reviews/WAVE-0.1B-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (see "Confidence and limitations") |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. Even where Q19 = YES, the
> composition model remains **NOT DECIDED** and bootc remains **NOT
> SELECTED** until an explicit Project Owner decision. The desktop used
> (GNOME via Fedora Silverblue) is a **representative workload only** —
> no desktop environment is selected.

Laboratory plan, scripts and artefacts: [`RES-0005-lab/`](RES-0005-lab/)
(RESEARCH ONLY — NOT PRODUCTION — NOT ELDORA IMPLEMENTATION). The plan
([`LAB-PLAN.md`](RES-0005-lab/LAB-PLAN.md)) was written before execution;
deviations are listed below.

## Question

Is there any behaviour, observed in a realistic desktop scenario, that
makes M3 (Fedora-derived bootc/OCI image) inadequate for Eldora OS V1? And,
after resolving evidence gaps E1–E5 from RES-0004 as far as technically
possible, is there enough evidence to promote M3 over M1 (Q19)?

## Laboratory

| Item | Value |
|---|---|
| Host | Project Owner's Fedora 44 workstation; **not modified**. QEMU 10.2.2/KVM as an unprivileged user; UEFI firmware read-only from `/usr/share/edk2/ovmf/` with the NVRAM template **copied** into the lab directory. The Project Owner's own VM was out of scope and never touched. |
| VM-A (builder, lab registry, LAB-M1) | Fedora Cloud Base Generic 44-1.7 (SHA-256 and CHECKSUM signature re-verified, Fedora 44 key `36F6 12DC … 6D9F 90A6`); BIOS; 3 GiB (2 GiB during the paired M3 phase) |
| VM-D (LAB-M3 desktop) | **UEFI with Secure Boot enabled, Microsoft certificates enrolled** (`OVMF_CODE.secboot.fd` + copied `OVMF_VARS.secboot.fd`, q35+SMM); virtio-vga; emulated HDA audio; 5 GiB, later 4 GiB |
| Desktop base (E1) | Official `quay.io/fedora/fedora-silverblue:44` (`44.20260926.0`, digest `sha256:494ff99b…c1dc`, 5.9 GB; `containers.bootc=1`; bootc 1.16.13; GNOME Shell 50.5; kernel 7.2.7-200.fc44; shim 16.1-5; grub2 2.12-64) |
| Fedora 45 base (E4) | Official `quay.io/fedora/fedora-silverblue:45` (`45.20260925.n.0`, "Silverblue Prerelease", `RELEASE_TYPE=development`; GNOME Shell 51 RC; systemd 262; kernel 7.2.7-300.fc45; shim 16.1-7; grub2 2.12-77) |
| Lab package | `eldora-lab-config` v1/v2 with **fixed sysusers IDs** (850/851/852), signed with an ephemeral lab key |
| Lab images | `eldora-desk:44-v1`, `44-v2`, revisions `44-r3/r4/r5`, unsigned `44-r6u`, `45-v2`; signed with ephemeral sigstore key A; a lab `:channel` tag simulating upstream publications |
| Trust in lab | VM-D: `policy.json` default `reject`; the lab repository requires key-A sigstore signatures; `containers-storage` accepted (local derived images — weaker trust); the Fedora toolbox registry added with `insecureAcceptAnything` (weaker trust, recorded). Fedora base images could not be signature-verified (no signatures observed; RES-0001/RES-0004). Builds verified the lab RPM explicitly with `rpm -K --define '_pkgverify_level all'`. |

### Deviations from the plan

1. **UEFI install:** the first install (from a BIOS builder, no
   `--generic-image`) was **not bootable under UEFI** (`BdsDxe: failed to
   load Boot0002 "UEFI Misc Device" … Not Found`); reinstalled with
   `bootc install to-disk --generic-image`, which wrote the removable
   fallback path (`EFI/BOOT/BOOTX64.EFI`, `fbx64.efi`).
2. **Lab harness:** Fedora desktop images do not enable `sshd`; the lab
   Containerfile gained a marked "LAB HARNESS ONLY" `systemctl enable
   sshd` step.
3. **Memory constraints:** the first E4 attempt was stopped by host memory
   pressure (twice); E4 was completed with the Project Owner–authorized
   single-VM sequence (VM-D alone at 4 GiB, then VM-A alone at 3 GiB).
4. **M1 E4 workload:** M1 was upgraded as a package-based server-class host
   (registry service, podman, lab RPM, local customizations); a desktop was
   not installed on M1 because of memory limits.

## E1 — Real desktop workload on bootc

| Check | 44-v1 install | after update to 44-v2 | after rollback | after roll-forward | Fedora 45 (E4) |
|---|---|---|---|---|---|
| graphical boot / `graphical.target` | yes | yes | yes | yes | yes |
| gdm, autologin session, Wayland | yes | yes | yes | yes | yes |
| gnome-shell running | yes (50.5) | yes | yes | yes | yes (51 RC) |
| NetworkManager | active | active | active | active | active |
| PipeWire / WirePlumber / audio server | active ("PulseAudio (on PipeWire 1.6.9)") | same | same | same | same |
| xdg-desktop-portal | active | active | active | active | active |
| User setting (`color-scheme = prefer-dark`) | set | kept | kept | kept | kept |
| User data (`/home/labuser/marker.txt`) | present | kept | kept | kept | kept |

Screenshots: [`d-before-44v1.png`](RES-0005-lab/evidence/d-before-44v1.png)
(GNOME 50 welcome on "Fedora Linux 44.20260926.0 (Silverblue)"),
[`d-f45.png`](RES-0005-lab/evidence/d-f45.png) (GNOME 51 with the GNOME
Software notification "Software Update Installed — An important operating
system update has been installed"),
[`d-firstboot.png`](RES-0005-lab/evidence/d-firstboot.png) (UEFI no-boot
before `--generic-image`).

**Result: PASS.** A Fedora desktop image derived and delivered via bootc
installed, booted graphically, logged in, updated, rolled back and rolled
forward with user state intact. Reboot times: ~16–31 s for most
transitions, up to 65–73 s when the session restarted services.

## E2 — Persistent escape hatch (critical gate)

| Mechanism | Classification | 1 persists | 2 follows upstream | 3 survives update | 4 survives rollback | 5 rebuild | 6 reboot | 7 system integration | 8 security / predictability | 9 plausible UX for Eldora | 10 upstream documentation |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `/usr/local` (→ `/var/usrlocal` on the Atomic desktop base) + unit in `/etc` | **SUPPORTED WITH LIMITATIONS** | yes | **yes** (independent of the image) | yes (verified 44-v2 → r3 → r4 → 45) | yes (it lives in `/var`/`/etc`) | no | no | partial: executables, scripts, systemd units; SELinux labelled `bin_t` | not versioned or verified; outside RPM/image tracking | plausible for simple tools/services | Atomic Desktops layout (`/usr/local` → `/var/usrlocal`) is documented (RES-0003); on `fedora-bootc` base `/usr/local` is read-only (RES-0004) |
| Local derived image (Containerfile `FROM` channel, `bootc switch --transport containers-storage`) | **SUPPORTED WITH LIMITATIONS** | yes | **only with a rebuild**: plain `bootc upgrade --check` → "No changes"; after `podman build --pull=always` (107 s) + `bootc upgrade` (25 s) it followed r3 → r4 | yes (after rebuild) | yes (previous local image restored) | **yes** | yes | **full** (RPMs, `/usr`, anything) | deployed as `ostree-unverified-image` (no signature); ~6.25 GB duplicate podman storage | expert-level unless Eldora wraps it | documented bootc local-build workflow |
| rpm-ostree layering on the OCI deployment (M2b) | **SUPPORTED WITH LIMITATIONS** (for the rpm-ostree client); **INCOMPATIBLE** with the bootc client | yes | **yes** via `rpm-ostree upgrade` (followed r4 → r5 with `strace` still layered, 62 s) | yes | yes | no | yes | full for RPMs | signature policy **enforced** (unsigned channel image rejected: "A signature was required, but no signature exists"); `bootc upgrade` blocked; `bootc switch` silently discards layering | familiar (Atomic desktops) | rpm-ostree docs; bootc states future rpm-ostree incompatibility (RES-0003) |
| `systemd-sysext` | **WORKAROUND** (upstream: not supported on bootc) | merge persisted via `systemd-sysext.service` | independent of image | **not established** (see correction below) | not tested | no | no (merge at runtime) | `/usr` and `/opt` overlay | unsupported by bootc upstream (overlay depth, composefs) | not recommendable | bootc: "not currently supported on bootc-managed systems" |
| Toolbx / containers | **SUPPORTED** (for workloads that need not modify the host) | yes | independent | yes (F44 toolbox kept working on F45 host with `--container`) | yes | no | no | none on host by design | **enforced system trust policy blocks the toolbox image** until the registry is explicitly allowed (one policy change) | good for development | Fedora Atomic docs (RES-0003) |
| `usroverlay` / `dnf --transient` | WORKAROUND (diagnostics only) | no | — | no | — | no | lost on reboot | temporary | — | diagnostics only | bootc / dnf5 docs (RES-0004) |
| systemd portable services | NOT APPLICABLE (not tested; services only, not general extension) | — | — | — | — | — | — | — | — | — | systemd docs (RES-0003) |

**Correction (important):** the first silent loss of a staged update in
this laboratory happened while a sysext was active and was initially
attributed to sysext. Later controlled trials (see "UEFI `/boot` finding")
showed the cause is the `/boot` automount interaction, reproduced with no
sysext present. Sysext was therefore **not shown** to break updates; its
status remains "not supported" upstream and untested across an update.

**Exact limits of `/usr/local` + `/etc` service** (the mechanism that
passed the advanced-user scenario):

- Meets: standalone executables and scripts; local systemd services and
  timers that use them; configuration via `/etc` drop-ins; tools that do
  not need to install into `/usr`.
- Does not meet: RPM-packaged software with dependencies installed into
  `/usr`; shared libraries in system library paths; kernel modules and
  initramfs content; SELinux policy modules; D-Bus/polkit/udev integration
  files that must live in `/usr`; anything expected to be updated by the
  system package manager; verification/provenance of the installed
  content. Those needs require the local derived image (with rebuild cost
  and unverified deployment) or M2b (bootc-incompatible).
- It is available only where the base image maps `/usr/local` to `/var`
  (true for the Atomic desktop base; **not** for `fedora-bootc`, where it
  is read-only — RES-0004).

## Desktop + advanced-user scenario

Desktop working → user needs a tool and a service → tool via the local
derived image (`htop`) and via `/usr/local` (`labtool`), service via
`/etc/systemd/system/labtool.service` → upstream publishes r4 → rebuild +
`bootc upgrade` + reboot → all functional on r4 → rollback → all functional
on r3 (predictable: image content follows the deployment; `/usr/local`,
`/etc` and `/var` persist). **PASS as evidence**, not as a universal
conclusion: it required a manual rebuild step to follow upstream, and the
tool is only as trustworthy as the unverified local image.

## E3 — UEFI, Secure Boot and bootloader

| Item | Result |
|---|---|
| UEFI | **UEFI TESTED** |
| Secure Boot | **SECURE BOOT TESTED** — `SecureBoot enabled`; kernel log "Kernel is locked down from EFI Secure Boot mode" |
| Kernel lockdown | `integrity` (observed on every boot) |
| `bootloader-update.service` under UEFI | SUCCESS (it failed under BIOS in RES-0004) |
| Kernel change (E4) | 7.2.7-200.fc44 → 7.2.7-300.fc45: booted under Secure Boot; both kernels present in BLS entries |
| Boot chain update (E4) | bootupd reported EFI update available (grub2 2.12-77, shim 16.1-7) and the next check showed "At latest version" — **EFI shim/grub updated under Secure Boot and the system kept booting** |
| Bootloader on rollback | **not rolled back**: bootupd reports "Ignoring downgrade"; Fedora 44 booted with Fedora 45's shim/grub on the ESP |
| Install for UEFI | requires `--generic-image` when the disk is written by a different (BIOS) machine (Deviation 1) |

## UEFI `/boot` finding (material)

- **Observation:** on the UEFI install, `systemd-gpt-auto-generator`
  created `boot.automount` (`/run/systemd/generator.late/boot.automount`);
  there was no `/etc/fstab` entry. When `/boot` had **not** been accessed
  during a session, `ostree-finalize-staged.service` failed at shutdown with
  **"error: Remounting /boot read-write: Invalid argument"**; the staged
  deployment was **silently discarded**; **no failure stamp** was written
  (`/boot/ostree-finalize-staged.failed` absent); `ostree-boot-complete`
  was skipped; **no user-visible signal**.
- **Reproduction:** deterministic. Trial A (`/boot` accessed before
  reboot) → finalized. Trial B (automount stopped, `/boot` not mounted) →
  failed as above. Observed 3 times in total, including once while a
  sysext was active.
- **Mitigation:** kernel argument `systemd.gpt_auto=0` removed the
  automount and the staged change finalized with `/boot` untouched; the
  argument carried over to later deployments including Fedora 45.
  Classified as **LAB-VALIDATED MITIGATION**, not an Eldora architectural
  solution.
- **Documentation:** `systemd-gpt-auto-generator(8)` states that on EFI
  systems it creates automount units and mounts the ESP/XBOOTLDR at
  `/boot/`, unless `/boot` is configured in fstab or the directory already
  contains files, and that `systemd.gpt_auto=0` disables it. The bootc book
  mentions the generator only for root discovery; OSTree deployment docs do
  not address it.
- **Classification: C — possible upstream integration defect** between the
  GPT auto-generator and OSTree/bootc deployments installed without fstab
  entries on UEFI, **with an install-method component (A)** (installers
  that write an fstab `/boot` entry would likely avoid it — UNVERIFIED).
  Whether it is already known upstream (B) was not checked (no issue
  trackers consulted).

## E4 — Fedora 44 → Fedora 45

### M3 (bootc desktop)

| Stage | Result |
|---|---|
| **BUILD** | **SUCCESS** — `eldora-desk:45-v2`: **zero changes** to lab artefacts except the base reference; build 176 s; push 193 s; lab RPM unchanged; fixed IDs unchanged |
| **DEPLOYMENT** | **SUCCESS** — staging: 8 layers reused, **62 new layers / ~2.4 GB**, 186 s ("Deploying…done (12 seconds)"); finalized at shutdown ("Copying /etc changes: 22 modified, 1 removed, 61 added") |
| **BOOT** | **SUCCESS** — Fedora Linux 45.20260925.n.0, kernel 7.2.7-300.fc45, Secure Boot enabled, lockdown integrity |
| **DESKTOP** | **SUCCESS** — GNOME 51 RC Wayland session, NetworkManager, PipeWire, portal, user setting and data intact; GNOME Software showed the OS-update notification |

Other M3 observations: `/etc` local items (gdm autologin, trust policy,
local unit, registry config) kept by the merge; `/var` state kept; UIDs
unchanged (850; remapped 958; local 1500); `/usr/local` tool and service
worked ("labtool ok on rev=45"); the local karg carried over; Toolbx:
existing F44 toolbox works with `--container fedora-toolbox-44`
(`toolbox run` without it looks for a version-matched container); podman
5.8.7 → 6.1.1; journal: `dracut-crypt-generator` exit 2 and tmpfiles
"… already exists and is not a directory" for `/home`, `/root`, `/srv`
(no functional effect observed); a transient `bootupd.service` failure was
caused by the lab collector racing `bootloader-update.service`. Rollback
to 44 worked (GNOME 50 with the user profile previously used by GNOME 51 —
no breakage observed in the checks); roll-forward to 45 worked. Reboots:
1 per transition. Disk: `/sysroot` 15 GB → 19 GB used after staging 45.

### M1 (package-based host)

| Item | Result |
|---|---|
| Initial | Fedora 44 Cloud, kernel 6.19.10, btrfs root, 481 packages; lab RPM v2 (signed, fixed IDs created at install) |
| Preparation | full `dnf --refresh upgrade` (Fedora guidance): 215 MiB, 114 s |
| Upgrade | `dnf system-upgrade download --releasever=45`: 13 installs, 471 upgrades (483 replacements), **6 downgrades** (F44 updates newer than F45 prerelease builds), no conflicts, **352 MiB**, 41 s; `dnf offline reboot` |
| Duration / reboots | ~2 min 20 s from reboot request to SSH on Fedora 45; **2 reboots** (into the offline environment and back) |
| Final | Fedora Linux 45 (Cloud Edition Prerelease), kernel 7.2.7-300.fc45, systemd 262, podman 6.1.1; 498 packages; three kernels retained |
| Lab RPM / config | `eldora-lab-config-2-1` (noarch) **unchanged, no rebuild**; local edits and drop-in unchanged; **no `.rpmnew`/`.rpmsave`** |
| IDs / state | 850/851/852 unchanged; `/var` state and `/home` data intact |
| Services | registry workload, lab service, sshd active; registry catalog intact |
| Rollback | **no system rollback**: btrfs subvolumes without snapshots, no snapper; returning to 44 means restore/reinstall |
| Trust detail | audit record showed `key_enforce=0` during the upgrade transaction (F44-era RPM config ran it) |

### Direct comparison (major-version transition)

| Aspect | M3 | M1 |
|---|---|---|
| Artefact maintenance (lab) | change base reference only | none |
| Eldora maintainer work | rebuild and publish image (176 + 193 s here), sign, test | publish RPMs only if changed; nothing here |
| User/admin work | stage + 1 reboot (could be automated) | full update, download, offline reboot (2 reboots) |
| Dependency handling | at build time, off-client | on each client (6 downgrades from prerelease here) |
| Download | ~2.4 GB image layers | 215 + 352 MiB packages |
| Infrastructure | registry, image signing, build capacity | RPM repo/signing (Fedora mirrors carry the rest) |
| Interventions | 1 command + reboot | 3 commands + reboot |
| Configuration handling | 3-way `/etc` merge (22/1/61) | RPM `%config`; no `.rpmnew` here |
| Failure surface | build-time + finalize-time (see `/boot` finding) | on-client transaction (offline) |
| Rollback | deployment rollback to 44 worked (OS side; bootloader not) | none (restore/reinstall) |
| Observed time | ~6 min staging (network-bound) + reboot | ~2.5 min download + ~2.5 min apply |

## E5 — Stable UID/GID with sysusers

- **Fixed IDs remove between-build drift:** `eldoralab` stayed 850 in the
  image and on the machine across v1 → v2 → rollback → roll-forward → 45
  (RES-0004 had 976 → 975 with dynamic IDs). `/var` ownership stayed 850.
  **SUPPORTED** for preventing normal between-build drift.
- **Local collision is unresolved:** with a local user already holding UID
  851, sysusers logged "Suggested user ID 851 for eldoralab2 already used"
  and **silently created `eldoralab2` with UID/GID 958** (image says 851);
  a local group named `eldoralabextra` kept GID 1500 (image 852). Visible
  only in the journal. **LOCAL COLLISION: still unresolved as a policy
  problem.**
- Fresh install (M1 install of v2, image build) produced the fixed IDs;
  upgraded installs keep existing local IDs.

## Trust findings (inherited and new)

RES-0004 conclusions stand (RISK-0007/0008/0009). New in this stage:
`rpm-ostree upgrade` on an OCI origin enforces `containers-policy.json`
signatures despite the `ostree-unverified-registry:` name; an enforced
system policy **also blocks unrelated user container images** (Toolbx)
until explicitly allowed; locally built images remain unverified; the lab
Containerfile's explicit `rpm -K` step verified the lab RPM while dnf still
printed "skipped OpenPGP checks … @commandline".

## Documentation vs observed behaviour

| # | Documentation | Observed |
|---|---|---|
| DV1 | Fedora bootc: auto-updates on by default | `bootc-fetch-apply-updates.timer` disabled on the Silverblue-derived install (also in RES-0004) |
| DV2 | bootc: sysext/confext not supported | merge worked at runtime; behaviour across updates not established |
| DV3 | GPT auto-generator creates `/boot` automount on EFI without fstab | as documented; its interaction with OSTree finalization silently drops staged updates |
| DV4 | — | bootloader not rolled back ("Ignoring downgrade") |
| DV5 | — | UEFI boot of a disk written from a BIOS machine needs `--generic-image` |
| DV6 | — | `toolbox run` expects a version-matched container after a major upgrade |

## Metrics (summary)

Interventions, rebuilds, reboots and times are in the tables above.
Additional: local derived image rebuild 107 s + upgrade 25 s, 160 MB
changed layers per revision, ~6.25 GB duplicate storage; M2b layering
53 s install, 62 s upgrade; desktop image size 5.9 GB base; `/sysroot`
usage 14–19 GB during tests. No aggregate score is computed.

## Failure modes observed

1. Silent discard of staged updates on UEFI (`/boot` automount) — no
   stamp, no user signal.
2. UEFI no-boot when installed from a BIOS builder without
   `--generic-image`.
3. Bootloader not rolled back with the OS.
4. Silent UID remapping on local collision.
5. Local derived image does not follow upstream without a rebuild;
   unverified deployment.
6. Enforced trust policy blocks Toolbx until explicitly allowed.
7. `bootc upgrade` blocked by rpm-ostree layering; `bootc switch` silently
   drops layering.
8. M1: no system rollback after a major upgrade.

## Evidence against M3

Failure modes 1–7; ~2.4 GB per major transition; image build, registry and
signing infrastructure; persistent host extension is either limited
(`/usr/local`), expert-level and unverified (local image), or
bootc-incompatible (M2b); prerelease-only evidence for Fedora 45.

## Evidence against M1

No system rollback (failure mode 8); dependency resolution on every client
(downgrades observed with prerelease); two reboots and three commands per
major upgrade; configuration drift and orphan behaviour from RES-0004
persist; F45 signature enforcement not active during the upgrade itself.

## Attempt to falsify the leading recommendation

The question: is any observed behaviour disqualifying for M3?

1. **Silent loss of staged updates (UEFI `/boot`).** The most serious
   finding: silent, deterministic, unsignalled. But it is configuration-
   and install-method-dependent, has a lab-validated mitigation, and is
   owned by the image/installer design (0.1D). **Serious, not
   disqualifying** — but it must be treated as a release blocker for any
   M3 design.
2. **Escape hatch.** No mechanism offers full host extension that is
   verified, follows upstream automatically and keeps bootc compatibility.
   Power users must choose between `/usr/local` (limited), a local image
   (rebuild + unverified) or M2b (bootc-incompatible). **Conditional, not
   disqualifying**: Eldora would have to provide a supported workflow.
3. **Bootloader not rolled back.** OS rollback does not cover the boot
   chain; a bad shim/grub update would not be undone by rollback.
   **Conditional (0.1C/0.1D).**
4. **Major-version cost.** M3 needed no artefact changes and rolled back
   cleanly; M1 needed no artefact changes but cannot roll back. **Does not
   falsify M3.**
5. **Desktop viability.** Full desktop, updates, rollbacks and a major
   upgrade worked under Secure Boot. **Does not falsify M3.**

Net: no observed behaviour makes M3 inadequate, but several make it
**conditional** on Eldora-owned engineering.

## Decision gate

- **Q19 — Is there sufficient evidence to promote M3 over M1?** **YES.**
  The remaining open items (UEFI `/boot` handling, bootloader rollback,
  update trust/freshness, UID collision policy, supported power-user
  workflow) are real but belong to 0.1C/0.1D or to Eldora's own design;
  none is a material gap that could realistically reverse M1 × M3, given
  M3's demonstrated desktop, rollback and major-upgrade behaviour and M1's
  lack of system rollback. **This is a research recommendation: the
  composition model remains NOT DECIDED and bootc NOT SELECTED until the
  Project Owner decides.**
- **Q19-A — Simple by default:** **SUPPORTED WITH CONDITIONS** — atomic
  updates, clean rollback and major upgrades worked; conditions: the
  `/boot` finding resolved in the image/installer design; update
  notification/UX retained (GNOME Software notified); stable-ID policy;
  trust policy that does not break default tooling.
- **Q19-B — Powerful when needed:** **SUPPORTED WITH CONDITIONS** —
  containers/Toolbx, `/usr/local` + `/etc` and local derived images exist;
  conditions: Eldora provides a supported, verifiable workflow for
  persistent host extensions that keeps following upstream (the local-image
  path needs automation and verification; M2b cannot be relied on).
- **Q19-C — Yours:** **SUPPORTED WITH CONDITIONS** — `/etc`, `/var`,
  `/home` and `/usr/local` remain the user's across updates, rollbacks and
  a major upgrade; conditions: no silent detachment from updates, no silent
  ID remapping or update loss (transparency of drift and failures).

## Recommendation

A recommendation is not a decision.

- **RECOMMENDATION:** present **M3 (Fedora-derived bootc/OCI image)** to
  the Project Owner as the recommended V1 composition model, with **M1 as
  the documented fallback**, and M2/M2b as references only.
- Conditions to carry into decisions and later waves: resolve the UEFI
  `/boot` staged-update loss in the image/installer design (0.1D) and treat
  it as a release blocker; define boot-chain rollback behaviour (0.1C);
  enforce signed updates with a freshness strategy and a trust policy that
  accommodates developer tooling (0.1C/0.1D); define a UID/GID allocation
  and collision policy (later wave); design a supported power-user
  extension workflow (later wave, 0.3/0.4 interaction).
- **Confidence: MEDIUM** — strong laboratory evidence for desktop,
  rollback and major-upgrade behaviour; limited by a single lab run, a
  Fedora 45 prerelease, virtual hardware only (RISK-0002 untouched), and a
  small lab component set.

## Risk impacts

- **RISK-0001 (cadence/rebase):** **REDUCES** — a major-version rebase
  required no lab artefact changes in either model; M3 needed one rebuild
  (~6 min end to end) and one reboot and could roll back. It does not
  measure porting cost of real Eldora components (shell, native code,
  kmods), so the risk is reduced, not closed.
- **RISK-0003 (bootc desktop maturity):** **REDUCES** — a real Fedora
  desktop worked through updates, rollbacks and a major upgrade under
  Secure Boot, with GNOME Software surfacing the OS update; offset by the
  `/boot` finding.
- **RISK-0005 (drift, users/groups):** fixed IDs resolve between-build
  drift; local collision remains (silent remap) — unchanged in status,
  sharpened in scope.
- **RISK-0006 (escape hatch):** **partially mitigated** — viable mechanisms
  exist, but no single supported, verified, upstream-following mechanism.
- **RISK-0007 (trust defaults):** unchanged; new interaction: enforced
  policy blocks developer tooling.
- **RISK-0008/0009:** unchanged.
- No risk status changed.

### Candidate new risks (recommended; no RISK-ID created)

| Candidate | Description | Evidence |
|---|---|---|
| RC-F | Staged OS updates silently discarded on UEFI installs when `/boot` is served by a GPT auto-generator automount (no stamp, no user signal). | UEFI `/boot` finding |
| RC-G | OS rollback does not roll back the boot chain (shim/grub), so a faulty bootloader update is not covered by rollback. | E3 ("Ignoring downgrade") |

## Forwarded to Wave 0.1C

Boot-chain rollback behaviour (RC-G); detection and user signalling of
failed finalization (RC-F); automatic update default (DV1); update trust
policy vs developer tooling; freshness (RISK-0008); schema compatibility
after rollback (inherited).

## Forwarded to Wave 0.1D

Installer/image configuration for UEFI (`--generic-image`, fstab `/boot`
or `systemd.gpt_auto`), treating RC-F as a release blocker; bootloader
update policy; build-input verification (RISK-0009); signing and channel
strategy; update size (~2.4 GB per major for a desktop image; ~160 MB per
small revision).

## Decisions that should wait for later waves

Desktop environment (0.2); application model and power-user extension
product design (0.3/0.4); UID/GID allocation policy (with 0.4 services);
repository strategy (0.5).

## Confidence and limitations

- Virtual hardware only; no physical hardware, no NVIDIA/firmware
  variation (RISK-0002 not addressed).
- Fedora 45 was a prerelease nightly (`45.20260925.n.0`).
- Single run of each scenario; timings depend on the host and on memory
  constraints that forced sequential execution.
- M1 E4 used a server-class workload, not a desktop.
- Lab harness changes (sshd; revision marker) and weaker trust entries are
  recorded above.

## Network actions

Host → `dl.fedoraproject.org` (Fedora Cloud 44 CHECKSUM and image) and
`fedoraproject.org/fedora.gpg`; host → public documentation pages
(freedesktop.org, bootc.dev, ostreedev) read-only; VMs → Fedora mirrors;
VM-A → `quay.io/fedora/fedora-silverblue:44` and `:45`; VM-D →
`registry.fedoraproject.org/fedora-toolbox:44`; VM-D → lab registry via
loopback forward. No GitHub operations, uploads, publication or cloud
resources.

## Decision

NOT TAKEN — composition model (Q-0001) and update/rollback model (Q-0008)
remain undecided pending Project Owner review.

## Sources

Primary evidence: laboratory outputs described above (local experimental
evidence with environment, steps and outputs recorded). Documentary:
`systemd-gpt-auto-generator(8)` —
https://www.freedesktop.org/software/systemd/man/latest/systemd-gpt-auto-generator.html
(systemd, accessed 2026-09-26, tier 1); bootc book —
https://bootc.dev/bootc/print.html (bootc project, accessed 2026-09-26,
tier 1); OSTree deployments —
https://ostreedev.github.io/ostree/deployment/ (OSTree, accessed
2026-09-26, tier 1); base images: `quay.io/fedora/fedora-silverblue:44`
and `:45` (Fedora, pulled 2026-09-26, tier 1); Fedora Cloud Base Generic
44-1.7 (Fedora, tier 1). Earlier sources: RES-0001 to RES-0004.
