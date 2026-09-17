# PricePoint Warrant Ledger

Use this ledger to separate implementation agreement from substantive warrant.

A rule can be translated perfectly by both R-A and R-B and still have weak business or evidentiary justification.

## Status labels

Use one of:

- **Source-backed**
- **Stakeholder-locked portfolio requirement**
- **Methodological judgment**
- **Model-dependent**
- **Unresolved / Open**

## Ledger

| ID | Rule / assumption / threshold | Stage introduced | Basis | Evidence / rationale | Sensitivity needed? | Status |
|---|---|---:|---|---|---|---|
| W-001 | _To be completed during formal run_ | — | — | — | — | Open |

## Required PricePoint entries

At minimum, add explicit ledger entries for any final:

- decision horizon;
- product/store eligibility rule;
- historical lookback;
- minimum history requirement;
- minimum price variation requirement;
- revenue definition;
- unit-sales downside guardrail;
- price-change action threshold;
- `INCONCLUSIVE` / abstention rule if used;
- model choice that materially affects the decision;
- causal-language restriction;
- and final recommendation criterion.

Do not hide a business judgment inside code because two implementations happen to agree on it.
