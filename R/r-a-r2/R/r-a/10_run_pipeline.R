#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(tidyverse)
  library(parsnip)
  library(recipes)
  library(glmnet)
  library(Matrix)
  library(workflows)
  library(tune)
  library(rsample)
  library(yardstick)
  library(jsonlite)
  library(digest)
})
source("R/r-a/functions.R", local = FALSE)

args <- parse_cli()
dir.create(args$out_dir, recursive = TRUE, showWarnings = FALSE)
lineage <- verify_extract_integrity(args$extract_dir)

src <- read_sources(args$extract_dir)
calendar_f <- calendar_features(src$calendar)

# Locked source/package invariants used by judged R path.
stopifnot(nrow(src$sales) == 4821444L)
stopifnot(dplyr::n_distinct(src$sales$item_id) == 2484L)
stopifnot(nrow(src$prices) == 568783L)
stopifnot(sum(src$prices$wm_yr_wk <= 11617L) == 558847L)
stopifnot(sum(src$prices$wm_yr_wk >= 11618L & src$prices$wm_yr_wk <= 11621L) == 9936L)
stopifnot(nrow(src$calendar) == 1969L)
stopifnot(dplyr::n_distinct(src$calendar$wm_yr_wk) == 282L)
stopifnot(sum(src$calendar$wm_yr_wk == 11621L) == 2L)
stopifnot(src$calendar$wday[src$calendar$date == as.Date("2016-05-21")] == 1L)

panel <- build_panel(src$sales, src$prices, calendar_f)
panel_with_trails <- compute_training_trails(panel)
levels <- factor_levels_from_calendar(calendar_f)

base <- build_universe_base(src$sales, src$prices, calendar_f, panel)
universe0 <- base$universe
candidates0 <- base$candidates
if (nrow(universe0) != 2484L) stop("Locked universe is not 2,484 rows")

# Primary d_1913 backtest is binding; d_1885 is stability-only.
primary_bt <- run_backtest_origin(
  src$sales, src$prices, calendar_f, panel, panel_with_trails,
  PP$backtest_origin_d, PP$backtest_current_week, levels
)
stability_bt <- run_backtest_origin(
  src$sales, src$prices, calendar_f, panel, panel_with_trails,
  PP$stability_origin_d, PP$stability_current_week, levels
)

# OC-5 Option A: TE6 is the usable slice. APE is diagnostic only.
live_te6_inputs <- compute_live_te6_inputs(src$sales, src$prices, calendar_f, panel)
te6_diag <- build_te6_diagnostics(live_te6_inputs, primary_bt$eval)
universe0 <- universe0 %>%
  select(-te6_usable_slice, -te6) %>%
  left_join(
    te6_diag$items %>% select(store_id, item_id, te6_usable_slice, te6, te6_ape_i),
    by = c("store_id", "item_id")
  ) %>%
  mutate(
    te6_usable_slice = replace_na(te6_usable_slice, 0L),
    te6 = replace_na(te6, 0L)
  ) %>%
  apply_trust_flags()

# Independent live Mode-A fit.
live_fit <- fit_mode_a(panel_with_trails, PP$origin_d, levels)

current_items <- universe0 %>%
  filter(!is.na(current_price), current_price > 0) %>%
  transmute(store_id, item_id, dept_id, scenario_price = current_price)
current_scores <- score_scenarios(
  live_fit$fit, current_items, calendar_f, panel, PP$origin_d,
  live_fit$item_stats, levels
)

candidate_items <- candidates0 %>%
  inner_join(universe0 %>% select(store_id, item_id, dept_id), by = c("store_id", "item_id")) %>%
  transmute(store_id, item_id, dept_id, scenario_price = candidate_price)
candidate_scores_raw <- score_scenarios(
  live_fit$fit, candidate_items, calendar_f, panel, PP$origin_d,
  live_fit$item_stats, levels
)

candidate_scored <- candidates0 %>%
  rename(scenario_price = candidate_price) %>%
  left_join(candidate_scores_raw, by = c("store_id", "item_id", "scenario_price")) %>%
  legalize_candidates(current_scores, PP$rho_min)

universe <- choose_actions(
  universe0, candidate_scored, current_scores,
  backtest_accept = primary_bt$backtest_accept
) %>%
  rank_capacity(PP$capacity_cap) %>%
  add_min_gain_diagnostic(primary_bt$dept_mae) %>%
  mutate(
    expectation_not_guarantee = 1L,
    backtest_accept = primary_bt$backtest_accept,
    action_twin_11616 = NA_character_,
    penalty_selected = live_fit$penalty_selected,
    penalty_grid_index = live_fit$penalty_grid_index,
    run_role = PP$run_role
  )

# T1's action construction is not fully specified in the supplied design; the required field is emitted as NA.
# This diagnostic field is not in receipt-v3 reconciliation_critical_fields and never changes a judged action.

# Attach TE6 department diagnostic.
universe <- universe %>%
  left_join(te6_diag$dept, by = "dept_id")

