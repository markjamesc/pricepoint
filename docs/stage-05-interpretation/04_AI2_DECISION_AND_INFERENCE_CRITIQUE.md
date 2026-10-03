# 04_AI2_DECISION_AND_INFERENCE_CRITIQUE

PRICEPOINT-001 · Stage 5 Finish · Independent first pass · AI 2 — Decision and Methodological Critic

SIMULATION / NON-LIVE. Historical M5 CA_1 data. No price is released. This pass has not seen any other AI's Stage 5 interpretation.

Bindings used: Stage 4 receipt `stage4_validation_status.json` 9536fe9832310cb9b23f8af60862bf7b47b1a3c0b97939146e2d29543f3a664d; design `08_CONSOLIDATED_CANDIDATE_v5_4` 3cfc71eb5e10c5f680e1768400d03daf05513a23199740ac9f80f8adff2b80ef; Stage 3 receipt v4 1ee9f4da9cffe3a906182d209c573b61c7451387cfc338009261c79f8620dd16; evidence bundle `evidence_pkg_v1.zip`; brief `01_STAGE_05_EVIDENCE_PACKAGE.v1.md`. Framework: `framework/three-ai-interpretation-and-recommendation-framework.md` (sections 3–22 and 24 read).

Conclusion ceiling (design §5; `stage3_locked_design.v4.json` field `claim_strength_ceiling`): predictive expectation. Allowed claim form only: "Under the locked model this is the 28-day expectation to pilot-test; it is not a guarantee and not a causal effect." No such expectation is decision-valid in this run, because the collapse fired.

## File inventory

Opened and used:

- `01_STAGE_05_EVIDENCE_PACKAGE.v1.md` (attachment; full).
- `evidence_pkg_v1/SHA256SUMS.txt` (full).
- `framework/three-ai-interpretation-and-recommendation-framework.md` (headings; §§3–22 and §24 in full or near-full; not §§23, 25–36 in full).
- `locked/framing_question_C2.txt` (full).
- `locked/decision_statement_T035.txt` (full).
- `locked/stage1_decision.json` (full).
- `locked/stage2_framing.json` (full).
- `locked/stage3_locked_design.v4.json` (keys plus `decision_rules`, `decision_statement`, `decision_horizon`, `claim_strength_ceiling`; not every block).
- `locked/08_CONSOLIDATED_CANDIDATE_v5_4.md` (targeted: §5, §6.1–6.3, §16.1–16.4, §17.R5–R8, trust/TE6 greps; not the full 2,050 lines).
- `stage4_receipts/stage4_validation_status.json` (full).
- `stage4_receipts/model.json` (full).
- `stage4_receipts/validation.json` (full enough to take gate wording, spine, ceiling, owner approval 2026-10-02 14:35 CT).
- `stage4_receipts/fixtures.json` (header fields only).
- `stage4_receipts/workflow_gate_status.json` (header and check list, partial).
- `stage4_receipts/validated_data_manifest.md` (first 120 lines).
- `stage4_receipts/lineage.json`, `source.json`, `reconciliation.json`, `structural.json` (opened in a concatenated dump; structural body not relied on beyond the validation-spine statement that structural PASS had 0 unresolved and 11 accepted limitations).
- `stage4_outputs/model_validation.json` (primary summary, stability summary, live penalty/folds, TE6 rule and sample rows, `dept_backtest_MAE_revenue`; not every per-item row narrated).
- `stage4_outputs/universe.csv` (header and action tally only).
- `stage4_outputs/candidates.csv` (header and row count only).
- `stage4_outputs/audit.csv` (header and the R-A row).
- `stage4_review/cross_review.md` (full).
- `stage4_review/findings_register.csv` (full).
- `stage4_review/reconciliation.csv` (header).
- `stage4_review/source_gate_report.csv` (header and first two rows; line count 25 including header).

Not opened, and not cited as read: `locked/10_STAGE_03_MEASUREMENT_DESIGN.v5_4.md`, `locked/11_STAGE_04_HANDOFF.v5_4.md`, `stage4_outputs/lineage.json`. No new decision result was computed. Counts below are either receipt fields or a direct tally of the `action` column in `universe.csv`.

