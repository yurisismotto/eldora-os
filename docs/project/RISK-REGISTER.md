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

Severity and likelihood of RISK-0001 to RISK-0004 were proposed by the agent
that recorded the migration, based on the cited evidence; the Project Owner
may adjust them.

| ID | Title | Status | Severity | Likelihood | Scope | Source / evidence | Mitigation or validation | Related | Owner | Resolution / closure evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| RISK-0001 | Fedora's short cadence and lack of an LTS may impose excessive rebase cost on a small team. | OPEN | HIGH — recurring cost for the whole V1 lifetime | MEDIUM — cadence is certain (~13 months support, no LTS); whether the cost is excessive is unmeasured | Eldora OS V1 base (OB-0004) | RES-0002 FE1, FE12, RX1 | Validate with probe PX1 before freezing irreversible composition, update or release-lifecycle decisions; consider kernel gating and CI-built rebases (RES-0002). | Q-0001, Q-0008; RES-0002; PX1 | Project Owner | — |
| RISK-0002 | NVIDIA + Secure Boot must be validated for the hardware experience Eldora intends. | OPEN | HIGH — affects the hardware-friendly goal and any hardware support claim | MEDIUM — Fedora's NVIDIA path requires third-party repositories and MOK enrolment | Eldora OS V1 hardware support | RES-0002 FE5, RX4 | Validate with probe PX3 before declaring corresponding hardware support/certification. | RES-0002; PX3 | Project Owner | — |
| RISK-0003 | The image-based/bootc direction is strategically relevant, but its desktop maturity is not yet proven. | OPEN | MEDIUM — package-based (M1) remains a valid fallback candidate | HIGH — Fedora states bootc production capacity has not been reached; no official bootc desktop exists | Eldora OS V1 composition and update model | RES-0001 FD7, FD8, FD12, RK1–RK5 | Investigate in Waves 0.1B–0.1D; probe PX5 (proposed); keep M1 as mandatory fallback. | Q-0001, Q-0008; RES-0001; PX5 | Project Owner | — |
| RISK-0004 | Eldora must avoid unnecessary coupling that would make future evolution of the base prohibitively expensive. | OPEN | HIGH — base changes after release imply user rebase/reinstall | MEDIUM — depends on design choices not yet made | Eldora OS architecture (V1 and later) | RES-0001 Q7; RES-0002 FX1–FX3, RX5 | Consider coupling explicitly in Waves 0.1B–0.1D and 0.4; prefer declarative, in-repository composition and Eldora-controlled update channels (RES-0001 Q7). | Q-0001, Q-0004; RES-0001; RES-0002 | Project Owner | — |

## Migration note

RISK-0001 to RISK-0004 replace the provisional identifiers R-FEDORA-01 to
R-FEDORA-04 (decision D14), with meaning preserved (D18):

| Former ID | New ID |
|---|---|
| R-FEDORA-01 | RISK-0001 |
| R-FEDORA-02 | RISK-0002 |
| R-FEDORA-03 | RISK-0003 |
| R-FEDORA-04 | RISK-0004 |
