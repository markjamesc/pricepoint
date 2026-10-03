# 07_DECISION_OPTION_MATRIX — PRICEPOINT-001 Stage 5 (draft v1, post-cross-review)
Source: AI 1 C-13..C-20, revised per XR5_AI2 #7 and #10 and XR5_AI1 #3. All approved options are evaluated (Gate 8).

| Option | Evidence required | Evidence observed | Benefit / downside / reversibility | Capacity / guardrail | Verdict |
|---|---|---|---|---|---|
| Pilot raise | Backtest accepted; trusted; legal; ρ̂ ≥ 0.90; ranked ≤ 25 | Backtest failed; n_raise 0 | Possible gain is unverifiable; acting would bypass §17.R8 | 0 slots | **Reject this cycle** |
| Pilot cut | Same as raise | n_cut 0 | Same as raise | 0 slots | **Reject this cycle** |
| Unchanged (model-based) | Trusted model and no legal candidate | Collapsed to hold_ne (§17.R8) | Shelf prices stay where they are operationally, but the label "unchanged" is not earned | — | **Not available as a label** |
| hold — not enough evidence | Locked trust failure | All 2,484 | Keeps the evidence threshold; may forgo real opportunities | 0/25 used; holds do not consume slots | **No price action; assign hold_ne to all 2,484** (the label "Act" was removed, XR5_AI2 #7) |
| Pilot from diagnostic candidates (override) | A rule change | R-10 is not decision-valid | Reversible operationally, but a rule breach | Would consume slots without qualification | **Reject.** Needs Stage 3 change control, not available |
| Monitor | A defined future readout | Locked A1/A2 at the next governed run | Low cost | None | **Adopt** (see 12_) |
| Collect more evidence | A targeted question | R11 routes the A2 small-denominator gap to Stage 3; A3/T6 and A2 breakdown are secondary | Addresses why the gate failed | None | **Adopt as next question; it does not change this cycle** |
| No price action | Rules produce no valid change | Package 0 | Fully reversible; nothing exposed | Fits | **Adopt (the recommendation)** |
