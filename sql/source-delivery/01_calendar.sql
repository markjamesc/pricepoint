-- PRICEPOINT-001 / sql/source-delivery/01_calendar.sql
-- Mechanical CALENDAR extract. SELECT-only. One result set.
-- Locked cardinality: 1,969 rows (§20.1, §21 item 9).
-- Casts: §20.3. TRIM + blank events → NULL.

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

SELECT
  CAST(TRIM(c.`date`) AS DATE)                         AS `date`,
  CAST(TRIM(c.wm_yr_wk) AS UNSIGNED)                   AS wm_yr_wk,
  NULLIF(TRIM(c.weekday), '')                          AS weekday,
  CAST(TRIM(c.wday) AS UNSIGNED)                       AS wday,
  CAST(TRIM(c.`month`) AS UNSIGNED)                    AS `month`,
  CAST(TRIM(c.`year`) AS UNSIGNED)                     AS `year`,
  CAST(SUBSTRING(TRIM(c.d), 3) AS UNSIGNED)            AS d,
  NULLIF(TRIM(c.event_name_1), '')                     AS event_name_1,
  NULLIF(TRIM(c.event_type_1), '')                     AS event_type_1,
  NULLIF(TRIM(c.event_name_2), '')                     AS event_name_2,
  NULLIF(TRIM(c.event_type_2), '')                     AS event_type_2,
  CAST(TRIM(c.snap_CA) AS UNSIGNED)                    AS snap_CA,
  CAST(TRIM(c.snap_TX) AS UNSIGNED)                    AS snap_TX,
  CAST(TRIM(c.snap_WI) AS UNSIGNED)                    AS snap_WI
FROM raw_calendar AS c
ORDER BY d;
