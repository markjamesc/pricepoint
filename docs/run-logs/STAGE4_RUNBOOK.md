# STAGE4_RUNBOOK — PRICEPOINT-001 (Execution & Independent Validation)

Prepared 2026-09-25, ~11:40 CT, by the coordinator (Grok Bot). This is a **read-only prep** document. No Stage 4 work has been done.
Sources:
- pinned workflow checkout f388be8c: `docs/three-ai-validation-and-analysis-framework.md` §2–§10, §6A, §6B, §16–§18, FORWARD ladder and evidence schema; `MASTER_PROMPT.md`; `r-procedure-gate-enforcement.md`; `templates/workflow-gate/stage4_validation_status.example.json`; `validation/workflow-gate/workflow_gate.R` (canonical) + `CONTRACT_V2.md`.
- project (`pricepoint`): `orchestration/master-orchestration-prompt.md` §7, §10, §15, §17; `docs/stage-04-execution-validation/{README.md, stage4_validation_status.example.json}`; `validation/workflow-gate/workflow_gate.R` (local, contract v2); directory READMEs.
- Stage 3: `stage3/deliverables/11_STAGE_04_HANDOFF.md` (v5.2 §20–§27), `stage3_locked_design.json` (sha 27812215…6b56f).

Current state: run_state `current_step = execution` (`pp_gate.R begin execution` AUTHORIZED, exit 0). design_version = `08_CONSOLIDATED_CANDIDATE_v5_2 (sha256 2065773c…8957)`, fixture_version = `fixture_pack_v1` (26 ids, pack sha 1390575a…976f), ml_mode = **A**, capacity_stance = **hard_attention_budget** (Stage 2 and Stage 3).

---

## 0. PRE-FLIGHT BLOCK — must be resolved before Stage 4 can complete (found during this prep)

The two workflow gates run by `pp_gate.R complete execution` require Stage 3 lock fields that the frozen `stage3_locked_design.json` does not contain. As locked, execution completion **cannot** return PASS, even if every analytical tier passes.

| # | Gate | Check that will FAIL | Cause in the locked JSON |
|---|---|---|---|
| B-1 | local `validation/workflow-gate/workflow_gate.R` | "Stage 3 required fields" | 11 fields are missing: decision_statement, analytical_question, decision_horizon, historical_lookback, price_definition, unit_sales_definition, revenue_definition, action_classes, uncertainty_rule, claim_strength_ceiling, source_delivery_contract (master prompt §9 lists them; §17 says to use the union of the local and canonical fields) |
| B-2 | local **and** canonical | "Ranking contract locked" (applies because Stage 2 capacity_stance = hard_attention_budget) | No `ranking_contract` {key, tie_break, capacity_unit, membership_first: true, padding_allowed: false, n: 25}. The content exists in the design (§17.R9, OC-4 N_CAP 25) but is not in the JSON |
| B-3 | local **and** canonical (corrected 11:55 CT, see BLOCK_S3_LOCK_FIELDS.md) | "Reconciliation scorecard" | `reconciliation_critical_fields` is an object {exact, tolerance_0_05_units, …}. The gate requires a flat, nonempty character array that is set-equal to the reconciliation receipt's `fields` |

Why this cannot be fixed by editing the file: the Procedure Gate records completed receipt hashes and rechecks them ("a completed receipt cannot be changed silently"; master §17 says "Completed receipt hashes remain frozen"). Stage 3 is recorded complete at sha 27812215…. MASTER_PROMPT: "Material changes to completed locks require the framework's owner-approved change control; if the existing gate cannot represent the required reopening, pause and report that limitation."
**Required human action:** an owner decision on a dated change-control route, e.g. an owner-approved Stage 3 v5.2 lock-receipt amendment that adds only the fields above, populated verbatim from the approved design (no new design content), with a new receipt identity. **Also** the owner must decide how the Procedure Gate should represent that reopening, because the gate may not support it. Do not edit the JSON, the run_state, or either gate to work around this. Everything below assumes this block is resolved first, or is resolved before step 16.

