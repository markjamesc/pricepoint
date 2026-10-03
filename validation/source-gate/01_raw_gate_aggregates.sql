-- PRICEPOINT-001 / validation/source-gate/01_raw_gate_aggregates.sql
-- Raw-side numeric facts for §21. SELECT-only. One result set (one row).
-- Repair r1: prices_crc32_sum is retained and is not the item-8 check.

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  (SELECT COUNT(*)
     FROM raw_sales_evaluation
    WHERE TRIM(store_id) = 'CA_1'
      AND TRIM(dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
  ) AS n_envelope_items,

  (SELECT GROUP_CONCAT(dpt ORDER BY dpt SEPARATOR ',')
     FROM (
       SELECT DISTINCT TRIM(dept_id) AS dpt
       FROM raw_sales_evaluation
       WHERE TRIM(store_id) = 'CA_1'
         AND TRIM(dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
     ) z
  ) AS dept_list,

  (SELECT MIN(JSON_LENGTH(sales_history))
     FROM raw_sales_evaluation
    WHERE TRIM(store_id) = 'CA_1'
      AND TRIM(dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
  ) AS min_json_len_envelope,

  (SELECT MAX(JSON_LENGTH(sales_history))
     FROM raw_sales_evaluation
    WHERE TRIM(store_id) = 'CA_1'
      AND TRIM(dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
  ) AS max_json_len_envelope,

  (SELECT COUNT(*) FROM raw_calendar) AS n_calendar_rows,
  (SELECT COUNT(DISTINCT CAST(TRIM(wm_yr_wk) AS UNSIGNED)) FROM raw_calendar) AS n_calendar_weeks,
  (SELECT COUNT(*) FROM raw_calendar
    WHERE CAST(TRIM(wm_yr_wk) AS UNSIGNED) = 11621) AS n_days_week_11621,
  (SELECT CAST(TRIM(wday) AS UNSIGNED) FROM raw_calendar
    WHERE CAST(TRIM(`date`) AS DATE) = '2016-05-21') AS wday_2016_05_21,
  (SELECT CAST(TRIM(`date`) AS DATE) FROM raw_calendar
    WHERE CAST(SUBSTRING(TRIM(d), 3) AS UNSIGNED) = 1941) AS date_d_1941,
  (SELECT CAST(SUBSTRING(TRIM(d), 3) AS UNSIGNED) FROM raw_calendar
    WHERE CAST(TRIM(`date`) AS DATE) = '2016-05-22') AS d_on_2016_05_22,
  (SELECT MIN(CAST(TRIM(wday) AS UNSIGNED)) FROM raw_calendar) AS min_wday,
  (SELECT MAX(CAST(TRIM(wday) AS UNSIGNED)) FROM raw_calendar) AS max_wday,
  (SELECT SUM(CAST(TRIM(wday) AS UNSIGNED) NOT BETWEEN 1 AND 7) FROM raw_calendar) AS n_wday_out_of_domain,
  (SELECT SUM(CAST(TRIM(snap_CA) AS UNSIGNED) NOT IN (0, 1)) FROM raw_calendar) AS n_snap_ca_out_of_domain,

  (SELECT COUNT(*)
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS n_prices,

  (SELECT COUNT(*)
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND CAST(TRIM(p.wm_yr_wk) AS UNSIGNED) <= 11617
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS n_prices_le_11617,

  (SELECT COUNT(*)
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND CAST(TRIM(p.wm_yr_wk) AS UNSIGNED) BETWEEN 11618 AND 11621
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS n_prices_11618_11621,

  (SELECT SUM(CAST(TRIM(p.sell_price) AS DECIMAL(10, 2)) <= 0)
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS n_prices_le_zero,

  (SELECT SUM(p.sell_price IS NULL OR TRIM(p.sell_price) = '')
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS n_prices_null,

  (SELECT ROUND(SUM(CAST(TRIM(p.sell_price) AS DECIMAL(10, 2))), 2)
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS sum_sell_price,

  -- NOT the §21 item 8 check (AI3-XR-05 / AI2-XR-01). Retained, unused.
  -- Item 8 is validation/source-gate/04_raw_price_rowkeys.sql vs prices.tsv.
  (SELECT SUM(CRC32(CONCAT(
            TRIM(p.item_id), '|',
            CAST(TRIM(p.wm_yr_wk) AS UNSIGNED), '|',
            CAST(ROUND(CAST(TRIM(p.sell_price) AS DECIMAL(10, 2)) * 100) AS SIGNED)
          )))
     FROM raw_sell_prices p
    WHERE TRIM(p.store_id) = 'CA_1'
      AND TRIM(p.item_id) IN (
            SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
             WHERE TRIM(s.store_id) = 'CA_1'
               AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
          )
  ) AS prices_crc32_sum,

  (SELECT COUNT(*)
     FROM (
       SELECT TRIM(store_id) AS store_id, TRIM(item_id) AS item_id,
              CAST(TRIM(wm_yr_wk) AS UNSIGNED) AS wm_yr_wk
       FROM raw_sell_prices
       WHERE TRIM(store_id) = 'CA_1'
         AND TRIM(item_id) IN (
               SELECT TRIM(s.item_id) FROM raw_sales_evaluation s
                WHERE TRIM(s.store_id) = 'CA_1'
                  AND TRIM(s.dept_id) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
             )
       GROUP BY store_id, item_id, wm_yr_wk
       HAVING COUNT(*) > 1
     ) dup
  ) AS n_dup_price_keys;
