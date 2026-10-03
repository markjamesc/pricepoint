# 08_CONSOLIDATED_CANDIDATE_MEASUREMENT_DESIGN_v5

## PRICEPOINT-001 — Stage 3 Consolidated Candidate Measurement Design Candidate v5

---

# v4 → v5 Change Log

**Document:** 08_CONSOLIDATED_CANDIDATE_MEASUREMENT_DESIGN_v5.md

**Revision basis:** Final three-AI audits (framework §27; AI1, AI2 and AI3 each "Pass with required revisions") and coordinator synthesis 09_FINAL_AUDIT_SYNTHESIS.md. v5 is a patch on v4: accepted residuals RES-01…RES-18 and accepted audit findings are applied; every other v4 section is carried unchanged.

| Change ID               | Source                                | Change                                                                                                                         | Sections      |
| ----------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| V5-01                   | RES-14; RES Part C-1                  | §2 = DIP §A approved decision statement verbatim; §3 curly quotes restored                                                     | §2, §3        |
| V5-02                   | RES Part C-2; AI2-MA-04               | §4 constraints restated from DIP §A / T-statements; "more than about 10%"                                                      | §4            |
| V5-03                   | AI2-MA-01                             | Falsifier-to-test mapping added                                                                                                | §6.3          |
| V5-04                   | RES-08; RES-13; AI1-DT-03             | Eligibility windows, E_A (three conjuncts) separated from e_pw52 / e_cand, leading-zero rule, DC-2, 274 label, 06 §C OC-2 text | §7            |
| V5-05                   | RES-09; OD-1 → OC-5 (06 §F)           | TE6 common text (Locked-proposed) and OC-5 options                                                                             | §7.7, M3, §26 |
| V5-06                   | RES-10; RES-07                        | Calendar/SNAP rules, leakage, backtest origins restored                                                                        | §8            |
| V5-07                   | AI3-S3; AI3-IC-11                     | Intermediate grain; calendar × price join prohibition                                                                          | §9.3, §9.4    |
| V5-08                   | RES-11; RES-12; AI3-IC-07             | Twin governance sentence; gain_below_half_mae definition with NA rule                                                          | §11           |
| V5-09                   | RES Part C-5                          | Price-band tertile naming                                                                                                      | §13           |
| V5-10                   | RES-16                                | Design B C1–C12 ledger with 06#21 treatments                                                                                   | §14           |
| V5-11                   | RES-07                                | Backtest detail (06#28)                                                                                                        | §16           |
| V5-12                   | RES-01; RES-02; AI1-TN-01/02          | §17 = 06 Appendix A steps 1–9 verbatim; M4 re-keyed (M4-001…M4-017)                                                            | §17, M4       |
| V5-13                   | RES-03…RES-06; AI2-MA-05              | Mode A lock fields restored (06#23, 06#24, 06#26, 06#27)                                                                       | §17A          |
| V5-14                   | RES-17                                | §18 column "Risk lifecycle status (07)" and note; RR-12 status reflects OC-5                                                   | §18           |
| V5-15                   | AI3-IC-04, 06, 09, 11                 | SQL joins, casts, prohibited precomputes, manifest hashes                                                                      | §19, §20      |
| V5-16                   | RES-18; AI3-IC-04, 05, 06, 08; AI3-S2 | Source Gate items 19–24                                                                                                        | §21           |
| V5-17                   | AI3-IC-01, 02; AI3-S4a/S4b/S5         | Candidate-table fields, independence, new §22.4 audit output table                                                             | §22           |
| V5-18                   | AI3-IC-01, 02, 07; AI3-S6a            | Reconciliation additions                                                                                                       | §23           |
| V5-19                   | AI1-DT-01; AI2-MA-02; AI3-IC-12       | FX-CENT-ROUND setup; FX-TE6-SLICE; FX-LEAK-11618 cite                                                                          | §24.1         |
| V5-20                   | AI1-DT-02; AI3-IC-03; AI2-MA-02       | M2 gate-class rows; TE6 row                                                                                                    | §24.5         |
| V5-21                   | RES-15                                | §25 = 06 record (row names and resolutions, DC-1…DC-4, §E 1–8, §F) plus final-audit record                                     | §25           |
| V5-22                   | RES-13; AI2-MA-03; OC-5               | §26 open/owner-choice tables; allowed-claim sentence                                                                           | §26           |
| V5-23                   | Tally                                 | Open 0; Owner choice 5                                                                                                         | §27           |

---

# Title and Metadata

## Document purpose

This document is the Candidate v5 measurement design for PRICEPOINT-001 Stage 3. It converts the approved business decision and analytical question into a measurement contract before production SQL or R code execution. Stage 3 defines hypothesis, population, grain, KPI, segments, confounders, data-quality rules, decision rules, risks, and SQL→R handoff. 

---

## Metadata

| Field         | Value                                              | Status                  | Origin                                        |
| ------------- | -------------------------------------------------- | ----------------------- | --------------------------------------------- |
| Document ID   | 08_CONSOLIDATED_CANDIDATE_MEASUREMENT_DESIGN_v5.md | Status: Locked-proposed | Origin: [MC] AI1_CANDIDATE_REVISION_PROMPT C1 |
| Version       | 08-v5                                              | Status: Locked-proposed | Origin: [MC] AI1_CANDIDATE_REVISION_PROMPT C2 |
| design_id     | PRICEPOINT-001-S3-v1                               | Status: Locked-proposed | Origin: [MC] AI1_CANDIDATE_REVISION_PROMPT C2 |
| Role          | AI 1 — Consolidated Candidate Design               | Status: Locked-proposed | Origin: [MC] framework §5                     |
| Stage         | Stage 3 — Design                                   | Status: Locked-proposed | Origin: [MC] framework §1                     |
| Input package | 01_DESIGN_INPUT_PACKAGE.md                         | Status: Locked-proposed | Origin: [MC] Inputs                           |
| Input package | 06_DESIGN_RECONCILIATION_MATRIX.md                 | Status: Locked-proposed | Origin: [MC] Inputs                           |
| Input package | 07_RISK_REGISTER.md                    | Status: Locked-proposed | Origin: [MC] Inputs                           |
| Input package | PROFILE_BUNDLE_01_04.md                            | Status: Locked-proposed | Origin: [MC] Inputs                           |
| Input package | three-ai-measurement-design-framework.md           | Status: Locked-proposed | Origin: [MC] Inputs                           |

The controlling reconciliation matrix identifies the frozen inputs used for Candidate synthesis. 

---

# M3 Field-Status Summary

| Field                                                                              | Value                                                                                                                                                                                                                                                                                                                                                                                                                                      | Status                       | Origin                          |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------- | ------------------------------- |
| OC-1 Department scope                                                              | Owner choice: (a) FOODS_1/2/3 + HOUSEHOLD_1/2, HOBBIES excluded (2,484 items); (b) add HOBBIES; (c) FOODS_3 + HOUSEHOLD_1 only. Coordinator recommendation: (a).                                                                                                                                                                                                                                                                           | Status: Owner choice pending | Origin: [OC] 06 §C OC-1; 06#4   |
| OC-2 Eligibility tightness                                                         | Owner choice: E_A + priced_weeks ≥ 52 + candidate-exists = 363 (29/99/172/60/3); E_A ∧ nd ≥ 4 = 274 before candidate-exists (273 or 274 after); E_C = 177; E_B = 784. Coordinator recommendation: E_A (363). Owner confirms that 363 is acceptable against the owner-side ~200–300 preference, or picks E_A ∧ nd ≥ 4.                                                                                                                      | Status: Owner choice pending | Origin: [OC] 06 §C OC-2; 06#6   |
| OC-3 "about 10%" → ρ̂ < 0.90 rejected                                              | Owner choice: 0.90 hard; 0.85/0.95 twins. Coordinator recommendation: 0.90 hard.                                                                                                                                                                                                                                                                                                                                                           | Status: Owner choice pending | Origin: [OC] 06 §C OC-3; 06#13  |
| OC-4 "about 25" → N_CAP = 25                                                       | Owner choice: 25 hard; 25 ± tolerance. Coordinator recommendation: 25 hard.                                                                                                                                                                                                                                                                                                                                                                | Status: Owner choice pending | Origin: [OC] 06 §C OC-4; 06#19  |
| OC-5 TE6 item-level rule ("the expectation for the next four weeks isn't a guess") | Owner choice (final audits did not converge; 06 §F bullet 2): Option A slice-only, te6 = te6_usable_slice; Option B 06#8 as written, te6 = te6_usable_slice AND (te6_ape_i ≤ 0.50 OR te6_ape_i ≤ te6_dept_median_ape), variant B1 verbatim or variant B2 with the dept-median limb only when the dept has ≥ 5 usable-slice items. The common TE6 text in §7.7 is Locked-proposed under every option. Coordinator recommendation: Option A. | Status: Owner choice pending | Origin: [OC] 06#8; 06 §F; 09 §4 |
| OD-2 `n_snap_next_28_known`                                                        | Dropped from the judged model and from every twin; FX-SNAP-FWD retired; OD-2 is no longer Open/Disputed.                                                                                                                                                                                                                                                                                                                                   | Status: Locked-proposed      | Origin: [MC] 06 §F              |

Field-status inventory: Open 0; Owner choice pending 5 (OC-1…OC-5); Disputed 0.



---

# 1. Document purpose and version

## Purpose

**Status: Locked-proposed**
**Origin: [MC] framework §3**

This document defines the complete Stage 3 measurement contract for PRICEPOINT-001 before Stage 4 execution.

The design establishes:

* decision alignment;
* hypothesis;
* population;
* grain;
* measurement;
* comparison;
* heterogeneity;
* alternative explanations;
* decision rules;
* measurement risks;
* SQL→R handoff.

---

## Version

**Status: Locked-proposed**
**Origin: [MC] AI1_CANDIDATE_REVISION_PROMPT C2**

Version:

`08-v5`

design_id:

`PRICEPOINT-001-S3-v1`

---

# 2. Approved decision statement

**Status: Locked-proposed**
**Origin: [SR] DIP §A**

> Morgan Lee, Pricing & Revenue Manager, must determine what recommendation to bring to the store general manager for products meeting the review criteria at the California pilot store’s everyday grocery and household aisles: a specific pilot shelf price increase, a specific pilot shelf price cut, leaving the shelf price unchanged, or classifying the product as “hold — not enough evidence” when the available evidence is not solid. The recommendation should identify the specific pilot price expected to produce the strongest trusted product revenue result (units sold × shelf price) over the next 28 days compared with the current price, while rejecting changes expected to reduce units by more than about 10%. The review occurs on a four-week cycle, with the price decision holding until the next review. The recommendation uses only information available at the end of the most recent history period: daily unit sales, weekly shelf prices, and calendar information including holidays, events, and SNAP benefit days. The output is a ranked list: the strongest trusted price-change opportunities, based on the biggest revenue gain that is trusted, form the GM package up to about 25 actual price changes. If fewer qualify, the list is not padded. If more qualify, additional qualifying opportunities remain below the line as next in line and are not included in that cycle’s package. Holds and hold — not enough evidence outcomes remain visible and do not consume the price-change capacity. Approved changes are pilots, and historical patterns should be presented as expectations to test rather than guarantees.



# 3. Locked analytical question

**Status: Locked-proposed**
**Origin: [SF] Framing C2**

For products meeting the review criteria in the California pilot store’s everyday grocery and household aisles, which specific pilot shelf prices should Morgan recommend for the next 28-day review cycle to produce the strongest trusted expected product revenue (units sold × shelf price) compared with the current price, without recommending a change expected to reduce units by more than about 10%; which products should instead remain unchanged or be classified as “hold — not enough evidence”; and which trusted price-change opportunities rank into the current-cycle GM package of up to about 25 actual price changes, with any additional qualifying opportunities listed below the line?

---

# 4. Stakeholder constraints and exceptions

| Constraint                    | Rule                                                                                                                                                                                                             | Status                       | Origin                                     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ------------------------------------------ |
| Revenue objective             | Identify the specific pilot price expected to produce the strongest trusted product revenue result (units sold × shelf price) over the next 28 days compared with the current price.                             | Status: Locked-proposed      | Origin: [SR] DIP §A                        |
| Unit protection               | Reject changes expected to reduce units by more than about 10%. Operational recommendation (OC-3): reject if ρ̂ < 0.90. 0.85 and 0.95 are diagnostic twins only.                                                 | Status: Owner choice pending | Origin: [SR] DIP §A; T006; [OC] 06 §C OC-3 |
| Evidence threshold            | When the evidence on a product is not solid, the output is “hold — not enough evidence” (action hold_ne) rather than a pushed change; a clear "can't tell" is a legitimate outcome.                              | Status: Locked-proposed      | Origin: [SR] T016; T038                    |
| No minimum gain               | A small gain does not make a trusted change untrustworthy; it ranks lower. No minimum revenue-gain threshold is applied in the judged rule.                                                                      | Status: Locked-proposed      | Origin: [SR] T040; [MC] 06#18              |
| Expectation, not guarantee    | Approved changes are pilots; historical patterns are presented as expectations to test rather than guarantees.                                                                                                   | Status: Locked-proposed      | Origin: [SR] DIP §A; T026; [MC] 06#2       |
| Review cycle                  | Four-week review cycle; the price decision holds until the next review (28-day horizon, price held constant).                                                                                                    | Status: Locked-proposed      | Origin: [SR] DIP §A; [MC] 06#10            |
| Information cutoff            | Only information available at the end of the most recent history period (d_1941 = 2016-05-22): daily unit sales, weekly shelf prices, and calendar information including holidays, events and SNAP benefit days. | Status: Locked-proposed      | Origin: [SR] DIP §A; [MC] 06#10            |
| Capacity                      | The GM package holds up to about 25 actual price changes (raises or cuts); operational N_CAP = 25 (OC-4).                                                                                                        | Status: Owner choice pending | Origin: [SR] T018; T024; [OC] 06 §C OC-4   |
| Holds do not consume capacity | Holds and hold — not enough evidence outcomes remain visible and do not consume the price-change capacity.                                                                                                       | Status: Locked-proposed      | Origin: [SR] T020; DIP §A                  |
| Below the line                | If more qualify, additional qualifying opportunities remain below the line as next in line and are not included in that cycle's package.                                                                         | Status: Locked-proposed      | Origin: [SR] T024; DIP §A                  |
| No padding                    | If fewer qualify, the list is not padded.                                                                                                                                                                        | Status: Locked-proposed      | Origin: [SR] DIP §A; T024                  |



---

# 5. Intended conclusion type and ceiling

## Conclusion type

**Status: Locked-proposed**
**Origin: [MC] 06#2**

Predictive expectation.

---

## Allowed claim

**Status: Locked-proposed**
**Origin: [MC] 06#2**

"Under the locked model this is the 28-day expectation to pilot-test; it is not a guarantee and not a causal effect."

---

## Required output field

| Field                     | Value | Status                  | Origin            |
| ------------------------- | ----- | ----------------------- | ----------------- |
| expectation_not_guarantee | 1     | Status: Locked-proposed | Origin: [MC] 06#2 |

---

# 6. Hypothesis hierarchy

## 6.1 Analytical hypothesis

**Status: Locked-proposed**
**Origin: [MC] 06#1**

Within-item log-price slope after calendar adjustment changes expected revenue ranking.

---

## 6.2 Mechanism

**Status: Locked-proposed**
**Origin: [MC] 06#1**

Historical within-item price variation contains predictive information about future demand response.

---

## 6.3 Falsifiers

**Status: Locked-proposed**
**Origin: [MC] 06#1**

The hypothesis is weakened if:

| Falsifier                              | Status                  | Origin            |
| -------------------------------------- | ----------------------- | ----------------- |
| Flat price response                    | Status: Locked-proposed | Origin: [MC] 06#1 |
| Backtest miss                          | Status: Locked-proposed | Origin: [MC] 06#1 |
| Calendar-only model matches            | Status: Locked-proposed | Origin: [MC] 06#1 |
| Candidates cluster in event/SNAP weeks | Status: Locked-proposed | Origin: [MC] 06#1 |

**Falsifier-to-test mapping (06#1):**

Flat price response → T6 (calendar-only) matches or beats the price+calendar model on A3's changed-price subset. Backtest miss → A1 or A2 fail at d_1913. Calendar-only model matches → same T6/A3 comparison. Candidates cluster in event/SNAP weeks → candidate event-week share diagnostic vs P04 baseline 47.23%. Exploratory department / SNAP-intensity / price-band cuts are not falsifiers and are not decision rules.

---

## 6.4 Exploratory list

**Status: Locked-proposed**
**Origin: [MC] 06#1**

Exploratory diagnostics:

* department differences;
* SNAP-intensity differences;
* price-band differences.

These are not additional decision rules.

---

END OF PART 1
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

# 12. Comparison and baseline contract

## 12.1 Baseline definition

**Status: Locked-proposed**
**Origin: [MC] 06#12**

Primary baseline:

Model-predicted current-price revenue over the same 28-day horizon.

---

## 12.2 Non-baseline diagnostic

**Status: Locked-proposed**
**Origin: [MC] 06#12**

Trailing realized revenue is diagnostic only.

It is not the comparison baseline.

---

## 12.3 Candidate comparison

**Status: Locked-proposed**
**Origin: [MC] 06#12**

Each candidate price is compared against:

$$
P_0
$$

the current price.

---

## 12.4 Decision comparison

**Status: Locked-proposed**
**Origin: [MC] 06#12**

The decision metric is:

$$
\Delta\hat R
$$

subject to:

* unit guardrail;
* trust eligibility;
* candidate legality.

---

END OF PART 2
# 13. Segment contract

## 13.1 Purpose

**Status: Locked-proposed**
**Origin: [MC] 06#20**

Segments are used for:

* reporting heterogeneity;
* diagnostics;
* interpretation.

Segments do not create additional judged actions.

---

## 13.2 Department reporting

**Status: Locked-proposed**
**Origin: [MC] 06#20**

Publish department rows for:

* FOODS_1;
* FOODS_2;
* FOODS_3;
* HOUSEHOLD_1;
* HOUSEHOLD_2.

Department rows are published even when:

$$
n = 3
$$

No department is silently removed because of low eligible count.

---

## 13.3 Exploratory SNAP-intensity and price-band segments

**Status: Locked-proposed**
**Origin: [MC] 06#20; Design B §13**

Two exploratory cuts are defined, and neither is a decision rule:

* SNAP-intensity tertile: the share of the item's last-52-week units that fall on snap_CA = 1 days, with tertiles computed on trust-eligible items only.
* Price-band tertile: the item's current-price tercile, with tertiles computed on the universe.

A band needs at least 20 items before a rate is published for it. These cuts must not retune ranking.

---

## 13.4 Excluded segmentation

**Status: Locked-proposed**
**Origin: [MC] 06#20**

`cat_id` is excluded as a judged segmentation dimension.

Reason:

No additional action rule is created from category grouping.

---

## 13.5 Required segment outputs

| Segment                    | Purpose                   | Status                  | Origin             |
| -------------------------- | ------------------------- | ----------------------- | ------------------ |
| Department                 | Scope reporting           | Status: Locked-proposed | Origin: [MC] 06#20 |
| Price-band tertiles (current price) | Exploratory heterogeneity | Status: Locked-proposed | Origin: [MC] 06#20 |
| SNAP-intensity diagnostics | Context only              | Status: Locked-proposed | Origin: [MC] 06#20 |

---

# 14. Confounder and competing-explanation ledger

**Status: Locked-proposed**
**Origin: [MC] 06#21; [DF] Design B §14**

| Risk ID | Variable / mechanism                        | Why it matters                                                                                                                                       | Relation to exposure                               | Relation to outcome                                                  | Available measure                                                                                                                | Planned treatment                                                                                                                                                                                                                                                                        | Residual limitation                                                                             |
| ------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| C1      | **Price endogeneity / inferred promotions** | Prices move when something else is happening. A high-price week that coincides with a display or manufacturer promo will look like inelastic demand. | Price changes are the exposure.                    | Units and therefore revenue.                                         | No promotion flag. Only price path + calendar.                                                                                   | (1) Identify from within-item price variation, not cross-item price levels. (2) Include SNAP and event features. (3) Restrict candidates to previously observed prices. (4) Calendar-only ablation twin. (5) Flag candidates whose historical occurrences were ≥50% event or SNAP weeks. | Unlabeled promotions remain. Causal ceiling stays predictive.                                   |
| C2      | SNAP cycle                                  | CA SNAP days materially move grocery. Horizon has snap_CA 6/1–6/10.                                                                                  | Prices may be set knowing SNAP weeks.              | Units jump on SNAP days.                                             | `snap_CA`                                                                                                                        | Daily SNAP feature; SNAP-intensity diagnostic. Do not use TX/WI SNAP.                                                                                                                                                                                                                    | SNAP feature captures average SNAP lift, not item-specific EBT elasticity if under-specified.   |
| C3      | Holidays / events                           | Memorial Day, sporting, religious, cultural events in horizon.                                                                                       | Promo pricing around events.                       | Units move.                                                          | event_name/type 1 and 2                                                                                                          | Type dummies + specific horizon-event flags listed in §17A.                                                                                                                                                                                                                              | Rare events have few training repeats (NBA Finals once per year).                               |
| C4      | Seasonality                                 | Month / season changes mix and demand.                                                                                                               | Seasonal price resets.                             | Units.                                                               | month, year, wday                                                                                                                | wday + month features; year not used as a future dummy.                                                                                                                                                                                                                                  | Smooth intra-month seasonality only partly captured.                                            |
| C5      | Selection on price-movers                   | Eligibility requires movement. Items that never move (possibly already “right” or constrained) are out.                                              | Exposure history is selected.                      | Learned slope is a slope for items someone already chose to reprice. | n_distinct_prices, n_changes                                                                                                     | Disclose; do not generalize to never-movers.                                                                                                                                                                                                                                             | Structural.                                                                                     |
| C6      | Survivor / late listing                     | Items must exist at CA_1 through 2016-05-22. Early failures unobserved. Leading zeros.                                                               | Long-lived SKUs over-represented.                  | Volume and stability overstated.                                     | first positive sale day; U5                                                                                                      | Start-of-life rule; do not treat pre-list zeros as demand.                                                                                                                                                                                                                               | No true list/delist file.                                                                       |
| C7      | Stockouts as zeros                          | Zeros may be no demand or no inventory.                                                                                                              | Price may rise when stock is low or fall to clear. | Units understated in stockout weeks.                                 | None                                                                                                                             | Retain zeros; do not impute. Sensitivity: winsorize training days at the item 99th percentile only (outliers), never impute zeros to median.                                                                                                                                             | Cannot distinguish.                                                                             |
| C8      | Category substitution                       | Raising item A may send units to item B. Item revenue can rise while aisle revenue falls, or vice versa.                                             | Simultaneous prices.                               | Item KPI misses aisle KPI.                                           | Other items’ prices exist but using contemporaneous other-item prices as features creates a different estimand and leakage risk. | **Do not** include other-item prices in the judged model. Disclose aisle-substitution as unmeasured.                                                                                                                                                                                     | Material residual. The KPI is item revenue as locked.                                           |
| C9      | Competitor prices                           | Missing.                                                                                                                                             | Competitive under/over-pricing.                    | Units.                                                               | None                                                                                                                             | Disclose Infeasible.                                                                                                                                                                                                                                                                     | Residual.                                                                                       |
| C10     | Cross-sectional price-quality confounding   | Expensive SKUs are different products. A pooled price coefficient without item level attributes “premium” to “high price.”                           | Exposure level differs by item.                    | Units lower for dear items for quality reasons.                      | dept, lagged item mean units                                                                                                     | Within-item identification via item-level lagged demand + dept, and candidates drawn from the item’s own history. Avoid using raw cross-section of price to explain cross-section of volume.                                                                                             | glmnet will still use cross-item variation if not careful; recipe rules in §17A constrain this. |
| C11     | Horizon price file leakage                  | Future weeks’ prices are in `raw_sell_prices`.                                                                                                       | Would reveal what Walmart later charged.           | Would contaminate “current” or candidates.                           | weeks 11618–11621 exist                                                                                                          | Ban as features and as candidate sources. Source Gate lists them; R filter is judged.                                                                                                                                                                                                    | Builder error. Fixtures must catch use of 11618+.                                               |
| C12     | Partial week 11621                          | 2-day week.                                                                                                                                          | If weekly model used, exposure window is wrong.    | Units inflated.                                                      | calendar                                                                                                                         | Daily 28-day sum.                                                                                                                                                                                                                                                                        | Controlled if daily grain is implemented.                                                       |

**Most important confounder (headline):** C1 price endogeneity / unlabeled promotions, operating jointly with C2–C4 calendar.

**06#21 additions:**

* C1 disclosure (06#15; P04 Q3): single-week prices are under-represented in event weeks (40.22% vs 47.23% baseline), so the single-week event filter (§17.R4) is a low-impact precaution, not a confounder control with evidence behind it.
* C6: U5 is replaced by the trust conjunct priced_weeks ≥ 52; leading-zero rule per §7.3 (06#5, 06#7).
* C10 treatment: the item-level proxy item_mean_log1p_units (§17A.5; 06#24 b) together with dept_id, and candidates drawn only from the item's own history (06#14).

---

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
# 17A. Predictive analytics / ML mode

## 17A.1 ML mode

**Status: Locked-proposed**
**Origin: [MC] 06#3**

ml_mode = A. Model output (Û, R̂, ΔR̂, ρ̂) changes the action among raise / cut / unchanged and the capacity ranking before Validation freeze (FORWARD use test). Mode B cannot rank the capacity list; Mode None is out of project scope. The scoring unit is one item-store at the decision origin; the training observation unit is one item-store-day with a mapped weekly price.

---

## 17A.2 Model family resolution

**Status: Locked-proposed**
**Origin: [MC] 06#23**

linear_reg(mode = "regression"), engine glmnet, mixture = 0.5. glmnet internal standardization off (standardize = FALSE); center/scale is recipe-side only, on training-window moments. Seed 20160522 is set before fitting, even though the fit is deterministic given the folds and grid.

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

# 18. Measurement-risk register

**Status: Locked-proposed**
**Origin: [MC] 06#38**

Class: **SQL** = SQL delivery risk (wrong rows/fields/multiplicity/values reach R); **R** = R translation risk (right data, wrong judged logic); **D** = design/measurement risk (shared by both R paths; fixtures cannot catch it).

The "Risk lifecycle status (07)" column preserves the lifecycle vocabulary of 07_RISK_REGISTER.md (framework §18 register Status field: Resolved, Accepted, Open, Blocking, Deferred). These values describe risk/control lifecycle and do not alter the candidate's design-element status inventory in M3.

| Risk ID | Class   | Design component                | Failure mode (description)                                                                                                                                               | Likelihood                                 | Decision impact                                                                       | Detection control                                                                                                          | Prevention control                                                                                                                                             | Sensitivity test                                            | Residual risk                                           | Risk lifecycle status (07)                  | Seed / updates                                                                  |
| ------- | ------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------ | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------- |
| RR-01   | D       | KPI / confounding (C1)          | Unlabeled promotions and event-timed price setting make the log-price slope endogenous: wrong sign or flattened elasticity                                               | High                                       | Wrong raise/cut direction; overstated gains                                           | Calendar-only ablation twin (06#29 T6); backtest A3 Spearman comparison (06#28); per-candidate event-week share diagnostic | Candidates only from own observed prices (06#14); SNAP/event features; within-item identification via item_mean_log1p_units (06#24); predictive ceiling (06#2) | T6 calendar-only; T5 no SNAP                                | High: no promotion field exists                         | Accepted with disclosure                    | B R1; Dossier M-03, M-06, L12; AI2-F09                                          |
| RR-02   | D       | Candidate event filter          | Single-week event filter presented as a confounder control although P04 Q3 shows single-week prices are under-represented in event weeks (40.22% vs 47.23% baseline)     | Medium                                     | Misleading narrative; the filter itself removes only 9 of 1,114 capped E_A candidates | P04 Q3 recorded; audit `n_candidates_event_filtered`                                                                       | Disclosure sentence in candidate §17; filter kept as low-impact precaution (06#15)                                                                             | Report with filter off (counts from P04 Q2)                 | Low                                                     | Accepted                                    | New (P04); AI3-M-08                                                             |
| RR-03   | D       | Comparison / baseline           | Builders or Stage 5 use trailing realized revenue as the baseline, so calendar lift (Memorial Day, SNAP 06-01…06-10) is credited to price                                | Medium                                     | Inflated gains; wrong ranking                                                         | Blueprint check; output contract carries predicted current-price fields                                                    | Locked predicted-current baseline (06#12)                                                                                                                      | Trailing-baseline diagnostic twin                           | Low                                                     | Resolved (design); Open until fixtures pass | B R2; AI2-F05                                                                   |
| RR-04   | R       | Current price                   | R-A/R-B pick different weeks (11616 vs 11617)                                                                                                                            | Medium → Low after lock                    | Wrong P0; raise/cut flip                                                              | Exact recon on current_price; FX-CURRENT-11617                                                                             | Lock week 11617 (06#9)                                                                                                                                         | T1 11616 twin + straddle action-flip flag (5 items per P03) | Low (5 of 2,484 items differ)                           | Resolved (design)                           | B R3; Dossier R-03, L02; AI1-F2; AI2-F04; AI3-B-02; P03                         |
| RR-05   | D       | Current price semantics         | The weekly file records week-ending rather than week-starting prices, so the 11617 price includes a change after 2016-05-22                                              | Low                                        | Wrong P0 for straddling items                                                         | straddle_flag; T1 twin                                                                                                     | Documented assumption (DIP §B: weekly price for the week)                                                                                                      | T1                                                          | Low (5 items)                                           | Accepted                                    | B §8.3 residual; AI2 owner-choice 2                                             |
| RR-06   | SQL / R | Leakage — post-origin prices    | Prices for weeks 11618–11621 (delivered, quarantined) enter candidates, features or current price                                                                        | Medium (rows sit in the extract)           | Oracle list that cannot be replicated                                                 | Source Gate identifies 9,936 post-origin rows; FX-LEAK-11618; exact recon on candidate table                               | Deliver-and-quarantine; forbidden-feature list (06#24, 06#30)                                                                                                  | —                                                           | Low if fixture binds                                    | Open until Stage 4                          | B R4; Dossier L01, L07, L08, SQL-06; AI2-F19; AI3 cross-review SQL-06 downgrade |
| RR-07   | R       | Grain / horizon                 | Weekly logic treats week 11621 as 7 days, or the horizon is not exactly d_1942–d_1969                                                                                    | Medium                                     | Inflated or deflated Û                                                                | n_horizon_days_scored = 28 assertion; FX-HORIZON-28                                                                        | Daily grain; 28-day sum (06#10, 06#26)                                                                                                                         | —                                                           | Low                                                     | Open until Stage 4                          | B R5; Dossier L10, R-05                                                         |
| RR-08   | D       | Population / departments        | Five-department scope is too wide (HOUSEHOLD_2 has 3 eligible items) or not what the owner means by "everyday grocery and household"                                     | Medium                                     | Different package composition                                                         | Audit n by dept (universe 216/398/823/532/515; eligible 29/99/172/60/3)                                                    | Owner confirmation OC-1 (06#4); item-level trust gate, no silent dept cuts                                                                                     | Drop-HOUSEHOLD_2 view in audit table                        | Low after owner confirms                                | Open (owner choice OC-1)                    | B R6; Dossier SQL-01; AI3-M-15; P04 Q1                                          |
| RR-09   | D       | Eligibility thresholds          | Cutoffs chosen without distribution evidence, or sized to a target not held by the stakeholder                                                                           | High → Medium                              | Empty or bloated trusted set                                                          | P02/P04 joint counts on record: E_A 364 (363 with candidates), E_A∧nd≥4 274, E_C 177, E_B 784                              | E_A tied to T010 clauses; owner choice OC-2 made before results (06#6)                                                                                         | T7 (E_A∧nd≥4), T8 (E_C)                                     | Medium: 363 is above the owner-side ~200–300 preference | Open (owner choice OC-2)                    | B R7; Dossier R-01, M-02; AI2-F03, F15; AI3-B-01, M-11; P04                     |
| RR-10   | D       | Provenance of the size target   | The "~200–300 eligible items" owner-side figure gets treated as a stakeholder requirement (as in the P02 NOTES and AI3-M-11)                                             | Medium                                     | Threshold picked to hit an invented business constraint                               | 06 DC-3 recorded; candidate must tag it "owner choice pending"                                                             | Label as owner-side preference, not T0xx (AI2-F15 accepted)                                                                                                    | —                                                           | Low                                                     | Resolved (design)                           | AI2-F15; 06 DC-3                                                                |
| RR-11   | R / D   | Week arithmetic                 | Windows computed by subtracting integers from wm_yr_wk (non-contiguous: 11552 → 11601), e.g. "11617−104" = 57 weeks, "11566–11617" = 17 weeks                            | High (it already happened once: P02 chg2y) | Wrong eligibility or feature windows; silent R-A/R-B divergence                       | FX-WEEK-ORDINAL; exact recon on eligibility integers                                                                       | Calendar-ordinal rule (06#39)                                                                                                                                  | —                                                           | Low if fixture binds                                    | Resolved (design); Open until Stage 4       | New (06 DC-1, DC-2; P04 Q5)                                                     |
| RR-12   | D       | "Not a guess" trust prong (TE6) | T040's third prong has no numeric test (Design B cap undefined), so builders invent one, or trusted items rest on unvalidated forecasts                                  | High                                       | Arbitrary hold_ne, or untrusted changes reach the package                             | Owner decides OC-5 at lock (final audits did not converge; 09 §4); te6 and te6_usable_slice in recon                                                                             | Model-level acceptance collapse (RR-14); coordinator recommendation in 06#8                                                                                    | Report package with and without TE6                         | Medium                                                  | Open (owner choice OC-5 at lock; formerly OD-1)                                 | B R12; AI3-M-04; 06#8                                                           |
| RR-13   | D       | Guardrail                       | A hard 0.90 cut on a noisy Û wrongly rejects or admits near-threshold changes                                                                                            | Medium                                     | False reject/accept                                                                   | List items with ρ̂ in [0.85, 0.95]                                                                                         | Show unit_ratio; owner re-affirms 0.90 (OC-3)                                                                                                                  | T2 0.85, T3 0.95                                            | Medium                                                  | Accepted                                    | B R8; Dossier R-06; AI3-B-03                                                    |
| RR-14   | D       | Backtest acceptance             | Model miscalibrated (A1 median APE > 0.40 or A2 bias outside ±0.20) but live list still recommends changes; or caps get moved after results                              | Medium                                     | Untrusted changes to the GM                                                           | A1/A2 computed at d_1913; d_1885 stability; FX-BACKTEST-COLLAPSE                                                           | Caps disclosed before execution; failure → all trust-eligible items hold_ne (06#28)                                                                            | d_1885 origin                                               | Medium: caps are provisional policy                     | Resolved (design); Open until Stage 4       | B §16.3, R12; Dossier L05, L06, R-11; AI2-F13                                   |
| RR-15   | D       | Minimum gain                    | A screen (half-MAE) suppresses trusted small gains that T040 says should just rank lower; or an undisclosed floor appears                                                | Medium                                     | Smaller package; stakeholder rule broken                                              | FX-MINGAIN-DIAG; gain_below_half_mae is diagnostic only                                                                    | No judged min-gain (T040) (06#18)                                                                                                                              | T9 listing of flagged items                                 | Low                                                     | Resolved (design)                           | B R9; Dossier R-09; AI2 cross-review §2; AI3 owner-choice 7 (rejected on T040)  |
| RR-16   | D       | KPI construct (C8)              | Item revenue rises while aisle revenue falls (substitution)                                                                                                              | High (conceptual)                          | GM optimizes item, not aisle                                                          | Cannot be measured with the locked contract                                                                                | Disclose ceiling; other-item prices banned as features                                                                                                         | —                                                           | High                                                    | Accepted (disclosure)                       | B R10                                                                           |
| RR-17   | D       | Zeros as stockouts (C7)         | Slope estimated on censored quantity (1,434 of 2,484 items have > 182 zero days)                                                                                         | Medium                                     | Biased Û for intermittent items                                                       | Zero-share diagnostic; zero_days_365 ≤ 182 gate for trust                                                                  | No imputation; E_A zero-day conjunct                                                                                                                           | —                                                           | High for residual intermittency                         | Accepted                                    | B R11; Dossier M-04; P02 P2                                                     |
| RR-18   | R       | Capacity / no-pad               | Builders pad to 25, promote holds, or mis-rank ties                                                                                                                      | Low                                        | Diluted GM package                                                                    | n_package = min(25, n_qualifiers); FX-NOPAD, FX-CAP25, FX-TIE, FX-MEMBER                                                   | Membership-first rule and tie-break locked (06#19)                                                                                                             | —                                                           | Low                                                     | Resolved (design)                           | B R13; Dossier R-07, R-08; AI3-M-03                                             |
| RR-19   | SQL     | JSON unnest                     | Position offset (index 0 ≠ d_1) shifts all dates and SNAP alignment                                                                                                      | Medium                                     | Every feature misaligned                                                              | Source Gate: index 0 → d_1, 1940 → d_1941 = 2016-05-22; per-item sum equality for all 2,484 items; 4,821,444 rows          | Mechanical unnest with fixed map (06#30–31)                                                                                                                    | —                                                           | Low if gated                                            | Open until Gate                             | B R14; Dossier SQL-02                                                           |
| RR-20   | SQL     | Price and calendar delivery     | Duplicate or dropped price rows; wrong wm_yr_wk / wday / snap mapping; varchar lexical casts                                                                             | Medium                                     | Wrong prices and features                                                             | Gate: 568,783 price rows (558,847 ≤ 11617), value equality on every row, calendar 1,969/282, 11621 = 2 days, domains       | Casts in SQL, verified by the Gate; ≤ 1 price per item-day                                                                                                     | Compare cast vs raw min/max                                 | Low if gated                                            | Open until Gate                             | Dossier SQL-03, SQL-04, SQL-05                                                  |
| RR-21   | SQL     | Lineage                         | Extract not tied to the source freeze; R outputs from different extracts                                                                                                 | Medium                                     | Reconciliation meaningless                                                            | Lineage equality check in Gate and recon                                                                                   | snapshot_id, source_version, observation_boundary_d, design_id, sql_extract_sha256, fixture_pack_sha256 (06#36)                                                | —                                                           | Low                                                     | Open until Stage 4                          | Dossier SQL-07                                                                  |
| RR-22   | R       | Model reconciliation            | Independent glmnet paths select different penalties, so actions differ                                                                                                   | Medium                                     | Recon fail or unstable package                                                        | Penalty + grid index audit; tolerances 0.05 units / $0.05; action equality exact                                           | Locked fold cuts ceiling(5·d/D), 50-value grid, ties → larger, recipe-side standardization, seed (06#27)                                                       | —                                                           | Low–Medium                                              | Accepted with tolerance                     | B R15; Dossier M-07, P-11, R-12; AI2 cross-review §2; AI3-B-04, B-09            |
| RR-23   | R       | Feature construction            | Trailing features on horizon rows roll into unknown post-origin days; item proxy computed differently                                                                    | Medium                                     | Divergent Û; hidden leakage                                                           | FX-TRAIL-ANCHOR; recon on .pred                                                                                            | Anchor at origin (AI3-M-13); item_mean_log1p_units definition (AI3-M-12) (06#24)                                                                               | —                                                           | Low                                                     | Resolved (design)                           | AI3-M-12, M-13; Dossier L04                                                     |
| RR-24   | D / R   | Forward SNAP feature            | `n_snap_next_28_known` cannot be computed exactly for horizon days d_1943–d_1969 because the calendar ends at d_1969; truncation makes training and scoring inconsistent | High if kept                               | Biased horizon predictions; R-A/R-B boundary divergence                               | FX-SNAP-FWD (only if kept)                                                                                                 | Recommendation: drop the feature (06#25)                                                                                                                       | Truncated version as a twin                                 | Low if dropped                                          | Resolved (06 §F: dropped)                   | AI3-M-14; 06#25                                                                 |
| RR-25   | D       | Target specification            | Training target read as "future horizon units" (unobserved)                                                                                                              | Medium → Low                               | Unbuildable or leaky model                                                            | Spec→builder attestation                                                                                                   | Target = observed daily units d ≤ origin; horizon = sum of 28 predictions (06#26)                                                                              | —                                                           | Low                                                     | Resolved (design)                           | AI3-B-06                                                                        |
| RR-26   | D       | Model class                     | Linear daily units predict negatives; flooring at 0 biases 28-day sums for low-volume items                                                                              | Medium                                     | Overstated Û for thin items                                                           | n_floored_days audit                                                                                                       | Floor + audit; zero-day gate limits thin items                                                                                                                 | Poisson-family twin later (non-judged)                      | Medium                                                  | Accepted                                    | B R18                                                                           |
| RR-27   | D       | Candidate band and cap          | Band too narrow (items lose all candidates) or too wide (implausible prices); cap ordering not reproducible                                                              | Medium → Low                               | Different printed prices                                                              | P04 Q2: ±25% leaves 1 of 364 E_A items without a candidate; cap binds for 20; FX-BAND25, FX-CAP5-TIE, FX-NOCAND            | ±25% inclusive, integer-cent comparison; cap 5 with distance rounded to 10 decimals, tie → lower price; no expansion (06#14, 06#16)                            | T4 ±20% band                                                | Low                                                     | Resolved (design)                           | Dossier M-01, R-04; AI3-M-10; AI2-F07; P04                                      |
| RR-28   | D       | Causal overclaim                | Stage 5 writes "will raise revenue"                                                                                                                                      | Medium                                     | False certainty to the GM                                                             | Conclusion-ceiling check at Stage 5                                                                                        | T026 wording; expectation_not_guarantee = 1 (06#2)                                                                                                             | —                                                           | Medium                                                  | Resolved (design)                           | B R16; AI2-F02                                                                  |
| RR-29   | D       | Segment multiplicity            | Fishing elasticities by SNAP tertile or price band                                                                                                                       | Medium                                     | Spurious story                                                                        | Exploratory label; ≥ 20-item floor                                                                                         | One judged list (06#20)                                                                                                                                        | —                                                           | Low                                                     | Resolved (design)                           | B R17                                                                           |
| RR-30   | R       | Independence                    | R-A/R-B share judged code, model/recipe objects, candidate/eligibility lists or scored tables                                                                            | Low–Medium                                 | Correlated error hidden; recon agreement meaningless                                  | Stage 4 independence attestations                                                                                          | Rule in 06#33                                                                                                                                                  | —                                                           | Low                                                     | Resolved (design)                           | AI3-B-10; framework §19A                                                        |
| RR-31   | R       | Fixture governance              | Fixtures rewritten after a Fail, or FX-UNCHANGED-SMALLGAIN (retired) used                                                                                                | Low                                        | Greenwashed build                                                                     | Fixture pack SHA-256 frozen before builders                                                                                | Appendix B pack; no-rewrite rule (06#35)                                                                                                                       | —                                                           | Low                                                     | Open until freeze                           | Framework §19A                                                                  |
| RR-32   | D       | Survivor / late listing (C6)    | Long-lived SKUs over-represented; 9 items with < 52 priced weeks                                                                                                         | Low                                        | Package tilted to mature items                                                        | priced_weeks audit (P04 Q4: 2,475 items first priced > 52 weeks before 11617)                                              | e_pw52 gate; disclose                                                                                                                                          | —                                                           | Low                                                     | Accepted                                    | B C6; Dossier P-03; P04 Q4                                                      |
| RR-33   | D       | Price anomalies                 | $0.01 prices (HOUSEHOLD_1) treated as real candidates or training points                                                                                                 | Low                                        | Implausible candidate                                                                 | Audit n_price_0_01_weeks                                                                                                   | Retain and flag; band excludes them for normally priced items                                                                                                  | —                                                           | Low                                                     | Accepted                                    | Dossier §3 P-04                                                                 |
| RR-34   | D       | Profile provenance              | Profile 02 recent-change figure (30) cited as evidence although it measured 57 weeks, not 104 (true 232)                                                                 | Medium                                     | Wrong rationale in the candidate                                                      | 06 DC-2; P04 Q5                                                                                                            | Candidate must cite 232 or omit the recent-change argument                                                                                                     | —                                                           | Low                                                     | Resolved (design)                           | New (P04)                                                                       |



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



END OF PART 4
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
# 25. Multi-AI review and resolution record

**Status: Locked-proposed**
**Origin: [MC] 06 §A, §B, §E, §F; 09**

## 25.1 Design reconciliation record

| 06 row | Component (06) | Resolution (06) | Status in v5 |
| ------ | -------------- | --------------- | ------------ |
| 1 | Hypothesis hierarchy | Lock Design B §6 (hypothesis + falsifiers + exploratory list); falsifiers map to locked tests (backtest A1/A2, calendar-only twin, event-week diagnostic); no half-MAE reference | Locked-proposed |
| 2 | Conclusion type and causal ceiling | Lock Design B §5 with A's ceiling label; allowed claim "Under the locked model this is the 28-day expectation to pilot-test; it is not a guarantee and not a causal effect." | Locked-proposed |
| 3 | ml_mode | Lock ml_mode = A (FORWARD use test) | Locked-proposed |
| 4 | Population / departments | Owner choice; recommendation = the five departments, HOBBIES excluded; HOUSEHOLD_2 stays in the universe | Owner choice pending (OC-1) |
| 5 | Universe membership and exclusions | Lock universe = all 2,484 CA_1 items in the five depts; U5 moves into the trust gate as priced_weeks ≥ 52 (hold_ne); keep X1–X6 with audit counts | Locked-proposed |
| 6 | Trust gate — price movement and volume (eligibility rule) | Owner choice; recommendation E_A (n_price_changes ≥ 3 lifetime, weeks ≤ 11617; units_365 ≥ 180, d_1577–d_1941; zero_days_365 ≤ 182) plus row 7 → 363; alternatives E_A ∧ nd ≥ 4 = 274, E_C = 177, E_B = 784; twins E_A ∧ nd ≥ 4 and E_C | Owner choice pending (OC-2) |
| 7 | Trust gate — listing age and candidate-exists | Lock priced_weeks ≥ 52 and n_candidates ≥ 1 as trust conjuncts (failure → hold_ne); revise leading-zero rule (raw 365-day window; training from first priced day; first_positive_d audit field) | Locked-proposed |
| 8 | Trust gate — "forward expectation is not a guess" (TE6) | Open for the final audit with recommendation: usable d_1913 slice AND (APE_i ≤ 0.50 OR APE_i ≤ dept median APE); no usable slice → hold_ne. The final audits did not converge → owner choice OC-5 (06 §F bullet 2; 09 §4) | Owner choice pending (OC-5) |
| 9 | Current price | Lock current_price = week-11617 price; twin = week-11616 price with straddle_flag (5 items) and action-flip flag | Locked-proposed |
| 10 | Decision date, horizon, time grain | Lock Design B §8: origin end of d_1941; horizon d_1942–d_1969 = 28 days; price constant; daily grain; wday as stored Sat=1…Fri=7; snap_CA only; calendar allowed forward; sales d ≥ 1942 and prices wm_yr_wk ≥ 11618 forbidden | Locked-proposed |
| 11 | Grain and join cardinality | Lock Design B §9 with AI3-m-01 wording ("many item-days per priced week; ≤ 1 price row per item-day") | Locked-proposed |
| 12 | Primary KPI and baseline | Lock Design B §10/§12: forward expectation at both prices; predicted current-price baseline; unrounded values for ranking, display rounding only | Locked-proposed |
| 13 | Guardrail ("about 10%") | Lock ρ̂ ≥ 0.90 required (reject if ρ̂ < 0.90, unrounded); twins 0.85 and 0.95; owner re-affirms "about 10%" → 0.90 at lock | Owner choice pending (OC-3) |
| 14 | Candidate construction — source and band | Lock observed own-item prices only, band [0.75 × P0, 1.25 × P0] inclusive in integer cents, weeks ≤ 11617, price > 0, P0 removed; twin ±20% band; band-expansion fallback dropped | Locked-proposed |
| 15 | Candidate construction — single-week event filter | Lock the single-week event filter extended to all four event_type_1 types; event_type_2 not used; audit n_candidates_event_filtered; disclosure 40.22% vs 47.23% | Locked-proposed |
| 16 | Candidate cap and ordering | Lock cap = 5, ordered by abs(ln(Pc/P0)) rounded to 10 decimals ascending, ties → lower price | Locked-proposed |
| 17 | Legal-change test and action assignment | Lock Design B §17.3–17.4 without condition 5; R base round(x, 2) on R̂(Pc) and R̂(P0) separately; legal requires rounded difference > 0; one action per universe item | Locked-proposed |
| 18 | Minimum-gain rule | Lock no minimum-gain rule in the judged rule; gain_below_half_mae is a diagnostic flag (AI3-M-09 definition) that never changes action or rank | Locked-proposed |
| 19 | Capacity, ranking, tie-break, membership-first, no-pad ("about 25") | Lock Design B §17.5 (N_CAP = 25 hard; membership-first; no pad; tie-break order); owner re-affirms "about 25" → 25 at lock | Owner choice pending (OC-4) |
| 20 | Segments | Lock Design B §13; HOUSEHOLD_2 published with its n; exploratory rates need ≥ 20 | Locked-proposed |
| 21 | Confounders | Lock Design B §14 plus the M-12 item-level proxy as the C10 treatment and the P04 Q3 disclosure under C1 | Locked-proposed |
| 22 | Missingness, anomaly, data quality | Lock Design B §15 with winsorization R quantile(type = 7) at 0.99 over positive training days (training target only); $0.01 prices retained, flagged and counted (n_price_0_01_weeks) | Locked-proposed |
| 23 | Model family, engine, recipe, determinism | Lock linear_reg(mode = "regression"), glmnet, mixture = 0.5, glmnet internal standardization off (recipe-side only), seed 20160522; fixed recipe order; no raw sell_price predictor; no item_id dummies; û = max(0, û_raw) | Locked-proposed |
| 24 | Features (allowed / forbidden), trailing anchoring, item-level proxy | Lock Design B allowed/forbidden lists and leakage rules, revised: origin-anchored trailing features (AI3-M-13); item_mean_log1p_units (AI3-M-12); NA-feature training rows dropped and counted | Locked-proposed |
| 25 | `n_snap_next_28_known` feature | Disputed in 06 (OD-2); resolved by 06 §F: dropped from the judged model and every twin; FX-SNAP-FWD retired | Locked-proposed (dropped) |
| 26 | Target and horizon aggregation | Lock training target = observed daily units at d ≤ origin (winsorized); Û(P) = sum of the 28 daily predictions d_1942–d_1969, each floored at 0 | Locked-proposed |
| 27 | Split, CV folds, penalty grid, training window | Lock training rows = all universe items' priced item-days with d ≤ origin; five contiguous d-blocks; grid 10^seq(−4, 1, length.out = 50); minimum mean held-out RMSE; ties → larger penalty; refit; penalty_selected and grid index audited | Locked-proposed |
| 28 | Backtest origin and acceptance | Lock Design B §16.3 with numbers: o = d_1913, horizon d_1914–d_1941, P0_bt = week 11613, re-anchored eligibility; A1 ≤ 0.40; A2 within [−0.20, +0.20]; A3 not binding; A4 0–25 valid; collapse → hold_ne incl. model-based unchanged; d_1885 stability only; U = 0 excluded and counted | Locked-proposed |
| 29 | Sensitivity twins (prespecified, diagnostic only) | Lock twins T1–T9; each reports package-membership overlap; none changes a judged action | Locked-proposed |
| 30 | Controlled SQL source contract | Lock Design B §20, deliver-and-quarantine; SALES_LONG carries wm_yr_wk attached on d; casts units → integer, sell_price → DECIMAL(10,2), wm_yr_wk → integer, d index → integer | Locked-proposed |
| 31 | SQL Source Gate requirements | Lock Design B §21 plus Dossier §9 additions with numeric pass conditions; any failure = Gate Fail | Locked-proposed |
| 32 | R-A / R-B judged-output contract | Lock Design B §22, revised field set (eligibility integers, conjunct flags, te6, audit fields); band_expanded dropped; separate candidate table | Locked-proposed |
| 33 | R-A / R-B independence | Lock Design B §22.4 + framework §19A: no shared judged code, objects, scored tables, lists, selected set or action table before first-pass freeze | Locked-proposed |
| 34 | R-A vs R-B reconciliation contract and tolerance | Lock Design B §23 plus exact equality on eligibility integers, flags, te6, candidate keys and audit counts; 0.05 units / $0.05 tolerances; penalty grid index diagnostic; any action, package, below-line or rank mismatch = fail; repair toward spec, never average | Locked-proposed |
| 35 | Known-case fixtures | Lock the Appendix B pack = Design B's 12 minus FX-UNCHANGED-SMALLGAIN plus the listed additions; freeze by path + SHA-256 before R-A/R-B start | Locked-proposed |
| 36 | Lineage | Lock Design B §24.1 with design_id = PRICEPOINT-001-S3-v1, fixture_pack_sha256, sql_extract_sha256, capacity_stance = hard_attention_budget on every judged export | Locked-proposed |
| 37 | Spec→builder translation packet | Lock Design B §24.3 extended so each decision-changing gate has its own line: clause cite → fixture IDs → R-A attestation → R-B attestation | Locked-proposed |
| 38 | Measurement-risk register | Lock register = 07_RISK_REGISTER.md | Locked-proposed |
| 39 | Week-window arithmetic (new) | Lock: every week window defined by calendar week ordinal, never integer subtraction on wm_yr_wk; fixture FX-WEEK-ORDINAL | Locked-proposed |

## 25.2 DC resolutions

| ID | Correction (06 §A) | Evidence | Consequence |
|---|---|---|---|
| DC-1 | `wm_yr_wk` is **not** a contiguous integer: weeks run 11101…11152, 11201…11252, 11301…11353, 11401…11452, 11501…11552, 11601…11621. Any "last N weeks" window must use calendar week ordinals, never `11617 − N`. | P04 header note + live check: integer range 11566–11617 contains 17 calendar weeks; 11513–11617 contains 57. | The last 52 calendar weeks ending at 11617 are 11518–11552 and 11601–11617. Adds fixture FX-WEEK-ORDINAL. |
| DC-2 | P02 column `chg2y_ge3` ("≥3 changes in last 104 weeks" = 30 items) actually measured the last **57** weeks (`wk ≥ 11513`). True last-104-calendar-week count is **232** (32/96/61/24/19). | P04 Q5 (`chk_lit11513_ge3` reproduces 30; `chg104_ge3` = 232). | AI2-F10 and the AI2 cross-review TE2 rationale ("n=30 would empty the review") rest on the error. The lifetime `n_price_changes ≥ 3` resolution still stands (it is chosen for T010 "at least a few times in the history", not because the recent rule is empty). |
| DC-3 | The "~200–300 eligible items" figure is **not** a stakeholder statement. No T000–T040 statement gives an eligible-item target. It comes from the owner's own project data briefing ("CA_1 FOODS_1+HOUSEHOLD_1 about 748 items exceeds intended ~200–300"). The P02 NOTES sentence "stakeholder's ~200–300 item intent" overstated it. (The coordinator could not locate the briefing text inside the Stage 3 files; /workspace/pricepoint was not opened.) | DIP §A (T000–T040 verbatim); AI2-F15; AI3-M-11 repeated the gloss. | Treated as an **owner-side scope preference to confirm at lock**, not a Start/Framing lock. AI2-F15 accepted. |
| DC-4 | AI3-B-05 cites a fixture "FX-HUNG" in Design B §24.2. No such fixture exists; Design B §24.2 has 12 fixtures (listed in Appendix B). | Design B §24.2. | Citation error only; no design effect. |

## 25.3 §E resolutions

06 §E, "Deviations from the coordinator's intended resolutions", verbatim:

1. Current price (row 9): locked as intended, but the stated premise "all three AIs recommend 11617" is wrong. AI1-F2 asked for an owner decision. The lock rests on the week definition and the 5-item impact.
2. Eligibility (row 6): E_A recommended as intended. Profile 04 sizes it at 363, above the owner-side 200–300 preference; E_A ∧ nd ≥ 4 (274) is the profiled in-range alternative. priced_weeks ≥ 52 does not bind for E_A.
3. TE6 (row 8): added as Open. The intended eligibility had no test for T040's third prong.
4. Candidate band (row 14): ±25% chosen by the stated criterion. Design B's band-expansion fallback dropped (applies to 1 item; would exceed the observed range).
5. Event filter (row 15): extended to four types as intended, but with a disclosure. P04 shows single-week prices are not concentrated in event weeks (40.22% vs 47.23% baseline).
6. n_snap_next_28 (row 25): marked Disputed rather than "exact formula". The calendar ends at d_1969.
7. Recent-change evidence (DC-2): the "30 items / would empty the review" argument is withdrawn (true figure 232). The resolution is unchanged.
8. Coordinator-specified numbers added for concreteness (subject to audit): penalty grid 10^seq(−4, 1, length.out = 50) with ties → larger penalty; fold rule ceiling(5·d/D); cap distance rounded to 10 decimals, tie → lower price; cent rounding via R `round(x, 2)`; winsorization quantile type 7; backtest collapse applies to model-based unchanged as well (Design B §16.3 last sentence).

## 25.4 §F Coordinator addendum

06 §F (2026-09-25, before the candidate), verbatim:

- OD-2 resolved, status Lock (methodological principle, framework §25 "Resolve through statistical principle"): `n_snap_next_28_known` is DROPPED from the judged model and from every twin. Reason: raw_calendar ends at d_1969, so the forward 28-day count is not computable for 27 of 28 horizon days; a feature whose scoring-time definition differs from its training-time definition is a train/score mismatch and a reconciliation hazard. SNAP enters only as same-day `snap_CA` and the `log_sell_price:snap_CA` interaction. FX-SNAP-FWD is retired. OD-2 is no longer Open/Disputed.
- OD-1 (TE6) stays Open for the final audits with the row 8 recommendation; if the audits do not converge it becomes an owner choice at the lock.
- Profile 02 erratum recorded in profile/design_profile_02_ERRATUM.md (104-week column spanned 57 real weeks; true count 232).

## 25.5 AI1 objections

No AI1 objection is outstanding. The final-audit objections to 06 (AI1-DT-01, FX-CENT-ROUND setup; AI2-MA-05, proxy interpretation) are resolved in 09 and applied in v5 (§24.1, §17A.5).

## 25.6 Final audit record

Final audits (framework §27): AI1 (decision trace), AI2 (methodology) and AI3 (SQL→R contract) each returned "Pass with required revisions". The coordinator synthesis (09_FINAL_AUDIT_SYNTHESIS.md) decided every item on evidence, with no vote:
* RES-01…RES-18: 15 accepted as written, 2 amended (RES-12, RES-17), RES-09 converted to OC-5.
* 32 new findings: 29 accepted, 3 rejected.

OD-1 did not converge and is now owner choice OC-5 (06 §F bullet 2). OD-2 was resolved by 06 §F.

---

# 26. Assumptions, open questions and accepted limitations

## 26.1 Open question

**Status: Locked-proposed**
**Origin: [MC] 06 §D; 06 §F; 09 §4–§5**

No Open design item remains:
* OD-1 (TE6) became owner choice OC-5 because the final audits did not converge (06 §F bullet 2).
* OD-2 (`n_snap_next_28_known`) was resolved by 06 §F (dropped).

---

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


## 26.3 Accepted limitations

The design estimates expected outcomes under the locked model.

It does not prove causal price elasticity.

It does not guarantee revenue improvement.

The model uses only available internal history:

* daily unit sales;
* historical shelf prices;
* calendar features;
* SNAP calendar information.

The design does not include:

* competitor pricing;
* inventory;
* cost;
* margin.

Revenue remains the defended KPI because those inputs are unavailable.

Historical pricing contains predictive information but is not a guarantee that a future pilot will reproduce the modeled expectation.

The output may state:

"Under the locked model this is the 28-day expectation to pilot-test; it is not a guarantee and not a causal effect."

It may not state:

"The price change will cause this result."

---

# 27. Stage 4 handoff and lock approval

## 27.1 Lock status table

| Requirement | Status |
| ----------- | ------ |
| Human approval | NOT given |
| Design Gate | NOT passed |
| Final audits | 3 of 3 Pass with required revisions (applied in v5) |
| Open items | 0 |
| Owner-choice items | 5 (OC-1…OC-5) |
| Disputed items | 0 |

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

## 27.4 Final candidate status

**Status: Candidate complete pending Design Gate review.**

Candidate v5 contains:

* corrected measurement contract;
* resolved §F SNAP treatment;
* deterministic decision-rule pipeline;
* Mode A predictive contract;
* frozen fixture requirements;
* SQL/R boundary;
* reconciliation standard;
* builder translation packet;
* risk register;
* Stage 4 handoff requirements.
* final-audit revisions (09_FINAL_AUDIT_SYNTHESIS.md).

END OF CANDIDATE v5

Candidate complete: 0 Open, 5 Owner-choice items.