Disclosed process limitations preserved, not repaired: Morgan Lee is synthetic (`stage1_decision.json`); the Stage 4 findings-register v1 was lost by overwrite and `findings_register.csv` 90fa70e6… is the approved register (brief; cross-review); 23 Stage 3 blocks are described in the brief as coordinator mechanical fallback — this pass did not re-count `authorship_provenance`.

---

## 1. Direct answer to C2

**C-01 (recommendation).** For the locked population of 2,484 CA_1 items in FOODS_1/2/3 and HOUSEHOLD_1/2, Morgan should recommend no pilot shelf-price raise and no pilot shelf-price cut for d_1942–d_1969. Every item is `hold_ne`. The GM package is empty (0 of N_CAP 25). The below-line list is empty. The list is not padded.

**C-02 (computed result, validated).** Source: R-04; `model.json` `model_acceptance_outcome`; `universe.csv` action tally `hold_ne` = 2,484; `audit.csv` R-A row `n_raise` = 0, `n_cut` = 0, `n_unchanged` = 0, `n_hold_ne` = 2484, `n_package` = 0, `n_below_line` = 0, `n_legal_changes` = 0. Evidence status: **Validated**. Finding class: **conclusive for the defined question** under the locked rule, not conclusive about the revenue ranking of prices.

**C-03 (computed result, validated with limitation).** The reason is the locked collapse, not a finding that current prices maximize expected revenue. At origin d_1913, A1 (median APE) = 0.1824 passes ≤ 0.40, and A2 (mean signed error) = 0.2697 fails the band [−0.20, +0.20], so `backtest_accept` = 0 (R-01; `model.json` results for R-A and R-B, identical). Design §16.3 defines A2 as the mean of (Û − U) / U on the acceptance set. Positive A2 is over-prediction of 28-day units at the backtest current price. §16.4 and §17.R8 then set every trust-eligible item to `hold_ne`, including what would have been model-based unchanged. Trust-eligible = 338; TE6 usable slice = 347 (R-04; `model.json` `te6`). Items already outside trust were `hold_ne` by §17.R5; the collapse is what removes the 338 from any raise, cut, or model-based unchanged.

**C-04 (interpretation).** C2 is answered. The answer is the hold class, not a price list. "Unchanged" is a different locked option and was not assigned (audit row `n_unchanged` = 0). Holds do not consume the 25-change capacity (T035; stage2 `capacity_stance` = `hard_attention_budget`).

**C-05 (observed fact).** `candidates.csv` has 3,654 rows of diagnostic predictions (R-10; row count matched on open). Those rows are not decision-valid. Using them to fill the package would reopen §17.R8. Routed to Stage 4 if anyone wants them re-labeled; not used here.

---

## 2. Strongest rival interpretation

**F-01 (interpretation; status: validated with limitation).** The strongest rival reading of A2 = 0.2697 at d_1913 against A2 = 0.1794 at d_1885 is: the binding failure is a level-calibration miss on units at the held price, same sign at both origins, origin-sensitive in magnitude, and not by itself a demonstration that within-item price rankings are noise.

What the pair does imply:

- **C-06.** At the binding origin, mean relative unit error is about +0.27, outside the pre-registered band. n_usable = 345, U0 excluded = 5 (R-01). The conjunctive rule does not let the A1 pass rescue acceptance (`model.json` `acceptance_rule`).
- **C-07.** The sign is over-prediction, not under-prediction (design §16.3). A revenue gain built from an inflated Û is the exposed direction of harm if the level error carries into R̂. Whether it carries into ΔR̂ is not tested in the opened artifacts.
- **C-08.** d_1885 is the same sign and inside the band: A1 = 0.1722, A2 = 0.1794, `backtest_accept_reported_only` = 1, n_usable = 335, U0 excluded = 14, same penalty 0.0021 grid index 14 (`model_validation.json` stability; R-02). Design §16.4 says this origin is reported only. It cannot override d_1913.
- **C-09.** `model.json` `status` = PASS means the locked backtest, collapse, and TE6 were executed and reconciled. The same file's `status_meaning` says PASS does not mean the model passed acceptance. Treating "Stage 4 PASS" as "model accepted" would be a false reading of the receipt (R-09 approval wording also states the A2 fail and the all-`hold_ne` result).

What the pair does not imply:

