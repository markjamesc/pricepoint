-- PRICEPOINT-001 Stage 3 targeted profiling 04 (framework §25; read-only aggregates, NOT production analysis; no staging objects)
-- Scope: store CA_1; depts FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2 (2,484 items).
-- Prices: wm_yr_wk <= 11617 only (11617 = week in effect on decision date 2016-05-22). Sales: last 365 days = JSON ordinal >= 1577 (ordinal 1 = d_1; 1941 = d_1941).
-- Event week = a wm_yr_wk containing >= 1 day with event_type_1 IN (National, Religious, Sporting, Cultural).
-- "Last 52 weeks" = the 52 distinct calendar wm_yr_wk values ending at 11617 (wks_back 0..51 = weeks 11518..11552 and 11601..11617).
--   NOTE: the literal integer range 11566..11617 is NOT 52 weeks (wm_yr_wk jumps 11552 -> 11601; literal range = 17 weeks), so week ordinals from raw_calendar are used.
-- Current price = week-11617 price (cur). Candidate price = distinct observed price at weeks <= 11617, price <> cur, within band x cur (inclusive).

-- ===== Q1 (a) eligibility joint counts by dept (+ (e) E_A subset of nd=5 / nd>5) =====
WITH cal AS (
  SELECT CAST(SUBSTRING(d,3) AS UNSIGNED) dnum, CAST(wm_yr_wk AS UNSIGNED) wk,
         (event_type_1 IN ('National','Religious','Sporting','Cultural')) ev
  FROM raw_calendar
), wkx AS (
  SELECT wk, MAX(ev) ev_wk, DENSE_RANK() OVER (ORDER BY wk DESC) - 1 wks_back
  FROM cal WHERE wk <= 11617 GROUP BY wk
), pr AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
), prl AS (
  SELECT pr.*, LAG(price) OVER (PARTITION BY item_id ORDER BY wk) prev FROM pr
), pi AS (
  SELECT dept_id, item_id, COUNT(*) priced_weeks, COUNT(DISTINCT price) nd,
         SUM(prev IS NOT NULL AND price<>prev) n_chg, MIN(wk) first_wk,
         MAX(CASE WHEN wk=11617 THEN price END) cur
  FROM prl GROUP BY dept_id, item_id
), ipw AS (
  SELECT item_id, price, COUNT(*) n_wk, MIN(wk) any_wk FROM pr GROUP BY item_id, price
), ip AS (
  SELECT ipw.item_id, ipw.price, ipw.n_wk, (ipw.n_wk=1 AND w.ev_wk=1) single_ev
  FROM ipw JOIN wkx w ON w.wk=ipw.any_wk
), cand AS (
  SELECT pi.item_id,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.80*pi.cur AND 1.20*pi.cur) k20,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.80*pi.cur AND 1.20*pi.cur AND NOT ip.single_ev) k20f,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.75*pi.cur AND 1.25*pi.cur) k25,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.75*pi.cur AND 1.25*pi.cur AND NOT ip.single_ev) k25f
  FROM pi JOIN ip ON ip.item_id=pi.item_id GROUP BY pi.item_id
), sd AS (
  SELECT s.item_id, j.pos, j.u
  FROM raw_sales_evaluation s,
       JSON_TABLE(s.sales_history, '$[*]' COLUMNS (pos FOR ORDINALITY, u INT PATH '$')) j
  WHERE s.store_id='CA_1' AND s.dept_id IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2') AND j.pos >= 1577
), sl AS (
  SELECT item_id, SUM(u) units_365, SUM(u=0) zero_days_365, COUNT(*) n_days FROM sd GROUP BY item_id
), swk AS (
  SELECT sd.item_id, c.wk, SUM(sd.u) wu
  FROM sd JOIN cal c ON c.dnum=sd.pos JOIN wkx w ON w.wk=c.wk AND w.wks_back<=51
  GROUP BY sd.item_id, c.wk
), pw AS (
  SELECT item_id, SUM(wu>0) pos_wk52, COUNT(*) n_wk52 FROM swk GROUP BY item_id
), t AS (
  SELECT pi.*, sl.units_365, sl.zero_days_365, sl.n_days, pw.pos_wk52, cand.k20, cand.k20f, cand.k25, cand.k25f,
         (pi.n_chg>=3 AND sl.units_365>=180 AND sl.zero_days_365<=182) ea
  FROM pi JOIN sl ON sl.item_id=pi.item_id JOIN pw ON pw.item_id=pi.item_id JOIN cand ON cand.item_id=pi.item_id
)
SELECT 'A_eligibility' q, COALESCE(dept_id,'TOTAL') dept_id, COUNT(*) n,
  SUM(ea) e_a,
  SUM(ea AND priced_weeks>=52) ea_pw52,
  SUM(ea AND nd>=4) ea_nd4,
  SUM(ea AND pos_wk52>=26) ea_pos26,
  SUM(ea AND priced_weeks>=52 AND nd>=4 AND pos_wk52>=26) ea_pw52_nd4_pos26,
  SUM(nd>=3 AND units_365>=180) e_b,
  SUM(n_chg>=5 AND units_365>=365) e_c,
  SUM(ea AND priced_weeks>=52 AND k20f>=1) ea_pw52_c20f,
  SUM(ea AND priced_weeks>=52 AND k25f>=1) ea_pw52_c25f,
  SUM(ea AND priced_weeks>=52 AND k20>=1) ea_pw52_c20,
  SUM(ea AND priced_weeks>=52 AND k25>=1) ea_pw52_c25,
  SUM(ea AND nd=5) ea_nd5,
  SUM(ea AND nd>5) ea_ndgt5,
  MIN(n_days) chk_min_days, MAX(n_days) chk_max_days
