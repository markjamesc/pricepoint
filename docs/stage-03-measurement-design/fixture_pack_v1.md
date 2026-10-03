# FIXTURE PACK v1 — PRICEPOINT-001 Stage 3 (Known-case fixtures, M1)

- **fixture_version:** `fixture_pack_v1`
- **Source:** `recon/08_CONSOLIDATED_CANDIDATE_v5_2.md` §24.1 (lines 1722–1749), SHA-256 `2065773c3224dd6eb083ef6b8f57deb88786ee1742d7da5f66f7fdf825278957`. The table in Part B is a byte-for-byte copy of those lines.
- **Prepared:** 2026-09-25 (CT) by the coordinator, mechanically extracted with no edits. Status: **DRAFT, pending owner lock.** The pack is frozen by path + SHA-256 (`fixtures/fixture_pack_v1.sha256`) before R-A/R-B start (§24.3). Known-case fixtures may not be rewritten after a Fail to greenwash a build (§24.3).
- **Active fixtures:** 26 (06 Appendix B: 25 active + FX-TE6-SLICE). Retired, not in the pack: FX-SNAP-FWD, FX-UNCHANGED-SMALLGAIN (§24.2).
- **Conditional:** if the owner selects OC-5 = Option B, FX-TE6-APE (09 §4) is added **before** the freeze. That creates fixture_pack_v2 with a new hash; v1 is not edited.
- **Form:** synthetic panels; stub predict functions where a prediction is needed (§24.1).
- **Fixture Gate authority:** each §24.1 row defines a build-fail condition ("Build fails if"). The pack is frozen by hash before R-A/R-B start (§24.3). §24.5 M2 maps every locked gate to its fixture IDs with R-A and R-B attestations. §27.3 runs fixture execution (step 5) before reconciliation (step 6).

## A. Fixture index

| # | Fixture ID | §17.R clause(s) | Origin |
|---|---|---|---|
| 1 | FX-HOLD-NE-PRICES | §17.R5 | [MC] 06 Appendix B |
| 2 | FX-GUARD-10 | §17.R7 | [MC] 06 Appendix B |
| 3 | FX-CUT-OK | §17.R7 | [MC] 06 Appendix B |
| 4 | FX-ARGMAX | §17.R7 | [MC] 06 Appendix B |
| 5 | FX-NOPAD | §17.R9 | [MC] 06 Appendix B |
| 6 | FX-CAP25 | §17.R9 | [MC] 06 Appendix B |
| 7 | FX-MEMBER | §17.R1, §17.R5 | [MC] 06 Appendix B |
| 8 | FX-LEAK-11618 | §8.3; §17.R4; §17A.5–17A.6; §20.4 | [MC] 06 Appendix B |
| 9 | FX-CURRENT-11617 | §17.R3 | [MC] 06 Appendix B |
| 10 | FX-HORIZON-28 | §17.R6 | [MC] 06 Appendix B |
| 11 | FX-TIE | §17.R9 | [MC] 06 Appendix B |
| 12 | FX-ELIG-BOUNDARY | §17.R2, §17.R5 | [MC] 06 Appendix B |
| 13 | FX-PW52 | §17.R2, §17.R5 | [MC] 06 Appendix B |
| 14 | FX-BAND25 | §17.R4 | [MC] 06 Appendix B |
| 15 | FX-NOCAND | §17.R4, §17.R5 | [MC] 06 Appendix B |
| 16 | FX-EVENT-SINGLE | §17.R4 | [MC] 06 Appendix B |
| 17 | FX-CAP5-TIE | §17.R4 | [MC] 06 Appendix B |
| 18 | FX-UP0-ZERO | §17.R7 | [MC] 06 Appendix B |
| 19 | FX-CENT-ROUND | §17.R7 | [MC] 06 Appendix B; 06#17; AI1-DT-01 |
| 20 | FX-MINGAIN-DIAG | §17.R7, §17.R9; §11.3 | [MC] 06 Appendix B |
| 21 | FX-BACKTEST-COLLAPSE | §17.R8 | [MC] 06 Appendix B |
| 22 | FX-TRAIL-ANCHOR | §17.R6 | [MC] 06 Appendix B |
| 23 | FX-WDAY-SNAP | §17.R6 | [MC] 06 Appendix B |
| 24 | FX-WEEK-ORDINAL | §17.R2 | [MC] 06 Appendix B |
| 25 | FX-INTERACT | §17.R6 | [MC] 06 Appendix B |
| 26 | FX-TE6-SLICE | §17.R5; §7.7 | [MC] 06#8; 09 AI2-MA-02 |

## B. Fixture table (verbatim from v5.2 §24.1)

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

## C. Per-fixture records (same text, one block per fixture)

