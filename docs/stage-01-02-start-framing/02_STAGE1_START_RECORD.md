# 02 — Stage 1 Start Record (PRICEPOINT-001)

Controlled combined document. Each framework §20 Start deliverable is a numbered section below. Status: **stakeholder-confirmed (synthetic); awaiting human analyst (owner) approval.** Nothing here is locked until the owner approves and `complete start` returns PASS.

| Field | Value |
|---|---|
| Run | PRICEPOINT-001 |
| Workflow pin | ai-augmented-analyst-workflow `f388be8c2379ac6a8959516b486af31c99423bb0` |
| Project HEAD | pricepoint `f9a4897c9a1468269801a9cf55ba57398d3c412c` (unchanged; no git operations) |
| Stakeholder | Morgan Lee — SYNTHETIC, simulated from `00_morgan_lee_brief_SIMULATOR_ONLY.md` (SHA-256 `74eaef377c179c02b389381e8c8adb5cab6a42a792d814b2131c6ccaef19be83`), which no AI saw |
| AI 1 (Dialogue Lead) | ChatGPT GPT-5.6 Sol, reasoning High (3 of 4; 4 of 4 needs a plan upgrade), one chat: https://chatgpt.com/c/6ab614b5-44a4-83e9-bf78-075f0421b5d8 |
| AI 2 (Reconstructor) | Grok Expert, new chat per round |
| AI 3 (Red team) | DeepSeek DeepThink, web search off, new chat per round |
| Relay | Grok Bot (Framework Coordinator) relayed AI 1's analyst messages unedited and played Morgan from the brief |

## 1. Start decision options (as established with the stakeholder)

Per product at the California pilot store, at each four-week review, Morgan brings the GM one of:
1. a specific pilot shelf-price increase (T002, T034);
2. a specific pilot shelf-price cut (T002, T034);
3. leave the shelf price unchanged (T002);
4. "hold — not enough evidence" (T016).

## 2. Decision ledger

| Element | Established value | Source turns |
|---|---|---|
| Decision owner | Morgan Lee, Pricing & Revenue Manager, recommends; store GM signs off | T002 |
| Action | four options in §1; raise/cut carry a specific pilot price | T002, T016, T034 |
| Outcome | expected product revenue (units × shelf price) over next 28 days at recommended price vs current price | T004, T014, T034 |
| Guardrail | reject changes expected to cut units by more than about 10% | T006 |
| Grain / scope | product at a specific store; one California pilot store; everyday grocery and household aisles | T008 |
| Eligibility principle | several real past price changes; sells steadily enough to show a change; cutoffs delegated with disclosure | T008, T010 |
| Timing | four-week cycle; price holds until next review; 28-day horizon; decision date = end of most recent history; no look-ahead | T012 |
| Information at decision time | daily unit sales, weekly shelf prices, holidays/events, SNAP days; no competitor, inventory, cost | T014 |
| Uncertainty tolerance | fewer, stronger calls; explicit can't-tell outcome | T016 |
| Capacity | ranked list; up to about 25 actual price changes form the GM package; no padding; overflow below the line, not in package; holds outside capacity but listed | T018, T020, T024 |
| Ranking basis | biggest revenue gain the analysis actually trusts; scoring delegated with disclosure | T024 |
| Implementation context | approved changes are piloted; historical patterns are expectations, not guarantees | T026 |

## 3. Ambiguity ledger

