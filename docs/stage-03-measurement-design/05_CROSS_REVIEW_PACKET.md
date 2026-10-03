# 05 CROSS-REVIEW PACKET — PRICEPOINT-001 Stage 3 (information barriers removed)

Contents, in order: (A) Design A by AI 1, (B) Design B by AI 2, (C) Data and Risk Dossier by AI 3, (D) targeted profiling results 01 and 02 (read-only aggregate SQL run by the coordinator under framework §25). All three first passes were frozen and SHA-256 hashed before this packet was built; they are reproduced verbatim.

Frozen hashes:
    294ac79f42f41b8bac6cbda2b04db63183b6cc8ec5192bf1f8acfeaf9268c215  reviews/ai1_designA_raw.txt
    ba9362db323fbde2700f86e1a4a7bbf5514a207c18338b0ecb18212759ffa588  ai2_designB_raw.txt
    ff3af86bc2f3135bf9afa404324ff1e5b111870a83c1825681779b3760f9b61a  ai2_designB_file.md
    # AI2 Grok Expert chat: https://grok.com/c/9eac0805-230d-4c14-9b55-f89ff710e86f ; ai2_designB_file.md = downloaded artifact 03_AI2_INDEPENDENT_COUNTER_DESIGN.md (Design B of record)
    cee5d4c574382d971af82f16ba9c4b3857e809bed9534613b51da0d959dd3e67  reviews/ai3_dossier_raw.txt
    # AI3 DeepSeek DeepThink ON Search OFF chat: https://chat.deepseek.com/a/chat/s/9c2e9a19-a845-4bcd-9d16-e7922deb90fd ; first passes frozen 2026-09-25T04:19:09-05:00

---

# PART A — DESIGN A (AI 1, verbatim)

Prepared from the locked AI1 prompt, the frozen Design Input Package, and the governing Stage 3 framework. The task is to produce an independent Design A without changing the approved decision/question, and to define the measurement contract before SQL/R execution.  The design below follows the required 27-section structure. 

# 02_AI1_PRIMARY_MEASUREMENT_DESIGN

## 1. Document purpose and version

**Status:** Locked-proposed
**Origin:** Locked framework requirement; methodological choice

Purpose: Define the Stage 3 measurement contract for PRICEPOINT-001 before Stage 4 SQL delivery and independent R-A/R-B implementation.

This design converts the locked pricing decision into:

* measurable hypotheses,
* population rules,
* KPI definitions,
* predictive contract,
* decision rules,
* SQL→R handoff,
* reconciliation requirements.

No production SQL or production R is included.

---

# 2. Approved decision statement

**Status:** Locked-proposed
**Origin:** Locked Stage 1 statement

Morgan Lee, Pricing & Revenue Manager, must determine what recommendation to bring to the store general manager for products meeting the review criteria in the California pilot store’s everyday grocery and household aisles:

* specific pilot shelf price increase,
* specific pilot shelf price cut,
* leave shelf price unchanged,
* or hold — not enough evidence.

The recommendation should identify the specific pilot price expected to produce the strongest trusted product revenue result:

Revenue = units sold × shelf price

over the next 28 days compared with current price, while rejecting changes expected to reduce units by more than about 10%.

The output is a ranked list:

* up to about 25 actual raise/cut recommendations enter the GM package;
* additional qualifying opportunities appear below the line;
* no padding occurs if fewer qualify.

Approved changes are pilots, not guarantees.

---

# 3. Locked analytical question

**Status:** Locked-proposed
**Origin:** Locked Framing statement

For products meeting the review criteria in the California pilot store’s everyday grocery and household aisles, which specific pilot shelf prices should Morgan recommend for the next 28-day review cycle to produce the strongest trusted expected product revenue compared with the current price, without recommending a change expected to reduce units by more than about 10%; which products should remain unchanged or be classified as hold — not enough evidence; and which trusted opportunities rank into the current-cycle GM package of up to about 25 actual price changes?

---

# 4. Stakeholder constraints and exceptions

| Element                                  | Status          | Origin                  |
| ---------------------------------------- | --------------- | ----------------------- |
| Revenue objective                        | Locked-proposed | Stakeholder requirement |
| No margin/cost optimization              | Locked-proposed | Stakeholder requirement |
| Unit loss guardrail                      | Locked-proposed | Stakeholder requirement |
| Four-week review                         | Locked-proposed | Stakeholder requirement |
| Pilot interpretation                     | Locked-proposed | Stakeholder requirement |
| No padding                               | Locked-proposed | Stakeholder requirement |
| Holds visible but not capacity-consuming | Locked-proposed | Stakeholder requirement |

---

# 5. Intended conclusion type and ceiling

**Status:** Locked-proposed
**Origin:** Methodological choice + stakeholder constraint

Conclusion type:

**Predictive / expected-value recommendation**

Allowed claim:

* "Historical evidence supports this as the expected pilot outcome."

Not allowed:

* causal claim that price change will definitely create the observed outcome.

Causal ceiling:
**Predictive-associational.**

---

# 6. Hypothesis hierarchy

## Primary business hypothesis

**Status:** Proposed
**Origin:** Methodological choice

Some products have enough historical price variation and sales evidence to support trusted pilot-price recommendations.

## Mechanism hypothesis

**Status:** Proposed

Historical responses to price variation contain useful information for estimating future 28-day revenue under candidate prices.

## Observable implication

**Status:** Proposed

Trusted candidates should show:

* historical price movement,
* sufficient sales activity,
* stable enough forward expectation,
* expected revenue improvement.

## Counterevidence

**Status:** Proposed

The hypothesis weakens when:

* insufficient price history exists,
* sales are too sparse,
* predictions are unstable,
* candidate price effects cannot be distinguished from uncertainty.

---

# 7. Population and eligibility contract

## Target population

**Status:** Locked-proposed
**Origin:** Stakeholder requirement

Products in:

* CA_1,
* everyday grocery and household aisles.

## Observable population

**Status:** Verified
**Origin:** Data package

CA_1 products available in M5 source tables.

## Department mapping

**Status:** Proposed

Initial scope:

Include:

* FOODS_1
* FOODS_2
* FOODS_3
* HOUSEHOLD_1
* HOUSEHOLD_2

Reason:
These represent grocery/household scope.

Exclude:

* HOBBIES departments.

## Eligibility rule

**Status:** Proposed

A product qualifies for modeling if:

1. Has price history before decision date.
2. Has at least a minimum number of observed price states.
3. Has sufficient sales observations.

Exact thresholds:

**Status:** Open

Required Stage 3 validation:
Profile distributions before locking.

---

# 8. Time-window and date contract

## Decision date

**Status:** Verified

2016-05-22 (d_1941).

## Forecast horizon

**Status:** Locked-proposed

28 days:
d_1942–d_1969.

## Current price definition

**Status:** Proposed

Current price =
latest valid weekly sell price available at decision date.

Missing price:
not zero.

## Leakage rule

**Status:** Locked-proposed

No post-decision prices or sales may enter features.

Known issue:
raw_sell_prices contains horizon weeks; those are forbidden except current decision-date price.

---

# 9. Grain and join-cardinality contract

## Source grain

**Status:** Verified

Sales:
product-store series.

Prices:
store-item-week.

Calendar:
day.

## SQL delivery grain

**Status:** Proposed

Deliver source evidence without final judgments.

## Eligibility grain

**Status:** Locked-proposed

product × store.

## Decision grain

**Status:** Locked-proposed

one product-store recommendation.

## Join rules

**Status:** Proposed

Expected:

* one-to-one calendar date joins,
* many-to-one weekly calendar mapping,
* one-to-one product-store-week price keys.

---

# 10. Primary KPI contract

## Primary KPI

**Expected 28-day revenue uplift**

Status:
Locked-proposed

Formula:

Expected revenue at candidate price
minus
Expected revenue at current price

## Components

Expected units:
predicted units over 28-day horizon.

Revenue:
expected units × shelf price.

Precision:
continuous internal values; display rounding only.

---

# 11. Guardrail, diagnostic, audit, sensitivity metrics

## Guardrail

**Unit change percentage**

Status:
Locked-proposed

Reject if expected units decline > about 10%.

## Diagnostics

Status:
Proposed

* predicted units,
* predicted revenue,
* price delta,
* historical price count,
* sales volume indicators.

## Audit

Status:
Proposed

* eligible count,
* excluded count,
* hold count,
* below-line count.

## Sensitivity

Status:
Proposed

Alternative:
candidate price ranges and model stability checks.

---

# 12. Comparison and baseline contract

## Baseline

**Status:** Locked-proposed

Current price at decision date.

## Candidate comparison

**Status:** Locked-proposed

Each candidate price compared against current price.

No peer baseline required.

---

# 13. Segment contract

## Required segments

Status:
Proposed

Department:

* grocery department
* household department

Purpose:
identify whether recommendation behavior differs.

## Minimum sizes

Status:
Open

Require profiling.

---

# 14. Confounder and competing-explanation ledger

| Risk                   | Status   | Treatment                 |
| ---------------------- | -------- | ------------------------- |
| Seasonality            | Proposed | Calendar features         |
| Holidays/events        | Proposed | Calendar features         |
| SNAP effects           | Proposed | SNAP features             |
| Product demand changes | Proposed | Historical sales features |
| Price-selection bias   | Open     | Sensitivity/disclosure    |

---

# 15. Missingness, anomaly, and data-quality rules

## Missing prices

Status:
Locked-proposed

Never treat as zero.

## Missing sales

Status:
Proposed

Retain zero sales as observed demand, not stockout.

## Duplicate keys

Status:
Proposed

Fail Source Gate if unexpected.

## Invalid dates

Status:
Proposed

Reject or investigate.

---

# 16. Sample-size and uncertainty rules

Minimum evidence thresholds:

Status:
Open

Will be determined from profiling.

Required:

* eligibility stability,
* prediction stability,
* ranking stability.

No threshold becomes an SLA.

---

# 17. Decision rules and capacity constraints

## Action categories

Status:
Locked-proposed

1. Specific price increase.
2. Specific price cut.
3. Unchanged.
4. Hold — not enough evidence.

## Trusted gate

Status:
Proposed

A product is trusted only if:

* price moved historically,
* product sells enough,
* forward expectation is not effectively a guess.

Trust is a gate, not a ranking weight.

## Capacity

Status:
Locked-proposed

capacity_stance:

`hard_attention_budget`

Capacity unit:

Actual raise/cut recommendations prepared for GM review.

Rules:

* membership first,
* rank trusted qualifiers,
* select top ~25,
* no padding.

---

# 17A. Predictive analytics / ML mode

## ml_mode

**Status:** Locked-proposed
**Value:** A — Judged predictive contract

Reason:
Model output changes recommendation actions and ranking.

---

## Mode A lock fields

### Prediction unit

Status:
Locked-proposed

product-store.

### Target

Status:
Proposed

Future daily units during 28-day horizon.

### Allowed features

Status:
Proposed

* historical sales,
* historical prices,
* current price,
* calendar,
* events,
* SNAP indicators,
* product hierarchy.

### Forbidden features

Status:
Locked-proposed

* future prices,
* horizon sales,
* inventory,
* competitor data,
* cost data.

### Split

Status:
Proposed

Temporal split only.

Training:
history before pseudo-decision date.

### Model family

Status:
Proposed

Parsnip model specification.

Candidate:
regularized regression or tree-based regression.

Exact family:
deferred pending validation.

### Evaluation metrics

Status:
Proposed

* unit prediction error,
* revenue error,
* ranking stability.

### Threshold→action mapping

Status:
Locked-proposed

1. Generate candidate prices.
2. Predict units.
3. Compute revenue.
4. Apply unit guardrail.
5. Rank trusted gains.

### Reconciliation fields

Status:
Proposed

Required:

* .pred units,
* predicted revenue,
* action,
* selected status.

### Fixtures

Status:
Open

Need frozen known cases.

---

# 18. Measurement-risk register

| Risk                 | Impact             | Control         |
| -------------------- | ------------------ | --------------- |
| Look-ahead leakage   | Invalid prediction | temporal cutoff |
| Sparse products      | False confidence   | trust gate      |
| Price-selection bias | Misinterpretation  | disclose        |
| Model instability    | Ranking changes    | validation      |
| Join errors          | Wrong evidence     | Source Gate     |

---

# 19. Non-executable SQL→R implementation blueprint

SQL delivers:

* raw sales evidence,
* price evidence,
* calendar evidence,
* keys,
* lineage fields.

SQL may:

* mechanically join source tables.

SQL may not:

* calculate eligibility,
* generate predictions,
* rank products,
* assign actions.

R-A/R-B independently:

* construct analytical dataset,
* apply eligibility,
* train model,
* generate predictions,
* assign actions.

---

# 20. Controlled SQL source contract

## Tables

Verified:

* raw_sales_evaluation
* raw_sell_prices
* raw_calendar

## Required fields

Status:
Proposed

Need:
IDs,
sales history,
prices,
calendar variables,
lineage identifiers.

## Forbidden SQL transformations

Status:
Locked-proposed

No:

* final action,
* ranking,
* prediction,
* eligibility decision.

---

# 21. SQL Source Gate handoff requirements

Stage 4 must verify:

* row coverage,
* key uniqueness,
* price-key integrity,
* calendar coverage,
* critical-field preservation,
* lineage identity,
* no post-decision leakage.

---

# 22. R-A / R-B judged-output contract

Both outputs must contain:

* product-store key,
* eligibility status,
* current price,
* candidate price,
* predicted units,
* predicted revenue,
* guardrail result,
* trust status,
* action,
* rank,
* capacity status,
* lineage fields.

---

# 23. R-A versus R-B exact reconciliation contract

Compare:

* universe coverage,
* keys,
* eligibility,
* predictions,
* actions,
* selected package,
* rank ordering,
* audit fields.

Continuous tolerance:

Status:
Open

Must be locked before execution.

---

# 24. Fixture and lineage contract

Fixtures:

Status:
Open

Required before builders run.

Must include:

* known product,
* expected trust outcome,
* expected action,
* expected capacity behavior.

Lineage:

Required:

* snapshot ID,
* source version,
* extraction boundary.

---

# 25. Multi-AI review and resolution record

Status:
Deferred

AI 1 independent design only.

No AI2/AI3 revisions incorporated.

---

# 26. Assumptions, open questions, accepted limitations

## Assumptions

* Historical patterns can inform pilot expectations.
* Price changes are not guaranteed causal effects.

## Open questions

* Exact eligibility thresholds.
* Candidate price generation algorithm.
* Model family selection.
* Minimum gain rule.
* Segment thresholds.
* Continuous reconciliation tolerance.

## Limitations

No:

* costs,
* inventory,
* competitor prices.

---

# 27. Stage 4 handoff and lock approval

## Handoff requirements

Before Stage 4:

1. Freeze this design.
2. Freeze fixtures.
3. Freeze Mode A fields.
4. Freeze SQL source contract.
5. Freeze reconciliation contract.

Stage 4 workflow:

SQL source delivery → SQL Source Gate → R-A/R-B independent judged implementations → exact reconciliation.

Human analyst approval required before execution.

**Design A status: Proposed measurement contract pending Design Gate review.**

---

# PART B — DESIGN B (AI 2, verbatim artifact 03_AI2_INDEPENDENT_COUNTER_DESIGN.md)

# 03_AI2_INDEPENDENT_COUNTER_DESIGN

**Project:** PRICEPOINT-001  
**Stage:** 3 — Measurement Design  
**Role:** AI 2, Independent Counter-Designer and Methodological Critic  
**Design ID:** Design B  
**Version:** B-v1  
**Date:** 2026-09-25  
**Input freeze:** DIP-v1 (2026-09-25) + framework workflow commit `f388be8c2379ac6a8959516b486af31c99423bb0`  
**Independence statement:** This design was constructed from the Design Input Package and the governing framework only. It does not assume the existence of Design A and does not edit another design.

---

## 1. Document purpose and version

**Status:** Locked for this artifact.  
**Origin:** Framework §31 required structure; AI2 prompt (PRICEPOINT-001 Stage 3).

This document is Design B: an independent, complete measurement contract for the locked Morgan Lee pricing-review decision. Its job is to specify what would count as evidence *before* any production SQL or R is written.

Design B is not disagreement for variety. Where it makes a choice, it states (a) the risk controlled and (b) the tradeoff accepted. Material elements carry a status from the framework vocabulary (Locked / Proposed / Verified / Provisional / Disputed / Open / Infeasible / Deferred / Rejected) and an origin (stakeholder requirement, Start/Framing lock, verified data fact, methodological choice, provisional assumption, or targeted profiling gap).

**ml_mode (preview; full lock in §17A):** `A` — judged predictive contract. Expected revenue at current vs candidate price is produced by a locked parsnip model. Those predictions change actions and the capacity ranking before Validation freeze.

**What this design will not do:** rewrite the approved decision or question; invent fields, counts, or distributions; write production SQL or production R; treat Mode B or Mode None as available (project requirement + use test); claim causality for a pilot price.

---

## 2. Approved decision statement

**Status:** Locked.  
**Origin:** Stage 1 approved decision statement (DIP §A). Unchanged.

> Morgan Lee, Pricing & Revenue Manager, must determine what recommendation to bring to the store general manager for products meeting the review criteria at the California pilot store’s everyday grocery and household aisles: a specific pilot shelf price increase, a specific pilot shelf price cut, leaving the shelf price unchanged, or classifying the product as “hold — not enough evidence” when the available evidence is not solid. The recommendation should identify the specific pilot price expected to produce the strongest trusted product revenue result (units sold × shelf price) over the next 28 days compared with the current price, while rejecting changes expected to reduce units by more than about 10%. The review occurs on a four-week cycle, with the price decision holding until the next review. The recommendation uses only information available at the end of the most recent history period: daily unit sales, weekly shelf prices, and calendar information including holidays, events, and SNAP benefit days. The output is a ranked list: the strongest trusted price-change opportunities, based on the biggest revenue gain that is trusted, form the GM package up to about 25 actual price changes. If fewer qualify, the list is not padded. If more qualify, additional qualifying opportunities remain below the line as next in line and are not included in that cycle’s package. Holds and hold — not enough evidence outcomes remain visible and do not consume the price-change capacity. Approved changes are pilots, and historical patterns should be presented as expectations to test rather than guarantees.

---

## 3. Locked analytical question

**Status:** Locked.  
**Origin:** Stage 2, C2 (DIP §A). Unchanged.

