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
dir.create(dirname(args$fixture_out), recursive = TRUE, showWarnings = FALSE)

results <- list()
record <- function(id, expr, pass_detail) {
  out <- tryCatch({
    ok <- isTRUE(force(expr))
    list(ok = ok, detail = if (ok) pass_detail else "Predicate evaluated FALSE")
  }, error = function(e) list(ok = FALSE, detail = paste0("ERROR: ", conditionMessage(e))))
  results[[length(results) + 1L]] <<- tibble(
    fixture_id = id,
    expected = "PASS",
    observed = if (out$ok) "PASS" else "FAIL",
    result = if (out$ok) "PASS" else "FAIL",
    detail = out$detail
  )
  invisible(out$ok)
}

trusted_stub <- function(item_id = "A", current_price = 1) {
  tibble(store_id = "CA_1", item_id = item_id, current_price = current_price, trust_eligible = 1L)
}
current_stub <- function(item_id = "A", units = 100, rev = 100) {
  tibble(store_id = "CA_1", item_id = item_id, scenario_price = 1, pred_units = units, pred_rev = rev,
         n_horizon_days_scored = 28L, n_floored_days = 0L)
}
candidate_stub <- function(item_id = "A", price, units, rev) {
  tibble(store_id = "CA_1", item_id = item_id, scenario_price = price, pred_units = units, pred_rev = rev,
         n_horizon_days_scored = 28L, n_floored_days = 0L)
}
empty_legal <- function() {
  tibble(
    store_id = character(), item_id = character(), scenario_price = double(), legal_change = integer(),
    delta_rev = double(), .pred_units_candidate = double(), .pred_rev_candidate = double(), unit_ratio = double(),
    guardrail_pass = integer(), n_floored_days = integer()
  )
}
minimal_panel <- function(prices, event_weeks = integer()) {
  prices %>%
    transmute(store_id, item_id, wm_yr_wk, sell_price,
              price_cents = as.integer(round(sell_price * 100)),
              d = row_number(), event_type_1 = if_else(wm_yr_wk %in% event_weeks, "Sporting", "none"))
}

# 1 FX-HOLD-NE-PRICES
record("FX-HOLD-NE-PRICES", {
  x <- tibble(store_id = "CA_1", item_id = "A", current_price = 1,
              n_price_changes_pre = 0L, units_365 = 500, zero_days_365 = 10L, priced_weeks_pre = 100L,
              e_cand = 1L, te6 = 1L) %>% apply_ea_flags() %>% apply_pw52_flag() %>% apply_trust_flags()
  lc <- legalize_candidates(candidate_stub(price = 1.2, units = 100, rev = 120), current_stub(), 0.90)
  a <- choose_actions(x, lc, current_stub(), 1L)
  identical(x$trust_eligible, 0L) && a$action[[1]] == "hold_ne"
}, "One-price item fails trust and maps to hold_ne")

# 2 FX-GUARD-10
record("FX-GUARD-10", {
  lc <- legalize_candidates(candidate_stub(price = 2, units = 89, rev = 178), current_stub(), 0.90)
  a <- choose_actions(trusted_stub(), lc, current_stub(), 1L)
  lc$guardrail_pass[[1]] == 0L && a$action[[1]] != "raise"
}, "89/100 unit ratio fails the 0.90 guardrail despite positive revenue delta")

# 3 FX-CUT-OK
record("FX-CUT-OK", {
  lc <- legalize_candidates(candidate_stub(price = 0.9, units = 120, rev = 108), current_stub(), 0.90)
  a <- choose_actions(trusted_stub(), lc, current_stub(), 1L)
  a$action[[1]] == "cut"
}, "Legal cut is allowed")

