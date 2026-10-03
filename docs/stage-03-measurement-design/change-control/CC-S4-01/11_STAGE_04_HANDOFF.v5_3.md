# 11_STAGE_04_HANDOFF — PRICEPOINT-001 (builder-facing)

**CHANGE CONTROL CC-S4-01 (owner-approved 2026-10-02T11:43:00-05:00).** This is the amended Stage 4 builder handoff. Design of record is now `08_CONSOLIDATED_CANDIDATE_v5_3.md` (SHA-256 `d3af4b594a80c8e458d8c41c4829cf1a8e250e0bbdbaf491811c8c26cbdc9a46`), which is v5.2 (`2065773c3224dd6eb083ef6b8f57deb88786ee1742d7da5f66f7fdf825278957`) with one addition at the end of the §17A.2 paragraph (same line; no line numbers move): "Every glmnet fit (all CV folds and final fits, at every origin) uses convergence threshold thresh = 1e-12. No other model setting changes." Nothing else in this file changed except this notice; references below to v5.2 now mean v5.3. Lock receipt: `stage3_locked_design.json` v3 (receipt_revision 3).

**Framework deliverable:** §33 item 11. The framework name is `11_STAGE_04_EXECUTION_HANDOFF.md`; this file uses the name the owner requested.

**Status: DRAFT — PENDING OWNER LOCK.** No builder may start before:
1. the owner records OC-1…OC-5 and approves the lock, and
2. `stage3_locked_design.json` exists with `status = LOCKED`.

**Design of record:** `recon/08_CONSOLIDATED_CANDIDATE_v5_2.md` (SHA-256 `2065773c3224dd6eb083ef6b8f57deb88786ee1742d7da5f66f7fdf825278957`), = `deliverables/10_STAGE_03_MEASUREMENT_DESIGN.md`.
- Part B below is a verbatim extract of the builder-relevant sections, with source line ranges.
- If Part A and Part B ever differ, Part B / the design of record governs.

**Prepared:** 2026-09-25 (CT), coordinator.

# Part A — Builder rules (summary, with sources)

## A1. Inputs a builder receives (v5.2 §27.2)
- The locked design (this file + 10_).
- The frozen fixture pack `fixtures/fixture_pack_v1.md`, SHA-256 `1390575a2ee1a6488d0ef53e0cf93396ddbb299455a1b47571626a9d6ecf976f`. It becomes v2 only if OC-5 = Option B adds FX-TE6-APE before the freeze.
- The verified SQL package.
- Lineage values.
- `07_MEASUREMENT_RISK_REGISTER.md`.
- Owner decisions OC-1…OC-5 from the locked JSON. Builders never choose these values.

## A2. Stage 4 sequence (v5.2 §27.3)

SQL evidence delivery → SQL Source Gate → R-A implementation ‖ R-B implementation (independent) → fixture execution → reconciliation → Stage 5.

## A3. Extract spec (v5.2 §20; Part B)
- **Envelope:** CA_1 × five departments (OC-1 (a)). The deliveries:
  - SALES_LONG: 2,484 × 1,941 = 4,821,444 rows;
  - CALENDAR: 1,969 rows;
  - PRICES: 568,783 rows (558,847 at weeks ≤ 11617; 9,936 at weeks 11618–11621, delivered and quarantined).
- **SQL permitted:** envelope, unnest, casts, calendar attach, and the permitted joins of §20.2.
- **SQL prohibited:** all judged precomputes (§20.4).
- **Casts:** as in §20.3.
- **sql_extract_sha256:** the manifest hash rule in §20.5.

## A4. SQL Source Gate (v5.2 §21)

All 24 numeric items must pass; **any failure = Gate Fail**. No R judged code consumes the extract before the Source Gate passes.

## A5. Frozen-extract-only rule

R-A and R-B read **only** the single frozen, Source-Gate-verified extract, identified by `sql_extract_sha256` (§20.5, §24.4).
- Both paths receive the identical package.
- **R never connects to MySQL** (DIP, database paragraph). No staging objects are created in the database.

## A6. No database connectors in R

R code must not load or call `DBI`, `RMariaDB` or any other database driver (A5; DIP). Any such call is a handoff violation.

## A7. R 4.6.1 package preflight

Before any judged code runs, each path runs a preflight. It checks two things:
- The R version is 4.6.1 (DIP).
- The packages the design requires can be loaded:
  - `tidyverse` and `parsnip` (DIP project requirement);
  - `recipes` and `glmnet` (§17A.2–17A.3: parsnip `linear_reg(mode = "regression")`, engine glmnet, recipe steps).

A preflight failure halts the path. No engine or package substitution is allowed: it would change the locked Mode A contract (§17A.2). Record the R and package versions with the run's lineage record.

## A8. R-A / R-B contract (v5.2 §22)
- Required outputs:
  - universe table (§22.1);
  - candidate table (§22.2);
  - audit output table (§22.4);
  - lineage (§24.4).
- Independence (§22.3): no shared judged code, recipe/workflow/fit/tuning objects, selected penalty, scored tables, candidate or eligibility lists, selected set or action table.
- Shared as specification only: locked design, fixture pack, verified SQL package, lineage, output schema, fold cuts and penalty grid.
- Each path attests to every M2 line (§24.5).

## A9. Fixtures (v5.2 §24; `fixtures/fixture_pack_v1.md`)

Each path must pass all 26 active fixtures. A fixture's "Build fails if" condition = build FAIL.
- Fixtures are frozen by path + SHA-256 before R-A/R-B start.
- They are never rewritten after a Fail.

Fixture IDs: FX-HOLD-NE-PRICES, FX-GUARD-10, FX-CUT-OK, FX-ARGMAX, FX-NOPAD, FX-CAP25, FX-MEMBER, FX-LEAK-11618, FX-CURRENT-11617, FX-HORIZON-28, FX-TIE, FX-ELIG-BOUNDARY, FX-PW52, FX-BAND25, FX-NOCAND, FX-EVENT-SINGLE, FX-CAP5-TIE, FX-UP0-ZERO, FX-CENT-ROUND, FX-MINGAIN-DIAG, FX-BACKTEST-COLLAPSE, FX-TRAIL-ANCHOR, FX-WDAY-SNAP, FX-WEEK-ORDINAL, FX-INTERACT, FX-TE6-SLICE.

## A10. Reconciliation tolerances (v5.2 §23)

- **Exact equality:**
  - keys; row counts;
  - eligibility integers (n_price_changes_pre, n_distinct_prices_pre, priced_weeks_pre, units_365, zero_days_365); conjunct flags; te6; te6_usable_slice; trust_eligible;
  - current and candidate prices; candidate-table keys item_id × candidate_price; n_candidates; straddle_flag;
  - backtest_accept; all §22.4 audit counts and flags;
  - guardrail_pass; legal_change; cent_delta_rev;
  - actions; package_flag; below_line_flag; rank_among_qualifiers;
  - lineage.
- **|Δ| ≤ 0.05 units:** .pred_units_current, .pred_units_candidate.
- **|Δ| ≤ $0.05:** .pred_rev_current, .pred_rev_candidate, delta_rev.
- **Diagnostic triggers only (not a FAIL by themselves):** penalty_grid_index, gain_below_half_mae, backtest_A1_median_ape, backtest_A2_mean_signed_error, dept_backtest_MAE_revenue, te6_ape_i, te6_dept_median_ape.
- **FAIL conditions:**
  - any action, package, below-line or rank mismatch;
  - a cent_delta_rev sign mismatch. Repair toward base R round(x, 2) on each side.
- Tolerance never reconciles a discrete field. Repair toward the spec, never average.
- The outcome is PASS or FAIL only.

## A11. Owner-dependent values (to be filled from the locked JSON)

| OC | Item | Options | Coordinator recommendation | Design values that depend on it |
|---|---|---|---|---|
| OC-1 | Department scope | (a) FOODS_1/2/3 + HOUSEHOLD_1/2 (2,484 items); (b) add HOBBIES; (c) FOODS_3 + HOUSEHOLD_1 only | (a) | universe (§7.1, §17.R1), n_universe (§22.4), department rows (§13.2) |
| OC-2 | Eligibility tightness | E_A = 363; E_A ∧ nd ≥ 4 = 274; E_C = 177; E_B = 784 | E_A (363) | E_A (§7.3, §17.R2), trust-eligible set |
| OC-3 | "about 10%" | ρ̂ ≥ 0.90 hard (0.85 / 0.95 twins) | 0.90 hard | guardrail / legal test (§11.1, §17.R7) |
| OC-4 | "about 25" | N_CAP = 25 hard; 25 ± tolerance | 25 hard | package / below-line (§17.R9) |
| OC-5 | TE6 rule | Option A slice-only; Option B1 / B2 | Option A | te6, trust_eligible (§7.7, §17.R5); FX-TE6-APE only if Option B |

# Part B — Verbatim extract of the design of record

<!-- BEGIN VERBATIM v5.2 lines 247–368: §7 Population and eligibility contract -->
# 7. Population and eligibility contract

## 7.1 Analytical universe

**Status: Locked-proposed**
**Origin: [MC] 06#5; 06 Appendix A step 1**

The analytical universe is all 2,484 CA_1 items in the five departments FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1 and HOUSEHOLD_2 (U1–U4 of Design B). The five-department scope is subject to OC-1 (§26.2); X2 applies the owner-selected department set.

Every universe item gets exactly one row and one action. No item leaves the universe for being new: first-listing age is the trust conjunct priced_weeks ≥ 52 (§7.3), and its failure gives hold_ne. Non-qualifying items receive a visible outcome rather than being removed (T020).

---

## 7.2 Universe audit exclusions X1–X6

**Status: Locked-proposed**
**Origin: [DF] 06#5**

The universe audit records:

| ID | Audit field     | Rule                                                                                          |
| -- | --------------- | --------------------------------------------------------------------------------------------- |
| X1 | n_dropped_by_X1 | Non-CA_1 items                                                                                |
| X2 | n_dropped_by_X2 | Outside approved grocery/household departments                                                |
| X3 | n_dropped_by_X3 | No current-price week row                                                                     |
| X4 | n_dropped_by_X4 | U5 first-listing age rule replaced by priced_weeks trust requirement; failure becomes hold_ne |
| X5 | n_dropped_by_X5 | Invalid JSON series length ≠ 1,941                                                            |
| X6 | n_dropped_by_X6 | Negative units or non-numeric price                                                           |

---

## 7.3 Eligibility rule E_A and trust conjuncts

**Status: Locked-proposed**
**Origin: [MC] 06#6; 06#7; 06 Appendix A step 2; AI1-DT-03**