> For products meeting the review criteria in the California pilot store’s everyday grocery and household aisles, which specific pilot shelf prices should Morgan recommend for the next 28-day review cycle to produce the strongest trusted expected product revenue (units sold × shelf price) compared with the current price, without recommending a change expected to reduce units by more than about 10%; which products should instead remain unchanged or be classified as “hold — not enough evidence”; and which trusted price-change opportunities rank into the current-cycle GM package of up to about 25 actual price changes, with any additional qualifying opportunities listed below the line?

---

## 4. Stakeholder constraints and exceptions

**Status:** Locked unless noted.  
**Origin:** DIP §A constraints + verbatim T002–T040.

| Constraint | Operational meaning in Design B | Status | Origin |
|---|---|---|---|
| Decision owner | Morgan recommends; GM signs off. Design produces the recommendation package, not a live price write. | Locked | Stakeholder |
| Actions per product | Exactly one of: specific pilot increase; specific pilot cut; leave unchanged; hold — not enough evidence. | Locked | Stakeholder |
| Outcome | Expected product revenue = expected units × shelf price over 28 days. No cost/margin exists. | Locked | Stakeholder + verified absence of cost |
| Unit guardrail | Reject any change whose expected 28-day units are more than about 10% below expected units at the current price. A cut that raises units is allowed if revenue is not expected to fall (see §17). | Locked intent; Proposed operationalization in §17 | T006 |
| Capacity | `capacity_stance = hard_attention_budget`. Capacity unit = actual raise or cut recommendations per cycle, about 25. Holds do not consume slots. No padding. Extra qualifiers listed below the line. | Locked stance; Proposed operationalization = 25 exactly | T018, T020, T024 |
| Trust is a gate, not a weight | Untrusted → hold — not enough evidence. Among trusted, rank by expected revenue gain. | Locked | T016, T038, T040 |
| Eligibility principle | Exclude never-moved and barely-selling items. “At least a few times.” Cutoffs are analyst-set and disclosed. Prefer smaller trusted list. | Locked principle; Provisional cutoffs in §7 | T008, T010 |
| Grain / scope | Product at one store. CA pilot store. Everyday grocery and household aisles. Department mapping is analyst-proposed. | Locked grain/store; Proposed depts in §7 | T008 |
| Information set | Only what is known at end of last history day: daily units, weekly shelf prices, calendar (holidays, events, SNAP). No competitor prices, inventory, or cost. | Locked | T014 |
| Decision timing | Treat review as occurring at end of d_1941 = 2016-05-22. Decision holds 28 days. | Locked | T012; verified d_1941 date |
| Output form | Specific pilot shelf price; expected units and revenue at that price and at current; ranked GM package + below-the-line; holds listed. | Locked | T024, T034 |
| Interpretation ceiling | Pilots; historical patterns are expectations to test, not guarantees. | Locked | T026 |
| No stakeholder min-gain | Any minimum-gain rule is an analyst choice and must be disclosed. | Locked | T040 |
| Project tooling | Predictive model in R with tidyverse + parsnip. Mode A expected because model values change judged action and capacity ranking. | Locked | Project requirement + framework FORWARD use test |

**Exceptions:** None recorded beyond “hold — not enough evidence” as a legitimate action and the unit guardrail. No product-level policy exclusions (regulatory, private-label contract, etc.) exist in the packet.

---

## 5. Intended conclusion type and ceiling

**Status:** Locked.  
**Origin:** Methodological choice required by framework §14 causal ceiling + T026.

| Claim type | Allowed? |
|---|---|
| Descriptive (what sold at what price in history) | Yes, as diagnostics only |
| Comparative (candidate vs current *under the model*) | Yes — this is the decision comparison |
| Associational | Yes, and this is the honest ceiling of the price coefficient |
| Predictive | Yes — primary use of the model: 28-day expected units at a specified price and known calendar |
| Causal (“this price *will cause* this revenue”) | **No.** Ceiling is predictive / associational. Pilots test the expectation. |

**Design B controlling sentence:** The package answers “which specific pilot prices are expected, under a locked demand model trained only on pre-decision information, to raise trusted 28-day item revenue relative to the current price without an expected unit decline worse than the guardrail?” It does not answer “what is the causal price elasticity after shutting down promotions, SNAP timing, and category substitution?”

**Risk controlled:** over-claiming causality to a GM.  
**Tradeoff:** a well-specified predictive comparison can still be wrong if historical price moves were bundled with unobserved promotions.

---

## 6. Hypothesis hierarchy

**Status:** Proposed (methodological).  
**Origin:** Framework §8; locked question.

### 6.1 Primary business hypothesis

A non-empty subset of eligible CA_1 everyday grocery and household items has at least one previously observed alternative shelf price that, given the known next-28-day calendar, is predicted to produce higher item revenue than the current shelf price without an expected unit decline of more than about 10%, and the trusted members of that subset can be ranked into a GM package of at most about 25 actual changes.

### 6.2 Mechanism / rationale (not established)

Shelf price and quantity sold have historically co-moved. If some of that co-movement is a usable demand slope rather than pure confounding, then moving an item to another price it has already borne may raise revenue. SNAP days, holidays, and sporting/religious events also move grocery volume in this chain; any usable slope must be separated from those calendar effects as far as the data allow.

This is a rationale, not a proven mechanism.

### 6.3 Primary analytical hypothesis

For eligible item-store units, a regularized log-price demand model that is identified primarily from *within-item* historical price variation, after calendar adjustment, will assign 28-day expected units at an observed candidate price that differ from expected units at the current price by enough to change the revenue ranking, and those differences will be directionally confirmed in a pre-decision backtest window.

### 6.4 Observable implications

If the hypothesis is useful:

1. A non-trivial share of eligible items will have at least one candidate price with predicted revenue > predicted current-price revenue and unit ratio ≥ 0.90.
2. Backtested 28-day unit totals at the *actual* then-current price will not be wildly miscalibrated relative to realized units (acceptance in §17 / §16).
3. Items that fail the trust gate will not dominate the top of a raw-gain list (the gate binds).
4. Recommended raises will not be systematically the items whose only historical “high price” weeks were holiday/SNAP weeks (confounder diagnostic).

### 6.5 Counterevidence (falsifiers)

The design is weakened or defeated if:

- After the trust gate, zero or near-zero items pass the revenue-and-guardrail test in backtest *and* live scoring (hypothesis of usable opportunities fails).
- Backtest realized 28-day revenue at the model-chosen candidate (where the actual historical price happened to equal that candidate) is not better, on average, than realized revenue at other observed prices, after calendar adjustment.
- Predicted unit ratios at alternative prices are almost always ≈ 1 (model finds no price response once calendar and item level are included) — then almost everything should be “leave unchanged” or “hold — not enough evidence,” not a long raise/cut list.
- Recommended candidates cluster entirely in weeks that also contain events/SNAP, and a no-price calendar-only model explains the same unit variation (price coefficient is a stand-in for promotions/events).

### 6.6 Secondary / exploratory (not confirmatory)

- Department differences in predicted elasticity.
- SNAP-day share of an item’s volume as a modifier of price response.
- Asymmetric response to historical raises vs cuts.

These may be described after the judged list is frozen. They must not retune eligibility, the trust gate, or ranking.

### 6.7 What is not a statistical NHST exercise

No p-value is the decision rule. Capacity ranking is by expected trusted revenue gain. Optional coefficient-level inference on the pooled log-price term is a diagnostic only.

---

## 7. Population and eligibility contract

**Status:** Mix of Locked / Proposed / Provisional / Open as tagged.  
**Origin:** T008–T010, T016; verified CA_1 / department profile; methodological.

### 7.1 Target vs observable population

| Layer | Definition | Status |
|---|---|---|
| Target | Everyday grocery and household items at the California pilot store that Morgan could actually reprice in the next four-week review. | Locked (business) |
| Observable | Item-store series in `raw_sales_evaluation` with `store_id = 'CA_1'` and `dept_id` in the locked department set, with weekly prices in `raw_sell_prices` and calendar coverage through the horizon. | Verified tables exist |
| Gap | No inventory, no stockout flag, no competitor price, no cost, no official “everyday aisle” flag, no promotion label. Zeros are not stockouts. Leading zeros may precede listing. HOBBIES exist at CA_1 but are outside the aisle language. | Verified limitations |

### 7.2 Department mapping (analyst proposal)

**Proposed mapping (Design B):**

`dept_id ∈ {FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2}`

**Exclude:** `HOBBIES_1`, `HOBBIES_2`, all non-CA_1 stores, all other states.

**Why this mapping:** The locked language is “everyday grocery and household aisles.” FOODS_* is the grocery mapping available in M5; HOUSEHOLD_* is household. HOBBIES are present at CA_1 (416 + 149 items) but are not grocery/household. Stakeholder invited a proposal and did not name hobbies.

**Risk controlled:** silent inclusion of hobby items that Morgan did not ask to review; silent exclusion of a grocery department without a reason.  
**Tradeoff:** HOUSEHOLD_2 has few items with 4+ distinct prices (profile: 38). A trust-first alternative would drop HOUSEHOLD_2 and/or FOODS_1 to raise average price-history density. Design B keeps them in the *universe* and lets the trust gate drop thin items, so exclusion is item-level and auditable rather than a silent department cut.

**Profiled support (verified):** CA_1 item counts and price-movement density by dept are in DIP §B. Bounded extract of 3–5 departments is feasible.

### 7.3 Inclusion rules (applied in R, not SQL)

An item at CA_1 is **in the analytical universe** if all of the following hold.

| Rule ID | Rule | Status | Origin |
|---|---|---|---|
| U1 | `store_id = 'CA_1'` | Locked | Stakeholder pilot + candidate mapping |
| U2 | `dept_id` in the five-department set above | Proposed | Analyst mapping |
| U3 | Sales series exists with `JSON_LENGTH(sales_history) = 1941` | Verified fact for all rows | Profile |
| U4 | A sell_price exists for the current-price week defined in §8 | Verified: every CA_1 item has week 11616 and 11617 | Profile |
| U5 | First priced week is on or before the day 364 days before the decision date (one year of price opportunity). Exact first-week cutoff is computed from calendar, not invented. | Provisional | Survivor / late-listing control |

Universe includes items that later fail the trust gate. Holds must remain visible (T020). Membership-first requires the full universe of in-scope items, not only qualifiers.

### 7.4 Eligibility for a *price-change recommendation* (trust-eligible)

Trust-eligible is stricter than universe membership. An item is trust-eligible only if all of TE1–TE6 hold at the decision date using only pre-decision information.

| Rule ID | Rule | Status | Rationale / risk / tradeoff |
|---|---|---|---|
| TE1 | Count of distinct `sell_price` values at CA_1 for weeks whose Friday (week end) is on or before d_1941, using weeks with a price row, is **≥ 4**. | Provisional | “At least a few times.” Profile already publishes 4+ distinct-price counts by dept. Controls never-moved and once-moved items. Tradeoff: drops items with 2–3 levels that might still be informative; prefer smaller trusted list (T010, T016). |
| TE2 | Count of week-to-week *changes* (contiguous priced weeks, `sell_price_t ≠ sell_price_{t-1}`) with the later week ending on or before d_1941 is **≥ 3**. | Provisional | Distinct levels can be two old prices plus a recent reset. Changes measure actual movement. Tradeoff: two-level promo toggling may pass TE1 and fail TE2 or vice versa; both are required. |
| TE3 | In the last 52 complete Walmart weeks ending on or before the current-price week, at least **26 weeks** have weekly units > 0. | Provisional | “Sells steadily enough that a change would show up.” Tradeoff: seasonal items with long zero stretches look thin even if annual volume is large. |
| TE4 | Total units over those 52 weeks ≥ **L**, where L is **Open pending profiling** of the CA_1 52-week unit distribution in the five departments. Working placeholder for sensitivity, not a lock: L = 52 (average ≥ 1 unit/week). | Open / Provisional placeholder | Do not invent a distribution. See targeted profiling Q1–Q3. |
| TE5 | At least one candidate price in the candidate set (§17) has been *observed* as `sell_price` for this item-store in some pre-decision week. | Proposed (Design B distinctive) | Controls extrapolation to never-charged prices. Tradeoff: cannot recommend a brand-new price point; pilots stay inside the item’s historical price set. |
| TE6 | Model-evidence gate (§17A / §16): the item’s backtest 28-day absolute percent error at the then-current price is below the locked error cap **or** the item is in the lower error half of its department on that backtest. Items with no usable backtest slice fail TE6. | Proposed | “Forward four-week expectation is not a guess” (T040). Tradeoff: a one-window error cap is noisy; department-relative cap is the mitigation. |

**Failed TE\* → action = `hold — not enough evidence`.** These items stay in the universe listing and do not consume capacity.

### 7.5 Exclusions (applied in R; each produces an audit count)

| Excl ID | Exclusion | Stage | Reason | Expected effect |
|---|---|---|---|---|
| X1 | Non-CA_1 | Envelope + R | Out of pilot scope | Large row drop |
| X2 | HOBBIES_* and any dept outside the five | R | Not everyday grocery/household | Drops 416+149 CA_1 hobby items (profiled) |
| X3 | Item lacks current-price week row | R | Cannot form current price | Profile says 0 at CA_1 for 11616/11617; still audit |
| X4 | Item fails U5 (too new) | R | Insufficient price history opportunity | Unknown until profiled |
| X5 | Sales JSON length ≠ 1941 | R / Source Gate | Corrupt series | Profile says 0 |
| X6 | Negative units or non-numeric price after parse | R | Impossible values | Should be 0; flag if found |

Zeros in daily sales are **retained** as zeros. They are not stockout exclusions (no inventory field). Leading-zero prefix before first positive sale is retained in the series but does not count toward TE3/TE4 weeks before first positive day (those weeks are “not yet listed” and are excluded from the 52-week window if they predate first positive sale). **Status:** Proposed listing-start rule. **Risk controlled:** treating pre-list zeros as “barely sells.” **Tradeoff:** first-positive-day is a proxy for list date, not a true list date.

### 7.6 Lower/upper bounds

- Sales history used for features and eligibility: d_1 through d_1941 inclusive (2011-01-29 through 2016-05-22).
- Prices used for eligibility, current price, and candidate construction: weeks whose period intersects d_1–d_1941, with the current-price rule in §8. Weeks 11618–11621 must not be used as historical observations or as candidate sources.
- Horizon of the *decision* is future sales days d_1942–d_1969; those sales do not exist in this extract and must not be used.

### 7.7 Exclusion reporting

R-A and R-B emit audit counts: n_items_CA_1_total, n_after_dept_map, n_universe, n_dropped_by_X1…X6, n_fail_TE1…TE6 (not mutually exclusive), n_trust_eligible, n_action_raise, n_action_cut, n_action_unchanged, n_action_hold_ne, n_package, n_below_line.

---

## 8. Time-window and date contract

**Status:** Locked where dates are verified; Proposed on current-price week.  
**Origin:** DIP §B profile; T012; leakage control.

### 8.1 Calendrical facts (verified)

- d_1 = 2011-01-29; d_1941 = 2016-05-22 (last observed sales day; decision origin).
- Horizon of interest: d_1942–d_1969 = 2016-05-23 through 2016-06-19 (28 days).
- Walmart week key `wm_yr_wk`; weeks run Saturday–Friday.
- `wday` coding: Sat=1 … Fri=7 (not ISO Monday=1).
- Week 11616 = 2016-05-14 to 2016-05-20.
- Week 11617 = 2016-05-21 to 2016-05-27, **straddles the decision date**.
- Week 11621 has only 2 calendar days (2016-06-18/19).
- Horizon calendar already profiled: Memorial Day 2016-05-30 (National); NBAFinalsStart 2016-06-02 (Sporting); Ramadan start 2016-06-07 (Religious); NBAFinalsEnd and Father’s Day 2016-06-19; snap_CA = 1 on 2016-06-01 through 2016-06-10.
- `raw_sell_prices` contains weeks 11617–11621. Using 11618–11621 as observed history is look-ahead. Using the price *in effect on d_1941* is allowed.

### 8.2 Decision origin and information set

**Decision timestamp (conceptual):** end of calendar day 2016-05-22.  
**Allowed information:** any sales cell with `d ≤ d_1941`; any sell_price for weeks that have already started on or before 2016-05-22 and that we treat as known shelf price that day; the full calendar table through d_1969 (calendar is scheduled and known forward).

**Forbidden information:** sales d ≥ d_1942; sell_price for wm_yr_wk ≥ 11618; any feature that uses those values.

### 8.3 Current-price definition

**Proposed lock (Design B):**

`current_price` = `sell_price` on `(store_id = CA_1, item_id, wm_yr_wk = 11617)`.

**Justification:** Week 11617 begins Saturday 2016-05-21. A weekly shelf price in this dataset is the price for that Walmart week. On Sunday 2016-05-22 the shelf price in effect is the week-11617 price. Profile confirms every CA_1 item has this row.

**Risk controlled:** using week 11616 would describe last week’s completed price, not the price the GM would be changing *from*. Using week 11618+ is leakage.

**Tradeoff / residual risk:** if Walmart’s weekly file was written at week-end rather than week-start, 11617 could embed a mid-week change after 5/22 that we cannot see. No intra-week price timestamp exists.

**Sensitivity twin (required diagnostic, not the judged current price):** `current_price_11616` = week 11616 sell_price. If 11616 ≠ 11617, report the item and do not silently average. If the judged action would flip under the twin, flag `current_price_straddle_risk = 1`.

### 8.4 Horizon window

Half-open in day-index terms is unnecessary because days are discrete integers. Horizon = `{d : 1942 ≤ d ≤ 1969}` inclusive (28 days).

The pilot price, if adopted, is assumed **constant** across those 28 days (stakeholder: decision holds until next review). Do not assign different candidate prices to different horizon weeks.

### 8.5 Training / estimation window

See §17A. Production scoring train-through date = d_1941. Backtest uses an earlier origin (§16).

### 8.6 Weekday and SNAP coding

- Use source `wday` as stored (Sat=1 … Fri=7). Do **not** recode to lubridate ISO weekdays.
- SNAP feature for CA_1 is `snap_CA` (0/1) on that calendar day. Do not use `snap_TX` or `snap_WI` as CA_1 demand shifters.
- Event features: `event_name_1`, `event_type_1`, `event_name_2`, `event_type_2`. Blank means no event. Do not invent an “inferred promotion” field.

### 8.7 Partial last week

Week 11621 covers only two horizon days. **This is why Design B models daily units and sums 28 days**, rather than summing four “weeks” as if they were equal 7-day blocks.

