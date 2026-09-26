# RES-0004 laboratory plan — Wave 0.1B-P Composition Validation Probes

> **RESEARCH ONLY — NOT PRODUCTION — NOT ELDORA IMPLEMENTATION.**
> Everything in this directory exists only to make the RES-0004 probes
> reproducible. The package, images, keys and names are laboratory
> artefacts ("eldora-lab") and must never be reused as Eldora components.

Written before execution (2026-09-26). Deviations found during execution
are recorded in RES-0004.

## Safety rules

- All mutable operations run **inside disposable QEMU/KVM virtual
  machines** started as unprivileged user processes.
- The host (Project Owner's Fedora 44 workstation) is not modified: no
  package installs, no sudo, no changes to host `/etc`, boot, SELinux,
  firewall, registries, repositories, users or storage. Host-side files are
  written only under the job scratch directory
  `$L=/home/yuri/.claude/jobs/95dfae05/tmp/lab`.
- Keys are ephemeral laboratory material generated inside the VMs (or in
  `$L`), never published.
- No image is pushed outside the laboratory; the only registry is a local
  `docker-distribution` instance inside VM-A, reachable only through a
  loopback port forward (`127.0.0.1:5000`).
- Destruction: stop the QEMU processes and `rm -rf $L`. Nothing else
  persists.

## Network actions planned

1. Host: download `Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2` and its
   `CHECKSUM` file from `dl.fedoraproject.org`; verify the SHA-256 against
   the checksum file, and verify the checksum file signature with Fedora's
   published key in a temporary `GNUPGHOME` under `$L`.
2. Inside the VMs: Fedora package repositories (dnf).
3. Inside VM-A: `podman pull quay.io/fedora/fedora-bootc:44` (the bootc
   laboratory base image).

No other network action is planned. Anything else requires stopping and
requesting authorization.

## Environments

| Name | Role | Base | Resources | Access |
|---|---|---|---|---|
| VM-A | LAB-M1 (package-based host) **and** builder (rpmbuild, podman build, local registry, `bootc install to-disk` target writer) | Fedora Cloud Base Generic 44-1.7 (qcow2 overlay, grown to 60 GiB) | 4 vCPU, 5 GiB RAM, BIOS | SSH `127.0.0.1:2221`; registry forwarded to `127.0.0.1:5000` |
| VM-B | LAB-M3 (bootc host) | Disk written by `bootc install to-disk` from lab image v1 (derived `FROM quay.io/fedora/fedora-bootc:44`) | 4 vCPU, 4 GiB RAM, BIOS | SSH `127.0.0.1:2222`; reaches the registry as `labregistry:5000` via `10.0.2.2` |
| LAB-M2b | Not a separate VM. Only a narrow check inside VM-B: `rpm-ostree install` followed by `bootc upgrade`, to test the layering escape hatch. | — | — | — |

Both VMs resolve `labregistry` to the registry (`127.0.0.1` in VM-A,
`10.0.2.2` in VM-B) so that image references and signature identities are
identical on both sides.

UEFI/Secure Boot is **not** tested (BIOS boot keeps the lab small; Secure
Boot belongs to RISK-0002/0.1D).

## Laboratory artefacts

- `rpm/eldora-lab-config.spec` — one spec built twice (`lab_ver` 1 and 2).
  Contents:
  - `/etc/eldora-lab/unmodified.conf` and `/etc/eldora-lab/modified.conf`
    (`%config(noreplace)`, `value=<ver>`);
  - `/etc/eldora-lab/new-in-v2.conf` (v2 only);
  - `/usr/lib/eldora-lab/defaults.conf` (vendor default in `/usr`, P1) and
    `/etc/eldora-lab/conf.d/` for local drop-ins (P2);
  - `/usr/bin/eldora-lab-effective` (prints the effective configuration:
    `/usr` defaults overridden by `/etc` drop-ins);
  - `/usr/lib/sysusers.d/eldora-lab.conf` (v1: user/group `eldoralab`; v2
    adds user `eldoralab2` and group `eldoralabextra`) (P3);
  - `eldora-lab.service` (oneshot, `User=eldoralab`, `StateDirectory=`,
    appends `schema=<ver>` to `/var/lib/eldora-lab/state.log`) enabled by a
    preset file.
- `images/Containerfile` — `FROM quay.io/fedora/fedora-bootc:44`, installs
  the lab RPM of a given version, runs `bootc container lint`.
- `scripts/collect-state.sh` — read-only state snapshot run inside a VM
  (config files, `.rpmnew`, effective config, users/groups, group
  membership, service state log, machine-id hash, SSH host key
  fingerprints, hostname, deployment status).

## Probes, hypotheses and criteria

### PB3 — `/etc` and users/groups drift

- **Hypothesis H-PB3:** in both models, a locally modified configuration
  file stops receiving vendor changes; M1 signals this with `.rpmnew`, M3
  silently keeps the local file; in M3 a locally modified `/etc/passwd`
  hides new image users unless they are created by sysusers at boot;
  rollback in M3 does not restore `/etc` edits made after the update.
- **Procedure (both):** install v1 → BEFORE snapshot → local changes (edit
  `modified.conf`; add a drop-in; `useradd` a local user; add it to the
  vendor group `eldoralab`) → update to v2 (M1: `dnf upgrade`; M3: `bootc
  switch`/`upgrade` + reboot) → AFTER snapshot → rollback (M1: `dnf
  downgrade`/`history undo`; M3: `bootc rollback` + reboot) → ROLLBACK
  snapshot. M3 extra: edit `/etc` after update, then roll back.
- **Expected (from documentation):** see hypothesis.
- **Pass/fail:** each expectation is marked CONFIRMED, NOT CONFIRMED or
  DIFFERENT with the observed evidence. No single case is generalized.

### PB2 — advanced administration / escape hatch

- **Hypothesis H-PB2:** M1 supports persistent host changes directly; M3
  supports persistent `/etc` and `/var` changes, while persistent `/usr`
  changes require a (local) derived image and reboot; host `dnf` is
  refused or transient; rpm-ostree layering blocks `bootc upgrade`.
- **Operations (chosen to discriminate):** O1 persistent CLI tool
  (`strace`); O2 local systemd unit in `/etc`; O3 configuration drop-in; O4
  write to `/usr/local` and `/opt`; O5 containerized tool environment
  (podman); O6 revert each customization; O7 (M2b check) `rpm-ostree
  install` then `bootc upgrade`.
- **Metrics:** administrative steps, rebuild needed, reboot needed,
  persistence across reboot and update, update compatibility, rollback
  behaviour, failure visibility, specialist knowledge needed.
- **Pass/fail:** per operation, observed vs documented behaviour recorded.

### PB5 — update trust chain

- **Hypothesis H-PB5:** RPM verification is on by default only from F45
  (on F44 it must be enabled); the container policy accepts unsigned
  images by default; with an explicit sigstore policy, bootc accepts only
  images signed by the trusted key; digest pinning stops tag movement.
- **M1 tests:** install unsigned lab RPM (F44 default); install with
  `_pkgverify_level all` unsigned / signed-trusted / signed-untrusted.
- **M3 tests (VM-B):** T1 default policy + unsigned image; T2 enforced
  sigstore policy + image signed with trusted key; T3 enforced + unsigned;
  T4 enforced + image signed with an untrusted key; T5 `bootc switch
  --enforce-container-sigpolicy` with the default policy; T6 switch to a
  digest reference and observe `bootc upgrade` after the tag moves.
- **Pass/fail:** accept/reject outcome and error text per case.

### PB1 — minimum Eldora-owned surface (derived evidence)

- Count and list what the laboratory had to own in M1 and M3 to deliver the
  same lab component (RPM, repository, signing keys, image definition,
  registry, policy), and whether the same RPM served both models.

### PB4 — machine state across image update, replacement and rollback (derived evidence, M3 focus)

- Track `/etc` files, `/var/lib/eldora-lab/state.log`, machine-id (hash),
  SSH host key fingerprints, hostname, a user file in `/home`, and journal
  boots across v1→v2 update, rollback, and replacement by a different image
  (plain `fedora-bootc:44` without the lab package).
- Factory reset is not tested.

## Destruction procedure

1. `kill` the QEMU processes (PIDs recorded in `$L/*.pid`).
2. `rm -rf /home/yuri/.claude/jobs/95dfae05/tmp/lab`.
3. Verify host unchanged: `git status` of the repository unchanged except
   for documentation; no host packages installed (`rpm -qa --last | head`).
