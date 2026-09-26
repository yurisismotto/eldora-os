# RES-0001 — Fedora Ecosystem & Base-System Composition Models (Wave 0.1A)

| Field | Value |
|---|---|
| ID | RES-0001 |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1A — Fedora Ecosystem & Base-System Composition Models) |
| Related questions | Q-0001, Q-0008 |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): research planning, web documentary research (five delegated research sub-agents plus direct spot-checks), local read-only evidence collection, drafting. No human has reviewed this report yet. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; see [review record](../../project/reviews/WAVE-0.1A-0.1X-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (overall; per-claim and per-alternative confidence stated below) |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records (ADR, GDR, LDR, BDR)
> accepted by the Project Owner. See
> `docs/research/README.md` and `docs/project/DECISION-LIFECYCLE.md`.

Label convention used throughout: **FACT** (externally or locally verifiable,
cited), **HYPOTHESIS** (unverified proposition to test), **REQUIREMENT**
(derived from Owner Baselines / vision; not new owner requirements),
**ALTERNATIVE**, **INFERENCE** (reasoned from facts, not stated by a
source), **RECOMMENDATION**, **DECISION** (always NOT TAKEN here).
Source references `[Sn]` point to the Sources table; `[Ln]` to Local
evidence.

## Question

Which technically viable models exist, **within the Fedora ecosystem**, for
composing the Eldora OS V1 base system, and which deserve detailed
investigation in the next stages of Wave 0.1?

Fedora-derived is an Owner Baseline for V1 (OB-0004). The *form* of
derivation/composition is open (Q-0001). The relationship of each model to
system update and rollback (Q-0008) is covered at survey level only;
detailed update/rollback research is forwarded to Wave 0.1C.

## Scope

- Composition models: package-based mutable host; OSTree/rpm-ostree;
  bootable containers (bootc, OCI image mode); transitional hybrids.
- Current Fedora image/build/compose tooling and which model each belongs to.
- Derivative identity and ownership mechanics (release identity, packages,
  repositories, defaults, branding, update source, signing/trust, lifecycle).
- Upstream relationship: what Eldora would consume, own, and be coupled to.
- Current terminology, strategy and deprecation direction in Fedora
  (state as of 2026-09-26).

## Out of Scope

- Comparing Fedora with non-Fedora bases (excluded by OB-0004 and the
  Wave 0.1 roadmap).
- Desktop environment, compositor, toolkit (Wave 0.2); application model and
  application updates (Wave 0.3); platform layers (Wave 0.4).
- Final boundary architecture, implementation, experiments that build or
  install images (none were run), and any decision.
- Legal advice. Trademark observations below inform the Project Owner only
  and belong ultimately to Q-0010.

## Method and limitations

- Documentary research on 2026-09-26 using public web sources, split across
  five research sub-agents (package-based model; Atomic Desktops/rpm-ostree;
  bootc; build tooling; identity/trust/strategy), followed by direct
  spot-checks by the author of the claims the recommendation depends on most
  (raw wiki text of Change pages and upstream documentation).
- Local read-only evidence was collected on the author's workstation
  (Fedora 44). No image was built, installed or booted.
- No Git/GitHub remote operation was performed. Public github.com,
  gitlab.com and quay.io pages were read as documents only (one sub-agent
  made anonymous read-only calls to the public Quay.io tag-listing API to
  observe whether signature tags exist on Fedora images; no action was
  taken on any repository).
- **Access limitation:** docs.fedoraproject.org and forge.fedoraproject.org
  intermittently served bot-challenge (Anubis) pages to automated fetchers.
  Some pages were read via plain HTTP clients or via archived/raw sources
  instead; a few (noted UNVERIFIED) could not be read.
- **Quote fidelity:** some quotations were extracted through a
  summarizing web-fetch tool. Quotations used for key claims were
  re-verified verbatim by the author where marked "(verified)". Others
  should be spot-checked before the report is cited in a decision record.

## Local evidence

Environment: author's workstation, Fedora Linux 44 (Workstation Edition),
kernel 7.2.5-200.fc44.x86_64, btrfs root, not OSTree-booted. Commands were
read-only; repository queries used the local DNF5 metadata cache only
(`-C`, cache last refreshed 2026-09-24).

| ID | Command | Result (summary) |
|---|---|---|
| L1 | `cat /etc/os-release` | `ID=fedora`, `VERSION_ID=44`, `VARIANT_ID=workstation`, `RELEASE_TYPE=stable`, `SUPPORT_END=2027-05-19`, `LOGO=fedora-logo-icon`; no `ID_LIKE`, no `IMAGE_ID`. |
| L2 | `rpm -qf /usr/lib/os-release /etc/yum.repos.d/fedora.repo /etc/containers/policy.json` | `fedora-release-identity-workstation-44-18`, `fedora-repos-44-2`, `containers-common-0.67.2-1.fc44`. |
| L3 | `dnf5 repoquery -C --latest-limit=1 …` | Packaged in Fedora 44 repositories: `bootc 1.16.10-1.fc44` (built 2026-08-26), `rpm-ostree 2026.2-1.fc44` (built 2026-06-08), `ostree 2026.4-1.fc44`, `osbuild 193-1.fc44` (built 2026-09-06), `image-builder 83.0.0-1.fc44` (built 2026-09-16), `kiwi-cli 11.0.2-1.fc44`, `lorax 44.7-1.fc44`, `pungi 4.14.0-2.fc44`, `anaconda-core 44.30-2.fc44`, `pykickstart 3.69-1.fc44`, `composefs 1.0.8-5.fc44`, `system-reinstall-bootc 1.16.10-1.fc44`. No `bootc-image-builder` package was found. |
| L4 | `cat /etc/containers/policy.json` | Default policy `insecureAcceptAnything` (no signature requirement by default). |
| L5 | `grep … /etc/yum.repos.d/fedora.repo` | `metalink=https://mirrors.fedoraproject.org/metalink?…`, `gpgcheck=1`, `repo_gpgcheck=0`. |
| L6 | `rpm -q snapper; findmnt -no FSTYPE /` | `snapper` not installed; root filesystem `btrfs`. |

## Facts

### F-A. Fedora release lifecycle and baseline state

- **FA1.** A Fedora release is supported until about four weeks after the
  release of N+2 (≈13 months at a ≈6-month cadence) [S27, tier 4, citing the
  official lifecycle page, which could not be fetched]. The local F44
  system declares `SUPPORT_END=2027-05-19` [L1]. **Conflict:** [S27] lists
  F44 EOL as 2027-06-02. The primary local evidence is preferred; the
  difference does not affect this report's conclusions.
- **FA2.** Fedora 45 Beta was announced 2026-09-15 [S15]; the F45 final
  target is 2026-10-20 (fallbacks 2026-10-27, 2026-11-03) [S16].
- **FA3.** DNF5 became the default package manager in F41 [S1]; Anaconda
  moved to DNF5 in F43 [S2]; PackageKit moved to a DNF5 backend in F44 [S3].
- **FA4.** Fedora 45 enforces RPM signature checking by default: "only
  packages with a verified signature can be installed" unless explicitly
  overridden [S4, S5]. F45 also relocates packaged RPM repository
  configuration to `/usr` and moves OpenPGP verification toward Sequoia
  [S4].

### F-B. Package-based (traditional) model

- **FB1.** Package composition uses RPM + DNF5, comps groups
  (fedora-comps), and kickstart (pykickstart; e.g. `repo`, `%packages`)
  [S6].
- **FB2.** Fedora's package-based live media moved from
  lorax/livemedia-creator to **Kiwi**: Kiwi builds Cloud images since F40
  [S7]; desktop teams began switching in F41 and more in F42 [S8, tier 2];
  the F42 EROFS Change lists "all kiwi-produced live media. Currently:
  Workstation, KDE Desktop, KDE Mobile, LXQt, MiracleWM, COSMIC, Xfce,
  Budgie" [S9]. The ModernizeBootISO Change states (verified): "Package based
  live media has moved onto `kiwi`. ostree-, and bootc-based artifacts have
  moved onto `image-builder` though some deliverables remain to be
  migrated" [S12]. No single Change page moved all live media to Kiwi;
  evidence combines tier-1 and tier-2 sources.
- **FB3.** lorax is still maintained and packaged (lorax 44.7 in F44 [L3];
  45.3 in F45 [S88]) but its Fedora compose role is shrinking to `boot.iso`;
  the change replacing it for `boot.iso` (ModernizeBootISO) is now
  targeted at **Fedora 46** (`ChangeAcceptedF46`, verified) [S12].
- **FB4.** Fedora (Btrfs by default on desktops since F33) explicitly
  provides "no automatic snapshots/rollbacks" [S24]. DNF5 offers
  `history undo/rollback` of transactions [S25] and offline
  `system-upgrade` for release upgrades [S26]. No atomic whole-system
  rollback is part of the default package-based Fedora desktop (INFERENCE
  from [S24–S26]; consistent with [L6]: btrfs root, `snapper` not
  installed on a default-installed F44 Workstation host).
- **FB5.** Copr is a Fedora build service producing per-project RPM
  repositories for FOSS projects, with limited build retention and
  Copr-managed signing keys [S23]; it is not designed as a distribution's
  release infrastructure (INFERENCE).
- **FB6.** Existing package-based Fedora derivatives exist: Nobara
  ("not a Fedora Spin and has no formal relationship with Red Hat") [S107,
  tier 4] and Ultramarine, whose primary deliverable remains package-based
  ISOs built with its own tool, while its bootc variant is "experimental"
  [S106, tier 4].

### F-C. OSTree / rpm-ostree and Fedora Atomic Desktops

- **FC1. Terminology.** Since F40 the rpm-ostree desktop variants are
  grouped as **Fedora Atomic Desktops**; Sericea became Sway Atomic and
  Onyx became Budgie Atomic; Silverblue and Kinoite kept their names [S28,
  S29]. "Atomic" was chosen over "immutable" [S29]. Current variants:
  Silverblue, Kinoite, Sway Atomic, Budgie Atomic, COSMIC Atomic [S30]. The
  per-variant Silverblue docs were archived on 2026-01-09 and merged into
  unified Atomic Desktops documentation [S48, S31].
- **FC2. OSTree model.** libostree provides a content-addressed store of
  bootable filesystem trees and deploys them with bootloader integration;
  `/etc` is 3-way merged, `/var` is shared and not modified by upgrades,
  writable locations are redirected into `/var` (e.g. `/opt → /var/opt`,
  `/home → /var/home`); upgrades are atomic via a bootloader symlink swap
  ("you will have either the old system, or the new one") [S34].
- **FC3. rpm-ostree** is "a hybrid image/package system" combining
  libostree with RPM on client and server side, supporting client-side
  package layering, overrides, rebase and rollback; client changes normally
  take effect on reboot (`apply-live` exists) [S35, S36]. Server-side
  composition uses `rpm-ostree compose tree` with a treefile; upstream now
  calls it "a low level tool" [S37].
- **FC4. rpm-ostree strategic status (verified):** "Currently, development
  focus has shifted to bootc, dnf, and the ecosystem around those tools.
  However, rpm-ostree is widely in use today in many upstream projects and
  downstream products and continues to be supported. In general, new major
  features related to bootable containers should land in those projects
  instead." [S35]. It is still released (v2026.3 on 2026-09-10 [S40];
  v2026.2 packaged in F44 [L3]). "Maintenance mode" is **not** the wording
  used.