**Risk controlled:** treating 11621 as a full week would inflate expected units in the last week and distort SNAP/event placement.  
**Tradeoff:** daily grain is noisier than weekly; the model must use weekday and SNAP dummies to absorb that noise.

### 8.8 Date comparison rules

- All comparisons are calendar-date / `d`-index, no timestamps, no timezone conversion.
- Same-day: a price week contains a day if that day’s date falls in the Sat–Fri span of `wm_yr_wk`.
- Missing calendar day: treat as a source defect; do not impute (calendar is complete 1,969 days per profile).
- Partial days: none (daily grain is a full day of units).

---

## 9. Grain and join-cardinality contract

**Status:** Proposed for judged grains; Verified for source keys.  
**Origin:** Framework §10; DIP table descriptions.

### 9.1 Grain table

| Layer | One row means | Keys | Status |
|---|---|---|---|
| Source sales | One item-store evaluation series | `id` = item_id + store_id + evaluation suffix | Verified unique, 30,490 |
| Source prices | One item-store-week shelf price | `(store_id, item_id, wm_yr_wk)` | Verified unique, 6,841,121 |
| Source calendar | One calendar day | `d` / `date` | Verified unique, 1,969 |
| SQL delivery — sales long | One item-store-day of units | `(store_id, item_id, d)` | Proposed mechanical unnest |
| SQL delivery — prices | One item-store-week | `(store_id, item_id, wm_yr_wk)` | Mechanical envelope |
| SQL delivery — calendar | One day | `d` | Full table |
| Feature / training observation | One item-store-day with mapped week price and calendar | `(item_id, store_id, d)` | Judged in R |
| Eligibility / trust | One item-store at the decision origin | `(item_id, store_id)` | Judged in R |
| KPI / prediction | One item-store × 28-day horizon × price scenario | `(item_id, store_id, price_scenario)` | Judged in R |
| Decision | One item-store | `(item_id, store_id)` | Locked business grain |
| Segment | Department or SNAP-intensity band rolled from item-store | `dept_id` etc. | Diagnostic |

### 9.2 Grain transition map

| From | To | Grouping | Aggregation | Row-count direction | Uniqueness assertion |
|---|---|---|---|---|---|
| sales JSON (1 / item-store) | item-store-day | unnest position 0..1940 → d_1..d_1941 | none; value = units that day | ×1941 | one row per (item, store, d) in envelope |
| item-store-day + calendar | item-store-day-enriched | join on `d` | 1:1 | same | every sales day finds one calendar day |
| item-store-day + prices | item-store-day-priced | join on store, item, `wm_yr_wk` of that day | many-days-to-one-week | same row count; price repeats 7× | no day with two prices |
| item-store-day-priced | item-store eligibility | group item, store | counts, sums, distinct prices | ÷ ~1941 | one row per in-scope item |
| item-store + scenarios | item-store-scenario predictions | cross join candidates | model score, 28-day sum | × (1 + n_candidates) | unique (item, scenario) |
| item-store-scenario | item-store decision | pick best legal scenario | argmax gain under gates | ÷ n_scenarios | one action per item |

### 9.3 Join cardinality (expected)

| Join | Cardinality | Control |
|---|---|---|
| sales long ↔ calendar on `d` | many-to-one | calendar `d` unique; unmatched sales day is a defect |
| sales long ↔ prices on (store_id, item_id, wm_yr_wk) | many-to-one | price key unique; a day may lack a price if the item-week is missing. Profile: CA_1 items have no internal gaps once priced, but leading unpriced weeks exist. Missing price on a day after first priced week is a defect at CA_1; before first priced week is expected. |
| sales header ↔ prices | one-to-many (weeks) | expected |
| No join among the three fact tables that creates many-to-many | — | Do not join sales to prices without the week key. Do not cartesian items. |

`DISTINCT` is not an acceptable repair for a bad join.

### 9.4 SQL vs R grain split

- **SQL may** restrict the extract envelope to `store_id = 'CA_1'` and `dept_id` in the five departments, unnest `sales_history` into long item-day rows for d_1..d_1941, attach `wm_yr_wk` by joining calendar on `d`, and deliver all price rows for those item-store keys (including weeks after 11617, so the Source Gate can prove they were *present* — R must still ignore them as features). Delivering post-decision prices is allowed only as a quarantined field group named so R cannot “accidentally” use them as history. **Preferred:** SQL delivers prices for all weeks for the envelope items; R applies the week ≤ 11617 filter as judged logic.
- **SQL must not** compute distinct-price counts, trust flags, candidate sets, predicted units, actions, or ranks.

---

## 10. Primary KPI contract

**Status:** Proposed formulas; Locked name/purpose from stakeholder.  
**Origin:** T004, locked question; Design B comparison logic.

### Primary KPI name

**Trusted expected 28-day item revenue gain versus current price**

Working symbol: \(\Delta \widehat{R}_{i}\)

### Purpose

Rank trusted, guardrail-passing price-change opportunities for the GM package. Also determine whether any change beats current.

### Grain

Item-store at the decision origin, evaluated over the 28-day horizon.

### Population

Trust-eligible items (TE1–TE6) for ranking; full universe for listing.

### Formula

Let \(P^{0}_{i}\) be current_price (§8.3).  
Let \(P^{c}_{i}\) be a candidate price from the item’s candidate set (§17).  
Let \(\hat{u}_{i,t}(P)\) be the model’s predicted units of item \(i\) on horizon day \(t\) if the shelf price on \(t\) equals \(P\) and calendar features equal the known calendar of day \(t\).

$$
\widehat{U}_{i}(P) = \sum_{t \in \{d_{1942},\ldots,d_{1969}\}} \max\bigl(0,\,\hat{u}_{i,t}(P)\bigr)
$$

$$
\widehat{R}_{i}(P) = \widehat{U}_{i}(P) \times P
$$

$$
\Delta \widehat{R}_{i}(P^{c}) = \widehat{R}_{i}(P^{c}) - \widehat{R}_{i}(P^{0})
$$

$$
\widehat{\rho}_{i}(P^{c}) = \frac{\widehat{U}_{i}(P^{c})}{\widehat{U}_{i}(P^{0})}
$$

If \(\widehat{U}_{i}(P^{0}) = 0\), the unit ratio is undefined: the item fails the trust/guardrail path and is `hold — not enough evidence` (cannot defend a 10% unit rule against a zero baseline).

**Numerator of the decision ranking:** \(\Delta \widehat{R}_{i}(P^{*}_{i})\) where \(P^{*}_{i}\) is the selected candidate (§17).  
**Denominator / reference:** expected revenue at the *current price under the same model and same horizon calendar*, not last-28-day realized revenue.

### Why predicted-current rather than trailing realized current

**Risk controlled by this choice:** the next 28 days include Memorial Day, NBA Finals, Ramadan start, Father’s Day, and a 10-day SNAP window. Last 28 days are not the same calendar. Comparing a candidate prediction to raw trailing revenue mixes calendar shift into the “gain.”

**Tradeoff:** model error appears in both \(\widehat{R}(P^{c})\) and \(\widehat{R}(P^{0})\). If error is price-invariant it cancels in \(\Delta \widehat{R}\); if the model’s price slope is wrong, both the gain and the guardrail are wrong together. Backtest (§16) is the control.

### Direction

Larger \(\Delta \widehat{R}\) is better among trusted guardrail-passers. Negative gain is not a change recommendation.

### Time basis

Horizon calendar days d_1942–d_1969. Price held constant. Features for those days use known calendar + the scenario price + pre-origin lags.

### Missingness

No predicted day may be dropped from the 28-day sum. If a feature is missing on a horizon day, that is a pipeline defect (calendar is complete). If a training day lacks price, drop that *training* row, not a horizon day.

### Weighting / aggregation

Item-level, unweighted across items. Portfolio revenue is not the KPI. Do not revenue-weight the model’s loss function toward expensive SKUs as a silent second KPI.

### Precision

- Internal: double precision.
- Display prices: 2 decimal places (source prices appear dollar-like).
- Display units: 2 decimal places internally for expectations; 1 decimal for GM-facing tables.
- Display revenue: cents.
- Ranking uses unrounded \(\Delta \widehat{R}\).

### Audit components (required fields)

`pred_units_current`, `pred_units_candidate`, `pred_rev_current`, `pred_rev_candidate`, `delta_rev`, `unit_ratio`, `current_price`, `candidate_price`, plus the 28 daily `.pred` values *or* an equivalent checksum of the 28-day sum that reconciliation can match.

### Limitations

- Not margin.
- Not category / store revenue (substitution ignored).
- Not causal.
- Not a guarantee (T026).

---

## 11. Guardrail, diagnostic, audit, and sensitivity metrics

**Status:** Proposed.  
**Origin:** T006, T040, framework §11 hierarchy.

### 11.1 Guardrail metric (binding)

**Expected unit ratio** \(\widehat{\rho}_{i}(P^{c})\) defined in §10.

Operational rule: reject candidate if \(\widehat{\rho}_{i}(P^{c}) < 0.90\).

“About 10%” is operationalized as a **hard 10.0% expected unit decline cap**.  
**Status:** Proposed policy operationalization, not a natural law.  
**Origin:** T006 “more than about 10 percent.”  
**Risk controlled:** implementers each picking 8% or 12% or “statistically significant 10%.”  
**Tradeoff:** a predicted −9.9% cut proceeds and a −10.1% cut dies; near-threshold items are fragile. Sensitivity twin uses 0.85 and 0.95 thresholds as *diagnostics after freeze*, not as alternate judged actions.

A price *cut* that raises units (\(\widehat{\rho} > 1\)) is legal on the guardrail. It still must have \(\Delta \widehat{R} > 0\) to be preferred to “leave unchanged” (T006: “as long as the revenue holds” — Design B reads “holds” as not falling, i.e. \(\Delta \widehat{R} \ge 0\); to avoid recommending zero-gain churn, judged raises/cuts require \(\Delta \widehat{R} > 0\) after cent rounding).

### 11.2 Diagnostic metrics (non-binding)

| Metric | Purpose |
|---|---|
| Predicted 28-day units at current and at each candidate | Explain the revenue numbers |
| Implied arc elasticity between \(P^{0}\) and \(P^{c}\) using predicted units | Sanity-check slope |
| Share of last-52-week units occurring on snap_CA=1 days | SNAP-intensity |
| Number of distinct historical prices and n_changes | Trust transparency |
| Trailing 28-day realized units and revenue (pre-origin) | Context only; not the baseline |
| Straddle flag (11616 price ≠ 11617 price) | Current-price risk |
| Department-level median predicted elasticity | Heterogeneity without separate lists |

### 11.3 Audit metrics

Universe counts in §7.7; join-loss counts; n_training_rows per item; n_horizon_days scored (must be 28); n_candidates_per_item; checksum of delivered units d_1–d_1941 per item; source lineage ids.

### 11.4 Sensitivity twins (prespecified)

1. Current price = week 11616 instead of 11617.  
2. Guardrail floors 0.85 and 0.95.  
3. Candidate set = {historical prices} vs {historical prices within ±20% of current} (narrower band).  
4. Drop SNAP features (does the package churn?).  
5. Calendar-only model (no price feature): if rankings look similar, price is not identified.  
Twins are not judged actions. Report overlap of package membership.

---

## 12. Comparison and baseline contract

**Status:** Proposed.  
**Origin:** Locked question “compared with the current price”; Design B methodological stance on endogeneity.

### 12.1 Primary comparison (judged)

For each item, every candidate price is compared to **the same item, same store, same 28-day horizon calendar, current shelf price**, using the **same model**.

This is a model-based no-change counterfactual, not a peer-group or prior-period comparison.

### 12.2 Why not last-28-day realized revenue as the baseline

Memorial Day, SNAP 6/1–6/10, NBA Finals, Ramadan, Father’s Day are in the horizon and not identically placed in the prior 28 days. A raw prior-period baseline attributes calendar lift to the price change.

### 12.3 Why not cross-item peers

Prices and demand levels differ by item. Peer median price is not a counterfactual for item i’s revenue.

### 12.4 Secondary comparison (diagnostic only)

Realized trailing 28-day revenue vs predicted current-price revenue over a *past* 28-day window (calibration). Not used to rank the live package.

### 12.5 Strongest alternative comparison considered and rejected for the judged path

Compare candidate predictions to a **calendar-only** prediction (price feature ablated). That is an excellent *identification diagnostic* (§11.4 twin 5) but it answers “does price add anything?” not “which price should Morgan print?” The locked question is candidate vs current price.

### 12.6 Weighting

Unweighted item-level comparison. The item does contribute to its own model through training rows; at score time the 28-day sum does not include those horizon days (they are unseen). No leave-one-item-out is required for scoring; leakage control is temporal, not cross-sectional.

### 12.7 Interpretation permission

Permits: “Under the locked model, P^c is expected to produce $X more item revenue than P^0 over these 28 calendar days, with expected units Y vs Z.”  
Does not permit: “Raising the price will cause $X more revenue net of substitution, inventory, and competitor response.”

---

## 13. Segment contract

**Status:** Proposed.  
**Origin:** Framework §13; avoid multiplicity.

| Segment | Priority | Source | Rule | Min size | What it can change |
|---|---|---|---|---|---|
| `dept_id` (5 values) | Required diagnostic / fairness of coverage | `dept_id` | as stored | Report even if small; do not suppress departments from the universe | Can change *interpretation* of concentration (e.g., package is all FOODS_3). Does **not** get a separate capacity budget. |
| SNAP-intensity tertile | Exploratory | computed share of last-52-week units on snap_CA=1 days | tertiles computed on trust-eligible items only, after eligibility | Provisional min 20 items/band to publish a rate | Must not retune ranking. May inform Stage 5 narrative. |
| Price-band (item current price tercile) | Exploratory | current_price | tertiles on universe | same | Diagnostic for whether gains are only cheap or only dear items. |
| Category `cat_id` | Excluded as a second cut | — | FOODS vs HOUSEHOLD is already in dept | — | Redundant with dept. |

**Multiplicity control:** one judged list for the store-aisle scope. No per-department top-25. No SNAP-band-specific gates. Exploratory cuts are labeled exploratory.

**Missing segment values:** `dept_id` is required; if missing, exclude and audit (should not occur).

---

## 14. Confounder and competing-explanation ledger

**Status:** Proposed.  
**Origin:** Framework §14; prompt emphasis on price endogeneity.

| Risk ID | Variable / mechanism | Why it matters | Relation to exposure | Relation to outcome | Available measure | Planned treatment | Residual limitation |
|---|---|---|---|---|---|---|---|
| C1 | **Price endogeneity / inferred promotions** | Prices move when something else is happening. A high-price week that coincides with a display or manufacturer promo will look like inelastic demand. | Price changes are the exposure. | Units and therefore revenue. | No promotion flag. Only price path + calendar. | (1) Identify from within-item price variation, not cross-item price levels. (2) Include SNAP and event features. (3) Restrict candidates to previously observed prices. (4) Calendar-only ablation twin. (5) Flag candidates whose historical occurrences were ≥50% event or SNAP weeks. | Unlabeled promotions remain. Causal ceiling stays predictive. |
| C2 | SNAP cycle | CA SNAP days materially move grocery. Horizon has snap_CA 6/1–6/10. | Prices may be set knowing SNAP weeks. | Units jump on SNAP days. | `snap_CA` | Daily SNAP feature; SNAP-intensity diagnostic. Do not use TX/WI SNAP. | SNAP feature captures average SNAP lift, not item-specific EBT elasticity if under-specified. |
| C3 | Holidays / events | Memorial Day, sporting, religious, cultural events in horizon. | Promo pricing around events. | Units move. | event_name/type 1 and 2 | Type dummies + specific horizon-event flags listed in §17A. | Rare events have few training repeats (NBA Finals once per year). |
| C4 | Seasonality | Month / season changes mix and demand. | Seasonal price resets. | Units. | month, year, wday | wday + month features; year not used as a future dummy. | Smooth intra-month seasonality only partly captured. |
| C5 | Selection on price-movers | Eligibility requires movement. Items that never move (possibly already “right” or constrained) are out. | Exposure history is selected. | Learned slope is a slope for items someone already chose to reprice. | n_distinct_prices, n_changes | Disclose; do not generalize to never-movers. | Structural. |
| C6 | Survivor / late listing | Items must exist at CA_1 through 2016-05-22. Early failures unobserved. Leading zeros. | Long-lived SKUs over-represented. | Volume and stability overstated. | first positive sale day; U5 | Start-of-life rule; do not treat pre-list zeros as demand. | No true list/delist file. |
| C7 | Stockouts as zeros | Zeros may be no demand or no inventory. | Price may rise when stock is low or fall to clear. | Units understated in stockout weeks. | None | Retain zeros; do not impute. Sensitivity: winsorize training days at the item 99th percentile only (outliers), never impute zeros to median. | Cannot distinguish. |
| C8 | Category substitution | Raising item A may send units to item B. Item revenue can rise while aisle revenue falls, or vice versa. | Simultaneous prices. | Item KPI misses aisle KPI. | Other items’ prices exist but using contemporaneous other-item prices as features creates a different estimand and leakage risk. | **Do not** include other-item prices in the judged model. Disclose aisle-substitution as unmeasured. | Material residual. The KPI is item revenue as locked. |
| C9 | Competitor prices | Missing. | Competitive under/over-pricing. | Units. | None | Disclose Infeasible. | Residual. |
| C10 | Cross-sectional price-quality confounding | Expensive SKUs are different products. A pooled price coefficient without item level attributes “premium” to “high price.” | Exposure level differs by item. | Units lower for dear items for quality reasons. | dept, lagged item mean units | Within-item identification via item-level lagged demand + dept, and candidates drawn from the item’s own history. Avoid using raw cross-section of price to explain cross-section of volume. | glmnet will still use cross-item variation if not careful; recipe rules in §17A constrain this. |
| C11 | Horizon price file leakage | Future weeks’ prices are in `raw_sell_prices`. | Would reveal what Walmart later charged. | Would contaminate “current” or candidates. | weeks 11618–11621 exist | Ban as features and as candidate sources. Source Gate lists them; R filter is judged. | Builder error. Fixtures must catch use of 11618+. |
| C12 | Partial week 11621 | 2-day week. | If weekly model used, exposure window is wrong. | Units inflated. | calendar | Daily 28-day sum. | Controlled if daily grain is implemented. |

**Most important confounder (headline):** C1 price endogeneity / unlabeled promotions, operating jointly with C2–C4 calendar.

---

## 15. Missingness, anomaly, and data-quality rules

**Status:** Proposed.  
**Origin:** Framework §15; verified profile facts.

