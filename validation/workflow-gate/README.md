# PricePoint deterministic workflow gate

This directory contains the cross-stage R enforcement layer for the PricePoint five-stage workflow.

The gate is deliberately separate from Stage 4 analytical validation.

- Stage 4 R-A/R-B and reconciliation ask whether the locked analytical contract was independently implemented consistently.
- The workflow gate asks whether the prescribed procedure was actually followed before Stage 5 begins.

Run from the repository root:

```bash
Rscript validation/workflow-gate/workflow_gate.R .
```

Dependency:

```r
install.packages("jsonlite")
```

The gate reads:

- `docs/stage-01-02-start-framing/stage1_decision.json`
- `docs/stage-01-02-start-framing/stage2_framing.json`
- `docs/stage-03-measurement-design/stage3_locked_design.json`
- `docs/stage-04-execution-validation/stage4_validation_status.json`

It verifies Stage 1/2 locks, Stage 3 contract completeness, Stage 3→4 design/fixture version continuity, Source Gate, both fixture paths, R-A/R-B completion, exact reconciliation, structural cross-review, lineage/attestation, validated-data freeze, unresolved issues, declared evidence files, and any decision-critical model validation.

It writes:

`validation/workflow-gate/workflow_gate_status.json`

Stage 5 is allowed only when that report contains:

```json
{
  "result": "PASS",
  "stage5_allowed": true
}
```

A FAIL is not repaired by editing the gate output. Repair the owning upstream stage or implementation, regenerate the truthful receipt, and rerun the gate.
