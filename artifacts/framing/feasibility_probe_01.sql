SELECT s.cat_id, s.dept_id, COUNT(*) AS items,
 SUM(p.n_prices>=2) AS items_with_any_price_change,
 SUM(p.n_prices>=4) AS items_with_4plus_distinct_prices,
 SUM(p.n_weeks IS NULL) AS items_no_price_rows,
 ROUND(AVG(p.n_weeks),1) AS avg_priced_weeks
FROM raw_sales_evaluation s
LEFT JOIN (SELECT item_id, COUNT(*) n_weeks, COUNT(DISTINCT sell_price) n_prices
           FROM raw_sell_prices WHERE store_id='CA_1' GROUP BY item_id) p ON p.item_id=s.item_id
WHERE s.store_id='CA_1' AND s.cat_id IN ('FOODS','HOUSEHOLD')
GROUP BY s.cat_id, s.dept_id ORDER BY s.cat_id, s.dept_id;
SELECT MAX(wm_yr_wk) max_price_week, MIN(wm_yr_wk) min_price_week FROM raw_sell_prices WHERE store_id='CA_1';
SELECT d, date, wm_yr_wk FROM raw_calendar WHERE d IN ('d_1941','d_1942','d_1969');
