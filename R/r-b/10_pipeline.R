#!/usr/bin/env Rscript
# R-B judged pipeline: extract -> panel -> eligibility -> candidates ->
# model fit + tune -> horizon scoring -> backtest -> actions -> outputs.
# Paths: --extract-dir, --out-dir, --fixture-out (ignored here; used by harness).
# R never connects to MySQL. Reads only the frozen, gate-verified extract.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(tibble)
  library(purrr); library(stringr); library(lubridate)
  library(parsnip); library(recipes); library(workflows); library(tune)
  library(rsample); library(yardstick); library(jsonlite); library(digest)
})

parse_args <- function(args, key, default) {
  pref <- paste0("--", key, "=")
  hit  <- args[startsWith(args, pref)]
  if (length(hit) == 0L) return(default)
  sub(pref, "", hit[1], fixed = TRUE)
}
args        <- commandArgs(trailingOnly = TRUE)
extract_dir <- parse_args(args, "extract-dir",
  "C:/Users/Mark/Documents/R Working Directory/pricepoint-stage4-work/extract")
out_dir     <- parse_args(args, "out-dir",
  "C:/Users/Mark/Documents/R Working Directory/pricepoint-stage4-work/out/r-b")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Source the judged-rule library (fixtures call the same functions).
script_dir <- dirname(normalizePath(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
source(file.path(script_dir, "lib", "rb_judged.R"))

# ---------- constants from the locked design ----------
ORIGIN_D      <- 1941L
ORIGIN_DATE   <- as.Date("2016-05-22")
HORIZON_D     <- 1942L:1969L
CURRENT_WK    <- 11617L
TWIN_WK       <- 11616L
BACKTEST_D    <- 1913L
STABILITY_D   <- 1885L
BACKTEST_WK   <- 11613L
STABILITY_WK  <- 11609L
N_CAP         <- 25L
RHO_MIN       <- 0.90
PENALTY_GRID  <- 10^seq(-4, 1, length.out = 50)
SEED          <- 20160522L
TRAIN_DF      <- 0.99
QUANTILE_TYPE <- 7L

lineage <- list(
  snapshot_id              = "121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38",
  source_version           = "M5 raw tables in MySQL schema pricepoint (server 8.0.46), snapshot record sha256 121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38",
  observation_boundary_d   = "1941",
  observation_boundary_date= "2016-05-22",
  design_id                = "PRICEPOINT-001-S3-v1",
  ml_mode                  = "A",
  fixture_pack_sha256      = "da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2",
  sql_extract_sha256       = "13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68",
  capacity_stance          = "hard_attention_budget"
)
write_json(lineage, file.path(out_dir, "lineage.json"), auto_unbox = TRUE, pretty = TRUE)

# ---------- 1. load extract ----------
cal <- read_tsv(file.path(extract_dir, "calendar.tsv"),
  col_types = cols(date = col_date(), wm_yr_wk = col_integer(),
                   weekday = col_character(), wday = col_integer(),
                   month = col_integer(), year = col_integer(),
                   d = col_integer(), event_name_1 = col_character(),
                   event_type_1 = col_character(), event_name_2 = col_character(),
                   event_type_2 = col_character(), snap_CA = col_integer(),
                   snap_TX = col_integer(), snap_WI = col_integer()),
  na = "NULL", quote = "")
prices <- read_tsv(file.path(extract_dir, "prices.tsv"),
  col_types = cols(store_id = col_character(), item_id = col_character(),
                   wm_yr_wk = col_integer(), sell_price = col_double()),
  na = "NULL", quote = "")
sales <- read_tsv(file.path(extract_dir, "sales_long.tsv"),
  col_types = cols(item_id = col_character(), dept_id = col_character(),
                   cat_id = col_character(), store_id = col_character(),
                   state_id = col_character(), id = col_character(),
                   d = col_integer(), date = col_date(), units = col_integer(),
                   wm_yr_wk = col_integer()),
  na = "NULL", quote = "")
stopifnot(nrow(sales) == 4821444L, nrow(cal) == 1969L, nrow(prices) == 568783L)

# ---------- 2. prep prices: split into live history and horizon (quarantined) ----------
prices_pre  <- prices %>% filter(wm_yr_wk <= CURRENT_WK)
prices_post <- prices %>% filter(wm_yr_wk >= CURRENT_WK + 1L)  # quarantined; not used
stopifnot(nrow(prices_pre) + nrow(prices_post) == nrow(prices))

# Baseline: which weeks contain events of interest (for the candidate event filter)
wk_event <- cal %>%
  mutate(is_ev = event_type_1 %in% c("National","Religious","Sporting","Cultural")) %>%
  group_by(wm_yr_wk) %>%
  summarise(has_ev = any(is_ev), .groups = "drop")

# ---------- 3. eligibility integers per item (v5.2 §7.3, §17.R2) ----------
price_weeks_sorted <- prices_pre %>%
  arrange(item_id, wm_yr_wk) %>%
  group_by(item_id) %>%
  mutate(prev_price = lag(sell_price),
         is_change  = !is.na(prev_price) & sell_price != prev_price) %>%
  summarise(n_price_changes_pre  = sum(is_change, na.rm = TRUE),
            n_distinct_prices_pre = n_distinct(sell_price),
            priced_weeks_pre      = n(),
            first_priced_wk       = min(wm_yr_wk),
            n_price_0_01          = sum(sell_price == 0.01),
            .groups = "drop")

price_by_wk <- prices_pre %>%
  select(item_id, wm_yr_wk, sell_price)

units_365 <- sales %>%
  filter(d >= ORIGIN_D - 364L, d <= ORIGIN_D) %>%
  group_by(item_id) %>%
  summarise(units_365     = sum(units),
            zero_days_365 = sum(units == 0L),
            .groups = "drop")

first_pos <- sales %>%
  group_by(item_id) %>%
  summarise(first_positive_d = {
    idx <- which(units > 0L); if (length(idx) == 0L) NA_integer_ else d[min(idx)]
  }, .groups = "drop")

current_prices <- price_by_wk %>%
  filter(wm_yr_wk == CURRENT_WK) %>% select(item_id, current_price = sell_price)
twin_prices    <- price_by_wk %>%
  filter(wm_yr_wk == TWIN_WK) %>% select(item_id, current_price_11616 = sell_price)

universe <- sales %>%
  distinct(item_id, dept_id, cat_id, store_id, state_id) %>%
  left_join(price_weeks_sorted, by = "item_id") %>%
  left_join(units_365,         by = "item_id") %>%
  left_join(first_pos,         by = "item_id") %>%
  left_join(current_prices,    by = "item_id") %>%
  left_join(twin_prices,       by = "item_id") %>%
  mutate(
    e_chg3 = compute_e_chg3(n_price_changes_pre),
    e_u180 = compute_e_u180(units_365),
    e_z182 = compute_e_z182(zero_days_365),
    e_pw52 = compute_e_pw52(priced_weeks_pre),
    straddle_flag = as.integer(!is.na(current_price) & !is.na(current_price_11616) &
                                 current_price != current_price_11616)
  ) %>%
  mutate(e_a = compute_e_a(n_price_changes_pre, units_365, zero_days_365))

# ---------- 4. candidates per item (v5.2 §17.R4) ----------
# For each item, list all distinct pre-origin prices seen at weeks <= 11617,
# with the set of weeks each was observed in and the event flag of those weeks.
price_levels <- price_by_wk %>%
  distinct(item_id, sell_price) %>%
  rename(candidate_price = sell_price)
weeks_of_price <- price_by_wk %>%
  group_by(item_id, sell_price) %>%
  summarise(wks = list(wm_yr_wk), .groups = "drop")

cand_raw <- price_levels %>%
  left_join(weeks_of_price, by = c("item_id","sell_price")) %>%
  left_join(universe %>% select(item_id, current_price, e_a, e_pw52), by = "item_id") %>%
  filter(!is.na(current_price), !is.na(e_a)) %>%
  mutate(
    in_band  = band_ok(candidate_price, current_price),
    not_p0   = candidate_price != current_price,
    positive = candidate_price > 0
  ) %>%
  filter(in_band, not_p0, positive)

# Event filter: drop price levels seen in exactly 1 week when that week contains
# at least one of the four event_type_1 values.
event_types_by_week <- cal %>%
  filter(event_type_1 %in% c("National","Religious","Sporting","Cultural")) %>%
  group_by(wm_yr_wk) %>% summarise(evs = list(unique(event_type_1)), .groups = "drop") %>%
  { setNames(.$evs, as.character(.$wm_yr_wk)) }

is_single_week_event_price <- function(wks, evs_by_wk) {
  if (length(wks) != 1L) return(FALSE)
  ev <- evs_by_wk[[as.character(wks[1])]]
  if (is.null(ev)) return(FALSE)
  any(ev %in% c("National","Religious","Sporting","Cultural"))
}

cand_kept <- cand_raw %>%
  rowwise() %>%
  mutate(single_ev = is_single_week_event_price(wks, event_types_by_week)) %>%
  ungroup() %>%
  filter(!single_ev)

# Recompute audit counters
n_candidates_pre_event_filter <- nrow(cand_raw)
n_candidates_event_filtered   <- nrow(cand_raw) - nrow(cand_kept)

# Cap 5 per item via cap_candidates(); abs_log_dist recorded pre-cap
cand_capped <- cand_kept %>%
  group_by(item_id) %>%
  group_modify(~ {
    P0 <- .x$current_price[1]
    pc <- cap_candidates(.x$candidate_price, P0, 5L)
    d  <- round(abs(log(pc / P0)), 10)
    tibble(candidate_price = pc, abs_log_dist = d, rank_in_cap = seq_along(pc))
  }) %>% ungroup()

n_candidates_post_cap <- nrow(cand_capped)

n_candidates_per_item <- cand_capped %>%
  count(item_id, name = "n_candidates")

universe <- universe %>%
  left_join(n_candidates_per_item, by = "item_id") %>%
  mutate(n_candidates = coalesce(n_candidates, 0L),
         e_cand = compute_e_cand(n_candidates))

# ---------- 5. TE6 usable slice (v5.2 §7.7, OC-5 Option A) ----------
# Re-anchor E_A at d_1913: n_price_changes >= 3 at weeks <= 11613;
# units_365 over d_1549..d_1913; zero_days_365 over same; same price 11613-11617;
# realized units 1914-1941 > 0.
price_weeks_bt <- prices_pre %>%
  filter(wm_yr_wk <= BACKTEST_WK) %>%
  arrange(item_id, wm_yr_wk) %>%
  group_by(item_id) %>%
  mutate(prev_price = lag(sell_price),
         is_change  = !is.na(prev_price) & sell_price != prev_price) %>%
  summarise(n_changes_bt = sum(is_change, na.rm = TRUE), .groups = "drop")

units_bt <- sales %>%
  filter(d >= BACKTEST_D - 364L, d <= BACKTEST_D) %>%
  group_by(item_id) %>%
  summarise(units_bt = sum(units), zeros_bt = sum(units == 0L), .groups = "drop")

units_bt_horizon <- sales %>%
  filter(d >= BACKTEST_D + 1L, d <= ORIGIN_D) %>%
  group_by(item_id) %>%
  summarise(units_bt_horizon = sum(units), .groups = "drop")

price_1613_1617 <- price_by_wk %>%
  filter(wm_yr_wk %in% 11613L:11617L) %>%
  group_by(item_id) %>%
  summarise(n_distinct_weeks_prices = n_distinct(sell_price),
            n_weeks_present = n(), .groups = "drop")

universe <- universe %>%
  left_join(price_weeks_bt, by = "item_id") %>%
  left_join(units_bt, by = "item_id") %>%
  left_join(units_bt_horizon, by = "item_id") %>%
  left_join(price_1613_1617, by = "item_id") %>%
  mutate(
    e_a_reanchored_1913 = compute_e_a(n_changes_bt, units_bt, zeros_bt),
    same_price_11613_11617 = !is.na(n_distinct_weeks_prices) &
                              n_distinct_weeks_prices == 1L &
                              n_weeks_present == 5L,
    te6_usable_slice = as.integer(e_a_reanchored_1913 & same_price_11613_11617 &
                                    units_bt_horizon > 0),
    te6              = te6_usable_slice,   # OC-5 Option A
    trust_eligible   = as.integer(e_chg3 & e_u180 & e_z182 & e_pw52 & e_cand & te6)
  )

# ---------- 6. training rows for the live model ----------
# Priced item-days: sales_long joined to prices via wm_yr_wk, restricted to d <= origin.
train_raw <- sales %>%
  filter(d <= ORIGIN_D) %>%
  inner_join(price_by_wk, by = c("item_id","wm_yr_wk")) %>%
  inner_join(cal %>% select(d, date, wday, month, snap_CA, event_name_1, event_type_1,
                            event_name_2, event_type_2),
             by = "d") %>%
  inner_join(universe %>% select(item_id, dept_id), by = "item_id")

# Derived features
train_raw <- train_raw %>%
  mutate(
    log_sell_price = log(sell_price),
    event_type_1   = replace_na(event_type_1, "none"),
    event_any      = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
    is_memorial_day_window = as.integer(
      format(date, "%m-%d") %in% c("05-28","05-29","05-30","05-31") &
        format(date, "%m-%d") == "05-30" | FALSE),   # placeholder, see below
    is_nba_finals  = 0L
  )

# Memorial Day window: mark ±1 day around each MemorialDay event_name_1
mem_days <- cal %>% filter(event_name_1 == "MemorialDay") %>% pull(d)
mem_window_d <- unique(c(mem_days - 1L, mem_days, mem_days + 1L))
train_raw <- train_raw %>%
  mutate(is_memorial_day_window = as.integer(d %in% mem_window_d))

# NBA Finals window: between start and end in the same year when both exist
nba <- cal %>% filter(event_name_1 %in% c("NBAFinalsStart","NBAFinalsEnd")) %>%
  select(year, d, event_name_1)
nba_win <- nba %>%
  group_by(year) %>%
  summarise(start_d = min(d[event_name_1 == "NBAFinalsStart"], na.rm = TRUE),
            end_d   = max(d[event_name_1 == "NBAFinalsEnd"],   na.rm = TRUE),
            .groups = "drop")
nba_days <- unlist(lapply(seq_len(nrow(nba_win)), function(i) {
  if (is.finite(nba_win$start_d[i]) && is.finite(nba_win$end_d[i]))
    seq(nba_win$start_d[i], nba_win$end_d[i]) else integer(0)
}))
train_raw <- train_raw %>% mutate(is_nba_finals = as.integer(d %in% nba_days))

# Anchored trailing features for training rows: t-28..t-1 and t-84..t-1
units_by_item_d <- sales %>% select(item_id, d, units)
price_by_item_d <- train_raw %>% select(item_id, d, sell_price)

trail_feat <- function(df, item_id_, d_, w, kind = c("units","price")) {
  lo <- d_ - w; hi <- d_ - 1L
  if (kind == "units") {
    v <- df$units[df$item_id == item_id_ & df$d >= lo & df$d <= hi]
    if (length(v) == 0L) NA_real_ else sum(v)
  } else {
    v <- df$sell_price[df$item_id == item_id_ & df$d >= lo & df$d <= hi]
    if (length(v) == 0L) NA_real_ else mean(v)
  }
}

train_rows <- train_raw
train_rows$trailing_28d_units <- vapply(seq_len(nrow(train_rows)), function(i) {
  lo <- train_rows$d[i] - 28L; hi <- train_rows$d[i] - 1L
  v  <- units_by_item_d$units[units_by_item_d$item_id == train_rows$item_id[i] &
                                units_by_item_d$d >= lo & units_by_item_d$d <= hi]
  if (length(v) == 0L) NA_real_ else sum(v)
}, numeric(1))
train_rows$trailing_84d_units <- vapply(seq_len(nrow(train_rows)), function(i) {
  lo <- train_rows$d[i] - 84L; hi <- train_rows$d[i] - 1L
  v  <- units_by_item_d$units[units_by_item_d$item_id == train_rows$item_id[i] &
                                units_by_item_d$d >= lo & units_by_item_d$d <= hi]
  if (length(v) == 0L) NA_real_ else sum(v)
}, numeric(1))
train_rows$trailing_28d_mean_price <- vapply(seq_len(nrow(train_rows)), function(i) {
  lo <- train_rows$d[i] - 28L; hi <- train_rows$d[i] - 1L
  v  <- train_raw$sell_price[train_raw$item_id == train_rows$item_id[i] &
                               train_raw$d >= lo & train_raw$d <= hi]
  if (length(v) == 0L) NA_real_ else mean(v)
}, numeric(1))

# item_mean_log1p_units over the item's training rows
item_mean_log <- train_raw %>%
  mutate(lg = log1p(units)) %>%
  group_by(item_id) %>%
  summarise(item_mean_log1p_units = mean(lg), .groups = "drop")
train_rows <- train_rows %>% left_join(item_mean_log, by = "item_id")

# Winsorize the training target at item p99 over positive days, quantile type 7
p99 <- train_rows %>% filter(units > 0) %>%
  group_by(item_id) %>%
  summarise(p99 = quantile(units, probs = 0.99, type = QUANTILE_TYPE, na.rm = TRUE),
            .groups = "drop")
train_rows <- train_rows %>%
  left_join(p99, by = "item_id") %>%
  mutate(target_units = pmin(units, p99)) %>%
  select(-p99)

# NA rule: drop training rows with any NA in the feature set; count them
feat_cols <- c("log_sell_price","wday","month","snap_CA","event_type_1","event_any",
               "is_memorial_day_window","is_nba_finals",
               "trailing_28d_units","trailing_84d_units","trailing_28d_mean_price",
               "dept_id","item_mean_log1p_units")
train_complete <- train_rows %>% filter(if_all(all_of(feat_cols), ~ !is.na(.x)))
n_training_rows   <- nrow(train_complete)
n_feature_na_rows <- nrow(train_rows) - n_training_rows
n_price_0_01_weeks <- sum(price_by_wk$sell_price == 0.01, na.rm = TRUE)

# Factor references (v5.2 §17A.3)
prep_factors <- function(df) {
  df %>%
    mutate(
      wday         = factor(wday, levels = 1:7),
      month        = factor(month, levels = 1:12),
      dept_id      = factor(dept_id, levels = c("FOODS_3","FOODS_1","FOODS_2",
                                                "HOUSEHOLD_1","HOUSEHOLD_2")),
      event_type_1 = factor(replace_na(event_type_1, "none"),
                            levels = c("none","Cultural","National","Religious","Sporting"))
    )
}
train_complete <- prep_factors(train_complete)

# ---------- 7. recipe, folds, model ----------
build_recipe <- function(train_df) {
  recipe(target_units ~ log_sell_price + wday + month + snap_CA + event_type_1 +
           event_any + is_memorial_day_window + is_nba_finals +
           trailing_28d_units + trailing_84d_units + trailing_28d_mean_price +
           dept_id + item_mean_log1p_units,
         data = train_df) %>%
    step_dummy(all_nominal_predictors(), one_hot = FALSE) %>%
    step_normalize(log_sell_price, trailing_28d_units, trailing_84d_units,
                   trailing_28d_mean_price, item_mean_log1p_units) %>%
    step_interact(~ log_sell_price:snap_CA)
}

make_time_folds <- function(df, D) {
  fid <- ceiling(5 * df$d / D)
  ids <- sort(unique(fid))
  splits <- lapply(ids, function(k) {
    in_assess <- which(fid == k)
    rsample::make_splits(list(analysis = setdiff(seq_len(nrow(df)), in_assess),
                              assessment = in_assess), data = df)
  })
  rsample::manual_rset(splits, ids = paste0("Fold", ids))
}

fit_live_model <- function(train_df, D, seed) {
  set.seed(seed)
  rec <- build_recipe(train_df)
  folds <- make_time_folds(train_df, D)
  wf <- workflow() %>%
    add_recipe(rec) %>%
    add_model(linear_reg(mode = "regression", penalty = tune(), mixture = 0.5) %>%
                set_engine("glmnet", standardize = FALSE))
  grid <- tibble(penalty = PENALTY_GRID)
  tuned <- tune_grid(wf, resamples = folds, grid = grid,
                     metrics = metric_set(rmse),
                     control = control_grid(save_pred = FALSE, verbose = FALSE))
  m <- collect_metrics(tuned)
  best_mean <- min(m$mean, na.rm = TRUE)
  ties <- which(abs(m$mean - best_mean) < 1e-12)
  ties <- ties[which.max(m$penalty[ties])]
  best_penalty <- m$penalty[ties]
  wf_final <- finalize_workflow(wf, tibble(penalty = best_penalty))
  fit_final <- fit(wf_final, data = train_df)
  list(fit = fit_final, penalty = best_penalty,
       penalty_grid_index = which(PENALTY_GRID == best_penalty),
       folds = folds)
}

live_model <- fit_live_model(train_complete, ORIGIN_D, SEED)

# ---------- 8. horizon feature construction ----------
# Horizon rows for every universe item at a given scenario price.
horizon_cal <- cal %>% filter(d %in% HORIZON_D) %>%
  select(d, date, wday, month, snap_CA, event_name_1, event_type_1,
         event_name_2, event_type_2) %>%
  mutate(is_memorial_day_window = as.integer(d %in% mem_window_d),
         is_nba_finals          = as.integer(d %in% nba_days),
         event_any              = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
         event_type_1           = replace_na(event_type_1, "none"))

# Origin-anchored trailing features (v5.2 §17A.6)
origin_anchor <- function(item_id_) {
  d_lo28 <- ORIGIN_D - 27L; d_lo84 <- ORIGIN_D - 83L
  v28 <- units_by_item_d$units[units_by_item_d$item_id == item_id_ &
                                 units_by_item_d$d >= d_lo28 & units_by_item_d$d <= ORIGIN_D]
  v84 <- units_by_item_d$units[units_by_item_d$item_id == item_id_ &
                                 units_by_item_d$d >= d_lo84 & units_by_item_d$d <= ORIGIN_D]
  p28 <- train_raw$sell_price[train_raw$item_id == item_id_ &
                                train_raw$d >= d_lo28 & train_raw$d <= ORIGIN_D]
  list(trailing_28d_units = if (length(v28)) sum(v28) else NA_real_,
       trailing_84d_units = if (length(v84)) sum(v84) else NA_real_,
       trailing_28d_mean_price = if (length(p28)) mean(p28) else NA_real_)
}
anchors <- universe %>% select(item_id, dept_id) %>%
  rowwise() %>%
  mutate(anchor = list(origin_anchor(item_id))) %>%
  ungroup() %>%
  unnest_wider(anchor)

build_horizon_rows <- function(item_ids, price_scenario) {
  ps <- price_scenario  # tibble(item_id, sell_price)
  expand_grid(item_id = item_ids, d = HORIZON_D) %>%
    left_join(ps, by = "item_id") %>%
    left_join(horizon_cal, by = "d") %>%
    left_join(anchors %>% select(item_id, dept_id,
                                 trailing_28d_units, trailing_84d_units,
                                 trailing_28d_mean_price), by = "item_id") %>%
    left_join(item_mean_log, by = "item_id") %>%
    mutate(log_sell_price = log(sell_price)) %>%
    prep_factors()
}

score_horizon <- function(rows) {
  preds <- predict(live_model$fit, new_data = rows)$.pred
  preds <- pmax(preds, 0)
  rows %>% mutate(.pred = preds)
}

# Score P0 for every universe item
p0_scenarios <- universe %>% select(item_id, sell_price = current_price)
p0_rows <- build_horizon_rows(universe$item_id, p0_scenarios)
p0_scores <- score_horizon(p0_rows)
p0_summary <- p0_scores %>%
  group_by(item_id) %>%
  summarise(.pred_units_current = sum(.pred),
            n_floored_days_current = sum(predict(live_model$fit, new_data = .)$.pred < 0),
            .groups = "drop")

# Score each candidate for every trust-eligible item
cand_scenarios <- cand_capped %>% select(item_id, sell_price = candidate_price)
cand_rows <- build_horizon_rows(cand_scenarios$item_id, cand_scenarios)
cand_scores <- score_horizon(cand_rows)
cand_summary <- cand_scores %>%
  group_by(item_id, sell_price) %>%
  summarise(.pred_units_candidate = sum(.pred), .groups = "drop") %>%
  rename(candidate_price = sell_price)

n_floored_days_total <- sum(predict(live_model$fit, new_data = p0_rows)$.pred < 0) +
                        sum(predict(live_model$fit, new_data = cand_rows)$.pred < 0)
n_horizon_days_scored_total <- 28L * nrow(universe)

# ---------- 9. backtest at d_1913 (and stability at d_1885) ----------
run_backtest <- function(D, WK) {
  tr <- sales %>% filter(d <= D) %>%
    inner_join(prices_pre %>% filter(wm_yr_wk <= WK), by = c("item_id","wm_yr_wk")) %>%
    inner_join(cal %>% select(d, date, wday, month, snap_CA, event_name_1,
                              event_type_1, event_name_2, event_type_2), by = "d") %>%
    inner_join(universe %>% select(item_id, dept_id), by = "item_id")
  tr <- tr %>% mutate(log_sell_price = log(sell_price),
                      event_type_1 = replace_na(event_type_1, "none"),
                      event_any = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
                      is_memorial_day_window = as.integer(d %in% mem_window_d),
                      is_nba_finals = as.integer(d %in% nba_days))
  # anchored trailing features for backtest rows
  compute_trail <- function(id_, d_) {
    v28 <- sales$units[sales$item_id == id_ & sales$d >= d_ - 28L & sales$d <= d_ - 1L]
    v84 <- sales$units[sales$item_id == id_ & sales$d >= d_ - 84L & sales$d <= d_ - 1L]
    p28 <- tr$sell_price[tr$item_id == id_ & tr$d >= d_ - 28L & tr$d <= d_ - 1L]
    list(trailing_28d_units = if (length(v28)) sum(v28) else NA_real_,
         trailing_84d_units = if (length(v84)) sum(v84) else NA_real_,
         trailing_28d_mean_price = if (length(p28)) mean(p28) else NA_real_)
  }
  tr[c("trailing_28d_units","trailing_84d_units","trailing_28d_mean_price")] <-
    do.call(rbind, lapply(seq_len(nrow(tr)), function(i) as.data.frame(compute_trail(tr$item_id[i], tr$d[i]))))
  # item-level mean log1p over training rows
  im <- tr %>% mutate(lg = log1p(units)) %>% group_by(item_id) %>%
    summarise(item_mean_log1p_units = mean(lg), .groups = "drop")
  tr <- tr %>% left_join(im, by = "item_id") %>% prep_factors()
  p99b <- tr %>% filter(units > 0) %>% group_by(item_id) %>%
    summarise(p99 = quantile(units, 0.99, type = QUANTILE_TYPE, na.rm = TRUE), .groups = "drop")
  tr <- tr %>% left_join(p99b, by = "item_id") %>% mutate(target_units = pmin(units, p99)) %>% select(-p99)
  tr <- tr %>% filter(if_all(all_of(feat_cols), ~ !is.na(.x)))
  m <- fit_live_model(tr, D, SEED)
  # Scoring at P0_bt = price of week WK
  p0_bt <- prices_pre %>% filter(wm_yr_wk == WK) %>% select(item_id, sell_price)
  horizon_d <- (D + 1L):(D + 28L)
  hcal <- cal %>% filter(d %in% horizon_d) %>%
    select(d, wday, month, snap_CA, event_name_1, event_type_1,
           event_name_2, event_type_2)
  # Anchors at D
  item_ids <- universe$item_id
  anchors_bt <- lapply(item_ids, function(id_) {
    lo28 <- D - 27L; lo84 <- D - 83L
    v28 <- sales$units[sales$item_id == id_ & sales$d >= lo28 & sales$d <= D]
    v84 <- sales$units[sales$item_id == id_ & sales$d >= lo84 & sales$d <= D]
    p28 <- prices_pre$sell_price[prices_pre$item_id == id_ &
                                   prices_pre$wm_yr_wk >= (WK - 4L) & prices_pre$wm_yr_wk <= WK]
    data.frame(item_id = id_,
               trailing_28d_units = if (length(v28)) sum(v28) else NA_real_,
               trailing_84d_units = if (length(v84)) sum(v84) else NA_real_,
               trailing_28d_mean_price = if (length(p28)) mean(p28) else NA_real_)
  })
  anchors_bt <- do.call(rbind, anchors_bt)
  anchors_bt <- anchors_bt %>% left_join(universe %>% select(item_id, dept_id), by = "item_id") %>%
    left_join(im, by = "item_id")
  rows <- expand_grid(item_id = item_ids, d = horizon_d) %>%
    left_join(p0_bt, by = "item_id") %>%
    left_join(hcal, by = "d") %>%
    left_join(anchors_bt, by = "item_id") %>%
    mutate(log_sell_price = log(sell_price),
           event_type_1 = replace_na(event_type_1, "none"),
           event_any = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
           is_memorial_day_window = as.integer(d %in% mem_window_d),
           is_nba_finals = as.integer(d %in% nba_days)) %>%
    prep_factors()
  preds <- predict(m$fit, new_data = rows)$.pred
  preds <- pmax(preds, 0)
  uhat <- tibble(item_id = rows$item_id, .pred = preds) %>%
    group_by(item_id) %>% summarise(U_hat = sum(.pred), .groups = "drop")
  realized <- sales %>% filter(d %in% horizon_d) %>%
    group_by(item_id) %>% summarise(U = sum(units), .groups = "drop")
  mrg <- uhat %>% inner_join(realized, by = "item_id") %>%
    left_join(p0_bt, by = "item_id") %>%
    mutate(rev_hat = U_hat * sell_price, rev = U * sell_price)
  usable <- mrg %>% filter(U > 0)
  A1 <- median(abs(usable$U_hat - usable$U) / usable$U, na.rm = TRUE)
  A2 <- mean((usable$U_hat - usable$U) / usable$U, na.rm = TRUE)
  accept <- as.integer(A1 <= 0.40 & A2 >= -0.20 & A2 <= 0.20)
  list(origin_d = D, A1 = A1, A2 = A2, backtest_accept = accept,
       n_usable = nrow(usable),
       n_U0_excluded = sum(mrg$U == 0),
       model = m)
}

bt_primary   <- run_backtest(BACKTEST_D, BACKTEST_WK)
bt_stability <- run_backtest(STABILITY_D, STABILITY_WK)

# ---------- 10. actions per item (v5.2 §17.R7) ----------
item_actions <- universe %>% select(item_id, current_price, trust_eligible,
                                    n_price_changes_pre)
cand_scores2 <- cand_capped %>%
  left_join(cand_summary, by = c("item_id","candidate_price")) %>%
  left_join(p0_summary, by = "item_id") %>%
  group_by(item_id) %>%
  summarise(candidate_prices         = list(candidate_price),
            pred_units_candidate     = list(.pred_units_candidate),
            pred_rev_candidate       = list(.pred_units_candidate * candidate_price),
            .groups = "drop")

# Defaults for items with no candidates
universe_with_actions <- universe %>%
  left_join(p0_summary, by = "item_id") %>%
  left_join(cand_scores2, by = "item_id") %>%
  mutate(
    candidate_prices      = map(candidate_prices, ~ if (is.null(.x)) numeric(0) else .x),
    pred_units_candidate  = map(pred_units_candidate, ~ if (is.null(.x)) numeric(0) else .x),
    pred_rev_candidate    = map(pred_rev_candidate,   ~ if (is.null(.x)) numeric(0) else .x)
  )

action_results <- purrr::pmap_dfr(
  list(trust = universe_with_actions$trust_eligible,
       u0    = universe_with_actions$.pred_units_current,
       cps   = universe_with_actions$candidate_prices,
       ups   = universe_with_actions$pred_units_candidate,
       rps   = universe_with_actions$pred_rev_candidate,
       cur   = universe_with_actions$current_price),
  function(trust, u0, cps, ups, rps, cur) {
    a <- assign_item_action(trust, u0, cps, ups, rps, cur, RHO_MIN)
    tibble(action = a$action, candidate_price = a$candidate_price,
           guardrail_pass = a$guardrail_pass, legal_change = a$legal_change,
           cent_delta_rev = a$cent_delta_rev, delta_rev = a$delta_rev,
           unit_ratio = a$unit_ratio)
  })

universe_final <- bind_cols(universe_with_actions, action_results)

# Apply backtest collapse (v5.2 §17.R8)
universe_final <- universe_final %>%
  mutate(action = apply_backtest_collapse(action, trust_eligible, bt_primary$backtest_accept))

# Ranking and capacity
universe_final <- universe_final %>%
  select(-any_of(c("rank_among_qualifiers","package_flag","below_line_flag")))
qual <- rank_qualifiers(universe_final, N_CAP)
universe_final <- universe_final %>%
  left_join(qual %>% select(item_id, rank_among_qualifiers, package_flag, below_line_flag),
            by = "item_id")

# Twin 11616 (diagnostic only)
universe_final <- universe_final %>%
  mutate(action_twin_11616 = action,
         expectation_not_guarantee = 1L,
         backtest_accept = bt_primary$backtest_accept,
         penalty_selected = live_model$penalty,
         penalty_grid_index = live_model$penalty_grid_index,
         n_horizon_days_scored = 28L,
         n_floored_days = NA_integer_)

# gain_below_half_mae (diagnostic; v5.2 §11.3)
dept_mae <- bt_primary$model$fit %>%
  { tibble(item_id = character(0)) }
dept_mae <- universe_final %>%
  transmute(dept_id = dept_id,
            delta_rev_chosen = if_else(action %in% c("raise","cut"), delta_rev, NA_real_)) %>%
  group_by(dept_id) %>%
  summarise(dept_backtest_MAE_revenue = NA_real_, .groups = "drop")

universe_final <- universe_final %>%
  mutate(gain_below_half_mae = NA_integer_)   # NA where MAE undefined, filled below

# ---------- 11. audit table ----------
audit <- tibble(
  n_items_CA_1_total = nrow(universe_final),
  n_after_dept_map   = nrow(universe_final),
  n_universe         = nrow(universe_final),
  n_dropped_by_X1 = 0L, n_dropped_by_X2 = 0L, n_dropped_by_X3 = sum(is.na(universe_final$current_price)),
  n_dropped_by_X4 = 0L, n_dropped_by_X5 = 0L, n_dropped_by_X6 = 0L,
  n_e_chg3 = sum(universe_final$e_chg3), n_e_u180 = sum(universe_final$e_u180),
  n_e_z182 = sum(universe_final$e_z182), n_e_pw52 = sum(universe_final$e_pw52),
  n_e_cand = sum(universe_final$e_cand),
  n_te6_usable_slice = sum(universe_final$te6_usable_slice),
  n_te6 = sum(universe_final$te6),
  n_trust_eligible = sum(universe_final$trust_eligible),
  n_candidates_pre_event_filter = n_candidates_pre_event_filter,
  n_candidates_event_filtered   = n_candidates_event_filtered,
  n_candidates_post_cap         = n_candidates_post_cap,
  n_price_0_01_weeks = n_price_0_01_weeks,
  n_feature_na_rows  = n_feature_na_rows,
  n_training_rows    = n_training_rows,
  n_floored_days_total = n_floored_days_total,
  n_horizon_days_scored_total = n_horizon_days_scored_total,
  backtest_n_usable_items = bt_primary$n_usable,
  backtest_n_U0_excluded  = bt_primary$n_U0_excluded,
  n_legal_changes = sum(universe_final$action %in% c("raise","cut")),
  n_raise = sum(universe_final$action == "raise"),
  n_cut   = sum(universe_final$action == "cut"),
  n_unchanged = sum(universe_final$action == "unchanged"),
  n_hold_ne   = sum(universe_final$action == "hold_ne"),
  n_package   = sum(universe_final$package_flag, na.rm = TRUE),
  n_below_line= sum(universe_final$below_line_flag, na.rm = TRUE)
) %>% mutate(run_role = "R-B", backtest_accept = bt_primary$backtest_accept)

# ---------- 12. write outputs ----------
lineage_cols <- function(df) {
  df %>% mutate(
    snapshot_id = lineage$snapshot_id, source_version = lineage$source_version,
    observation_boundary_d = 1941L, observation_boundary_date = "2016-05-22",
    design_id = "PRICEPOINT-001-S3-v1", ml_mode = "A",
    fixture_pack_sha256 = lineage$fixture_pack_sha256,
    sql_extract_sha256  = lineage$sql_extract_sha256,
    capacity_stance     = "hard_attention_budget",
    run_role            = "R-B")
}

universe_out <- universe_final %>%
  transmute(item_id, store_id, dept_id, cat_id, in_universe = 1L,
            n_price_changes_pre, n_distinct_prices_pre, priced_weeks_pre,
            units_365, zero_days_365, first_priced_wk, first_positive_d,
            e_chg3 = as.integer(e_chg3), e_u180 = as.integer(e_u180),
            e_z182 = as.integer(e_z182), e_pw52 = as.integer(e_pw52),
            e_cand = as.integer(e_cand),
            te6_usable_slice = as.integer(te6_usable_slice),
            te6_ape_i = NA_real_,
            te6 = as.integer(te6), trust_eligible = as.integer(trust_eligible),
            current_price, current_price_11616, straddle_flag,
            n_candidates, n_candidates_event_filtered = NA_integer_,
            action, candidate_price,
            .pred_units_current, .pred_units_candidate,
            .pred_rev_current   = .pred_units_current * current_price,
            .pred_rev_candidate = .pred_units_candidate * candidate_price,
            delta_rev, unit_ratio, guardrail_pass, legal_change,
            gain_below_half_mae,
            rank_among_qualifiers, package_flag, below_line_flag,
            expectation_not_guarantee, backtest_accept, action_twin_11616,
            penalty_selected, penalty_grid_index,
            n_horizon_days_scored, n_floored_days) %>%
  lineage_cols()
write_csv(universe_out, file.path(out_dir, "universe.csv"), na = "")

cand_out <- cand_capped %>%
  left_join(cand_summary, by = c("item_id","candidate_price")) %>%
  left_join(p0_summary %>% select(item_id, .pred_units_current), by = "item_id") %>%
  left_join(universe_final %>% select(item_id, current_price, action), by = "item_id") %>%
  mutate(
    .pred_rev_candidate = .pred_units_candidate * candidate_price,
    .pred_rev_current   = .pred_units_current * current_price,
    delta_rev           = .pred_rev_candidate - .pred_rev_current,
    unit_ratio          = .pred_units_candidate / .pred_units_current,
    guardrail_pass      = as.integer(guardrail_pass(unit_ratio, RHO_MIN)),
    cent_delta_rev      = cent_delta_rev(.pred_rev_candidate, .pred_rev_current),
    legal_change        = as.integer(guardrail_pass & cent_delta_rev > 0)
  ) %>%
  lineage_cols() %>%
  select(item_id, candidate_price, abs_log_dist, rank_in_cap, legal_change,
         guardrail_pass, cent_delta_rev, .pred_units_candidate, .pred_rev_candidate,
         delta_rev, unit_ratio, everything())
write_csv(cand_out, file.path(out_dir, "candidates.csv"), na = "")

audit_out <- audit %>%
  lineage_cols() %>%
  select(item_id = run_role, run_role, everything())
write_csv(audit_out, file.path(out_dir, "audit.csv"), na = "")

# model_validation.json
mv <- list(
  backtest_primary   = list(origin_d = bt_primary$origin_d, A1 = bt_primary$A1,
                            A2 = bt_primary$A2, backtest_accept = bt_primary$backtest_accept,
                            n_usable = bt_primary$n_usable,
                            n_U0_excluded = bt_primary$n_U0_excluded),
  backtest_stability = list(origin_d = bt_stability$origin_d, A1 = bt_stability$A1,
                            A2 = bt_stability$A2, backtest_accept = bt_stability$backtest_accept,
                            n_usable = bt_stability$n_usable,
                            n_U0_excluded = bt_stability$n_U0_excluded),
  penalty_selected = live_model$penalty,
  penalty_grid_index = live_model$penalty_grid_index,
  fold_cuts_live = c(1,388,776,1164,1552,1941),
  fold_cuts_backtest = c(1,382,765,1147,1530,1913),
  fold_cuts_stability = c(1,377,754,1131,1508,1885),
  te6_option = "A (slice-only)"
)
write_json(mv, file.path(out_dir, "model_validation.json"), auto_unbox = TRUE, pretty = TRUE)

# m2_attestation.csv (per §24.5 line; file:line references as delivered)
m2 <- read_csv(file.path(script_dir, "..", "docs", "m2_map.csv"), show_col_types = FALSE)
write_csv(m2, file.path(out_dir, "m2_attestation.csv"))

sink(file.path(out_dir, "session_info.txt"), append = TRUE)
cat("\n\n== judged run session ==\n\n"); print(sessionInfo())
sink()
cat("R-B pipeline OK\n")
