# PricePoint

**AI-Augmented Pricing & Revenue Decision System using the M5 retail dataset**

PricePoint is **Dataset 3 of 3** in a portfolio evaluation of the five-stage **AI-Augmented Analyst** methodology.

The project tests the same decision-first workflow on a retail pricing problem with a materially different data shape from FulfillIQ 2.0 and Chicago 311.

## Five-stage method

1. **Start**
2. **Framing**
3. **Measurement Design**
4. **Execution, Independent Validation, and Analysis**
5. **Interpretation and Recommendation**

The reusable methodology is documented separately in [`ai-augmented-analyst-workflow`](https://github.com/markjamesc/ai-augmented-analyst-workflow).

PricePoint also uses a separate **deterministic R workflow gate**. Stage 4 R-A/R-B validates the analysis; the workflow gate verifies that the prescribed five-stage procedure was actually followed before Stage 5 can begin.

## Current data layer

The local MySQL schema is:

```text
pricepoint
```

Raw source tables currently prepared:

```text
raw_calendar              1,969 rows
raw_sell_prices       6,841,121 rows
raw_sales_evaluation     30,490 rows
```

`raw_sales_evaluation` stores one product-store series per row, with **1,941 daily unit-sales values** preserved as a JSON array. This avoids prematurely expanding the full M5 history into roughly 59 million product-store-day rows before the business decision and analytical scope are locked.

## Core architecture

```text
LOCKED STAGE 3
      |
      v
CONTROLLED SQL SOURCE
bounded, faithful, nonjudgmental
      |
      v
SQL SOURCE GATE
      |
   -----------
   |         |
   v         v
  R-A       R-B
independent judged paths
   |         |
   -----+-----
        |
        v
FIXTURE GATE + EXACT RECONCILIATION
        |
        v
STRUCTURAL CROSS-REVIEW
        |
        v
VALIDATED DATA FREEZE
        |
        v
R WORKFLOW GATE
procedural compliance
        |
   PASS / FAIL
        |
        v
STAGE 5 only on PASS
```

SQL is used for controlled source delivery and verification. Analytical meaning is frozen in Stage 3 and independently implemented in R-A and R-B. The separate workflow gate then checks stage locks, version continuity, required validation statuses, evidence-file existence, and decision-critical model validation when applicable.

Run the workflow gate from the repository root with:

```bash
Rscript validation/workflow-gate/workflow_gate.R .
```

Stage 5 is prohibited unless `validation/workflow-gate/workflow_gate_status.json` reports `PASS` and `stage5_allowed = true`.

## PricePoint-specific guardrail

The raw M5 dataset is large enough to create unnecessary computational cost if expanded indiscriminately. The project therefore requires both:

- **decision feasibility** — the proposed decision must be materially answerable from the available data; and
- **delivery feasibility** — Stage 3 must define the smallest faithful source-delivery envelope that preserves everything required for the decision without embedding judged analytical logic upstream.

A full-history, full-product long-form expansion is **not** the default.

## Repository map

```text
pricepoint/
├── README.md
├── COPYRIGHT.md
├── docs/
│   ├── source-manifest.md
│   ├── dataset-eval-context.md
│   ├── warrant-ledger.md
│   ├── orchestration/
│   │   ├── master-orchestration-prompt.md
│   │   └── controlling-framework-manifest.md
│   ├── stage-01-02-start-framing/
│   │   ├── stage1_decision.example.json
│   │   └── stage2_framing.example.json
│   ├── stage-03-measurement-design/
│   │   └── stage3_locked_design.example.json
│   ├── stage-04-execution-validation/
│   │   └── stage4_validation_status.example.json
│   └── stage-05-interpretation/
├── sql/source-delivery/
├── R/r-a/
├── R/r-b/
├── validation/source-gate/
├── validation/fixtures/
├── validation/reconciliation/
├── validation/cross-review/
├── validation/workflow-gate/
│   ├── workflow_gate.R
│   └── README.md
├── outputs/
└── data-documentation/
```

The `.example.json` files are templates; actual receipts are created only after the corresponding stage gate truthfully passes.

Raw M5 files are not committed to this repository.

## Prospective workflow update

The project prompt, receipt templates and R gate now require explicit capacity and ML-mode declarations plus hashed evidence receipts. See [executable contract v2](validation/workflow-gate/CONTRACT_V2.md). This setup change does not begin the analytical run or approve a stage.

## Status

**PRICEPOINT-001 is CERTIFIED** (five-stage Procedure Gate `finalize` → `result: PASS`, `certified: true`, 2026-10-02 22:01:47 CT / 2026-10-03T03:01:47Z).

| Record | sha256 |
|---|---|
| [`artifacts/final_certificate.json`](artifacts/final_certificate.json) | `223411d0726e04727d0a21505d9565b2463b417b7f01d2ba3ec5bd2efcaf18cf` |
| [`artifacts/stage5_interpretation_status.json`](artifacts/stage5_interpretation_status.json) (Stage 5 receipt) | `518856ea7a57fe1de4d5ff3fad181a9ca7c5b57228e4254135a2ca34831a97a8` |
| [`artifacts/stage4_validation_status.json`](artifacts/stage4_validation_status.json) (Stage 4 receipt) | `9536fe9832310cb9b23f8af60862bf7b47b1a3c0b97939146e2d29543f3a664d` |
| [`docs/stage-05-interpretation/11_STAGE_05_DECISION_EVALUATION.md`](docs/stage-05-interpretation/11_STAGE_05_DECISION_EVALUATION.md) | `cbf3f562eebcf7656c5ec02274ca2f80b62120df5fd30b157ea86ae004674d6f` |
| Locked design `08_CONSOLIDATED_CANDIDATE_v5_4.md` (CC-S4-02) | `3cfc71eb5e10c5f680e1768400d03daf05513a23199740ac9f80f8adff2b80ef` |

**SIMULATION / NON-LIVE.** Historical M5 CA_1 analysis with a simulated stakeholder (Morgan Lee). Certification authorizes no live price change.

### Recommendation

For the locked horizon d_1942–d_1969 (2016-05-23 through 2016-06-19): **0 shelf-price changes**. All **2,484** CA_1 items in FOODS_1/2/3 and HOUSEHOLD_1/2 are **`hold_ne`** (hold, not enough evidence); the GM package is 0 of 25 and the below-line list is empty.

Reason: the locked binding backtest at origin d_1913 passed A1 (median APE **0.1824** ≤ 0.40) but **failed A2** (mean signed error **0.2697**, outside ±0.20), so `backtest_accept = 0` and the locked collapse rule applies. `hold_ne` is an insufficient-evidence classification, not a finding that current prices are optimal. The claim ceiling is predictive; nothing here is a causal price effect.

### Most important caveat (owner ruling R11, verbatim)

> R11: Option A. Keep the A2 lock and the collapse outcome for PRICEPOINT-001. Disclose the FOODS_3_092 single-item contribution (0.1872 of A2 0.2697) as the most important caveat, labelled coordinator arithmetic on validated per-item rows. Do not present the leave-one-out figure as a result. Route the A2 small-denominator gap to Stage 3 as the next analytical question.

FOODS_3_092 had 1 realized unit against 65.6009 predicted (signed error 64.6009 over 345 usable items). The run records (`docs/rulings/HC1_BRIEF_A2_SINGLE_ITEM.v1.md`, `docs/run-logs/STAGE5_LOG.md`) show the pre-ruling coordinator diagnostic; per R11 it is not a result.

### Case-study contents (the certified run)

| Path | Contents |
|---|---|
| `docs/stage-01-02-start-framing/` | Stage 1–2 dialogue, packets, raw AI reviews, receipts |
| `docs/stage-03-measurement-design/` | Three-AI design, cross-review, audits, locked design, change-control records CC-S3-01 / CC-S4-01 / CC-S4-02, superseded receipts |
| `docs/stage-04-execution-validation/` | Evidence JSONs, validated data manifest, Validation Gate approval, Stage 4 receipt |
| `docs/stage-05-interpretation/` | Stage 5 deliverables 01–12 and the HC-2/HC-3 owner approval record |
| `artifacts/` | Procedure Gate state, check records (`artifacts/procedure/checks/`), amendment archive, stage receipts, `final_certificate.json` |
| `sql/source-delivery/`, `validation/source-gate/` | mysql-CLI extract queries and the SQL Source Gate (r2, with superseded r1) |
| `R/r-a*/`, `R/r-b*/` | Independent R-A and R-B implementations, including every R-B revision (r2–r10); certified paths are R-A r2 and R-B r10 |
| `validation/` | Fixture results, exact reconciliation, structural cross-review, workflow gate status |
| `outputs/pricepoint-001/` | Validated outputs of R-A r2 and R-B r10 (universe, candidates, audit, model validation, lineage, session info) |
| `data-documentation/extract-records/` | Extract freeze record, manifest, snapshot record and raw-side gate aggregates |
| `docs/rulings/` | Owner rulings R1–R11, CC-S4-01 change-control approval, HC-1 brief |
| `docs/run-logs/` | Coordinator logs for Stage 3 lock, CC-S3-01 adoption, Stage 4, Stage 5 |
| `docs/orchestration/run-control/` | `pp_gate.R` (run-control helper, kept outside the project during the run) and its pre-CC-S3-01 backup |
| `docs/PRICEPOINT-001_SHA256SUMS.txt` | sha256 of every case-study file as committed |

Hashes are of the exact bytes produced during the run (some files are CRLF). To reproduce them, check out with `core.autocrlf=false`.

### Not committed (size or raw-data policy)

The frozen source extract is **not** in the repository (raw M5 data policy, and `sales_long.tsv` exceeds GitHub's 100 MB limit). Its identity is fixed by hash:

| File (PC: `pricepoint-stage4-work/extract/`) | Bytes | sha256 |
|---|---:|---|
| `sales_long.tsv` | 449,366,357 | `536eb633a3a27a734e9883001213491ae3ae63b8872d824161e13b16aa5ee8ae` |
| `prices.tsv` | 17,472,933 | `0cbd6c8b0ee4b6ea0b52b58094c94e27a2d9b5c31c0d08d3d0e7661a6eb3ce73` |
| `calendar.tsv` | 131,669 | `a2807afd5a1dbd35523c9161128bef31a54332f21cf77889fc168a9fa0086858` |
| `raw_gate/raw_price_rowkeys.tsv` | 16,881,381 | `e3a3ab15ddd91d80c81c9aece8edbe73c4cdc69cfc0ff29b121831f58067b39a` |
| `raw_gate/raw_item_json.tsv` | 249,448 | `ceed69ae04e21f905eb8d7a793e28b7802889d224052c769c37fc2a60c6f6f7c` |

The extract manifest (`sql_extract_sha256` `13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68`) is committed under `data-documentation/extract-records/`. Database credentials (mysql `--login-path`, stored in the local `.mylogin.cnf`) are never committed; only the login-path name appears in run sheets.

### Next analytical question (Stage 3, prospective)

How should the A2 calibration rule handle extreme influence from items with very small realized-unit denominators while preserving A2's role as a calibration guardrail? A3/T6 and an A2 distributional breakdown are secondary, non-binding diagnostics. See [`12_MONITORING_AND_NEXT_QUESTION_PLAN.md`](docs/stage-05-interpretation/12_MONITORING_AND_NEXT_QUESTION_PLAN.md).

### Governance epochs

Stages 1–3 ran under workflow `f388be8` (PricePoint `f9a4897`). Owner change control CC-S3-01 adopted workflow PR #9 (`6ad1e202db986d5c96482f903a7519df747768cd`, procedure-gate `amend`) for the remainder of the run; CC-S4-01 and CC-S4-02 amended the locked design during Stage 4 through that mechanism. The governance-history audit is in the workflow repository.

### GrokBot project prompt

Give GrokBot [the PricePoint Master Orchestration Prompt](docs/orchestration/master-orchestration-prompt.md). Section 17 contains project configuration and executable R checkpoints for every stage. The prompt is unchanged by this publication; it is the version the run used.

## Copyright

Copyright © 2026 Mark Ciganovic. All rights reserved. See [`COPYRIGHT.md`](COPYRIGHT.md).
