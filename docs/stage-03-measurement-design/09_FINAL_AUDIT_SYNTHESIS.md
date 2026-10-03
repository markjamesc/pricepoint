# 09 — FINAL AUDIT SYNTHESIS (PRICEPOINT-001, Stage 3, framework §27; §33 deliverable 09)

Version: 09-v1, 2026-09-25 (CT). Author: coordinator. Candidate audited: `recon/08_CONSOLIDATED_CANDIDATE_v4.md` (sha256 1a2371d9…) with `recon/08v4_RESIDUALS_FOR_AUDIT.md` (RES-01…RES-18).
Audit inputs (frozen; hashes verified OK against `reviews/SHA256SUMS_audit.txt`; each raw file = its parts _p1+_p2+_p3 concatenated):
- `reviews/ai1_audit_raw.txt`: AI1 (ChatGPT), decision-trace lens.
- `reviews/ai2_audit_raw.txt`: AI2 (Grok), methodology lens.
- `reviews/ai3_audit_raw.txt`: AI3 (DeepSeek), SQL→R implementation-contract lens. Part 2 was captured by manual text selection (`ai3_audit_p2_CAPTURE_NOTE.txt`), so its formatting is flattened; its content is treated as authoritative.

**Method.** This is coordinator work with no AI calls and no majority vote. Every item below is decided on the evidence: 06 (reconciliation matrix incl. §A, §C, §D, §E, §F and Appendices A and B), 07 (risk register), DIP (`01_DESIGN_INPUT_PACKAGE.md`), Design B where 06 locks it, the profiles (P01–P04), and the framework. Agreement among auditors is recorded but never used as the reason. Where the auditors disagree and the evidence does not decide, the item goes to the owner.

**Dispositions used:**
- **Accept:** goes into v5 as written.
- **Accept (amended):** goes into v5 with a stated coordinator change, with the reason given.
- **Accept (merged):** folded into another accepted item.
- **Reject:** not carried, with the reason given.
- **Owner-choice:** carried to lock as an owner decision.

---

## 1. Verdicts

| Auditor | Lens | Verdict | Blocking findings (own count) | OD-1 position |
|---|---|---|---|---|
| AI1 (ChatGPT) | Decision trace | **Pass with required revisions** | RES-01…10, 12–15 confirmed as blocking; new AI1-DT-01, -02, -03 blocking | (iii) CANNOT RESOLVE: owner choice at lock |
| AI2 (Grok) | Methodology | **Pass with required revisions** | RES-01…10, 12–15 blocking; new AI2-MA-02 blocking | (ii) ADOPT WITH AMENDMENT: slice-only TE6 |
| AI3 (DeepSeek) | SQL→R contract | **Pass with required revisions** | RES-01…10, 12, 14 blocking; new AI3-IC-01…05 blocking | (ii) ADOPT WITH AMENDMENT: 06#8 kept, dept-median floor ≥ 5 |

**Framework §27 outcome: Pass with required revisions.** All three auditors agree that no finding requires redesign. Every blocking item is closed by exact text taken from frozen sources or by an audit-specified precision edit. Applying the revisions produces candidate v5 (prompt: `recon/AI1_CANDIDATE_REVISION_PROMPT_v5.txt`).

Lock state is unchanged: human approval **NOT given**; Design Gate **NOT passed**.

---

## 2. RES-01…RES-18 disposition table

Key: C = CONFIRM, A = AMEND. Severities are shown as each auditor gave them (B = blocking, NB = non-blocking).

