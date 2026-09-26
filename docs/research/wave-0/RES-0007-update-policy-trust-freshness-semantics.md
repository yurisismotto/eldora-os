# RES-0007 — Update Policy, Trust & Freshness Semantics (Wave 0.1C-B)

| Field | Value |
|---|---|
| ID | RES-0007 |
| Title | Update Policy, Trust & Freshness Semantics |
| Status | REVIEWED |
| Wave | 0.1 (sub-stage 0.1C-B — Update Policy, Trust & Freshness Semantics, parent 0.1C) |
| Related questions | Q-0008 |
| Author(s) | Claude Opus 5.5 (AI agent, Claude Code), at the request of the Project Owner |
| Responsible human | Project Owner |
| Agent assistance | Claude Opus 5.5 (Claude Code): verification of the repository preconditions; planning; documentary research through five delegated read-only research sub-agents (A: OCI/containers-image/bootc trust; B: TUF, Sigstore, Notary, SLSA/in-toto; C: update-policy primitives and precedents; D: freshness/anti-rollback/downgrade precedents; E: privacy, clock/time, offline); author spot-checks of load-bearing local man-page quotes; re-analysis of RES-0003 to RES-0006 and their versioned lab scripts; analysis and drafting. Process deviations are disclosed under "Method and limitations". Lifecycle status and review metadata updated by the agent on Project Owner instruction after review; the report body is unchanged. |
| Reviewer(s) | Project Owner (human review, 2026-09-26; outcome: APPROVED AS RESEARCH — see [review record](../../project/reviews/WAVE-0.1C-REVIEW.md#review-of-res-0007-wave-01c-b)) |
| Created | 2026-09-26 |
| Last updated | 2026-09-26 |
| Review date | 2026-09-26 |
| Confidence | MEDIUM (documentary; see "Confidence and limitations") |
| Supersedes | — |
| Superseded by | — |

> This research does not take decisions. It informs the Project Owner.
> Decisions are recorded only in decision records accepted by the Project
> Owner. ADR-0001 (M3 SELECTED FOR V1) is **not** reopened by this report.
> Q-0008 remains **NOT DECIDED**. RISK-0010 remains **OPEN / RELEASE
> BLOCKER FOR M3**. No probe was executed (P-01 included); no VM was
> started; nothing was implemented. No policy, channel name, signing
> solution, retention count or threshold is selected here.
>
> **Review status:** REVIEWED — approved as research by the Project Owner
> on 2026-09-26. The review does **not** accept R1–R9 as architectural
> decisions, does not accept the candidate requirements (`R-…`, `HC-…`,
> `HD-…`) and does not authorise implementation. The Project Owner's
> conclusions are recorded in the
> [review record](../../project/reviews/WAVE-0.1C-REVIEW.md#review-of-res-0007-wave-01c-b).

Labels used: **FACT** (documented upstream, cited `[Sn]`), **OBSERVED**
(versioned laboratory evidence in RES-0004/RES-0005, cited `[RES-000x]`),
**INFERENCE** (reasoned from facts/observations), **HYPOTHESIS** (to be
tested), **RECOMMENDATION** (not a decision), **OPEN QUESTION**.
`UNVERIFIED` marks a claim that could not be confirmed from an allowed
primary source. Candidate requirements are labelled `R-…` and are
**proposals**, not Owner requirements.

## Question

Which update, trust and freshness policies must Eldora OS V1 define on top
of bootc/OCI to offer updates that are safe, predictable, controllable by
the machine owner and compatible with the principles Simple, Powerful,
Private, Open and Secure?

## Scope

Parts 1–28 of the 0.1C-B brief (Project Owner instruction, 2026-09-26):
policy model per phase; simple-by-default semantics; power-user controls;
owner control; network, power and storage policy inputs; deferral; release
channels; major-version transitions; trust chain; OCI/containers-image
trust; trust roots; key rotation/revocation; freshness; anti-rollback;
TUF/update frameworks; provenance boundary; compromised registry;
compromised signing authority; clock; offline update; privacy; managed
devices; upstream capability map; policy state model; threat model;
principle evaluation. Default backend: OSTree (as in RES-0004 to RES-0006).

## Out of Scope

Health, `BOOTED`/`HEALTHY`/`KNOWN_GOOD`, health gates, automatic rollback
triggers, rollback-loop behaviour, recovery architecture, `/var`
compatibility and boot-chain recovery (owned by **0.1C-C**; only
requirements are forwarded). Build pipeline, production registry, signing
infrastructure, key custody, CI/CD, publishing, provenance/SBOM production
and release promotion (owned by **0.1D**; only requirements are
forwarded). UI design; APIs, D-Bus interfaces or schemas; implementing the
Update Supervisor; network detection; executing any probe (P-01 to P-16);
starting 0.1C-C, 0.1C-F or 0.1D; reopening ADR-0001; closing or re-rating
risks; creating RISK-IDs or ADRs.

## Preconditions verified (2026-09-26, repository state at `df39d5f`)

Wave 0.1C-A CLOSED; RES-0006 REVIEWED; ADR-0001 ACCEPTED; OB-0004
(Fedora-derived V1) CONFIRMED; M3 bootc/OCI SELECTED FOR V1; Q-0008 IN
RESEARCH / NOT DECIDED; RISK-0010 OPEN / RELEASE BLOCKER FOR M3;
RISK-0012 to RISK-0016 OPEN; 0.1C-B, 0.1C-C and 0.1C-F PLANNED / not
started; 0.1D PLANNED. No divergence found. This report moves 0.1C-B to IN
PROGRESS only (see the administrative changes in the same change set).

## Method and limitations

- Documentary research on 2026-09-26 by five read-only research
  sub-agents constrained to public documentation, specifications, local
  man pages and (only where strictly necessary) anonymous read-only views
  of public issue-tracker and source pages, followed by author spot-checks
  of load-bearing local man-page quotes (marked "(verified)").
- Local Tier-1 sources on the Project Owner's Fedora 44 workstation,
  read-only: containers-common 0.67.2-1.fc44 (containers-policy.json(5),
  containers-signature(5), containers-registries.d(5),
  containers-registries.conf(5), containers-transports(5) and the shipped
  `/etc/containers` files), skopeo 1.22.3, systemd 259.9 man pages,
  NetworkManager 1.56.1, upower 1.91.4, chrony 4.9, dnf5 5.4.5,
  gnome-software 50.4 schema, flatpak 1.18.2, fedora-gpg-keys 44-2.
  **bootc, ostree and rpm-ostree are not installed on this host**; their
  behaviour comes from upstream documentation and source pages only.
- `docs.fedoraproject.org` returned a bot-protection ("Anubis") access
  denied page to all sub-agents; it was not bypassed. Fedora bootc
  auto-update and Fedora CoreOS stream pages were read from their public
  AsciiDoc sources where available, or are marked UNVERIFIED.
- Web fetches pass through a summarising tool; quotes not marked
  "(verified)" or "(verbatim, local)" may carry paraphrase drift and must be
  re-checked before citation in a decision record.
- Source-code pages were read at upstream `main` on 2026-09-26, not pinned
  to versions Fedora ships; behaviour of shipped versions may differ.
- **Process deviations (disclosed):**
  1. One sub-agent (B) downloaded the public TUF specification HTML page
     (~250 KB) with anonymous `curl` into the job scratch directory instead
     of the web-fetch tool, to quote it exactly.
  2. One sub-agent (D) fetched ordinary public documentation pages (each
     < 1 MB; ostreedev.github.io, coreos.github.io, bootc.dev,
     docs.flatpak.org, chromium.org, source.android.com,
     android.googlesource.com, uptane.org, the TUF spec site,
     docs.sigstore.dev) with a small Python `urllib` script into the job
     scratch directory because the fetch tool truncated them.
  3. Sub-agents viewed public github.com / raw.githubusercontent.com pages
     anonymously (issue/PR pages as Tier 2; specification documents and
     source files hosted there as Tier 1), as permitted by the brief "when
     strictly necessary". No `gh`, API, login, clone, fetch, write, registry
     contact, image pull, sudo, package installation or VM was used.
  All scratch files live under the job scratch directory, outside the
  repository.

## Definitions (used consistently in this report)

| Property | Meaning here | Question it answers | Typical mechanism |
|---|---|---|---|
| **INTEGRITY** | The bytes received are the bytes that were identified. | "Was it modified?" | Content addressing (digest), transport TLS |
| **AUTHENTICITY** | The artefact (or its identifier) was endorsed by a key/identity the client recognises. | "Who vouches for it?" | Signature over a manifest digest |
| **AUTHORIZATION** | The Eldora release authority intends *this* artefact for *this* machine's channel/target now or in principle. | "Is it meant for me?" | Signed identity/channel binding, signed release metadata |
| **FRESHNESS** | The client's view of "what is current" is recent, not stale or frozen. | "Am I seeing the latest intended state?" | Signed, expiring, versioned metadata (e.g. TUF timestamp) |
| **ANTI-ROLLBACK** | The client never *automatically* moves to an artefact older than a floor it already trusts. | "Is this going backwards?" | Monotonic version/timestamp floor, persisted locally |

Three problems are kept separate throughout:

1. **POLICY** — *when* Eldora checks, resolves, fetches, stages and asks
   to apply an update.
2. **TRUST** — *why* Eldora accepts an artefact as authorised.
3. **FRESHNESS** — *why* an authentic, authorised artefact is also the
   appropriate/current one and not a replay, freeze or downgrade.

**USER ROLLBACK** (returning to a retained, previously booted deployment,
or an owner-directed downgrade) is distinct from **SECURITY
ANTI-ROLLBACK** (refusing attacker- or accident-induced movement to older
artefacts).

## Facts

### Policy primitives (P-series)

- **FACT P1 — bootc upgrade verbs.** `bootc upgrade` options: `--quiet`,
  `--check`, `--apply`, `--soft-reboot=required|auto`, `--download-only`,
  `--from-downloaded`, `--tag`. `--check` "only downloads the updated
  manifest and image configuration (typically kilobyte-sized metadata)"
  [S14]. By default "the update will be applied at shutdown time via
  `ostree-finalize-staged.service`"; upstream states this "is likely to
  change such that reboots outside of a `bootc upgrade --apply` do _not_
  automatically apply the update" [S14, S15; RES-0006 L5, L8].
- **FACT P2 — download-only.** A download-only staged deployment is
  discarded if the machine reboots before it is applied, while "the
  downloaded image data remains cached"; `--from-downloaded` applies it
  without checking for a newer one [S15; RES-0006 L7]. The mechanism is
  OSTree finalization locking (`ostree admin deploy --lock-finalization`)
  [S41].
- **FACT P3 — upstream auto-update units.** Upstream
  `bootc-fetch-apply-updates.service` runs `bootc upgrade --apply --quiet`;
  its timer uses `OnBootSec=1h`, `OnUnitInactiveSec=8h`,
  `RandomizedDelaySec=2h`; no `ConditionACPower`, no metered condition, no
  network-online ordering (INFERENCE from file contents) [S21]. The
  bootc.dev man page describes "daily" checks — **documentation vs source
  discrepancy** [S21]. OBSERVED: the timer was disabled on both lab
  installs (RES-0004 DV1, RES-0005 DV1).
- **FACT P4 — rpm-ostree policy.** `AutomaticUpdatePolicy` = `none`
  (default), `check`, `stage`, `apply`; "stage" "downloads and unpacks the
  update, queuing it for the next boot. This leaves initiating a reboot to
  other automation tools"; "apply" "will currently always initiate a
  reboot"; reboots "default to honoring active systemd inhibitors" [S25].
- **FACT P5 — Zincati (Fedora CoreOS).** Finalization strategies
  `immediate` (default), `periodic` (weekly maintenance windows) and
  `fleet_lock`; auto-updates can be disabled (`[updates] enabled=false`);
  downgrades are refused unless `allow_downgrade=true`, which "may allow
  rogue Cincinnati servers to induce downgrades to old releases with known
  security vulnerabilities" [S28, S29]. With active interactive sessions
  Zincati broadcasts a reboot warning and delays about 10 minutes (Tier 2)
  [S85].
- **FACT P6 — desktop precedents.** GNOME Software (50.4, local schema):
  `download-updates` default true; `refresh-when-metered` default **false**
  [S70]. Endless eos-updater: `LastAutomaticStep` 0–3 (none / poll /
  +fetch / +apply) and randomised scheduling [S71].
- **FACT P7 — status fields.** bootc status exposes `staged`, `booted`,
  `rollback`, `other_deployments` (pinned), `rollbackQueued`,
  `cachedUpdate`, `downloadOnly`, `pinned`, `softRebootCapable`; image
  status carries image, version, timestamp, digest and architecture, but
  **no download size** [S19; RES-0006 Part 3].
- **FACT P8 — network primitives.** NetworkManager `Metered`: UNKNOWN,
  YES (explicit), NO, GUESS_YES, GUESS_NO; connectivity: UNKNOWN, NONE,
  PORTAL ("hijacked by a captive portal"), LIMITED, FULL [S72]. Fedora
  ships a connectivity check URI (`fedoraproject.org/static/hotspot.txt`,
  300 s interval) [S72]. bootc "honors almost all the same configuration
  options in `/etc/containers`", including mirrors [S22];
  containers-registries.conf(5) mirrors are tried in order, primary last,
  with `mirror-by-digest-only` / `pull-from-mirror` [S5]. ostree-ext caches
  layers by content digest, so an interrupted pull resumes **per layer**
  (INFERENCE: not per byte) [S20]. Proxy handling for bootc host pulls is
  **UNVERIFIED**.
- **FACT P9 — power primitives.** `ConditionACPower=true` holds when an AC
  connector is connected "or if no AC connectors are known" (desktops
  pass) [S74]. logind inhibitors (`shutdown`, `sleep`, `idle`,
  `handle-*`; modes `block`, `block-weak`, `delay`); `LidSwitchIgnoreInhibited=`
  defaults to `yes` [S74]. UPower exposes `OnBattery`, `Percentage`,
  `WarningLevel`, `TimeToEmpty` [S73]. `ostree-finalize-staged.service`
  does its work as `ExecStop=` with a 5-minute timeout [S47]; the `/etc`
  merge is "delayed until the system is rebooted or shut down" [S47].
  INFERENCE: suspend/hibernate neither finalize nor discard a staged
  deployment (untested).
- **FACT P10 — storage primitives.** OSTree `min-free-space-percent`
  (default 3) / `min-free-space-size` ("the smaller of the two limits is
  used") [S42]; `ostree admin pin` keeps a deployment from default garbage
  collection [S46]; OCI descriptors carry a `size` [S11]; ostree-ext can
  enumerate layers still to fetch before fetching [S20]. No bootc document
  states the required download size before a pull [S14, S19].
- **FACT P11 — external deferral precedents.** Windows Update for Business:
  "The *effective deadline* is whichever is the later of the scan discovery
  time plus the specified deadline or the restart required time plus the
  grace period"; after it "the device is forced to restart regardless of
  active hours"; the grace period protects users "returning from vacation"
  [S68]. Chrome relaunch notifications: "Recommended" vs "Required",
  default period 7 days; ChromeOS relaunch window default 02:00–04:00
  [S69].

### Trust primitives (T-series)

- **FACT T1 — policy types.** containers-policy.json(5) has exactly four
  requirement types: `insecureAcceptAnything`, `reject`, `signedBy` (GPG
  only) and `sigstoreSigned`; "all of the requirements must be satisfied
  simultaneously"; only the most specific scope applies [S1, S2].
- **FACT T2 — identity rules.** `signedIdentity`: `matchExact`,
  `matchRepoDigestOrExact` (default when absent), `matchRepository`,
  `exactReference`, `exactRepository`, `remapIdentity` [S1]. `dir:` and
  `oci:` scopes "can be only used with exactReference or exactRepository"
  [S1].
- **FACT T3 — cosign signatures carry no tag (verified).** "Note that
  cosign-created signatures only contain a repository, so only
  matchRepository and exactRepository can be used to accept them (and that
  does not protect against substitution of a signed image with an
  unexpected tag)" [S1] (verified, local man page). OBSERVED: the RES-0004
  lab signed with `podman push --sign-by-sigstore-private-key`
  (`RES-0004-lab/vm/a-build-images.sh`), whose signatures embed the tagged
  reference; that is why the default identity rejected cross-tag replay
  (T7b) and promotion (T7c) [RES-0004 PB5]. **INFERENCE:** the strength of
  identity binding depends on the signing tool/format chosen in 0.1D.
- **FACT T4 — sigstoreSigned trust material (0.67.2).** Exactly one of
  `keyPath(s)`/`keyData(s)`, `fulcio` (CA + `oidcIssuer` + `subjectEmail`,
  Rekor key mandatory) or `pki` (CA roots + intermediates + subject
  hostname/email) [S1] (verified). No revocation (CRL/OCSP), expiry or TUF
  mechanism is documented in the man page (verified: no match for
  "revoc", "crl", "ocsp") [S1].
- **FACT T5 — what a simple-signing payload covers (verified).**
  `critical.identity.docker-reference`,
  `critical.image.docker-manifest-digest`, `critical.type`;
  `optional.creator`, `optional.timestamp` ("identifies the time when the
  signature was created"); the only expiry rule is that the cryptographic
  "signature MUST NOT be expired" [S3] (verified). In source,
  `optional.timestamp` is carried as an untrusted, informational field and
  not used in acceptance decisions [S8].
- **FACT T6 — Rekor gives log presence, not freshness.** For public-key
  sigstore verification, source comment: "We don't care about the Rekor
  timestamp, just about log presence"; for Fulcio, the certificate is
  checked at the Rekor integrated time (making short-lived certificates
  usable later) [S8]. Sigstore timestamps prove signing time within the
  certificate validity window [S55].
- **FACT T7 — signature discovery.** Sigstore signatures are read only if
  `use-sigstore-attachments` is enabled for the registry/repository in
  `registries.d` (built-in default: not read) [S4, S1]. containers/image
  locates them by the tag `sha256-<hex>.sig`, not via the OCI referrers API
  (source) [S9]. **UNVERIFIED (Tier 4 only):** cosign 3.x new-format
  bundles stored as OCI referrers are invisible to podman/skopeo/bootc
  while `cosign verify` passes [S80].
- **FACT T8 — digests.** "The digest property of a Descriptor acts as a
  content identifier, enabling content addressability"; "If the digest can
  be communicated in a secure manner, one can verify content from an
  insecure source by recalculating the digest" [S11]. Tags are pointers; "A
  manifest digest may have zero, one, or many tags referencing it" [S12].
  `org.opencontainers.image.version` / `.created` are annotations/labels
  [S11]. INFERENCE: the image configuration (and its labels) is referenced
  by digest from the manifest, so a signature over the manifest digest
  transitively authenticates the labels.
- **FACT T9 — bootc verification.** bootc "honors the default
  /etc/containers/policy.json"; "It is not a vulnerability in bootc that
  signatures are not required by default" [S17].
  `--enforce-container-sigpolicy` exists on `switch` and `install` (not on
  `upgrade`) [S16, S18, S14]; the origin records the signature mode
  (`ContainerPolicy`, `ContainerPolicyAllowInsecure`, `OstreeRemote`)
  [S19, S20]. The "best effort to reject `default: insecureAcceptAnything`"
  inspects only the top-level `default` of `/etc/containers/policy.json`,
  not per-transport or per-scope entries (source) [S19, S20].
  `ostree-remote-*` origins "Cannot currently verify layered containers"
  (source) [S20]. INFERENCE (from source, untested): `bootc upgrade`
  reuses the booted origin and its signature mode.
- **FACT T10 — Fedora defaults.** Fedora 44 ships
  `/etc/containers/policy.json` with `default: insecureAcceptAnything` and
  no `use-sigstore-attachments` entry for quay.io/fedora [S7]. No Fedora
  F44/F45 Change establishes sigstore/cosign signing of Fedora bootc or
  Atomic images; Fedora infrastructure has documented cosign signing but
  noted blockers (Tier 2) [S79]. Whether quay.io/fedora images are signed
  today: **UNVERIFIED** (would require registry access, forbidden).
- **FACT T11 — local builds.** Locally built images carry no signature
  unless one is created in storage; bootc deploys them as
  `ostree-unverified-image` [S10; RES-0004 PB2; RES-0005 E2].
- **FACT T12 — offline transports.** The OCI image layout destination does
  not store containers/image signatures ("Pushing signatures for OCI images
  is not supported", source; string present in the local skopeo binary);
  `dir:` stores "the manifest, layer tarballs and signatures as individual
  files" [S6, S10, S82]. bootc supports `switch --transport oci|oci-archive|
  containers-storage` and documents USB/offline flows [S16, S22].

### Freshness and anti-rollback primitives (F-series)

- **FACT F1 — no freshness in the OCI/bootc chain.** No expiry, version
  ordering or "latest" statement exists in containers/image signatures or
  policy [S1, S3, S8]. bootc decides "No update available" by comparing
  manifest digests; no version/timestamp comparison or downgrade refusal
  was found in the reviewed code or in any bootc document (absence of
  evidence outside the reviewed files: UNVERIFIED) [S14, S15, S19].
  OBSERVED: an old signed image served under a moved tag was accepted with
  `matchRepository` (RES-0004 T7a).
- **FACT F2 — OSTree native had timestamp monotonicity.**
  `ostree_sysroot_upgrader_check_timestamps`: "Check that the timestamp on
  to_rev is equal to or newer than from_rev. This protects systems against
  man-in-the-middle attackers which provide a client with an older commit"
  [S37]; pull option `timestamp-check` [S38]; `ostree admin upgrade
  --allow-downgrade` ("Permit deployment of chronologically older trees")
  [S40]; `rpm-ostree upgrade --allow-downgrade` [S26]. Whether this check
  applies to container origins: **UNVERIFIED** [S24, S26].
- **FACT F3 — OSTree ref binding.** A commit can carry signed ref/collection
  bindings; pull "will enforce that the commit was retrieved from one of
  the branch names in this array"; `ostree pull --disable-verify-bindings`
  exists [S44, S45 (Tier 3 rendering)]. Summary metadata
  `ostree.summary.expires` is cache semantics ("similar to the HTTP Expires
  header"); no client rejection of expired summaries is documented [S39].
  `ostree.commit.version` is "freeform" and not interpreted semantically
  [S45].
- **FACT F4 — Fedora CoreOS.** Cincinnati graph (DAG, each edge a valid
  transition); barriers ("Releases older than a certain barrier must first
  update to it"), dead-ends and rollout parameters (Tier 2) [S31, S34];
  client-side "age index" prevents automatic downgrades [S28]; barriers
  exist "to make sure that older (and possibly stale) instances
  automatically receive and trust newly generated keys" [S32]. Whether the
  graph is signed: **UNVERIFIED**. FCOS is moving its update graph towards
  an OCI artifact (Tier 2) [S35, S36].
- **FACT F5 — TUF 1.0.36 (2026-08-05).** Roles root/targets/snapshot/
  timestamp (+ optional mirrors), thresholds, expiry, monotonic versions;
  "Clients MUST NOT trust an expired file"; "Clients MUST NOT replace a
  metadata file with a version number less than the one currently
  trusted"; root N+1 must be signed by a threshold of root N **and** of root
  N+1; "all released versions of root metadata files MUST always be
  provided so that outdated clients can update"; "If a threshold of root
  keys is compromised … safely recovering from it is nearly impossible";
  timestamp key online, others "should be stored securely offline"; freeze
  by withholding root is "limited by the expiration time of the latest root
  metadata available to the client"; the spec lists rollback, indefinite
  freeze, mix-and-match, fast-forward, endless-data and key-compromise
  attacks [S48]. Clock: expiry is checked against a "fixed update start
  time"; §7.1 notes a possible "'no, my clock is _supposed_ to be wrong'
  mode" as future work [S48]. Targets `custom` may carry version numbers,
  enforcement left to the application [S48].
- **FACT F6 — TUF around OCI.** No accepted TAP standardises TUF metadata
  in OCI registries; TAP 19 (draft, content-addressable systems) discusses
  OSTree but not OCI [S50]. Sigstore distributes its own trust root with
  TUF and re-signs online roles "at least every three days" [S51, S54].
  Docker Content Trust (Notary v1, TUF-based) is being retired; notary.docker.io
  shuts down on 2026-12-08 (vendor blog, Tier 2) [S59].
- **FACT F7 — Uptane 2.1.0.** Director (online) vs Image repository
  (offline keys); image metadata may carry a release counter "to prevent
  rollback attacks even in cases where the Director repository is
  compromised"; "ECUs SHALL have a secure source of time"; too-far-ahead
  clocks cause denial of service, too-far-behind clocks allow freeze/replay
  [S52, S53].
- **FACT F8 — floor after known-good (precedents).** Android AVB:
  "stored_rollback_index[n] should only be updated from slots that are
  marked as SUCCESSFUL"; the device rejects an image unless
  `rollback_index >= stored_rollback_index` [S66]. ChromeOS firmware: the
  stored key/firmware version is updated from `min(A, B)` and "on
  successful boot with the new firmware" [S64]; ChromeOS enterprise
  rollback "wipe[s] all local data" and is impossible across firmware/kernel
  rollback protection [S65]. Shim SBAT generations "should only ever go up"
  [S67].
- **FACT F9 — Notary Project.** Notation trust policy verifies signer-set
  expiry and revocation (OCSP/CRL) at `strict` level; expiry is "a 'best by
  use' time … as defined by the signer"; no version monotonicity [S58].
- **FACT F10 — Fedora key continuity.** `fedora-gpg-keys-44-2` on Fedora 44
  already ships RPM keys for Fedora 45, 46 and rawhide (local) [S81].
  INFERENCE: Fedora pre-distributes future keys so that later transitions
  verify without a trust bootstrap step.

### Privacy, time and offline primitives (X-series)

- **FACT X1 — what a pull reveals.** A pull is `GET
  /v2/<name>/manifests/<tag-or-digest>` then `GET /v2/<name>/blobs/<digest>`
  [S12], optionally preceded by an anonymous token request carrying
  `service` and `scope` [S13]. containers/image sends a `User-Agent` naming
  the library and version; no machine identifier was found in the client
  code reviewed [S9]; bootc's own user-agent/identifier behaviour:
  **UNVERIFIED** [S22]. INFERENCE: a registry/CDN necessarily sees client
  IP, request times, repository, tag/digest, blob digests and tool version.
- **FACT X2 — counting without IDs.** DNF countme sends a weekly age bucket
  on a normal metalink request, no UUID ("We don't want to track; just
  count") [S78]; rpm-ostree implements the same with
  `rpm-ostree-countme.timer` [S27]. Zincati sends `node_uuid` derived by
  hashing `/etc/machine-id` with an application ID to the Cincinnati server
  [S30, S31]. Fedora CoreOS removed its never-completed telemetry agent in
  favour of countme (Tier 2) [S84].
- **FACT X3 — client-side rollout randomness.** Zincati
  `rollout_wariness` (0.0–1.0) [S28, S30]; systemd `RandomizedDelaySec=`,
  `FixedRandomDelay=` (derived locally from machine ID; nothing sent)
  [S74].
- **FACT X4 — clock.** systemd advances the clock at boot to the highest of
  the systemd build time, the mtime of `/usr/lib/clock-epoch` and the mtime
  of `/var/lib/systemd/timesync/clock` (verified, local) [S74]; a clock
  more than 15 years ahead is rewound [S74]. Fedora 44 enables chronyd and
  disables systemd-timesyncd by preset [S75]; NTS is not enabled by default
  in Fedora [S76]. Roughtime is an IETF draft [S77]. INFERENCE: on default
  Fedora, the boot-time clock floor is effectively the systemd build time
  (plus any `/usr/lib/clock-epoch` an image ships) until NTP succeeds.

## Hypotheses

- **HYPOTHESIS HB1:** a client-side monotonic floor keyed on a signed
  image label (version or build timestamp) can be evaluated after
  `bootc upgrade --check` (manifest + configuration only) and before any
  layer download. Depends on bootc exposing the fetched configuration
  labels (`cachedUpdate.version`/`timestamp`, FACT P7). Probe P-18.
- **HYPOTHESIS HB2:** image-shipped updates to `/etc/containers/policy.json`
  or `registries.d` do not reach machines where the owner edited those
  files (whole-file `/etc` merge, RES-0003 FS3). Probe P-19.
- **HYPOTHESIS HB3:** a signature over a manifest in an OCI archive cannot
  be carried and verified by bootc without an additional mechanism
  (FACT T12). Probe P-20.
- **HYPOTHESIS HB4:** the rpm-ostree/OSTree timestamp check does not apply
  to bootc container origins (FACT F1/F2). Probe P-18.

## Part 1 — Update policy model

### Phase × control modes (INFERENCE from P1–P11)

Modes: **AUTO** automatic; **USER** user-initiated; **CONF**
user-confirmable (proposed by the system, confirmed by the user); **SCHED**
scheduled; **POL** policy-constrained (network/power/disk/deferral
conditions); **ADMIN** admin-controlled.

| Phase | Upstream primitive | Feasible modes | Notes / constraints |
|---|---|---|---|
| Update check | `bootc upgrade --check` (kB metadata) [P1] | AUTO, USER, SCHED, POL, ADMIN | Low cost; exposes online presence (X1); freshness-relevant: "could not check" ≠ "up to date" |
| Metadata / image resolution | tag → manifest digest (+ config) | AUTO, POL | Eligibility (channel, version floor, freshness) must be decided **here**, before fetch (RES-0006 Part 1) |
| Download / fetch | `bootc upgrade --download-only` (pull + import + stage-locked) [P2] | AUTO, USER, SCHED, POL, ADMIN | Size up to ~2.4 GB (major) / ~160 MB (revision) [RES-0005]; metered/battery/disk gates |
| Verification | containers/image policy inside fetch [T1] | AUTO only (never user-skippable by default) | Signature/identity; freshness/anti-rollback are **not** covered upstream (F1) |
| Staging | stage (unlocked) or stage-locked (download-only) [P1, P2] | AUTO, USER, POL | Unlocked staging applies at any orderly shutdown/reboot (P1) → "update surprise"; locked staging is discarded on reboot (P2) |
| Reboot / apply | `--apply` always reboots; `--from-downloaded`; `--soft-reboot` [P1] | USER, CONF, SCHED, POL, ADMIN; AUTO only in some profiles | Data-loss risk; RISK-0010/0012 windows |
| Post-boot validation boundary | none upstream (RES-0006 Part 6) | AUTO (0.1C-C) | Policy must not declare success before 0.1C-C's boundary |
| Rollback boundary | `bootc rollback` (manual) | USER, ADMIN; AUTO per 0.1C-C | Policy must suppress re-application of a rolled-back target (RISK-0015) |

### Policy alternatives (not selected)

| ID | Alternative | Check | Fetch+verify | Stage | Apply | Precedent |
|---|---|---|---|---|---|---|
| PA | Manual | USER | USER | USER | USER | rpm-ostree `none` default [P4] |
| PB | Notify-only | AUTO | USER | USER | USER | rpm-ostree `check`; eos-updater step 1 |
| PC | Background download, restart on request | AUTO/POL | AUTO/POL | AUTO (locked) | USER/CONF/SCHED | GNOME Software `download-updates` [P6]; bootc `--download-only` [P2] |
| PD | Background stage, apply at next orderly restart | AUTO/POL | AUTO/POL | AUTO (unlocked) | any orderly reboot | rpm-ostree `stage` [P4]; current bootc default semantics [P1] |
| PE | Background stage + maintenance window reboot | AUTO/POL | AUTO/POL | AUTO | SCHED (window) | Zincati `periodic` [P5]; Windows/Chrome windows [P11] |
| PF | Fully automatic | AUTO | AUTO | AUTO | AUTO immediate | upstream `bootc-fetch-apply-updates` (`--apply`) [P3]; Zincati `immediate` [P5] |

Comparison (INFERENCE):

| Criterion | PA | PB | PC | PD | PE | PF |
|---|---|---|---|---|---|---|
| Security latency | worst | poor | good (restart-bound) | good | good | best |
| Update surprise | none | none | none (explicit restart) | **high** (any reboot applies) | medium (known window) | **very high** |
| Data-loss risk from reboot | none | none | none | low | medium (unattended) | **high** on desktops |
| Bandwidth/metered exposure | none | minimal | gated by POL | gated by POL | gated by POL | ungated upstream (P3) |
| RISK-0012 (abrupt loss after staging) exposure | short | short | none by design (locked stage is discarded on reboot; intent must be recorded anyway) | **long window** | window until reboot | short |
| Dependence on uncertain upstream semantics | none | none | depends on `--download-only`/`--from-downloaded` | depends on "reboot applies" (upstream says may change, P1) | as PD | depends on `--apply` |
| Suitability, personal desktop | poor | poor | **strong** | medium | medium | poor |
| Suitability, managed/kiosk | poor | poor | medium | medium | **strong** | strong |

Key observation (INFERENCE): because upstream may stop applying staged
updates on reboots outside `bootc upgrade --apply` (P1), any Eldora policy
must **own the "apply on next restart" semantics explicitly** instead of
relying on the current implicit behaviour (candidate requirement R-P3).

## Part 2 — Simple by default (semantics only; no UI)

| Question | Finding / candidate semantics |
|---|---|
| Automatic check? | Yes, candidate: periodic, randomised (X3), privacy-minimal (Part 23). Rationale: security latency; `--check` is kB-level (P1). |
| Automatic download? | Yes, candidate, **policy-constrained** (metered, power, disk; Parts 5–7). |
| Automatic staging? | Yes, candidate, but in a state that does **not** apply on an arbitrary reboot unless the owner has chosen that (locked staging or equivalent, PC); see Part 1 comparison. |
| Automatic reboot? | Not by default on personal devices (Part 8, H3). |
| Must the user understand "deployment"? | No. The user-facing model can be "current system", "update ready", "previous system available". "Deployment" belongs to advanced views (Part 3). |
| Must the user understand "image digest"? | No. Digest is an identifier for diagnostics and support. A human-readable version must exist and be **signed** (T8 INFERENCE). |
| Avoid unnecessary prompts | Prompt only at decision points: restart, explicit trust changes, major transitions (Part 10), owner-overridable policy boundaries. Never prompt for verification outcomes (always enforced). |
| Avoid update surprise | No application of an update on a restart the user did not intend as "restart to update" (R-P3); announce what a restart will do. |
| Communicate "ready to restart" | Event only when: target verified, eligible, staged, intent recorded, and pre-restart checks (e.g. `/boot` writable, RISK-0010 C-R1/C-R3) pass. |
| Communicate failure before reboot | Persisted, classified failure record (fetch, verification, eligibility, disk, network) — upstream failures are transient CLI errors (RES-0006 Part 3). |
| Communicate deferral | Deferral state must be persisted with its origin (user, policy, condition such as metered/battery) and a next-evaluation time. |
| Machines without reboot for weeks | Staged target may go stale (newer update published) — policy must re-resolve before apply (`--from-downloaded` does not check for newer [P2]); escalation per deferral model (Part 8); freshness of "update ready" state (Part 15). |

## Part 3 — Powerful when needed

| Capability | Classification | Notes |
|---|---|---|
| check now | SUPPORTED POWER-USER CAPABILITY (also cheap default action) | — |
| download now / stage now | SUPPORTED POWER-USER CAPABILITY | overrides metered/battery gates with explicit consent |
| defer | DEFAULT USER EXPERIENCE (simple form) + power form (explicit date) | Part 8 |
| schedule restart | DEFAULT USER EXPERIENCE (simple choices) | needs locked staging + explicit apply (P2) |
| select channel | SUPPORTED POWER-USER CAPABILITY | cross-channel semantics Part 9 |
| inspect current deployment / target version & digest | SUPPORTED POWER-USER CAPABILITY | `bootc status --json` [P7] |
| inspect update history | SUPPORTED POWER-USER CAPABILITY | requires Eldora-persisted history (RES-0006 Part 12) |
| manual rollback | SUPPORTED POWER-USER CAPABILITY; recovery entry is 0.1C-C | Part 16 |
| pin/hold | SUPPORTED POWER-USER CAPABILITY | must be visible as "not receiving updates" state |
| controlled downgrade | SUPPORTED POWER-USER CAPABILITY with explicit, logged owner action | Part 16 |
| advanced diagnostics | SUPPORTED POWER-USER CAPABILITY | local only (Part 23) |
| policy override | SUPPORTED POWER-USER CAPABILITY (owner/root only) | Part 4 |
| admin-managed policy | V1 EXTENSIBILITY REQUIREMENT | Part 24 |
| add/replace trust roots, local derived images | SUPPORTED POWER-USER CAPABILITY; not default | RISK-0006, T11, Part 4 |

Principle (RECOMMENDATION): every advanced capability is reachable through a
stable, documented local interface (CLI/API, not decided here) and the
default experience exposes only check/defer/restart/"previous system".

## Part 4 — Yours / owner control

The owner is root on the machine. Eldora **cannot** and should not attempt
to cryptographically override a legitimate owner (RES-0003 Part 13: local
root can overlay `/usr`; trust files live in `/etc`). The meaningful
boundary is therefore **who can change update behaviour and how visibly**:

| Actor | Should be able to change update/trust behaviour? |
|---|---|
| Network attacker, registry, mirror | Never (trust + freshness) |
| Unprivileged local user / applications | Only request benign actions (check, schedule restart); never trust, channel, downgrade, disable |
| Owner / administrator (root) | Everything, through explicit, logged, visible actions |
| Managed-device administrator (policy) | Within the managed profile, visibly to the local owner (Part 24) |

Concrete policies compared (secure-by-default vs owner control):

| Topic | Option A (secure-first) | Option B (owner-first) | Consequence |
|---|---|---|---|
| Deferral | bounded, then forced reboot | unbounded with escalation | A: exposure bounded, data-loss/surprise risk; B: exposure owner-chosen, visible |
| Reboot | forced after deadline | owner-initiated or owner-scheduled | see Part 8 |
| Channel | fixed by Eldora | owner-selectable among signed channels | B safe if channels are authorised by signed metadata (Part 9) |
| Rollback | only to retained deployments | also explicit downgrade | B requires anti-rollback exception semantics (Part 16) |
| Downgrade | forbidden | explicit, logged owner action | B viable if not reachable by non-owner actors |
| Local policy | read-only vendor policy | owner overrides via drop-in | B requires trust config not to freeze vendor updates (HB2, RC-M) |
| Offline operation | expire and block | continue, with visible "stale" state | B needs clock-independent anti-rollback (Part 21) |
| Local diagnostics | — | full local visibility | no conflict |
| Disable automatic download | not allowed | allowed | B: security latency owner's choice; state must be visible |
| Disable automatic checks | not allowed | allowed only as explicit, persistent, visibly "unprotected" state | technically trivial for root anyway (timers); refusing it only hides the state |
| Security-critical updates | forced install+reboot | expedited, escalated notification; no forced reboot on personal profile | Part 8 |

**Finding (INFERENCE):** the defensible limit between *Secure by default*
and *owner control* is: (1) security properties that protect the owner
against **third parties** (verification, authorization, freshness,
anti-rollback against automatic movement) are enforced by default and not
reachable by non-owner actors; (2) decisions that trade the owner's own
availability, data or bandwidth against exposure (when to reboot, whether
to download on metered, whether to defer) default to secure-leaning
behaviour but remain the owner's, **with the resulting state always
visible** ("not protected since …", "updates paused by you"); (3)
weakening a third-party protection (e.g. trusting a new key, accepting an
unsigned local image, downgrading) is possible for the owner only through
explicit, local, logged actions, never through a default path or a
network-supplied instruction. Forced reboot on a personal device is not
needed to be "secure by default" if (1) holds and (2) is visible; it
remains a legitimate *managed-profile* policy (Part 24).

## Part 5 — Network policy

| Situation | Upstream provides | Eldora must define |
|---|---|---|
| Metered | NM `Metered` incl. explicit vs guessed (P8); GNOME precedent: no refresh when metered (P6) | whether `--check` (kB) is allowed on metered; download never on explicit-metered without consent; treatment of GUESS_YES |
| Roaming / low bandwidth | NM metered (roaming usually flagged by NM — UNVERIFIED) | defer large downloads; allow owner override |
| Offline | nothing (fetch fails, F01 RES-0006) | distinguish "offline" from "up to date"; offline media path (Part 22) |
| Interrupted / resumable download | per-layer resume via ostree-ext cache (P8) | retry/backoff; stale-cache cleanup (P10); never treat partial as staged |
| Background bandwidth | none in bootc | bandwidth/IO niceness policy (UNVERIFIED that bootc exposes any) |
| Proxy | containers/image configuration; bootc host proxy **UNVERIFIED** | proxy source of truth for the host updater (probe P-24) |
| Enterprise network / mirrors | `registries.conf` mirrors, `mirror-by-digest-only` (P8) | mirror policy; note tag-tracking never uses digest-only mirrors [S5] |
| Captive portal | NM connectivity PORTAL/LIMITED (P8) | don't attempt/declare failures while PORTAL; TLS failures behind portals ≠ attack signal |
| Registry temporarily unavailable | CLI error only (RES-0006 F03) | retry; persisted "last successful check"; freeze visibility (Part 15) |

## Part 6 — Power / battery policy

| Situation | Evidence | Policy need (no thresholds selected) |
|---|---|---|
| Desktop (no battery) | `ConditionACPower` passes when no AC connector is known (P9) | power rarely constrains; unattended reboot still risks data loss |
| Laptop on AC | UPower `OnBattery=false` (P9) | normal |
| Laptop on battery | UPower `Percentage`, `WarningLevel`, `TimeToEmpty` | download/stage allowed above an evidence-based level; thresholds require probe P-22 |
| Low / critical battery | `WarningLevel` Low/Critical/Action | no staging; no reboot-to-update; never start finalization |
| Suspend / hibernate | finalization only in the shutdown path (P9, INFERENCE) | suspend does not apply or lose a staged update; abrupt battery death after staging = RISK-0012 case |
| Lid close | `LidSwitchIgnoreInhibited=yes` default (P9) | inhibitors cannot prevent lid suspend; fetch must tolerate suspend mid-download |
| Staging on battery | stage = pull + import (CPU/IO heavy) | policy-constrained |
| Reboot on battery | finalization `ExecStop` ≤ 5 min timeout (P9); boot-config swap is atomic (RES-0006 L12) | reboot-to-update requires AC or sufficient battery; energy/time cost unmeasured → P-22 |

Desktops and laptops need **different** default policies (INFERENCE). No
threshold is proposed without measurement.

## Part 7 — Storage policy

Information a future policy must know (INFERENCE from P7, P10):

1. free space on the filesystem holding `/sysroot` (object store) and on
   `/var` (logs, containers, user data share it in default layouts);
2. bytes still to fetch: from OCI descriptor sizes of layers not already
   cached (P10: descriptors carry `size`; ostree-ext can list layers to
   fetch) — **not** reported by bootc status (P7);
3. OSTree's own floor `min-free-space-*` (default 3 %) (P10);
4. the set of deployments that will exist after staging (booted, rollback,
   staged, pinned) and their shared vs unique object size;
5. whether an older cached, unreferenced image/layers can be pruned
   (`ostree container image prune`/GC; exact commands UNVERIFIED for bootc);
6. whether a staging failure left residue (RES-0006 F07, F08, OQ5).

**Cleanup vs rollback ability (INFERENCE, important):** retention is
booted + rollback (+ staged) + pinned (P7, P10). Staging a new update makes
the currently booted deployment the future rollback and drops the previous
rollback. Two successive updates **without** a confirmed known-good point
can therefore remove the last deployment that was actually good. GC itself
does not delete the rollback deployment; **staging does**. Retention and
pinning of a known-good deployment are 0.1C-C decisions; 0.1C-B requires
that storage policy never prunes a deployment 0.1C-C marks as protected and
never stages when doing so would remove the only protected fallback
(candidate R-S3). Retention count: **not selected** (depends on 0.1C-C).

## Part 8 — Update deferral

| Model | Personal desktop | Workstation | Managed device | Offline device | Main trade-off |
|---|---|---|---|---|---|
| No deferral | poor (surprise) | poor | acceptable with windows | n/a | exposure minimal; data loss/surprise |
| User-controlled indefinite deferral | acceptable only with escalation + visible exposure | good | poor | natural | exposure unbounded, owner-chosen |
| Bounded deferral (then forced) | contested (H3) | contested | **good** | not enforceable (no updates arrive) | bounded exposure vs control |
| Security-only forced deadline | contested | contested | good | n/a | needs **signed** urgency metadata; urgency is an attack surface if unsigned |
| Policy-defined deadline | n/a | optional | **good** (Windows precedent P11) | n/a | admin control; local owner visibility |
| Notification/escalation without forced reboot | **good** | **good** | insufficient alone | good | residual exposure visible, not bounded |

Findings (INFERENCE): (1) all profiles need persisted deferral state and a
reason; (2) security urgency must be a property of **signed release
metadata**, never of an unsigned channel hint, otherwise an attacker can
manufacture urgency (forced reboots as DoS) or suppress it; (3) the
Windows "deadline + grace period after return" idea (P11) addresses
machines that were offline/asleep; (4) forced reboot is a *managed*
feature, not a V1 personal default requirement (H3).

## Part 9 — Release channel semantics

| Aspect | Finding |
|---|---|
| Channel identity | Must be an Eldora-signed concept (name + authority), not a registry artefact. A tag can *transport* the pointer; it cannot *be* the identity (FACT T3, F1). |
| Is a channel mutable? | Yes — its target changes over time by definition. Mutability is exactly what an attacker exploits (RES-0004 T7a). |
| Tags vs security boundary | Tags are registry-mutable pointers (FACT T8); anyone controlling the registry can re-point them without keys (RES-0004 `a-retag.sh`). With **exact** identity, a tag-embedding signature binds image ↔ tag, blocking cross-tag replay but also promotion without re-signing (RES-0004 T7b/T7c). Even with exact identity, **every image ever signed for `:stable` stays valid for `:stable` forever** — same-tag replay of an older release is not prevented (INFERENCE from T5 + F1). With cosign-format signatures only repository identity is available (T3), so cross-tag substitution is also possible. |
| Target digest/version | The channel's *current target* should be stated as digest + monotonic version in signed metadata; the client pulls by digest (INFERENCE). |
| Upgrade | Target version > current floor within the channel. |
| Downgrade | Never automatic; explicit owner action (Part 16). |
| Channel switching / cross-channel | Moving from a faster to a slower channel can mean a *lower* version (FCOS: switching streams can skip barriers and regress [S33]). Semantics needed: (a) wait until the slower channel catches up, or (b) explicit owner-confirmed downgrade. |
| Relationship with OCI tags | Tags may remain as human-friendly aliases and for tooling compatibility; security decisions use signed metadata + digest. |
| Names | Not selected (stable/testing/development/preview are examples only). |

## Part 10 — Major version transitions

Evidence: RES-0005 E4 — Fedora 44 → 45 via rebuilt image: zero artefact
changes except the base reference; ~2.4 GB, 62 new layers; `/etc` merge
"22 modified, 1 removed, 61 added"; toolbox version mismatch; rollback to
44 and roll-forward worked; bootloader not rolled back ("Ignoring
downgrade"). FCOS moves streams across Fedora majors automatically with a
**barrier** release [F4].

| Semantic model | Fit | Consequences |
|---|---|---|
| NORMAL UPDATE | technically possible (same channel, bigger image) | surprise: size, toolbox mismatch, desktop changes; rollback crosses major boundary with `/var`/`$HOME` migrated forward (RISK-0014) |
| SPECIAL UPDATE (same channel, flagged in signed metadata) | **strong candidate** | allows distinct policy: larger-download gates, announce, owner-confirmed or scheduled, barrier-first |
| USER-CONFIRMED UPDATE | candidate for personal profile | respects "Yours"; must bound how long an old major stays supported (RISK-0001 cadence, ~13 months) |
| CHANNEL TRANSITION | fits only if channels are per-major | multiplies channels; cross-channel semantics (Part 9) |
| REBASE | describes the build side (image rebased on new Fedora) | client-side "rebase" (tracking a different reference) is not required if the channel carries the transition (INFERENCE) |

Findings (INFERENCE): a major transition should be a **flagged transition
within a channel**, gated by a barrier (every machine first reaches the
last release of N, which also carries any key/trust changes, F4 [S32]),
with a policy that differs from normal updates (confirmation or schedule,
larger-download gates, explicit rollback-window notice because `/var`
state may migrate forward). The composition model is not redefined; the
support window of N after N+1 is a product/lifecycle decision (SPEC,
RISK-0001).

## Part 11 — Trust chain map

| Link | Current mechanism | Cryptographic identity | Content addressing | Signature verification | Policy enforcement | Transport security | Local trust anchor | Gap |
|---|---|---|---|---|---|---|---|---|
| Eldora release authority | none yet | ED (0.1D) | — | — | — | — | — | who is authoritative (Part 13) |
| Release metadata / policy (channel → target) | **none upstream** | — | — | — | — | — | — | ELDORA MUST DEFINE (freshness, channel, version) |
| OCI reference (repo:tag) | origin in bootc | none | no | no | policy scope by reference [T1] | — | — | tag mutable [T8] |
| Registry | serves manifests/blobs/signature tags | none (TLS server identity only) | — | — | — | TLS (registry cert) | system CA store | untrusted for integrity/authorization by design |
| Manifest / index | digest | none | **yes** | via signature over manifest digest [T5] | `sigstoreSigned`/`signedBy` + `signedIdentity` [T1–T2] | TLS | keys/CA in `/etc/containers` (machine state) | default policy permissive [T10] |
| Image config (labels, version) | referenced by digest from manifest | none | yes | transitively (INFERENCE T8) | not interpreted by policy | TLS | — | version not enforced (F1) |
| Layers / content | digests | none | **yes** | transitively | — | TLS | — | runtime sealing not default (RES-0003 FR4–FR5) |
| Local deployment | ostree commit with `ostree.manifest-digest` | none | yes | origin signature mode recorded [T9] | at fetch only | — | — | `/etc`, `/var` outside image (RES-0003 FR4) |
| Booted system | `/usr` read-only; Secure Boot for kernel/boot chain | shim/GRUB/kernel signatures (UEFI) | composefs digests (fs-verity not default) | Secure Boot (RES-0005 E3) | lockdown `integrity` | — | UEFI db/MOK; SBAT | image-to-boot binding requires sealed/UKI flows (future) |

**Content-addressed ≠ cryptographically authorised by Eldora.** A digest
proves the bytes match an identifier; only a signature by an Eldora-
recognised key over that digest (plus an authorization statement binding
it to a channel/target) makes it Eldora-authorised; only signed,
versioned, time-bounded metadata makes it *current*.

## Part 12 — OCI / containers-image trust (mechanisms and boundaries)

| Mechanism | Provides | Does not provide | Boundary for Eldora |
|---|---|---|---|
| Digest pinning | integrity for a known digest | authorization, freshness; knowledge of *which* digest is current | needs a trusted source of the digest (signed metadata) |
| `signedBy` (GPG simple signing) | authenticity; tag-embedding identity | freshness; delegation | key distribution in `/etc` |
| `sigstoreSigned` + static keys | authenticity; identity per signing format (T3) | freshness, revocation, rotation protocol | multiple keys possible (`keyPaths`) → rotation overlap |
| `sigstoreSigned` + `fulcio` + Rekor | identity-based signing, log presence | freshness; offline independence (needs Fulcio/Rekor keys locally; static files, no TUF in policy) [T4, T6] | public-good infrastructure dependence; privacy of OIDC identity |
| `sigstoreSigned` + `pki` | CA-based delegation (offline root → signing certs) | revocation (no CRL/OCSP documented) [T4] | viable model for offline root + online signing (Part 13) |
| `signedIdentity` exact rules | cross-tag replay protection (with tag-embedding signatures) | same-tag replay; promotion without re-signing | promotion = re-signing (0.1D) |
| Referrers API / attachments | discovery of signatures/SBOM/attestations | — | containers/image uses `.sig` tags, not referrers [T7]; format choice matters (0.1D) |
| bootc `--enforce-container-sigpolicy` | refuses top-level permissive default at switch/install | scope-level permissive entries; `upgrade` flag | Eldora must ship an enforced policy and check it itself (RC-O) |
| Registry trust / TLS | transport confidentiality/integrity | authorization of content | registry treated as untrusted (Part 19) |
| Fedora integration | — (Fedora base images' signatures UNVERIFIED) [T10] | — | base image input verification is 0.1D (RISK-0009) |

No production signing solution is selected. A structural finding: the
signing **tool/format** determines which identity rules are usable (T3),
and the signature **discovery mechanism** (tag attachment vs referrers)
determines whether bootc can see the signature at all (T7, UNVERIFIED
detail) — both are requirements on 0.1D.

## Part 13 — Trust root: what is an "Eldora-authorized update"?

**Working definition (INFERENCE / proposal):** an update is
*Eldora-authorised* when (a) the artefact's manifest digest is signed by a
key or certificate that chains to an Eldora trust root present on the
machine, (b) a signed Eldora statement binds that digest to the machine's
channel as a target with a version, and (c) that statement is at least as
new as the newest statement the machine has already accepted (and, where a
clock is trustworthy, not expired). (a) is TRUST; (b) AUTHORIZATION; (c)
FRESHNESS/ANTI-ROLLBACK.

| Model | Description | Pros | Cons | Upstream fit |
|---|---|---|---|---|
| Embedded static key | public key(s) in policy; signer signs every release | simplest; offline-verifiable | compromise = full; rotation via update signed by the same key (Part 14) | `keyPaths` [T4] |
| Certificate-based | offline CA root; online signing certs | delegation; rotation of signing certs without touching root | no revocation in containers/image [T4]; CA operations | `pki` [T4] |
| Delegated signing | root delegates channel/role keys | limits blast radius per channel | needs metadata beyond containers/image | TUF delegations [F5] |
| Threshold / multiple signers | k-of-n signatures required | resists single-key compromise | operational cost; containers/image requires all requirements, each satisfied by ≥ 1 signature (T1) — k-of-n over **distinct** keys is **not** expressible except as "all of these requirement objects" (INFERENCE) | TUF thresholds [F5] |
| Offline root + online release signing | root rarely used; online key signs releases/timestamps | compromise of online key recoverable | ceremony cost | TUF [F5]; FCOS barrier practice [F4] |
| Framework-based metadata trust | TUF (or equivalent) metadata signed by roles; image signatures optional/secondary | freshness, rotation, thresholds specified | client code; no OCI standard; clock | TUF [F5, F6] |
| Keyless (Fulcio/Rekor) | OIDC identity certs, transparency log | no long-lived private key | depends on public-good services/trust root distribution; privacy of signer identity; no freshness | `fulcio` [T4, T6] |

Architectural requirements (proposal): distinguish at least a **rarely-used
root** from **online release/freshness** keys (R-T4); trust anchors must
be updatable by a verifiable chain from the previous anchors (R-T5); the
anchor set must be vendor-owned content, with local additions possible but
not able to silently freeze vendor rotation (R-T6, RC-M).

## Part 14 — Key rotation and revocation

| Scenario | Requirement (candidate) | Evidence/precedent |
|---|---|---|
| Planned signing-key rotation | overlap: new key trusted before first use; old key retained until all supported releases are re-signed or superseded | `keyPaths` (T4); Fedora pre-ships future keys (F10); FCOS barrier releases carry new keys (F4) |
| Compromised key | remove from trust + stop accepting its signatures; recovery signed by a key the attacker does not hold | TUF: root N+1 needs threshold of N and N+1; online-key compromise recoverable, root compromise "nearly impossible" (F5) |
| Revocation | a revocation must reach clients through a channel the compromised key cannot forge or suppress indefinitely | containers/image: no revocation list (T4) → only by changing trust files; OSTree has `revoked.*` key files [S43] |
| Expired key/certificate | expiry must not brick offline machines (clock, Part 21) | Sigstore verifies cert at signing time (T6); TUF expiry vs clock (F5) |
| Offline device returning | must be able to walk forward through every intermediate trust change | TUF keeps all N.root.json (F5); FCOS barriers (F4) |
| Trust-root update | chained: new root authorised by old root (threshold) | TUF §5.3 (F5) |
| Emergency recovery | out-of-band path (media/reinstall) when root is compromised | TUF: out-of-band for root compromise (F5) |

**Critical question — how does an old machine legitimately learn a new
authority without accepting an attacker?** (INFERENCE from F4, F5, F10):
only by (a) a statement signed by authority it *already* trusts that
introduces the new authority (chain of custody: root N signs root N+1; or
a barrier release signed by the old key ships the new key), **and** (b)
never skipping links (keep every link published; barrier releases
mandatory), **and** (c) for a compromised root, an out-of-band path
(physical media, reinstall) — no online mechanism can distinguish a
legitimate new root from an attacker holding the old root threshold.

**Eldora-specific hazard:** trust anchors for bootc live in
`/etc/containers` (machine state). If the owner edits
`/etc/containers/policy.json`, image-shipped updates to that file stop
propagating (RES-0003 FS3), so key rotation and revocation silently stop
reaching that machine (HB2; RC-M). Rotation design must survive local
trust edits (R-T6).

## Part 15 — Freshness

What bootc/OCI **provides**: integrity by digest; authenticity and
(format-dependent) identity by signature; digest-equality "no update"
detection (T1–T9, F1).

What it **does not provide** (FACT F1, T5, T6): expiry of signatures or
"latest" statements; version ordering; downgrade refusal; freeze
detection; distinction between "no update exists" and "I am being shown a
stale view".

| Threat | Model that detects/prevents it | Clock needed? | Upstream? |
|---|---|---|---|
| Replay of an old validly signed release | monotonic floor on signed version/timestamp, or signed "current target" metadata with monotonic version | no | no (F1); OSTree-native had timestamp check (F2) |
| Registry rollback (tag moved back) | same as above | no | no |
| Stale metadata | signed metadata with expiry; "last successful fresh check" state | expiry: yes | no |
| Freeze attack (show nothing new) | expiring signed timestamp statement (TUF timestamp) | **yes** | no |
| Involuntary downgrade | anti-rollback floor + explicit override (Part 16) | no | no (Zincati/OSTree precedents) |
| Malicious rollback to vulnerable version | floor + minimum-allowed version in signed metadata | no | no |

Freshness models compared:

| Model | Components | Protects | Does not protect | Cost |
|---|---|---|---|---|
| FM0 — none (status quo) | digest + signature | integrity, authenticity | replay, freeze, downgrade | none |
| FM1 — client monotonic floor on signed image label | version/timestamp label in signed config (T8 INFERENCE); persisted high-water mark | replay/downgrade of older versions *relative to what the client saw* | freeze; first-install stale; same-version re-tags | low; HB1/P-18 |
| FM2 — signed channel metadata, versioned | Eldora-signed "channel → digest, version, min-version, urgency" statement, monotonic metadata version | replay, downgrade, authorization to channel, signed urgency | freeze (unless expiring) | medium |
| FM3 — FM2 + expiry (timestamp role) | short-lived signed timestamp over FM2 | freeze (bounded by expiry) | clockless machines (Part 21) | online signer; re-sign cadence (F6: Sigstore ≤ 3 days) |
| FM4 — TUF (or Uptane-like) | root/targets/snapshot/timestamp, thresholds, delegation | all of FM3 + mix-and-match, rotation, threshold root, fast-forward recovery | first-install bootstrap relies on shipped root; clock | highest (client code, ceremonies, no OCI standard) |

Where authenticity ends and freshness begins (from RES-0006 Part 9,
confirmed): a signature says "this digest was authorised at some time";
only separate, versioned (and, for freeze, expiring) signed metadata says
"this is still the current intended target".

## Part 16 — Anti-rollback

| Model | Mechanism | Legitimate rollback | Recovery | Precedent |
|---|---|---|---|---|
| Monotonic version | refuse target version < floor | only to retained deployments (local, already verified) or explicit override | explicit override | Zincati age index (F4); OSTree timestamp check (F2) |
| Release epoch | separate "security epoch"; only raise when older releases are unsafe | older release with same epoch allowed | — | SBAT generations (F8); ChromeOS K#/F# (F8) |
| Signed metadata version | refuse metadata version < trusted | independent of image versions | — | TUF (F5) |
| Minimum allowed version | signed `min-version` per channel | anything ≥ min | — | Uptane release counter (F7) |
| Rollback window | floor = min(version of retained protected deployments) | within window | outside window needs override | ChromeOS min(A,B) (F8); AVB "largest value allowing all bootable slots" (F8) |
| Explicitly authorised rollback target | signed statement authorising a specific older digest | yes, signed | — | (proposal) |
| Recovery exception | owner action + state reset | yes, with cost | reset/wipe or `/var` compatibility guarantee | ChromeOS enterprise rollback wipes (F8) |

**Central question — how to allow recovery without destroying freshness?**
(INFERENCE):

1. Apply anti-rollback to **newly fetched targets**, not to deployments
   already on disk and already verified (user rollback between retained
   deployments stays possible).
2. Advance the persisted floor only when the new version is confirmed good
   — the AVB/ChromeOS pattern (F8). *What* "confirmed good" means is
   0.1C-C's decision (known-good).
3. Keep security-motivated floors (epoch / min-version) separate from the
   "highest version seen" floor, so that a signed min-version can forbid
   known-vulnerable versions even within the rollback window.
4. Owner-directed downgrade below the floor is an explicit, local,
   logged action (never triggered by network data), with a warning about
   `/var`/`$HOME` state (RISK-0014) — the recovery exception.
5. After a rollback, the rolled-back target is **suppressed** for
   automatic re-application (RISK-0015) — which interacts with the floor:
   the suppressed target is still ≥ floor; suppression is a separate state.

## Part 17 — TUF / update frameworks

| TUF concept | Problem solved | Needed by Eldora? (INFERENCE) |
|---|---|---|
| Root role, thresholds, offline root | trust bootstrap and compromise-resistant rotation | yes in some form (Part 13–14) |
| Targets (+ custom fields) | what artefacts are authorised, with hashes/lengths (+ version) | yes: channel → digest + version (FM2) |
| Snapshot | consistent view of all targets metadata (mix-and-match) | only if multiple targets files/delegations exist |
| Timestamp + expiry | freeze detection | yes if freeze detection is required (clock caveat) |
| Rollback protection (metadata versions) | replay of old metadata | yes |
| Key rotation (root chaining) | legitimate learning of new authority | yes |
| Delegation | per-channel or per-team signing | optional in V1 |
| Consistent snapshots | concurrent publication | operational (0.1D) |

**Costs/complexity (FACT F5, F6; INFERENCE):** an online timestamp
signer with short expiry (Sigstore re-signs at least every three days); periodic
offline signing ceremonies for expiring roles; client-side verifier (no
containers/image/bootc integration exists: T4, F6); retention of all root
versions; clock dependence for expiry; no standard mapping to OCI
registries (F6); first-install trust shipped out-of-band (installer image).

**Simpler alternative:** OCI signatures + local policy + a small
Eldora-signed channel statement (FM2/FM3). It reproduces the targets +
timestamp subset but must then re-solve rotation, thresholds and
compromise recovery ad hoc.

**Falsification attempts:**

- *"TUF is necessary"* — partly falsified: FM1/FM2 already remove replay
  and downgrade without TUF; freeze detection can be added with an
  expiring signed statement (FM3). Full TUF is **not strictly necessary**
  for the V1 threat model *if* Eldora accepts a simpler, specified rotation
  and compromise-recovery scheme.
- *"TUF is excessive"* — partly falsified: the moment Eldora requires freeze
  detection **and** recovery from online-key compromise **and** chained
  root rotation for long-offline machines, it needs roles, thresholds,
  expiry and version rules that are TUF's core; re-inventing them risks
  known pitfalls (mix-and-match, fast-forward). The heavy parts of TUF
  (delegation, snapshot) are the optional ones for a single-channel-set OS.

Result: **H2 SUPPORTED WITH CONDITIONS** — an explicit freshness/metadata
layer is required; *whether it is TUF itself, a TUF subset, or an
equivalent* is **MORE EVIDENCE REQUIRED** (design study + 0.1D
operational assessment; ADR candidate).

## Part 18 — Transparency / provenance boundary

| Artefact | What the updater must require/understand (0.1C-B) | What the pipeline must produce (0.1D) |
|---|---|---|
| Signature over manifest digest | verify against Eldora trust root; mandatory | produce with a tool/format compatible with the chosen identity rules (T3, T7) |
| Channel/freshness metadata | verify, enforce version/expiry/min-version | publish, re-sign on cadence |
| SLSA provenance (`https://slsa.dev/provenance/v1`) | **optional** for V1 client: at most verify builder identity/source against expectations (SLSA verifier steps) [S60] | generate and sign provenance (Build L2+ target: not selected) |
| in-toto attestations / VSA | optional: a signed Verification Summary could let the client check one statement instead of full provenance [S61] | produce/verify at release |
| SBOM (SPDX/CycloneDX) | **not** an updater requirement; retrievable for diagnostics/audit | produce and attach (referrers or equivalent) |
| Transparency log (Rekor) | may be required as evidence of publication (log presence) [T6]; it does **not** provide freshness | decide whether to log (privacy of signer identity if keyless) |
| Reproducibility | not verified by the client | 0.1D/RES-0003 FR6 |

Boundary statement: the updater enforces **authorization + freshness +
anti-rollback**; provenance/SBOM/transparency are **release-quality and
audit evidence** that 0.1D must produce and that the client may *expose*,
and may optionally *check* in a later phase. RISK-0009 (build inputs)
cannot be mitigated on the client.

## Part 19 — Compromised registry (Eldora signing authority intact)

| Attacker action | Possible? | Detected by | Residual |
|---|---|---|---|
| Replace a tag with unsigned/foreign image | yes | signature policy (enforced) | none if enforced (RES-0004 T3/T4) |
| Re-point tag to an older signed image (same repo) | yes, no key needed (RES-0004 `a-retag.sh`) | cross-tag: exact identity with tag-embedding signatures (T7b); same-tag older image: **only freshness/anti-rollback** (FM1+) | with FM0: **undetected**, older vulnerable image deployed (RISK-0008) |
| Serve an old manifest for the tracked tag | yes | FM1+ (version floor) | FM0: undetected |
| Serve different content for a known digest | no (digest mismatch) | content addressing (T8) | none (integrity) |
| Freeze (serve the current-but-stale view forever) | yes | only FM3/FM4 (expiring metadata) + client "last fresh check" state | FM0–FM2: undetected; visible only as "no updates" |
| Withhold everything | yes | availability error | DoS; must be distinguished from "up to date" |
| Serve huge/slow responses | yes | size limits from signed metadata (TUF endless-data) | resource exhaustion otherwise |
| Delete signatures | yes | policy rejects (unsigned) | DoS only |
| Mix channels | yes | exact identity or signed channel metadata | FM0 with cosign-format: undetected (T3) |

Availability (DoS, withholding) cannot be prevented by cryptography;
integrity is already provided; authorization depends on identity rules and
signing format; freshness requires Eldora metadata.

## Part 20 — Compromised signing authority

| Compromised | Blast radius | Detection assumptions | Recovery |
|---|---|---|---|
| Online release key (static-key model) | attacker (with registry/network position) can ship arbitrary "authorised" images to every machine | publication monitoring; transparency log alerts (if used); reproducible builds (0.1D) | **no in-band recovery**: trust update must be signed by the same key → attacker can race/forge; out-of-band (reinstall/media) unless a separate root exists |
| Online release key (offline-root model, `pki` or TUF) | same until revoked | same | root issues new signing identity; with no CRL in containers/image (T4), revocation = new trust config shipped by an update signed under the new chain; old-cert acceptance persists until clients update (window) |
| Online timestamp/freshness key (FM3/FM4) | freeze/replay within validity; cannot sign images | expiry mismatch, monitoring | root rotates timestamp key; TUF deletes old timestamp/snapshot to recover from fast-forward (F5) |
| Root (below threshold) | none alone | ceremony audit | rotate with remaining keys (F5) |
| Root (threshold) | total | — | out-of-band only: "nearly impossible" to recover safely (F5) → reinstall/physical media |

Offline devices: remain vulnerable to a compromised key until they
reconnect and receive revocation; a device offline across a compromise
event must walk the trust chain forward (Part 14). Emergency release path:
requires a pre-planned signer (root-authorised) distinct from the
compromised one, plus a mechanism to force a fresh check (the freshness
layer). **Not designed here** (0.1D key custody; this report forwards
requirements HD-4 to HD-7).

## Part 21 — Clock / time

| Guarantee | Needs trusted wall clock? |
|---|---|
| Integrity, authenticity | no (except cert validity; Sigstore checks at signing time, T6) |
| Authorization (signed channel binding) | no |
| Anti-rollback (version floor, metadata versions) | **no** (F5; ChromeOS: "the firmware can't guarantee the local clock is not changed" → counters [S64]) |
| Freeze detection (expiry) | **yes** |
| "Staleness" warnings to the user | approximate (monotonic, locally accumulated time since last fresh check is clock-independent — INFERENCE) |
| Certificate validity (pki/fulcio) | yes at verification unless evaluated at signing time |

Findings (FACT X4; INFERENCE): the Fedora default boot-time clock floor is
only the systemd build time until NTP (chronyd) syncs; NTS is not default;
an RTC reset can put the clock years behind (stale metadata looks valid)
or ahead (valid metadata looks expired → update DoS). Uptane requires a
secure time source and warns about both directions (F7). A persisted
"highest trusted metadata issue time seen" can act as a local time floor
(clock can be pushed forward, never back behind it) — INFERENCE.
**Freshness guarantees still possible without a reliable clock:**
anti-rollback relative to previously seen metadata, authorization, and
detection of *monotonic-counter* regressions; **not** absolute freeze
detection.

## Part 22 — Offline update

Requirements that must not be precluded (INFERENCE):

1. **Authenticated offline artefact:** OCI layout / archive transports do
   not carry containers/image signatures (FACT T12); an offline package
   needs signatures carried separately (e.g. `dir:` transport, or an
   Eldora metadata bundle that pins digests and carries the channel
   statement) — probe P-20.
2. **Freshness offline:** version floor works offline; freeze detection
   does not (an offline machine is by definition "frozen"); expiring
   metadata must degrade to an explicit, owner-visible "offline/stale"
   state rather than blocking the owner's own offline update.
3. **Rollback authorization offline:** same anti-rollback rules as online;
   a USB stick with an older signed image must not downgrade silently.
4. **Air-gapped machines / internal mirrors:** signature identity is
   evaluated against the logical reference, so mirrored bytes remain
   verifiable (INFERENCE from [S5, S1]); tag-tracking bypasses
   digest-only mirrors [S5].
5. **Delayed updates:** trust-chain walking (all intermediate roots /
   barrier releases must be available on media too).
6. Precedent: Flatpak USB sideloading requires signed commits and
   collection IDs (FACT [S63]); Uptane anticipates long-offline vehicles
   missing key rotations [S52].

## Part 23 — Private by design

| Data | Technically required? | Default? |
|---|---|---|
| Client IP address | inherent to networking (X1) | unavoidable (mitigable only by mirrors/proxies owner chooses) |
| Repository, tag/digest, blob digests | required to fetch (X1) | yes (reveals Eldora version/channel to registry/CDN) |
| User-Agent (tool + version) | sent by containers/image (X1) | acceptable (no unique ID); verify bootc (UNVERIFIED) |
| Anonymous registry token request | protocol-dependent (X1) | acceptable |
| Freshness metadata fetch | required if FM2+ | yes; no identifiers |
| Time sync (NTP) | OS function, not update-specific | Fedora default |
| machine-id or derived IDs (e.g. Zincati `node_uuid`) | **not required** | **must not be sent** (X2) |
| cohort / rollout identifiers | not required (client-side randomness suffices, X3) | must not be sent |
| hardware inventory, installed apps | not required | must not be sent |
| update results, failures, crash reports | not required | must not be sent (local diagnostics only, RES-0006 Part 12) |
| usage counting | not required | not selected; if ever wanted, countme-style bucket without UUID and opt-in decision (X2) |

Baseline preserved: no remote telemetry is needed for fundamental update
functionality. Timing correlation (checks at predictable times reveal
presence) is reduced by randomised delays (X3). No analytics selected; no
silent device tracking introduced.

## Part 24 — Managed devices

| Requirement | Classification |
|---|---|
| Local owner visibility of any admin policy in force | **V1 CORE** |
| Policy layering: vendor default < admin policy < (owner, if not locked) — declarative, local file-based | V1 EXTENSIBILITY REQUIREMENT |
| Maintenance window | V1 EXTENSIBILITY REQUIREMENT (Zincati periodic precedent) |
| Pinned channel / hold | V1 CORE for owner; admin enforcement: V1 EXTENSIBILITY |
| Maximum deferral / deadline | V1 EXTENSIBILITY REQUIREMENT |
| Staged rollout | V1 EXTENSIBILITY (client-side randomness, no IDs); server-side orchestration: LATER PRODUCT FEATURE |
| Emergency update (expedite) | V1 CORE semantics (signed urgency); forced application for managed: V1 EXTENSIBILITY |
| Fleet coordination (fleet_lock-like) | LATER PRODUCT FEATURE |
| Remote management/reporting | LATER PRODUCT FEATURE (separate research, consent, privacy) |

No enterprise management architecture is designed here.

## Part 25 — Upstream capability map

| Need | Classification | Basis |
|---|---|---|
| Update check | UPSTREAM PROVIDES (`--check`, `cachedUpdate`); ELDORA MUST DEFINE cadence/privacy | P1, P7 |
| Fetch | UPSTREAM PROVIDES (per-layer resume) | P1, P8 |
| Integrity | UPSTREAM PROVIDES (digests) | T8 |
| Authorization | UPSTREAM PARTIALLY PROVIDES (signature + identity rules; format-dependent); ELDORA MUST DEFINE channel authorization | T1–T3 |
| Freshness | ELDORA MUST DEFINE; ELDORA MUST IMPLEMENT LATER (client) + 0.1D (publication) | F1 |
| Anti-rollback | ELDORA MUST DEFINE (with 0.1C-C floor semantics); ELDORA MUST IMPLEMENT LATER | F1, F2 |
| Channel semantics | ELDORA MUST DEFINE | Part 9 |
| Deferral | ELDORA MUST DEFINE | P4–P6 |
| Metered policy | UPSTREAM PARTIALLY PROVIDES (NM state); ELDORA MUST DEFINE | P8 |
| Battery policy | UPSTREAM PARTIALLY PROVIDES (UPower, `ConditionACPower`, inhibitors); ELDORA MUST DEFINE | P9 |
| Disk preflight | UPSTREAM PARTIALLY PROVIDES (min-free-space, descriptor sizes); ELDORA MUST IMPLEMENT LATER | P10 |
| Scheduling | UPSTREAM PARTIALLY PROVIDES (timers, download-only); ELDORA MUST DEFINE | P2, X3 |
| Reboot policy | UPSTREAM PARTIALLY PROVIDES (`--apply`, soft-reboot, inhibitors); ELDORA MUST DEFINE | P1, P9 |
| History | ELDORA MUST IMPLEMENT LATER (no upstream record) | RES-0006 Part 3 |
| Local diagnostics | UPSTREAM PARTIALLY PROVIDES (status JSON, journal); ELDORA MUST DEFINE | RES-0006 Part 12 |
| Owner override | ELDORA MUST DEFINE | Part 4 |
| Managed policy | ELDORA MUST DEFINE (extensibility); LATER PRODUCT FEATURE (management) | Part 24 |
| Trust root / key rotation | ELDORA MUST DEFINE; 0.1D implements custody | Parts 13–14 |
| Offline media | UPSTREAM PARTIALLY PROVIDES (`oci`/`oci-archive` transports, no signatures) | T12 |
| Remote telemetry | OUT OF SCOPE (not required) | Part 23 |

## Part 26 — Policy state model (hypothesis; not an API, not a schema)

Minimal persistent state the future Update Supervisor would need
(INFERENCE; to be decided later). Storage must not depend on `/boot`
(RES-0006 Part 5 §7).

| State item | Why | Origin |
|---|---|---|
| current (booted) deployment: digest, version | baseline | derivable (bootc status) — cache only |
| target: digest, version, channel, source statement version | what is being pursued | Eldora |
| channel (identity + authority) | authorization | Eldora (owner-selectable) |
| last check: time (monotonic + wall), result class ("up to date" / "could not check" / "update available") | freeze visibility | Eldora |
| last *fresh* trusted metadata: version, issue time, expiry | freshness | Eldora (FM2+) |
| anti-rollback floor(s): highest confirmed version; security epoch / min-version | anti-rollback | Eldora + 0.1C-C (when floor advances) |
| trust state: root version/identity in use | rotation | Eldora |
| attempt ID + stage reached + failure class | diagnostics; lost-update detection | Eldora (RES-0006) |
| pre-restart recorded intent (target digest, staged serial, locked/unlocked) | RISK-0010/0012 detection | Eldora (RES-0006) |
| policy in force + its source (vendor/admin/owner) | explainability | Eldora |
| defer-until + reason; restart requested/scheduled | deferral | Eldora |
| suppressed targets (after rollback) | loop prevention (RISK-0015) | Eldora + 0.1C-C |
| explicit owner overrides (downgrade, local trust additions, pinned hold) with timestamps | owner control audit | Eldora |

Everything else (progress, layer lists, NM/UPower state) is transient.

## Part 27 — Threat model (minimal)

Scope owners: **B** = 0.1C-B (defines requirement); **D** = 0.1D; **C** =
0.1C-C; **L** = later.

| ID | Threat | Asset | Attacker capability | Existing control | Gap | Candidate mitigation | Residual risk | Owner |
|---|---|---|---|---|---|---|---|---|
| T01 | Network MITM | integrity, authorization | intercept/modify traffic | TLS; digests; enforced signatures (opt-in) | default policy permissive (T10) | enforce signature policy for Eldora OS scope by default (R-T1) | DoS; freshness gaps (T04/T05) | B / D |
| T02 | Compromised registry | authorization, freshness | re-tag, serve old manifests, withhold | digests; signatures if enforced | same-tag replay, freeze (Part 19) | FM2/FM3; exact identity; tag-embedding format | availability | B / D |
| T03 | Malicious / stale mirror | freshness | serve old but signed content | signature identity by logical name | freeze/replay | same as T02; mirror-independent metadata | availability | B |
| T04 | Replay of old valid artefact | freshness | serve older signed release | none (F1) | no floor | FM1/FM2 floor | first-install window | B |
| T05 | Freeze attack | freshness | show stale "current" view | none | no expiry | FM3/FM4 expiry + "last fresh check" state | clock-dependent; offline | B / D |
| T06 | Unauthorised downgrade | anti-rollback | offer older target; induce channel switch | none | no floor; cross-channel regress | floor; explicit owner downgrade only | owner can still downgrade (by design) | B / C |
| T07 | Compromised online signing key | authorization | sign arbitrary images | none | no revocation (T4) | offline root + online keys; rotation chain; monitoring | window until revocation reaches clients | B / D |
| T08 | Compromised root key | all trust | re-anchor trust | none | — | threshold, offline, ceremony; out-of-band recovery | "nearly impossible" to recover in-band (F5) | D |
| T09 | Malicious local unprivileged user | policy | trigger/suppress updates, change channel | root-owned files | unknown for Eldora IPC | privilege model: only benign requests unprivileged (R-P9) | DoS by repeated requests | B / L |
| T10 | Malicious local privileged admin | everything | root | none (by design) | — | **no cryptographic protection promised**; visibility/audit only | full | out of scope (owner authority) |
| T11 | Incorrect system clock | freshness | skew clock (or RTC reset) | systemd epoch floor (X4) | expiry misjudged | clock-independent anti-rollback; persisted time floor; tolerate expiry with visible state | freeze undetected while clock wrong | B |
| T12 | Offline machine with stale trust metadata | trust continuity | wait out rotation; replay old chain | none | chain walking | keep all trust links published; barrier releases; media carry chain | compromise window for offline devices | B / D |
| T13 | Update metadata loss/corruption (local) | state | disk corruption, power loss | none | no persisted state upstream | atomic persisted state (not in `/boot`); re-derivable from bootc status | floor loss → conservative re-init | B / C |
| T14 | Denial of service | availability | block network, huge data, forced-reboot abuse | TLS, size checks partially | unsigned urgency could force reboots | signed urgency; size limits from signed metadata; backoff | availability | B |
| T15 | Supply-chain artefact substitution | build integrity | inject content before signing | none on client | RISK-0009 | build-input verification; provenance (0.1D) | client cannot detect | D |

## Part 28 — Principle evaluation (qualitative; no scores)

| Alternative | Simple by default | Powerful when needed | Private by design | Open by nature | Secure by default | Hardware-friendly | Yours |
|---|---|---|---|---|---|---|---|
| PA/PB manual/notify | − many decisions | + | + | + | − latency | + | + |
| PC background download, restart on request | + no surprise | + with controls | + | + | ± restart-bound latency | + gates power/metered | + |
| PD stage, apply on any reboot | ± surprise | + | + | + | + | − surprise on battery reboots | ± |
| PE maintenance window | ± | + | + | + | + | ± | ± (fine if owner sets window) |
| PF fully automatic immediate | + nothing to do | − | + | + | + latency | − data loss, battery | − |
| FM0 digest+signature only | + | + | + | + | − replay/freeze | + | + |
| FM1 client floor | + invisible | + | + | + | ± replay only | + | + (override path) |
| FM2/FM3 signed channel metadata (+expiry) | + invisible | + | + (no IDs) | + (open format needed) | + | ± clock | + if offline degrades visibly |
| FM4 full TUF | + invisible | + | + | + (open spec) | ++ | ± clock | + |
| Forced reboot deadline (personal) | ± | − | + | + | + bounded exposure | − | − |
| Keyless Fulcio/Rekor signing | + | + | ± signer identity public; client offline needs static keys | + | ± | + | ± public-good dependency |

## Answers to the mandatory questions

- **Q1 — Automatic by default?** Candidate direction (not a decision):
  update check; metadata resolution and eligibility (trust, channel,
  anti-rollback, freshness); download + verification when network, power
  and disk policies allow; staging in a state that does not surprise the
  user on an unrelated restart (PC). Verification is always automatic and
  not skippable by default.
- **Q2 — Requires user action?** Restart to apply (or accepting a
  schedule); major-version transitions (confirmation or schedule); metered
  or low-battery overrides; channel changes; downgrades; trust changes;
  disabling checks/downloads.
- **Q3 — Can reboot be automatic?** Yes in *managed* (maintenance window,
  policy deadline), kiosk/unattended and explicitly opted-in personal
  profiles; not as the personal-desktop default (Parts 1, 8; H3).
  Upstream `--apply` always reboots and the upstream timer would do so
  every ~8 h if enabled (P3) — Eldora must control that preset (RC-Q).
- **Q4 — Deferral vs security urgency?** Urgency as a **signed** property
  of release metadata; urgency shortens check/download latency and
  escalates notifications; forced reboot only where a policy (managed)
  says so; deadline + grace-on-return semantics (P11); deferral state and
  exposure always visible.
- **Q5 — Advanced controls without polluting the default?** Part 3:
  check/download/stage now, schedule, channel, inspect status/target/
  history, manual rollback, pin/hold, controlled downgrade, diagnostics,
  policy override, local trust additions — available via documented local
  interfaces, outside the default flow.
- **Q6 — Metered/battery/disk?** Metered: kB checks acceptable (decision
  pending), large downloads deferred on explicit metered without consent,
  guessed-metered treated conservatively; battery: gate staging and
  reboot-to-update by level (thresholds need P-22), desktops differ;
  disk: preflight from descriptor sizes vs free space and OSTree floor;
  never remove a protected fallback deployment (Part 7).
- **Q7 — What defines an Eldora-authorised update?** Part 13: signature
  chaining to an Eldora root over the manifest digest **+** signed channel
  binding (digest ↔ channel ↔ version) **+** at least as new as the last
  accepted statement (and unexpired where time is trusted).
- **Q8 — Is an OCI digest sufficient?** No. It provides integrity for a
  known identifier only; it says nothing about who authorised it or
  whether it is current, and the registry controls which digest a tag
  resolves to (T8, RES-0004 T7a).
- **Q9 — Is a signature sufficient?** No. It provides authenticity and
  (format-dependent) identity binding, but no freshness, no ordering and no
  expiry of "current-ness"; every older signed release stays valid forever
  (T5, T6, F1); cosign-format signatures do not even bind the tag (T3).
- **Q10 — Authorization vs freshness?** Authorization answers "is this
  artefact intended for my channel by Eldora?"; freshness answers "is this
  the currently intended one, and is my view recent?". An authorised
  artefact can be stale; a fresh view can still point to an unauthorised
  artefact if signatures are not enforced.
- **Q11 — Detecting replay of an old validly signed release?** Persisted
  monotonic floor on a signed version (FM1) or signed, monotonically
  versioned channel metadata (FM2); upstream alone cannot (F1).
- **Q12 — Detecting freeze/stale metadata?** Only with signed, expiring
  metadata (FM3/FM4) plus a trustworthy clock; without a clock, only
  "no fresh metadata for N (monotonic) days" warnings (Part 21).
- **Q13 — Preventing unauthorised downgrade?** Floor enforced before
  fetch/stage; downgrades only via explicit local owner action; cross-channel
  moves never downgrade automatically; signed min-version (Part 16).
- **Q14 — Legitimate rollback without destroying anti-rollback?** Apply the
  floor to new targets, not retained deployments; advance the floor only
  after 0.1C-C's known-good; separate security epoch/min-version from the
  high-water mark; owner-directed recovery exception with state caveats;
  suppress re-application of rolled-back targets (Part 16).
- **Q15 — Key rotation (conceptual)?** Overlapping trust (new key trusted
  before use), chained authorisation from the previous anchor, mandatory
  intermediate (barrier) releases, all chain links kept available, trust
  anchors as vendor content that local edits cannot freeze (Part 14).
- **Q16 — Recovering from signing-key compromise?** Requires a separate,
  uncompromised authority (offline root) that can authorise a new signing
  key and revoke the old one, delivered through the freshness layer;
  without such a root, only out-of-band recovery (Part 20).
- **Q17 — Updating trust roots on old/offline machines?** Walk forward
  through every published chain link (TUF root N→N+1, or barrier releases
  signed by the old key carrying the new one); media must carry the chain;
  compromised-root cases need out-of-band action (Part 14).
- **Q18 — Does TUF (or equivalent) solve material problems?** Yes: freeze
  detection, rollback of metadata, chained rotation, threshold/offline
  root, fast-forward recovery (Part 17).
- **Q19 — Its costs?** Online timestamp signing with short expiry;
  periodic offline ceremonies; client verifier outside containers/image;
  no OCI standard; clock dependence; publication of all root versions;
  bootstrap via installer (Part 17).
- **Q20 — OCI signatures + local policy without a freshness framework
  sufficient?** No — they leave replay, downgrade, freeze and (with
  cosign-format) tag substitution open (Parts 15, 19; H1 refuted).
- **Q21 — Compromised registry?** Moves the threat from integrity (still
  protected by digests) to authorization (identity rules/format) and
  freshness (replay, freeze) — Part 19.
- **Q22 — Compromised signing authority?** Everything the key can sign is
  "authorised"; containment depends on role separation, revocation path
  and monitoring; single-key model has no in-band recovery (Part 20).
- **Q23 — Guarantees depending on a reliable clock?** Freeze detection
  (expiry), certificate validity at verification time, absolute staleness
  reporting. Not: integrity, authenticity, anti-rollback via counters
  (Part 21).
- **Q24 — Keeping offline update possible?** Separate signature carriage
  for offline media; digest-pinned metadata bundle; clock-independent
  anti-rollback; visible stale state instead of hard expiry; trust chain on
  media (Part 22).
- **Q25 — Strictly necessary network data?** IP (inherent), repository +
  tag/digest + blob digests, User-Agent, anonymous token scope, freshness
  metadata fetch (Part 23).
- **Q26 — Not sent by default?** machine-id or derived IDs, cohort IDs,
  hardware/app inventory, update outcomes, crash/failure reports,
  analytics (Part 23).
- **Q27 — Channel without trusting mutable tags?** Signed channel metadata
  naming target digest + monotonic version; client pulls by digest; tags
  only as aliases (Part 9).
- **Q28 — Is a major Fedora transition a normal update?** No — a flagged
  transition within the channel, barrier-first, with distinct policy
  (confirmation or schedule, larger-download gates, rollback-window
  notice) (Part 10).
- **Q29 — What can 0.1C-B recommend now?** See Recommendation R1–R9.
- **Q30 — What must wait for 0.1C-C?** Floor advancement point
  (known-good); automatic rollback triggers and loop suppression rules;
  retention/pinning count; downgrade vs `/var`/`$HOME` compatibility;
  recovery exception mechanics; what "update successful" means for UX
  (HC-1 to HC-8).
- **Q31 — What must wait for 0.1D?** Signing tool/format; key custody,
  offline root ceremonies; registry and mirrors; publication of
  channel/freshness metadata and re-signing cadence; provenance/SBOM
  production; build-input verification; installer trust bootstrap;
  `/boot` layout (HD-1 to HD-12).
- **Q32 — What needs a future product SPEC?** Update UX and notifications;
  deferral and restart scheduling; advanced controls surface; diagnostics
  viewer; managed policy format; major-transition UX; offline media UX
  (Future SPEC candidates).
- **Q33 — Hypotheses needing probes?** HB1–HB4 and those listed under
  "Proposed probes" (P-17 to P-24; P-12, P-13, P-06 extended).
- **Q34 — Does the evidence materially threaten ADR-0001?** No (see
  "Effect on ADR-0001").

## Anti-bias / falsification

| Hypothesis | Result | Explanation |
|---|---|---|
| **H1** "OCI content addressing + signature verification is sufficient for the Eldora V1 trust model." | **REFUTED** | Sufficient for integrity and authenticity only. Replay of older signed releases (same tag), registry-side tag substitution with cosign-format signatures (T3), freeze and downgrade remain (F1; RES-0004 T7a). Arguments for H1: enforced policy rejected unsigned/wrong-key images (RES-0004 T3–T5); exact identity blocked cross-tag replay — true but insufficient. |
| **H2** "Eldora needs an explicit freshness/metadata framework, such as TUF or equivalent." | **SUPPORTED WITH CONDITIONS** | An explicit, signed, versioned metadata layer is needed (Q20). Full TUF is not proven necessary: FM2/FM3 cover replay/downgrade/freeze; TUF's added value is standardized rotation/threshold/compromise recovery. Choice: MORE EVIDENCE REQUIRED (design study, 0.1D operations). |
| **H3** "Owner control and Secure by default can coexist without forced reboot." | **SUPPORTED WITH CONDITIONS** | Conditions: third-party protections enforced by default and unreachable by non-owners; exposure from deferral always visible and escalated; security urgency signed; restart friction minimized (update pre-staged); managed profiles may impose deadlines. Counter-evidence: indefinitely deferring users remain exposed — an accepted, visible owner choice, not a silent default. |
| **H4** "Release channels can be represented only by mutable OCI tags." | **REFUTED** | Tags can be re-pointed without keys (RES-0004 T7a); exact identity makes every past `:channel` signature valid forever (same-tag replay) and blocks promotion (T7c); cosign-format signatures do not bind tags (T3). Tags are acceptable as aliases only. |
| **H5** "Offline-capable update is compatible with strong freshness guarantees." | **SUPPORTED WITH CONDITIONS** | Compatible with strong *anti-rollback* and authorization (clock-independent counters, signed metadata carried on media). **Not** compatible with absolute freeze detection, which needs fresh, time-checked metadata. Offline must be an explicit degraded-freshness mode visible to the owner. |

## Requirements proposed for Eldora (CANDIDATES — not accepted)

Policy:
- **R-P1** Update policy is defined per phase (check, resolve, fetch,
  verify, stage, apply) and per device profile; defaults differ for
  personal desktop, laptop, managed and offline profiles.
- **R-P2** Eligibility (trust, channel authorization, anti-rollback,
  freshness) is decided before fetch/stage.
- **R-P3** Eldora owns the "apply on next restart" semantics explicitly;
  no update is applied on a restart that was not intended as an update
  restart unless the active policy says so.
- **R-P4** Staged-but-not-applied targets are re-resolved (newer target?
  still eligible?) before apply.
- **R-P5** "Could not check" is distinct from "up to date"; the last
  successful check and last fresh metadata are persisted.
- **R-P6** Deferral has a persisted state, origin (user/policy/condition)
  and next-evaluation time; exposure is visible.
- **R-P7** Security urgency is only honoured when carried in signed
  release metadata.
- **R-P8** The upstream `bootc-fetch-apply-updates` timer is not enabled
  implicitly by a base-image preset; Eldora controls presets.
- **R-P9** Unprivileged local actors may request only benign actions
  (check, schedule restart); channel, trust, downgrade and disabling
  require owner/admin authority.
Network/power/storage:
- **R-N1** Download policy distinguishes explicit and guessed metered
  states; captive-portal/limited connectivity is not treated as an attack
  or as "up to date".
- **R-W1** Laptop and desktop profiles have separate power policies;
  staging and reboot-to-update are power-gated on battery devices
  (thresholds from measurement).
- **R-S1** Preflight uses remaining bytes (descriptor sizes minus cached
  layers) against free space and the OSTree floor.
- **R-S2** Partial/abandoned fetch residue is cleaned by policy.
- **R-S3** Storage/cleanup/staging never removes a deployment that 0.1C-C
  marks as the protected fallback.
Trust:
- **R-T1** Signature enforcement for the Eldora OS image scope is on by
  default (no `insecureAcceptAnything` for that scope), verified by Eldora
  itself (not only bootc's top-level best-effort check, RC-O).
- **R-T2** The signing format must support the chosen identity rules
  (tag-binding if tags are used for identity) and be discoverable by the
  client stack (T3, T7).
- **R-T3** Trust policy for Eldora OS images is separate from trust policy
  for user/developer container images (Toolbx conflict, RES-0005).
- **R-T4** At least two trust tiers: a rarely-used root and online
  release/freshness keys.
- **R-T5** Trust anchors are updatable only through a chain authorised by
  current anchors; all chain links remain published.
- **R-T6** Vendor trust anchors are not frozen by local edits of
  `/etc/containers/*` (HB2, RC-M); local trust additions are explicit and
  logged.
- **R-T7** Locally built/derived images are an explicit owner trust
  decision, visible as such (T11, RISK-0006).
Freshness / anti-rollback:
- **R-F1** A signed, monotonically versioned channel statement (target
  digest, version, minimum allowed version, urgency, transition flags)
  exists; whether it is TUF, a TUF subset or equivalent is an ADR
  decision.
- **R-F2** Freeze detection (expiry) is supported when a trustworthy clock
  is available and degrades to a visible "stale" state otherwise.
- **R-A1** Automatic updates never move below the anti-rollback floor.
- **R-A2** The floor advances only at a point defined by 0.1C-C
  (known-good); security epoch/min-version is separate.
- **R-A3** Owner-directed downgrade is explicit, local and logged; never
  initiated by network data.
Privacy / offline / managed:
- **R-V1** Update traffic carries no device-unique or cohort identifiers
  by default; rollout randomness is client-side.
- **R-O1** An offline update format carries signatures and the channel
  statement with the artefact; anti-rollback applies to offline media.
- **R-M1** Any admin policy is visible to the local owner; policy
  layering is declarative and local.

## Requirements handed to 0.1C-C

- **HC-1** Define "known good" such that it can serve as the anti-rollback
  floor advancement point (R-A2).
- **HC-2** Define rollback-window semantics: which retained deployments
  remain eligible below the floor (Part 16).
- **HC-3** Define suppression of rolled-back targets vs automatic policy
  (RISK-0015), including when suppression lifts (new target? signed
  re-release?).
- **HC-4** Define the protected-fallback deployment and retention/pinning
  count, so that staging never removes it (Part 7).
- **HC-5** Define downgrade/rollback compatibility rules for `/var` and
  `$HOME` that the owner-directed downgrade path must warn about (RISK-0014).
- **HC-6** Define the post-boot boundary at which the policy may report
  "update successful".
- **HC-7** Define recovery behaviour when the trust state is lost or
  corrupted (T13).
- **HC-8** Define recovery entry points that do not bypass trust (e.g.
  recovery media still verified).

## Requirements handed to 0.1D

- **HD-1** Signing tool/format compatible with R-T2 (identity binding and
  discovery by containers/image/bootc; cosign legacy vs bundle/referrers).
- **HD-2** Publication of the channel/freshness statement (R-F1) and, if
  expiring, an online re-signing service with defined cadence.
- **HD-3** Trust-root design: root custody, ceremonies, thresholds (if
  any), online key custody, emergency signer.
- **HD-4** Rotation procedure with overlap and barrier releases; all chain
  links retained.
- **HD-5** Revocation distribution mechanism (containers/image has none
  built in).
- **HD-6** Compromise response runbook (Part 20).
- **HD-7** Installer trust bootstrap (initial anchors, initial floor).
- **HD-8** Signed version labels/metadata in every image (monotonic
  version; build timestamp) (HB1).
- **HD-9** Provenance/SBOM production and attachment; optional VSA.
- **HD-10** Build-input verification (RISK-0009).
- **HD-11** Registry, mirrors/CDN and offline media production carrying
  signatures (R-O1).
- **HD-12** Presets for update timers; Eldora-controlled defaults (R-P8).

## Future SPEC candidates

Update UX and notifications (ready-to-restart, failure before reboot,
deferral, stale/offline, "not protected" states); restart scheduling and
deferral controls; advanced update controls surface; local update history
and diagnostics viewer; major-version transition UX; managed policy file
format and precedence; offline update media UX; owner trust-management UX
(local derived images, extra keys).

## Risks

Existing risks re-evaluated (no status, severity or likelihood changed):

| Risk | Impact of this research |
|---|---|
| RISK-0007 (permissive default trust) | **Sharpened:** Fedora 44 ships `insecureAcceptAnything` (T10); bootc's best-effort check covers only the top-level default in `/etc/containers/policy.json` (T9; RC-O); `--enforce-container-sigpolicy` is absent from `upgrade`. |
| RISK-0008 (no freshness/anti-rollback) | **Confirmed and sharpened:** no expiry/ordering anywhere in the chain (F1, T5, T6); exact identity does not stop **same-tag replay** of older releases; cosign-format signatures only allow repository identity (T3). Mitigation direction: FM1–FM4 (Part 15). |
| RISK-0009 (build inputs) | Unchanged; confirmed client cannot detect (T15); 0.1D (HD-10). |
| RISK-0010 (UEFI `/boot` release blocker) | Policy interaction: "ready to restart" must require the pre-restart checks of C-R1/C-R3; unlocked staging extends exposure to any restart. No change; P-01 not needed for 0.1C-B (see P-01 section). |
| RISK-0011 (boot chain not rolled back) | Boot-chain anti-rollback (SBAT) is a separate, monotonic mechanism (F8) that OS anti-rollback must not contradict; 0.1C-C/0.1D. |
| RISK-0012 (abrupt loss after staging) | Policy lever identified: locked staging (PC) avoids the long unlocked window but still needs intent recording; unlocked staging (PD) maximises the window. |
| RISK-0014 (older code over newer state) | Owner-directed downgrade and cross-channel downgrade inherit this risk (R-A3, HC-5). |
| RISK-0015 (re-apply loops) | Requires "suppressed target" state separate from the floor (Part 16 point 5; HC-3). Upstream timer default (`--apply`) would aggravate it (RC-Q). |
| RISK-0005 (drift) | Extended: trust configuration in `/etc` freezes on local edit (RC-M). |
| RISK-0006 (escape hatch) | Local derived images are unverified by design (T11); owner trust decision must be explicit (R-T7). |
| RISK-0004 (coupling) | Choosing TUF vs a bespoke format couples Eldora clients to that format; keep the metadata format open and documented. |

### Candidate new risks (no RISK-ID created)

| Candidate | Description | Evidence |
|---|---|---|
| RC-M | Trust configuration (`/etc/containers/policy.json`, `registries.d`, keys) is machine state under the whole-file `/etc` merge; a local edit silently freezes vendor trust updates (key rotation, revocation), leaving the machine on stale or revoked trust. | RES-0003 FS3; T9 (bootc reads `/etc` only); HB2 (P-19) |
| RC-N | Identity-binding strength and signature visibility depend on the signing tool/format: cosign signatures carry only the repository (tag substitution possible); cosign 3.x referrer bundles may be invisible to containers/image/bootc (Tier 4). | T3 (verified), T7; RES-0004 lab used podman sigstore signing |
| RC-O | bootc's rejection of permissive policy checks only the top-level default in `/etc/containers/policy.json`; a scope-level permissive entry or a relaxed scope passes silently. | T9 (source) |
| RC-P | If expiry-based freshness is adopted, the Fedora default clock floor (systemd build time until NTP; no NTS by default) and RTC resets can cause false expiry (update DoS) or accept stale metadata. Conditional on design. | X4; F5; F7 |
| RC-Q | The upstream `bootc-fetch-apply-updates.timer` runs `bootc upgrade --apply` (always reboots) every ~8 h with no power, metered or session awareness; enabling it through a base-image preset would cause surprise reboots and aggravate RISK-0015. | P3 (source; docs say "daily") |
| RC-R | Offline media in OCI layout/archive form do not carry containers/image signatures; offline updates are either unverified or need a separate mechanism. | T12 (source; local skopeo) |
| RC-S | With a single online signing key and no offline root, a key compromise has no in-band recovery path (trust updates would be signed by the compromised key). | Part 20; F5; T4 |

## Proposed probes (NOT executed)

Numbering continues RES-0006. Scheduling is a Project Owner decision;
proposed for 0.1C-F unless stated.

| ID | Purpose | Outline |
|---|---|---|
| P-17 | Identity binding per signing format | podman sigstore vs cosign legacy `.sig` vs cosign bundle/referrers; bootc switch/upgrade under `matchRepoDigestOrExact`/`matchRepository`; visibility and tag substitution |
| P-18 | Version floor feasibility (HB1, HB4) | does `bootc upgrade --check` expose `cachedUpdate.version/timestamp` before layer fetch; does any OSTree/rpm-ostree timestamp check apply to container origins |
| P-19 | Trust config drift (HB2) | locally edit `/etc/containers/policy.json`; ship a new key in the next image; observe merge result |
| P-20 | Offline media signatures (HB3) | `dir:` vs `oci:`/`oci-archive:` with enforced policy and `bootc switch --transport` |
| P-21 | Enforcement coverage | scope-level permissive entry vs top-level default with `--enforce-container-sigpolicy`; user policy file effects |
| P-22 | Power/time cost of stage and finalize | measure duration/energy of fetch, stage, finalize on battery-class hardware (evidence for thresholds; physical hardware claim requires physical hardware) |
| P-23 | Preflight accuracy | predicted bytes from descriptors vs actual; behaviour at OSTree min-free-space floor (extends P-06) |
| P-24 | Network conditions | proxy honouring for host pulls; captive portal; interrupted pull resume granularity (extends P-04) |
| P-12 (extended) | Same-tag replay | older image re-signed/served for the same tag under exact identity |
| P-13 (extended) | Locked staging semantics | discard-on-reboot, cache reuse, time-to-apply after `--from-downloaded` |
| PX6 (RES-0002) | CVE fix latency | documentary input for security-urgency and deferral bounds |

## P-01 — material dependency assessment

P-01 settles the `/boot` layout hypotheses H-L1/H-L2 for RISK-0010
(RES-0006 Part 5). 0.1C-B's conclusions that touch RISK-0010 are
**layout-independent**: the policy must record intent without `/boot`,
must gate "ready to restart" on pre-restart checks, and must treat
unlocked staging as extending exposure — all true under H-L1 and H-L2.
**P-01 is not materially required before review of 0.1C-B.** It remains
pending (EARLY FACT-FINDING PROBE), not executed, and no authorisation is
requested by this report.

## Effect on ADR-0001

**No material threat.** The ADR-0001 reversibility trigger "the update
trust chain (C3–C5) cannot be enforced with acceptable usability" is not
met: enforcement exists upstream (RES-0004 PB5); the gaps (freshness,
anti-rollback, rotation, format-dependent identity) are addressable by an
Eldora metadata/supervisor layer above containers/image without replacing
bootc/OCI, and are expected by conditions C3–C4. New findings (RC-M to
RC-S) add engineering work and 0.1D requirements, not evidence that M3 is
unworkable. ADR-0001 reconsideration is **not** recommended.

## Recommendation

A recommendation is not a decision.

- **R1.** Adopt, as working vocabulary for 0.1C, the separation POLICY /
  TRUST / FRESHNESS and the five properties (integrity, authenticity,
  authorization, freshness, anti-rollback).
- **R2.** Direction for the default policy (for a later ADR/SPEC, not
  decided): automatic, privacy-minimal checks; policy-gated automatic
  download and verification; staging that does not apply on unintended
  restarts (PC); user-initiated or user-scheduled restart on personal
  devices; maintenance windows/deadlines as managed-profile features.
- **R3.** Treat H1 as refuted: plan an Eldora-signed, monotonically
  versioned channel/freshness statement (R-F1) — **ADR candidate**
  ("update freshness and channel metadata"), with the TUF vs subset vs
  equivalent choice explicitly decided there (MORE EVIDENCE REQUIRED).
- **R4.** Enforce signature verification for the Eldora OS image scope by
  default, verified by Eldora and separated from developer-image trust
  (R-T1, R-T3) — **ADR candidate** ("update trust root and policy").
- **R5.** Adopt the anti-rollback principles of Part 16 (floor on new
  targets, advance after known-good, separate security epoch, explicit
  owner downgrade) as input to a joint 0.1C-B/0.1C-C decision — **ADR
  candidate** after 0.1C-C.
- **R6.** Channels are signed Eldora concepts; OCI tags are aliases only
  (H4 refuted) — part of R3's ADR.
- **R7.** Major Fedora transitions: flagged, barrier-first transitions
  within a channel with distinct policy — to be confirmed with PX1 and a
  product SPEC.
- **R8.** Privacy baseline for update traffic (R-V1) — can be recorded
  now as a constraint for 0.1D and later SPECs.
- **R9.** Record RC-M to RC-S for Project Owner review; schedule P-17 to
  P-24 (and extensions) for 0.1C-F; keep P-01 pending as scheduled.

Decisions needing an ADR (proposed): trust root and signature policy
model; freshness/channel metadata mechanism; anti-rollback floor semantics
(with 0.1C-C); default update policy per profile (ADR for architecture +
SPEC for UX).

- **Confidence:** MEDIUM.

## Confidence and limitations

- MEDIUM overall. Trust/identity facts rest on local Tier-1 man pages
  (several spot-checked, "(verified)") and upstream source read at `main`;
  bootc/rpm-ostree/ostree behaviour is documentary (not installed locally,
  no probe executed).
- Absence claims (no downgrade check in bootc; no freshness in
  containers/image) rest on documentation plus partial source review;
  they are marked UNVERIFIED beyond the reviewed files and are the subject
  of P-18.
- Fedora documentation (docs.fedoraproject.org) was inaccessible; Fedora
  signing status of base images is UNVERIFIED; Fedora CoreOS stream/graph
  details rely on AsciiDoc sources and Tier-2 tracker pages.
- Quotes from web pages passed through a summarising tool except where
  marked "(verified)"; re-check before citation in a decision record.
- Source files were read at upstream `main` (2026-09-26), not at the
  versions Fedora 44 ships.
- External precedents (Windows, ChromeOS, Android, Uptane) are used only as
  design precedents, not as claims about Eldora.
- No physical hardware evidence; power thresholds deliberately not
  proposed.
- Process deviations: see "Method and limitations".

## Decision

NOT TAKEN — research does not decide. Q-0008 remains NOT DECIDED.

## Sources

All accessed 2026-09-26. Tier per `docs/research/README.md`. Type:
SPEC = specification; DOC = official documentation; SRC = source code;
ISSUE = upstream issue/PR; FEDORA = Fedora integration documentation;
LOCAL = local man page/file on the Fedora 44 host.

| # | Source (title — organization — URL / path) | Tier | Type | Version / date covered | Accessed | Used for |
|---|---|---|---|---|---|---|
| S1 | containers-policy.json(5) — containers — local `man 5 containers-policy.json` | 1 | LOCAL | containers-common 0.67.2-1.fc44 | 2026-09-26 | T1–T4, T9, Part 12 (verified quotes) |
| S2 | containers-policy.json.5.md — containers/container-libs — https://github.com/containers/container-libs/blob/main/image/docs/containers-policy.json.5.md | 1 | DOC | main | 2026-09-26 | T1–T4 |
| S3 | containers-signature(5) — containers — local man page | 1 | LOCAL | 0.67.2 | 2026-09-26 | T5 (verified) |
| S4 | containers-registries.d(5) — containers — local man page | 1 | LOCAL | 0.67.2 | 2026-09-26 | T7 |
| S5 | containers-registries.conf(5) — containers — local man page | 1 | LOCAL | 0.67.2 | 2026-09-26 | P8, Part 22 |
| S6 | containers-transports(5) — containers — local man page | 1 | LOCAL | 0.67.2 | 2026-09-26 | T12 |
| S7 | `/etc/containers/policy.json`, `/etc/containers/registries.d/*` — Fedora — local files | 1 | FEDORA | containers-common 0.67.2-1.fc44 | 2026-09-26 | T10 |
| S8 | container-libs `image/signature/{simple.go, internal/rekor_set.go, policy_eval_sigstore.go, fulcio_cert.go}` — containers — https://github.com/containers/container-libs/tree/main/image/signature | 1 | SRC | main | 2026-09-26 | T5, T6, F1 |
| S9 | container-libs `image/docker/docker_client.go`, `internal/useragent`, `types/types.go` — containers — https://github.com/containers/container-libs/tree/main/image | 1 | SRC | main | 2026-09-26 | T7, X1 |
| S10 | container-libs `image/oci/layout/oci_dest.go`, `image/storage/storage_src.go`, `internal/signature/signature.go` — containers — https://github.com/containers/container-libs/tree/main/image | 1 | SRC | main | 2026-09-26 | T11, T12 |
| S11 | OCI Image Format Specification (descriptor, manifest, annotations) — OCI — https://github.com/opencontainers/image-spec | 1 | SPEC | main (post-v1.1) | 2026-09-26 | T8, P10 |
| S12 | OCI Distribution Specification — OCI — https://github.com/opencontainers/distribution-spec/blob/main/spec.md | 1 | SPEC | main (≥ 1.1) | 2026-09-26 | T8, X1 |
| S13 | Token Authentication Specification — CNCF Distribution — https://distribution.github.io/distribution/spec/auth/token/ | 1 | SPEC | current | 2026-09-26 | X1 |
| S14 | bootc-upgrade(8) — bootc — https://bootc.dev/bootc/man/bootc-upgrade.8.html | 1 | DOC | live (~1.16) | 2026-09-26 | P1, T9, F1 |
| S15 | Upgrade and rollback — bootc — https://bootc.dev/bootc/upgrades.html | 1 | DOC | live | 2026-09-26 | P1, P2, F1 |
| S16 | bootc-switch(8) — bootc — https://bootc.dev/bootc/man/bootc-switch.8.html | 1 | DOC | live | 2026-09-26 | T9, T12 |
| S17 | Security and threat model — bootc — https://bootc.dev/bootc/security.html | 1 | DOC | live | 2026-09-26 | T9 |
| S18 | bootc-install-to-disk(8) — bootc — https://bootc.dev/bootc/man/bootc-install-to-disk.8.html | 1 | DOC | live | 2026-09-26 | T9 |
| S19 | bootc_lib rustdoc/source (cli.rs, utils.rs, spec) — bootc — https://bootc.dev/bootc/internals/bootc_lib/ | 1 | SRC | current main | 2026-09-26 | P7, T9, F1 |
| S20 | ostree-ext container/store, SignatureSource — bootc — https://bootc.dev/bootc/internals/ostree_ext/container/ ; https://docs.rs/ostree-ext/latest/ | 1 | SRC | live; docs.rs 0.15.3 | 2026-09-26 | P8, P10, T9 |
| S21 | `bootc-fetch-apply-updates.{timer,service}` — bootc — https://github.com/bootc-dev/bootc/tree/main/systemd ; man page https://bootc.dev/bootc/man/bootc-fetch-apply-updates.service.5.html | 1 | SRC / DOC | main; live | 2026-09-26 | P3 (discrepancy) |
| S22 | Accessing registries and offline updates — bootc — https://bootc.dev/bootc/registries-and-offline.html | 1 | DOC | live | 2026-09-26 | P8, T12, X1 |
| S23 | bootc-rollback(8) — bootc — https://bootc.dev/bootc/man/bootc-rollback.8.html | 1 | DOC | live | 2026-09-26 | Part 16 |
| S24 | ostree native containers (URL formats) — rpm-ostree — https://coreos.github.io/rpm-ostree/container/ | 1 | DOC | live | 2026-09-26 | T9, F2 |
| S25 | rpm-ostreed.conf(5) source and rpm-ostreed-automatic.timer — rpm-ostree — https://github.com/coreos/rpm-ostree/tree/main/man ; …/src/daemon | 1 | SRC | main | 2026-09-26 | P4 |
| S26 | rpm-ostree(1) — rpm-ostree (ManKier rendering) — https://www.mankier.com/1/rpm-ostree | 3 | DOC (rendering) | current | 2026-09-26 | F2 |
| S27 | DNF Count Me support — rpm-ostree — https://coreos.github.io/rpm-ostree/countme/ | 1 | DOC | live | 2026-09-26 | X2 |
| S28 | Zincati auto-updates — CoreOS — https://coreos.github.io/zincati/usage/auto-updates/ | 1 | DOC | live | 2026-09-26 | P5, F4, X3 |
| S29 | Zincati updates strategy — CoreOS — https://coreos.github.io/zincati/usage/updates-strategy/ | 1 | DOC | live | 2026-09-26 | P5 |
| S30 | Zincati agent identity — CoreOS — https://coreos.github.io/zincati/usage/agent-identity/ | 1 | DOC | live | 2026-09-26 | X2, X3 |
| S31 | Cincinnati for Fedora CoreOS (protocol) — CoreOS — https://coreos.github.io/zincati/development/cincinnati/protocol/ | 1 | SPEC | live | 2026-09-26 | F4, X2 |
| S32 | update-barrier-signing-keys.adoc — Fedora CoreOS docs source — https://github.com/coreos/fedora-coreos-docs/blob/main/modules/ROOT/pages/update-barrier-signing-keys.adoc | 1 | FEDORA | main | 2026-09-26 | F4, Part 14 |
| S33 | update-streams.adoc — Fedora CoreOS docs source — https://github.com/coreos/fedora-coreos-docs/blob/main/modules/ROOT/pages/update-streams.adoc | 1 | FEDORA | main | 2026-09-26 | Part 9 |
| S34 | Updates metadata specifications — fedora-coreos-tracker — https://github.com/coreos/fedora-coreos-tracker/blob/main/metadata/updates/specifications.md | 2 | FEDORA | main | 2026-09-26 | F4 |
| S35 | Issue #1872 "Move from Cincinnati to OCI for update graph" — fedora-coreos-tracker — https://github.com/coreos/fedora-coreos-tracker/issues/1872 | 2 | ISSUE | opened 2025-02-05 | 2026-09-26 | F4 |
| S36 | Changes/CoreOSOstree2OCIUpdates — Fedora — https://fedoraproject.org/wiki/Changes/CoreOSOstree2OCIUpdates | 1 | FEDORA | F42 | 2026-09-26 | F4 |
| S37 | Simple upgrade class (`ostree_sysroot_upgrader_check_timestamps`) — OSTree — https://ostreedev.github.io/ostree/reference/ostree-Simple-upgrade-class.html | 1 | DOC | live | 2026-09-26 | F2 |
| S38 | OstreeRepo API (pull options, summary) — OSTree — https://ostreedev.github.io/ostree/reference/ostree-OstreeRepo.html | 1 | DOC | live | 2026-09-26 | F2, F3 |
| S39 | Core repository-independent functions (summary metadata keys) — OSTree — https://ostreedev.github.io/ostree/reference/ostree-Core-repository-independent-functions.html | 1 | DOC | live | 2026-09-26 | F3 |
| S40 | ostree-admin-upgrade(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-upgrade.html | 1 | DOC | live | 2026-09-26 | F2 |
| S41 | ostree-admin-deploy(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-deploy.html | 1 | DOC | live | 2026-09-26 | P2, P10 |
| S42 | ostree.repo-config(5) — OSTree — https://ostreedev.github.io/ostree/man/ostree.repo-config.html | 1 | DOC | live | 2026-09-26 | P10 |
| S43 | ostree-sign(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-sign.html | 1 | DOC | live | 2026-09-26 | Part 14 |
| S44 | ostree-pull(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-pull.html | 1 | DOC | live | 2026-09-26 | F3 |
| S45 | OSTree 1.0 constants (PyGObject rendering) — pgi-docs — https://lazka.github.io/pgi-docs/OSTree-1.0/constants.html | 3 | DOC (rendering) | undated | 2026-09-26 | F3 |
| S46 | ostree-admin-pin(1) — OSTree — https://ostreedev.github.io/ostree/man/ostree-admin-pin.html | 1 | DOC | live | 2026-09-26 | P10 |
| S47 | `ostree-finalize-staged.service`; Deployments — OSTree — https://github.com/ostreedev/ostree/blob/main/src/boot/ostree-finalize-staged.service ; https://ostreedev.github.io/ostree/deployment/ | 1 | SRC / DOC | main; live | 2026-09-26 | P9 |
| S48 | The Update Framework Specification — TUF — https://theupdateframework.github.io/specification/latest/ | 1 | SPEC | 1.0.36 (2026-08-05) | 2026-09-26 | F5, Parts 14–17, 21 |
| S49 | TUF Security; Roles and Metadata — TUF — https://theupdateframework.io/docs/security/ ; https://theupdateframework.io/docs/metadata/ | 1 | DOC | 2024-10-12; 2025-04-17 | 2026-09-26 | F5 |
| S50 | TAPs index; TAP 4, TAP 8, TAP 19 — TUF — https://github.com/theupdateframework/taps | 1 | SPEC | current | 2026-09-26 | F6 |
| S51 | tuf-on-ci README; sigstore/root-signing README — TUF / Sigstore — https://github.com/theupdateframework/tuf-on-ci ; https://github.com/sigstore/root-signing | 1 | DOC | current | 2026-09-26 | F6 |
| S52 | Uptane Standard — Uptane — https://uptane.org/docs/latest/standard/uptane-standard | 1 | SPEC | 2.1.0 | 2026-09-26 | F7, Part 22 |
| S53 | Uptane Deployment Best Practices — Uptane — https://uptane.org/docs/2.1.0/deployment/best-practices (and 1.1.0) | 1 | DOC | 2.1.0; 1.1.0 | 2026-09-26 | F7 |
| S54 | Sigstore FAQ; Configuring cosign with custom components — Sigstore — https://docs.sigstore.dev/about/faq/ ; https://docs.sigstore.dev/cosign/system_config/custom_components/ | 1 | DOC | current | 2026-09-26 | F6 |
| S55 | Sigstore verifying signatures, timestamps, bundle format, attestations — Sigstore — https://docs.sigstore.dev/cosign/verifying/verify/ ; …/timestamps/ ; https://docs.sigstore.dev/about/bundle/ ; …/verifying/attestation/ | 1 | DOC | current (bundle v0.3.2) | 2026-09-26 | T6, Part 18 |
| S56 | Sigstore threat model — Sigstore — https://docs.sigstore.dev/about/threat-model/ | 1 | DOC | current | 2026-09-26 | Part 19 |
| S57 | Issue #2047 "Discourage signing references to images that aren't digests" — sigstore/cosign — https://github.com/sigstore/cosign/issues/2047 | 2 | ISSUE | 2022-07-04, closed | 2026-09-26 | Part 9 |
| S58 | Trust store and trust policy; signature specification — Notary Project — https://github.com/notaryproject/specifications/tree/main/specs | 1 | SPEC | main | 2026-09-26 | F9 |
| S59 | Docker Content Trust retirement and migration guidance — Docker — https://www.docker.com/blog/docker-content-trust-retirement-and-migration-guidance/ | 2 | DOC (vendor blog) | 2026-06-16 | 2026-09-26 | F6 |
| S60 | SLSA specification (build track, provenance, verifying artifacts) — OpenSSF — https://slsa.dev/spec/v1.2/ | 1 | SPEC | v1.2 | 2026-09-26 | Part 18 |
| S61 | in-toto Attestation Framework — in-toto — https://github.com/in-toto/attestation/blob/main/spec/README.md | 1 | SPEC | v1.2 | 2026-09-26 | Part 18 |
| S62 | Flatpak command reference; flatpak-update(1), flatpak-remote-add(1) — Flatpak — https://docs.flatpak.org/en/latest/flatpak-command-reference.html ; local man pages | 1 | DOC / LOCAL | latest; flatpak 1.18.2-1.fc44 | 2026-09-26 | F3 context, Part 16 |
| S63 | Flatpak USB drives — Flatpak — https://docs.flatpak.org/en/latest/usb-drives.html | 1 | DOC | latest | 2026-09-26 | Part 22 |
| S64 | Firmware verified boot crypto; Verified boot; Firmware boot and recovery — Chromium OS — https://www.chromium.org/chromium-os/chromiumos-design-docs/ | 1 | DOC | undated design docs | 2026-09-26 | F8, Part 21 |
| S65 | Roll back ChromeOS to a previous version — Google — https://support.google.com/chrome/a/answer/12569990 | 1 | DOC | current | 2026-09-26 | F8 |
| S66 | Verified Boot; Boot flow; AVB README; A/B updates — Android — https://source.android.com/docs/security/features/verifiedboot/ ; https://android.googlesource.com/platform/external/avb/+/refs/heads/main/README.md ; https://source.android.com/docs/core/ota/ab | 1 | DOC / SRC | current; main | 2026-09-26 | F8 |
| S67 | SBAT.md — rhboot/shim — https://github.com/rhboot/shim/blob/main/SBAT.md | 1 | SRC (repo doc) | main | 2026-09-26 | F8 |
| S68 | Enforce compliance deadlines with policies — Microsoft Learn — https://learn.microsoft.com/en-us/windows/deployment/update/wufb-compliancedeadlines | 1 | DOC | ms.date 2026-06-30 | 2026-09-26 | P11 |
| S69 | Notify users to restart to apply pending updates — Google — https://support.google.com/chrome/a/answer/7679871 | 1 | DOC | current | 2026-09-26 | P11 |
| S70 | `org.gnome.software.gschema.xml` — GNOME — local `/usr/share/glib-2.0/schemas/` | 1 | LOCAL | gnome-software 50.4-1.fc44 | 2026-09-26 | P6 |
| S71 | eos-autoupdater.conf(5), eos-autoupdater(8), eos-updater(8) — Endless — https://github.com/endlessm/eos-updater (man sources) | 1 | SRC (man pages) | master | 2026-09-26 | P6 |
| S72 | NetworkManager D-Bus API types — NetworkManager — https://networkmanager.dev/docs/api/latest/nm-dbus-types.html ; local NetworkManager.conf(5), nm-settings-nmcli(5), `/usr/lib/NetworkManager/conf.d/20-connectivity-fedora.conf` | 1 | SPEC / LOCAL | latest; 1.56.1-2.fc44 | 2026-09-26 | P8 |
| S73 | UPower Device and Manager interfaces — freedesktop.org — https://upower.freedesktop.org/docs/Device.html ; …/UPower.html | 1 | SPEC | current | 2026-09-26 | P9 |
| S74 | systemd.timer(5), systemd.unit(5), systemd-inhibit(1), logind.conf(5), systemd-soft-reboot.service(8), systemd(1) "System clock epoch", systemd-timesyncd(8), timesyncd.conf(5) — systemd — local man pages | 1 | LOCAL | systemd 259.9-1.fc44 | 2026-09-26 | P9, X3, X4 (epoch verified) |
| S75 | `90-default.preset`; `chronyd.service`; chrony.conf(5), chronyd(8) — Fedora / chrony — local files | 1 | FEDORA / LOCAL | fedora-release-common 44-18; chrony 4.9-1.fc44 | 2026-09-26 | X4 |
| S76 | Changes/NetworkTimeSecurity — Fedora — https://fedoraproject.org/wiki/Changes/NetworkTimeSecurity | 1 | FEDORA | F33 | 2026-09-26 | X4 |
| S77 | draft-ietf-ntp-roughtime — IETF — https://datatracker.ietf.org/doc/draft-ietf-ntp-roughtime/ | 1 | SPEC (draft) | -19 | 2026-09-26 | X4 |
| S78 | dnf5.conf(5) `countme`; `/etc/yum.repos.d/fedora*.repo`; Changes/DNF_Better_Counting — DNF5 / Fedora — local; https://fedoraproject.org/wiki/Changes/DNF_Better_Counting | 1 | LOCAL / FEDORA | dnf5 5.4.5; fedora-repos 44-2 | 2026-09-26 | X2 |
| S79 | Releases/44 and /45 ChangeSet; Changes/konflux-atomic-change-proposal; Changes/Build_FCOS_on_Fedora_Konflux — Fedora — https://fedoraproject.org/wiki/ ; siguldry issue #49 and PR #188 — fedora-infra — https://github.com/fedora-infra/siguldry | 1 / 2 | FEDORA / ISSUE | 2026 | 2026-09-26 | T10 |
| S80 | Issue #977 (cosign 3.x bundles vs podman/skopeo/bootc) — projectbluefin/common — https://github.com/projectbluefin/common/issues/977 | 4 | ISSUE (community downstream) | June 2026 | 2026-09-26 | T7 (corroboration only) |
| S81 | fedora-gpg-keys file list and key metadata — Fedora — local `rpm -ql fedora-gpg-keys`, `gpg --show-keys`; https://fedoraproject.org/security/ | 1 | FEDORA / LOCAL | fedora-gpg-keys 44-2 | 2026-09-26 | F10 |
| S82 | skopeo(1), skopeo-copy(1); containers-image-proxy `ImageProxyConfig` — containers — local man pages; https://docs.rs/containers-image-proxy/latest/ | 1 | LOCAL / DOC | skopeo 1.22.3; crate 0.11.0 | 2026-09-26 | T12, X1 |
| S83 | Issues #218 and #528 — bootc-dev/bootc — https://github.com/bootc-dev/bootc/issues/218 ; …/528 | 2 | ISSUE | closed | 2026-09-26 | T9 background |
| S84 | Issue #770 "Remove fedora-coreos-pinger" — fedora-coreos-tracker — https://github.com/coreos/fedora-coreos-tracker/issues/770 | 2 | ISSUE | 2021, closed | 2026-09-26 | X2 |
| S85 | Zincati PR #156 (dead-end) and issue #554 (interactive sessions) — CoreOS — https://github.com/coreos/zincati | 2 | ISSUE | 2019; 2021 | 2026-09-26 | P5, F4 |

Earlier project evidence: RES-0003, RES-0004, RES-0005 (and their
versioned lab directories, notably `RES-0004-lab/vm/a-build-images.sh`
and `a-retag.sh`) and RES-0006.