| Issue | Action | SQL vs R | Audit |
|---|---|---|---|
| Duplicate `(store, item, wm_yr_wk)` in prices | Source defect; Source Gate fail if count ≠ distinct keys | SQL Gate | row count vs distinct key |
| Duplicate `id` in sales | Gate fail | SQL Gate | |
| `JSON_LENGTH` ≠ 1941 | Gate fail for that row; R excludes X5 | Both | |
| Negative units | Exclude item from recommendations (X6); do not clip silently without flag | R judged | count |
| `sell_price` non-numeric / ≤ 0 | After parse: price ≤ 0 is anomaly. Profile min is $0.01. Exclude that week from training and from candidate set; if it is the current-price week, item → hold NE | R | count |
| Missing price after first priced week at CA_1 | Profile says no internal gaps. If found, treat days in that week as training-unusable; do not fill with last price unless U5/TE logic already passed — Design B **does not last-observe-carry-forward across a hole** because holes are unexpected and may mark a listing break | R | count holes |
| Missing price before first priced week | Expected. Those days are not training rows (no price feature). | R | |
| Blank event fields | Normal. Code as no-event. | R | |
| Outlier daily units | Winsorize **training target only** at item-level 99th percentile of positive days. Do not winsorize prices. Do not winsorize horizon predictions beyond floor at 0. | R | p99 value recorded |
| Conflicting dept/cat vs id parse | Prefer table columns `dept_id`, `cat_id`, `item_id`, `store_id` over parsing `id` | R | mismatch count |
| Horizon sales present | They must **not** be present in the authorized sales extract (sales_history stops at d_1941). If a builder joins evaluation beyond 1941, that is leakage. | SQL contract: do not deliver d>1941 sales | Gate on max d |
| Week 11621 2-day week | Not an anomaly; handle via daily grain | R | |

Prespecified. No post-hoc dropping of items because they “look wrong” after seeing ranks.

---

## 16. Sample-size and uncertainty rules

**Status:** Provisional thresholds labeled as such.  
**Origin:** T010/T016/T040; framework §16.

### 16.1 Minimum denominators

- TE1–TE4 are the sample-size eligibility rules. They are **provisional policy thresholds** serving the stakeholder preference for a smaller trusted list. They are not SLAs and not statistically derived optima.
- Segment publication: exploratory tertiles need ≥ 20 trust-eligible items to quote a median elasticity; otherwise qualitative only.
- Model training: an item may be scored if it is trust-eligible even if some other items dominate the pooled fit. No per-item minimum training-row lock beyond TE3/TE4.

### 16.2 Uncertainty representation

Design B does **not** emit full prediction intervals unless the locked engine provides them cheaply (glmnet default does not). Uncertainty is represented by:

1. Trust gate TE6 using **backtest absolute percent error** of the 28-day unit sum at the then-current price.
2. An analyst **minimum-gain screen** that is uncertainty-aware rather than a dollar SLA (see §17): a trusted change must have \(\Delta \widehat{R}\) strictly greater than \(0.5 \times \text{department backtest MAE of 28-day revenue at current price}\).  
   **Status:** Proposed analyst choice, disclosed (T040 allows it).  
   **Risk controlled:** ranking noise when predicted gains are smaller than typical model error.  
   **Tradeoff:** some true small gains will be labeled unchanged or hold; stakeholder said small gains are still trustworthy if evidence is solid — this screen can be too harsh. Sensitivity: report the list with the screen off as a twin.

3. Raw components \(\widehat{U}\), \(\widehat{R}\) always shown so a human can see thin expectations.

No confidence interval is required for reconciliation.

### 16.3 Backtest design (required before trusting live scores)

**Primary pseudo-decision origin:** end of **d_1913**.  
**Computation check (not a new data fact):** d_1941 − 28 = d_1913. Date: 2016-05-22 minus 28 days = 2016-04-24.  
**Backtest horizon:** d_1914 through d_1941 (28 days of *observed* sales).  
**Backtest current price:** sell_price of the `wm_yr_wk` that contains d_1913.  
**Backtest information set:** sales d ≤ d_1913; prices for weeks that are allowed under the same “in-effect at origin” rule; calendar known forward.

**Secondary origin (stability):** end of d_1885 (a further 28 days earlier), same mechanics, if the item remains TE-eligible at that origin. If coverage is thin, skip and record.

**What is scored in backtest**

- Calibration: MAE, RMSE, and median APE of \(\widehat{U}_{i}(P^{0})\) vs realized 28-day units at the price that actually prevailed.  
  Note: actual prices may change during a historical 28-day window. For calibration of the *current-price* predictor, evaluate against realized units **and** report a second calibration restricted to items whose price was constant across that 28-day window (reduces mismatch between assumed constant pilot price and historical reality).
- Slope check: among item-weeks in training with a price change, sign of unit change vs sign of price change after calendar adjustment (descriptive).
- Decision-usefulness: using only information at the pseudo-origin, form the package; compare realized item revenue in the next 28 days for items whose *actual* subsequent price moved toward the recommended candidate vs those that stayed. This is **observational** and weak; it is not a causal pass/fail. It is recorded as a diagnostic.

**Acceptance criteria (provisional, must not be quietly moved after seeing results)**

| ID | Criterion | Cap |
|---|---|---|
| A1 | Median APE of 28-day units at current price, trust-eligible items with constant actual price in the window | ≤ 40% |
| A2 | Mean signed percent error (bias) on that subset | between −20% and +20% |
| A3 | Calendar-only ablation must **not** produce a higher Spearman correlation between predicted gain and realized revenue change than the price+calendar model on items that actually changed price in the window | qualitative pass |
| A4 | Package size in backtest is allowed to be 0–25; a backtest package of 0 is a valid outcome | — |

If A1 or A2 fail, the live posture is: still produce the list, but **all modeled changes become `hold — not enough evidence`** except where the design’s TE6 already did that. That is, a failed backtest acceptance collapses judged changes to hold NE. Leave-unchanged remains available as a non-model policy only for items that pass trust but have no positive legal gain — if the model itself is unaccepted, prefer hold NE over confident “unchanged.”

**Status of A1–A2 caps:** Provisional. They are disclosed before execution. They are not industry constants.

### 16.4 Targeted profiling required to harden TE4 and TE6

See §26 questions Q1–Q4. Until answered, TE4 uses the placeholder L=52 and TE6 uses department-relative backtest error.

---

## 17. Decision rules and capacity constraints

**Status:** Proposed judged rules.  
**Origin:** Locked actions, T006/T016/T018/T020/T024/T034/T038/T040; framework §17 membership-first / no-pad.

### 17.1 Candidate-price construction (Design B distinctive)

For each universe item, build `candidate_set_i` from **that item-store’s own pre-decision weekly prices**.

1. Collect distinct `sell_price` values from weeks with week-end ≤ d_1941 (equivalently: `wm_yr_wk` ≤ 11617, excluding any week used only as quarantined future).  
2. Drop P ≤ 0 or non-finite.  
3. Drop prices that occurred in only one week **and** that week had a National or Religious `event_type_1` (single-week event price is treated as non-repeatable promo-like). **Status:** Provisional anti-confounder filter.  
4. Keep prices in the closed band \([0.80 \times P^{0},\ 1.20 \times P^{0}]\). If after the band the set is only \(\{P^{0}\}\), expand the band to all remaining distinct prices from step 3 (do not invent new numeric prices). Record `band_expanded = 1`.  
5. Remove \(P^{0}\) from the *change* candidates; it remains the no-change scenario.  
6. Cap the change-candidate list at the **five** distinct prices nearest to \(P^{0}\) by absolute log-distance. Prevents scoring 15 noisy historical pennies.

**Do not** invent ±10% synthetic prices that were never charged.  
**Do not** use weeks 11618–11621 as sources.  
**Do not** use other stores’ prices.

**Risk controlled:** recommending an untested shelf price; using future prices; letting a one-off holiday price become “the” candidate.  
**Tradeoff:** cannot propose a clean new price ladder step the item has never sat on; may miss a profitable new point. Stakeholder allowed analyst construction method if shown (T034).

### 17.2 Scoring each scenario

For each item and each scenario price \(P \in \{P^{0}\} \cup \text{candidates}\):

- Build 28 horizon feature rows (d_1942–d_1969) with that P as `sell_price`, actual calendar, and lags computed from data dated ≤ d_1941 only.
- Predict daily units with the locked model.
- Floor at 0, sum to \(\widehat{U}(P)\), multiply by P for \(\widehat{R}(P)\).

### 17.3 Legal-change test

A candidate \(P^{c}\) is **legal** if and only if:

1. Item is trust-eligible (TE1–TE6).  
2. \(\widehat{U}(P^{0}) > 0\).  
3. \(\widehat{\rho}(P^{c}) \ge 0.90\).  
4. \(\Delta \widehat{R}(P^{c}) > 0\) after rounding both revenues to cents.  
5. Uncertainty screen: \(\Delta \widehat{R}(P^{c}) > 0.5 \times \text{dept_backtest_MAE_revenue}\) (analyst min-gain; disclosed). If a department has no MAE (too few backtest items), the screen is waived and `min_gain_waived = 1`.  
6. \(P^{c} \neq P^{0}\).

If the uncertainty screen is the only failure and all other legal tests pass, action is **`leave unchanged`** (evidence exists; gain is not distinguishable from error), not hold NE.

### 17.4 Action assignment (exactly one)

Let \(L_i\) be the set of legal candidates.

- If the item is **not** trust-eligible → **`hold — not enough evidence`**.  
- Else if \(L_i\) is empty → **`leave unchanged`**, recommended price = \(P^{0}\), expected units/revenue = current-price predictions.  
- Else let \(P^{*}_{i} = \arg\max_{P \in L_i} \Delta \widehat{R}_{i}(P)\).  
  - If \(P^{*} > P^{0}\) → **`raise`** to \(P^{*}\).  
  - If \(P^{*} < P^{0}\) → **`cut`** to \(P^{*}\).  
- Never assign raise/cut to a non-legal candidate.  
- Never convert hold NE into unchanged to “fill” narrative; they are different actions.

### 17.5 Ranking key, tie-break, capacity, no-pad

Among items with action ∈ {raise, cut}:

**Rank key (descending):** `delta_rev` unrounded.  

**Tie-break, in order:**

1. Larger `pred_units_current` (more observed volume behind the expectation).  
2. Larger `n_price_changes` (more identification).  
3. `item_id` ascending (stable, arbitrary).

**Capacity:** `N_CAP = 25` exactly as the operationalization of “about 25.”  
**Status:** Proposed operationalization of locked stance `hard_attention_budget`.

**Membership-first + no-pad:**

1. Form the full universe list (all in-scope items) with actions.  
2. Qualifiers = rows with action ∈ {raise, cut}.  
3. Sort qualifiers by the rank key.  
4. `package_flag = 1` for rank 1..min(25, n_qualifiers).  
5. `below_line_flag = 1` for rank > 25.  
6. If n_qualifiers < 25, package has n_qualifiers rows. **Do not** promote unchanged or hold NE into the package. **Do not** invent items.

Holds and unchanged are listed in separate sections of the output, sorted by `item_id`, and do not consume slots.

### 17.6 “About 10%” and “about 25” — explicit

| Phrase | Design B lock | Status |
|---|---|---|
| about 10% | reject if expected unit ratio < 0.90 | Proposed operationalization |
| about 25 | hard cap 25 actual raise/cut rows in the package | Proposed operationalization |

### 17.7 Minimum-gain option

Yes, disclosed: department-specific half-MAE screen (§16.2, §17.3.5). Not a stakeholder-supplied dollar floor.

### 17.8 Unused framework mechanics (explicit N/A)

- Half-window persistence: **N/A** (not a two-half rate design).  
- Dual-clock / twin action-override: **N/A** as a judged dual pipeline. Sensitivity twins exist as diagnostics, not as an INCONCLUSIVE override clock.  
- Simulation occupancy labels: **N/A** (not a simulation).  
- Capacity labels: **used** (`package_flag`, `below_line_flag`, `capacity_stance = hard_attention_budget`).

### 17.9 What the rule does not establish

Crossing the 10% or 25 lines is not proof that the 26th item is unattractive or that a −9.9% unit item is safe. Thresholds are policy operationalizations.

---

## 17A. Predictive analytics / ML mode and Mode A lock fields

**Status:** Locked mode; Proposed specification of lock fields.  
**Origin:** Project requirement; framework §17A and FORWARD use test.

### ml_mode

**`A`** — Judged predictive contract.

Use-test reasons: \(\widehat{U}\), \(\widehat{R}\), \(\Delta \widehat{R}\), and \(\widehat{\rho}\) change (i) the action among raise / cut / unchanged and (ii) capacity ranking, before Validation freeze. Mode B is therefore not available. Mode None is out of project scope.

### Prediction unit

- **Scoring / decision unit:** one item-store at the decision origin (`item_id`, `store_id='CA_1'`).  
- **Model observation unit (training):** one item-store-day with a mapped weekly price.

### Target

Daily unit sales \(u_{i,t}\) on the original scale (non-negative integer in source).  
Model predicts \(\hat{u}_{i,t}\). Horizon KPI sums 28 daily predictions.

**Not the target:** revenue (price would appear on both sides), weekly sums (partial-week distortion), log units as the *reconciled* target (log may be used only inside a recipe if reversed consistently — Design B avoids that path to prevent retransformation disagreement between R-A and R-B).

### Allowed features (known at origin or scheduled)

| Feature | Construction rule |
|---|---|
| `sell_price` | Week-mapped price for that day; at score time, the *scenario* price, constant across the 28 days |
| `log_sell_price` | `log(sell_price)` ; sell_price > 0 |
| `wday` | source coding Sat=1…Fri=7, as factor |
| `month` | source month, as factor |
| `snap_CA` | 0/1 that day |
| `event_type_1` | factor including a level for blank/none |
| `event_any` | 1 if event_name_1 or event_name_2 non-blank |
| `is_memorial_day_window` | 1 if date is 2016-05-30 or ±1 day, and the analogous Memorial Day window in prior years using calendar event_name_1 = 'MemorialDay' |
| `is_nba_finals` | 1 if event_name is NBAFinalsStart or NBAFinalsEnd on that day or between those two event days in the same year if both exist |
| `trailing_28d_units` | sum of units on t-28 … t-1 (requires t-1 ≤ origin when scoring) |
| `trailing_84d_units` | sum of units on t-84 … t-1 |
| `trailing_28d_mean_price` | mean sell_price on days t-28 … t-1 that have a price |
| `dept_id` | factor |
| `n_snap_next_28_known` | count of snap_CA=1 days in the 28-day window starting at t — **allowed on horizon rows** because SNAP is scheduled; on training rows, this looks forward up to 27 days. **Restriction:** this feature may use calendar only, never future sales or future prices. |

### Forbidden features

- Any unit, revenue, or price from d > origin (live origin d_1941; backtest origin d_1913 / d_1885).  
- `sell_price` from wm_yr_wk ≥ 11618 for live scoring (and analogously after the backtest current week).  
- Other stores’ sales or prices.  
- Other items’ contemporaneous prices or units (substitution unmodeled by contract).  
- `snap_TX`, `snap_WI`.  
- Year dummy that would require a 2016-only level at score time without training support.  
- Item_id as a high-cardinality dummy in glmnet (would absorb level, not slope, and is unstable across R encodings).  
- Realized horizon outcomes.  
- Inventory, cost, competitor, promotion labels (do not exist).

### Leakage rules

1. Temporal cutoff at origin is absolute for sales and prices.  
2. Calendar may extend past origin.  
3. Trailing features use strictly earlier days (`t-1` and before).  
4. Training rows with `d` in a backtest horizon are excluded from that backtest’s training set.  
5. SQL may deliver post-origin prices only as quarantined columns; they are not recipe inputs.  
6. No target encoding using the full panel including future days.

### Split and training window

- **Live judged model:** train on item-store-days with `d ≤ d_1941`, price present, item in the five departments at CA_1. No random split.  
- **Hyperparameter / penalty selection:** 5-fold **time-blocked** CV *inside* the training window. Blocks are contiguous date bands. No random row folds.  
- **Backtest model:** separately retrained with train `d ≤` pseudo-origin. Do not reuse live coefficients for backtest acceptance.  
- **No random train/test shuffle.**

### Model class / parsnip family / engine / hyperparameters or selection rule

**Locked family:** `linear_reg`  
**Locked engine:** `glmnet`  
**Locked mode:** regression  
**Locked mixture:** `0.5` (elastic net)  
**Locked penalty selection rule:** choose `penalty` by 5-fold time-blocked CV minimizing RMSE of daily units on held-out blocks inside the training window. The selected penalty is then refit on the full training window. Same rule in R-A and R-B independently (they may obtain numerically close but not identical penalties; see reconciliation tolerance on `.pred`).

**Why this class (Design B):**

- A linear / elastic-net log-price term is an explicit, inspectable slope — needed to criticize endogeneity rather than hide it in a forest.  
- glmnet controls the wide dummy set (wday, month, dept, event).  
- Ranger/forests would capture SNAP×price interactions automatically but would make the within-item identification story harder to audit and would allow wild interpolation between scattered price points.

**Risk controlled:** opaque black-box slope; uncontrolled high-dim dummy overfit.  
**Tradeoff:** weak interactions (SNAP × price) unless explicitly added. Design B **does** add one interaction: `log_sell_price * snap_CA`. No other interactions.

**Recipe (judged, implemented independently in R):**

- Filter to allowed features.  
- `log_sell_price = log(sell_price)`.  
- Dummy-encode factors with a fixed reference: `wday` reference = 1 (Saturday); `month` reference = 1; `dept_id` reference = `FOODS_3` (largest grocery dept by profiled item count); `event_type_1` reference = none.  
- Center/scale only the numeric non-dummy predictors using training-window moments.  
- Include main effects + `log_sell_price:snap_CA`.  
- Do **not** include raw `item_id`. Item level is proxied by `trailing_28d_units` and `trailing_84d_units`.

**Prediction post-process:** \(\hat{u} = \max(0, \hat{u}_{\text{raw}})\). No integer rounding before the 28-day sum.

### Evaluation metrics (model)

Primary: RMSE and MAE of **28-day summed units** at the current price on the backtest constant-price subset.  
Secondary: daily RMSE inside CV; mean signed error; median APE.  
Decision metrics: package overlap across twins; guardrail violation rate if actual units were as predicted.  
Not used for selection: accuracy@k, ROC (wrong task).

### Threshold → action mapping

