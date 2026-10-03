# 01_STAGE_05_EVIDENCE_PACKAGE — PRICEPOINT-001 (controlled combination)

Part A: 01_STAGE_05_EVIDENCE_PACKAGE.v1.md (sha256 1476d664648613813fb3f4e1e50f307d9171980a86c7f9e4620413d1eb1500f6), verbatim. Part B: 01a_STAGE_05_EVIDENCE_ADDENDUM.v2.md (sha256 300a43c03b60a655b82ee1cf47904cee8e099f9dfc78fd70ab742703895ce4d5), verbatim. Bundle: evidence_pkg_v1.zip fd1307c32111595f14e0737e6e48475c950da8ecf5dfbe27ed3071102904aee3 (28 files; SHA256SUMS.txt 21a24f4a…). AI 3 r2 upload set: SHA256SUMS_ai3_r2_upload.txt 39dc2b06….

---
## Part A
# 01_STAGE_05_EVIDENCE_PACKAGE — PRICEPOINT-001 (v1, FROZEN 2026-10-02 ~20:50 CT)

**SIMULATION / NON-LIVE.** This uses historical M5 CA_1 data. No price has been changed or released anywhere. A Stage 4 PASS unlocks interpretation only.

## Bindings
| Item | Identity |
|---|---|
| Run | PRICEPOINT-001. `pp_gate.R begin finish` returned AUTHORIZED 2026-10-02 20:44:55 CT; check report finish-begin.json 5c0543a6… |
| Stage 4 receipt | stage4_validation_status.json **9536fe9832310cb9b23f8af60862bf7b47b1a3c0b97939146e2d29543f3a664d** |
| Design | 08_CONSOLIDATED_CANDIDATE_v5_4 **3cfc71eb5e10c5f680e1768400d03daf05513a23199740ac9f80f8adff2b80ef** (plus 10_…v5_4 b913c82f…, 11_…v5_4 b8d67ce4…) |
| Stage 3 receipt | v4 1ee9f4da9cffe3a906182d209c573b61c7451387cfc338009261c79f8620dd16 |
| Workflow Gate report | workflow_gate_status.json 5401b40b87f467f4cfce0a55b732a5cc41a4c96dc8d7984c39c896e2a5903a58 |
| Framework | three-ai-interpretation-and-recommendation-framework.md 77e666b4… |
| Bundle | evidence_pkg_v1.zip. The per-file sha256 is listed in evidence_pkg_v1/SHA256SUMS.txt (28 files). |

## Locked inputs (folder locked/)
- **Decision statement** (T035): decision_statement_T035.txt. Decision owner: Morgan Lee, Pricing & Revenue Manager (SYNTHETIC). The recommendation goes to the store GM.
- **Analytical question** (C2): framing_question_C2.txt.
- **Decision options:**
  - pilot raise;
  - pilot cut;
  - unchanged;
  - "hold — not enough evidence" (hold_ne).
- **Capacity:** a GM package of at most 25 changes (N_CAP 25, hard). The list is not padded; extra qualifiers go below the line.
- **Guardrail:** rho ≥ 0.90 (hard), so no change expected to cut units by more than about 10%.
- **Horizon:** d_1942–d_1969 (2016-05-23 to 2016-06-19). The origin is d_1941 and the leakage boundary is week 11618.
- **Population:** 2,484 CA_1 items in FOODS_1/2/3 and HOUSEHOLD_1/2 (OC-1 a). Each item gets exactly one row and one action.
- **Trust subset:** E_A + pw52 + candidate-exists + te6 (OC-5, slice-only).
- **Conclusion ceiling:** predictive expectation (design §5). The only allowed claim form is: "Under the locked model this is the 28-day expectation to pilot-test; it is not a guarantee and not a causal effect."
- **Backtest collapse (§16.3/§17.R8, M4-013):**
  - At origin d_1913, the backtest passes only if A1 (median APE) ≤ 0.40 AND A2 (mean signed error) is within [−0.20, +0.20].
  - If it fails, every trust-eligible item → hold_ne, including model-based unchanged.
  - The d_1885 result is a stability check, reported only.

## Validated Stage 4 results (status: Validated)
| ID | Result | Source |
|---|---|---|
| R-01 | Mode A backtest at d_1913: A1 = 0.1824 (passes), **A2 = 0.2697 (fails ±0.20)**, backtest_accept = 0. n_usable 345, U0 excluded 5. | model_validation.json ce09ea11…; model.json d27a6c4f… |
| R-02 | d_1885 stability: A1 0.1722, A2 0.1794 (reported only, not binding) | same |
| R-03 | Penalty 0.0021 (grid idx 14), glmnet α 0.5, thresh 1e-12 (CC-S4-01), seed 20160522 | model.json |
| R-04 | Outcome: 2,484/2,484 hold_ne; package 0; below-line 0; legal changes 0; trust-eligible 338; TE6 usable slice 347 | universe.csv e1d7545e…; manifest 3206e412… |
| R-05 | R-A r2 and the independent R-B r10 reconcile 75/75, mismatch 0 | reconciliation.csv 5535102a…; reconciliation.json be03c090… |
| R-06 | Source Gate r2 PASS 24/24 | source_gate_report.csv 5d087e2d…; source.json de7ae9c2… |
| R-07 | Fixtures: 26/26 on both paths | fixtures.json abdde7f6… |
| R-08 | Cross-review: 14 findings; XR-01..03 resolved; XR-04..14 accepted limitations (owner R10); unresolved 0 | cross_review.md 2a9cec57…; findings_register.csv 90fa70e6… |
| R-09 | Validation Gate approved by the owner 2026-10-02 14:35 CT (simulation; Stage 5 interpretation only) | validation.json ce38a8c7… |
| R-10 | candidates.csv: 3,654 candidate rows with diagnostic predictions. **Not decision-valid**, because the collapse applies. | candidates.csv 772450cd… |

