# Stage 2 Framing: feasibility and bounded-extract answer (PRICEPOINT-001)

Method: one read-only aggregate query against `pricepoint` (mysql CLI, --login-path=chicago311), with no writes and no staging objects. The query and output are saved on the PC at `artifacts/framing/feasibility_probe_01.sql` and `feasibility_probe_01_output.txt` (run 2026-09-25 ~03:40 CT).

Findings at store CA_1 (the candidate pilot store):

| Dept | Items | Any price change | 4+ distinct prices | Avg priced weeks |
|---|---:|---:|---:|---:|
| FOODS_1 | 216 | 180 | 69 | 241.5 |
| FOODS_2 | 398 | 363 | 202 | 228.0 |
| FOODS_3 | 823 | 583 | 209 | 226.9 |
| HOUSEHOLD_1 | 532 | 367 | 63 | 220.1 |
| HOUSEHOLD_2 | 515 | 310 | 38 | 237.0 |

- All CA_1 grocery/household items have price rows. Price weeks run 11101 to 11621.
- The history cut is d_1941 = 2016-05-22 (wm_yr_wk 11617). The 28-day horizon is d_1942–d_1969 (2016-05-23 to 2016-06-19, weeks 11617–11621).

Answer: the data can support the question at the product × pilot-store grain. There is real price variation across many items (for example, FOODS_1 + HOUSEHOLD_1 has 748 items, of which 547 had at least one price change and 132 had four or more distinct prices), which is what Morgan's eligibility principle needs. A bounded extract is feasible. For one store and the chosen departments, that is roughly 1.5M item-day sales rows after pivot and under 200k price rows, well within R memory.

Stage 3 must address:
1. The eligibility cutoffs and department mapping. Candidate counts differ a lot by department.
2. `raw_sell_prices` contains prices for horizon weeks 11617–11621, which is AFTER the decision date. Using them would be look-ahead. The extract or design must bound price history at the decision date, apart from the current price in effect at the decision date.
3. Horizon sales (d_1942–d_1969) are not in the evaluation file used for training. Any backtest must use an earlier pseudo-decision date.

No KPI, threshold, or model is locked here.