There is no score cutoff such as “if .pred > 0.5 then intervene.” Mapping is the §17 decision rule applied to scenario-level `.pred` sums. The “threshold” objects are: unit ratio 0.90, delta_rev > 0, half-MAE screen, top-25.

### Reconciliation-critical fields (Mode A)

Must be present on the item-store judged output:

- `item_id`, `store_id`  
- `action`  
- `current_price`, `candidate_price` (candidate_price = current_price when action is unchanged or hold NE)  
- `.pred_units_current`, `.pred_units_candidate`  
- `.pred_rev_current`, `.pred_rev_candidate`  
- `delta_rev`, `unit_ratio`  
- `trust_eligible`, `guardrail_pass`, `legal_change`  
- `package_flag`, `below_line_flag`, `rank_among_qualifiers`  
- `penalty_selected` (audit)  
- lineage fields (§24)

Daily 28-length prediction vectors are reconciliation-optional if the 28-day sums match within tolerance; at least one builder path should retain them for fixtures.

### Fixtures including known prediction / action cases

See §24. Mode A fixtures must include at least one item where a higher candidate price reduces predicted units by more than 10% and **must not** receive raise; one item with two legal candidates where the higher delta_rev wins; one item that fails TE1 and must be hold NE regardless of predicted gain.

---

## 18. Measurement-risk register

**Status:** Proposed.  
**Origin:** Framework §18.

| Risk ID | Component | Failure mode | Likelihood | Decision impact | Detection | Prevention | Sensitivity | Residual | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | KPI / C1 | Endogenous price treated as exogenous slope → wrong sign or flat elasticity | High | Wrong raise/cut | Calendar ablation; event-week flag on candidates | Observed-price candidates; SNAP/event features; within-item lags | Ablate price | High residual | Accepted with disclosure |
| R2 | Comparison | Using trailing realized revenue as baseline | Medium if builders drift | Calendar attributed to price | Blueprint + fixtures | Locked predicted-current baseline | Twin with trailing baseline | Low if locked | Open until fixtures pass |
| R3 | Current price | 11617 vs 11616 straddle | Medium | Wrong P0, wrong raise vs cut | Straddle flag | Documented rule + twin | 11616 twin | Medium | Accepted |
| R4 | Leakage | Future prices 11618–11621 used as candidates or features | Medium (field is sitting in the table) | Non-replicable “oracle” list | Source Gate quarantine + R fixture that fails if 11618 price appears in candidate_set | Forbidden-feature list | — | Low if fixtures bind | Open until Stage 4 |
| R5 | Grain | Weekly model treats 11621 as 7 days | Medium | Inflated horizon units | Horizon-day count = 28 assertion | Daily grain | — | Low if implemented | Open until Stage 4 |
| R6 | Population | Department mapping too wide (HOUSEHOLD_2 thin) or too narrow | Medium | Different package composition | Audit n by dept | Universe wide, trust gate item-level | Drop HOUSEHOLD_2 twin | Medium | Accepted |
| R7 | TE thresholds | Provisional 4 prices / 3 changes / 26 weeks invented relative to unknown distributions | High | Empty or bloated trusted set | Profiling Q1–Q3 | Mark Provisional; prefer smaller list | Alternate 3-price / 20-week twin | Medium | Open (profiling) |
| R8 | Guardrail | 0.90 hard cut on noisy \(\widehat{U}\) | Medium | False reject/accept of cuts and raises | Near-threshold listing | Show unit_ratio; 0.85/0.95 twins | Twins | Medium | Accepted |
| R9 | Min-gain half-MAE | Over-prunes true small gains | Medium | Smaller package | Twin with screen off | Disclosed analyst choice | Twin | Medium | Accepted |
| R10 | Substitution C8 | Item revenue up, aisle revenue down | High conceptually | GM optimizes the wrong object | Cannot measure well | Disclose ceiling | — | High | Accepted disclosure |
| R11 | Stockout zeros C7 | Slope estimated on constrained quantity | Medium | Biased units | Zero-share diagnostic | No imputation | — | High | Accepted |
| R12 | Sample / TE6 | One backtest window error cap is noisy | Medium | Arbitrary hold NE | Secondary origin d_1885 | Department-relative rule | Two-origin rule | Medium | Provisional |
| R13 | Capacity | Builders pad to 25 | Low if contract clear | Diluted GM attention | n_package ≤ 25 and n_package = min(25, n_qualifiers) | Membership-first fixtures | — | Low | Controlled |
| R14 | SQL delivery | JSON unnest off-by-one (position 0 ≠ d_1) | Medium | All dates shifted, SNAP misaligned | Checksum: date of position 1940 = 2016-05-22; units sum vs source | Source Gate | — | Low if gated | Open until Gate |
| R15 | R translation | Two glmnet paths pick different penalty, different actions | Medium | Recon fail or unstable package | Penalty + .pred tolerance | Locked CV rule; recon tolerance | — | Medium | Accepted with tolerance |
| R16 | Causal overclaim | Stage 5 writes “will raise revenue” | Medium | False certainty to GM | Conclusion ceiling §5 | T026 language in output columns (`expectation_not_guarantee = 1`) | — | Medium | Controlled in design |
| R17 | Segment multiplicity | Fishing elasticities by SNAP tertile | Medium | Spurious story | Predeclared exploratory | One judged list | — | Low | Controlled |
| R18 | Model class | Linear daily units can predict negatives; floor at 0 biases sums | Medium | Overstated low-volume items | Count of floored days | Floor + audit n_floored | Poisson family twin later (not judged) | Medium | Accepted |

SQL delivery vs R translation are distinguished: R14 is SQL; R15 is R.

---

## 19. Non-executable SQL→R implementation blueprint

**Status:** Proposed.  
**Origin:** Framework §19.

1. **Authoritative sources:** `pricepoint.raw_sales_evaluation`, `pricepoint.raw_calendar`, `pricepoint.raw_sell_prices`.  
2. **Required fields:**  
   - sales: `id`, `item_id`, `dept_id`, `cat_id`, `store_id`, `state_id`, `sales_history`  
   - calendar: `date`, `wm_yr_wk`, `weekday`, `wday`, `month`, `year`, `d`, `event_name_1`, `event_type_1`, `event_name_2`, `event_type_2`, `snap_CA` (TX/WI optional for gate completeness, unused in model)  
   - prices: `store_id`, `item_id`, `wm_yr_wk`, `sell_price`  
3. **Keys:** as §9.  
4. **Joins:** calendar to sales on `d`; prices to sales-day on `(store_id, item_id, wm_yr_wk)`.  
5. **SQL grain:** item-store-day for CA_1 × five depts, d_1–d_1941, plus full calendar, plus all price rows for those item-store pairs.  
6. **Permitted SQL mechanical transformations:** envelope filter on store/dept; JSON unnest of 1,941 positions to `d` / `units`; type casts of varchar numbers; attach `wm_yr_wk` from calendar.  
7. **Prohibited SQL judged transformations:** eligibility, distinct price counts as final flags, candidate lists, trailing features that encode a chosen origin, predictions, actions, ranks, trust, package membership.  
8. **R independently:** listing-start, TE1–TE6, candidate construction, recipe, glmnet CV, 28-day scoring at multiple prices, guardrail, actions, ranking, package flags, audit counts.  
9–16. As contracts in §20–24.

Acceptable blueprint sentence:

> SQL delivers CA_1 everyday grocery and household item-day units through d_1941, the matching weekly prices, and the calendar through the horizon, without computing trust, candidates, predictions, or actions. R-A and R-B independently construct the panel, apply eligibility and leakage cutoffs, fit the locked parsnip model, score current vs observed-price candidates over the 28 known calendar days, and assign actions and the 25-slot package.

---

## 20. Controlled SQL source contract

**Status:** Proposed.  
**Origin:** Framework §20.1; DIP database notes (MySQL 8.0, schema `pricepoint`, R never connects).

### Envelope

- `store_id = 'CA_1'`  
- `dept_id IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')`  
- Sales days: positions corresponding to d_1–d_1941 only.  
- Calendar: all 1,969 days (needed for horizon features and week mapping of the last sales days).  
- Prices: all weeks for the envelope item-store keys, including post-decision weeks (quarantine in documentation).

### Deliverables (logical tables, not production SQL)

**SALES_LONG:** `item_id`, `dept_id`, `cat_id`, `store_id`, `state_id`, `id`, `d`, `date`, `units`  
**CALENDAR:** full source columns listed above  
**PRICES:** `store_id`, `item_id`, `wm_yr_wk`, `sell_price`  
**LINEAGE:** `snapshot_id`, `source_version`, `extraction_timestamp`, `observation_boundary_d = 1941`, `observation_boundary_date = '2016-05-22'`, `design_id = 'PRICEPOINT-001-B-v1'`

### Multiplicity

- SALES_LONG unique on `(store_id, item_id, d)`  
- One-to-one with calendar on `d`  
- PRICES unique on `(store_id, item_id, wm_yr_wk)`

### Permitted mechanical work

Envelope, unnest, casts, calendar attach of `d`/`date`/`wm_yr_wk` onto sales long.

### Prohibited precomputes

Final eligibility, TE flags, candidate prices, trailing-feature tables keyed to the live origin, `.pred`, actions, ranks, package flags, “trusted” labels, distinct-price-count *as an output of record* (R must compute TE1 from delivered prices). SQL may not train or score.

### Post-decision prices

May appear in PRICES. Must be identifiable by `wm_yr_wk >= 11618`. R judged logic ignores them for current price (except 11617), candidates, and features.

---

## 21. SQL Source Gate handoff requirements

**Status:** Proposed.  
**Origin:** Framework §20.2.

Stage 4 must independently verify against raw:

| Check | Pass condition |
|---|---|
| Envelope item count | Distinct CA_1 items in five depts in extract = distinct such items in raw sales |
| Sales day coverage | Every envelope item has exactly 1,941 long rows, d from 1 to 1941 inclusive |
| Position mapping | For a frozen fixture item, JSON position 0 units = long `d=1` units; position 1940 = `d=1941` units; date of d_1941 = 2016-05-22 |
| Units equality | Per-item sum of long units = sum of JSON array values |
| Price key uniqueness | extract price rows for envelope = raw count for those keys; no duplicate keys |
| Price value equality | `sell_price` matches raw for a sample of keys including week 11616, 11617, 11618 |
| 11617/11616 completeness | Every envelope item has both weeks (profiled); Gate fails if any missing |
| Calendar completeness | 1,969 days; 282 wm_yr_wk; snap_CA and MemorialDay date match raw |
| Join loss | Every sales long row with a priced week finds ≤1 price row |
| No extra sales days | max(d) in sales long = 1941 |
| Lineage | snapshot/source fields present and equal to the freeze identity |
| Null profile | units never null after unnest; sell_price never blank in delivered price rows |

Failure of mapping, completeness, or value equality is Gate Fail. Stage 3 does not write the gate queries.

---

## 22. R-A / R-B judged-output contract

**Status:** Proposed.  
**Origin:** Framework §20.3.

Both independent R builders produce, from the same verified source package:

### 22.1 Universe table (one row per in-scope item-store)

Keys: `item_id`, `store_id`.

Required fields:

- `dept_id`, `cat_id`  
- `in_universe`, `list_start_d`, `n_distinct_prices_pre`, `n_price_changes_pre`, `n_positive_weeks_52`, `units_52`  
- `te1`…`te6`, `trust_eligible`  
- `current_price`, `current_price_11616`, `straddle_flag`  
- `n_candidates`, `band_expanded`  
- `action` ∈ {`raise`,`cut`,`unchanged`,`hold_ne`}  
- `candidate_price`  
- `.pred_units_current`, `.pred_units_candidate`, `.pred_rev_current`, `.pred_rev_candidate`  
- `delta_rev`, `unit_ratio`, `guardrail_pass`, `legal_change`, `min_gain_waived`  
- `rank_among_qualifiers` (NA if not qualifier)  
- `package_flag`, `below_line_flag`  
- `expectation_not_guarantee` = 1  
- `penalty_selected`  
- `n_horizon_days_scored` (must be 28)  
- `n_floored_days`  
- lineage: `snapshot_id`, `source_version`, `observation_boundary_d`, `design_id`, `ml_mode='A'`  
- `capacity_stance = 'hard_attention_budget'`  
- `run_role` ∈ {`R-A`,`R-B`} (label, not a live-system claim)

### 22.2 Qualifier ranking table

Subset with action in {raise, cut}, sorted by locked key, with ranks 1…n.

### 22.3 Audit table

Exclusion counts §7.7; backtest A1–A4 results; department package counts.

### 22.4 Model artifact note

R-A and R-B must **not** share a fitted parsnip workflow, glmnet object, recipe object, or scored table as a build input. Each fits from the spec.

### 22.5 Uniqueness

One row per `item_id` in the universe table for CA_1.

---

## 23. R-A versus R-B exact reconciliation contract

**Status:** Proposed.  
**Origin:** Framework §20.4.

| Object | Standard |
|---|---|
| Key coverage | Same set of `item_id` in universe |
| Row counts | Exact equality on n_universe, n_trust_eligible, n_raise, n_cut, n_unchanged, n_hold_ne, n_package, n_below_line |
| Eligibility flags | Exact equality on te1–te6, trust_eligible |
| Prices | Exact equality on current_price, candidate_price (currency values as parsed) |
| Actions | Exact equality on `action`, `package_flag`, `below_line_flag` |
| Ranks | Exact equality on `rank_among_qualifiers` for qualifiers |
| Lineage | Same snapshot_id / observation_boundary_d |
| Continuous predictions | `max abs(.pred_units_current_A − _B)` ≤ **0.05 units** per item; same for candidate units; `max abs(delta_rev_A − delta_rev_B)` ≤ **$0.05** |
| Penalty | No exact equality required on `penalty_selected`; if actions disagree, recon **fails** even if penalties differ — builders must repair toward spec, not average models |

“Close on the package, off on holds” is not a pass.

If glmnet numeric drift exceeds tolerance *and* flips an action, that is a failed recon, not a license to pick one path.

---

## 24. Fixture and lineage contract

**Status:** Proposed.  
**Origin:** Framework §19A / §20.5. Freeze before R builders run.

### 24.1 Lineage

All judged exports carry `snapshot_id`, `source_version`, `observation_boundary_d=1941`, `observation_boundary_date=2016-05-22`, `design_id=PRICEPOINT-001-B-v1`, `ml_mode=A`. Validation-green claims require these fields.

### 24.2 Known-case fixtures (tiny constructed panels, not live M5 rows)

The pack is synthetic so expected actions are knowable without the full model fit. Each fixture is a miniature item-day panel plus calendar/price stubs. R builders run the *locked rules* on the pack (eligibility, candidates, guardrail, ranking, leakage bans). Where a fixture requires a prediction, it injects a **stub predict function** specified by the fixture (not ENGINE Expand) so that action logic is tested independently of glmnet numerics. A separate fixture checks that forbidden week 11618 prices never enter `candidate_set`.

| Fixture ID | Setup (prose) | Must pass if | Must fail the build if |
|---|---|---|---|
| FX-HOLD-NE-PRICES | Item with only 1 distinct pre-origin price | `trust_eligible=0`, `action=hold_ne` | Builder recommends a raise because a model stub says gain is large |
| FX-GUARD-10 | Trust-eligible item; stub \(\widehat{U}(P^c)=89\), \(\widehat{U}(P^0)=100\), \(P^c>P^0\), positive revenue gain | `guardrail_pass=0`, action ≠ raise | Builder applies 10% to revenue instead of units, or uses 0.89 ≥ 0.90 incorrectly |
| FX-CUT-OK | Cut candidate, stub units +20%, revenue + | action=cut allowed | Builder bans all cuts |
| FX-ARGMAX | Two legal candidates, delta_rev 10 vs 8 | selects the 10 | selects the smaller gain or the closer price |
| FX-NOPAD | 3 qualifiers only | n_package=3, no holds promoted | package padded to 25 |
| FX-CAP25 | 30 legal qualifiers with strictly decreasing gains | n_package=25, n_below_line=5, order by gain | 26th placed in package or unsorted |
| FX-MEMBER | Universe includes a zero-eligible item | row present, action=hold_ne | builder drops non-qualifiers from output |
| FX-LEAK-11618 | Item has a lucrative price only in week 11618 | that price ∉ candidate_set | future price recommended |
| FX-CURRENT-11617 | 11616 price 3.00, 11617 price 3.50 | current_price=3.50 | uses 3.00 or average |
| FX-HORIZON-28 | Calendar stub includes 11621 2-day week | n_horizon_days_scored=28 | scores 4×7=28 from week keys and double-counts or drops days |
| FX-TIE | Two items identical delta_rev, different pred_units_current | higher units ranks first | random or item_id-first before volume |
| FX-UNCHANGED-SMALLGAIN | Legal on guardrail but delta_rev below half-MAE screen | action=unchanged not hold_ne | dumped into hold NE or still ranked as change |

**Fixture Gate authority:** freeze path + content hash before either R builder starts. On Fail, repair toward this spec; do not rewrite expected outcomes.

### 24.3 Spec→builder translation packet (gate classes)

| Gate class | Used? | Clause cite | R-A / R-B attestation |
|---|---|---|---|
| Half-window persistence | N/A | §17.8 | Attest unused |
| Dual-clock twin override | N/A | §17.8 | Attest unused |
| Full analytical-unit universe | Yes | §7, §17.5, FX-MEMBER | Emit every in-scope item including hold NE |
| Membership-first + capacity + no-pad | Yes | §17.5, FX-NOPAD, FX-CAP25 | Qualifiers only fill 25 slots; no padding |
| Non-enrolling actions | Yes | §17.4 hold_ne / unchanged never promoted to package | FX-NOPAD |
| Lineage field mapping | Yes | §24.1 | snapshot_id etc. on judged export |
| Capacity / simulation labels | Capacity yes; simulation N/A | §17.5, §22 | `package_flag`, `below_line_flag`, `capacity_stance` |
| Mode A scoring | Yes | §17A | Independent fit; recon on actions and `.pred_*` |
| Leakage cutoff | Yes | §8, §17A, FX-LEAK-11618 | No post-11617 prices in features/candidates |

---

## 25. Multi-AI review and resolution record

**Status:** Deferred (this artifact is the independent first pass).  
**Origin:** Framework §23–24.

This file is Design B only. It has not seen Design A or the AI 3 dossier. Cross-review, reconciliation matrix, and human lock belong in later artifacts (`05_`–`10_`). No vote is taken here.