No other BLOCK: the pricepoint repo has no Stage 4 R or SQL code yet (only READMEs), and no `DBI::dbConnect` / `RMariaDB` use. Note: DBI 1.3.0 and RMariaDB 1.3.5 are installed in the R user library from before today's install. Judged R must not load them (handoff A6).

---

## Actors
| Actor | Stage 4 role |
|---|---|
| **Coordinator (Grok Bot)** | Runs AI 2's SQL via the `mysql` CLI on the PC (read-only; no staging objects). Runs all R scripts under R 4.6.1 (`Rscript.exe`) exactly as delivered. Hashes and preserves evidence. Keeps the information barriers. Runs gates. **Never authors judged SQL/R** and does not repair judged code. May write only a "dumb" mechanical comparator and hashing/receipt scaffolding |
| **AI 1 (ChatGPT, same as Stage 3)** | Builds **R-A** (independent judged path) |
| **AI 2 (Grok Expert)** | Builds the controlled SQL source delivery and the SQL Source Gate. In cross-review, reviews R-A + R-B for judged-logic leakage |
| **AI 3 (DeepSeek)** | Builds **R-B** (independent judged path) |
| **Owner (human)** | Validation Gate approval. Every change-control / new freeze. Any further package installs or system changes. Stage 0 block resolution |

Directory convention: docs = `docs/stage-04-execution-validation/` (receipt, manifests, evidence JSON receipts). Project code/evidence dirs: `sql/source-delivery/`, `R/r-a/`, `R/r-b/`, `validation/{source-gate,fixtures,reconciliation,cross-review,workflow-gate}/`. `artifacts/` holds the byte-identical copy of the Stage 4 receipt plus gate/procedure outputs. Frozen extract data should live outside git, or be hashed only if large. Box mirror: `/workspace/pp001/stage4/`.

---

## Ordered checklist