- **C-10.** It does not imply every usable item is over-predicted. A1 is a median of absolute percentage errors and passed at 0.1824; A2 is a mean of signed errors and failed. Those two functionals can diverge if a right tail of large positive errors pulls the mean. The opened receipts do not store median signed error, the share of positive errors, or a winsorized A2. That decomposition is **Recompute in Stage 4**. Until then, "typical item is off by 27%" is unsupported.
- **C-11.** It does not imply the log-price slope has the wrong sign, is flat, or is well identified. Design §6.3 maps "backtest miss" to A1 or A2 failure as a falsifier of the analytical hypothesis, and maps "flat price response" to the A3 / calendar-only comparison. A3 is not in `model_validation.json` primary or stability. Absence of A3 is an omitted result (§9), not a silent pass.
- **C-12.** It does not imply current prices are optimal, or that a raise or a cut would reduce revenue. `hold_ne` is the locked response to a failed trust gate. It is not an estimate of ΔR̂ = 0.
- **C-13.** The d_1885 pass does not show stability of calibration inside the band. The two A2 values differ by about nine percentage points of relative error, the usable sets differ (345 vs 335), and only one origin is binding. Stability is therefore **inconclusive**, not conflicting in the decision sense: the design already says which origin governs.

Residual force of the rival: a common multiplicative over-prediction that is shared by Û(P0) and Û(Pc) would cancel in ρ̂ = Û(Pc)/Û(P0) and might leave the sign of ΔR̂ intact. That story is coherent and untested. It is not available as a Stage 5 repair of §16.4.

Hypothesis status under §6: the analytical hypothesis ("within-item log-price slope after calendar adjustment changes expected revenue ranking") is **weakened**, not refuted. The mapped falsifier "backtest miss" fired. The mapped falsifier "flat price response" was not adjudicated in the opened model artifact.

---

## 3. Strongest alternative recommendation

**C-14 (recommendation, rejected for this cycle).** The strongest alternative is to treat the A2 miss as a level offset, ignore §17.R8, and fill the GM package from the largest diagnostic `delta_rev` rows in `candidates.csv`, still applying ρ̂ ≥ 0.90 and N_CAP 25.

Why it is the strongest alternative: A1 passed; d_1885 A2 passed; the penalty matched across origins and across R-A/R-B; a common-mode bias could in principle cancel in the unit ratio; the operational action is a four-week pilot and is reversible at the next review; capacity is only 25.

Why it is not available here:

- It changes the locked collapse rule (design §16.4, §17.R8; brief M4-013). Stage 5 records a lock defect; it does not repair one (framework §4).
- R-10 states the candidate file is not decision-valid. No receipt gives a decision-valid ranking under `backtest_accept` = 0.
- The owner Validation Gate wording already states the result as no price changes and Stage 5 interpretation only (`validation.json` `approval_wording_verbatim`).
- Shipping diagnostic deltas would present method-dependent estimates as if they had cleared the trust gate. That breaks the evidence-to-action chain (framework §11).

**C-15 (recommendation, the admissible alternative).** Do not change prices. Ask Stage 4, under the same locks, for the omitted diagnostics in §9. Do not promote any of them into the package unless a later Stage 3 change control rewrites acceptance and a new Stage 4 run accepts. This is "collect more evidence," not a price action.

Decision-option matrix (framework §19; no utility weights invented):

| Option | Evidence required | Evidence observed | Expected benefit | Downside | Uncertainty | Capacity | Reversibility | Guardrail | Gap | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|
| Pilot raise | Trust-eligible item, legal candidate, ρ̂ ≥ 0.90, positive cent ΔR̂, backtest accept, rank inside 25 | 0 raises (R-04; audit row) | None validated | Would override collapse | Diagnostic file not decision-valid | Would consume a slot | Next-cycle reversible, rule-irreversible inside this run | Unevaluable; collapse preempts | A2 fail | Reject |
| Pilot cut | Same, with Pc < P0 | 0 cuts | None validated | Same | Same | Same | Same | Same | Same | Reject |
| Unchanged | No legal candidate, and backtest accept so the model-based unchanged is allowed | 0 unchanged; collapse converts model-based unchanged to hold_ne | None as a scored action | Labeling unchanged would overclaim calibration | Whether any item would have been unchanged pre-collapse is not a decision result | Does not consume capacity | N/A | N/A | Pre-collapse action mix not used | Reject as the assigned action |
| hold_ne | A1 or A2 fail, or trust fail | A2 fail; 2,484 hold_ne; package 0 | Preserves the trust gate; no padded list | Forgoes an unquantified diagnostic upside | Opportunity cost not decision-valid | 0 of 25 | Fully reversible; nothing shipped | No change can breach ρ̂ | Dollar upside unknown | No action |
| Override collapse and ship top 25 diagnostic deltas | A Stage 3 rewrite of §16.4 plus a new Stage 4 accept, or an explicit owner exception | Neither is in the bundle | Unknown; R-10 forbids use | False legitimacy of a failed gate | High | Would fill 25 | Operationally reversible next cycle | Might still show ρ̂ ≥ 0.90 in diagnostics; not allowed to count | Whole path | Reject this cycle; route to Stage 3 if the owner wants the rule changed |

