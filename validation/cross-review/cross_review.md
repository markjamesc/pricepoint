# Step 11 structural cross-review — PRICEPOINT-001 Stage 4
Status: **PASSED (2026-10-02 ~14:36 CT).** XR-01..03 were RESOLVED by the AI 2 repair r1, Source Gate r2 PASS 24/24 on the unchanged extract, and were VERIFIED by AI 1. XR-04..14 are accepted limitations (owner R10, 14:05 CT). Version 1 (OPEN) is preserved as cross_review.v1_3ede32ea.md.
Compiled on 2026-10-02 at about 14:05 CT. Design v5.4 3cfc71eb…; receipt v4 1ee9f4da….

## Replies (frozen; extracted mechanically)
| Reviewer | Chat | Reviewed | Frozen page | Extracted text |
|---|---|---|---|---|
| AI 1 ChatGPT | R-A chat 6abf7212… (sent ~13:36 CT) | R-B r10 + SQL/Source Gate | 87e72fe5824a461bf44ad14b34459f1514caf5add69dd3006c16e47105e84d0f | 146da4cbebec24ec4c3a74f6da5422a26175c504ad0093976d7c15990b78b7e6 (extractor v2 3bd83244…) |
| AI 2 Grok | grok.com/c/012b438a… (sent ~13:37 CT) | R-A r2 + R-B r10 (+ item 8) | b5270332d47bd29c7fb4e794f06dc27fa82b66e46488dff9c9f6d4ebcb30de20 | 4f91461d715ece4964355b3bbb0dfff3b6b2289aa096aae5a2ff1c04f5a8016f (new extractor_grok v2 3c77cd4d9bcd86dfbaf6ab2b4668fada78126947ee7db2f17258d62182124a1e; 15,549 vs 15,478 visible non-space chars, i.e. full) |
| AI 3 DeepSeek | R-B chat 8f977a7f… (sent ~13:37 CT) | R-A r2 + SQL/Source Gate | 2615f7d0a7095fb666c03573dda1f8b39b03c32eceb1dbcca5e5340bc01a761b | 7a0db7b449d480f8fe993765e0414c151956aeb7503ec3438349e09cfd97dfcf (extractor v2) |

All three reviews were reasoning-only (no reruns). Every judged path received review from a non-author: R-A from AI 2 and AI 3; R-B from AI 1 and AI 2; the Source Gate from AI 1 and AI 3, plus AI 2 on item 8.

## Verdicts
- AI 1: R-B r10 BLOCKING (XR-05); SQL/Gate BLOCKING (XR-01, XR-02, XR-04); design escalations (XR-04, XR-06).
- AI 2: R-A r2 FINDINGS (Minor); R-B r10 FINDINGS (Minor); Gate item 8 MATERIAL.
- AI 3: R-A r2 FINDINGS (Minor); SQL/Gate MATERIAL (item 8).

## Depth questions
- **DQ-1 FX-WDAY-SNAP:** answered yes for both paths' actual recipe and model matrix (AI 1 for R-B; AI 2 for both; AI 3 for R-A). wday is used as stored with levels 1..7; only snap_CA is read; there is one interaction, (scaled log_sell_price) × snap_CA. Coordinator check: the extract has wday = 1 and snap_CA = 0 on 2016-05-21.
- **DQ-2 FX-TE6-SLICE:** answered yes for both pipelines (AI 1 for R-B; AI 2 for both; AI 3 for R-A).
  - All three §7.7 inputs are derived from data with the locked windows.
  - te6 is computed before the collapse, and d_1885 is not used.
  - No counterexample was found. 347 is plausible, though not recomputed.
  - Fixture depth stays a Minor limitation (XR-08).
- **Item 8 caveat:** all three reviewers say it is NOT adequate for §21 item 8 as locked → XR-01.

## Classification summary (full register: findings_register.csv fd41c13632ced4d8d3763a02975914312c43c001edde1b9ff8bdff5d6713d3a2)
| XR | Issue | Coordinator severity | Validity | Path to close |
|---|---|---|---|---|
| XR-01 | Gate item 8 = count + sum, not row-wise | **Material** | valid (3/3) | AI 2 repair → coordinator reruns Source Gate (extract unchanged, so no R rebuild) → AI 1 or AI 3 verifies |
| XR-02 | Gate item 22 does not test TRIM on all varchar categoricals | **Material** | valid | same repair |
| XR-03 | Gate reader treats literal "NA" as missing | Minor | valid | same repair |
| XR-04 | No Gate check of calendar day-grain uniqueness/completeness | Minor on this run (verified unique and complete) | valid design gap | owner ruling |
| XR-05 | R-B penalty "tie" uses 1e-12 tolerance | Minor on this run (R-A's exact rule picked the same idx 14; 75/75) | valid deviation | owner ruling: accept, or R-B r11 |
| XR-06 | is_nba_finals: event_name_1 vs either field | Minor on this run (no NBA/Memorial marker in event_name_2) | valid ambiguity | owner ruling |
| XR-07…14 | docs stamps, fixture depth, design gaps (argmax tie, winsorise with no positive day, item-level guardrail on unchanged), hygiene, relative path, integer week window | Minor | valid | proposed accepted limitations |

Reviewer severities downgraded by the coordinator, with stated evidence:
- XR-01 (AI 1 said Blocking) and XR-02 (Blocking) → Material. These are Gate-proof gaps; nothing shows the current extract is wrong.
- XR-04, XR-05 (Blocking) and XR-06 (Material) → Minor on this run. Each was checked on the frozen data or outputs.

The owner may hold any of these at the reviewer's severity.

## Resolution (v2)
- AI 2 repair r1 (frozen ce1055d5…): 04_raw_price_rowkeys.sql 9e69e2c0…, run_source_gate.R 72162631…, 01 comments only (a08b5749…).
- Source Gate r2: 2026-10-02 14:22 CT, PASS 24/24. Report 5d087e2d…; item 8 keyed 568,783/568,783, 0 mismatches; item 22 untrimmed 0/0/0. Extract unchanged (13d037ef…); raw CHECKSUM TABLE = r1 snapshot.
- Verification by AI 1 / ChatGPT (non-author; frozen 0a6e357a…, text 67c7b39d…): XR-01 VERIFIED, XR-02 VERIFIED, XR-03 VERIFIED; no new findings.
- Owner R10 (rulings/OWNER_RULING_R10.md 502eb010…): XR-04..14 accepted as documented limitations; no R-B rebuild.
- Register: findings_register.csv 90fa70e6c68019edeaac8b3c77b7c1dc878e3cd1c6ce1dca8e116c9e8a723abd (v2 0cca481d… preserved; the original v1 fd41c136… was lost by overwrite, see log).

## Cross-review gate (framework §9)
- Source Gate PASS (r2, 24/24).
- Fixture Gate PASS (26/26 both paths).
- Reconciliation PASS 75/75 (unchanged; no judged code changed).
- Blocking 0. Material unresolved 0. Accepted limitations documented (11). Corrections independently verified.
- **Result: PASSED.**