# Candidate output at item_id x candidate_price grain.
candidates <- candidate_scored %>%
  rename(candidate_price = scenario_price) %>%
  mutate(run_role = PP$run_role) %>%
  select(
    item_id, store_id, candidate_price, abs_log_dist, rank_in_cap,
    legal_change, guardrail_pass, cent_delta_rev,
    .pred_units_candidate, .pred_rev_candidate, delta_rev, unit_ratio,
    everything()
  )

# Add lineage to all judged CSV exports.
universe <- add_lineage(universe, lineage)
candidates <- add_lineage(candidates, lineage)

# Ensure exactly one action per universe row and locked vocabulary.
if (anyDuplicated(universe[c("store_id", "item_id")])) stop("Duplicate universe key")
if (any(!universe$action %in% c("raise", "cut", "unchanged", "hold_ne"))) stop("Invalid action vocabulary")
if (anyDuplicated(candidates[c("item_id", "candidate_price")])) stop("Duplicate candidate key")
if (any(candidates$rank_in_cap > 5L)) stop("Candidate cap exceeded")

sales_item_counts <- src$sales %>% count(store_id, item_id, name = "n_rows")
invalid_items <- union(
  unique(src$sales$item_id[src$sales$units < 0L | is.na(src$sales$units)]),
  unique(src$prices$item_id[src$prices$sell_price <= 0 | is.na(src$prices$sell_price)])
)

# Packet §5 requires audit.csv as one row of counts/flags. Per-origin and per-dept diagnostics are in model_validation.json.
audit <- tibble(
  run_role = PP$run_role,
  n_items_CA_1_total = n_distinct(src$sales$item_id[src$sales$store_id == "CA_1"]),
  n_after_dept_map = n_distinct(src$sales$item_id[src$sales$store_id == "CA_1" & src$sales$dept_id %in% PP$departments]),
  n_universe = nrow(universe),
  n_dropped_by_X1 = n_distinct(src$sales$item_id[src$sales$store_id != "CA_1"]),
  n_dropped_by_X2 = n_distinct(src$sales$item_id[src$sales$store_id == "CA_1" & !src$sales$dept_id %in% PP$departments]),
  n_dropped_by_X3 = sum(is.na(universe$current_price)),
  n_dropped_by_X4 = 0L,
  n_dropped_by_X5 = sum(sales_item_counts$n_rows != 1941L),
  n_dropped_by_X6 = length(invalid_items),
  n_e_chg3 = sum(universe$e_chg3),
  n_e_u180 = sum(universe$e_u180),
  n_e_z182 = sum(universe$e_z182),
  n_e_pw52 = sum(universe$e_pw52),
  n_e_cand = sum(universe$e_cand),
  n_te6_usable_slice = sum(universe$te6_usable_slice),
  n_te6 = sum(universe$te6),
  n_trust_eligible = sum(universe$trust_eligible),
  n_candidates_pre_event_filter = sum(universe$n_candidates_pre_event_filter),
  n_candidates_event_filtered = sum(universe$n_candidates_event_filtered),
  n_candidates_post_cap = nrow(candidates),
  n_price_0_01_weeks = sum(src$prices$wm_yr_wk <= PP$current_week & round(src$prices$sell_price * 100) == 1),
  n_feature_na_rows = live_fit$n_feature_na_rows,
  n_training_rows = live_fit$n_training_rows,
  penalty_selected = live_fit$penalty_selected,
  penalty_grid_index = live_fit$penalty_grid_index,
  n_floored_days_total = sum(universe$n_floored_days, na.rm = TRUE),
  n_horizon_days_scored_total = sum(universe$n_horizon_days_scored, na.rm = TRUE),
  backtest_accept = primary_bt$backtest_accept,
  backtest_A1_median_ape = primary_bt$A1_median_ape,
  backtest_A2_mean_signed_error = primary_bt$A2_mean_signed_error,
  backtest_n_usable_items = primary_bt$backtest_n_usable_items,
  backtest_n_U0_excluded = primary_bt$backtest_n_U0_excluded,
  n_legal_changes = sum(universe$legal_change, na.rm = TRUE),
  n_raise = sum(universe$action == "raise"),
  n_cut = sum(universe$action == "cut"),
  n_unchanged = sum(universe$action == "unchanged"),
  n_hold_ne = sum(universe$action == "hold_ne"),
  n_package = sum(universe$package_flag),
  n_below_line = sum(universe$below_line_flag)
) %>% add_lineage(lineage)