FROM t GROUP BY dept_id WITH ROLLUP;

-- ===== Q2 (b) candidate-price count distribution per E_A item (band 0.80-1.20 / 0.75-1.25 x cur; with/without single-week-event filter) =====
WITH cal AS (
  SELECT CAST(SUBSTRING(d,3) AS UNSIGNED) dnum, CAST(wm_yr_wk AS UNSIGNED) wk,
         (event_type_1 IN ('National','Religious','Sporting','Cultural')) ev
  FROM raw_calendar
), wkx AS (
  SELECT wk, MAX(ev) ev_wk, DENSE_RANK() OVER (ORDER BY wk DESC) - 1 wks_back
  FROM cal WHERE wk <= 11617 GROUP BY wk
), pr AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
), prl AS (
  SELECT pr.*, LAG(price) OVER (PARTITION BY item_id ORDER BY wk) prev FROM pr
), pi AS (
  SELECT dept_id, item_id, COUNT(*) priced_weeks, COUNT(DISTINCT price) nd,
         SUM(prev IS NOT NULL AND price<>prev) n_chg, MAX(CASE WHEN wk=11617 THEN price END) cur
  FROM prl GROUP BY dept_id, item_id
), ipw AS (
  SELECT item_id, price, COUNT(*) n_wk, MIN(wk) any_wk FROM pr GROUP BY item_id, price
), ip AS (
  SELECT ipw.item_id, ipw.price, ipw.n_wk, (ipw.n_wk=1 AND w.ev_wk=1) single_ev
  FROM ipw JOIN wkx w ON w.wk=ipw.any_wk
), cand AS (
  SELECT pi.item_id,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.80*pi.cur AND 1.20*pi.cur) k20,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.80*pi.cur AND 1.20*pi.cur AND NOT ip.single_ev) k20f,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.75*pi.cur AND 1.25*pi.cur) k25,
    SUM(ip.price<>pi.cur AND ip.price BETWEEN 0.75*pi.cur AND 1.25*pi.cur AND NOT ip.single_ev) k25f
  FROM pi JOIN ip ON ip.item_id=pi.item_id GROUP BY pi.item_id
), sl AS (
  SELECT s.item_id, SUM(j.u) units_365, SUM(j.u=0) zero_days_365
  FROM raw_sales_evaluation s,
       JSON_TABLE(s.sales_history, '$[*]' COLUMNS (pos FOR ORDINALITY, u INT PATH '$')) j
  WHERE s.store_id='CA_1' AND s.dept_id IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2') AND j.pos >= 1577
  GROUP BY s.item_id
), ea AS (
  SELECT pi.dept_id, pi.item_id, pi.priced_weeks, cand.k20, cand.k20f, cand.k25, cand.k25f
  FROM pi JOIN sl ON sl.item_id=pi.item_id JOIN cand ON cand.item_id=pi.item_id
  WHERE pi.n_chg>=3 AND sl.units_365>=180 AND sl.zero_days_365<=182
), kv AS (
  SELECT dept_id, 'b1_band20_nofilter' v, k20 k FROM ea
  UNION ALL SELECT dept_id, 'b2_band20_eventfilter', k20f FROM ea
  UNION ALL SELECT dept_id, 'b3_band25_nofilter', k25 FROM ea
  UNION ALL SELECT dept_id, 'b4_band25_eventfilter', k25f FROM ea
)
SELECT 'B_candidates_EA' q, v variant, COALESCE(dept_id,'TOTAL') dept_id,
  SUM(k=0) k0, SUM(k=1) k1, SUM(k=2) k2, SUM(k=3) k3, SUM(k=4) k4, SUM(k=5) k5, SUM(k>5) k_gt5,
  COUNT(*) n_ea, SUM(LEAST(k,5)) sum_capped5