---

## 4. Statistical versus practical significance

**F-02 (interpretation).** This design does not use a p-value. Practical significance is encoded as two pre-registered caps plus a capacity cap. Those caps were disclosed as provisional policy, not industry constants (design §16.3).

- **C-16.** Direction: A2 positive at both origins (over-prediction). Magnitude at the binding origin: 0.2697 versus a band edge of 0.20, a miss of about 0.07 in mean relative units. That is material relative to the rule the owner locked. It is not a barely-crossed rounding artifact: `audit.csv` stores unrounded A2 = 0.2696681754366238 and unrounded A1 = 0.18243343920694519, and both paths match the rounded receipt figures (R-01, R-05).
- **C-17.** A1 = 0.1824 is practically inside its cap (less than half of 0.40) on n = 345. Passing A1 is real and is not the decision. A tight typical absolute error with a failing mean signed error is exactly the pattern that should block a mean-based revenue claim and should not be talked into a pass.
- **C-18.** Sample size is the acceptance set, not the 2,484. Decisions about the 2,146 items outside trust-eligible were already hold_ne by the trust gate. The calibration claim is about 345 usable backtest items (5 U0 excluded). That is enough for the locked mean and median rules. It is not a store-wide estimate of bias for items that failed E_A, pw52, candidate-exists, or TE6.
- **C-19.** No interval around A2 is in the opened receipts. Uncertainty of the mean itself is **Recompute in Stage 4**. The decision does not need that interval: the point estimate is outside the locked band, and the rule is a threshold rule, not a test against zero.
- **C-20.** Practical importance for the GM: the actionable set is empty. Department backtest MAE of revenue is stored and is diagnostic only (`model_validation.json` primary): FOODS_1 74.3558, FOODS_2 62.3338, FOODS_3 71.313, HOUSEHOLD_1 45.7697, HOUSEHOLD_2 62.0567. These are not a ranking rule and are not converted here into a package. They do show that absolute revenue error on the backtest is not negligible relative to a 25-change attention budget, which cuts against overriding the collapse on "the errors are small" grounds.
- **C-21.** d_1885 A2 = 0.1794 would have passed. That is a sensitivity result the design deliberately marked non-binding. Calling the d_1913 fail "statistically fussy" would smuggle the non-binding origin into the decision. Status of the stability contrast: **sensitivity-dependent** as a description of calibration, **decision-irrelevant** as a way around §17.R8.

---

## 5. Causal-ceiling assessment

**F-03 (interpretation; ceiling held).** Nothing in this package supports a causal price effect, a promotional interpretation, or a claim that holding price constant is optimal.

- **C-22.** Ceiling is predictive expectation (design §5). The collapse means the allowed sentence cannot be said of any item: there is no trusted 28-day expectation to pilot-test.
- **C-23.** Design confounder C1 (price endogeneity / unlabeled promotions) remains in force. Mitigations locked there — within-item variation, SNAP and event features, previously observed prices, calendar-only twin, event-week share — do not raise the ceiling. The calendar-only twin's A3 result is not in the opened model artifact, so even the predictive falsifier for "flat price response" is unresolved.
- **C-24.** ρ̂ ≥ 0.90 is a predictive guardrail on Û(Pc)/Û(P0), not an estimate of a causal unit elasticity. It was not reached as a binding constraint, because no legal change survived (R-04).
- **C-25.** Forbidden claim forms, all unsupported: "raising price will increase revenue," "the model shows demand is inelastic," "customers will buy 27% less than forecast," "current prices are right." The last is a business reading of hold_ne that the rule does not license.

