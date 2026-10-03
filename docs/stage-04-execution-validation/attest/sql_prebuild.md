# PRICEPOINT-001 Stage 4 — SQL-path pre-build attestation

**Path:** SQL source delivery + SQL Source Gate (AI 2)
**Attestor:** AI 2
**Design of record:** `08_CONSOLIDATED_CANDIDATE_v5_2` (sha256 `2065773c3224dd6eb083ef6b8f57deb88786ee1742d7da5f66f7fdf825278957`)
**Stage 3 receipt v2:** sha256 `a68575d5aa0ac0c431a1d308fe477eac53c90eefaebcbb880c68ffca783ab9e3`
**ml_mode:** A · **capacity_stance:** hard_attention_budget
**This attestation is frozen before any extract is executed. No results are claimed.**

## (a) Required source fields and mechanical grain
Cite: design §20.1, §20.2, §9.2, §9.4.

Envelope: `store_id = CA_1` × `dept_id ∈ {FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2}` (OC-1 (a)).

SALES_LONG grain item-store-day, 4,821,444 rows: item_id, dept_id, cat_id, store_id, state_id, id, d (int), date, units (int), wm_yr_wk (int, calendar-attached on d).
CALENDAR grain day, 1,969 rows: date, wm_yr_wk (int), weekday, wday (int), month (int), year (int), d (int), event_name_1, event_type_1, event_name_2, event_type_2, snap_CA (int), snap_TX (int), snap_WI (int).
PRICES grain item-store-week, 568,783 rows (558,847 ≤ 11617; 9,936 in 11618–11621): store_id, item_id, wm_yr_wk (int), sell_price DECIMAL(10,2).

Permitted joins: CALENDAR ↔ SALES_LONG on integer d only. No CALENDAR × PRICES. No SALES_LONG × PRICES in a delivered file. Item 20 is a Source Gate cardinality probe (LEFT JOIN on store_id, item_id, wm_yr_wk).

JSON_TABLE FOR ORDINALITY is 1-based = delivered d. JSON index 0 ↔ d = 1; index 1940 ↔ d = 1941.

## (b) Authorized values preserved
Cite: §20.3, §20.5, §21 items 8, 13–16, 22, 24.
Mechanical casts only. TRIM on varchar categoricals; empty events → NULL. Post-origin prices delivered and identifiable by week. No DISTINCT-as-repair (§9.5).

## (c) Prohibited judged logic — each §20.4 item absent
eligibility; TE flags/TE6; n_price_changes_pre; n_distinct_prices_pre; priced_weeks_pre; units_365; zero_days_365; first_priced_wk; first_positive_d; candidates/band/cap/event filter; trailing origin features; item_mean_log1p_units; .pred/glmnet/recipe/folds; actions; ranks/package; flags; distinct-price counts.

## (d) SQL Source Gate can pass and can fail
Cite: §21 items 1–24. Every item is computed from raw MySQL and/or the frozen extract. No hard-coded PASS. No sampling on items 4, 8, 19. Any single mismatch = FAIL and non-zero exit.

## (e) Lineage identity
snapshot_id = SHA-256 of frozen snapshot_record.out
source_version = M5 raw tables in MySQL schema pricepoint (server <VERSION()>), snapshot record sha256 <snapshot_id>
observation_boundary_d = 1941
observation_boundary_date = 2016-05-22
design_id = PRICEPOINT-001-S3-v1
ml_mode = A
fixture_pack_sha256 = da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2
sql_extract_sha256 = SHA-256 of extract_manifest.txt bytes
capacity_stance = hard_attention_budget

Item 18: manifest files = hashed files; sha256(manifest) = freeze sql_extract_sha256; freeze constants = §24.4.

## Framework §6A judged-path items 1–13 — N/A on the SQL path
Cite: §20.4. Eligibility, TE flags, current price, candidates, trailing features, item_mean_log1p_units, Mode A fit/.pred, KPI, guardrail, capacity/rank, Appendix A actions, backtest/TE6, fixtures/recon — the SQL source path does not implement judged logic.

Session: max_execution_time=0; net_read_timeout=3600; net_write_timeout=3600; group_concat_max_len=1048576 (item-19 raw hash only). Justified by ~540 s unindexed JSON_TABLE profile. No SET GLOBAL. No staging objects.
