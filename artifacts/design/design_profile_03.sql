-- PRICEPOINT-001 Stage 3 targeted profiling 03 (read-only aggregates; answers cross-review items AI2 Q4 / AI1 item 1 and AI2 Q1 remainder)
-- Scope: CA_1; FOODS_1-3, HOUSEHOLD_1-2; prices wm_yr_wk <= 11617.
WITH w AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id,
         MAX(CASE WHEN CAST(p.wm_yr_wk AS UNSIGNED)=11616 THEN CAST(p.sell_price AS DECIMAL(10,2)) END) p16,
         MAX(CASE WHEN CAST(p.wm_yr_wk AS UNSIGNED)=11617 THEN CAST(p.sell_price AS DECIMAL(10,2)) END) p17,
         COUNT(DISTINCT CAST(p.sell_price AS DECIMAL(10,2))) nd
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
  GROUP BY SUBSTRING_INDEX(p.item_id,'_',2), p.item_id
)
SELECT dept_id, COUNT(*) n_items,
  SUM(p16 IS NOT NULL AND p17 IS NOT NULL AND p16<>p17) n_11616_ne_11617,
  SUM(p17>p16) n_up_in_11617, SUM(p17<p16) n_down_in_11617,
  SUM(nd=1) nd1, SUM(nd=2) nd2, SUM(nd=3) nd3, SUM(nd>=4) nd4p
FROM w GROUP BY dept_id WITH ROLLUP;