Independence note: if a later reviewer finds Design B coincidentally similar to Design A, similarity is not evidence of copying; both are constrained by the same locked question.

---

## 26. Assumptions, open questions, and accepted limitations

**Status:** Open items explicitly listed.

### 26.1 Working assumptions (disclosed)

- Week-11617 sell_price is the shelf price in effect on 2016-05-22.  
- The pilot holds a single price constant for 28 days.  
- Zeros are true recorded units, not censored stockouts.  
- Calendar through 2016-06-19 is known at decision time.  
- “Everyday grocery and household” = FOODS_1/2/3 + HOUSEHOLD_1/2.  
- glmnet on daily units with a log-price term plus lags is a usable predictive instrument, not a causal demand system.  
- Half-MAE min-gain is a reasonable noise filter.

### 26.2 Targeted profiling questions (do not invent answers)

**Q1.** For CA_1 items in the five departments, using only weeks with `wm_yr_wk ≤ 11617`, what is the distribution (min, p10, p25, median, p75, p90, max) of (a) distinct sell_price count and (b) week-to-week price-change count? How many items sit at 0, 1, 2, 3, 4+ distinct prices?

**Q2.** For the same items, last 52 complete weeks ending at or before week 11617: distribution of total units, share of days that are zero, and number of weeks with positive weekly units.

**Q3.** Typical |percent change| when price changes week-to-week (median, p75), overall and by dept. Needed to judge whether the ±20% candidate band is wide or narrow relative to history.

**Q4.** How many CA_1 five-dept items have week-11616 price ≠ week-11617 price?

**Q5.** How many items would remain if U5 requires a first priced week at least 364 days before d_1941?

These questions may be answered by a *targeted* profile. They must not become the judged pricing analysis.

### 26.3 Accepted limitations

- No margin, inventory, competitors, or promo labels.  
- Item KPI ignores substitution.  
- Never-movers are out by design (selection).  
- One store, one cycle.  
- Predictive ceiling only.  
- Provisional sample gates until Q1–Q3 return.  
- Elastic-net daily linear model cannot fully represent SNAP×price heterogeneity.  
- Backtest acceptance caps are provisional.

### 26.4 Infeasible controls

Competitor prices, true stockouts, cost, official aisle planogram, manufacturer promo calendar.

---

## 27. Stage 4 handoff and lock approval

**Status:** Proposed handoff; lock approval is human and has **not** occurred.

### Handoff contents

- This Design B contract (not yet the consolidated locked design).  
- ml_mode = A with §17A fields.  
- Controlled SQL source contract §20.  
- SQL Source Gate requirements §21.  
- R-A / R-B judged-output contract §22.  
- Exact recon contract §23.  
- Fixture and lineage contract §24.  
- Spec→builder packet in §24.3 covering every used gate class.

### What Stage 4 still must not do

Invent a different department set, current-price week, candidate rule, guardrail, capacity rule, or model family without returning to Stage 3.

### Lock approval

| Role | Status |
|---|---|
| AI 2 independent design | Complete (this document) |
| Cross-review | Not started |
| Human analyst approval | Not given |
| Design Gate | Not passed |
| Stage 4 authorization | Not given |

---

## Design B headline alternatives

These five lines are the required AI-2 close. Each is a *strongest* alternative relative to this design’s judged path, not a menu of leftovers.

1. **Strongest alternative KPI.** *Category- or aisle-expected 28-day revenue* (sum of predicted item revenues in the same department under a simultaneous-price scenario) rather than single-item revenue. It better matches “don’t do something dumb to the customer / the aisle,” and it is the only nearby construct that addresses substitution (C8). It is not used as primary because the locked outcome is product revenue, costless substitution modeling would be an unidentified second demand system, and the GM package is item-priced. Item revenue remains the honest locked KPI; aisle revenue is the strongest rival construct.

2. **Strongest alternative grain.** *Item-store-week* demand with a 4-week sum, instead of item-store-day summed over 28 calendar days. Aligns with the native price grain and reduces daily zero inflation. Rejected for the judged path because week 11621 is a 2-day week and the horizon is defined as 28 days, not four Walmart weeks; a weekly grain would require an ad-hoc partial-week scaler that two R builders would implement differently.

3. **Strongest alternative comparison.** *Candidate predicted revenue versus realized trailing 28-day revenue at the actual recent price*, rather than versus model-predicted revenue at current price on the forward calendar. This avoids canceling-error optimism and is easier to explain to a GM (“last four weeks you took in $X; we expect $Y at the new price”). Rejected for the judged path because the forward window’s SNAP and holiday placement differs from the trailing window; that comparison confounds calendar with price. Retained as a diagnostic twin.

4. **Most important confounder.** **Unlabeled promotions and other event-timed price setting (C1), entangled with SNAP and holiday calendar (C2–C4).** Every historical price move that identifies the glmnet log-price term may be a bundled treatment. If that confounder dominates, trusted “gains” are memories of promotions, not forecasts of a quiet shelf-price pilot.

5. **Design choice most likely to change the decision.** **Restricting candidates to previously observed item-store prices (plus the companion trust gates TE1–TE6 and the half-MAE min-gain screen).** Switching to synthetic ±X% prices around current, or loosening “a few” price moves to a single historical change, would change both *which* items appear and *which numbers* get printed on the shelf. The second most decisive switch would be current-price week 11616 vs 11617 for straddling items (Q4 will say how many).

---

*End of Design B. No production SQL. No production R. Locked decision and question unaltered.*

---

# PART C — DATA AND RISK DOSSIER (AI 3, verbatim)

# 04_AI3_DATA_AND_RISK_DOSSIER

Independent AI 3 audit for PRICEPOINT-001, Stage 3 Measurement Design.  
Inputs used: `01_DESIGN_INPUT_PACKAGE.md` (DIP-v1, frozen 2026-09-25) and `three-ai-measurement-design-framework.md` (workflow commit `f388be8c2379ac6a8959516b486af31c99423bb0`).  
I have not seen Design A or Design B. This dossier works only from verified package facts and marks missing facts as profiling gaps. No production SQL or production R is written.

---

## 1. Source-to-concept map

| Concept required by locked question | Exact source mapping | Status | Notes / limits |
|---|---|---|---|
| Product | `raw_sales_evaluation.item_id`; hierarchy via `raw_sales_evaluation.dept_id`, `raw_sales_evaluation.cat_id`; also `raw_sell_prices.item_id` | Verified source field | Product is at item level. No brand/size/package attributes. |
| Pilot store | `raw_sales_evaluation.store_id`; `raw_sell_prices.store_id`; `raw_sales_evaluation.state_id` | Verified source field | Candidate mapping is `CA_1`, but final store scope must be locked. |
| Aisle / department | `raw_sales_evaluation.dept_id`; category via `raw_sales_evaluation.cat_id` | Verified source field | Department mapping is open to analyst proposal. `raw_sell_prices` has no `dept_id`; must join through item. |
| Daily units | `raw_sales_evaluation.sales_history` JSON array, positions 0…1940, mapped to `raw_calendar.d` d_1…d_1941 | Verified source field, requires mechanical unnesting | Array length is 1,941 for every row. Zeros are not stockout diagnoses. Items may have leading zeros before stocked. |
| Shelf price | `raw_sell_prices.sell_price` at grain `store_id × item_id × wm_yr_wk` | Verified source field | Weekly price. Not balanced. Missing price is never zero. Discounts inferred, not labeled. |
| Current price | Candidate source: `raw_sell_prices.sell_price` for `store_id + item_id + wm_yr_wk = 11617`, because decision date 2016-05-22 is inside week 11617 | Requires locked definition | Week 11617 straddles the decision date. Final rule must lock whether current price is week 11617 or prior completed week 11616. |
| Price change | Derived from ordered `raw_sell_prices.sell_price` over `wm_yr_wk` per `store_id + item_id` | Derived, not a source column | No price-change reason, promotion label, or markdown flag. |
| Event / holiday / SNAP | `raw_calendar.event_name_1`, `raw_calendar.event_type_1`, `raw_calendar.event_name_2`, `raw_calendar.event_type_2`, `raw_calendar.snap_CA` | Verified source fields | Blank event fields are normal. `snap_CA` is 0/1. Horizon SNAP days are known from calendar. |
| 28-day horizon | `raw_calendar.d`, `raw_calendar.date`, `raw_calendar.wm_yr_wk` for d_1942–d_1969 = 2016-05-23 to 2016-06-19, weeks 11617–11621 | Calendar verified; horizon sales unavailable | Horizon sales are not in `raw_sales_evaluation`, which ends at d_1941. |
| Expected units | Not a source field; must be model output from R-A / R-B | Unavailable as source | Requires locked prediction unit, target, model, features, training window, and horizon aggregation. |
| Expected revenue | Not a source field; derived as expected units × shelf price at current or candidate price | Unavailable as source | No cost/margin. Revenue is the only defensible outcome. |
| Trusted evidence | Not a single source field; composite of price movement, sales volume, and forward expectation not being a guess | Unavailable as source | Must be constructed in R-A / R-B from source fields, derived metrics, and locked trust gate. |

---

## 2. Key and cardinality map for plausible joins

| Join | Left grain / right grain | Join keys | Expected relationship | Multiplicity / risk / control |
|---|---|---|---|---|
| Sales series ↔ calendar via JSON position | `raw_sales_evaluation` series row × 1,941 JSON positions → item-day; `raw_calendar` day | Unnested position `i` → `d_{i+1}`; `raw_calendar.d` | One series row → 1,941 item-day rows; each item-day → one calendar day | Many-to-one from item-day to calendar. Risk: wrong position-to-`d` offset. Control: position 0 = d_1; position 1940 = d_1941; JSON_LENGTH = 1,941 verified for all rows. |
| Calendar ↔ sell_prices via `wm_yr_wk` | Calendar day; sell_price store-item-week | `raw_calendar.wm_yr_wk` = `raw_sell_prices.wm_yr_wk` | Direct join is many-to-many: many days per week × many store-item price rows per week | Risk: huge multiplication if joined directly. Control: aggregate to week or attach weekly price to item-day after mapping day→week. Weeks have 7 days except week 11621 has 2 days. |
| Sales item-day ↔ sell_prices | Item-day; store-item-week price | `store_id + item_id + wm_yr_wk` | Item-day → at most one sell_price row if price row exists; many-to-one when price exists | Risk: unbalanced price panel; missing price rows cause inner-join loss. Control: left join or deliver price rows separately; missing price is not zero; audit unmatched item-days. At CA_1, no internal gaps between first and last priced week; every CA_1 item has price row in 11616 and 11617. |
| `raw_sales_evaluation` ↔ `raw_sell_prices` via `store_id + item_id` alone | Series; price week rows | `store_id + item_id` | Many-to-many across weeks | Not a valid direct join. Must include `wm_yr_wk`. |
| `raw_calendar.date` ↔ `raw_calendar.d` | Day; day key | `date` ↔ `d` | One-to-one | `d` is unique: 1,969 distinct. |
| `raw_calendar.wm_yr_wk` ↔ week | Day; week | `wm_yr_wk` | Many-to-one | 282 distinct weeks; last week 11621 has 2 days. |
| `raw_sales_evaluation.id` | Series | `id` | Unique | 30,490 rows, 30,490 unique. |
| `raw_sales_evaluation.item_id + store_id` | Product-store series | `item_id + store_id` | One per product-store series | Package states one row per product-store series (3,049 items × 10 stores). |
| `raw_sell_prices` key | Store-item-week | `store_id + item_id + wm_yr_wk` | Unique | 6,841,121 rows = 6,841,121 distinct keys. |

---

## 3. Missingness and anomaly summary

| Issue | Verified facts | Risk / impact | Required treatment / audit |
|---|---|---|---|
| Unbalanced price panel | `raw_sell_prices` has price rows only for weeks a product-store was on sale. Missing price is never zero. At CA_1, no internal gap between first and last priced week. Every CA_1 item has price row in 11616 and 11617. | Inner joins can drop item-days. Missing price could be mistaken for zero or for no demand. | Preserve missing price as missing. Audit unmatched item-days by item/week. Do not forward-fill unless locked in R and disclosed. |
| Leading zero sales before item stocked | `sales_history` can contain leading zeros; items may have leading zeros before stocked. | Eligibility and price-response model can treat pre-stock days as real zero demand. | Detect leading zero runs and align with first priced week. Audit first nonzero sales day and first priced week. |
| Zero-sales days | Zeros are not stockout diagnoses; no inventory data. | Zero days can be true zero demand, out-of-stock, or not stocked. Model may learn false price response. | Preserve zeros but flag. Profiling gap: per-item zero-day share before decision date. |
| $0.01 prices | Minimum `sell_price` is $0.01; HOUSEHOLD_1 range includes $0.01. | Could be valid clearance, placeholder, or data anomaly. | Retain and flag until profiled. Audit count of $0.01 prices and sales during those weeks. |
| Partial week 11621 | Week 11621 has 2 days: 2016-06-18/19. Horizon includes it. | Weekly price may be applied to only 2 days; aggregation must use 28 calendar days, not 4 full weeks. | Use calendar days for horizon. Confirm sell_price rows for 11621. |
| Week 11617 straddle | Week 11617 = 2016-05-21 to 2016-05-27; decision date = 2016-05-22. | Current price, horizon price, and training window can be confused. Using post-decision prices leaks. | Lock current-price definition. Exclude future observed price changes from features. |
| Varchar typing | All value columns are stored as varchar unless noted. | Lexical comparisons, bad casts, leading/trailing spaces, wrong numeric ordering. | Cast mechanically in SQL or R to integer/decimal/date. SQL Source Gate must verify domains and casts. |
| Blank event fields | Event blanks are normal. 162 days have event_name_1; 5 have event_name_2. | Blank may be miscoded as missing/unknown. | Treat blank as no event. Audit blank counts. |
| JSON array length | `JSON_LENGTH(sales_history)` = 1,941 for every row. | Unnesting errors can shift dates or lose days. | Verify exact length and position mapping. |

---

## 4. Unavailable-field list

| Unavailable concept | Source status | What it prevents |
|---|---|---|
| Cost | Not in package | Prevents margin, profit, contribution, and cost-based guardrails. Decision must remain revenue-only. |
| Inventory | Not in package | Prevents stockout diagnosis, availability correction, and true lost-sales estimation. |
| Stockout | Not in package | Prevents distinguishing zero sales due to no demand from zero sales due to empty shelf. |
| Competitor prices | Not in package | Prevents competitive response, relative price positioning, cross-price effects, and market-share explanations. |
| Promotion labels | Not in package | Prevents separating promotional price cuts from permanent price changes, ads, displays, or coupons. Discounts are inferred only. |
| Price-change reason | Not in package | Prevents knowing whether a price move was clearance, cost pass-through, promo, or strategic. |
| Product attributes | Only `item_id`, `dept_id`, `cat_id` | Prevents brand, size, pack, perishability, substitute/complement structure. |
| Shelf space / facings | Not in package | Prevents shelf-availability and merchandising confounders. |
| Store traffic / customer counts | Not in package | Prevents traffic normalization and basket-context controls. |
| Weather | Not in package | Prevents weather confounders for grocery demand. |
| Local demographics / income | Not in package | Prevents heterogeneity controls beyond store and department. |
| Supply chain / lead time | Not in package | Prevents supply-driven price and availability explanations. |
| Actual SNAP redemption | Only `snap_CA` day flag | Prevents measuring actual benefit redemption or household-level SNAP response. |
| Known price elasticity | Not in package | Prevents validating model extrapolation against established elasticity ranges. |

---

## 5. Leakage and temporal-risk list

| Risk ID | Risk | Mechanism | Detection | Prevention |
|---|---|---|---|---|
| L01 | Horizon prices in weeks 11617–11621 | `raw_sell_prices` includes future weeks after decision date. Using 11618–11621 prices as features or targets leaks future price changes. | Check feature extraction window excludes weeks after 11617 except for locked current-price use. | Deliver/use sell_prices only through week 11617 for features/current price. Do not use future observed prices. |
| L02 | Week 11617 straddles decision date | Week 11617 includes 2016-05-21 to 05-27; decision date is 2016-05-22. It contains both pre-decision and horizon days. | Audit item-days in d_1941 and d_1942 by week. | Lock current-price definition: week 11617 vs 11616. If week 11617 is current, treat as known at decision date. Do not treat its horizon days as observed outcomes. |
| L03 | Decision date mid-week | Weekly price grain does not align with daily sales. | Check day-of-week and week-key alignment. | Map each item-day to its `wm_yr_wk`. Lock weekly price alignment rule. |
| L04 | Future calendar features known vs not | Holidays, events, and SNAP days are calendar-known in advance; actual demand is not. | Confirm feature set uses only calendar fields known at decision date. | Use future calendar features only if known in advance. Do not use future sales. |
| L05 | Target/feature leakage in backtests | Backtest may accidentally use prices or sales after pseudo-decision date. | Audit training/validation boundary at pseudo-decision date. | Use temporal split. Training window ends at pseudo-decision date. Validation horizon begins after. |
| L06 | Pseudo-decision-date choice | Any backtest must use an earlier pseudo-decision date. Choice can change results. | Check pseudo-date is locked before training. | Lock pseudo-decision date, training window, validation window, and pass/fail criteria before model runs. |
| L07 | Candidate price construction using future prices | Using horizon prices to set candidate price leaks future information. | Audit candidate-price method against pre-decision price history only. | Build candidate prices only from pre-decision observed prices and locked rules. |
| L08 | Future price changes as features | Model may use a price change that occurs after decision date. | Audit price-change event dates ≤ decision date. | Compute price changes only up to week 11617. |
| L09 | Horizon sales | Horizon sales d_1942–d_1969 are not in data. | Confirm no attempt to use them. | Expected units must be model predictions, not observed. |
| L10 | Partial week 11621 | Horizon ends mid-week in week 11621. | Check aggregation uses 28 calendar days. | Aggregate by day, not by full week. |
| L11 | SNAP schedule | `snap_CA` future days are known in calendar. | Confirm future SNAP flags come from calendar, not inferred. | Use calendar `snap_CA` for horizon. |
| L12 | Price endogeneity | Observed price changes may respond to past sales, confounding price response. | Inspect price-change timing vs prior sales. | Disclose as observational/predictive ceiling; use temporal validation; sensitivity tests. |

---

## 6. Measurement-risk register

Framework §18 fields. Statuses: Resolved, Accepted, Open, Blocking, Deferred.

### 6A. SQL delivery risks

