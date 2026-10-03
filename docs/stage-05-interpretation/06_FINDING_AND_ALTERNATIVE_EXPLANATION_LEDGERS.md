# 06_FINDING_AND_ALTERNATIVE_EXPLANATION_LEDGERS — PRICEPOINT-001 Stage 5 (draft v1, post-cross-review)

## A. Finding Ledger (framework §13)
| ID | Finding | Class (§9) | Evidence role (§16) | Status | Decision consequence |
|---|---|---|---|---|---|
| SF-01 | The locked binding backtest failed on A2 (0.2697 vs ±0.20); A1 passed (0.1824) | Conclusive for the defined question | Primary (gate) | Validated (R-01) | Collapse §17.R8 fires; no trusted price expectation exists |
| SF-02 | All 2,484 items are hold_ne; package 0/25; below-line 0 | Conclusive | Primary (outcome) | Validated (R-04) | GM package is empty and must not be padded |
| SF-03 | One usable item, FOODS_3_092 (U = 1, Û 65.6009), contributes 0.1872 of A2 0.2697 | Observed fact plus coordinator arithmetic | Diagnostic (most important caveat, R11) | Row Validated; share is coordinator arithmetic | None this cycle: the lock stands (R11). Exposes a design gap, routed to Stage 3 |
| SF-04 | A2 is positive (over-prediction) at both origins; d_1885 A2 0.1794 is inside the band | Sensitivity-dependent / non-binding (relabelled from "Conflicting", per XR5_AI2 #4/#12) | Diagnostic | Validated with limitation (R-02) | None; d_1885 cannot override d_1913 (§16.4) |
| SF-05 | Analytical hypothesis (within-item price variation carries predictive ranking information): **weakened, not rejected** | Inconclusive | — | The backtest-miss falsifier fired; A3/T6 is absent (G-1) | None this cycle |
| SF-06 | The independent R-A and R-B builds agree exactly | Conclusive | Audit | Validated (R-05) | Supports confidence that the rule was executed correctly |
| SF-07 | Current prices are not shown to be optimal, and no causal price effect is shown | Unsupported (as a claim) | — | — | Forbidden wording: "current prices are right" or "raising price will…" |
| SF-08 | Dept revenue MAE values are non-trivial | Validated; diagnostic only | Diagnostic | R-11 | None. The comparison with N_CAP 25 was removed (XR5_AI1 #4) |

## B. Alternative-Explanation Ledger (framework §18)
| ID | Alternative explanation for "all hold_ne" | Support | Against | Residual | Effect on action |
|---|---|---|---|---|---|
| AE-1 | **Small-denominator / influence:** the A2 failure is driven by a single item with near-zero realized units (possible stockout or delisting, design C7) rather than by a general calibration failure | SF-03: 0.1872 of 0.2697 comes from one row; median APE passes | Locked A2 has no floor; R11 keeps the lock | High plausibility. Not validated by Stage 4 (coordinator arithmetic) | None this cycle (R11). Primary next question (Stage 3) |
| AE-2 | Common multiplicative over-prediction that cancels in ρ̂ and in the sign of ΔR̂, so rankings could survive (AI 2) | Same sign of A2 at both origins | No candidate-price backtest; A3 absent | Medium, untested | Does not lift hold_ne |
| AE-3 | Genuine level-calibration miss at d_1913 (origin-specific drift) | A2 at d_1913 > d_1885 | d_1885 is receipt-level only | Unresolved | None |
| AE-4 | Price endogeneity / unlabeled promotions (design C1) bias the price slope | No promotion field exists | Mitigations locked in the design | High, accepted with disclosure | None. Predictive ceiling unchanged |
| AE-5 | Path-specific bug (R-A vs R-B) | None | 75/75 exact reconciliation; identical A1/A2 | Low | None |

## C. Claim-to-Evidence Ledger (framework §14), for claims in 11_
| Claim | Type (§10) | Evidence | Status |
|---|---|---|---|
| D-1 "No price changes are recommended this cycle" | Recommendation | R-01, R-04, §17.R8 | Supported (AI 1, AI 2, AI 3) |
| D-2 "The model failed its locked A2 test" | Computed result | R-01 | Verified |
| D-3 "One item contributes 0.1872 of A2" | Computed result (coordinator arithmetic) | R-01c | Labelled per R11 |
| D-4 "This does not show current prices are best" | Interpretation | SF-07 | Supported |
| D-5 "Under the locked model there is no trusted 28-day expectation to pilot-test" | Interpretation at the ceiling | design §5; SF-01 | Supported (AI 2 C-22) |