### 1. FX-HOLD-NE-PRICES
- Label in §24.1: FX-HOLD-NE-PRICES (B)
- Setup / predicate: Item with 1 distinct pre-origin price; stub gain large
- Expected (pass): trust_eligible = 0; action = hold_ne
- Build fails if: any raise/cut
- Clause: §17.R5
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 2. FX-GUARD-10
- Label in §24.1: FX-GUARD-10 (B)
- Setup / predicate: Trusted; stub Û(Pc) = 89, Û(P0) = 100; Pc > P0; ΔR̂ > 0
- Expected (pass): guardrail_pass = 0; action ≠ raise
- Build fails if: raise assigned, or revenue used instead of units
- Clause: §17.R7
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 3. FX-CUT-OK
- Label in §24.1: FX-CUT-OK (B)
- Setup / predicate: Cut candidate; stub units +20%; ΔR̂ > 0
- Expected (pass): action = cut
- Build fails if: cuts banned
- Clause: §17.R7
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 4. FX-ARGMAX
- Label in §24.1: FX-ARGMAX (B)
- Setup / predicate: Two legal candidates, ΔR̂ = 10 vs 8
- Expected (pass): picks ΔR̂ = 10
- Build fails if: picks 8 or the nearer price
- Clause: §17.R7
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 5. FX-NOPAD
- Label in §24.1: FX-NOPAD (B)
- Setup / predicate: 3 qualifiers
- Expected (pass): n_package = 3; no hold/unchanged promoted
- Build fails if: package padded
- Clause: §17.R9
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 6. FX-CAP25
- Label in §24.1: FX-CAP25 (B)
- Setup / predicate: 30 qualifiers, strictly decreasing ΔR̂
- Expected (pass): n_package = 25; n_below_line = 5; order by ΔR̂
- Build fails if: 26th in package / unsorted
- Clause: §17.R9
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 7. FX-MEMBER
- Label in §24.1: FX-MEMBER (B)
- Setup / predicate: Universe contains a zero-eligible item
- Expected (pass): row present; action = hold_ne
- Build fails if: row dropped
- Clause: §17.R1, §17.R5
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 8. FX-LEAK-11618
- Label in §24.1: FX-LEAK-11618 (B)
- Setup / predicate: Lucrative price exists only in week 11618
- Expected (pass): price ∉ candidate set; never a feature
- Build fails if: future price used
- Clause: §8.3; §17.R4; §17A.5–17A.6; §20.4
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 9. FX-CURRENT-11617
- Label in §24.1: FX-CURRENT-11617 (B)
- Setup / predicate: 11616 = 3.00, 11617 = 3.50
- Expected (pass): current_price = 3.50; straddle_flag = 1; current_price_11616 = 3.00
- Build fails if: uses 3.00 or average
- Clause: §17.R3
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 10. FX-HORIZON-28
- Label in §24.1: FX-HORIZON-28 (B)
- Setup / predicate: Calendar stub with 2-day week 11621
- Expected (pass): n_horizon_days_scored = 28 (d_1942–d_1969)
- Build fails if: 4 × 7 week logic, dropped or doubled days
- Clause: §17.R6
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 11. FX-TIE
- Label in §24.1: FX-TIE (B)
- Setup / predicate: Equal ΔR̂, different pred_units_current
- Expected (pass): higher units ranks first
- Build fails if: item_id or random first
- Clause: §17.R9
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 12. FX-ELIG-BOUNDARY
- Label in §24.1: FX-ELIG-BOUNDARY (new)
- Setup / predicate: Items: (chg 3, units 180, zero 182) / (chg 2, 180, 182) / (3, 179, 182) / (3, 180, 183)
- Expected (pass): only the first passes E_A
- Build fails if: any other passes / first fails
- Clause: §17.R2, §17.R5
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 13. FX-PW52
- Label in §24.1: FX-PW52 (new)
- Setup / predicate: E_A true, priced_weeks = 51
- Expected (pass): e_pw52 = 0; hold_ne
- Build fails if: trusted
- Clause: §17.R2, §17.R5
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 14. FX-BAND25
- Label in §24.1: FX-BAND25 (new)
- Setup / predicate: P0 = 4.00; history prices 3.00, 3.01, 4.99, 5.00, 5.01
- Expected (pass): candidates include 3.00 (= 0.75·P0), 3.01, 4.99, 5.00 (= 1.25·P0); exclude 5.01
- Build fails if: boundary prices dropped or 5.01 kept (float compare)
- Clause: §17.R4
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 15. FX-NOCAND
- Label in §24.1: FX-NOCAND (new)
- Setup / predicate: Trusted-otherwise item with no in-band prior price
- Expected (pass): e_cand = 0; hold_ne; no band expansion
- Build fails if: band expanded or unchanged assigned
- Clause: §17.R4, §17.R5
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 16. FX-EVENT-SINGLE
- Label in §24.1: FX-EVENT-SINGLE (new)
- Setup / predicate: Price seen in 1 week containing a Sporting (or Cultural) event_type_1 day; another price seen in 1 non-event week
- Expected (pass): first excluded, second kept; n_candidates_event_filtered = 1
- Build fails if: only National/Religious filtered, or non-event single-week price dropped
- Clause: §17.R4
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 17. FX-CAP5-TIE
- Label in §24.1: FX-CAP5-TIE (new)
- Setup / predicate: P0 = 4.00; 7 in-band prices incl. 3.20 and 5.00 (equal abs log distance)
- Expected (pass): 5 nearest kept; distances compared after rounding to 10 decimals, so 3.20 and 5.00 tie and the lower price (3.20) ranks first
- Build fails if: more than 5 kept, or tie order differs
- Clause: §17.R4
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 18. FX-UP0-ZERO
- Label in §24.1: FX-UP0-ZERO (new)
- Setup / predicate: Trusted; stub Û(P0) = 0
- Expected (pass): action = hold_ne
- Build fails if: unit ratio computed / raise
- Clause: §17.R7
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 19. FX-CENT-ROUND
- Label in §24.1: FX-CENT-ROUND (new)
- Setup / predicate: Trusted item with a single candidate; stub R̂(P0) = 100.000 and R̂(Pc) = 100.004, so round(R̂(P0), 2) = 100.00 and round(R̂(Pc), 2) = 100.00 (cent_delta_rev = 0.00)
- Expected (pass): legal_change = 0; not legal; action = unchanged
- Build fails if: raise/cut assigned
- Clause: §17.R7
- Status / Origin: Locked-proposed / [MC] 06 Appendix B; 06#17; AI1-DT-01

