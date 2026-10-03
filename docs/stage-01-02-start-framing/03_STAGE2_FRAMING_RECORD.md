# 03 — Stage 2 Framing Record (PRICEPOINT-001)

This is a controlled combined document; each section corresponds to a framework §20 deliverable. **Status: stakeholder-approved (synthetic, T042), Framing Gate self-check PASS, awaiting human analyst (owner) approval.** Nothing is locked until the owner approves and `complete framing` returns PASS.

`begin framing` was AUTHORIZED at 2026-09-25 ~03:02 CT. AI roles: AI 1 is ChatGPT GPT-5.6 Sol at High (3 of 4), in the same chat as Stage 1. AI 2 is Grok Expert and AI 3 is DeepSeek DeepThink with search off; each used a fresh chat for its first-pass review. Morgan Lee is SYNTHETIC.

## 1. Candidate Question Ledger

| ID | Source | Status | Reviews |
|---|---|---|---|
| C1 | reviews/ai1_T041_raw.txt | Held; superseded | AI 2 Tighten, AI 3 Pass |
| **C2** | reviews/ai1_T041R_raw.txt | **Stakeholder-approved T042** | AI 2 Keep, AI 3 Pass |

C1: "For products meeting the review criteria at the California pilot store, which specific shelf prices should Morgan recommend for the next 28-day pilot to produce the highest trusted expected product revenue relative to the current price, without recommending a change expected to reduce units by more than about 10%, and which products should instead remain unchanged or be classified as “hold — not enough evidence”?"

**C2 (final; SHA-256 of framing_question_C2.txt `4ab0e3e377f28994177814d1c08088886988fd8358de242f03ffc4c24767bbe6`):**

> For products meeting the review criteria in the California pilot store’s everyday grocery and household aisles, which specific pilot shelf prices should Morgan recommend for the next 28-day review cycle to produce the strongest trusted expected product revenue (units sold × shelf price) compared with the current price, without recommending a change expected to reduce units by more than about 10%; which products should instead remain unchanged or be classified as “hold — not enough evidence”; and which trusted price-change opportunities rank into the current-cycle GM package of up to about 25 actual price changes, with any additional qualifying opportunities listed below the line?

Decision linkage: the question supports Morgan's decision about which specific pilot shelf-price recommendation, unchanged-price decision, or hold-not-enough-evidence outcome to bring to the GM for the next four-week pricing cycle, and which changes make the ranked package.

## 2. Framing dialogue and decision/ambiguity updates

