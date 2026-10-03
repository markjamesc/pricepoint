# PricePoint Warrant Ledger

Use this ledger to separate implementation agreement from substantive warrant.

A rule can be translated perfectly by both R-A and R-B and still have weak business or evidentiary justification.

## Status labels

Use one of:

- **Source-backed**
- **Stakeholder-locked portfolio requirement**
- **Methodological judgment**
- **Model-dependent**
- **Unresolved / Open**

## Ledger

| ID | Rule / assumption / threshold | Stage introduced | Basis | Evidence / rationale | Sensitivity needed? | Status |
|---|---|---:|---|---|---|---|
| W-001 | Decision horizon = 28 days after the review date; four-week cycle | 1 | Stakeholder (synthetic) | T012 | No | Stakeholder-locked portfolio requirement |
| W-002 | Revenue definition = units sold × shelf price (no margin) | 1 | Stakeholder | T004; no cost data | No | Stakeholder-locked portfolio requirement |
| W-003 | Unit downside guardrail ≈10% expected unit decline | 1 | Stakeholder candidate guardrail | T006; "about" to be fixed at Stage 3 | Yes | Stakeholder-locked portfolio requirement (exact value Open) |
| W-004 | Eligibility principle: real past price changes + steady sales; cutoffs delegated | 1 | Stakeholder principle; analyst cutoffs | T008, T010 | Yes | Unresolved / Open (Stage 3) |
| W-005 | Hold — not enough evidence (abstention) outcome required | 1 | Stakeholder | T016; threshold delegated | Yes | Stakeholder-locked (threshold Open) |
| W-006 | Capacity ≈25 actual price changes, ranked by biggest trusted revenue gain, no padding, overflow below line | 1 | Stakeholder | T018, T020, T024 | Yes | Stakeholder-locked (ranking formula Open) |
| W-007 | Causal-language restriction: expectations to pilot, not guarantees | 1 | Stakeholder | T026 | No | Stakeholder-locked portfolio requirement |
| W-008 | Raise/cut recommendations carry a specific pilot price; construction delegated | 1 | Stakeholder | T034 | Yes | Stakeholder-locked (method Open) |
| W-009 | Trust is an evidence gate: untrusted expectations become "hold — not enough evidence" and do not rank | 2 | Stakeholder | T038, T040 | Yes | Stakeholder-locked (gate definition Open, Stage 3) |
| W-010 | Ranking within the trusted set is by expected revenue gain vs current price | 2 | Stakeholder | T024, T038 | Yes | Stakeholder-locked (formula/tie-break Open, Stage 3) |
| W-011 | No stakeholder minimum-gain cutoff; any materiality rule is an analyst choice, disclosed | 2 | Stakeholder delegation | T040 | Yes | Methodological judgment (Open) |
| W-012 | capacity_stance = hard_attention_budget; unit = actual raise/cut recommendations per cycle | 2 | Stakeholder; all three AIs independently | T018, T020, T024 | Yes | Stakeholder-locked portfolio requirement |
| W-013 | Decision-date information bound: no prices or sales after 2016-05-22 except the current price in effect | 2 | Stakeholder T012/T014 plus feasibility finding | feasibility_probe_01 | No | Stakeholder-locked; implementation Stage 3 |
| W-014 | Locked Stage 3 measurement design = v5.2 (sha256 2065773c3224dd6eb083ef6b8f57deb88786ee1742d7da5f66f7fdf825278957); lock record stage3_locked_design.json (sha256 2781221592adcb9d25c3c4611e72e9dc5d13d2f308413caac2b173258562f56b) | 3 | Owner approval (Mark, 2026-09-25 08:38 CT) of the three-AI design | docs/stage-03-measurement-design/08_CONSOLIDATED_CANDIDATE.md = 10_STAGE_03_MEASUREMENT_DESIGN.md body; owner_approval_text in the lock JSON; Design Gate self-check DG-SC-2 Gates 1–11 PASS | No | Methodological judgment (owner-approved, locked) |
| W-015 | ml_mode A: judged predictive contract. parsnip linear_reg(mode = "regression"), engine glmnet elastic net, mixture = 0.5, standardize = FALSE (recipe-side scaling), penalty grid 10^seq(-4, 1, length.out = 50) selected by 5 contiguous time folds (ties → larger penalty), seed 20160522, 13 locked features, predictions floored at 0 | 3 | DIP project requirement (tidyverse + parsnip); framework FORWARD use test; 06#3, #23, #24, #27 | v5.2 §17A.1–17A.10 | Yes (calendar-only ablation T6; A3 comparison) | Model-dependent (locked) |
| W-016 | Population = OC-1 (a): CA_1 × FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2 = 2,484 items; HOBBIES excluded; every universe item gets one row and one action | 3 | Owner choice OC-1 (a) | v5.2 §7.1–7.2, §17.R1; 06 §C OC-1 | No | Stakeholder-locked (owner choice OC-1 (a)) |
| W-017 | Trust subset = OC-2 E_A: n_price_changes_pre ≥ 3, units_365 ≥ 180 and zero_days_365 ≤ 182 over d_1577–d_1941, plus priced_weeks ≥ 52 and candidate-exists = 363 items (29/99/172/60/3); non-trusted → hold_ne. Resolves the W-004 cutoffs | 3 | Owner choice OC-2; profiled counts (06#6) | v5.2 §7.3–7.5, §17.R2, §17.R5 | Yes (T7 E_A ∧ nd ≥ 4 = 274; T8 E_C = 177) | Methodological judgment (owner-confirmed OC-2) |
| W-018 | Unit guardrail = OC-3: legal change requires ρ̂ = Û(Pc)/Û(P0) ≥ 0.90, hard; 0.85 and 0.95 reported as sensitivity only. Fixes the W-003 exact value | 3 | Stakeholder T006 ("about 10%"); owner choice OC-3 | v5.2 §4, §11.1–11.2, §17.R7 | Yes (0.85 / 0.95 twins) | Stakeholder-locked (exact value owner-fixed, OC-3) |
| W-019 | Capacity = OC-4: N_CAP = 25 hard; package = ranks 1…min(25, n), rest below the line; rank ΔR̂ desc → pred_units_current desc → n_price_changes_pre desc → item_id asc; no padding; holds and unchanged do not consume slots. Resolves the W-006 formula and W-010 tie-break | 3 | Stakeholder T018/T020/T024; owner choice OC-4 | v5.2 §17.R9; M4-014/015 | No | Stakeholder-locked (owner choice OC-4) |
| W-020 | TE6 = OC-5 Option A: te6 = te6_usable_slice (E_A re-anchored at d_1913; same price in weeks 11613–11617; realized units d_1914–d_1941 > 0), otherwise hold_ne; no per-item error threshold (te6_ape_i and the dept median reported only) | 3 | Stakeholder T040; owner choice OC-5; 06#8 / 06 §F | v5.2 §7.7, §17.R5; fixture FX-TE6-SLICE | Yes (te6_ape_i reported) | Methodological judgment (owner choice OC-5 Option A) |
| W-021 | Backtest at origin d_1913 (A1 median APE ≤ 0.40; A2 mean signed error within ±0.20; failure → every trust-eligible item hold_ne); d_1885 stability check, reporting only; price weeks 11618–11621 delivered but quarantined from all judged logic | 3 | Analyst design (06#28, 06#10/#30); thresholds are provisional policy | v5.2 §8.3–8.4, §16.1–16.5, §17.R8, §20.1; fixtures FX-BACKTEST-COLLAPSE, FX-LEAK-11618 | Yes (stability origin d_1885) | Methodological judgment (provisional thresholds, disclosed) |
| W-022 | 23 design sections are a disclosed coordinator mechanical transcription of the v5 revision-prompt blocks (AI1 non-delivery/deviation). AI1 countersigned lightly (verification only): "COUNTERSIGN: CONFIRMED" | 3 | Coordinator process deviation, disclosed to and approved by the owner | 08_PROVENANCE.md (sha256 cfd6e319ea2822aa7d0198f559b6f2ec6d7773f320e317c5a377e398bffb66d6); 08_AI1_COUNTERSIGN.txt (sha256 13276291fb98a8e18b4fda1740346bdcadf663ee8ea13149f51430be2d68d74d); owner approval text | No | Methodological judgment (disclosed, owner-approved) |
| W-023 | Final three-AI audits (framework §27) all returned "Pass with required revisions"; coordinator synthesis 09 accepted the revisions, which were applied in v5–v5.2 (compliance check: 104/104 Faithful, 47/47 Done) | 3 | AI1/AI2/AI3 final audits; coordinator synthesis | 09_FINAL_AUDIT_SYNTHESIS.md (sha256 92fefed3ece24acd9ed4c337c4020f48136e8929922f2f21a6e04f7a31a909e1); 09_audits/ai1–ai3_audit_raw.txt | No | Source-backed |
| W-024 | Known-case fixture pack v1: 26 active fixtures, frozen by hash before R-A/R-B start and never rewritten after a Fail; sha256 1390575a2ee1a6488d0ef53e0cf93396ddbb299455a1b47571626a9d6ecf976f | 3 | 06 Appendix B + FX-TE6-SLICE (09 AI2-MA-02); OC-5 Option A adds no FX-TE6-APE | fixture_pack_v1.md; v5.2 §24.1–24.3 | No | Methodological judgment (locked, frozen by hash) |
| W-025 | Source architecture: one frozen, bounded extract through the mysql command-line client, verified by the SQL Source Gate (24 items, identified by sql_extract_sha256), with the identical package fed to R-A and R-B. R never connects to MySQL (no DBI/RMariaDB); no staging objects in the database | 3 | DIP (database paragraph); framework §19–§21 | v5.2 §19–§21, §24.4; 11_STAGE_04_HANDOFF.md A3–A6 | No | Stakeholder-locked portfolio requirement |

## Required PricePoint entries

At minimum, add explicit ledger entries for any final:

- decision horizon;
- product/store eligibility rule;
- historical lookback;
- minimum history requirement;
- minimum price variation requirement;
- revenue definition;
- unit-sales downside guardrail;
- price-change action threshold;
- `INCONCLUSIVE` / abstention rule if used;
- model choice that materially affects the decision;
- causal-language restriction;
- and final recommendation criterion.

Do not hide a business judgment inside code because two implementations happen to agree on it.