Which eligibility rule is judged is OC-2 (§7.5); the definitions below are fixed.

Eligibility integers are computed from prices at weeks ≤ 11617 and sales d_1577–d_1941 (06 Appendix A step 2):

* n_price_changes_pre = number of week-to-week sell_price changes over the item's price rows at weeks ≤ 11617 (lifetime), computed exactly as profiled (P04);
* n_distinct_prices_pre = number of distinct sell_price values at weeks ≤ 11617;
* priced_weeks_pre = count of price rows at weeks ≤ 11617 (contiguous rows verified, so it equals weeks since first listing + 1);
* units_365 = sum of daily units over d_1577–d_1941;
* zero_days_365 = number of days in d_1577–d_1941 with units = 0.

E_A = (n_price_changes_pre ≥ 3) ∧ (units_365 ≥ 180) ∧ (zero_days_365 ≤ 182). Separately, e_pw52 = (priced_weeks_pre ≥ 52) and e_cand = (n_candidates ≥ 1). trust_eligible additionally requires e_pw52, e_cand and te6. Failure of e_pw52 or e_cand → hold_ne.

Conjunct flags: e_chg3 = (n_price_changes_pre ≥ 3); e_u180 = (units_365 ≥ 180); e_z182 = (zero_days_365 ≤ 182); e_pw52; e_cand (candidate construction §17.R4); te6 (§7.7); trust_eligible (§17.R5).

