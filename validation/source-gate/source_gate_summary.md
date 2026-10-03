# PRICEPOINT-001 SQL Source Gate summary

- items scored: 24 (PASS 24 / FAIL 0)
- verdict: **PASS**

Any single FAIL = Gate Fail (design §21).

| item_no | item | locked_value | observed_value | result | method |
|---|---|---|---|---|---|
| 1 | SALES_LONG row count = 4,821,444 | 4821444 | 4821444 | PASS | nrow(sales_long.tsv) |
| 2 | SALES_LONG item count = 2,484 | 2484 | 2484 | PASS | uniqueN(item_id) |
| 3 | Each SALES_LONG item has d 1..1941 | 0 incomplete items | 0 | PASS | per-item n==1941 & min(d)==1 & max(d)==1941 & uniqueN(d)==1941 |
| 4 | Per-item unit sums equal JSON sums for all 2,484 items | 0 mismatches; 2484 items compared | compared=2484 sum_mismatch=0 | PASS | SUM(JSON_TABLE units) vs SUM(sales_long.units) by item_id; all items |
| 5 | PRICES row count = 568,783 | 568783 | 568783 | PASS | nrow(prices.tsv) |
| 6 | PRICES rows at weeks <= 11617 = 558,847 | 558847 | 558847 | PASS | wm_yr_wk<=11617 |
| 7 | PRICES rows in weeks 11618-11621 = 9,936 | 9936 | 9936 | PASS | deliver-and-quarantine count |
| 8 | PRICES values equal raw values for every row | 0 key-only rows; 0 value mismatches; keys equal | ext=568783 raw=568783 only_ext=0 only_raw=0 value_mismatch=0 dup_ext=0 dup_raw=0 na_cents=0 | PASS | keyed (store_id, item_id, wm_yr_wk, integer cents) prices.tsv vs raw_price_rowkeys.tsv; prices_crc32_sum unused |
| 9 | Calendar row count = 1,969 | 1969 | 1969 | PASS | nrow(calendar.tsv) |
| 10 | Calendar week count = 282 | 282 | 282 | PASS | uniqueN(wm_yr_wk) |
| 11 | Week 11621 = 2 days | 2 | 2 | PASS | wm_yr_wk==11621 |
| 12 | wday(2016-05-21) = 1 | 1 | 1 | PASS | calendar.tsv date==2016-05-21 |
| 13 | units integer >= 0 | 0 violating rows | 0 | PASS | units numeric; reject negative or non-integer |
| 14 | sell_price > 0 | 0 rows with sell_price<=0 | 0 | PASS | sell_price numeric > 0 |
| 15 | wday in 1..7 | 0 out-of-domain rows | 0 | PASS | wday domain |
| 16 | snap_CA in {0,1} | 0 out-of-domain rows | 0 | PASS | snap_CA domain |
| 17 | Recorded department list = five approved departments | FOODS_1,FOODS_2,FOODS_3,HOUSEHOLD_1,HOUSEHOLD_2 | FOODS_1,FOODS_2,FOODS_3,HOUSEHOLD_1,HOUSEHOLD_2 | PASS | sort(unique(dept_id)) vs OC-1 (a) |
| 18 | Lineage equality | manifest files=hashed files; manifest hash=sql_extract_sha256; freeze constants match §24.4 | calendar.tsv:131669:a2807afd5a1dbd35523c9161128bef31a54332f21cf77889fc168a9fa0086858 / prices.tsv:17472933:0cbd6c8b0ee4b6ea0b52b58094c94e27a2d9b5c31c0d08d3d0e7661a6eb3ce73 / sales_long.tsv:449366357:536eb633a3a27a734e9883001213491ae3ae63b8872d824161e13b16aa5ee8ae / observation_boundary_d=1941 / observation_boundary_date=2016-05-22 / design_id=PRICEPOINT-001-S3-v1 / ml_mode=A / fixture_pack_sha256=da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2 / capacity_stance=hard_attention_budget / snapshot_id=121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38 / source_version=M5 raw tables in MySQL schema pricepoint (server 8.0.46), snapshot record sha256 121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38 | PASS | sha256(extract files)==manifest rows; sha256(manifest)==freeze.sql_extract_sha256; freeze §24.4 constants |
| 19 | Position mapping full check + spot 0→d_1 and 1940→d_1941=2016-05-22 | 0 hash mismatches; spot units equal; d_1941 date=2016-05-22 | hash_mismatch=0 spot1=0 spot1941=0 date_ok=TRUE | PASS | per-item SHA-256 of pos=<d>;u=<units>\n vs raw JSON_TABLE ordinality |
| 20 | <=1 price row per item-day after mechanical attachment; 4,821,444 rows | 4821444 rows; max prices per item-day <=1 | extract_join_rows=4821444 extract_max=1 raw_join_rows=4821444 raw_max=1 | PASS | LEFT JOIN sales_long.tsv to prices.tsv + raw attach query |
| 21 | Extract manifest exists with §20.5 layout; sql_extract_sha256 equals SHA-256(manifest) | 13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68 | manifest_sha256=13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68 layout_ok=TRUE file_match=TRUE | PASS | parse extract_manifest.txt; hash files the gate read; sha256(manifest)==freeze.sql_extract_sha256 |
| 22 | TRIM applied; blank events → NULL; wday/snap domains | 0 untrimmed varchar categoricals; 0 blank event strings; domains hold | untrimmed_cal=0 untrimmed_prices=0 untrimmed_sales=0 blank_events=0 wday_bad=0 snap_bad=0 | PASS | x==trimws(x) on delivered varchar categoricals; blank events; items 15/16 |
| 23 | Delivered key uniqueness SALES_LONG and PRICES | 0 duplicate keys on either table | sales_dups=0 prices_dups=0 | PASS | unique (store_id,item_id,d) and (store_id,item_id,wm_yr_wk) |
| 24 | No NULL units in SALES_LONG and no NULL sell_price in PRICES | 0 NULL units and 0 NULL sell_price | null_units=0 null_price=0 | PASS | is.na(units)+is.na(sell_price) |
