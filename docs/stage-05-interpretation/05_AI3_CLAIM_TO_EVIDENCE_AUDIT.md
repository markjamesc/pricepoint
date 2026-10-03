# 05_AI3_CLAIM_TO_EVIDENCE_AUDIT (r2)

**Run:** PRICEPOINT-001  
**Stage:** 5 — Finish / Interpretation  
**Role:** AI 3 — Claim-to-Evidence and Numerical Auditor  
**Mode:** SIMULATION / NON-LIVE  
**Bound receipt:** Stage 4 receipt `9536fe9832310cb9b23f8af60862bf7b47b1a3c0b97939146e2d29543f3a664d`  
**Bound design:** `08_CONSOLIDATED_CANDIDATE_v5_4` `3cfc71eb5e10c5f680e1768400d03daf05513a23199740ac9f80f8adff2b80ef`

---

## 1. File inventory

| File | Opened? | SHA256 checked against `SHA256SUMS.txt`? | Notes |
| --- | --- | --- | --- |
| `01_STAGE_05_EVIDENCE_PACKAGE.v1.md` | Yes | Hash listed: `1476d664...`; not recomputed | Inline text supplied. |
| `SHA256SUMS.txt` | Yes | Yes, as reference | Lists 28 files. |
| `audit.csv` | Yes | Listed `e76ab012...`; not recomputed | Stage 4 audit table. |
| `model.json` | Yes | Listed `d27a6c4f...`; not recomputed | Model validation summary. |
| `stage4_validation_status.json` | Yes | Listed `9536fe98...`; not recomputed | Stage 4 receipt. |
| `validated_data_manifest.md` | Yes | Listed `3206e412...`; not recomputed | FINAL manifest. |
| `reconciliation.json` | Yes | Listed `be03c090...`; not recomputed | Reconciliation PASS. |
| `fixtures.json` | Yes | Listed `abdde7f6...`; not recomputed | Fixtures PASS. |
| `source.json` | Yes | Listed `de7ae9c2...`; not recomputed | Source Gate PASS. |
| `validation.json` | Yes | Listed `ce38a8c7...`; not recomputed | Validation Gate PASS. |
| `findings_register.csv` | Yes | Listed `90fa70e6...`; not recomputed | Cross-review register. |
| `cross_review.md` | Yes | Listed `2a9cec57...`; not recomputed | Cross-review PASS. |
| `decision_statement_T035.txt` | Yes | Listed `b30ae5be...`; not recomputed | Decision statement. |
| `framing_question_C2.txt` | Yes | Listed `4ab0e3e3...`; not recomputed | Analytical question. |
| `X1_backtest_d1913_per_item_base_trust.csv` | Yes | Cannot hash-verify against original | Mechanical extract. |
| `X2_universe_decision_fields.csv` | Yes | Cannot hash-verify against original | Mechanical extract. |
| `X3_te6_per_item_usable.csv` | Yes | Cannot hash-verify against original | Mechanical extract. |
| `X4_model_validation_summary.json` | Yes | Cannot hash-verify against original | Mechanical extract. |
| `X5_design_v5_4_excerpt.md` | Yes | Cannot hash-verify against original | Verbatim design excerpt. |
| `X6_owner_rulings_R1-R10.md` | Yes | Cannot hash-verify against original | New evidence in r2. |
| `make_extracts.py` | Yes | Cannot hash-verify against original | Extract script. |

**Finding F-01:** The mechanical extracts cannot be hash-verified against their full originals because the full originals were not supplied. This is a disclosed limitation.  
**Finding F-02:** For the original files, I compared the hashes listed in `SHA256SUMS.txt` with the bindings in `01_STAGE_05_EVIDENCE_PACKAGE.v1.md`. They match where cross-referenced, but I did not recompute SHA256.

---

## 2. Result inventory (§12)