Leading-zero rule (06#7): eligibility metrics are computed on the raw 365-day window exactly as profiled (no listing-start adjustment; the P04 counts are the reproducible reference); training rows start at the first priced day (no price → no training row); first positive sale d is an audit field (first_positive_d).

Recent-change evidence (06 §A DC-2): the true last-104-calendar-week count of items with ≥ 3 price changes is 232 (32/96/61/24/19); the Profile 02 figure of 30 measured the last 57 weeks. The lifetime rule n_price_changes ≥ 3 is kept on T010 ("at least a few times in the history"), not because a recent-change rule would empty the review.

---

## 7.4 Eligibility counts

**Status: Verified**
**Origin: [PA] P04; [MC] 06#6; 06 §C OC-2**

| Rule                                                                   |                                          Items |
| ---------------------------------------------------------------------- | ---------------------------------------------: |
| E_A (three conjuncts)                                                  |                                            364 |
| E_A + priced_weeks ≥ 52 + candidate-exists (trust-eligible before TE6) |                                            363 |
| of which FOODS_1 / FOODS_2 / FOODS_3 / HOUSEHOLD_1 / HOUSEHOLD_2       |                         29 / 99 / 172 / 60 / 3 |
| E_A ∧ nd ≥ 4                                                           | 274 before candidate-exists (273 or 274 after) |
| E_C                                                                    |                                            177 |
| E_B                                                                    |                                            784 |

positive_weeks_52 ≥ 26 and priced_weeks ≥ 52 do not bind for E_A.

---

## 7.5 OC-2 eligibility tightness

**Status: Owner choice pending**
**Origin: [OC] 06 §C OC-2; 06#6**

| # | Item | Alternatives (profiled) | Coordinator recommendation |
|---|---|---|---|
| OC-2 | Eligibility tightness (row 6; DC-3) | E_A + priced_weeks ≥ 52 + candidate-exists = 363 (29/99/172/60/3); E_A ∧ nd ≥ 4 = 274 before candidate-exists (273 or 274 after); E_C = 177; E_B = 784 | E_A (363). Owner confirms that 363 is acceptable against the owner-side ~200–300 preference, or picks E_A ∧ nd ≥ 4 |

Sensitivity twins: T7 E_A ∧ nd ≥ 4; T8 E_C (06#29).

---

## 7.6 DC-3 size clarification

**Status: Locked-proposed**
**Origin: [MC] 06 DC-3**

The ~200–300 figure is not a stakeholder statement.

It is an owner-side project-data preference requiring owner confirmation, not a T000–T040 requirement.

---

## 7.7 TE6 — "the expectation for the next four weeks isn't a guess" (OC-5)

**Status: Owner choice pending**
**Origin: [OC] 06#8; 06 §F; 09 §4**

Source: T040 ("The product's price has actually moved before, it sells enough to see what happened, and the expectation for the next four weeks isn't a guess."). The final audits did not converge on an item-level rule, so it is owner choice OC-5 at lock (06 §F bullet 2). OC-5 must be decided at lock before R builders run (framework §17A; 07 RR-12).

**Common text (Status: Locked-proposed under every OC-5 option; Origin: [MC] 06#8; 06#28):**

te6_usable_slice = 1 iff all of: (1) E_A holds when re-anchored at o = d_1913, i.e. n_price_changes (weeks ≤ 11613) ≥ 3 AND units_365 over d_1549–d_1913 ≥ 180 AND zero_days_365 over d_1549–d_1913 ≤ 182; (2) the item has the same sell_price in each of weeks 11613, 11614, 11615, 11616 and 11617; (3) realized units summed over d_1914–d_1941 > 0. Items with te6_usable_slice = 0 have te6 = 0 and fail trust → hold_ne.

APE_i = abs(Û_i(P0_bt) − U_i)/U_i, where Û_i(P0_bt) is the d_1913 backtest model's 28-day prediction at P0_bt (the week-11613 price) and U_i is realized units d_1914–d_1941. It is emitted as te6_ape_i for every item with te6_usable_slice = 1 (NA otherwise), with a per-dept median te6_dept_median_ape.

te6 is computed before §17.R8; the backtest collapse (backtest_accept = 0) overrides actions but does not change te6. d_1885 does not enter TE6. Fixture: FX-TE6-SLICE.

**OC-5 options (owner selects one at lock):**

* Option A (slice-only): te6 = te6_usable_slice. te6_ape_i and te6_dept_median_ape are reported only; there is no item-level APE threshold.
* Option B (06#8 as written): te6 = 1 iff te6_usable_slice = 1 AND (te6_ape_i ≤ 0.50 OR te6_ape_i ≤ te6_dept_median_ape). Variant B1: 06#8 verbatim. Variant B2: the dept-median limb applies only when the dept has ≥ 5 usable-slice items (otherwise only the 0.50 limb applies), and te6_rule_fired ∈ {absolute, dept_median, both, neither} is emitted. 0.50 is a coordinator proposal with no evidence behind it (06#8); provisional policy. If Option B is chosen, fixture FX-TE6-APE is added before the fixture freeze (09 §4).

**Coordinator recommendation: Option A.** It is the only option with no unevidenced item-level number. Model-level accuracy is enforced by the A1/A2 collapse (06#28). te6 is then computable from data alone and reconciles exactly.

---

<!-- END VERBATIM v5.2 lines 247–368 -->

<!-- BEGIN VERBATIM v5.2 lines 369–424: §8 Time-window and date contract -->
# 8. Time-window and date contract

## 8.1 Decision origin

**Status: Locked-proposed**
**Origin: [MC] 06#10**

The decision origin is the end of d_1941 = 2016-05-22 (Sunday). Current price P0 = week-11617 price (§17.R3).

---

## 8.2 Forecast horizon

**Status: Locked-proposed**
**Origin: [MC] 06#10; 06#26**

The horizon is d_1942–d_1969 inclusive = 28 days (2016-05-23 through 2016-06-19), daily grain. The price is held constant at P0 or at the candidate Pc across the 28 horizon days. Week 11621 has only 2 days, so a weekly grain would be inexact; n_horizon_days_scored = 28 (FX-HORIZON-28).

---

## 8.3 Leakage boundary

**Status: Locked-proposed**
**Origin: [MC] 06#10; 06#24; 06#30**

Sales at d ≥ d_1942 and prices at wm_yr_wk ≥ 11618 are forbidden in features, candidates and the current price. Post-origin price rows are delivered, identifiable by week, and quarantined (§20.1). Calendar fields (event_type_1, event names, snap_CA, wday, month) are allowed forward on horizon rows because they are scheduled. Fixture: FX-LEAK-11618.

---

## 8.4 Backtest origins

**Status: Locked-proposed**
**Origin: [MC] 06#28**

Primary backtest origin o = d_1913: horizon d_1914–d_1941; P0_bt = price of week 11613. Stability origin d_1885: horizon d_1886–d_1913; P0 = price of week 11609; reported for stability only (§16).

---

## 8.5 Week-ordinal rule

**Status: Locked-proposed**
**Origin: [MC] 06 DC-1; 06#39**

wm_yr_wk is not a contiguous integer: weeks run 11101…11152, 11201…11252, 11301…11353, 11401…11452, 11501…11552, 11601…11621. Every week window is defined by calendar week ordinal (distinct wm_yr_wk sorted), never by integer subtraction on wm_yr_wk. The last 52 calendar weeks ending at 11617 are 11518–11552 and 11601–11617. Fixture: FX-WEEK-ORDINAL.

---

## 8.6 Calendar coding and SNAP

**Status: Locked-proposed**
**Origin: [MC] 06#10; 06 §F**

wday is used as stored, Sat = 1 … Fri = 7 (2016-05-21 has wday = 1); no ISO recode. Only snap_CA is used; snap_TX and snap_WI are never used. SNAP enters the model only as same-day snap_CA plus the single interaction (scaled log_sell_price) × snap_CA; n_snap_next_28_known is dropped (06 §F). Fixture: FX-WDAY-SNAP.

---

<!-- END VERBATIM v5.2 lines 369–424 -->

<!-- BEGIN VERBATIM v5.2 lines 425–476: §9 Grain and join-cardinality contract -->
# 9. Grain and join-cardinality contract

## 9.1 Analytical grain

**Status: Locked-proposed**
**Origin: [MC] 06#11**

The recommendation grain:

`item-store`

---

## 9.2 Source grain table

| Source   | Grain           | Status                  | Origin             |
| -------- | --------------- | ----------------------- | ------------------ |
| Sales    | item-store-day  | Status: Locked-proposed | Origin: [MC] 06#11 |
| Price    | item-store-week | Status: Locked-proposed | Origin: [MC] 06#11 |
| Calendar | day             | Status: Locked-proposed | Origin: [MC] 06#11 |

---

## 9.3 Transition map

**Status: Locked-proposed**
**Origin: [MC] 06#11; 06#32**

item-store-day source rows (week price mapped via wm_yr_wk) → item × candidate scoring rows (item_id × candidate_price, each scored over the 28 horizon days) → one item-store action row (argmax, §17.R7). The candidate table grain is item_id × candidate_price (§22.2).

---

## 9.4 Join rules

**Status: Verified**
**Origin: [PA] P01 Q1; [MC] 06#11; 06#30**

* Many item-days per priced week; ≤ 1 price row per item-day.
* Prices reach item-days only through wm_yr_wk attached to SALES_LONG from CALENDAR on d.
* No direct CALENDAR × PRICES join on wm_yr_wk, and no SALES_LONG × PRICES join without wm_yr_wk.

---

## 9.5 Forbidden repair behavior

**Status: Locked-proposed**
**Origin: [MC] 06#11**

DISTINCT cannot be used as a repair for join duplication.

---

<!-- END VERBATIM v5.2 lines 425–476 -->

<!-- BEGIN VERBATIM v5.2 lines 477–543: §10 Primary KPI contract -->
# 10. Primary KPI contract

## 10.1 Predicted units

**Status: Locked-proposed**
**Origin: [MC] 06#12**

For price P:

$$
\hat U(P)=\sum_{d_{1942}}^{d_{1969}}\max(0,\hat u_t(P))
$$

---

## 10.2 Predicted revenue

**Status: Locked-proposed**
**Origin: [MC] 06#12**

$$
\hat R(P)=\hat U(P)\times P
$$

---

## 10.3 Revenue delta

**Status: Locked-proposed**
**Origin: [MC] 06#12**

$$
\Delta \hat R=\hat R(P_c)-\hat R(P_0)
$$

---

## 10.4 Unit ratio

**Status: Locked-proposed**
**Origin: [MC] 06#13**

$$
\hat\rho=\frac{\hat U(P_c)}{\hat U(P_0)}
$$

---

## 10.5 Zero baseline handling

**Status: Locked-proposed**
**Origin: [MC] 06#12**

If:

$$
\hat U(P_0)=0
$$

then:

Action:

`hold_ne`

---

<!-- END VERBATIM v5.2 lines 477–543 -->

<!-- BEGIN VERBATIM v5.2 lines 544–610: §11 Guardrail, diagnostic, audit and sensitivity metrics -->
# 11. Guardrail, diagnostic, audit and sensitivity metrics

## 11.1 Unit guardrail

**Status: Owner choice pending**
**Origin: [OC] 06#13 OC-3**

Recommendation:

$$
\hat{\rho}<0.90
$$

is rejected.

Sensitivity twins:

* T2: 0.85.
* T3: 0.95.

---

## 11.2 Sensitivity twins

**Status: Locked-proposed**
**Origin: [MC] 06#29**

| Twin | Rule                                                                     |
| ---- | ------------------------------------------------------------------------ |
| T1   | Current price = week 11616; includes straddle_flag and action_twin_11616 |
| T2   | Unit guardrail = 0.85                                                    |
| T3   | Unit guardrail = 0.95                                                    |
| T4   | Candidate band ±20%                                                      |
| T5   | No SNAP features                                                         |
| T6   | Calendar-only model                                                      |
| T7   | E_A ∧ nd ≥ 4                                                             |
| T8   | E_C                                                                      |
| T9   | gain_below_half_mae listing                                              |

Each twin reports package-membership overlap with the judged package. None changes a judged action. T1: 5 of 2,484 items differ between weeks 11616 and 11617 (P03).

---

## 11.3 Minimum-gain rule

**Status: Locked-proposed**
**Origin: [MC] 06#18; AI3-M-09; 09 RES-12**

No minimum-gain rule in the judged rule (T040). gain_below_half_mae is a diagnostic flag that never changes action or rank (twin T9 lists it).

dept_backtest_MAE_revenue = mean, over d_1913-backtest trust-eligible items with constant actual price in weeks 11613–11617, of abs(R̂(P0_bt) − realized revenue d_1914–d_1941), by dept.

gain_below_half_mae = 1 when the chosen ΔR̂ is not > 0.5 × dept_backtest_MAE_revenue of the item's dept, and 0 otherwise. It is NA for items with no chosen legal candidate (action ∉ {raise, cut}). If a department has no qualifying d_1913 item, dept_backtest_MAE_revenue is undefined and gain_below_half_mae = NA (not 0).

Reconciliation: diagnostic; an R-A/R-B mismatch is a diagnostic trigger, not a FAIL (§23). Fixture: FX-MINGAIN-DIAG.

---

## 11.4 Audit metrics

**Status: Locked-proposed**
**Origin: [MC] 06#22, 06#24, 06#27, 06#28; Design B §7.7**

The required audit metrics are listed in full in §22.4 (audit output table). They include n_dropped_by_X1…X6, n_candidates_event_filtered, n_price_0_01_weeks, n_feature_na_rows, backtest acceptance counts and statistics, and dept_backtest_MAE_revenue.

---

<!-- END VERBATIM v5.2 lines 544–610 -->

<!-- BEGIN VERBATIM v5.2 lines 777–873: §15 Missingness, anomaly and data-quality rules -->
# 15. Missingness, anomaly and data-quality rules

## 15.1 Training target treatment

**Status: Locked-proposed**
**Origin: [MC] 06#22**

The training target is winsorized:

* at the item's p99;
* using positive training days only;
* R quantile type 7.

---

## 15.2 $0.01 prices

**Status: Locked-proposed**
**Origin: [MC] 06#22**

Prices equal to:

$$
\$0.01
$$

are retained.

Required flag:

`n_price_0_01_weeks`

---

## 15.3 Invalid prices

**Status: Locked-proposed**
**Origin: [MC] 06#22**

Rule:

$$
price \leq 0
$$

causes:

* week exclusion.

If current week is invalid:

$$
hold\_ne
$$

---

## 15.4 Missing historical prices

**Status: Locked-proposed**
**Origin: [MC] 06#22**

No LOCF.

Historical gaps are not filled forward.

---

## 15.5 Sales leakage rule

**Status: Locked-proposed**
**Origin: [MC] 06#22**

Forbidden:

Any sales observation:

$$
d > 1941
$$

---

## 15.6 Data-quality audits

Required:

| Audit                | Status                  | Origin               |
| -------------------- | ----------------------- | -------------------- |
| Price-key uniqueness | Status: Locked-proposed | Origin: [DF] P01 Q1  |
| Series length        | Status: Locked-proposed | Origin: [DF] P01 Q2  |
| Calendar coverage    | Status: Locked-proposed | Origin: [DF] P01 Q3  |
| Price gaps           | Status: Locked-proposed | Origin: [DF] P01 Q8  |
| Horizon calendar     | Status: Locked-proposed | Origin: [DF] P01 Q10 |

---

<!-- END VERBATIM v5.2 lines 777–873 -->

<!-- BEGIN VERBATIM v5.2 lines 874–938: §16 Sample-size and uncertainty rules (backtest) -->
# 16. Sample-size and uncertainty rules

## 16.1 Backtest purpose and origin

**Status: Locked-proposed**
**Origin: [MC] 06#28**

The backtest determines whether the predictive system is calibrated well enough for recommendations to be trusted.

* Primary origin o = d_1913; horizon d_1914–d_1941; P0_bt = price of week 11613.
* The backtest model is refit separately on training rows with d ≤ 1913, using the same recipe, the fold rule of §17A.7 for D = 1913, and the same grid and selection rule. Live coefficients are never reused.
* Candidates and eligibility are re-anchored at o: units_365 and zero_days_365 over d_1549–d_1913; price changes, priced weeks and prices at weeks ≤ 11613.

---

## 16.2 Acceptance set

**Status: Locked-proposed**
**Origin: [MC] 06#28**

Acceptance set = trust-eligible-at-o items whose price is the same in weeks 11613–11617 and whose realized 28-day units (d_1914–d_1941) > 0. Items with U = 0 are excluded from A1/A2 and counted (backtest_n_U0_excluded). Û = the backtest model's 28-day prediction at P0_bt; U = realized units d_1914–d_1941.

---

## 16.3 Acceptance tests

**Status: Locked-proposed**
**Origin: [MC] 06#28**

* A1: median over the set of abs(Û − U)/U ≤ 0.40.
* A2: mean over the set of (Û − U)/U within [−0.20, +0.20].
* A3: Spearman(ΔR̂, realized revenue change) of the price+calendar model ≥ that of the calendar-only ablation (T6) on items whose price changed in the window; reported, not binding.
* A4: a backtest package of 0–25 is valid.

The caps are disclosed before execution (framework §32). They are provisional policy, not industry constants.

---

## 16.4 Backtest collapse rule

**Status: Locked-proposed**
**Origin: [MC] 06#28; 06 Appendix A step 8**

If A1 or A2 fails at d_1913, then backtest_accept = 0 and every trust-eligible item's action becomes hold_ne. This applies to modeled raise/cut and model-based unchanged alike (Design B §16.3: "prefer hold NE over confident unchanged"). The list is still produced. Clause §17.R8; fixture FX-BACKTEST-COLLAPSE.

---

## 16.5 Stability origin

**Status: Locked-proposed**
**Origin: [MC] 06#28**

d_1885 (horizon d_1886–d_1913, P0 = week 11609): same metrics, reported for stability only. It never changes backtest_accept.

---

## 16.6 No minimum-gain rule

**Status: Locked-proposed**
**Origin: [MC] 06#18**

No minimum-gain threshold is applied. Small gains rank lower but remain eligible if all rules pass (§11.3).

---

<!-- END VERBATIM v5.2 lines 874–938 -->

<!-- BEGIN VERBATIM v5.2 lines 939–1033: §17 Decision rules and capacity constraints -->
# 17. Decision rules and capacity constraints

**Status: Locked-proposed**
**Origin: [MC] 06 Appendix A (per universe item, live origin d_1941)**

## 17.R1 — Universe

**Origin: [MC] 06 Appendix A step 1; 06#5**

> 1. Universe: CA_1 × five depts (2,484 items). Every item gets exactly one row and one action.

The five-department set is subject to OC-1 (§26.2).

## 17.R2 — Eligibility integers

**Origin: [MC] 06 Appendix A step 2; 06#6; 06#7**

> 2. Eligibility integers from prices at weeks ≤ 11617 and sales d_1577–d_1941: n_price_changes_pre, n_distinct_prices_pre, priced_weeks_pre, units_365, zero_days_365.

Precision (06 rows): definitions, flags and the leading-zero rule are in §7.3. Week windows use calendar week ordinals (§8.5).

## 17.R3 — Current price

**Origin: [MC] 06 Appendix A step 3; 06#9**

> 3. Current price P0 = week-11617 price; P0_twin = week-11616 price; straddle_flag.

Precision (06 rows): straddle_flag = 1 where the week-11616 price differs from the week-11617 price (5 items, P03). current_price_11616 and action_twin_11616 are output fields (twin T1). The twin never changes a judged action.

## 17.R4 — Candidate set

**Origin: [MC] 06 Appendix A step 4; 06#14; 06#15; 06#16**

> 4. Candidate set: distinct own prices at weeks ≤ 11617, > 0, ≠ P0, within [0.75·P0, 1.25·P0] (integer-cent comparison), minus single-week event-week prices (four types), ordered by round(abs(ln(Pc/P0)), 10) then price ascending, first 5 kept.

Precision (06 rows):
* Integer-cent comparison: 100·Pc ≥ 75·P0 and 100·Pc ≤ 125·P0.
* Event filter: drop a price level observed in exactly one week ≤ 11617 when that week contains ≥ 1 day with event_type_1 ∈ {National, Religious, Sporting, Cultural}; event_type_2 is not used. Audit count n_candidates_event_filtered.
* Ordering ties at equal rounded distance → lower price first.
* No band expansion: an item with no in-band candidate has n_candidates = 0 → e_cand = 0 → hold_ne. band_expanded is dropped.
* Disclosure: single-week prices are under-represented in event weeks (40.22% vs 47.23% baseline), so the filter is a low-impact precaution.

## 17.R5 — Trust

**Origin: [MC] 06 Appendix A step 5; 06#6; 06#7; 06#8**

> 5. trust_eligible = e_chg3 ∧ e_u180 ∧ e_z182 ∧ e_pw52 ∧ e_cand ∧ te6 [te6 per OD-1]. Not trusted → hold_ne.

OD-1 is now owner choice OC-5: te6 follows the OC-5 option selected at lock (§7.7). te6 is computed before §17.R8.

## 17.R6 — Fit and score

**Origin: [MC] 06 Appendix A step 6; 06#12; 06#13; 06#26**

> 6. Fit the locked model (row 23–27); score P0 and each candidate over d_1942–d_1969; Û, R̂, ΔR̂, ρ̂.

Precision (06 rows):
* Û(P) = Σ over d_1942–d_1969 of max(0, û_t(P)).
* R̂(P) = Û(P) × P.
* ΔR̂(Pc) = R̂(Pc) − R̂(P0).
* ρ̂ = Û(Pc)/Û(P0).
* pred_units_current = Û(P0).
* Unrounded values are used for ranking; rounding is for display only.
* Model specification: §17A.

## 17.R7 — Legal change and action

**Origin: [MC] 06 Appendix A step 7; 06#13; 06#17**

> 7. Û(P0) = 0 → hold_ne. Legal candidate: ρ̂ ≥ 0.90 AND round(R̂(Pc),2) − round(R̂(P0),2) > 0. None legal → unchanged at P0. Else argmax ΔR̂ (unrounded) → raise if Pc > P0, cut if Pc < P0.

Precision (06 rows):
* ρ̂ is compared unrounded.
* Cent rounding uses R base round(x, 2) on R̂(Pc) and on R̂(P0) separately; cent_delta_rev = round(R̂(Pc), 2) − round(R̂(P0), 2) is an exact reconciliation field (§23).
* action ∈ {raise, cut, unchanged, hold_ne}; exactly one per universe item.
* The 0.90 cut is OC-3.

## 17.R8 — Backtest collapse

**Origin: [MC] 06 Appendix A step 8; 06#28**

> 8. If backtest_accept = 0 (A1 or A2 fails at d_1913): all trust-eligible items → hold_ne.

Precision (06 rows): this covers modeled raise/cut and model-based unchanged alike, and the list is still produced (§16.4).

## 17.R9 — Ranking and capacity

**Origin: [MC] 06 Appendix A step 9; 06#19**

> 9. Qualifiers (raise/cut) ranked by ΔR̂ desc, then pred_units_current desc, then n_price_changes_pre desc, then item_id asc; package_flag for ranks 1…min(25, n); below_line_flag for ranks > 25; no padding; holds and unchanged listed separately and do not consume slots.

Precision (06 rows): 25 = N_CAP (OC-4); membership-first.

---

<!-- END VERBATIM v5.2 lines 939–1033 -->

<!-- BEGIN VERBATIM v5.2 lines 1034–1057: M4 Decision-rule pipeline -->
# M4 Decision-rule pipeline

**Status: Locked-proposed**
**Origin: [MC] 06 Appendix A; 06#37**

| M4 ID | §17 clause | Testable rule | Output field(s) | Fixture(s) |
| ----- | ---------- | ------------- | --------------- | ---------- |
| M4-001 | §17.R1 | Every universe item (2,484 under OC-1 (a)) gets exactly one row and one action; no item is dropped | in_universe; action | FX-MEMBER |
| M4-002 | §17.R2 | Eligibility integers from prices at weeks ≤ 11617 and sales d_1577–d_1941; E_A = (n_price_changes_pre ≥ 3) ∧ (units_365 ≥ 180) ∧ (zero_days_365 ≤ 182); e_pw52 = (priced_weeks_pre ≥ 52) | n_price_changes_pre, n_distinct_prices_pre, priced_weeks_pre, units_365, zero_days_365; e_chg3, e_u180, e_z182, e_pw52 | FX-ELIG-BOUNDARY, FX-PW52, FX-WEEK-ORDINAL |
| M4-003 | §17.R3 | P0 = week-11617 price; P0_twin = week-11616 price; straddle_flag = 1 where they differ | current_price, current_price_11616, straddle_flag, action_twin_11616 | FX-CURRENT-11617 |
| M4-004 | §17.R4 | Candidates = distinct own prices at weeks ≤ 11617, > 0, ≠ P0, with 100·Pc ≥ 75·P0 and 100·Pc ≤ 125·P0; no band expansion | candidate table keys | FX-BAND25, FX-LEAK-11618 |
| M4-005 | §17.R4 | Drop single-week event-week prices (event_type_1 ∈ {National, Religious, Sporting, Cultural}) | n_candidates_event_filtered | FX-EVENT-SINGLE |
| M4-006 | §17.R4 | Order by round(abs(ln(Pc/P0)), 10) ascending, then price ascending; keep first 5; e_cand = (n_candidates ≥ 1) | abs_log_dist, rank_in_cap, n_candidates, e_cand | FX-CAP5-TIE, FX-NOCAND |
| M4-007 | §17.R5 | trust_eligible = e_chg3 ∧ e_u180 ∧ e_z182 ∧ e_pw52 ∧ e_cand ∧ te6 (te6 per OC-5, §7.7); Not trusted → hold_ne | te6_usable_slice, te6, trust_eligible, action | FX-HOLD-NE-PRICES, FX-PW52, FX-NOCAND, FX-TE6-SLICE, FX-MEMBER |
| M4-008 | §17.R6 | Score P0 and each candidate over d_1942–d_1969 (28 days); Û, R̂, ΔR̂, ρ̂ unrounded | .pred_units_current, .pred_units_candidate, .pred_rev_current, .pred_rev_candidate, delta_rev, unit_ratio, n_horizon_days_scored, n_floored_days | FX-HORIZON-28, FX-TRAIL-ANCHOR, FX-WDAY-SNAP, FX-INTERACT |
| M4-009 | §17.R7 | Û(P0) = 0 → hold_ne (no unit ratio computed) | action | FX-UP0-ZERO |
| M4-010 | §17.R7 | Legal candidate: ρ̂ ≥ 0.90 AND round(R̂(Pc),2) − round(R̂(P0),2) > 0 | guardrail_pass, cent_delta_rev, legal_change | FX-GUARD-10, FX-CENT-ROUND, FX-CUT-OK |
| M4-011 | §17.R7 | None legal → unchanged at P0 (candidate_price = current_price) | action, candidate_price | FX-CENT-ROUND |
| M4-012 | §17.R7 | Else argmax ΔR̂ (unrounded) → raise if Pc > P0, cut if Pc < P0 | action, candidate_price | FX-ARGMAX, FX-CUT-OK, FX-MINGAIN-DIAG |
| M4-013 | §17.R8 | backtest_accept = 0 (A1 or A2 fails at d_1913) → all trust-eligible items → hold_ne, including model-based unchanged | backtest_accept, action | FX-BACKTEST-COLLAPSE |
| M4-014 | §17.R9 | Qualifiers (raise/cut) ranked by ΔR̂ desc, then pred_units_current desc, then n_price_changes_pre desc, then item_id asc | rank_among_qualifiers | FX-TIE, FX-ARGMAX |
| M4-015 | §17.R9 | package_flag for ranks 1…min(25, n); below_line_flag for ranks > 25; no padding; holds and unchanged listed separately and do not consume slots | package_flag, below_line_flag | FX-NOPAD, FX-CAP25, FX-MEMBER |
| M4-016 | §17.R1, §17.R7 | Action vocabulary is exactly {raise, cut, unchanged, hold_ne}; one action per item | action | FX-MEMBER |
| M4-017 | — | Excluded alternatives: band-expansion fallback (dropped, 06#14); half-MAE minimum-gain screen (removed from the judged rule, 06#18); split-window persistence and dual-clock twin override (not used; framework §20 gate classes marked N/A in §24.5) | — | — |
<!-- END VERBATIM v5.2 lines 1034–1057 -->

<!-- BEGIN VERBATIM v5.2 lines 1058–1191: §17A Predictive analytics / ML mode -->
# 17A. Predictive analytics / ML mode

## 17A.1 ML mode

**Status: Locked-proposed**
**Origin: [MC] 06#3**

ml_mode = A. Model output (Û, R̂, ΔR̂, ρ̂) changes the action among raise / cut / unchanged and the capacity ranking before Validation freeze (FORWARD use test). Mode B cannot rank the capacity list; Mode None is out of project scope. The scoring unit is one item-store at the decision origin; the training observation unit is one item-store-day with a mapped weekly price.

---

## 17A.2 Model family resolution

**Status: Locked-proposed**
**Origin: [MC] 06#23**

linear_reg(mode = "regression"), engine glmnet, mixture = 0.5. glmnet internal standardization off (standardize = FALSE); center/scale is recipe-side only, on training-window moments. Seed 20160522 is set before fitting, even though the fit is deterministic given the folds and grid. **[Amended by owner change control CC-S4-01, approved 2026-10-02 11:43 CT:]** Every glmnet fit (all CV folds and final fits, at every origin) uses convergence threshold thresh = 1e-12. No other model setting changes.

---

## 17A.3 Recipe and feature construction

**Status: Locked-proposed**
**Origin: [MC] 06#23; [DF] Design B §17A recipe**

Recipe order:

1. log_sell_price = ln(sell_price) (sell_price > 0).
2. Dummy-encode factors with fixed references: wday = 1 (Saturday); month = 1; dept_id = FOODS_3; event_type_1 = none (a blank/NULL event_type_1 is the level none).
3. Center/scale the numeric non-dummy predictors on training-window moments.
4. Exactly one interaction = (scaled log_sell_price) × snap_CA.

Raw sell_price is not a predictor (it is only used to derive the log). No item_id dummies. Fixture: FX-INTERACT.

---

## 17A.4 Target definition

**Status: Locked-proposed**
**Origin: [MC] 06#26; 06#22**

The training target is observed daily units at d ≤ origin, winsorized at the item's 0.99 quantile using R quantile(type = 7) over the item's positive training days (training target only; never predictions). The horizon expectation is Û(P) = the sum of the 28 daily predictions d_1942–d_1969 at scenario price P, each floored at 0. Neither revenue nor weekly sums are the target.

---

## 17A.5 Feature list

**Status: Locked-proposed**
**Origin: [MC] 06#24; [DF] Design B §17A allowed/forbidden features; 06 §F**

Allowed features (exactly these): log_sell_price, wday, month, snap_CA, event_type_1, event_any, is_memorial_day_window, is_nba_finals, trailing_28d_units, trailing_84d_units, trailing_28d_mean_price, dept_id, item_mean_log1p_units.

* event_any = 1 if event_name_1 or event_name_2 is non-blank.
* is_memorial_day_window = 1 if the date is 2016-05-30 or ±1 day, and the analogous Memorial Day window in prior years using calendar event_name_1 = 'MemorialDay'.
* is_nba_finals = 1 if event_name is NBAFinalsStart or NBAFinalsEnd on that day, or the day lies between those two event days in the same year if both exist.
* item_mean_log1p_units = mean of ln(1 + daily units) over the item's training rows (priced days d ≤ origin), frozen per fit. Disclosed limitation: it also uses held-out CV folds (06#24 b).
* item_mean_log1p_units is a level control, not an identification strategy. Report the price-model vs calendar-only comparison (T6/A3) as the slope check. Do not interpret a small log-price coefficient as 'no demand response' without T6.

Excluded or forbidden:
* n_snap_next_28_known (dropped, 06 §F);
* raw sell_price as a predictor;
* any unit, revenue or price from d > origin (live d_1941; backtest d_1913 / d_1885);
* sell_price from wm_yr_wk ≥ 11618 (and, analogously, after the backtest current week);
* other stores' sales or prices;
* other items' contemporaneous prices or units;
* snap_TX, snap_WI;
* a year dummy;
* item_id dummies;
* realized horizon outcomes;
* inventory, cost, competitor or promotion labels.

NA rule (06#24 c): training rows with any NA feature (e.g. t < 85, or no priced day in t−28…t−1) are dropped and counted (n_feature_na_rows).

---

## 17A.6 Trailing-window anchoring

**Status: Locked-proposed**
**Origin: [MC] 06#24 a (AI3-M-13)**

On training rows, trailing windows are t−28…t−1 and t−84…t−1.

On every horizon row t ∈ d_1942–d_1969, and on backtest horizon rows, trailing features are anchored at the origin o:
* trailing_28d_units = Σ units d_(o−27)…d_o;
* trailing_84d_units = Σ units d_(o−83)…d_o;
* trailing_28d_mean_price = mean mapped daily price d_(o−27)…d_o.

Live o = 1941 gives d_1914…d_1941 and d_1858…d_1941. Backtest o = 1913 gives d_1886…d_1913 and d_1830…d_1913. Fixture: FX-TRAIL-ANCHOR.

---

## 17A.7 Fold construction

**Status: Locked-proposed**
**Origin: [MC] 06#27**

Training rows = all universe items' priced item-days with d ≤ origin and complete features (all 2,484 items, not only trust-eligible).

Folds = five contiguous d-blocks, fold(d) = ceiling(5·d/D), leave-one-block-out; no random split. Cut points:
* live D = 1941: 1–388 / 389–776 / 777–1164 / 1165–1552 / 1553–1941;
* backtest D = 1913: 1–382 / 383–765 / 766–1147 / 1148–1530 / 1531–1913;
* stability D = 1885: 1–377 / 378–754 / 755–1131 / 1132–1508 / 1509–1885.

Each backtest model is refit separately on training rows with d ≤ its pseudo-origin.

---

## 17A.8 Hyperparameter grid

**Status: Locked-proposed**
**Origin: [MC] 06#27; 06 §E-8**

Penalty grid: 50 values 10^seq(−4, 1, length.out = 50). Select the grid value with the minimum mean held-out daily-unit RMSE across the 5 folds; ties → larger penalty. Refit on the full window at that value. penalty_selected and its grid index (penalty_grid_index) are audit fields. The grid endpoints are coordinator-specified (06 §E-8).

---

## 17A.9 Prediction floor

**Status: Locked-proposed**
**Origin: [MC] 06#23; 06#26**

û = max(0, û_raw), with no integer rounding before the 28-day sum. The count of floored horizon days is audited (n_floored_days).

---

## 17A.10 SNAP forward feature correction

**Status: Locked-proposed**
**Origin: [MC] 06 §F**

`n_snap_next_28_known` is DROPPED from the judged model and from every twin (06 §F). FX-SNAP-FWD is retired. OD-2 is resolved.

---

<!-- END VERBATIM v5.2 lines 1058–1191 -->

<!-- BEGIN VERBATIM v5.2 lines 1240–1314: §19 Non-executable SQL→R blueprint -->
# 19. Non-executable SQL→R blueprint

**Status: Locked-proposed**
**Origin: [MC] framework §19; [MC] 06#30**

Stage 3 must describe the required transformation logic without writing production SQL or R.

The blueprint identifies, in order:

1. **authoritative source tables** — `raw_sales_evaluation`, `raw_sell_prices`, and `raw_calendar`.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

2. **required source fields** — source IDs, sales-history evidence, prices, calendar evidence, and lineage required by the controlled source contract.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

3. **expected keys** — item/store identity, item/store/week price identity, and day/calendar identity are preserved for Source Gate verification.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

4. **source join relationships** — SALES_LONG receives `wm_yr_wk` by mechanical calendar attachment on `d`; no judged join logic is performed in SQL. Permitted joins are listed in §20.2.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

5. **controlled SQL source grain** — SQL delivers the approved CA_1 × department envelope, daily sales-long rows, calendar rows, price rows, and lineage.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

6. **permitted SQL mechanical transformations** — envelope restriction, JSON unnest, casts, and calendar attach only.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

7. **prohibited SQL judged transformations** — eligibility, TE flags, candidates, trailing features keyed to origin, `.pred`, actions, ranks, flags, and distinct-price counts. The full list is in §20.4.
   **Status: Locked-proposed**
   **Origin: [MC] 06#30**

8. **population rules to be applied independently in R-A and R-B** — both paths independently establish the locked 2,484-item universe from the verified SQL package.
   **Status: Locked-proposed**
   **Origin: [MC] framework §19; [MC] 06#5**

9. **eligibility logic to be applied independently in R-A and R-B** — E_A conjuncts, `priced_weeks`, candidate-exists, and TE6 are independently implemented from source evidence.
   **Status: Locked-proposed**
   **Origin: [MC] 06#6–06#8**

10. **judged grain transitions** — verified source rows → item-day judged features → item × candidate scoring → one item-level action row.
    **Status: Locked-proposed**
    **Origin: [MC] framework §19; [MC] 06#11**

11. **metric components** — predicted units, predicted revenue, `delta_rev`, and `unit_ratio`.
    **Status: Locked-proposed**
    **Origin: [MC] 06#12–06#13**

12. **aggregations** — daily scored units are floored at zero and summed over the locked 28-day horizon before revenue is calculated.
    **Status: Locked-proposed**
    **Origin: [MC] 06#12; [MC] 06#26**

13. **segment assignments** — department reporting and prespecified exploratory diagnostic segments are assigned in R, not SQL.
    **Status: Locked-proposed**
    **Origin: [MC] 06#20**

14. **decision classifications** — `raise`, `cut`, `unchanged`, and `hold_ne` are assigned independently in R-A and R-B.
    **Status: Locked-proposed**
    **Origin: [MC] 06#17**

15. **audit counts** — both R paths produce the audit fields and counts locked by the design; SQL Source Gate separately verifies faithful source delivery.
    **Status: Locked-proposed**
    **Origin: [MC] framework §19; [MC] 06#22, 06#24, 06#27, 06#28**

16. **required judged outputs** — both R paths produce the complete locked universe table, candidate table, audit outputs, lineage fields, action, package membership, below-line status, and rank required by §22.
    **Status: Locked-proposed**
    **Origin: [MC] framework §19; [MC] 06#32**



<!-- END VERBATIM v5.2 lines 1240–1314 -->

<!-- BEGIN VERBATIM v5.2 lines 1316–1415: §20 Controlled SQL source contract -->
# 20. Controlled SQL source contract

## 20.1 Envelope and source deliveries

**Status: Locked-proposed**
**Origin: [MC] 06#30**

Envelope CA_1 × five depts.

**Status: Locked-proposed**
**Origin: [MC] 06#30**

SALES_LONG (`item_id`, `dept_id`, `cat_id`, `store_id`, `state_id`, `id`, `d`, `date`, `units` [+ `wm_yr_wk` attach per §19]).

**Status: Locked-proposed**
**Origin: [MC] 06#30**

SALES_LONG = 2,484 × 1,941 = **4,821,444 rows**.

**Status: Locked-proposed**
**Origin: [MC] 06#30**

CALENDAR full **1,969 rows**.

**Status: Locked-proposed**
**Origin: [MC] 06#30**

PRICES = **568,783 rows**, of which **558,847** are at weeks ≤ 11617 and **9,936** are at weeks 11618–11621.

**Status: Locked-proposed**
**Origin: [MC] 06#30**

Post-origin price rows (`wm_yr_wk ≥ 11618`) are delivered, identifiable by week, and forbidden to R judged logic (`FX-LEAK-11618`).

---

## 20.2 Permitted SQL mechanical transformations

**Status: Locked-proposed**
**Origin: [MC] 06#30**

Permitted:

* envelope;
* unnest;
* casts;
* calendar attach.

**Status: Locked-proposed**
**Origin: [MC] 06#30**

SALES_LONG carries `wm_yr_wk` attached from the calendar on `d` (mechanical).

**Status: Locked-proposed**
**Origin: [MC] 06#30; 06#11; AI3-IC-11**

Permitted mechanical joins: CALENDAR ↔ SALES_LONG on `d` (one-to-many; attaches `date` and `wm_yr_wk`). No other joins are permitted in SQL, except that a mechanical price attachment, if performed, joins PRICES to SALES_LONG on (`store_id`, `item_id`, `wm_yr_wk`) only (§21 item 20). Joining CALENDAR to PRICES directly on `wm_yr_wk`, or SALES_LONG to PRICES without `wm_yr_wk`, is prohibited.

---

## 20.3 Required casts

**Status: Locked-proposed**
**Origin: [MC] 06#30; AI3-IC-06**

* units → integer;
* sell_price → DECIMAL(10,2);
* wm_yr_wk → integer;
* d index → integer;
* raw_calendar wday, month, year and snap_CA → integer (snap_CA domain {0, 1});
* event_name_1, event_type_1, event_name_2, event_type_2: trimmed of leading and trailing whitespace; empty string → NULL at delivery;
* TRIM applies to all varchar-delivered categorical fields.

R maps a NULL event_type_1 to the reference level none (§17A.3).

---

## 20.4 Prohibited SQL judged transformations

**Status: Locked-proposed**
**Origin: [MC] 06#30; 06#32; AI3-IC-09**

Prohibited precomputes in SQL: eligibility; TE flags; any of `n_price_changes_pre`, `n_distinct_prices_pre`, `priced_weeks_pre`, `units_365`, `zero_days_365`, `first_priced_wk`, `first_positive_d`; candidates; trailing features keyed to origin; `item_mean_log1p_units`; `.pred`; actions; ranks; flags; distinct-price counts. SQL may deliver only the source fields listed in §20.1.

---

## 20.5 Deliver-and-quarantine resolution

**Status: Locked-proposed**
**Origin: [MC] 06#30**

**Lock Design B §20, deliver-and-quarantine:** post-origin price rows (wm_yr_wk ≥ 11618) are delivered, identifiable by week, and forbidden to R judged logic (FX-LEAK-11618). SALES_LONG carries wm_yr_wk attached from the calendar on d (mechanical). Casts: units → integer, sell_price → DECIMAL(10,2), wm_yr_wk → integer, d index → integer. Reason: the Source Gate can prove the rows exist and match raw, and a fixture proves R never uses them; AI3 withdrew its SQL-side exclusion preference.

**Status: Locked-proposed**
**Origin: [MC] 06#36; 06#34; AI3-IC-04**

`sql_extract_sha256` is the SHA-256 (hex, lowercase, no separators) of the concatenated bytes of the extract manifest file. The manifest lists each delivered file as one line, in lexicographic ascending order of the file path, with `path | byte_length | file_sha256` (pipe-separated, LF line endings, UTF-8, no trailing whitespace). `fixture_pack_sha256` is computed on the fixture-pack manifest by the identical rule. Both R outputs must carry equal values for both hashes; a mismatch is a FAIL on the §23 lineage-equality check.



<!-- END VERBATIM v5.2 lines 1316–1415 -->

<!-- BEGIN VERBATIM v5.2 lines 1416–1522: §21 SQL Source Gate handoff requirements -->
# 21. SQL Source Gate handoff requirements

**Status: Locked-proposed**
**Origin: [MC] 06#31**

Each condition below is a required numeric pass condition.

1. **SALES_LONG row count = 4,821,444 rows.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

2. **SALES_LONG item count = 2,484 items.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

3. **Each SALES_LONG item has d 1…1941.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

4. **Per-item unit sums equal JSON sums for all 2,484 items (not a sample).**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

5. **PRICES row count = 568,783 rows.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

6. **PRICES has 558,847 rows at weeks ≤ 11617.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

7. **PRICES has 9,936 rows in weeks 11618–11621.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

8. **PRICES values equal raw values for every row.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

9. **Calendar row count = 1,969 rows.**
   **Status: Locked-proposed**
   **Origin: [MC] 06#31**

10. **Calendar week count = 282 weeks.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

11. **Week 11621 = 2 days.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

12. **wday(2016-05-21) = 1.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

13. **units integer ≥ 0.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

14. **sell_price > 0.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

15. **wday ∈ 1…7.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

16. **snap_CA ∈ {0, 1}.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

17. **Recorded department list = the five approved departments.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

18. **Lineage equality.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

19. **Position mapping full check. For each of the 2,484 envelope items, the multiset of (JSON position index, unit value) pairs equals the multiset of (d-index, delivered units) pairs. The Gate may implement this as a per-item SHA-256 of the canonical serialization `pos=<int>;u=<int>\n` for pos ascending, compared against the same hash of the delivered SALES_LONG rows sorted by `d` for that item, or an equivalent full-row comparison. Position 0 → d_1 and position 1940 → d_1941 = 2016-05-22 remain as required spot checks of the same condition.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31; Dossier §9; AI3-IC-05**

20. **There is ≤ 1 price row per item-day after mechanical price attachment. After mechanical price attachment, SALES_LONG has exactly 4,821,444 rows, and every (store_id, item_id, d) key appears exactly once.**
    **Status: Locked-proposed**
    **Origin: [MC] 06#31**

21. **Extract manifest exists at the path recorded in the Stage 4 extract-freeze record, with the byte layout in §20.5, and sql_extract_sha256 equals its SHA-256.**
**Status: Locked-proposed**
**Origin: [MC] 06#36; AI3-IC-04**
22. **TRIM applied on all varchar-delivered categorical fields; event_type_1, event_name_1, event_type_2 and event_name_2 blank → NULL; domain wday ∈ 1…7 and snap_CA ∈ {0, 1} verified across all rows.**
**Status: Locked-proposed**
**Origin: [MC] 06#31; AI3-IC-06**
23. **Delivered key uniqueness: SALES_LONG (store_id, item_id, d) and PRICES (store_id, item_id, wm_yr_wk) are each unique.**
**Status: Locked-proposed**
**Origin: [MC] 06#31; [PA] P01 Q1–Q3; AI3-S2**
24. **No NULL units in delivered SALES_LONG and no NULL sell_price in delivered PRICES.**
**Status: Locked-proposed**
**Origin: [MC] 06#31; AI3-S2**

**Any failure = Gate Fail.**

**Status: Locked-proposed**
**Origin: [MC] 06#31**



<!-- END VERBATIM v5.2 lines 1416–1522 -->

<!-- BEGIN VERBATIM v5.2 lines 1523–1614: §22 R-A / R-B judged-output contract -->
# 22. R-A / R-B judged-output contract

## 22.1 Universe table

**Status: Locked-proposed**
**Origin: [MC] 06#32**

One row per in-scope item-store.

Keys:

* `item_id`
* `store_id`

Required fields:

* `dept_id`, `cat_id`
* `in_universe`, `list_start_d`
* `n_price_changes_pre`, `n_distinct_prices_pre`, `priced_weeks_pre`, `units_365`, `zero_days_365`, `first_priced_wk`, `first_positive_d`
* `e_chg3`, `e_u180`, `e_z182`, `e_pw52`, `e_cand`, `te6_usable_slice`, `te6_ape_i`, `te6`, `trust_eligible` (plus `te6_rule_fired` only if OC-5 = Option B2)
* `current_price`, `current_price_11616`, `straddle_flag`
* `n_candidates`, `n_candidates_event_filtered`
* `action` ∈ {`raise`,`cut`,`unchanged`,`hold_ne`}
* `candidate_price`
* `.pred_units_current`, `.pred_units_candidate`, `.pred_rev_current`, `.pred_rev_candidate`
* `delta_rev`, `unit_ratio`, `guardrail_pass`, `legal_change`
* `gain_below_half_mae` ∈ {0, 1, NA} (§11.3)
* `rank_among_qualifiers`
* `package_flag`, `below_line_flag`
* `expectation_not_guarantee` = 1
* `backtest_accept`
* `action_twin_11616`
* `penalty_selected`, `penalty_grid_index`
* `n_horizon_days_scored`
* `n_floored_days`
* `snapshot_id`, `source_version`, `observation_boundary_d`, `observation_boundary_date`, `design_id`, `ml_mode`
* `fixture_pack_sha256`, `sql_extract_sha256`
* `capacity_stance = 'hard_attention_budget'`
* `run_role` ∈ {`R-A`,`R-B`}

`band_expanded` is dropped.

## 22.2 Candidate table

**Status: Locked-proposed**
**Origin: [MC] 06#32; AI3-IC-02; AI3-S4a**

Separate candidate table, one row per capped candidate (grain item_id × candidate_price; at most 5 per item):

* `item_id`
* `candidate_price`
* `abs_log_dist` (= round(abs(ln(Pc/P0)), 10))
* `rank_in_cap`
* `legal_change`
* `guardrail_pass`
* `cent_delta_rev` (= round(R̂(Pc), 2) − round(R̂(P0), 2))
* `.pred_units_candidate`
* `.pred_rev_candidate`
* `delta_rev`
* `unit_ratio`

## 22.3 R-A / R-B independence

**Status: Locked-proposed**
**Origin: [MC] 06#33; framework §19A; AI3-S5**

No shared judged code, model/recipe/workflow objects, scored tables, candidate or eligibility lists, selected set or action table before first-pass freeze. Shared: locked design, frozen fixture pack, verified SQL package, lineage, output schema, fold cuts and penalty grid (spec).

The non-shared objects explicitly include: recipe objects, parsnip workflow objects, glmnet fit objects, tuning objects, the selected penalty value (only the grid and the fold cuts are shared, as specification), and scored horizon tables. R-A and R-B each attest to every M2 line (§24.5). On a reconciliation FAIL, each path repairs toward the spec independently; neither path copies code or outputs from the other.



## 22.4 Audit output table

**Status: Locked-proposed**
**Origin: [MC] 06#32; 06#34; Design B §7.7; AI3-IC-01**

Both R paths emit one audit table, keyed by `run_role` and, where applicable, `dept_id` or `origin_d`, with these fields:

* Universe: `n_items_CA_1_total`, `n_after_dept_map`, `n_universe` (2,484 under OC-1 (a)), `n_dropped_by_X1` … `n_dropped_by_X6`.
* Eligibility and trust: `n_e_chg3`, `n_e_u180`, `n_e_z182`, `n_e_pw52`, `n_e_cand`, `n_te6_usable_slice`, `n_te6`, `n_trust_eligible`.
* Candidates: `n_candidates_pre_event_filter`, `n_candidates_event_filtered`, `n_candidates_post_cap`.
* Data quality and model: `n_price_0_01_weeks`, `n_feature_na_rows`, `n_training_rows`, `penalty_selected`, `penalty_grid_index`, `n_floored_days_total`, `n_horizon_days_scored_total` (= 28 × number of scored items).
* Backtest (per origin_d ∈ {1913, 1885}): `backtest_accept`, `backtest_A1_median_ape`, `backtest_A2_mean_signed_error`, `backtest_n_usable_items`, `backtest_n_U0_excluded`.
* Per dept: `dept_backtest_MAE_revenue`, `te6_dept_median_ape`.
* Actions: `n_legal_changes`, `n_raise`, `n_cut`, `n_unchanged`, `n_hold_ne`, `n_package`, `n_below_line`.
* If OC-5 = Option B2 only: `te6_rule_fired_counts` over {absolute, dept_median, both, neither}.

Every count and flag in §22.4 is exact-equality (§23). The continuous statistics `backtest_A1_median_ape`, `backtest_A2_mean_signed_error`, `dept_backtest_MAE_revenue` and `te6_dept_median_ape` are diagnostic-trigger fields (§23). backtest_accept for origin_d = 1885 is reported for stability only.

---

<!-- END VERBATIM v5.2 lines 1523–1614 -->

<!-- BEGIN VERBATIM v5.2 lines 1615–1712: §23 R-A versus R-B exact reconciliation contract -->
# 23. R-A versus R-B exact reconciliation contract

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Exact equality is required on:

* keys;
* row counts;
* eligibility integers:

  * `n_price_changes_pre`
  * `n_distinct_prices_pre`
  * `priced_weeks_pre`
  * `units_365`
  * `zero_days_365`
* conjunct flags;
* `te6`;
* `trust_eligible`;
* current and candidate prices;
* full candidate-table keys: `item_id × candidate_price`;
* `n_candidates`;
* `straddle_flag`;
* `backtest_accept`;
* all audit counts and flags in §22.4;
* `te6_usable_slice`;
* `guardrail_pass` and `legal_change` (universe and candidate tables);
* `cent_delta_rev` at each candidate price;
* actions;
* `package_flag`;
* `below_line_flag`;
* `rank_among_qualifiers`;
* lineage.

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Continuous tolerance:

$$
|\Delta| \leq 0.05\text{ units}
$$

on:

* `.pred_units_current`
* `.pred_units_candidate`

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Continuous tolerance:

$$
|\Delta| \leq \$0.05
$$

on:

* `.pred_rev_current`
* `.pred_rev_candidate`
* `delta_rev`

**Status: Locked-proposed**
**Origin: [MC] 06#34**

`penalty_grid_index` mismatch is a diagnostic trigger, not by itself a reconciliation failure.

**Status: Locked-proposed**
**Origin: [MC] 06#34; 06#18; AI3-IC-01; AI3-IC-07**

Diagnostic-trigger fields (reported by both paths; a mismatch triggers review but is not by itself a FAIL): `penalty_grid_index`, `gain_below_half_mae`, `backtest_A1_median_ape`, `backtest_A2_mean_signed_error`, `dept_backtest_MAE_revenue`, `te6_ape_i`, `te6_dept_median_ape`. The binding outputs `backtest_accept` and `te6` are exact.

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Any action, package, below-line or rank mismatch = FAIL.

**Status: Locked-proposed**
**Origin: [MC] 06#34; 06#17; AI3-IC-02; AI3-S6a**

A sign mismatch on `cent_delta_rev` at any candidate = FAIL; repair toward base R round(x, 2) on each side, never toward averaging the unrounded values. When a continuous-tolerance check passes but any action, package, below-line or rank field disagrees, reconciliation FAILS and both paths repair toward the spec independently; tolerance is never used to reconcile a discrete field.

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Repair toward the spec, never average.

**Status: Locked-proposed**
**Origin: [MC] 06#34**

Reconciliation outcome is only:

* PASS
* FAIL



<!-- END VERBATIM v5.2 lines 1615–1712 -->

<!-- BEGIN VERBATIM v5.2 lines 1713–1824: §24 Fixture and lineage contract -->
# 24. Fixture and lineage contract

## 24.1 M1 — Active frozen fixture pack

**Status: Locked-proposed**
**Origin: [MC] 06#35; 06 Appendix B**

Synthetic panels; stub predict functions where a prediction is needed.

| ID                                                     | Setup / predicate                                                                                                 | Expected (pass)                                                                                                               | Build fails if                                                           | §17.R clause   | Status          | Origin             |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | -------------- | --------------- | ------------------ |
| FX-HOLD-NE-PRICES (B)                                  | Item with 1 distinct pre-origin price; stub gain large                                                            | trust_eligible = 0; action = hold_ne                                                                                          | any raise/cut                                                            | §17.R5         | Locked-proposed | [MC] 06 Appendix B |
| FX-GUARD-10 (B)                                        | Trusted; stub Û(Pc) = 89, Û(P0) = 100; Pc > P0; ΔR̂ > 0                                                           | guardrail_pass = 0; action ≠ raise                                                                                            | raise assigned, or revenue used instead of units                         | §17.R7         | Locked-proposed | [MC] 06 Appendix B |
| FX-CUT-OK (B)                                          | Cut candidate; stub units +20%; ΔR̂ > 0                                                                           | action = cut                                                                                                                  | cuts banned                                                              | §17.R7         | Locked-proposed | [MC] 06 Appendix B |
| FX-ARGMAX (B)                                          | Two legal candidates, ΔR̂ = 10 vs 8                                                                               | picks ΔR̂ = 10                                                                                                                | picks 8 or the nearer price                                              | §17.R7         | Locked-proposed | [MC] 06 Appendix B |
| FX-NOPAD (B)                                           | 3 qualifiers                                                                                                      | n_package = 3; no hold/unchanged promoted                                                                                     | package padded                                                           | §17.R9         | Locked-proposed | [MC] 06 Appendix B |
| FX-CAP25 (B)                                           | 30 qualifiers, strictly decreasing ΔR̂                                                                            | n_package = 25; n_below_line = 5; order by ΔR̂                                                                                | 26th in package / unsorted                                               | §17.R9         | Locked-proposed | [MC] 06 Appendix B |
| FX-MEMBER (B)                                          | Universe contains a zero-eligible item                                                                            | row present; action = hold_ne                                                                                                 | row dropped                                                              | §17.R1, §17.R5 | Locked-proposed | [MC] 06 Appendix B |
| FX-LEAK-11618 (B)                                      | Lucrative price exists only in week 11618                                                                         | price ∉ candidate set; never a feature                                                                                        | future price used                                                        | §8.3; §17.R4; §17A.5–17A.6; §20.4 | Locked-proposed | [MC] 06 Appendix B |
| FX-CURRENT-11617 (B)                                   | 11616 = 3.00, 11617 = 3.50                                                                                        | current_price = 3.50; straddle_flag = 1; current_price_11616 = 3.00                                                           | uses 3.00 or average                                                     | §17.R3         | Locked-proposed | [MC] 06 Appendix B |
| FX-HORIZON-28 (B)                                      | Calendar stub with 2-day week 11621                                                                               | n_horizon_days_scored = 28 (d_1942–d_1969)                                                                                    | 4 × 7 week logic, dropped or doubled days                                | §17.R6         | Locked-proposed | [MC] 06 Appendix B |
| FX-TIE (B)                                             | Equal ΔR̂, different pred_units_current                                                                           | higher units ranks first                                                                                                      | item_id or random first                                                  | §17.R9         | Locked-proposed | [MC] 06 Appendix B |
| FX-ELIG-BOUNDARY (new)                                 | Items: (chg 3, units 180, zero 182) / (chg 2, 180, 182) / (3, 179, 182) / (3, 180, 183)                           | only the first passes E_A                                                                                                     | any other passes / first fails                                           | §17.R2, §17.R5 | Locked-proposed | [MC] 06 Appendix B |
| FX-PW52 (new)                                          | E_A true, priced_weeks = 51                                                                                       | e_pw52 = 0; hold_ne                                                                                                           | trusted                                                                  | §17.R2, §17.R5 | Locked-proposed | [MC] 06 Appendix B |
| FX-BAND25 (new)                                        | P0 = 4.00; history prices 3.00, 3.01, 4.99, 5.00, 5.01                                                            | candidates include 3.00 (= 0.75·P0), 3.01, 4.99, 5.00 (= 1.25·P0); exclude 5.01                                               | boundary prices dropped or 5.01 kept (float compare)                     | §17.R4         | Locked-proposed | [MC] 06 Appendix B |
| FX-NOCAND (new)                                        | Trusted-otherwise item with no in-band prior price                                                                | e_cand = 0; hold_ne; no band expansion                                                                                        | band expanded or unchanged assigned                                      | §17.R4, §17.R5 | Locked-proposed | [MC] 06 Appendix B |
| FX-EVENT-SINGLE (new)                                  | Price seen in 1 week containing a Sporting (or Cultural) event_type_1 day; another price seen in 1 non-event week | first excluded, second kept; n_candidates_event_filtered = 1                                                                  | only National/Religious filtered, or non-event single-week price dropped | §17.R4         | Locked-proposed | [MC] 06 Appendix B |
| FX-CAP5-TIE (new)                                      | P0 = 4.00; 7 in-band prices incl. 3.20 and 5.00 (equal abs log distance)                                          | 5 nearest kept; distances compared after rounding to 10 decimals, so 3.20 and 5.00 tie and the lower price (3.20) ranks first | more than 5 kept, or tie order differs                                   | §17.R4         | Locked-proposed | [MC] 06 Appendix B |
| FX-UP0-ZERO (new)                                      | Trusted; stub Û(P0) = 0                                                                                           | action = hold_ne                                                                                                              | unit ratio computed / raise                                              | §17.R7         | Locked-proposed | [MC] 06 Appendix B |
| FX-CENT-ROUND (new) | Trusted item with a single candidate; stub R̂(P0) = 100.000 and R̂(Pc) = 100.004, so round(R̂(P0), 2) = 100.00 and round(R̂(Pc), 2) = 100.00 (cent_delta_rev = 0.00) | legal_change = 0; not legal; action = unchanged | raise/cut assigned | §17.R7 | Locked-proposed | [MC] 06 Appendix B; 06#17; AI1-DT-01 |
| FX-MINGAIN-DIAG (new, replaces FX-UNCHANGED-SMALLGAIN) | Legal change with ΔR̂ below stub half-MAE                                                                         | action = raise/cut, ranked normally; gain_below_half_mae = 1                                                                  | demoted to unchanged or hold_ne                                          | §17.R7, §17.R9; §11.3 | Locked-proposed | [MC] 06 Appendix B |
| FX-BACKTEST-COLLAPSE (new)                             | Stub backtest A1 median APE = 0.45                                                                                | backtest_accept = 0; every trust-eligible item → hold_ne                                                                      | any raise/cut/unchanged survives                                         | §17.R8         | Locked-proposed | [MC] 06 Appendix B |
| FX-TRAIL-ANCHOR (new; AI3-M-13)                        | Horizon rows d_1942 and d_1969                                                                                    | trailing_28d_units identical on both = Σ d_1914…d_1941                                                                        | uses post-origin (unknown) days or rolls forward                         | §17.R6         | Locked-proposed | [MC] 06 Appendix B |
| FX-WDAY-SNAP (new; AI2-F18)                            | 2016-05-21 row; snap_TX = 1, snap_CA = 0 day                                                                      | wday = 1 (Saturday); SNAP feature = 0                                                                                         | ISO recode or TX/WI SNAP used                                            | §17.R6         | Locked-proposed | [MC] 06 Appendix B |
| FX-WEEK-ORDINAL (new; DC-1)                            | Week window "last 52 weeks ending 11617"                                                                          | weeks 11518–11552 and 11601–11617 (52 weeks)                                                                                  | integer range 11566–11617 (17 weeks)                                     | §17.R2         | Locked-proposed | [MC] 06 Appendix B |
| FX-INTERACT (new; AI3-m-04)                            | Recipe stub                                                                                                       | model matrix has exactly one interaction column = scaled log_sell_price × snap_CA                                             | missing or extra interactions                                            | §17.R6         | Locked-proposed | [MC] 06 Appendix B |
| FX-TE6-SLICE (new; AI2-MA-02) | Three items that pass E_A, e_pw52 and e_cand at d_1941, each with a large stub gain: (a) units_365 over d_1549–d_1913 = 179 (E_A fails when re-anchored at d_1913); (b) realized units d_1914–d_1941 = 0; (c) sell_price in week 11613 differs from week 11617 | te6_usable_slice = 0; te6 = 0; trust_eligible = 0; action = hold_ne for all three, under every OC-5 option | any raise/cut/unchanged assigned | §17.R5; §7.7 | Locked-proposed | [MC] 06#8; 09 AI2-MA-02 |

Active pack: 26 fixtures (06 Appendix B, 25 active, plus FX-TE6-SLICE). If OC-5 = Option B, FX-TE6-APE (09 §4) is added before the freeze.

 

## 24.2 Retired fixtures

**Status: Locked-proposed**
**Origin: [MC] 06 §F; 06#35**

FX-SNAP-FWD and FX-UNCHANGED-SMALLGAIN retired (06 §F).

## 24.3 Fixture freeze

**Status: Locked-proposed**
**Origin: [MC] 06#35**

Freeze by path + SHA-256 before R-A/R-B start.

Known-case fixtures may not be rewritten after a Fail to greenwash a build.

## 24.4 Lineage

**Status: Locked-proposed**
**Origin: [MC] 06#36**

Every judged export carries:

* `snapshot_id`
* `source_version`
* `observation_boundary_d = 1941`
* `observation_boundary_date = 2016-05-22`
* `design_id = PRICEPOINT-001-S3-v1`
* `ml_mode = A`
* `fixture_pack_sha256`
* `sql_extract_sha256`
* `capacity_stance = hard_attention_budget`



## 24.5 M2 — Spec-to-builder translation packet

**Status: Locked-proposed**
**Origin: [MC] 06#37; [DF] Design B §24.3; framework §19A–§20**

| Gate | Used? | Clause cite | Fixture IDs | R-A attestation | R-B attestation |
| ---- | ----- | ----------- | ----------- | --------------- | --------------- |
| E_A conjuncts | Yes | §7.3; §17.R2, §17.R5 | FX-ELIG-BOUNDARY, FX-HOLD-NE-PRICES | Required | Required |
| priced_weeks | Yes | §7.3; §17.R2, §17.R5 | FX-PW52, FX-WEEK-ORDINAL | Required | Required |
| candidate-exists | Yes | §17.R4, §17.R5 | FX-NOCAND | Required | Required |
| TE6 | Yes — OC-5 pending lock | §7.7; §17.R5 | FX-TE6-SLICE | Required | Required |
| current price | Yes | §17.R3 | FX-CURRENT-11617 | Required | Required |
| band | Yes | §17.R4 | FX-BAND25 | Required | Required |
| event filter | Yes | §17.R4 | FX-EVENT-SINGLE | Required | Required |
| cap/tie | Yes | §17.R4 | FX-CAP5-TIE | Required | Required |
| legal test | Yes | §17.R7 | FX-GUARD-10, FX-CUT-OK, FX-UP0-ZERO, FX-CENT-ROUND | Required | Required |
| guardrail | Yes — OC-3 pending lock | §17.R7 | FX-GUARD-10 | Required | Required |
| ΔR̂ > 0 cent rounding | Yes | §17.R7; §23 | FX-CENT-ROUND | Required | Required |
| action map | Yes | §17.R5, §17.R7 | FX-HOLD-NE-PRICES, FX-CUT-OK, FX-ARGMAX, FX-UP0-ZERO, FX-MINGAIN-DIAG | Required | Required |
| backtest collapse | Yes | §16.4; §17.R8 | FX-BACKTEST-COLLAPSE | Required | Required |
| ranking/tie-break | Yes | §17.R9 | FX-TIE, FX-ARGMAX | Required | Required |
| Membership-first + capacity + no-pad | Yes — OC-4 pending lock | §17.R9 | FX-NOPAD, FX-CAP25, FX-MEMBER | Required | Required |
| leakage | Yes | §8.3; §17.R4; §17A.5–17A.6; §20.4 | FX-LEAK-11618 | Required | Required |
| horizon-28 | Yes | §8.2; §17.R6 | FX-HORIZON-28 | Required | Required |
| week-ordinal rule | Yes | §8.5; §17.R2 | FX-WEEK-ORDINAL | Required | Required |
| trailing anchoring | Yes | §17.R6; §17A.6 | FX-TRAIL-ANCHOR | Required | Required |
| recipe | Yes | §8.6; §17.R6; §17A.3 | FX-WDAY-SNAP, FX-INTERACT | Required | Required |
| Half-window / persistence | N/A | §16 (no split-window persistence rule; 06 Appendix A has none) | N/A | Required (attest unused) | Required (attest unused) |
| Dual-clock / twin action-override | N/A | §11.2 (twins are diagnostic; none changes a judged action, 06#29) | N/A | Required (attest unused) | Required (attest unused) |
| Full analytical-unit universe | Yes | §7.1; §17.R1 | FX-MEMBER | Required | Required |
| Non-enrolling actions | Yes | §17.R5, §17.R7, §17.R9 (hold_ne and unchanged never promoted to the package) | FX-NOPAD, FX-HOLD-NE-PRICES, FX-NOCAND, FX-UP0-ZERO | Required | Required |
| Lineage field mapping | Yes | §24.4; §20.5 | N/A (not fixture-testable) | Required (all §24.4 lineage fields populated and equal to the frozen extract identity) | Required |
| Capacity / simulation labels | Capacity yes; simulation N/A | §17.R9; §22.1; §22.4; §24.4 | FX-NOPAD, FX-CAP25 | Required | Required |
| Mode A scoring | Yes | §17A; §17.R6; §22.3 | FX-INTERACT, FX-TRAIL-ANCHOR | Required (independent fit) | Required (independent fit) |
| Minimum-gain diagnostic (non-judged) | Yes | §11.3 | FX-MINGAIN-DIAG | Required | Required |
<!-- END VERBATIM v5.2 lines 1713–1824 -->

<!-- BEGIN VERBATIM v5.2 lines 1931–1948: §26.2 Owner choices -->
## 26.2 Owner choices

**Status: Owner choice pending**
**Origin: [OC] 06 §C; 06#8; 09 §4**

| # | Item | Alternatives (profiled) | Coordinator recommendation |
|---|---|---|---|
| OC-1 | Department scope (row 4; AI3-M-15) | (a) FOODS_1/2/3 + HOUSEHOLD_1/2, HOBBIES excluded (2,484 items); (b) add HOBBIES; (c) FOODS_3 + HOUSEHOLD_1 only | (a) |
| OC-2 | Eligibility tightness (row 6; DC-3) | E_A + priced_weeks ≥ 52 + candidate-exists = 363 (29/99/172/60/3); E_A ∧ nd ≥ 4 = 274 before candidate-exists (273 or 274 after); E_C = 177; E_B = 784 | E_A (363). Owner confirms that 363 is acceptable against the owner-side ~200–300 preference, or picks E_A ∧ nd ≥ 4 |
| OC-3 | "about 10%" → ρ̂ < 0.90 rejected (row 13; T006) | 0.90 hard; 0.85/0.95 twins | 0.90 hard |
| OC-4 | "about 25" → N_CAP = 25 (row 19; T018/T024; AI3-m-05) | 25 hard; 25 ± tolerance | 25 hard |
| OC-5 | TE6 item-level rule (row 8; T040; 06 §F) | Option A: te6 = te6_usable_slice (slice-only; APE reported only). Option B: te6_usable_slice AND (APE_i ≤ 0.50 OR APE_i ≤ dept median APE of usable items); B1 = 06#8 verbatim; B2 = dept-median limb only when the dept has ≥ 5 usable-slice items. Common slice text: §7.7 | Option A |

All five are confirmed by the human owner at lock. OC-5 must be decided before R builders run.

---


<!-- END VERBATIM v5.2 lines 1931–1948 -->

<!-- BEGIN VERBATIM v5.2 lines 1998–2029: §27.2–27.3 Stage 4 inputs and sequence -->
## 27.2 Stage 4 inputs

Stage 4 receives:

1. Locked-proposed decision statement.
2. Approved analytical question.
3. Frozen population definition.
4. Eligibility contract.
5. Candidate-price rules.
6. KPI definitions.
7. Guardrail choice after OC-3 resolution.
8. Feature contract.
9. Frozen fixture pack.
10. Controlled SQL source package.
11. SQL Source Gate requirements.
12. Independent R-A implementation.
13. Independent R-B implementation.
14. Reconciliation contract.
15. Lineage requirements.
16. Risk register.
17. Owner decisions OC-1…OC-5 recorded at lock (OC-5 selects the TE6 rule before R builders run).

## 27.3 Stage 4 sequence

1. SQL evidence delivery.
2. SQL Source Gate execution.
3. R-A implementation.
4. R-B implementation.
5. Fixture execution.
6. Reconciliation.
7. Stage 5 interpretation.

<!-- END VERBATIM v5.2 lines 1998–2029 -->

END OF 11_STAGE_04_HANDOFF