| RES | Subject | AI1 | AI2 | AI3 | Coordinator decision | Reason (evidence) |
|---|---|---|---|---|---|---|
| RES-01 | §17.R1–R9 = 06 Appendix A 1–9 verbatim | C (B) | C (B) | C (B) | **Accept** | 06 Appendix A is the locked pipeline. v4 omits steps 1, 2, 3, 5, 7 and 9 content. In v5, step 5 "[te6 per OD-1]" is carried with the OC-5 pointer (§4 below). |
| RES-02 | M1/M2 cites; M4 re-key; M4 lines for "Not trusted → hold_ne" and "Û(P0) = 0 → hold_ne" | C (B) | C (B) | C (B) | **Accept** | 06#35, 06#37. AI1 also asked for M4 lines on R1 universe, R2 integers, R3 twin/straddle and R6 scoring, and for the M4-014 origin correction (AI1-TN-01/02, §3). |
| RES-03 | glmnet `standardize = FALSE`; recipe-side center/scale | C (B) | C (B) | C (B) | **Accept** | 06#23. |
| RES-04 | Recipe order, references wday 1 / month 1 / dept FOODS_3 / event none | C (B) | C (B) | C (B) | **Accept** | 06#23; Design B §17A recipe. |
| RES-05 | Feature list, windows, NA rule, item proxy | C (B) | C (B) | C (B) | **Accept** | 06#24 (a)–(d); Design B allowed-features table; 06 §F. |
| RES-06 | Folds, cut points, training rows, refit | C (B) | C (B) | C (B) | **Accept** | 06#27. The cut points were re-derived from ceiling(5·d/D) for D = 1941 / 1913 / 1885 and match. |
| RES-07 | §16 backtest detail | C (B) | C (B) | C (B) | **Accept** | 06#28. |
| RES-08 | §7 windows, leading zero, 274 label, DC-2 | C (B) | C (B) | C (B) | **Accept** | 06#6, 06#7, Appendix A-2, 06 §A DC-2. AI1-DT-03 (E_A vs trust conjuncts) is applied together with it. |
| RES-09 | TE6 text in body | C (B) | A (B): slice-only rule, do not present 0.50 as evidenced | C (B) | **Accept, converted**: body carries the OC-5 text (§4) | 06#8 text is carried in full as OC-5 option B. The shared components are carried as locked text. 06 §F bullet 2 applies because the audits did not converge. |
| RES-10 | §8 wday / SNAP / forward calendar | C (B) | C (B) | C (B) | **Accept** | 06#10; 06 §F bullet 1. |
| RES-11 | §11.2 twin governance sentence | C (NB) | C (NB, or B if twins could mutate actions) | C (NB) | **Accept** | 06#29 verbatim; P03 (5 of 2,484). |
| RES-12 | gain_below_half_mae definition | A: no-MAE dept → NA | A: no-MAE dept → NA (not 0) | C | **Accept (amended)**: definition per 06#18/AI3-M-09 plus "If a department has no qualifying d_1913 item, dept_backtest_MAE_revenue is undefined and gain_below_half_mae = NA (not 0)." | The 06#18 flag says whether the gain is below half the MAE. With no MAE, 0 would assert something false, so NA is the only truthful value. The flag never changes action or rank (06#18). AI3-IC-07 (reconciliation of the flag) is handled in §3. |
| RES-13 | 06 §C alternatives verbatim; E_B in M3; §7.1 subject to OC-1 | C (B) | C (B) | C (NB) | **Accept** | 06 §C. The severity difference has no effect because the item is accepted either way. |
| RES-14 | §2 = DIP §A paragraph verbatim | C (B) | C (B) | C (B) | **Accept** | DIP §A "Approved decision statement (Stage 1, locked)". |
| RES-15 | §25 = 06 record (row names/resolutions, DC-3/DC-4, §E 1–8, §F 3 bullets) | C (B) | C (B) | C (NB) | **Accept** | 06 §A, §B col. 2 and resolution column, §E, §F. v4 DC-4 and §E are fabricated. |
| RES-16 | §14 = Design B C1–C12 | C (NB) | C (NB) | C (NB) | **Accept** | 06#21 locks Design B §14 plus the C10 proxy and the P04 Q3 disclosure under C1. |
| RES-17 | §18 status vocabulary | A (final, Part 3): no second column; rename to "Risk lifecycle status (07)" plus a one-sentence note | A: add a second framework field-status column | C: keep 07 statuses plus a one-line mapping footnote | **Accept (amended)**: AI1 Part 3 text, with the file name corrected to `07_RISK_REGISTER.md`. No second column. | Framework §18 defines the register's own Status field ("Resolved, accepted, open, blocking, or deferred"), so the 07 values are the correct register vocabulary. A second field-status column would duplicate M3 (AI1 and AI3). Rejecting AI2's column loses nothing: M3 carries the field statuses. RR-12's status cell is updated to reflect OC-5 in the same way RR-24 reflects 06 §F (§4). |
| RES-18 | §21 items 19–20 in scope | C (NB) | C (NB) | C (NB) | **Accept** (keep) | 06#31 "Design B §21 plus Dossier §9 additions"; 07 RR-19/RR-20. AI3-IC-05 and AI3-IC-08 strengthen these items (§3). |

**RES tally:** 18 items.
- Accepted as written: 15 (RES-01…08, 10, 11, 13, 14, 15, 16, 18).
- Accepted with amendment: 2 (RES-12, RES-17).
- Converted to owner choice: 1 (RES-09 → OC-5; its text is carried).
- Rejected: 0.

---

## 3. New findings from the audits

Classes:
- **T** = transcription from 06/07/DIP/Design B/framework.
- **P** = audit-specified precision; Stage 4 contract strengthening with no decision effect.
- **O** = owner judgment.

No accepted finding changes which items are in scope, which items are trusted, or which action an item receives, with one exception: OD-1/OC-5, handled in §4.

### 3.1 AI1 (decision trace)