---

## 6. Alternative-Explanation Ledger

| Alternative ID | Explanation | Evidence for | Evidence against | Confounder relation | Test performed | Residual plausibility | Effect on recommendation |
|---|---|---|---|---|---|---|---|
| AE-1 | Mean signed error is a tail artifact; the typical item is calibrated, so the band is the wrong functional | A1 pass at 0.1824 vs A2 fail at 0.2697; median and mean answer different questions | Band was pre-registered; both paths agree; unrounded audit value still fails | Not a Stage 3 confounder; a metric-choice issue | None on the distribution | Medium as a description; low as a reason to ship | No change this cycle; optional Stage 4 diagnostic |
| AE-2 | Common multiplicative over-prediction cancels in ρ̂ and in the sign of ΔR̂, so rankings survive | Same-sign A2 at both origins; same penalty; ρ̂ is a ratio | No candidate-price backtest; A3 absent from opened model file; R-10 bars the diagnostic file | C1 could still bias the slope even if the level cancels | None | Medium, untested | Weaken any future override; does not lift hold_ne |
| AE-3 | d_1913 is a one-origin shock; d_1885 shows the model is acceptable | d_1885 A2 0.1794 inside band; same penalty | Design marks d_1885 non-binding; usable n and U0 counts differ; A2 still positive and closer to the edge than to zero | Horizon shift / calendar mix, untested | Stability origin reported only | Medium as a stability caveat; low as a decision input | No change |
| AE-4 | The fail is an artifact of U = 0 exclusion or of the acceptance-set definition | 5 U0 excluded at d_1913; 14 at d_1885 | Exclusion is locked (§16.2); both paths match | Small-denominator relative error | None beyond the locked exclusion | Low | No change |
| AE-5 | R-A / R-B disagreement is being hidden, and the collapse is path-specific | None in the opened reconciliation header | R-05: 75/75, mismatch 0; `model.json` R-A and R-B A1/A2 identical | Independent reconstruction | Reconciliation | Low | No change |
| AE-6 | Unlabeled promotions in the backtest window inflated realized units and made the model look high | Positive A2 is the direction that story does not fit: the model was high, realized units were lower than Û | A promo-driven demand spike would push A2 negative if Û missed it | C1, design § on endogeneity | Not identifiable; no promotion flag | Unknown | Does not support a price change; keeps the ceiling predictive |
| AE-7 | Stage 4 execution failed, so the hold is a pipeline error | XR-01..03 were blocking and then resolved; owner still accepted XR-04..14 | R-06 Source Gate 24/24; R-07 fixtures 26/26 both paths; R-09 owner gate; `status_meaning` separates execution PASS from acceptance fail | Process limitation, not a demand confounder | Cross-review | Low for the A2 number; medium for documentation limits already accepted | No change; do not re-litigate accepted limitations as if unresolved |
| AE-8 | hold_ne is evidence that expected revenue gains are ~0 | Collapse and trust rules assign hold_ne without estimating ΔR̂ = 0 | audit row shows 0 legal changes after collapse, which is the rule, not a zero-gain estimate | None | Rule application | Low | Reject this reading in the GM note |

No alternative above is defeated merely by lacking its own model (framework §18). None of them is strong enough to replace hold_ne inside the locked rule.

---

## 7. Risk and reversibility

**F-04 (business judgment, tied to validated findings).**

Cost of the no-change outcome:

- **C-26.** Customer and shelf risk of this cycle's recommendation is null: no price moves, and the run is non-live.
- **C-27.** Attention cost is null: package 0, no padding.
- **C-28.** Opportunity cost is real and unquantified. Up to 25 qualifying changes could have been recommended if the backtest had accepted. The dollar size of that forgone list is not decision-valid (R-10). Stating a sum of diagnostic `delta_rev` would be a new decision-facing computation. **Recompute in Stage 4** only as a clearly labeled non-decision diagnostic, not as a package.
- **C-29.** Epistemic cost of no-change is low. The next review can refit. The cost of implying that hold_ne means "prices are right" is the material communication risk.

