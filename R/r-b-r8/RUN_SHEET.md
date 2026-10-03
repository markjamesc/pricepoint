# R-B run sheet (PRICEPOINT-001, Stage 4)

**Package:** PP001-S4-R-PACKET-RB-v1. **Path:** R-B. **ml_mode:** A.

## Order of execution

1. `Rscript R/r-b/00_preflight.R --extract-dir <EXTRACT> --out-dir <OUT>`
   Halts on any failure (R != 4.6.1; missing package; DB connector attached;
   hash mismatch in `extract_manifest.txt` or against `sql_extract_sha256`).
   Writes `<OUT>/session_info.txt`.

2. `Rscript R/r-b/10_pipeline.R --extract-dir <EXTRACT> --out-dir <OUT>`
   Reads only the frozen extract. Produces in `<OUT>`:
   - `universe.csv`  (2,484 rows expected)
   - `candidates.csv` (item_id × candidate_price, ≤ 5 per item)
   - `audit.csv` (single row of counts and flags)
   - `lineage.json` (nine §24.4 lineage fields)
   - `model_validation.json` (backtest A1/A2 at d_1913 and d_1885; dept MAE;
     TE6 slice summary; penalty and grid index; fold cuts)
   - `m2_attestation.csv` (per-§24.5-line file:line references)
   Appends judged-run sessionInfo to `<OUT>/session_info.txt`.

3. `Rscript R/r-b/fixtures/run_fixtures.R --fixture-out <FIXTURE_OUT>`
   Runs all 26 frozen fixtures. Exits non-zero if any fixture fails.
   Writes `<FIXTURE_OUT>` = `<...>/validation/fixtures/r_b_fixture_results.csv`.

## Expected output files (paths relative to project root)

- `R/r-b/00_preflight.R`, `R/r-b/10_pipeline.R`,
  `R/r-b/lib/rb_judged.R`, `R/r-b/fixtures/run_fixtures.R`, `R/r-b/RUN_SHEET.md`
- Output dir defaults to `C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-b\`
- Fixture output defaults to `C:\Users\Mark\Documents\R Working Directory\pricepoint\validation\fixtures\r_b_fixture_results.csv`

## Runtime estimate (no observed run in this chat)

- `00_preflight.R`: seconds (I/O on 450 MB, sha256 on 4.8M-row TSV ~ 30–60 s on the reported i7-10700).
- `10_pipeline.R`: minutes. Rough budget: extract read ~30 s; panel/eligibility ~15 s; recipe + 5-fold glmnet tune ~2–4 min (5 folds × 50 penalties on ~3.9M training rows); live + two backtest fits ~2–3 min; horizon scoring (2,484 + up to ~1,100 candidate scenarios) ~10–20 s; writes < 10 s. **Expected total: 6–10 minutes.**
- `run_fixtures.R`: seconds (synthetic panels only).

## Reconciliation tolerances (design §23)

- Exact: keys, row counts, eligibility integers, conjunct flags, `te6`,
  `te6_usable_slice`, `trust_eligible`, `current_price`, `candidate_price`,
  `n_candidates`, `straddle_flag`, `backtest_accept`, all `audit.csv` counts
  and flags, `guardrail_pass`, `legal_change`, `cent_delta_rev`, `action`,
  `package_flag`, `below_line_flag`, `rank_among_qualifiers`, lineage.
- `|Δ| ≤ 0.05` units: `.pred_units_current`, `.pred_units_candidate`.
- `|Δ| ≤ $0.05`: `.pred_rev_current`, `.pred_rev_candidate`, `delta_rev`.
- Diagnostic-trigger only: `penalty_grid_index`, `gain_below_half_mae`,
  `backtest_A1_median_ape`, `backtest_A2_mean_signed_error`,
  `dept_backtest_MAE_revenue`, `te6_ape_i`, `te6_dept_median_ape`.

## Column inventory (75 reconciliation names)

- **universe.csv** carries the item-level subset of the 75 names, plus
  supporting columns.
- **candidates.csv** carries the candidate-level subset (`item_id`,
  `candidate_price`, `abs_log_dist`, `rank_in_cap`, `legal_change`,
  `guardrail_pass`, `cent_delta_rev`, `.pred_units_candidate`,
  `.pred_rev_candidate`, `delta_rev`, `unit_ratio`), plus lineage.
- **audit.csv** carries the count-level subset plus lineage.
- Lineage columns appear on all three tables.

## Independence

R-B implements every judged step from the locked design of record. Shared
with R-A: locked design text, fixture pack, verified SQL package, lineage,
output schema, fold cuts and penalty grid (spec). Not shared: recipe object,
workflow object, fitted model object, tuned result, candidate table, eligibility
list, selected set, action table, scored horizon table. On a FAIL, R-B repairs
its own code toward the spec; R-B never copies from R-A.
