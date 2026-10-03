# R-B judged-rule library. Every function implements exactly one locked
# design clause. Both the R-B pipeline and R-B's fixture harness call these
# functions; the fixture harness never re-implements a judged rule.
# Design of record: 08_CONSOLIDATED_CANDIDATE_v5_2 (sha256 2065773c...7859).
#
# r6 changes over r5 (library):
#   (1) assign_item_action() accepts both logical TRUE/FALSE (fixtures) and
#       integer 0L/1L (pipeline) for trust_eligible. r5 tested the argument
#       with isTRUE(), and isTRUE(1L) is FALSE, so every trusted item was
#       silently routed to hold_ne. Fixed by coercing with as.logical().
#   (2) assign_item_action() now returns pred_units_best (the model
#       prediction at the chosen candidate_price), so the pipeline does not
#       need to look up the list column per item. In hold_ne / unchanged
#       branches, pred_units_best equals the input pred_units_current.
#   No judged-rule change; no fixture-pack change.

# ---------------------------------------------------------------------------
# Eligibility (v5.2 §7.3, §17.R2)
# ---------------------------------------------------------------------------
compute_e_a <- function(n_price_changes_pre, units_365, zero_days_365) {
  (n_price_changes_pre >= 3L) &
    (units_365 >= 180L) &
    (zero_days_365 <= 182L)
}

compute_e_chg3 <- function(n_price_changes_pre) n_price_changes_pre >= 3L
compute_e_u180 <- function(units_365)           units_365 >= 180L
compute_e_z182 <- function(zero_days_365)       zero_days_365 <= 182L
compute_e_pw52 <- function(priced_weeks_pre)    priced_weeks_pre >= 52L
compute_e_cand <- function(n_candidates)        n_candidates >= 1L

# ---------------------------------------------------------------------------
# Current price (v5.2 §17.R3)
# ---------------------------------------------------------------------------
compute_current_price <- function(price_wk11617, price_wk11616) {
  list(
    current_price       = price_wk11617,
    current_price_11616 = price_wk11616,
    straddle_flag       = as.integer(!is.na(price_wk11617) & !is.na(price_wk11616) &
                                       price_wk11617 != price_wk11616)
  )
}

# ---------------------------------------------------------------------------
# Candidate band, integer-cent (v5.2 §17.R4)
# ---------------------------------------------------------------------------
band_ok <- function(Pc, P0) {
  pc <- as.integer(round(Pc * 100))
  p0 <- as.integer(round(P0 * 100))
  (4L * pc >= 3L * p0) & (4L * pc <= 5L * p0)
}

# ---------------------------------------------------------------------------
# Candidate cap ordering (v5.2 §17.R4)
# Order by round(abs(ln(Pc/P0)), 10) ascending, then Pc ascending.
# Distances are canonicalised to a 10-decimal string so that values equal
# at the 10th decimal are exact ties, and the tie resolves to lower price.
# ---------------------------------------------------------------------------
cap_candidates <- function(Pc, P0, max_n = 5L) {
  if (length(Pc) == 0L) return(numeric(0))
  dist_num <- round(abs(log(Pc / P0)), 10)
  dist_key <- sprintf("%.10f", dist_num)
  ord      <- order(dist_key, Pc, method = "radix")
  Pc[ord][seq_len(min(max_n, length(Pc)))]
}

# ---------------------------------------------------------------------------
# Event filter (v5.2 §17.R4)
# ---------------------------------------------------------------------------
event_filter <- function(Pc, price_weeks_by_price, event_types_by_week) {
  keep <- logical(length(Pc))
  for (i in seq_along(Pc)) {
    wks <- price_weeks_by_price[[i]]
    if (length(wks) != 1L) { keep[i] <- TRUE; next }
    ev <- event_types_by_week[[as.character(wks)]]
    keep[i] <- !any(ev %in% c("National", "Religious", "Sporting", "Cultural"))
  }
  Pc[keep]
}

# ---------------------------------------------------------------------------
# TE6 (v5.2 §7.7, OC-5 Option A)
# ---------------------------------------------------------------------------
te6_usable_slice <- function(e_a_reanchored_at_1913,
                             same_price_weeks_11613_11617,
                             realized_units_1914_1941) {
  isTRUE(e_a_reanchored_at_1913) &
    isTRUE(same_price_weeks_11613_11617) &
    (realized_units_1914_1941 > 0)
}