| # | Ambiguity | Raised by | Resolution | Where settled |
|---|---|---|---|---|
| A1 | One decision vs per-product review | AI 3 r1 | Per-product recommendation within one pricing decision (one decision class) | T002; reconciled T003 §0 |
| A2 | Leading language in T001 | AI 3 r1 | Accepted; later turns kept to stakeholder wording | T003 §0 |
| A3 | Outcome undefined | AI 1 dialogue | Product revenue, 28 days | T004, T012 |
| A4 | Downside guardrail | AI 1 dialogue | ~10% unit decline | T006 |
| A5 | Scope and eligibility | AI 1 dialogue | CA pilot store, grocery/household; principles, cutoffs delegated | T008, T010 |
| A6 | Capacity | AI 1 dialogue | ~25 price changes per cycle | T018 |
| A7 | Does cap include holds | AI 1 | No; holds listed, outside cap | T020 |
| A8 | Hard cap vs ranked list; 26+ treatment; meaning of "strongest" | AI 2/3 r2 | Ranked list; overflow below line; strongest = biggest trusted revenue gain | T024 |
| A9 | Other rejection conditions / causal claims | AI 1 | None beyond stated; pilot, expectation not guarantee | T026 |
| A10 | Authority wording; unchanged vs can't-tell; pilot/SNAP omissions | AI 2/3 r3 | Statement revised | T029 |
| A11 | Cadence, no-padding, holds, below-line wording | AI 2/3 verification | Statement revised | T031, T035 |
| A12 | Price magnitude: specific price vs direction | AI 3 verification (AI 1 and AI 2 would have deferred it) | Coordinator put the one question to Morgan: specific pilot price required; method delegated | T033–T034 |

Deferred to Framing / Stage 3 (delegated by the stakeholder, to be disclosed): candidate-price construction; ranking/scoring formula; eligibility cutoffs; evidence-sufficiency ("solid") threshold; department mapping within grocery/household; reporting label for guardrail-rejected candidates; exact treatment of "about 10%" and "about 25".

## 4. Independent Start reviews (frozen before AI 1 saw them)

| Round | AI 2 (Grok) | AI 3 (DeepSeek) | Hash file |
|---|---|---|---|
| r1 (T000–T002) | Cannot yet frame | Cannot yet frame | reviews/SHA256SUMS_r1.txt |
| r2 (through T021 draft) | Revise | Revise | reviews/SHA256SUMS_r2.txt |
| r3 (through T027 draft) | Pass | Revise | reviews/SHA256SUMS_r3.txt |
| verify T029 | Pass | Revise | SHA256SUMS_r3.txt |
| verify T031 | Pass | Revise (magnitude) | SHA256SUMS_r3.txt |
| verify T035 (final) | **Pass** | **Pass** | SHA256SUMS_r3.txt |

Chats: AI 2 r1 https://grok.com/c/8dd288d4-7fec-48da-b3d8-258f909e56f0, r2 https://grok.com/c/51f808cb-7206-4501-956c-a48de2fa90a4, r3+verifications https://grok.com/c/169f7dc6-3382-4771-97b9-60a74beaedff. AI 3 r1 https://chat.deepseek.com/a/chat/s/443be5f9-2cfa-48bb-b16c-e379844fed46, r2 https://chat.deepseek.com/a/chat/s/dec6fcfe-2f85-4b45-8631-ba3a41d0f8bc, r3+verifications https://chat.deepseek.com/a/chat/s/0c68c233-f9ed-41a3-a4ad-a455c1d20cb1.

## 5. Decision statement (stakeholder-confirmed T036, synthetic; owner approval pending)

SHA-256 of `decision_statement_T035.txt`: `b30ae5be454112ed1f36e7e892a0a16d86ffeef9ec1f77e08daee2c6e0412929`