# 4 FX-ARGMAX
record("FX-ARGMAX", {
  cs <- bind_rows(candidate_stub(price = 1.1, units = 100, rev = 108), candidate_stub(price = 1.2, units = 100, rev = 110))
  lc <- legalize_candidates(cs, current_stub(), 0.90)
  a <- choose_actions(trusted_stub(), lc, current_stub(), 1L)
  a$candidate_price[[1]] == 1.2 && a$delta_rev[[1]] == 10
}, "Unrounded delta_rev argmax selects the 10-unit gain")

# 5 FX-NOPAD
record("FX-NOPAD", {
  u <- tibble(
    store_id = "CA_1", item_id = c("A", "B", "C", "H", "U"),
    action = c("raise", "cut", "raise", "hold_ne", "unchanged"),
    delta_rev = c(5, 4, 3, NA, 0), .pred_units_current = c(10, 10, 10, 10, 10),
    n_price_changes_pre = c(5L, 5L, 5L, 5L, 5L)
  ) %>% rank_capacity(25L)
  sum(u$package_flag) == 3L && all(u$package_flag[u$action %in% c("hold_ne", "unchanged")] == 0L)
}, "Three qualifiers produce a three-item package; no padding")

# 6 FX-CAP25
record("FX-CAP25", {
  u <- tibble(
    store_id = "CA_1", item_id = sprintf("I%02d", 1:30), action = "raise",
    delta_rev = rev(seq_len(30)), .pred_units_current = 100, n_price_changes_pre = 5L
  ) %>% rank_capacity(25L)
  sum(u$package_flag) == 25L && sum(u$below_line_flag) == 5L && max(u$rank_among_qualifiers[u$package_flag == 1L]) == 25L
}, "Thirty qualifiers cap at 25 with five below line")

# 7 FX-MEMBER
record("FX-MEMBER", {
  x <- tibble(store_id = "CA_1", item_id = "ZERO", current_price = 1,
              n_price_changes_pre = 0L, units_365 = 0, zero_days_365 = 365L,
              priced_weeks_pre = 0L, e_cand = 0L, te6 = 0L) %>% apply_ea_flags() %>% apply_pw52_flag() %>% apply_trust_flags()
  cur <- current_stub(item_id = "ZERO")
  a <- choose_actions(x, empty_legal(), cur, 1L)
  nrow(x) == 1L && x$trust_eligible[[1]] == 0L && a$action[[1]] == "hold_ne"
}, "Zero-eligible universe member remains present and non-trusted")

# 8 FX-LEAK-11618
record("FX-LEAK-11618", {
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = c(11610L, 11617L, 11618L), sell_price = c(3.8, 4.0, 4.5))
  panel <- minimal_panel(p[p$wm_yr_wk <= 11617L, ])
  u <- tibble(store_id = "CA_1", item_id = "A", current_price = 4.0)
  cands <- build_candidates(p, panel, u, 1941L, 11617L)$candidates
  sales1 <- tibble(item_id = "A", dept_id = "FOODS_3", cat_id = "FOODS", store_id = "CA_1", d = 1941L, units = 1L, wm_yr_wk = 11617L)
  cal1 <- tibble(d = 1941L, date = as.Date("2016-05-22"), wm_yr_wk = 11617L, wday = 2L, month = 5L, year = 2016L,
                 event_name_1 = NA_character_, event_type_1 = "none", event_name_2 = NA_character_, event_type_2 = NA_character_,
                 snap_CA = 0L, event_any = 0L, is_memorial_day_window = 0L, is_nba_finals = 0L)
  mapped <- build_panel(sales1, p, cal1)
  !any(cands$candidate_price == 4.5) && mapped$sell_price[[1]] == 4.0
}, "Week-11618 price is quarantined from candidates")

# 9 FX-CURRENT-11617
record("FX-CURRENT-11617", {
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = c(11616L, 11617L), sell_price = c(3.0, 3.5))
  x <- current_price_fields(p)
  x$current_price[[1]] == 3.5 && x$current_price_11616[[1]] == 3.0 && x$straddle_flag[[1]] == 1L
}, "Current price uses 11617 and flags the 11616 straddle")

