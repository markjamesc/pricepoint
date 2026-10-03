-- PRICEPOINT-001 Stage 3 targeted profiling 02 (read-only aggregates; answers AI1 open item "profile distributions before locking")
-- Scope: CA_1, FOODS_1-3, HOUSEHOLD_1-2. Price history bounded at wm_yr_wk <= 11617 (current week); sales bounded at d_1941.
WITH pr AS (
  SELECT p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price,
         LAG(CAST(p.sell_price AS DECIMAL(10,2))) OVER (PARTITION BY p.item_id ORDER BY CAST(p.wm_yr_wk AS UNSIGNED)) prev
  FROM raw_sell_prices p WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
), pi AS (
  SELECT item_id, COUNT(*) priced_weeks, COUNT(DISTINCT price) n_distinct_prices,
         SUM(prev IS NOT NULL AND price<>prev) n_price_changes,
         SUM(prev IS NOT NULL AND price<>prev AND wk >= 11617-104) n_changes_last_2y
  FROM pr GROUP BY item_id
), sl AS (
  SELECT s.item_id, s.dept_id, SUM(j.u) units_365, SUM(j.u=0) zero_days_365
  FROM raw_sales_evaluation s,
       JSON_TABLE(s.sales_history, '$[*]' COLUMNS (pos FOR ORDINALITY, u INT PATH '$')) j
  WHERE s.store_id='CA_1' AND s.dept_id IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2') AND j.pos >= 1577
  GROUP BY s.item_id, s.dept_id
), t AS (SELECT sl.*, pi.priced_weeks, pi.n_distinct_prices, pi.n_price_changes, pi.n_changes_last_2y FROM sl JOIN pi ON pi.item_id=sl.item_id)
SELECT 'P1_changes_bucket' q, dept_id,
  SUM(n_price_changes=0) c0, SUM(n_price_changes BETWEEN 1 AND 2) c1_2, SUM(n_price_changes BETWEEN 3 AND 5) c3_5, SUM(n_price_changes BETWEEN 6 AND 10) c6_10, SUM(n_price_changes>10) c11p,
  SUM(n_changes_last_2y>=3) chg2y_ge3, COUNT(*) n FROM t GROUP BY dept_id
UNION ALL
SELECT 'P2_units365_bucket', dept_id, SUM(units_365<28), SUM(units_365 BETWEEN 28 AND 179), SUM(units_365 BETWEEN 180 AND 364), SUM(units_365 BETWEEN 365 AND 1094), SUM(units_365>=1095), SUM(zero_days_365>182), COUNT(*) FROM t GROUP BY dept_id
UNION ALL
SELECT 'P3_joint_chg3_u180_zero<=50pct', dept_id, SUM(n_price_changes>=3 AND units_365>=180 AND zero_days_365<=182), SUM(n_price_changes>=3 AND units_365>=365), SUM(n_distinct_prices>=3 AND units_365>=180), SUM(n_changes_last_2y>=2 AND units_365>=180), SUM(n_price_changes>=5 AND units_365>=365), SUM(priced_weeks<52), COUNT(*) FROM t GROUP BY dept_id
ORDER BY 1,2;
-- Column legend: P1 c0|c1_2|c3_5|c6_10|c11p|changes_last_104wk>=3|n ; P2 units<28|28-179|180-364|365-1094|>=1095|zero_days>182|n ; P3 chg>=3&u>=180&zero<=182 | chg>=3&u>=365 | distinct>=3&u>=180 | chg2y>=2&u>=180 | chg>=5&u>=365 | priced_weeks<52 | n
WITH pr AS (
  SELECT p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price,
         LAG(CAST(p.sell_price AS DECIMAL(10,2))) OVER (PARTITION BY p.item_id ORDER BY CAST(p.wm_yr_wk AS UNSIGNED)) prev
  FROM raw_sell_prices p WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617 AND (p.item_id LIKE 'FOODS%' OR p.item_id LIKE 'HOUSEHOLD%')
)
SELECT 'P4_change_magnitude_pct' q,
  COUNT(*) n_changes, ROUND(AVG(ABS(price/prev-1))*100,2) mean_abs_pct,
  SUM(ABS(price/prev-1) < 0.05) lt5, SUM(ABS(price/prev-1) BETWEEN 0.05 AND 0.10) p5_10, SUM(ABS(price/prev-1) > 0.10 AND ABS(price/prev-1)<=0.25) p10_25, SUM(ABS(price/prev-1) > 0.25) gt25,
  SUM(price>prev) ups, SUM(price<prev) downs
FROM pr WHERE prev IS NOT NULL AND price<>prev;