| Claim ID | Result ID | Claim | Verdict | Source |
| --- | --- | --- | --- | --- |
| C-01 | R-01 | Mode A backtest at d_1913: A1 = 0.1824, A2 = 0.2697, `backtest_accept = 0`, `n_usable 345`, U0 excluded 5. | **Qualify** | `model.json`; `audit.csv`; X1 contradicts `n_usable` and A2 if FOODS_3_092 is included. |
| C-02 | R-02 | d_1885 stability: A1 0.1722, A2 0.1794; reported only. | **Qualify** | Receipt-level only; no per-item rows in X1/X3. |
| C-03 | R-03 | Penalty 0.0021 (grid idx 14), glmnet α 0.5, thresh 1e-12, seed 20160522. | **Correct** | `model.json`; `audit.csv`. |
| C-04 | R-04 | Outcome: 2,484/2,484 `hold_ne`; package 0; below-line 0; legal changes 0; trust-eligible 338; TE6 usable slice 347. | **Verified** | X2, X3, `audit.csv`, `validated_data_manifest.md`. |
| C-05 | R-05 | R-A r2 and R-B r10 reconcile 75/75, mismatch 0. | **Verified** | `reconciliation.json`. |
| C-06 | R-06 | Source Gate r2 PASS 24/24. | **Verified** | `source.json`. |
| C-07 | R-07 | Fixtures 26/26 on both paths. | **Verified** | `fixtures.json`. |
| C-08 | R-08 | Cross-review: 14 findings; XR-01..03 resolved; XR-04..14 accepted limitations; unresolved 0. | **Verified** | `findings_register.csv`, `cross_review.md`. |
| C-09 | R-09 | Validation Gate approved 2026-10-02 14:35 CT. | **Verified** | `validation.json`. |
| C-10 | R-10 | `candidates.csv`: 3,654 rows; not decision-valid because collapse applies. | **Verified** | `reconciliation.json` row_counts; `audit.csv`. |

---

## 3. Independent checks of critical values

### 3.1 A1 / A2 / n_usable / U0 excluded from X1

**Source:** `X1_backtest_d1913_per_item_base_trust.csv`; `model.json`; `audit.csv`.

**My recomputation from X1:**

* Total `base_trust_at_o = 1` rows: **359**.
* Rows with `realized_units = 0` and `usable = 0`: **5**  
  `FOODS_3_271`, `FOODS_3_276`, `FOODS_3_319`, `FOODS_3_644`, `FOODS_3_767`.
* Rows with `stable_price = 0` and `usable = 0`: **8**  
  `FOODS_2_364`, `FOODS_3_227`, `FOODS_3_269`, `FOODS_3_535`, `FOODS_3_645`, `FOODS_3_782`, `HOUSEHOLD_1_449`, `HOUSEHOLD_1_497`.
* Therefore `usable = 1` rows in X1: **359 − 5 − 8 = 346**.

**Official values:** `n_usable = 345`, `n_U0_excluded = 5`.

**Discrepancy:** X1 yields **346** usable rows, while `model.json` and `audit.csv` report **345**. The one-row difference is `FOODS_3_092`:


```
FOODS_3_092,FOODS_3,1,1,1,1,65.6009,64.6009,64.6009
```

`FOODS_3_092` has `realized_units = 1`, `stable_price = 1`, `usable = 1`. If it is included, the mean signed error changes materially. Using the official sum implied by A2 = 0.2697 over 345 rows:

* Implied sum of signed errors = 0.2697 × 345 ≈ 93.0465.
* Add `FOODS_3_092` signed error = 64.6009 → sum ≈ 157.6474.
* Mean over 346 rows ≈ 157.6474 / 346 ≈ **0.4556**.

This is inconsistent with the official A2 = 0.2697. Therefore either X1’s `usable = 1` for `FOODS_3_092` is wrong, or the official summary excluded it without a documented rule in the supplied files.

**Verdicts:**

