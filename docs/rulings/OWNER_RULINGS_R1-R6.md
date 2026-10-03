# PRICEPOINT-001 · Stage 4 · Owner ruling record: R1–R6

- **Ruling time:** 2026-10-02 09:57 CT (UTC-5)
- **Ruled by:** Owner (human), as relayed to the coordinator
- **Exact owner text (verbatim):**

> I accept recommendations R1–R6 as written in the brief.

- **Bound document:** `run/VALIDATION_GATE_BRIEF_draft.md` (owner checkpoint packet v4 final)
  - sha256 **77d2f861e1528b31cb7c67617ef3ed13022b798141f2c1847845a8058aaaa689**, re-verified at recording.
  - The rulings are the "Recommendation" text of brief §6 (R1–R6, including R5 items 1–7) in that exact file. Any later edit to the brief does not change this ruling.
- **Context:** design 08_CONSOLIDATED_CANDIDATE_v5_2; fixture_pack_v1. The evidence bound by the brief is R-A r1 vs R-B r7, reconciliation `recon_ra_r1_vs_rb_r7.csv` 964b4a0165b0270787bcf57d08023068d98862fd0edfcb263765ba046c7d2c22.

## Summary of what was accepted (from brief §6; the brief text governs)
| Ruling | Accepted recommendation |
|---|---|
| R1 | Accept the locked backtest collapse (d_1913 A2 outside ±0.20 → all trust-eligible hold_ne → empty package) as the run's result. No Stage 3 change control. |
| R2 | n_floored_days counts the 28 horizon days of the scenario that sets the item's final action; n_floored_days_total is the sum. |
| R3 | Post-collapse values in universe.csv: guardrail_pass, legal_change, package_flag, below_line_flag = 0 (not NA); candidate_price, .pred_*_candidate, delta_rev blank. Pre-collapse scoring stays in candidates.csv. |
| R4 | te6_ape_i (§7.7), dept_backtest_MAE_revenue and gain_below_half_mae (§11) are defined by the locked text and must be emitted. Per-item n_candidates_event_filtered = the item's count of filtered price levels. |
| R5 | R-A Q1: item-by-item §6A attestation required before step 15. Q2: collapse applies to twins (T1 → hold_ne); R-A's NA is a disclosed gap unless R-A is rebuilt. Q3: A3/T6 reported, non-binding, not required for this gate. Q4: R-A's p99 reading is confirmed. Q5: one-row audit accepted as a disclosed representation difference. Q6: tie rule recorded as a design gap; no change now. Q7: to structural cross-review (as is R-B's FX-WDAY-SNAP depth). |
| R6 | No tolerance waiver. The numeric residual stays in the mismatch loop and goes to cross-review for root cause. |

## Status and limits
- These rulings interpret the locked design. The owner made no change-control designation, so none is recorded.
- **This is NOT the Validation Gate approval (runbook step 15).** It must not be reused, cited or recorded as Validation Gate approval in `evidence/validation.json` or the Stage 4 receipt. The Validation Gate needs a separate, explicit owner action after reconciliation PASS and steps 11–14.