| Risk ID | Design component | Failure mode | Likelihood | Decision impact | Detection control | Prevention control | Sensitivity test | Residual risk | Status |
|---|---|---|---|---|---|---|---|---|---|
| SQL-01 | Source envelope | Wrong store or department rows delivered | Medium | Wrong product universe | Row counts by store/dept vs source | Lock envelope; Source Gate | Compare alternative dept envelopes | Unlocked dept mapping | Blocking until dept mapping locked |
| SQL-02 | JSON unnesting | Position-to-date shift or lost days | Medium | Wrong daily units and price joins | JSON_LENGTH=1941; position map; row count = series × 1941 | Mechanical unnest with fixed mapping | Rebuild from raw for sample series | JSON parsing edge cases | Open |
| SQL-03 | Price join | Duplicate price rows or dropped item-days | Medium | Wrong price response and revenue | Key uniqueness; join multiplicity; unmatched count | Join on `store_id+item_id+wm_yr_wk`; left join | Compare inner vs left join counts | Missing price treatment | Open |
| SQL-04 | Calendar join | Wrong `wm_yr_wk`, `wday`, SNAP | Medium | Wrong seasonality and horizon features | Date coverage; domain checks | Cast and map `d` exactly | Compare week 11617/11621 day counts | Partial week | Open |
| SQL-05 | Varchar casts | Lexical ordering or bad numeric values | Medium | Wrong prices and units | Domain checks; min/max; null/blank profile | Cast to numeric/date; reject blanks | Compare string vs numeric sort | Hidden blanks | Open |
| SQL-06 | Future price rows | Delivered weeks after 11617 | Medium | Look-ahead leakage | Check max `wm_yr_wk` delivered | Bound sell_prices to ≤11617 | Exclude future weeks and rerun | Week 11617 straddle | Open |
| SQL-07 | Lineage | Extract not tied to source freeze | Medium | Reconciliation cannot be trusted | `snapshot_id`, source version, boundary | Mandatory lineage fields | Re-extract with same metadata | No source lineage columns in package | Blocking until Stage 4 metadata defined |

### 6B. R translation risks

| Risk ID | Design component | Failure mode | Likelihood | Decision impact | Detection control | Prevention control | Sensitivity test | Residual risk | Status |
|---|---|---|---|---|---|---|---|---|---|
| R-01 | Eligibility | Different cutoffs for “price moved” or “barely sells” | High | Different product universe | Audit counts of included/excluded | Lock exact cutoffs and stage | Vary cutoffs | Analyst judgment | Blocking until cutoffs locked |
| R-02 | Trust gate | Untrusted expectations ranked as trusted | High | Bad price change to GM | Audit trust flags | Lock trust definition and thresholds | Loosen/tighten trust gate | No uncertainty field | Blocking until trust gate locked |
| R-03 | Current price | R-A and R-B choose different current week | High | Wrong revenue baseline | Compare current-price fields | Lock week 11617 vs 11616 | Use alternative current-price definition | Week 11617 straddle | Blocking until locked |
| R-04 | Candidate price | Different candidate prices constructed | High | Different actions and ranks | Compare candidate-price tables | Lock construction method | Alternative ±% rules | Extrapolation | Blocking until locked |
| R-05 | KPI aggregation | Units/revenue aggregated over wrong days | Medium | Wrong ranking | Compare 28-day totals | Lock horizon d_1942–d_1969 | Daily vs weekly aggregation | Partial week 11621 | Open |
| R-06 | Guardrail “about 10%” | Different rejection rule | Medium | Unwanted unit loss | Audit rejected items | Lock exact threshold | Test 5%, 10%, 15% | Stakeholder said “about” | Open |
| R-07 | Capacity “about 25” | Padding or different selection | Medium | Wrong GM package | Audit membership and selected count | Lock membership-first, no-pad | Vary capacity | Stakeholder said “about” | Open |
| R-08 | Ranking/tie-break | Different order | Medium | Wrong top 25 | Compare ranks | Lock ranking key and tie-break | Alternative tie-breaks | Ties | Open |
| R-09 | Minimum-gain rule | Undisclosed threshold | Low | Changes list | Check disclosure | Lock or explicitly state none | None vs small threshold | Analyst option | Open |
| R-10 | Leakage in R | Future prices used as features | Medium | Overstated performance | Feature-window audit | Use only ≤11617 | Exclude future weeks | Complex lags | Open |
| R-11 | Backtest | No pseudo-decision date or wrong window | Medium | Invalid validation | Audit split dates | Lock pseudo-date and windows | Multiple pseudo-dates | Historical regime | Open |
| R-12 | Reconciliation | R-A and R-B differ silently | Medium | Unverified outputs | Exact key/action/rank comparison | Locked output schema and tolerance | Re-run reconciliation | Stochastic model | Open |

### 6C. Model-related risks for parsnip price-response model

| Risk ID | Model risk | Failure mode | Likelihood | Decision impact | Detection control | Prevention control | Sensitivity test | Residual risk | Status |
|---|---|---|---|---|---|---|---|---|---|
| M-01 | Extrapolation beyond observed prices | Candidate price outside historical range | High | Unreliable units/revenue | Compare candidate vs observed min/max | Restrict candidate to observed range or flag extrapolation | Limit candidate to historical range | Business may want new price | Blocking until candidate rule locked |
| M-02 | Few price changes | Model learns little price response | High | Untrusted estimates | Count price changes per item | Eligibility requires “at least a few” changes | Vary minimum changes | Some items excluded | Blocking until cutoff locked |
| M-03 | Confounded price variation | Price changes correlate with season, promos, events | High | Biased price effect | Include calendar controls; inspect timing | Use pre-decision controls; disclose | Add/remove controls | No promo labels | Open |
| M-04 | Zero-sales inflation | Many zeros distort model | Medium | Wrong expected units | Zero-day share profile | Model choice or transformation | Zero-inflated vs linear | No stockout data | Open |
| M-05 | Missing price weeks | Model treats missing as zero or drops rows | Medium | Wrong price series | Join-failure audit | Preserve missing; lock treatment | Drop vs impute | Unbalanced panel | Open |
| M-06 | Price endogeneity | Past sales influence price changes | Medium | Causal interpretation invalid | Price-change timing audit | Predictive ceiling only | Lagged features | Observational data | Accepted |
| M-07 | Stochastic model reconciliation | R-A and R-B differ due to randomness | Medium | No exact reconciliation | Compare `.pred` | Use deterministic engine or lock seeds/tolerance | Re-run with same seed | Floating point | Open |
| M-08 | Horizon feature construction | Wrong `wday` coding (Sat=1) or SNAP | Medium | Wrong expected units | Compare feature tables | Lock calendar mappings | Rebuild from calendar | Coding error | Open |

---

## 7. Targeted profiling gaps

| Gap ID | Missing fact | Exact aggregate needed | Why needed |
|---|---|---|---|
| P-01 | Per-item sales-volume distribution | For each `store_id, item_id` at CA_1 in candidate depts: mean, median, p10/p25/p75/p90 daily units before decision date; total units in last 28/52/104 weeks; zero-day share; leading-zero count; first nonzero sales `d` | Eligibility “sells steadily enough”; trust gate; model stability. |
| P-02 | Price-change distribution | For each `store_id, item_id`: count distinct `sell_price`; count price changes vs prior priced week; first/last priced week; number of priced weeks; distribution of price-change magnitudes (absolute and relative) before decision date | Eligibility “price changed at least a few times”; candidate-price construction; model training. |
| P-03 | Missing price weeks | For each CA_1 item: first priced `wm_yr_wk`; last priced `wm_yr_wk`; count weeks before first with no price; count weeks after last; confirm no internal gaps between first and last | Join loss and eligibility. |
| P-04 | $0.01 price anomaly | Count `sell_price = 0.01` rows at CA_1 by dept, item, `wm_yr_wk`; units sold in those item-weeks | Decide retain/flag/exclude. |
| P-05 | Week 11617 straddle | Count sales item-days in d_1941 and d_1942 by `wm_yr_wk`; confirm price row for 11617 for all CA_1 items | Current-price definition and leakage control. |
| P-06 | Week 11621 partial | Confirm `raw_sell_prices` rows for `wm_yr_wk = 11621` for CA_1 items; count calendar days = 2 | Horizon aggregation. |
| P-07 | Department mapping | Distinct `dept_id`, `cat_id` at CA_1 with item counts, price-change counts, 4+ distinct price counts, avg priced weeks | Lock pilot scope: everyday grocery and household. |
| P-08 | Event/SNAP distribution | Counts of `event_name_1`, `event_type_1`, `event_name_2`, `event_type_2`, `snap_CA` by date and by dept/item sales | Horizon feature construction and confounder control. |
| P-09 | Candidate pseudo-decision dates | For candidate earlier pseudo-decision dates: count eligible items with sufficient price history and sales; count price rows and sales coverage before and after | Backtest design and validation. |
| P-10 | Price-change timing vs events | Cross-tab of price changes by week, event, SNAP, and dept before decision date | Confounding and model feature design. |
| P-11 | Model engine determinism | For proposed parsnip engine: whether fit/predict is deterministic; required seeds; numerical tolerance | R-A/R-B exact reconciliation. |

---

## 8. SQL source-delivery requirements

### 8.1 Smallest faithful source envelope

| Envelope element | Required source | Grain | Notes |
|---|---|---|---|
| Sales series | `raw_sales_evaluation` filtered to `store_id = 'CA_1'` and locked department envelope | One row per product-store series | Deliver `id`, `item_id`, `dept_id`, `cat_id`, `store_id`, `state_id`, `sales_history`. |
| Daily sales | Unnested `sales_history` to item-day | One row per item-day for d_1–d_1941 | Must preserve exact position mapping. |
| Calendar | `raw_calendar` for d_1–d_1969 | One row per day | Needed for history and horizon. |
| Weekly price | `raw_sell_prices` filtered to `store_id = 'CA_1'`, items in envelope, `wm_yr_wk <= 11617` | One row per store-item-week | Exclude future weeks 11618–11621 to prevent leakage. Include 11617 for current-price candidate. |
| Lineage metadata | Assigned by Stage 4 extract, not a source column | Extract-level | `snapshot_id`, `source_version`, extraction boundary. |

### 8.2 Mechanical SQL vs R-A / R-B judged logic

| Transformation | Where it belongs | Reason |
|---|---|---|
| Filter `store_id = 'CA_1'` and locked department envelope | SQL | Mechanical envelope restriction. |
| Unnest `sales_history` JSON to item-day rows | SQL | Mechanical array expansion with fixed position-to-`d` map. |
| Cast varchar to integer/decimal/date | SQL | Mechanical typing. |
| Bound calendar to d_1–d_1969 | SQL | Mechanical date bounding. |
| Join item-day to calendar on `d` | SQL | Mechanical enrichment. |
| Attach weekly `sell_price` by `store_id + item_id + wm_yr_wk` | SQL | Mechanical join, preserving missing as NULL. Do not impute or forward-fill. |
| Exclude future `sell_prices` weeks >11617 | SQL | Mechanical leakage envelope. |
| Eligibility rules | R-A / R-B | Judged analytical rule. |
| Trust gate | R-A / R-B | Judged evidence gate. |
| Price-change derivation and features | R-A / R-B | Judged analytical feature construction. |
| Current-price selection | R-A / R-B | Judged temporal rule. |
| Candidate-price construction | R-A / R-B | Judged analytical choice. |
| Model training / scoring | R-A / R-B | Mode A judged predictive contract. |
| Expected units/revenue KPI | R-A / R-B | Judged metric aggregation. |
| Actions, ranking, capacity, no-pad | R-A / R-B | Judged decision rule. |
| Fixtures and reconciliation | R-A / R-B + Stage 4 | Not SQL source logic. |

---

## 9. SQL-versus-R boundary risks and SQL Source Gate evidence required

| Boundary risk | Why it matters | SQL Source Gate evidence required |
|---|---|---|
| Envelope coverage | Missing or extra stores/departments change universe | Row counts by `store_id`, `dept_id`; list of distinct dept values; item counts. |
| JSON unnesting correctness | Wrong position shifts dates and price joins | `JSON_LENGTH = 1941` for every series; unnest row count = series count × 1941; position-to-`d` spot checks and full multiset checksum if possible. |
| Key uniqueness | Duplicate series or price rows multiply outputs | `raw_sales_evaluation.id` unique; `raw_sell_prices` key unique; `raw_calendar.d` unique. |
| Join multiplicity | Item-day ↔ price join must not duplicate | Count item-day rows; count matched price rows; assert ≤1 price row per item-day; count unmatched. |
| Critical-field equality | Delivered values must match source | Compare item_id, dept_id, store_id, sales_history values, sell_price, date, wm_yr_wk, event, snap. |
| Domains | Bad values break model | Sales nonnegative integers; sell_price >0 and min $0.01; wday coding Sat=1…Fri=7; snap_CA 0/1; event blanks allowed. |
| Date coverage | Wrong window breaks horizon/backtest | Sales d_1–d_1941; calendar d_1–d_1969; sell_prices ≤11617; week 11621 = 2 days. |
| Missing price preservation | Missing price is not zero | Count NULL sell_price after left join; no imputation in SQL. |
| Future price exclusion | Prevents leakage | Max delivered `wm_yr_wk` ≤11617; no 11618–11621 price rows. |
| Lineage | Reconciliation must tie to same freeze | `snapshot_id`, `source_version`, extraction/observation boundary in both R outputs. |
| Department mapping | Unlocked mapping can change universe | Gate must record the exact dept list used in extract. |
| Varchar casts | Lexical errors | Compare cast vs raw for min/max, sample rows, blanks. |

---

## 10. Implementability verdict for each required design component in package §C

| Required Stage 3 component | Verdict | Conditions / blocking gaps |
|---|---|---|
| `ml_mode` and Mode A lock fields | Implementable with conditions | Package says Mode A expected. Must lock prediction unit, target, allowed/forbidden features, leakage rules, temporal split, training window, parsnip model class/engine, evaluation metrics, threshold→action mapping, reconciliation-critical fields, fixtures. |
| Eligibility rule | Implementable with conditions | Must lock “price changed at least a few times” and “sells steadily enough” cutoffs. Needs P-01 and P-02. |
| Department mapping | Implementable with conditions | Must lock pilot scope. Candidate depts likely FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2; HOBBIES exist but are not everyday grocery/household. Needs P-07. |
| “Trusted” evidence gate | Implementable with conditions | Must lock price-movement test, volume test, and “forward expectation not a guess” test. Needs P-01, P-02, model validation. |
| Candidate pilot-price construction | Implementable with conditions | Must lock method and candidate range. Extrapolation risk if outside observed prices. Needs P-02. |
| Parsnip model specification | Implementable with conditions | Must lock model family, engine, formula/recipe, features, hyperparameters, deterministic settings. Needs P-11. |
| Training window | Implementable with conditions | Must lock window end at decision date or pseudo-decision date. Exclude future prices/sales. Needs P-09. |
| KPI formulas: expected units and revenue at current vs candidate price over 28 days | Implementable | Must lock horizon d_1942–d_1969, current price, candidate price, aggregation. Data supports calendar; expected units are model output. |
| Operational treatment of “about 10%” | Implementable with conditions | Must lock exact unit guardrail (e.g., reject if expected units < 90% of current). Stakeholder said “about.” |
| Operational treatment of “about 25” | Implementable with conditions | Must lock capacity rule: up to about 25 actual changes, no padding, holds excluded. |
| Ranking key, tie-break, membership-first/no-pad | Implementable with conditions | Must lock full analytical-unit universe, membership-first, rank by trusted expected revenue gain, tie-break. |
| Minimum-gain rule | Implementable with conditions | Analyst option. Must either lock a disclosed threshold or explicitly state none. |
| Current-price definition at decision date | Implementable with conditions | Must lock week 11617 vs 11616. Week 11617 straddles decision date. Needs P-05. |
| Horizon feature construction | Implementable | Calendar, event, SNAP, wday known in advance. Must lock Sat=1 coding and SNAP mapping. |
| Leakage control | Implementable with conditions | Must exclude future prices and sales; use pre-decision features only. Needs P-05, P-09. |
| Backtest at earlier pseudo-decision date and validation criteria | Implementable with conditions | Must lock pseudo-date, training/validation windows, metrics, pass/fail. Needs P-09. |
| Controlled SQL source contract | Implementable with conditions | Must lock envelope, keys, fields, lineage, mechanical transformations, prohibited judged logic. |
| SQL Source Gate handoff | Implementable with conditions | Must lock row coverage, multiplicity, critical-field equality, domains, date coverage, lineage. |
| R-A / R-B judged-output contract | Implementable with conditions | Must lock decision grain, keys, eligibility, trust, actions, ranking, audit fields, lineage. |
| R-A vs R-B exact reconciliation | Implementable with conditions | For stochastic-free parsnip model, exact reconciliation is feasible if engine, formula, preprocessing, hyperparameters, and data are identical. If any stochastic step exists, lock seeds, engine version, deterministic settings, and numeric tolerance. |
| Known-case fixtures | Implementable with conditions | Must freeze fixtures before R builders run. Must include cases that fail if trust gate, guardrail, capacity, or no-pad are omitted. |
| Lineage contract | Implementable with conditions | Source tables lack lineage columns; Stage 4 must assign extract metadata and carry it into both R outputs. |
| Overall Stage 3 design | Implementable with conditions | Not implementable as-is until: department mapping, eligibility cutoffs, trust gate, current-price rule, candidate-price rule, model locks, pseudo-decision date, guardrail/capacity/tie-break, and SQL Source Gate are locked. No component is inherently infeasible from verified data facts; several are blocked on missing locks and targeted profiling. |
---

# PART D — TARGETED PROFILING (coordinator, read-only aggregates)