| Claim | Verdict | Reason |
| --- | --- | --- |
| C-01 A1 = 0.1824 | **Qualify** | Cannot fully confirm while `n_usable` is disputed. |
| C-01 A2 = 0.2697 | **Qualify** | X1 implies A2 ≈ 0.4556 if `FOODS_3_092` is included. |
| C-01 `n_usable = 345` | **Qualify** | X1 yields 346. |
| C-01 `n_U0_excluded = 5` | **Verified** | X1 confirms exactly 5 rows with `realized_units = 0`. |

**Finding F-03:** Material numerical discrepancy: X1 supports `n_usable = 346`, not 345. The difference is `FOODS_3_092`. This changes A2. Route: **Recompute in Stage 4**.  
**Finding F-04:** The sign convention is confirmed: `signed_error = (pred_units − realized_units) / realized_units`.  
Spot checks:

* `FOODS_1_004`: realized 95, pred 25.7276, signed_error −0.7292 (pred < realized → negative).
* `FOODS_1_012`: realized 78, pred 81.8831, signed_error +0.0498 (pred > realized → positive).
* `FOODS_1_013`: realized 25, pred 65.0243, signed_error +1.601 (pred > realized → positive).

### 3.2 Universe action counts from X2

**Source:** `X2_universe_decision_fields.csv`; `audit.csv`.

| Check | Result | Verdict |
| --- | --- | --- |
| Total rows | 2,484 | **Verified** |
| `action = hold_ne` | 2,484 | **Verified** |
| `package_flag = 1` | 0 | **Verified** |
| `below_line_flag = 1` | 0 | **Verified** |
| `legal_change = 1` | 0 | **Verified** |
| `backtest_accept = 1` | 0 | **Verified** |
| `trust_eligible = 1` | 338 | **Verified** (matches `audit.csv`) |
| `te6 = 1` | 347 | **Verified** from X3 row count (29 + 94 + 161 + 59 + 4 = 347) |
| `action_twin_11616` populated | 0 | **Verified** (blank for all rows) |

**Finding F-05:** X2 confirms the collapse outcome: all items `hold_ne`, no package, no below-line, no legal changes.

---

## 4. Population, grain and time-window verification

| Item | Claim | Verdict |
| --- | --- | --- |
| Universe | 2,484 CA_1 items in FOODS_1/2/3 and HOUSEHOLD_1/2 | **Verified** from X2 and `audit.csv`. |
| Grain | One row per item; one action per item | **Verified** from X2. |
| Backtest origin | d_1913 | **Correct** per `model.json`, X5 §16.1. |
| Live origin | d_1941 | **Correct** per `audit.csv`, X5 §17. |
| Horizon | d_1942–d_1969 (28 days) | **Correct** per X5 §16.1, `audit.csv`. |
| Leakage boundary | week 11618 | **Correct** per X5 §16.1; fixtures PASS. |

**Finding F-06:** Population, grain and time windows are consistent across the attached files.

---

## 5. Table, receipt and manifest consistency audit

| Check | Result | Verdict |
| --- | --- | --- |
| Stage 4 receipt hash | `9536fe98...` matches binding | **Verified** |
| `audit.csv` vs `model.json` | Both report A1 0.1824, A2 0.2697, `n_usable` 345, U0 5 | **Qualify** — both match each other but conflict with X1. |
| `reconciliation.json` | 75/75, mismatch 0, row_count 2,484 | **Verified** |
| `source.json` | 24/24 PASS | **Verified** |
| `fixtures.json` | 26/26 both paths | **Verified** |
| `findings_register.csv` | 14 findings; XR-01..03 resolved; unresolved 0 | **Verified** |
| `validation.json` | Validation Gate PASS, owner approval 14:35 CT | **Verified** |
| `validated_data_manifest.md` | 2,484 hold_ne, package 0, trust-eligible 338, TE6 347 | **Verified** except `n_usable` not restated there. |

**Finding F-07:** The consistency audit passes for all files except the `n_usable` / A2 discrepancy between X1 and the official summaries.