fixture_calendar <- tibble(
  d = 1942:1969,
  date = seq(as.Date("2016-05-23"), as.Date("2016-06-19"), by = "day"),
  wm_yr_wk = c(rep(11617L, 5), rep(11618L, 7), rep(11619L, 7), rep(11620L, 7), rep(11621L, 2)),
  wday = rep(1:7, length.out = 28), month = c(rep(5L, 9), rep(6L, 19)), year = 2016L,
  event_name_1 = NA_character_, event_type_1 = "none", event_name_2 = NA_character_, event_type_2 = NA_character_,
  snap_CA = 0L, event_any = 0L, is_memorial_day_window = 0L, is_nba_finals = 0L
)
fixture_hist_panel <- tibble(
  store_id = "CA_1", item_id = "A", dept_id = "FOODS_3", d = 1858:1941,
  units = 1L, sell_price = 2, wday = rep(1:7, length.out = 84), month = 5L,
  snap_CA = 0L, event_type_1 = "none", event_any = 0L, is_memorial_day_window = 0L, is_nba_finals = 0L
)
fx_levels <- list(wday = as.character(1:7), month = as.character(1:12),
                  dept_id = c("FOODS_3", "FOODS_1", "FOODS_2", "HOUSEHOLD_1", "HOUSEHOLD_2"),
                  event_type_1 = c("none", "Cultural", "National", "Religious", "Sporting"))

# 10 FX-HORIZON-28
record("FX-HORIZON-28", {
  rows <- make_horizon_rows(
    tibble(store_id = "CA_1", item_id = "A", dept_id = "FOODS_3", scenario_price = 2),
    fixture_calendar, fixture_hist_panel, 1941L,
    tibble(item_id = "A", item_mean_log1p_units = log(2)), fx_levels
  )
  nrow(rows) == 28L && identical(sort(rows$d), 1942:1969) && sum(rows$wm_yr_wk == 11621L) == 2L
}, "Horizon has exactly d_1942–d_1969 and two days in week 11621")

# 11 FX-TIE
record("FX-TIE", {
  u <- tibble(store_id = "CA_1", item_id = c("A", "B"), action = "raise", delta_rev = c(10, 10),
              .pred_units_current = c(100, 120), n_price_changes_pre = c(5L, 5L)) %>% rank_capacity(25L)
  u$item_id[which.min(u$rank_among_qualifiers)] == "B"
}, "Equal delta_rev ranks the higher current-units item first")

# 12 FX-ELIG-BOUNDARY
record("FX-ELIG-BOUNDARY", {
  x <- tibble(
    item_id = letters[1:4], n_price_changes_pre = c(3L, 2L, 3L, 3L),
    units_365 = c(180, 180, 179, 180), zero_days_365 = c(182L, 182L, 182L, 183L)
  ) %>% apply_ea_flags() %>% mutate(E_A = e_chg3 * e_u180 * e_z182)
  identical(x$item_id[x$E_A == 1L], "a")
}, "Only the exact E_A boundary item passes")

# 13 FX-PW52
record("FX-PW52", {
  x <- tibble(store_id = "CA_1", item_id = "A", current_price = 1,
              n_price_changes_pre = 3L, units_365 = 180, zero_days_365 = 182L, priced_weeks_pre = 51L,
              e_cand = 1L, te6 = 1L) %>% apply_ea_flags() %>% apply_pw52_flag() %>% apply_trust_flags()
  lc <- legalize_candidates(candidate_stub(price = 1.2, units = 100, rev = 120), current_stub(), 0.90)
  a <- choose_actions(x, lc, current_stub(), 1L)
  x$e_pw52[[1]] == 0L && x$trust_eligible[[1]] == 0L && a$action[[1]] == "hold_ne"
}, "51 priced weeks fails e_pw52 and trust")