te6_option_a <- function(te6_usable_slice) as.integer(te6_usable_slice)

# ---------------------------------------------------------------------------
# Guardrail (v5.2 §17.R7, OC-3)
# ---------------------------------------------------------------------------
guardrail_pass <- function(rho, rho_min = 0.90) {
  !is.na(rho) & (rho >= rho_min)
}

# ---------------------------------------------------------------------------
# Cent rounding and legal test (v5.2 §17.R7)
# ---------------------------------------------------------------------------
cent_delta_rev <- function(Rc, R0) round(Rc, 2) - round(R0, 2)

legal_change <- function(guardrail_pass, cent_delta_rev) {
  guardrail_pass & (cent_delta_rev > 0)
}

# ---------------------------------------------------------------------------
# Item-level action assignment (v5.2 §17.R7)
#
# r6: trust_eligible may arrive as logical (fixtures) or integer 0L/1L
# (pipeline). It is coerced with as.logical() before the isTRUE() test so
# both forms are accepted. The return list includes pred_units_best: the
# model prediction at the chosen price (pred_units_candidate[best_idx] on
# a successful legal pick, or pred_units_current in every other branch).
# ---------------------------------------------------------------------------
assign_item_action <- function(trust_eligible,
                               pred_units_current,
                               candidate_prices,
                               pred_units_candidate,
                               pred_rev_candidate,
                               current_price,
                               rho_min = 0.90) {

  trust_eligible <- as.logical(trust_eligible)

  hold <- function() list(action = "hold_ne", candidate_price = current_price,
                          guardrail_pass = NA_integer_, legal_change = NA_integer_,
                          cent_delta_rev = NA_real_, delta_rev = NA_real_,
                          unit_ratio = NA_real_,
                          pred_units_best = pred_units_current)

  if (!isTRUE(trust_eligible))                           return(hold())
  if (is.na(current_price) || is.na(pred_units_current)) return(hold())
  if (pred_units_current == 0)                           return(hold())

  if (length(candidate_prices) == 0L) {
    return(list(action = "unchanged", candidate_price = current_price,
                guardrail_pass = NA_integer_, legal_change = 0L,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_,
                pred_units_best = pred_units_current))
  }

  stopifnot(length(candidate_prices) == length(pred_units_candidate),
            length(candidate_prices) == length(pred_rev_candidate))

  rho              <- pred_units_candidate / pred_units_current
  pred_rev_current <- pred_units_current * current_price
  guard            <- guardrail_pass(rho, rho_min)
  cdr              <- cent_delta_rev(pred_rev_candidate, pred_rev_current)
  legal            <- guard & (cdr > 0)

  if (!any(legal)) {
    return(list(action = "unchanged", candidate_price = current_price,
                guardrail_pass = as.integer(any(guard)),
                legal_change = 0L,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_,
                pred_units_best = pred_units_current))
  }

  delta_rev <- pred_rev_candidate - pred_rev_current
  legal_idx <- which(legal)
  best_idx  <- legal_idx[which.max(delta_rev[legal_idx])]
  best_pc   <- candidate_prices[best_idx]
  action <- if (best_pc > current_price) "raise"
            else if (best_pc < current_price) "cut"
            else "unchanged"

  list(action = action, candidate_price = best_pc,
       guardrail_pass = 1L, legal_change = 1L,
       cent_delta_rev = cdr[best_idx], delta_rev = delta_rev[best_idx],
       unit_ratio = rho[best_idx],
       pred_units_best = pred_units_candidate[best_idx])
}

# ---------------------------------------------------------------------------
# Backtest collapse (v5.2 §17.R8)
# ---------------------------------------------------------------------------
apply_backtest_collapse <- function(action, trust_eligible, backtest_accept) {
  if (isTRUE(backtest_accept == 0L)) {
    return(ifelse(as.logical(trust_eligible), "hold_ne", action))
  }
  action
}