> Morgan Lee, Pricing & Revenue Manager, must determine what recommendation to bring to the store general manager for products meeting the review criteria at the California pilot store’s everyday grocery and household aisles: a specific pilot shelf price increase, a specific pilot shelf price cut, leaving the shelf price unchanged, or classifying the product as “hold — not enough evidence” when the available evidence is not solid. The recommendation should identify the specific pilot price expected to produce the strongest trusted product revenue result (units sold × shelf price) over the next 28 days compared with the current price, while rejecting changes expected to reduce units by more than about 10%. The review occurs on a four-week cycle, with the price decision holding until the next review. The recommendation uses only information available at the end of the most recent history period: daily unit sales, weekly shelf prices, and calendar information including holidays, events, and SNAP benefit days. The output is a ranked list: the strongest trusted price-change opportunities, based on the biggest revenue gain that is trusted, form the GM package up to about 25 actual price changes. If fewer qualify, the list is not padded. If more qualify, additional qualifying opportunities remain below the line as next in line and are not included in that cycle’s package. Holds and hold — not enough evidence outcomes remain visible and do not consume the price-change capacity. Approved changes are pilots, and historical patterns should be presented as expectations to test rather than guarantees.

## 6. Revision trail

| Draft | Shown to Morgan? | Why superseded |
|---|---|---|
| T017 | Yes | Morgan corrected: capacity missing (T018) |
| T021 | No (held) | r2 reviews: capacity interpretation, ranking key, 26+ treatment |
| T027 | No (held) | r3: authority, unchanged vs can't-tell, pilot, SNAP |
| T029 | No (held) | verification: cadence, no-padding, holds, below-line, magnitude |
| T031 | No (held) | AI 3: magnitude Start-level; coordinator asked Morgan (T033–T034) |
| **T035** | **Yes; confirmed T036** | Final |

Turn numbers skipped (T022, T028, T030, T032) correspond to held drafts with no stakeholder reply; each is recorded in the dialogue ledger.

## 7. Warrant Ledger entries proposed at Stage 1 (to be written into `docs/warrant-ledger.md` on owner approval)

| ID | Rule / assumption | Stage | Basis | Evidence / rationale | Sensitivity? | Status |
|---|---|---:|---|---|---|---|
| W-001 | Decision horizon = 28 days after the review date; four-week cycle | 1 | Stakeholder (synthetic) | T012 | No | Stakeholder-locked portfolio requirement |
| W-002 | Revenue definition = units sold × shelf price (no margin) | 1 | Stakeholder | T004; no cost data | No | Stakeholder-locked portfolio requirement |
| W-003 | Unit downside guardrail ≈10% expected unit decline | 1 | Stakeholder candidate guardrail | T006; "about" to be fixed at Stage 3 | Yes | Stakeholder-locked portfolio requirement (exact value Open) |
| W-004 | Eligibility principle: real past price changes + steady sales; cutoffs delegated | 1 | Stakeholder principle; analyst cutoffs | T008, T010 | Yes | Unresolved / Open (Stage 3) |
| W-005 | Hold — not enough evidence (abstention) outcome required | 1 | Stakeholder | T016; threshold delegated | Yes | Stakeholder-locked (threshold Open) |
| W-006 | Capacity ≈25 actual price changes, ranked by biggest trusted revenue gain, no padding, overflow below line | 1 | Stakeholder | T018, T020, T024 | Yes | Stakeholder-locked (ranking formula Open) |
| W-007 | Causal-language restriction: expectations to pilot, not guarantees | 1 | Stakeholder | T026 | No | Stakeholder-locked portfolio requirement |
| W-008 | Raise/cut recommendations carry a specific pilot price; construction delegated | 1 | Stakeholder | T034 | Yes | Stakeholder-locked (method Open) |

All Stage 1 bases are a SYNTHETIC stakeholder; none is real business validation.

## 8. Disclosures for the owner
- Morgan Lee is simulated by Grok Bot from a fixed brief written before the dialogue; the brief is included and no AI saw it. Morgan's T034 answer (specific pilot price) was written to stay consistent with the brief without naming a method.
- The coordinator made one steering decision (A12): after two reconciliation passes left AI 1/AI 2 and AI 3 disagreeing on magnitude, it instructed AI 1 to ask Morgan the single question rather than settle it by vote.
- AI 1 ran at High 3 of 4 (maximum on the Plus plan).
- Review rounds r3 onward reused the same reviewer chats for verification follow-ups; each first pass was a new chat.