### 20. FX-MINGAIN-DIAG
- Label in §24.1: FX-MINGAIN-DIAG (new, replaces FX-UNCHANGED-SMALLGAIN)
- Setup / predicate: Legal change with ΔR̂ below stub half-MAE
- Expected (pass): action = raise/cut, ranked normally; gain_below_half_mae = 1
- Build fails if: demoted to unchanged or hold_ne
- Clause: §17.R7, §17.R9; §11.3
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 21. FX-BACKTEST-COLLAPSE
- Label in §24.1: FX-BACKTEST-COLLAPSE (new)
- Setup / predicate: Stub backtest A1 median APE = 0.45
- Expected (pass): backtest_accept = 0; every trust-eligible item → hold_ne
- Build fails if: any raise/cut/unchanged survives
- Clause: §17.R8
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 22. FX-TRAIL-ANCHOR
- Label in §24.1: FX-TRAIL-ANCHOR (new; AI3-M-13)
- Setup / predicate: Horizon rows d_1942 and d_1969
- Expected (pass): trailing_28d_units identical on both = Σ d_1914…d_1941
- Build fails if: uses post-origin (unknown) days or rolls forward
- Clause: §17.R6
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 23. FX-WDAY-SNAP
- Label in §24.1: FX-WDAY-SNAP (new; AI2-F18)
- Setup / predicate: 2016-05-21 row; snap_TX = 1, snap_CA = 0 day
- Expected (pass): wday = 1 (Saturday); SNAP feature = 0
- Build fails if: ISO recode or TX/WI SNAP used
- Clause: §17.R6
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 24. FX-WEEK-ORDINAL
- Label in §24.1: FX-WEEK-ORDINAL (new; DC-1)
- Setup / predicate: Week window "last 52 weeks ending 11617"
- Expected (pass): weeks 11518–11552 and 11601–11617 (52 weeks)
- Build fails if: integer range 11566–11617 (17 weeks)
- Clause: §17.R2
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 25. FX-INTERACT
- Label in §24.1: FX-INTERACT (new; AI3-m-04)
- Setup / predicate: Recipe stub
- Expected (pass): model matrix has exactly one interaction column = scaled log_sell_price × snap_CA
- Build fails if: missing or extra interactions
- Clause: §17.R6
- Status / Origin: Locked-proposed / [MC] 06 Appendix B

### 26. FX-TE6-SLICE
- Label in §24.1: FX-TE6-SLICE (new; AI2-MA-02)
- Setup / predicate: Three items that pass E_A, e_pw52 and e_cand at d_1941, each with a large stub gain: (a) units_365 over d_1549–d_1913 = 179 (E_A fails when re-anchored at d_1913); (b) realized units d_1914–d_1941 = 0; (c) sell_price in week 11613 differs from week 11617
- Expected (pass): te6_usable_slice = 0; te6 = 0; trust_eligible = 0; action = hold_ne for all three, under every OC-5 option
- Build fails if: any raise/cut/unchanged assigned
- Clause: §17.R5; §7.7
- Status / Origin: Locked-proposed / [MC] 06#8; 09 AI2-MA-02

END OF FIXTURE PACK v1
