# RES-0006 — Update State Machine & Failure Semantics (Wave 0.1C-A)

| Field | Value |
|---|---|
| ID | RES-0006 |
| Title | Update State Machine & Failure Semantics |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1C-A — Update State Machine & Failure Semantics, parent 0.1C) |
| Related questions | Q-0008 |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): planning; documentary research through four delegated research sub-agents (bootc/OSTree lifecycle; boot success and boot chain; RISK-0010 `/boot` automount; trust, freshness, state and policy primitives); author spot-checks of load-bearing bootc quotes; re-analysis of RES-0004/RES-0005 versioned evidence; drafting; a second, Project Owner–authorized read-only pass over the bootc and ostree GitHub issue trackers for RISK-0010 (Part 5). Process deviations are disclosed under "Method and limitations". Editorial corrections requested at Project Owner review were applied by the agent on Project Owner instruction (listed in the review record). |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: APPROVED WITH EDITORIAL CORRECTIONS — see [review record](../../project/reviews/WAVE-0.1C-REVIEW.md)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (documentary; several items UNVERIFIED; see "Confidence and limitations") |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records accepted by the Project
> Owner. ADR-0001 (M3 SELECTED FOR V1) is **not** reopened by this report.
> Q-0008 remains **NOT DECIDED**. RISK-0010 remains **OPEN / RELEASE
> BLOCKER FOR M3**. No probe was executed; no failure was injected; nothing
> was implemented.

Labels used: **FACT** (documented upstream, cited `[Sn]`), **OBSERVED**
(versioned laboratory evidence in RES-0004/RES-0005, cited `[RES-000x]`),
**INFERENCE** (reasoned from facts/observations), **HYPOTHESIS** (to be
tested), **RECOMMENDATION** (not a decision), **OPEN QUESTION**.
`UNVERIFIED` marks a claim that could not be confirmed from an allowed
primary source.

## Question

What is the real update state machine available to an Eldora OS V1 based
on bootc/OCI (ADR-0001, M3), which states and failures are observable, and
which additional responsibilities must Eldora own?

This report determines the behaviour of the selected technologies first;
it does **not** design the Eldora solution.

## Scope

Parts 1–12 of the 0.1C-A brief: bootc update lifecycle; component
boundaries; observability; failure matrix F01–F26; deep re-analysis of
RISK-0010; success semantics; boot-success mechanisms; persistent state;
trust/freshness; UX event semantics; update-policy questions; local
diagnostics. Default backend analysed: **OSTree backend** (what Fedora
bootc images and the RES-0004/RES-0005 laboratories used). The
composefs-native backend is covered where it differs.

## Out of Scope

Designing the Eldora update engine or UI; selecting policies, signing
infrastructure, telemetry, installer or bootloader architecture; executing
probes or failure injection; sub-stages 0.1C-B, 0.1C-C, 0.1C-F and Wave
0.1D; reopening ADR-0001; closing or re-rating risks.

## Method and limitations

- Documentary research on 2026-09-26 with four research sub-agents
  constrained to public documentation, followed by author spot-checks of the
  bootc quotes on which conclusions depend (marked "(verified)"; checked
  against a local text copy of the bootc book print page).
- Local Tier-1 sources: man pages and unit files installed on the Project
  Owner's Fedora 44 workstation (systemd 259.9, grub2 2.12-64,
  containers-common 0.67.2, shim-x64 16.1-5), read-only. bootc, ostree CLI,
  rpm-ostree, bootupd and greenboot are **not** installed there.
- Evidence re-analysed: RES-0004 and RES-0005 reports and their versioned
  lab scripts (notably `RES-0005-lab/vm/d-trial.sh`, `d-mitigation.sh`,
  `d-diag-finalize.sh`, `d-automount-origin.sh`, `d-boot-mounts.sh`). Raw
  session logs of those labs were not committed and are not available.
