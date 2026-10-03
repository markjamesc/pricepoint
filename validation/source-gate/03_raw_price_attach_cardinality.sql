-- PRICEPOINT-001 / validation/source-gate/03_raw_price_attach_cardinality.sql
-- §21 item 20: after mechanical LEFT JOIN of envelope prices onto unnested
-- sales+calendar on (store_id, item_id, wm_yr_wk), row count remains 4,821,444
-- and max prices per item-day is ≤ 1.
-- SELECT-only. One result set. Heavy: unindexed JSON_TABLE + join.

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  COUNT(*)                         AS n_rows_after_attach,
  MAX(z.n_prices)                  AS max_prices_per_itemday,
  SUM(z.n_prices > 1)              AS n_itemdays_with_gt1_price,
  SUM(z.n_prices = 0)              AS n_itemdays_with_0_price
FROM (
  SELECT
    TRIM(s.store_id) AS store_id,
    TRIM(s.item_id)  AS item_id,
    jt.pos           AS d,
    COUNT(p.item_id) AS n_prices
  FROM raw_sales_evaluation AS s
  INNER JOIN JSON_TABLE(
               s.sales_history,
               '$[*]' COLUMNS (
                 pos FOR ORDINALITY,
                 u INT PATH '$' ERROR ON ERROR
               )
             ) AS jt
  INNER JOIN raw_calendar AS c
    ON CAST(SUBSTRING(TRIM(c.d), 3) AS UNSIGNED) = jt.pos
  LEFT JOIN raw_sell_prices AS p
    ON TRIM(p.store_id) = TRIM(s.store_id)
   AND TRIM(p.item_id)  = TRIM(s.item_id)
   AND CAST(TRIM(p.wm_yr_wk) AS UNSIGNED) = CAST(TRIM(c.wm_yr_wk) AS UNSIGNED)
  WHERE TRIM(s.store_id) = 'CA_1'
    AND TRIM(s.dept_id) IN (
          'FOODS_1', 'FOODS_2', 'FOODS_3',
          'HOUSEHOLD_1', 'HOUSEHOLD_2'
        )
  GROUP BY TRIM(s.store_id), TRIM(s.item_id), jt.pos
) AS z;
