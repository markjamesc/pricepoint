-- PRICEPOINT-001 / sql/source-delivery/snapshot_record.sql
-- Read-only source snapshot. mysql --batch concatenates result sets.
-- snapshot_id := sha256(frozen stdout file)
-- source_version := "M5 raw tables in MySQL schema pricepoint (server <VERSION()>), snapshot record sha256 <snapshot_id>"
-- Adequate: VERSION + exact COUNTs + JSON_LENGTH bounds + envelope size + CHECKSUM TABLE
-- of the three raw tables on this server at freeze time. DB is used read-only.

SET SESSION max_execution_time = 0;

SELECT
  VERSION()                         AS server_version,
  @@hostname                        AS hostname,
  DATABASE()                        AS db_name,
  @@character_set_database          AS db_charset,
  @@collation_database              AS db_collation,
  NOW()                             AS snapshot_ts;

SELECT
  t.TABLE_NAME                      AS table_name,
  t.TABLE_ROWS                      AS engine_table_rows,
  t.ENGINE                          AS engine,
  t.TABLE_COLLATION                 AS table_collation,
  t.CREATE_TIME                     AS create_time,
  t.UPDATE_TIME                     AS update_time
FROM information_schema.TABLES AS t
WHERE t.TABLE_SCHEMA = DATABASE()
  AND t.TABLE_NAME IN ('raw_calendar', 'raw_sales_evaluation', 'raw_sell_prices')
ORDER BY t.TABLE_NAME;

SELECT 'raw_calendar' AS table_name, COUNT(*) AS n FROM raw_calendar
UNION ALL
SELECT 'raw_sales_evaluation', COUNT(*) FROM raw_sales_evaluation
UNION ALL
SELECT 'raw_sell_prices', COUNT(*) FROM raw_sell_prices;

SELECT
  MIN(JSON_LENGTH(sales_history))   AS min_json_length,
  MAX(JSON_LENGTH(sales_history))   AS max_json_length,
  SUM(JSON_LENGTH(sales_history) <> 1941) AS n_jsonlen_ne_1941,
  COUNT(*)                          AS n_series,
  COUNT(DISTINCT id)                AS n_distinct_id,
  COUNT(DISTINCT CONCAT(store_id, '|', item_id)) AS n_distinct_store_item
FROM raw_sales_evaluation;

SELECT
  COUNT(*)                          AS n_ca1_five_dept_series
FROM raw_sales_evaluation
WHERE TRIM(store_id) = 'CA_1'
  AND TRIM(dept_id) IN (
        'FOODS_1', 'FOODS_2', 'FOODS_3',
        'HOUSEHOLD_1', 'HOUSEHOLD_2'
      );

SELECT
  TRIM(dept_id)                     AS dept_id,
  COUNT(*)                          AS n_series
FROM raw_sales_evaluation
WHERE TRIM(store_id) = 'CA_1'
  AND TRIM(dept_id) IN (
        'FOODS_1', 'FOODS_2', 'FOODS_3',
        'HOUSEHOLD_1', 'HOUSEHOLD_2'
      )
GROUP BY TRIM(dept_id)
ORDER BY dept_id;

CHECKSUM TABLE raw_calendar, raw_sales_evaluation, raw_sell_prices;
