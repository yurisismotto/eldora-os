# RES-0004 — Composition Validation Probes (Wave 0.1B-P)

| Field | Value |
|---|---|
| ID | RES-0004 |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1B-P — Composition Validation Probes, parent 0.1B) |
| Related questions | Q-0001, Q-0008 (evidence only) |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): laboratory design, execution of probes in disposable VMs, evidence collection, drafting. No sub-agents were used for this sub-stage. No human has reviewed this report yet. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: accepted as experimental evidence — see [review record](../../project/reviews/WAVE-0.1B-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM–HIGH for observed behaviour in this laboratory; MEDIUM for generalisation (see Limitations) |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records accepted by the Project
> Owner. Composition model: NOT DECIDED.

Laboratory design, scripts and artefacts: [`RES-0004-lab/`](RES-0004-lab/)
(RESEARCH ONLY — NOT PRODUCTION — NOT ELDORA IMPLEMENTATION). The plan
([`LAB-PLAN.md`](RES-0004-lab/LAB-PLAN.md)) was written before execution;
deviations are listed below.

## Question

Does controlled experimental evidence support promoting M3 (bootc/OCI)
over M1 (package-based), per RES-0003 Q19, with focus on PB2 (advanced
administration / escape hatch), PB3 (`/etc` and users/groups drift), PB5
(update trust chain), and derived evidence for PB1 (minimum Eldora
surface) and PB4 (machine state)?

## Scope and out of scope

In scope: the probes above in disposable VMs. Out of scope: Waves 0.1C and
0.1D decisions (rollback policy, health checks, boot counting, recovery UI,
factory reset policy, production registry, CI provider, release pipeline,
installer, bootloader architecture); desktop environments; application
model; UEFI/Secure Boot.

## Laboratory

| Item | Value |
|---|---|
| Host | Project Owner's Fedora 44 workstation, **not modified**; QEMU 10.2.2 with KVM run as an unprivileged user; all files under the job scratch directory, deleted at the end |
| VM-A (LAB-M1 + builder + registry) | Fedora Cloud Base Generic 44-1.7 (SHA-256 `28680fe5…90b7f`, verified against the CHECKSUM file signed by the Fedora 44 key `36F6 12DC F27F 7D1A 48A8 35E4 DBFC F71C 6D9F 90A6`); kernel 6.19.10; after in-VM updates: rpm 6.0.2, systemd 259.9, dnf5 5.4.1; podman 5.8.1; skopeo 1.22.3; docker-distribution 3.1.1; SELinux enforcing; 4 vCPU / 5 GiB; BIOS |
| VM-B (LAB-M3) | Installed with `bootc install to-disk` from lab image v1 built `FROM quay.io/fedora/fedora-bootc:44` (base digest `sha256:ef8a660e…df2c`, version `44.20260925.0`); kernel 7.2.7; bootc 1.16.13; rpm-ostree 2026.2; ostree 2026.4; systemd 259.9; dnf5 5.4.5; podman 5.8.7; selinux-policy 44.10; SELinux enforcing; composefs root; 4 vCPU / 4 GiB; BIOS |
| LAB-M2b | Narrow check inside VM-B only (rpm-ostree layering vs bootc) |
| Lab package | `eldora-lab-config` v1/v2 (one spec): `%config(noreplace)` files, a v2-only file, `/usr` defaults with `/etc` drop-ins, sysusers user/group, a `StateDirectory=` service writing a schema marker, preset |
| Lab images | `eldora-lab:v1`, `:v2` (signed, key A), `:v2u` (unsigned), `:v2b` (signed, untrusted key B), `eldora-lab-plain:44` (plain Fedora bootc base, signed A); tags `:track`, `:latest` created without any key |
| Keys | Ephemeral, generated in VM-A: GPG ed25519 keys A/B for RPMs; sigstore keys A/B for images. Destroyed with the lab |
| Network | See "Network actions" |

## Method

Each probe recorded BEFORE → change → UPDATE → AFTER → ROLLBACK snapshots
with a read-only collector script
([`collect-state.sh`](RES-0004-lab/scripts/collect-state.sh)). Commands are
in [`RES-0004-lab/vm/`](RES-0004-lab/vm/). Output excerpts below are
minimal; full session logs were kept in the job scratch area during the
task (not committed).

## PB3 — `/etc` and users/groups drift

Same package, same local changes in both models: edit `modified.conf`; add
a drop-in; `useradd labuser`; add it to the vendor group `eldoralab`; set
hostname; add a local unit. Update v1→v2, then roll back.

| Item | M1 AFTER UPDATE | M3 AFTER UPDATE | M1 AFTER ROLLBACK (`dnf downgrade`) | M3 AFTER ROLLBACK (`bootc rollback` + reboot) |
|---|---|---|---|---|
| Unmodified vendor file | follows v2 (`value=2`) | follows v2 | back to `value=1` | back to `value=1` |
| Locally modified file | kept (`local`) **+ `modified.conf.rpmnew`** (signalled) | kept (`local`), **no signal** | kept + `.rpmnew` now holding v1 | kept |
| New v2 file | appears | appears | removed | removed |
| Drop-in override (P2) | effective (`color=green level=2`) | effective | effective | effective |
| New v2 user/group | created by RPM sysusers at install | **not** merged from the image (local `/etc/passwd` wins), **but created by `systemd-sysusers` at boot** from `/usr/lib/sysusers.d` | **remain** (not removed) | **absent** (deployment's own `/etc`) |
| Service UID | stable (990) | image v1 built with UID 976; image v2 built with UID **975**; machine keeps 976 — **UID drift between image builds** | stable | 976 |
| `usermod -aG` vendor group created at build (`/etc/group`) | works | works | — | — |
| `usermod -aG` group only in `/usr/lib/group` (`audio`) | n/a | **exit 0, membership not added** (silent failure) | — | — |
| `/var` service state | schema 1→2 appended | schema 1→2 appended | **schema 2 state remains**; v1 appends | **schema 2 state remains**; v1 appends |
| `/etc` edit made after the update | — | — | — | hidden after rollback; **reappeared on roll-forward and was carried into a later deployment** |
| Drift visibility | `.rpmnew`, `dnf` output `created as …rpmnew` | `ostree admin config-diff` lists `M passwd/group/shadow/…` and `M eldora-lab/modified.conf` | same | same |

Evidence excerpts:

```text
M1:  >>> [RPM] /etc/eldora-lab/modified.conf created as /etc/eldora-lab/modified.conf.rpmnew
M3:  /usr/etc/passwd:eldoralab:x:975:975:…      /etc/passwd:eldoralab:x:976:976:…
M3:  systemd-sysusers[682]: Creating user 'eldoralab2' (…) with UID 974 and GID 974.
M3:  usermod -aG audio exit=0 / labuser in audio (count): 0 / /usr/lib/group:audio:x:63:
M3:  after rollback: unmodified.conf value=1; after replacement later: value=edited-after-update
```

**Findings:**
- Both models freeze locally modified files; **M1 signals it (`.rpmnew`),
  M3 does not** (drift visible only through `ostree admin config-diff`).
- In M3 the "hidden new users" pitfall (RES-0003 FS6) occurred for the
  image's `/etc/passwd`, but **systemd-sysusers at boot compensated**
  (working principle P3 is effective in practice).
- **UID/GID drift between image builds is real** without fixed IDs: two
  builds of the same base allocated different IDs; the machine keeps its
  local IDs, so the image's view and the machine diverge.
- The documented silent `usermod -aG` failure is **confirmed only for
  groups defined solely in `/usr/lib/group`**.
- M1 rollback (downgrade) is **incomplete** for users and state; M3
  rollback cleanly restores the OS side (including users) but not `/var`.
- M3 `/etc` rollback semantics are **non-intuitive**: edits made after an
  update are hidden by rollback, but persist in the other deployment and
  return on roll-forward.

## PB2 — advanced administration / "Yours"

| Operation | M1 | M3 (bootc) | M2b (rpm-ostree on bootc host) |
|---|---|---|---|
| O1 persistent CLI tool (`strace`) | `dnf install`: 1 step, no reboot, persists, updated by dnf | `dnf install` **refused** with guidance ("…configured to be read-only. Pass --transient…"); `--transient`: 1 step, **lost on reboot**; persistent via **local derived image**: write Containerfile + `podman build` (**90 s**, pulled the full image into podman storage) + `bootc switch --transport containers-storage` + reboot = 3 steps + reboot; persisted | `rpm-ostree install htop`: 1 step (39 s) + reboot; persisted |
| Side effects of O1 | none | while on the local image, `bootc upgrade --check` → "No changes in: …localhost/eldora-local…" — **the machine stops following upstream updates**; local image deployed as `ostree-unverified-image` | `bootc upgrade` **refused**: "Deployment contains local rpm-ostree modifications; cannot upgrade via bootc. You can run `rpm-ostree reset`…"; `rpm-ostree upgrade` still works; **`bootc switch` succeeded and silently discarded the layered package** |
| O2 local systemd unit in `/etc` | 3 steps, persists | 3 steps, persists across update (merge) | same as M3 |
| O3 configuration drop-in | persists, effective | persists, effective | — |
| O4 write `/usr/local`, `/opt`, `/usr/bin` | writable | **read-only** (all three) | read-only |
| O5 container tooling | podman | podman and `toolbox` present in the Fedora bootc image | — |
| O6 revert | `dnf remove`: 1 step | `bootc switch` back to the registry image + reboot | layering removal via rpm-ostree, or discarded by `bootc switch` |

**Findings:** M3 offers a persistent escape hatch (local derived image)
that is **powerful but operationally hostile for everyday use**: it needs
Containerfile knowledge, minutes of build time and a reboot, and it
**detaches the machine from upstream updates** until the user rebuilds or
switches back. `/etc` customization and containers are comfortable. The
M2b path is the easiest persistent host change on an image-based host but
**blocks `bootc upgrade`** and is silently undone by `bootc switch`.

## PB5 — update trust chain

### M1 (RPM)

| Test | Result |
|---|---|
| F44 default `_pkgverify_level` | `digest` (signature not required by default on F44; F45 changes this, RES-0001/FA4) |
| T1 unsigned, default | **accepted** |
| T2 unsigned, `_pkgverify_level all` | rejected: "does not verify: no signature" |
| T3 signed by untrusted key B, level all | rejected: "NOKEY" |
| T4 signed by trusted key A, level all | accepted |
| T5 dnf repo `gpgcheck=1` (key A) serving B-signed package | rejected: "Import of the key didn't help, wrong key?" |

### M3 (OCI / bootc)

| Test | Result |
|---|---|
| Build: dnf in Containerfile installing a local lab RPM | **"Warning: skipped OpenPGP checks for 1 package from repository: @commandline"** — build inputs not verified by default |
| T1 default policy (`insecureAcceptAnything`), unsigned image | **accepted** (staged as OS update) |
| T5 default policy + `--enforce-container-sigpolicy` | rejected: "containers-policy.json specifies a default of `insecureAcceptAnything`; refusing usage" |
| T2 enforced sigstore policy, signed by trusted key A | accepted |
| T3 enforced, unsigned | rejected: "A signature was required, but no signature exists" |
| T4 enforced, signed by untrusted key B | rejected: "cryptographic signature verification failed" |
| T6a/T6b digest-pinned reference after the tag moved | "No changes" (pinned); tag-tracking reference detected the update (2 layers, 11.4 MB of 68 layers / 1.1 GB) |
| T7a old signed image served under a new tag, `signedIdentity: matchRepository` | **accepted** — registry-side re-tagging (no key) can serve an older signed image |
| T7b same, default identity (`matchRepoDigestOrExact`) | rejected: "Signature for identity "labregistry:5000/eldora-lab:v1" is not accepted" |
| T7c tag promotion by re-pointing (`:track`), default identity | **rejected** (same reason) — exact identity forbids promotion without re-signing |
| Local derived image (PB2) | deployed as `ostree-unverified-image:containers-storage:…` |

### Guarantee classification

| Guarantee | M1 | M3 |
|---|---|---|
| Package signature verification | F44: CONFIGURABLE; F45: DEFAULT | Build time: CONFIGURABLE (not default for local RPMs) |
| Image signature verification | n/a | CONFIGURABLE (default accepts anything) |
| Trusted key distribution and policy on clients | ELDORA MUST PROVIDE (repo key) | ELDORA MUST PROVIDE (policy.json, registries.d, keys) |
| Digest pinning | n/a (versionlock) | CONFIGURABLE |
| Freshness / anti-rollback (replay of older signed content) | metalink freshness for Fedora mirrors (RES-0003); for an Eldora repo: ELDORA MUST PROVIDE | **NOT CURRENTLY AVAILABLE** in the tested chain; the identity rule trades cross-tag replay protection against tag promotion |
| Verification of locally built images | n/a | NOT CURRENTLY AVAILABLE (unverified by design) |

## PB1 — minimum Eldora-owned surface (derived evidence)

The **same signed RPM** (`eldora-lab-config`) served both models unchanged
(M1 host install; M3 image build) — evidence for working principle P4 and
for RES-0003 H1 (surface is largely model-independent).

| Artefact the lab had to own | M1 | M3 |
|---|---|---|
| Package spec and signed RPMs | yes | yes (same) |
| RPM signing key + public key distribution | yes | yes (build side) |
| RPM repository + client repo definition | yes | build-time only |
| Image definition (Containerfile) + base-image choice | — | yes |
| Image build capacity (minutes; ~1.1 GB images) | — | yes |
| Registry + image signing key + signature attachments | — | yes |
| Client trust policy (`policy.json`, `registries.d`, key) | — | yes |
| Installer invocation details (`--filesystem` required) | — | yes |

**Finding:** the component surface is identical; M3 adds image,
registry, signing and client-policy responsibilities (confirms RES-0003
Q14).

## PB4 — machine state across update, rollback and replacement (M3 focus)

| State | v1→v2 update | rollback | replacement by a different image (plain `fedora-bootc:44`) |
|---|---|---|---|
| machine-id (hash `b1f1d19f…`) | kept | kept | kept |
| SSH host keys (3 fingerprints) | kept | kept | kept |
| hostname (`lab-m3-custom`) | kept | kept | kept |
| `/home/labuser/marker.txt` | kept | kept | kept |
| `/var/lib/eldora-lab/state.log` | kept, appended | kept (newer schema lines remain) | kept, **service absent** |
| local unit in `/etc` | kept | kept | kept |
| config of the removed package | — | — | **locally modified/added files remain as orphans**; unmodified files removed |
| lab users/groups | new created by sysusers | OS-side reverted | **remain as orphans** (frozen local `/etc/passwd`) |

M1 symmetric check (`dnf remove` of the lab package): leaves
`modified.conf.rpmsave`, a stale `.rpmnew`, the drop-in, users/groups and
`/var` state — **orphaned machine state is model-independent**; M1
renames modified files (signalled), M3 leaves them in place.

## Metrics summary

| Metric | M1 | M3 | Notes |
|---|---|---|---|
| Steps: persistent CLI tool | 1 | 3 + reboot (local image) | M2b: 1 + reboot, blocks `bootc upgrade` |
| Rebuild needed for persistent `/usr` change | no | yes | |
| Reboot for OS update to apply | no (package-level) | yes (~15–16 s per reboot in lab) | |
| Update compatibility after local customization | preserved | preserved for `/etc`/`/var`; lost for local image (no upstream tracking) and rpm-ostree layering (bootc blocked) | |
| Rollback behaviour | partial (users/state remain) | clean for OS incl. users; `/var` not rolled back; `/etc` hidden/restored semantics | |
| Failure visibility | `.rpmnew`/`.rpmsave`, dnf messages | explicit errors for dnf and bootc; silent `/etc` freezing; bootloader-update failure only in journal | |
| State outside the image | everything is host state | `/etc` (4 local identity files, config, units), `/var`, `/home` | |
| Specialist knowledge | RPM/dnf | Containerfile, bootc, policy.json, registries.d, sysusers | |
| Update size (lab) | n/a | 2 changed layers, 11.4 MB, of 1.1 GB | tag-tracking v1→v2 |

No aggregate score is computed; metrics are not commensurable.

## Documentation vs observed behaviour

| # | Documentation (source) | Observed |
|---|---|---|
| DV1 | Fedora bootc: OS auto-updates by default via `bootc-fetch-apply-updates.timer` (RES-0003 FR2) | Timer **disabled** on the installed lab system |
| DV2 | dnf on bootc "will error out" (Fedora docs 2024) | Refuses with an explicit message pointing to `--transient` (improved UX) |
| DV3 | Rollback: `/etc` changes "won't carry over" (bootc/Fedora) | Correct for the rolled-back boot, but the edits survive in the other deployment and **return on roll-forward** |
| DV4 | Not documented in sources read | `bootc switch` silently discards rpm-ostree layered packages |
| DV5 | Local `/etc/passwd` edits hide new image users (bootc docs) | True for the image file, but **sysusers at boot created them** |
| DV6 | Install examples | Fedora base required explicit `--filesystem` ("No root filesystem specified") |
| DV7 | — | `bootloader-update.service` failed ("opening EFI dir") in a BIOS-booted VM — likely lab artefact (UNVERIFIED on UEFI) |

## Failure modes observed

- Silent freezing of locally modified `/etc` files (M3); signalled freezing
  (M1).
- UID/GID drift between image builds (M3).
- Silent `usermod -aG` no-op for `/usr/lib/group`-only groups (M3).
- Detachment from upstream updates after switching to a local image (M3).
- `bootc upgrade` blocked by rpm-ostree layering (M2b); layering silently
  discarded by `bootc switch`.
- Unsigned image accepted as an OS update under the default policy (M3);
  unsigned RPM accepted on F44 default (M1).
- Old signed image accepted under a new tag with `matchRepository` (M3).
- Build-time acceptance of unverified local RPMs (M3 build).
- Orphaned configuration, accounts and state after package/image removal
  (both).
- Older service running over newer `/var` state after rollback (both).
- Bootloader update failure visible only in the journal (lab, BIOS).

## Implications for "Simple. Powerful. Yours."

(INFERENCE) *Simple by default*: M3 delivers predictable OS updates and
clean OS rollback; M1 is simple but less predictable. *Powerful when
needed*: M1 wins today; M3's persistent host power exists but is expert
territory and silently costs upstream updates; containers/toolbox cover
development well. *Yours*: M3 honours local `/etc`, `/var` and `/home`,
but host software ownership requires either Eldora-provided tooling for
local derivation that keeps tracking updates, or accepting the M2b
trade-offs. Without such tooling, M3 risks feeling hostile to power users
(RISK-0006 confirmed).

## Evidence Against M3 (from this laboratory)

PB2 escape-hatch cost and update detachment; silent `/etc` freezing;
UID/GID drift; permissive trust defaults; no freshness protection; build
inputs unverified by default; non-intuitive `/etc` rollback semantics;
bootloader update failure (lab-specific).

## Evidence Against M1 (from this laboratory)

Unsigned RPMs accepted by default on F44; downgrade leaves new users and
newer state; no OS-level rollback; host mutations directly alter `/usr`
(`/usr/local`, `/opt` writable), so the installed state is not tied to any
reproducible artefact.

## Attempt to falsify the recommendation

Recommendation below: keep M3 leading with MORE EVIDENCE REQUIRED.
- *"M3 is operationally hostile, so M1 should prevail"*: PB2 supports
  hostility for persistent host changes, but PB3/PB4 show M3's OS/state
  separation and clean OS rollback, and PB5 shows strong enforcement once
  configured. The hostility is concentrated in one area that Eldora could
  address with tooling. **Not falsified, but this is the decisive open
  issue.**
- *"M3's drift advantage is illusory"*: partly — `/etc` drift and orphans
  behave similarly in both, and M1 signals drift better; M3 still keeps
  `/usr` exact and rollback clean. **Weakens the advantage.**
- *"M1 is unacceptable"*: not shown; its costs (partial rollback, weaker
  default verification on F44) are real but familiar. **M1 remains valid.**

## Q19 — revisited

**MORE EVIDENCE REQUIRED.** The laboratory narrowed the gap but did not
close it. Exact evidence still missing:

1. **E1 — Desktop image behaviour** (RISK-0003): a GNOME/KDE-class desktop
   image on Fedora bootc, including graphical update UX and Flatpak
   coexistence.
2. **E2 — Escape-hatch design validation** (RISK-0006): whether a supported
   workflow (e.g., managed local derivation that keeps tracking upstream,
   the rpm-ostree client path M2b, or a future supported extension
   mechanism) makes persistent host changes acceptable for power users.
3. **E3 — UEFI/Secure Boot and bootloader updates** (RISK-0002, 0.1D): the
   BIOS lab could not assess them; bootloader-update failed in BIOS mode.
4. **E4 — Release rebase cost** (RISK-0001, PX1): F44→F45 for both models.
5. **E5 — UID/GID stabilization** (RISK-0005): verify that fixed IDs in
   sysusers (or equivalent) eliminate drift across image builds.

## Recommendation

A recommendation is not a decision.

- Keep **M3 as leading candidate**, **M1 as required fallback**; keep
  **M2b on record** (practical escape hatch observed; forward-compatibility
  risk with bootc remains; not promoted).
- Record, for later decisions, what Eldora **must provide** if M3 is
  chosen: enforced signature policy with trusted keys; a signing strategy
  that addresses tag identity vs promotion and freshness; verification of
  build inputs; stable UID/GIDs; drift visibility for `/etc`; an
  orphaned-state policy; and a supported power-user path.
- Working principles P1–P4 and P6 were **supported** by evidence (drop-ins
  effective; sysusers compensated; same RPM served both models; state
  separation observable). P5 was not exercised.
- **Confidence:** MEDIUM.

## Risk impacts

- **RISK-0005:** confirmed and sharpened (UID/GID drift between builds;
  silent `/etc` freezing; orphans; non-intuitive rollback of `/etc`).
- **RISK-0006:** confirmed (escape hatch expensive and detaching; M2b
  blocks bootc).
- **RISK-0007:** confirmed (unsigned image accepted by default) and
  extended (no freshness; identity trade-off).
- **RISK-0001, RISK-0003, RISK-0004:** unchanged; E1/E4 remain.
- No risk status is changed by this report.

### Candidate new risks (recommended; no RISK-ID created)

| Candidate | Description | Evidence |
|---|---|---|
| RC-D | No freshness/anti-rollback protection in the OCI update chain; signature identity rules trade replay protection against tag promotion. | PB5 T7a–T7c |
| RC-E | Build-time supply-chain gap: local RPMs installed into images without signature verification by default; locally built images deployed unverified. | PB5 build warning; PB2 local image |

## Forwarded to Wave 0.1C

Signature/identity/freshness policy design (T7); `/etc` rollback semantics
(DV3); state schema compatibility after rollback (PB3/PB4 `/var`);
orphaned-state cleanup and factory reset scope (PB4); auto-update default
(DV1); behaviour when a machine tracks a local image (update detachment).

## Forwarded to Wave 0.1D

Installer parameters (`--filesystem`, DV6); bootloader update on UEFI
(DV7, E3); build-input verification in the image pipeline (RC-E); image
signing and per-tag/channel strategy; update size (11.4 MB of 1.1 GB for a
small component change; rechunking); fixed UID/GID allocation in builds
(E5).

## Limitations

- Single lab run, BIOS boot, server-class Fedora bootc base without a
  desktop; results are not generalized beyond the tested cases.
- Local registry over HTTP (insecure transport) in an isolated lab;
  transport security was not evaluated.
- M1 update/rollback used a single package; system-wide release upgrades
  were not exercised.
- Host podman image count (15) was pre-existing; the lab never ran podman
  on the host.

## Network actions

1. Host → `dl.fedoraproject.org`: Fedora Cloud 44 CHECKSUM and qcow2
   (583 MB); host → `fedoraproject.org/fedora.gpg` (public keys), used in a
   temporary keyring under the lab directory.
2. VM-A/VM-B → Fedora package mirrors (dnf) inside the VMs.
3. VM-A → `quay.io/fedora/fedora-bootc:44` pull (inside the VM).
4. VM-B → VM-A lab registry through a loopback port forward.
No GitHub, API, cloud, publication or upload actions.

## Decision

NOT TAKEN — composition model (Q-0001) and update/rollback model (Q-0008)
remain undecided.

## Sources

Primary evidence is the laboratory output described above (tier: local
experimental evidence with environment, steps and outputs recorded, per
`docs/research/README.md`). Documentary context: RES-0001, RES-0002,
RES-0003 and their sources (bootc book, Fedora bootc docs, OSTree docs,
DNF5 docs). Base artefacts: Fedora Cloud Base Generic 44-1.7
(https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images/,
accessed 2026-09-26, tier 1) and `quay.io/fedora/fedora-bootc:44`
(version 44.20260925.0, pulled 2026-09-26 inside VM-A, tier 1).
