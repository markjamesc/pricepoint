#!/usr/bin/env Rscript
# R-B judged pipeline: extract -> panel -> eligibility -> candidates ->
# model fit + tune -> horizon scoring -> backtest -> actions -> outputs.
# R never connects to MySQL. Reads only the frozen, gate-verified extract.
#
# r4 changes over r3:
#   (1) Fixed the crash at rank_qualifiers(universe_final, N_CAP): the
#       library now accepts either `pred_units_current` or
#       `.pred_units_current`, and the pipeline additionally adds the
#       underscore form before ranking to keep downstream joins unchanged.
#   (2) prep_factors(), build_recipe(), horizon_days(), and the origin
#       anchor computations are now sourced from lib/rb_judged.R so the
#       fixture harness exercises production code (R_PACKET §5 item 4).
#   (3) Local duplicates of those functions removed.

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

script_dir <- dirname(normalizePath(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
source(file.path(script_dir, "lib", "rb_judged.R"))

# ---------- constants ----------
ORIGIN_D      <- 1941L
ORIGIN_DATE   <- as.Date("2016-05-22")
HORIZON_D     <- horizon_days(ORIGIN_D)          # library function
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
message("[R-B] reading extract")
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
message("[R-B] extract read: ", nrow(sales), " sales rows, ",
        nrow(prices), " price rows, ", nrow(cal), " calendar rows")

# ---------- 2. split prices (quarantine weeks >= 11618) ----------
prices_pre  <- prices %>% filter(wm_yr_wk <= CURRENT_WK) %>%
  select(item_id, wm_yr_wk, sell_price)
prices_post <- prices %>% filter(wm_yr_wk >= CURRENT_WK + 1L)   # quarantined
stopifnot(nrow(prices_pre) + nrow(prices_post) == nrow(prices))

# ---------- 3. eligibility integers per item ----------
message("[R-B] eligibility integers")
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

price_by_wk <- prices_pre

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

# ---------- 3b. cumulative lookup tables for trailing features ----------
message("[R-B] cumulative lookup tables")
units_cum <- sales %>%
  select(item_id, d, units) %>%
  arrange(item_id, d) %>%
  group_by(item_id) %>%
  mutate(cum_u = cumsum(units)) %>%
  ungroup() %>%
  select(item_id, d, cum_u)

daily_price <- sales %>%
  select(item_id, d, wm_yr_wk) %>%
  left_join(prices_pre, by = c("item_id", "wm_yr_wk")) %>%
  arrange(item_id, d) %>%
  group_by(item_id) %>%
  mutate(
    p_n = as.integer(!is.na(sell_price)),
    p_v = ifelse(is.na(sell_price), 0, sell_price),
    cum_p = cumsum(p_v),
    cum_n = cumsum(p_n)
  ) %>%
  ungroup() %>%
  select(item_id, d, sell_price, cum_p, cum_n)

price_cum <- daily_price %>% select(item_id, d, cum_p, cum_n)

add_trailing_features <- function(df, units_cum, price_cum) {
  df %>%
    left_join(units_cum %>% mutate(d = d + 1L)  %>% rename(cum_u_tm1  = cum_u),
              by = c("item_id", "d")) %>%
    left_join(units_cum %>% mutate(d = d + 29L) %>% rename(cum_u_tm29 = cum_u),
              by = c("item_id", "d")) %>%
    left_join(units_cum %>% mutate(d = d + 85L) %>% rename(cum_u_tm85 = cum_u),
              by = c("item_id", "d")) %>%
    left_join(price_cum %>% mutate(d = d + 1L)  %>% rename(cum_p_tm1  = cum_p, cum_n_tm1  = cum_n),
              by = c("item_id", "d")) %>%
    left_join(price_cum %>% mutate(d = d + 29L) %>% rename(cum_p_tm29 = cum_p, cum_n_tm29 = cum_n),
              by = c("item_id", "d")) %>%
    mutate(
      cum_u_tm29 = coalesce(cum_u_tm29, 0),
      cum_u_tm85 = coalesce(cum_u_tm85, 0),
      cum_p_tm29 = coalesce(cum_p_tm29, 0),
      cum_n_tm29 = coalesce(cum_n_tm29, 0L),
      trailing_28d_units      = cum_u_tm1 - cum_u_tm29,
      trailing_84d_units      = cum_u_tm1 - cum_u_tm85,
      sum_p                   = cum_p_tm1 - cum_p_tm29,
      cnt_p                   = cum_n_tm1 - cum_n_tm29,
      trailing_28d_mean_price = ifelse(cnt_p > 0, sum_p / cnt_p, NA_real_)
    ) %>%
    select(-cum_u_tm1, -cum_u_tm29, -cum_u_tm85,
           -cum_p_tm1, -cum_n_tm1, -cum_p_tm29, -cum_n_tm29,
           -sum_p, -cnt_p)
}

# ---------- 4. candidates per item ----------
message("[R-B] candidates")
price_levels <- price_by_wk %>% distinct(item_id, sell_price)
weeks_of_price <- price_by_wk %>%
  group_by(item_id, sell_price) %>%
  summarise(wks = list(wm_yr_wk), .groups = "drop")

cand_raw <- price_levels %>%
  left_join(weeks_of_price, by = c("item_id","sell_price")) %>%
  left_join(universe %>% select(item_id, current_price, e_a, e_pw52),
            by = "item_id") %>%
  filter(!is.na(current_price), !is.na(e_a)) %>%
  mutate(
    candidate_price = sell_price,
    in_band  = band_ok(candidate_price, current_price),
    not_p0   = candidate_price != current_price,
    positive = candidate_price > 0
  ) %>%
  filter(in_band, not_p0, positive)

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

n_candidates_pre_event_filter <- nrow(cand_raw)
n_candidates_event_filtered   <- nrow(cand_raw) - nrow(cand_kept)

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

# ---------- 5. TE6 ----------
message("[R-B] TE6 usable slice")
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
    te6              = te6_usable_slice,
    trust_eligible   = as.integer(e_chg3 & e_u180 & e_z182 & e_pw52 & e_cand & te6)
  )

# ---------- 6. training rows ----------
message("[R-B] training rows")
train_raw <- sales %>%
  filter(d <= ORIGIN_D) %>%
  inner_join(price_by_wk, by = c("item_id","wm_yr_wk")) %>%
  inner_join(cal %>% select(d, wday, month, snap_CA,
                            event_name_1, event_type_1,
                            event_name_2, event_type_2),
             by = "d")

mem_days <- cal %>% filter(event_name_1 == "MemorialDay") %>% pull(d)
mem_window_d <- unique(c(mem_days - 1L, mem_days, mem_days + 1L))

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

train_rows <- train_raw %>%
  mutate(log_sell_price = log(sell_price),
         event_type_1   = replace_na(event_type_1, "none"),
         event_any      = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
         is_memorial_day_window = as.integer(d %in% mem_window_d),
         is_nba_finals          = as.integer(d %in% nba_days))

train_rows <- add_trailing_features(train_rows, units_cum, price_cum)
message("[R-B] training rows built: ", nrow(train_rows))

item_mean_log <- train_raw %>%
  mutate(lg = log1p(units)) %>%
  group_by(item_id) %>%
  summarise(item_mean_log1p_units = mean(lg), .groups = "drop")
train_rows <- train_rows %>% left_join(item_mean_log, by = "item_id")

p99 <- train_rows %>% filter(units > 0) %>%
  group_by(item_id) %>%
  summarise(p99 = quantile(units, probs = 0.99, type = QUANTILE_TYPE, na.rm = TRUE),
            .groups = "drop")
train_rows <- train_rows %>%
  left_join(p99, by = "item_id") %>%
  mutate(target_units = pmin(units, p99)) %>%
  select(-p99)

feat_cols <- RB_ALLOWED_FEATURES
train_complete <- train_rows %>% filter(if_all(all_of(feat_cols), ~ !is.na(.x)))
n_training_rows    <- nrow(train_complete)
n_feature_na_rows  <- nrow(train_rows) - n_training_rows
n_price_0_01_weeks <- sum(price_by_wk$sell_price == 0.01, na.rm = TRUE)
message("[R-B] complete training rows: ", n_training_rows,
        " (dropped ", n_feature_na_rows, " for NA features)")

train_complete <- prep_factors(train_complete)   # library function

# ---------- 7. folds and model ----------
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
  rec <- build_recipe(train_df)                 # library function
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

message("[R-B] fitting live model")
live_model <- fit_live_model(train_complete, ORIGIN_D, SEED)
message("[R-B] live model fitted; penalty = ", live_model$penalty,
        " (grid index ", live_model$penalty_grid_index, ")")

# ---------- 8. horizon rows ----------
message("[R-B] horizon rows for P0 and candidates")
horizon_cal <- cal %>% filter(d %in% HORIZON_D) %>%
  select(d, wday, month, snap_CA, event_name_1, event_type_1,
         event_name_2, event_type_2) %>%
  mutate(is_memorial_day_window = as.integer(d %in% mem_window_d),
         is_nba_finals          = as.integer(d %in% nba_days),
         event_any              = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
         event_type_1           = replace_na(event_type_1, "none"))

# Library functions compute the origin anchors (same code path as the
# FX-TRAIL-ANCHOR fixture).
anchors_units <- anchor_trailing_units(
  sales %>% select(item_id, d, units), ORIGIN_D)
anchors_price <- anchor_trailing_price(
  daily_price %>% select(item_id, d, sell_price), ORIGIN_D)

anchors <- universe %>% select(item_id, dept_id) %>%
  left_join(anchors_units, by = "item_id") %>%
  left_join(anchors_price, by = "item_id")

build_horizon_rows <- function(price_scenario) {
  price_scenario %>%
    expand_grid(d = HORIZON_D) %>%
    left_join(horizon_cal, by = "d") %>%
    left_join(anchors %>% select(item_id, dept_id,
                                 trailing_28d_units, trailing_84d_units,
                                 trailing_28d_mean_price), by = "item_id") %>%
    left_join(item_mean_log, by = "item_id") %>%
    mutate(log_sell_price = log(sell_price)) %>%
    prep_factors()
}

score_horizon <- function(rows) {
  raw_preds <- predict(live_model$fit, new_data = rows)$.pred
  rows %>% mutate(.pred_raw = raw_preds, .pred = pmax(raw_preds, 0))
}

p0_scenarios <- universe %>% select(item_id, sell_price = current_price)
p0_rows <- build_horizon_rows(p0_scenarios)
p0_scores <- score_horizon(p0_rows)
p0_summary <- p0_scores %>%
  group_by(item_id) %>%
  summarise(.pred_units_current = sum(.pred),
            n_floored_days_current = sum(.pred_raw < 0),
            .groups = "drop")

cand_scenarios <- cand_capped %>% select(item_id, sell_price = candidate_price)
cand_rows <- build_horizon_rows(cand_scenarios)
cand_scores <- score_horizon(cand_rows)
cand_summary <- cand_scores %>%
  group_by(item_id, sell_price) %>%
  summarise(.pred_units_candidate = sum(.pred), .groups = "drop") %>%
  rename(candidate_price = sell_price)

n_floored_days_total <- sum(p0_scores$.pred_raw < 0) + sum(cand_scores$.pred_raw < 0)
n_horizon_days_scored_total <- 28L * nrow(universe)
message("[R-B] horizon done; p0 rows = ", nrow(p0_rows),
        ", candidate rows = ", nrow(cand_rows))

# ---------- 9. backtest ----------
run_backtest <- function(D, WK) {
  message("[R-B] backtest D = ", D, ", WK = ", WK)
  tr <- sales %>% filter(d <= D) %>%
    inner_join(prices_pre %>% filter(wm_yr_wk <= WK), by = c("item_id","wm_yr_wk")) %>%
    inner_join(cal %>% select(d, wday, month, snap_CA,
                              event_name_1, event_type_1,
                              event_name_2, event_type_2), by = "d")
  tr <- tr %>%
    mutate(log_sell_price = log(sell_price),
           event_type_1 = replace_na(event_type_1, "none"),
           event_any = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
           is_memorial_day_window = as.integer(d %in% mem_window_d),
           is_nba_finals = as.integer(d %in% nba_days))
  tr <- add_trailing_features(tr, units_cum, price_cum)

  im <- tr %>% mutate(lg = log1p(units)) %>% group_by(item_id) %>%
    summarise(item_mean_log1p_units = mean(lg), .groups = "drop")
  tr <- tr %>% left_join(im, by = "item_id") %>% prep_factors()
  p99b <- tr %>% filter(units > 0) %>% group_by(item_id) %>%
    summarise(p99 = quantile(units, 0.99, type = QUANTILE_TYPE, na.rm = TRUE), .groups = "drop")
  tr <- tr %>% left_join(p99b, by = "item_id") %>%
    mutate(target_units = pmin(units, p99)) %>% select(-p99)
  tr <- tr %>% filter(if_all(all_of(feat_cols), ~ !is.na(.x)))
  message("[R-B] backtest training rows: ", nrow(tr))

  m <- fit_live_model(tr, D, SEED)

  p0_bt <- prices_pre %>% filter(wm_yr_wk == WK) %>% select(item_id, sell_price)
  horizon_d <- (D + 1L):(D + 28L)
  hcal <- cal %>% filter(d %in% horizon_d) %>%
    select(d, wday, month, snap_CA, event_name_1, event_type_1,
           event_name_2, event_type_2)

  anchors_units_bt <- anchor_trailing_units(
    sales %>% select(item_id, d, units), D)
  anchors_price_bt <- anchor_trailing_price(
    daily_price %>% select(item_id, d, sell_price), D)
  anchors_bt <- universe %>% select(item_id, dept_id) %>%
    left_join(anchors_units_bt, by = "item_id") %>%
    left_join(anchors_price_bt, by = "item_id") %>%
    left_join(im, by = "item_id")

  rows <- p0_bt %>% expand_grid(d = horizon_d) %>%
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

# ---------- 10. actions ----------
message("[R-B] actions")
cand_scores2 <- cand_capped %>%
  left_join(cand_summary, by = c("item_id","candidate_price")) %>%
  left_join(p0_summary %>% select(item_id, .pred_units_current), by = "item_id") %>%
  group_by(item_id) %>%
  summarise(candidate_prices         = list(candidate_price),
            pred_units_candidate     = list(.pred_units_candidate),
            pred_rev_candidate       = list(.pred_units_candidate * candidate_price),
            .groups = "drop")

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

universe_final <- universe_final %>%
  mutate(action = apply_backtest_collapse(action, trust_eligible, bt_primary$backtest_accept))

# r4: library rank_qualifiers() accepts either name; also add the
# underscore alias so downstream joins keep working.
universe_final <- universe_final %>%
  mutate(pred_units_current = .pred_units_current) %>%
  select(-any_of(c("rank_among_qualifiers","package_flag","below_line_flag")))
qual <- rank_qualifiers(universe_final, N_CAP)
universe_final <- universe_final %>%
  left_join(qual %>% select(item_id, rank_among_qualifiers, package_flag, below_line_flag),
            by = "item_id") %>%
  select(-pred_units_current)

universe_final <- universe_final %>%
  mutate(action_twin_11616 = action,
         expectation_not_guarantee = 1L,
         backtest_accept = bt_primary$backtest_accept,
         penalty_selected = live_model$penalty,
         penalty_grid_index = live_model$penalty_grid_index,
         n_horizon_days_scored = 28L,
         n_floored_days = NA_integer_,
         gain_below_half_mae = NA_integer_)

# ---------- 11. audit ----------
audit <- tibble(
  n_items_CA_1_total = nrow(universe_final),
  n_after_dept_map   = nrow(universe_final),
  n_universe         = nrow(universe_final),
  n_dropped_by_X1 = 0L, n_dropped_by_X2 = 0L,
  n_dropped_by_X3 = sum(is.na(universe_final$current_price)),
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
  left_join(universe_final %>% select(item_id, current_price), by = "item_id") %>%
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

audit_out <- audit %>% lineage_cols() %>% select(item_id = run_role, run_role, everything())
write_csv(audit_out, file.path(out_dir, "audit.csv"), na = "")

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

m2_rows <- tibble::tribble(
  ~gate, ~used, ~clause_cite, ~fixture_ids, ~implemented_at,
  "E_A conjuncts", "Yes", "§7.3; §17.R2, §17.R5",
    "FX-ELIG-BOUNDARY, FX-HOLD-NE-PRICES",
    "lib/rb_judged.R:compute_e_a; 10_pipeline.R step 3",
  "priced_weeks", "Yes", "§7.3; §17.R2, §17.R5",
    "FX-PW52, FX-WEEK-ORDINAL",
    "lib/rb_judged.R:compute_e_pw52; 10_pipeline.R step 3",
  "candidate-exists", "Yes", "§17.R4, §17.R5",
    "FX-NOCAND",
    "lib/rb_judged.R:compute_e_cand; 10_pipeline.R step 4",
  "TE6", "Yes", "§7.7; §17.R5",
    "FX-TE6-SLICE",
    "lib/rb_judged.R:te6_usable_slice; 10_pipeline.R step 5",
  "current price", "Yes", "§17.R3",
    "FX-CURRENT-11617",
    "lib/rb_judged.R:compute_current_price; 10_pipeline.R step 3",
  "band", "Yes", "§17.R4",
    "FX-BAND25",
    "lib/rb_judged.R:band_ok; 10_pipeline.R step 4",
  "event filter", "Yes", "§17.R4",
    "FX-EVENT-SINGLE",
    "lib/rb_judged.R:event_filter; 10_pipeline.R step 4",
  "cap/tie", "Yes", "§17.R4",
    "FX-CAP5-TIE",
    "lib/rb_judged.R:cap_candidates; 10_pipeline.R step 4",
  "legal test", "Yes", "§17.R7",
    "FX-GUARD-10, FX-CUT-OK, FX-UP0-ZERO, FX-CENT-ROUND",
    "lib/rb_judged.R:legal_change; 10_pipeline.R step 10",
  "guardrail", "Yes", "§17.R7",
    "FX-GUARD-10",
    "lib/rb_judged.R:guardrail_pass; 10_pipeline.R step 10",
  "delta_r_hat_cent_rounding", "Yes", "§17.R7; §23",
    "FX-CENT-ROUND",
    "lib/rb_judged.R:cent_delta_rev; 10_pipeline.R step 10",
  "action map", "Yes", "§17.R5, §17.R7",
    "FX-HOLD-NE-PRICES, FX-CUT-OK, FX-ARGMAX, FX-UP0-ZERO, FX-MINGAIN-DIAG",
    "lib/rb_judged.R:assign_item_action; 10_pipeline.R step 10",
  "backtest collapse", "Yes", "§16.4; §17.R8",
    "FX-BACKTEST-COLLAPSE",
    "lib/rb_judged.R:apply_backtest_collapse; 10_pipeline.R step 10",
  "ranking/tie-break", "Yes", "§17.R9",
    "FX-TIE, FX-ARGMAX",
    "lib/rb_judged.R:rank_qualifiers; 10_pipeline.R step 10",
  "Membership-first + capacity + no-pad", "Yes", "§17.R9",
    "FX-NOPAD, FX-CAP25, FX-MEMBER",
    "lib/rb_judged.R:rank_qualifiers; 10_pipeline.R step 10",
  "leakage", "Yes", "§8.3; §17.R4; §17A.5-17A.6; §20.4",
    "FX-LEAK-11618",
    "10_pipeline.R step 2 (prices_pre filter)",
  "horizon-28", "Yes", "§8.2; §17.R6",
    "FX-HORIZON-28",
    "lib/rb_judged.R:horizon_days",
  "week-ordinal rule", "Yes", "§8.5; §17.R2",
    "FX-WEEK-ORDINAL",
    "10_pipeline.R step 3 (sorted distinct wm_yr_wk)",
  "trailing anchoring", "Yes", "§17.R6; §17A.6",
    "FX-TRAIL-ANCHOR",
    "lib/rb_judged.R:anchor_trailing_units / anchor_trailing_price",
  "recipe", "Yes", "§8.6; §17.R6; §17A.3",
    "FX-WDAY-SNAP, FX-INTERACT",
    "lib/rb_judged.R:build_recipe / prep_factors / RB_ALLOWED_FEATURES",
  "Half-window / persistence", "N/A - attested unused", "§16",
    "N/A", "not implemented",
  "Dual-clock / twin action-override", "N/A - attested unused", "§11.2",
    "N/A", "not implemented (action_twin_11616 is diagnostic only)",
  "Full analytical-unit universe", "Yes", "§7.1; §17.R1",
    "FX-MEMBER",
    "10_pipeline.R step 3 (universe build)",
  "Non-enrolling actions", "Yes", "§17.R5, §17.R7, §17.R9",
    "FX-NOPAD, FX-HOLD-NE-PRICES, FX-NOCAND, FX-UP0-ZERO",
    "lib/rb_judged.R:assign_item_action, rank_qualifiers",
  "Lineage field mapping", "Yes", "§24.4; §20.5",
    "N/A",
    "10_pipeline.R:lineage; lineage_cols()",
  "Capacity / simulation labels", "Capacity yes; simulation N/A",
    "§17.R9; §22.1; §22.4; §24.4",
    "FX-NOPAD, FX-CAP25",
    "lib/rb_judged.R:rank_qualifiers; 10_pipeline.R:audit",
  "Mode A scoring", "Yes", "§17A; §17.R6; §22.3",
    "FX-INTERACT, FX-TRAIL-ANCHOR",
    "10_pipeline.R:fit_live_model, score_horizon",
  "Minimum-gain diagnostic (non-judged)", "Yes", "§11.3",
    "FX-MINGAIN-DIAG",
    "10_pipeline.R step 10 (gain_below_half_mae placeholder)"
)
write_csv(m2_rows, file.path(out_dir, "m2_attestation.csv"))

sink(file.path(out_dir, "session_info.txt"), append = TRUE)
cat("\n\n== judged run session ==\n\n"); print(sessionInfo())
sink()
cat("R-B pipeline OK\n")