- **FC5. Delivery of official Atomic Desktops is still the OSTree
  repository.** The official docs use `rpm-ostree rebase
  fedora:fedora/44/x86_64/silverblue` [S50]; container images at
  `quay.io/fedora-ostree-desktops/*` are explicitly "Unofficial" [S51].
  The 2022–2024 proposal to move Atomic variants to container delivery and
  make the OSTree repository read-only (OstreeNativeContainerStable) carries
  the Change-Rejected banner (verified) [S41].
- **FC6.** Composefs is used by default on Fedora CoreOS/IoT since F41 and
  on Atomic Desktops since F42 [S43, S32] (scope conflict noted in
  Conflicts).
- **FC7.** Documented desktop limitations of the rpm-ostree model: Flatpak
  is the primary application path; layering requires reboot and can block
  upgrades when a layered package needs a newer base package; `/opt` issues
  for third-party RPMs; no DKMS, kernel modules via kmods/akmods with
  Secure Boot signing concerns; one rollback deployment kept by default
  [S48 archived docs, dated ≤2026-01-09].

### F-D. Bootable containers (bootc / image mode)

- **FD1.** bootc provides "Transactional, in-place operating system updates
  using OCI/Docker container images" [S53]. APIs were declared stable in
  v1.1.0 (2024-10-17) [S54]; the docs state "The CLI and API for bootc are
  now considered stable" [S53]. Current line: 1.16.x (1.16.10 packaged in
  F44 [L3]; 1.16.13 released Sep 15 [S56]).
- **FD2.** bootc was accepted into the CNCF on 2025-01-21 at **Sandbox**
  maturity (CNCF's entry tier) [S55].
- **FD3. Relationship to OSTree/rpm-ostree.** bootc currently uses OSTree
  for deployment and bootloader management while pulling content as OCI
  images; "The role of OSTree may further shrink in the future";
  bootc and rpm-ostree may be used together, but after client-side
  rpm-ostree changes "bootc upgrade will error out" [S57, S58]. A native
  composefs backend exists but is explicitly **experimental** ("on-disk
  formats are subject to change") [S59].
- **FD4. Semantics.** A/B-style staged updates applied on reboot;
  `bootc switch` changes the image reference; `bootc rollback` reorders
  deployments; `/etc` 3-way merged; image changes to `/var` are **not**
  applied after initial install; `/` is read-only [S58, S60, S61]. Fedora's
  docs state that rollback does not carry `/etc` edits and that Fedora
  bootc images perform automatic updates by default [S66].
- **FD5. Build model.** Derived images are built with a normal
  Containerfile `FROM` a base image; `dnf` works at build time but fails on
  the deployed host (read-only), except for a transient `usroverlay` [S70].
  From-scratch base images use `bootc-base-imagectl build-rootfs` with
  `minimal`/`standard` manifests; its rpm-ostree implementation is "an
  implementation detail subject to change" and directly configuring the
  package set "is currently not officially supported" [S69]. Fedora base
  content sets are `minimal`, `minimal-plus` (intended shared base for IoT,
  Atomic Desktops and CoreOS) and `standard` [S68].
- **FD6. Installation.** `bootc install to-disk` is described as mainly a
  demo of `to-filesystem`, which external installers use [S63]. Anaconda
  gained a `bootc` kickstart command (added F43, options extended F45) with
  limitations: no multi-disk layouts, no arbitrary mount points, no
  authenticated registries [S6, S74]. Logically bound images are not
  supported by Anaconda [S64].
- **FD7. Fedora status (verified).** The Fedora Council initiative "Image
  Mode, Phase 2 (2026)" states "Fedora has not yet reached true production
  capacity for the bootc toolchain", sets development (by F44) and
  production (by F45) pipelines for official base images, and a vision of
  "all atomic (immutable) operating system variants delivered as layered
  bootable OCI artifacts, built using the upstream bootc toolchain" [S72].
  Konflux was accepted in F44 as the draft pipeline for bootc base images
  [S73].
- **FD8. No official Fedora bootc desktop exists yet.** No F44/F45 Change
  makes Atomic Desktops bootc-native [S3, S4]. The F45 image-builder Change
  says it "will also enable (in the future) to migrate the Fedora Atomic
  Desktops to be `bootc`-based" (verified) [S14]. The Atomic Desktops
  roadmap (open since 2024-05-13) lists as still open: GNOME
  Software/Discover integration, local package layering, installer,
  migration of existing users, and signed container images [S52].
  Sealed (UKI + composefs + fs-verity) Atomic test images are unofficial and
  "not signed with the official keys from Fedora" [S49].
- **FD9. Fedora CoreOS already moved.** FCOS updates come from
  `quay.io/fedora/fedora-coreos` (F42) and it stopped publishing to the
  OSTree repository in F43 [S44, S45, S47]; from F43 FCOS is built with a
  Containerfile as "a child of Fedora bootc" [S46].
- **FD10. Vendor commitment.** RHEL 10 documents "image mode" based on
  `rhel10/rhel-bootc` [S75]; this indicates sustained Red Hat investment
  (INFERENCE; GA wording not captured verbatim).
- **FD11. Update size.** Layer-granular updates can mean that "a
  modification to a single configuration file could result in downloading
  gigabytes of data"; rechunking (`rpm-ostree compose build-chunked-oci`,
  chunkah) mitigates it [S77, S39, S78]. zstd:chunked partial pulls have
  open failure reports for bootc (issues opened 2024-05-03 and 2026-08-24,
  both open) [S79, S80].
- **FD12. Graphical update UX.** The roadmap records "GNOME Software: TBD",
  "Plasma Discover: Partial", and "Bootc is currently root only: no
  unprivileged interface, no DBus interface" [S52].
- **FD13. Kernel modules.** Third-party modules must be built into the
  image against the image's kernel; prebuilt kmods can cause "silent boot
  failures" on kernel updates; Secure Boot requires signing with a trusted
  key/MOK [S76].
- **FD14. Desktop derivatives on OCI exist** (tier 4, corroboration only):
  Universal Blue images (Bluefin, Aurora, Bazzite) are delivered as OCI
  images, cosign-signed, built with Containerfiles on GitHub Actions; some
  still use `rpm-ostree rebase ostree-image-signed:…` on the client; the
  image template makes signing mandatory [S102–S105]. A September 2026
  issue in a Bluefin-derived project reports an install path where
  "nothing on this install path ever verifies that signature" [S109].

### F-E. Build and compose tooling

- **FE1.** osbuild is the build engine; the stateless **image-builder**
  CLI is the recommended local tool, replacing the "legacy service-based
  model" (osbuild-composer/composer-cli, not formally deprecated) [S84,
  S83, S85].
- **FE2.** **bootc-image-builder is deprecated**: "being deprecated in
  favor of the unified image-builder CLI"; its repository was merged into
  image-builder and archived on 2026-06-18; compatibility is guaranteed for
  the life of RHEL 10; RHEL 11 ships only image-builder [S81, S82]. It is
  not packaged in F44 [L3].