| Turn | Question / answer | Effect |
|---|---|---|
| T037/T038 | Should priority go to the largest opportunity, the highest confidence, or a balance? | Confidence acts as a gate, not a weight. Untrusted expectations become holds; trusted ones are ranked by biggest revenue gain. Trust criterion delegated (consistent with T024). |
| T039/T040 | Does trust mean evidence strength, gain size, or both? | Trust means evidence strength (real price movement, enough sales, a forward expectation that isn't a guess). Gain size only affects ranking. No materiality cutoff from the stakeholder; any minimum-gain rule is an analyst choice, to be disclosed. |
| T041 | C1 draft | Held for Phase F |
| T041R/T042 | C2 presented | Approved as written (synthetic) |

New ambiguity resolved in Framing: F1, prioritization philosophy (T038); F2, the meaning of "trusted" (T040); F3, the question omitted package ranking and aisle scope (AI 2 r1; fixed in C2).

## 3. Independent Framing reviews (first passes frozen before AI 1 saw them)

| Round | AI 2 (Grok Expert) | AI 3 (DeepSeek DeepThink) |
|---|---|---|
| r1 on C1, fresh chats | Tighten (https://grok.com/c/b918adb4-b8d8-485c-af9a-4871d62885b9) | Pass, no blocking findings (https://chat.deepseek.com/a/chat/s/e8923a94-e418-4037-b941-b350aec1e361) |
| verify on C2, same chats | **Keep**, no required changes | **Pass**, no required revisions |

Hashes: reviews/SHA256SUMS_framing_r1.txt. AI 3 checked capacity in both directions in both rounds, and both passed.

## 4. Reconciliation
AI 1 (reviews/ai1_T041R_raw.txt SECTION 0) accepted every AI 2 point and adopted AI 2's replacement wording. It carried the feasibility items into Stage 3 open work. No coordinator tie-break was needed in Stage 2.

## 5. capacity_stance
**`hard_attention_budget`**. The capacity unit is actual raise or cut recommendations that the team works up and takes through GM review in one four-week cycle, about 25. Holds and hold-not-enough-evidence outcomes are visible but do not consume capacity. There is no padding when fewer qualify, and additional qualifiers go below the line as next in line. Support: T018, T020, T024, T038. AI 1, AI 2 and AI 3 each reached this stance independently. N (about 25) was stated by the stakeholder rather than deferred. Its exact operational treatment, together with the ranking key, tie-break and no-pad rule, must be frozen at Stage 3 (FORWARD Deferred-N rule). Capacity × Mode: the capacity ranking must come from a Mode A (judged predictive) contract, and a Mode B diagnostic score may not rank this list.

## 6. Feasibility and bounded-extract answer
Method: one read-only aggregate query against `pricepoint` (mysql CLI, --login-path=chicago311), with no writes and no staging objects. The query and output are saved on the PC at `artifacts/framing/feasibility_probe_01.sql` and `feasibility_probe_01_output.txt` (run 2026-09-25 ~03:40 CT).

Findings at store CA_1 (the candidate pilot store):

| Dept | Items | Any price change | 4+ distinct prices | Avg priced weeks |
|---|---:|---:|---:|---:|
| FOODS_1 | 216 | 180 | 69 | 241.5 |
| FOODS_2 | 398 | 363 | 202 | 228.0 |
| FOODS_3 | 823 | 583 | 209 | 226.9 |
| HOUSEHOLD_1 | 532 | 367 | 63 | 220.1 |
| HOUSEHOLD_2 | 515 | 310 | 38 | 237.0 |

- All CA_1 grocery/household items have price rows. Price weeks run 11101 to 11621.
- The history cut is d_1941 = 2016-05-22 (wm_yr_wk 11617). The 28-day horizon is d_1942–d_1969 (2016-05-23 to 2016-06-19, weeks 11617–11621).

Answer: the data can support the question at the product × pilot-store grain. There is real price variation across many items (for example, FOODS_1 + HOUSEHOLD_1 has 748 items, of which 547 had at least one price change and 132 had four or more distinct prices), which is what Morgan's eligibility principle needs. A bounded extract is feasible. For one store and the chosen departments, that is roughly 1.5M item-day sales rows after pivot and under 200k price rows, well within R memory.

Stage 3 must address:
1. The eligibility cutoffs and department mapping. Candidate counts differ a lot by department.
2. `raw_sell_prices` contains prices for horizon weeks 11617–11621, which is AFTER the decision date. Using them would be look-ahead. The extract or design must bound price history at the decision date, apart from the current price in effect at the decision date.
3. Horizon sales (d_1942–d_1969) are not in the evaluation file used for training. Any backtest must use an earlier pseudo-decision date.

No KPI, threshold, or model is locked here.

## 7. Framing Gate self-check (§15 plus FORWARD additions)

| Criterion | Result | Basis |
|---|---|---|
| One primary analytical question | PASS | C2. AI 3 judged the price-per-product and ranked-package parts to be one linked decision |
| Decision owner identifiable | PASS | Morgan recommends; the GM signs off |
| Action clear | PASS | Specific raise or cut price, unchanged, or hold-not-enough-evidence |
| Unit/target bounded | PASS | Products meeting review criteria, CA pilot store, grocery and household aisles. Cutoffs go to Stage 3 |
| Outcome explicit | PASS | Trusted expected product revenue (units × price) vs current price |
| Time scope defined | PASS | Next 28-day review cycle |
| Capacity/policy constraint represented | PASS | Up to ~25 actual price changes, below-line list, ~10% unit guardrail |
| Required outputs/exceptions recorded | PASS | Holds visible, no padding, pilots as expectations (locked Stage 1 statement and working assumptions) |
| Does not assume the answer | PASS | AI 3 finding 3 |
| Causal language within evidence | PASS | Wording is "expected"; T026 pilot-not-guarantee. AI 3 noted "produce" as mild, non-blocking |
| Answerable through analysis | PASS | Feasibility §6 |
| Different answers mean different actions | PASS | AI 2 reason 2 |
| No blocking AI 3 objection | PASS | AI 3 Pass in both rounds |
| Stakeholder approved | PASS (synthetic) | T042 |
| Human analyst approves handoff | **PENDING** | Owner checkpoint |
| capacity_stance recorded | PASS | hard_attention_budget |
| Capacity unit or deferral named | PASS | ~25 actual raise/cut recommendations |
| AI 3 capacity check both directions | PASS | r1 and verify |
| Handoff includes capacity_stance | PASS | §8 |
| Owner constraint: needs tidyverse + parsnip ML, not rules-only | PASS | A forward 28-day expectation at current vs candidate prices, with calendar effects, across hundreds of products needs panel wrangling and a predictive model (AI 2 r1 reason 8, verify reason 8). The question names no model |

## 8. Stage 3 handoff package

**Locked content:** the original request (T000); the Stage 1 decision statement (decision_statement_T035.txt); the analytical question C2; the decision owner (Morgan recommends, GM signs off); the possible actions (specific raise price, specific cut price, unchanged, hold-not-enough-evidence); the outcome (trusted expected product revenue, units × shelf price, vs current price); the unit (product at the CA pilot store, grocery and household aisles); the time scope (next 28 days, four-week hold, information frozen at the end of history, 2016-05-22); constraints (~10% unit guardrail, capacity_stance hard_attention_budget at ~25 actual raise/cut changes, no padding, below-line list, holds outside capacity); interpretation (trust is an evidence gate and gain ranks within it; pilots are expectations, not guarantees); output form (ranked list with GM package and below-line list, holds listed); stakeholder approval records T036 and T042 (synthetic).

**Open design work (Stage 3 must define and disclose):** ML mode (A expected; B may not rank the capacity list); the eligibility rule and cutoffs, including the department mapping within grocery/household (about 748 items in FOODS_1+HOUSEHOLD_1); the evidence-sufficiency ("trusted") gate, disclosed; candidate pilot-price construction; the prediction method and parsnip model spec; KPI formulas for expected units and revenue at current vs candidate price; operational treatment of "about 10%" and the reporting label for guardrail-rejected candidates; the ranking key, tie-break, and no-pad and capacity-application rules, including the treatment of "about 25"; any minimum-gain rule (analyst option, disclosed); definition of the current price at the review date (a missing price is not zero); the forward 28-day window with calendar/SNAP features; leakage control (sell_prices has horizon weeks 11617–11621, so bound the data at the decision date); a backtest at an earlier pseudo-decision date, since horizon sales are absent; the analytical grain; validation criteria; and limitations.

## 9. Revision trail
C1 (T041, held) was followed by AI 2 Tighten and AI 3 Pass, then reconciliation to C2 (T041R), then AI 2 Keep and AI 3 Pass on verification, then shown to Morgan, who approved it (T042).

## 10. Proposed Warrant Ledger rows (to be written on owner approval)

| ID | Rule / assumption | Stage | Basis | Evidence / rationale | Sensitivity? | Status |
|---|---|---:|---|---|---|---|
| W-009 | Trust is an evidence gate: untrusted expectations become "hold — not enough evidence" and do not rank | 2 | Stakeholder | T038, T040 | Yes | Stakeholder-locked (gate definition Open, Stage 3) |
| W-010 | Ranking within the trusted set is by expected revenue gain vs current price | 2 | Stakeholder | T024, T038 | Yes | Stakeholder-locked (formula/tie-break Open, Stage 3) |
| W-011 | No stakeholder minimum-gain cutoff; any materiality rule is an analyst choice, disclosed | 2 | Stakeholder delegation | T040 | Yes | Methodological judgment (Open) |
| W-012 | capacity_stance = hard_attention_budget; unit = actual raise/cut recommendations per cycle | 2 | Stakeholder; all three AIs independently | T018, T020, T024 | Yes | Stakeholder-locked portfolio requirement |
| W-013 | Decision-date information bound: no prices or sales after 2016-05-22 except the current price in effect | 2 | Stakeholder T012/T014 plus feasibility finding | feasibility_probe_01 | No | Stakeholder-locked; implementation Stage 3 |

## 11. Disclosures
- Morgan is simulated from the fixed brief (unchanged since Stage 1). Her T038, T040 and T042 answers restate brief items 8 and 9 and her earlier T024. She gave no numbers.
- The feasibility probe was one read-only aggregate SQL query. Nothing was written to the database.
- Stage 2 first stopped before its first step because the delegated session could not operate the AI chats. That stop was recorded (STAGE2_BLOCKED_NOTE_resolved.md). No turns were lost, and the packet's wording was unchanged apart from removing its header line.
- The owner project constraint (R, tidyverse, parsnip) was given to all three AIs as an owner requirement, not as a stakeholder statement.
