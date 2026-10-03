# PROFILE BUNDLE 01–04 (PRICEPOINT-001 Stage 3, targeted profiling per framework §25)

Verbatim copies of the four design-profile SQL files, their UTF-8 outputs, and the notes files. Source directory: `/workspace/pp001/stage3/profile/` (PC copies under `C:\Users\Mark\Documents\R Working Directory\pricepoint\artifacts\design\`). All queries are read-only aggregates against MySQL schema `pricepoint`. UTF-8 outputs for 01 and 02 were produced from the UTF-16 PC outputs with iconv (-f UTF-16 -t UTF-8, CR stripped) and are byte-identical to `xreview/profile_0{1,2}_output_utf8.txt`. Profiles 01 and 03 have no separate notes file. Profile 04 failed once (ERROR 1054) before the successful run; the failed output is included at the end.

Known correction (see 04 NOTES and 06 DC-2): profile 02 column chg2y_ge3 measured 57 calendar weeks, not 104.

---

## Profile 01

### design_profile_01.sql

```sql
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
```

### output (UTF-8): profile_01_output_utf8.txt

```text
+--------------------+---------+---------+
| q                  | n_rows  | n_keys  |
+--------------------+---------+---------+
| Q1_price_key_dupes | 6841121 | 6841121 |
+--------------------+---------+---------+
+-----------+-------+-------+--------+--------+
| q         | n     | n_id  | minlen | maxlen |
+-----------+-------+-------+--------+--------+
| Q2_series | 30490 | 30490 |   1941 |   1941 |
+-----------+-------+-------+--------+--------+
+--------+------+------+------------+------------+-----+
| q      | n    | nd   | mn         | mx         | nwk |
+--------+------+------+------------+------------+-----+
| Q3_cal | 1969 | 1969 | 2011-01-29 | 2016-06-19 | 282 |
+--------+------+------+------------+------------+-----+
+----------------+----------+------+------------+------------+
| q              | wm_yr_wk | days | MIN(date)  | MAX(date)  |
+----------------+----------+------+------------+------------+
| Q4_cal_wk_days | 11101    |    7 | 2011-01-29 | 2011-02-04 |
| Q4_cal_wk_days | 11612    |    7 | 2016-04-16 | 2016-04-22 |
| Q4_cal_wk_days | 11613    |    7 | 2016-04-23 | 2016-04-29 |
| Q4_cal_wk_days | 11614    |    7 | 2016-04-30 | 2016-05-06 |
| Q4_cal_wk_days | 11615    |    7 | 2016-05-07 | 2016-05-13 |
| Q4_cal_wk_days | 11616    |    7 | 2016-05-14 | 2016-05-20 |
| Q4_cal_wk_days | 11617    |    7 | 2016-05-21 | 2016-05-27 |
| Q4_cal_wk_days | 11618    |    7 | 2016-05-28 | 2016-06-03 |
| Q4_cal_wk_days | 11619    |    7 | 2016-06-04 | 2016-06-10 |
| Q4_cal_wk_days | 11620    |    7 | 2016-06-11 | 2016-06-17 |
| Q4_cal_wk_days | 11621    |    2 | 2016-06-18 | 2016-06-19 |
+----------------+----------+------+------------+------------+
+----------------------+-------------+------------+------+-------+-------+
| q                    | dept_id     | price_rows | mn   | mx    | blank |
+----------------------+-------------+------------+------+-------+-------+
| Q5_ca1_price_by_dept | FOODS_1     |      52156 | 0.97 | 12.98 |     0 |
| Q5_ca1_price_by_dept | FOODS_2     |      90747 | 0.64 | 13.98 |     0 |
| Q5_ca1_price_by_dept | FOODS_3     |     186763 | 0.20 | 19.48 |     0 |
| Q5_ca1_price_by_dept | HOBBIES_1   |      96737 | 0.10 | 30.98 |     0 |
| Q5_ca1_price_by_dept | HOBBIES_2   |      32892 | 0.05 |  9.97 |     0 |
| Q5_ca1_price_by_dept | HOUSEHOLD_1 |     117067 | 0.01 | 29.97 |     0 |
| Q5_ca1_price_by_dept | HOUSEHOLD_2 |     122050 | 0.75 | 26.88 |     0 |
+----------------------+-------------+------------+------+-------+-------+
+------------------------------+-------------+-------+--------------+
| q                            | dept_id     | items | priced_11617 |
+------------------------------+-------------+-------+--------------+
| Q6_ca1_current_price_wk11617 | FOODS_1     |   216 |          216 |
| Q6_ca1_current_price_wk11617 | FOODS_2     |   398 |          398 |
| Q6_ca1_current_price_wk11617 | FOODS_3     |   823 |          823 |
| Q6_ca1_current_price_wk11617 | HOBBIES_1   |   416 |          416 |
| Q6_ca1_current_price_wk11617 | HOBBIES_2   |   149 |          149 |
| Q6_ca1_current_price_wk11617 | HOUSEHOLD_1 |   532 |          532 |
| Q6_ca1_current_price_wk11617 | HOUSEHOLD_2 |   515 |          515 |
+------------------------------+-------------+-------+--------------+
+---------------------+-------------+-------+--------------+
| q                   | dept_id     | items | priced_11616 |
+---------------------+-------------+-------+--------------+
| Q7_ca1_priced_11616 | FOODS_1     |   216 |          216 |
| Q7_ca1_priced_11616 | FOODS_2     |   398 |          398 |
| Q7_ca1_priced_11616 | FOODS_3     |   823 |          823 |
| Q7_ca1_priced_11616 | HOBBIES_1   |   416 |          416 |
| Q7_ca1_priced_11616 | HOBBIES_2   |   149 |          149 |
| Q7_ca1_priced_11616 | HOUSEHOLD_1 |   532 |          532 |
| Q7_ca1_priced_11616 | HOUSEHOLD_2 |   515 |          515 |
+---------------------+-------------+-------+--------------+
+-------------------+-------------+--------------------------+
| q                 | dept_id     | items_with_internal_gaps |
+-------------------+-------------+--------------------------+
| Q8_ca1_price_gaps | FOODS_1     |                        0 |
| Q8_ca1_price_gaps | FOODS_2     |                        0 |
| Q8_ca1_price_gaps | FOODS_3     |                        0 |
| Q8_ca1_price_gaps | HOBBIES_1   |                        0 |
| Q8_ca1_price_gaps | HOBBIES_2   |                        0 |
| Q8_ca1_price_gaps | HOUSEHOLD_1 |                        0 |
| Q8_ca1_price_gaps | HOUSEHOLD_2 |                        0 |
+-------------------+-------------+--------------------------+
+--------------------+------+------+--------+------+
| q                  | ev1  | ev2  | snapca | n    |
+--------------------+------+------+--------+------+
| Q9_cal_events_snap |  162 |    5 |    650 | 1969 |
+--------------------+------+------+--------+------+
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
| q                  | date       | weekday   | wday | event_name_1   | event_type_1 | event_name_2 | snap_CA |
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
| Q10_horizon_events | 2016-05-30 | Monday    | 3    | MemorialDay    | National     |              | 0       |
| Q10_horizon_events | 2016-06-01 | Wednesday | 5    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-02 | Thursday  | 6    | NBAFinalsStart | Sporting     |              | 1       |
| Q10_horizon_events | 2016-06-03 | Friday    | 7    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-04 | Saturday  | 1    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-05 | Sunday    | 2    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-06 | Monday    | 3    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-07 | Tuesday   | 4    | Ramadan starts | Religious    |              | 1       |
| Q10_horizon_events | 2016-06-08 | Wednesday | 5    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-09 | Thursday  | 6    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-10 | Friday    | 7    |                |              |              | 1       |
| Q10_horizon_events | 2016-06-19 | Sunday    | 2    | NBAFinalsEnd   | Sporting     | Father's day | 0       |
+--------------------+------------+-----------+------+----------------+--------------+--------------+---------+
```

---

## Profile 02

### design_profile_02.sql

```sql
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
```

### output (UTF-8): profile_02_output_utf8.txt

```text
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
| q                              | dept_id     | c0   | c1_2 | c3_5 | c6_10 | c11p | chg2y_ge3 | n   |
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
| P1_changes_bucket              | FOODS_1     |   36 |   92 |   52 |    32 |    4 |        11 | 216 |
| P1_changes_bucket              | FOODS_2     |   35 |  117 |  157 |    83 |    6 |         4 | 398 |
| P1_changes_bucket              | FOODS_3     |  241 |  289 |  187 |    90 |   16 |        11 | 823 |
| P1_changes_bucket              | HOUSEHOLD_1 |  165 |  268 |   84 |    15 |    0 |         1 | 532 |
| P1_changes_bucket              | HOUSEHOLD_2 |  206 |  236 |   68 |     5 |    0 |         3 | 515 |
| P2_units365_bucket             | FOODS_1     |    3 |   39 |   76 |    73 |   25 |       119 | 216 |
| P2_units365_bucket             | FOODS_2     |    0 |  108 |  132 |   130 |   28 |       247 | 398 |
| P2_units365_bucket             | FOODS_3     |    4 |  112 |  207 |   313 |  187 |       361 | 823 |
| P2_units365_bucket             | HOUSEHOLD_1 |    1 |  124 |  151 |   202 |   54 |       242 | 532 |
| P2_units365_bucket             | HOUSEHOLD_2 |   33 |  353 |   95 |    33 |    1 |       465 | 515 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_1     |   29 |   31 |  101 |    17 |    7 |         0 | 216 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_2     |   99 |  103 |  207 |    30 |   50 |         4 | 398 |
| P3_joint_chg3_u180_zero<=50pct | FOODS_3     |  172 |  190 |  302 |    68 |  107 |         4 | 823 |
| P3_joint_chg3_u180_zero<=50pct | HOUSEHOLD_1 |   61 |   56 |  146 |    25 |   13 |         1 | 532 |
| P3_joint_chg3_u180_zero<=50pct | HOUSEHOLD_2 |    3 |    1 |   28 |     4 |    0 |         0 | 515 |
+--------------------------------+-------------+------+------+------+-------+------+-----------+-----+
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
| q                       | n_changes | mean_abs_pct | lt5  | p5_10 | p10_25 | gt25 | ups  | downs |
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
| P4_change_magnitude_pct |      5465 |        16.22 | 1867 |  1686 |   1451 |  461 | 3234 |  2231 |
+-------------------------+-----------+--------------+------+-------+--------+------+------+-------+
```

### design_profile_02_NOTES.md (verbatim)

````markdown
# Design profiling 02: interpretation notes (PRICEPOINT-001 Stage 3, §25 targeted profiling)
Source: design_profile_02.sql (read-only aggregates, run 2026-09-25 ~04:05 CT on DESKTOP-RPECRM9, 54.7 s). Output: design_profile_02_output.txt.
Scope: CA_1; FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2 (2,484 items). Price history weeks <= 11617; sales last 365 days (d_1577..d_1941).
Column legend is the SQL comment on line 27 (the output header row reuses P1 column names for P2/P3).

Key facts for design:
- Items in scope: FOODS_1 216, FOODS_2 398, FOODS_3 823, HOUSEHOLD_1 532, HOUSEHOLD_2 515 (total 2,484).
- Items with zero historical price changes: 36/35/241/165/206 (683 total) -> no own-price variation.
- Items with >=3 price changes in last 104 weeks: 11/4/11/1/3 (30 total) -> recent price variation is scarce.
- Items with >182 zero-sales days in last 365: 119/247/361/242/465 (1,434 total) -> intermittent demand is the majority.
- Joint rule (changes>=3 AND units_365>=180 AND zero_days<=182): 29/99/172/61/3 = 364 items.
- changes>=3 AND units_365>=365: 31/103/190/56/1 = 381.
- distinct_prices>=3 AND units_365>=180: 101/207/302/146/28 = 784.
- changes_last_2y>=2 AND units_365>=180: 17/30/68/25/4 = 144.
- changes>=5 AND units_365>=365: 7/50/107/13/0 = 177.
- priced_weeks<52: 0/4/4/1/0.
- Price-change magnitudes (all FOODS/HOUSEHOLD CA_1 changes, weeks<=11617): 5,465 changes; mean |pct| 16.22%; <5%: 1,867; 5-10%: 1,686; 10-25%: 1,451; >25%: 461; ups 3,234; downs 2,231.
Implication: an eligibility rule of roughly the "joint" form lands near the stakeholder's ~200-300 item intent only with a threshold choice; this is an owner-visible design choice to lock in the candidate. Candidate price grids beyond about +/-10-25% are outside most observed change magnitudes.
````

---

## Profile 03

### design_profile_03.sql

```sql
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
```

### output (UTF-8): design_profile_03_output_utf8.txt

```text
+-------------+---------+------------------+---------------+-----------------+------+------+------+------+
| dept_id     | n_items | n_11616_ne_11617 | n_up_in_11617 | n_down_in_11617 | nd1  | nd2  | nd3  | nd4p |
+-------------+---------+------------------+---------------+-----------------+------+------+------+------+
| FOODS_1     |     216 |                1 |             1 |               0 |   36 |   47 |   64 |   69 |
| FOODS_2     |     398 |                0 |             0 |               0 |   35 |   85 |   76 |  202 |
| FOODS_3     |     823 |                3 |             0 |               3 |  241 |  235 |  138 |  209 |
| HOUSEHOLD_1 |     532 |                0 |             0 |               0 |  165 |  182 |  122 |   63 |
| HOUSEHOLD_2 |     515 |                1 |             0 |               1 |  206 |  177 |   94 |   38 |
| NULL        |    2484 |                5 |             1 |               4 |  683 |  726 |  494 |  581 |
+-------------+---------+------------------+---------------+-----------------+------+------+------+------+
```

---

## Profile 04

### design_profile_04.sql

```sql
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
```

### output (UTF-8): design_profile_04_output_utf8.txt

```text
+---------------+-------------+------+------+---------+--------+----------+-------------------+------+------+--------------+--------------+-------------+-------------+--------+----------+--------------+--------------+
| q             | dept_id     | n    | e_a  | ea_pw52 | ea_nd4 | ea_pos26 | ea_pw52_nd4_pos26 | e_b  | e_c  | ea_pw52_c20f | ea_pw52_c25f | ea_pw52_c20 | ea_pw52_c25 | ea_nd5 | ea_ndgt5 | chk_min_days | chk_max_days |
+---------------+-------------+------+------+---------+--------+----------+-------------------+------+------+--------------+--------------+-------------+-------------+--------+----------+--------------+--------------+
| A_eligibility | FOODS_1     |  216 |   29 |      29 |     20 |       29 |                20 |  101 |    7 |           29 |           29 |          29 |          29 |      2 |        4 |          365 |          365 |
| A_eligibility | FOODS_2     |  398 |   99 |      99 |     77 |       99 |                77 |  207 |   50 |           97 |           99 |          97 |          99 |     25 |       14 |          365 |          365 |
| A_eligibility | FOODS_3     |  823 |  172 |     172 |    136 |      172 |               136 |  302 |  107 |          169 |          172 |         169 |         172 |     31 |       41 |          365 |          365 |
| A_eligibility | HOUSEHOLD_1 |  532 |   61 |      61 |     39 |       61 |                39 |  146 |   13 |           59 |           60 |          59 |          60 |      7 |        9 |          365 |          365 |
| A_eligibility | HOUSEHOLD_2 |  515 |    3 |       3 |      2 |        3 |                 2 |   28 |    0 |            3 |            3 |           3 |           3 |      0 |        0 |          365 |          365 |
| A_eligibility | TOTAL       | 2484 |  364 |     364 |    274 |      364 |               274 |  784 |  177 |          357 |          363 |         357 |         363 |     65 |       68 |          365 |          365 |
+---------------+-------------+------+------+---------+--------+----------+-------------------+------+------+--------------+--------------+-------------+-------------+--------+----------+--------------+--------------+
+-----------------+-----------------------+-------------+------+------+------+------+------+------+-------+------+-------------+
| q               | variant               | dept_id     | k0   | k1   | k2   | k3   | k4   | k5   | k_gt5 | n_ea | sum_capped5 |
+-----------------+-----------------------+-------------+------+------+------+------+------+------+-------+------+-------------+
| B_candidates_EA | b1_band20_nofilter    | FOODS_1     |    0 |    7 |   10 |    8 |    0 |    0 |     4 |   29 |          71 |
| B_candidates_EA | b1_band20_nofilter    | FOODS_2     |    2 |    6 |   23 |   34 |   21 |    6 |     7 |   99 |         303 |
| B_candidates_EA | b1_band20_nofilter    | FOODS_3     |    3 |   22 |   43 |   55 |   26 |   22 |     1 |  172 |         492 |
| B_candidates_EA | b1_band20_nofilter    | HOUSEHOLD_1 |    2 |    6 |   19 |   21 |    4 |    8 |     1 |   61 |         168 |
| B_candidates_EA | b1_band20_nofilter    | HOUSEHOLD_2 |    0 |    0 |    1 |    2 |    0 |    0 |     0 |    3 |           8 |
| B_candidates_EA | b1_band20_nofilter    | TOTAL       |    7 |   41 |   96 |  120 |   51 |   36 |    13 |  364 |        1042 |
| B_candidates_EA | b2_band20_eventfilter | FOODS_1     |    0 |    9 |    8 |    8 |    0 |    0 |     4 |   29 |          69 |
| B_candidates_EA | b2_band20_eventfilter | FOODS_2     |    2 |    6 |   25 |   32 |   21 |    6 |     7 |   99 |         301 |
| B_candidates_EA | b2_band20_eventfilter | FOODS_3     |    3 |   23 |   42 |   57 |   24 |   22 |     1 |  172 |         489 |
| B_candidates_EA | b2_band20_eventfilter | HOUSEHOLD_1 |    2 |    6 |   20 |   20 |    4 |    8 |     1 |   61 |         167 |
| B_candidates_EA | b2_band20_eventfilter | HOUSEHOLD_2 |    0 |    0 |    1 |    2 |    0 |    0 |     0 |    3 |           8 |
| B_candidates_EA | b2_band20_eventfilter | TOTAL       |    7 |   44 |   96 |  119 |   49 |   36 |    13 |  364 |        1034 |
| B_candidates_EA | b3_band25_nofilter    | FOODS_1     |    0 |    1 |   10 |   14 |    0 |    0 |     4 |   29 |          83 |
| B_candidates_EA | b3_band25_nofilter    | FOODS_2     |    0 |    8 |   16 |   40 |   22 |    6 |     7 |   99 |         313 |
| B_candidates_EA | b3_band25_nofilter    | FOODS_3     |    0 |   10 |   41 |   68 |   26 |   19 |     8 |  172 |         535 |
| B_candidates_EA | b3_band25_nofilter    | HOUSEHOLD_1 |    1 |    4 |   21 |   20 |    6 |    8 |     1 |   61 |         175 |
| B_candidates_EA | b3_band25_nofilter    | HOUSEHOLD_2 |    0 |    0 |    1 |    2 |    0 |    0 |     0 |    3 |           8 |
| B_candidates_EA | b3_band25_nofilter    | TOTAL       |    1 |   23 |   89 |  144 |   54 |   33 |    20 |  364 |        1114 |
| B_candidates_EA | b4_band25_eventfilter | FOODS_1     |    0 |    3 |    8 |   14 |    0 |    0 |     4 |   29 |          81 |
| B_candidates_EA | b4_band25_eventfilter | FOODS_2     |    0 |    8 |   18 |   38 |   22 |    6 |     7 |   99 |         311 |
| B_candidates_EA | b4_band25_eventfilter | FOODS_3     |    0 |   11 |   40 |   70 |   24 |   19 |     8 |  172 |         532 |
| B_candidates_EA | b4_band25_eventfilter | HOUSEHOLD_1 |    1 |    5 |   21 |   19 |    6 |    8 |     1 |   61 |         173 |
| B_candidates_EA | b4_band25_eventfilter | HOUSEHOLD_2 |    0 |    0 |    1 |    2 |    0 |    0 |     0 |    3 |           8 |
| B_candidates_EA | b4_band25_eventfilter | TOTAL       |    1 |   27 |   88 |  143 |   52 |   33 |    20 |  364 |        1105 |
+-----------------+-----------------------+-------------+------+------+------+------+------+------+-------+------+-------------+
+----------------------+-------------+----------------+--------------+--------------+---------------+------------------+-------------------+--------+--------+--------+--------+------------+---------------+------------------+-----------------+-----------+
| q                    | dept_id     | n_price_levels | n_single_all | n_single_pre | single_pre_ev | single_pre_nonev | pct_single_pre_ev | sp_nat | sp_rel | sp_spo | sp_cul | item_weeks | item_weeks_ev | pct_itemweeks_ev | cal_event_weeks | cal_weeks |
+----------------------+-------------+----------------+--------------+--------------+---------------+------------------+-------------------+--------+--------+--------+--------+------------+---------------+------------------+-----------------+-----------+
| C_single_week_prices | FOODS_1     |            786 |           21 |           21 |            15 |                6 |             71.43 |     10 |      3 |      1 |      2 |      51292 |         24241 |            47.26 |             132 |       278 |
| C_single_week_prices | FOODS_2     |           1453 |           32 |           32 |            12 |               20 |             37.50 |      5 |      6 |      2 |      5 |      89155 |         42110 |            47.23 |             132 |       278 |
| C_single_week_prices | FOODS_3     |           2166 |           47 |           47 |            16 |               31 |             34.04 |      4 |      4 |      0 |      9 |     183471 |         86677 |            47.24 |             132 |       278 |
| C_single_week_prices | HOUSEHOLD_1 |           1179 |           46 |           46 |            18 |               28 |             39.13 |      9 |     13 |      1 |      1 |     114939 |         54176 |            47.13 |             132 |       278 |
| C_single_week_prices | HOUSEHOLD_2 |           1012 |           39 |           38 |            13 |               25 |             34.21 |      6 |      2 |      2 |      4 |     119990 |         56765 |            47.31 |             132 |       278 |
| C_single_week_prices | TOTAL       |           6596 |          185 |          184 |            74 |              110 |             40.22 |     34 |     28 |      6 |     21 |     558847 |        263969 |            47.23 |             132 |       278 |
+----------------------+-------------+----------------+--------------+--------------+---------------+------------------+-------------------+--------+--------+--------+--------+------------+---------------+------------------+-----------------+-----------+
+---------------------+-------------+------+--------------+-----------------+--------------+----------+-------------------+-------------------+---------+-----------+------------+----------+-------------+---------------+
| q                   | dept_id     | n    | min_first_wk | median_first_wk | max_first_wk | at_11101 | gt52_before_11617 | le52_before_11617 | wb_0_50 | wb_51_104 | wb_105_208 | wb_gt208 | priced_lt52 | chk_gap_items |
+---------------------+-------------+------+--------------+-----------------+--------------+----------+-------------------+-------------------+---------+-----------+------------+----------+-------------+---------------+
| D_first_priced_week | FOODS_1     |  216 |        11101 |           11103 |        11451 |      101 |               216 |                 0 |       0 |         8 |         50 |      158 |           0 |             0 |
| D_first_priced_week | FOODS_2     |  398 |        11101 |           11104 |        11548 |      189 |               394 |                 4 |       4 |        37 |         85 |      272 |           4 |             0 |
| D_first_priced_week | FOODS_3     |  823 |        11101 |           11110 |        11603 |      338 |               819 |                 4 |       4 |        62 |        213 |      544 |           4 |             0 |
| D_first_priced_week | HOUSEHOLD_1 |  532 |        11101 |           11136 |        11531 |      162 |               531 |                 1 |       1 |        40 |        164 |      327 |           1 |             0 |
| D_first_priced_week | HOUSEHOLD_2 |  515 |        11101 |           11103 |        11510 |      220 |               515 |                 0 |       0 |        35 |        117 |      363 |           0 |             0 |
| D_first_priced_week | TOTAL       | 2484 |        11101 |           11109 |        11603 |     1010 |              2475 |                 9 |       9 |       182 |        629 |     1664 |           9 |             0 |
+---------------------+-------------+------+--------------+-----------------+--------------+----------+-------------------+-------------------+---------+-----------+------------+----------+-------------+---------------+
+---------------------------------+-------------+------+------+------+--------+--------+------------+------------+-----------+-----------+-----------+------------------+
| q                               | dept_id     | n    | nd4  | nd5  | nd_gt5 | max_nd | chg104_ge3 | chg104_ge2 | chg52_ge3 | chg52_ge2 | chg52_ge1 | chk_lit11513_ge3 |
+---------------------------------+-------------+------+------+------+--------+--------+------------+------------+-----------+-----------+-----------+------------------+
| E_distinct_and_F_recent_changes | FOODS_1     |  216 |   27 |    9 |     33 |     16 |         32 |         43 |         7 |        30 |        42 |               11 |
| E_distinct_and_F_recent_changes | FOODS_2     |  398 |   80 |   76 |     46 |      9 |         96 |        165 |         4 |        38 |       152 |                4 |
| E_distinct_and_F_recent_changes | FOODS_3     |  823 |  100 |   57 |     52 |      9 |         61 |        154 |         8 |        58 |       263 |               11 |
| E_distinct_and_F_recent_changes | HOUSEHOLD_1 |  532 |   43 |    9 |     11 |      7 |         24 |         80 |         0 |        27 |       124 |                1 |
| E_distinct_and_F_recent_changes | HOUSEHOLD_2 |  515 |   23 |   12 |      3 |      6 |         19 |         57 |         1 |        19 |        98 |                3 |
| E_distinct_and_F_recent_changes | TOTAL       | 2484 |  273 |  163 |    145 |     16 |        232 |        499 |        20 |       172 |       679 |               30 |
+---------------------------------+-------------+------+------+------+--------+--------+------------+------------+-----------+-----------+-----------+------------------+
```

### design_profile_04_NOTES.md (verbatim)

````markdown
# Design profiling 04: column legend and totals (PRICEPOINT-001 Stage 3, framework §25 targeted profiling)

Source: `design_profile_04.sql` (read-only aggregates; CTEs only; no CREATE/INSERT/temporary objects). Run on DESKTOP-RPECRM9 via mysql.exe `--login-path=chicago311 --database=pricepoint --table`, started 2026-09-25 04:42 CT, completed in 539.8 s (exit 0). Raw output (UTF-16, as written by PowerShell Tee-Object): `design_profile_04_output.txt`; UTF-8 copy (\r stripped): `design_profile_04_output_utf8.txt`.
First attempt failed (ERROR 1054, unknown column `n_days` in Q1: `sl.n_days` was not carried into CTE `t`). Failed SQL kept as `design_profile_04_fail1.sql`, failed output as `design_profile_04_output_fail1.txt` (+ `_utf8`). Fix = add `sl.n_days` to the `t` select list; nothing else changed.

Scope: store CA_1; depts FOODS_1, FOODS_2, FOODS_3, HOUSEHOLD_1, HOUSEHOLD_2 (2,484 items). Prices wm_yr_wk <= 11617. Sales last 365 days = JSON ordinal >= 1577 (d_1577..d_1941 = 2015-05-24..2016-05-22; chk_min_days = chk_max_days = 365 for every item).

## Definitions (as implemented)
- n_chg = count of weeks where price <> previous priced week's price (LAG over wm_yr_wk). nd = distinct prices (weeks <= 11617, current price included). priced_weeks = count of price rows <= 11617.
- units_365 / zero_days_365 = sum of units / count of zero days, d_1577..d_1941.
- **Last 52 weeks = the 52 distinct calendar wm_yr_wk values ending at 11617 (weeks 11518..11552 and 11601..11617), assigned by calendar ordinal.** The literal integer range 11566..11617 named in the task brief is NOT 52 weeks: wm_yr_wk jumps 11552 -> 11601, and the literal range contains only 17 calendar weeks (verified: 17 weeks, 2016-01-30..2016-05-27). Week 11617 contributes only 2 sales days (d_1940, d_1941). pos_wk52 = weeks with weekly units > 0.
- Event week = wm_yr_wk containing >= 1 day with event_type_1 in {National, Religious, Sporting, Cultural}. 132 of the 278 calendar weeks <= 11617 are event weeks.
- cur = week-11617 price. Candidate prices = distinct prices at weeks <= 11617, price <> cur, inside the inclusive band [0.80, 1.20] x cur ("20") or [0.75, 1.25] x cur ("25"). Event filter ("f") = also drop a price level that occurs in exactly one week when that week is an event week.
- E_A = n_chg >= 3 AND units_365 >= 180 AND zero_days_365 <= 182. E_B = nd >= 3 AND units_365 >= 180. E_C = n_chg >= 5 AND units_365 >= 365.

## Q1 (a) eligibility joint counts (+ (e) nd = 5 / > 5 among E_A)
Columns: n | e_a | ea_pw52 (E_A and priced_weeks >= 52) | ea_nd4 (E_A and nd >= 4) | ea_pos26 (E_A and pos_wk52 >= 26) | ea_pw52_nd4_pos26 | e_b | e_c | ea_pw52_c20f / ea_pw52_c25f (E_A, priced_weeks >= 52, >= 1 event-filtered candidate in the ±20% / ±25% band) | ea_pw52_c20 / ea_pw52_c25 (same, no event filter) | ea_nd5 | ea_ndgt5 | chk_min_days / chk_max_days.

| dept | n | E_A | +pw52 | +nd4 | +pos26 | +pw52+nd4+pos26 | E_B | E_C | +pw52+cand±20 f | +pw52+cand±25 f | E_A nd=5 | E_A nd>5 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FOODS_1 | 216 | 29 | 29 | 20 | 29 | 20 | 101 | 7 | 29 | 29 | 2 | 4 |
| FOODS_2 | 398 | 99 | 99 | 77 | 99 | 77 | 207 | 50 | 97 | 99 | 25 | 14 |
| FOODS_3 | 823 | 172 | 172 | 136 | 172 | 136 | 302 | 107 | 169 | 172 | 31 | 41 |
| HOUSEHOLD_1 | 532 | 61 | 61 | 39 | 61 | 39 | 146 | 13 | 59 | 60 | 7 | 9 |
| HOUSEHOLD_2 | 515 | 3 | 3 | 2 | 3 | 2 | 28 | 0 | 3 | 3 | 0 | 0 |
| TOTAL | 2,484 | 364 | 364 | 274 | 364 | 274 | 784 | 177 | 357 | 363 | 65 | 68 |

Arithmetic: E_A totals 29+99+172+61+3 = 364; E_B 784 and E_C 177 reproduce profile 02 exactly (cross-check passed). priced_weeks >= 52 and pos_wk52 >= 26 remove 0 E_A items (non-binding). nd >= 4 removes 364 - 274 = 90 E_A items. E_A items with nd = 4: 274 - 65 - 68 = 141. Candidate-exists without/with event filter gives identical item counts (357 at ±20%, 363 at ±25%); ±20% leaves 7 E_A items with no candidate (FOODS_2 2, FOODS_3 3, HOUSEHOLD_1 2), ±25% leaves 1 (HOUSEHOLD_1). Share of E_A with >= 1 candidate: 357/364 = 98.1% (±20%), 363/364 = 99.7% (±25%). Not computed: E_A AND nd >= 4 AND candidate-exists (bounded: 273 or 274, since only 1 E_A item lacks a ±25% candidate).

## Q2 (b) candidate-price count per E_A item (n = 364)
Columns k0..k5, k_gt5 = number of E_A items with 0..5 and > 5 candidate prices (before any cap); sum_capped5 = sum over items of min(k, 5).

| variant | k0 | k1 | k2 | k3 | k4 | k5 | >5 | n | sum min(k,5) |
|---|---|---|---|---|---|---|---|---|---|
| ±20%, no filter | 7 | 41 | 96 | 120 | 51 | 36 | 13 | 364 | 1,042 |
| ±20%, event filter | 7 | 44 | 96 | 119 | 49 | 36 | 13 | 364 | 1,034 |
| ±25%, no filter | 1 | 23 | 89 | 144 | 54 | 33 | 20 | 364 | 1,114 |
| ±25%, event filter | 1 | 27 | 88 | 143 | 52 | 33 | 20 | 364 | 1,105 |

Arithmetic: each row sums to 364. Event filter lowers the capped candidate total by 8 (±20%) and 9 (±25%) and changes no item's k0 status. The cap of 5 binds for 13 items (±20%) / 20 items (±25%). Per-dept rows are in the output.

## Q3 (c) single-week pre-origin price levels
Columns: n_price_levels (distinct item x price pairs, weeks <= 11617) | n_single_all (levels seen in exactly 1 week) | n_single_pre (same, week < 11617) | single_pre_ev / single_pre_nonev | pct_single_pre_ev | sp_nat/sp_rel/sp_spo/sp_cul (single_pre levels in weeks containing that event type; not exclusive) | item_weeks / item_weeks_ev / pct_itemweeks_ev (baseline: share of all item-week price rows in event weeks) | cal_event_weeks / cal_weeks.

| dept | levels | single (all) | single (<11617) | in event wk | non-event | % event | base % item-weeks in event wks |
|---|---|---|---|---|---|---|---|
| FOODS_1 | 786 | 21 | 21 | 15 | 6 | 71.43 | 47.26 |
| FOODS_2 | 1,453 | 32 | 32 | 12 | 20 | 37.50 | 47.23 |
| FOODS_3 | 2,166 | 47 | 47 | 16 | 31 | 34.04 | 47.24 |
| HOUSEHOLD_1 | 1,179 | 46 | 46 | 18 | 28 | 39.13 | 47.13 |
| HOUSEHOLD_2 | 1,012 | 39 | 38 | 13 | 25 | 34.21 | 47.31 |
| TOTAL | 6,596 | 185 | 184 | 74 | 110 | 40.22 | 47.23 |

Arithmetic: 74 + 110 = 184; 74/184 = 40.22%. Baseline 263,969/558,847 = 47.23% of item-weeks fall in event weeks (132/278 = 47.48% of calendar weeks). By type (non-exclusive): National 34, Religious 28, Sporting 6, Cultural 21. Under the original Design B filter (National or Religious only) at most 34 + 28 = 62 levels would be candidates for removal; adding Sporting/Cultural adds at most 27. Only FOODS_1 shows single-week levels concentrated in event weeks (71.43%); in total, single-week prices are not over-represented in event weeks relative to the 47.23% baseline. The one level with n_single_all but not n_single_pre (HOUSEHOLD_2) is a price seen only in week 11617.

## Q4 (d) first priced week per item
Columns: min/median/max first priced wm_yr_wk (median = lower median by row order) | at_11101 (first data week) | gt52 / le52 = first priced week more than / at most 52 calendar weeks before 11617 | wb_* = weeks-back buckets (0-50, 51-104, 105-208, > 208) | priced_lt52 | chk_gap_items (priced_weeks <> weeks_back + 1).

| dept | n | min | median | max | at 11101 | > 52 wks before 11617 | <= 52 | wb 0-50 | 51-104 | 105-208 | > 208 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| FOODS_1 | 216 | 11101 | 11103 | 11451 | 101 | 216 | 0 | 0 | 8 | 50 | 158 |
| FOODS_2 | 398 | 11101 | 11104 | 11548 | 189 | 394 | 4 | 4 | 37 | 85 | 272 |
| FOODS_3 | 823 | 11101 | 11110 | 11603 | 338 | 819 | 4 | 4 | 62 | 213 | 544 |
| HOUSEHOLD_1 | 532 | 11101 | 11136 | 11531 | 162 | 531 | 1 | 1 | 40 | 164 | 327 |
| HOUSEHOLD_2 | 515 | 11101 | 11103 | 11510 | 220 | 515 | 0 | 0 | 35 | 117 | 363 |
| TOTAL | 2,484 | 11101 | 11109 | 11603 | 1,010 | 2,475 | 9 | 9 | 182 | 629 | 1,664 |

Arithmetic: 9 + 182 + 629 + 1,664 = 2,484; 2,475 + 9 = 2,484. priced_lt52 = 9 (0/4/4/1/0) reproduces profile 02; chk_gap_items = 0 in every dept (no internal price gaps, consistent with profile 01 Q8).

## Q5 (e) distinct pre-origin prices, and (f) corrected recent-change counts
Columns: nd4 / nd5 / nd_gt5 = items with exactly 4 / exactly 5 / > 5 distinct prices (weeks <= 11617, current included) | max_nd | chg104_ge3 / chg104_ge2 = items with >= 3 / >= 2 changes in the last 104 calendar weeks (weeks_back 0..103) | chg52_ge3 / ge2 / ge1 = same for last 52 calendar weeks | chk_lit11513_ge3 = replication of profile 02 `wk >= 11617-104` rule.

| dept | n | nd=4 | nd=5 | nd>5 | max nd | >=3 chg last 104 wks | >=2 chg last 104 | >=3 chg last 52 | >=2 last 52 | >=1 last 52 | profile-02 literal rule |
|---|---|---|---|---|---|---|---|---|---|---|---|
| FOODS_1 | 216 | 27 | 9 | 33 | 16 | 32 | 43 | 7 | 30 | 42 | 11 |
| FOODS_2 | 398 | 80 | 76 | 46 | 9 | 96 | 165 | 4 | 38 | 152 | 4 |
| FOODS_3 | 823 | 100 | 57 | 52 | 9 | 61 | 154 | 8 | 58 | 263 | 11 |
| HOUSEHOLD_1 | 532 | 43 | 9 | 11 | 7 | 24 | 80 | 0 | 27 | 124 | 1 |
| HOUSEHOLD_2 | 515 | 23 | 12 | 3 | 6 | 19 | 57 | 1 | 19 | 98 | 3 |
| TOTAL | 2,484 | 273 | 163 | 145 | 16 | 232 | 499 | 20 | 172 | 679 | 30 |

Arithmetic: 273 + 163 + 145 = 581 = profile 03 nd4p (cross-check passed).
**Correction to profile 02:** profile 02 column `chg2y_ge3` ("changes in last 104 weeks >= 3", total 30) used `wk >= 11617-104` = wm_yr_wk >= 11513, which spans only 57 calendar weeks (2015-04-25..2016-05-27) because wm_yr_wk is not a contiguous integer. The replication column reproduces 30 exactly. Over the true last 104 calendar weeks the count is **232** (32/96/61/24/19). The profile 02 NOTES line "Items with >=3 price changes in last 104 weeks: 30" and statements derived from it (AI2-F10, AI2 cross-review §2 TE2 row: "n=30 would empty the review") rest on this arithmetic error. It does not change the recommendation to use lifetime n_chg >= 3, but "a recent-movement rule would empty the review" is not supported.

## Profile 02 NOTES correction (scope preference)
The profile 02 NOTES sentence "lands near the stakeholder's ~200-300 item intent" overstated the source. No stakeholder statement (T000-T040) gives an eligible-item target; the ~200-300 figure comes from the owner's project data briefing (context: "CA_1 FOODS_1+HOUSEHOLD_1 about 748 items exceeds intended ~200-300"). It is an owner-side scope preference to confirm at lock (AI2-F15 accepted).
````

---

## Profile 04 failed first attempt (kept per run protocol)

Failed SQL = design_profile_04_fail1.sql (identical to design_profile_04.sql except the CTE `t` select list lacked `sl.n_days`). Output:

```text
mysql.exe : ERROR 1054 (42S22) at line 10: Unknown column 'n_days' in 'field list'
At C:\Users\Mark\AppData\Local\Temp\ps-script-7b2c9156-0fa2-46f3-bf13-754417b00cdf.ps1:73 char:125
+ ... sql" -Raw | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (ERROR 1054 (42S...in 'field list':String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
```

## Hashes

```text
6f29d95edbb0cdd255068115b8ba0fe5f11c40c070df13571a0890c1f0675b10  design_profile_02.sql
da4f39517b5396b0d12feb0397a91de9c27cec53be0823f7ce5230384c509b30  design_profile_02_output.txt
d62bc1e8631011a4290e21c36ef354a0bc329588b162ff2dfcf9304072c892fd  design_profile_02_NOTES.md
999a850916e4111d7fdf801a35e1956a6061fbe7fa6e88dbfc24f1e0e9cf5fb7  design_profile_03.sql
4e73ef4480c16e3995fec7d175ab5161c2977e062fd46f98f2fb4c771c51996a  design_profile_03_output.txt
733db4f64781c728e94defeb36d184f4ddc2ef1be0355da38140c48b5a686bdc  design_profile_03_output_utf8.txt
924ba0b54b9f3416a6f4ae2e4e2f200d02c0e1afd48b85d5e0ef1bfc0821e725  design_profile_04.sql
f12e3c353be18ed5d276d9d142645c79d24b5fc0ee7b995df80d28983e4defc4  design_profile_04_fail1.sql
64c1e65ae2b0c2f72c664c6f8eeaffbc9fba3440283d38140bb4386e7b261915  design_profile_04_output.txt
2d45592a7cfbd4e71fba83084d48bbc4fba047596a5dbfa4892c051fdc77506d  design_profile_04_output_utf8.txt
d41aea858e41c4cadb2a0f08bb4c2103b43676dd77b09ed5e7257633c72f56bd  design_profile_04_output_fail1.txt
00a4a3c2208ab7ea35aa5c19240ddb5588d9c1be69ba32417a2f2bfce77bfe7e  design_profile_04_output_fail1_utf8.txt
c2f8bc9a095b3287b38c50f44206d2ef081f00fae914db4bcffa1c331bfbef16  design_profile_04_NOTES.md
47259bafa23dcf1e5a3249e6a4d57b59a27843ad6bfd26953386e296597e0926  design_profile_01.sql
647ce0f59b061f1c4e300bcf602581a9266ee008f69cd595f63f152e76dc77e4  design_profile_01_output.txt
42f59c7e9b1d13687c1e6774c07a1fa77b2708eeef68b10bae9f4de8b7585807  xreview/profile_01_output_utf8.txt
bd320167b8c92558732a65084ce0629a73ab40a3a55c1b712276d04c47d950df  xreview/profile_02_output_utf8.txt
```
