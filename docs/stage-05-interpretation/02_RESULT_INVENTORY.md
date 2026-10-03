# 02_RESULT_INVENTORY — PRICEPOINT-001 Stage 5 (draft v2; v1 7b135a0f… preserved; R-11 "Checked by" corrected per FA5_AI3 R7)
SIMULATION / NON-LIVE. Bound to Stage 4 receipt 9536fe98…664d and design v5.4 3cfc71eb…80ef.
Statuses use the framework §8 vocabulary. "Checked by" lists who independently confirmed each value.

| Result | Value | Status | Source artifact / field | Checked by |
|---|---|---|---|---|
| R-01 | d_1913 binding backtest: A1 median APE 0.1824 (limit ≤ 0.40, pass); A2 mean signed error 0.2697 (limit ±0.20, **fail**); backtest_accept 0; n_usable 345; U0 excluded 5. Unrounded A1 0.18243343920694519 and A2 0.2696681754366238 (audit.csv). | Validated | model_validation.json primary (ce09ea11…); model.json (d27a6c4f…); audit.csv (e76ab012…) | R-A = R-B (Stage 4); box (E-3/E-6); AI 3 r2 (n_U0, sign) and XR5_AI3 #3 (Verified); AI 2 |
| R-01s | Sign convention: signed_error = (Û − U)/U, so positive = over-prediction | Validated | design §16.3; per_item rows | box; AI 3 (3 spot checks); AI 2 |
| R-01c | FOODS_3_092: U = 1, Û = 65.6009, signed_error 64.6009. Its share of A2 is 64.6009/345 = 0.1872. | Row: Validated. The 0.1872 share: **coordinator arithmetic on validated per-item rows** (R11). | model_validation.json primary.per_item | box; AI 3 quoted the row |
| R-02 | d_1885 stability: A1 0.1722, A2 0.1794, n_usable 335, U0 14, backtest_accept_reported_only 1 | Validated with limitation (receipt-level only, no per-item rows; non-binding per §16.4) | model_validation.json stability | AI 2; AI 3 |
| R-03 | Penalty 0.0021 (grid idx 14) at all origins; glmnet α 0.5; thresh 1e-12; seed 20160522 | Validated | model.json | AI 3 (Correct) |
| R-04 | 2,484/2,484 hold_ne; package 0; below-line 0; legal changes 0; raise/cut/unchanged 0; trust-eligible 338; te6 347 | Validated | universe.csv (e1d7545e…); audit.csv; manifest (3206e412…) | box; AI 2 (tally); AI 3 (X2/X3, Verified) |
| R-05 | Reconciliation 75/75, mismatch 0 | Validated | reconciliation.csv/json | AI 3 (Verified) |
| R-06 | Source Gate r2 24/24 | Validated | source.json | AI 3 |
| R-07 | Fixtures 26/26 on both paths | Validated | fixtures.json | AI 3 |
| R-08 | Cross-review: 14 findings; XR-04..14 accepted limitations (R10); 0 unresolved | Validated | findings_register.csv; cross_review.md | AI 3 |
| R-09 | Validation Gate approved 2026-10-02 14:35 CT | Validated | validation.json | AI 3 |
| R-10 | candidates.csv: 3,654 rows for 1,758 items, diagnostic only, **not decision-valid** (collapse) | Validated (diagnostic only) | candidates.csv | box; AI 3 |
| R-11 | dept_backtest_MAE_revenue: FOODS_1 74.3558, FOODS_2 62.3338, FOODS_3 71.313, HOUSEHOLD_1 45.7697, HOUSEHOLD_2 62.0567 | Validated; diagnostic only | model_validation.json primary | box; AI 2 (first pass C-20); AI 3 via XR5_AI3 #40 cross-review |
| G-1 | A3 (Spearman of price+calendar vs calendar-only T6) and twins T2–T9 **not produced** | Unsupported (absent). Disclosed gap; owner R5-Q3 says non-binding and not required. | Stage 4 log F-03 | AI 1, AI 2, AI 3 |
| G-2 | action_twin_11616 blank for all rows | Disclosed gap (R5-Q2); collapse applies to twins | universe.csv | AI 3 |

## Excluded or superseded
- AI 3 r1 audit (a4aba498…): it had no file access. Kept for the record, not used.
- AI 3 r2 F-03 ("346 usable / A2 ≈ 0.4556"): **Rejected**. It rests on a miscount (E-6), and AI 3 withdrew it in XR5_AI3 (a).
- Any leave-one-out or counterfactual A2: not a result (R11).
