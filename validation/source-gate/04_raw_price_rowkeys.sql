-- PRICEPOINT-001 / validation/source-gate/04_raw_price_rowkeys.sql
-- §21 item 8 repair r1 (AI2-XR-01 / AI1 / AI3). SELECT-only. One result set.
-- Keyed raw PRICES rows for the OC-1 (a) envelope. No staging objects.
-- Canonical value = integer cents of TRIM(sell_price) cast DECIMAL(10,2).
-- Not prices_crc32_sum. Compared row-by-row to prices.tsv in run_source_gate.R.
-- group_concat_max_len is not used.

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  TRIM(p.store_id)                                              AS store_id,
  TRIM(p.item_id)                                               AS item_id,
  CAST(TRIM(p.wm_yr_wk) AS UNSIGNED)                            AS wm_yr_wk,
  CAST(ROUND(CAST(TRIM(p.sell_price) AS DECIMAL(10, 2)) * 100) AS SIGNED) AS sell_price_cents
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
