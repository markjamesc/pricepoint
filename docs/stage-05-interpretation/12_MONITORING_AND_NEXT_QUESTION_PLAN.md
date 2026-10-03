# 12_MONITORING_AND_NEXT_QUESTION_PLAN — PRICEPOINT-001 (draft v1)
SIMULATION / NON-LIVE. Bound to Stage 4 receipt 9536fe98… and design v5.4 3cfc71eb…. Applies R5-Q3 and R11.

| Element | Contract |
|---|---|
| Exposure | None. 0 price changes, so there is no pilot treatment, no pilot KPI readout and no rollback this cycle. |
| Primary readiness metric | At the next governed run: the locked A1 (≤ 0.40) and A2 (±0.20) at the binding origin. These are locked thresholds; none is newly chosen here. |
| Business KPI (only if a future package becomes decision-valid) | 28-day product revenue (units × shelf price) versus current price, per the locked decision statement |
| Guardrail | ρ̂ ≥ 0.90 (hard) on any future candidate; N_CAP 25 hard; no padding |
| Success trigger | A future validated Stage 4 run, under a design fixed before execution, passes A1 and A2. Only then may Stage 5 evaluate a non-empty package. |
| Failure trigger | Either test fails, so hold_ne remains and no diagnostic candidate is elevated |
| Escalation trigger | Any proposal to change A2 or the collapse goes to Stage 3 change control plus an owner decision before execution, never after results |
| Rollback | Not applicable this cycle. Any future pilot must define a rollback threshold before launch (deployment prerequisite). |
| Owner | Morgan Lee (simulated) owns the decision review. The human analyst (owner) owns escalation and approval. |
| Timing | Next 4-week review cycle, or the next governed run, whichever applies |

## Next analytical questions
1. **Primary (Stage 3, per R11): A2 small-denominator handling.** How should the A2 calibration test treat items with very small realized units, for example a minimum-units floor, a robust or trimmed form, or a weighted mean? Decide before any future run.
   - **Why:** one item (FOODS_3_092, U = 1) contributes 0.1872 of A2 0.2697 (coordinator arithmetic). The current rule lets a single near-zero item decide the gate.
2. **Secondary (non-binding, R5-Q3): the A3/T6 comparison.** Does the price-plus-calendar model rank realized revenue changes better than the calendar-only model on items whose price changed?
   - **Why:** this tests the "flat price response" falsifier and the mechanism behind the hypothesis.
3. **Secondary (diagnostic only): A2 breakdown.** Median signed error, share of positive errors and per-item influence, reported independently by R-A and R-B in a future Stage 4.
   - **Why:** it validates the R11 caveat instead of relying on coordinator arithmetic. It must not be used to repair or bypass a gate after the fact.
4. **Data question.** Was FOODS_3_092 out of stock or delisted in d_1914–d_1941?
   - **Why:** this is the C7 stockout confounder. M5 has no inventory field, so this is likely unanswerable from M5 alone; record it as such.