| ID | Section | Severity | Required text (short) | Class | Disposition | Reason |
|---|---|---|---|---|---|---|
| AI1-DT-01 | §24.1 FX-CENT-ROUND | B (objection to 06 fixture wording) | Stub R̂(P0) = 100.000 and R̂(Pc) = 100.004 → both round to 100.00 → not legal; unchanged | P | **Accept** (setup values from AI1; AI3-IC-10a merged) | The Appendix B setup states a difference ("R̂(Pc) − R̂(P0) = 0.004"). Appendix A step 7 tests round(R̂(Pc),2) − round(R̂(P0),2). The fixture must stub each side separately. The rule is unchanged. |
| AI1-DT-02 | §24.5 M2 | B | Add gate-class rows: Half-window/persistence N/A; Dual-clock/twin action-override N/A; Full analytical-unit universe; Membership-first + capacity + no-pad; Non-enrolling actions; Lineage field mapping; Capacity/simulation labels; Mode A scoring | T | **Accept** (union with AI3-IC-03) | 06#37 locks "Design B §24.3 extended". Design B §24.3 lists exactly these gate classes. Framework §20 minimum gate classes and the Design Gate addition (items 3, 6, 7) require them. |
| AI1-DT-03 | §7.3 | B | E_A = (n_price_changes_pre ≥ 3) ∧ (units_365 ≥ 180) ∧ (zero_days_365 ≤ 182). e_pw52 and e_cand are separate trust conjuncts; failure → hold_ne. | T | **Accept** | 06 §C OC-2 ("E_A + priced_weeks ≥ 52 + candidate-exists = 363") and 06#6/#7 define E_A as three conjuncts. v4 §7.3 lists five conjuncts, which conflicts with the §7.4 count 364. |
| AI1-TN-01 | M4-014 | NB (trace note) | Origin of "band expansion dropped" is 06#14, not "06 Appendix A" | T | **Accept** | 06#14 (Revise/drop band expansion); 06#18 (min-gain screen removed). |
| AI1-TN-02 | M4 | NB (trace note) | Add M4 lines for R1 universe, R2 integers, R3 current price/twin/straddle, R6 scoring; restore §8/§17A text behind FX-TRAIL-ANCHOR, FX-WDAY-SNAP, FX-INTERACT | T | **Accept** (covered by the RES-01/02/05/10 rewrite) | 06 Appendix A 1, 2, 3, 6; 06#10, #23, #24. |

### 3.2 AI2 (methodology)