| # | Step | Actor | Inputs | Outputs (path) | Gate / check that must pass | Human checkpoint |
|---|---|---|---|---|---|---|
| 0 | Resolve BLOCK B-1..B-3 (above) | Owner decides; coordinator carries out the approved change control | Locked JSON; the two workflow_gate.R files | Change-control note + amended/new Stage 3 receipt identity (docs/stage-03 + artifacts, byte-identical) | Local + canonical Stage 3 checks satisfiable; Procedure Gate state consistent | **Yes: owner change control** |
| 1 | Environment preflight | Coordinator | R 4.6.1; env log | `stage4/env/` (done 11:24 CT: tidyverse 2.0.0, glmnet 5.1, parsnip 1.6.0, recipes 1.4.0, Matrix 1.7.5; smoke PASS) | Handoff A7: R == 4.6.1 and packages load. Each path re-runs its own preflight at build time | Done (owner approved the install 11:23 CT). Any further install needs new owner approval |
| 2 | Builder packets (spec-only) | Coordinator assembles; no judged content | Locked design (10_/11_), fixture_pack_v1 (sha 1390575a…), risk register 07_, OC-1..OC-5 from the JSON, output schema, fold cuts and penalty grid (v5.2 §22.3) | Three separate packets: SQL packet → AI 2; R packet → AI 1 and AI 3 (sent after the Source Gate passes) | Fixture freeze identity recorded **before** any builder starts (§6A) | — |
| 3 | Pre-build attestations | AI 2 (SQL path), AI 1 (R-A), AI 3 (R-B), each on its own | Packets | `docs/stage-04-execution-validation/attest/{sql,r_a,r_b}_prebuild.md` citing Stage 3 clauses: all 13 judged items (§6A) including the Mode A item; lineage identities | Blocking if any attestation is missing or incomplete (§6A spine #1) | — |
| 4 | Controlled SQL source delivery | AI 2 authors; **coordinator runs** via `mysql` CLI on the PC (read-only) | v5.2 §20: envelope CA_1 × 5 depts; SALES_LONG 4,821,444, CALENDAR 1,969, PRICES 568,783 rows (9,936 quarantined weeks 11618–11621); only permitted casts/joins; no judged precomputes (§20.4) | `sql/source-delivery/*.sql`; extract files + source-delivery manifest (snapshot, rows, fields, transforms, `sql_extract_sha256` per §20.5) | Extract hashes recorded; no staging objects created | — |
| 5 | **SQL Source Gate** | AI 2 builds; coordinator runs; it must be able to fail | Raw source (mysql, read-only), extract, manifest | `validation/source-gate/source_gate_report.csv` (+ md); evidence receipt `docs/stage-04-execution-validation/evidence/source.json` | All **24** numeric items in v5.2 §21 PASS; any failure = Gate FAIL → repair SQL, regenerate, rerun the whole gate, keep the failed report | — |
| 6 | Freeze source package | Coordinator | Gate-verified extract | Frozen package identified by `sql_extract_sha256`; lineage values (snapshot_id, source_version, observation boundary) | No blank or PENDING lineage. R reads **only** this frozen extract. **R never connects to MySQL** (no DBI/RMariaDB) | — |
| 7 | Independent R-A and R-B builds (barriers up) | AI 1 → R-A; AI 3 → R-B. Coordinator runs each under R 4.6.1 | R packet + frozen extract | `R/r-a/*.R`, `R/r-b/*.R`; per path: universe table (§22.1), candidate table (§22.2), audit table (§22.4), lineage (§24.4), M2 attestation (§24.5), session info | Independence (§22.3): no shared judged code, recipe/fit objects, penalty, scored tables, candidate/eligibility/selected lists. Mode A: glmnet via parsnip `linear_reg` + recipe per §17A, no engine substitution. No DBI/RMariaDB. Neither builder sees the other's code or results | — |
| 8 | **Fixture Gate** | Coordinator runs the frozen pack against both paths | fixture_pack_v1 (26 IDs), R-A/R-B outputs | `validation/fixtures/r_a_fixture_results.csv`, `r_b_fixture_results.csv`; receipt `evidence/fixtures.json` | All 26 PASS in **both** paths. "Build fails if" → build FAIL. Never rewrite fixtures; repair code toward the design and rerun | A fixture correction is allowed only by **owner change control** → fixture_pack_v2 + rerun |
| 9 | **Exact reconciliation** | Coordinator runs a mechanical comparator (not judged) | R-A vs R-B outputs | `validation/reconciliation/reconciliation.csv` + report (rows, unmatched keys, dup keys, differing rows/cols, action/selected mismatches, max numeric diff, control totals); receipt `evidence/reconciliation.json` | v5.2 §23: exact on keys, counts, eligibility integers, flags, prices, candidates, actions, package/below-line/rank, lineage. \|Δ\| ≤ 0.05 units (.pred_units_*), ≤ $0.05 (.pred_rev_*, delta_rev). Tolerance never reconciles a discrete field. PASS/FAIL only. Fixture Gate PASS is a precondition | — |
| 10 | Mismatch loop (if any) | The owning builder repairs its own code; the coordinator reruns from source | Failed report (kept) | Root-cause log (source / translation / plumbing / shared design / recon bug) | Never copy IDs/actions across paths. Never hand-edit tables. Rerun 8→9 | — |
| 11 | **Structural cross-review** (barriers removed) | AI 1 → R-B + Source Gate; AI 2 → R-A + R-B (leakage); AI 3 → R-A + Source Gate | Code, outputs, reports | `validation/cross-review/cross_review.md` + issue register; receipt `evidence/structural.json` | Framework §9 checklist (design compliance, source, grain, joins, dates, missing values, boundaries, reproducibility, counterexamples; Mode A: shared leakage, split misuse, copied model artifacts). No unresolved material/blocking finding; corrections independently verified; 5, 8 and 9 still PASS | — |
| 12 | Lineage / attestation | Coordinator compiles; each path attests | Extract hash, fixture freeze, script hashes, R/pkg versions | receipt `evidence/lineage.json` (source_snapshot, extract_identity, script_versions[]) | Same frozen source + design + fixtures drove both paths; no blanks/PENDING | — |
| 13 | Decision-critical model validation (Mode A → required) | R-A/R-B per the locked contract; coordinator runs | v5.2 §16 backtest (A1/A2 at origin d_1913), TE6 slice (OC-5 Option A), §17A | Model validation report; receipt `evidence/model.json` | Locked acceptance tests / backtest-collapse rule applied exactly as locked (§16.3–16.4); reconciled across paths | — |
| 14 | Validated-data freeze | Coordinator | Everything above | `docs/stage-04-execution-validation/validated_data_manifest.md` (dataset, row count, key profile, snapshot/source_version, SQL/R-A/R-B/recon versions, fixture identity/results, cross-review register, simulation/non-live labels, never-copy attestations, dataset hash) | Blank lineage fails the freeze | — |
| 15 | **Validation Gate** | Coordinator assembles; **owner decides** | §6A spine items 1–9 all green; tiers 1–4 PASS | receipt `evidence/validation.json`; owner approval text + timestamp (CT) | Aggregate PASS; simulation/non-live ceiling stated (PASS unlocks Stage 5 interpretation only, not live release) | **Yes: owner Validation Gate action (explicit; not chat consensus)** |
| 16 | Stage 4 receipt | Coordinator (fields only from executed checks, never defaults) | All receipts + hashes | `docs/stage-04-execution-validation/stage4_validation_status.json` **and** byte-identical `artifacts/stage4_validation_status.json` | Fields below; hashes are the exact SHA-256 of each receipt file | — |
| 17 | Local workflow gate (dry run, optional) | Coordinator | Repo | `validation/workflow-gate/workflow_gate_status.json` | result PASS, stage5_allowed true (conditions below) | — |
| 18 | `Rscript pp_gate.R complete execution` | Coordinator | Repo, run_state | Runs local workflow_gate.R (must be PASS + stage5_allowed), then canonical procedure gate (execution check + canonical workflow gate → `artifacts/workflow_gate_status.json`) → `artifacts/procedure/run_state.json`, `artifacts/procedure/checks/execution-complete.json` | Exit 0 / PASS. If FAIL/BLOCKED: stop and report failed checks; don't edit state or gates | Stage 5 (Finish) follows; Finish gate is an owner gate |

Rules for all steps: failability ladder (fixtures → Source → recon → structural → Validation → Workflow) is hard. There is no verbal waiver. A failed tier blocks every later tier. Correction = dated owner change-control note + new freeze identity + rerun of that tier and its dependents. Preserve every failed report.

---

## Stage 4 receipt — exact fields required

`stage4_validation_status.json` (union of local project example and canonical template; one receipt, two byte-identical copies):

```json
{
  "stage": 4,
  "status": "PASS",
  "design_version_used": "<identical string to stage3.design_version>",
  "fixture_version_used": "fixture_pack_v1",
  "sql_source_gate": "PASS",
  "fixtures": "PASS",
  "r_a_fixtures": "PASS",
  "r_b_fixtures": "PASS",
  "r_a_status": "PASS",
  "r_b_status": "PASS",
  "reconciliation": "PASS",
  "structural_cross_review": "PASS",
  "lineage_attestation": "PASS",
  "validated_data_freeze": "PASS",
  "validation_gate": "PASS",
  "unresolved_issues": 0,
  "decision_critical_model_required": true,
  "decision_critical_model_validation": "PASS",
  "artifact_paths": ["validation/source-gate/source_gate_report.csv", "validation/fixtures/r_a_fixture_results.csv", "validation/fixtures/r_b_fixture_results.csv", "validation/reconciliation/reconciliation.csv", "validation/cross-review/cross_review.md", "docs/stage-04-execution-validation/validated_data_manifest.md"],
  "evidence_receipts": {
    "source":         {"path": "docs/stage-04-execution-validation/evidence/source.json",         "sha256": "<64 hex>"},
    "fixtures":       {"path": "docs/stage-04-execution-validation/evidence/fixtures.json",       "sha256": "<64 hex>"},
    "reconciliation": {"path": "docs/stage-04-execution-validation/evidence/reconciliation.json", "sha256": "<64 hex>"},
    "structural":     {"path": "docs/stage-04-execution-validation/evidence/structural.json",     "sha256": "<64 hex>"},
    "validation":     {"path": "docs/stage-04-execution-validation/evidence/validation.json",     "sha256": "<64 hex>"},
    "lineage":        {"path": "docs/stage-04-execution-validation/evidence/lineage.json",        "sha256": "<64 hex>"},
    "model":          {"path": "docs/stage-04-execution-validation/evidence/model.json",          "sha256": "<64 hex>"}
  }
}
```
(Canonical templates also define role/review/approval attestations. Record the builders, reviewers and the owner's Validation Gate approval as extra fields/evidence. Extra fields are allowed.)

**Every evidence receipt JSON** must contain `status: "PASS"`, `design_version` (== stage3.design_version, exact string), `fixture_version` (== "fixture_pack_v1"), and a nonempty `checked_at_utc`. Each must be nonempty and inside the project root. Paths are relative with no `..`, no absolute paths or drive letters. The sha256 must match the file bytes exactly.
- `reconciliation.json`: `fields` = a flat string array set-equal to stage3 `reconciliation_critical_fields` (needs B-3 fixed); numeric `mismatch_count: 0`; integer `row_count` ≥ 0.
- `fixtures.json`: `cases` = array of {id, expected, observed_a, observed_b}. The ids are exactly the 26 stage3 `fixture_ids`, each once, with no NA, and expected == observed_a == observed_b (scalar comparable values, e.g. outcome strings).
- `lineage.json`: nonempty `source_snapshot`, `extract_identity` (e.g. sql_extract_sha256), `script_versions` (string array of SQL/R-A/R-B/recon script hashes).
- `model.json` (required because ml_mode = A): standard metadata + model validation results.

## What workflow_gate.R needs to return `result: PASS`, `stage5_allowed: true`

Local gate (`Rscript validation/workflow-gate/workflow_gate.R .`, requires jsonlite + digest): **every** check must pass.
1. Stage 1/2/3/4 receipts present and parse. Stage 2 has stage/status/analytical_question and status LOCKED. Stage 3 has all 19 required fields (**B-1**) and status LOCKED.
2. Stage 4 has the 18 required fields (above, minus `fixtures` and `evidence_receipts`, which are checked separately). design_version_used == stage3.design_version. fixture_version_used == stage3.fixture_version.
3. These all == "PASS": sql_source_gate, r_a_fixtures, r_b_fixtures, r_a_status, r_b_status, reconciliation, structural_cross_review, lineage_attestation, validated_data_freeze, validation_gate. unresolved_issues == 0. status == "PASS".
4. Every file in artifact_paths exists relative to the project root.
5. v2: Stage 2 capacity_stance enum ✓ (hard_attention_budget). Stage 3 ml_mode enum ✓ (A). **ranking_contract** locked (**B-2**). decision_critical_model_required == true and validation == "PASS" (Mode A).
6. evidence_receipts has all roles: source, fixtures, reconciliation, structural, validation, lineage, **model**. Each passes the hash check, metadata check, and payload scorecards above.
Output: `validation/workflow-gate/workflow_gate_status.json` (contract_version prospective-v2, result, stage5_allowed, checks[], verified receipts). Exit 0 only on PASS.

Canonical gate (run by the Procedure Gate): reads `artifacts/stage*.json`. It needs Stage 3 window_start/window_end/decision_rules (present), Stage 4 incl. `fixtures`: "PASS", the same v2 mode/receipt checks (incl. ranking_contract — **B-2**). It writes `artifacts/workflow_gate_status.json`. `pp_gate.R complete execution` requires both gates to PASS with stage5_allowed true, the docs/artifacts receipt copies identical, and earlier completed receipt hashes unchanged.

## Human checkpoints in Stage 4 (summary)
1. **Now (step 0):** owner change control for the Stage 3 receipt gaps B-1..B-3, including how the Procedure Gate represents the reopening.
2. **Validation Gate (step 15):** explicit owner approval.
3. **Any change control / new freeze** (fixture correction → v2, design correction, source re-extract after the freeze).
4. **Any further package install or system change** (today's approval covered only tidyverse + glmnet).
Stage 4 PASS allows Stage 5 interpretation of a simulation/non-live pack only. Live release is a separate owner decision.