# 14 FX-BAND25
record("FX-BAND25", {
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = 11610:11615,
              sell_price = c(3.00, 3.01, 4.99, 5.00, 5.01, 4.00))
  panel <- minimal_panel(p)
  u <- tibble(store_id = "CA_1", item_id = "A", current_price = 4.00)
  got <- sort(build_candidates(p, panel, u, 1941L, 11617L)$candidates$candidate_price)
  identical(got, c(3.00, 3.01, 4.99, 5.00))
}, "Integer-cent ±25% band keeps both boundaries and excludes 5.01")

# 15 FX-NOCAND
record("FX-NOCAND", {
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = c(11610L, 11611L, 11617L), sell_price = c(2, 6, 4))
  panel <- minimal_panel(p)
  u <- tibble(store_id = "CA_1", item_id = "A", current_price = 4)
  z <- build_candidates(p, panel, u, 1941L, 11617L)
  flags <- tibble(store_id = "CA_1", item_id = "A", current_price = 4,
                  n_price_changes_pre = 3L, units_365 = 180, zero_days_365 = 10L, priced_weeks_pre = 52L,
                  e_cand = z$per_item$e_cand, te6 = 1L) %>% apply_ea_flags() %>% apply_pw52_flag() %>% apply_trust_flags()
  cur <- tibble(store_id = "CA_1", item_id = "A", scenario_price = 4, pred_units = 100, pred_rev = 400, n_horizon_days_scored = 28L, n_floored_days = 0L)
  a <- choose_actions(flags, empty_legal(), cur, 1L)
  nrow(z$candidates) == 0L && flags$e_cand[[1]] == 0L && flags$trust_eligible[[1]] == 0L && a$action[[1]] == "hold_ne"
}, "No in-band candidate leaves e_cand=0; no band expansion")

# 16 FX-EVENT-SINGLE
record("FX-EVENT-SINGLE", {
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = c(11610L, 11611L, 11617L), sell_price = c(3.8, 3.9, 4.0))
  panel <- minimal_panel(p, event_weeks = 11610L)
  u <- tibble(store_id = "CA_1", item_id = "A", current_price = 4.0)
  z <- build_candidates(p, panel, u, 1941L, 11617L)
  identical(z$candidates$candidate_price, 3.9) && z$per_item$n_candidates_event_filtered[[1]] == 1L
}, "Single-week Sporting price is removed; single-week non-event price is retained")

# 17 FX-CAP5-TIE
record("FX-CAP5-TIE", {
  vals <- c(4.10, 3.90, 4.40, 3.60, 3.20, 5.00, 3.00, 4.00)
  p <- tibble(store_id = "CA_1", item_id = "A", wm_yr_wk = 11610L + seq_along(vals) - 1L, sell_price = vals)
  panel <- minimal_panel(p)
  u <- tibble(store_id = "CA_1", item_id = "A", current_price = 4.00)
  z <- build_candidates(p, panel, u, 1941L, 11617L)$candidates
  nrow(z) == 5L && 3.20 %in% z$candidate_price && !5.00 %in% z$candidate_price &&
    z$rank_in_cap[z$candidate_price == 3.20] < 6L
}, "Five nearest candidates kept; equal rounded distance favors lower price 3.20 over 5.00")

# 18 FX-UP0-ZERO
record("FX-UP0-ZERO", {
  cur <- current_stub(units = 0, rev = 0)
  lc <- legalize_candidates(candidate_stub(price = 1.1, units = 100, rev = 110), cur, 0.90)
  a <- choose_actions(trusted_stub(), lc, cur, 1L)
  a$action[[1]] == "hold_ne" && is.na(lc$unit_ratio[[1]])
}, "Zero predicted baseline units maps to hold_ne without a unit ratio")