Change controls: CC-S3-01, CC-S4-01 (thresh 1e-12), CC-S4-02 (cent_delta_rev sign + $0.05).

## Disclosed process limitations (preserve; do not repair)
- The Stage 4 findings register v1 (fd41c136…) was lost by overwrite. The current register 90fa70e6… is the approved one.
- Morgan Lee is a simulated stakeholder.
- 23 Stage 3 blocks are coordinator mechanical fallback (see the receipt's authorship_provenance).

## File inventory rule
Each AI must list which bundle files it actually opened. It must not claim a file it did not read, and must not compute new decision results. Any needed new computation is returned to Stage 4 as "Recompute in Stage 4".

---
## Part B
# 01a_STAGE_05_EVIDENCE_ADDENDUM v2 — PRICEPOINT-001 (coordinator; existing artifacts only; supersedes v1 f759253c…, which is preserved)
This addendum supplements 01_STAGE_05_EVIDENCE_PACKAGE.v1.md (1476d664…). It is issued to all three AIs with the cross-review packets only. It is NOT given to AI 3 for its r2 first pass, because E-3 would anchor AI 3's independent recomputation. AI 3 r2 gets the ruling text through X6 instead.
- **E-1. Owner ruling R5-Q3** (2026-10-02 09:57 CT; OWNER_RULINGS_R1-R6.md 2ce662c1…): "A3/T6 reported, non-binding, not required for this gate."
  - Stage 4 did not produce A3 (Spearman, price+calendar vs calendar-only T6). This is a disclosed Stage 4 gap (Stage 4 log F-03).
  - The other twins T2–T9 are also not in the §22 judged-output contract and were not produced.
- **E-2. Owner ruling R5-Q2:** the collapse applies to twins (T1 → hold_ne). R-A's action_twin_11616 = NA is a disclosed gap (Stage 4 log F-01).
- **E-3. Box verification of the headline numbers** (coordinator, mechanical, 2026-10-02 ~20:55 CT), from model_validation.json primary.per_item and universe.csv:
  - n_usable 345, median ape 0.1824, mean signed_error 0.2697;
  - universe 2,484 rows, all hold_ne, trust_eligible 338, te6 347;
  - signed_error = (pred_units − realized_units)/realized_units, so positive = over-prediction (e.g. FOODS_1_004: pred 25.7276, realized 95, signed −0.7292).
- **E-4. AI 3 r1** could not open the zip. AI 3 r2 received individual files plus mechanical extracts (ai3_r2_upload/, make_extracts.py).
- **E-5. d_1885:** no per-item rows exist. The d_1885 figures are receipt-level only: n_usable 335, U0 14, A1 0.1722, A2 0.1794, backtest_accept_reported_only 1.
- **E-6. Correction to AI 3 r2 F-03** (coordinator, mechanical check of X1 492469b3…, the same rows as model_validation.json primary.per_item):
  - X1 has 359 base_trust rows. 9 have stable_price = 0: FOODS_2_364, FOODS_3_227, FOODS_3_269, **FOODS_3_469**, FOODS_3_535, FOODS_3_645, FOODS_3_782, HOUSEHOLD_1_449, HOUSEHOLD_1_497. AI 3 listed 8 and omitted FOODS_3_469.
  - 5 have realized_units = 0. That leaves **345 usable rows**, and FOODS_3_092 is one of them.
  - Over those 345 rows: median ape = 0.1824, mean signed_error = 0.2697. This **confirms the official A1/A2 and n_usable** (R-01).
  - AI 3's "346 / A2 ≈ 0.4556" and the "Recompute in Stage 4" rows that follow from it (r2 §3.1, §8, §9, §10) rest on that miscount.
  - The d_1885 per-item rows do not exist (E-5). R-02 is reported-only and not binding.
- **E-7. Owner ruling R11** (2026-10-02 21:11 CT; stage5/rulings/OWNER_RULING_R11.md 5a13bba9…; bound to HC-1 brief 86083b97…). Verbatim:
  > R11: Option A. Keep the A2 lock and the collapse outcome for PRICEPOINT-001. Disclose the FOODS_3_092 single-item contribution (0.1872 of A2 0.2697) as the most important caveat, labelled coordinator arithmetic on validated per-item rows. Do not present the leave-one-out figure as a result. Route the A2 small-denominator gap to Stage 3 as the next analytical question.
  - The facts behind it are observed in the validated model_validation.json per_item. FOODS_3_092 (FOODS_3): realized units d_1914–d_1941 = 1; predicted = 65.6009; signed_error = ape = 64.6009. Its contribution 64.6009/345 = 0.1872 is coordinator arithmetic, not a Stage 4-validated diagnostic.
  - Under R11, the A2 lock, the collapse and the outcome of 2,484 hold_ne / 0 changes all stand. No leave-one-out or other counterfactual A2 may be stated as a result.
