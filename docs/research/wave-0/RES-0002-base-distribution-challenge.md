# RES-0002 — Base Distribution Challenge: Fedora × Ubuntu × Debian (Wave 0.1X)

| Field | Value |
|---|---|
| ID | RES-0002 |
| Status | REVIEWED |
| Wave | 0.1X — Base Distribution Challenge (extraordinary investigation between 0.1A and 0.1B, directed by the Project Owner on 2026-09-26) |
| Related questions | Q-0013 (review of OB-0004); Q-0001, Q-0008 (context) |
| Related Owner Baseline | OB-0004 — status for this research: **EXISTING OWNER BASELINE UNDER REVIEW** (the baseline itself is unchanged and ACTIVE) |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): planning, documentary web research through four delegated research sub-agents (Ubuntu; Debian; Fedora challenge criteria; derivative case studies and distribution-agnostic tooling), direct verbatim spot-checks, local read-only evidence, drafting. No human has reviewed this report yet. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; see [review record](../../project/reviews/WAVE-0.1A-0.1X-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (overall); per-claim and per-answer confidence stated below |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records (ADR, GDR, LDR, BDR)
> accepted by the Project Owner. Owner Baselines are changed only by the
> Project Owner. See `docs/research/README.md`,
> `docs/project/DECISION-LIFECYCLE.md` and `docs/project/OWNER-BASELINES.md`.

Labels: **FACT**, **HYPOTHESIS**, **REQUIREMENT**, **ALTERNATIVE**,
**INFERENCE**, **RECOMMENDATION**, **DECISION** (always NOT TAKEN).
`[Sn]` = Sources table; `[Ln]` = local evidence; `RES-0001/…` = facts in
[RES-0001](RES-0001-fedora-base-system-composition-models.md).

## Question

"If Eldora OS V1 were choosing its Linux family/base today without a prior
preference, would Fedora, Ubuntu or Debian offer the best foundation for
Eldora's specific goals?"

## Governance context

- OB-0004 ("Eldora OS V1 is Fedora-derived") is ACTIVE. For this research it
  is treated as **an existing Owner Baseline under review**, not as a
  conclusion to confirm. This report does not change it; only the Project
  Owner can (GOVERNANCE.md, OWNER-BASELINES.md).
- The Wave 0.1 roadmap scope lists "comparing Fedora against non-Fedora
  bases" as out of scope. This investigation exists because the Project
  Owner explicitly directed an extraordinary review of OB-0004 on
  2026-09-26; it is therefore recorded as a separate stage (0.1X), not as an
  expansion of Wave 0.1's scope. "0.1X" is not a general numbering pattern.
- RES-0001 remains valid as internal research on the Fedora ecosystem and
  was not modified.

## Scope

Fedora, Ubuntu and Debian ecosystems (including their image-based options),
evaluated against Eldora's product and architecture goals and the 40
criteria requested by the Project Owner; case studies of desktop platforms
built on these bases; one ALTERNATIVE DISCOVERED recorded without
expansion.

## Out of Scope

Comparison of other distributions beyond one discovered alternative;
desktop/toolkit selection (Wave 0.2); application model (Wave 0.3); platform
layers (Wave 0.4); executing probes (none were executed); legal advice;
any decision.

## Eldora goal profile used for evaluation

**REQUIREMENT (candidate)** — the following goals were stated by the
Project Owner in the 0.1X research request (2026-09-26). They are not yet
recorded in [V1-VISION](../../product/vision/V1-VISION.md) and are used
here as evaluation criteria only:

G1 own desktop platform on Linux; G2 visually and functionally distinct
from upstream; G3 Wayland-first if confirmed; G4 own shell/desktop
experience; G5 own applications; G6 own Platform APIs/System Services where
justified (hypothesis, Q-0004); G7 simple for end users; G8 secure; G9
hardware-friendly; G10 suitable for open-source development; G11
sustainable for a small initial team; G12 able to evolve to multiple
architectures; G13 own lifecycle and update channel; G14 reuse mature Linux
infrastructure without becoming a superficial customization.

## Method and limitations

- Documentary research on 2026-09-26 by four research sub-agents, each
  instructed to collect evidence **for and against** its subject with the
  same structure; followed by the author's verbatim spot-checks of the
  claims the conclusions depend on most (marked "(verified)").
- Local read-only evidence from the author's Fedora 44 workstation
  (cached package metadata only). No Ubuntu or Debian system was available
  locally; no VM, install, image build or large download was performed.
- No Git/GitHub remote operation was performed. Public github.com,
  gitlab.com and salsa pages were read as documents only (e.g., README
  pages); no API was called.
- Several sites (docs.fedoraproject.org, wiki.debian.org, packages.debian.org,
  some Canonical and Vanilla OS pages) served anti-bot or JavaScript-only
  pages; alternative clients or secondary corroboration were used, as noted
  per claim. Some quotations were extracted through a summarizing fetch
  tool; unverified quotations should be spot-checked before citation in a
  decision record.
- **Bias control:** RES-0001's investment in Fedora was not counted as an
  argument (sunk cost). The Fedora sub-agent was explicitly tasked to find
  evidence against Fedora. The author's workstation running Fedora is
  recorded only as a source of local package evidence, not as a preference.

## Local evidence

| ID | Command (read-only, cached metadata) | Result |
|---|---|---|
| L1 | `dnf5 repoquery -C --repo=fedora … kernel-core mesa-dri-drivers gnome-shell` | Fedora 44 release repository: kernel 6.19.10, Mesa 26.0.3, GNOME Shell 50.0. |
| L2 | `dnf5 repoquery -C --repo=updates --latest-limit=1 …` | Fedora 44 updates (cache 2026-09-24): kernel 7.2.6, Mesa 26.2.2, GNOME Shell 50.5 — i.e., kernel and Mesa rebased to new upstream series within the release; GNOME stays within its major version. |
| L3 | `cat /etc/os-release` | `SUPPORT_END=2027-05-19` for Fedora 44 (≈13 months after the April 2026 release). |

## Facts

### Fedora (A1)

- **FE1.** Fedora "provides updated packages … for approximately 13 months"
  (verified) [S1]; N-2 reaches EOL four weeks after N [S2]; actual support
  since F21: 322–420 days [S3]. No LTS exists [S1–S3; INFERENCE from
  absence].
- **FE2.** System upgrades are supported "over 2 releases at most" [S4].
- **FE3.** Fedora rebases the kernel within stable releases and does not use
  longterm kernels [S5, S6, S7]; Mesa also moves to new series within a
  release [L1, L2]; KDE SIG ships "at least two major (6.x.0) updates for
  Plasma … per Fedora release" [S9]; GNOME stays within its major version
  [L1, L2].
- **FE4.** Wayland-only: KDE Plasma X11 session dropped in F40 [S10]; GNOME
  X11 session removed in F43 [S11].
- **FE5.** NVIDIA's proprietary driver cannot be part of Fedora; F41 added
  installation from GNOME Software with local MOK self-signing for Secure
  Boot [S12]; drivers come from RPM Fusion (akmods; local signing key;
  legacy GPUs "best effort") via opt-in third-party repositories [S13–S15].
- **FE6.** Firmware is split per vendor (`linux-firmware` subpackages) [S17].
- **FE7.** x86_64 and AArch64 are primary; RISC-V/ppc64le/s390x
  "Alternative" [S18]; Asahi Remix (Apple Silicon) with platform packages
  upstream in Fedora [S23, S24]; Snapdragon X requires manual kernel
  arguments and firmware copying [S25]; RISC-V builders are community
  hardware "hosted in people's homes" [S26].
- **FE8.** Security bugs rely on Red Hat Product Security and package
  maintainers; the Security SIG "complements but does not replace Red Hat
  Product Security" [S27, S28]; "Security updates are subject to the same
  thresholds as other updates" in Bodhi [S7].
- **FE9.** Reproducibility tooling since F41; ~90% of builds reproducible;
  "builds are expected to be reproducible" mandate accepted for F46 [S29,
  S30, S32]; RPM signature enforcement by default in F45 [RES-0001/FA4].
- **FE10.** "The Fedora Project Leader is hired by Red Hat"; budget via Red
  Hat OSPO [S34]; Red Hat owns the Fedora trademarks [S35]; Pagure is being
  decommissioned (end of July 2026) during a forge migration [S37, S38].
- **FE11.** From RES-0001: Fedora offers package-based, rpm-ostree and
  bootc composition; bootc/OCI is the stated strategic direction but not yet
  production for desktops (RES-0001/FD7–FD8); derivatives may redistribute
  Fedora binaries after replacing `fedora-release`/`fedora-logos` with own
  packages (RES-0001/FF1–FF2).
- **FE12.** Bluefin (Fedora bootc derivative) gates Fedora kernels (~2 weeks
  behind) and created "Bluefin LTS", "built on CentOS Stream 10" for "a
  three-to-five year lifespan" [S20, S21].
- **FE13.** The F44 "Drop i686 support" proposal was withdrawn after
  community pushback [S39, S40].
- **FE14.** KDE Plasma was promoted to an Edition in F42 [S41]; Fedora
  Workstation has "a long history of developing and promoting the Wayland
  experience for GNOME" [S11].

### Ubuntu (A2)

- **FU1.** Ubuntu 26.04 LTS was released 2026-04-23; 26.10 final is
  scheduled for 2026-10-15; interim releases get 9 months [S50–S54].
- **FU2.** LTS: "5 years of standard security maintenance … for packages in
  the Main repository"; Universe security coverage is part of Ubuntu Pro
  (ESM), up to 10 years (15 with Legacy add-on); Pro is free for personal
  use on up to five machines [S55].
- **FU3.** Kernel policy: Ubuntu ships "the absolute latest available
  version of the upstream Linux kernel at the specified Ubuntu release
  freeze date, even if upstream is still in Release Candidate (RC) status"
  (verified) [S56]; LTS desktop installs track the rolling HWE stack
  [S58]; Mesa is updated in LTS (24.04-updates 25.2.8; 26.04-updates
  26.0.8) [S59].
- **FU4.** Since 25.10 the Ubuntu Desktop session runs only on Wayland; the
  26.04 notes state "Machines using Nvidia graphics now fully support
  Wayland" [S51, S54].
- **FU5.** `ubuntu-drivers` installs "pre-built, signed drivers, which are
  known to work with Secure Boot"; DKMS drivers "are not signed with
  Canonical's key" [S60, S61].
- **FU6.** Firefox, Thunderbird and Chromium debs are transitional packages
  installing snaps; `snapd` is a Recommends of `ubuntu-desktop-minimal`
  [S62, S63]; TPM-backed FDE "requires a specific kernel snap" [S51].
- **FU7.** The Dedicated Snap Store is "a paid product", Canonical-hosted
  [S64, S65]; brand stores require Canonical-managed brand accounts [S66].
  No primary source for a self-hostable open snap store was found
  (absence; corroborating tier-4 forum posts only [S67]).
- **FU8.** Ubuntu Core 26 was released May 2026 for IoT/embedded [S68]; no
  stable Ubuntu Core Desktop exists; a Canonical VP described it as "a five
  to ten-year thing" [S69, tier 3 interview]; its model depends on
  brand-signed model assertions and a dedicated store [S66, S70].
- **FU9.** Build tooling: livecd-rootfs ("used by Canonical to create both
  preinstalled images as well as installer images"), ubuntu-image,
  ubuntu-desktop-provision installer with `whitelabel.yaml`, autoinstall,
  Launchpad PPAs (source-upload only, Launchpad-generated keys) [S71–S75].
  Parts of the image documentation are marked draft [S71].
- **FU10.** Canonical IP Rights Policy (2015-07-15) (verified): "You can
  redistribute Ubuntu, but only where there has been no modification to
  it"; for modified versions "you must remove and replace the Trademarks
  and will need to recompile the source code to create your own binaries.
  This does not affect your rights under any open source licence";
  Canonical claims rights in "trade dress and look and feel" [S76, S77].
  The FSF stated the GPL's permission is not overridden but the clause
  "does not help works covered by lax permissive licenses"; the SFC wrote
  full permission "remains in question" [S78, S79].
- **FU11.** Identity files (`os-release`, `lsb-release`, `issue`) are in
  `base-files` [S80]; Livepatch, Landscape and ESM are Ubuntu Pro services
  [S55].
- **FU12.** Active USN/OVAL advisory feeds [S81, S82]; SBOMs published for
  Ubuntu Core [S83]; no official reproducible-builds status for Ubuntu was
  found (UNVERIFIED).
- **FU13.** Ubuntu's shim embeds Canonical's key; Canonical-built modules
  are signed with it [S84]. A derivative's own shim requires shim-review;
  since 2026-06-27 only the Microsoft UEFI CA 2023 signs new shims [S85].
- **FU14.** No official atomic classic desktop; APT gains
  `history-undo/rollback` in 26.04 [S51].
- **FU15.** Official generic ARM64 desktop ISO with initial Snapdragon X
  Elite enablement; RISC-V 26.04 requires RVA23 hardware that was not
  available as of April 2026 [S51].
- **FU16.** Governance: "This is not a democracy"; the SABDFL has a casting
  vote [S86]. Past reversals: Upstart (2014) and Unity 8/convergence (2017,
  "I was wrong on both counts") [S87, S88].
- **FU17.** Recent distribution-level defaults inherited by derivatives:
  sudo-rs, rust-coreutils (with GNU cp/mv/rm retained due to "unresolved
  bugs"), dracut, chrony [S51, S89].

### Debian (A3)

- **FD1.** Debian 13 "trixie" released 2025-08-09 after ~2 years; Debian 12
  2023-06-10 [S90, S91].
- **FD2.** (verified) "The Debian 13 life cycle encompasses five years: the
  initial three years of full Debian support, until August 9th, 2028, and
  two years of Long Term Support (LTS), until June 30th, 2030. The set of
  supported architectures is reduced during the LTS term." [S92]. Paid
  Extended LTS (Freexian) to 2035 for a customer-driven package subset
  [S93].
- **FD3.** Point releases follow a published calendar; forky (Debian 14)
  freeze dates are "TBA" [S94–S96].
- **FD4.** Testing "does not get security updates in a timely manner"
  [S97].
- **FD5.** Trixie ships Linux 6.12 LTS, GNOME 48, Plasma 6.3 [S90, S98];
  stable kernel 6.12.107 and Mesa 25.0.7 vs. trixie-backports kernel 7.1.8
  and Mesa 26.1.6 [S99]; backports are "provided on an as-is basis … Use
  with care!" [S100].
- **FD6.** Official media include non-free firmware since the 2022 GR
  [S101].
- **FD7.** GNOME uses Wayland by default, but GDM falls back to X11 with the
  proprietary NVIDIA driver [S102]; Debian wiki pages disagree on KDE's
  Wayland default (Conflict C2).
- **FD8.** Stable `nvidia-driver` 550 "does not support Blackwell" and
  "will not work with kernels 6.16 or newer like the current one from
  trixie-backports" [S103].
- **FD9.** Debian's shim embeds a Debian CA; DKMS modules are signed with a
  locally enrolled MOK key [S104].
- **FD10.** Trademark policy: derivatives cannot use Debian marks as product
  names or in branding logos, but may make "true factual statements"
  (e.g., based on Debian) with a non-affiliation disclaimer [S105].
- **FD11.** Derivatives Guidelines: must not be named Debian; overlay
  repository with only added/modified packages; keep Debian signatures on
  unmodified packages; own keyring package; version suffix for rebuilds;
  dpkg origins [S106]. More than 120 active derivatives are listed [S107].
- **FD12.** Tooling in the archive: live-build (official live images,
  amd64-only in trixie, Calamares + d-i), FAI (cloud images), mkosi,
  mmdebstrap, debos [S90, S108–S111]; trixie live ISOs are not fully
  reproducible (core squashfs is) [S112].
- **FD13.** No official atomic/image-based Debian desktop; `ostree` and
  `systemd-sysupdate` are packaged; `bootc` is not packaged [S113–S115].
- **FD14.** Active DSA stream and security tracker; documented limits for
  qtwebengine (unsupported), Chromium in oldstable, Go/Rust (point-release
  updates only) [S116–S118].
- **FD15.** Reproducible builds: trixie/amd64 96.9% in CI; the Release Team
  states "Debian must ship reproducible packages" with migration gating;
  APT verifies signatures with Sequoia `sqv` [S119, S96, S120].
- **FD16.** Debian is "an association of individuals"; assets and
  trademark held by SPI [S121, S105].
- **FD17.** Seven official architectures in trixie including arm64 and
  riscv64 (first time official); i386 no longer a regular architecture
  [S90].
- **FD18.** Only upgrades from the previous release are supported; non-Debian
  packages "may be removed during the upgrade" [S122].

### Case studies and distribution-agnostic tooling (X)

- **FX1. Endless OS** (Debian + OSTree) is re-basing Endless OS 7 on GNOME
  OS (verified): "About 95 percent of what we ship is GNOME OS"; "We learned
  the hard way that you can't out‑code the global open‑source community";
  "If your OS development cycle is measured in years, you're always
  behind … Now we can update every six months and keep pace." [S130, S131]
- **FX2. Vanilla OS** moved Ubuntu → Debian sid (2023), citing Ubuntu's
  modified GNOME, snap issues ("centralization"), and release-schedule
  independence (reported via tier-3 sources quoting its blog) [S132, S133];
  v2 (2024) uses OCI images + ABRoot; v3 (2026-08) still Debian sid with
  own repositories, more than two years after v2 [S134, S135].
- **FX3. KDE neon** (Ubuntu LTS) "has somewhat reached its limit"; its LTS
  base required "packaging busywork" and tinkering that broke "the LTS
  promise" [S136, S137]. KDE Linux uses Arch packages + mkosi +
  systemd-sysupdate; systemd 260 removed sysupdate from API stability
  guarantees and broke Discover updates (2026-03-31) [S137, S138].
- **FX4. elementary OS 8** is built from Ubuntu 24.04, released ~7 months
  after its base, Flatpak-first apps, Ubuntu HWE stack [S139, S140].
- **FX5. Pop!_OS 24.04** with COSMIC shipped 2025-12-11 (~20 months after
  its Ubuntu base), "entirely funded by System76 hardware sales"; System76
  patches and ships its own kernels and maintains NVIDIA and Mesa packaging
  [S141, S142, S143]. COSMIC also ships on Fedora [S144].
- **FX6. SteamOS 3** moved from Debian to Arch for "rolling updates …
  more rapid development"; A/B updates with contracted tooling work
  [S145, S146].
- **FX7. Bluefin** (Fedora bootc) states "bootc is the technology we all
  depend on" [S147]; its "Dakota" variant is built on GNOME OS with
  BuildStream and published as a bootc image [S148].
- **FX8. GNOME OS** is built with BuildStream on freedesktop-sdk, uses
  systemd-sysupdate with Secure Boot and FDE, and is still labelled
  pre-release [S149, S150, S151].
- **FX9.** mkosi supports Fedora, Debian, Ubuntu, Arch, openSUSE and others
  [S152]; official bootc base images exist for Fedora/CentOS/RHEL family;
  upstream issue "Demonstrate a debian or arch base image" has been open
  since 2024-11-01; community non-Fedora bootc images are experimental
  [S153, S154, S155].

## Hypotheses

- **H1.** For a platform that ships its own shell and services, the
  dominant long-term cost is divergence from the base, not the base's
  cadence alone (supported by FX1–FX3; INFERENCE).
- **H2.** Fedora's six-month cadence can be absorbed by a small team if the
  OS is built as a CI-produced image with kernel gating (FE12 precedent;
  unverified for Eldora).
- **H3.** Ubuntu's snap/IPR constraints can be fully removed in a
  derivative without legal or functional regressions (unverified;
  FU6, FU10).
- **H4.** Debian stable plus Eldora-owned kernel/Mesa/driver enablement is
  sustainable for a small team (contradicted by FX1; partially supported by
  Endless 6 history and Apertis policy).

## Alternatives

| ID | Alternative | Notes |
|---|---|---|
| A1 | Fedora ecosystem | Package-based, rpm-ostree or bootc derivation (RES-0001). |
| A2 | Ubuntu ecosystem | Classic Ubuntu Desktop/LTS derivation (Ubuntu Core Desktop assessed separately below). |
| A3 | Debian ecosystem | Debian stable (optionally with backports or own enablement), or testing/sid (Vanilla OS pattern). |
| A4 | **ALTERNATIVE DISCOVERED:** GNOME OS / freedesktop-sdk (BuildStream) as a reference-OS base | Appeared inevitably: adopted by Endless OS 7 and Bluefin Dakota (FX1, FX7, FX8). Recorded, not compared in depth. Also observed but not expanded: Arch + mkosi + sysupdate (KDE Linux, FX3) and CentOS Stream as a longer-lived Red Hat-family base (FE12). |

**Ubuntu Core Desktop assessment:** unsuitable for Eldora V1 — not released,
multi-year horizon, and a third-party brand would depend on a paid,
Canonical-hosted store and Canonical-registered kernel/gadget snaps (FU7,
FU8). This is a strong, primary-source-backed exclusion.

## Comparison (40 criteria)

Qualitative ratings: `+` favourable, `~` mixed/conditional, `−`
unfavourable, `?` unknown. Each cell cites its basis. No numeric scores.
"Stable" means the base's stable/LTS release unless stated.

| # | Criterion | Fedora (A1) | Ubuntu (A2) | Debian (A3) |
|---|---|---|---|---|
| 1 | Wayland / modern desktop readiness | + Wayland-only GNOME and KDE (FE4) | + Wayland-only session; NVIDIA Wayland supported in 26.04 (FU4) | ~ Wayland default, but X11 fallback with proprietary NVIDIA (FD7) |
| 2 | Graphics stack freshness | + Mesa rebased within release (L1–L2) | + Mesa updated in LTS (FU3) | − Stable Mesa frozen (25.0.7); newer only via as-is backports (FD5) |
| 3 | Recent hardware enablement | + Kernel/Mesa/firmware current (FE3, FE6) | + HWE rolling; Snapdragon ISO (FU3, FU15) | − Eldora must own it or rely on backports (FD5; FX1 evidence of cost) |
| 4 | Kernel cadence | + Rebased in-release (FE3) | + Latest at freeze, HWE in LTS (FU3) | ~ LTS kernel 6.12 for stable life; backports 7.1 (FD5) |
| 5 | Mesa cadence | + (L1–L2) | + (FU3) | − (FD5) |
| 6 | Desktop stack cadence | + ~6-month GNOME; Plasma majors in-release (FE3) | ~ Interim 6-month; LTS every 2 years (FU1) | − ~2-year cadence (FD1) |
| 7 | Stability | ~ In-release rebases can regress; derivatives gate kernels (FE3, FE12) | ~ RC-kernel-at-freeze policy; LTS point releases (FU3) | + Conservative stable (FD1, FD5) |
| 8 | Security maintenance | ~ No dedicated distro team; same Bodhi thresholds for security (FE8) | ~ Strong USN process, but free coverage Main-only; Universe needs Pro (FU2, FU12) | + Dedicated team, DSA stream, LTS; documented exceptions (FD2, FD14) |
| 9 | Release lifecycle | − ~13 months, no LTS (FE1) | + 5-year LTS for Main (FU2) | + 5 years (3+2 LTS), paid ELTS to 2035 (FD2) |
| 10 | Upgrade complexity | ~ Upgrade at least yearly; N→N+2 supported (FE2) | + LTS→LTS every 2 years (FU1) | ~ Every ~2 years; non-Debian packages may be removed (FD18) |
| 11 | Ability to control Eldora release lifecycle | ~ Bound to ~yearly rebases (FE1) | ~ Bound to LTS cadence; Pro-only extended coverage not redistributable (FU2, FU11) | + Long base life gives freedom, if Eldora owns enablement (FD2) |
| 12 | Atomic/image-based options | + rpm-ostree and bootc official; bootc desktop not yet production (FE11) | − Only Ubuntu Core (not desktop-ready) (FU8, FU14) | ~ No official; ostree/sysupdate packaged; derivatives prove it (FD13, FX1–FX2) |
| 13 | Rollback possibilities | + Via image models (FE11) | ~ APT history rollback only (FU14) | ~ Only via Eldora-built image system (FD13) |
| 14 | Reproducibility | + ~90%, mandate F46 (FE9) | ? No official status found (FU12) | + 96.9% CI; migration gating (FD15) |
| 15 | Image generation | + Kiwi, image-builder, bootc tooling (FE11) | + livecd-rootfs, ubuntu-image (docs partly draft) (FU9) | + live-build, FAI, mkosi, debos (FD12) |
| 16 | Installer flexibility | ~ Anaconda (WebUI), bootc kickstart limits (RES-0001/FD6) | + desktop-provision whitelabel, autoinstall (FU9) | + d-i and Calamares (FD12) |
| 17 | Custom repositories | + Own signed RPM repo (RES-0001/FF3) | ~ Own apt repo; PPAs are Launchpad-hosted, Launchpad-keyed (FU9) | + Documented overlay-repo model (FD11) |
| 18 | Package ownership | + Replace release/logos packages; reuse binaries (FE11) | − Modified redistribution requires trademark removal and recompilation per IPR (FU10) | + Keep Debian signatures on unmodified packages (FD11) |
| 19 | System update ownership | + Own registry/OSTree/repo (FE11) | ~ Own apt repo; snaps tied to Canonical store (FU6, FU7) | + Own repo or own image channel (FD11, FD13) |
| 20 | Application distribution freedom | + No store lock-in; Flatpak common (RES-0001) | − Core apps via snaps from Canonical store unless replaced (FU6, FU7) | + No store lock-in (FD11) |
| 21 | Avoid upstream-specific lock-in | ~ bootc most mature on Red Hat family (FX9) | − Snap, Launchpad, IPR (FU7, FU9, FU10) | + Standard tooling; mkosi/ostree/sysupdate portable (FD12, FX9) |
| 22 | Branding/derivative requirements | ~ Replace marks; "Remix" rules; "based on Fedora" wording unclear (RES-0001/FF1) | − Remove marks, recompile, trade dress claims (FU10) | + Factual "based on Debian" permitted with disclaimer (FD10) |
| 23 | Secure Boot implications | ~ Reuse Fedora chain unchanged; own kernel needs own shim (RES-0001/FF5) | ~ Reuse Canonical chain; recompiled kernel loses Canonical signature (FU13) | ~ Reuse Debian chain; own kernel needs own shim (FD9) |
| 24 | Third-party driver implications | ~ akmods + MOK (FE5) | + Signed prebuilt modules (FU5) | − DKMS + MOK; old driver branch (FD8, FD9) |
| 25 | NVIDIA implications | ~ Outside Fedora; GUI install with MOK (FE5) | + Best of the three (FU4, FU5) | − No Blackwell in stable driver; backports-kernel incompatibility (FD8) |
| 26 | Firmware availability | + Split packages (FE6) | + (INFERENCE; not specifically researched) | + Non-free-firmware on media (FD6) |
| 27 | ARM64 viability | + Primary arch; Asahi; Snapdragon manual (FE7) | + Official ARM64 ISO incl. Snapdragon (FU15) | ~ Official arm64; live images amd64-only (FD12, FD17) |
| 28 | Virtualization/dev environment | + (INFERENCE: all three well-supported as VM guests; not a differentiator) | + | + |
| 29 | CI suitability | + OCI/bootc builds in any CI (RES-0001) | ~ Tooling oriented to Launchpad/Canonical infra (FU9) | + mkosi/debos/live-build run anywhere (FD12) |
| 30 | Debugging/developer experience | + Upstream-near versions (FE3) | ~ (not differentiated by evidence) | ~ Old stable versions vs. current upstream (FD5) |
| 31 | Supply-chain security | + Signature enforcement F45, reproducibility (FE9) | ~ Signed archive; Pro-gated coverage (FU2, FU12) | + Reproducibility gate, Sequoia sqv (FD15) |
| 32 | SBOM/provenance | ~ SPDX licences; no distro SBOM programme found (FE9) | ~ SBOM for Core only (FU12) | ? No SBOM programme found (FD15) |
| 33 | Upstream community model | ~ Community + Red Hat-sponsored councils (FE10) | − "Not a democracy" (FU16) | + Association of individuals, GR process (FD16) |
| 34 | Corporate dependency/control | ~ Red Hat hires FPL, owns trademark (FE10) | − Canonical controls store, trademarks, direction; reversals (FU7, FU16) | + No single corporate owner (FD16) |
| 35 | Sustainability for a small team | ~ Twice-yearly rebases vs. upstream-provided enablement (FE1, FE3) | ~ LTS helps; snap/IPR removal work (FU2, FU6, FU10) | − Eldora owns enablement (FD5, FD8; FX1) |
| 36 | Effort to become a distinct platform | ~ Low legal friction; strategic image tooling (FE11) | − Must unwind snap-centric defaults and IPR constraints (FU6, FU10; FX2) | ~ Clean legal path, but more integration work (FD11, FD5) |
| 37 | Long-term migration cost | ~ Portable Containerfile/RPM; bootc-specific (FX9) | − Snap-centric pieces non-portable (FU6) | + Standard packaging and tools (FD12) |
| 38 | Keep Linux-specific details behind Eldora boundaries | ~ Not differentiated by evidence; depends on Wave 0.4 (INFERENCE) | ~ | ~ |
| 39 | Risk of fighting upstream's intended architecture | + Fedora moving toward image-based derivation Eldora could use (RES-0001/FD7) | − Canonical's direction is snap-centric/Core; derivatives revert changes (FU6, FU8; FX2, FX3) | ~ Debian's intended use is stable classic; image-based is Eldora's own (FD13) |
| 40 | Suitability specifically for Eldora V1 | ~/+ Best fit to G3, G9, G13, G14; weakest on G11 lifecycle burden | ~/− Best NVIDIA/ARM64; weakest on G2, G13, G14 due to snap/IPR/control | ~ Best independence/lifecycle; weakest on G3, G9 without owned enablement |

## Gains and losses

**Fedora (Q3).** Gains: current kernel/Mesa/desktop without Eldora-owned
enablement; Wayland-only already done; official image-based paths
(bootc/rpm-ostree) aligned with Fedora's own direction; reproducibility and
signature enforcement; binary reuse with simple mark replacement; AArch64
primary. Losses: ~13-month lifecycle and no LTS (permanent rebase
treadmill); in-release kernel/Plasma rebases can regress; NVIDIA outside the
distribution; weaker formal security process; Red Hat dependency; bootc
desktop gaps (RES-0001).

**Ubuntu (Q4).** Gains: 5-year LTS for Main; best NVIDIA/Secure Boot
experience; Wayland on NVIDIA; official ARM64 Snapdragon image; mature
whitelabel installer; strong advisory infrastructure. Losses: IPR policy
requires recompilation for modified redistribution and claims trade dress;
snap-centric defaults tied to a Canonical-hosted store; free security
coverage limited to Main; no desktop image-based path; distribution-level
decisions made by Canonical; derivative precedents show time spent reverting
Canonical's choices (FX2, FX3) and long delays shipping on LTS (FX5).

**Debian (Q5).** Gains: independence and clear derivative rules; 5-year
lifecycle; strong security team and reproducibility; broad architectures;
standard, portable tooling; freedom to design the image system. Losses:
stable graphics/kernel lag unless Eldora owns enablement; NVIDIA gaps; no
official image-based path; testing/sid lack timely security; the strongest
Debian image-based derivative (Endless) is leaving Debian to reduce
maintenance cost (FX1).

## Evidence Against Fedora

1. Support is ~13 months with no LTS (FE1) — a structural, recurring
   rebase and user-upgrade burden for a small team.
2. A Fedora-based derivative (Bluefin) found it necessary to gate Fedora
   kernels and to create an LTS variant on CentOS Stream (FE12).
3. Kernel and Plasma move within stable releases (FE3), importing
   regression risk.
4. NVIDIA is outside Fedora; the user path requires MOK enrolment and local
   signing (FE5).
5. No dedicated distribution security team; security updates follow the
   same Bodhi thresholds (FE8).
6. Red Hat employs the FPL, funds the budget and owns the trademarks
   (FE10); infrastructure is mid-migration (FE10).
7. bootc desktop is not production-ready; Fedora's own initiative says
   production capacity has not been reached (RES-0001/FD7–FD8).
8. Snapdragon support needs manual workarounds; RISC-V far from primary
   (FE7).

## Evidence Against Ubuntu

1. IPR policy: modified redistribution requires trademark removal and
   recompilation; trade-dress claims; unresolved permission questions for
   permissive-licensed works (FU10) — verified primary text.
2. Snap is embedded in core desktop apps, App Center and TPM-FDE, and the
   store is Canonical-hosted; a brand store is paid (FU6, FU7).
3. Ubuntu Core Desktop is not available and is years away (FU8).
4. Free security coverage is limited to Main; Universe coverage is an
   Ubuntu Pro service that a derivative cannot pass on (FU2, FU11).
5. Canonical governance ("not a democracy") and a record of reversals
   (FU16); distribution-level defaults (rust-coreutils, sudo-rs) flow to
   derivatives (FU17).
6. Derivatives report cost in reverting Canonical choices (Vanilla OS) and
   packaging busywork on LTS (KDE neon); Pop!_OS shipped ~20 months after
   its base (FX2, FX3, FX5).
7. No image-based classic desktop path (FU14).

## Evidence Against Debian

1. Stable kernel/Mesa are frozen for the release life; newer stacks only
   through as-is backports (FD5).
2. NVIDIA: no Blackwell support in the stable driver; driver/kernel
   mismatch with backports; X11 fallback in GDM with proprietary driver
   (FD7, FD8).
3. No official image-based path and no bootc (FD13).
4. Testing/sid lack timely security support (FD4) — a fresher base shifts
   security work to Eldora.
5. Endless OS, the strongest Debian-based image-based platform precedent, is
   moving to GNOME OS to reduce maintenance cost (FX1) (verified).
6. Live images are amd64-only and not fully reproducible in trixie (FD12).
7. Release timing is less predictable (forky dates TBA) (FD3).

## Answers to the critical questions

**Q1 — Without OB-0004.** **RECOMMENDATION (preliminary):** Fedora.
Confidence MEDIUM that Fedora is at least as suitable as either alternative
for V1; LOW confidence that the margin is large. Basis: Fedora is the only
option that simultaneously provides current graphics/hardware enablement
from upstream (criteria 1–5), an officially supported image-based
derivation path aligned with the base's own direction (12, 13, 39), and a
low-friction derivative regime (18, 22) — the combination that matches G3,
G9, G13 and G14. Its main weakness (lifecycle, 9–11, 35) is real.

**Q2 — Structural or convenience?** Mostly structural: upstream proximity
(FE3, FE4, FE14), image-mode direction backed by the base itself
(RES-0001/FD7), and the binary-reuse/trademark regime (FE11) are properties
of the ecosystem, not of Eldora's head start. Convenience factors (RES-0001
already done; author's workstation runs Fedora) were deliberately
excluded. The lifecycle disadvantage is equally structural.

**Q3–Q5.** See "Gains and losses".

**Q6 — Least own infrastructure initially.** Fedora (package-based) and
Ubuntu classic are close; Ubuntu's signed NVIDIA path and LTS reduce early
work, but its IPR recompilation requirement for modified redistribution and
snap removal may add infrastructure (INFERENCE; legal scope UNVERIFIED).
Debian requires the most (own enablement for current hardware).

**Q7 — Greatest long-term platform control.** Debian (independence,
permissive derivative rules, long lifecycle, portable tooling) — conditional
on Eldora owning enablement and the image system. Fedora second (control of
own image and channel; Red Hat dependency). Ubuntu least (store, IPR,
governance).

**Q8 — Tension between Q6 and Q7?** Yes. The base that gives the most
long-term independence (Debian) is the one that makes Eldora own the most
integration early; the case evidence shows that this cost was decisive for
Endless (FX1).

**Q9 — Least lock-in.** Organizational: Debian (FD16). Technological:
Debian with distribution-agnostic tools (mkosi, ostree, sysupdate) (FX9);
Fedora's bootc path is currently Red Hat-family-centric (FX9); Ubuntu has
the most lock-in (snap store, Launchpad, IPR).

**Q10 — Best balance (hardware, stability, modern desktop, maintenance,
independence).** Fedora, with the lifecycle burden as the main trade-off.
Ubuntu balances hardware and stability well but scores worst on
independence. Debian balances stability and independence but not hardware
or modern desktop without owned work.

**Q11 — Fedora's short cadence.** A **structural cost** that is
**administrable** rather than disqualifying: evidence shows derivatives
manage it with CI-built images and kernel gating (FE12), and the case
studies suggest a six-month cadence can be an advantage for a fast-moving
shell (FX1, FX6). Unverified for Eldora; probe PX1 is designed to measure it.

**Q12 — Would Ubuntu LTS be significantly more sustainable without hurting
desktop evolution?** Not on current evidence. LTS gives longer base
support, but the precedents show tension between LTS bases and fast-moving
desktop stacks (FX3, FX5) and cost in unwinding Canonical defaults (FX2);
the IPR and snap constraints act directly against G2, G13 and G14.
Confidence MEDIUM.

**Q13 — Would Debian reduce organizational dependency at the cost of too
much integration?** Yes, likely: Debian offers the best independence, but
Eldora would own kernel/Mesa/NVIDIA enablement and the entire image-based
system (FD5, FD8, FD13); Endless OS is leaving Debian for exactly this
reason (FX1). Confidence MEDIUM.

**Q14 — Fourth alternative.** **ALTERNATIVE DISCOVERED:** GNOME OS /
freedesktop-sdk (BuildStream) as a reference-OS base (A4). It appeared in
two independent recent re-basings (Endless OS 7, Bluefin Dakota) and
directly embodies the "stay close to upstream" lesson. Caveats: pre-release
status (FX8); GNOME-centric, so a distinct Eldora shell may "fight" it;
BuildStream expertise concentration (tier 2–3 evidence). Not expanded
further, per the research brief. Also noted without expansion: Arch +
mkosi + sysupdate (KDE Linux) and CentOS Stream as a longer-lived
Red Hat-family base (FE12) — the latter raises the question of whether
OB-0004's "Fedora ecosystem" includes CentOS Stream (open question).

**Q15 — Evidence strength.** See "Assessment of OB-0004".

## Recommendation

A recommendation is not a decision.

- **RECOMMENDATION (preliminary):** among Fedora, Ubuntu and Debian,
  Fedora is the most suitable base for Eldora V1's stated goals. Confidence
  **MEDIUM**.
- Favourable evidence: criteria 1–5, 12–13, 18, 22, 31, 39 (see
  Comparison); FE3–FE4, FE9, FE11, FE14; FX7.
- Contrary evidence: Evidence Against Fedora (1–8); criteria 8–11, 24–25,
  33–35.
- Assumptions: G1–G14 reflect the Owner's intent; a small team; image-based
  delivery remains desirable (RES-0001 recommendation); Eldora does not need
  a multi-year frozen base for V1.
- Unknowns: see Unknowns.
- Reversibility: before significant implementation, changing base is cheap;
  each probe reduces the cost of being wrong. After release, a base change
  implies reinstall/rebase for users (INFERENCE).

## Attempt to falsify the recommendation

The following arguments were actively sought to show Fedora is a bad
choice. Outcome per argument:

1. **"The lifecycle treadmill will exhaust a small team."** Strongest
   argument. Evidence: FE1, FE12 (Bluefin needed CentOS LTS and kernel
   gating). Counter-evidence: Bluefin and Bazzite sustain Fedora-based
   images with small teams via CI (FX7; tier 1–4 mix); Endless moved *toward*
   a six-month cadence to reduce cost (FX1). **Result: not falsified, but
   unresolved** — this is the main risk and is testable (PX1).
2. **"Fedora's image-based advantage is future, not present."** True for
   bootc desktops (RES-0001/FD7–FD8). If image-based delivery is not
   available in time, Fedora's advantage over Ubuntu narrows to trademark,
   snap and governance factors, which still favour Fedora. **Result:
   weakens the margin, does not reverse the ranking.**
3. **"Ubuntu has materially better NVIDIA/Secure Boot and ARM64."** True
   (FU4, FU5, FU15). But these gains are offset by IPR/snap/control factors
   that bear directly on G2, G13, G14. If NVIDIA-heavy hardware were the
   dominant target market, this could flip the result. **Result: holds
   conditionally; probe PX3 required.**
4. **"Red Hat dependency is equivalent to Canonical dependency."** Partly
   true (FE10), but Fedora's derivative regime permits binary reuse with
   mark replacement and has no store lock-in, whereas Ubuntu's IPR and
   snap store create direct controls (FU7, FU10). **Result: not
   falsified.**
5. **"Debian's independence outweighs everything for a long-lived
   platform."** Plausible for later versions. For V1, FD5/FD8/FD13 and FX1
   show the integration burden. **Result: not falsified for V1;** relevant
   for post-V1 bases (OB-0004 is V1-only).
6. **"The discovered alternative (GNOME OS) beats all three."** It matches
   the upstream-proximity lesson best, but is pre-release and GNOME-centric
   (FX8). **Result: cannot be evaluated here; recorded for the Owner.**

Net: the recommendation survives with **MEDIUM** confidence; it is **not**
strong enough to be HIGH, chiefly because of argument 1 and argument 3.

## Assessment of OB-0004

**Assessment: CONFIRM (provisional).** OWNER BASELINE CHANGE is **not**
recommended.

- Not REOPEN: no alternative shows a structural advantage for Eldora's
  stated goals that outweighs its structural disadvantages; Ubuntu's
  advantages (NVIDIA, LTS, ARM64) are offset by IPR/snap/governance
  constraints; Debian's (independence, lifecycle) are offset by
  integration burden evidenced by Endless OS.
- Not blocking on MORE EVIDENCE: the remaining uncertainties (cadence cost,
  NVIDIA experience) are measurable by probes and would not change OB-0004
  unless results are strongly adverse.
- Conditions that would justify REOPEN: PX1 shows Fedora rebase effort
  unsustainable for the expected team size; PX3 shows the NVIDIA path is
  unacceptable for Eldora's target hardware while Ubuntu's is; or the Owner
  decides a multi-year frozen base is a V1 requirement.
- This assessment is a recommendation to the Project Owner. OB-0004 is
  unchanged. DECISION: NOT TAKEN.

## Proposed probes (NOT executed)

| ID | Hypothesis tested | Fedora procedure | Ubuntu procedure | Debian procedure | Metrics | Expected evidence | Approx. cost | VM/hardware | Risk |
|---|---|---|---|---|---|---|---|---|---|
| PX1 | Release-rebase cost is sustainable for a small team | Build a minimal branded Eldora image (bootc Containerfile or Kiwi) on F44; rebase to F45 | Branded image on 24.04 (livecd-rootfs or mkosi); rebase to 26.04 | Branded image on 12 (live-build or mkosi); rebase to 13 | Engineer-hours; number of breakages; patches carried | Quantified rebase effort per year | 3–5 engineer-days per base | VM | Low |
| PX2 | Out-of-box hardware enablement on current machines | Boot official live media | Boot official live media | Boot official live media (stable and with backports kernel) | Checklist: GPU accel, Wayland, suspend, Wi-Fi, audio, camera, fingerprint | Pass/fail matrix per machine | 1–2 days + hardware access | Physical hardware (3–4 reference machines incl. recent AMD, Intel, NVIDIA, ARM64) | Low (live media, no install) |
| PX3 | NVIDIA + Secure Boot user path is acceptable | GNOME Software/RPM Fusion install with MOK; kernel update | `ubuntu-drivers` signed modules; kernel update | nvidia-driver (stable and backports) with MOK; kernel update | Steps, reboots, prompts, Wayland session success, survival across kernel update | Friction score per base | 1–2 days | Physical NVIDIA hardware (Ada and Blackwell) | Medium (boot changes on test machine) |
| PX4 | Derivative identity is legally and technically clean | Replace release/logos packages; scan image for marks | Replace base-files/branding; list binaries needing recompilation per IPR; remove snapd | Replace base-files, dpkg origins, keyring | Residual marks; rebuilt-package count; legal questions list | Effort and legal-risk inventory | 2–3 days + legal review by a qualified human | VM | Low (legal review is not agent work) |
| PX5 | Atomic update and rollback feasible on each base | bootc upgrade/rollback | mkosi + systemd-sysupdate image | mkosi + sysupdate or OSTree image | Update size, time, rollback success, failure injection | Feasibility and effort per base | 3–5 days per base | VM | Medium (experimental tooling) |
| PX6 | Security response latency | Sample 10 recent high-severity desktop CVEs; days to stable fix via Bodhi | Same via USN | Same via DSA/security tracker | Median/max days to fix | Comparative latency | 1 day (documentary) | None | Low |
| PX7 | Desktop stack freshness for Eldora shell development | Build current upstream shell dependencies (e.g., current GTK/Qt/compositor libraries) on stable release | Same on 26.04 LTS | Same on trixie | Number of backports/bundled deps required | Maintenance-burden estimate | 2 days | VM or container | Low |
| PX8 | Snap removal on Ubuntu is clean | — | Remove snapd; replace Firefox/Thunderbird; test App Center, FDE, prompting | — | Broken features; replacement effort | Feasibility of snap-free Ubuntu base | 1 day | VM | Low |
| PX9 | ARM64 desktop viability | Workstation aarch64 image | Generic ARM64 ISO | arm64 install | Boot, GPU, suspend on ARM64 target | ARM64 readiness | 1–2 days | Physical ARM64 laptop or VM | Low |

## Risks

| ID | Risk | Evidence |
|---|---|---|
| RX1 | Fedora cadence overwhelms the team | FE1, FE12 |
| RX2 | Confirmation bias toward the existing baseline | Mitigated by method; residual risk remains — human review required |
| RX3 | Ubuntu IPR scope misread (legal question) | FU10; requires qualified legal review, not agent research |
| RX4 | NVIDIA-heavy target hardware would change the ranking | FU5, FE5, FD8 |
| RX5 | Divergence cost regardless of base | FX1–FX3 |
| RX6 | Image-based tooling instability (bootc desktop gaps; sysupdate API break) | RES-0001/FD8, FX3 |
| RX7 | Red Hat or Canonical strategic changes | FE10, FU16 |

## Unknowns

- Actual Eldora team size and funding (affects criteria 11, 35).
- Target hardware (NVIDIA share, ARM64 priority).
- Whether a multi-year frozen base is a V1 requirement.
- Legal interpretation of Ubuntu's IPR policy for an Eldora derivative;
  whether "based on Fedora" wording is permitted (Q-0010 matter).
- Measured CVE fix latency per base (PX6).
- Whether OB-0004's "Fedora ecosystem" includes CentOS Stream/EPEL.
- Timeline of Fedora bootc desktop readiness (RES-0001).
- Maturity trajectory of GNOME OS as a base (A4).

## Potential roadmap impact

- 0.1X is recorded in `FOUNDATION-ROADMAP.md` between 0.1A and 0.1B. Wave
  0.1B remains **blocked until human review of this report**.
- If the Owner accepts the provisional CONFIRM: 0.1B–0.1D proceed as
  forwarded by RES-0001, with added inputs: cadence mitigation (kernel
  gating, CI rebases), NVIDIA strategy, and the CentOS Stream scope question.
- If the Owner REOPENS OB-0004: RES-0001's Fedora-specific questions need
  distribution-neutral reframing; probes PX1–PX5 become prerequisites;
  Wave 0.2 may need to consider A4 (GNOME OS) given its desktop coupling.
- If the Owner requests MORE EVIDENCE: execute PX1, PX3 and PX6 first
  (highest information value per cost).

## Decision

NOT TAKEN — research does not decide. OB-0004 is unchanged. See the
Decision Register entry Q-0013.

## Conflicts and uncertainties

- **C1.** Fedora schedule docs disagree on "third" vs. "fourth" Tuesday
  release targets [S1, S2]; immaterial.
- **C2.** Debian wiki pages disagree on KDE Plasma's Wayland default
  [S102]; the newer KDE page states Wayland by default since Debian 12.
- **C3.** Vanilla OS reasons are quoted through tier-3 sources because the
  project blog is JavaScript-only [S132, S133].
- **C4.** Snap Store proprietary status rests on older tier-4 posts plus
  the absence of a primary self-hosting option [S67].
- **C5.** Pop!_OS reasons for choosing Ubuntu and snap defaults are not
  documented in primary sources (UNVERIFIED).
- **C6.** KDE Linux alpha dated 2025-09-06 (blog) vs. 2025-09-10 (LWN
  article date) [S136, S137].
- **C7.** Fedora F44 EOL: 2027-05-19 [L3] vs. other dates in tier-4
  sources (RES-0001/C1).

## Validation performed

- Verbatim spot-checks by the author (2026-09-26): S1 (Fedora ~13 months),
  S56 (Ubuntu RC-kernel policy), S76 (Ubuntu IPR recompilation and trade
  dress), S92 (Debian 13 lifecycle), S130 (Endless OS quotes).
- URL checks: see the final report of this task; all URLs were requested
  over HTTP(S).
- Fairness check: the same evidence structure (facts, evidence against,
  evidence for) was requested for each distribution; each has an "Evidence
  Against" section; Fedora's weaknesses are reflected in the matrix and in
  the falsification exercise.

## Sources

All accessed 2026-09-26. Tier per `docs/research/README.md`.

| # | Source (title — organization — URL) | Tier | Date covered | Used for |
|---|---|---|---|---|
| S1 | Fedora Linux Release Life Cycle — Fedora — https://docs.fedoraproject.org/en-US/releases/lifecycle/ | 1 | current | FE1 (verified) |
| S2 | Fedora Linux Releases — Fedora — https://docs.fedoraproject.org/en-US/releases/ | 1 | current | FE1 |
| S3 | End of Life Releases — Fedora — https://docs.fedoraproject.org/en-US/releases/eol/ | 1 | current | FE1 |
| S4 | Upgrading Fedora (offline) — Fedora — https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/ | 1 | current | FE2 |
| S5 | Fedora Linux Kernel Overview — Fedora — https://docs.fedoraproject.org/en-US/quick-docs/kernel-overview/ | 1 | reviewed 2024-06-15 | FE3 |
| S6 | KernelRebases — Fedora wiki — https://fedoraproject.org/wiki/KernelRebases | 2 | older | FE3 |
| S7 | Updates Policy — FESCo — https://docs.fedoraproject.org/en-US/fesco/Updates_Policy/ | 1 | current | FE3, FE8 |
| S8 | Package pages (kernel, mesa, plasma, gnome-shell) — Fedora — https://packages.fedoraproject.org/pkgs/kernel/kernel/ | 1 | snapshot | FE3 |
| S9 | KDE update policy — Fedora KDE SIG — https://fedoraproject.org/wiki/SIGs/KDE/Update_policy | 2 | current | FE3 |
| S10 | Changes/KDE Plasma 6 — Fedora — https://fedoraproject.org/wiki/Changes/KDE_Plasma_6 | 1 | F40 | FE4 |
| S11 | Changes/WaylandOnlyGNOME — Fedora — https://fedoraproject.org/wiki/Changes/WaylandOnlyGNOME | 1 | F43 | FE4, FE14 |
| S12 | Changes/NvidiaInstallationWithSecureboot — Fedora — https://fedoraproject.org/wiki/Changes/NvidiaInstallationWithSecureboot | 1 | F41 | FE5 |
| S13 | Third-Party Repositories — Fedora Workstation WG — https://docs.fedoraproject.org/en-US/workstation-working-group/third-party-repos/ | 1 | current | FE5 |
| S14 | Howto/NVIDIA — RPM Fusion — https://rpmfusion.org/Howto/NVIDIA | 2 | current | FE5 |
| S15 | Howto/Secure Boot — RPM Fusion — https://rpmfusion.org/Howto/Secure%20Boot | 2 | current | FE5 |
| S17 | linux-firmware package — Fedora — https://packages.fedoraproject.org/pkgs/linux-firmware/ | 1 | live | FE6 |
| S18 | Architectures — Fedora wiki — https://fedoraproject.org/wiki/Architectures | 1 | current | FE7 |
| S20 | Bluefin LTS — Project Bluefin — https://docs.projectbluefin.io/lts/ | 2 | current | FE12 |
| S21 | Bluefin Administrator's Guide — Project Bluefin — https://docs.projectbluefin.io/administration/ | 2 | current | FE12 |
| S23 | Fedora Asahi Remix User Guide — Fedora — https://docs.fedoraproject.org/en-US/fedora-asahi-remix/ | 1 | current | FE7 |
| S24 | Fedora Asahi Remix — Asahi Linux — https://asahilinux.org/fedora/ | 2 | F44 | FE7 |
| S25 | Snapdragon WoA Laptop Install — Fedora wiki — https://fedoraproject.org/wiki/Snapdragon_WoA_Laptop_Install | 2 | F44 | FE7 |
| S26 | riscv/planning #23 — Fedora Forge — https://forge.fedoraproject.org/riscv/planning/issues/23 | 2 | 2026-06-11 | FE7 |
| S27 | Security Bugs — Fedora wiki — https://fedoraproject.org/wiki/Security_Bugs | 1 | older | FE8 |
| S28 | Fedora Security SIG — Fedora — https://docs.fedoraproject.org/en-US/security/ | 1 | current | FE8 |
| S29 | Changes/ReproduciblePackageBuilds — Fedora — https://fedoraproject.org/wiki/Changes/ReproduciblePackageBuilds | 1 | F41 | FE9 |
| S30 | Changes/Package builds are expected to be reproducible — Fedora — https://fedoraproject.org/wiki/Changes/Package_builds_are_expected_to_be_reproducible | 1 | accepted F46 | FE9 |
| S32 | Fedora Reproducible Builds — Fedora — https://docs.fedoraproject.org/en-US/reproducible-builds/ | 1 | current | FE9 |
| S34 | Fedora Council — Fedora — https://docs.fedoraproject.org/en-US/council/ | 1 | current | FE10 |
| S35 | Fedora trademark guidelines — Fedora/Red Hat — https://docs.fedoraproject.org/en-US/legal/trademarks/ | 1 | 2024-12-05 | FE10 |
| S37 | What's Next for Pagure.io?! — Fedora Magazine — https://fedoramagazine.org/whats-next-for-pagure-io/ | 2 | 2026-06-16 | FE10 |
| S38 | Git Forge Initiative 2025 — Fedora — https://fedoraproject.org/wiki/Initiatives/Git_Forge_Initiative_2025 | 1 | 2025 | FE10 |
| S39 | Changes/Drop i686 support — Fedora — https://fedoraproject.org/wiki/Changes/Drop_i686_support | 1 | 2025 | FE13 |
| S40 | Fedora's i686 support gets a reprieve — LWN — https://lwn.net/Articles/1026917/ | 3 | 2025-06-30 | FE13 |
| S41 | Changes/Promote KDE Plasma Desktop variant to Edition — Fedora — https://fedoraproject.org/wiki/Changes/Promote_KDE_Plasma_Desktop_variant_to_Edition | 1 | F42 | FE14 |
| S50 | Ubuntu 26.04 LTS release notes — Canonical — https://documentation.ubuntu.com/release-notes/26.04/ | 1 | 2026-08-28 | FU1 |
| S51 | Ubuntu 26.04 changes since 25.10 — Canonical — https://documentation.ubuntu.com/release-notes/26.04/changes-since-previous-interim/ | 1 | 2026-08-27 | FU4, FU6, FU14, FU15, FU17 |
| S52 | Ubuntu 26.04.1 — Canonical — https://documentation.ubuntu.com/release-notes/26.04/1/ | 1 | 2026-08-28 | FU1 |
| S53 | Ubuntu 26.10 schedule — Canonical — https://documentation.ubuntu.com/release-notes/26.10/schedule/ | 1 | 2026-09-25 | FU1 |
| S54 | Ubuntu 25.10 release notes — Canonical — https://documentation.ubuntu.com/release-notes/25.10/ | 1 | 2026-04-15 | FU1, FU4 |
| S55 | Ubuntu release cycle — Canonical — https://ubuntu.com/about/release-cycle | 1 | 2026 | FU2, FU11 |
| S56 | Kernel Version Selection for Ubuntu Releases — Ubuntu Discourse (Canonical Kernel Team) — https://discourse.ubuntu.com/t/kernel-version-selection-for-ubuntu-releases/47007 | 2 | 2024-08-09 | FU3 (verified) |
| S58 | Kernel lifecycle / HWE — Canonical — https://ubuntu.com/kernel/lifecycle | 1 | current | FU3 |
| S59 | mesa-vulkan-drivers package search — Canonical — https://packages.ubuntu.com/search?keywords=mesa-vulkan-drivers | 1 | live | FU3 |
| S60 | Install NVIDIA drivers (26.04) — Canonical — https://ubuntu.com/desktop/docs/en/26.04/how-to/graphics/install-nvidia-drivers/ | 1 | 2026-08-25 | FU5 |
| S61 | Build NVIDIA modules with DKMS (26.04) — Canonical — https://ubuntu.com/desktop/docs/en/26.04/how-to/graphics/build-your-own-nvidia-modules-using-the-dkms-package/ | 1 | 2026-08-27 | FU5 |
| S62 | firefox package (resolute) — Canonical — https://packages.ubuntu.com/resolute/firefox | 1 | live | FU6 |
| S63 | ubuntu-desktop-minimal (resolute) — Canonical — https://packages.ubuntu.com/resolute/ubuntu-desktop-minimal | 1 | live | FU6 |
| S64 | Dedicated Snap Store docs — Canonical — https://documentation.ubuntu.com/dedicated-snap-store/ | 1 | 2026-07-10 | FU7 |
| S65 | Dedicated snap store (Core docs) — Canonical — https://documentation.ubuntu.com/core/explanation/stores/dedicated-snap-store/ | 1 | 2026-04-20 | FU7 |
| S66 | Brand accounts — Canonical — https://documentation.ubuntu.com/core/explanation/stores/brand-accounts/ | 1 | 2026-04-20 | FU7, FU8 |
| S67 | Is the snapcraft.io back-end open source? — Snapcraft forum — https://forum.snapcraft.io/t/is-the-snapcraft-io-back-end-server-open-source/9202 | 4 | 2018-12 | FU7 (corroboration) |
| S68 | Canonical launches Ubuntu Core 26 — Canonical — https://canonical.com/blog/canonical-launches-ubuntu-core-26 | 1 | 2026-05 | FU8 |
| S69 | Canonical Q&A (J. Seager) — The Register — https://www.theregister.com/2025/11/03/canonical_jon_seager_qa/ | 3 | 2025-11-03 | FU8 |
| S70 | Ubuntu Core Desktop deep dive — Ubuntu Discourse — https://discourse.ubuntu.com/t/ubuntu-core-desktop-deep-dive/37740 | 2 | 2023-08-11 | FU8 |
| S71 | Create installer image (Image Cookbook) — Canonical — https://ubuntu.com/hardware/docs/image-cookbook/howto/images/create_installer_image/ | 1 | 2026 (draft) | FU9 |
| S72 | Create customized image with ubuntu-image — Canonical — https://ubuntu.com/hardware/docs/image-cookbook/howto/images/create_image/ | 1 | 2026-02-20 | FU9 |
| S73 | ubuntu-desktop-provision README — Canonical (GitHub page) — https://github.com/canonical/ubuntu-desktop-provision | 1 | n/d | FU9 |
| S74 | Introduction to autoinstall — Canonical — https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html | 1 | 2024-04-05 | FU9 |
| S75 | Personal Package Archive — Launchpad manual — https://documentation.ubuntu.com/launchpad/user/reference/packaging/ppas/ppa/ | 1 | 2026-07-22 | FU9 |
| S76 | Intellectual property rights policy — Canonical — https://ubuntu.com/legal/intellectual-property-policy | 1 | 2015-07-15 | FU10 (verified) |
| S77 | Clarification on IP Rights Policy — Canonical — https://canonical.com/blog/clarification-on-ip-rights-policy | 1 | 2015-07-15 | FU10 |
| S78 | Statement on Canonical's updated licensing terms — FSF — https://www.fsf.org/news/canonical-updated-licensing-terms | 3 | 2015-07-15 | FU10 |
| S79 | Ubuntu IP policy — Software Freedom Conservancy — https://sfconservancy.org/news/2015/jul/15/ubuntu-ip-policy/ | 3 | 2015-07-15 | FU10 |
| S80 | base-files file list (resolute) — Canonical — https://packages.ubuntu.com/resolute/amd64/base-files/filelist | 1 | live | FU11 |
| S81 | Ubuntu Security Notices — Canonical — https://ubuntu.com/security/notices | 1 | live | FU12 |
| S82 | Ubuntu OVAL — Canonical — https://ubuntu.com/security/oval | 1 | current | FU12 |
| S83 | Software bill of materials (Core) — Canonical — https://documentation.ubuntu.com/core/reference/software-bill-of-materials/ | 1 | 2026-05-14 | FU12 |
| S84 | UEFI Secure Boot — Canonical — https://documentation.ubuntu.com/security/security-features/platform-protections/secure-boot/ | 1 | 2026-01-22 | FU13 |
| S85 | shim-review README — rhboot (GitHub page) — https://github.com/rhboot/shim-review | 1 | cites 2026-06-27 | FU13 |
| S86 | Ubuntu governance — Canonical — https://ubuntu.com/community/governance | 1 | current | FU16 |
| S87 | Losing graciously (archived) — M. Shuttleworth — http://web.archive.org/web/2014/http://www.markshuttleworth.com/archives/1316 | 2 | 2014-02-14 | FU16 |
| S88 | Growing Ubuntu for cloud and IoT… — Canonical — https://canonical.com/blog/growing-ubuntu-for-cloud-and-iot-rather-than-phone-and-convergence | 1 | 2017-04-05 | FU16 |
| S89 | An update on rust-coreutils — Ubuntu Discourse — https://discourse.ubuntu.com/t/an-update-on-rust-coreutils/80773 | 2 | 2026-04-22 | FU17 |
| S90 | Debian 13 "trixie" released — Debian — https://www.debian.org/News/2025/20250809 | 1 | 2025-08-09 | FD1, FD5, FD12, FD17 |
| S91 | Debian 12 "bookworm" released — Debian — https://www.debian.org/News/2023/20230610 | 1 | 2023-06-10 | FD1 |
| S92 | trixie Release Information — Debian — https://www.debian.org/releases/trixie/ | 1 | 2026 | FD2 (verified) |
| S93 | Debian Extended LTS — Freexian — https://www.freexian.com/lts/extended/ | 1 (vendor) | current | FD2 |
| S94 | Debian Release Management — Debian — https://release.debian.org/ | 1 | 2026 | FD3 |
| S95 | forky Freeze Timeline and Policy — Debian — https://release.debian.org/testing/freeze_policy.html | 1 | current | FD3 |
| S96 | Bits from the Release Team — debian-devel-announce — https://lists.debian.org/debian-devel-announce/2026/05/msg00001.html | 2 | 2026-05-10 | FD3, FD15 |
| S97 | forky Release Information — Debian — https://www.debian.org/releases/forky/ | 1 | 2025-10-18 | FD4 |
| S98 | trixie release notes: What's new — Debian — https://www.debian.org/releases/trixie/release-notes/whats-new.en.html | 1 | 2025 | FD5 |
| S99 | Package search (linux-image-amd64, mesa-vulkan-drivers) — Debian — https://packages.debian.org/search?keywords=linux-image-amd64 | 1 | live | FD5 |
| S100 | Debian Backports — Debian — https://backports.debian.org/ | 1 | current | FD5 |
| S101 | GR 2022: non-free firmware — Debian — https://www.debian.org/vote/2022/vote_003 | 1 | 2022-10 | FD6 |
| S102 | Wayland; KDE — Debian wiki — https://wiki.debian.org/Wayland ; https://wiki.debian.org/KDE | 1/4 | 2025-10/11 | FD7, C2 |
| S103 | NvidiaGraphicsDrivers — Debian wiki — https://wiki.debian.org/NvidiaGraphicsDrivers | 1/4 | 2026-09-25 | FD8 |
| S104 | SecureBoot — Debian wiki — https://wiki.debian.org/SecureBoot | 1 | 2026-07-19 | FD9 |
| S105 | Debian Trademarks — Debian/SPI — https://www.debian.org/trademark | 1 | 2013 policy; page 2026-06-10 | FD10, FD16 |
| S106 | Derivatives/Guidelines — Debian wiki — https://wiki.debian.org/Derivatives/Guidelines | 1 | 2021-09-27 | FD11 |
| S107 | Derivatives — Debian wiki — https://wiki.debian.org/Derivatives | 1 | 2026-08-23 | FD11 |
| S108 | DebianLive — Debian wiki — https://wiki.debian.org/DebianLive | 1 | 2022 | FD12 |
| S109 | Cloud — Debian wiki — https://wiki.debian.org/Cloud | 1 | 2025-08-17 | FD12 |
| S110 | mkosi(1) trixie — Debian manpages — https://manpages.debian.org/trixie/mkosi/mkosi.1.en.html | 1 | 25.3 | FD12 |
| S111 | debos README — go-debos (GitHub page) — https://github.com/go-debos/debos | 4 | current | FD12 |
| S112 | ReproducibleInstalls/LiveImages — Debian wiki — https://wiki.debian.org/ReproducibleInstalls/LiveImages | 1 | 2026-05-18 | FD12 |
| S113 | ostree package search — Debian — https://packages.debian.org/search?keywords=ostree | 1 | live | FD13 |
| S114 | sysupdate.d(5) trixie — Debian manpages — https://manpages.debian.org/trixie/systemd-container/sysupdate.d.5.en.html | 1 | 257 | FD13 |
| S115 | bootc package search — Debian — https://packages.debian.org/search?keywords=bootc | 1 | live | FD13 |
| S116 | Debian Security Information — Debian — https://www.debian.org/security/ | 1 | 2026-09-25 | FD14 |
| S117 | Security Bug Tracker — Debian — https://security-tracker.debian.org/tracker/ | 1 | live | FD14 |
| S118 | trixie release notes: Issues — Debian — https://www.debian.org/releases/trixie/release-notes/issues.en.html | 1 | 2025 | FD14 |
| S119 | trixie/amd64 reproducibility stats — Reproducible Builds — https://tests.reproducible-builds.org/debian/trixie/index_suite_amd64_stats.html | 1 | live | FD15 |
| S120 | OpenPGP/Sequoia — Debian wiki — https://wiki.debian.org/OpenPGP/Sequoia | 1 | 2025-09-01 | FD15 |
| S121 | Debian Constitution — Debian — https://www.debian.org/devel/constitution | 1 | v1.9 (2022) | FD16 |
| S122 | trixie release notes: Upgrades — Debian — https://www.debian.org/releases/trixie/release-notes/upgrading.en.html | 1 | 2025 | FD18 |
| S130 | Endless OS: what's changing and why — Endless Access — https://access.endlessstudios.com/blog/endless-os-a-conversation-about-whats-changing-and-why-it-matters | 1/2 | 2026-01-07 | FX1 (verified) |
| S131 | Endless OS 7 release notes (draft) — Endless — https://support.endlessos.org/en/endless-os/release-notes/7 | 1 | 2026 draft | FX1 |
| S132 | Vanilla OS shifting to Debian — LWN — https://lwn.net/Articles/929124/ | 3 | 2023 | FX2 |
| S133 | Vanilla OS moves to Debian Sid — It's FOSS — https://itsfoss.com/news/vanilla-os-debian-ubuntu/ | 3 | 2023-03-10 | FX2 |
| S134 | Vanilla OS 2 — LWN — https://lwn.net/Articles/989629/ | 3 | 2024 | FX2 |
| S135 | Vanilla OS 3 Reunion — Vanilla OS — https://vanillaos.org/blog/article/2026-08-24/vanilla-os-3-reunion---stable-release | 1 | 2026-08-24 | FX2 |
| S136 | Announcing the Alpha release of KDE Linux — N. Graham (KDE) — https://pointieststick.com/2025/09/06/announcing-the-alpha-release-of-kde-linux/ | 2 | 2025-09-06 | FX3 |
| S137 | KDE launches its own distribution (again) — LWN — https://lwn.net/Articles/1037166/ | 3 | 2025-09-10 | FX3 |
| S138 | This month in KDE Linux: March 2026 — N. Graham — https://pointieststick.com/2026/03/31/this-month-in-kde-linux-march-2026/ | 2 | 2026-03-31 | FX3 |
| S139 | Let's Talk OS 8 — elementary — https://blog.elementary.io/lets-talk-os-8/ | 1 | 2023-11-03 | FX4 |
| S140 | OS 8 Available Now — elementary — https://blog.elementary.io/os-8-available-now/ | 1 | 2024-11-26 | FX4 |
| S141 | Pop!_OS 24.04 LTS: letter from our founder — System76 — https://system76.com/blog/post/pop-os-letter-from-our-founder/ | 1 | 2025-12-11 | FX5 |
| S142 | Dirty Frag/Copy Fail fixes — System76 — https://system76.com/blog/post/linux-zero-day-dirty-frag-and-copy-fail-vulnerability-fixes-released | 1 | 2026-05-08 | FX5 |
| S143 | pop-os/nvidia-graphics-drivers — System76 (GitHub page) — https://github.com/pop-os/nvidia-graphics-drivers | 1 | n/d | FX5 |
| S144 | Fedora COSMIC — Fedora — https://fedoraproject.org/spins/cosmic/ | 1 | current | FX5 |
| S145 | Valve dumped Debian for Arch with SteamOS 3 — GamingOnLinux — https://www.gamingonlinux.com/2021/08/valve-dumped-debian-linux-for-arch-linux-with-steamos-3-because-surprise-faster-updates/ | 3 | 2021-08-10 | FX6 |
| S146 | SteamOS 3.6 atomic updates — Collabora — https://www.collabora.com/news-and-blog/news-and-events/steamos-3-6-how-the-steam-deck-atomic-updates-are-improving.html | 2 | 2024-05-10 | FX6 |
| S147 | Bluefin press kit — Project Bluefin — https://docs.projectbluefin.io/press-kit/ | 1 | n/d | FX7 |
| S148 | Dakota Alpha 1 — Project Bluefin — https://docs.projectbluefin.io/blog/dakota-alpha-1/ | 1 | 2026-04-19 | FX7 |
| S149 | GNOME OS — GNOME — https://os.gnome.org/ | 1 | current | FX8 |
| S150 | GNOME OS and systemd-sysupdate — Codethink — https://www.codethink.co.uk/articles/2024/GNOME-OS-systemd-sysupdate/ | 2 | 2024-05-14 | FX8 |
| S151 | GNOME STF 2024 Project Report — T. Bernard (GNOME) — https://blogs.gnome.org/tbernard/2025/04/ | 2 | 2025-04-11 | FX8 |
| S152 | mkosi man page — systemd (GitHub raw document) — https://raw.githubusercontent.com/systemd/mkosi/main/mkosi/resources/man/mkosi.1.md | 1 | main | FX9 |
| S153 | Demonstrate a debian or arch base image (#865) — bootc (GitHub page) — https://github.com/bootc-dev/bootc/issues/865 | 2 | open since 2024-11-01 | FX9 |
| S154 | bootcrew — community (GitHub page) — https://github.com/bootcrew | 4 | 2026 | FX9 |
| S155 | Bootc for workstation use — LWN — https://lwn.net/Articles/1042708/ | 3 | 2025 | FX9 |

Source numbering is non-contiguous by design (grouped by subject); unused
numbers are intentionally not assigned. Tier-4 sources are used only for
corroboration.