# 19 FX-CENT-ROUND
record("FX-CENT-ROUND", {
  cur <- current_stub(units = 100, rev = 100.000)
  lc <- legalize_candidates(candidate_stub(price = 1.1, units = 100, rev = 100.004), cur, 0.90)
  a <- choose_actions(trusted_stub(), lc, cur, 1L)
  lc$cent_delta_rev[[1]] == 0 && lc$legal_change[[1]] == 0L && a$action[[1]] == "unchanged"
}, "Separate base-R cent rounding makes 100.004 vs 100.000 non-legal")

# 20 FX-MINGAIN-DIAG
record("FX-MINGAIN-DIAG", {
  lc <- legalize_candidates(candidate_stub(price = 1.2, units = 100, rev = 110), current_stub(), 0.90)
  a <- choose_actions(trusted_stub(), lc, current_stub(), 1L) %>%
    mutate(dept_id = "FOODS_3", n_price_changes_pre = 5L) %>% rank_capacity(25L) %>%
    add_min_gain_diagnostic(tibble(dept_id = "FOODS_3", dept_backtest_MAE_revenue = 100))
  a$action[[1]] == "raise" && a$gain_below_half_mae[[1]] == 1L && a$rank_among_qualifiers[[1]] == 1L
}, "Below-half-MAE gain remains a ranked legal action and is diagnostic-only")

# 21 FX-BACKTEST-COLLAPSE
record("FX-BACKTEST-COLLAPSE", {
  lc <- legalize_candidates(candidate_stub(price = 1.2, units = 100, rev = 110), current_stub(), 0.90)
  accept <- backtest_accept_flag(0.45, 0.00)
  a <- choose_actions(trusted_stub(), lc, current_stub(), accept)
  accept == 0L && a$action[[1]] == "hold_ne"
}, "A1=0.45 collapses the trusted action set to hold_ne")

# 22 FX-TRAIL-ANCHOR
record("FX-TRAIL-ANCHOR", {
  rows <- make_horizon_rows(
    tibble(store_id = "CA_1", item_id = "A", dept_id = "FOODS_3", scenario_price = 2),
    fixture_calendar, fixture_hist_panel, 1941L,
    tibble(item_id = "A", item_mean_log1p_units = log(2)), fx_levels
  )
  v <- rows$trailing_28d_units[rows$d %in% c(1942L, 1969L)]
  length(v) == 2L && identical(as.numeric(v), c(28, 28))
}, "Both first and last horizon rows use the same d_1914–d_1941 trailing anchor")

# 23 FX-WDAY-SNAP
record("FX-WDAY-SNAP", {
  c0 <- tibble(
    date = as.Date("2016-05-21"), wm_yr_wk = 11617L, wday = 1L, month = 5L, year = 2016L, d = 1940L,
    event_name_1 = NA_character_, event_type_1 = NA_character_, event_name_2 = NA_character_, event_type_2 = NA_character_,
    snap_CA = 0L, snap_TX = 1L, snap_WI = 0L
  )
  x <- calendar_features(c0)
  x$wday[[1]] == 1L && x$snap_CA[[1]] == 0L
}, "Stored Saturday wday=1 and CA SNAP=0 are preserved")

# 24 FX-WEEK-ORDINAL
record("FX-WEEK-ORDINAL", {
  weeks <- c(11518:11552, 11601:11617)
  c0 <- tibble(wm_yr_wk = weeks, d = seq_along(weeks))
  got <- last_n_week_ids(c0, 11617L, 52L)
  identical(got, as.integer(weeks)) && length(got) == 52L
}, "Last 52 calendar weeks are 11518–11552 plus 11601–11617")

