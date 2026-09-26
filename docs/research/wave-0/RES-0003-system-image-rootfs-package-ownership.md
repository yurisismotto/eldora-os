# RES-0003 — System Image, Root Filesystem and Package Ownership (Wave 0.1B)

| Field | Value |
|---|---|
| ID | RES-0003 |
| Status | REVIEWED |
| Wave | 0.1 (stage 0.1B — System Image / Root Filesystem / Package Ownership) |
| Related questions | Q-0001, Q-0008 (structural consequences only) |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): planning; documentary research through four delegated research sub-agents (filesystem and configuration; image anatomy and package ownership; administration, development and application boundary; failure modes, security and reproducibility); verbatim spot-checks; trivial read-only local observations; drafting. No human has reviewed this report yet. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: accepted as research evidence — see [review record](../../project/reviews/WAVE-0.1B-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (overall); per-claim confidence stated where relevant |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records (ADR, GDR, LDR, BDR)
> accepted by the Project Owner. See `docs/research/README.md` and
> `docs/project/DECISION-LIFECYCLE.md`.

Labels: **FACT**, **HYPOTHESIS**, **REQUIREMENT**, **ALTERNATIVE**,
**INFERENCE**, **RECOMMENDATION**, **DECISION** (always NOT TAKEN).
`[Sn]` = Sources; `[Ln]` = local observations; `RES-0001/…`, `RES-0002/…`
= facts in earlier reports.

## Question

1. How should Eldora OS V1 structure and own its base system, root
   filesystem, system image, configuration and packages so that it can build
   its own desktop platform on Fedora without unnecessarily taking on the
   whole responsibility of maintaining a distribution?
2. What exactly belongs to Eldora OS, what belongs to Fedora/upstream, what
   is machine state, and what belongs to the user and applications?

## Context and fixed premises

Treated as existing decisions and not reopened: Linux kernel (OB-0001);
Eldora OS V1 is Fedora-derived and Fedora is the principal upstream family
(OB-0004, confirmed D13, interpreted D20); CentOS Stream/EPEL are not the
base; Eldora aims to be its own desktop platform. Not decided and not
treated as chosen: package-based host, bootc, OCI image, rpm-ostree/OSTree,
filesystem layout, read-only/immutable/writable root, update, rollback,
installer, recovery, compositor, desktop, toolkit, application model
(Flatpak, Snap, AppImage, containers, Eldora bundles), Secure Boot,
bootloader, partition layout. bootc/OCI (M3) is a CANDIDATE, not SELECTED;
package-based (M1) remains valid; OSTree/rpm-ostree (M2) is a reference.

## Scope

Ownership map; root filesystem and path semantics; `/etc` and configuration
ownership; `/var` and machine state; package ownership; what an "Eldora
image" would be under M3; derivation strategies; mutability terminology;
local administration; development environments; the OS/application
boundary; failure modes, security and reproducibility **only** at the level
of structural consequences.

## Out of Scope

Choosing a model; update/rollback/recovery design (Wave 0.1C); build
pipeline, CI, registry and boot architecture (Wave 0.1D); application model
(Wave 0.3); platform layers (Wave 0.4); defining an Eldora filesystem layout;
executing probes.

## Method and limitations

- Documentary research on 2026-09-26 via four research sub-agents, followed
  by the author's verbatim spot-checks of the claims the conclusions depend
  on most (marked "(verified)").
- Trivial read-only observations of the Project Owner's Fedora 44
  Workstation (package-based) as **context only**; it is not treated as
  Eldora. No sudo, installs, VMs, image pulls or builds.
- No Git/GitHub remote operation. Public github.com, gitlab.com and raw
  document pages were read as documents. **Disclosure:** one sub-agent ran
  `skopeo list-tags quay.io/fedora/fedora-bootc` (an anonymous, read-only
  registry tag listing, not GitHub and not the Eldora repository) to check
  for signature tags; this exceeded the sub-agent's "no API" instruction and
  is recorded here for transparency.
- Many upstream documentation pages (bootc book, Fedora bootc docs) carry no
  page date; they were read live on 2026-09-26. Some Fedora bootc pages are
  stale (reference `fedora-bootc:42`; one page last updated 2024-06-08).
  Some quotations were obtained through a summarizing fetch tool; those not
  marked "(verified)" should be re-checked before citation in a decision
  record.
- Nothing was tested on a running bootc, OSTree or Eldora system;
  behaviour claims are documentary.

## Local observations (context only)

Fedora 44 Workstation, systemd 259.9, rpm 6.0.2, dnf5 5.4.5, read-only
commands only.

| ID | Observation |
|---|---|
| L1 | `/bin`, `/lib`, `/lib64` are symlinks into `/usr`; `/usr/sbin` → `bin` (bin/sbin unification). |
| L2 | `rpm --eval %_dbpath` → `/usr/lib/sysimage/rpm` (package database lives under `/usr`). |
| L3 | 2321 installed packages; 1499 files declared as RPM `%config`. |
| L4 | No `.rpmnew`/`.rpmsave` files found in the readable part of `/etc` (unreadable directories not inspected). |
| L5 | No `/usr/etc` (package-based host); `/usr/share/factory/etc` exists (vendor copies for some files). |
| L6 | 80 `tmpfiles.d` and 60 `sysusers.d` snippets in `/usr/lib`. |
| L7 | `/etc/containers/policy.json` default is `insecureAcceptAnything` (from RES-0001/L4; still true). |

## Facts

### Filesystem and configuration

- **FS1.** bootc: with composefs "the entire / is a read-only filesystem";
  the image is fully mutable while built as a container and read-only when
  deployed [S1, S2].
- **FS2.** bootc `/etc` is "mutable persistent state by default", merged
  3-way at update ("The new default /etc is used as a base"; "The diff
  between current and previous /etc is applied"); enabling `etc.transient`
  is "supported (and encouraged)" [S1]. `/usr/etc` is generated client side
  and must not be populated by builders (lint check) [S1].
- **FS3.** The OSTree merge is whole-file: "as soon as you modify or add a
  file in /etc, this file will be propagated forever as is" [S7]; the
  upstream source removes locally deleted files from the new `/etc` and
  ignores xattrs in the diff, so a label-only change does not persist unless
  content also changes [S9].
- **FS4.** (verified) Image content in `/var` "acts like a Docker VOLUME
  /var" — unpacked only at initial install; later image changes to `/var`
  are not applied; tmpfiles.d/`StateDirectory=` are recommended, and lint
  checks missing tmpfiles entries [S1].
- **FS5.** (verified) Rollback: "any changes made to files in the /etc
  directory won't carry over to the rolled-back deployment" because rollback
  reorders existing deployments [S1, S13].
- **FS6.** (verified) Users/groups: a locally modified `/etc/passwd` means
  "new changes in the container image (such as users from new packages) will
  not appear on subsequent updates"; bootc recommends systemd-sysusers,
  `DynamicUser=yes` or `/usr`-canonical user records [S4]. `usermod -aG` for
  groups defined in `/usr/lib/group` "exits 0 but does not add the member"
  [S4]; UID/GID drift is a documented problem under discussion [S31, tier 3].
- **FS7.** (verified) "systemd-confext and systemd-sysext are not currently
  supported on bootc-managed systems" (overlay stacking depth limits) [S1].
- **FS8.** Path treatment differs by model (details in Part 2): OSTree
  recommends symlinks `/home→/var/home`, `/opt→/var/opt`, `/srv→/var/srv`,
  `/root→/var/roothome`, `/usr/local→/var/usrlocal`, `/mnt→/var/mnt` [S6];
  bootc recommends `/usr/local` as a regular (image-owned) directory and
  treats `/opt` as image-owned and read-only, with opt-in state overlays or
  symlinks [S1]; a bootc maintainer states Fedora bootc ships `/opt` as a
  regular directory [S15, tier 2].
- **FS9.** Fedora Atomic Desktops: `/` and `/usr` read-only; `/etc` and
  `/var` writable; `/sysroot` read-only since F37; `/boot` and `/boot/efi`
  writable [S14].
- **FS10.** M1 configuration: Fedora packaging requires `%config(noreplace)`
  for configuration files and forbids `%config` under `/usr` ("/usr is deemed
  to not contain configuration files in Fedora") [S16]; RPM writes `.rpmnew`
  when a modified file exists [S17]; Fedora's upgrade guide points to
  `rpmconf -a` and warns that reverting files can change behaviour (e.g.,
  sshd defaults) [S18]. No automatic merge exists.
- **FS11.** (verified) Fedora is moving vendor configuration out of `/etc`:
  F45 relocates packaged repository definitions to `/usr/share/dnf5/repos.d`
  and keys to `/usr/share/pki/rpm-gpg` so users can "trivially identify
  local changes and undo them", and says this is "necessary to simplify how
  derivatives handle repository definitions" (`ChangeAcceptedF45`) [S19].
  The RPM database moved to `/usr/lib/sysimage/rpm` in F36 [S20, L2].
- **FS12.** UAPI.6 (Configuration Files Specification v1.0) enables the
  "hermetic-usr pattern, where all vendor files are shipped in the vendor
  tree itself (/usr/)", with precedence `/usr` < `/run` < `/etc` and
  drop-ins [S22]; UAPI.9 (work in progress) and systemd `file-hierarchy(7)`
  describe `/usr` as usually read-only and `/usr/share/factory/etc` as
  pristine vendor configuration [S21, S23]; tmpfiles.d can copy from the
  factory tree [S24]. FHS 3.0: `/usr` is shareable read-only data; `/var`
  holds variable data [S25].
- **FS13.** M2 regression example (2026): an rpm-ostree 2026.3 update caused
  SELinux label mismatches on upgraded systems whose legacy
  `/var/lib/selinux` layout persisted (open issue, 2026-09-20) [S32, tier 2].

### Image anatomy and package ownership

- **IM1.** An OCI image is an image manifest (per platform), an optional
  index, a configuration and content-addressed filesystem layers; manifests
  can reference other artifacts via `subject` (referrers API, used for
  signatures and SBOMs) [S26, S27].
- **IM2.** A bootable bootc image additionally requires `LABEL
  containers.bootc=1`, the kernel at `/usr/lib/modules/$kver/vmlinuz` with
  an `initramfs.img` generated at build time, no content in `/boot`, a
  `/sysroot` directory and base-image content [S3]; `bootc container lint`
  performs static checks during the build [S3]. Container metadata such as
  `ENV` is ignored when booted [S10].
- **IM3.** Not in the image or not updated by it: `/var` after install
  (FS4), locally modified `/etc` (FS2), local users (FS6), install-time
  kernel arguments ("unmanaged" machine state) [S3, S11], secrets ("The
  bootc project does not currently include one single opinionated mechanism
  for secrets") [S3], host keys and machine identity, and bootloader
  binaries on the ESP (bootloader updates are not automatic) [S3, S12].
- **IM4.** Fedora base images: `quay.io/fedora/fedora-bootc` (standard);
  `minimal` and `minimal-plus` content sets; `minimal-plus` is "intended to
  be the shared base used by all image-based Fedora variants" but "is not
  exposed as a stable interface" [S28]. Derived images use `dnf` at build
  time exactly as in application containers; Fedora warns against `dnf -y
  update` in derived builds for kernel/bootloader reasons [S10].
- **IM5.** Branding in images: `dnf -y swap fedora-release generic-release`
  and forking `generic-release`; `IMAGE_VERSION` recommended [S29].
- **IM6.** On a deployed bootc host, `dnf install` errors (read-only) [S10];
  DNF5 offers `--transient` / `persistence=transient`, "Only applicable on
  bootc systems" (verified), with `/etc` and `/var` changes still persisting
  [S30]; `bootc usr-overlay` is a RAM-backed transient overlay [S1];
  persistent host-side dnf layering is future work [S10]. (verified) "any
  local state mutations such as package layering … will cause bootc upgrade
  to error out"; bootc "takes a relatively hard stance that system state
  should come from a container image" [S5]; upstream expects that a future
  podman binding "will … break compatibility with rpm-ostree" [S5].
- **IM7.** Persistent local change on bootc is done by building a derived
  image locally and switching to it (`bootc switch --transport
  containers-storage`); copying the booted image is experimental [S1].
- **IM8.** F45 enforces RPM signature verification by default
  (`%_pkgverify_level` `all`) — applies to Eldora RPMs installed on M1 hosts
  and during M3 image builds [RES-0001/FA4; S33].
- **IM9.** M1 mechanics relevant to ownership: `dnf5 swap` (single
  transaction), vendor-change policy, `versionlock`, offline transactions
  [S34]; Epoch "must never be removed or decreased" [S35]; default services
  via systemd presets [S36].
- **IM10.** Downstream corroboration (tier 3–4): Universal Blue builds
  kernel modules centrally as daily "akmods" OCI images with a custom MOK
  key and pins kernels when modules cannot build [S37]; its image template
  makes cosign signing mandatory [S38].

### Administration, development and application boundary

- **AD1.** rpm-ostree (M2) states a goal to "empower users and system
  administrators … you are root on your own computer"; layering is
  persistent but "sparingly" recommended, needs reboot unless `apply-live`
  [S39, S40]; `apply-live` changes to `/etc` are not transactional [S41].
- **AD2.** Toolbx is designed for development "without having to install
  software on the host" with shared home, D-Bus, journal and devices;
  "SELinux label separation is disabled"; it makes no security promise
  beyond the host [S42]. Fedora Atomic guidance: Flatpak for GUI apps,
  Toolbx for CLI, layering for system-level packages [S43].
- **AD3.** Bluefin separates the OS and developer environment "explicitly
  and purposely"; Homebrew for CLI tools; host package addition discouraged
  [S44, tier 1 for that project]. KDE Linux warns Homebrew packages "can
  override system libraries" and uses sysext for developers [S45, tier 2].
- **AD4.** Reported friction (tier 2–3): IDE integration with toolboxes and
  Flatpak IDEs on Atomic desktops (2024–2025) [S46, S47]; kernel modules on
  bootc must be built at image build time against the image kernel [S48,
  tier 3].
- **AD5.** Application boundary precedents: Fedora Atomic ships most GUI
  apps via Flatpak with some (Firefox) in the image [S43]; KDE Linux keeps
  deeply integrated system apps (Dolphin, Konsole, System Settings,
  Discover) in the base image because "Flatpak is currently a pretty poor
  technology for system-level apps" [S45]. XDG Base Directory places user
  config, data and state under `$HOME` [S49]; desktop entries and AppStream
  define integration points independent of packaging technology [S50,
  S51].
- **AD6.** systemd factory reset exists (`factory-reset.target` since v250,
  `systemd-factory-reset` since v258, repart `FactoryReset=`) [S52]; bootc
  `install reset` is experimental and leaves the old stateroot on disk [S1];
  a GNOME OS developer argues bootc cannot securely wipe data without also
  erasing the OS (a bootc maintainer disputes the threat model) [S53, tier
  2].

### Failure, security and reproducibility

- **FR1.** OSTree: "If the system crashes or you pull the power, you will
  have either the old system, or the new one" [S6]; bootc stages updates
  and finalizes at shutdown; failures are detected by
  `ostree-boot-complete.service`; the composefs-native backend has no
  equivalent and no boot counting yet [S1].
- **FR2.** bootc rollback is manual by default and can be undone by the
  default auto-update timer; Fedora bootc images auto-update by default
  [S1, S13].
- **FR3.** M1: Fedora calls every system upgrade "potentially risky";
  recovery tools are `rpm --rebuilddb`, `distro-sync`, and duplicate
  removal [S18]; older kernels are retained (DNF5 `installonly_limit` default 3, local man page read by a sub-agent);
  DNF5 offline transactions run in a minimal environment [S34]. No primary
  source documents RPM behaviour on power loss (UNVERIFIED).
- **FR4.** (verified) Security defaults: "fsverity is not enabled by
  default" on the default backend; only composefs with sealed UKIs verifies
  the root mount; `/etc` "can easily contain arbitrary executable code"
  and is unaffected by fsverity [S1]; "It is not a vulnerability in bootc
  that signatures are not required by default" [S1]; Fedora's default
  container policy accepts anything [L7]; no cosign-style signature tags
  were observed for `quay.io/fedora/fedora-bootc` (referrers API not
  checked) [RES-0001/FF4; sub-agent observation].
- **FR5.** Integrity sealing on Fedora exists only as unofficial test images
  (April 2026) [S54].
- **FR6.** Reproducibility inputs: ~90% of Fedora package builds are
  reproducible with a 99% goal accepted for F46 [RES-0002/FE9]; podman
  supports `--timestamp`/`--source-date-epoch` for stable image digests
  [S55]; bootc notes initramfs regeneration and an OSTree timestamp bug as
  obstacles and warns that cache hits are not reproducibility [S1]; the DNF5
  manifest (lockfile) plugin is "experimental" [S56]; Konflux RPM
  lockfiles become inconsistent as repositories move [S57]; no official
  dated Fedora repository snapshots were found (UNVERIFIED negative).

## Hypotheses

- **H1.** Most of the ownership discipline Eldora needs (hermetic `/usr`,
  `/etc` for local overrides only, sysusers/tmpfiles, Eldora-owned RPMs) is
  model-independent and would keep a later switch between M1 and M3 cheap.
  (Supported by FS10–FS12, IM8; untested for Eldora.)
- **H2.** M3's lack of a supported persistent host escape hatch conflicts
  with "Yours" for power users unless user-level mechanisms (containers,
  `$HOME` tools, local derived images) are good enough. (Unverified; AD2–AD4.)
- **H3.** `/etc` and users/groups drift remain the main reproducibility
  gap in *both* models. (Supported by FS2–FS6, FS10.)

## Requirements

Derived from repository documents and the Owner's 0.1B brief (candidate
criteria, not new owner requirements): own platform identity (OB-0004,
V1-VISION); reuse mature Fedora infrastructure; "Simple. Powerful. Yours."
(OB-0003 is a provisional tagline — used here only as a design heuristic,
not a requirement); small team (RES-0002 profile G11); avoid unnecessary
coupling (RISK-0004).

## Alternatives

| ID | Model | Treatment in this report |
|---|---|---|
| M1 | Fedora package-based mutable host | Deep comparison |
| M3 | Fedora-derived bootc/OCI system image | Deep comparison |
| M2 | rpm-ostree/OSTree (incl. RES-0001's M2b: rpm-ostree client over OCI) | Reference and control; see "Status of M2" |

## Part 1 — System ownership map

Categories: **UP** upstream-owned; **FE** Fedora-owned; **EL**
Eldora-owned; **MS** machine state; **US** user-owned; **AP**
application-owned; **ND** shared / needs decision. This is a
responsibility model for later decisions, not an architecture.

| Class | Primary owner | Notes (M1 / M3 differences) |
|---|---|---|
| Linux kernel | FE (UP) | Consume Fedora kernel; own kernel only with own Secure Boot chain (RES-0001/FF5). M3: kernel is part of the image. |
| Kernel modules (in-tree) | FE | Shipped with kernel. |
| Out-of-tree/proprietary modules | ND | M1: built on host (akmods). M3: built into image at build time [IM10, AD4]. RISK-0002. |
| Firmware | FE (UP) | Split packages (RES-0002/FE6). |
| initramfs | FE tooling; EL config | M1: generated on host. M3: generated at build time, part of image [IM2]. |
| Boot artifacts / bootloader | FE packages; ND for update policy | M3: bootloader not updated automatically [IM3] → 0.1C/0.1D. |
| Base userspace, glibc, systemd, udev, D-Bus | FE (UP) | Consume without fork. |
| Networking, Bluetooth, audio infrastructure | FE (UP) | Consume; configuration defaults may be EL. |
| Graphics stack, Mesa, Wayland libraries | FE (UP) | Consume; freshness is Fedora's strength (RES-0002). |
| GPU drivers (open) | FE (UP) | In kernel/Mesa. |
| Proprietary drivers | ND (third party) | RISK-0002. |
| Filesystem/storage tooling | FE | Consume. |
| Security infrastructure, SELinux policy | FE policy; EL additions; MS local modules | Eldora components may need policy modules (EL). Local policy changes are machine state and drift [FS13, FR4]. |
| Certificates / trust stores | FE bundle; MS local anchors | Local anchors in `/etc/pki/ca-trust/source/anchors` are machine state. |
| Package database | FE mechanism; content follows OS owner | Lives in `/usr` [L2, FS11]; in M3 it describes the image. |
| System repositories | FE (Fedora repos); EL (Eldora repo) | F45 moves repo definitions to `/usr` [FS11]. |
| System configuration defaults | EL (where Eldora differs) over FE defaults | Ship in `/usr` (hermetic pattern) [FS12]. |
| Local system configuration | MS | `/etc` overrides only (both models). |
| Eldora System Services (hypothesis, Q-0004) | EL | Would be Eldora RPMs/image content. |
| Future Broker / Platform APIs (hypothesis) | EL | Same; not assumed to exist. |
| Desktop shell/compositor | EL or UP (undecided, Q-0002) | OS component either way (AD5). |
| Eldora system applications | EL | Deeply integrated ones behave as OS components (AD5). |
| Third-party applications | AP | Outside the OS (model undecided, Q-0003). |
| User-installed applications | US/AP | Outside the OS. |
| User configuration and data | US | `$HOME` (XDG) [AD5]. |
| Machine-local persistent state | MS | `/var`, machine-id, host keys, hostname, network connections. |
| Logs | MS | `/var/log`, journal. |
| Secrets | US (keyrings) / MS (host keys, credentials) | No bootc-wide mechanism [IM3]; TPM binding interacts with image changes (0.1C). |
| Recovery artifacts | ND | 0.1C. |

## Part 2 — Root filesystem

| Path | M1 (package-based) | M2 (OSTree / Atomic Desktops) | M3 (Fedora bootc, default backend) | Imposed / recommended / conventional |
|---|---|---|---|---|
| `/` | rw, persistent | ro | ro (composefs) [FS1] | M2/M3: imposed |
| `/usr` | rw for RPM; FHS read-only by policy | ro, image-owned | ro, image-owned; transient overlay only [IM6] | M2/M3 imposed; M1 conventional |
| `/etc` | rw, persistent; per-file RPM logic, no merge [FS10] | rw per deployment; 3-way merge [FS2–FS3] | same as M2; optional transient `/etc` [FS2] | merge imposed in M2/M3 |
| `/usr/etc` | absent [L5] | internal image defaults | internal; builders must not populate [FS2] | imposed |
| `/var` | rw, persistent | rw, shared across deployments, not rolled back | same; image `/var` only at install [FS4] | imposed |
| `/home` | directory | → `/var/home` | → `/var/home` [S13] | M2/M3 recommended/implemented |
| `/root` | directory | → `/var/roothome` | → `/var/roothome` [S13] | implemented |
| `/opt` | rw directory | → `/var/opt` | image-owned, read-only (maintainer statement) [FS8] | differs; M3 upstream recommendation |
| `/srv`, `/mnt` | directories | → `/var/srv`, `/var/mnt` | UNVERIFIED for Fedora bootc | recommended (OSTree) |
| `/usr/local` | rw directory | → `/var/usrlocal` | regular directory, read-only (upstream recommendation); Fedora choice UNVERIFIED | differs |
| `/run`, `/tmp` | tmpfs | tmpfs / see conflicts | tmpfs; image must not ship `/run` content [S1] | conventional |
| `/boot`, `/boot/efi` | rw, RPM-managed | writable | managed by bootc/bootupd; ro status UNVERIFIED | 0.1D |

Consequences for Eldora (INFERENCE): in M2/M3 the layout is largely
**imposed** by the tooling; in M1 it is **conventional** and must be
enforced by packaging discipline. No Eldora layout is proposed here.

## Part 3 — `/etc` and configuration ownership

**How each model behaves.**

| Aspect | M1 | M3 (and M2) |
|---|---|---|
| Who owns defaults | Packages (`%config(noreplace)` in `/etc`), increasingly `/usr` [FS10–FS11] | The image (`/usr/etc` generated from image `/etc`) [FS2] |
| Local changes survive updates | Yes; package ships `.rpmnew` instead [FS10] | Yes; locally modified file wins forever as a whole file [FS3] |
| Upstream changes reach system | Only for unmodified files; modified files need manual merge (`rpmconf`) | Only for unmodified files; same whole-file limitation [FS3] |
| Merge | None (two-way, file-level) | Three-way at deployment creation; deleted files stay deleted [FS3] |
| Drift visibility | `rpm -V`, `rpmconf`, `.rpmnew` files | `ostree admin config-diff`, diff of `/etc` vs `/usr/etc` |
| Declarative option | Kickstart/config management | Configuration baked in image; optional transient `/etc` [FS2] |
| Machine identity | `/etc/machine-id`, hostname, host keys in `/etc` | Same, machine-local in `/etc` [S13] |
| Users/groups | RPM scriptlets / sysusers in `/etc/passwd` | nss-altfiles + sysusers; local `/etc/passwd` edits freeze updates [FS6] |

**Answer: how to avoid `/etc` becoming an undefined collection of
irreproducible mutations?** (INFERENCE from FS2–FS12)

1. Ship all Eldora and vendor defaults in `/usr` (hermetic-`/usr` pattern,
   UAPI.6) and treat `/etc` as **local override only** — this follows
   Fedora's own direction (FS11) and works in M1 and M3.
2. Prefer drop-in directories over whole-file replacement (bootc guidance
   [S2], UAPI.6) so updates to defaults are not frozen by local edits.
3. Use sysusers/tmpfiles/`StateDirectory=` instead of scriptlet mutations
   (FS4, FS6).
4. Make drift visible (diff against vendor defaults) — both models have
   primitives; M3/M2 have a first-class baseline (`/usr/etc`).
5. Evaluate transient `/etc` only where machine-local state has another
   home (0.1C/0.1D question; it moves problems rather than removing them).

Neither model eliminates `/etc` drift by itself; M3 bounds it better
because `/usr` cannot drift and the default baseline is explicit.

## Part 4 — `/var` and machine state

**SYSTEM IMAGE** (or, in M1, the package-managed OS): `/usr`, vendor
defaults, kernel/initramfs, RPM database (FS11, IM2).

**PERSISTENT MACHINE STATE**: `/etc` local overrides, `/var` (logs,
databases, caches, service state, container storage, Flatpak system
installs, update caches), machine identity, host keys, local users, `/home`
(via `/var/home` in M2/M3).

Consequences (INFERENCE): in M3 the separation is structural — image
updates and rollback do not touch `/var` (FS4, FS5); services must
self-initialize state (tmpfiles, `StateDirectory=`) and must tolerate state
written by a *newer* image after rollback (schema compatibility becomes an
Eldora engineering rule, forwarded to 0.1C). In M1 the separation is only
conventional; rollback of state does not exist, so the same issue appears
as irreversible upgrades. Backup scope and factory reset are simpler to
define when the separation is structural (AD6), but secure wipe interacts
with encryption and partitioning (0.1C/0.1D).

## Part 5 — Package ownership

| Class | M1 | M3 |
|---|---|---|
| A. OS packages | Fedora repos, updated on host by DNF5 | Inherited `FROM` Fedora base; updated by rebuilding the image [IM4] |
| B. Eldora-only packages | Eldora-signed RPMs in an Eldora repo; `eldora-release` replaces `fedora-release` [IM5, IM8, IM9] | Same RPMs installed during image build, or files copied into `/usr` (RPMs preferred for traceability — INFERENCE) |
| C. Drivers (out-of-tree) | akmods/DKMS on host | Built into image, centrally (Universal Blue pattern) [IM10] |
| D. Codecs | Third-party repos on host | Installed at build time; repo trust moves to the build |
| E. Development tools | Host DNF or containers | Containers/`$HOME`; transient overlay for ad hoc use [IM6, AD2] |
| F. Administrative tools | Host DNF | Baked into image or transient [IM6] |
| G. User applications | Undecided (Q-0003) | Undecided (Q-0003); host `/usr` not available |
| H. Proprietary third-party apps | Vendor repos on host | Must be in image or outside the OS; no persistent host layering [IM6] |
| I. Compatibility/runtime deps | Host RPMs | In image or in the application's own runtime (Q-0003) |

Specific mechanisms: RPM ownership and Epoch rules (IM9) apply in both;
F45 signing enforcement means an Eldora signing infrastructure is required
in both (IM8); version pinning via versionlock (M1) or base-image digest
(M3); emergency fixes are a host transaction in M1 and an image rebuild +
redeploy in M3 (IM7).

## Part 6 — What is "the Eldora image" (M3)?

**Conceptual definition (INFERENCE from IM1–IM5):** an Eldora OS image
would be an OCI image (manifest, config, content-addressed layers,
identified by digest) built `FROM` a Fedora bootc base image, into which
Eldora-owned RPMs and `/usr` defaults are installed at build time, with a
build-time initramfs, `containers.bootc=1`, Eldora `os-release`
identity (`IMAGE_ID`/`IMAGE_VERSION`), systemd units enabled via presets,
and `/etc` defaults that become `/usr/etc` on the client. It would be
published to a registry, pulled by digest, optionally signed and
accompanied by SBOM/provenance artifacts attached via the referrers
mechanism.

**Container image vs bootable OS container image:** both are OCI images;
a bootable one carries a kernel, initramfs, systemd as init, SELinux policy
and the bootc label, is installed to disk and booted directly, and ignores
runtime container metadata (IM2). An application container image is run by
a container engine on top of an existing kernel.

**Not part of the image:** `/var` content after install, local `/etc`
changes, local users, install-time kernel arguments, secrets and host keys,
bootloader binaries on the ESP, user data, and applications outside `/usr`
(IM3).

## Part 7 — Derivation strategies

| Strategy | Maintenance cost | Security responsibility | Update latency | Reproducibility | Independence | Coupling | Supply chain |
|---|---|---|---|---|---|---|---|
| A. Consume Fedora repos directly | Lowest | Fedora | Fedora cadence | Limited by moving repos (FR6) | Low | High to Fedora | Fedora keys |
| B. Eldora RPMs on top of Fedora packages | Low–medium | Eldora for own RPMs | Eldora-controlled for own RPMs | Good for own RPMs | Medium | Medium | Eldora key required (IM8) |
| C. Eldora repo + Fedora repos | Low–medium (repo ops) | Same as B | Same as B | Same as B | Medium | Medium | Two trust roots |
| D. Eldora bootc image FROM Fedora bootc | Medium (CI, registry, signing) | Eldora for image composition | Rebuild cadence (Eldora-controlled) | Image digest per release; inputs float unless pinned (FR6) | Medium–high (controls exact composition) | Coupled to Fedora base-image interface (IM4, `minimal-plus` not stable) | Registry + image signing required (FR4) |
| E. Rebuild selected Fedora packages | High per package | Eldora for rebuilt packages | Eldora lag | Good | Higher | Divergence cost | Eldora signing |
| F. Fork packages | Highest | Eldora | Eldora lag | Good | High | High divergence (RES-0002/FX1) | Eldora |
| G. Downstream patches | High, cumulative | Eldora | Lag on each Fedora update | Good | Medium | Rebase burden (RISK-0001) | Eldora |
| H. Upstream Eldora-required changes | Low long-term; slow short-term | Upstream | Upstream schedule | n/a | Low but durable | Lowest | Upstream |
| I. Vendor components | Medium–high | Eldora for vendored code | Eldora | Good | Medium | Hidden duplication | Eldora must track CVEs |

**Minimum Eldora-owned surface (INFERENCE):** A+B+C (and D if M3), with H
preferred over E/F/G. Concretely: release/identity/branding packages; a
defaults/configuration package set shipped in `/usr`; presets; Eldora's own
components (shell, system apps, services — whichever are retained by Waves
0.2–0.4); the Eldora repository and signing key; and, for M3, the image
definition and its published images. Everything else is consumed from
Fedora unchanged. This surface is almost identical for M1 and M3; M3 adds
the image definition, registry and image-signing responsibilities.

## Part 8 — Mutability model

| Term | Definition used here | Not equivalent to |
|---|---|---|
| Immutable | Content cannot be changed after creation (e.g., an image digest's content) | "read-only" at runtime — a read-only mount can be remounted or overlaid by root (IM6) |
| Read-only | Mounted without write permission at runtime | Security boundary — root can overlay (`usr-overlay`) [IM6, FR4] |
| Image-based | The OS is delivered as a whole filesystem artifact | Atomic (an image can be applied non-atomically) |
| Atomic | An update results in either the old or the new system, never a mix | Transactional rollback of state (`/var` is not rolled back) [FR1, FS4] |
| Transactional | Changes are grouped and applied/aborted as a unit (RPM transaction, deployment) | Atomic under power loss (RPM power-loss behaviour UNVERIFIED) [FR3] |
| Declarative | The desired state is described, then realised by tooling | Reproducible (a Containerfile with floating repos is declarative but not reproducible) [FR6] |
| Reproducible | The same inputs produce the same output (package set, filesystem, digest…) | Declarative or image-based |

**Who can change what:**

| Actor | M1 | M3 |
|---|---|---|
| User | `$HOME`; apps per app model | Same |
| Administrator (root) | Everything, persistently | `/etc`, `/var` persistently; `/usr` only transiently or via a derived image and reboot [IM6, IM7] |
| System services | `/var`, `/etc` (by design) | `/var`, `/etc` |
| Updater | All package-owned files | Swaps `/usr` and merges `/etc` at next boot [FS2] |
| Applications | Per app model; M1 host packages can touch `/usr` | Cannot modify `/usr` |

## Part 9 — Local administration ("Simple. Powerful. Yours.")

| Action | M1 | M2 | M3 |
|---|---|---|---|
| Install CLI tool | DNF (persistent) | Layering (persistent, reboot) or container/`$HOME` | Container/`$HOME`; derived image (persistent after reboot); transient overlay |
| Compile software | `/usr/local`, `/opt` | Container/`$HOME` | Container/`$HOME`; image build stage |
| Install SDKs | DNF or `$HOME` managers | Container | Container/`$HOME` |
| Use containers | Podman | Podman | Podman |
| Modify system services | `/etc` drop-ins | `/etc` drop-ins | `/etc` drop-ins (rollback reverts them) [FS5] |
| Diagnose system | Install tools | Transient overlay / toolbox | Transient overlay / toolbox [IM6, AD2] |
| Advanced config | `/etc` | `/etc` | `/etc`, kargs.d in image |
| Add kernel module | akmods/DKMS | Layered kmods (no DKMS) | Build into image [AD4] |

Assessment (INFERENCE): M1 offers the widest persistent escape hatch; M2
offers persistent layering; M3 offers persistent change only by building
a local derived image (powerful but heavy) and lacks sysext support (FS7).
"Simple by default, powerful when needed" is achievable in M3 only if
user-level mechanisms (containers, `$HOME` tooling, possibly a supported
local-derivation workflow) are made first-class; that is a design question
for later waves, not something the tooling provides today.

## Part 10 — Development environments

**Question:** must development dependencies modify the base system? The
evidence shows host/dev separation is widely practised (Toolbx, Bluefin,
Fedora Atomic guidance) and keeps the OS reproducible (AD2, AD3), but it is
organisational, not a security boundary (SELinux separation disabled in
Toolbx [AD2]), and IDE/GPU/device integration causes documented friction
(AD4). Low-level development (kernel modules, system services, the Eldora
shell itself) needs host-level access that containers only partly provide
(AD3, AD4). **No solution is chosen.** The structural consequence is that
M3 makes separation mandatory for persistent tools, while M1 makes it
optional.

## Part 11 — Application boundary

Evidence-based boundary (INFERENCE from AD5): the line between OS
component and application is drawn by **integration depth**, not by
application category. Components requiring privileged integration (shell,
system settings, file manager in KDE's experience, update UI) behave as OS
components: updated and rolled back with the OS. General applications live
outside `/usr`, with state in `$HOME` (XDG) or `/var`, update independently
and are **not** rolled back with the OS (FS4, AD5). Consequences: OS
rollback must tolerate newer application state; permission and sandboxing
policy belongs to the application model (Q-0003); system-wide vs per-user
installation must be defined there. The conceptual "get app → add to
Applications → run" experience is compatible with any model that keeps
applications outside the OS image; no technology is chosen.

## Part 12 — Failure modes (conceptual)

| Failure | M1 | M3 | Prevent | Detect | Recover |
|---|---|---|---|---|---|
| Interrupted update | In-place transaction; recovery via rpmdb rebuild/distro-sync; power-loss atomicity UNVERIFIED [FR3] | Staged; old deployment intact [FR1] | Offline/staged updates | Boot-complete checks [FR1] | M1 repair tools; M3 previous deployment |
| Bad system update | Kernel fallback only; `dnf history undo` if packages available | Previous deployment; manual rollback default [FR2] | CI testing | Health checks (0.1C) | Rollback (M3) / repair (M1) |
| Broken dependency / RPM transaction | Solver refuses; partial upgrades possible | Caught at image build (off-client) | Depsolve in CI | Build failure | Fix and rebuild |
| Broken image | n/a | Lint, boot tests [IM2] | CI boot tests | Boot failure | Previous deployment |
| Corrupted persistent state | Shared with OS | `/var`, `/etc` not rolled back [FS4, FS5] | Hermetic `/usr`, minimal `/etc` | Drift diff | Reset of state (0.1C) |
| Bad `/etc` change | Persists | Persists; rollback does not restore edits [FS5] | Drop-ins, audit | config diff | Restore from vendor defaults |
| Incompatible driver | akmods rebuild may fail at boot | Must be built into image; kernel/kmod skew [AD4, IM10] | Build kmods in CI | Build/boot failure | Previous deployment (M3) / older kernel (M1) |
| Disk full | Cache, kernels | Two deployments + image store [S1] | Space checks | Monitoring | GC |
| Registry / repository unavailable | Mirror failover (metalink) | Registry dependency; offline OCI transport possible [S1] | Mirrors | Update failure | Retry/offline media |
| Signing failure | F45 refuses unsigned RPMs [IM8] | Rejected only if policy enforces signatures [FR4] | Enforce policy | Verification error | Re-sign / rebuild |
| Boot failure | Older kernel entry | Previous deployment; boot counting varies by backend [FR1] | Boot assessment | Boot counting | Automatic/manual fallback (0.1C) |
| Rollback failure | No system rollback | Composefs-backend recovery untested [S1] | Test paths | — | Reinstall (0.1C) |
| Local customization vs update | Solver conflicts | Layering blocks `bootc upgrade`; `/etc` metadata diffs block updates of files [IM6, FS3] | Discourage host mutation | Upgrade error | Reset customization |

Design of detection and recovery is deferred to 0.1C.

## Part 13 — Security

- **Integrity:** M3's read-only `/usr` prevents inadvertent change, not
  determined root (FR4, IM6). Verified integrity requires sealed images,
  which Fedora offers only as unofficial test images (FR5). "Immutable =
  secure" is not supported by the evidence.
- **Attack surface / persistence:** in both models `/etc` and `/var`
  persist across updates and can hold executable configuration (unit
  files) (FR4); malware persistence there survives image updates unless
  `/etc` is transient (INFERENCE).
- **Verification:** M1 has enforced RPM signatures from F45 (IM8) with
  unsigned metadata protected by HTTPS metalinks [RES-0001/FF4]. M3 adds a
  registry trust path whose signature enforcement is opt-in and whose
  Fedora base images showed no signature tags (FR4).
- **Rollback/freeze attacks:** no primary source describes freshness
  protection for OCI updates; inferred risk, UNVERIFIED (forwarded to 0.1C).
- **Provenance/SBOM:** tooling exists (podman SBOM generation, Konflux
  SLSA claims), but availability for Fedora's published bootc images was
  not verified (FR6, IM1).
- **Local root:** both models grant root broad control; M3 makes `/usr`
  changes transient, which is a predictability property, not a security
  boundary.

## Part 14 — Reproducibility

| Meaning | M1 realistic | M3 realistic |
|---|---|---|
| 1. Package set | Possible with pinning; repos float; lockfile tooling experimental [FR6] | Same at build time; the resulting set is recorded in the image |
| 2. Filesystem | Diverges per host | `/usr` identical per digest; `/etc` and `/var` diverge |
| 3. Image digest | Not applicable | Achievable with timestamp control; obstacles documented (initramfs, OSTree timestamps) [FR6] — not demonstrated here |
| 4. Build inputs | Repo state at a moment; no dated snapshots found | Containerfile + base digest + repos; same snapshot gap |
| 5. Installed machine state | Not reproducible after drift | Not reproducible for `/etc`/`/var`; `/usr` is |

No "reproducible build" claim is made for either model.

## Part 15 — Update/recovery boundary (forwarded to 0.1C)

See "Questions forwarded to Wave 0.1C". Structural consequences only were
analysed above.

## Part 16 — Build/boot boundary (forwarded to 0.1D)

See "Questions forwarded to Wave 0.1D".

## Status of M2

M2 remains a **reference**, not reclassified. Evidence relevant to not
discarding it prematurely: M2 is today the only Fedora-official
image-based desktop delivery (RES-0001/FC5) and offers a persistent
host-layering escape hatch that M3 lacks (AD1, IM6). Evidence against
promoting it: upstream bootc expects compatibility with rpm-ostree to break
in future (IM6), rpm-ostree development focus has shifted
(RES-0001/FC4), and a 2026 regression shows long-lived-host divergence
(FS13). **Recorded explicitly:** the M2b path (rpm-ostree client over an
OCI image) should remain on record as a possible *transitional* client
mechanism if M3's missing escape hatch proves blocking; this is not a
reclassification.

## Answers to the mandatory questions

**Q1 — Eldora Base System.** (INFERENCE) Everything in `/usr` delivered as
the OS: Fedora-consumed packages, Eldora-owned packages (identity,
defaults, presets, Eldora components retained by later waves), kernel and
initramfs, and — in M3 — the image definition that composes them. It
excludes machine state (`/etc` local overrides, `/var`), user data and
applications.

**Q2 — Minimum Eldora-owned surface.** Release/identity/branding;
defaults/configuration in `/usr`; presets; Eldora's own components; Eldora
repository and signing key; (M3) image definition, published images and
their signatures. No forks by default (Part 7).

**Q3 — Consume from Fedora without fork.** Kernel, firmware, base
userspace (glibc, systemd, udev, D-Bus), networking/Bluetooth/audio,
graphics stack and Mesa, Wayland libraries, filesystem/storage tooling,
SELinux base policy, trust store, DNF/RPM, bootc/OSTree tooling.

**Q4 — When Eldora needs its own RPMs.** For identity and branding
(trademark requirement), Eldora defaults and presets, Eldora components,
SELinux policy modules for Eldora services, and — exceptionally — for a
Fedora package that must be patched when upstreaming fails (Part 7 E/G).

**Q5 — `/usr`, `/etc`, `/var`.** See Parts 2–4: M1 all writable and
package-managed; M3 `/usr` image-owned read-only, `/etc` 3-way merged
machine state, `/var` persistent and outside the image lifecycle.

**Q6 — Local configuration and drift.** M1: local files win; `.rpmnew`
accumulates; no merge. M3: local files win as whole files; unmodified files
follow the image; explicit baseline for diffs; users/groups and metadata
pitfalls (FS3, FS6).

**Q7 — OS vs machine state.** M3 structurally (`/usr` vs `/etc`/`/var`);
M1 by convention only.

**Q8 — OS vs applications.** Neither model defines it; M3 forces
applications out of `/usr`, M1 permits both. The boundary should follow
integration depth (Part 11).

**Q9 — Advanced administration without destroying predictability.** Keep
vendor state in `/usr`, local intent as drop-ins in `/etc`, tools in
containers/`$HOME`, and provide a persistent, visible escape hatch (M1:
host packages with drift reporting; M3: supported local derivation or
extension mechanism — currently missing, FS7).

**Q10 — Development without an irreproducible host.** Default to separated
development environments while keeping a documented path for host-level
work (Part 10). Not decided.

**Q11 — What system rollback should not necessarily revert.** User data,
application state and data, logs, `/var` service state (with schema
compatibility caveats), secrets, machine identity. `/etc` behaviour on
rollback is a 0.1C question (FS5).

**Q12 — What must survive a full image replacement.** `/home`, `/var`
(machine state, logs, containers, application installs outside `/usr`),
machine identity and host keys, local users, network configuration,
secrets, local `/etc` overrides (subject to 0.1C policy).

**Q13 — What a factory reset would erase (not decided).** Candidate scope:
`/etc` local overrides, `/var`, local users and home directories, secrets
and enrolled credentials; retaining the OS image. Secure-wipe semantics
depend on encryption/partitioning (AD6) → 0.1C/0.1D.

**Q14 — Additional responsibilities with M3.** Image definition and CI
builds; registry hosting and availability; image signing and policy
enforcement; rechunking/update size; kernel-module builds in CI;
bootloader update policy; local escape-hatch design; tracking Fedora
base-image interface changes (`minimal-plus` not stable).

**Q15 — Additional responsibilities with M1.** Drift management and
support of heterogeneous hosts; configuration-merge tooling; lack of
atomic rollback (compensating recovery tooling); on-host kmod builds;
testing upgrades across diverse local states; protecting Eldora defaults
from local replacement.

**Q16 — Which reduces configuration drift more?** M3 (with M2): `/usr`
cannot drift and `/etc` has an explicit baseline; it does not eliminate
`/etc`/users drift. Confidence MEDIUM–HIGH.

**Q17 — Which offers the larger escape hatch?** M1. M2 second
(persistent layering). M3 last today (FS7, IM6). Confidence HIGH.

**Q18 — Legitimate hybrid?** Not a runtime hybrid. There is a legitimate
structural commonality: M3 images are composed from RPMs, so an Eldora
component and configuration set packaged as signed RPMs following the
hermetic-`/usr` discipline serves both M1 hosts and M3 images (H1). This
keeps the model choice reversible for longer; it is not proposed as a way
to avoid choosing.

**Q19 — Enough evidence to promote M3 over M1?** **MORE EVIDENCE
REQUIRED.** M3 has structural advantages in drift bounding, atomic
updates and OS/state separation, but the desktop-critical gaps found here
(no supported persistent escape hatch, sysext unsupported, users/groups
pitfalls, Fedora bootc pipeline not yet in production, opt-in signing,
kmods at build time) are unresolved and untested for Eldora.

**Q20 — Decide now vs later.**
- *Now (0.1B-level, recommendations for the Owner):* adopt the ownership
  map as a working model; adopt the principle "vendor and Eldora defaults
  in `/usr`, `/etc` for local overrides only" as a packaging rule
  applicable to either model; confirm that Eldora-owned content is
  delivered as signed RPMs; keep M1 and M3 both open.
- *0.1C:* update/rollback/recovery semantics, `/etc` on rollback, factory
  reset, health checks, signature enforcement and freshness, state schema
  compatibility.
- *0.1D:* build pipeline, registry, image signing, SBOM/provenance, boot
  architecture, bootloader updates, installer.
- *Later waves:* application model and boundary technology (0.3);
  desktop/shell as OS component (0.2); platform services (0.4).

## Evidence Against M1

1. No reconciliation of configuration; `.rpmnew` and local files diverge
   silently (FS10).
2. Fedora itself is moving vendor configuration into `/usr` to make local
   changes identifiable — an implicit acknowledgement of the M1 `/etc`
   problem (FS11).
3. No atomic system update or rollback; Fedora calls upgrades "potentially
   risky"; power-loss behaviour undocumented (FR3).
4. Installed machine state cannot be reproduced after drift (Part 14).
5. On-host kmod builds can fail after kernel updates without system
   rollback (Part 12).
6. Fedora's integrity work (sealed images) targets image-based variants
   only (FR5).

## Evidence Against M3

1. No supported persistent host escape hatch: layering breaks `bootc
   upgrade`; dnf changes are transient; sysext/confext unsupported
   (IM6, FS7) — verified.
2. Users/groups: local `/etc/passwd` edits hide new image users;
   `usermod -aG` silently fails for image groups; UID/GID drift (FS6).
3. Rollback does not restore `/etc` edits; `/var` never follows the image
   (FS4, FS5).
4. Signatures not required by default; Fedora base images without observed
   signatures; fsverity off by default (FR4).
5. Kernel modules must be built at image build time (AD4, IM10).
6. Fedora's base image interface is not stable (`minimal-plus`) and the
   production pipeline targets F45 (IM4; RES-0001/FD7).
7. Bootloader updates are not automatic; factory reset experimental
   (IM3, AD6).
8. Parts of Fedora bootc documentation are stale or server/edge-focused
   (Method).

## Evidence Against M2 (reference)

1. Same `/etc` merge limitations as M3 (FS3).
2. Upstream bootc expects rpm-ostree compatibility to break (IM6).
3. 2026 SELinux label regression on long-lived hosts (FS13).
4. Layering can fail to depsolve when base and third-party repos skew
   (sub-agent evidence, tier 3).

## Attempt to falsify the leading recommendation

The leading recommendation below keeps M3 as the principal candidate while
answering Q19 "MORE EVIDENCE REQUIRED". Attempts to show M3 is inadequate
for Eldora:

1. **"'Yours' is incompatible with M3."** Strongest argument: no supported
   persistent host modification exists today (IM6, FS7), and bootc's
   stance is explicitly against client-side state. Counter: user-level
   tools and local derived images exist (IM7, AD2–AD3); KDE Linux and
   Bluefin ship image-based desktops with such workflows. **Result: not
   falsified, but unresolved; this is the principal open issue** (probe
   PB2).
2. **"M3 does not actually solve drift."** Partly true: `/etc`, users and
   `/var` still drift (FS3–FS6). But `/usr` cannot drift and there is an
   explicit baseline; M1 is worse on the same axes (FS10). **Result:
   weakens the advantage; does not reverse it.**
3. **"M3 shifts too much operational burden to a small team."** Registry,
   signing, CI, kmods and rechunking are new responsibilities (Q14).
   Counter: M1 shifts burden to field support of drifted hosts (Q15).
   **Result: unresolved; measurable only by probes (PB1, RES-0002 PX1).**
4. **"M1 is operationally unacceptable."** Falsification attempted in the
   other direction: no evidence shows M1 is unacceptable for a desktop —
   Fedora Workstation, the largest Fedora desktop, uses it. Its costs are
   real but familiar. **Result: M1 is not falsified; it remains a valid
   fallback.**

Net: evidence supports keeping M3 as the principal candidate and M1 as a
real fallback; it does not support promoting M3.

## Recommendation

A recommendation is not a decision.

1. **Q19: MORE EVIDENCE REQUIRED.** Do not promote M3 over M1 yet.
2. Keep **M3 as principal candidate** and **M1 as mandatory fallback**;
   keep M2 as reference with the M2b transitional note.
3. Adopt, as model-independent working principles for later decisions
   (for Owner consideration, not decisions): the ownership map (Part 1);
   "vendor and Eldora defaults in `/usr`, `/etc` for local overrides,
   drop-ins over whole files"; sysusers/tmpfiles for users and state;
   Eldora content delivered as signed Eldora RPMs; consume Fedora without
   forks; upstream before patch.
4. Run probes PB1–PB5 before a composition decision.

- **Confidence:** MEDIUM.
- **Favourable evidence:** FS1–FS5, FS11–FS12, FR1, IM1–IM5.
- **Contrary evidence:** Evidence Against M3 (1–8); Q17.
- **Assumptions:** the Owner values both predictability and user control;
  desktop update UX and application model are resolved in later waves.
- **Reversibility:** high; the working principles serve both models.

## Risk Register impact

- **RISK-0001 (rebase cost):** unchanged in status. RES-0003 adds that the
  cost differs by model: M3 concentrates rebase work in the image build
  (testable in CI), M1 distributes it across heterogeneous hosts. Probe
  PB1 complements PX1.
- **RISK-0003 (bootc desktop maturity):** reinforced with specific gaps:
  missing persistent escape hatch (FS7, IM6), users/groups pitfalls (FS6),
  unstable base-image interface (IM4), opt-in signing (FR4). Status stays
  OPEN.
- **RISK-0004 (coupling):** mitigation direction identified: keeping
  Eldora content as RPMs following the hermetic-`/usr` discipline reduces
  coupling to the composition model (Q18); M3 couples Eldora to Fedora's
  base-image interface and bootc semantics.
- **RISK-0002:** relevant only through kmod placement (Part 5 C).

No risk status is changed by this report.

### Candidate new risks (recommended for the Risk Register; no RISK-ID created)

| Candidate | Description | Evidence |
|---|---|---|
| RC-A | Configuration and users/groups drift under the image model (whole-file `/etc` merge freezing, hidden new users, UID/GID drift) could undermine predictability even with M3. | FS3, FS6 |
| RC-B | Absence of a supported persistent host-extension mechanism on bootc (sysext unsupported, layering incompatible) may conflict with the "powerful when needed" goal. | FS7, IM6 |
| RC-C | Update trust defaults are permissive (container policy accepts anything; base images unsigned) and must be deliberately hardened by Eldora. | FR4, L7 |

## Proposed probes (NOT executed)

| ID | Hypothesis | M1 procedure | M3 procedure | Metrics | Cost | VM/hardware | Risk |
|---|---|---|---|---|---|---|---|
| PB1 | Minimal Eldora ownership surface is small and model-independent | Build eldora-release/defaults/presets RPMs; install on Fedora VM | Same RPMs in a Containerfile `FROM fedora-bootc`; install to VM | Count of Eldora-owned packages/files; build effort; differences between models | 2–3 days | VM | Low |
| PB2 | M3 can offer a usable persistent escape hatch | Host DNF baseline | Local derived-image workflow; toolbox; `$HOME` tools; transient overlay | Steps/time to install a CLI tool, a system service and a kernel module persistently; survival across update | 2 days | VM | Low |
| PB3 | `/etc` and users/groups drift behaviour | Modify configs, upgrade, observe `.rpmnew` | Modify configs/users, update/rollback, observe merge and hidden users | Files diverged; failed updates; user visibility | 1–2 days | VM | Low |
| PB4 | Machine state survives OS replacement cleanly | Upgrade across releases | Switch/rollback across images with services that write `/var` schemas | State compatibility failures | 2 days | VM | Low |
| PB5 | Update trust can be enforced end-to-end | Signed Eldora repo | Signed image, enforced policy at install and update | Rejection of unsigned inputs; configuration effort | 1–2 days | VM | Low |

## Questions forwarded to Wave 0.1C (Update / Rollback / Recovery)

1. `/etc` semantics on rollback (FS5) and whether transient `/etc` is
   desirable.
2. Automatic vs manual rollback; health checks; boot counting per backend
   (FR1, FR2).
3. State schema compatibility when rolling back an image while `/var`
   holds newer state.
4. Factory reset scope and secure-wipe semantics (Q13, AD6).
5. Signature enforcement at install and update; freshness/freeze-attack
   protection for OCI updates (FR4).
6. Emergency fix path in M3 (rebuild/redeploy latency) vs M1 (host
   transaction).
7. Behaviour of M1 updates on power loss (UNVERIFIED) and compensating
   recovery.
8. TPM-bound secrets across image updates.

## Questions forwarded to Wave 0.1D (Image Build / Boot / Release Pipeline)

1. Base image choice (`standard`, `minimal`, `minimal-plus`, from-scratch)
   and dependence on a non-stable interface (IM4).
2. CI pipeline, registry hosting, rechunking and update size.
3. Image signing, SBOM and provenance generation and publication.
4. Kernel-module build pipeline and MOK/Secure Boot strategy (RISK-0002).
5. Bootloader update policy; installer path (Anaconda `bootc` kickstart
   limits, RES-0001/FD6).
6. Reproducibility controls (base digest pinning, lockfiles, timestamps).
7. Eldora RPM repository hosting and signing infrastructure (IM8).

## Decisions that should wait for later waves

Application model and boundary technology (0.3); desktop shell and system
apps as OS components (0.2); platform services and Broker (0.4); repository
strategy for Eldora packages vs images (0.5).

## Decision

NOT TAKEN — research does not decide. Composition model (Q-0001) and
update/rollback model (Q-0008) remain open.

## Conflicts and uncertainties

- **C1.** Fedora bootc `dnf` page (2024-10-30) says host `dnf install`
  errors; DNF5 docs describe a transient mode for bootc. Both can be true
  (transient mode must be requested); current Fedora default behaviour
  untested.
- **C2.** `/usr/local` on bootc: upstream recommends a regular directory;
  OSTree convention is a symlink to `/var`; Fedora bootc's actual choice
  UNVERIFIED. `/srv`, `/mnt`, `/boot` treatment on Fedora bootc UNVERIFIED.
- **C3.** bootc docs say the `/etc` diff includes metadata; OSTree source
  ignores xattrs; uid/gid/mode likely count (UNVERIFIED from code).
- **C4.** `/tmp` on Atomic Desktops: docs list a `/sysroot/tmp` symlink;
  behaviour on current systems UNVERIFIED.
- **C5.** Fedora Quick Doc says `--duplicates` is DNF4-only; the local DNF5
  man page documents it (context).
- **C6.** Whether Fedora's official bootc images carry signatures, SBOM or
  provenance via the referrers API: UNVERIFIED.
- **C7.** Freeze/rollback attack exposure for OCI updates: inference only.

## Validation performed

- Verbatim spot-checks (2026-09-26): bootc book — sysext/confext
  unsupported; `/var` as Docker VOLUME; hidden new users after local
  `/etc/passwd` edits; signatures not required by default; fsverity not
  enabled by default; "relatively hard stance"; `/etc` edits not carried on
  rollback; "not a vulnerability" statement. Fedora F45
  RelocateRpmRepoConfigsToUsr (`ChangeAcceptedF45`, stated purpose). DNF5
  `persistence` option "Only applicable on bootc systems".
- URL checks: see the final report of this task.

## Sources

All accessed 2026-09-26. Tier per `docs/research/README.md`.

| # | Source (title — organization — URL) | Tier | Date covered | Used for |
|---|---|---|---|---|
| S1 | bootc book (print view: filesystem, upgrades, rollback, security, local builds, usr-overlay, composefs backend, install reset) — bootc project — https://bootc.dev/bootc/print.html | 1 | undated (live) | FS1–FS7, IM6–IM7, FR1–FR4, AD6 (verified quotes) |
| S2 | Generic guidance for building images — bootc — https://bootc.dev/bootc/building/guidance.html | 1 | undated | FS1, Part 3 |
| S3 | bootc image requirements, bootloaders, secrets, kargs — bootc — https://bootc.dev/bootc/bootc-images.html | 1 | undated | IM2, IM3 |
| S4 | Users and groups — bootc — https://bootc.dev/bootc/building/users-and-groups.html | 1 | undated | FS6 |
| S5 | Relationships (bootc and rpm-ostree) — bootc — https://bootc.dev/bootc/relationships.html | 1 | undated | IM6 |
| S6 | Atomic upgrades; Adapting existing systems — OSTree — https://ostreedev.github.io/ostree/atomic-upgrades/ ; https://ostreedev.github.io/ostree/adapting-existing/ | 1 | undated | FS3, FS8, FR1 |
| S7 | Deployments — OSTree — https://ostreedev.github.io/ostree/deployment/ | 1 | undated | FS3 |
| S9 | ostree-sysroot-deploy.c — OSTree (raw source document) — https://raw.githubusercontent.com/ostreedev/ostree/main/src/libostree/ostree-sysroot-deploy.c | 1 | main | FS3 |
| S10 | Fedora bootc docs: building containers, dnf, rpm-ostree — Fedora — https://docs.fedoraproject.org/en-US/bootc/building-containers/ ; https://docs.fedoraproject.org/en-US/bootc/dnf/ | 1 | undated / 2024-10-30 | IM2, IM4, IM6 |
| S11 | Kernel arguments — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/kernel-args/ | 1 | undated | IM3 |
| S12 | Bootloader updates — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/bootloader-updates/ | 1 | undated | IM3 |
| S13 | Filesystem; home directories; manual rollbacks; auto-updates — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/filesystem/ ; https://docs.fedoraproject.org/en-US/bootc/auto-updates/ | 1 | undated | FS5, FR2, Part 2 |
| S14 | Technical information — Fedora Atomic Desktops docs — https://docs.fedoraproject.org/en-US/atomic-desktops/technical-information/ | 1 | undated | FS9 |
| S15 | Working with /opt (discussion #1038) — bootc-dev (maintainer) — https://github.com/bootc-dev/bootc/discussions/1038 | 2 | 2025-01-16 | FS8 |
| S16 | Fedora Packaging Guidelines — Fedora — https://docs.fedoraproject.org/en-US/packaging-guidelines/ | 1 | current | FS10 |
| S17 | Spec file format — rpm.org — https://rpm.org/docs/latest/manual/spec.html | 1 | latest | FS10 |
| S18 | Upgrading Fedora offline — Fedora — https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/ | 1 | 2025-08-26 | FS10, FR3 |
| S19 | Changes/RelocateRpmRepoConfigsToUsr — Fedora — https://fedoraproject.org/wiki/Changes/RelocateRpmRepoConfigsToUsr | 1 | ChangeAcceptedF45 | FS11 (verified) |
| S20 | Changes/RelocateRPMToUsr — Fedora — https://fedoraproject.org/wiki/Changes/RelocateRPMToUsr | 1 | F36 | FS11 |
| S21 | file-hierarchy(7) — systemd — https://www.freedesktop.org/software/systemd/man/latest/file-hierarchy.html | 1 | systemd 262 | FS12 |
| S22 | UAPI.6 Configuration Files Specification — UAPI Group — https://uapi-group.org/specifications/specs/configuration_files_specification/ | 1 | v1.0 | FS12 |
| S23 | UAPI.9 Linux File System Hierarchy — UAPI Group — https://uapi-group.org/specifications/specs/linux_file_system_hierarchy/ | 1 | v0.1 (WIP) | FS12 |
| S24 | tmpfiles.d(5) — systemd — https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html | 1 | systemd 262 | FS12 |
| S25 | Filesystem Hierarchy Standard 3.0 — Linux Foundation — https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04.html | 1 | 3.0 (2015) | FS12 |
| S26 | OCI Image Format Specification — Open Container Initiative (GitHub document) — https://github.com/opencontainers/image-spec/blob/main/spec.md | 1 | v1.1.1+dev | IM1 |
| S27 | OCI Distribution Specification — Open Container Initiative (GitHub document) — https://github.com/opencontainers/distribution-spec/blob/main/spec.md | 1 | v1.1.1+dev | IM1 |
| S28 | fedora/bootc/base-images README — Fedora — https://gitlab.com/fedora/bootc/base-images | 1 | current | IM4 |
| S29 | Configuring os-release and versions — Fedora bootc docs — https://docs.fedoraproject.org/en-US/bootc/os-release-and-versions/ | 1 | 2024-07-10 | IM5 |
| S30 | dnf5.conf(5) — DNF5 — https://dnf5.readthedocs.io/en/latest/dnf5.conf.5.html | 1 | latest | IM6 (verified) |
| S31 | Addressing UID/GID drift in rpm-ostree and bootc — LWN — https://lwn.net/Articles/1018082/ | 3 | 2025-04-23 | FS6 |
| S32 | rpm-ostree 2026.3 SELinux label mismatches (#2226) — fedora-coreos-tracker (GitHub page) — https://github.com/coreos/fedora-coreos-tracker/issues/2226 | 2 | 2026-09-20 | FS13 |
| S33 | Changes/Enforcing signature checking by default — Fedora — https://fedoraproject.org/wiki/Changes/Enforcing_signature_checking_by_default | 1 | F45 | IM8 |
| S34 | DNF5 commands (swap, versionlock, offline) — DNF5 — https://dnf5.readthedocs.io/en/latest/commands/offline.8.html | 1 | latest | IM9, FR3 |
| S35 | Versioning guidelines — Fedora — https://docs.fedoraproject.org/en-US/packaging-guidelines/Versioning/ | 1 | current | IM9 |
| S36 | Default services — Fedora — https://docs.fedoraproject.org/en-US/packaging-guidelines/DefaultServices/ | 1 | current | IM9 |
| S37 | ublue-os/akmods README — Universal Blue (GitHub page) — https://github.com/ublue-os/akmods | 3 | current | IM10 |
| S38 | ublue-os/image-template README — Universal Blue (GitHub page) — https://github.com/ublue-os/image-template | 3 | current | IM10 |
| S39 | Administrator handbook — rpm-ostree — https://coreos.github.io/rpm-ostree/administrator-handbook/ | 1 | undated | AD1 |
| S40 | Getting started — Fedora Atomic Desktops docs — https://docs.fedoraproject.org/en-US/fedora-silverblue/getting-started/ | 1 | 2026-01-14 | AD1 |
| S41 | Architecture of apply-live — rpm-ostree — https://coreos.github.io/rpm-ostree/apply-live/ | 1 | undated | AD1 |
| S42 | Toolbx documentation — containertoolbx.org — https://containertoolbx.org/doc/ | 1 | current | AD2 |
| S43 | FAQ — Fedora Atomic Desktops docs — https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/ | 1 | 2026-01-09 | AD2, AD5 |
| S44 | Bluefin developer and administration docs — Project Bluefin — https://docs.projectbluefin.io/bluefin-dx | 1 (project) | 2026 | AD3 |
| S45 | Announcing the Alpha release of KDE Linux — N. Graham (KDE) — https://pointieststick.com/2025/09/06/announcing-the-alpha-release-of-kde-linux/ | 2 | 2025-09-06 | AD3, AD5 |
| S46 | Are Fedora Atomic desktops actually good for developers? — Fedora Discussion — https://discussion.fedoraproject.org/t/are-fedora-atomic-desktops-actually-good-for-developers/133532 | 3 | 2024-10-11 | AD4 |
| S47 | How to properly set up VSCode and toolbox containers? — Fedora Discussion — https://discussion.fedoraproject.org/t/how-to-properly-set-up-vscode-and-toolbox-containers/173622 | 3 | 2025-11-23 | AD4 |
| S48 | Bootc for workstation use — LWN — https://lwn.net/Articles/1042708/ | 3 | 2025-11-07 | AD4 |
| S49 | XDG Base Directory Specification — freedesktop.org — https://specifications.freedesktop.org/basedir-spec/latest/ | 1 | 0.8 | AD5 |
| S50 | Desktop Entry Specification — freedesktop.org — https://specifications.freedesktop.org/desktop-entry-spec/latest/ | 1 | 1.5 | AD5 |
| S51 | AppStream metadata — freedesktop.org — https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html | 1 | current | AD5 |
| S52 | Factory Reset; systemd-factory-reset(8) — systemd — https://systemd.io/FACTORY_RESET/ | 1 | current | AD6 |
| S53 | Why did GNOME OS choose systemd-sysupdate over bootc? — GNOME Discourse — https://discourse.gnome.org/t/why-did-gnome-os-choose-systemd-sysupdate-over-bootc/24642 | 2 | 2024-10 | AD6 |
| S54 | Sealed Atomic Desktops test images — Fedora Magazine — https://fedoramagazine.org/sealed-atomic-desktops-test-images/ | 2 | 2026-04-28 | FR5 |
| S55 | podman-build(1) — Podman — https://docs.podman.io/en/latest/markdown/podman-build.1.html | 1 | latest | FR6 |
| S56 | Manifest command (DNF5 plugin) — DNF5 — https://dnf5.readthedocs.io/en/latest/dnf5_plugins/manifest.8.html | 1 | latest | FR6 |
| S57 | RPM lockfiles — Konflux — https://konflux-ci.dev/docs/mintmaker/rpm-lockfile/ | 1 | current | FR6 |

Source numbering is non-contiguous (S8 unused). Tier-3/4 sources are used
only for corroboration.