# ---------------------------------------------------------------------------
# Ranking and capacity (v5.2 §17.R9, OC-4)
# Accepts either `pred_units_current` or `.pred_units_current`; no rule
# change, just name tolerance for the pipeline vs the fixture harness.
# ---------------------------------------------------------------------------
rank_qualifiers <- function(df, n_cap = 25L) {
  if (!"pred_units_current" %in% names(df)) {
    if (".pred_units_current" %in% names(df)) {
      df <- dplyr::rename(df, pred_units_current = ".pred_units_current")
    }
  }
  stopifnot(all(c("item_id","action","delta_rev","pred_units_current",
                  "n_price_changes_pre") %in% names(df)))
  q <- df[df$action %in% c("raise","cut"), , drop = FALSE]
  ord <- order(-q$delta_rev, -q$pred_units_current, -q$n_price_changes_pre,
               q$item_id, method = "radix")
  q <- q[ord, , drop = FALSE]
  q$rank_among_qualifiers <- seq_len(nrow(q))
  q$package_flag          <- as.integer(q$rank_among_qualifiers <= n_cap)
  q$below_line_flag       <- as.integer(q$rank_among_qualifiers >  n_cap)
  q
}

# ---------------------------------------------------------------------------
# Production functions shared with the fixture harness.
# ---------------------------------------------------------------------------

# §8.2 / §17.R6: horizon is d_(o+1) ... d_(o+28), daily grain.
horizon_days <- function(origin_d, n = 28L) seq.int(origin_d + 1L, origin_d + n)

# §17A.6: origin-anchored trailing units. df must have columns
# item_id, d, units.
anchor_trailing_units <- function(df_units, origin_d) {
  d_lo28 <- origin_d - 27L
  d_lo84 <- origin_d - 83L
  df_units %>%
    dplyr::filter(d >= d_lo84, d <= origin_d) %>%
    dplyr::group_by(item_id) %>%
    dplyr::summarise(
      trailing_28d_units = sum(units[d >= d_lo28]),
      trailing_84d_units = sum(units),
      .groups = "drop"
    )
}

# §17A.6: origin-anchored trailing mean price over [o-27, o].
anchor_trailing_price <- function(df_price, origin_d) {
  d_lo28 <- origin_d - 27L
  df_price %>%
    dplyr::filter(d >= d_lo28, d <= origin_d, !is.na(sell_price)) %>%
    dplyr::group_by(item_id) %>%
    dplyr::summarise(
      trailing_28d_mean_price = mean(sell_price),
      .groups = "drop"
    )
}

# §17A.5: the allowed feature list.
RB_ALLOWED_FEATURES <- c(
  "log_sell_price", "wday", "month", "snap_CA", "event_type_1", "event_any",
  "is_memorial_day_window", "is_nba_finals",
  "trailing_28d_units", "trailing_84d_units", "trailing_28d_mean_price",
  "dept_id", "item_mean_log1p_units"
)

# §8.6 / §17A.3: fixed factor references.
prep_factors <- function(df) {
  df %>%
    dplyr::mutate(
      wday         = factor(wday, levels = 1:7),
      month        = factor(month, levels = 1:12),
      dept_id      = factor(dept_id, levels = c("FOODS_3","FOODS_1","FOODS_2",
                                                "HOUSEHOLD_1","HOUSEHOLD_2")),
      event_type_1 = factor(tidyr::replace_na(event_type_1, "none"),
                            levels = c("none","Cultural","National",
                                       "Religious","Sporting"))
    )
}

# §17A.3: recipe order = log price -> dummies -> normalize -> exactly one
# interaction (scaled log_sell_price x snap_CA).
build_recipe <- function(train_df) {
  recipes::recipe(
    target_units ~ log_sell_price + wday + month + snap_CA + event_type_1 +
      event_any + is_memorial_day_window + is_nba_finals +
      trailing_28d_units + trailing_84d_units + trailing_28d_mean_price +
      dept_id + item_mean_log1p_units,
    data = train_df) %>%
    recipes::step_dummy(recipes::all_nominal_predictors(), one_hot = FALSE) %>%
    recipes::step_normalize(log_sell_price, trailing_28d_units, trailing_84d_units,
                            trailing_28d_mean_price, item_mean_log1p_units) %>%
    recipes::step_interact(~ log_sell_price:snap_CA)
}
