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

### GrokBot project prompt

Give GrokBot [the PricePoint Master Orchestration Prompt](docs/orchestration/master-orchestration-prompt.md). Section 17 contains project configuration and executable R checkpoints for every stage, using the pinned workflow version in the [framework manifest](docs/orchestration/controlling-framework-manifest.md). GrokBot must resolve the two local repository paths before execution. The existing local Workflow Gate and the canonical release check both remain required; the run finishes only with the outer Procedure Gate certificate. No business decision, horizon, or guardrail is pre-approved by this prompt.

**Database setup complete. Analytical stages not yet started.**

The exact pricing/revenue decision and framing question must be established through Stages 1–2 rather than assumed from the dataset alone. This means the workflow-enforcement upgrade does not invalidate any completed analytical stage.

## Copyright

Copyright © 2026 Mark Ciganovic. All rights reserved. See [`COPYRIGHT.md`](COPYRIGHT.md).
