# Risk Register

This register tracks project risks during the Foundation phase. It is a
minimal convention established by the Project Owner (decision D18,
2026-09-26; see
[`reviews/WAVE-0.1A-0.1X-REVIEW.md`](reviews/WAVE-0.1A-0.1X-REVIEW.md)).
The current summary of active risks is linked from
[`CURRENT-STATE.md`](CURRENT-STATE.md#tracked-risks).

## Convention

- **ID:** `RISK-NNNN`, zero-padded, sequential, never reused.
- **Fields:** ID; title; status; severity; likelihood; scope;
  source/evidence; mitigation or validation; related question/research/probe;
  owner; resolution/closure evidence (when applicable).
- **Status:** `OPEN` (identified, not yet being reduced), `MITIGATING`
  (mitigation or validation in progress), `ACCEPTED` (the Project Owner
  accepts the residual risk), `CLOSED` (no longer applicable or resolved;
  closure evidence required).
- **Severity and likelihood:** qualitative `HIGH`, `MEDIUM` or `LOW`, with
  a basis in the cited evidence. No numeric probabilities.
- A risk is not a decision. Moving a risk to `ACCEPTED` or `CLOSED` is done
  by, or on explicit instruction of, the Project Owner.

## Register

Severity and likelihood of RISK-0001 to RISK-0011 were proposed by the agent
that recorded them, based on the cited evidence; the Project Owner may adjust
them. RISK-0005 to RISK-0007 were accepted by the Project Owner from
RES-0003, RISK-0008 to RISK-0009 from RES-0004, and RISK-0010 to RISK-0011
from RES-0005 (review record 0.1B). The "release blocker" designation of
RISK-0010 is a note recorded by the Project Owner's decision (ADR-0001), not
a lifecycle status.

| ID | Title | Status | Severity | Likelihood | Scope | Source / evidence | Mitigation or validation | Related | Owner | Resolution / closure evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| RISK-0001 | Fedora's short cadence and lack of an LTS may impose excessive rebase cost on a small team. | OPEN | HIGH — recurring cost for the whole V1 lifetime | MEDIUM — cadence is certain (~13 months support, no LTS); whether the cost is excessive is unmeasured | Eldora OS V1 base (OB-0004) | RES-0002 FE1, FE12, RX1 | Validate with probe PX1 before freezing irreversible composition, update or release-lifecycle decisions; consider kernel gating and CI-built rebases (RES-0002). | Q-0001, Q-0008; RES-0002; PX1 | Project Owner | — |
| RISK-0002 | NVIDIA + Secure Boot must be validated for the hardware experience Eldora intends. | OPEN | HIGH — affects the hardware-friendly goal and any hardware support claim | MEDIUM — Fedora's NVIDIA path requires third-party repositories and MOK enrolment | Eldora OS V1 hardware support | RES-0002 FE5, RX4 | Validate with probe PX3 before declaring corresponding hardware support/certification. | RES-0002; PX3 | Project Owner | — |
| RISK-0003 | The image-based/bootc direction is strategically relevant, but its desktop maturity is not yet proven. | OPEN | MEDIUM — package-based (M1) remains a valid fallback candidate | HIGH — Fedora states bootc production capacity has not been reached; no official bootc desktop exists | Eldora OS V1 composition and update model | RES-0001 FD7, FD8, FD12, RK1–RK5 | Investigate in Waves 0.1B–0.1D; probe PX5 (proposed); keep M1 as mandatory fallback. | Q-0001, Q-0008; RES-0001; PX5 | Project Owner | — |
| RISK-0004 | Eldora must avoid unnecessary coupling that would make future evolution of the base prohibitively expensive. | OPEN | HIGH — base changes after release imply user rebase/reinstall | MEDIUM — depends on design choices not yet made | Eldora OS architecture (V1 and later) | RES-0001 Q7; RES-0002 FX1–FX3, RX5 | Consider coupling explicitly in Waves 0.1B–0.1D and 0.4; prefer declarative, in-repository composition and Eldora-controlled update channels (RES-0001 Q7). | Q-0001, Q-0004; RES-0001; RES-0002 | Project Owner | — |
| RISK-0005 | Configuration and user/group drift in image-based models. | OPEN | MEDIUM — undermines predictability and reproducibility of machine state even when `/usr` is image-owned | HIGH — documented upstream behaviour (whole-file `/etc` merge; hidden image users after local `/etc/passwd` edits; UID/GID drift) | Eldora OS V1 composition (M3, also M2) | RES-0003 FS3, FS6, RC-A | Validate with probe PB3 (Wave 0.1B-P); apply working principles P1–P3 (review record 0.1B). | Q-0001, Q-0008; RES-0003; PB3 | Project Owner | — |
| RISK-0006 | No supported persistent host-extension/administration mechanism in bootc (M3), conflicting with "Powerful when needed" and "Yours". | OPEN | HIGH — affects advanced users, developers and local administration | HIGH — current documented state (sysext/confext unsupported; layering breaks `bootc upgrade`; host dnf changes transient) | Eldora OS V1 composition (M3) | RES-0003 FS7, IM6, RC-B | Validate with probe PB2 (Wave 0.1B-P); keep M1 as required fallback; M2b kept on record. | Q-0001; RES-0003; PB2 | Project Owner | — |
| RISK-0007 | Permissive default trust in the image-based update chain. | OPEN | HIGH — unsigned or unauthorised images could be accepted as system updates | MEDIUM — hardening is configurable but not default | Eldora OS V1 update chain (M3) | RES-0003 FR4, L7, RC-C | Validate with probe PB5 (Wave 0.1B-P); policy design forwarded to Wave 0.1C. | Q-0008; RES-0003; PB5 | Project Owner | — |
| RISK-0008 | No freshness/anti-rollback guarantee in the OCI update chain: a validly signed older image could be replayed. | OPEN | HIGH — clients could be moved back to older, vulnerable system images | MEDIUM — demonstrated in the laboratory with `matchRepository` identity by re-pointing a tag without any signing key; exact identity blocks cross-tag replay but prevents tag promotion | Eldora OS V1 update chain (M3) | RES-0004 PB5 T7a–T7c, RC-D | Design freshness/identity strategy in Wave 0.1C; signing strategy in Wave 0.1D. | Q-0008; RES-0004 | Project Owner | — |
| RISK-0009 | Insufficiently verified build inputs can introduce unauthenticated content even when the final image is signed. | OPEN | HIGH — a signed image would carry unauthenticated content | MEDIUM — observed default: local RPMs installed in image builds without OpenPGP verification; locally built images deployed unverified | Eldora image build pipeline (M3; also M1 package builds) | RES-0004 PB5 (build warning), PB2 (local image), RC-E | Address build-input verification in Wave 0.1D. | Q-0001, Q-0008; RES-0004 | Project Owner | — |
| RISK-0010 | Staged OS updates are silently discarded on UEFI installs when `/boot` is served by a systemd GPT auto-generator automount (no failure stamp, no user signal). **RELEASE BLOCKER FOR M3** (ADR-0001 condition C2). | OPEN | HIGH — users silently stay on old, possibly vulnerable images | HIGH — reproduced deterministically in the laboratory on a UEFI `bootc install to-disk` installation without fstab `/boot` entry | Eldora OS V1 image/installer design (M3) | RES-0005 "UEFI `/boot` finding", RC-F | Must be resolved before release (ADR-0001 C1, C2). `systemd.gpt_auto=0` is a LAB-VALIDATED MITIGATION only. Design in Waves 0.1C (failure detection/signalling) and 0.1D (installer/image configuration). | Q-0001 (ADR-0001), Q-0008; RES-0005 | Project Owner | — |
| RISK-0011 | OS image rollback does not roll back the boot chain (shim/grub), so a faulty bootloader update is not undone by rollback. | OPEN | HIGH — a bad boot-chain update could prevent booting any deployment | LOW–MEDIUM — observed behaviour ("Ignoring downgrade"); a faulty boot-chain update was not observed | Eldora OS V1 update/rollback (M3) | RES-0005 E3, RC-G | Define boot-chain update and recovery behaviour in Waves 0.1C/0.1D (ADR-0001 condition C8). | Q-0008; RES-0005 | Project Owner | — |

## Migration note

RISK-0001 to RISK-0004 replace the provisional identifiers R-FEDORA-01 to
R-FEDORA-04 (decision D14), with meaning preserved (D18):

| Former ID | New ID |
|---|---|
| R-FEDORA-01 | RISK-0001 |
| R-FEDORA-02 | RISK-0002 |
| R-FEDORA-03 | RISK-0003 |
| R-FEDORA-04 | RISK-0004 |