- **FE3.** In Fedora's own composes: Pungi orchestrates, Koji builds; Kiwi
  builds package-based live/cloud media; image-builder (via the
  koji-image-builder plugin, F43) builds IoT/Minimal and, from F45, Atomic
  Desktop ISOs; lorax remains for `boot.iso` until F46; `rpm-ostree compose
  tree` still produces Atomic OSTree commits; bootc base images move to
  Konflux [S86, S87, S14, S12, S11 (tier 2), S73]. The F45 Beta
  announcement confirms "Atomic Desktop ISO builds also now use
  image-builder" [S15].
- **FE4.** Anaconda's WebUI is the default installer for Workstation since
  F42 and for Atomic ISOs in F45 [S110, S4, S90].

### F-F. Derivative identity, trust and upstream

- **FF1. Trademark rules.** Distributing modified or non-Fedora-combined
  materials requires removing `fedora-logos`, `fedora-release`,
  `fedora-release-notes` (replacing them with own packages free of Fedora
  marks) and prominently stating the software is not provided or supported
  by the Fedora Project; using "Fedora" in one's own product name requires
  Fedora Council permission; the "Fedora Remix" mark is permitted under
  conditions; "Other uses of any Fedora Trademarks to refer to work that
  includes or is derived from Fedora Materials are not permitted", while
  fair use is not limited [S17, content dated 2024-12-05; S18].
