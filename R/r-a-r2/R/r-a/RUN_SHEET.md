# PRICEPOINT-001 Stage 4 — R-A RUN SHEET

## Active locked specification

- Design of record: `08_CONSOLIDATED_CANDIDATE_v5_3.md` — SHA-256 `d3af4b594a80c8e458d8c41c4829cf1a8e250e0bbdbaf491811c8c26cbdc9a46`.
- Stage 3 lock receipt: `stage3_locked_design.v3.json` (receipt v3) — SHA-256 `4fb33333bfe1e0310ed433dbe50bc433ba5a05bb7c7eb1fcd64457a1e7eae948`.
- CC-S4-01: every glmnet fit uses convergence threshold `thresh = 1e-12`; R-A passes it directly through `parsnip::set_engine("glmnet", ..., thresh = 1e-12)`. No other model setting changes.

Run from the project root:

`C:\Users\Mark\Documents\R Working Directory\pricepoint\`

Use exactly R 4.6.1:

`C:\Program Files\R\R-4.6.1\bin\Rscript.exe`

## Frozen paths

- Extract: `C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\extract`
- R-A output: `C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-a`
- Fixture result: `validation\fixtures\r_a_fixture_results.csv`

## Run order

1. Freeze the R-A pre-build attestation as `docs\stage-04-execution-validation\attest\r_a_prebuild.md` before executing any R code.

2. Preflight and source-package integrity:

```bat
"C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R\r-a\00_preflight.R --extract-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\extract" --out-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-a" --fixture-out "validation\fixtures\r_a_fixture_results.csv"
```

Expected output after PASS:

- `C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-a\session_info.txt`

Do not run step 3 if preflight exits non-zero.

3. Independent judged R-A pipeline:

```bat
"C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R\r-a\10_run_pipeline.R --extract-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\extract" --out-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-a" --fixture-out "validation\fixtures\r_a_fixture_results.csv"
```

Expected outputs after successful completion:

- `out\r-a\universe.csv`
- `out\r-a\candidates.csv`
- `out\r-a\audit.csv`
- `out\r-a\lineage.json`
- `out\r-a\model_validation.json`
- `out\r-a\m2_attestation.csv`
- `out\r-a\session_info.txt` (from preflight)

Do not edit any judged output or judged R code between this run and fixture execution.

4. Frozen fixture pack harness:

```bat
"C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R\r-a\fixtures\run_fixtures.R --extract-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\extract" --out-dir "C:\Users\Mark\Documents\R Working Directory\pricepoint-stage4-work\out\r-a" --fixture-out "validation\fixtures\r_a_fixture_results.csv"
```

Expected output:

- `validation\fixtures\r_a_fixture_results.csv` with exactly 26 rows, one per frozen fixture ID; the script exits non-zero unless every row is PASS.

5. Only after steps 2–4 pass, hand the frozen R-A outputs to the coordinator for mechanical R-A/R-B reconciliation. Do not inspect or import R-B code, IDs, selected sets, actions, penalties, or results before first-pass R-A freeze.

## Planning runtime estimate (not an observed result)

- Preflight/hash verification: approximately 1–5 minutes, dominated by hashing the ~449 MB sales extract.
- Judged pipeline: approximately 1.5–5 hours on the stated i7-10700 / 31.7 GB machine. The main cost is three independent Mode-A fits (live, d_1913 backtest, d_1885 stability), each with five contiguous CV folds over millions of item-day rows. `tune_grid()` is intentionally run without parallel workers to avoid unapproved dependencies and memory spikes.
- Fixture harness: usually under 2 minutes because it uses synthetic cases and does not fit the production model.

These are execution-planning estimates only. The coordinator should record actual elapsed times from the first PC run rather than treating these estimates as validation evidence.