# 25 FX-INTERACT
record("FX-INTERACT", {
  n <- 12L
  df <- tibble(
    target = seq_len(n), sell_price = seq(1.1, 2.2, length.out = n),
    wday = factor(as.character(rep(1:7, length.out = n)), levels = fx_levels$wday),
    month = factor(as.character(1:12), levels = fx_levels$month),
    snap_CA = rep(c(0L, 1L), length.out = n),
    event_type_1 = factor(rep(fx_levels$event_type_1, length.out = n), levels = fx_levels$event_type_1),
    event_any = rep(c(0L, 1L), length.out = n), is_memorial_day_window = rep(c(0L, 0L, 1L), length.out = n),
    is_nba_finals = rep(c(0L, 1L, 1L, 0L), length.out = n),
    trailing_28d_units = seq(10, 21), trailing_84d_units = seq(40, 51),
    trailing_28d_mean_price = seq(1.5, 2.6, length.out = n),
    dept_id = factor(rep(fx_levels$dept_id, length.out = n), levels = fx_levels$dept_id),
    item_mean_log1p_units = seq(0.5, 1.6, length.out = n)
  )
  baked <- recipes::prep(make_model_recipe(df), training = df, retain = TRUE) %>% recipes::juice()
  nm <- names(baked)[grepl("log_sell_price", names(baked)) & grepl("snap_CA", names(baked))]
  length(nm) == 1L && isTRUE(all.equal(baked[[nm]] , baked$log_sell_price * baked$snap_CA, tolerance = 1e-12))
}, "Recipe emits exactly one scaled-log-price × raw-snap_CA interaction")

# 26 FX-TE6-SLICE
record("FX-TE6-SLICE", {
  x <- tibble(
    store_id = "CA_1", item_id = c("a", "b", "c"), current_price = 1,
    e_chg3 = 1L, e_u180 = 1L, e_z182 = 1L, e_pw52 = 1L, e_cand = 1L,
    ea_reanchored = c(FALSE, TRUE, TRUE), stable_price = c(TRUE, TRUE, FALSE), realized_units = c(100, 0, 100)
  ) %>%
    mutate(te6_usable_slice = te6_slice_flags(ea_reanchored, stable_price, realized_units), te6 = te6_usable_slice) %>%
    apply_trust_flags()
  cur <- tibble(store_id = "CA_1", item_id = c("a", "b", "c"), scenario_price = 1, pred_units = 100, pred_rev = 100, n_horizon_days_scored = 28L, n_floored_days = 0L)
  cand <- tibble(store_id = "CA_1", item_id = c("a", "b", "c"), scenario_price = 1.2, pred_units = 100, pred_rev = 120, n_horizon_days_scored = 28L, n_floored_days = 0L)
  lc <- legalize_candidates(cand, cur, 0.90)
  a <- choose_actions(x, lc, cur, 1L)
  all(x$te6_usable_slice == 0L) && all(x$te6 == 0L) && all(x$trust_eligible == 0L) && all(a$action == "hold_ne")
}, "Each of the three TE6 failure modes forces te6=0 and trust_eligible=0")

out <- bind_rows(results)
locked_ids <- c(
  "FX-HOLD-NE-PRICES", "FX-GUARD-10", "FX-CUT-OK", "FX-ARGMAX", "FX-NOPAD", "FX-CAP25", "FX-MEMBER",
  "FX-LEAK-11618", "FX-CURRENT-11617", "FX-HORIZON-28", "FX-TIE", "FX-ELIG-BOUNDARY", "FX-PW52", "FX-BAND25",
  "FX-NOCAND", "FX-EVENT-SINGLE", "FX-CAP5-TIE", "FX-UP0-ZERO", "FX-CENT-ROUND", "FX-MINGAIN-DIAG",
  "FX-BACKTEST-COLLAPSE", "FX-TRAIL-ANCHOR", "FX-WDAY-SNAP", "FX-WEEK-ORDINAL", "FX-INTERACT", "FX-TE6-SLICE"
)
if (!identical(out$fixture_id, locked_ids)) stop("Fixture harness did not emit the frozen 26 IDs in order")
readr::write_csv(out, args$fixture_out, na = "")
if (any(out$result != "PASS")) stop("One or more R-A fixtures failed; see ", args$fixture_out)
message("R-A fixture harness PASS 26/26")
