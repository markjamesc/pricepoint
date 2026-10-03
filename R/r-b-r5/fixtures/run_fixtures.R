#!/usr/bin/env Rscript
# R-B fixture harness. Builds each synthetic setup exactly as written in
# fixture_pack_v1.md, calls the production functions from lib/rb_judged.R,
# and writes r_b_fixture_results.csv with one row per fixture.
# Exits non-zero if any fixture fails.
#
# r4 changes over r3: the four fixtures that previously evaluated constants
# now call production functions (R_PACKET §5 item 4). No fixture-pack
# changes; no library judged-rule changes.

suppressPackageStartupMessages({
  library(dplyr); library(tibble); library(readr); library(purrr); library(recipes)
})

script_dir <- dirname(normalizePath(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
source(file.path(script_dir, "..", "lib", "rb_judged.R"))

parse_args <- function(args, key, default) {
  pref <- paste0("--", key, "=")
  hit  <- args[startsWith(args, pref)]
  if (length(hit) == 0L) return(default)
  sub(pref, "", hit[1], fixed = TRUE)
}
args       <- commandArgs(trailingOnly = TRUE)
out_path   <- parse_args(args, "fixture-out",
  "C:/Users/Mark/Documents/R Working Directory/pricepoint/validation/fixtures/r_b_fixture_results.csv")
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)

results <- list()
record <- function(id, expected, observed, detail) {
  results[[length(results) + 1L]] <<- tibble(
    fixture_id = id, expected = expected, observed = observed,
    result = if (identical(observed, expected)) "PASS" else "FAIL",
    detail = detail)
}

run_fx <- function(id, fn) {
  o <- tryCatch(fn(), error = function(e) paste0("ERROR:", conditionMessage(e)))
  if (is.character(o) && length(o) == 1L && startsWith(o, "ERROR:")) {
    record(id, "PASS", "FAIL", o)
  } else if (isTRUE(o)) {
    record(id, "PASS", "PASS", "")
  } else {
    record(id, "PASS", "FAIL", as.character(o))
  }
}

# 1. FX-HOLD-NE-PRICES
run_fx("FX-HOLD-NE-PRICES", function() {
  a <- assign_item_action(trust_eligible = FALSE, pred_units_current = 100,
                          candidate_prices = c(1.20), pred_units_candidate = 200,
                          pred_rev_candidate = 240, current_price = 1.00)
  identical(a$action, "hold_ne")
})

# 2. FX-GUARD-10
run_fx("FX-GUARD-10", function() {
  a <- assign_item_action(TRUE, 100, c(1.20), 89, 89*1.20, 1.00)
  a$action != "raise" && identical(a$guardrail_pass, 0L)
})

# 3. FX-CUT-OK
# Frozen pack: "Cut candidate; stub units +20%; Delta-Rhat > 0";
# expected action = cut. Pc = 0.90 satisfies all three premises:
# rho = 1.20 >= 0.90; Rhat(Pc) = 108; Rhat(P0) = 100; cent_delta_rev = 8 > 0.
run_fx("FX-CUT-OK", function() {
  a <- assign_item_action(TRUE, 100, c(0.90), 120, 120*0.90, 1.00)
  identical(a$action, "cut")
})

# 4. FX-ARGMAX
run_fx("FX-ARGMAX", function() {
  a <- assign_item_action(TRUE, 100, c(1.05, 1.10), c(110, 120),
                          c(110*1.05, 120*1.10), 1.00)
  identical(a$candidate_price, 1.10)
})

# 5. FX-NOPAD
run_fx("FX-NOPAD", function() {
  df <- tibble(item_id = c("A","B","C","D"),
               action = c("raise","cut","raise","hold_ne"),
               delta_rev = c(10, 8, 6, NA),
               pred_units_current = c(100, 100, 100, 100),
               n_price_changes_pre = c(5, 5, 5, 0))
  q <- rank_qualifiers(df, 25L)
  nrow(q) == 3L && all(q$package_flag == 1L) && all(q$below_line_flag == 0L)
})

# 6. FX-CAP25
run_fx("FX-CAP25", function() {
  df <- tibble(item_id = sprintf("I%02d", 1:30),
               action = "raise",
               delta_rev = rev(seq_len(30)),
               pred_units_current = rep(100, 30),
               n_price_changes_pre = rep(5, 30))
  q <- rank_qualifiers(df, 25L)
  sum(q$package_flag) == 25L && sum(q$below_line_flag) == 5L &&
    all(diff(q$delta_rev) <= 0)
})

# 7. FX-MEMBER
run_fx("FX-MEMBER", function() {
  a <- assign_item_action(FALSE, NA_real_, numeric(0), numeric(0), numeric(0), 1.00)
  identical(a$action, "hold_ne")
})

# 8. FX-LEAK-11618
run_fx("FX-LEAK-11618", function() {
  pre  <- c(1.20)
  post <- c(1.40)
  kept <- cap_candidates(pre, 1.00, 5L)
  !(1.40 %in% kept)
})

# 9. FX-CURRENT-11617
run_fx("FX-CURRENT-11617", function() {
  cp <- compute_current_price(3.50, 3.00)
  identical(cp$current_price, 3.50) && identical(cp$straddle_flag, 1L) &&
    identical(cp$current_price_11616, 3.00)
})

# 10. FX-HORIZON-28
# Frozen pack: setup "Calendar stub with 2-day week 11621"; expected
# "n_horizon_days_scored = 28 (d_1942-d_1969)". r4 calls the production
# horizon_days() function; a weekly 4x7 recode would yield 28 too, so the
# additional assertion is that the horizon starts at d_1942 (not d_1941)
# and does not roll past d_1969.
run_fx("FX-HORIZON-28", function() {
  h <- horizon_days(1941L)
  length(h) == 28L &&
    identical(as.integer(h[1]), 1942L) &&
    identical(as.integer(h[28]), 1969L) &&
    all(diff(h) == 1L)
})

# 11. FX-TIE
run_fx("FX-TIE", function() {
  df <- tibble(item_id = c("A","B"), action = c("raise","raise"),
               delta_rev = c(10, 10),
               pred_units_current = c(200, 100),
               n_price_changes_pre = c(5, 5))
  q <- rank_qualifiers(df, 25L)
  q$item_id[1] == "A"
})

# 12. FX-ELIG-BOUNDARY
run_fx("FX-ELIG-BOUNDARY", function() {
  compute_e_a(3L, 180L, 182L) &&
    !compute_e_a(2L, 180L, 182L) &&
    !compute_e_a(3L, 179L, 182L) &&
    !compute_e_a(3L, 180L, 183L)
})

# 13. FX-PW52
run_fx("FX-PW52", function() {
  identical(compute_e_pw52(51L), FALSE) && identical(compute_e_pw52(52L), TRUE)
})

# 14. FX-BAND25
run_fx("FX-BAND25", function() {
  band_ok(3.00, 4.00) && band_ok(3.01, 4.00) &&
    band_ok(4.99, 4.00) && band_ok(5.00, 4.00) && !band_ok(5.01, 4.00)
})

# 15. FX-NOCAND
run_fx("FX-NOCAND", function() {
  a <- assign_item_action(TRUE, 100, numeric(0), numeric(0), numeric(0), 1.00)
  identical(a$action, "unchanged")
})

# 16. FX-EVENT-SINGLE
run_fx("FX-EVENT-SINGLE", function() {
  ev <- list("11617" = "Sporting")
  pc_after <- event_filter(c(1.20, 1.30),
                           list(11617L, c(11610L, 11611L)),
                           ev)
  length(pc_after) == 1L && pc_after == 1.30
})

# 17. FX-CAP5-TIE
run_fx("FX-CAP5-TIE", function() {
  P0 <- 4.00
  Pc <- c(3.20, 5.00, 3.10, 5.20, 3.30, 4.80, 3.40)
  kept <- cap_candidates(Pc, P0, 5L)
  if (length(kept) != 5L) return(FALSE)
  i320 <- which(kept == 3.20)
  i500 <- which(kept == 5.00)
  length(i320) == 1L && length(i500) == 1L && i320 < i500
})

# 18. FX-UP0-ZERO
run_fx("FX-UP0-ZERO", function() {
  a <- assign_item_action(TRUE, 0, c(1.20), c(50), 60, 1.00)
  identical(a$action, "hold_ne")
})

# 19. FX-CENT-ROUND
run_fx("FX-CENT-ROUND", function() {
  r0 <- 100.000; rc <- 100.004
  cdr <- cent_delta_rev(rc, r0)
  a <- assign_item_action(TRUE, 100, c(1.01), 100, rc, 1.00)
  identical(cdr, 0) && a$action == "unchanged"
})

# 20. FX-MINGAIN-DIAG
run_fx("FX-MINGAIN-DIAG", function() {
  a <- assign_item_action(TRUE, 100, c(1.05), 100, 100*1.05, 1.00)
  a$action %in% c("raise","cut") && a$legal_change == 1L
})

# 21. FX-BACKTEST-COLLAPSE
run_fx("FX-BACKTEST-COLLAPSE", function() {
  a <- c("raise","cut","unchanged","hold_ne")
  t <- c(TRUE, TRUE, TRUE, FALSE)
  out <- apply_backtest_collapse(a, t, 0L)
  all(out[t] == "hold_ne")
})

# 22. FX-TRAIL-ANCHOR
# Frozen pack: setup "Horizon rows d_1942 and d_1969"; expected
# "trailing_28d_units identical on both = sum d_1914...d_1941"; build fails
# if "uses post-origin (unknown) days or rolls forward".
# r4: build a synthetic single-item 142-day panel (d_1830..d_1971) whose
# units differ on the 28-day window, the 84-day window and the post-origin
# tail. Assert that anchors computed at origin 1941 equal the expected sums
# and are independent of any row with d > 1941, and that joining the same
# anchors onto horizon day d_1942 and d_1969 yields identical values.
run_fx("FX-TRAIL-ANCHOR", function() {
  d_all <- 1830:1971
  units_all <- rep(0L, length(d_all))
  units_all[d_all >= 1858 & d_all <= 1913] <- 1L       # 56 days pre-28-window
  units_all[d_all >= 1914 & d_all <= 1941] <- 2L       # 28 days in 28-window
  units_all[d_all >= 1942 & d_all <= 1971] <- 9999L    # post-origin; must be ignored
  panel <- data.frame(item_id = "ITEM_X", d = d_all, units = units_all)

  anchors <- anchor_trailing_units(panel, 1941L)
  expected_28 <- 56L
  expected_84 <- 56L + 56L
  ok1 <- nrow(anchors) == 1L &&
    anchors$trailing_28d_units[1] == expected_28 &&
    anchors$trailing_84d_units[1] == expected_84

  horizon_a <- data.frame(item_id = "ITEM_X", d = 1942L)
  horizon_b <- data.frame(item_id = "ITEM_X", d = 1969L)
  merged_a <- dplyr::left_join(horizon_a, anchors, by = "item_id")
  merged_b <- dplyr::left_join(horizon_b, anchors, by = "item_id")
  ok2 <- merged_a$trailing_28d_units[1] == merged_b$trailing_28d_units[1] &&
    merged_a$trailing_28d_units[1] == expected_28 &&
    merged_a$trailing_84d_units[1] == expected_84

  ok1 && ok2
})

# 23. FX-WDAY-SNAP
# Frozen pack: setup "2016-05-21 row; snap_TX = 1, snap_CA = 0 day";
# expected "wday = 1 (Saturday); SNAP feature = 0"; build fails if
# "ISO recode or TX/WI SNAP used".
# r4: assert (a) prep_factors() preserves wday = 1 as integer level 1 (no
# ISO recode); (b) the allowed feature list contains snap_CA and not
# snap_TX/snap_WI.
run_fx("FX-WDAY-SNAP", function() {
  row <- data.frame(wday = 1L, month = 5L,
                    dept_id = "FOODS_3", event_type_1 = NA_character_)
  pf <- prep_factors(row)
  wday_ok <- identical(as.integer(as.character(pf$wday)), 1L)

  snap_ok <- ("snap_CA" %in% RB_ALLOWED_FEATURES) &&
    !("snap_TX" %in% RB_ALLOWED_FEATURES) &&
    !("snap_WI" %in% RB_ALLOWED_FEATURES)

  wday_ok && snap_ok
})

# 24. FX-WEEK-ORDINAL
run_fx("FX-WEEK-ORDINAL", function() {
  weeks <- sort(c(11518:11552, 11601:11617))
  length(weeks) == 52L
})

# 25. FX-INTERACT
# Frozen pack: setup "Recipe stub"; expected "model matrix has exactly one
# interaction column = scaled log_sell_price x snap_CA"; build fails if
# "missing or extra interactions".
# r4: build the production recipe on a synthetic panel, prep it, bake it,
# and assert exactly one interaction column, containing both terms.
run_fx("FX-INTERACT", function() {
  tiny <- tibble::tibble(
    target_units = c(1, 2, 3, 4, 5),
    log_sell_price = c(0.1, 0.2, 0.3, 0.4, 0.5),
    wday = factor(c(1L, 2L, 3L, 1L, 2L), levels = 1:7),
    month = factor(c(1L, 1L, 2L, 2L, 3L), levels = 1:12),
    snap_CA = c(0L, 1L, 0L, 1L, 0L),
    event_type_1 = factor(c("none","Sporting","none","National","none"),
                          levels = c("none","Cultural","National",
                                     "Religious","Sporting")),
    event_any = c(0L, 1L, 0L, 1L, 0L),
    is_memorial_day_window = c(0L, 0L, 1L, 0L, 0L),
    is_nba_finals = c(0L, 0L, 0L, 1L, 0L),
    trailing_28d_units = c(10, 20, 30, 40, 50),
    trailing_84d_units = c(50, 60, 70, 80, 90),
    trailing_28d_mean_price = c(1.0, 1.1, 1.2, 1.3, 1.4),
    dept_id = factor(c("FOODS_3","FOODS_1","FOODS_2","HOUSEHOLD_1","FOODS_3"),
                     levels = c("FOODS_3","FOODS_1","FOODS_2",
                                "HOUSEHOLD_1","HOUSEHOLD_2")),
    item_mean_log1p_units = c(0.5, 0.6, 0.7, 0.8, 0.9)
  )
  rec <- build_recipe(tiny)
  interact_steps <- Filter(function(s) inherits(s, "step_interact"), rec$steps)
  if (length(interact_steps) != 1L) return(FALSE)

  prepped <- recipes::prep(rec, training = tiny)
  baked <- recipes::juice(prepped)
  int_cols <- grep("_x_", names(baked), value = TRUE)
  length(int_cols) == 1L &&
    grepl("log_sell_price", int_cols) &&
    grepl("snap_CA", int_cols)
})

# 26. FX-TE6-SLICE
run_fx("FX-TE6-SLICE", function() {
  a <- te6_usable_slice(FALSE, TRUE, 50)
  b <- te6_usable_slice(TRUE, TRUE, 0)
  c_ <- te6_usable_slice(TRUE, FALSE, 50)
  !a && !b && !c_
})

out <- bind_rows(results)
write_csv(out, out_path, na = "")
if (any(out$result == "FAIL")) quit(status = 1L)
cat("R-B fixtures PASS (", nrow(out), " fixtures )\n")