- **FF2.** `generic-release` and `generic-logos` are maintained Fedora
  packages designed as replacements for the trademarked packages (current
  for F44–Rawhide) [S19, S20]. Fedora's bootc docs show `dnf -y swap
  fedora-release generic-release` and forking `generic-release` for
  derivatives [S22].
- **FF3. Identity files.** os-release defines `ID_LIKE` for derivatives,
  and `IMAGE_ID`/`IMAGE_VERSION` for OSes built and shipped as whole images
  [S21]; Fedora bootc docs recommend using `IMAGE_VERSION` [S22]. On
  Fedora, identity, presets, repositories and GPG keys are owned by
  separate release packages (`fedora-release-identity-*`,
  `fedora-release-common`, `fedora-repos`, `fedora-gpg-keys`) [L2; S19].
- **FF4. Trust per model.**
  - RPM: packages signed with per-release Fedora OpenPGP keys [S91];
    repository metadata is protected by an HTTPS metalink with hashes, not
    a metadata signature (`repo_gpgcheck=0`) [L5; INFERENCE].
  - OSTree: remotes verify GPG-signed commits by default; `ostree sign`
    supports ed25519 [S92, S93].
  - OCI/bootc: signature enforcement depends on `containers-policy.json`;
    the Fedora default is `insecureAcceptAnything` [L4]; bootc offers
    `--enforce-container-sigpolicy`, and upstream says how enforcement
    carries from installation into the installed system "is not settled
    yet" [S58, S62]. Official Fedora bootc images did not show cosign
    signature tags on 2026-09-26 [S95, observation; partially UNVERIFIED];
    Fedora infrastructure noted blockers to container signing as of
    2026-04 [S94]. FCOS signs artifacts and images via GPG [S96].
- **FF5. Secure Boot.** A Fedora-based distribution can ship Fedora's
  signed shim, GRUB and kernel unchanged; customizing them requires own
  signing, disabling Secure Boot, or own keys [S98, dated 2020]. Obtaining
  an own Microsoft-signed shim requires passing shim-review (SBAT, NX,
  lockdown, HSM key protection) [S100].
- **FF6. Strategy signal.** Fedora Strategy 2028 includes the objective
  "Immutable variants are the majority of Fedora Linux in use" [S101]; the
  Image Mode initiative defines the OCI/bootc end state for atomic variants
  [S72].

## Hypotheses

- **H1.** An Eldora image can be derived from a Fedora bootc base (or from a
  Fedora Atomic OCI image) and carry a complete desktop plus Eldora
  identity without rebuilding Fedora packages. (Supported by FD5, FF2,
  FD14; not verified experimentally for Eldora.)
- **H2.** An image-based model reduces field drift and makes Eldora
  platform components (if retained in Wave 0.4) version-coherent with the
  OS. (INFERENCE; untested.)
- **H3.** The bootc desktop gaps (FD8, FD12, FD6) will be materially closed
  within the V1 development window. (Uncertain; Fedora schedules have
  slipped — FB3, FC5.)
- **H4.** A package-based Eldora can reach acceptable update safety by
  combining offline updates with filesystem snapshots, without Fedora
  shipping this by default. (Unverified; FB4.)

## Requirements

Derived from existing repository documents only (no new owner
requirements are introduced):

- **R1.** Fedora-derived for V1 (OB-0004).
- **R2.** Reuse mature Linux/Fedora infrastructure where adequate
  ([V1-VISION](../../product/vision/V1-VISION.md)).
- **R3.** Eldora must be able to present its own identity (name, branding)
  distinct from Fedora — implied by the vision and required by Fedora
  trademark rules for modified distributions (FF1).
- **R4.** System/base-image update and rollback architecture must be
  defined (Q-0008).
- **R5.** Fundamental functionality must not require AI services
  (AGENTS.md) — no impact on composition identified.
- **R6 (candidate, needs Owner confirmation).** Reliable rollback and
  atomic updates for end users. The prompt for this wave lists them as
  evaluation criteria; they are not recorded as owner requirements in the
  repository.

## Alternatives

| ID | Model | Description |
|---|---|---|
| M1 | Package-based mutable host | Eldora ISO/images composed from Fedora RPM repos plus Eldora RPM repo; built with Kiwi (or kickstart/livemedia-creator, image-builder); host updated with DNF5; Eldora replaces release/logos/repos/keys packages. |
| M2 | OSTree / rpm-ostree, classic delivery | Eldora composes OSTree commits server-side (`rpm-ostree compose tree`, treefile) and serves its own OSTree repository; clients use rpm-ostree (as classic Fedora Atomic Desktops). |
| M2b | rpm-ostree client + OCI delivery (transitional hybrid) | Eldora builds an OCI image (Containerfile) and clients consume it through rpm-ostree `ostree-image-signed:`/`ostree-unverified-registry:` transports (as FCOS F42 and some Universal Blue images). |
| M3 | bootc / OCI image mode | Eldora builds an OCI bootable image with a Containerfile `FROM` a Fedora base (sub-options: M3a `fedora-bootc` base + desktop; M3b Fedora Atomic Desktop OCI image; M3c own base via `bootc-base-imagectl`), publishes it to an Eldora-controlled registry, and clients update with bootc. |

Alternatives considered and excluded:

| Alternative | Reason for exclusion |
|---|---|
| Full rebuild of Fedora from source in Eldora infrastructure (own Koji) | Contradicts "without reconstructing the whole userspace" and R2; cost disproportionate for V1. May be revisited only if coupling becomes unacceptable. |
| Official Fedora Spin / Fedora Atomic variant inside Fedora | Would require Fedora SIG processes and Fedora branding; conflicts with R3 (own identity, release lifecycle and update channel). |
| Fedora CoreOS as base | Server/edge-oriented, Ignition-provisioned, no desktop; its relevance is as evidence for M3 (FD9), not as a desktop base. |
| Package-based with snapshot-based rollback (snapper/btrfs) | Treated as a variant of M1 (H4), not a distinct composition model; Fedora provides no default (FB4). |

## Evidence

The evidence for each alternative is the set of facts above, summarized:

- **M1:** FB1–FB6, FA3–FA4, FF1–FF4, FE1, FE3. Current and primary Fedora
  delivery model (Workstation, Spins).
- **M2:** FC1–FC7, FC5 (official delivery today), FD9 (FCOS already left
  the OSTree repository), FF6 and FD7 (stated end state is OCI/bootc).
- **M2b:** FC4, FD3, FD9 (FCOS F42 used it), FD14 (derivatives), FC4
  (focus shifted away from rpm-ostree).
- **M3:** FD1–FD14, FE2, FF4, FF6.

## Comparison

Qualitative classifications only; no numeric scores. `+` = favourable,
`~` = mixed/conditional, `−` = unfavourable, `?` = not established.

| Criterion | M1 Package-based | M2 OSTree classic | M2b rpm-ostree + OCI | M3 bootc / OCI |
|---|---|---|---|---|
| Maturity | + Decades; Fedora's main deliverables (FB2) | + Mature since ~2018 on desktops (FC1–FC3) | ~ Used by FCOS F42, derivatives; bridge (FD9, FD14) | ~ API stable since 2024 (FD1); CNCF Sandbox (FD2); Fedora not yet at production capacity (FD7) |
| Fedora strategic alignment | + Current for Workstation/Spins; tooling actively modernized (FB2, FA4) | − Fedora moving atomic variants to OCI; CoreOS left the OSTree repo (FD9, FD7) | ~ Transitional; rpm-ostree focus shifted (FC4) | + Stated end state for atomic variants (FD7, FF6); not yet delivered for desktops (FD8) |
| Classification (Q2) | CURRENT | CURRENT for Fedora Atomic Desktops, TRANSITIONAL direction | TRANSITIONAL | STRATEGIC (not yet CURRENT for Fedora desktops) |
| Atomic updates | − Not atomic by default (FB4) | + (FC2) | + (FC2) | + (FD4) |
| Rollback | − Transaction undo only; no default snapshots (FB4) | + One previous deployment by default (FC7) | + | + Reorders deployments; `/etc` edits not carried (FD4) |
| Reproducibility | ~ Depends on repo snapshotting; host drift over time | + Commit = exact tree | + Image digest | + Image digest; build still resolves repos at build time (INFERENCE) |
| Host mutability | Fully mutable | Read-only `/usr`; layering allowed | Same as M2 | Read-only `/`; host `dnf` fails; local layering unsolved (FD5, FD8) |
| Desktop customization (by Eldora, at build time) | + Unlimited | + Treefile | + Containerfile | + Containerfile (familiar tooling) |
| Customization by end user | + | ~ Layering with caveats (FC7) | ~ | − Layering unsupported with bootc upgrades (FD3) |
| Developer experience | + Familiar | − Treefile/compose server specialised; "low level tool" (FC3) | + Containerfile | + Containerfile, podman, CI-native |
| Debugging | + Direct host edits | ~ `usroverlay`/unlock | ~ | ~ Transient `usroverlay`; rebuild-and-redeploy cycle (FD5) |
| CI suitability | ~ Kiwi/image-builder in CI; images test only initial state | ~ Requires OSTree compose infra | + OCI build in any CI | + OCI build in any CI (FD14) |
| Image generation | Kiwi, image-builder, lorax(legacy) (FE1–FE3) | image-builder (ostree), lorax(legacy) | image-builder `--bootc-ref` | image-builder (bootc-image-builder deprecated) (FE2) |
| Update infrastructure | RPM repos + mirrors + metalink (Eldora repo only for own packages; Fedora mirrors for the rest — INFERENCE) | Own OSTree repo + static delta hosting | OCI registry | OCI registry; bandwidth needs rechunking (FD11) |
| Recovery implications | − Broken host requires manual repair or reinstall | + Boot previous deployment | + | + Boot previous deployment; `/var` not rolled back (FD4) |
| Security implications | ~ Signed RPMs, F45 enforcement (FA4); mutable host | + Read-only `/usr`, signed commits (FF4) | ~ Depends on policy/transport | ~ composefs/sealing path strong but experimental (FD3, FD8); sig enforcement opt-in, default policy permissive (FF4) |
| Supply-chain implications | Trust Fedora RPM keys + own key | Trust Fedora RPMs + own OSTree signing | Trust Fedora RPMs/base + own OCI signing | Trust Fedora base image (currently unsigned by cosign, FF4) + own OCI signing; registry becomes critical |
| Operational complexity | ~ Low build complexity; high field-support complexity (drift) | − Own OSTree repo + compose server | ~ | ~ Registry, signing, rechunking; low per-host complexity |
| Eldora ownership/control of update channel | ~ Controls own repo; Fedora repos still consumed directly by hosts (INFERENCE) | + Full, via own OSTree remote | + Via own registry | + Via own registry; Eldora controls exact composition shipped |
| Upstream coupling | Fedora repos & cadence | Fedora RPMs + rpm-ostree (de-prioritised) | Fedora base + rpm-ostree | Fedora base images + bootc/ostree internals + Fedora's timeline for desktop gaps |
| Migration/reversibility | ~ Moving later to image-based is a reinstall/rebase for users (INFERENCE) | − Fedora is leaving this delivery path | ~ Can move to bootc client (FD3) | ~ Composition (Containerfile) is portable; switching back to package-based would be a reinstall (INFERENCE) |

## Trade-offs

- **Control vs. field drift.** M1 gives the simplest build and debugging
  story but pushes complexity to the field: every host can diverge, and
  there is no default atomic rollback. Image models move complexity to
  build/release infrastructure but give Eldora an exact, versioned system
  per release.
- **Strategy vs. readiness.** M3 matches Fedora's stated direction, but for
  desktops Fedora itself has not finished it (FD7, FD8, FD12). Choosing M3
  means Eldora inherits unsolved desktop gaps or solves them itself.
- **Legacy risk vs. transitional risk.** M2 is well-understood and still
  official for Atomic Desktops, but its delivery path is the one Fedora is
  moving away from (FD9, FD7). M2b reduces that risk but depends on a
  client whose development focus has moved (FC4).
- **End-user freedom vs. platform integrity.** Image models restrict host
  package installation (Flatpak/containers first), which interacts with the
  application model (Wave 0.3).

## Risks

| ID | Risk | Affects | Evidence |
|---|---|---|---|
| RK1 | Fedora desktop bootc milestones slip beyond V1 needs | M3 | FD7, FD8; history of slips FB3, FC5 |
| RK2 | Graphical update UX (GNOME Software/Discover) unavailable or partial for bootc | M3 | FD12 |
| RK3 | Update trust misconfigured (permissive default policy; unsigned base images; install-time switch not verified) | M3, M2b | FF4, FD14 |
| RK4 | Large update downloads without rechunking; zstd:chunked unreliable | M3, M2b | FD11 |
| RK5 | Experimental composefs-native backend changes on-disk format | M3 (if adopted) | FD3 |
| RK6 | rpm-ostree client features de-prioritised | M2, M2b | FC4 |
| RK7 | Host drift and non-atomic failures increase support cost | M1 | FB4 |
| RK8 | Kernel modules (e.g., GPU drivers) break on kernel updates; Secure Boot signing | All; strongest in image models | FC7, FD13, FF5 |
| RK9 | Trademark non-compliance (use of "Fedora" wording, residual branding) | All | FF1 |
| RK10 | Fedora cadence (~6-month releases, ~13-month support) forces regular rebases | All | FA1 |
| RK11 | Documentation drift/stale Fedora docs mislead implementation | M3 | Conflicts C2, C5 |
| RK12 | Evidence on desktop derivatives is mostly tier 4 | M3 | FD14 |

## Evidence Against the Leading Alternative

The leading alternative after this research is **M3 (bootc/OCI)** for deep
investigation (see Recommendation). Evidence against it:

1. Fedora itself states it "has not yet reached true production capacity
   for the bootc toolchain" (verified) [S72]; production is targeted for
   F45, which is not yet released [FA2].
2. There is no official Fedora bootc desktop. Official Atomic Desktops
   still ship through the OSTree repository and rpm-ostree [S50, S51];
   bootc migration is only a "future" enablement in the F45 Change [S14].
3. Core desktop pieces are open on Fedora's own roadmap: GNOME Software
   "TBD", Discover "Partial", no D-Bus/unprivileged interface, local
   layering, installer and migration [S52].
4. Local package layering is incompatible with `bootc upgrade` [S57];
   host `dnf` fails [S70]. Users who need host packages are pushed to
   Flatpak/containers, which is an unresolved Wave 0.3 dependency.
5. Anaconda's `bootc` path has documented limitations (no multi-disk,
   arbitrary mount points or authenticated registries) [S74]; logically
   bound images are unsupported by Anaconda [S64]; the anaconda-iso output
   type is slated for removal in RHEL 11 [S81].
6. Trust is weak by default: permissive container policy [L4], opt-in
   enforcement [S62], official Fedora bootc images without observed cosign
   signatures [S95], Fedora infrastructure container-signing blockers
   [S94], a real-world unverified install path in a derivative [S109].
7. Update bandwidth requires extra engineering (rechunking), and
   zstd:chunked partial pulls have open failure reports [S77, S79, S80].
8. bootc is a CNCF **Sandbox** project [S55]; the native composefs
   backend and sealed images are experimental [S59, S49].
9. Fedora bootc documentation contains stale pages (F42 references, "Tech
   Preview" wording) [S67, S71], increasing implementation risk.
10. The positive desktop evidence (Universal Blue) is tier 4 and relies on
    third-party infrastructure (GitHub Actions/GHCR) [S102–S105].

Assessment: this evidence does not refute M3 as a candidate for
investigation, but it **does** refute treating M3 as ready for an Eldora
V1 decision without experiments. It also keeps M1 alive as a credible
fallback.

## Answers to the mandatory questions

**Q1 — Relevant models today.** M1 (package-based), M2 (OSTree/rpm-ostree,
classic delivery), M2b (rpm-ostree client + OCI delivery), and M3 (bootc/OCI
image mode, with sub-options M3a/M3b/M3c). See Alternatives.

**Q2 — Classification (evidence-based).**
- CURRENT: M1 (Fedora Workstation/Spins; Kiwi, image-builder, DNF5) [FB2,
  FA3]. M2 is CURRENT for Fedora Atomic Desktops delivery [FC5].
- TRANSITIONAL: M2 delivery path (CoreOS left it; Fedora's stated end state
  is OCI) [FD9, FD7]; M2b [FC4, FD9]; rpm-ostree client [FC4];
  osbuild-composer service model ("legacy service-based model") [FE1].
- STRATEGIC: M3 [FD7, FF6, FD10]; image-builder [FE1, FE3]; Konflux
  pipeline for Fedora bootc artifacts [FD7].
- LEGACY / DEPRECATED: ImageFactory (replaced by Kiwi) [S7];
  livemedia-creator for Fedora official live media (replaced by Kiwi; tool
  itself still maintained) [FB2, FB3]; lorax in composes (boot.iso until
  F46) [FB3]; bootc-image-builder (deprecated, merged) [FE2]; the
  2022–2024 plan to move Atomic Desktops to container delivery (rejected
  Change) [FC5].

**Q3 — Architectural difference.**
- *Package-based mutable host:* the unit of change is the RPM transaction
  on a live, writable root; state and OS are interleaved; no system-level
  version identity beyond package versions; rollback = inverse
  transactions (FB4).
- *OSTree/rpm-ostree:* the unit of change is a complete filesystem tree
  (commit) deployed side by side and selected at boot; `/usr` read-only,
  `/etc` merged, `/var` persistent; client may add RPM layers that produce
  a new local deployment (FC2, FC3).
- *bootc/OCI:* the unit of change is an OCI image (digest) built with
  container tooling and pulled from a registry, then deployed (currently
  via OSTree) side by side; the host is not meant to be changed locally;
  the image *is* the OS version (FD1–FD5).

**Q4 — Own identity, lifecycle and update channel without rebuilding
userspace.** All models allow own identity via replacement release/logos
packages (FF1–FF3). Own **update channel** covering the whole OS: M2
(own OSTree remote), M2b and M3 (own registry). In M1, Eldora controls its
own repository and release package, but hosts still pull most packages from
Fedora repositories and mirrors, so the "Eldora release" is a set of repo
definitions rather than a versioned whole-OS artifact (INFERENCE). None of
the models requires rebuilding Fedora packages (FD5, FB1).

**Q5 — Which model favours each property.**

| Property | Favoured by | Basis |
|---|---|---|
| Reliable rollback | M2, M2b, M3 | FC2, FD4 |
| Atomic update | M2, M2b, M3 | FC2, FD4 |
| Reproducibility | M3, M2 (exact digests/commits) | FD1, FC2 |
| Security | Image models (read-only root), conditional on signing being configured | FF4, FD3 |
| Maintenance (for Eldora team) | Contested: M1 simplest to build; image models simplest to support in the field | Trade-offs |
| Local development | M1, M3 (Containerfile/podman) | FD5 |
| CI | M3, M2b | FD14 |
| Deep desktop customization (by Eldora) | All; M3/M1 most familiar tooling | Comparison |
| Debugging | M1 | FB1, FD5 |
| Recovery | M2, M2b, M3 | FC2, FD4 |

**Q6 — Costs/limitations.** See Comparison, Risks and Evidence Against.
In short — M1: no atomic rollback, drift, field support cost. M2: own
OSTree infrastructure, de-prioritised tooling, direction away from it. M2b:
transitional client, trust configuration. M3: Fedora desktop gaps,
installer limits, signing and bandwidth engineering, registry operations,
experimental newer backends.

**Q7 — Upstream dependencies vs. Eldora-owned (survey, not design).**
- *Likely consumed from Fedora:* signed RPM packages (kernel, systemd,
  graphics, desktop stacks); Fedora signed shim/GRUB/kernel chain if
  unchanged (FF5); Fedora bootc base images or Fedora repos/comps; build
  tooling (image-builder/osbuild, Kiwi, rpm-ostree, bootc, Anaconda);
  release cadence (FA1).
- *Likely Eldora-owned:* release/identity packages (replacing
  `fedora-release*`, `fedora-logos`), os-release identity, branding;
  Eldora RPM repository and signing key (mandatory given F45 enforcement,
  FA4); image definition (Containerfile/Kiwi description/kickstart);
  update channel (repo, OSTree remote or registry) and its signing keys;
  default configuration (presets, dconf, polkit); CI/release pipeline;
  release versioning and lifecycle policy; any Eldora components.
- *Strong-coupling points:* Fedora release cadence/EOL; Fedora base image
  content sets (not officially configurable, FD5); bootc/OSTree internals;
  Secure Boot chain (modifying the kernel requires own signing, FF5);
  Fedora trademark rules (FF1); availability of Fedora infrastructure
  (mirrors, quay.io).
- *Boundaries that could preserve evolution (to investigate, not
  designed):* keep Eldora components as separately packaged units with
  their own identity; keep the image/compose definition declarative and in
  the Eldora repository; avoid patching Fedora packages; publish updates
  under an Eldora-controlled channel name so the upstream source can change
  behind it; avoid depending on rpm-ostree-only client features.

**Q8 — Risk of choosing a technology Fedora is replacing.** Yes, concrete:
- classic OSTree-repository delivery (M2) — CoreOS already stopped
  publishing to it; the Fedora end state for atomic variants is OCI
  (FD9, FD7);
- rpm-ostree as the client of the future — development focus shifted
  (FC4);
- bootc-image-builder — deprecated (FE2);
- lorax/livemedia-creator for official media — superseded by Kiwi and
  image-builder (FB2, FB3);
- osbuild-composer service model — called legacy (FE1);
- the composefs-native bootc backend is the opposite risk: new and
  experimental (FD3).

**Q9 — Decisions needed in Wave 0.1 vs. later.**
- *Wave 0.1 (needed):* composition model family (Q-0001: package-based vs.
  image-based, and which image path); system update/rollback model family
  (Q-0008); whether Eldora owns a whole-OS update channel; whether
  experimental probes are authorised before the decision.
- *Can wait (0.1B–0.1D or later):* exact base image/content set (M3a/b/c);
  registry host and build service; signing tooling; composefs backend;
  Secure Boot strategy (reuse vs. own shim); installer choice; release
  numbering/cadence details; rechunking approach.
- *Depends on other waves:* host package installation policy (Wave 0.3);
  desktop update UX (Waves 0.2/0.3); whether platform services exist
  (Wave 0.4).

**Q10 — Questions forwarded.** See Open Questions.

## Open Questions

Forwarded to **Wave 0.1B — System Image / Root Filesystem / Package
Ownership:**

1. Which base should an image-based Eldora derive from: `fedora-bootc`
   (minimal/minimal-plus/standard), a Fedora Atomic Desktop OCI image, or
   an own base via `bootc-base-imagectl`? What does each cost to maintain
   per Fedora release?
2. Exact list of Fedora packages Eldora must replace (release, identity,
   logos, repos, gpg-keys, notes) and packages it must add; how F45's move
   of repo configs to `/usr` affects this.
3. os-release strategy (`ID`, `ID_LIKE`, `VARIANT_ID`, `IMAGE_ID`,
   `IMAGE_VERSION`) and its effect on software that checks `ID=fedora`.
4. Filesystem layout policy: `/etc`, `/var`, `/opt`, `/usr/local`, home
   directories; what may be changed by users and how.
5. Host package policy: is local layering needed at all for V1 (depends on
   Wave 0.3)?
6. Kernel and kernel-module policy (GPU drivers, Secure Boot signing).
7. Trademark-compliant wording for describing the Fedora relationship
   (to be coordinated with Q-0010).

Forwarded to **Wave 0.1C — Update / Rollback / Recovery:**

1. Update trust chain end-to-end: base image verification, Eldora signing,
   `containers-policy.json`/`registries.d`, install-time enforcement,
   key rotation.
2. Rollback semantics acceptable to users given `/etc` and `/var`
   behaviour; number of retained deployments.
3. Automatic vs. user-controlled updates; staged/deferred updates; offline
   and USB updates.
4. Graphical update UX feasibility with bootc (no D-Bus interface yet).
5. Major-version rebase procedure (Fedora N → N+1) and its failure modes.
6. Recovery paths when both deployments fail; relation to installer/live
   media.
7. For a package-based fallback: is snapshot-based rollback viable and
   supportable?

Forwarded to **Wave 0.1D — Image Build / Boot / Release Pipeline:**

1. Build tool per model: image-builder (bootc/ostree), Kiwi (package
   based), Containerfile + podman; which outputs are needed (ISO, qcow2,
   raw).
2. CI/build service and registry hosting; independence from any single
   third-party platform; bandwidth and rechunking strategy.
3. Installer path: Anaconda `bootc`/`ostreecontainer` kickstart,
   WebUI, limitations and workarounds.
4. Secure Boot: reuse Fedora's signed chain vs. own shim review;
   UKI/sealed images timeline.
5. Release versioning, channels (stable/testing), and alignment with
   Fedora's cadence and EOL.
6. Reproducibility controls (pinning repositories/base digests; SBOM).

Governance observations for the Project Owner:

- The Foundation roadmap defines Wave 0.1 but not the sub-stages
  0.1A–0.1D named in the Owner's research prompt. The Owner may wish to
  record them in `FOUNDATION-ROADMAP.md`.
- Wave 0.1 exit criterion C1 requires this report to reach `REVIEWED` by a
  human reviewer.

## Recommendation

A recommendation is not a decision.

**RECOMMENDATION:** advance the following to detailed investigation in
Waves 0.1B–0.1D:

1. **Leading candidate for investigation: M3 — bootc/OCI image mode**,
   deriving from a Fedora base image (sub-options M3a/M3b/M3c to be
   compared in 0.1B), with an Eldora-controlled registry and signing.
2. **Fallback / control baseline: M1 — package-based**, built with current
   Fedora tooling (Kiwi or image-builder), with Eldora release/identity
   packages and a signed Eldora repository. It is kept as a real
   alternative, not a formality, because of the M3 desktop gaps.
3. **Do not advance M2 (classic OSTree repository delivery) as a new
   Eldora target.** M2b is noted as a transitional compatibility path
   only (e.g., if bootc client gaps require rpm-ostree on the client).
4. **Run experimental probes before any decision** (require Project Owner
   authorisation; they are research probes, not product implementation):
   - P1: derive an image from `quay.io/fedora/fedora-bootc:44` (or 45)
     with a desktop and Eldora identity; build ISO/qcow2 with image-builder;
     install in a VM with Anaconda.
   - P2: upgrade, rollback and `/etc`/`/var` behaviour across several
     updates, including an F44 → F45 rebase.
   - P3: signing end to end (sign with Eldora key, enforce policy,
     verify at install and on update).
   - P4: update size with and without rechunking.
   - P5: graphical update UX with GNOME Software/Discover on a bootc host.
   - P6: the same identity/branding and update flow for M1 (Kiwi-built
     live ISO + Eldora repo), as the comparison baseline.
   - P7: kernel-module/Secure Boot behaviour on the image model.

- **Confidence:** MEDIUM that M3 and M1 are the right pair to investigate;
  LOW for any claim that M3 is ready for Eldora V1 today.
- **Favourable evidence:** FD1, FD7, FD9, FD10, FF6 (direction and
  vendor commitment); FC2/FD4 (atomic update/rollback); FD5, FD14 (build
  model and derivative feasibility); FF2/FF3 (identity mechanisms).
- **Contrary evidence:** Evidence Against the Leading Alternative (items
  1–10).
- **Assumptions:** atomic updates/rollback are desirable for Eldora V1
  (R6, unconfirmed by the Owner); Eldora prefers owning a whole-OS update
  channel; the application model (Wave 0.3) will not require extensive
  host package installation.
- **Unknowns:** Fedora's actual F45/F46 delivery of bootc desktop pieces;
  GNOME Software/Discover support timing; signing of official Fedora base
  images; installer maturity; real update sizes; long-term status of the
  composefs-native backend.
- **Reversibility:** the recommendation is fully reversible (it selects
  what to investigate). A later model *decision* would be moderately
  reversible before release and costly after users are installed (model
  changes imply rebase or reinstall — INFERENCE).
- **Facts to verify experimentally:** probes P1–P7 above.

## Decision

NOT TAKEN — research does not decide. See the Decision Register entry for
the related questions and any resulting decision record.

## Conflicts and uncertainties

- **C1.** F44 support end: 2027-05-19 [L1] vs. 2027-06-02 [S27, tier 4].
  Local primary evidence preferred.
- **C2.** Composefs on Atomic Desktops: the F42 Change text scopes it to
  bootable-container images only [S43]; the F42 article says Atomic
  Desktops use composefs by default [S32]. An older Fedora bootc page says
  Atomic Desktops do not use composefs [S71]. Unresolved without a running
  system; treated as not material to the recommendation.
- **C3.** ModernizeBootISO: discussed as F45, now `ChangeAcceptedF46`
  (verified) [S12]. Reason for retargeting not found.
- **C4.** Whether official Fedora OCI images carry signatures via
  mechanisms other than cosign tags (lookaside, referrers) was not
  verified [S95].
- **C5.** Fedora bootc base-images documentation references F42 and "Tech
  Preview" [S67], contradicting later sources (FD7, FD10). Treated as stale.
- **C6.** The image-builder README still says the projects are expected to
  "merge eventually" while the osbuild deprecation notice and archived
  repository say the merge happened [S83 vs. S81, S82]. The later, more
  specific notice is preferred.
- **C7.** Whether "<Name>, based on Fedora" wording is permitted under the
  trademark guidelines is unresolved (FF1); it is a Q-0010 matter.
- **C8.** Kiwi's role in all Spins: "most desktop spins" [S11, tier 2];
  exact list UNVERIFIED.

## Validation performed

- **URL check (2026-09-26):** every URL in this report was requested over
  HTTP(S). All source URLs returned HTTP 200 (some Red Hat and
  freedesktop.org pages only with a default client user agent). A 200 on
  docs.fedoraproject.org/forge.fedoraproject.org may be a bot-challenge
  page; content from those hosts was read through alternative routes as
  described in "Method and limitations".
- **Verbatim spot-checks by the author** (raw page text): S12, S14, S35,
  S41, S72, S110 — marked "(verified)" where used.
- **Not verified:** mock/fedpkg details; current trademark wording beyond
  S17's 2024-12-05 content; official Fedora lifecycle page (blocked);
  signatures on official Fedora OCI images via lookaside/referrers (C4);
  F45 final release status (not yet released per S16).
- **Decision discipline:** no recommendation is recorded as a decision; no
  ADR was created; Decision remains NOT TAKEN.

## Sources

All sources accessed 2026-09-26. Tier per `docs/research/README.md`. "n/d" =
no date shown on the page.

| # | Source (title — organization) | Tier | Version / date covered | Accessed | Used for |
|---|---|---|---|---|---|
| S1 | Changes/SwitchToDnf5 — Fedora Project — https://fedoraproject.org/wiki/Changes/SwitchToDnf5 | 1 | F41; updated 2024-10-18 | 2026-09-26 | FA3 |
| S2 | Releases/43/ChangeSet — Fedora Project — https://fedoraproject.org/wiki/Releases/43/ChangeSet | 1 | F43 | 2026-09-26 | FA3 |
| S3 | Releases/44/ChangeSet — Fedora Project — https://fedoraproject.org/wiki/Releases/44/ChangeSet | 1 | F44 | 2026-09-26 | FA3, FD8 |
| S4 | Releases/45/ChangeSet — Fedora Project — https://fedoraproject.org/wiki/Releases/45/ChangeSet | 1 | F45 (entries to 2026-08) | 2026-09-26 | FA4, FD8, FE4 |
| S5 | Changes/Enforcing signature checking by default — Fedora Project — https://fedoraproject.org/wiki/Changes/Enforcing_signature_checking_by_default | 1 | F45; updated 2026-01-21 | 2026-09-26 | FA4 |
| S6 | Kickstart documentation — pykickstart — https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html | 1 | pykickstart 3.78 | 2026-09-26 | FB1, FD6 |
| S7 | Changes/KiwiBuiltCloudImages — Fedora Project — https://fedoraproject.org/wiki/Changes/KiwiBuiltCloudImages | 1 | F40; 2024-02-28 | 2026-09-26 | FB2, Q2 |
| S8 | "Is kiwi used for Fedora 42 official image builds?" — Fedora Discussion (maintainers) — https://discussion.fedoraproject.org/t/is-kiwi-used-for-fedora-42-official-image-builds/142373 | 2 | 2025-01-14/15 | 2026-09-26 | FB2 |
| S9 | Changes/EROFSforLiveMedia — Fedora Project — https://fedoraproject.org/wiki/Changes/EROFSforLiveMedia | 1 | F42; 2025-02-18 | 2026-09-26 | FB2 |
| S10 | "Custom live iso F44?" — Fedora Discussion (Fedora QA reply) — https://discussion.fedoraproject.org/t/custom-live-iso-f44/191470 | 2 | 2026-05 | 2026-09-26 | FB2 (corroboration) |
| S11 | The Fedora 45 Sausage Factory — Simon de Vlieger (image-builder developer) — https://supakeen.com/weblog/the-fedora-45-sausage-factory/ | 2 | 2026 (compose 2026-07-23) | 2026-09-26 | FE3, FE4, C8 |
| S12 | Changes/ModernizeBootISO — Fedora Project — https://fedoraproject.org/wiki/Changes/ModernizeBootISO | 1 | ChangeAcceptedF46; updated 2026-08-20 | 2026-09-26 | FB2, FB3, C3 (verified) |
| S13 | Changes/ModernizeLiveMedia — Fedora Project — https://fedoraproject.org/wiki/Changes/ModernizeLiveMedia | 1 | now F46; 2026-08-20 | 2026-09-26 | schedule slippage context |
| S14 | Changes/BuildAtomicDesktopsWithImageBuilder — Fedora Project — https://fedoraproject.org/wiki/Changes/BuildAtomicDesktopsWithImageBuilder | 1 | ChangeAcceptedF45 | 2026-09-26 | FD8, FE3 (verified) |
| S15 | Announcing Fedora Linux 45 Beta — Fedora Magazine — https://fedoramagazine.org/announcing-fedora-linux-45-beta/ | 1 | 2026-09-15 | 2026-09-26 | FA2, FE3 |
| S16 | Fedora 45 key tasks schedule — Fedora Project — https://fedorapeople.org/groups/schedule/f-45/f-45-key-tasks.html | 1 | F45 | 2026-09-26 | FA2 |
| S17 | Fedora Trademark Guidelines — Fedora Project / Red Hat — https://docs.fedoraproject.org/en-US/legal/trademarks/ | 1 | content 2024-12-05 | 2026-09-26 | FF1 |
| S18 | Remix — Fedora Project wiki — https://fedoraproject.org/wiki/Remix | 1 | 2023-11-09 | 2026-09-26 | FF1 |
| S19 | generic-release package — Fedora Packages — https://packages.fedoraproject.org/pkgs/generic-release/generic-release/ | 1 | F44–Rawhide | 2026-09-26 | FF2, FF3 |
| S20 | generic-logos package — Fedora Packages — https://packages.fedoraproject.org/pkgs/generic-logos/generic-logos/ | 1 | F44–F45 | 2026-09-26 | FF2 |
| S21 | os-release(5) — freedesktop.org / systemd — https://www.freedesktop.org/software/systemd/man/latest/os-release.html | 1 | systemd 262 | 2026-09-26 | FF3 |
| S22 | Configuring os-release and versions — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/os-release-and-versions/ | 1 | 2024-07-10 | 2026-09-26 | FF2, FF3 |
| S23 | Copr user documentation — Copr — https://docs.copr.fedorainfracloud.org/user_documentation.html | 1 | n/d | 2026-09-26 | FB5 |
| S24 | Changes/BtrfsByDefault — Fedora Project — https://fedoraproject.org/wiki/Changes/BtrfsByDefault | 1 | F33 | 2026-09-26 | FB4 |
| S25 | dnf5 history(8) — DNF5 — https://dnf5.readthedocs.io/en/latest/commands/history.8.html | 1 | latest | 2026-09-26 | FB4 |
| S26 | dnf5 system-upgrade(8) — DNF5 — https://dnf5.readthedocs.io/en/latest/commands/system-upgrade.8.html | 1 | latest | 2026-09-26 | FB4 |
| S27 | Fedora Linux — endoflife.date — https://endoflife.date/fedora | 4 | updated 2026-09-21 | 2026-09-26 | FA1, C1 (corroboration only) |
| S28 | Changes/AtomicDesktops — Fedora Project — https://fedoraproject.org/wiki/Changes/AtomicDesktops | 1 | F40; 2024-01-24 | 2026-09-26 | FC1 |
| S29 | Introducing Fedora Atomic Desktops — Fedora Magazine — https://fedoramagazine.org/introducing-fedora-atomic-desktops/ | 1 | 2024-02-09 | 2026-09-26 | FC1 |
| S30 | Fedora Atomic Desktops — Fedora Project — https://fedoraproject.org/atomic-desktops/ | 1 | current (F44) | 2026-09-26 | FC1 |
| S31 | What's new for Fedora Atomic Desktops in Fedora Linux 44 — Fedora Magazine (T. Ravier) — https://fedoramagazine.org/whats-new-fedora-atomic-desktops-in-fedora-linux-44/ | 2 | 2026-04-28 | 2026-09-26 | FC1, FD8 |
| S32 | What's new for Fedora Atomic Desktops in Fedora 42 — Fedora Magazine — https://fedoramagazine.org/whats-new-for-fedora-atomic-desktops-in-fedora-42/ | 2 | 2025-04-15 | 2026-09-26 | FC6, C2 |
| S33 | What's new for Fedora Atomic Desktops in Fedora 41 — Fedora Magazine — https://fedoramagazine.org/whats-new-for-fedora-atomic-desktops-in-fedora-41/ | 2 | 2024-11-05 | 2026-09-26 | FC5 context |
| S34 | libostree documentation (index, Deployments, Atomic upgrades, Adapting existing systems) — ostreedev — https://ostreedev.github.io/ostree/ | 1 | n/d | 2026-09-26 | FC2 |
| S35 | rpm-ostree documentation home — CoreOS — https://coreos.github.io/rpm-ostree/ | 1 | n/d | 2026-09-26 | FC3, FC4 (verified) |
| S36 | rpm-ostree Administrator handbook — CoreOS — https://coreos.github.io/rpm-ostree/administrator-handbook/ | 1 | n/d | 2026-09-26 | FC3 |
| S37 | rpm-ostree Compose server — CoreOS — https://coreos.github.io/rpm-ostree/compose-server/ | 1 | n/d | 2026-09-26 | FC3 |
| S38 | rpm-ostree ostree native containers — CoreOS — https://coreos.github.io/rpm-ostree/container/ | 1 | n/d | 2026-09-26 | M2b |
| S39 | rpm-ostree compose build-chunked-oci — CoreOS — https://coreos.github.io/rpm-ostree/build-chunked-oci/ | 1 | n/d | 2026-09-26 | FD11 |
| S40 | rpm-ostree releases — CoreOS (GitHub page, read as document) — https://github.com/coreos/rpm-ostree/releases | 1 | to v2026.3 (2026-09-10) | 2026-09-26 | FC4 |
| S41 | Changes/OstreeNativeContainerStable — Fedora Project — https://fedoraproject.org/wiki/Changes/OstreeNativeContainerStable | 1 | Change-Rejected banner | 2026-09-26 | FC5 (verified) |
| S42 | Changes/DNFAndBootcInImageModeFedora — Fedora Project — https://fedoraproject.org/wiki/Changes/DNFAndBootcInImageModeFedora | 1 | F41; 2024-10-02 | 2026-09-26 | FD5 context |
| S43 | Changes/ComposefsAtomicDesktops — Fedora Project — https://fedoraproject.org/wiki/Changes/ComposefsAtomicDesktops | 1 | F42 | 2026-09-26 | FC6, C2 |
| S44 | Changes/CoreOSOstree2OCIUpdates — Fedora Project — https://fedoraproject.org/wiki/Changes/CoreOSOstree2OCIUpdates | 1 | F42; 2025-02-17 | 2026-09-26 | FD9 |
| S45 | Changes/CoreOSStopPublishingOSTree — Fedora Project — https://fedoraproject.org/wiki/Changes/CoreOSStopPublishingOSTree | 1 | F43; 2025-07-03 | 2026-09-26 | FD9 |
| S46 | Changes/BuildFCOSUsingContainerfile — Fedora Project — https://fedoraproject.org/wiki/Changes/BuildFCOSUsingContainerfile | 1 | F43; 2025-08-06 | 2026-09-26 | FD9 |
| S47 | Fedora Linux 43 is here! — Fedora Magazine — https://fedoramagazine.org/announcing-fedora-linux-43/ | 1 | 2025-10-28 | 2026-09-26 | FD9 |
| S48 | silverblue-docs (archived) — Fedora Silverblue (GitHub page, read as document) — https://github.com/fedora-silverblue/silverblue-docs | 1 | archived 2026-01-09 | 2026-09-26 | FC1, FC7 |
| S49 | Sealed Atomic Desktops test images — Fedora Magazine — https://fedoramagazine.org/sealed-atomic-desktops-test-images/ | 2 | 2026-04-28 | 2026-09-26 | FD8 |
| S50 | Updates, upgrades and rollbacks — Fedora Atomic Desktops docs — https://docs.fedoraproject.org/en-US/atomic-desktops/updates-upgrades-rollbacks/ | 1 | n/d (F44) | 2026-09-26 | FC5 |
| S51 | ci-test ("Unofficial Atomic Desktops builds") — Fedora ostree SIG (GitLab page) — https://gitlab.com/fedora/ostree/ci-test | 2 | n/d | 2026-09-26 | FC5 |
| S52 | Roadmap to Fedora Bootable Containers (#26) — Fedora Atomic Desktops SIG — https://forge.fedoraproject.org/atomic-desktops/tracker/issues/26 | 2 | opened 2024-05-13, open | 2026-09-26 | FD8, FD12 |
| S53 | bootc — bootc project — https://bootc.dev/bootc/ | 1 | n/d (live) | 2026-09-26 | FD1 |
| S54 | bootc v1.1.0 release — bootc-dev (GitHub page) — https://github.com/bootc-dev/bootc/releases/tag/v1.1.0 | 1 | 2024-10-17 | 2026-09-26 | FD1 |
| S55 | bootc — CNCF — https://www.cncf.io/projects/bootc/ | 1 | accepted 2025-01-21 | 2026-09-26 | FD2 |
| S56 | bootc releases — bootc-dev (GitHub page) — https://github.com/bootc-dev/bootc/releases | 1 | to 1.16.13 | 2026-09-26 | FD1 |
| S57 | Relationships — bootc — https://bootc.dev/bootc/relationships.html | 1 | n/d | 2026-09-26 | FD3 |
| S58 | bootc book (print view) — bootc — https://bootc.dev/bootc/print.html | 1 | n/d | 2026-09-26 | FD3, FD4, FF4 |
| S59 | Experimental composefs backend — bootc — https://bootc.dev/bootc/experimental-composefs.html | 1 | n/d | 2026-09-26 | FD3 |
| S60 | Filesystem — bootc — https://bootc.dev/bootc/filesystem.html | 1 | n/d | 2026-09-26 | FD4 |
| S61 | Managing upgrades — bootc — https://bootc.dev/bootc/upgrades.html | 1 | n/d | 2026-09-26 | FD4 |
| S62 | bootc-switch(8) — bootc — https://bootc.dev/bootc/man/bootc-switch.8.html | 1 | n/d | 2026-09-26 | FF4 |
| S63 | bootc install — bootc — https://bootc.dev/bootc/bootc-install.html | 1 | n/d | 2026-09-26 | FD6 |
| S64 | Logically bound images — bootc — https://bootc.dev/bootc/logically-bound-images.html | 1 | n/d | 2026-09-26 | FD6 |
| S65 | Registries and offline updates — bootc — https://bootc.dev/bootc/registries-and-offline.html | 1 | n/d | 2026-09-26 | update infrastructure |
| S66 | Auto-updates and manual rollbacks — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/auto-updates/ | 1 | n/d | 2026-09-26 | FD4 |
| S67 | Base images — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/base-images/ | 1 | 2024-06-08 (stale) | 2026-09-26 | C5 |
| S68 | fedora/bootc/base-images README — Fedora (GitLab page) — https://gitlab.com/fedora/bootc/base-images | 1 | n/d (lists F43) | 2026-09-26 | FD5 |
| S69 | Building from scratch — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/building-from-scratch/ | 1 | n/d | 2026-09-26 | FD5 |
| S70 | Using dnf — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/dnf/ | 1 | n/d | 2026-09-26 | FD5 |
| S71 | Linux desktops — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/linux-desktops/ | 1 | n/d (stale) | 2026-09-26 | C2 |
| S72 | Initiatives/Image Mode, Phase 2 (2026) — Fedora Council — https://fedoraproject.org/wiki/Initiatives/Image_Mode,_Phase_2_(2026) | 1 | 2026 | 2026-09-26 | FD7, FF6 (verified) |
| S73 | F44 Change Proposal: Using Konflux for bootc-Based Artifacts — Fedora Discussion — https://discussion.fedoraproject.org/t/f44-change-proposal-using-konflux-for-bootc-based-artifacts-selfcontained/179522 | 1 | 2026-01 | 2026-09-26 | FD7, FE3 |
| S74 | Introducing the new bootc kickstart command in Anaconda — Fedora Magazine — https://fedoramagazine.org/introducing-the-new-bootc-kickstart-command-in-anaconda/ | 2 | 2025-12-31 | 2026-09-26 | FD6 |
| S75 | Introducing image mode for RHEL (RHEL 10) — Red Hat — https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/introducing-image-mode-for-rhel | 1 | RHEL 10 | 2026-09-26 | FD10 |
| S76 | Integrating third-party drivers in image mode — Red Hat — https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/integrating-third-party-drivers-in-image-mode-for-rhel | 1 | RHEL 10 | 2026-09-26 | FD13 |
| S77 | Reduce bootc system update size — Red Hat Developer — https://developers.redhat.com/articles/2025/11/03/reduce-bootc-system-update-size | 2 | 2025-11-03 | 2026-09-26 | FD11 |
| S78 | chunkah README — CoreOS (GitHub page) — https://github.com/coreos/chunkah | 1 | n/d | 2026-09-26 | FD11 |
| S79 | zstd:chunked issues (#509) — bootc-dev (GitHub page) — https://github.com/bootc-dev/bootc/issues/509 | 2 | opened 2024-05-03, open | 2026-09-26 | FD11 |
| S80 | composefs backend zstd:chunked pull failure (#2408) — bootc-dev (GitHub page) — https://github.com/bootc-dev/bootc/issues/2408 | 2 | opened 2026-08-24, open | 2026-09-26 | FD11 |
| S81 | Deprecation notice — bootc-image-builder — osbuild — https://osbuild.org/docs/bootc/deprecation-notice/ | 1 | n/d (2026) | 2026-09-26 | FE2 |
| S82 | bootc-image-builder repository (archived) — osbuild (GitHub page) — https://github.com/osbuild/bootc-image-builder | 1 | archived 2026-06-18 | 2026-09-26 | FE2 |
| S83 | image-builder README — osbuild (GitHub page) — https://github.com/osbuild/image-builder | 1 | n/d | 2026-09-26 | FE1, C6 |
| S84 | On-premises overview — osbuild — https://osbuild.org/docs/on-premises/overview/ | 1 | n/d | 2026-09-26 | FE1 |
| S85 | image-builder usage — osbuild — https://osbuild.org/docs/developer-guide/projects/image-builder/usage/ | 1 | n/d | 2026-09-26 | FE1 |
| S86 | Changes/KojiLocalImageBuilder — Fedora Project — https://fedoraproject.org/wiki/Changes/KojiLocalImageBuilder | 1 | F43 | 2026-09-26 | FE3 |
| S87 | F44 Change Proposal: KojiServiceImageBuilderRemoval — Fedora devel list — https://www.mail-archive.com/devel@lists.fedoraproject.org/msg209354.html | 1 | 2025-09-25 | 2026-09-26 | FE3 |
| S88 | lorax package — Fedora Packages — https://packages.fedoraproject.org/pkgs/lorax/lorax/ | 1 | F43–Rawhide | 2026-09-26 | FB3 |
| S89 | pungi package (Rawhide) — Fedora Packages — https://packages.fedoraproject.org/pkgs/pungi/pungi/fedora-rawhide.html | 1 | 4.14.0 | 2026-09-26 | FE3 |
| S90 | F45 Change: Anaconda WebUI Fedora Atomic — Fedora devel-announce — https://www.mail-archive.com/devel-announce@lists.fedoraproject.org/msg03814.html | 1 | 2026-07-22 | 2026-09-26 | FE4 |
| S91 | Fedora security / package signing keys — Fedora Project — https://fedoraproject.org/security/ | 1 | live | 2026-09-26 | FF4 |
| S92 | ostree-sign(1) — ostreedev — https://ostreedev.github.io/ostree/man/ostree-sign.html | 1 | n/d | 2026-09-26 | FF4 |
| S93 | fedora-repos `fedora.conf` (OSTree remote) — Fedora dist-git — https://src.fedoraproject.org/rpms/fedora-repos/raw/rawhide/f/fedora.conf | 1 | rawhide | 2026-09-26 | FF4 |
| S94 | siguldry PR #188 "Document Container Signing with Cosign" — Fedora Infrastructure (GitHub page) — https://github.com/fedora-infra/siguldry/pull/188 | 2 | merged 2026-04-10 | 2026-09-26 | FF4 |
| S95 | Quay.io tag listing for quay.io/fedora/fedora-bootc — Quay.io (public API, read-only observation) — https://quay.io/api/v1/repository/fedora/fedora-bootc/tag/ | 1 (observation) | 2026-09-26 | 2026-09-26 | FF4, C4 |
| S96 | Signing keys and updates — Fedora CoreOS docs — https://docs.fedoraproject.org/en-US/fedora-coreos/update-barrier-signing-keys/ | 1 | 2026-01-09 | 2026-09-26 | FF4 |
| S97 | Fedora CoreOS tracker #2218 — CoreOS (GitHub page) — https://github.com/coreos/fedora-coreos-tracker/issues/2218 | 2 | 2026-09-05 | 2026-09-26 | FF4 context |
| S98 | Secureboot — Fedora Project wiki — https://fedoraproject.org/wiki/Secureboot | 1 | 2020-02-13 (old) | 2026-09-26 | FF5 |
| S99 | "bootc: how can I sign shim and kernel with own keys" — Fedora Discussion (T. Ravier reply) — https://discussion.fedoraproject.org/t/bootc-how-can-i-sign-shim-and-kernel-with-own-keys/169474 | 2 | 2025-11-04 | 2026-09-26 | FF5 |
| S100 | shim-review README — rhboot (GitHub page) — https://github.com/rhboot/shim-review | 1 | live (mentions 2026-06-27) | 2026-09-26 | FF5 |
| S101 | Objective review: Immutable variants are the majority of Fedora Linux in use — Fedora Discussion — https://discussion.fedoraproject.org/t/objective-review-immutable-variants-are-the-majority-of-fedora-linux-in-use/79288 | 2 | 2023-03-20 | 2026-09-26 | FF6 |
| S102 | Universal Blue — Universal Blue — https://universal-blue.org/ | 4 | n/d | 2026-09-26 | FD14 |
| S103 | Bluefin Administrator's Guide — Project Bluefin — https://docs.projectbluefin.io/administration/ | 4 | n/d | 2026-09-26 | FD14 |
| S104 | Bazzite updating guide — Bazzite — https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/updating_guide/ | 4 | 2026-08-19 | 2026-09-26 | FD14 |
| S105 | image-template README — Universal Blue (GitHub page) — https://github.com/ublue-os/image-template | 4 | n/d | 2026-09-26 | FD14 |
| S106 | Ultramarine download / bootc README — Ultramarine Linux — https://ultramarine-linux.org/download/ ; https://github.com/Ultramarine-Linux/bootc | 4 | UM 44 | 2026-09-26 | FB6 |
| S107 | Nobara Project — Nobara — https://nobaraproject.org/ | 4 | n/d | 2026-09-26 | FB6 |
| S108 | gnome-software-plugin-bootc (third-party experiment) — individual (GitHub page) — https://github.com/ramonmsilvabr/gnome-software-plugin-bootc | 4 | n/d | 2026-09-26 | FD12 corroboration |
| S109 | finpilot #356 install-time bootc switch unverified — Project Bluefin (GitHub page) — https://github.com/projectbluefin/finpilot/issues/356 | 4 | 2026-09-11 | 2026-09-26 | FD14, RK3 |
| S110 | Releases/42/ChangeSet ("Anaconda WebUI for Fedora Workstation by default") — Fedora Project — https://fedoraproject.org/wiki/Releases/42/ChangeSet | 1 | F42 | 2026-09-26 | FE4 |

Tier-4 sources are used only for corroboration; no key claim relies on them
alone. Where a key claim relies on a tier-2 source, a tier-1 source is also
cited or the reliance is stated.
