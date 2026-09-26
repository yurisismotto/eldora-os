# RES-0008 — Health, Known-Good, Rollback & Recovery Semantics (Wave 0.1C-C)

| Field | Value |
|---|---|
| ID | RES-0008 |
| Title | Health, Known-Good, Rollback & Recovery Semantics |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1C-C — Health, Known-Good, Rollback & Recovery Semantics, parent 0.1C) |
| Related questions | Q-0008 |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): verification of repository preconditions; planning; documentary research through four delegated read-only research sub-agents (A: bootc/OSTree rollback, retention, boot counting, reset, bootupd; B: systemd boot assessment, failure actions, journal, pstore, factory reset; C: Fedora GRUB flags, greenboot/greenboot-rs, shim/SBAT, Fedora/FCOS recovery; D: external precedents — Android, ChromeOS, Mender, RAUC, Ubuntu Core, systemd-sysupdate, Windows, macOS, application data downgrade); re-analysis of RES-0003 to RES-0007; analysis and drafting. Process deviations are disclosed under "Method and limitations". Bounded semantic corrections A1–A5, the RC-Y Project Owner direction and the lifecycle/review metadata were applied by the agent on Project Owner instruction after review (listed in the review record). |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: APPROVED WITH REQUIRED SEMANTIC CORRECTIONS — see [review record](../../project/reviews/WAVE-0.1C-REVIEW.md#review-of-res-0008-wave-01c-c)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (documentary; no probe executed; see "Confidence and limitations") |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records accepted by the Project
> Owner. ADR-0001 (M3 SELECTED FOR V1) is **not** reopened by this report.
> Q-0008 remains **NOT DECIDED**. RISK-0010 remains **OPEN / RELEASE
> BLOCKER FOR M3**. No probe was executed (P-01 included); no VM was
> started; no failure was injected; nothing was implemented. No state
> name, threshold, attempt count, retention count, dwell time, recovery
> environment or destructive default is selected here. No ADR is created
> or proposed in this change. No risk is registered, closed or re-rated.
>
> **Review status:** REVIEWED — approved with required semantic
> corrections by the Project Owner on 2026-09-26. Corrections A1–A5 and
> the Project Owner direction on RC-Y are incorporated below (marked
> "Project Owner correction" / "Project Owner direction"). The review
> accepts the candidate requirements only as **input / architectural
> direction** for later ADRs and planning (not permanent requirements);
> attempt count and dwell parameters remain undecided and
> probe-dependent; reset/reinstall preservation defaults remain
> deferred. RC-U to RC-Z were registered as RISK-0017 to RISK-0022
> (OPEN); RC-T is avoided by design direction (R-HM6); RC-AA is deferred.
> No ADR is created; Q-0008 remains NOT DECIDED. Dispositions are
> recorded in the
> [review record](../../project/reviews/WAVE-0.1C-REVIEW.md#review-of-res-0008-wave-01c-c).

Labels used (as in RES-0006/RES-0007): **FACT** (documented upstream,
cited `[Sn]`), **OBSERVED** (versioned laboratory evidence in
RES-0004/RES-0005, or read-only observation of the local Fedora 44 host,
cited as such), **INFERENCE** (reasoned from facts/observations),
**HYPOTHESIS** (to be tested), **RECOMMENDATION** (not a decision),
**CANDIDATE REQUIREMENT** (proposal, not accepted), **OPEN QUESTION**.
`UNVERIFIED` marks a claim that could not be confirmed from an allowed
primary source.

Candidate requirements in this report use the namespace `R-<AREA><n>`
with the areas `HM` (health model), `KG` (known-good), `RB` (rollback),
`AT` (attempts), `LP` (loop prevention), `FL` (floor interaction), `RT`
(retention), `ST` (persistent state), `RC` (recovery), `OV` (owner
override), `OB` (observability), `PV` (privacy). They are distinct from the
RES-0007 candidates (`R-P…`, `R-T…`, `R-F…`, `R-A…`, `R-S…`, …), which
remain as RES-0007 recorded them. Failure scenarios of this report are
numbered **RF1–RF22** to avoid confusion with RES-0006 F01–F26. Candidate
risks continue the RES-0007 sequence (**RC-T** onwards). Proposed probes
continue the P-series (**P-25** onwards).

## Question

How should Eldora OS determine whether a newly booted deployment is
healthy and known-good, when should it roll back, and how should it
recover when normal deployment rollback is insufficient?

## Scope

Parts 1–33 of the 0.1C-C brief (Project Owner instruction, 2026-09-26):
lifecycle categories STAGED … RECOVERY_REQUIRED; the BOOTED / HEALTHY /
KNOWN_GOOD model; upstream capability map; health domains; critical vs
degraded vs optional health; health-signal trust; known-good models;
update-success semantics; automatic rollback triggers; boot-attempt
budget; rollback-loop prevention; rollback vs anti-rollback; floor
advancement; deployment retention; `/etc`, `/var` and `$HOME` across
rollback; application-model requirements; boot-chain recovery; both
deployments failing; recovery environment alternatives and capabilities;
repair/reset/reinstall semantics; hardware failure boundary; third-party
drivers; security failure semantics; owner override; observability;
privacy; threat model; failure matrix; responsibility map. Inputs:
RES-0006 (state machine, F01–F26, Parts 6–8, 12), RES-0007 (Part 16
anti-rollback principles — mandatory input per the Project Owner's
review — and HC-1 to HC-8). Default backend: OSTree (as in RES-0004 to
RES-0007); the composefs-native backend is noted where it differs.

## Out of Scope

Implementing Eldora OS, the Update Supervisor, health services, daemons,
APIs, D-Bus interfaces, schemas or UI; defining implementation probes for
health (only semantics); selecting greenboot or any component; selecting
a bootloader, installer, partition layout or recovery environment (0.1D
and a later ADR); signing infrastructure (0.1D); the application model
(Q-0003, Wave 0.3); NVIDIA/driver support (RISK-0002, PX3); executing any
probe (P-01 to P-24, PX-series); starting 0.1C-F or 0.1D; deciding
Q-0008; creating or accepting an ADR; registering, closing or re-rating
risks.

## Preconditions verified (2026-09-26, repository state at `9503aaa`)

Verified from the repository (not from the brief): `main` =
`origin/main` = `9503aaa` (local refs only; no remote contacted); working
tree clean; Git identity unchanged (Project Owner's configured name and
e-mail). Wave 0.1C-A CLOSED; RES-0006 REVIEWED; Wave 0.1C-B CLOSED;
RES-0007 REVIEWED; ADR-0001 ACCEPTED; OB-0004 (Fedora-derived V1)
CONFIRMED; M3 bootc/OCI SELECTED FOR V1; Q-0008 IN RESEARCH / NOT DECIDED;
RISK-0010 OPEN / RELEASE BLOCKER FOR M3; RISK-0012 to RISK-0016 OPEN;
Wave 0.1C-C PLANNED / not started; Wave 0.1C-F PLANNED / not started;
Wave 0.1D PLANNED / not started. **No divergence found.**

Status of risks and probes from RES-0006 and RES-0007 (verified):

| Item | Status in the repository |
|---|---|
| RC-H to RC-L (RES-0006) | Registered as RISK-0012 to RISK-0016, all `OPEN` |
| RC-M to RC-S (RES-0007) | Candidates only; **not registered** (review record 0.1C) |
| P-01 (RES-0006) | EARLY FACT-FINDING PROBE; **not executed** |
| P-02 to P-16 (RES-0006) | PLANNED FOR 0.1C-F; none executed |
| P-17 to P-24; extensions of P-04, P-06, P-12, P-13, PX6 (RES-0007) | PROPOSED; preserved for 0.1C-F; none executed |
| PX1 / PX3 / PX6 (RES-0002) | HIGH PRIORITY / FUTURE GATE; HIGH PRIORITY / HARDWARE GATE; MEDIUM PRIORITY / DOCUMENTARY; none executed |
| PX2, PX4, PX5, PX7, PX8, PX9 (RES-0002) | PROPOSED; none executed |

This report moves Wave 0.1C-C to IN PROGRESS only (administrative changes
in the same change set: `CURRENT-STATE.md`, `FOUNDATION-ROADMAP.md`,
`DECISION-REGISTER.md` link to this DRAFT).

## Method and limitations

- Documentary research on 2026-09-26 by four read-only research
  sub-agents, constrained by the brief's network rules (public
  documentation, specifications, public source-code and issue/PR web
  pages viewed anonymously and read-only; no `git` remote operation, no
  `gh`, no authenticated or REST API, no registry, no image pull, no
  large download, no VM, no sudo, no package installation, no host
  change, no failure injection).
- Local Tier-1 sources on the Project Owner's Fedora 44 workstation,
  read-only: systemd 259.9-1.fc44 man pages and unit files;
  grub2-tools 2.12-64.fc44 units and man pages; shim-x64 16.1-5 file
  list; mokutil 0.7.2 man page; dracut.cmdline(7); polkit action files;
  `/proc/sys/kernel/panic`, `/proc/cmdline`, EFI variable presence
  (`LoaderBootCountPath` absent; LoaderInfo "GRUB 2.12"). **bootc,
  ostree, rpm-ostree, bootupd and greenboot are not installed** on this
  host; their behaviour comes from upstream documentation and source
  pages only. The host is a package-based Fedora Workstation, **not** an
  Eldora or bootc system; host observations are evidence about Fedora
  defaults, not about Eldora.
- Several upstream documents were read at upstream `main` (bootc,
  OSTree, systemd, rhboot/grub2 `fedora-44` branch, greenboot-rs); the
  versions Fedora ships may differ.
- Web fetches pass through a summarising tool. Quotes marked "(verbatim)"
  were returned as exact text (raw files or local man pages); other
  quotes may carry paraphrase drift and must be re-checked before
  citation in a decision record.
- docs.fedoraproject.org and src.fedoraproject.org returned bot-protection
  pages; they were **not** bypassed. Fedora Atomic documentation claims
  rely on the public AsciiDoc source of `fedora-silverblue/silverblue-docs`
  (possibly a legacy copy; UNVERIFIED as current) and on Fedora wiki
  Change pages. freedesktop.org man pages returned 403; systemd man pages
  were read locally (259.9) and from upstream raw sources.
- **Process deviations (disclosed):**
  1. Sub-agents A, B and C read documentation and source files through
     anonymous `raw.githubusercontent.com` / `github.com` web views (bootc
     docs sources, systemd docs and man XML, the UAPI BLS spec,
     rhboot/grub2 `fedora-44` `util/grub.d/*.in`, greenboot-rs sources,
     bootupd README/source, shim `README.fallback`/`SBAT.md`) because
     rendered pages were blocked or summarised lossily. This is within
     the brief's "public source-code viewing when necessary"; no API,
     authentication, clone or write was used.
  2. Sub-agent B saved plain-text renderings of local man pages into the
     job scratch directory (outside the repository) for quoting.
  3. Some precedents (Ubuntu Core boot modes, Mender U-Boot integration,
     Android bootloader updating page) rest on search-engine snippets
     because the pages failed to load; they are marked as such.
  No VM, probe, failure injection, sudo, package installation, registry
  contact, image pull or Git remote operation was performed. No
  repository file outside the listed administrative files and this
  report was modified.

## Facts

### Upstream bootc / OSTree (U-series)

- **FACT U1 — no health gate, no automatic rollback in bootc.** "The
  system must perform health checking on itself (or have an external
  system do it)" [S3]; no automatic rollback is documented in bootc
  [S1, S2, S4]. RES-0006 L10/L13 and Part 6 confirmed.
- **FACT U2 — rollback is an entry reorder.** `bootc rollback`: "Change
  the bootloader entry ordering; the deployment under `rollback` will be
  queued for the next boot, and the current will become rollback. If
  there is a `staged` entry … then it will be discarded" (verbatim) [S1].
  "absent any additional control logic, if there is an active agent doing
  automated upgrades … the change here may be reverted" (verbatim) [S1].
  A rollback invocation logs `MESSAGE_ID=26f3b1eb24464d12aa5e7b544a6b5468`
  (verbatim) [S1]. Tier-2 bug: rollback after `switch` both discards the
  staged deployment and queues the rollback entry (bootc#946, open) [S20].
- **FACT U3 — `/etc` on rollback.** "any changes made to files in the
  `/etc` directory won't carry over to the rolled-back deployment … This
  is because `bootc rollback` just reorders the existing deployments. It
  doesn't create new deployments. The `/etc` merges happen when new
  deployments are created" (verbatim) [S1]. Consistent with RES-0006 Q13
  and RES-0004 DV3.
- **FACT U4 — default retention is two, staging prunes the old
  rollback.** libostree's simple write "by default … GCs every other
  deployment … except the merge deployment and the booted deployment";
  "Typical uses of libostree only retain at most 2 deployments" [S10];
  rpm-ostree: "will keep at most two bootable 'deployments', though the
  underlying technology supports more" [S19]; `ostree admin deploy`
  offers `--retain`, `--retain-pending`, `--retain-rollback` [S11].
  **No configurable retention count** was found; a `deployments-max`
  proposal was closed and an experimental, env-gated "early prune" of the
  rollback kernel/initramfs from `/boot` was merged instead (Tier 2)
  [S17].
- **FACT U5 — pinning exists in OSTree, not in bootc's verbs.** `ostree
  admin pin INDEX` "Ensures the deployment at INDEX, will not be garbage
  collected by default" [S12]; bootc(8) lists no pin verb [S9]; bootc
  status reports `otherDeployments` ("i.e. pinned") and `pinned` [S8].
  API note: libostree versions unaware of pinning may still remove pinned
  deployments [S10].
- **FACT U6 — boot counting in OSTree targets BLS/systemd-boot.**
  `[sysroot] boot-counting-tries` stores counters in the boot entry file
  name per the BLS (verbatim) [S14]; added 2025-07 (Tier 2), tested on
  EDK2 + systemd-boot, behind a build option (UNVERIFIED whether Fedora
  enables it) [S16]. bootc: "systemd-boot is only supported for Composefs
  Backend and not for Ostree" (verbatim) [S5]; "the composefs backend does
  not configure boot entry counting, this is likely to be added in the
  future" (verbatim) [S4].
- **FACT U7 — failure detection covers finalization, not boot or
  workload.** `ostree-boot-complete.service` runs only when the
  finalize-failure stamp exists [S4, S18] (RES-0006 L13); composefs has no
  equivalent [S4]. It is **not** a boot-success or health mechanism.
- **FACT U8 — `/var` and state.** "OSTree does not touch the contents of
  `/var`" [S15]; `/var` content in the image "acts like a Docker `VOLUME
  /var`" and later image changes to `/var` "are not automatically
  applied"; "a bootc update or rollback should not affect this
  application data" [S6]. No bootc/OSTree guidance on schema/data
  migration or backward compatibility for rollback was found [S6, S15].
  Transient `/etc` is "supported (and encouraged)" via `prepare-root.conf`
  [S6].
- **FACT U9 — stateroots and experimental reset.** "Each deployment is
  grouped in exactly one 'stateroot'"; "Each stateroot has exactly one
  copy of the traditional Unix `/var`" [S15]. `bootc install reset` is
  experimental ("use `--experimental` flag"): it "creates a fresh
  installation state in a new stateroot while preserving the existing
  system's files on disk"; after reboot "`/etc` contains only the
  configuration from the container image" and "`/var` is empty"; the old
  stateroot remains until manually removed (verbatim) [S7].
- **FACT U10 — disk floors.** OSTree `min-free-space-percent` default 3
  and `min-free-space-size` default 1 GB, "the smaller of the two is
  enforced"; not enforced on metadata objects (verbatim) [S14]. Behaviour
  of bootc staging at the floor: not documented (RES-0006 F07/F08).
- **FACT U11 — bootupd.** UEFI ESP updates are "considered safe, even in
  case of power failures"; "bootupd does not yet perform updates in a way
  that is safe against a buggy bootloader update that fails to boot the
  system" (issue #440, A/B via `BootNext`, open since 2023-03-17) [S21];
  downgrades are skipped ("Ignoring downgrade", source; OBSERVED RES-0005
  E3); no backup of previous EFI binaries found (UNVERIFIED beyond the
  file read) [S21]. Fedora enables `bootloader-update.service` for bootc
  systems (F43; Atomic Desktops since F41); the Change makes no rollback
  or recovery statement [S22].

### systemd (Y-series)

- **FACT Y1 — Automatic Boot Assessment.** "systemd provides support for
  automatically reverting back to the previous version of the OS or
  kernel in case the system consistently fails to boot" (verbatim) [S23].
  The loader decrements the "tries left" counter in the entry file name
  **before** booting ("at this point one attempt has started", verbatim);
  at zero the entry is "considered 'bad', and ordered after all non-bad
  entries" (verbatim) [S23, S25]. Success = reaching
  `boot-complete.target`, after which `systemd-bless-boot.service`
  removes the counters [S23, S24].
- **FACT Y2 — plugging in health.** Checks are ordered "before the
  generic `boot-complete.target` target unit, combined with `Requires=`
  dependencies from the target, so that the target cannot be reached when
  any of the units fail" (verbatim) [S23]. The document's own example
  gates success on a user session: "one minute after the user has logged
  in and started the first program, a user service … makes a D-Bus call
  to `graphical-session-good.service`" (verbatim) [S23].
  `systemd-bless-boot bad` can mark the current entry bad at any time
  [S23, S24].
- **FACT Y3 — loader dependency.** bless-boot operates on the
  `LoaderBootCountPath` EFI variable "passed from the boot loader to the
  OS" (verbatim) [S24]; the generator acts "when boot counting, as
  implemented by systemd-boot(7), is enabled" (verbatim) [S24]. OBSERVED
  (host): Fedora GRUB 2.12 does not set `LoaderBootCountPath`.
  systemd-boot lets the user "freely choose to boot any entry of the menu,
  including those already marked 'bad'" [S26].
- **FACT Y4 — minimal check only.** `systemd-boot-check-no-failures.service`
  "implements a very minimal test only: whether there are any failed
  units on the system. This service is disabled by default … probably not
  suitable for deployment in most scenarios" (verbatim) [S24].
- **FACT Y5 — failure and timeout actions.** `FailureAction=`,
  `OnFailure=`, `StartLimitAction=`, `JobTimeoutSec=`/`JobTimeoutAction=`
  (values include `reboot`, `reboot-force`, `soft-reboot`, `poweroff`)
  exist; `JobTimeoutAction=` defaults to none [S27]. Initrd and root
  filesystem failures go to `emergency.target` (`OnFailure=`) [S27;
  OBSERVED host units], which "starts an emergency shell on the main
  console" (verbatim) [S24]. dracut: "rd.emergency=[reboot|poweroff|halt]
  specify, what action to execute in case of a critical failure. rd.shell=0
  must also be specified" (verbatim) [S28]. `systemd.crash_action=`
  defaults to "freeze" (PID 1 only) [S27].
- **FACT Y6 — panic and watchdog defaults.** Kernel `panic=0` means
  "loop forever" [S29]. OBSERVED (host): `kernel.panic = 0`,
  `panic_on_oops = 0`, no sysctl or cmdline override;
  `RuntimeWatchdogSec` off by default [S27]. INFERENCE: on a default
  Fedora configuration a kernel panic or an emergency-shell stop **does
  not end the boot attempt**; the loader never runs again until a human or
  a hardware watchdog power-cycles the machine.
- **FACT Y7 — crash evidence.** `systemd-pstore.service` saves pstore
  records to the journal and `/var/lib/systemd/pstore` (verbatim) [S30].
  OBSERVED (host): the EFI pstore backend is disabled by default
  (`efi_pstore pstore_disable=Y`, backend `(null)`); `kdump.service` not
  present. journald defaults to persistent storage under
  `/var/log/journal`, but uses volatile storage until
  `systemd-journal-flush.service` [S31]. INFERENCE: failures before `/var`
  is mounted and flushed leave **no** durable log.
- **FACT Y8 — factory reset.** "Factory reset always takes place during
  early boot"; `systemd-repart` erases only partitions marked
  `FactoryReset=` ("Defaults to off"); request via the
  `FactoryResetRequest` EFI variable or `systemd.factory_reset=1`
  (verbatim) [S32]. Local 259.9 wiring differs from upstream `main` in
  the units pulled into `factory-reset.target` (OBSERVED) [S32].
- **FACT Y9 — soft-reboot skips the loader.** It skips "The firmware
  initialization. • The boot loader initialization. • The kernel
  initialization. • The initrd initialization" (verbatim) [S33]; no
  statement about boot counting was found. INFERENCE: soft-reboot neither
  consumes nor records a loader-level attempt.
- **FACT Y10 — privilege.** `org.freedesktop.systemd1.manage-units`
  requires `auth_admin` (active: `auth_admin_keep`) (OBSERVED, local
  polkit policy) [S35]: unprivileged users cannot start
  `boot-complete.target` or bless-boot. `org.freedesktop.login1.reboot`
  is `allow_active=yes` [S35]: an active local user can reboot, and so
  consume a loader-level boot attempt.
- **FACT Y11 — sysupdate precedent.** `sysupdate.d` can write initial
  `TriesLeft=`/`TriesDone=` into installed file names; `ProtectVersion=`
  versions "are never removed"; `pending` reports an installed but not
  yet booted version [S34]. No mark-good/rollback verb of its own [S34].

### Fedora integration (G-series)

- **FACT G1 — Fedora GRUB "success" is a user-session timer.**
  `grub-boot-success.timer` (user unit): "Mark boot as successful after
  the user session has run 2 minutes", `ConditionUser=!@system`,
  `OnActiveSec=2min`; the service runs `grub2-set-bootflag boot_success`
  (verbatim, local) [S36]. `grub2-set-bootflag` is **setuid root**
  (`-rwsr-xr-x`, OBSERVED) and accepts `boot_success` and
  `menu_show_once` [S36, S37].
- **FACT G2 — what `boot_success` does.** `10_reset_boot_success`: "The
  boot_success var needs to be set to 1 from userspace to mark a boot
  successful"; it permits menu hiding and is reset to 0 each boot;
  `12_menu_auto_hide` hides the menu only if the previous boot set it
  (verbatim, rhboot/grub2 `fedora-44`) [S37, S40]. **Effect: menu
  visibility, not entry selection.**
- **FACT G3 — GRUB fallback counting exists but is inert by default.**
  `08_fallback_counting`: "The boot_counter env var can be used to count
  down boot attempts after an OSTree upgrade and choose the rollback
  deployment when 0 is reached. Both boot_counter=X and boot_success=1
  need to be set from userspace"; at 0 it does `set default=1` (verbatim)
  [S37]. It is hard-wired to the **second** menu entry.
- **FACT G4 — no evidence that Fedora GRUB honours BLS `+N-M` counters.**
  Only systemd-boot is documented as implementing them [S23, S26]; OSTree
  counting targeted systemd-boot [S16]; Fedora `blscfg` code was not
  inspected (UNVERIFIED) [S37].
- **FACT G5 — security history of the flag path.** CVE-2024-1048: a
  killed `grub2-set-bootflag` leaves temporary files that "may fill the
  filesystem" (`/boot`), exploitable by an unprivileged local user (CVSS
  3.3) [S38]. Red Hat bz#1975891 (Tier 2): grubenv writes on every boot
  change TPM PCR 8 [S39].
- **FACT G6 — greenboot / greenboot-rs.** Fedora 43 Change (accepted):
  Rust rewrite "adding support for bootc systems alongside rpm-ostree";
  "If any required checks fail the system will reboot, and may rollback
  to a previous, working deployment if necessary"; on success
  "`boot_counter` … is unset and the `boot_success` … is set to 1" [S41].
  greenboot-rs: `required.d`/`wanted.d`/`red.d`/`green.d`, health check
  "before systemd's boot-complete.target", default
  `GREENBOOT_MAX_BOOT_ATTEMPTS=3` (verbatim), rollback via `bootc
  rollback` or `rpm-ostree rollback` depending on detection, `Requires:
  rpm-ostree` in the spec, GRUB fragment installed through bootupd static
  configs with `default=1` [S42]. Explicit loop protection when the
  rollback target also fails: **not found** (only an MOTD warning;
  UNVERIFIED beyond the summarised code) [S42]. Red Hat MicroShift docs:
  "If a rollback is not available, the system log output shows that
  manual intervention is required" [S43]. **Contradiction:** bootc docs
  still say "greenboot does not yet integrate with bootc" [S3]; the F43
  Change and greenboot-rs code claim bootc support [S41, S42]. Actual
  behaviour on a bootc + Fedora GRUB host: **UNVERIFIED** (probe P-08).
- **FACT G7 — shim fallback and SBAT.** Firmware falls back to
  `\EFI\BOOT\BOOTX64.EFI`; `fbx64.efi` recreates boot variables from
  `BOOTX64.CSV` — it repairs NVRAM entries, not damaged binaries [S44].
  SBAT: generation numbers "should only ever go up; they should never be
  reset" [S44]; binaries below the stored level fail verification.
  August 2024 precedent: an SBAT revocation applied by a Windows update
  made older Linux shims unbootable under Secure Boot (Tier 3) [S45].
- **FACT G8 — Fedora Atomic manual recovery.** Rollback by boot-menu
  selection or `rpm-ostree rollback`; "Updating will undo the rollback";
  "`rpm-ostree` only keeps one rollback version available by default";
  pinning via `ostree admin pin` (legacy AsciiDoc source; UNVERIFIED as
  current) [S46]. Anaconda rescue mode exists (`inst.rescue`) but is not
  on Workstation Live media; WebUI support UNVERIFIED [S47].
- **FACT G9 — Fedora CoreOS has no automatic rollback.** Manual rollback
  only; "Zincati will keep looking for updates and upgrade to any new
  available OS deployment, other than the one you just reverted" [S48];
  tracker #47 "Determine how to handle automatic rollback" open since
  2018, citing the need to avoid "flapping" [S48].

### External precedents (X-series; design precedents only)

- **X1 — Android A/B.** The framework marks the slot successful "after …
  finishes the post-reboot checks" (verbatim); `update_verifier` runs
  "before zygote to avoid Java services making any irreversible changes
  that would prevent a safe rollback" (verbatim); per-slot retry counts in
  the bootloader [S49]. Anti-rollback: "until you've actually successfully
  booted the new image, rollback protection doesn't consider it to be the
  current system image" (verbatim) [S49]; AVB updates stored rollback
  indexes only from SUCCESSFUL slots, to the largest value allowing all
  bootable slots to boot (wording UNVERIFIED) [S50]. Virtual A/B merges
  "after confirming a successful boot" [S51]. User Data Checkpoint rolls
  `/data` back with the OS for an unconfirmed boot [S52]. Explicit
  downgrades always force a data wipe [S53]. Rescue Party escalates to a
  factory-reset **prompt**; "devices must provide a way for users to
  confirm any destruction of user data" (verbatim) [S54].
- **X2 — ChromeOS.** GPT "Successful Boot Flag", "Tries Remaining",
  "Priority" (verbatim); historically 6 attempts; success marked by a
  timer (45 s) after `update_engine` starts; rollback when "The kernel
  panics … The system hangs … The system application crashes before
  triggering boot-complete" (verbatim; design doc, possibly dated) [S55].
  Recovery image from read-only firmware wipes stateful data [S55];
  enterprise rollback wipes all local data [S56].
- **X3 — Mender / RAUC.** Mender commits after reboot and after
  `ArtifactCommit_Enter` checks (e.g. UI responding); a failed rollback
  leaves a "permanently inconsistent state" [S57]. RAUC: "It is a good
  idea to wait for the system to be fully started before marking it as
  successfully booted", via a systemd service ordered after the relevant
  services (verbatim) [S58].
- **X4 — Ubuntu Core.** Try-boot of kernel/base: success = snapd starts
  (effectively one attempt); per-revision snapshots of `SNAP_DATA` are
  restored on revert (verbatim); signed recovery "seed" systems with
  distinct Recover (data untouched), Factory reset (system data erased,
  `ubuntu-save` kept) and Install (everything erased) modes (verbatim)
  [S59].
- **X5 — Windows.** WinRE auto-entry after "Two consecutive failed
  attempts to start Windows" and after two unexpected shutdowns or
  reboots "within two minutes of boot completion" (verbatim); WinRE on a
  separate partition so it works when the Windows partition is encrypted
  (verbatim); Quick Machine Recovery fetches remediation over the network
  from WinRE [S60]. Distinct user options: go back (10 days, files kept),
  reset (keep/remove files), reinstall (files, apps, settings kept) [S60].
  Historical Last Known Good required a successful logon [S61].
- **X6 — macOS.** Paired and fallback recoveryOS; fallback cannot
  downgrade security state (snippet-level); SSV seal failure halts boot
  and prompts reinstall; reinstall "doesn't remove your apps or personal
  data" (verbatim) [S62].
- **X7 — data cannot always go backwards.** Android `SQLiteOpenHelper`
  default rejects downgrades [S66]; Chrome snapshots user data at each
  major update and users without sync "lose data … between the latest
  version update and rollback" (verbatim) [S63]; Firefox warns that an
  older version "can corrupt bookmarks" (Tier 2) [S64]; PostgreSQL blocks
  data directories of an incompatible major version (verbatim) [S65].
- **X8 — loop prevention is poorly documented on-device** in every
  precedent reviewed (UNVERIFIED throughout); FCOS/Zincati document only
  "other than the one you just reverted" [S48].

## Hypotheses

- **HY1:** Fedora GRUB with greenboot-rs's `boot_counter` fragment can
  provide automatic fallback on a bootc (OSTree backend) Eldora image
  (P-07, P-08).
- **HY2:** OSTree `boot-counting-tries` BLS counters are not honoured by
  Fedora GRUB (P-07; RES-0006 H2).
- **HY3:** With default `panic=0`, a kernel panic in the new deployment
  hangs indefinitely and consumes no further attempt (P-26).
- **HY4:** Staging a new target while the booted deployment is not yet
  known-good evicts the last known-good deployment unless it is pinned
  (P-28).
- **HY5:** A failed boot of deployment B leaves no durable evidence
  readable from A when the failure occurs before `/var` is mounted and
  the journal flushed (P-32).
- **HY6:** `ostree admin pin` protects a deployment on a bootc-managed
  sysroot across `bootc upgrade`/`rollback` and GC (P-28).

## Part 1 — Fundamental model: BOOTED ≠ HEALTHY ≠ KNOWN_GOOD

### Testing the proposition

**Result: SUPPORTED** (FACT U1, U7, Y1–Y4, G1–G2; X1–X3). Upstream
already separates three different facts, none of which is the next one:

- *the loader started an entry* (BLS counters, GRUB `boot_counter`) —
  a statement about an **attempt**;
- *userspace reached a milestone* (`status.booted` = digest;
  `boot-complete.target`; Fedora's 2-minute session timer) — a statement
  about **one boot**;
- *the system is working as intended* — **not provided upstream** for
  bootc (U1); precedents define it separately and later (Android
  post-reboot checks, ChromeOS timer, Mender commit, RAUC "fully
  started") (X1–X3).

Every precedent that advances anti-rollback or ends its rollback window
does so at the third, not the first, point (X1, X2; RES-0007 F8).

### Refined definitions (INFERENCE / proposal, not final names)

The brief's definitions are **necessary but not sufficient**. Three
refinements are needed:

1. **Scope.** BOOTED and HEALTHY are properties of **a boot** of a
   deployment (they can differ between two boots of the same
   deployment); KNOWN_GOOD is a durable property of **a deployment**
   (identified by manifest digest and OSTree checksum/serial) on **this
   machine**; SUPPRESSED and FORBIDDEN are properties of **a target**
   (digest + signed version) independent of any deployment on disk.
2. **Evidence, not assertion.** Each category is backed by recorded
   evidence (what was checked, when, by which component, in which boot
   ID), so that the state can be explained after a rollback (Part 28)
   and re-evaluated.
3. **History vs current eligibility** (Project Owner correction A1).
   BOOTED/HEALTHY are recomputed each boot. KNOWN_GOOD is **historical
   evidence**: "at a recorded point in time, this deployment satisfied
   Eldora's known-good evidence criteria on this machine". That fact is
   never erased or rewritten; it remains available for audit,
   diagnostics and recovery reasoning. It is **not** a security
   attestation. What later conditions change is the deployment's
   **current eligibility** (e.g. for automatic selection as a rollback
   target), not its history: (a) a later locally observed critical
   regression of the same deployment on the same hardware (delayed
   failure) can make it unsuitable for automatic selection; (b) a signed
   security statement can make it FORBIDDEN (Part 26); (c) hardware or
   persistent-state changes can make it no longer currently usable.
   None of these deletes the deployment by itself. No production state
   machine or API is implied.

| Category | Scope | Meaning (proposal) | Established by | Upstream signal |
|---|---|---|---|---|
| STAGED | deployment | Target fetched, verified, eligible (RES-0007 R-P2), deployment created, intent recorded (RES-0006 Part 5 §7) | Eldora supervisor + bootc | `status.staged` (RES-0006 Part 3) |
| FINALIZED | deployment | `/etc` merge and atomic boot-config swap completed during shutdown | OSTree | none positive; failure stamp by contract (U7); silent in the RISK-0010 path |
| BOOTED | boot | The recorded target is the booted deployment (`status.booted` digest = intent) and userspace reached a defined early milestone | Eldora, from bootc status + boot ID | `status.booted` |
| HEALTH_PENDING (added) | boot | BOOTED; health evaluation running; attempt still open | Eldora | none |
| HEALTHY | boot | All **critical** health conditions (Part 4) passed in this boot | privileged Eldora health evaluation | `boot-complete.target` if used (Y1) |
| DEGRADED | boot | Critical conditions pass; one or more degraded-class conditions fail | Eldora | none |
| FAILED | boot | A critical condition failed, or the boot never reached HEALTHY (hang, panic, timeout) | Eldora (if running) or inferred from an unconsumed attempt | loader counter at zero; GRUB `boot_success` unset |
| KNOWN_GOOD | deployment | Historical fact: at a recorded time the deployment satisfied the known-good evidence criteria of Part 7 on this machine; current eligibility is evaluated separately (A1) | Eldora, privileged | none |
| ROLLBACK_REQUESTED | machine | A rollback decision exists (automatic or owner) and is recorded with its reason | Eldora or owner | `rollbackQueued` (U2) |
| ROLLED_BACK | machine | Booted deployment is the former rollback **because of** a recorded rollback decision | Eldora (intent vs `status.booted`) | derivable only (RES-0006 Part 3) |
| RECOVERY_REQUIRED | machine | No eligible deployment can reach HEALTHY, or a condition exists that deployment rollback cannot fix (Parts 18–23) | Eldora or recovery path | none |
| SUPPRESSED (added) | target | A target that failed here is not automatically re-applied (Part 11) | Eldora | none |
| FORBIDDEN (added) | target / deployment | Below a signed security floor (epoch / min-version) (Part 26) | signed metadata (RES-0007 R-F1) | none |

INFERENCE: HEALTHY is the right point to **end the loader-level attempt**
(clear counters: "this deployment boots and works minimally");
KNOWN_GOOD is the right point to **end the rollback-candidate window**
(advance the floor, allow destructive/contract state-migration steps
that break rollback compatibility, allow eviction of the previous
known-good). Before KNOWN_GOOD, state may still evolve, but only without
destroying rollback compatibility (Project Owner correction A4; Part 16). Merging the two either makes rollback too
eager (clearing counters late turns ordinary user reboots into
rollbacks — Part 10) or too weak (advancing the floor at first health —
Part 13).

### Is KNOWN_GOOD immediate, time-, session-, explicit-, hybrid- or workload-based?

Not selected (Part 7 compares). Structural finding: KNOWN_GOOD must be
**profile-sensitive** (interactive desktop vs headless/unattended vs
managed) because evidence of "a usable local session" exists only on
interactive profiles, and it must never *require* network access or
user presence to be reachable (Parts 7, 29).

## Part 2 — Upstream capability map

| Capability | Classification | Basis |
|---|---|---|
| Deployment rollback (entry reorder) | UPSTREAM PROVIDES | U2 |
| Automatic rollback | UPSTREAM PARTIALLY PROVIDES (greenboot-rs + GRUB counter, bootc support UNVERIFIED; systemd ABA with systemd-boot only); ELDORA MUST DEFINE policy | U1, G3, G6, Y1–Y3 |
| Boot counting (loader) | UPSTREAM PARTIALLY PROVIDES: systemd-boot/BLS (with bootc: composefs backend only, not yet configured); Fedora GRUB `boot_counter` (inert unless armed) | U6, G3, G4, Y3 |
| Boot success marking | UPSTREAM PARTIALLY PROVIDES: `boot-complete.target` + bless-boot (systemd-boot); Fedora GRUB `boot_success` (user-settable; menu only) | Y1–Y3, G1–G2 |
| Health checks | UPSTREAM PARTIALLY PROVIDES (framework only: `boot-complete.target`, greenboot `required.d`/`wanted.d`); ELDORA MUST DEFINE the health model | Y2, G6 |
| Known-good | ELDORA MUST DEFINE; ELDORA MUST IMPLEMENT LATER | U1; RES-0006 Part 6 |
| Deployment pinning | UPSTREAM PROVIDES (OSTree `admin pin`); no bootc verb → ELDORA MUST IMPLEMENT LATER (integration) | U5 |
| Deployment retention count | UPSTREAM PARTIALLY PROVIDES (fixed default 2 + pins + retain flags); ELDORA MUST DEFINE semantics | U4 |
| Boot selection (menu, one-shot menu) | UPSTREAM PROVIDES (GRUB menu, `menu_show_once`, `systemctl reboot --boot-loader-menu`) | G1–G2 [S36] |
| Failure detection — finalization | UPSTREAM PROVIDES (contract); fails in the RISK-0010 path | U7; RES-0006 Part 5 |
| Failure detection — boot hang / panic | UPSTREAM PARTIALLY PROVIDES (`panic=`, watchdog, `rd.emergency=reboot`, `JobTimeoutAction=`) — **not enabled by default** | Y5, Y6 |
| Emergency / rescue targets | UPSTREAM PROVIDES (interactive) | Y5 |
| Crash evidence | UPSTREAM PARTIALLY PROVIDES (persistent journal, pstore service); EFI pstore backend and kdump off by default | Y7 |
| Lost-update detection | ELDORA MUST DEFINE / IMPLEMENT LATER | RES-0006 Part 5 §7 |
| Loop suppression | ELDORA MUST DEFINE; ELDORA MUST IMPLEMENT LATER | U2, G9, X8 |
| Anti-rollback floor | ELDORA MUST DEFINE (RES-0007 Part 16 + Part 13 here) | RES-0007 F1 |
| ESP / boot-chain update | UPSTREAM PROVIDES (bootupd; atomic per ESP on UEFI) | U11 |
| ESP / boot-chain rollback | **not provided** (bootupd #440 open; SBAT forbids generation resets by design) → ELDORA MUST DEFINE policy; 0.1D | U11, G7 |
| Shim fallback / NVRAM entry repair | UPSTREAM PROVIDES (`fbx64.efi`) | G7 |
| `/etc` per-deployment snapshot | UPSTREAM PROVIDES (OSTree); ELDORA MUST DEFINE explanation/diagnostics | U3 |
| `/var` state compatibility | ELDORA MUST DEFINE (contract); FUTURE APP MODEL | U8 |
| Factory reset | UPSTREAM PARTIALLY PROVIDES (systemd factory reset, per-partition opt-in; bootc `install reset` experimental) | U9, Y8 |
| Recovery environment | UPSTREAM PARTIALLY PROVIDES (installer rescue on non-Live media; firmware menu; extra stateroot possible) → ELDORA MUST DEFINE; 0.1D | G8, U9 |
| Owner override primitives (menu, pin, rollback) | UPSTREAM PROVIDES primitives; ELDORA MUST DEFINE semantics and audit | U2, U5, Y3 |
| Remote telemetry | OUT OF SCOPE (not required) | Part 29 |
| systemd-boot / UKI / sysupdate | OUT OF SCOPE for selection here (0.1D); relevant alternative path | U6, Y11 |

greenboot is **not selected**; it is the closest upstream building block
and remains a probe subject (P-08).

## Part 3 — Health domains

Columns: **Measurable** (what can be observed; no probe designed);
**Mandatory?** (candidate class; Part 4); **HW-dep** (hardware
dependence); **Must not block KG** (conditions that must never alone
prevent known-good); **FP** (healthy system judged failed); **FN**
(broken system judged healthy).

| Domain | Measurable | Mandatory? (candidate) | HW-dep | Must not block KG | FP risks | FN risks |
|---|---|---|---|---|---|---|
| H-BOOT | switch-root reached; `sysinit.target` reached; booted digest = intent; no `emergency.target` | **CRITICAL** | low (firmware, storage controllers) | — | slow storage timeouts; firmware glitch after power loss | a boot that "reaches userspace" with half the system missing |
| H-SYSTEM | a defined, small set of Eldora-critical units active (not "any failed unit", Y4) | **CRITICAL** for an allow-listed set | medium | optional or third-party units; units failing identically on the previous known-good | one flaky non-critical unit; start-rate races | a critical unit "active" but non-functional |
| H-GRAPHICS | display manager started; greeter/compositor presented a frame (interactive profiles only) | **CRITICAL for the basic graphical session on an interactive profile that promises one, even on first install** (A3); regressions of further capabilities (acceleration, displays) judged against the previous KG; n/a headless | **high** (GPU, driver, firmware) | missing secondary monitor; non-default GPU; headless profile | driver races; absent external monitor; slow first-boot shader compilation | software-rendering fallback reported as success |
| H-STORAGE | `/`, `/var`, `/var/home`, `/sysroot` mounted as expected (rw where expected); free space above floors; no filesystem errors at mount | **CRITICAL** (mount / rw); **DEGRADED** (low space) | medium (disk) | removable or optional data volumes | slow fsck; nearly full disk | silent corruption not visible at mount |
| H-NETWORK | NM state; connectivity FULL/LIMITED/PORTAL | **not critical by default**; critical only where a profile declares a network-dependent role | high (NIC, firmware) + environment | no connectivity; captive portal; no Wi-Fi on a wired desktop | environmental outage mistaken for regression (RES-0006 F19) | NIC up but DNS broken |
| H-SECURITY | Secure Boot state vs expectation; lockdown mode; SELinux mode; signature policy state; trust anchors readable | **CRITICAL only for invariants Eldora expects and can verify** (Part 26) | medium (firmware) | owner-chosen weaker configuration (explicit, recorded) | firmware reset clearing SB state; owner changes | a compromised deployment reporting itself compliant (Part 5) |
| H-UPDATE | booted = intended; no finalize-failure stamp; supervisor state readable; trust state and floor readable; `bootc status --json` parses | **CRITICAL** (the machine must remain updatable) | low | registry unreachable (environmental) | transient registry error during boot | update machinery present but unable to stage later |
| H-USER | a local user session started and lived for a period; session crash counts (interactive) | **evidence for KG on interactive profiles**, not a boot-critical gate | medium | no user logged in (unattended, lid closed, headless) | user logs out quickly | session alive but shell unusable |
| H-HARDWARE | kernel/driver probe errors vs the previous KG's recorded capability profile (Part 23) | **DEGRADED** by default; CRITICAL only for boot-essential devices (storage controller; display on interactive) | **total** | peripherals, Bluetooth, camera, fingerprint | intermittent hardware; unplugged devices | regression in rarely used hardware |

Key finding (INFERENCE): **health must be judged relative to this
machine's own previous known-good capability profile** in addition to
absolute rules. "Wi-Fi fails" is a regression only if Wi-Fi
worked on the previous known-good deployment on this hardware. This is
the main defence against both hardware-diverse false positives and
environment-caused rollbacks. First install has no baseline; there the
absolute critical set alone applies.

**Project Owner correction A3 — profile requirements are absolute; the
baseline is additional evidence.** The previous-known-good baseline
never replaces, and must never demote, a capability that is intrinsically
required by the selected machine profile. An interactive Eldora Desktop
profile that promises a usable graphical session may classify the basic
graphical-session capability as CRITICAL even on first install; a
managed kiosk profile may declare networking CRITICAL with no prior
baseline; a headless profile does not require graphics. The baseline is
used only to detect **additional** regressions and hardware-specific
expectations on top of the profile's absolute critical set.

## Part 4 — Critical vs degraded vs optional health

Alternatives (not selected):

| ID | Model | For | Against |
|---|---|---|---|
| CM-A | Any failed unit = failure (Y4 style) | trivial | FP-heavy; one optional service triggers destructive action |
| CM-B | Fixed critical allow-list; all else informational | predictable, auditable | misses regressions outside the list |
| CM-C | Three classes CRITICAL / DEGRADED / OPTIONAL with fixed membership | explicit semantics per class | membership disputes; hardware diversity |
| CM-D | CM-C (absolute, profile-defined critical set) + **additional regression detection relative to the previous known-good capability profile** | resists hardware and environment FPs; catches regressions | needs a recorded baseline for the additional part; none on first install |
| CM-E | CM-D + owner/admin-declared role requirements (e.g. "network required" for a kiosk) | fits managed and headless | configuration surface |

Candidate semantics (RECOMMENDATION: CM-D, with CM-E as extension):

- **CRITICAL** failure ⇒ boot FAILED; eligible for automatic rollback
  only under the conditions of Part 9.
- **DEGRADED** failure ⇒ boot HEALTHY-but-DEGRADED; **no automatic
  rollback**; KNOWN_GOOD deferred if the degradation is a regression
  versus the previous known-good profile; owner informed and may roll
  back.
- **OPTIONAL** capability failure ⇒ recorded only; never blocks
  KNOWN_GOOD; never triggers rollback.

Brief examples (candidate classification; INFERENCE):

| Situation | Class | Rationale |
|---|---|---|
| No Wi-Fi on a desktop with Ethernet | OPTIONAL (DEGRADED if Wi-Fi was in use on the previous KG) | environment/role dependent |
| No Bluetooth | OPTIONAL (DEGRADED if regression) | peripheral |
| PipeWire failure | DEGRADED on interactive profiles (regression ⇒ defer KG) | usable system without audio; rollback not warranted automatically |
| Graphical login unavailable (interactive) | CRITICAL on a profile that promises a usable graphical session, including on first install (A3); loss of further graphics capabilities (e.g. acceleration) is CRITICAL or DEGRADED according to the previous-KG baseline | most likely desktop regression class; strongly hardware-dependent (RISK-0002) |
| One optional service failed | OPTIONAL | Y4 warning against "any failed unit" |
| Update service failed (supervisor unusable, status unreadable, trust state unreadable) | CRITICAL (H-UPDATE) | a deployment that cannot update cannot repair itself |
| Secure Boot expectation violated | not uniformly CRITICAL; usually SECURITY_DEGRADED + owner decision; rollback does not change firmware state (Part 26) | firmware state is shared by all deployments |
| Disk unexpectedly mounted read-only | CRITICAL for `/var`/`/sysroot`, but rollback usually does **not** help (shared filesystem) ⇒ RECOVERY_REQUIRED / hardware suspicion (Part 23) | shared state |

Principle (candidate R-HM2): **no single non-critical condition may cause
automatic or destructive action**; automatic rollback is reserved for
CRITICAL failures attributable to the deployment (Part 9).

## Part 5 — Health-signal trust

| Declarer | Unprivileged spoofing | Broken/compromised new deployment self-marks KG | Health service itself broken | Crash before marking |
|---|---|---|---|---|
| One health daemon (root) | not possible if its interface is authorised (Y10 precedent) | **possible** (the daemon is part of the image under test) | no mark ⇒ attempt stays open (fail-safe) | attempt stays open |
| systemd target (`boot-complete.target`) | not possible (`manage-units` = auth_admin, Y10) | possible (same image) | target not reached ⇒ fail-safe | fail-safe |
| Multiple independent checks | as above | harder (several checks must lie), not prevented | partial | fail-safe |
| Signed local state | a signature protects origin, not truth; a key in the same deployment gives no gain against self-marking | possible | — | — |
| Privileged supervisor | not possible | possible | fail-safe | fail-safe |
| Bootloader success marker (GRUB `boot_success`) | **POSSIBLE today**: setuid `grub2-set-bootflag` lets any logged-in user set it (G1, G5) | possible | n/a | fail-safe |
| User-session confirmation | possible for the user, by definition | — | — | — |
| Hybrid: privileged evaluator; session evidence as input only | not possible for the decision; user evidence cannot alone reach KG | possible (inherent) | fail-safe | fail-safe |

Findings:

1. **Unprivileged spoofing (T-R1)** is prevented only if the health
   decision is taken by a privileged component and user-session inputs
   are *evidence*, never *the decision*. Fedora's GRUB `boot_success`
   flag must **not** be reused as an Eldora health or known-good signal
   (candidate RC-T). A second-order issue: an active local user can
   reboot (Y10), consuming loader attempts; attempts must be cleared at
   HEALTHY, not at KNOWN_GOOD, so a user cannot force a rollback by
   rebooting a healthy system (Part 10).
2. **Self-assessment is inherent (T-R2).** Any evaluator runs inside the
   booted deployment; a compromised or buggy deployment running as root
   can mark itself known-good. INFERENCE: KNOWN_GOOD can only mean "not
   observed to be broken on this machine" — a reliability signal, **not**
   an integrity attestation. Integrity belongs to Secure Boot, image
   signatures, trust/freshness metadata and runtime sealing (RES-0007
   Part 11).
3. **Fail-safe direction.** Absence of a positive mark means "not yet
   healthy" (attempt open), never "healthy". A broken health service
   therefore behaves as a failed boot of that deployment — correct,
   because the health service is part of the image under test. Cost: a
   bug in the evaluator causes a correct-but-avoidable rollback;
   mitigated by a small critical set (Part 4) and CI (0.1D).
4. **Crash before marking** leaves the attempt open; the next loader run
   counts it (Part 10).

## Part 6 — Transport independence of the health decision

Fedora provides two unrelated "success" notions: GRUB `boot_success`
(user timer, menu hiding; G1–G2) and systemd `boot-complete.target`
(bless-boot; effective only with systemd-boot; Y1–Y3). Neither is a
health model; both are **transports** for a decision Eldora must make.
Candidate R-HM1: Eldora's health decision is defined independently of
the loader mechanism that consumes it, so that 0.1D may choose GRUB with
an armed counter, systemd-boot with BLS counting, or another path without
changing semantics. The `boot-complete.target` ordering pattern (Y2) is a
suitable integration point in either case (INFERENCE).

## Part 7 — Known-good semantics (mandatory decision input; HC-1)

| Model | Desktop | Headless | Laptop | Offline | Unattended | Regression detection | False rollback | Delayed failures |
|---|---|---|---|---|---|---|---|---|
| KG-A first successful boot | + fast | + | + | + | + | **poor** | low | **missed** |
| KG-B critical health pass | + | + | + | + | + | medium | low–medium | missed |
| KG-C health + minimum dwell (accumulated healthy uptime) | + | + | ± (use accumulated uptime, not wall time) | + | + | good for crashes, leaks, late failures | low | partly caught |
| KG-D health + successful user session | **+** | **never reached** | + | + | **never reached** | good for desktop regressions | low | partly |
| KG-E explicit user confirmation | − prompts; users click through | n/a | − | + | **never reached** | user-dependent | low | — |
| KG-F multi-boot confidence (≥ k clean boots) | ± users rarely reboot | + | ± | + | ± | good for boot-path regressions | low | caught across reboots |
| KG-G hybrid | + | + | + | + | + | best | low | best |

Candidate hybrid (RECOMMENDATION for a later ADR; **no parameter
selected**):

- **Necessary in every profile:** at least one boot of the deployment
  reached HEALTHY (critical set, Part 4), **and** an accumulated healthy
  runtime ("dwell") elapsed without a critical failure or crash loop.
  Dwell is accumulated monotonic uptime across boots of that deployment
  (clock-independent; suspend does not count as uptime — INFERENCE), so
  offline, clockless and laptop use are covered.
- **Additionally on interactive profiles:** evidence that a local user
  session started and was not in a crash loop (H-USER), with a bounded
  fallback so that a machine nobody logs into still reaches KNOWN_GOOD
  on system-only evidence after a longer dwell (unattended machines must
  not be starved of a known-good point).
- **Multi-boot evidence** is *preferred but not required*: a second
  HEALTHY boot within the window strengthens evidence; requiring it would
  leave rarely rebooted machines without a known-good point.
- **Owner override / owner acceptance** (Project Owner correction A2)
  is not a way to reach KNOWN_GOOD. The owner may keep using, retry or
  explicitly accept a deployment (Part 27), but this is recorded as an
  explicit, local, logged **owner acceptance**, distinct from — and never
  substituting for — the ordinary known-good evidence used by vendor
  policy. It does not by itself advance the vendor high-water floor and
  does not clear FORBIDDEN. No production state name is selected.
- **Workload sensitivity** (managed/kiosk) is an extension via
  admin-declared role checks (CM-E).
- **No network requirement** in any profile (Part 29).

Evidence required before the anti-rollback floor may advance (HC-1;
input to Part 13): KNOWN_GOOD as above **and** the target was accepted as
an Eldora-authorised target under the trust/freshness rules of RES-0007
(R-F1). INFERENCE: an owner-installed local or owner-downgraded image
must not move the *vendor* floor (Part 13).

## Part 8 — Update success semantics (HC-6)

"When is an Eldora OS update actually successful?" — **when the target
deployment is KNOWN_GOOD on this machine** (INFERENCE; precedents X1–X3).

| State | May be presented as | Must **not** be presented as |
|---|---|---|
| downloaded / verified | "update downloaded" | installed, successful |
| staged | "ready to restart" (only with RES-0007 pre-restart conditions) | installed, successful |
| finalized | (internal) | successful — RISK-0010 shows finalization can silently fail |
| booted | "update installed — checking" | successful (RISK-0013) |
| healthy | "update installed and working" (UX reassurance) | known-good for **policy**: floor, retention, rollback-compatibility-breaking migration steps and loop state must not act on it |
| known-good | "update successful" (UX and policy) | — |
| failed / rolled back | "update failed; previous system restored", with reason | silent |

Candidate R-KG3: policy engines (floor advancement, retention/eviction of
the previous known-good, loop-suppression clearing, and state-migration
steps that destroy rollback compatibility) act only on KNOWN_GOOD;
migrations needed for operation may run earlier if they preserve
rollback compatibility (A4). Candidate R-KG4: "update successful"
is reserved for KNOWN_GOOD; earlier states are never reported to users or
to policy as success.

## Part 9 — Automatic rollback

| Trigger | Reliability of detection | False-positive risk | Observability after the fact | Upstream support | Eldora responsibility |
|---|---|---|---|---|---|
| Boot failure (never reaches userspace) | high **only if** the attempt ends (panic reboot / watchdog / non-interactive emergency action); otherwise the machine hangs (Y6) | low | poor: early failures leave no durable log (Y7) | loader counters (systemd-boot BLS; GRUB `boot_counter` if armed) | arm counting; make failed boots terminate (P-26); record intent to explain afterwards |
| Repeated boot failure | high once attempts terminate | low | counter + recorded intent | as above | attempt budget (Part 10) |
| Health-check failure (critical) | medium–high (depends on check quality) | medium | good if recorded in `/var` before reboot | `boot-complete.target` / greenboot `required.d` | critical set; regression baseline (Parts 3–4) |
| Critical service failure | medium | medium (flaky units) | good | `FailureAction=`/`OnFailure=` (Y5) | only allow-listed units; not "any failed unit" |
| Graphical-session failure | medium (hardware-dependent) | **high** (drivers, monitors, first-boot) | good | none (GRUB timer is menu-only) | only as regression vs previous KG on same hardware; else owner decision |
| Watchdog / crash loop | high for hard hangs (hardware watchdog); medium for crash loops | low–medium | pstore if enabled; journal if flushed | watchdog off by default (Y6) | decide whether to enable (0.1D/hardware); crash-loop threshold |
| Explicit user action | certain | none | recorded | `bootc rollback`, boot menu | record reason; loop suppression |
| Timeout before known-good | n/a — expiry of the dwell window is not a failure | **high** if treated as failure | — | — | must **not** trigger rollback; only withhold KG |
| Security invariant failure | varies (Part 26) | medium | recorded | Secure Boot/lockdown observable | classify; rarely fixable by deployment rollback |

Findings (INFERENCE):

1. **Not every health failure should cause rollback.** Automatic rollback
   is appropriate only when (a) the failure is CRITICAL, (b) it is
   attributable to the deployment (regression relative to the previous
   KG on the same hardware, or boot failure), (c) the rollback target is
   eligible (retained, KNOWN_GOOD, not FORBIDDEN — Part 12), and (d)
   rollback is expected to help (not shared-state or boot-chain or
   hardware failures — Parts 18–23).
2. **Automatic rollback must not occur** (candidate R-RB2) when: the
   failure is environmental (network, captive portal, peripheral);
   degraded or optional; in shared state (`/var` read-only, disk
   errors, full disk); in the boot chain or firmware; a security
   invariant that rollback cannot restore; the target deployment is
   FORBIDDEN or not KNOWN_GOOD (unless the owner chooses); the owner has
   disabled automatic rollback; or the machine has already rolled back
   once for the same attempt (no ping-pong, Part 11).
3. **Automatic rollback is a boot-time action, not a runtime action**:
   after KNOWN_GOOD, later regressions become owner decisions (with
   evidence), not automatic rollbacks — otherwise a late, unrelated
   failure could revert a deployment that already advanced the floor and
   ran irreversible migrations (Parts 13, 16). Precedents end automatic
   rollback at the success mark (X1–X3).

## Part 10 — Boot counting / attempt budget

| Question | Finding |
|---|---|
| Should a new deployment get N attempts? | Yes, a small budget (INFERENCE; precedents: snapd effectively 1, systemd examples and greenboot default 3, ChromeOS historically 6 — X2, X4, G6, Y1). **N not selected**; evidence from P-07/P-08/P-25 required. |
| What constitutes an attempt? | Loader-level: the loader selecting the entry for a full firmware boot (Y1: decrement "before" booting). Eldora-level: a boot ID of the deployment that has not reached HEALTHY. They should normally coincide. |
| User-requested reboot | Counts at loader level if it happens **before** HEALTHY (counter not yet cleared). Clearing counters at HEALTHY (not KG) prevents normal reboots of a working system from consuming the budget (Part 5). |
| Power loss | Counts (unavoidable at loader level). Eldora can annotate it (no clean shutdown record) but must not refund it automatically, since a hang is indistinguishable from power loss without hardware evidence. |
| Kernel panic | Counts **only if** the machine reboots (`panic=N` or watchdog). With Fedora's default `panic=0`, the machine hangs (Y6) — attempts stall (candidate RC-U). |
| Suspend / resume | Not an attempt (no loader run). Suspend during the health window must not count as failure; dwell uses accumulated uptime. |
| Soft-reboot | Not a loader attempt (Y9). Eldora must decide whether a soft-reboot into the *same* deployment is a new boot for health purposes (INFERENCE: yes for health evaluation; no for the loader budget). Soft-reboot into a new deployment is outside the counter entirely — P-16/P-25. |
| When is the counter cleared? | At HEALTHY (end of loader-level risk). KNOWN_GOOD is tracked separately by Eldora. |
| Where can the counter live? | BLS file names on `/boot` or ESP (systemd-boot); GRUB env block (`grubenv`, on `/boot` or ESP) for Fedora GRUB; neither in `/var` (the loader cannot read it). **Both locations depend on a writable `/boot`/ESP at runtime — the same mount-ownership problem as RISK-0010** (INFERENCE). Eldora's explanatory attempt record lives in `/var` (shared across deployments; not in per-deployment `/etc`). |
| Bootloader state vs OS state disagree | Loader state is authoritative for *selection*; Eldora's record is authoritative for *explanation*. On each boot Eldora reconciles: booted = intended ⇒ attempt continues; booted = previous and counter exhausted ⇒ AUTOMATIC ROLLBACK (loader) recorded; booted = previous with a recorded owner choice ⇒ ROLLED_BACK (owner); booted = previous with neither ⇒ LOST UPDATE or unexplained, classify from previous-boot journal (RES-0006 Part 5 §7). |

Additional findings:

- GRUB's Fedora fallback selects `default=1` (the **second** entry) when
  the counter expires (G3). That is only correct if entry 1 is the
  intended rollback target; pinned or extra deployments change the
  menu order (INFERENCE; candidate RC-Z, P-28).
- Counters are not selected-for-security: an attacker with root can
  rewrite them; the attempt budget is a reliability mechanism (Part 30).
- CVE-2024-1048 shows the flag-writing path is itself an attack surface
  on `/boot` (G5).

## Part 11 — Rollback loop prevention (HC-3; RISK-0015)

Model: A known-good → B staged → B fails → rollback to A → automatic
policy sees B still offered → B again → failure → …

| Mechanism | Prevents loop? | Offline? | Lifts when | Weakness |
|---|---|---|---|---|
| Digest suppression | yes for the same bytes | yes | never automatically | a re-signed/rebuilt identical release has a new digest (re-offered) |
| Release/version suppression (signed version) | yes for the same release | yes | a strictly newer version is offered | needs signed versions (RES-0007 R-F1, HD-8) |
| Failure counter per target | bounds retries | yes | — | still retries |
| Quarantine (explicit state) | yes | yes | owner action or newer version | needs UX |
| Explicit reauthorization | yes | yes | owner | burdens owner |
| Metadata revocation / withdrawal (server) | yes, fleet-wide | **no** | publisher | needs connectivity; not for local-only failures (hardware-specific regressions) |
| Retry budget with classification | allows one retry if failure was plausibly transient (power loss during window) | yes | — | classification uncertainty |

Candidate model (RECOMMENDATION): a local **SUPPRESSED** record keyed by
**signed release version and digest** (both), with failure class,
attempt count and evidence; automatic policy never re-applies a
suppressed target; suppression lifts only when (a) a strictly newer
authorised version is offered, or (b) the owner explicitly retries
(logged). A publisher-side withdrawal complements it but is not
required. A single automatic retry may be allowed only when the failure
class is "indeterminate" (e.g. power loss during the health window) —
not selected. FCOS precedent: "other than the one you just reverted"
(G9).

State that must persist across rollback (candidate R-LP2): suppressed
targets; attempt records and failure classes; rollback reason; the
intent record; the floor(s) and known-good history. **It must live
outside per-deployment `/etc`** (which rolls back — U3) and outside
`/boot` (RISK-0010); `/var` is the natural location, with the caveat
that `/var` is writable by the failed deployment (Part 30, T-R3).

## Part 12 — Rollback vs anti-rollback (RES-0007 Part 16 reconciliation; HC-2)

Model under test: *the anti-rollback floor governs newly accepted
targets; already-retained, previously authorised deployments remain
eligible for local recovery.*

| Scenario | Result under the model | Contradiction / condition |
|---|---|---|
| Compromised old release (A later found compromised) | A remains locally bootable unless FORBIDDEN by a signed security epoch/min-version | **Condition:** security floor must be able to exclude retained deployments from *automatic* rollback (candidate R-FL2) |
| Newly discovered CVE in A | same as above; severity decides whether to forbid | owner may still choose A explicitly (owner authority), with warning |
| Emergency recovery (B broken, A below security floor) | automatic rollback to A **not allowed**; RECOVERY_REQUIRED; owner may explicitly select A as a logged recovery exception (Project Owner direction) | **CONTRADICTION**: security floor vs availability — resolved by Project Owner direction (below); RC-Y → RISK-0021 |
| Owner-requested downgrade (fetch an older release) | below floor ⇒ explicit local owner action only (RES-0007 R-A3); state warnings (Part 16) | consistent |
| Security epoch raised | forbids older targets and deployments for **automatic** use | consistent if epoch is separate from high-water mark (RES-0007 Part 16 §3) |
| Offline machine | cannot learn of new epochs; keeps using retained deployments | consistent; staleness must be visible (RES-0007 H5) |

**Project Owner direction on RC-Y (recorded 2026-09-26; ADR input, not
a finalized ADR).** If the active/new deployment fails and every retained
rollback deployment is below the signed security floor (FORBIDDEN for
automatic use): (1) Eldora must not automatically roll back below the
signed security floor; (2) the machine enters RECOVERY_REQUIRED at the
semantic level; (3) the legitimate local owner may explicitly choose a
retained FORBIDDEN deployment as a recovery exception; (4) that owner
action is local, explicit and logged, shows that the deployment is
security-forbidden/stale, does not lower or clear the vendor security
floor, does not clear the deployment's FORBIDDEN state, does not make it
normally eligible for automatic policy, and does not advance the vendor
high-water floor; (5) network metadata can never invoke this owner
exception; (6) recovery tooling continues to offer the verified
independent recovery path (A5) so the owner is not forced to choose the
vulnerable deployment.

Finding: the model is **consistent with conditions**. It needs three
separate notions: (1) the **high-water floor** (advanced at KG; governs
new targets); (2) the **security floor** (signed epoch/min-version;
governs automatic use of targets *and* retained deployments); (3) the
**owner's explicit choice** (may boot anything retained, logged). The
one real contradiction is RC-Y (registered as RISK-0021): a signed
security floor can leave no automatically eligible deployment; it is
resolved by the Project Owner direction above (RECOVERY_REQUIRED + an
explicit, logged owner recovery exception that leaves the floor and
FORBIDDEN state intact + the independent recovery path).

## Part 13 — Floor advancement (HC-1; RES-0007 R-A2)

| Advance at | For | Against |
|---|---|---|
| verification | earliest replay protection | a verified-but-unbootable B would forbid re-fetching A if A is lost (retention) |
| staging | — | same; plus staging can be discarded (RISK-0010/0012) |
| first boot | cheap | H1/H4 refuted: B may fail later; AVB precedent refuses |
| HEALTHY | better | still premature for delayed failures |
| KNOWN_GOOD | matches precedents (X1, RES-0007 F8); floor never exceeds what works here | replay window between staging and KG for *new* targets older than B but ≥ old floor |
| elapsed time | clock-dependent | offline/clock issues (RES-0007 Part 21) |
| server metadata change | fleet-coordinated | not local evidence; offline |
| hybrid | — | complexity |

Falsification of "the floor should advance only after KNOWN_GOOD":

- *Replay window.* Between staging B and B becoming KG, the floor is
  still A's version; a replay of a target older than B (but ≥ A) could
  be offered. Mitigation: the policy never automatically selects a
  target older than the **currently attempted** target (a separate,
  non-persistent-floor rule), and the signed channel metadata version
  (RES-0007 FM2) is monotonic independently of the floor. ⇒ the
  proposition survives **with** this condition.
- *Known-good later found dangerous.* The high-water floor never goes
  back down; danger is handled by the **security floor** forbidding B
  and a newer fixed C being offered. If no C exists yet, B remains
  booted (owner-visible warning). The floor semantics are not the right
  tool for this case. ⇒ survives.
- *KG never reached* (unattended starved, or perpetual degraded). The
  floor stalls; replay protection relative to A only. Mitigation: KG
  fallback path for unattended machines (Part 7). ⇒ survives with
  condition.
- *Owner-installed local images* must not raise the vendor floor
  (they are outside vendor versioning) (Part 7).

Result: **"advance only after KNOWN_GOOD" is SUPPORTED WITH CONDITIONS**
(no automatic selection below the current attempt; separate security
floor; KG reachable in all profiles). No final floor policy is defined
here.

## Part 14 — Deployment retention (HC-4)

Facts: default retention is two (booted + rollback), plus staged and
pinned; staging prunes the previous rollback (U4); no retention count
setting; pinning via OSTree only (U5); `/boot` early-prune can drop the
rollback kernel when `/boot` is small (U4, experimental).

Key hazard (INFERENCE; candidate RC-V; HY4): if B is booted but **not
yet KNOWN_GOOD** and C is staged, C becomes default, B becomes rollback,
and A — the last KNOWN_GOOD — is garbage-collected. A second update
before confidence can erase the last deployment known to work (RES-0007
Part 7 made the same observation).

Candidate semantic requirements (not a count):

- **R-RT1** Never garbage-collect or evict the last KNOWN_GOOD deployment
  merely to reclaim space or to stage; if necessary, refuse to stage and
  report why.
- **R-RT2** Do not stage a new target while the booted deployment is not
  KNOWN_GOOD unless the last KNOWN_GOOD is protected (pinned) — or the
  new target is a fix explicitly authorised for that situation (policy
  decision).
- **R-RT3** The protected set is at least {booted, last KNOWN_GOOD (if
  different), staged}; its size is not fixed here.
- **R-RT4** Pinning performed by Eldora is recorded with reason and
  released when a newer KNOWN_GOOD exists.
- Disk pressure: pinning a third deployment costs only the unique
  objects of that image plus its kernel/initramfs in `/boot`; size
  impact unmeasured (P-28). `/boot` capacity (0.1D) is the tighter
  constraint where `/boot` is separate (U4 early-prune).
- **Consequence tested:** "never GC the last KG" can block updates on a
  full disk — acceptable only if visible (RES-0007 R-P5-style state) and
  if the owner can explicitly release the pin (Part 27).

## Part 15 — `/etc` rollback semantics

OSTree owns `/etc` semantics (U3; RES-0006 Q13): per-deployment
snapshots; three-way merge at deployment creation; rollback selects the
old snapshot; later edits are hidden on rollback and return on
roll-forward.

| Case | Behaviour | What Eldora should explain / track (no redesign) |
|---|---|---|
| Bad local edit made on B | rollback to A hides it; roll-forward re-exposes it | record `/etc` diff (`ostree admin config-diff`) at KG and at failure; warn on roll-forward |
| Bad local edit made before A and B were created | present in **both** snapshots ⇒ rollback does not help (both-deployment failure cause) | classify as CONFIG failure ⇒ REPAIR (reset specific files to image defaults) |
| Update migration of image defaults | new defaults ignored where the owner modified the whole file (RES-0003 FS3) | drift report per deployment; P1–P2 principles |
| Rollback hiding an edit | owner surprise | explain on rollback |
| Roll-forward re-exposing an edit | owner surprise | explain on roll-forward |
| Admin configuration compatibility | an `/etc` file valid for A may be invalid for B | pre-flight compatibility is image-build/CI work (0.1D); runtime only reports |
| Recovery diagnostics | failed deployment's `/etc` is still on disk (in its deployment directory) | expose for inspection from A or recovery |

Candidate R-ST4: Eldora-owned state that must survive rollback (Part 11)
must not live in `/etc`. Transient `/etc` (U8) would change these
semantics and is a 0.1D/ADR topic, not evaluated here.

## Part 16 — `/var` and `$HOME` (RISK-0014; HC-5)

Model: B migrates S1 → S2; B fails; rollback to A; A reads S2. Facts:
`/var` and `/home` are never rolled back (U8; RES-0006 Part 8;
OBSERVED RES-0004 PB3 schema 2 remained); precedents show many programs
refuse or corrupt on downgrade (X7).

| State class | Typical owner | Risk after rollback | Candidate strategy |
|---|---|---|---|
| System service databases (`/var/lib/*`) | image components | older code fails or corrupts on newer schema | before KG only expand-style / backward-compatible changes readable by the retained rollback deployment; **destructive/contract steps only after KNOWN_GOOD** (A4) |
| Application state (Flatpak/containers, `/var/lib/flatpak`, `~/.var`) | apps (Q-0003) | app/runtime mismatch | application responsibility; app model requirement (Part 17) |
| System service state (NM connections, accounts, fwupd) | Fedora upstream components | mostly forward-compatible; unverified per component | inventory of image components that migrate state (0.1D/CI) |
| Caches | any | stale caches | safe to discard; must be marked discardable |
| Schema migrations | components | irreversible | versioned state + deferred contract step + pre-migration copy for Eldora components |
| User configuration (`$HOME`) | desktop, apps | newer profile seen by older desktop (OBSERVED no breakage in RES-0005 E4 checks, limited) | desktop components must tolerate N+1 config; no global rollback |
| Secrets (keyrings, TPM-bound) | system/user | TPM-sealed secrets bound to measurements may not unseal after rollback/boot-chain change (RES-0003 Q8 forwarded) | 0.1D/hardware; out of scope here beyond noting |
| Device state (firmware updated by fwupd) | firmware | **not reversible by OS rollback** | Part 23 |

Strategies compared:

| Strategy | Protects | Cost | V1 fit (INFERENCE) |
|---|---|---|---|
| Backwards-compatible migrations (N-1 reads N) | rollback by one release | engineering discipline | **required for Eldora components** |
| Two-phase: rollback-compatible (expand) steps before KG, destructive/contract steps after KG | whole rollback window | two-phase migrations | **strong** (uses KG, Part 1; A4) |
| Versioned state (per-version directories, snap-style) | clean revert | disk, copy time | selective (Eldora components) |
| Snapshot (filesystem-level, e.g. btrfs) | everything | filesystem choice (0.1D), space, restore semantics, secrets/log implications | **not justified as global V1 mechanism** (evidence: no upstream integration; conflicts with logs/evidence retention; restore ⇒ data loss per X7 Chrome) |
| Transactional state (UDC-style checkpoint) | pre-KG window | filesystem/dm support | later research |
| Recovery tooling (repair/reset per component) | last resort | per component | V1 desirable |
| Application responsibility | apps | app model | future app model |

Finding: **OS rollback is not sufficient when persistent state has
migrated** (H5 REFUTED). The minimum V1 mitigation is a **state
compatibility contract** for components shipped in the image (candidate
R-ST1..R-ST3) — not a global snapshot system.

**Project Owner correction A4 — the rule is "do not destroy rollback
compatibility before KNOWN_GOOD", not "no migration before KNOWN_GOOD".**
A new deployment may need to evolve state before it can operate, and
therefore before it can become known-good. Before KNOWN_GOOD, migrations
needed for operation must be additive/expand-style, backward-compatible
or otherwise safely readable by the retained rollback deployment. After
KNOWN_GOOD, destructive cleanup, contract steps or compatibility-breaking
irreversible migrations may occur according to the later
state-contract architecture. No migration engine is designed here.

## Part 17 — Application-model boundary (requirements for later waves)

Q-0003 is not decided; these are **requirements handed to Wave 0.3**,
not decisions:

- **AM-1** Application persistent state must tolerate the OS rolling
  back by at least one release (apps may run on an older OS than the one
  on which they last ran).
- **AM-2** Applications that migrate their own data must declare
  migrations and either keep them backward-compatible across the
  rollback window or defer rollback-compatibility-breaking steps until
  the OS deployment is known-good (analogous to R-ST1/R-ST2).
- **AM-3** Application data must be separate from system state and from
  the OS image (P6), so that OS repair/reset can preserve it.
- **AM-4** Application update/rollback is independent from OS rollback;
  an OS rollback must not implicitly roll back applications, and vice
  versa, unless the app model defines it.
- **AM-5** Data durability expectations (e.g. databases fsync) must hold
  across power loss during the health window.
- **AM-6** The app model must state what "rollback awareness" an app gets
  (e.g. a signal that the OS version decreased), if any.

## Part 18 — Boot-chain recovery (RISK-0011)

| Layer | Per deployment? | Recovered by OSTree deployment rollback? | Other recovery | Evidence |
|---|---|---|---|---|
| Firmware (UEFI) | no (machine) | **no** | vendor firmware recovery; owner/hardware domain | — |
| Secure Boot db/dbx/MOK, SbatLevel | no (NVRAM) | **no**; SBAT is monotonic by design | disable Secure Boot (owner); MokManager; newer shim | G7 |
| shim | no (ESP) | **no** ("Ignoring downgrade") | removable-media boot; firmware menu; reinstall ESP content from media | U11, G7; RES-0005 E3 |
| bootloader (GRUB EFI binary) | no (ESP) | **no** | same as shim | U11 |
| bootloader configuration — BLS entries | yes (one per deployment) | **yes** | — | RES-0006 L9 |
| bootloader configuration — grubenv / static config | no (shared) | **no** | reset env from recovery | G2–G3 |
| kernel | yes (in image) | **yes** | — | RES-0006 Part 8 |
| initramfs | yes (in image) | **yes** | — | RES-0006 Part 8 |
| deployment (`/usr`) | yes | **yes** | — | U2 |
| root filesystem / `/sysroot` / `/var` | no (shared) | **no** | fsck/repair from recovery; reinstall | U8 |

Findings: deployment rollback recovers kernel, initramfs, `/usr`, BLS
entry and the `/etc` snapshot choice; it recovers **nothing below the
bootloader configuration** and nothing in shared filesystems. A failed
shim/GRUB update makes **every** deployment unbootable (shared ESP) —
precisely the class that needs an independent path (Part 20). SBAT
additionally means that re-installing an *older* boot chain may be
impossible under Secure Boot (candidate RC-W); recovery must use a boot
chain at or above the machine's SBAT level. Boot-chain update policy and
A/B ESP (bootupd #440) belong to 0.1D (HD-type requirement, Part 38).

## Part 19 — Both deployments fail (RISK-0016)

| Cause | Does deployment rollback help? | Needed beyond rollback |
|---|---|---|
| Shared boot-chain damage (shim/GRUB/grubenv/ESP) | no | independent boot path (external verified media or firmware-level fallback), ESP repair |
| Hardware failure (disk, RAM, GPU) | no | hardware diagnosis; stop software rollback (Part 23) |
| Persistent-state corruption / forward-migrated `/var` incompatible with both | no | state repair/reset per component; data rescue |
| Incompatible firmware update (fwupd) | no | firmware domain; owner |
| Broken `/var` (full, read-only, corrupted) | no | fsck, cleanup, space reclaim from a context not dependent on `/var` |
| Local admin changes present in both `/etc` snapshots | no | `/etc` repair to image defaults (selective) |
| Disk corruption | no | recovery media; data rescue; reinstall |
| Both deployments individually bad (second update before KG evicted the good one) | no | prevented by retention rules (R-RT1/R-RT2) |

Finding (INFERENCE): **every** both-fail cause is outside what a second
or third deployment can fix, except the eviction case, which retention
rules prevent. Beyond deployment rollback Eldora needs: (1) a boot path
that does not depend on the installed ESP/boot chain and root
filesystem; (2) tools to inspect and repair shared state; (3) data
preservation/rescue before any destructive step; (4) a verified way to
reinstall the image. This is independent of whether an on-disk recovery
environment exists.

## Part 20 — Recovery environment alternatives (not selected)

| ID | Model | Independence from normal root | Boot-chain dependency | Offline | Disk cost | Updateability | Attack surface | Secure Boot | Owner control | Repair capability |
|---|---|---|---|---|---|---|---|---|---|---|
| R-A | No dedicated recovery (boot menu + pinned deployments + reinstall) | none | full | yes | none | n/a | minimal | as normal | high | low |
| R-B | Recovery deployment (pinned image / separate stateroot, U9) | partial: own `/usr`, own `/etc`/`/var` if separate stateroot; same `/sysroot` filesystem | **same ESP, shim, GRUB** | yes | one image's unique objects + `/boot` kernel | via same update chain | same as OS | same chain | high | medium (cannot fix ESP or filesystem it lives on) |
| R-C | Recovery partition/image (separate partition, own kernel/initrd) | high (separate fs) | **same ESP / shim / firmware** unless separate ESP entry path; SBAT-constrained | yes | fixed partition (layout decision, 0.1D) | separate update path (risk of staleness, SBAT drift) | extra signed image | must be signed and SBAT-current | medium | high |
| R-D | Installer / live-media recovery (verified external media) | **full** | **none on disk** (uses media's own shim/GRUB) | yes (once media exists) | none on disk | media refresh by owner; old media may fail SBAT (G7) | media provenance (T-R9) | media must be signed, SBAT-current | high | high |
| R-E | Network recovery (firmware/OS fetches a recovery image) | full | depends on firmware HTTP boot or an on-disk stub | **no** | small | server-side | server trust, privacy | needs signed chain | medium | high |
| R-F | Hybrid (e.g. R-B for fast local fix + R-D as independent floor) | combined | combined | yes | small | combined | combined | combined | high | high |

Findings (INFERENCE):

- Only **R-D** (and firmware-level R-E) is independent of the installed
  ESP/boot chain; R-B and R-C share the ESP and firmware, so they cannot
  recover the boot-chain failures of Part 18.
- R-B is cheap and uses mechanisms that exist (pinning, stateroots,
  U5, U9) but duplicates what a pinned known-good deployment already
  gives, unless it is a *minimal, separately stateful* recovery image.
- R-C adds a layout, update and SBAT-currency burden (0.1D) and still
  shares the ESP.
- R-E conflicts with "no cloud dependency for fundamental recovery"
  unless optional (Part 29); precedent exists (Windows QMR, macOS
  Internet Recovery — X5, X6).
- **Recommendation (not a decision):** V1 needs an **independent
  recovery path**; verified external media (R-D) is the lowest-cost
  path that is truly independent; whether V1 also ships an on-disk
  recovery (R-B/R-C/R-F) is a later ADR with 0.1D (layout, ESP, Secure
  Boot, installer). The evidence is **not overwhelming** for selecting
  any on-disk environment now.
- **Project Owner correction A5 (architectural direction, not a
  selected implementation):** V1 requires an independent, verified,
  offline-capable recovery path that can operate when both deployments
  fail, when the installed root/shared state is damaged, and when the
  installed ESP/boot chain cannot boot. Verified, SBAT-current external
  media is the **leading minimum-cost candidate** because it carries its
  own boot chain; it is **not** an accepted architecture. Whether V1
  additionally or alternatively uses an on-disk recovery deployment, a
  recovery partition, a hybrid or firmware/network recovery remains a
  0.1D-informed ADR decision.

## Part 21 — Recovery capabilities

| Capability | Class (candidate) | Note |
|---|---|---|
| Inspect deployments (status, KG history, failure reasons) | V1 REQUIRED | from `/var` records + bootc status |
| Select known-good / previous deployment | V1 REQUIRED | boot menu already allows; must be reachable without a working desktop |
| Repair bootloader / ESP (reinstall shim/GRUB from verified source) | V1 REQUIRED (via independent path) | SBAT-current binaries (Part 18) |
| Inspect logs (journal of failed boots, pstore) | V1 REQUIRED | Part 28 |
| Check filesystem | V1 REQUIRED | from outside the mounted root |
| Recover user data (copy `/var/home` to external storage) | V1 REQUIRED | before any destructive step |
| Reset system configuration (`/etc` to image defaults, selective) | V1 DESIRABLE | Part 15 |
| Reinstall system image (verified) | V1 REQUIRED | preserving `/home` where possible |
| Preserve `/home` | V1 REQUIRED default for non-destructive paths | Part 22 |
| Preserve or repair `/var` | V1 DESIRABLE | component-level repair (Part 16) |
| Network access in recovery | V1 DESIRABLE (optional) | privacy, Part 29 |
| Offline-capable, independent, verified recovery path | V1 REQUIRED (A5) | verified external media (R-D) is the leading implementation candidate, not yet an accepted architecture |
| Verify downloaded/media recovery artefacts | V1 REQUIRED | trust rules must not be bypassed (HC-8, Part 26) |
| Unlock encrypted storage in recovery | V1 REQUIRED if encryption is default (0.1D) | recovery keys; TPM interplay |
| Hardware diagnostics (disk SMART, memory test pointers) | LATER (pointer/advice V1 DESIRABLE) | Part 23 |
| Guided factory reset / reinstall UI | LATER (semantics V1) | no UI designed |

## Part 22 — Rollback, recovery, repair, reset, reinstall

| Operation | Meaning (proposal) | `/home` | `/var` | Machine identity (machine-id, host keys) | Secrets | Owner data | Logs | System configuration (`/etc`) |
|---|---|---|---|---|---|---|---|---|
| ROLLBACK | Boot a retained deployment | keep | keep (not reverted) | keep | keep | keep | keep | previous snapshot |
| RECOVERY | Bring the machine back to a bootable, known state by non-destructive means (select deployment, repair boot chain, fsck) | keep | keep | keep | keep | keep | keep | keep |
| REPAIR | Targeted fix of a component (ESP, `/etc` file, a service's state) | keep | targeted | keep | keep | keep | keep | targeted |
| RESET | Return system state to image defaults while keeping the OS | **decision required** (candidate default: keep, explicit option to erase) | reset (except logs/evidence if chosen) | **decision required** | **decision required** | keep unless erasure chosen | **decision required** | image defaults |
| REINSTALL | Deploy a verified image fresh | **decision required** (candidate: keep, explicit option to erase) | fresh or kept (decision) | decision required | decision required | decision required | decision required | image defaults |

All destructive defaults are **left for explicit Project Owner review**
(the brief forbids deciding them). Candidate R-RC3: any operation that
erases owner data requires explicit, local owner confirmation (Android
Rescue Party precedent X1; systemd factory reset opt-in per partition
Y8). Candidate R-RC4: before any destructive step, offer data rescue.
Note: bootc `install reset` (experimental) keeps the old stateroot on
disk — it is not an erasure (U9); secure erasure depends on encryption
design (RES-0003 AD6; 0.1D).

## Part 23 — Hardware failure boundary (T-R12)

Signals that point to hardware rather than to the deployment
(INFERENCE):

- the same failure occurs on the previous KNOWN_GOOD deployment (it
  worked before on this hardware and now fails too);
- filesystem/IO errors, SMART failures, ECC/MCE records, kernel oops in
  unrelated subsystems, random crashes across deployments;
- GPU initialisation failure on both deployments;
- power/battery instability (unexpected shutdowns with low battery).

Candidate rule (R-RB3): **stop automatic software rollback after one
automatic rollback per attempt** — if the rollback target also fails its
critical checks, do not ping-pong; enter RECOVERY_REQUIRED with a
"possible hardware or shared-state failure" classification.
Firmware regressions (fwupd) are not reverted by OS rollback and must be
recorded as their own event (Part 28). Precedents: Windows WinRE after
repeated failures (X5), Android Rescue Party escalation (X1).

## Part 24 — NVIDIA / third-party driver implications (RISK-0002)

Not solved here. Dependencies recorded (INFERENCE):

- **Health:** out-of-tree drivers are the most likely cause of
  H-GRAPHICS failure after a kernel change; the capability baseline
  must record which driver stack worked on the previous KG.
- **Known-good:** a deployment is KG *for this hardware*; a new kernel
  without a matching signed module is a predictable H-GRAPHICS
  regression; KG must not be granted on software-rendering fallback
  when the previous KG had hardware acceleration (DEGRADED).
- **Kernel transitions:** image-based delivery means modules must be
  built into the image or delivered in a way that matches the kernel
  (RES-0003 Q14 on-host kmod builds are M1-specific); coordination is
  0.1D/hardware-wave work.
- **Rollback:** kernel and in-image modules roll back together (good);
  DKMS-like host builds would not fit (RES-0003).
- **Secure Boot:** MOK-enrolled keys are firmware state (not rolled
  back); key rotation for third-party modules interacts with SBAT/MOK
  (G7).
- **Recovery:** recovery media must boot without the proprietary driver
  (basic display).
- Handed to PX3 and the hardware wave (Part 40).

## Part 25 — Interplay with lost updates (RISK-0010, RISK-0012)

The health model starts at BOOTED = intended target. If the intended
target is not booted and no rollback decision exists, the event is a
**LOST UPDATE** (RES-0006), not a rollback and not a health failure; it
must be classified before any health logic runs (candidate R-OB2). Loop
suppression must not suppress a target that was merely lost (it never
booted) — it should be re-staged, not quarantined (INFERENCE). Boot
counter storage on `/boot`/ESP shares the RISK-0010 mount-ownership
dependency (Part 10).

## Part 26 — Security failure semantics

| Failure | Rollback helps? | Candidate class | Rationale |
|---|---|---|---|
| Secure Boot unexpectedly disabled | no (firmware state) | SECURITY_DEGRADED + USER DECISION; not FAILED | owner may have disabled it; firmware reset possible; forcing rollback is pointless |
| Secure Boot enabled but expected signature verification unavailable (e.g. lockdown not `integrity`, module signature enforcement off) | maybe (if B's kernel config regressed) | FAILED if regression attributable to B; else SECURITY_DEGRADED | attributable vs environmental |
| Trust metadata corrupt (local) | no (shared `/var`) | RECOVERY of trust state (HC-7): re-derive from image-shipped anchors; never "trust anything"; updates blocked until restored | RES-0007 T13 |
| Security service fails (e.g. SELinux policy load failure, auditing) | yes if regression | FAILED (critical) when the service is in the critical set and it worked on the previous KG | attributable |
| Integrity expectation violated (composefs/fs-verity mismatch, image signature origin mismatch) | possibly (other deployment intact) | RECOVERY_REQUIRED + owner decision; do not auto-mark anything KG; evidence preserved | tampering vs corruption ambiguity |
| Booted deployment FORBIDDEN by new signed security floor | n/a | SECURITY_DEGRADED; update urgently; no automatic rollback to another FORBIDDEN deployment; if the booted deployment also fails and only FORBIDDEN targets remain ⇒ RECOVERY_REQUIRED with owner recovery exception (Project Owner direction, Part 12) | Part 12 |

Finding: security differences are **not identical**. Only regressions
attributable to the deployment are FAILED; firmware/environment changes
are owner-visible degradations; integrity violations are RECOVERY
situations requiring evidence preservation. HC-8: recovery entry points
must still verify artefacts (no "recovery bypasses trust").

## Part 27 — Owner override

| Override | Owner control | Security consequence | Recoverability | Auditability |
|---|---|---|---|---|
| Boot a quarantined (SUPPRESSED) deployment | full | none for third parties (local, explicit) | high | record event, reason |
| Retry a failed update | full | none | high (rollback still available if retention protected) | record |
| Downgrade (below floor) | full, explicit | weakens anti-rollback for this machine by owner choice | medium (state compatibility, Part 16) | record with warning shown |
| Disable automatic rollback | full | none for third parties; availability risk owner-chosen | lower | persistent visible state |
| Accept a deployment as usable (owner acceptance) | full | recorded as OWNER ACCEPTANCE, **not** as KNOWN_GOOD evidence (A2); does not by itself advance the vendor high-water floor; does not clear FORBIDDEN | medium | record |
| Select recovery target | full | none | high | record |
| Boot a FORBIDDEN deployment (recovery exception) | full, explicit, local | owner accepts known vulnerability; does not lower or clear the security floor, does not clear FORBIDDEN, does not make it normally eligible for automatic policy, does not advance the high-water floor; never invocable by network metadata (Project Owner direction on RC-Y, Part 12) | high | record, persistent warning that the deployment is security-forbidden/stale |

All overrides are **possible** for the legitimate owner (H8), through
explicit, local, logged actions, never through network data or
unprivileged requests (RES-0007 Part 4 boundary; R-P9). No "security
that overrides the legitimate owner" model is proposed. An override
changes what the owner chose to run; it never fabricates the evidence
that vendor policy relies on (KNOWN_GOOD, floor, FORBIDDEN) (A2).

## Part 28 — Observability (local)

Minimum durable evidence (candidate R-OB1), stored outside per-deployment
`/etc` and not dependent on `/boot` writes:

| Evidence | Why | Survives rollback? | Note |
|---|---|---|---|
| Intent record (target digest, version, serial, time, boot ID) | lost-update vs rollback classification | yes (`/var`) | RES-0006 |
| Attempt records per deployment (boot IDs, reached state, attempt count) | why rollback occurred; attempts | yes | reconciled with loader state |
| Health results per boot (which condition failed, class, baseline comparison) | which condition failed | yes if written before reboot; **no** if failure precedes `/var` | HY5 |
| Rollback records (automatic/owner/menu; reason; from/to) | why rollback occurred | yes | plus bootc `MESSAGE_ID` (U2) |
| Known-good history (deployment, time, evidence summary) | KG history | yes | |
| Suppression/quarantine records | loop prevention | yes | |
| Owner overrides | audit | yes | |
| Recovery actions (repair/reset/reinstall; who; what) | audit | yes if `/var` preserved; else on recovery media/log export | |
| Previous-boot journal; pstore records | failure cause | only if journal flushed / pstore enabled (Y7) | candidate RC-X |
| Firmware/ESP versions at each boot | boot-chain divergence | yes | bootupd status (RES-0006 Part 3) |

Logs inside the failed deployment: the journal is shared in `/var`, so
B's boot is visible from A **if** B reached journal flush (Y7); earlier
failures need pstore/kdump/serial or a loader-level record (INFERENCE,
P-32). No telemetry is designed.

## Part 29 — Privacy and local operation

Hypothesis "No health/known-good decision requires cloud connectivity" —
**attempted falsification:**

- *Security revocation (FORBIDDEN)* needs fresh signed metadata; an
  offline machine cannot learn it. This limits **security currency**,
  not the health/KG decision (RES-0007 H5).
- *Network-dependent roles* (kiosk/managed) may declare network health
  critical (CM-E) — local measurement, no cloud.
- *Network recovery (R-E)* needs network, but is optional.
- *Fleet withdrawal of a bad release* is server-side and optional
  (Part 11).

Result: **not falsified** — health, known-good, rollback and loop
suppression can be decided entirely locally; remote reporting remains
optional and outside fundamental semantics (candidate R-PV1). Health
evidence must not be transmitted by default (RES-0007 Part 23).

## Part 30 — Recovery threat model

Owners: **C** 0.1C-C (semantics), **F** 0.1C-F (probes), **D** 0.1D,
**A** application wave, **H** hardware wave, **O** owner domain.

| ID | Threat | Asset | Attacker capability | Existing upstream control | Gap | Candidate mitigation | Residual risk | Owning wave |
|---|---|---|---|---|---|---|---|---|
| T-R1 | Unprivileged user fakes health | KG / floor | local login | polkit `manage-units` auth_admin (Y10) | **GRUB `boot_success` settable by any user** (G1, G5) | privileged evaluator; session evidence only as input; do not reuse `boot_success` | user can influence session evidence (not decision) | C / D |
| T-R2 | Compromised deployment marks itself known-good | KG / floor | root in B | Secure Boot, signatures (integrity only) | self-assessment inherent | KG ≠ attestation; floor tied to authorised target; security floor revocation; integrity checks at lower layers | a root-compromised system can lie | C / D |
| T-R3 | Attacker suppresses rollback | availability | root, or write access to `/var`, `/boot` | none | counters/records writable by root | fail-safe defaults; loader-level counter independent of userspace; evidence | root can always suppress | C / D |
| T-R4 | Rollback loop DoS | availability | serve bad update repeatedly; or local reboot abuse | none upstream (G9 manual) | no suppression | SUPPRESSED records; one automatic rollback per attempt; clear counters at HEALTHY | owner confusion | C |
| T-R5 | Forced downgrade to vulnerable retained deployment | integrity/security | trigger failure of B (e.g. crash) to force rollback to A | none | automatic rollback targets older code | security floor excludes FORBIDDEN deployments from automatic rollback; retained set bounded | window until security floor known | C / D |
| T-R6 | Persistent-state incompatibility corrupts data after rollback | user/system data | none (accident) or induce rollback | none | no contract | state contract; deferred migrations; data rescue | third-party components | C / A |
| T-R7 | Recovery environment tampered with | recovery | root on-disk; physical | Secure Boot if signed | on-disk recovery writable by root | signed, verified recovery; prefer external verified media | on-disk tampering by root | D |
| T-R8 | Recovery path bypasses Secure Boot/trust | trust | boot unsigned recovery | Secure Boot, SBAT | recovery flows that "just work" unsigned | recovery artefacts verified; SB kept | owner may disable SB (owner domain) | D |
| T-R9 | Malicious recovery media | whole machine | physical / social | Secure Boot (signed media only) | unsigned media if SB off | signed media; verification tool; guidance | SB-off machines | D / O |
| T-R10 | Logs/evidence destroyed by rollback | diagnostics | accident or attacker | persistent journal in `/var` (Y7) | early-boot failures not persisted; pstore off | evidence records in `/var`; pstore consideration | pre-`/var` failures | C / D |
| T-R11 | Disk exhaustion removes known-good deployment | availability | fill disk (e.g. CVE-2024-1048-style on `/boot`) | OSTree min-free-space | staging evicts rollback (U4) | R-RT1/R-RT2; pins; refuse to stage | blocked updates on full disk (visible) | C / D |
| T-R12 | Hardware failure misdiagnosed as software regression | availability/data | none | none | ping-pong rollback | one automatic rollback per attempt; both-fail ⇒ RECOVERY_REQUIRED with hardware hint | misclassification | C / H |
| T-R13 | Local privileged owner overrides policy | policy | root (legitimate) | none by design | — | explicit, logged, visible; no cryptographic prevention | full (by design) | O |

## Part 31 — Failure matrix (RF1–RF22; documentary)

Columns: **Det** detectable?; **Auto** automatic action (candidate);
**Owner** owner action; **RB?** rollback helps?; **Rec?** recovery
required?; **Data** data risk; **Resp** U = upstream, E = Eldora
policy/implementation, H = hardware/owner. RES-0006 cross-references in
brackets.

| ID | Scenario | Det | Auto | Owner | RB? | Rec? | Data | Resp |
|---|---|---|---|---|---|---|---|---|
| RF1 | Image verified but never boots | yes if attempts terminate (Y6) | loader fallback after budget | select previous in menu | **yes** | no | low | U (counting) + E (arming, termination) [F16] |
| RF2 | Kernel panic | only with `panic=N`/watchdog; default hangs | as RF1 once terminating | power-cycle; menu | yes | no | low | E + D (kargs) |
| RF3 | initramfs failure | emergency shell (interactive) | none by default; `rd.emergency=reboot` possible | menu | yes | no | low | E + D |
| RF4 | Critical system service failure | yes (critical set) | rollback if regression vs KG | inspect / rollback | yes | no | low–medium | E [F18] |
| RF5 | Graphical stack failure | yes (interactive) | rollback only if regression on same hardware; else owner decision | TTY/SSH/menu rollback | often | no | low | E + H [F17] |
| RF6 | User session cannot start | yes (interactive) | as RF5 | as RF5 | often | no | low | E |
| RF7 | Networking failure | yes | none (environmental unless declared role) | diagnose | rarely | no | none | E [F19] |
| RF8 | Audio/Bluetooth failure | yes | none; defer KG if regression | rollback optional | sometimes | no | none | E |
| RF9 | Health service itself fails | yes (absence of mark) | treated as failed boot (fail-safe) | inspect | yes (it is part of the image) | no | low | E |
| RF10 | Machine crashes before known-good | partial (next boot) | attempt consumed; KG withheld | — | if repeated | no | medium (unsynced writes) | E |
| RF11 | Power loss during health window | yes (no clean shutdown record) | attempt consumed; classify indeterminate; no suppression by itself | — | not needed | no | medium | E |
| RF12 | Repeated boot loop | yes (counter) | loader fallback; SUPPRESS target | — | yes | if rollback target also loops | low | U + E |
| RF13 | Rollback deployment fails | yes | **no second automatic rollback**; RECOVERY_REQUIRED | recovery path | no | **yes** | medium | E [F24] |
| RF14 | `/var` incompatible after rollback | partial (service failures on A) | none automatic (rollback already done) | component repair; roll forward if B fixed | no | repair | **high** | E + A [F21] |
| RF15 | `/etc` issue disappears on rollback and returns on roll-forward | yes (config diff) | explain; warn before roll-forward | fix file | temporary | no | low | U (OSTree) + E (explain) [F20] |
| RF16 | Bootloader failure | no from OS (does not boot) | none (firmware fallback path only) | boot external media; repair ESP | **no** | **yes** | low | U (bootupd) + E + D [F25] |
| RF17 | Secure Boot chain failure (SBAT/dbx revocation, key issue) | no from OS | none | update boot chain from media; owner may disable SB | **no** | **yes** | low | U + D + O |
| RF18 | Disk full removes recovery margin | yes (preflight) | refuse to stage; keep pins | free space | n/a | no | low | E [F07/F08] |
| RF19 | Corrupted disk/filesystem | partial (mount/IO errors) | no rollback; RECOVERY_REQUIRED with hardware hint | fsck; data rescue | no | **yes** | **high** | H + E |
| RF20 | Hardware regression/failure | partial (both deployments fail) | stop after one rollback | hardware service | no | yes | variable | H |
| RF21 | Owner forces failed deployment | yes (override record) | respect; no automatic re-rollback loop while override active | owner | n/a | no | owner-chosen | E (audit) |
| RF22 | Recovery environment unavailable (not installed, stale, SBAT-revoked media) | on use | none | obtain current verified media | no | yes | variable | E + D + O |

## Part 32 — Upstream vs Eldora responsibility map

| UPSTREAM OWNS | ELDORA POLICY OWNS | ELDORA IMPLEMENTATION LATER | FUTURE APP MODEL | HARDWARE / OWNER DOMAIN |
|---|---|---|---|---|
| Deployment creation, `/etc` merge, atomic swap, rollback reorder (OSTree/bootc) | Health model (critical/degraded/optional, baseline) | Health evaluator integration (`boot-complete.target` or equivalent) | App state backward compatibility (AM-1..AM-6) | Firmware updates, NVRAM, SB enablement |
| Pinning, GC, min-free-space (OSTree) | KNOWN_GOOD definition and profiles | Attempt/intent/evidence records in `/var` | App data separation | Hardware diagnosis/repair |
| Loader-level counters (systemd-boot; GRUB `boot_counter` script) | Automatic rollback conditions; one-rollback rule | Arming/clearing counters; boot termination config (kargs, emergency action) | App rollback awareness | Owner overrides (by right) |
| `boot-complete.target`, bless-boot, failure actions (systemd) | Update-success semantics | Loop suppression store | | MOK/third-party keys |
| ESP update (bootupd), shim fallback, SBAT (shim) | Loop suppression and lift rules | Pin management for last KG | | |
| Persistent journal, pstore service (systemd) | Floor advancement point; security floor effects on rollback | Evidence and explanation surface | | |
| Factory-reset primitives (systemd; bootc reset experimental) | Retention semantics (protected set) | Recovery path integration (0.1D) | | |
| greenboot-rs (candidate building block, unselected) | Recovery semantics; destructive-action consent | State contract tooling for Eldora components | | |
| | Security failure classification; owner override semantics | | | |

## Part 33 — Candidate requirements (CANDIDATES — not accepted)

Health model:
- **R-HM1** The health decision is defined independently of the loader
  mechanism that consumes it (Part 6).
- **R-HM2** Health conditions are classified CRITICAL / DEGRADED /
  OPTIONAL; no single non-critical condition causes automatic or
  destructive action (Part 4).
- **R-HM3** Health always applies the selected profile's absolute
  critical requirements; where a previous known-good capability profile
  exists, it is used **additionally** to detect machine-specific
  regressions, and never demotes a capability the profile intrinsically
  requires (Part 3; Project Owner correction A3).
- **R-HM4** The health decision is taken by a privileged component;
  user-session inputs are evidence only and cannot alone produce
  HEALTHY or KNOWN_GOOD (Part 5).
- **R-HM5** Absence of a positive health mark is "not healthy" (attempt
  open), never "healthy" (fail-safe) (Part 5).
- **R-HM6** Fedora GRUB `boot_success` (user-settable) is not used as an
  Eldora health or known-good signal (RC-T).

Known-good / success:
- **R-KG1** BOOTED is never equated with HEALTHY or KNOWN_GOOD (Part 1).
- **R-KG2** KNOWN_GOOD requires HEALTHY plus accumulated healthy runtime
  on this machine, profile-sensitive, reachable without network or user
  presence (Part 7).
- **R-KG3** Floor advancement, eviction of the previous known-good,
  state-migration steps that destroy rollback compatibility and
  suppression clearing act only on KNOWN_GOOD (Part 8; A4).
- **R-KG4** "Update successful" is reserved for KNOWN_GOOD (Part 8).
- **R-KG5** KNOWN_GOOD is a reliability signal, not an integrity
  attestation. It is recorded as historical evidence that is never
  erased or rewritten; later local critical regressions, a signed
  security floor (FORBIDDEN) or hardware/state changes affect only the
  deployment's current eligibility, not that history (Parts 1, 5;
  Project Owner correction A1).
- **R-KG6** An owner override or owner acceptance never fabricates
  ordinary KNOWN_GOOD evidence; it is recorded as an owner action, does
  not by itself advance the vendor high-water floor and does not clear
  FORBIDDEN (Parts 7, 27; Project Owner correction A2).

Rollback and attempts:
- **R-RB1** Automatic rollback only for CRITICAL failures attributable
  to the deployment, when an eligible (retained, KNOWN_GOOD, not
  FORBIDDEN) target exists (Part 9).
- **R-RB2** Automatic rollback never for environmental, degraded,
  optional, shared-state, boot-chain, firmware or hardware failures, nor
  after KNOWN_GOOD (Part 9).
- **R-RB3** At most one automatic rollback per update attempt; if the
  rollback target fails, enter RECOVERY_REQUIRED (Parts 19, 23).
- **R-AT1** A small, evidence-based attempt budget; loader counters are
  cleared at HEALTHY, not at KNOWN_GOOD (Part 10).
- **R-AT2** A failed boot must terminate the attempt without a human
  (no indefinite hang on panic or emergency shell) where automatic
  rollback is promised (Part 10; RC-U).
- **R-AT3** A durable attempt record exists outside `/etc` and `/boot`
  and is reconciled with loader state each boot (Part 10).

Loop prevention and floor:
- **R-LP1** A rolled-back failed target is SUPPRESSED by signed version
  and digest; automatic policy never re-applies it (Part 11).
- **R-LP2** Suppression persists across rollback and lifts only on a
  strictly newer authorised version or explicit owner retry (Part 11).
- **R-LP3** A lost (never-booted) target is not suppressed (Part 25).
- **R-FL1** The high-water floor advances only at KNOWN_GOOD of an
  Eldora-authorised target; owner-local images do not raise it
  (Part 13).
- **R-FL2** A signed security floor excludes retained deployments from
  *automatic* rollback; the owner may still choose them explicitly as a
  logged recovery exception that does not lower the floor, clear
  FORBIDDEN or restore automatic eligibility, and that network metadata
  can never invoke (Part 12; Project Owner direction on RC-Y).
- **R-FL3** Automatic policy never selects a new target older than the
  currently attempted target (Part 13).

Retention:
- **R-RT1..R-RT4** as in Part 14 (never evict last KNOWN_GOOD; no
  staging over a non-KG booted deployment unless the last KG is
  protected; protected set; pin recording).

Persistent state:
- **R-ST1** Before KNOWN_GOOD, state changes by Eldora components remain
  readable by the retained rollback deployment (N-1 compatibility across
  the rollback window): migrations needed for operation are
  additive/expand-style or otherwise backward-compatible (A4).
- **R-ST2** Destructive cleanup, contract steps and
  compatibility-breaking irreversible migrations of Eldora components
  occur only after KNOWN_GOOD, per the later state-contract architecture
  (A4).
- **R-ST3** Components declare discardable caches separately from
  durable state.
- **R-ST4** Eldora's own recovery-relevant state lives outside
  per-deployment `/etc` and does not depend on `/boot` writes.

Recovery:
- **R-RC1** An independent, verified, offline-capable recovery path
  exists that does not depend on the installed ESP/boot chain or root
  filesystem (Parts 19–20); its implementation (external media, on-disk,
  hybrid, firmware/network) is not selected (A5).
- **R-RC2** Recovery artefacts are verified; recovery does not bypass
  trust or Secure Boot (HC-8; Part 26).
- **R-RC3** Destructive recovery (erasing owner data) requires explicit,
  local owner confirmation (Part 22).
- **R-RC4** Data rescue is offered before any destructive step
  (Part 22).
- **R-RC5** Trust-state loss/corruption is recovered from image-shipped
  anchors, never by falling back to permissive trust (HC-7; Part 26).

Owner, observability, privacy:
- **R-OV1** The owner can override every automatic recovery decision
  through explicit, local, logged actions (Part 27); overrides are
  recorded as owner actions/acceptance and never as ordinary KNOWN_GOOD
  evidence (R-KG6).
- **R-OB1** Minimum durable local evidence per Part 28.
- **R-OB2** Lost updates are classified before health logic (Part 25).
- **R-PV1** Health, known-good, rollback and suppression decisions work
  offline; remote reporting is optional and off by default (Part 29).

## Part 34 — Anti-bias / falsification (H1–H8)

| Hypothesis | Result | Explanation |
|---|---|---|
| **H1** "Successful boot is sufficient to mark an update known-good." | **REFUTED** | Booted-but-broken is the defining risk (RISK-0013); precedents mark success after checks/time (X1–X3); Fedora's own boot-success signal is a user-settable menu hint (G1–G2). For: fast, simple, no false rollbacks. Insufficient. |
| **H2** "Automatic rollback should trigger on any failed health check." | **REFUTED** | Optional/environmental failures (network, Bluetooth, monitors) would cause destructive rollbacks (Part 4); shared-state and hardware failures are not fixed by rollback and would loop (Parts 19, 23); systemd itself calls any-failed-unit checks "probably not suitable" (Y4). |
| **H3** "Two OSTree deployments are sufficient recovery for Eldora V1." | **REFUTED** | Staging before KG evicts the last good deployment (U4, RC-V); boot-chain failures affect all deployments (Part 18); `/var` and disk failures are shared (Part 19). Two deployments are sufficient only for per-deployment regressions. |
| **H4** "Advancing the anti-rollback floor immediately after first successful boot is safe." | **REFUTED** | Delayed failures after first boot would leave the only compatible older target below the floor if its deployment is lost; AVB and ChromeOS precedents advance only after success (X1, RES-0007 F8). Safe point: KNOWN_GOOD (Part 13, with conditions). |
| **H5** "OS rollback is sufficient even when persistent state has migrated." | **REFUTED** | `/var` and `$HOME` are not rolled back (U8); forward-migrated state persisted in the lab (RES-0004 PB3); many programs refuse or corrupt on downgrade (X7). |
| **H6** "A dedicated recovery environment is necessary for V1." | **REFUTED as stated; SUPPORTED WITH CONDITIONS in weaker form** | What is necessary is an *independent recovery path* (R-RC1). An on-disk recovery environment shares the ESP/firmware and cannot fix boot-chain failures (Part 20); verified external media are the leading candidate for the independent path (not selected, A5). Whether V1 also or instead ships an on-disk environment: MORE EVIDENCE REQUIRED (0.1D/ADR). |
| **H7** "Health/known-good can operate entirely locally without cloud dependency." | **SUPPORTED WITH CONDITIONS** | Decisions are local (Part 29). Condition: security revocation (FORBIDDEN) requires fresh signed metadata; offline machines have visible, reduced security currency (RES-0007 H5). Network recovery is optional. |
| **H8** "The legitimate machine owner must retain a way to override automatic recovery policy." | **SUPPORTED WITH CONDITIONS** | Owner is root; overrides must exist (Part 27); conditions: explicit, local, logged; not reachable by unprivileged or network actors; owner overrides are recorded as owner acceptance, never as fabricated KNOWN_GOOD evidence, do not raise the vendor floor and do not clear FORBIDDEN (A2); destructive actions need explicit confirmation. |

## Part 35 — Relation to existing risks (no status, severity or likelihood changed)

| Risk | Effect of this research |
|---|---|
| RISK-0002 (NVIDIA + Secure Boot) | Sharpened for health: out-of-tree drivers are the leading H-GRAPHICS regression source; KG must be hardware-relative; MOK state not rolled back (Part 24). PX3 remains the gate. |
| RISK-0010 (UEFI `/boot`, release blocker) | Extended: loader-level boot counters (GRUB env, BLS names) require runtime writes to `/boot`/ESP — the same mount ownership; lost updates must be classified before health (Part 25). Remains OPEN / RELEASE BLOCKER. |
| RISK-0011 (boot chain not rolled back) | Confirmed and extended: no layer below BLS entries is rolled back; SBAT makes boot-chain downgrade impossible by design; only an independent path recovers (Parts 18–20). |
| RISK-0012 (abrupt loss after staging) | Interaction: lost-update classification precedes health; lost targets are not suppressed (Part 25). |
| RISK-0013 (booted ≠ healthy) | Addressed at semantic level: model Parts 1–8; mechanism availability on bootc + Fedora GRUB still UNVERIFIED (P-07, P-08); default `panic=0` weakens automatic rollback (RC-U). |
| RISK-0014 (older code over newer state) | Confirmed; mitigation direction: state contract — rollback-compatible changes before KG, destructive/contract steps only after KG; no global snapshot (Part 16). |
| RISK-0015 (re-apply loops) | Addressed at semantic level: SUPPRESSED by version + digest; lift rules; one-rollback rule (Parts 11, 23). |
| RISK-0016 (both deployments / boot chain fail) | Confirmed: every both-fail cause needs a path beyond rollback; independent verified path recommended (Parts 19–22). |
| RISK-0008 (freshness / anti-rollback) | Floor advancement point proposed (KG, with conditions); security floor vs retained deployments (Parts 12–13). |
| RISK-0005 (`/etc` drift) | `/etc` rollback explanation and both-snapshot edits as both-fail cause (Part 15). |
| RES-0007 candidates RC-M, RC-O, RC-Q | RC-Q (upstream auto-update timer) aggravates loops — suppression must be enforced by Eldora's own policy (Part 11). RC-M: trust-state recovery must use image anchors (R-RC5). RC-O unchanged. |

## Part 36 — New risk candidates (dispositions recorded at Project Owner review)

Project Owner disposition (2026-09-26): RC-U → RISK-0017, RC-V →
RISK-0018, RC-W → RISK-0019, RC-X → RISK-0020, RC-Y → RISK-0021 and
RC-Z → RISK-0022 are registered as OPEN risks in
[`RISK-REGISTER.md`](../../project/RISK-REGISTER.md). RC-T is **not**
registered: AVOIDED BY DESIGN DIRECTION — Eldora must not use Fedora GRUB
`boot_success` as its health/known-good authority (R-HM6). RC-AA is
**not** registered: CONDITIONAL / DEFERRED to the future
TPM/measured-boot/sealed-secret architecture (0.1D/hardware work).

| Candidate | Description | Evidence |
|---|---|---|
| RC-T | Fedora GRUB `boot_success` can be set by any logged-in user (setuid `grub2-set-bootflag`, user timer); if reused as a health/known-good signal, health is spoofable; the path has had a local DoS CVE on `/boot`. | G1, G5 |
| RC-U | Fedora defaults (`panic=0`, interactive emergency shell, runtime watchdog off) make a failed boot hang instead of ending the attempt, so loader-level automatic rollback does not trigger on unattended machines. | Y5, Y6 (local observation) |
| RC-V | With default retention (two deployments), staging a new update while the booted deployment is not yet known-good evicts the last known-good deployment; bootc has no pin verb. | U4, U5; RES-0007 Part 7 |
| RC-W | SBAT revocation is monotonic: after a boot-chain update, older boot chains — including older recovery/installer media — may become unbootable under Secure Boot; boot-chain "rollback" is impossible by design. | G7 |
| RC-X | Failures before `/var` is mounted and the journal flushed leave no durable evidence by default (EFI pstore disabled, kdump absent), so the cause of a failed boot of B is invisible from A. | Y7 (local observation) |
| RC-Y | A signed security floor (epoch/min-version) can make the only rollback target forbidden, leaving no automatically eligible deployment when the new one fails. | Part 12 |
| RC-Z | The Fedora GRUB / greenboot fallback selects `default=1` (second menu entry); with pinned or additional deployments the entry order may not match the intended rollback target. | G3, G6 (INFERENCE; P-28) |
| RC-AA | GRUB environment writes on every boot change TPM PCR 8; any future TPM-sealed secret design interacts with boot-counting/boot-flag writes. | G5 (bz#1975891) |

## Part 37 — Probes

### Existing probes mapped to conclusions (none executed)

| Probe | Conclusions depending on it |
|---|---|
| P-01 | Part 10/25: counter storage shares `/boot` ownership (layout-independent semantics; not required before review) |
| P-03 | Part 25: finalize-failure vs lost-update classification |
| P-05 | RF10, RF11, Part 25 (power loss before finalization vs in health window) |
| P-06 / P-23 | RF18, Part 14 (disk floors vs protected set) |
| P-07 | Parts 2, 10; HY1, HY2; RF1–RF3, RF12 (boot counting on Fedora GRUB) |
| P-08 | Parts 2, 9, 11; HY1; RF4, RF12, RF13 (greenboot-rs on bootc; loop behaviour) — **extend** to rollback-target failure and auto-update re-apply |
| P-09 | Part 16; RF14 (`/var` schema after rollback) |
| P-10 | Part 15; RF15 (`/etc` roll-forward) |
| P-11 | Parts 18, 20; RF16, RF17 — **extend** to SBAT level vs older media/boot chain (RC-W) |
| P-12 / P-18 | Part 13 (floor, versions) |
| P-14 | Part 28 (status-change hook for evidence) |
| P-16 | Part 10 (soft-reboot vs attempts) |
| PX3 | Part 24 (drivers) |
| PX1 | Part 16 (major-version state migration) |

### New probe candidates (proposed for 0.1C-F; NOT executed)

| ID | Purpose | Outline |
|---|---|---|
| P-25 | Health-marker and attempt survival | arm counter; crash before HEALTHY; power loss inside health window; user reboot before/after HEALTHY; soft-reboot; verify loader vs Eldora-record reconciliation |
| P-26 | Boot termination on failure | kernel panic, initramfs failure, emergency shell with default kargs vs `panic=N`, `rd.emergency=reboot`, `JobTimeoutAction=`; does the attempt end without a human? (HY3, RC-U) |
| P-27 | Graphical-session failure classification | break the display manager / compositor in a test image; measure detection and FP behaviour with absent/secondary monitors (VM-level only; physical hardware claims need hardware) |
| P-28 | Retention and pinning | stage C while B not KG; verify eviction of A (HY4); `ostree admin pin` on a bootc sysroot across `bootc upgrade`/`rollback`/GC (HY6); GRUB `default=1` target with pinned third deployment (RC-Z); disk cost of a third deployment |
| P-29 | Both-deployments-fail recovery via verified external media | corrupt ESP / both deployments; boot signed live/installer media; repair ESP; rescue `/var/home`; reinstall preserving `/home` |
| P-30 | Evidence survival | failure of B before and after journal flush; visibility from A (`journalctl -b -1`); pstore with EFI backend enabled (HY5, RC-X) |
| P-31 | Owner override audit | owner boots SUPPRESSED/FORBIDDEN deployment via menu/CLI; verify it is recorded and that automatic policy does not immediately undo it |

Loop suppression itself is covered by extending P-08 (no separate
probe). PX6 extension from RES-0007 unaffected.

### Is any probe required before human review?

**No.** The conclusions of this report are semantic and are stated
conditionally where they depend on mechanism behaviour (HY1–HY6,
UNVERIFIED items). The probes validate *mechanisms* for later ADRs; none
is needed to review the semantics. **No authorisation is requested.**
P-01 remains a pending early fact-finding probe; not executed.

## Part 38 — Requirements handed to 0.1C-F and 0.1D

To **0.1C-F** (validation):
- **HF-1** Execute P-07 and extended P-08 to establish whether automatic
  fallback works on bootc (OSTree backend) + Fedora GRUB.
- **HF-2** P-25, P-26: attempt semantics and boot termination.
- **HF-3** P-28: retention eviction and pinning under bootc.
- **HF-4** P-09, P-10: state and `/etc` behaviour across rollback.
- **HF-5** P-29, P-30: independent recovery path and evidence survival.
- **HF-6** P-11 extended: SBAT/older media.
- **HF-7** P-27, P-31 as capacity permits.

To **0.1D** (build / boot / release):
- **HD-13** Bootloader path decision (Fedora GRUB + armed counter vs
  systemd-boot/UKI + BLS counting; bootc composefs backend status) able
  to carry R-HM1 / R-AT1.
- **HD-14** Kernel arguments / system configuration so failed boots
  terminate (panic, emergency action, timeouts, watchdog) — R-AT2.
- **HD-15** `/boot`/ESP layout with runtime-writable counter storage
  consistent with RISK-0010 ownership.
- **HD-16** Boot-chain (shim/GRUB) update policy, SBAT currency, A/B or
  backup ESP feasibility (bootupd #440); RISK-0011.
- **HD-17** Independent recovery path: verified, SBAT-current installer
  or recovery media; optional on-disk recovery (R-B/R-C) decision.
- **HD-18** Pin management for the last known-good deployment and
  `/boot` capacity for three kernels/initramfs sets.
- **HD-19** CI regression tests for health-critical paths (boot,
  graphics, update machinery) before publication.
- **HD-20** Encryption/secure-erase design for reset/reinstall
  semantics; recovery unlock.
- **HD-21** Crash-evidence configuration (pstore backend, optional
  kdump) and early-boot log retention (RC-X).
- **HD-22** Signed version metadata sufficient for suppression by
  version (extends HD-8).

## Part 39 — Requirements handed to the application wave (0.3)

AM-1 to AM-6 (Part 17). Additionally: application platforms (Flatpak or
other) must document their behaviour when the host OS is rolled back.

## Part 40 — Requirements handed to hardware / driver work

- **HW-1** Capability baseline per machine (which devices and driver
  stack worked on the last KG) as health input (Part 3).
- **HW-2** Out-of-tree driver delivery that rolls back with the kernel
  and remains Secure Boot-compatible (Part 24; RISK-0002; PX3).
- **HW-3** Hardware-failure indicators (SMART, MCE, IO errors) to stop
  software rollback (Part 23).
- **HW-4** Firmware update (fwupd) events recorded; firmware regressions
  are not reverted by OS rollback.
- **HW-5** Physical-hardware validation of health checks (no VM-only
  claims).

## Part 41 — Effect on ADR-0001

**No material threat.** Nothing found shows that M3 cannot support
health gating, automatic rollback or recovery: the missing pieces are
Eldora policy plus configuration of existing primitives (boot counting
via GRUB `boot_counter` or systemd-boot/BLS; `boot-complete.target`;
pinning; external media). The largest uncertainty is whether automatic
fallback works on the bootc OSTree backend with Fedora GRUB (P-07/P-08);
if it does not, the consequence is a **bootloader/backend choice in
0.1D** (e.g. systemd-boot with the composefs backend when bootc supports
counting there), not a composition-model failure. None of the ADR-0001
reversibility triggers is met. ADR-0001 reconsideration is **not**
recommended.

## Answers to the mandatory questions

- **Q1 — BOOTED?** The recorded target deployment is the booted
  deployment and userspace reached a defined early milestone; a property
  of one boot (Part 1).
- **Q2 — HEALTHY?** In this boot, every CRITICAL condition passed,
  evaluated by a privileged component, relative to the machine's previous
  known-good baseline where available (Parts 1, 3–5).
- **Q3 — KNOWN_GOOD?** Historical per-deployment, per-machine evidence
  that, at a recorded time, the deployment was HEALTHY and accumulated
  healthy runtime, profile-sensitive (session evidence on interactive
  profiles, with an unattended fallback), reachable offline; a
  reliability signal, not an attestation. The history is never erased;
  later conditions change only current eligibility; owner overrides
  never fabricate it (Parts 1, 7; A1, A2).
- **Q4 — Update successful?** When the target deployment is KNOWN_GOOD
  (Part 8).
- **Q5 — Critical domains?** H-BOOT, H-SYSTEM (allow-list), H-STORAGE
  (mount/rw), H-UPDATE; the basic graphical session on interactive
  profiles that promise one (even on first install), networking where a
  profile declares it; further capabilities judged additionally against
  the previous-KG baseline; H-SECURITY only for verifiable, attributable
  invariants (Parts 3–4; A3).
- **Q6 — Failures that should not cause rollback?** Environmental,
  degraded, optional, shared-state, boot-chain, firmware, hardware,
  post-KG, timeout-before-KG, security changes rollback cannot fix
  (Part 9).
- **Q7 — Who can declare health?** A privileged Eldora component;
  session evidence as input only (Part 5).
- **Q8 — Spoofing prevention?** Privileged decision via authorised
  interfaces (manage-units = auth_admin precedent); do not reuse GRUB
  `boot_success`; fail-safe absence semantics. Self-marking by a
  compromised root deployment cannot be prevented, only bounded
  (Part 5).
- **Q9 — Attempts?** A small budget; value not selected (precedents 1–6;
  evidence from P-07/P-08/P-25) (Part 10).
- **Q10 — What is an attempt?** A full firmware→loader boot of the
  deployment that has not yet reached HEALTHY; soft-reboot and suspend
  are not loader attempts (Part 10).
- **Q11 — When automatic rollback?** CRITICAL, attributable failure
  before KNOWN_GOOD with an eligible target; or exhausted loader budget
  (Part 9).
- **Q12 — When not?** See Q6; also never a second automatic rollback in
  the same attempt; never to a FORBIDDEN or non-KG target; never when the
  owner disabled it (Part 9).
- **Q13 — Quarantine?** Local SUPPRESSED record by signed version and
  digest, with evidence, outside `/etc`/`/boot` (Part 11).
- **Q14 — Loop prevention?** Suppression + lift only on newer version or
  owner retry + one automatic rollback per attempt + counters cleared at
  HEALTHY (Parts 10–11, 23).
- **Q15 — Floor advance?** At KNOWN_GOOD of an Eldora-authorised target,
  with conditions (no automatic selection below the current attempt;
  separate security floor; KG reachable) (Part 13).
- **Q16 — Can a known-good deployment become forbidden?** Yes, via a
  signed security floor; its KNOWN_GOOD history is kept (A1), but it
  loses automatic rollback eligibility. If only FORBIDDEN deployments
  remain after a failure, the machine enters RECOVERY_REQUIRED and the
  owner may explicitly choose one as a logged recovery exception that
  leaves the floor and FORBIDDEN state intact (Parts 12, 26; Project
  Owner direction on RC-Y).
- **Q17 — Always retained?** The booted deployment, the last KNOWN_GOOD
  (if different) and any staged target (Part 14).
- **Q18 — GC of old deployments?** When a newer KNOWN_GOOD exists and the
  deployment is neither booted, the last KG, staged nor owner-pinned
  (Part 14).
- **Q19 — `/etc` on rollback?** OSTree selects the old snapshot; later
  edits are hidden and may return on roll-forward; Eldora explains and
  tracks diffs (Part 15).
- **Q20 — `/var` and `$HOME`?** Not rolled back; older code runs on newer
  state (Part 16).
- **Q21 — Constrain migrations?** Do not destroy rollback
  compatibility before KNOWN_GOOD: operational migrations before KG are
  additive/expand-style or backward-compatible; destructive/contract
  steps only after KG; discardable caches declared (R-ST1..R-ST3; A4).
- **Q22 — Application-model requirements?** AM-1..AM-6 (Part 17).
- **Q23 — What OSTree rollback cannot recover?** Firmware, NVRAM/SB/SBAT,
  shim, GRUB binaries, shared GRUB env/static config, `/var`, `/home`,
  filesystem corruption, hardware, firmware updates (Part 18).
- **Q24 — Both deployments fail?** RECOVERY_REQUIRED; independent
  verified path; data rescue before destructive steps (Part 19).
- **Q25 — Dedicated recovery environment for V1?** An independent,
  verified, offline-capable recovery *path* is needed (architectural
  direction, A5); an on-disk environment is not shown necessary;
  verified SBAT-current external media is the leading candidate, not
  selected; decision for a 0.1D-informed ADR (Part 20; H6).
- **Q26 — Recovery capabilities?** Part 21 table (V1 REQUIRED / V1
  DESIRABLE / LATER).
- **Q27 — What should repair/reset/reinstall preserve?** Rollback,
  recovery and repair preserve everything; reset and reinstall defaults
  require Project Owner decision (Part 22).
- **Q28 — Boot-chain recovery?** Only via a path independent of the
  installed ESP (verified external media, firmware fallback); SBAT-
  current binaries (Part 18).
- **Q29 — Hardware vs software?** Failure persists on the previous KG;
  IO/MCE/SMART signals; both deployments fail ⇒ stop rollback (Part 23).
- **Q30 — Third-party drivers vs known-good?** KG is hardware-relative;
  driver/kernel mismatch is a predictable graphics regression; MOK not
  rolled back (Part 24).
- **Q31 — Security failures forcing recovery?** Integrity violations and
  corrupted trust state; SB disabled is an owner-visible degradation, not
  forced recovery (Part 26).
- **Q32 — Owner overrides?** All listed in Part 27, explicit, local,
  logged; recorded as owner actions/acceptance, never as fabricated
  KNOWN_GOOD evidence; they do not advance the vendor floor or clear
  FORBIDDEN (A2).
- **Q33 — Evidence surviving rollback?** Part 28 list (in `/var`, not
  `/etc`/`/boot`).
- **Q34 — Network/cloud needed?** No for decisions; yes only for fresh
  security revocation and optional network recovery (Part 29).
- **Q35 — Recommendable now?** Semantic model (Parts 1, 8); critical/
  degraded/optional (Part 4); privileged decision (Part 5); KG hybrid
  direction (Part 7); floor at KG with conditions (Part 13); suppression
  model (Part 11); retention semantics (Part 14); state contract
  direction (Part 16); independent recovery path (Part 20); local-only
  decisions (Part 29).
- **Q36 — Requiring 0.1C-F probes?** Mechanism availability and
  behaviour: HF-1 to HF-7 (Part 38).
- **Q37 — Requiring 0.1D?** HD-13 to HD-22 (Part 38).
- **Q38 — Later application/hardware waves?** AM-1..AM-6; HW-1..HW-5
  (Parts 39–40).
- **Q39 — New risk candidates?** RC-T to RC-AA (Part 36); at review
  RC-U to RC-Z were registered as RISK-0017 to RISK-0022, RC-T avoided
  by design (R-HM6), RC-AA deferred.
- **Q40 — Threat to ADR-0001?** No (Part 41).

## Open Questions

- OQ-C1: Does greenboot-rs work on a bootc OSTree-backend host with
  Fedora GRUB, and how does it behave when the rollback target also
  fails? (P-08)
- OQ-C2: Do Fedora GRUB builds honour BLS `+N-M` counters? (P-07)
- OQ-C3: Does `ostree admin pin` interact safely with bootc operations?
  (P-28)
- OQ-C4: When will bootc configure boot counting for the composefs
  backend, and is that path viable for Eldora V1? (0.1D)
- OQ-C5: What dwell and attempt parameters fit desktop, laptop and
  unattended profiles? (P-25, later ADR)
- OQ-C6: Which Fedora/upstream components in the image perform
  irreversible `/var` migrations? (inventory, 0.1D)
- OQ-C7: Reset/reinstall defaults for `/home`, identity, secrets and
  logs (Project Owner decision).
- OQ-C8: RC-Y (security floor forbids the only rollback target) —
  **resolved as Project Owner direction** (Part 12); remains ADR input
  for the final floor/recovery ADRs.

## Recommendation

A recommendation is not a decision.

- **R1.** Adopt, as 0.1C working vocabulary, the separation of
  *attempt* / *boot* (BOOTED, HEALTHY) / *deployment* (KNOWN_GOOD) /
  *target* (SUPPRESSED, FORBIDDEN) scopes, and clear loader attempts at
  HEALTHY while reserving policy effects for KNOWN_GOOD.
- **R2.** Health: CRITICAL / DEGRADED / OPTIONAL with
  regression-relative evaluation and a privileged decision; do not
  reuse GRUB `boot_success`.
- **R3.** Known-good: hybrid (health + accumulated dwell, session
  evidence on interactive profiles, unattended fallback; owner
  acceptance recorded separately and never as KNOWN_GOOD evidence)
  — **ADR candidate** "health, known-good and automatic rollback
  semantics", parameters after P-25.
- **R4.** Floor advances at KNOWN_GOOD with the conditions of Part 13;
  security floor separate — joint **ADR candidate** with RES-0007 R5
  ("anti-rollback floor semantics").
- **R5.** Loop prevention by SUPPRESSED records (version + digest) and
  one automatic rollback per attempt.
- **R6.** Retention: protect the last KNOWN_GOOD; never stage over a
  non-KG booted deployment without protecting it.
- **R7.** Persistent state: a compatibility contract for Eldora
  components (N-1; do not destroy rollback compatibility before
  KNOWN_GOOD; destructive/contract steps after KG); no global snapshot
  system for V1; application requirements AM-1..AM-6 to Wave 0.3.
- **R8.** Recovery: V1 needs an independent, verified, offline-capable
  recovery path (accepted at review as architectural direction, A5);
  verified SBAT-current external media is the leading candidate; the
  implementation (external media, on-disk, hybrid, firmware/network) is
  deferred to a 0.1D-informed **ADR candidate** ("recovery path");
  destructive defaults to Project Owner.
- **R9.** Record RC-T to RC-AA for Project Owner review; schedule P-25 to
  P-31 and the P-08/P-11 extensions for 0.1C-F.

Decisions needing an ADR (proposed): health/known-good/automatic
rollback semantics; anti-rollback floor semantics (with RES-0007);
recovery path; bootloader/boot-counting path (0.1D). The persistent-state
contract may need an ADR (architecture) plus a SPEC (component rules).

- **Confidence:** MEDIUM.

## Confidence and limitations

- MEDIUM overall. Semantic conclusions rest on Tier-1 documentation of
  bootc, OSTree, systemd, the BLS, shim and Fedora GRUB sources, local
  Fedora 44 man pages/units and consistent external precedents. They are
  documentary: **no probe was executed** and no mechanism was observed on
  an Eldora or bootc machine in this sub-stage.
- Mechanism availability on bootc + Fedora GRUB (greenboot-rs, GRUB
  counters, OSTree boot counting) is **UNVERIFIED**; bootc and
  greenboot-rs documents contradict each other on integration (G6).
- Host observations (panic, pstore, polkit, setuid bit) come from a
  package-based Fedora 44 Workstation, not from a bootc image; Eldora
  images may differ.
- Upstream sources were read at `main`; shipped versions may differ.
- Quotes returned through a summarising fetch tool are not marked
  verbatim and must be re-checked before citation in a decision record.
- External precedents (Android, ChromeOS, Mender, RAUC, Ubuntu Core,
  Windows, macOS) are design precedents only; several rest on dated
  design documents or search snippets (marked).
- docs.fedoraproject.org was blocked; Fedora Atomic claims rely on a
  possibly legacy AsciiDoc source.
- No physical hardware evidence; hardware and driver statements are
  inferences.
- Process deviations: see "Method and limitations".

## Decision

NOT TAKEN — research does not decide. Q-0008 remains NOT DECIDED.

## Sources

All accessed 2026-09-26. Tier per `docs/research/README.md`. Type: SPEC =
specification; DOC = official documentation; SRC = source code; ISSUE =
upstream issue/PR/bug tracker; FEDORA = Fedora integration documentation;
LOCAL = local man page/file/observation on the Fedora 44 host; PREC =
external precedent documentation.

| # | Source (title — organization — URL / path) | Tier | Type | Version / date covered | Accessed | Used for |
|---|---|---|---|---|---|---|
| S1 | bootc-rollback(8) — bootc — https://bootc.dev/bootc/man/bootc-rollback.8.html (source `docs/src/man/bootc-rollback.8.md`) | 1 | DOC | main (undated) | 2026-09-26 | U2, U3 (verbatim) |
| S2 | Upgrades and rollback — bootc — https://bootc.dev/bootc/upgrades.html | 1 | DOC | main | 2026-09-26 | U1, U2, download-only |
| S3 | bootc runtime (HEALTHCHECK) and book print view — bootc — https://bootc.dev/bootc/building/bootc-runtime.html ; https://bootc.dev/bootc/print.html | 1 | DOC | main | 2026-09-26 | U1, G6 contradiction |
| S4 | Boot failure detection — bootc — https://bootc.dev/bootc/boot-failure-detection.html | 1 | DOC | main | 2026-09-26 | U6, U7 (verbatim) |
| S5 | Bootloaders — bootc — https://bootc.dev/bootc/bootloaders.html | 1 | DOC | main | 2026-09-26 | U6, U11 (verbatim) |
| S6 | Filesystem — bootc — https://bootc.dev/bootc/filesystem.html | 1 | DOC | main | 2026-09-26 | U8 |
| S7 | Experimental: install reset — bootc — https://bootc.dev/bootc/experimental-install-reset.html | 1 | DOC | main | 2026-09-26 | U9 (verbatim) |
| S8 | host-v1 JSON schema — bootc — https://bootc.dev/bootc/host-v1.schema.json | 1 | SRC/DOC | `org.containers.bootc/v1` | 2026-09-26 | U5 |
| S9 | bootc(8) — bootc — https://bootc.dev/bootc/man/bootc.8.html | 1 | DOC | main | 2026-09-26 | U5 (no pin verb) |
| S10 | OSTree Sysroot API (gir rendering) — pgi-docs mirror of libostree API — https://lazka.github.io/pgi-docs/OSTree-1.0/classes/Sysroot.html | 1 (mirror) | DOC | undated | 2026-09-26 | U4, U5 |
| S11 | ostree-admin-deploy(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-deploy.html | 1 | DOC | main | 2026-09-26 | U4 |
| S12 | ostree-admin-pin(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-pin.html | 1 | DOC | main | 2026-09-26 | U5 |
| S13 | ostree-admin-cleanup(1); ostree-admin-undeploy(1) — OSTree — https://ostreedev.github.io/ostree/man/ | 1 | DOC | main | 2026-09-26 | retention, cleanup (Part 14) |
| S14 | ostree.repo-config(5) — OSTree — https://ostreedev.github.io/ostree/man/ostree.repo-config.html | 1 | DOC | main | 2026-09-26 | U6, U10 (verbatim) |
| S15 | Deployments; `/var`; Atomic upgrades — OSTree — https://ostreedev.github.io/ostree/deployment/ ; …/var/ ; …/atomic-upgrades/ | 1 | DOC | main | 2026-09-26 | U8, U9 |
| S16 | PR #3310 (boot counting `boot-counting-tries`) — ostreedev/ostree — https://github.com/ostreedev/ostree/pull/3310 | 2 | ISSUE | merged 2025-07-10 | 2026-09-26 | U6 |
| S17 | Issue #2670; PR #2847 (early prune) — ostreedev/ostree — https://github.com/ostreedev/ostree/issues/2670 ; …/pull/2847 | 2 | ISSUE | 2022-07-08; merged 2023-05-01 | 2026-09-26 | U4 |
| S18 | `ostree-boot-complete.service` — OSTree — https://github.com/ostreedev/ostree/blob/main/src/boot/ostree-boot-complete.service | 1 | SRC | main | 2026-09-26 | U7 |
| S19 | rpm-ostree administrator handbook; rpm-ostree(1) (ManKier rendering) — rpm-ostree — https://coreos.github.io/rpm-ostree/administrator-handbook/ ; https://www.mankier.com/1/rpm-ostree | 1 / 3 | DOC | current | 2026-09-26 | U4 |
| S20 | Issue #946 (rollback after switch) — bootc-dev/bootc — https://github.com/bootc-dev/bootc/issues/946 | 2 | ISSUE | 2024-12-07, open | 2026-09-26 | U2 |
| S21 | bootupd README; issues #440, #454; `src/bootupd.rs` — coreos/bootupd — https://github.com/coreos/bootupd | 1 / 2 | DOC / SRC / ISSUE | main; #440 open since 2023-03-17 | 2026-09-26 | U11 |
| S22 | Changes/AutomaticBootloaderUpdatesBootc — Fedora — https://fedoraproject.org/wiki/Changes/AutomaticBootloaderUpdatesBootc | 1 | FEDORA | F43 | 2026-09-26 | U11 |
| S23 | Automatic Boot Assessment — systemd — https://systemd.io/AUTOMATIC_BOOT_ASSESSMENT/ (source `docs/AUTOMATIC_BOOT_ASSESSMENT.md`) | 1 | DOC | main | 2026-09-26 | Y1, Y2 (verbatim) |
| S24 | systemd-bless-boot.service(8), systemd-bless-boot-generator(8), systemd-boot-check-no-failures.service(8), systemd.special(7) and unit files — systemd — local | 1 | LOCAL | systemd 259.9-1.fc44 | 2026-09-26 | Y1–Y4, Y5 (verbatim) |
| S25 | UAPI.1 Boot Loader Specification (boot counting) — UAPI Group — https://uapi-group.org/specifications/specs/boot_loader_specification/ | 1 | SPEC | main | 2026-09-26 | Y1 |
| S26 | systemd-boot(7) (`LoaderBootCountPath`, bad-entry ordering); Boot Loader Interface — systemd — upstream `man/systemd-boot.xml`; https://systemd.io/BOOT_LOADER_INTERFACE/ | 1 | DOC | main | 2026-09-26 | Y3, G4 |
| S27 | systemd.unit(5), systemd(1), systemd-system.conf(5), `/usr/lib/systemd/system.conf` — systemd — local | 1 | LOCAL | 259.9 | 2026-09-26 | Y5, Y6 |
| S28 | dracut.cmdline(7) — dracut — local | 1 | LOCAL | Fedora 44 | 2026-09-26 | Y5 (verbatim) |
| S29 | Documentation for /proc/sys/kernel (`panic`) — Linux kernel — https://docs.kernel.org/admin-guide/sysctl/kernel.html ; local `/proc/sys/kernel/panic` | 1 | DOC / LOCAL | current; host kernel | 2026-09-26 | Y6 |
| S30 | systemd-pstore.service(8) — systemd — local; host pstore/kdump observation | 1 | LOCAL | 259.9 | 2026-09-26 | Y7 |
| S31 | journald.conf(5), journalctl(1) — systemd — local | 1 | LOCAL | 259.9 | 2026-09-26 | Y7 |
| S32 | Factory Reset; systemd-factory-reset(8); repart.d(5); systemd-repart(8) — systemd — https://systemd.io/FACTORY_RESET/ ; local | 1 | DOC / LOCAL | main; 259.9 | 2026-09-26 | Y8 |
| S33 | systemd-soft-reboot.service(8) — systemd — local | 1 | LOCAL | 259.9 | 2026-09-26 | Y9 (verbatim) |
| S34 | sysupdate.d(5), systemd-sysupdate(8) — systemd — local; man.archlinux.org (262) | 1 | LOCAL / DOC | 259.9; 262 | 2026-09-26 | Y11 |
| S35 | `org.freedesktop.systemd1.policy`; `org.freedesktop.login1.policy` — systemd — local `/usr/share/polkit-1/actions/` | 1 | LOCAL | 259.9 | 2026-09-26 | Y10 |
| S36 | `grub-boot-success.timer/.service`, `grub-boot-indeterminate.service`, `grub2-systemd-integration.service`, grub2-set-bootflag(1), file mode — grub2 (Fedora) — local | 1 | LOCAL / FEDORA | grub2-tools 2.12-64.fc44 | 2026-09-26 | G1 (verbatim) |
| S37 | `util/grub.d/08_fallback_counting.in`, `10_reset_boot_success.in`, `12_menu_auto_hide.in`, `util/grub-set-bootflag.c` — rhboot/grub2 `fedora-44` — https://github.com/rhboot/grub2/tree/fedora-44 | 1 | SRC / FEDORA | fedora-44 branch | 2026-09-26 | G2, G3 (verbatim) |
| S38 | CVE-2024-1048 — Red Hat Bugzilla 2256827; oss-security 2024-02-06 — https://bugzilla.redhat.com/show_bug.cgi?id=2256827 ; https://www.openwall.com/lists/oss-security/2024/02/06/3 | 1 / 2 | ISSUE | 2024-02 | 2026-09-26 | G5 |
| S39 | Bug 1975891 (grubenv writes, PCR 8) — Red Hat Bugzilla — https://bugzilla.redhat.com/show_bug.cgi?id=1975891 | 2 | ISSUE | closed 2024-05-21 | 2026-09-26 | G5 |
| S40 | Changes/HiddenGrubMenu — Fedora — https://fedoraproject.org/wiki/Changes/HiddenGrubMenu | 1 | FEDORA | F29 | 2026-09-26 | G2 |
| S41 | Changes/Greenboot_RS_Change_Proposal — Fedora — https://fedoraproject.org/wiki/Changes/Greenboot_RS_Change_Proposal | 1 | FEDORA | F43 | 2026-09-26 | G6 |
| S42 | greenboot README; greenboot-rs README, `greenboot.conf`, `greenboot-rs.spec`, `src/lib/handler.rs` — fedora-iot — https://github.com/fedora-iot/greenboot ; https://github.com/fedora-iot/greenboot-rs | 1 | DOC / SRC | greenboot-rs 0.16.4 (2026-08-18) | 2026-09-26 | G6 |
| S43 | MicroShift greenboot documentation — Red Hat — docs.redhat.com (MicroShift 4.13 greenboot chapter); Red Hat Developer "Greenboot" article (2024-08-12) | 1 / 2 | DOC | 4.13; 2024 | 2026-09-26 | G6 |
| S44 | shim `README.fallback`, `SBAT.md` — rhboot/shim — https://github.com/rhboot/shim ; mokutil(1) local; `rpm -ql shim-x64` | 1 | SRC / LOCAL | main; mokutil 0.7.2; shim 16.1-5 | 2026-09-26 | G7 |
| S45 | Windows SBAT update breaks Linux dual boot (Aug 2024) — BleepingComputer | 3 | PREC | 2024-08 | 2026-09-26 | G7 precedent |
| S46 | `updates-upgrades-rollbacks.adoc` — fedora-silverblue/silverblue-docs — https://github.com/fedora-silverblue/silverblue-docs | 1 (possibly legacy) | FEDORA | main | 2026-09-26 | G8 |
| S47 | Anaconda `docs/rescue.rst` — rhinstaller/anaconda; QA:Testcase_Anaconda_rescue_mode — Fedora wiki | 1 | DOC / FEDORA | main; current | 2026-09-26 | G8 |
| S48 | `manual-rollbacks.adoc` — coreos/fedora-coreos-docs; issue #47 "Determine how to handle automatic rollback" — coreos/fedora-coreos-tracker | 1 / 2 | FEDORA / ISSUE | main; 2018-09-11 (open) | 2026-09-26 | G9 |
| S49 | A/B (seamless) updates; Implementing A/B; A/B FAQ; update_engine README — Android — https://source.android.com/docs/core/ota/ab ; …/ab_implement ; …/ab_faqs ; https://android.googlesource.com/platform/system/update_engine/+/HEAD/README.md | 1 | PREC | current | 2026-09-26 | X1 |
| S50 | AVB README (stored rollback indexes) — Android — https://android.googlesource.com/platform/external/avb/+/refs/heads/main/README.md | 1 | PREC | main | 2026-09-26 | X1 (wording UNVERIFIED) |
| S51 | Virtual A/B — Android — https://source.android.com/docs/core/ota/virtual_ab | 1 | PREC | current | 2026-09-26 | X1 |
| S52 | User Data Checkpoint — Android — https://source.android.com/docs/core/ota/user-data-checkpoint | 1 | PREC | current | 2026-09-26 | X1 |
| S53 | `ota_from_target_files.py` (`--downgrade`) — Android build — https://android.googlesource.com/platform/build/+/master/tools/releasetools/ota_from_target_files.py | 1 | SRC | master | 2026-09-26 | X1 |
| S54 | Rescue Party — Android — https://source.android.com/docs/core/tests/debug/rescue-party | 1 | PREC | current | 2026-09-26 | X1 |
| S55 | Disk format; Boot design; File system/autoupdate; Firmware boot and recovery — Chromium OS — https://www.chromium.org/chromium-os/ (design docs and developer library) | 1 (dated design docs) | PREC | undated | 2026-09-26 | X2 |
| S56 | Roll back ChromeOS to a previous version — Google — https://support.google.com/chrome/a/answer/12569990 | 1 | PREC | current | 2026-09-26 | X2 |
| S57 | Mender state scripts; update modules v3 file API — Mender — https://docs.mender.io/artifact-creation/state-scripts ; https://github.com/mendersoftware/mender (Documentation) | 1 | PREC | current | 2026-09-26 | X3 |
| S58 | RAUC: Using RAUC; Integration — RAUC — https://rauc.readthedocs.io/en/latest/using.html ; …/integration.html | 1 | PREC | latest | 2026-09-26 | X3 |
| S59 | Ubuntu Core recovery modes; remodel essential snaps; snap data locations; boot modes (snippet) — Canonical — https://documentation.ubuntu.com/core/ ; https://snapcraft.io/docs/ | 1 | PREC | current | 2026-09-26 | X4 |
| S60 | Windows RE technical reference; Quick Machine Recovery; Recovery options in Windows — Microsoft — https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-recovery-environment--windows-re--technical-reference ; https://learn.microsoft.com/en-us/windows/configuration/quick-machine-recovery/ ; support.microsoft.com | 1 | PREC | ms.date 2026-08-19; 2026-08-17 | 2026-09-26 | X5 |
| S61 | Deciphering Windows safe boot and last known good (archived blog) — Microsoft — learn.microsoft.com/archive/blogs/astebner | 2 | PREC | archived | 2026-09-26 | X5 |
| S62 | Apple Platform Security: boot modes; Signed System Volume; macOS Recovery support — Apple — https://support.apple.com/guide/security/ ; https://support.apple.com/en-us/102518 | 1 | PREC | current | 2026-09-26 | X6 |
| S63 | Chrome user data snapshots (rollback) — Google — https://support.google.com/chrome/a/answer/9917429 | 1 | PREC | current | 2026-09-26 | X7 |
| S64 | Bug 1535116 (profile downgrade protection) — Mozilla — https://bugzilla.mozilla.org/show_bug.cgi?id=1535116 | 2 | ISSUE | 2019 | 2026-09-26 | X7 |
| S65 | Upgrading a PostgreSQL cluster — PostgreSQL — https://www.postgresql.org/docs/current/upgrading.html | 1 | PREC | 18.6 | 2026-09-26 | X7 |
| S66 | `SQLiteOpenHelper.onDowngrade` — Android (Microsoft .NET mirror of the Android reference) | 1 (mirror) | PREC | current | 2026-09-26 | X7 |

Earlier project evidence: RES-0003, RES-0004, RES-0005 (and their
versioned lab directories), RES-0006, RES-0007; review records
`WAVE-0.1B-REVIEW.md` and `WAVE-0.1C-REVIEW.md`.
