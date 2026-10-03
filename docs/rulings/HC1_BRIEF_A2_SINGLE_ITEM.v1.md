# HC-1 brief — PRICEPOINT-001 Stage 5 — A2 failure is driven by one item (v1, 2026-10-02 ~21:20 CT)
SIMULATION / NON-LIVE. Bound to Stage 4 receipt 9536fe98…664d and design v5.4 3cfc71eb…80ef. Nothing has been recomputed in Stage 4, and nothing has been changed.

## How it surfaced
AI 3 r2 (DeepSeek) claimed that X1 gives n_usable 346, not 345, and A2 ≈ 0.4556. It routed this as "Recompute in Stage 4". **That claim is wrong.**
- AI 3 counted 8 stable_price = 0 rows. There are 9; it missed FOODS_3_469.
- X1 has exactly 345 usable rows, and FOODS_3_092 is already one of them.
- On the box, X1 gives median ape 0.1824 and mean signed_error 0.2697, both matching the receipt.
- So R-01 is **Verified**, and AI 3's "Recompute in Stage 4" item has no basis.

## What the box check of AI 3's claim exposed (observed facts from the validated model_validation.json per_item, ce09ea11…)
- **FOODS_3_092 (FOODS_3):**
  - realized backtest units, d_1914–d_1941: **1**;
  - predicted: **65.6009**;
  - signed_error = ape = **64.6009**;
  - units_365 = 727; trust-eligible = 1; te6 = 1 (te6_ape_i is also 64.6009).
- Its contribution to the mean is 64.6009 / 345 = **0.1872** of the 0.2697. This is coordinator arithmetic.
- **Coordinator diagnostic, NOT a Stage 4-validated result and NOT a decision input:**
  - Mean signed error over the other 344 items = **0.0827**, inside ±0.20.
  - Median signed error = 0.0166; 180 of 345 errors are positive; the next-largest signed error is 3.72.
  - In plain terms, the A2 failure that triggered the collapse comes from **one item with a near-zero denominator**. This is plausibly a stockout or delisting (design confounder C7: "stockouts as zeros… cannot distinguish").
- AI 2 already predicted this pattern in its first pass (C-10, "a right tail of large positive errors pulls the mean") and asked for an A2 decomposition.

## Why this is HC-1
- **Possible defect in a locked design choice.** Design §16.2–16.3 excludes only U = 0. There is no minimum-U floor and no robust form of A2. So one item with U = 1 can decide the backtest gate.
- **Decision relevance.** This is the only reason backtest_accept = 0. If the gate had passed, the run would have produced a modeled price list instead of 2,484 hold_ne.
- **Framework constraints.**
  - §4 forbids repairing a lock inside Stage 5 prose; it must be routed to the stage that owns it.
  - §33 forbids using a new computation that has not been through Stage 4 validation.
- **Execution was correct.** The rule was applied exactly as locked, and R-A and R-B agree (75/75).

## Options
- **A (RECOMMENDED): keep the locks and finish Stage 5 as is.**
  - The A2 failure and the collapse stand, so the result is no price changes this cycle.
  - The final document discloses the following as the **most important caveat**:
    - the FOODS_3_092 row, as an observed fact from the validated artifact;
    - its 0.1872 contribution, labelled as coordinator arithmetic.
  - It states that the gate outcome is fragile to a single near-zero-denominator item.
  - The design gap goes to Stage 3 as the next analytical question: a minimum-U floor or robust A2, decided **before** any future run.
  - This respects pre-specification: the caps were disclosed before execution, and changing them after seeing the result would be result-driven.
  - The 0.0827 counterfactual is **not** presented as a result. The document says only that the gate outcome depends on one item.
- **B: as A, plus a Stage 4 validation round for the decomposition only.**
  - R-A and R-B would each independently report per-item influence and median signed error, so the caveat is validated rather than coordinator arithmetic.
  - Decision unchanged.
  - Cost: about 1–2 h, a PC round-trip and a Stage 4 change control, which conflicts with the owner's no-PC instruction.
- **C (NOT recommended): change-control A2 (floor or robust form), then rerun Stage 4.**
  - This is a post-hoc rule change after seeing the result, so it reopens Stage 3 and violates lock-preservation intent.
  - The rerun would produce a price list from a rule chosen after the fact.

## Suggested owner wording (new ruling R11; do not reuse any earlier approval)
- **A:** "R11: Option A. Keep the A2 lock and the collapse outcome for PRICEPOINT-001. Disclose the FOODS_3_092 single-item contribution (0.1872 of A2 0.2697) as the most important caveat, labelled coordinator arithmetic on validated per-item rows. Do not present the leave-one-out figure as a result. Route the A2 small-denominator gap to Stage 3 as the next analytical question."
- **B:** "R11: Option B …" (as A, plus "authorize a Stage 4 diagnostic-only validation of A2 per-item influence by R-A and R-B; the decision is unchanged").
- **C:** "R11: Option C …" (names the new A2 rule and authorizes Stage 3 reopening and a Stage 4 rerun).

## Also pending (not HC-1)
AI 3 r2 is **truncated**. It stops inside §9; §10 and the END line are missing. A continuation request is drafted (S5_FIRSTPASS_AI3_CONTINUE.r2.md). AI 3's F-03 error will be corrected in cross-review via addendum E-3/E-6, not by the coordinator editing its text.
