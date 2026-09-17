# PricePoint Dataset Evaluation Context

## Position in the three-dataset evaluation

PricePoint is **Dataset 3 of 3** in the AI-Augmented Analyst methodology evaluation.

The three projects are intentionally different:

| Dataset | Decision level | Primary analytical character |
|---|---|---|
| FulfillIQ 2.0 | Seller | Performance measurement and intervention |
| Chicago 311 | Service request | Large-scale operational prioritization |
| PricePoint | Product / product-store | Pricing, revenue, prediction/scenario analysis |

PricePoint should therefore demonstrate a capability not already established by the first two projects rather than repeat them.

## What is already prepared

The local MySQL source layer exists and has been populated under schema `pricepoint`.

The raw source has deliberately **not** been expanded into a full long-form product-store-day table.

This is intentional. Stage 1–3 should determine the business decision and the smallest source-delivery envelope required to answer it.

## What is not yet locked

The following remain open until the formal workflow runs:

- exact business decision;
- stakeholder-approved framing question;
- decision horizon;
- eligible product/store universe;
- price action set;
- downside guardrail;
- claim-strength ceiling;
- modeling strategy;
- source-delivery scope.

Do not treat earlier exploratory conversation as a substitute for formal Stage 1–3 locks.

## Evaluation objective

The project should test whether the workflow can take a retail dataset that could become computationally large after reshaping and still produce a bounded, validated, auditable business recommendation without allowing data availability to dictate the decision.
