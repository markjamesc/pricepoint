-- PRICEPOINT-001 / validation/source-gate/02_raw_item_json.sql
-- Per-item JSON sum + position-hash for §21 items 4 and 19. All 2,484 items.
-- Serialization: pos=<ordinal>;u=<int>\n with ordinal = JSON_TABLE 1-based
-- (same integer as delivered d).

SET SESSION max_execution_time = 0;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;
SET SESSION group_concat_max_len = 1048576;

SELECT
  TRIM(s.item_id) AS item_id,
  CAST(SUM(jt.u) AS SIGNED) AS json_units_sum,
  SHA2(
    GROUP_CONCAT(
      CONCAT('pos=', jt.pos, ';u=', jt.u, '\n')
      ORDER BY jt.pos
      SEPARATOR ''
    ),
    256
  ) AS json_pos_sha256,
  MIN(jt.pos) AS min_pos,
  MAX(jt.pos) AS max_pos,
  COUNT(*)    AS n_pos,
  MAX(CASE WHEN jt.pos = 1    THEN jt.u END) AS u_pos1,
  MAX(CASE WHEN jt.pos = 1941 THEN jt.u END) AS u_pos1941
FROM raw_sales_evaluation AS s
INNER JOIN JSON_TABLE(
             s.sales_history,
             '$[*]' COLUMNS (
               pos FOR ORDINALITY,
               u INT PATH '$' ERROR ON ERROR
             )
           ) AS jt
WHERE TRIM(s.store_id) = 'CA_1'
  AND TRIM(s.dept_id) IN (
        'FOODS_1', 'FOODS_2', 'FOODS_3',
        'HOUSEHOLD_1', 'HOUSEHOLD_2'
      )
GROUP BY TRIM(s.item_id)
ORDER BY item_id;