---

## 6. Model metric audit

| Check | Verdict | Source |
| --- | --- | --- |
| A1/A2 come from approved held-out backtest at d_1913 | **Correct** | X5 §16.1: origin d_1913, horizon d_1914–d_1941, P0_bt week 11613. |
| A1/A2 not from training data | **Correct** | X5 §16.1 states backtest model refit separately; live coefficients never reused. |
| A1/A2 values | **Qualify** | Official values conflict with X1 as above. |
| d_1885 stability | **Qualify** | Receipt-level only; no per-item rows in X1/X3. |

**Finding F-08:** The held-out backtest provenance is correct. The numerical values remain qualified pending resolution of the X1 discrepancy.

---

## 7. Decision-rule application audit

| Rule | Application | Verdict |
| --- | --- | --- |
| §17.R8 collapse | A2 fails → `backtest_accept = 0` → all trust-eligible items `hold_ne` | **Verified** from X2 and `audit.csv`. |
| Action map | All 2,484 items `hold_ne` | **Verified** |
| N_CAP 25 | Package 0 ≤ 25; no padding | **Verified** |
| Below-line | 0 | **Verified** |
| Legal changes | 0 | **Verified** |
| Twin action | Blank for all | **Verified** |

**Finding F-09:** The decision-rule application is internally consistent with the collapse rule.

---

## 8. Unsupported-claim list

| Claim in `01_…md` | Issue | Verdict |
| --- | --- | --- |
| R-01 `n_usable = 345` | X1 yields 346; `FOODS_3_092` marked usable=1. | **Qualify** |
| R-01 `A2 = 0.2697` | If `FOODS_3_092` is included, A2 ≈ 0.4556. | **Qualify** |
| R-02 d_1885 per-item stability | No per-item rows supplied. | **Qualify** |
| Hash verification of extracts | Cannot recompute SHA256. | **Qualify** |

**Finding F-10:** The above claims are not fully backed by the attached extracts without Stage 4 clarification.

---

## 9. Unvalidated-computation list

| Computation | Why needed | Route |
| --- | --- | --- |
| Resolve `n_usable` discrepancy: 345 vs 346 | Determines correct A1/A2. | **Recompute in Stage 4** |
| Recompute A2 with correct usable set | Official A2 depends on excluding `FOODS_3_092`. | **Recompute in Stage 4** |
| Confirm `FOODS_3_092` exclusion rule | Not stated in supplied design excerpt. | **Recompute in Stage 4** |
| Recompute A1 median with correct set | Median may shift slightly. | **Recompute in Stage 4** |
| Recompute d_1885 per-item metrics | R-02 is receipt-level only. | **Recompute in Stage 4** |

**Finding F-11:** No new decision result was computed in this audit. The listed items require Stage 4 recomputation.

---

## 10. Evidence-traceability verdict

**Verdict: QUALIFY**

Rationale:

* The Stage 4 process spine is well documented: Source Gate 24/24, fixtures 26/26, reconciliation 75/75, cross-review 14 findings with 0 unresolved, Validation Gate PASS.
* The collapse rule is correctly applied: A2 fails, `backtest_accept = 0`, all 2,484 items `hold_ne`, package 0.
* However, the attached mechanical extract `X1` contradicts the official `n_usable` and A2. X1 yields 346 usable rows; the official summary reports 345. The difference is `FOODS_3_092`. Including it changes A2 from 0.2697 to approximately 0.4556.
* This is a material numerical inconsistency. Until Stage 4 resolves it, the evidence traceability cannot be marked PASS.
* If Stage 4 confirms `FOODS_3_092` should be excluded and reissues the extract/summary consistently, the verdict may rise to PASS.

**Finding F-12:** Overall traceability is **QUALIFY** pending resolution of the `n_usable` / A2 discrepancy.

END 05_AI3_CLAIM_TO_EVIDENCE_AUDIT