Cost of overriding the collapse:

- **C-30.** Breaks the pre-registered trust gate the decision owner locked. A later good outcome would not retroactively validate the breach.
- **C-31.** Directional risk matches the A2 sign: unit levels were high on the backtest, so revenue expectations built from Û are the exposed side. The guardrail ρ̂ ≥ 0.90 does not protect against a shared level bias.
- **C-32.** Reversibility is asymmetric. A live pilot could be walked back at the next four-week review (T035). The rule breach cannot be walked back inside this evidence package. Because this package is simulation / non-live, even that operational risk is not incurred now. The interpretation must not be written as if a live override were authorized.

Accepted limitations that bear on risk, not on the action: XR-04..14 remain accepted (R-08); they are not a second reason to ship prices, and they are not unresolved blockers. The lost v1 findings register is a process scar; the approved register is 90fa70e6….

---

## 8. Evidence that would change the verdict

The verdict moves off all-`hold_ne` only if one of the following is produced outside this prose:

1. A new Stage 4 run, same locks, in which d_1913 A2 is inside [−0.20, +0.20] and A1 ≤ 0.40, with R-A/R-B reconciliation still matching, and the owner Validation Gate rebound. Then raise/cut/unchanged may be read under §17.R7.
2. An owner change control at Stage 3 that rewrites §16.3/§16.4, followed by a new Stage 4 execution. A Stage 5 argument that the band was too tight is not that change control.
3. Not sufficient: d_1885 already inside the band; A1 already passing; department MAE figures; a narrative common-mode-bias story; any sort of `candidates.csv` without a new accept flag.

Evidence that would change the critic's view of the rival, without changing this cycle's prices: a Stage 4 decomposition of signed error (median, share positive, by department) and a reported A3 on the changed-price subset. Those can lower or raise AE-2's residual plausibility. They cannot fill the package while `backtest_accept` = 0.

---

## 9. Most important omitted result or option

**F-05 (unsupported until recomputed).** The most important omission is A3: Spearman(ΔR̂, realized revenue change) for the price-plus-calendar model versus the calendar-only ablation, on items whose price changed, design §16.3, reported and not binding. It is the locked test of the "flat price response" falsifier (§6.3). It is not in the opened `model_validation.json` primary or stability objects. Without it, the critic cannot say whether the price term earned its keep on the backtest, and cannot calibrate AE-2.

Next omitted result, same status: the distribution behind A2 (median signed error, share of positive errors, influence of the upper tail) on the 345 usable items. That is the difference between "the mean is outside the band" (known) and "the typical item is biased by 27%" (not known).

Omitted option the GM may expect and must not be given: a below-line ranking of "what we would have piloted." That option is not in the locked action set once the collapse fires. A clearly watermarked diagnostic appendix is a communication choice for the human analyst; it is not a recommendation, and this pass does not build it. **Recompute in Stage 4** if that appendix is wanted as a frozen, non-enrolling table.

---

## 10. Decision verdict

**Verdict: no action.**

Reasons, in chain:

1. C2 asks for specific pilot prices, otherwise unchanged or hold_ne, with at most 25 trusted changes (C2 text; T035).
2. The validated binding result is A2 failure and `backtest_accept` = 0 (R-01), reconciled on both paths (R-05).
3. The locked consequence is hold_ne for every trust-eligible item, and the observed assignment is hold_ne for all 2,484 (R-04).
4. Proportionality (framework §20): the evidence contradicts shipping a change under the locked rule. The action is low-cost and reversible only because it is inaction. A pilot would be proportionate only after acceptance.
5. Ceiling stays predictive, and no predictive expectation is cleared to pilot-test.
6. The rival (level bias, maybe canceling in ratios) is the right worry to write down and the wrong reason to override.

What Morgan takes to the GM: no price changes this cycle; package empty; do not pad; do not describe hold_ne as an optimality finding; next analytical question is the omitted A3 and the A2 decomposition, returned to Stage 4, not a new price list.

Confidence in the no-action verdict, given the locks: high. Confidence that the model is useless for a future redesigned gate: low — that question is unresolved, which is why the alternative is more evidence rather than a permanent stop.

END 04_AI2_DECISION_AND_INFERENCE_CRITIQUE
