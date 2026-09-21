# PricePoint Controlling Framework Manifest

This file records the controlling reusable framework documents and the project-local deterministic workflow gate for the PricePoint run.

If conversational memory conflicts with the adopted framework files, the adopted files control.

| Stage / control | Framework | Repository path | Purpose |
|---|---|---|---|
| 1–2 | Start & Framing | `ai-augmented-analyst-workflow/docs/three-ai-start-and-framing-dialogue-framework.md` | Discover and lock the decision and analytical question |
| 3 | Measurement Design | `ai-augmented-analyst-workflow/docs/three-ai-measurement-design-framework.md` | Freeze analytical meaning and the SQL→R handoff |
| 4 | Validation & Analysis | `ai-augmented-analyst-workflow/docs/three-ai-validation-and-analysis-framework.md` | Controlled SQL source delivery, Source Gate, independent R-A/R-B, fixtures, reconciliation, cross-review |
| 4 optional | R Workflow Engine | `ai-augmented-analyst-workflow/docs/ENGINE.md` | Optional post-gate R implementation/reporting aid |
| Cross-stage | Deterministic R Workflow Gate | `pricepoint/validation/workflow-gate/workflow_gate.R` | Verify that required procedural controls, versions, evidence files, and model-validation requirements were actually satisfied before Stage 5 |
| 5 | Interpretation & Recommendation | `ai-augmented-analyst-workflow/docs/three-ai-interpretation-and-recommendation-framework.md` | Convert validated evidence into a proportionate recommendation |

## Canonical URLs

- https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/three-ai-start-and-framing-dialogue-framework.md
- https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/three-ai-measurement-design-framework.md
- https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/three-ai-validation-and-analysis-framework.md
- https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/ENGINE.md
- https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/three-ai-interpretation-and-recommendation-framework.md

## Project-local workflow enforcement

The workflow gate is deliberately distinct from Stage 4 analytical validation.

Stage 4 determines whether the locked analytical contract was implemented and validated correctly. The workflow gate determines whether the required procedure was actually followed and evidenced.

Before Stage 5, Grok Bot must run:

```bash
Rscript validation/workflow-gate/workflow_gate.R .
```

Stage 5 is blocked unless the generated `validation/workflow-gate/workflow_gate_status.json` contains both:

```text
result = PASS
stage5_allowed = true
```

A verbal AI statement that the process was followed is not a substitute for this gate.

## Versioning rule

At formal run start, record the commit/blob/retrieval version for every controlling reusable framework and the project-local master prompt/gate. If a controlling component changes materially during the project, document the change and determine whether any previously passed gate must be reopened.

## Prospective adoption — September 20, 2026

Previously adopted reusable framework commit: `61b739a1a20de5f1332c138d548bd696e40844f0` (superseded prospectively by the adoption below).

[Previous immutable framework snapshot](https://github.com/markjamesc/ai-augmented-analyst-workflow/tree/61b739a1a20de5f1332c138d548bd696e40844f0), retained as adoption history. The current adoption below controls the prospective run; main-branch URLs remain navigation links, not permission to change a locked run.

The local prompt, examples and gate implement explicit capacity stance and ML mode plus the [v2 receipt contract](../../validation/workflow-gate/CONTRACT_V2.md). This is setup adoption only: no analytical stage has started or passed. At formal run start, record the exact project commit containing the local prompt and gate alongside this framework commit.

## Current adoption — GrokBot R checkpoint template

Adopted reusable workflow and Master Prompt commit: `c8ed0d91592bf2eeba6b7b0b40d40d5d23a5f40b`.

[Immutable workflow snapshot](https://github.com/markjamesc/ai-augmented-analyst-workflow/tree/c8ed0d91592bf2eeba6b7b0b40d40d5d23a5f40b).

Use this commit for all reusable framework paths above, `docs/MASTER_PROMPT.md`, `procedure-gate/procedure_gate.R`, `procedure-gate/procedure.json`, and `workflow-gate/workflow_gate.R`. The PricePoint-specific prompt is [master-orchestration-prompt.md](master-orchestration-prompt.md), with executable checkpoints in section 17.

The project-local Workflow Gate remains unchanged and mandatory. Execution completion first checks it, then the canonical Procedure Gate invokes the canonical Workflow Gate. Stage 5 requires both releases. Preserve the separate local report at `validation/workflow-gate/workflow_gate_status.json` and canonical report at `artifacts/workflow_gate_status.json`.

Stages 1–4 use byte-identical receipt copies in the existing documented folders and `artifacts/`; section 17 defines the mapping and conflict checks. The canonical templates supplement the local receipt fields. After Finish, the outer gate must write `artifacts/final_certificate.json` with PASS and certified true. Record the PricePoint commit containing this prompt at run start. This setup update does not authorize starting the analysis or certify any stage.
