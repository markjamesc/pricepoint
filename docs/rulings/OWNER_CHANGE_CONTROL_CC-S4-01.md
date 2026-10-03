# PRICEPOINT-001 · Stage 4 · Owner change control record: CC-S4-01

- **Approval time:** 2026-10-02 11:43 CT (UTC-5) = 2026-10-02T11:43:00-05:00
- **Approved by:** Owner (human), as relayed to the coordinator
- **Exact owner text (verbatim):**

> I approve CC-S4-01: add glmnet convergence threshold 1e-12 to §17A.2 and rebuild/rerun both paths.

- **Bound document:** `run/VALIDATION_GATE_BRIEF_draft.md` (owner checkpoint packet v6)
  - sha256 **96f4a67482770e49d49c56e7207332fe4f85fbedb937f4bb5b39a1e065a2a3d7**, verified at recording; preserved read-only as `run/VALIDATION_GATE_BRIEF_draft.v6_1143.md`.
  - It answers brief v6 decision R8 with option (a). The approved §17A.2 wording comes from brief v6: "Every glmnet fit (all CV folds and final fits, at every origin) uses convergence threshold thresh = 1e-12. No other model setting changes."
- **Applied as (framework change control, same route as CC-S3-01):**
  - design text v5.2 (2065773c…8957) → **v5.3** `08_CONSOLIDATED_CANDIDATE_v5_3.md` (see the CC-S4-01 folder for hashes);
  - Stage 3 lock receipt v2 (a68575d5…) → **v3** `stage3_locked_design.v3.json`;
  - change record `CC-S4-01_change_record.json`;
  - Procedure Gate `pp_gate.R amend design` on the PC.
- **Effect:**
  - Both R paths are rebuilt and rerun from fixtures onward: R-A request r2 and R-B request r9.
  - No tolerance is changed or waived.
  - Every earlier owner ruling (R1–R7) stays in force unchanged.
- **This is NOT the Validation Gate approval (runbook step 15).** It must not be reused or cited as one.