- **GitHub (first pass: not consulted).** Per `AGENTS.md` ("GitHub and
  remote authority"), github.com, raw.githubusercontent.com and the GitHub
  API were initially treated as off-limits. Documentation sites hosted as
  project documentation (bootc.dev, ostreedev.github.io, coreos.github.io)
  were read as documents, as in RES-0003/RES-0005.
- **GitHub (second pass, authorized).** On 2026-09-26 the Project Owner
  explicitly authorized **read-only** consultation of the official bootc
  and ostreedev/ostree issue trackers (and, only if strictly necessary for
  the same finding, systemd and Fedora trackers) **exclusively to clarify
  RISK-0010**. Only public, unauthenticated issue/PR/commit/release web
  pages were viewed (no `gh`, no API, no login, no writes, no Git remote
  operation). Results are in Part 5, "Upstream issue-tracker evidence".
  Source code, bootupd, greenboot and the OCI spec text remain unread;
  claims depending on them stay UNVERIFIED.
- docs.fedoraproject.org returned a bot-protection "access denied" page to
  the sub-agents on 2026-09-26; Fedora bootc and Fedora IoT pages could not
  be re-read. Fedora-specific claims rely on RES-0003 (read 2026-09-26),
  Fedora wiki Change pages, and lab observations.
- Web fetches pass through a summarising tool; quotes not marked
  "(verified)" may carry minor paraphrase drift and should be re-checked
  before citation in a decision record.
- **Process deviations (disclosed):**
  1. One sub-agent fetched one github.com page
     (`opencontainers/image-spec/.../annotations.md`) by mistake — anonymous,
     read-only; its content is **not** used as evidence here.
  2. One sub-agent downloaded the public bootc book print page
     (`https://bootc.dev/bootc/print.html`, ~390 KB) with `curl` into `/tmp`
     instead of the web-fetch tool; it was used for local quote checks and
     deleted at the end of the task. No GitHub, registry or remote Git
     contact was involved.
  3. One sub-agent ran a read-only `ls` of `/usr/lib/grub/x86_64-efi` and
     `strings` on the local gpt-auto generator binary.
  No Git remote operation, `gh`, GitHub API, registry enumeration, image
  pull, VM, sudo or package installation was performed.

## Part 1 — bootc update lifecycle (OSTree backend)

### Facts

- **FACT L1 — discovery.** `bootc upgrade` queries "the container image
  source" tracked by the host; `bootc upgrade --check` "only downloads the
  updated manifest and image configuration (typically kilobyte-sized
  metadata)" (verified) [S1, S2]. The result is recorded as
  `status.*.cachedUpdate` ("The last fetched cached update metadata") [S3].
  A digest-pinned reference makes `upgrade` a no-op; a tag reference
  follows the tag [S4; RES-0004 T6a/T6b OBSERVED].
- **FACT L2 — identity.** Deployed images are identified by manifest digest
  (`image.imageDigest`, "The digest of the fetched image"), with optional
  `version` and build `timestamp` [S3]. ostree-ext stores the manifest digest
  as commit metadata `ostree.manifest-digest` and recognises a `version`
  label [S5].
- **FACT L3 — fetch.** ostree-ext uses `containers-image-proxy` (skopeo) to
  contact registries; each layer is "fetched, decompressed, and imported as
  an ostree commit"; "Only changed layers are downloaded" [S5, S6].
  Content-digest verification of layers is implied by content addressing
  ("cached by their content digest") but no explicit guarantee statement
  was found — **UNVERIFIED as a documented guarantee**.
- **FACT L4 — signature policy.** Verification depends on the origin
  transport/`ImageSignature`: `containerPolicy` defers to
  `containers-policy.json` "but we make a best effort to reject `default:
  insecureAcceptAnything`"; `insecure` performs no verification;
  `ostreeRemote` verifies the ostree commit signature [S3, S6];
  `--enforce-container-sigpolicy` enforces the policy on switch/install
  [S4, S7]. OBSERVED: default policy accepted an unsigned image; enforced
  sigstore policy rejected unsigned and wrongly-signed images [RES-0004
  PB5].
- **FACT L5 — staging.** "The new deployment is still created when the
  command is invoked, but the 3-way `/etc` merge is delayed until the system
  is rebooted or shut down. … This is done by the
  `ostree-finalize-staged.service` systemd unit" [S8]. "Currently by
  default, the update will be applied at shutdown time via
  `ostree-finalize-staged.service`" (verified) [S2].
- **FACT L6 — when `/boot` changes.** "ostree writes a new set of files in
  `/boot/loader/entries` (during `ostree-finalize-staged.service` on system
  shutdown)" [S9]. Exactly when the kernel/initramfs are copied into `/boot`
  (stage or finalize) is **UNVERIFIED**. Kernel and initramfs are part of the
  image (`/usr/lib/modules/$kver/`), generated at image build time
  [RES-0003 IM2].
- **FACT L7 — download-only (locked staging).** `bootc upgrade
  --download-only` creates "a staged deployment in download-only mode. The
  deployment will not be applied on shutdown or reboot until you explicitly
  apply it"; `--from-downloaded` "unlocks the staged deployment"; "If you
  reboot before applying a download-only update, the system will boot into
  the current deployment and the staged deployment will be discarded.
  However, the downloaded image data remains cached" (verified) [S2]. OSTree
  exposes the underlying "finalization locked" state [S10]. Status field
  `downloadOnly` [S3].
- **FACT L8 — apply / reboot.** `--apply` "currently always reboots the
  system"; upstream states that in future "reboots outside of a `bootc
  upgrade --apply` do not automatically apply the update" (verified) [S2].
  `--soft-reboot=required|auto` exists (verified) [S2]; status field
  `softRebootCapable` [S3].
- **FACT L9 — boot selection.** Each deployment has a BLS entry
  `ostree-$stateroot-$checksum.$serial.conf` with an `ostree=` kernel
  argument used by the initramfs (`ostree-prepare-root`) to enter the
  deployment [S8, S11].
- **FACT L10 — preservation, rollback, roll-forward.** `bootc rollback`:
  "Change the bootloader entry ordering; the deployment under `rollback`
  will be queued for the next boot, and the current will become rollback. If
  there is a `staged` entry … then it will be discarded"; `/etc` changes do
  not carry over; an update agent such as `bootc-fetch-apply-updates.timer`
  may revert the rollback [S12, S2]. Status `rollbackQueued`, spec
  `bootOrder: default|rollback` [S3]. There is no "roll-forward" verb;
  OBSERVED roll-forward was performed by rolling back again or re-staging
  [RES-0004, RES-0005]. Pinning (`ostree admin pin`) protects deployments
  from garbage collection [S13]; the number of retained deployments beyond
  booted + rollback (+ staged) is **UNVERIFIED**.
- **FACT L11 — switch vs upgrade.** "`bootc switch` has the same effect as
  `bootc upgrade`; there is no semantic difference between the two other
  than changing the container image being tracked" (verified) [S2]. Both
  preserve `/etc` and `/var` state. OBSERVED: `bootc switch` silently
  discarded rpm-ostree layering [RES-0004 DV4].
- **FACT L12 — atomicity boundary.** OSTree swaps boot configuration with
  the "swapped directory pattern": "we create `/ostree/boot.1`, populate it
  with the new contents, then atomically swap the symbolic link"; "the
  currently booted deployment must always be in the new set" [S14]. "If the
  system crashes or you pull the power, you will have either the old
  system, or the new one" [RES-0003 FR1].
- **FACT L13 — failure detection contract.** "When
  `ostree-finalize-staged.service` fails during shutdown/reboot, this will
  create a stamp file in `/boot`, and then on a subsequent reboot the
  `ostree-boot-complete.service` service will detect it, and then itself
  exit with a failure mode" (verified) [S2]. For the composefs backend
  "there is not currently a similar -boot-complete.service"; operators are
  told to check `journalctl -u bootc-finalize-staged.service -b -1`
  (verified) [S2]. OSTree documents that the failure mode "can be confusing
  (the machine will reboot into the same deployment)" [S8].
- **FACT L14 — progress.** `--progress-fd` emits JSON Lines with stages
  "pulling, importing, and staging"; it is **experimental** and "new stages
  or fields may be added at any time" (verified) [S2].
- **FACT L15 — status change hook.** `bootc-status-updated.path` watches
  `/ostree/bootc`; "bootc updates the mtime on its root directory when the
  contents of bootc status changes as a result of an
  update/upgrade/edit/switch/rollback operation", triggering
  `bootc-status-updated.target` (verified) [S2].
- **FACT L16 — API surface.** "bootc is primarily intended to be driven via
  a fork/exec model"; `bootc status --json --format-version=1`
  (`org.containers.bootc/v1`, stable); do not parse human-readable output
  (verified) [S2, S15]. No bootc D-Bus API was found; rpm-ostree has a
  D-Bus daemon (`org.projectatomic.rpmostree1`) and, for container origins,
  "`rpm-ostree upgrade` and `bootc upgrade` are effectively equivalent"
  [S16, S17].

### State machine actually found (INFERENCE from L1–L16)

```text
                    (timer / user / agent)
IDLE ──check──► UPDATE_AVAILABLE (cachedUpdate differs from booted digest)
  │                   │ upgrade/switch
  │                   ▼
  │             FETCHING (pull → import → stage; --progress-fd, experimental)
  │               │ error ─────────────► FETCH_FAILED  (CLI exit ≠ 0; no persistent record)
  │               │ policy reject ─────► REJECTED      (CLI error; no persistent record)
  │               ▼
  │             STAGED (status.staged set; downloadOnly = false)      STAGED_LOCKED (downloadOnly = true)
  │               │                     ◄──--from-downloaded──────────┘   │ reboot → DISCARDED (documented)
  │               │ orderly shutdown/reboot (any initiator)
  │               │   [abrupt power loss / hard reset instead: finalization never runs → SILENTLY_LOST (F13)]
  │               ▼
  │             FINALIZING (ostree-finalize-staged ExecStop: /etc merge, BLS write, boot.N swap)
  │               │ failure ─► FINALIZE_FAILED → stamp in /boot (contract) → reboot into OLD deployment
  │               │            └─ RISK-0010 path: no stamp → SILENTLY_LOST (OBSERVED)
  │               ▼
  │             BOOTING_NEW (bootloader picks first BLS entry; initramfs ostree-prepare-root)
  │               │ kernel/initramfs/rootfs failure ─► (no automatic fallback unless boot counting
  │               │                                     is configured AND honoured by the loader)
  │               ▼
  │             BOOTED_NEW (status.booted = new digest; previous = status.rollback)
  │               │ upstream stops here: no health state, no "known good"
  │               ▼
  └────────────  [ELDORA-DEFINED: VALIDATING → HEALTHY / KNOWN_GOOD or → ROLLBACK/RECOVERY]
ROLLBACK_QUEUED (bootc rollback: reorders entries; discards staged) ─► reboot ─► BOOTED_PREVIOUS
```

**Comparison with the working hypothesis** (AVAILABLE → AUTHENTIC →
ELIGIBLE → DOWNLOADED → VERIFIED → STAGED → REBOOT → BOOT CANDIDATE →
HEALTH VALIDATION → KNOWN GOOD):

| Hypothesis state | Upstream reality | Change |
|---|---|---|
| AVAILABLE | Exists (`--check`, `cachedUpdate`) | keep |
| AUTHENTIC | Not a separate observable state; signature policy evaluated inside fetch; failure = CLI error | **merge into FETCHING** as a gate; not persistently observable |
| ELIGIBLE | **Does not exist upstream** (no version ordering, no channel/policy eligibility, no downgrade refusal documented) | **ELDORA MUST DEFINE**; must occur *before* fetch/stage |
| DOWNLOADED / VERIFIED | Not separable: pull, import and stage are one operation; layer digests verified by content addressing (UNVERIFIED as documented guarantee) | **merge** into FETCHING→STAGED |
| STAGED | Exists; **split** into STAGED and STAGED_LOCKED (download-only) | split |
| REBOOT | **Split**: FINALIZING (shutdown, not atomic w.r.t. `/etc` merge) then atomic boot-config swap | add FINALIZING and FINALIZE_FAILED / SILENTLY_LOST |
| BOOT CANDIDATE | Exists only if boot counting is configured and honoured by the loader (UNVERIFIED for Fedora GRUB) | conditional |
| HEALTH VALIDATION | **Not upstream** (bootc: "The system must perform health checking on itself (or have an external system do it)") [S2] | ELDORA MUST DEFINE |
| KNOWN GOOD | **Not upstream**; only `booted`/`rollback` slots; no health attribute | ELDORA MUST DEFINE |
| FAILURE / ROLLBACK / RECOVERY | Rollback = manual reorder; failure detection partial; recovery = boot menu / reinstall | Eldora must define automatic paths |
| (missing) | DISCARDED (download-only across reboot; staged discarded by rollback/switch) | add |
| (missing) | ROLLBACK_QUEUED | add |

### What is transactional and what is not (INFERENCE from L5, L12, FACT B-series)

| Operation | Atomic / transactional boundary | Not covered |
|---|---|---|
| Fetch/import into repo | Content-addressed objects; partial pulls leave unreferenced objects, the booted system is untouched | progress is not persisted; a crash leaves cache/garbage (UNVERIFIED exact cleanup) |
| Stage (deployment directory created) | Deployment is created but not bootable until finalization | disk space consumed; `/etc` not yet merged |
| Finalization `/etc` 3-way merge | **not** atomic by itself; failure aborts before the swap | a failed merge leaves the old configuration active [S18] |
| Boot configuration swap (`/ostree/boot.N` symlink) | **Atomic** (rename of symlink) — this is the only documented atomic boundary | — |
| `/var` | never versioned | no rollback |
| ESP binaries (shim/GRUB) via `bootloader-update.service` | per-ESP atomic `RENAME_EXCHANGE` on UEFI only [S19] | not tied to any deployment; BIOS updates "lack the atomic guarantees" [S19] |
| Rollback | atomic reorder of boot entries | `/etc` edits not carried; `/var` untouched; ESP untouched |

"Atomic" in this report means only: *after power loss at any point, the
next boot selects either the complete previous boot configuration or the
complete new one*. It does **not** mean the update succeeded, that state is
consistent, or that the boot chain matches the OS.

## Part 2 — Component responsibility map

Classes: **UP** upstream mechanism; **FE** Fedora integration; **ED**
Eldora must define; **EX** Eldora may extend; **OOS** out of scope for
0.1C-A.

| Component | Real responsibility (evidence) | Class |
|---|---|---|
| bootc | CLI/API: check, fetch, stage, lock, apply, rollback, switch, status JSON, status-updated path, progress-fd [S2, S3] | UP |
| OSTree | Object store, deployments, `/etc` merge, BLS entries, atomic boot swap, finalize and boot-complete units, optional boot-counting-tries [S8, S9, S14, S20] | UP |
| ostree-container (ostree-ext) | OCI → ostree import, manifest-digest metadata, transports, signature policy hand-off [S5, S6] | UP |
| systemd | Shutdown ordering of finalization, generators (gpt-auto), boot-complete.target, bless-boot, soft-reboot, `ConditionNeedsUpdate` [S21–S26] | UP |
| systemd-boot | Implements boot counting; with bootc supported **only** for the composefs backend [S27] | UP / OOS (V1 default is GRUB) |
| GRUB (Fedora) | Boot entry selection via blscfg; grubenv `boot_success`/`boot_indeterminate`; Fedora-specific fallback counting scripts (contents UNVERIFIED) [S28–S30] | FE |
| shim | First-stage Secure Boot loader, fallback path `EFI/BOOT/BOOTX64.EFI` + `fbx64.efi`; SBAT revocation [S31, S32] | FE / UP |
| kernel, initramfs | Built into the image; initramfs runs `ostree-prepare-root` (and composefs) [S11; RES-0003 IM2] | FE; ED for kargs policy |
| `bootloader-update.service` / bootupd | Updates ESP on next boot, atomic per-ESP swap on UEFI, not rolled back ("Ignoring downgrade" OBSERVED) [S19, S27; RES-0005 E3] | FE (default on Atomic Desktops since F41) |
| Filesystem | Root layout; physical `/boot` placement depends on install method [S33] | ED (with 0.1D) |
| `/boot` | Holds BLS entries, kernels, finalize stamp; mount ownership undefined in bootc `to-disk` without LUKS (RISK-0010) | **ED** (with 0.1D) |
| EFI System Partition | Shared by all deployments; single version of shim/GRUB | ED (boot-chain policy, RISK-0011) |
| Container registry | Serves manifests/layers/signatures; availability is Eldora's | ED (0.1D) |
| Image verification policy | `policy.json`, `registries.d`, keys; default permissive | **ED** (C3; RISK-0007) |
| SELinux | Policy is image content; `/etc/selinux` local changes persist and merge | FE; EX |
| Fedora packaging | Unit presets (e.g. whether `bootc-fetch-apply-updates.timer` is enabled — disabled in the labs, DV1) | FE; ED for Eldora presets |
| Persistent machine state (`/etc`, `/var`, `/home`) | Never rolled back (`/var`), per-deployment (`/etc`) | ED (compatibility rules) |
| Health validation, known-good, automatic rollback | Not provided upstream for bootc (§7) | **ED** |
| Freshness / anti-rollback of images | Not provided upstream for bootc (§9) | **ED** (with 0.1D) |
| Update policy (when to check/stage/reboot) | Primitives only; defaults vary by distribution | **ED** (0.1C-B) |
| User-facing events | Only status JSON, path unit, journal | **ED** |
| Local diagnostics record | Journal only; no update history record | **ED** |
| Remote telemetry | — | OOS (not selected) |

## Part 3 — Observability matrix

Classes: **DO** directly observable; **DV** derivable; **NE** not exposed;
**RE** requires Eldora mechanism; **UNK** unknown.

| State | Class | How (evidence) |
|---|---|---|
| Current (booted) deployment | DO | `bootc status --json`: `status.booted` (image, `imageDigest`, `version`, `timestamp`, `ostree.checksum`, `deploySerial`) [S3] |
| Staged deployment | DO | `status.staged`, `downloadOnly` [S3] |
| Rollback deployment | DO | `status.rollback`, `rollbackQueued` [S3] |
| Image digest | DO | `imageDigest` [S3] |
| Image version | DO (if label present) | `version` "if any" [S3]; depends on Eldora labelling (ED) |
| Update availability | DO / DV | `bootc upgrade --check` + `cachedUpdate` vs booted digest [S1, S3] |
| Download progress | DO (experimental) | `--progress-fd` JSON Lines [S2]; only for the invoking process |
| Staging success | DO (at the moment) | CLI exit code + `status.staged` [S2, S3] |
| Staging failure | DO (transient) / RE (persistent) | CLI error; **no persisted failure record** (INFERENCE: status shows only successful state) |
| Pending reboot | DV | `staged != null && downloadOnly == false`, or `rollbackQueued` [S3] |
| Booted deployment after reboot | DO | `status.booted` |
| Failed finalization | DO by contract / **NE in RISK-0010 path** | stamp + `ostree-boot-complete` failure [S2]; OBSERVED absent in RISK-0010 [RES-0005] |
| Failed boot of new deployment | NE / RE | no boot-level record unless boot counting is active; otherwise only "system came up on old deployment" (DV if the intended target was recorded) |
| Previous boot result | DV | `journalctl -b -1 -u ostree-finalize-staged` [S2]; unit state does not survive reboot |
| Boot count | UNK (GRUB) / DO (systemd-boot) | BLS `+N-M` counters; `systemd-bless-boot status` requires `LoaderBootCountPath` set by the loader [S22]; Fedora GRUB support UNVERIFIED |
| Deployment health | **NE → RE** | no upstream concept [S2] |
| Rollback occurrence | DV / RE | booted digest changed to the former rollback; cause (manual, automatic, menu) not recorded |
| Update discarded / lost | **RE** | no upstream event; needs recorded intent (target digest) compared with post-boot `booted` |
| Bootloader state (ESP) | DV | bootupd status (`bootupctl status`) [S27]; not in bootc status; version divergence from OS not reported (UNVERIFIED format) |
| Status change event | DO | `bootc-status-updated.path/.target` [S2] |

## Part 4 — Failure matrix (documentary; nothing executed)

Columns: Prev = prevention; Det = detection; Signal = observable signal;
After = system state after failure; Old = previous/booted deployment
usable; Rb = reboot required to recover; Upstream = recovery available
upstream; Gap = what Eldora must solve. Evidence level per row: **D**
documented, **O** observed in RES-0004/0005, **I** inference, **U**
unknown → probe.

| ID | Scenario | Prev | Det | Signal | After | Old | Rb | Upstream | Gap | Ev. |
|---|---|---|---|---|---|---|---|---|---|---|
| F01 | Network lost before download | none needed | check/upgrade error | CLI exit ≠ 0 | unchanged | yes | no | retry | retry/backoff policy; user message; offline media | I |
| F02 | Network lost during download | resumable per layer | CLI error | exit ≠ 0; progress stops | partial objects cached; nothing staged | yes | no | re-run (changed layers only) | retry; cache GC; metered policy | D (layers) / U (cleanup) |
| F03 | Registry unavailable | mirrors (ED) | CLI error | exit ≠ 0 | unchanged | yes | no | retry | registry HA (0.1D); signal "cannot check" vs "up to date" | I |
| F04 | Image not found | channel design | CLI error | exit ≠ 0 | unchanged | yes | no | switch to valid ref | channel lifecycle; EOL signalling | I |
| F05 | Invalid/untrusted signature | enforced policy | policy reject | "signature … not accepted" | unchanged | yes | no | none needed | enforce policy by default (C3); key rotation; user message | O (PB5) |
| F06 | Digest mismatch / corruption | content addressing | import error | exit ≠ 0 | unchanged (UNVERIFIED cleanup) | yes | no | re-pull | verify exact behaviour; fsverity/composefs sealing (future) | U |
| F07 | Insufficient disk before staging | none upstream | CLI error (UNVERIFIED message) | exit ≠ 0 | unchanged | yes | no | GC/prune | pre-flight space check; GC policy; message | U |
| F08 | Disk fills during operation | none upstream | error | exit ≠ 0 | partial import; `/var` may also be full | yes (if `/var` not critical) | maybe | prune | space reservation; health of `/var` | U |
| F09 | Process crash during fetch | — | process exit | none persisted | partial cache | yes | no | re-run | supervisor; persisted attempt record | I |
| F10 | Process crash during staging | ostree sysroot lock | none persisted | staged may or may not exist | UNVERIFIED | yes | no | re-run; `ostree admin cleanup` (UNVERIFIED) | verify idempotence; attempt record | U |
| F11 | Power loss during fetch | — | none | none | partial cache | yes | — | re-run | as F09 | I |
| F12 | Power loss during staging | old boot config untouched | none | staged absent after boot (`/run` state) | old deployment boots | yes | — | re-run | detect "intended but absent" | I (from L12) / U |
| F13 | Abrupt power loss / hard reset after staging, before finalization (an orderly shutdown or reboot runs finalization and is covered by F14/F15, not F13) | — | none | staged absent; finalization never ran | **old boots; update lost silently** | yes | — | re-run | lost-update detection (RE); UX "update not applied" | I (FACT: finalization runs only in the orderly shutdown path) |
| F14 | Shutdown failure (finalize error, hang, timeout) | — | stamp + `ostree-boot-complete` (contract) | failed unit next boot; journal | old deployment boots | yes | — | re-stage | surface failure; RISK-0010 shows contract can fail | D + O |
| F15 | `/boot` unavailable / read-only / conflicting mount | correct mount ownership (ED/0.1D) | contract: stamp — **OBSERVED: none** | journal only (`Remounting /boot read-write: Invalid argument`) | old boots; **update silently discarded** | yes | — | none reliable | **RISK-0010**: see Part 5 | O |
| F16 | New deployment does not boot | CI boot tests (0.1D) | only with boot counting | none by default | stuck / emergency / reboot loop | via manual boot menu selection | yes | manual menu; boot counting if loader honours it (UNVERIFIED on GRUB) | automatic fallback mechanism | D (partial) / U |
| F17 | Kernel boots, graphical desktop fails | CI desktop tests | none upstream (bootc) | Fedora GRUB `boot_success` never set (2-min session timer) → menu shown next boot [S29, S30] | system up without desktop | manual rollback | yes | `bootc rollback` via TTY/SSH | health check + automatic rollback policy | D (GRUB flag) / I |
| F18 | Critical system service fails | CI | `systemctl --failed`; optional `systemd-boot-check-no-failures` (disabled by default, "very minimal") [S23] | failed units | degraded | manual rollback | yes | manual | define critical services; health gating | D |
| F19 | Network unavailable after otherwise successful boot | — | NetworkManager state | NM online state | booted, cannot fetch further updates | yes | — | manual rollback | health must distinguish local vs environmental failures | I |
| F20 | `/etc` override incompatible with new image | drop-ins, hermetic `/usr` (P1–P2) | none upstream | service failures | new deployment degraded; **old deployment keeps its own `/etc`** | yes (rollback restores old `/etc` snapshot) | yes | rollback | drift visibility (`ostree admin config-diff`); pre-flight compatibility check | D + O (PB3) |
| F21 | `/var` state incompatible with new image | tmpfiles/`StateDirectory=` | none upstream | service failures | new deployment degraded; **rollback does not revert `/var`** | **maybe not** (older code on newer state) | yes | none | state versioning / compatibility contract | D + O (PB3/PB4) |
| F22 | User manually selects previous deployment | — | DV (`booted` = former rollback) | boot menu choice not recorded | old booted; staged? n/a; auto-update may re-apply | yes | — | — | record reason; suppress re-apply loop; UX | D (auto-update may revert) |
| F23 | Automatic rollback attempt fails | — | none (no automatic rollback upstream) | — | depends | — | yes | manual/reinstall | define rollback supervision | I |
| F24 | Previous deployment also fails | older pinned deployment | none | none | unbootable OS | no | yes | pinned 3rd deployment; reinstall/recovery media | recovery environment (0.1C/0.1D) | I |
| F25 | Bootloader/shim update diverges from OS deployment | test boot chain in CI | none in bootc | bootupd status; journal | ESP newer than rolled-back OS (OBSERVED "Ignoring downgrade") | usually yes; **not if boot chain broken** | yes | removable fallback path; firmware menu | boot-chain policy (RISK-0011); SBAT-aware rollback | O + D |
| F26 | Replay/downgrade to older validly signed image | exact identity; digest pinning | **none upstream** | none | older vulnerable image staged and booted | yes | — | none | freshness/anti-rollback (RISK-0008) | O (PB5 T7a) |

## Part 5 — RISK-0010 deep re-analysis

### Evidence chain re-examined

- **OBSERVED** [RES-0005]: UEFI install via `bootc install to-disk
  --generic-image`; no `/etc/fstab` `/boot` entry;
  `/run/systemd/generator.late/boot.automount` present; with `/boot` not
  accessed (and in trial B, where the script explicitly ran `systemctl stop
  boot.automount boot.mount` — `RES-0005-lab/vm/d-trial.sh`) finalization
  failed with "error: Remounting /boot read-write: Invalid argument";
  staged deployment discarded; no stamp file; `ostree-boot-complete`
  skipped; no user signal. Trial A (`ls /boot` before reboot) finalized.
  `systemd.gpt_auto=0` removed the automount and finalization succeeded.
- **Precision correction:** RES-0005 did not record the **partition
  layout**, the partition **type GUIDs**, or **which partition**
  `boot.mount` mounted (`What=`). The lab script `d-automount-origin.sh`
  ran `lsblk` and `systemctl show`, but outputs were not committed.
- **FACT** [S33] (verified): "The default as of bootc 1.11 uses the
  Discoverable Partitions Specification"; layout: ESP, "Boot: Separate
  `/boot` partition, only created when using LUKS encryption", root. The
  lab used bootc 1.16.13 without LUKS (as recorded).
- **FACT** [S21] (local man page, systemd 259.9): gpt-auto mounts XBOOTLDR at
  `/boot/`; "The ESP is mounted to `/boot/` if that directory is not used for
  XBOOTLDR, and otherwise to `/efi/`"; it uses automount units; it does not
  create units for directories that already contain files or when mount
  entries exist "in the `/boot/` or `/efi/` hierarchies in fstab(5)";
  `systemd.gpt_auto=0` disables it. The binary contains the messages "EFI
  loader partition unknown, skipping ESP and XBOOTLDR mounts" and "(The boot
  loader did not set EFI variable LoaderDevicePartUUID.)" and writes
  `TimeoutIdleSec=` (local `strings`, INFERENCE that mounts are gated on
  `LoaderDevicePartUUID`).
- **FACT** [S34]: automount units "acquire automatic Before= and Conflicts=
  on umount.target in order to be stopped during shutdown".
- **FACT** [S14, S35]: OSTree "will automatically remount read-write just
  for the portion of time necessary to update the bootloader
  configuration"; libostree "will automatically remount as writable any
  mount points on which it operates. This currently is just `/sysroot` and
  `/boot`".
- **FACT** [S36]: mount(2): "EINVAL: A remount operation (MS_REMOUNT) was
  attempted, but source was not already mounted on target."
- **FACT** [S2]: the documented contract is that finalize failure creates a
  stamp in `/boot` detected at next boot.

### Answers

1. **Technical ownership.** A three-party integration seam:
   (a) **systemd-gpt-auto-generator** (behaving as documented) creates a
   lazily-mounted, idle-expiring `/boot` automount when nothing else claims
   `/boot`; (b) **bootc `install to-disk`** (documented direction "to stop
   using `/etc/fstab`" [S33]) leaves `/boot` without an explicit mount owner
   in the non-LUKS layout; (c) **OSTree finalization** tries to remount
   `/boot` read-write, fails with EINVAL, and does **not** honour its own
   documented failure-signalling contract. The composition of these is
   owned by whoever composes image + installer + boot configuration — for
   Eldora, **Eldora** (with 0.1D), with an upstream defect in (c).
2. **Classification.** Not a single category:
   - gpt-auto behaviour: **expected behaviour** (documented);
   - missing explicit `/boot` mount on the install: **configuration /
     install-method integration gap**;
   - finalize failing without stamp or signal: **probable upstream bug** —
     OBSERVED behaviour contradicts the documented bootc contract (L13);
   - whether it is a **known upstream incompatibility**: see the authorized
     issue-tracker pass below — **C (known incompatibility, introduced as a
     regression in ostree 2026.3) + D (known open bug in the `/boot`
     remount logic)**; the finalize-at-shutdown loss and the missing
     failure stamp are **not** reported upstream (**NO CONFIRMED UPSTREAM
     MATCH FOUND** for the complete chain). An Arch Linux file list of
     ostree 2026.4 shows an `ostree-finalize-staged-hold.service` unit
     [S37, tier 2], introduced by ostree PR #2544 [S50].
3. **Why the update was lost.** INFERENCE (consistent with S34–S36 and the
   trial B script): at shutdown the automount/mount had been stopped (or was
   never triggered), so `/boot` was a plain directory on the read-only
   composefs root; libostree saw a read-only `/boot`, attempted
   `MS_REMOUNT` on a non-mount-point and got EINVAL; finalization aborted
   before the atomic swap; the staged deployment lives in `/run` state and
   was discarded by the reboot.
4. **When.** During the shutdown transaction, in the `ExecStop` of
   `ostree-finalize-staged.service`, i.e. after the user asked to restart and
   after user-facing software has already exited.
5. **Why no adequate signal.** INFERENCE: the stamp is itself written into
   `/boot`; with `/boot` not writable/not mounted the stamp cannot be
   written either, so `ostree-boot-complete` (conditioned on the stamp) is
   skipped. No component records "an update was intended". bootc has no
   persistent update-attempt record. GNOME-class UIs cannot report what is
   never recorded.
6. **Indirect signals that existed.** Previous-boot journal of
   `ostree-finalize-staged.service` (error text and failed unit result);
   after reboot `status.booted.imageDigest` unchanged and `status.staged`
   null; `cachedUpdate`/`--check` still reporting the same update available;
   `boot.automount` present under `/run/systemd/generator.late/`.
7. **Deterministic detection (INFERENCE; no implementation).** Before
   reboot, persist the *intended* target (staged `imageDigest` and ostree
   checksum/serial, plus whether `downloadOnly` is false); after boot,
   compare with `status.booted`. Outcomes: equal → applied; different and
   `rollbackQueued`/user selection recorded → intentional; different
   otherwise → **LOST UPDATE** (classify using the previous-boot journal of
   the finalize unit). This must not depend on writing to `/boot`. A
   pre-reboot check that `/boot` is an active, writable mount of the
   expected partition is a complementary prevention.
8. **Upstream mitigations.** Documented: an fstab entry in the `/boot` or
   `/efi` hierarchy suppresses gpt-auto ESP/XBOOTLDR units [S21];
   `systemd.gpt_auto=0` [S21]; bootc `--boot-mount-spec` / `boot-mount-spec`
   install configuration for a separate `/boot` [S33]; bootc `--karg` to
   ship kernel arguments [S7]; GPT "no-auto" attribute (bit 63) applies to
   XBOOTLDR but **not** to the ESP (the ESP's "no block IO protocol" bit is
   a firmware-level attribute, not a safe mitigation) [S21, S38]. Code-level
   upstream fixes: exist only for adjacent paths — bootc CLI namespace
   propagation (U4) and the composefs-backend finalize hold (U5); for the
   OSTree backend, maintainers discussed revert, opt-in or documenting
   `systemd.gpt_auto=0` (U1); no fix found as of 2026-09-26.
9. **`systemd.gpt_auto=0`.** A **workaround**, not architecture: it disables
   all GPT auto-discovery (root, `/var`, swap, ESP, XBOOTLDR), hides the
   problem rather than defining `/boot` ownership, and does not fix the
   missing failure signal. It remains a LAB-VALIDATED MITIGATION.
10. **Conditions to lift the release blocker (RECOMMENDATION, for the
    Project Owner).** All of:
    - C-R1: the Eldora install/image layout gives `/boot` (and the ESP) an
      explicit, documented mount owner, and the mechanism is validated on
      UEFI + Secure Boot for every supported install path (0.1D);
    - C-R2: failure-injection probes in 0.1C-F show finalization succeeds
      with `/boot` untouched, idle-expired, and after long uptime, across
      reboot, power-off, soft-reboot and update-timer paths;
    - C-R3: an Eldora-owned **lost-update detection** that does not depend
      on `/boot` writes detects every injected finalize failure (100 % in
      probes) and produces a user-visible and locally-logged event;
    - C-R4: the upstream defect class (ostree ≥ 2026.3 gpt-auto
      activation, U1–U3, and the remount bug, U7) is either fixed in the
      versions Eldora ships (verified by release notes and probes) or
      explicitly neutralised by Eldora's `/boot` ownership, with the
      chosen upstream direction (revert / opt-in / `gpt_auto=0`) tracked;
    - C-R5: regression coverage in CI for the finalize path (0.1D).
    Closure remains a Project Owner decision.

### Layout hypotheses (must be settled first)

- **HYPOTHESIS H-L1:** no separate `/boot` partition (bootc ≥ 1.11 non-LUKS
  default); `boot.mount` mounted the **ESP** on `/boot`. If true, the ESP
  overmounting `/boot` also affects what users/tools see at `/boot`, and
  trial A's success may be explained by a writable vfat mount satisfying
  the remount check rather than by the correct partition being present.
- **HYPOTHESIS H-L2:** a separate `/boot` (XBOOTLDR-typed) partition existed
  and was automounted.
- Settling H-L1/H-L2 is probe P-01 (see "Proposed probes" below).

### Upstream issue-tracker evidence (authorized read-only pass, 2026-09-26)

Scope and method: see "Method and limitations". Repositories searched:
bootc-dev/bootc and ostreedev/ostree (issue and PR search for "automount",
"gpt-auto", "volatile-root", "finalize-staged boot", "staged finalize",
"Remounting /boot read-write"); one systemd issue and one Fedora
Bugzilla report were read because they are directly cross-referenced by
the ostree change below. Tier 2 (maintainer/tracker) unless stated.

| # | Project / item | Title | Status (as of 2026-09-26) | Dates | Versions | Relation to our finding | Differences from our lab | Confidence of relation |
|---|---|---|---|---|---|---|---|---|
| U1 | ostree PR #3608 [S49] | "prepare-root: create /run/systemd/volatile-root for composefs" | Merged | opened 2026-07-03; merged 2026-07-31; shipped in ostree **v2026.3** (release notes: "Created `/run/systemd/volatile-root` for composefs support", 2026-08-05) [S51] | affects ostree ≥ 2026.3 on composefs systems | **Trigger.** Before it, gpt-auto could not resolve the root block device on composefs and did not create ESP/XBOOTLDR units; the PR states that without it "the ESP … fails to automount on /boot" — i.e. it deliberately **enables** ESP automount on `/boot`. Post-merge, the maintainer wrote: "Fallout in … bugzilla … 2520626" (2026-08-21) and "I'm leaning a bit towards suggesting people who have regressions from this to revert this particular change. Or perhaps we make it opt-in upstream here until we've had time to sort through the implications?" (2026-08-26); the author replied "Maybe just document that the generator can be disabled with `systemd.gpt_auto=0`?" | Upstream does not mention finalize failure or lost staged deployments | HIGH that it is the enabling change (lab ran ostree 2026.4 per RES-0004; VM-D ostree version not recorded, INFERENCE same range) |
| U2 | Fedora Bugzilla 2520626 [S52] | ostree-2026.3-1.fc44 boot failure (`home.mount: Mount path /home is not canonical`) | NEW, severity high; no fixed-in version | reported 2026-08-20 | ostree 2026.3-1.fc44, Fedora 44 Silverblue | Same root cause (gpt-auto newly active on OSTree/composefs, per U1); workarounds listed: `systemd.gpt_auto=0` or changing partition type GUID | Different symptom (`/home`, not `/boot`, not updates) | HIGH same class, LOW same symptom |
| U3 | bootc issue #2402 [S53] | "auto-updates fail with `opendir(boot): Operation not permitted` when /boot is a systemd automount that has idled out" | Open, label "triaged" | opened 2026-08-22 | bootc 1.16.7-1.fc44, ostree 2026.3-1.fc44, systemd 259.8-1.fc44; BIOS/GRUB, composefs | Describes the mechanism: two generators claim `/boot` — ostree-system-generator (bind mount) and gpt-auto (automount, idle ~120 s); when autofs expires it unmounts ostree's `/boot` bind mount; names ostree commit 62109dca (U1) as the exposing change | Failure in bootc CLI / update **timer** at run time, not at shutdown finalization; BIOS vs our UEFI; error text differs | MEDIUM–HIGH same mechanism |
| U4 | bootc PR #2411 [S54] | "Unshare fix for boot.automount" | Merged | 2026-08-26 | bootc release containing it: not stated | Fixes #2402 for bootc CLI commands (mount propagation into bootc's namespace); reviewer noted underlying ostree issues may remain | Does not address ostree-finalize-staged | MEDIUM (adjacent fix) |
| U5 | bootc PR #2488 [S55] → PR #2496 [S56] | "systemd: Order bootc-finalize-staged after /boot mount" (closed, not merged) → "composefs: Hold /boot open while a deployment is staged" | #2488 closed 2026-09-24; #2496 merged 2026-09-25 | — | bootc main after 2026-09-25; release not stated | Same hazard **at shutdown finalization**: with `/boot` automounted by gpt-auto, finalization hung/failed and "staged deployments fail to finalize" (CI "guest reboot timeout"); fixed by a hold service keeping `/boot` open, copied from ostree | **composefs-native backend only** (`bootc-finalize-staged.service`); symptom was a hang, not EINVAL; Eldora V1 labs used the OSTree backend | MEDIUM (analogous, different backend) |
| U6 | ostree issue #2543 / PR #2544 [S50] | "Finalizing staged deployments broken on /boot automount" / "finalize-staged: Ensure /boot and /sysroot automounts don't expire" | Closed / merged | 2022-02-16 → merged 2022-08-30 | ostree ≥ 2022.6 | Earlier instance of the same class (ESP automount on `/boot`, systemd-boot, Endless OS): automount expiry broke finalization; fixed with `finalize-staged --hold` and a hold unit | Pre-composefs; different layout; the hold mechanism existed in our lab's ostree yet the failure occurred — why it did not protect our case is **UNVERIFIED** (U3 suggests the stacked bind mount + automount interaction) | MEDIUM |
| U7 | ostree issue #3365 [S57] | "prepare-root: boot is kept writable" | Open | opened 2025-01-06 (maintainer) | — | **Error-text mechanism.** The maintainer states the remount code "checks for ST_RDONLY and tries to remount if it finds that, but that's broken - we need to check if it's actually a mountpoint instead", citing the error "Remounting /boot read-write: Invalid argument" | Reported for `bootc status`/sysroot acquisition, not for shutdown finalization; not tied to gpt-auto | HIGH for the error mechanism; not a report of our full chain |
| U8 | bootc issue #1673 [S58] | "Problem enabling transient /etc … rpm-ostree-fix-shadow-mode.service failed" | Open | 2025-10-07 | Fedora 42, bootc 1.8.0, ostree 2025.6 | Same error string "Remounting /boot read-write: Invalid argument" | Different trigger (transient `/etc`, initramfs regenerated); **not treated as the same problem** | LOW |
| U9 | systemd issue #35017 [S59] | "systemd-gpt-auto-generator can't find ESP because it can't detect blockdev of / if composefs is used" | Open | 2024-11-04 | — | Background for U1 (why gpt-auto was previously inactive on composefs) | No update/finalize symptom | context only |

**Not found:** no upstream issue in either tracker reports the complete
chain *UEFI → gpt-auto `/boot` automount → OSTree finalize at shutdown →
"Remounting /boot read-write: Invalid argument" → staged deployment
discarded → no failure stamp / no user-visible failure*. **NO CONFIRMED
UPSTREAM MATCH FOUND** for the complete chain, and in particular none for
the missing failure stamp. This absence is not proof of a new bug.

**Classification against A–G (per element):**

| Element | Class | Basis |
|---|---|---|
| gpt-auto mounting the ESP on `/boot` when nothing else claims it | A — documented behaviour | S21; U1 states it as intended |
| gpt-auto becoming active on OSTree/composefs systems | C — known incompatibility (regression introduced by ostree 2026.3) | U1, U2, U3 |
| automount idle-expiry unmounting ostree's `/boot` bind mount | C/D — known, reported (bootc CLI) | U3; fixed only for the bootc CLI (U4) and composefs backend (U5) |
| remount of non-mount-point `/boot` → EINVAL | D — known open bug | U7 |
| OSTree-backend finalize at shutdown losing the staged deployment | F — not found upstream (analogues: U5 composefs, U6 2022) | — |
| no failure stamp / no user-visible failure | F — not found upstream | — |
| install without explicit `/boot` mount | B — configuration/install integration gap (Eldora/0.1D) | S33; U1 maintainers suggest `systemd.gpt_auto=0` |
| fixed for our configuration | **not established** — E only for adjacent paths (U4, U5) | — |

**Overall: C + D (known incompatibility and known bug), with the
finalize-loss and no-stamp aspects F (not found upstream); not E for the
OSTree backend as of 2026-09-26.** Confidence: MEDIUM–HIGH for the causal
link to ostree 2026.3 (U1–U3); MEDIUM for the finalize mechanism (analogy
U5/U6 plus U7); the specific reason the ostree hold unit (U6) did not
protect our lab remains UNVERIFIED.

**Effect on RISK-0010:** does **not** close or downgrade it. It sharpens
it: (1) likely trigger identified — ostree ≥ 2026.3 on composefs + UEFI
without an fstab `/boot` claim; (2) the failure class affects Fedora 44
Atomic/bootc systems generally, not only Eldora; (3) upstream has not
chosen a fix for the OSTree backend (options discussed: revert, opt-in
`ostree.enable_gpt`, document `systemd.gpt_auto=0`); (4) U1's wording
("ESP … automount on /boot") **supports H-L1**, still to be confirmed by
P-01; (5) the missing stamp and missing user signal remain an Eldora
problem regardless of the upstream fix (C1). Severity and likelihood are
unchanged (HIGH/HIGH); the Project Owner decides any change.

## Part 6 — Success semantics

| Concept | Exists upstream? | Where |
|---|---|---|
| UPDATE DISCOVERED | yes | `--check`, `cachedUpdate` [S1, S3] |
| UPDATE FETCHED | not separately | inside `upgrade` (progress-fd stages, experimental) [S2] |
| UPDATE VERIFIED | not separately observable | policy check during fetch; failure = error [S3, S6] |
| UPDATE STAGED | yes | `status.staged` [S3] |
| DEPLOYMENT BOOTED | yes | `status.booted` [S3] |
| SYSTEM BOOTABLE | only with boot counting (loader-dependent) | BLS counters / GRUB flags [S22, S29] |
| SYSTEM HEALTHY | **no** (bootc) | "The system must perform health checking on itself" [S2] |
| DEPLOYMENT KNOWN GOOD | **no** | no attribute in status schema [S3] |

**Critical question — when does upstream consider an update complete?**
INFERENCE: for bootc the operation is complete when `bootc upgrade` returns
with a staged deployment; "applied" is implicit when a later boot shows the
new digest in `status.booted`. There is no completion event after boot,
no health gate and no known-good marking. **Not sufficient for Eldora**:
it cannot distinguish "booted" from "working", cannot detect a lost update
by itself (RISK-0010), and records nothing after the fact.

## Part 7 — Boot-success mechanisms

- **systemd Automatic Boot Assessment** [S22–S24]: tries counters in BLS
  filenames (`+LEFT-DONE`); `boot-complete.target` defines success;
  `systemd-bless-boot.service` renames entries when the loader set
  `LoaderBootCountPath`; `systemd-boot-check-no-failures.service` is "a
  very minimal test only … disabled by default". Implemented by
  **systemd-boot**; the page does not mention GRUB.
- **OSTree**: `boot-counting-tries` config writes counters into BLS
  filenames [S20]; effect with Fedora GRUB **UNVERIFIED**. bootc: "the
  composefs backend does not configure boot entry counting" (verified) [S2];
  systemd-boot is supported by bootc only for the composefs backend [S27].
- **Fedora GRUB**: user unit `grub-boot-success.timer` — "Mark boot as
  successful after the user session has run 2 minutes" → `grub2-set-bootflag
  boot_success` (local unit files, grub2 2.12-64) [S28];
  `grub-boot-indeterminate.service` increments `boot_indeterminate` on
  offline-update boots [S28]; a maintainer explains success is "deliberately
  done from a timer … we want to ensure that the user can actually log-in"
  [S29]; Hidden GRUB menu shows the menu when the previous boot did not set
  the flag [S30]. `08_fallback_counting` semantics: UNVERIFIED (files not
  readable without privileges).
- **greenboot / greenboot-rs**: health scripts (`required.d`, `wanted.d`)
  before `boot-complete.target`; on required failure reboots and, after
  retries, rolls back (`rpm-ostree rollback` in the classic implementation);
  on success unsets `boot_counter` and sets `boot_success` [S39, S40, S41].
  **Contradiction:** bootc docs say "greenboot does not yet integrate with
  bootc" (verified) [S2]; the Fedora 43 greenboot-rs Change says it is
  "designed for use with bootc and rpm-ostree based systems" [S39]. Actual
  bootc integration: UNVERIFIED.

Success levels (INFERENCE):

| Level | Meaning | Upstream signal |
|---|---|---|
| FIRMWARE SUCCESS | firmware loaded shim | none recorded by OS (UEFI boot variables only) |
| BOOTLOADER SUCCESS | GRUB loaded kernel+initramfs | BLS counters (loader-dependent); GRUB flags |
| KERNEL SUCCESS | kernel + initramfs mounted root (`ostree-prepare-root`) | reaching userspace; journal |
| INIT/SYSTEM SUCCESS | systemd reached target without critical failures | `boot-complete.target` (if used) |
| GRAPHICAL SESSION SUCCESS | a user session ran | Fedora GRUB 2-min session timer (human-login based; no session = no success) |
| ELDORA PLATFORM SUCCESS | Eldora services and shell operational | **none — Eldora must define** |

Bootloader fallback does not imply system or platform health.

## Part 8 — Persistent state

| Item | Update | Rollback | Evidence |
|---|---|---|---|
| `/usr` | replaced by image | reverted | FACT [S2]; OBSERVED |
| `/etc` | 3-way merge at finalize; locally modified files win as whole files and propagate into the deployment being created | old deployment's own `/etc` snapshot (not retroactively modified); edits made after that snapshot are hidden but **return on roll-forward** to a deployment whose snapshot contains them | FACT [S12, S14]; OBSERVED [RES-0004 DV3] |
| `/var` | untouched (image `/var` only at install) | **not reverted** | FACT [S42]; OBSERVED |
| `/home` (`/var/home`) | kept | kept | OBSERVED [RES-0004 PB4, RES-0005 E1] |
| machine-id | kept | kept | OBSERVED [RES-0004 PB4] |
| host keys | kept | kept | FACT [S2]; OBSERVED |
| logs (journal) | kept (`/var/log`) | kept | INFERENCE from `/var` |
| databases, caches, service state | kept; may be migrated forward by new code | **not reverted** — older code runs over newer state | FACT [S42]; OBSERVED schema 2 remained [RES-0004 PB3] |
| user configuration | kept (`$HOME`) | kept (newer profile seen by older desktop, OBSERVED no breakage in checks) | OBSERVED [RES-0005 E4] |
| application state | kept | kept | INFERENCE (outside image) |
| users/groups | image users via sysusers; local collisions remapped silently | OS side reverted | OBSERVED [RES-0004, RES-0005 E5] |
| kernel arguments (local) | carried over | per deployment | OBSERVED [RES-0005] |
| ESP boot chain | updated by `bootloader-update.service` | **not reverted** | OBSERVED [RES-0005 E3] |

**What rollback reverts:** the image (`/usr`, kernel, initramfs, image
defaults, image-defined users) and the choice of `/etc` snapshot.
**What it does not revert:** `/var` (all service/application state,
databases, caches, logs, container storage, Flatpaks), `/home` and user
configuration, machine identity, the ESP boot chain, SBAT/UEFI variables,
TPM state, and any data migrated forward by newer code.

Schema/state risks (INFERENCE): forward-only migrations in `/var` or
`$HOME` break older code after rollback (F21); `ConditionNeedsUpdate=`
relies on `/usr` mtime, but OSTree "squashes all timestamps to zero" [S43]
— whether update-triggered services run on bootc is **UNVERIFIED**.

## Part 9 — Trust and freshness

| Property | Definition (for this report) | Where it can be applied | Upstream status |
|---|---|---|---|
| AUTHENTICITY | the image was produced by a trusted signer | fetch (policy.json `sigstoreSigned`/`signedBy`) | available, opt-in; default permissive [S44; RES-0004] |
| INTEGRITY | content matches the signed manifest digest | fetch/import (content addressing); runtime only with composefs sealing | fetch: implied; runtime sealing: not default [RES-0003 FR4–FR5] |
| AUTHORIZATION | this machine is allowed/intended to run this image (channel, identity) | signedIdentity rules; Eldora channel policy | partial: identity rules trade replay protection vs tag promotion [S44; RES-0004 T7] |
| FRESHNESS | the offered image is the latest intended by the publisher, not a frozen/stale view | pre-fetch eligibility (needs signed, expiring metadata) | **absent**: signatures bind `docker-manifest-digest` + `docker-reference`; the timestamp is optional and unenforced; no expiry [S45] |
| ANTI-ROLLBACK | never move to an image older than one already trusted | pre-stage eligibility; persisted high-water mark | **absent for bootc container origins** (not documented); OSTree native has `ostree_sysroot_upgrader_check_timestamps` and `--allow-downgrade` for ostree remotes [S46]; applicability to bootc UNVERIFIED |

**Where authenticity ends and freshness begins (Q17):** authenticity ends
when the signature on a specific manifest digest verifies; it says nothing
about *whether that digest is still current*. Freshness requires a
separately signed, time-bounded statement of "current" (the TUF
timestamp/snapshot model: rollback and indefinite-freeze attacks,
monotonic versions, expiry) [S47]. Boot-chain anti-rollback is a separate
mechanism (SBAT generations) [S32]. RISK-0008 stays OPEN; production
signing infrastructure is not chosen (0.1D).

## Part 10 — UX event semantics (no UI designed)

| Conceptual event | Upstream source | Class |
|---|---|---|
| update available | `--check` / `cachedUpdate` | derivable (poll) |
| downloading | `--progress-fd` (experimental, invoking process only) | partial |
| ready to restart | `status.staged` with `downloadOnly=false` | derivable |
| update failed before restart | CLI error of the invoking process | transient only → RE |
| restart into update | none (reboot is generic) | RE |
| update booted | `status.booted` digest = intended target | derivable with recorded intent → RE |
| validating system | none (bootc) | RE |
| update successful | none | RE |
| rollback occurred | booted = former rollback; cause unknown | RE |
| recovery required | none | RE |
| user action required | none | RE |
| status changed (any) | `bootc-status-updated.target` [S2] | direct (coarse) |

## Part 11 — Update policy questions (not decided)

Sub-stage mapping below follows the Wave 0.1C decomposition confirmed by
the Project Owner at review (2026-09-26; a scope definition, not an
architectural or product-policy decision): **0.1C-B — Update Policy, Trust
& Freshness Semantics**; **0.1C-C — Health, Known-Good, Rollback &
Recovery Semantics**; **0.1C-F — Experimental Validation & Failure
Injection**.

| Topic | Alternatives (examples) | Consequences | Belongs to |
|---|---|---|---|
| Automatic download | off / check-only / download-only / full stage | bandwidth, metered data vs security latency | 0.1C-B |
| Automatic staging | never / download-only lock / staged | RISK-0010 exposure window; F13 loss on abrupt power loss / hard reset before finalization | 0.1C-B (+0.1C-C detection) |
| Automatic reboot | never / scheduled / idle / forced after deadline | data loss vs exposure; `--apply` always reboots today | 0.1C-B + product SPEC |
| User-scheduled reboot | now / tonight / pick time | needs locked staging + `--from-downloaded` | 0.1C-B + product SPEC |
| Metered networks | defer / check-only / allow | NM `Metered` property available [S48] | 0.1C-B |
| Battery | require AC (`ConditionACPower=`) [S26] | deferral on laptops | 0.1C-B |
| Low disk | pre-flight check / GC / refuse | two deployments + cache (~2.4 GB major) | 0.1C-B + 0.1D (image size) |
| Deferral / maximum deferral | none / bounded / unbounded | security vs control ("Yours") | 0.1C-B + product SPEC |
| Security urgency | same path / expedited / forced | needs signed urgency metadata | 0.1C-B + 0.1D |
| Release channels | tags / repos / signed channel metadata | identity rule trade-off (RISK-0008) | 0.1C-B + 0.1D |
| Major-version transitions | automatic / opt-in / staged rollout | RES-0005 E4 ~2.4 GB; toolbox mismatch | 0.1C-B + product SPEC |
| Downgrade | forbidden / explicit user action / signed exception | anti-rollback vs recovery | 0.1C-B (trust) + 0.1C-C (recovery) |
| Rollback retention | 2 deployments / pinned known-good / N | disk vs recovery depth (F24) | 0.1C-C |
| Automatic rollback | none / boot-count / health-gated | loops, `/var` incompatibility | 0.1C-C |

## Part 12 — Privacy and local diagnostics

LOCAL DIAGNOSTICS required (INFERENCE): per-attempt record (timestamp,
source reference, target digest/version, stage reached, error class);
pre-reboot intended target and post-boot outcome (applied / lost /
rolled-back / manual); finalize and boot-complete unit results of the
previous boot; boot-counting/health outcomes; rollback cause; ESP/bootupd
version vs OS deployment; `/etc` drift summary; disk space at attempt;
retention of the journal across the relevant boots. All can stay on the
machine; none requires network transmission.

OPTIONAL FUTURE REMOTE TELEMETRY: not selected; would need its own
research, consent model and data minimisation. Nothing in the upstream
mechanisms requires it.

## Hypotheses

- H1: the OSTree-backend failure contract (stamp + boot-complete) is
  reliable except when `/boot` itself is unwritable (RISK-0010 path).
- H2: OSTree `boot-counting-tries` has no effect with Fedora GRUB (counters
  not honoured) — test in P-07.
- H3: greenboot-rs can supply health-gated rollback on a bootc host —
  test in P-08.
- H-L1 / H-L2: see Part 5.

## Requirements (derived; candidates for later waves, not owner requirements)

From ADR-0001 C1 (no silent loss of staged updates), C3 (trust chain), C4
(freshness), C8 (boot chain), C9 (local state control), P6 (state
separation).

## Anti-bias: attempt to falsify

Hypothesis: "bootc/OSTree already provides sufficient primitives for Eldora
to build a safe and recoverable update experience without maintaining a
complete update engine of its own."

Arguments against:

1. No health, known-good or automatic rollback in bootc (FACT, S2/S3).
2. Silent loss of a staged update is possible and the documented detection
   contract failed in the laboratory (RISK-0010).
3. No freshness/anti-rollback for container origins (RISK-0008).
4. Boot chain outside rollback (RISK-0011).
5. No persisted attempt/failure history; no event API beyond a path unit.
6. `/var` never rolls back; no compatibility contract.

Arguments for:

1. Fetch, verification, staging, locked staging, atomic boot swap,
   rollback, soft-reboot, stable JSON status and a status-change hook exist
   and are documented as stable (status v1).
2. Boot assessment (`boot-complete.target`, OSTree boot counting) and
   greenboot-rs provide building blocks, though integration with Fedora
   GRUB/bootc is UNVERIFIED.
3. Everything missing is *orchestration and policy around* the primitives
   (eligibility, intent recording, lost-update detection, health gating,
   rollback supervision, freshness metadata), not a replacement of the
   transport, storage or deployment engine.

**Result: SUPPORTED WITH SIGNIFICANT ELDORA LAYER.** Eldora does not need a
full update engine, but it does need an update **supervisor/orchestrator**
with its own state, policy, freshness verification, health model and event
surface. **ADR-0001 reconsideration: NOT recommended** — no evidence shows
that C1/C2 cannot be satisfied (documented mitigations exist; Part 5 §8)
or that the trust chain cannot be enforced; RISK-0010 remains a release
blocker whose resolution is still unproven.

## Answers to the mandatory questions

- **Q1.** See Part 1 state machine: IDLE → UPDATE_AVAILABLE → FETCHING
  (pull/import/stage, policy gate) → STAGED or STAGED_LOCKED → FINALIZING
  (shutdown) → atomic boot-config swap → BOOTING_NEW → BOOTED_NEW; failure
  exits FETCH_FAILED/REJECTED, FINALIZE_FAILED (stamp), SILENTLY_LOST
  (RISK-0010; F13 abrupt power loss / hard reset before finalization),
  DISCARDED; manual ROLLBACK_QUEUED → BOOTED_PREVIOUS.
- **Q2.** When `bootc upgrade` returns with a staged deployment; "applied"
  only implicitly when `status.booted` shows the new digest (Part 6).
- **Q3.** No. Only booted/staged/rollback slots and pinning.
- **Q4.** No. bootc delegates health; Fedora GRUB's 2-minute user-session
  timer is the only desktop-related signal and is not a functional check.
- **Q5.** Not in bootc (manual rollback). Possible via boot counting
  (loader-dependent, UNVERIFIED on Fedora GRUB) or greenboot-rs
  (bootc integration UNVERIFIED).
- **Q6.** Finalize failure: stamp + `ostree-boot-complete` (OSTree backend;
  not in composefs backend). Boot failure of the new deployment: only via
  boot counting/GRUB flags; otherwise not detected.
- **Q7.** systemd: `boot-complete.target` + `systemd-bless-boot`; Fedora
  GRUB: `boot_success` after 2 minutes of user session; greenboot: after
  required checks. None is enabled as a bootc update gate by default.
- **Q8.** Fetch, registry, not-found, signature, digest and disk errors are
  detectable by the invoking process (CLI exit status); they are not
  persisted.
- **Q9.** Finalize failure (contract, when `/boot` writable); status shows
  staged deployment until reboot. Abrupt power loss / hard reset after
  staging, before finalization (F13), and the RISK-0010 path are **not**
  detected upstream.
- **Q10.** Record intended target before reboot; compare with
  `status.booted` after boot; classify with the previous-boot journal
  (Part 5 §7). Requires an Eldora mechanism.
- **Q11.** `/usr` content, kernel/initramfs, image defaults, image users,
  and selection of the old deployment's `/etc` snapshot.
- **Q12.** `/var`, `/home`, user and application state, logs, machine
  identity, forward-migrated data, ESP boot chain, firmware/SBAT/TPM state.
- **Q13.** A locally modified `/etc` file is kept as a whole file by the
  three-way merge and can become incompatible with new image defaults (the
  new deployment breaks; F20). Its effect across deployments is
  directional (Part 8; FACT [S12, S14]; OBSERVED DV3):
  - a local `/etc` override can propagate through the three-way merge into
    **subsequently created** deployments;
  - an **already-existing** rollback deployment retains its own `/etc`
    snapshot and is **not** retroactively modified by a later edit;
  - rollback can therefore **hide** a later edit;
  - rolling forward to a deployment whose `/etc` snapshot contains that
    edit can make it **reappear**.
- **Q14.** New code migrates state forward; rollback runs old code on new
  state (OBSERVED schema 2 retained); rollback cannot undo the migration.
- **Q15.** No upstream path beyond older pinned deployments, the boot menu
  and reinstall/recovery media; Eldora must define recovery (F24).
- **Q16.** Independent: OS rollback reorders BLS entries; the ESP boot
  chain is updated by `bootloader-update.service` and is not rolled back
  ("Ignoring downgrade", OBSERVED).
- **Q17.** See Part 9.
- **Q18.** Part 10 table.
- **Q19.** Staging/finalize failure after the fact, lost update, health,
  known-good, rollback cause, boot-chain divergence, persistent attempt
  history, download progress for non-invoking observers.
- **Q20.** See "Eldora responsibilities" below.
- **Q21–Q24.** See "Questions for later sub-stages".

## Eldora responsibilities (INFERENCE; not a design)

1. Explicit `/boot`/ESP mount ownership (with 0.1D) and RISK-0010
   detection independent of `/boot`.
2. Update intent/attempt recording and lost-update detection.
3. Eligibility (channel, version ordering, anti-rollback high-water mark,
   freshness metadata verification) before fetch/stage.
4. Enforced trust policy and keys (C3) without breaking developer tooling.
5. Health model and definition of "known good"; health-gated or
   boot-count-based rollback policy and loop prevention.
6. Recovery path when both deployments fail; retention/pinning policy.
7. Boot-chain update and recovery policy (RISK-0011).
8. `/var` and `$HOME` state compatibility contract for Eldora components.
9. Event surface for UX and local diagnostics store.
10. Update policy (timing, metered, battery, disk, deferral).

## Risks

| Risk | Impact of this research (no status change) |
|---|---|
| RISK-0010 | Sharpened: layout unrecorded (H-L1/H-L2, U1 supports H-L1); documented detection contract violated; upstream: known incompatibility introduced by ostree 2026.3 (U1–U3) and known open remount bug (U7), no OSTree-backend fix as of 2026-09-26; finalize loss and missing stamp not reported upstream; lifting criteria C-R1–C-R5 proposed. Remains OPEN / RELEASE BLOCKER. |
| RISK-0011 | Confirmed by documentation: bootc runs bootupd only at install; Fedora's `bootloader-update.service` updates the ESP independently; atomic only per ESP on UEFI [S19, S27]. |
| RISK-0008 | Confirmed: no freshness fields in signatures; no documented bootc downgrade check. |
| RISK-0007 | Unchanged; bootc best-effort rejects `insecureAcceptAnything` only for `containerPolicy` origins [S3]. |
| RISK-0009 | Unchanged (0.1D). |
| RISK-0005 | Extended: `/etc` rollback semantics (Q13); `ConditionNeedsUpdate` uncertainty. |

### Candidate new risks

Registered as OPEN risks at Project Owner review (2026-09-26); see
[`RISK-REGISTER.md`](../../project/RISK-REGISTER.md).

| Candidate | Registered as | Description | Evidence |
|---|---|---|---|
| RC-H | RISK-0012 | Abrupt power loss, hard reset or crash after staging and before finalization silently loses the update intent, because upstream keeps no persistent attempt record; broader than RISK-0010. An orderly shutdown runs finalization and is not this case. | L5, L7; F13 |
| RC-I | RISK-0013 | No health gate / known-good concept: a booted-but-broken update is indistinguishable from success upstream; rollback is manual. | S2, S3; Part 6–7 |
| RC-J | RISK-0014 | Older code over forward-migrated `/var`/`$HOME` state after rollback can break or corrupt data; rollback may be insufficient. | S42; RES-0004 PB3 |
| RC-K | RISK-0015 | Rollback can be undone by automatic update agents (re-applying the bad update), creating update/rollback loops. | S12 |
| RC-L | RISK-0016 | Both deployments unbootable (or boot chain broken) leaves no upstream recovery path besides reinstall. | F24, F25 |

## Proposed probes for 0.1C-F (NOT executed)

Scheduling (Project Owner review, 2026-09-26): **P-01 is promoted to an
EARLY FACT-FINDING PROBE**, because it resolves the H-L1/H-L2 factual
uncertainty directly related to RISK-0010. **P-02 to P-16 remain planned
for 0.1C-F** unless later research provides a documented reason to
re-order them. No probe, including P-01, has been executed.

| ID | Purpose | Outline |
|---|---|---|
| P-01 | Settle RISK-0010 layout (H-L1/H-L2) | read-only: `lsblk -o NAME,PARTTYPE,FSTYPE`, `systemctl cat boot.automount boot.mount ostree-finalize-staged.service`, `findmnt /boot /efi /boot/efi`, `ls /sys/firmware/efi/efivars/LoaderDevicePartUUID*` on a fresh UEFI `to-disk` install |
| P-02 | Candidate mitigations | fstab `/boot`/`/efi` entry; `boot-mount-spec`; `gpt_auto=0`; idle-expired automount; long uptime |
| P-03 | Finalize failure signalling | inject finalize failure with `/boot` writable vs not; check stamp, boot-complete, journal |
| P-04 | Network loss / registry down during fetch | cache state, retry cost, error messages |
| P-05 | Power loss during staging and after staging | QEMU hard stop at defined points; old deployment, residue |
| P-06 | Disk full before/during staging | errors, residue, `/var` effects |
| P-07 | Boot counting with Fedora GRUB | OSTree `boot-counting-tries`; GRUB `boot_counter`; bad deployment (kernel panic) |
| P-08 | greenboot-rs on bootc | required check failure → rollback? loop behaviour |
| P-09 | `/var` schema downgrade | forward-migrating service; rollback; failure mode |
| P-10 | Incompatible `/etc` override | new vs old deployment behaviour; roll-forward |
| P-11 | Boot-chain divergence | older OS with newer ESP; ESP rollback feasibility; SBAT |
| P-12 | Replay/downgrade under enforced policy | older signed digest via tag; version labels; any refusal |
| P-13 | Download-only + reboot | discard behaviour, cache reuse |
| P-14 | Status-change hook and JSON | `bootc-status-updated.target` firing for each transition |
| P-15 | `ConditionNeedsUpdate` on bootc | `/usr` mtime after update |
| P-16 | Soft-reboot path | finalization and `/etc` semantics under `--soft-reboot=auto` |

## Questions for later sub-stages

**0.1C-B — Update Policy, Trust & Freshness Semantics** — automatic
check/download/stage/reboot defaults; metered/battery/disk rules; deferral
and maximum deferral; security urgency; channel model and signature
identity vs promotion; freshness metadata and anti-rollback high-water
mark; downgrade policy; major-version transition policy.

**0.1C-C — Health, Known-Good, Rollback & Recovery Semantics** — definition of health
and known good per success level; automatic rollback trigger (boot count
vs health); loop prevention with auto-update; retention/pinning; recovery
when both deployments fail; boot-chain recovery (RISK-0011); `/var` state
compatibility contract; `/etc` rollback semantics and drift visibility;
factory reset scope (inherited from RES-0003).

**0.1D** — `/boot`/ESP layout and mount ownership; installer path;
kernel-argument policy; bootloader-update policy and SBAT; image signing
infrastructure and keys; version labelling; registry availability;
CI boot/finalize/regression tests; image size and GC.

**Later product SPECs** — update UX (notifications, restart scheduling,
deferral UI); rollback and recovery UX; local diagnostics viewer; any
opt-in remote telemetry.

## Open Questions

- OQ1: Which partition did `boot.mount` mount in RES-0005 (H-L1/H-L2)?
- OQ2: Answered in part (Part 5, U1–U9). Still open: which upstream
  direction will be taken for the OSTree backend (revert, opt-in
  `ostree.enable_gpt`, documented `systemd.gpt_auto=0`); which bootc
  release ships U4/U5; why the ostree hold unit (U6) did not protect the
  lab; exact ostree version on RES-0005 VM-D.
- OQ3: Does Fedora GRUB honour BLS boot counters written by OSTree?
- OQ4: Does greenboot-rs integrate with bootc today?
- OQ5: Exact behaviour of F06–F10 (errors, cleanup, idempotence).
- OQ6: Does `ConditionNeedsUpdate` fire on bootc?
- OQ7: Fedora defaults for `bootc-fetch-apply-updates.timer` (docs blocked;
  labs observed disabled).
- OQ8: When exactly kernel/initramfs are copied to `/boot` (stage vs
  finalize).

## Recommendation

A recommendation is not a decision.

1. Keep M3; ADR-0001 reconsideration is **not** indicated by this evidence.
2. Treat the upstream state machine as **primitives**; plan an Eldora
   update supervisor layer (scope to be researched in 0.1C-B/0.1C-C), not a
   replacement update engine.
3. Keep RISK-0010 OPEN / RELEASE BLOCKER; adopt C-R1–C-R5 as candidate
   lifting criteria; run P-01 first (promoted at review to an early
   fact-finding probe; not executed).
4. Track the upstream direction for U1 (ostree 2026.3 gpt-auto
   activation) and U7 (remount bug); do not rely on an upstream fix alone,
   since the missing stamp/user signal is not reported upstream.
5. Register RC-H to RC-L after human review if accepted (registered at
   review as RISK-0012 to RISK-0016).
6. Confirm or re-map the scopes of 0.1C-B and 0.1C-C (confirmed at
   review, with 0.1C-F; see Part 11).

- **Confidence:** MEDIUM.

## Confidence and limitations

- **Fedora documentation: partially unavailable.** docs.fedoraproject.org
  returned access restrictions (a bot-protection "access denied" page) on
  2026-09-26; Fedora bootc and Fedora IoT pages could not be re-read.
  Fedora-specific claims rely on RES-0003, Fedora wiki Change pages and lab
  observations.
- **GitHub: intentionally not consulted in the first research pass**, per
  `AGENTS.md` ("GitHub and remote authority").
- **Authorized second pass.** The Project Owner later explicitly authorized
  a read-only pass over the official bootc and ostreedev/ostree issue
  trackers **exclusively for RISK-0010**. That pass is represented by
  U1–U9 / S49–S59 (Part 5); two items (S52, Fedora Bugzilla; S59, systemd)
  were read only because they are directly cross-referenced by U1, under
  the "strictly necessary" clause of the same authorization. It was not
  used for any other topic in this report.
- **Authority of tracker evidence.** U1–U9 are Tier 2 (maintainer/tracker
  statements; S51 release notes Tier 1), read through a summarising fetch
  tool, with statuses as of 2026-09-26. They show what upstream reported,
  discussed or merged; they do not establish code behaviour, do not prove
  that a fix is effective in the versions Eldora would ship, and the
  absence of a matching report is not proof of a new bug. Maintainer
  quotes were requested verbatim and should be re-checked before citation
  in a decision record.
- **Still UNVERIFIED where applicable:** source code (bootc, ostree,
  systemd, GRUB), bootupd, greenboot/greenboot-rs, the OCI spec text, and
  any other material not read; boot counting on Fedora GRUB, greenboot on
  bootc, Fedora defaults, and upstream bug or fix status beyond U1–U9.
- MEDIUM overall: state-machine and status facts rest on current bootc
  documentation (Tier 1, partly verified); the RISK-0010 root cause is an
  inference consistent with the documentation, the lab script and the
  tracker evidence, not observed at code level.
- No probe executed; the failure matrix is documentary.

## Decision

NOT TAKEN — research does not decide. Q-0008 remains NOT DECIDED.

## Sources

All accessed 2026-09-26. Tier per `docs/research/README.md`.

| # | Source (title — organization — URL / path) | Tier | Version / date covered | Accessed | Used for |
|---|---|---|---|---|---|
| S1 | bootc-upgrade(8) — bootc — https://bootc.dev/bootc/man/bootc-upgrade.8.html | 1 | bootc ~1.16 (undated) | 2026-09-26 | L1, L8 |
| S2 | bootc book, print view (upgrades, download-only, failure detection, progress-fd, status-updated units, container runtime, API) — bootc — https://bootc.dev/bootc/print.html | 1 | undated (live; ~1.16) | 2026-09-26 | L1, L5, L7, L8, L11, L13–L16, Parts 6–7 (verified) |
| S3 | host-v1 JSON schema — bootc — https://bootc.dev/bootc/host-v1.schema.json | 1 | `org.containers.bootc/v1` | 2026-09-26 | status fields |
| S4 | bootc-switch(8) — bootc — https://bootc.dev/bootc/man/bootc-switch.8.html | 1 | undated | 2026-09-26 | L1, L4 |
| S5 | ostree_ext container/store API docs — bootc — https://bootc.dev/bootc/internals/ostree_ext/container/store/index.html | 1 (internal API) | ostree-ext 0.15.3 | 2026-09-26 | L2, L3 |
| S6 | ostree native containers — rpm-ostree — https://coreos.github.io/rpm-ostree/container/ | 1 | undated | 2026-09-26 | L3, L4 |
| S7 | bootc-install-to-disk(8) — bootc — https://bootc.dev/bootc/man/bootc-install-to-disk.8.html | 1 | undated | 2026-09-26 | L4, `--karg` |
| S8 | Deployments — OSTree — https://ostreedev.github.io/ostree/deployment/ | 1 | undated | 2026-09-26 | L5, L9, L13 |
| S9 | Bootloaders — OSTree — https://ostreedev.github.io/ostree/bootloaders/ | 1 | undated | 2026-09-26 | L6 |
| S10 | ostree-admin-lock-finalization(1) — OSTree (Arch man mirror) — https://man.archlinux.org/man/extra/ostree/ostree-admin-lock-finalization.1.en | 1 (mirror of upstream man) | ostree 2026.4 | 2026-09-26 | L7 |
| S11 | composefs — OSTree — https://ostreedev.github.io/ostree/composefs/ | 1 | undated | 2026-09-26 | L9 |
| S12 | bootc-rollback(8) — bootc — https://bootc.dev/bootc/man/bootc-rollback.8.html | 1 | undated | 2026-09-26 | L10, Part 8 |
| S13 | ostree-admin-pin(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-pin.html | 1 | undated | 2026-09-26 | L10 |
| S14 | Atomic Upgrades — OSTree — https://ostreedev.github.io/ostree/atomic-upgrades/ | 1 | undated | 2026-09-26 | L12, Part 5 |
| S15 | Using bootc via API — bootc — https://bootc.dev/bootc/bootc-via-api.html | 1 | undated | 2026-09-26 | L16 |
| S16 | Relationships — bootc — https://bootc.dev/bootc/relationships.html | 1 | undated | 2026-09-26 | L16 |
| S17 | rpm-ostree daemon architecture — rpm-ostree — https://coreos.github.io/rpm-ostree/architecture-daemon/ | 1 | undated | 2026-09-26 | L16 |
| S18 | Bug 1945274 (finalize failure warning) — Red Hat Bugzilla — https://bugzilla.redhat.com/show_bug.cgi?id=1945274 | 2 | 2021 | 2026-09-26 | finalize failure field behaviour |
| S19 | Changes/AutomaticBootloaderUpdatesBootc — Fedora — https://fedoraproject.org/wiki/Changes/AutomaticBootloaderUpdatesBootc | 2 | F43 | 2026-09-26 | boot chain, atomic ESP swap |
| S20 | ostree.repo-config(5) — OSTree — https://ostreedev.github.io/ostree/man/ostree.repo-config.html | 1 | undated | 2026-09-26 | boot-counting-tries, bootprefix |
| S21 | systemd-gpt-auto-generator(8) — systemd — local `/usr/share/man/man8/systemd-gpt-auto-generator.8.gz` (and `strings` of the binary); online render at https://man7.org/linux/man-pages/man8/systemd-gpt-auto-generator.8.html | 1 | systemd 259.9-1.fc44 (local); 262~devel (online) | 2026-09-26 | Part 5 |
| S22 | Automatic Boot Assessment — systemd — https://systemd.io/AUTOMATIC_BOOT_ASSESSMENT/ ; systemd-bless-boot.service(8) local | 1 | current; 259.9 | 2026-09-26 | Part 7 |
| S23 | systemd-boot-check-no-failures.service(8) — systemd — local man page | 1 | 259.9 | 2026-09-26 | F18, Part 7 |
| S24 | systemd.special(7) (`boot-complete.target`) — systemd — local man page | 1 | 259.9 | 2026-09-26 | Part 7 |
| S25 | systemd.unit(5) (`ConditionNeedsUpdate=`, `RequiresMountsFor=`) — systemd — local man page | 1 | 259.9 | 2026-09-26 | Part 8 |
| S26 | systemd.unit(5) `ConditionACPower=` — systemd — local man page | 1 | 259.9 | 2026-09-26 | Part 11 |
| S27 | Bootloaders — bootc — https://bootc.dev/bootc/bootloaders.html | 1 | undated | 2026-09-26 | bootupd at install only; systemd-boot composefs-only |
| S28 | grub-boot-success.timer/.service, grub-boot-indeterminate.service — grub2 (Fedora) — local `/usr/lib/systemd/user/`, `/usr/lib/systemd/system/` | 1 | grub2 2.12-64.fc44 | 2026-09-26 | Part 7 |
| S29 | Bug 1971356 (boot_success timer rationale) — Red Hat Bugzilla — https://bugzilla.redhat.com/show_bug.cgi?id=1971356 | 2 | 2021 | 2026-09-26 | Part 7 |
| S30 | Changes/HiddenGrubMenu — Fedora — https://fedoraproject.org/wiki/Changes/HiddenGrubMenu | 2 | F29 | 2026-09-26 | Part 7 |
| S31 | shim-x64 file list — Fedora package — local `rpm -ql shim-x64` | 1 | 16.1-5 | 2026-09-26 | fallback path |
| S32 | RHSB-2021-003 (SBAT) — Red Hat — https://access.redhat.com/security/vulnerabilities/RHSB-2021-003 | 2 | 2021-03-01, upd. 2022-05-10 | 2026-09-26 | SBAT |
| S33 | Understanding bootc install / partitioning details — bootc — https://bootc.dev/bootc/print.html (install sections) | 1 | bootc ≥ 1.11 text | 2026-09-26 | layout, fstab direction, boot-mount-spec (verified) |
| S34 | systemd.automount(5) / systemd.mount(5) — systemd — local man pages | 1 | 259.9 | 2026-09-26 | shutdown ordering |
| S35 | Root partition mount point API (`ostree_sysroot_set_mount_namespace_in_use`) — OSTree — https://ostreedev.github.io/ostree/reference/ostree-Root-partition-mount-point.html | 1 | undated | 2026-09-26 | remount behaviour |
| S36 | mount(2) — Linux man-pages — https://man7.org/linux/man-pages/man2/mount.2.html | 1 | man-pages 6.19 | 2026-09-26 | EINVAL semantics |
| S37 | ostree 2026.4-1 file list — Arch Linux — https://archlinux.org/packages/extra/x86_64/ostree/files/ | 2 | 2026.4 | 2026-09-26 | finalize-staged-hold unit exists |
| S38 | UAPI.2 Discoverable Partitions Specification; UAPI.1 Boot Loader Specification — UAPI Group — https://uapi-group.org/specifications/specs/discoverable_partitions_specification/ ; https://uapi-group.org/specifications/specs/boot_loader_specification/ | 1 | current | 2026-09-26 | no-auto flag scope; ESP/XBOOTLDR mounting; boot counting |
| S39 | Changes/Greenboot_RS_Change_Proposal — Fedora — https://fedoraproject.org/wiki/Changes/Greenboot_RS_Change_Proposal | 2 | F43 | 2026-09-26 | greenboot-rs |
| S40 | Greenboot: Automate rollbacks for atomically updated systems — Red Hat Developer — https://developers.redhat.com/articles/2024/08/12/greenboot-automate-rollbacks-atomically-updated-systems | 2 | 2024-08-12 | 2026-09-26 | greenboot behaviour |
| S41 | MicroShift 4.22 greenboot documentation — Red Hat — docs.redhat.com (MicroShift greenboot chapter) | 2 | 4.22 | 2026-09-26 | GREENBOOT_MAX_BOOTS |
| S42 | Filesystem (`/var`) — bootc — https://bootc.dev/bootc/filesystem.html ; `/var` — OSTree — https://ostreedev.github.io/ostree/var/ | 1 | undated | 2026-09-26 | Part 8 |
| S43 | Filesystem (timestamps squashed) — bootc — https://bootc.dev/bootc/filesystem.html | 1 | undated | 2026-09-26 | Part 8 |
| S44 | containers-policy.json(5) — containers — local man page | 1 | containers-common 0.67.2 | 2026-09-26 | Part 9 |
| S45 | containers-signature(5) — containers — local man page | 1 | containers-common 0.67.2 | 2026-09-26 | Part 9 |
| S46 | libostree upgrader API (`ostree_sysroot_upgrader_check_timestamps`); ostree-admin-upgrade(1) `--allow-downgrade` — OSTree — https://ostreedev.github.io/ostree/ | 1 | undated | 2026-09-26 | Part 9 |
| S47 | The Update Framework specification — TUF — https://theupdateframework.github.io/specification/latest/ | 1 | 1.0.36 (2026-08-05) | 2026-09-26 | Part 9 |
| S48 | NetworkManager D-Bus `Metered`; nm-settings-nmcli(5) — NetworkManager — https://networkmanager.dev/docs/api/latest/ ; local man page | 1 | NM 1.56.1 (local) | 2026-09-26 | Part 11 |
| S49 | PR #3608 "prepare-root: create /run/systemd/volatile-root for composefs" (incl. post-merge comments) — ostreedev/ostree — https://github.com/ostreedev/ostree/pull/3608 ; commit https://github.com/ostreedev/ostree/commit/62109dca | 2 | merged 2026-07-31; comments 2026-08-21..27 | 2026-09-26 | Part 5 U1 (authorized pass) |
| S50 | Issue #2543 "Finalizing staged deployments broken on /boot automount"; PR #2544 "finalize-staged: Ensure /boot and /sysroot automounts don't expire" — ostreedev/ostree — https://github.com/ostreedev/ostree/issues/2543 ; https://github.com/ostreedev/ostree/pull/2544 | 2 | 2022-02-16 .. 2022-08-30 | 2026-09-26 | Part 5 U6 |
| S51 | Releases v2026.3 (2026-08-05) and v2026.4 (2026-08-19) — ostreedev/ostree — https://github.com/ostreedev/ostree/releases | 1 | 2026.3, 2026.4 | 2026-09-26 | Part 5 U1 |
| S52 | Bug 2520626 (ostree-2026.3-1.fc44, `/home` not canonical) — Fedora / Red Hat Bugzilla — https://bugzilla.redhat.com/show_bug.cgi?id=2520626 | 2 | 2026-08-20 .. 2026-08-22 | 2026-09-26 | Part 5 U2 |
| S53 | Issue #2402 "auto-updates fail with `opendir(boot): Operation not permitted` when /boot is a systemd automount that has idled out" — bootc-dev/bootc — https://github.com/bootc-dev/bootc/issues/2402 | 2 | 2026-08-22 (open) | 2026-09-26 | Part 5 U3 |
| S54 | PR #2411 "Unshare fix for boot.automount" — bootc-dev/bootc — https://github.com/bootc-dev/bootc/pull/2411 | 2 | merged 2026-08-26 | 2026-09-26 | Part 5 U4 |
| S55 | PR #2488 "systemd: Order bootc-finalize-staged after /boot mount" — bootc-dev/bootc — https://github.com/bootc-dev/bootc/pull/2488 | 2 | closed 2026-09-24 | 2026-09-26 | Part 5 U5 |
| S56 | PR #2496 "composefs: Hold /boot open while a deployment is staged" — bootc-dev/bootc — https://github.com/bootc-dev/bootc/pull/2496 | 2 | merged 2026-09-25 | 2026-09-26 | Part 5 U5 |
| S57 | Issue #3365 "prepare-root: boot is kept writable" — ostreedev/ostree — https://github.com/ostreedev/ostree/issues/3365 | 2 | 2025-01-06 (open) | 2026-09-26 | Part 5 U7 |
| S58 | Issue #1673 "Problem enabling transient /etc in fedora-based bootc image" — bootc-dev/bootc — https://github.com/bootc-dev/bootc/issues/1673 | 2 | 2025-10-07 (open) | 2026-09-26 | Part 5 U8 |
| S59 | Issue #35017 "systemd-gpt-auto-generator can't find ESP because it can't detect blockdev of / if composefs is used" — systemd/systemd — https://github.com/systemd/systemd/issues/35017 | 2 | 2024-11-04 (open) | 2026-09-26 | Part 5 U9 |

Earlier project evidence: RES-0003, RES-0004, RES-0005 and their lab
directories (versioned in this repository).