FROM kv GROUP BY v, dept_id WITH ROLLUP HAVING GROUPING(v)=0;

-- ===== Q3 (c) single-week pre-origin price levels: event vs non-event weeks =====
WITH cal AS (
  SELECT CAST(wm_yr_wk AS UNSIGNED) wk, event_type_1 et FROM raw_calendar
), wkx AS (
  SELECT wk, MAX(et IN ('National','Religious','Sporting','Cultural')) ev_wk,
         MAX(et='National') ev_nat, MAX(et='Religious') ev_rel, MAX(et='Sporting') ev_spo, MAX(et='Cultural') ev_cul
  FROM cal WHERE wk <= 11617 GROUP BY wk
), pr AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
), ipw AS (
  SELECT dept_id, item_id, price, COUNT(*) n_wk, MIN(wk) any_wk FROM pr GROUP BY dept_id, item_id, price
), iw AS (
  SELECT pr.dept_id, COUNT(*) item_weeks, SUM(w.ev_wk) item_weeks_ev FROM pr JOIN wkx w ON w.wk=pr.wk GROUP BY pr.dept_id WITH ROLLUP
), sw AS (
  SELECT ipw.dept_id, COUNT(*) n_price_levels, SUM(ipw.n_wk=1) n_single_all,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617) n_single_pre,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_wk=1) single_pre_ev,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_wk=0) single_pre_nonev,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_nat=1) sp_nat,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_rel=1) sp_rel,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_spo=1) sp_spo,
    SUM(ipw.n_wk=1 AND ipw.any_wk<11617 AND w.ev_cul=1) sp_cul
  FROM ipw JOIN wkx w ON w.wk=ipw.any_wk GROUP BY ipw.dept_id WITH ROLLUP
)
SELECT 'C_single_week_prices' q, COALESCE(sw.dept_id,'TOTAL') dept_id, sw.n_price_levels, sw.n_single_all, sw.n_single_pre,
  sw.single_pre_ev, sw.single_pre_nonev, ROUND(100*sw.single_pre_ev/sw.n_single_pre,2) pct_single_pre_ev,
  sw.sp_nat, sw.sp_rel, sw.sp_spo, sw.sp_cul,
  iw.item_weeks, iw.item_weeks_ev, ROUND(100*iw.item_weeks_ev/iw.item_weeks,2) pct_itemweeks_ev,
  (SELECT SUM(ev_wk) FROM wkx) cal_event_weeks, (SELECT COUNT(*) FROM wkx) cal_weeks
FROM sw JOIN iw ON (iw.dept_id=sw.dept_id OR (iw.dept_id IS NULL AND sw.dept_id IS NULL))
ORDER BY sw.dept_id IS NULL, sw.dept_id;