# Model-validation artifact: binding primary, stability-only origin, per-item A1/A2 records, dept MAE and TE6 diagnostics.
folds_to_df <- function(cuts) {
  tibble(fold = seq_along(cuts), start_d = vapply(cuts, `[[`, integer(1), 1L), end_d = vapply(cuts, `[[`, integer(1), 2L))
}
validation <- list(
  ml_mode = "A",
  primary = list(
    origin_d = PP$backtest_origin_d,
    current_week = PP$backtest_current_week,
    backtest_accept = primary_bt$backtest_accept,
    A1_median_ape = primary_bt$A1_median_ape,
    A2_mean_signed_error = primary_bt$A2_mean_signed_error,
    backtest_n_usable_items = primary_bt$backtest_n_usable_items,
    backtest_n_U0_excluded = primary_bt$backtest_n_U0_excluded,
    penalty_selected = primary_bt$fit$penalty_selected,
    penalty_grid_index = primary_bt$fit$penalty_grid_index,
    fold_cuts = folds_to_df(primary_bt$fit$fold_cuts),
    per_item = primary_bt$eval %>%
      transmute(item_id, dept_id, base_trust_at_o, stable_price, realized_units, usable,
                pred_units = .pred_units, ape, signed_error),
    dept_backtest_MAE_revenue = primary_bt$dept_mae
  ),
  stability = list(
    origin_d = PP$stability_origin_d,
    current_week = PP$stability_current_week,
    backtest_accept_reported_only = stability_bt$backtest_accept,
    A1_median_ape = stability_bt$A1_median_ape,
    A2_mean_signed_error = stability_bt$A2_mean_signed_error,
    backtest_n_usable_items = stability_bt$backtest_n_usable_items,
    backtest_n_U0_excluded = stability_bt$backtest_n_U0_excluded,
    penalty_selected = stability_bt$fit$penalty_selected,
    penalty_grid_index = stability_bt$fit$penalty_grid_index,
    fold_cuts = folds_to_df(stability_bt$fit$fold_cuts)
  ),
  live = list(
    origin_d = PP$origin_d,
    penalty_selected = live_fit$penalty_selected,
    penalty_grid_index = live_fit$penalty_grid_index,
    fold_cuts = folds_to_df(live_fit$fold_cuts)
  ),
  te6 = list(
    rule = "Option A: te6 = te6_usable_slice",
    per_item = universe %>% select(item_id, dept_id, te6_usable_slice, te6_ape_i, te6),
    te6_dept_median_ape = te6_diag$dept
  )
)

# Receipt-v3 reconciliation field coverage check.
critical_fields <- c(
  "item_id", "store_id", "n_price_changes_pre", "n_distinct_prices_pre", "priced_weeks_pre", "units_365", "zero_days_365",
  "e_chg3", "e_u180", "e_z182", "e_pw52", "e_cand", "te6", "trust_eligible", "current_price", "candidate_price", "n_candidates",
  "straddle_flag", "backtest_accept", "n_items_CA_1_total", "n_after_dept_map", "n_universe", "n_dropped_by_X1", "n_dropped_by_X2",
  "n_dropped_by_X3", "n_dropped_by_X4", "n_dropped_by_X5", "n_dropped_by_X6", "n_e_chg3", "n_e_u180", "n_e_z182", "n_e_pw52",
  "n_e_cand", "n_te6_usable_slice", "n_te6", "n_trust_eligible", "n_candidates_pre_event_filter", "n_candidates_event_filtered",
  "n_candidates_post_cap", "n_price_0_01_weeks", "n_feature_na_rows", "n_training_rows", "n_floored_days_total",
  "n_horizon_days_scored_total", "backtest_n_usable_items", "backtest_n_U0_excluded", "n_legal_changes", "n_raise", "n_cut", "n_unchanged",
  "n_hold_ne", "n_package", "n_below_line", "te6_usable_slice", "guardrail_pass", "legal_change", "cent_delta_rev", "action", "package_flag",
  "below_line_flag", "rank_among_qualifiers", "snapshot_id", "source_version", "observation_boundary_d", "observation_boundary_date", "design_id",
  "ml_mode", "fixture_pack_sha256", "sql_extract_sha256", "capacity_stance", ".pred_units_current", ".pred_units_candidate",
  ".pred_rev_current", ".pred_rev_candidate", "delta_rev"
)
covered <- union(union(names(universe), names(candidates)), names(audit))
missing_critical <- setdiff(critical_fields, covered)
if (length(missing_critical)) stop("Missing receipt-v3 reconciliation fields: ", paste(missing_critical, collapse = ", "))

# Deterministic output order.
universe <- universe %>% arrange(item_id)
candidates <- candidates %>% arrange(item_id, rank_in_cap, candidate_price)

readr::write_csv(universe, file.path(args$out_dir, "universe.csv"), na = "")
readr::write_csv(candidates, file.path(args$out_dir, "candidates.csv"), na = "")
readr::write_csv(audit, file.path(args$out_dir, "audit.csv"), na = "")
jsonlite::write_json(as.list(lineage), file.path(args$out_dir, "lineage.json"), auto_unbox = TRUE, pretty = TRUE)
jsonlite::write_json(validation, file.path(args$out_dir, "model_validation.json"), auto_unbox = TRUE, pretty = TRUE, na = "null", dataframe = "rows")
write_m2_attestation(file.path(args$out_dir, "m2_attestation.csv"), "R/r-a/functions.R")

message("R-A judged pipeline completed and exports written to: ", args$out_dir)
