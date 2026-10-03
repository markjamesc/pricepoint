# Validated-data manifest — PRICEPOINT-001 Stage 4 (DRAFT — freeze NOT final)

Status: DRAFT, compiled 2026-10-02 13:26 CT. **It is not final until step 11 structural cross-review closes.** The register in §9 is still pending. Once step 11 PASSes, this file gets renamed to validated_data_manifest.md and its hash is re-recorded.
Labels: **SIMULATION / NON-LIVE**. The data is the historical M5 CA_1 extract. No price change has been applied or released anywhere. A Validation Gate PASS unlocks Stage 5 interpretation only.

## 1. Dataset
| Item | Value |
|---|---|
| Validated dataset | R-A r2 judged outputs, reconciled 75/75 against the independent R-B r10 outputs |
| universe.csv | rows 2,484; key item_id (unique 2,484); sha256 e1d7545ea99aef2f4d2eb6815c4cdfd426d6cf2c7c8295ba09c764227c34f4d7 |
| candidates.csv | rows 3,654; key (item_id, candidate_price) (unique 3,654); sha256 772450cda9d3c84d91823b8e166db6fc7b2bee29e8408b78595d0da7de70255a |
| audit.csv | rows 1; sha256 e76ab0128bf196014bf2db4a84801c7d87747c77c6a5a0f3c617ecc8b586b6a8 |
| model_validation.json | sha256 ce09ea11afc075912c44a11ea8452edbc42ac770926a39677d80192076b5308b |
| lineage.json (path) | sha256 3f93679cadda13489ca01b29d85727403c546e229686c2040d98d12d694ec218 (R-B identical) |
| Peer (R-B r10) | universe 521660b215c243bd216bfa0204f61f6be5503b882a0d0f7c2b2ee10b8d107b0a; candidates 962ba3497e01cb42657d912de83d81c2caa260d3876a78382877d208859e3d4f; audit 4eac3998e4492c147c072d43394cd1106ffd83a2b1ae6be7537f4a493f2b22ad |
| Run bundles | R-A r2 925bc3636b2210b81cb33de66969e2f384021a520c7df0daea210f2ad25e44b9; R-B r10 6b6e38fd671964251995e0f4bb2c2a12506a4bb22ce6af69eaaa78df8bb155ea |
| Dataset hash | sha256 over the "universe,candidates,audit" sha list (R-A r2): 8b03a77d813342c89478768950a8a3fab75c135d01be0dd3111cceaf4fb88d7a |

## 2. Key profile
universe by dept: FOODS_1 216, FOODS_2 398, FOODS_3 823, HOUSEHOLD_1 532, HOUSEHOLD_2 515 (total 2,484). No duplicate keys in either path. Keys match across paths: 2,484 / 3,654 / 1.
Outcome profile: 2,484/2,484 hold_ne; package 0; below-line 0; legal changes 0; trust-eligible 338; n_floored_days_total 5,562; TE6 usable slice 347.

## 3. Source
snapshot / source_version / extract identity: see lineage.json. The extract manifest is 13d037ef…, sales_long 536eb633…, prices 0cbd6c8b…, calendar a2807afd…, snapshot 121341c1…. Source Gate is PASS 24/24 (report 72291842…). The receipt source.json e35eae99c6b259da9fec39a494065827e132322e1cdf3131e9e7c5f9e55f7e8c was reissued under design v5.4.
Caveat carried to cross-review: Source Gate item 8 is implemented as an envelope count plus SUM(sell_price) equality, not a row-wise comparison.

## 4. Design and change control
Design is 08_CONSOLIDATED_CANDIDATE_v5_4 (sha256 3cfc71eb5e10c5f680e1768400d03daf05513a23199740ac9f80f8adff2b80ef). The Stage 3 receipt v4 is 1ee9f4da9cffe3a906182d209c573b61c7451387cfc338009261c79f8620dd16.
Change-control chain: CC-S3-01 (2781→a685) → CC-S4-01 (a685→4fb3; thresh 1e-12; owner 11:43 CT) → CC-S4-02 (4fb3→1ee9; cent_delta_rev sign-exact + $0.05; owner R9 13:21 CT). Each step was applied via pp_gate.R amend design → AMENDED.

## 5. Code versions
SQL, Source Gate, R-A r2, R-B r10 and comparator v4 are listed per file in evidence/lineage.json script_versions. The comparator is reconcile_75.py v4 f7651ca1…; the fields list is 7fc18a65….

## 6. Fixtures
fixture_pack_v1. The pack file is 1390575a…; the lineage-rule hash is da25c258…. R-A r2 passed 26/26 (8e94123bbe32d795c3a52eecf09410845956622d961dffe5e5e0073f71d1876d) and R-B r10 passed 26/26 (f8b62d66364a3186d61c6b123145714bff976fe62b6ee1f19545e9f19f511915).

## 7. Reconciliation
PASS 75/75, mismatch_count 0 (reconciliation.csv 5535102a…). Failed reports are preserved (see reconciliation.json history).

## 8. Model validation (Mode A)
d_1913: A1 0.1824, A2 0.2697, so backtest_accept = 0 and the locked collapse rule was applied. d_1885: A1 0.1722, A2 0.1794 (reported only). Penalty 0.0021 (idx 14). Both paths are identical.

## 9. Cross-review register
**PENDING — step 11 not yet run.** Packets are drafted in run/packets/step11/.

## 10. Never-copy attestations
- Neither path received the other's code, outputs, item IDs, actions or lists. The R-A r2 and R-B r10 requests were scanned blind before sending.
- No table was hand-edited.
- No builder code was hand-fixed by the coordinator. Every code change came from the owning builder's reply and is frozen with its hashes.
- R never connected to MySQL. MySQL was used read-only, with no staging objects.
- Nothing was deleted. All failed runs and reports are preserved.