## D1. design_profile_01.sql
```sql
-- PRICEPOINT-001 Stage 3 targeted profiling (read-only aggregates, no staging)
SELECT 'Q1_price_key_dupes' q, COUNT(*) n_rows, COUNT(DISTINCT store_id,item_id,wm_yr_wk) n_keys FROM raw_sell_prices;
SELECT 'Q2_series' q, COUNT(*) n, COUNT(DISTINCT id) n_id, MIN(JSON_LENGTH(sales_history)) minlen, MAX(JSON_LENGTH(sales_history)) maxlen FROM raw_sales_evaluation;
SELECT 'Q3_cal' q, COUNT(*) n, COUNT(DISTINCT d) nd, MIN(date) mn, MAX(date) mx, COUNT(DISTINCT wm_yr_wk) nwk FROM raw_calendar;
SELECT 'Q4_cal_wk_days' q, wm_yr_wk, COUNT(*) days, MIN(date), MAX(date) FROM raw_calendar WHERE CAST(wm_yr_wk AS UNSIGNED) IN (11101,11612,11613,11614,11615,11616,11617,11618,11619,11620,11621) GROUP BY wm_yr_wk ORDER BY wm_yr_wk;
SELECT 'Q5_ca1_price_by_dept' q, s.dept_id, COUNT(*) price_rows, MIN(CAST(p.sell_price AS DECIMAL(10,2))) mn, MAX(CAST(p.sell_price AS DECIMAL(10,2))) mx, SUM(p.sell_price IS NULL OR p.sell_price='') blank
 FROM raw_sell_prices p JOIN raw_sales_evaluation s ON s.store_id=p.store_id AND s.item_id=p.item_id WHERE p.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q6_ca1_current_price_wk11617' q, s.dept_id, COUNT(*) items, SUM(p.item_id IS NOT NULL) priced_11617
 FROM raw_sales_evaluation s LEFT JOIN raw_sell_prices p ON p.store_id=s.store_id AND p.item_id=s.item_id AND p.wm_yr_wk='11617' WHERE s.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q7_ca1_priced_11616' q, s.dept_id, COUNT(*) items, SUM(p.item_id IS NOT NULL) priced_11616
 FROM raw_sales_evaluation s LEFT JOIN raw_sell_prices p ON p.store_id=s.store_id AND p.item_id=s.item_id AND p.wm_yr_wk='11616' WHERE s.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q8_ca1_price_gaps' q, dept_id, SUM(gap) items_with_internal_gaps FROM (
 SELECT s.dept_id, s.item_id, (MAX(CAST(p.wm_yr_wk AS UNSIGNED))-MIN(CAST(p.wm_yr_wk AS UNSIGNED))) AS span, COUNT(*) n,
 CASE WHEN COUNT(*) < (SELECT COUNT(DISTINCT c.wm_yr_wk) FROM raw_calendar c WHERE CAST(c.wm_yr_wk AS UNSIGNED) BETWEEN MIN(CAST(p.wm_yr_wk AS UNSIGNED)) AND MAX(CAST(p.wm_yr_wk AS UNSIGNED))) THEN 1 ELSE 0 END gap
 FROM raw_sell_prices p JOIN raw_sales_evaluation s ON s.store_id=p.store_id AND s.item_id=p.item_id WHERE p.store_id='CA_1' GROUP BY s.dept_id, s.item_id) t GROUP BY dept_id ORDER BY dept_id;
SELECT 'Q9_cal_events_snap' q, SUM(event_name_1<>'') ev1, SUM(event_name_2<>'') ev2, SUM(snap_CA='1') snapca, COUNT(*) n FROM raw_calendar;
SELECT 'Q10_horizon_events' q, date, weekday, wday, event_name_1, event_type_1, event_name_2, snap_CA FROM raw_calendar WHERE CAST(SUBSTRING(d,3) AS UNSIGNED) BETWEEN 1942 AND 1969 AND (event_name_1<>'' OR snap_CA='1') ORDER BY date;
```
## D1 output
```
+--------------------+---------+---------+
| q                  | n_rows  | n_keys  |
+--------------------+---------+---------+
| Q1_price_key_dupes | 6841121 | 6841121 |
+--------------------+---------+---------+
+-----------+-------+-------+--------+--------+
| q         | n     | n_id  | minlen | maxlen |
+-----------+-------+-------+--------+--------+
| Q2_series | 30490 | 30490 |   1941 |   1941 |
+-----------+-------+-------+--------+--------+
+--------+------+------+------------+------------+-----+
| q      | n    | nd   | mn         | mx         | nwk |
+--------+------+------+------------+------------+-----+
| Q3_cal | 1969 | 1969 | 2011-01-29 | 2016-06-19 | 282 |
+--------+------+------+------------+------------+-----+
+----------------+----------+------+------------+------------+
| q              | wm_yr_wk | days | MIN(date)  | MAX(date)  |
+----------------+----------+------+------------+------------+
| Q4_cal_wk_days | 11101    |    7 | 2011-01-29 | 2011-02-04 |
| Q4_cal_wk_days | 11612    |    7 | 2016-04-16 | 2016-04-22 |
| Q4_cal_wk_days | 11613    |    7 | 2016-04-23 | 2016-04-29 |
| Q4_cal_wk_days | 11614    |    7 | 2016-04-30 | 2016-05-06 |
| Q4_cal_wk_days | 11615    |    7 | 2016-05-07 | 2016-05-13 |
| Q4_cal_wk_days | 11616    |    7 | 2016-05-14 | 2016-05-20 |
| Q4_cal_wk_days | 11617    |    7 | 2016-05-21 | 2016-05-27 |
| Q4_cal_wk_days | 11618    |    7 | 2016-05-28 | 2016-06-03 |
| Q4_cal_wk_days | 11619    |    7 | 2016-06-04 | 2016-06-10 |
| Q4_cal_wk_days | 11620    |    7 | 2016-06-11 | 2016-06-17 |
| Q4_cal_wk_days | 11621    |    2 | 2016-06-18 | 2016-06-19 |
+----------------+----------+------+------------+------------+
+----------------------+-------------+------------+------+-------+-------+
| q                    | dept_id     | price_rows | mn   | mx    | blank |
+----------------------+-------------+------------+------+-------+-------+
| Q5_ca1_price_by_dept | FOODS_1     |      52156 | 0.97 | 12.98 |     0 |
| Q5_ca1_price_by_dept | FOODS_2     |      90747 | 0.64 | 13.98 |     0 |
| Q5_ca1_price_by_dept | FOODS_3     |     186763 | 0.20 | 19.48 |     0 |
| Q5_ca1_price_by_dept | HOBBIES_1   |      96737 | 0.10 | 30.98 |     0 |
| Q5_ca1_price_by_dept | HOBBIES_2   |      32892 | 0.05 |  9.97 |     0 |
| Q5_ca1_price_by_dept | HOUSEHOLD_1 |     117067 | 0.01 | 29.97 |     0 |
| Q5_ca1_price_by_dept | HOUSEHOLD_2 |     122050 | 0.75 | 26.88 |     0 |
+----------------------+-------------+------------+------+-------+-------+
+------------------------------+-------------+-------+--------------+
| q                            | dept_id     | items | priced_11617 |
+------------------------------+-------------+-------+--------------+
| Q6_ca1_current_price_wk11617 | FOODS_1     |   216 |          216 |
| Q6_ca1_current_price_wk11617 | FOODS_2     |   398 |          398 |
| Q6_ca1_current_price_wk11617 | FOODS_3     |   823 |          823 |
| Q6_ca1_current_price_wk11617 | HOBBIES_1   |   416 |          416 |
| Q6_ca1_current_price_wk11617 | HOBBIES_2   |   149 |          149 |
| Q6_ca1_current_price_wk11617 | HOUSEHOLD_1 |   532 |          532 |
| Q6_ca1_current_price_wk11617 | HOUSEHOLD_2 |   515 |          515 |
+------------------------------+-------------+-------+--------------+
+---------------------+-------------+-------+--------------+
| q                   | dept_id     | items | priced_11616 |
+---------------------+-------------+-------+--------------+
| Q7_ca1_priced_11616 | FOODS_1     |   216 |          216 |
| Q7_ca1_priced_11616 | FOODS_2     |   398 |          398 |
| Q7_ca1_priced_11616 | FOODS_3     |   823 |          823 |
| Q7_ca1_priced_11616 | HOBBIES_1   |   416 |          416 |
| Q7_ca1_priced_11616 | HOBBIES_2   |   149 |          149 |
| Q7_ca1_priced_11616 | HOUSEHOLD_1 |   532 |          532 |
| Q7_ca1_priced_11616 | HOUSEHOLD_2 |   515 |          515 |
+---------------------+-------------+-------+--------------+
+-------------------+-------------+--------------------------+
| q                 | dept_id     | items_with_internal_gaps |
+-------------------+-------------+--------------------------+
| Q8_ca1_price_gaps | FOODS_1     |                        0 |
| Q8_ca1_price_gaps | FOODS_2     |                        0 |
| Q8_ca1_price_gaps | FOODS_3     |                        0 |
| Q8_ca1_price_gaps | HOBBIES_1   |                        0 |
| Q8_ca1_price_gaps | HOBBIES_2   |                        0 |
| Q8_ca1_price_gaps | HOUSEHOLD_1 |                        0 |
| Q8_ca1_price_gaps | HOUSEHOLD_2 |                        0 |
+-------------------+-------------+--------------------------+
+--------------------+------+------+--------+------+
| q                  | ev1  | ev2  | snapca | n    |
+--------------------+------+------+--------+------+
| Q9_cal_events_snap |  162 |    5 |    650 | 1969 |
+--------------------+------+------+--------+------+
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
| q                  | date       | weekday   | wday | event_name_1   | event_type_1 | event_name_2 | snap_CA |
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
| Q10_horizon_events | 2016-05-30 | Monday    | 3    | MemorialDay    | National     |              | 0       |
| Q10_horizon_events | 2016-06-01 | Wednesday | 5    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-02 | Thursday  | 6    | NBAFinalsStart | Sporting     |              | 1       |
| Q10_horizon_events | 2016-06-03 | Friday    | 7    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-04 | Saturday  | 1    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-05 | Sunday    | 2    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-06 | Monday    | 3    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-07 | Tuesday   | 4    | Ramadan starts | Religious    |              | 1       |
| Q10_horizon_events | 2016-06-08 | Wednesday | 5    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-09 | Thursday  | 6    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-10 | Friday    | 7    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-19 | Sunday    | 2    | NBAFinalsEnd   | Sporting     | Father's day | 0       |
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
```
## D2. design_profile_02.sql
```sql
-- PRICEPOINT-001 Stage 3 targeted profiling 02 (read-only aggregates; answers AI1 open item "profile distributions before locking")
-- Scope: CA_1, FOODS_1-3, HOUSEHOLD_1-2. Price history bounded at wm_yr_wk <= 11617 (current week); sales bounded at d_1941.
WITH pr AS (
  SELECT p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price,
         LAG(CAST(p.sell_price AS DECIMAL(10,2))) OVER (PARTITION BY p.item_id ORDER BY CAST(p.wm_yr_wk AS UNSIGNED)) prev
  FROM raw_sell_prices p WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
), pi AS (
  SELECT item_id, COUNT(*) priced_weeks, COUNT(DISTINCT price) n_distinct_prices,
         SUM(prev IS NOT NULL AND price<>prev) n_price_changes,
         SUM(prev IS NOT NULL AND price<>prev AND wk >= 11617-104) n_changes_last_2y
  FROM pr GROUP BY item_id
), sl AS (
  SELECT s.item_id, s.dept_id, SUM(j.u) units_365, SUM(j.u=0) zero_days_365
  FROM raw_sales_evaluation s,
       JSON_TABLE(s.sales_history, '$[*]' COLUMNS (pos FOR ORDINALITY, u INT PATH '$')) j
  WHERE s.store_id='CA_1' AND s.dept_id IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2') AND j.pos >= 1577
  GROUP BY s.item_id, s.dept_id
), t AS (SELECT sl.*, pi.priced_weeks, pi.n_distinct_prices, pi.n_price_changes, pi.n_changes_last_2y FROM sl JOIN pi ON pi.item_id=sl.item_id)
SELECT 'P1_changes_bucket' q, dept_id,
  SUM(n_price_changes=0) c0, SUM(n_price_changes BETWEEN 1 AND 2) c1_2, SUM(n_price_changes BETWEEN 3 AND 5) c3_5, SUM(n_price_changes BETWEEN 6 AND 10) c6_10, SUM(n_price_changes>10) c11p,
  SUM(n_changes_last_2y>=3) chg2y_ge3, COUNT(*) n FROM t GROUP BY dept_id
UNION ALL
SELECT 'P2_units365_bucket', dept_id, SUM(units_365<28), SUM(units_365 BETWEEN 28 AND 179), SUM(units_365 BETWEEN 180 AND 364), SUM(units_365 BETWEEN 365 AND 1094), SUM(units_365>=1095), SUM(zero_days_365>182), COUNT(*) FROM t GROUP BY dept_id
UNION ALL
SELECT 'P3_joint_chg3_u180_zero<=50pct', dept_id, SUM(n_price_changes>=3 AND units_365>=180 AND zero_days_365<=182), SUM(n_price_changes>=3 AND units_365>=365), SUM(n_distinct_prices>=3 AND units_365>=180), SUM(n_changes_last_2y>=2 AND units_365>=180), SUM(n_price_changes>=5 AND units_365>=365), SUM(priced_weeks<52), COUNT(*) FROM t GROUP BY dept_id
ORDER BY 1,2;
-- Column legend: P1 c0|c1_2|c3_5|c6_10|c11p|changes_last_104wk>=3|n ; P2 units<28|28-179|180-364|365-1094|>=1095|zero_days>182|n ; P3 chg>=3&u>=180&zero<=182 | chg>=3&u>=365 | distinct>=3&u>=180 | chg2y>=2&u>=180 | chg>=5&u>=365 | priced_weeks<52 | n
WITH pr AS (
  SELECT p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price,
         LAG(CAST(p.sell_price AS DECIMAL(10,2))) OVER (PARTITION BY p.item_id ORDER BY CAST(p.wm_yr_wk AS UNSIGNED)) prev
  FROM raw_sell_prices p WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617 AND (p.item_id LIKE 'FOODS%' OR p.item_id LIKE 'HOUSEHOLD%')
)
SELECT 'P4_change_magnitude_pct' q,
  COUNT(*) n_changes, ROUND(AVG(ABS(price/prev-1))*100,2) mean_abs_pct,
  SUM(ABS(price/prev-1) < 0.05) lt5, SUM(ABS(price/prev-1) BETWEEN 0.05 AND 0.10) p5_10, SUM(ABS(price/prev-1) > 0.10 AND ABS(price/prev-1)<=0.25) p10_25, SUM(ABS(price/prev-1) > 0.25) gt25,
  SUM(price>prev) ups, SUM(price<prev) downs
FROM pr WHERE prev IS NOT NULL AND price<>prev;
```
## D2 output
```
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
| q                              | dept_id     | c0   | c1_2 | c3_5 | c6_10 | c11p | chg2y_ge3 | n   |
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
| P1_changes_bucket              | FOODS_1     |   36 |   92 |   52 |    32 |    4 |        11 | 216 |
| P1_changes_bucket              | FOODS_2     |   35 |  117 |  157 |    83 |    6 |         4 | 398 |
| P1_changes_bucket              | FOODS_3     |  241 |  289 |  187 |    90 |   16 |        11 | 823 |
| P1_changes_bucket              | HOUSEHOLD_1 |  165 |  268 |   84 |    15 |    0 |         1 | 532 |
| P1_changes_bucket              | HOUSEHOLD_2 |  206 |  236 |   68 |     5 |    0 |         3 | 515 |
| P2_units365_bucket             | FOODS_1     |    3 |   39 |   76 |    73 |   25 |       119 | 216 |
| P2_units365_bucket             | FOODS_2     |    0 |  108 |  132 |   130 |   28 |       247 | 398 |
| P2_units365_bucket             | FOODS_3     |    4 |  112 |  207 |   313 |  187 |       361 | 823 |
| P2_units365_bucket             | HOUSEHOLD_1 |    1 |  124 |  151 |   202 |   54 |       242 | 532 |
| P2_units365_bucket             | HOUSEHOLD_2 |   33 |  353 |   95 |    33 |    1 |       465 | 515 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_1     |   29 |   31 |  101 |    17 |    7 |         0 | 216 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_2     |   99 |  103 |  207 |    30 |   50 |         4 | 398 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_3     |  172 |  190 |  302 |    68 |  107 |         4 | 823 |
| P3_joint_chg3_u180_zero<=50pct | HOUSEHOLD_1 |   61 |   56 |  146 |    25 |   13 |         1 | 532 |
| P3_joint_chg3_u180_zero<=50pct | HOUSEHOLD_2 |    3 |    1 |   28 |     4 |    0 |         0 | 515 |
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
| q                       | n_changes | mean_abs_pct | lt5  | p5_10 | p10_25 | gt25 | ups  | downs |
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
| P4_change_magnitude_pct |      5465 |        16.22 | 1867 |  1686 |   1451 |  461 | 3234 |  2231 |
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
```
## D2 coordinator notes (column legend and totals; arithmetic only, no design recommendation is binding)
# Design profiling 02: interpretation notes (PRICEPOINT-001 Stage 3, §25 targeted profiling)
Source: design_profile_02.sql (read-only aggregates, run 2026-09-25 ~04:05 CT on DESKTOP-RPECRM9, 54.7 s). Output: design_profile_02_output.txt.
Scope: CA_1; FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2 (2,484 items). Price history weeks <= 11617; sales last 365 days (d_1577..d_1941).
Column legend is the SQL comment on line 27 (the output header row reuses P1 column names for P2/P3).

Key facts for design:
- Items in scope: FOODS_1 216, FOODS_2 398, FOODS_3 823, HOUSEHOLD_1 532, HOUSEHOLD_2 515 (total 2,484).
- Items with zero historical price changes: 36/35/241/165/206 (683 total) -> no own-price variation.
- Items with >=3 price changes in last 104 weeks: 11/4/11/1/3 (30 total) -> recent price variation is scarce.
- Items with >182 zero-sales days in last 365: 119/247/361/242/465 (1,434 total) -> intermittent demand is the majority.
- Joint rule (changes>=3 AND units_365>=180 AND zero_days<=182): 29/99/172/61/3 = 364 items.
- changes>=3 AND units_365>=365: 31/103/190/56/1 = 381.
- distinct_prices>=3 AND units_365>=180: 101/207/302/146/28 = 784.
- changes_last_2y>=2 AND units_365>=180: 17/30/68/25/4 = 144.
- changes>=5 AND units_365>=365: 7/50/107/13/0 = 177.
- priced_weeks<52: 0/4/4/1/0.
- Price-change magnitudes (all FOODS/HOUSEHOLD CA_1 changes, weeks<=11617): 5,465 changes; mean |pct| 16.22%; <5%: 1,867; 5-10%: 1,686; 10-25%: 1,451; >25%: 461; ups 3,234; downs 2,231.
Implication: an eligibility rule of roughly the "joint" form lands near the stakeholder's ~200-300 item intent only with a threshold choice; this is an owner-visible design choice to lock in the candidate. Candidate price grids beyond about +/-10-25% are outside most observed change magnitudes.
