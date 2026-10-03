-- PRICEPOINT-001 Stage 3 targeted profiling (read-only aggregates, no staging)
SELECT 'Q1_price_key_dupes' q, COUNT(*) n_rows, COUNT(DISTINCT store_id,item_id,wm_yr_wk) n_keys FROM raw_sell_prices;
SELECT 'Q2_series' q, COUNT(*) n, COUNT(DISTINCT id) n_id, MIN(JSON_LENGTH(sales_history)) minlen, MAX(JSON_LENGTH(sales_history)) maxlen FROM raw_sales_evaluation;
SELECT 'Q3_cal' q, COUNT(*) n, COUNT(DISTINCT d) nd, MIN(date) mn, MAX(date) mx, COUNT(DISTINCT wm_yr_wk) nwk FROM raw_calendar;
SELECT 'Q4_cal_wk_days' q, wm_yr_wk, COUNT(*) days, MIN(date), MAX(date) FROM raw_calendar WHERE CAST(wm_yr_wk AS UNSIGNED) IN (11101,11612,11613,11614,11615,11616,11617,11618,11619,11620,11621) GROUP BY wm_yr_wk ORDER BY wm_yr_wk;
SELECT 'Q5_ca1_price_by_dept' q, s.dept_id, COUNT(*) price_rows, MIN(CAST(p.sell_price AS DECIMAL(10,2))) mn, MAX(CAST(p.sell_price AS DECIMAL(10,2))) mx, SUM(p.sell_price IS NULL OR p.sell_price='') blank
 FROM raw_sell_prices p JOIN raw_sales_evaluation s ON s.store_id=p.store_id AND s.item_id=p.item_id WHERE p.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q6_ca1_current_price_wk11617' q, s.dept_id, COUNT(*) items, SUM(p.item_id IS NOT NULL) priced_11617
 FROM raw_sales_evaluation s LEFT JOIN raw_sell_prices p ON p.store_id=s.store_id AND p.item_id=s.item_id AND p.wm_yr_wk='11617' WHERE s.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q7_ca1_priced_11616' q, s.dept_id, COUNT(*) items, SUM(p.item_id IS NOT NULL) priced_11616
 FROM raw_sales_evaluation s LEFT JOIN raw_sell_prices p ON p.store_id=s.store_id AND p.item_id=s.item_id AND p.wm_yr_wk='11616' WHERE s.store_id='CA_1' GROUP BY s.dept_id ORDER BY s.dept_id;
SELECT 'Q8_ca1_price_gaps' q, dept_id, SUM(gap) items_with_internal_gaps FROM (
 SELECT s.dept_id, s.item_id, (MAX(CAST(p.wm_yr_wk AS UNSIGNED))-MIN(CAST(p.wm_yr_wk AS UNSIGNED))) AS span, COUNT(*) n,
 CASE WHEN COUNT(*) < (SELECT COUNT(DISTINCT c.wm_yr_wk) FROM raw_calendar c WHERE CAST(c.wm_yr_wk AS UNSIGNED) BETWEEN MIN(CAST(p.wm_yr_wk AS UNSIGNED)) AND MAX(CAST(p.wm_yr_wk AS UNSIGNED))) THEN 1 ELSE 0 END gap
 FROM raw_sell_prices p JOIN raw_sales_evaluation s ON s.store_id=p.store_id AND s.item_id=p.item_id WHERE p.store_id='CA_1' GROUP BY s.dept_id, s.item_id) t GROUP BY dept_id ORDER BY dept_id;
SELECT 'Q9_cal_events_snap' q, SUM(event_name_1<>'') ev1, SUM(event_name_2<>'') ev2, SUM(snap_CA='1') snapca, COUNT(*) n FROM raw_calendar;
SELECT 'Q10_horizon_events' q, date, weekday, wday, event_name_1, event_type_1, event_name_2, snap_CA FROM raw_calendar WHERE CAST(SUBSTRING(d,3) AS UNSIGNED) BETWEEN 1942 AND 1969 AND (event_name_1<>'' OR snap_CA='1') ORDER BY date;