-- ===== Q4 (d) first priced week per item =====
WITH wkx AS (
  SELECT wk, DENSE_RANK() OVER (ORDER BY wk DESC) - 1 wks_back
  FROM (SELECT DISTINCT CAST(wm_yr_wk AS UNSIGNED) wk FROM raw_calendar) c WHERE wk <= 11617
), f AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id, MIN(CAST(p.wm_yr_wk AS UNSIGNED)) first_wk, COUNT(*) priced_weeks
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
  GROUP BY SUBSTRING_INDEX(p.item_id,'_',2), p.item_id
), fb AS (
  SELECT f.*, w.wks_back,
    ROW_NUMBER() OVER (PARTITION BY f.dept_id ORDER BY f.first_wk, f.item_id) rn_d, COUNT(*) OVER (PARTITION BY f.dept_id) n_d,
    ROW_NUMBER() OVER (ORDER BY f.first_wk, f.item_id) rn_t, COUNT(*) OVER () n_t
  FROM f JOIN wkx w ON w.wk=f.first_wk
)
SELECT 'D_first_priced_week' q, dept_id, COUNT(*) n, MIN(first_wk) min_first_wk,
  MAX(CASE WHEN rn_d=CEIL(n_d/2) THEN first_wk END) median_first_wk, MAX(first_wk) max_first_wk,
  SUM(first_wk=11101) at_11101, SUM(wks_back>52) gt52_before_11617, SUM(wks_back<=52) le52_before_11617,
  SUM(wks_back BETWEEN 0 AND 50) wb_0_50, SUM(wks_back BETWEEN 51 AND 104) wb_51_104, SUM(wks_back BETWEEN 105 AND 208) wb_105_208, SUM(wks_back>208) wb_gt208,
  SUM(priced_weeks<52) priced_lt52, SUM(priced_weeks<>wks_back+1) chk_gap_items
FROM fb GROUP BY dept_id
UNION ALL
SELECT 'D_first_priced_week', 'TOTAL', COUNT(*), MIN(first_wk), MAX(CASE WHEN rn_t=CEIL(n_t/2) THEN first_wk END), MAX(first_wk),
  SUM(first_wk=11101), SUM(wks_back>52), SUM(wks_back<=52),
  SUM(wks_back BETWEEN 0 AND 50), SUM(wks_back BETWEEN 51 AND 104), SUM(wks_back BETWEEN 105 AND 208), SUM(wks_back>208),
  SUM(priced_weeks<52), SUM(priced_weeks<>wks_back+1)
FROM fb;

-- ===== Q5 (e) distinct pre-origin prices (incl. current) = 4 / = 5 / > 5 by dept; (f) corrected recent-change counts by calendar-week ordinal =====
WITH wkx AS (
  SELECT wk, DENSE_RANK() OVER (ORDER BY wk DESC) - 1 wks_back
  FROM (SELECT DISTINCT CAST(wm_yr_wk AS UNSIGNED) wk FROM raw_calendar) c WHERE wk <= 11617
), pr AS (
  SELECT SUBSTRING_INDEX(p.item_id,'_',2) dept_id, p.item_id, CAST(p.wm_yr_wk AS UNSIGNED) wk, CAST(p.sell_price AS DECIMAL(10,2)) price
  FROM raw_sell_prices p
  WHERE p.store_id='CA_1' AND CAST(p.wm_yr_wk AS UNSIGNED) <= 11617
    AND SUBSTRING_INDEX(p.item_id,'_',2) IN ('FOODS_1','FOODS_2','FOODS_3','HOUSEHOLD_1','HOUSEHOLD_2')
), prl AS (
  SELECT pr.*, w.wks_back, LAG(pr.price) OVER (PARTITION BY pr.item_id ORDER BY pr.wk) prev FROM pr JOIN wkx w ON w.wk=pr.wk
), pi AS (
  SELECT dept_id, item_id, COUNT(DISTINCT price) nd,
    SUM(prev IS NOT NULL AND price<>prev AND wks_back<=103) chg104,
    SUM(prev IS NOT NULL AND price<>prev AND wks_back<=51) chg52,
    SUM(prev IS NOT NULL AND price<>prev AND wk>=11617-104) chg_lit11513
  FROM prl GROUP BY dept_id, item_id
)
SELECT 'E_distinct_and_F_recent_changes' q, COALESCE(dept_id,'TOTAL') dept_id, COUNT(*) n,
  SUM(nd=4) nd4, SUM(nd=5) nd5, SUM(nd>5) nd_gt5, MAX(nd) max_nd,
  SUM(chg104>=3) chg104_ge3, SUM(chg104>=2) chg104_ge2, SUM(chg52>=3) chg52_ge3, SUM(chg52>=2) chg52_ge2, SUM(chg52>=1) chg52_ge1,
  SUM(chg_lit11513>=3) chk_lit11513_ge3
FROM pi GROUP BY dept_id WITH ROLLUP;
