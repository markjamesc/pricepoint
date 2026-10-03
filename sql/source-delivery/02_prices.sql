-- PRICEPOINT-001 / sql/source-delivery/02_prices.sql
-- Mechanical PRICES extract for the OC-1 (a) envelope. SELECT-only. One result set.
-- Locked cardinality: 568,783 rows; 558,847 at wm_yr_wk ≤ 11617; 9,936 at 11618–11621.
-- Deliver-and-quarantine: weeks ≥ 11618 are INCLUDED (§20.5). No judged filter.

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  TRIM(p.store_id)                            AS store_id,
  TRIM(p.item_id)                             AS item_id,
  CAST(TRIM(p.wm_yr_wk) AS UNSIGNED)          AS wm_yr_wk,
  CAST(TRIM(p.sell_price) AS DECIMAL(10, 2))  AS sell_price
FROM raw_sell_prices AS p
WHERE TRIM(p.store_id) = 'CA_1'
  AND TRIM(p.item_id) IN (
        SELECT TRIM(s.item_id)
        FROM raw_sales_evaluation AS s
        WHERE TRIM(s.store_id) = 'CA_1'
          AND TRIM(s.dept_id) IN (
                'FOODS_1', 'FOODS_2', 'FOODS_3',
                'HOUSEHOLD_1', 'HOUSEHOLD_2'
              )
      )
ORDER BY item_id, wm_yr_wk;
