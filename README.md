# PricePoint

**AI-Augmented Pricing & Revenue Decision System using the M5 retail dataset**

PricePoint is **Dataset 3 of 3** in a portfolio evaluation of the five-stage **AI-Augmented Analyst** methodology.

The project is designed to test the same decision-first workflow on a retail pricing problem with a materially different data shape from FulfillIQ 2.0 and Chicago 311.

## Five-stage method

1. **Start**
2. **Framing**
3. **Measurement Design**
4. **Execution, Independent Validation, and Analysis**
5. **Interpretation and Recommendation**

The reusable methodology is documented separately in [`ai-augmented-analyst-workflow`](https://github.com/markjamesc/ai-augmented-analyst-workflow).

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
EXACT RECONCILIATION
        |
        v
STRUCTURAL CROSS-REVIEW
        |
        v
VALIDATED DATA FREEZE
        |
        v
STAGE 5
```

SQL is used for controlled source delivery and verification. Analytical meaning is frozen in Stage 3 and independently implemented in R-A and R-B.

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
│   ├── stage-03-measurement-design/
│   ├── stage-04-execution-validation/
│   └── stage-05-interpretation/
├── sql/source-delivery/
├── R/r-a/
├── R/r-b/
├── validation/source-gate/
├── validation/fixtures/
├── validation/reconciliation/
├── validation/cross-review/
├── outputs/
└── data-documentation/
```

Raw M5 files are not committed to this repository.

## Status

**Database setup complete. Analytical stages not yet started.**

The exact pricing/revenue decision and framing question must be established through Stages 1–2 rather than assumed from the dataset alone.

## Copyright

Copyright © 2026 Mark Ciganovic. All rights reserved. See [`COPYRIGHT.md`](COPYRIGHT.md).
