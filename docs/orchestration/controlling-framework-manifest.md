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

Adopted reusable framework commit: `61b739a1a20de5f1332c138d548bd696e40844f0`.

[Immutable framework snapshot](https://github.com/markjamesc/ai-augmented-analyst-workflow/tree/61b739a1a20de5f1332c138d548bd696e40844f0). Use that snapshot for the paths above; the main-branch URLs are navigation links, not permission to change a locked run.

The local prompt, examples and gate implement explicit capacity stance and ML mode plus the [v2 receipt contract](../../validation/workflow-gate/CONTRACT_V2.md). This is setup adoption only: no analytical stage has started or passed. At formal run start, record the exact project commit containing the local prompt and gate alongside this framework commit.
