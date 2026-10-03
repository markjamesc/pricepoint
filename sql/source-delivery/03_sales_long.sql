-- PRICEPOINT-001 / sql/source-delivery/03_sales_long.sql
-- Mechanical SALES_LONG extract: envelope + JSON unnest + calendar attach on d.
-- SELECT-only. One result set.
-- Locked cardinality: 2,484 × 1,941 = 4,821,444 rows (§20.1, §21 item 1).
-- JSON_TABLE FOR ORDINALITY is 1-based = delivered d (§21 items 3, 19):
--   JSON index 0 ↔ d = 1 ; JSON index 1940 ↔ d = 1941.
-- No price join in this delivery (§20.1 field list; §9.4).

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  TRIM(s.item_id)                                   AS item_id,
  TRIM(s.dept_id)                                   AS dept_id,
  TRIM(s.cat_id)                                    AS cat_id,
  TRIM(s.store_id)                                  AS store_id,
  TRIM(s.state_id)                                  AS state_id,
  TRIM(s.id)                                        AS id,
  jt.pos                                            AS d,
  cal.`date`                                        AS `date`,
  jt.u                                              AS units,
  cal.wm_yr_wk                                      AS wm_yr_wk
FROM raw_sales_evaluation AS s
INNER JOIN JSON_TABLE(
             s.sales_history,
             '$[*]' COLUMNS (
               pos FOR ORDINALITY,
               u INT PATH '$' ERROR ON ERROR
             )
           ) AS jt
INNER JOIN (
  SELECT
    CAST(SUBSTRING(TRIM(c.d), 3) AS UNSIGNED) AS d,
    CAST(TRIM(c.`date`) AS DATE)              AS `date`,
    CAST(TRIM(c.wm_yr_wk) AS UNSIGNED)        AS wm_yr_wk
  FROM raw_calendar AS c
) AS cal
  ON cal.d = jt.pos
WHERE TRIM(s.store_id) = 'CA_1'
  AND TRIM(s.dept_id) IN (
        'FOODS_1', 'FOODS_2', 'FOODS_3',
        'HOUSEHOLD_1', 'HOUSEHOLD_2'
      )
ORDER BY item_id, d;