| ID | Section | Severity | Required text (short) | Class | Disposition | Reason |
|---|---|---|---|---|---|---|
| AI2-MA-01 | §6.3 | NB | Falsifier → test mapping (T6/A3; A1/A2 at d_1913; event-week share vs P04 47.23%); exploratory cuts are not falsifiers | T | **Accept** | 06#1 reason: "B's falsifiers map to locked tests (backtest A1/A2, calendar-only twin, event-week diagnostic)". Also residual Part C-3. |
| AI2-MA-02 | §24.1, §24.5 TE6 row | B | New fixture FX-TE6-SLICE (fails re-anchored E_A, or U(d_1914–d_1941) = 0, or non-constant price in 11613–11617 → te6 = 0, hold_ne, despite large stub gain). M2 TE6 row cites it; FX-HOLD-NE-PRICES stays on the E_A row. | P | **Accept (amended)**: expected output adds `te6_usable_slice = 0`, and the fixture is valid under both OC-5 options. The E_A sub-case uses the 06#8 three-conjunct E_A. | The v4 M2 TE6 row cites FX-HOLD-NE-PRICES, whose setup (1 distinct price) fails e_chg3, not TE6. Framework §19A requires a fixture where a known case is applicable. The slice rule is common to every OC-5 option. The active pack becomes 26 fixtures (Appendix B 25 active + 1). |
| AI2-MA-03 | §26.3 | NB | Allowed claim = 06#2 verbatim; keep the forbidden sentence "The price change will cause this result." | T | **Accept** | 06#2 (T026). Also residual Part C-6. |
| AI2-MA-04 | §4 Unit protection row | NB | "Reject changes expected to reduce units by more than about 10%. Operational recommendation (OC-3): reject if ρ̂ < 0.90. 0.85 and 0.95 are diagnostic twins only." | T | **Accept** | DIP §A / T006 "about 10%"; 06#13; 06 §C OC-3. Also Part C-2. |
| AI2-MA-05 | §17A.5 (C10 proxy) | NB (objection to 06#24b, no substitution) | item_mean_log1p_units is a level control, not an identification strategy. Report T6/A3 as the slope check. Do not read a small log-price coefficient as "no demand response" without T6. | P (disclosure) | **Accept** | The proxy stays as locked by 06#24b. The sentence only limits interpretation and matches 06#2 (predictive ceiling) and 06#29 T6. It has no decision effect. |

### 3.3 AI3 (SQL→R implementation contract)

| ID | Section | Severity | Required text (short) | Class | Disposition | Reason |
|---|---|---|---|---|---|---|
| AI3-IC-01 | new §22.4; §23 | B | Audit output table (n_universe, n_after_dept_map, n_dropped_by_X1…X6, n_e_* / n_te6 / n_trust_eligible, candidate counts, n_price_0_01_weeks, n_feature_na_rows, floored/scored days, backtest fields, dept MAE, action counts, package counts, TE6 fields); §23 exact equality on §22.4 | T/P | **Accept (amended)**: (1) Counts and flags are exact (06#34 "all audit counts"). (2) Continuous backtest statistics (backtest_A1_median_ape, backtest_A2_mean_signed_error, dept_backtest_MAE_revenue, te6 APE fields) are reported, and a mismatch is a diagnostic trigger, as for penalty_grid_index. The binding outputs backtest_accept and te6 stay exact. (3) Hard-coded values are made conditional: n_universe = 2,484 under OC-1 (a); n_horizon_days_scored_total = 28 × number of scored items. (4) n_training_rows is added (AI3-S4b). (5) TE6 fields follow OC-5. | Design B §7.7 already locks the audit counts. 06#32 and 06#34 lock "all audit counts" as exact. Exact equality on model-derived continuous statistics would contradict 06#34's tolerance design, so no new tolerance numbers are invented. |
| AI3-IC-02 | §17.R7 note; §22.2; §23 | B | cent_delta_rev = round(R̂(Pc),2) − round(R̂(P0),2) per candidate; exact field; sign mismatch = FAIL; repair toward base R round(x, 2) on each side | P | **Accept** | 06#17 (base R round(x, 2) on each side) and 06#34 (any action mismatch = fail; repair toward spec) already govern. Making the rounded delta an explicit exact field makes the rule testable. |
| AI3-IC-03 | §24.5 | B | 4 gate rows (universe; non-enrolling; lineage; capacity/simulation labels) | T | **Accept (merged)** into AI1-DT-02 | Same evidence. AI1's set is the superset. |
| AI3-IC-04 | §20.5; §21; §24.4 | B | sql_extract_sha256 = SHA-256 of a manifest ("path \| byte_length \| file_sha256", lexicographic, LF, UTF-8); fixture_pack_sha256 by the same rule; §21 item 21 manifest exists | P | **Accept (amended)**: "at the path recorded in §24.4" becomes "at the path recorded in the Stage 4 extract-freeze record" (§24.4 records no path). | 06#36 requires both hashes on every export; 06#34 requires exact lineage equality. A defined byte layout removes non-substantive lineage failures. No decision effect. |
| AI3-IC-05 | §21 item 19 | B (coordinator: required, non-decision-changing) | Replace item 19 with a full per-item position→d check; keep the 0/1940 spot checks | T/P | **Accept** | Dossier §9 ("position-to-d spot checks and full multiset checksum if possible"), within 06#31 scope. The severity is overstated: rotation, reversal and shift are already caught by the two endpoint checks. It is accepted because it is cheap and in scope. |
| AI3-IC-06 | §20.3; §21 | NB | Casts for wday, month, year, snap_CA; TRIM varchar; blank event fields → NULL; §21 item 22 | T/P | **Accept (amended)**: cast targets stated as "integer" (06#30 wording; the SIGNED/UNSIGNED dialect detail is left to Stage 4). Adds "R maps NULL event_type_1 to the reference level none". | DIP §B: raw columns are varchar. Design B §17A: event_type_1 is a "factor including a level for blank/none". This is a mechanical cast, not judged logic. |
| AI3-IC-07 | §23 | NB | gain_below_half_mae: exact after rounding delta_rev to 4 dp, OR declare it diagnostic and not reconciled | P | **Accept (amended; AI3's alternative)**: gain_below_half_mae is reported by both paths; a mismatch is a diagnostic trigger, not a FAIL | 06#18: the flag "never changes action or rank". 06#34 treats non-decision fields such as penalty_grid_index as diagnostic triggers. Rounding delta_rev to 4 dp does not remove the boundary problem. |
| AI3-IC-08 | §21 item 20 | NB | Price attachment preserves 4,821,444 rows; each (store_id, item_id, d) key appears exactly once | T | **Accept** | Dossier §9 join multiplicity; 07 RR-20; 06#31. |
| AI3-IC-09 | §20.4 (and §19 item 7 pointer) | NB | Name the prohibited precomputes (n_price_changes_pre … first_positive_d, item_mean_log1p_units); "SQL may deliver only the source fields listed in §20.1" | T | **Accept** | 06#30 prohibits judged precomputes; 06#32 names these as R-built fields. |
| AI3-IC-10a | §24.1 FX-CENT-ROUND | NB | Stub R̂(Pc) = 1.004, R̂(P0) = 1.000 | P | **Accept (merged)** into AI1-DT-01 (AI1 values used) | Same defect. One setup is enough. |
| AI3-IC-10b | new FX-CENT-ROUND-HALF | NB | Stub R̂(Pc) = 1.005; expected "per stated convention" | P | **Reject** | The expected result is not determinate: 1.005 has no exact binary representation, so base R `round(1.005, 2)` depends on representation. The fixture would test floating-point behaviour, not the locked rule. 06#17 already fixes the function (base R round(x, 2) on each side), and AI3-IC-02 makes the rounded values exact recon fields, so both paths must agree whatever the half-cent outcome. |
| AI3-IC-11 | §20.2; §9.4 | NB | Permitted joins: CALENDAR ↔ SALES_LONG on d only; no CALENDAR↔PRICES join on wm_yr_wk and no SALES_LONG↔PRICES join without wm_yr_wk in SQL | T | **Accept (amended)**: the join attaches only the SALES_LONG fields listed in §20.1 (`date`, `wm_yr_wk`). AI3's longer attach list is not adopted; CALENDAR is delivered in full separately. | 06#30 ("SALES_LONG carries wm_yr_wk attached from the calendar on d (mechanical)"); 06#11; residual Part C-4. |
| AI3-IC-12 | §24.1 FX-LEAK-11618 cite | NB | Cite §8.3, §17A.5–17A.6, §20.4 | T | **Accept (amended)**: cite = "§8.3; §17.R4; §17A.5–17A.6; §20.4" (§17.R4 kept because the fixture also tests the candidate set) | Appendix B: "price ∉ candidate set; never a feature". |
| AI3-S2 | §21 | NB (Part 2) | Add delivered-key uniqueness, no-internal-gap, null profile, date alignment, missing-price pattern | T | **Accept in part**: add (23) delivered-key uniqueness (SALES_LONG (store_id, item_id, d); PRICES (store_id, item_id, wm_yr_wk)) and (24) no NULL units or sell_price in delivered rows. Reject the rest as already covered. | P01 Q1–Q3 key uniqueness; Dossier §9. Already covered: no-internal-gap and the missing-price pattern by item 8 (value equality on every row) plus row counts; date alignment by items 3/19; dept domain by item 17. |
| AI3-S3 | §9.3, §9.4 | NB (Part 2) | State the intermediate grain item × candidate; prohibit a direct calendar×price join | T | **Accept** | 06#11; 06#32 candidate table grain; residual Part C-4. |
| AI3-S4a | §22.2 | NB (Part 2) | Candidate table adds guardrail_pass (per candidate) and cent_delta_rev | P | **Accept** | Makes the §17.R7 legal test reproducible from the candidate table (FX-GUARD-10, FX-CENT-ROUND). Fields only. |
| AI3-S4b | §22.4 | NB (Part 2) | Carry n_dropped_by_X1…X6, n_price_0_01_weeks, n_feature_na_rows, backtest components, n_training_rows | T/P | **Accept** (into §22.4 via AI3-IC-01) | Design B §7.7; 06#22, #24(c), #27, #28. |
| AI3-S4c | §22.1 | NB (Part 2) | first_priced_wk_wks_back; min_gain_waived; event_week_only_flag sidecar | P | **Reject** | Not in 06#32. first_priced_wk already exists. min_gain_waived belongs to the screen that 06#18 removed (replaced by the NA rule, RES-12). The event flag is fixture-only and optional per AI3 itself. |
| AI3-S5 | §22.3 | NB (Part 2) | Name the non-shared objects (recipe, workflow, glmnet fit, tune object, selected penalty, scored horizon tables); attestations per §24.5; repair-time never-copy rule | T | **Accept** | 06#33 and framework §19A (independence; attestations). 06#34 "repair toward spec". |
| AI3-S6a | §23 | NB (Part 2) | "When a continuous-tolerance check passes but any action, package, below-line or rank field disagrees, reconciliation FAILS and both paths repair toward the spec independently; tolerance is never used to reconcile a discrete field." | T | **Accept** | Restates 06#34. |
| AI3-S6b | §22/§23 | NB (Part 2) | boundary_flag when ρ̂ within ±0.001 of 0.90, cent delta within ±$0.01, argmax/rank gaps ≤ $0.10 | P | **Reject** | It introduces new unevidenced numeric bands that are not in 06#34. The locked rule already resolves boundary disagreements (discrete mismatch = FAIL; repair toward spec; never average). The owner may add it later as a Stage 4 diagnostic without a design change. |
| AI3-OD1-a | §7.7 / §17.R5 / §17.R8 | (OD-1 answer) | te6 is computed before the §17.R8 collapse; the collapse overrides actions but does not delete te6 | T | **Accept** (common OC-5 text) | Appendix A order (step 5 before step 8); 06#28 collapse acts on actions of trust-eligible items. |

**New-finding tally:** 32 findings (AI1 5, AI2 5, AI3 22).
- **Accepted: 29**, made up of:
  - 19 as written: AI1-DT-01, DT-02, DT-03, TN-01, TN-02; AI2-MA-01, 03, 04, 05; AI3-IC-02, 05, 08, 09, S3, S4a, S4b, S5, S6a, OD1-a;
  - 8 with amendment: AI2-MA-02; AI3-IC-01, 04, 06, 07, 11, 12; AI3-S2 (in part);
  - 2 merged: AI3-IC-03 into AI1-DT-02; AI3-IC-10a into AI1-DT-01.
- **Rejected: 3** (AI3-IC-10b, AI3-S4c, AI3-S6b).
- **Owner-choice: 0** findings. The only new owner-choice item is OC-5, which comes from OD-1 (§4), not from a finding.

---

## 4. OD-1 (TE6, "the expectation for the next four weeks isn't a guess", T040): collation and outcome

### 4.1 Positions

| Element | 06#8 (coordinator proposal) | AI1 | AI2 | AI3 |
|---|---|---|---|---|
| Overall | Open, recommendation below | **(iii) CANNOT RESOLVE**; keep 06#8 text as the documented proposal; owner decides at lock | **(ii) ADOPT WITH AMENDMENT**: slice-only | **(ii) ADOPT WITH AMENDMENT**: 06#8 including APE limbs |
| Usable d_1913 slice | E_A true re-anchored at d_1913; same price weeks 11613–11617; realized units d_1914–d_1941 > 0 | Sound ("well traced … conservative") | Yes; re-anchored conjuncts also include priced_weeks ≤ 11613 and n_candidates ≥ 1 (P0_bt = week-11613 price) | Yes; re-anchored conjuncts include priced_weeks ≥ 52 at ≤ 11613 |
| No usable slice | te6 = 0 → hold_ne | Agrees | Agrees | Agrees |
| APE_i ≤ 0.50 limb | Proposed; "0.50 is a coordinator proposal with no evidence behind it" | Unsupported before results | Drop; APE_i is an audit field only | Keep (acknowledges it is not evidence-based) |
| Dept-median limb | APE_i ≤ median APE of usable items in dept | Relative only: half of a poorly predicted dept passes | Drop | Keep, applied only when the dept has ≥ 5 usable items |
| Collapse interaction | Row 28 gate "exists either way" | Collapse is model-level and does not supply an item-level threshold | Collapse overrides; d_1885 does not enter TE6 | te6 computed before collapse; collapse overrides actions |
| Outputs | — | — | APE_i audit field plus dept summary | te6_ape_i, te6_dept_median_ape, te6_usable_slice, te6_rule_fired |

### 4.2 Evidence assessment

1. **Convergence exists on the slice component.** All three auditors accept that TE6 requires a usable d_1913 slice and that no slice → te6 = 0 → hold_ne. This component traces to 06#8, T040 ("the expectation for the next four weeks isn't a guess") and T016/T038 (prefer hold to a bad move). It is locked into v5 as the common text.
2. **No convergence on the item-level APE threshold.** AI1 cannot resolve, AI2 drops the threshold, and AI3 keeps it with a floor. No evidence decides it:
   - 06#8 itself states that 0.50 has no evidence behind it.
   - No model results exist, and framework §32 forbids thresholds invented after viewing results.
   - DIP T040 "I don't have a number" gives no stakeholder number.
   - Per 06 §F bullet 2 ("if the audits do not converge it becomes an owner choice at the lock"), the threshold becomes **OC-5 (Owner choice pending)**.
3. **Factual correction to one auditor argument.** AI2 says the dept-median rule "fails half of usable items by construction". For the 06#8 OR-rule (APE_i ≤ 0.50 **OR** ≤ dept median), at least half of each department's usable items pass, so the rule never fails more than half. AI1's point ("half of a poorly predicted department could satisfy the median rule") is the correct statement of the weakness. This correction does not by itself decide the option.
4. **Slice conjunct set.** 06#8 says "E_A true when re-anchored at d_1913". E_A is the three-conjunct rule (06 §C OC-2; 06#6; AI1-DT-03). AI2's extra conjuncts (priced_weeks and n_candidates at 11613) and AI3's (priced_weeks at 11613) are not in 06#8. v5 transcribes 06#8 literally: the three E_A conjuncts re-anchored (changes at weeks ≤ 11613; units_365 and zero_days_365 over d_1549–d_1913). Every live trust-eligible item must also pass e_pw52 and e_cand at d_1941 (§17.R5), so the extra re-anchored conjuncts would add little. This is a transcription decision, not an owner choice. It is flagged in §6 for visibility.

### 4.3 Outcome: **OD-1 → OC-5 (Owner choice pending at lock)**. Not Locked by audit.

**Common text, Locked-proposed; applies under every OC-5 option (v5 §7.7):**
> te6_usable_slice = 1 iff all of: (1) E_A holds when re-anchored at o = d_1913, i.e. n_price_changes (weeks ≤ 11613) ≥ 3 AND units_365 over d_1549–d_1913 ≥ 180 AND zero_days_365 over d_1549–d_1913 ≤ 182; (2) the item has the same sell_price in each of weeks 11613, 11614, 11615, 11616 and 11617; (3) realized units summed over d_1914–d_1941 > 0. Items with te6_usable_slice = 0 have te6 = 0 and fail trust → hold_ne. APE_i = abs(Û_i(P0_bt) − U_i)/U_i, where Û_i(P0_bt) is the d_1913 backtest model's 28-day prediction at P0_bt (week-11613 price) and U_i is realized units d_1914–d_1941. It is emitted as te6_ape_i for every item with te6_usable_slice = 1 (NA otherwise), with a per-dept median te6_dept_median_ape. te6 is computed before §17.R8; the collapse (backtest_accept = 0) overrides actions but does not change te6. d_1885 does not enter TE6.

**OC-5 options:**
- **Option A (slice-only; AI2):** te6 = te6_usable_slice. APE_i is reported only; no item-level APE threshold.
- **Option B (06#8 as written; AI3):** te6 = 1 iff te6_usable_slice = 1 AND (te6_ape_i ≤ 0.50 OR te6_ape_i ≤ te6_dept_median_ape).
  - Variant B1: 06#8 verbatim.
  - Variant B2 (AI3 amendment): the dept-median limb applies only when the dept has ≥ 5 usable-slice items; otherwise only the 0.50 limb applies. te6_rule_fired ∈ {absolute, dept_median, both, neither} is emitted.
  - Labelled provisional policy; 0.50 is a coordinator proposal with no evidence behind it (06#8).
- Both options use the same fixture FX-TE6-SLICE. If the owner picks B, the fixture FX-TE6-APE must also be added before freeze. Its setup is three usable-slice items with stubbed values:
  - te6_ape_i = 0.49 with dept median 0.40 → te6 = 1 (absolute limb);
  - te6_ape_i = 0.55 with dept median 0.60 → te6 = 1 (median limb; under B2 only if the dept has ≥ 5 usable items, otherwise 0);
  - te6_ape_i = 0.55 with dept median 0.40 → te6 = 0.
  The build fails on any other te6.

**Coordinator recommendation: Option A.** Reasons (evidence, not votes):
- It is the only option with no unevidenced item-level number (06#8; framework §32).
- Model-level accuracy is already enforced by the A1/A2 collapse (06#28), and APE_i stays visible for the owner and Stage 5.
- te6 under A is computed from data alone: prices, units and calendar at d_1913. It is exactly reconcilable, whereas B's APE limb depends on model predictions carried with a ±0.05 tolerance, so B risks R-A/R-B te6 flips near 0.50 and the median.
- It satisfies T040's third prong with an explicit "we can check the forecast" condition.

Option B remains fully defensible if the owner wants an item-level accuracy screen. B2 is preferred over B1 because it avoids a median over tiny departments (HOUSEHOLD_2 has 3 E_A items).

**Consequences in v5:**
- M3 replaces the OD-1 row with OC-5.
- §7.7 carries the common text plus the options.
- §17.R5 "[te6 per OD-1]" becomes "[te6 per OC-5, §7.7]".
- M2 TE6 row: "Yes — OC-5 pending lock", cites FX-TE6-SLICE.
- §18 RR-12 status: "Open (owner choice OC-5 at lock; formerly OD-1)".
- §25.1 row 8: "Open (analyst-method) → OC-5 after final audit (06 §F bullet 2)".
- §26.1: no Open item. §26.2 adds OC-5.
- §27.1: Open 0, Owner-choice 5.
- Tally: **"Candidate complete: 0 Open, 5 Owner-choice items."**
- 07's note ("If OD-1 is still Open at lock, RR-12 becomes Blocking") now reads as: OC-5 must be decided at lock before builders run (framework §17A: Mode A lock fields frozen). Otherwise the Design Gate cannot pass.

---

## 5. OD-2: identification and status

- **What it is:** OD-2 = `n_snap_next_28_known`, the forward 28-day SNAP count feature (06 row 25; 06 §D "Disputed"; Design B allowed-features table).
- **07's mentions:** RR-24 status "Open (Disputed OD-2)", and the 07 Design Gate summary lists "RR-24 (n_snap_next_28, Disputed OD-2)" under Open (design). Both were written before 06 §F.
- **Resolution:** 06 §F bullet 1 (coordinator addendum, before the candidate), status Lock (methodological principle, framework §25):
  - The feature is DROPPED from the judged model and every twin, because raw_calendar ends at d_1969 (train/score mismatch).
  - SNAP enters only as same-day snap_CA plus the log_sell_price:snap_CA interaction.
  - FX-SNAP-FWD is retired.
  - "OD-2 is no longer Open/Disputed."
- **Audits:** no auditor reopens it. AI2 and AI3 confirm RES-05/RES-10 with the feature dropped.
- **Status: Resolved (Locked by 06 §F). No action** beyond what v4 already carries: §17A.10, §24.2 retired list, and §18 RR-24 = "Resolved (06 §F: dropped)". v5 adds an informational M3 row ("OD-2 — dropped, 06 §F"). The stale 07 summary wording is superseded, not edited, because 07 is frozen.

---

## 6. Conflicts between auditors and how they were resolved on evidence

| # | Conflict | Positions | Resolution | Evidence |
|---|---|---|---|---|
| K1 | OD-1 TE6 threshold | AI1 cannot resolve; AI2 slice-only; AI3 06#8 + floor | **OC-5 Owner choice**; common slice text locked; recommendation A | §4; 06#8 "no evidence behind it"; 06 §F bullet 2 |
| K2 | TE6 slice conjuncts | AI2 adds priced_weeks + n_candidates at 11613; AI3 adds priced_weeks; AI1 silent (06#8) | 06#8 literal: three-conjunct E_A re-anchored | 06#8 text; 06 §C OC-2 definition of E_A |
| K3 | RES-09 | AI1/AI3 confirm 06#8 text; AI2 amends to slice-only | Body carries both as OC-5 options | 06 §F bullet 2 |
| K4 | RES-17 | AI1 rename + note (Part 3; withdrew its Part 1 two-column text); AI2 two columns; AI3 keep + mapping footnote | Rename + note, no second column | Framework §18 Status field vocabulary; M3 already holds field status |
| K5 | RES-12 no-MAE case | AI1/AI2 NA; AI3 confirm (no sub-point) | NA | 06#18 flag semantics; a 0 value would be false |
| K6 | gain_below_half_mae reconciliation | AI3-IC-07: exact after 4-dp rounding, or diagnostic | Diagnostic (mismatch = diagnostic trigger) | 06#18 "never changes action or rank"; 06#34 diagnostic-trigger precedent |
| K7 | FX-CENT-ROUND setup | AI1 100.000/100.004; AI3 1.000/1.004 plus a half-cent fixture | AI1 values; half-cent fixture rejected | Appendix A step 7; 06#17; floating-point indeterminacy of 1.005 |
| K8 | M2 gate rows | AI1 8 classes; AI3 4 classes | AI1 union set (8 classes, incl. the renamed capacity row), plus AI3's minimum-gain diagnostic row | Design B §24.3; framework §20 table; 06#37 |
| K9 | M2 TE6 fixture | AI2 new FX-TE6-SLICE; AI3/AI1 did not object to FX-HOLD-NE-PRICES | New fixture | FX-HOLD-NE-PRICES tests e_chg3, not TE6 (Appendix B setup) |
| K10 | Severity of RES-13/15 (AI3 NB vs AI1/AI2 B), RES-16 (all NB), AI3-IC-05 (B) | — | Severity does not change the disposition; all are accepted | — |
| K11 | §23 boundary handling | AI3-S6 boundary_flag with new bands vs 06#34 | Discrete-fail sentence accepted; boundary_flag rejected | 06#34 |
| K12 | Audit table exactness | AI3-IC-01 "exact equality on every field of §22.4" vs 06#34 tolerance design | Counts and flags exact; continuous backtest statistics diagnostic | 06#34 |

---

## 7. True owner-judgment items (would change which items or actions) vs transcription/precision fixes

### 7.1 Owner judgment at lock (the only items that change which items or actions)

| ID | Item | Options | Coordinator recommendation | Source |
|---|---|---|---|---|
| OC-1 | Department scope | (a) FOODS_1/2/3 + HOUSEHOLD_1/2, HOBBIES excluded (2,484 items); (b) add HOBBIES; (c) FOODS_3 + HOUSEHOLD_1 only | (a) | 06 §C (unchanged) |
| OC-2 | Eligibility tightness | E_A + priced_weeks ≥ 52 + candidate-exists = 363 (29/99/172/60/3); E_A ∧ nd ≥ 4 = 274 before candidate-exists (273 or 274 after); E_C = 177; E_B = 784 | E_A (363), or E_A ∧ nd ≥ 4 | 06 §C (unchanged) |
| OC-3 | "about 10%" → ρ̂ < 0.90 rejected | 0.90 hard; 0.85/0.95 twins | 0.90 hard | 06 §C (unchanged) |
| OC-4 | "about 25" → N_CAP = 25 | 25 hard; 25 ± tolerance | 25 hard | 06 §C (unchanged) |
| **OC-5 (new)** | **TE6 item-level rule** | **A slice-only; B 06#8 APE limbs (B1 verbatim / B2 with dept floor ≥ 5)** | **A** | **06#8, 06 §F; §4 above** |

### 7.2 Decided on evidence; not owner judgment, listed for visibility

- **TE6 slice conjunct set:** 06#8 literal (K2). This affects which items pass TE6 at the margin, but it is fixed by 06's text.
- **RES-12 NA rule:** no action effect.
- **Rejections of AI3-IC-10b, AI3-S4c, AI3-S6b:** no action effect.

### 7.3 Transcription/precision fixes (no decision effect)

All other accepted items:
- RES-01…08, 10, 11, 13…18;
- AI1-DT-01…03, TN-01/02;
- AI2-MA-01, 03, 04, 05, and MA-02 (a fixture);
- AI3-IC-01, 02, 04–09, 11, 12, S2 (part), S3, S4a, S4b, S5, S6a, OD1-a;
- residual Part C editorial items 1–12.

These restore locked text or add Stage 4 contract precision. None changes the universe, eligibility, candidates, scoring, legality, action or ranking.

---

## 8. v5 instruction summary (handed to AI1)

- **Prompt:** `recon/AI1_CANDIDATE_REVISION_PROMPT_v5.txt`. It is a patch on v4 in **5 replies**, each ending "END OF V5 PATCH PART k/5". Final line: **"Candidate complete: 0 Open, 5 Owner-choice items."**
- **Expected v5 inventory:**
  - M3: OC-1…OC-5 Owner choice pending, 0 Open, 0 Disputed.
  - Active fixtures: 26 (25 v4 + FX-TE6-SLICE).
  - M2 rows: 28.
  - §21 conditions: 24.
  - §22 subsections: 22.1–22.4.
  - Headings: 28 top-level sections unchanged (framework §31 27 + §17A); M3 and M4 blocks kept.
- **Unchanged sections:** everything not named in the prompt stays byte-for-byte as in v4, in particular §3 (except curly quotes), §5, §10, §12, §15, §19 (except the item 4 and item 7 pointers) and §18 rows other than RR-12 and the header.

*End of 09.*
