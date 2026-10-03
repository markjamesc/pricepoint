# PRICEPOINT-001 Stage 4 — SQL source delivery + Source Gate run sheet

Coordinator executes on DESKTOP-RPECRM9 from cmd.exe.
Client: "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
Flags: --login-path=chicago311 --database=pricepoint --batch --default-character-set=utf8mb4
--batch = UTF-8 TSV, one header, LF, NULL as the literal NULL. Do not add --raw or --skip-column-names.

%EX% = extract root (outside git). %SRC% = repo root. %MYSQL% = mysql.exe path.

Session variables (justified in the attestation): max_execution_time=0, net_read_timeout=3600,
net_write_timeout=3600, group_concat_max_len=1048576 (item-19 raw hash only).
No SET GLOBAL. No staging objects.

## A. Snapshot
%MYSQL% ... < %SRC%\sql\source-delivery\snapshot_record.sql > %EX%\snapshot_record.out

snapshot_id = SHA-256 of snapshot_record.out bytes.
source_version = M5 raw tables in MySQL schema pricepoint (server <VERSION()>), snapshot record sha256 <snapshot_id>

Convention is adequate: VERSION + exact COUNTs + JSON_LENGTH bounds + envelope 2,484 + CHECKSUM TABLE
of the three raw tables at freeze time on a read-only use of the instance.

## B. Extract (once, then freeze) — this order
01_calendar.sql    -> %EX%\calendar.tsv      expected data rows 1,969
02_prices.sql      -> %EX%\prices.tsv        expected data rows 568,783 (includes 9,936 weeks 11618–11621)
03_sales_long.sql  -> %EX%\sales_long.tsv    expected data rows 4,821,444 (~10 min)

If a query errors, stop and send AI 2 the exact stderr. Do not repair SQL locally.

## C. Manifest + freeze record (coordinator, mechanical)
Write %EX%\extract_manifest.txt, three lines, lexicographic path, §20.5 layout, final LF:

calendar.tsv | <byte_length> | <sha256>
prices.tsv | <byte_length> | <sha256>
sales_long.tsv | <byte_length> | <sha256>

sql_extract_sha256 = SHA-256 of that file's bytes.

Write %EX%\extract_freeze_record.txt as key=value:
snapshot_id, source_version, observation_boundary_d=1941,
observation_boundary_date=2016-05-22, design_id=PRICEPOINT-001-S3-v1,
ml_mode=A, fixture_pack_sha256=da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2,
sql_extract_sha256=<hex>, capacity_stance=hard_attention_budget

## D. Raw-side gate queries (not delivered to R-A/R-B)
01_raw_gate_aggregates.sql          -> raw_gate_aggregates.tsv           1 row
02_raw_item_json.sql                -> raw_item_json.tsv                 2,484 rows
03_raw_price_attach_cardinality.sql -> raw_price_attach_cardinality.tsv  1 row (heavy; do not kill under 30 min)

## E. File-side checker
Rscript %SRC%\validation\source-gate\run_source_gate.R --extract-dir %EX% --raw-dir %EX%\raw_gate --out-dir %SRC%\validation\source-gate --manifest %EX%\extract_manifest.txt --freeze-record %EX%\extract_freeze_record.txt

Writes source_gate_report.csv and source_gate_summary.md.
Exit 0 = PASS (24 items, zero FAIL). Exit 1 = Gate Fail.
R never connects to MySQL.

## F. Item ownership
Items 1–3, 13, 17: file checker on sales_long.tsv
Items 4, 19: raw_item_json.tsv (all 2,484) vs sales_long hashes/sums + d_1941 date spot
Items 5–8, 14: file checker on prices.tsv vs raw aggregates (item 8 = n + SUM(sell_price))
Items 9–12, 15–16, 22: file checker on calendar.tsv (and raw aggregates)
Item 20: extract LEFT JOIN + raw attach-cardinality query
Items 18, 21: manifest + freeze record (see G)
Items 23, 24: uniqueness and NULL checks on both delivered tables

## G. Item 18 and item 21 — exact comparison
Item 21: extract_manifest.txt exists; §20.5 byte layout; each listed file's size and sha256 equal the file the gate hashed at %EX%\<path>; sha256(manifest bytes) equals freeze.sql_extract_sha256.

Item 18: (1) the three extract files listed in the manifest are the files the gate hashed;
(2) sha256(manifest) = freeze.sql_extract_sha256;
(3) freeze constants equal §24.4 (boundary 1941 / 2016-05-22, design_id PRICEPOINT-001-S3-v1, ml_mode A, fixture_pack_sha256 da25c258…95d2, capacity_stance hard_attention_budget);
(4) snapshot_id and source_version are present and non-empty.

## H. After Gate PASS, R-A and R-B receive only
calendar.tsv, prices.tsv, sales_long.tsv, extract_manifest.txt, extract_freeze_record.txt
identified by sql_extract_sha256. Not the raw-side gate TSVs, not snapshot stdout, not MySQL.
