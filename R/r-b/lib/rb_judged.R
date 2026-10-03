# R-B judged-rule library. Every function implements exactly one locked
# design clause. Both the R-B pipeline and R-B's fixture harness call these
# functions; the fixture harness never re-implements a judged rule.
# Design of record: 08_CONSOLIDATED_CANDIDATE_v5_2 (sha256 2065773c...7859).

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
    current_price      = price_wk11617,
    current_price_11616 = price_wk11616,
    straddle_flag      = as.integer(!is.na(price_wk11617) & !is.na(price_wk11616) &
                                      price_wk11617 != price_wk11616)
  )
}

# ---------------------------------------------------------------------------
# Candidate band, integer-cent (v5.2 §17.R4)
# 100*Pc >= 75*P0  <->  4*Pc_cents >= 3*P0_cents
# 100*Pc <= 125*P0 <->  4*Pc_cents <= 5*P0_cents
# ---------------------------------------------------------------------------
band_ok <- function(Pc, P0) {
  pc <- as.integer(round(Pc * 100))
  p0 <- as.integer(round(P0 * 100))
  (4L * pc >= 3L * p0) & (4L * pc <= 5L * p0)
}

# ---------------------------------------------------------------------------
# Candidate cap ordering (v5.2 §17.R4)
# ---------------------------------------------------------------------------
cap_candidates <- function(Pc, P0, max_n = 5L) {
  if (length(Pc) == 0L) return(numeric(0))
  dist <- round(abs(log(Pc / P0)), 10)
  ord  <- order(dist, Pc, method = "radix")
  Pc[ord][seq_len(min(max_n, length(Pc)))]
}

# ---------------------------------------------------------------------------
# Event filter (v5.2 §17.R4)
# Inputs: numeric vector of Pc already in-band; a function week_events(wk)
# returning character(0) or one of {"National","Religious","Sporting","Cultural"}.
# Applied *before* the cap. Returns Pc to keep.
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
# Single-item API used by the pipeline and by the fixtures.
# ---------------------------------------------------------------------------
assign_item_action <- function(trust_eligible,
                               pred_units_current,
                               candidate_prices,
                               pred_units_candidate,
                               pred_rev_candidate,
                               current_price,
                               rho_min = 0.90) {
  if (!isTRUE(trust_eligible)) {
    return(list(action = "hold_ne", candidate_price = current_price,
                guardrail_pass = NA_integer_, legal_change = NA_integer_,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_))
  }
  if (is.na(pred_units_current) || pred_units_current == 0) {
    return(list(action = "hold_ne", candidate_price = current_price,
                guardrail_pass = NA_integer_, legal_change = NA_integer_,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_))
  }
  if (length(candidate_prices) == 0L) {
    return(list(action = "unchanged", candidate_price = current_price,
                guardrail_pass = NA_integer_, legal_change = 0L,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_))
  }
  pred_rev_current <- pred_units_current * current_price
  rho    <- pred_units_candidate / pred_units_current
  cdr    <- cent_delta_rev(pred_rev_candidate, pred_rev_current)
  guard  <- guardrail_pass(rho, rho_min)
  legal  <- legal_change(guard, cdr)
  if (!any(legal)) {
    return(list(action = "unchanged", candidate_price = current_price,
                guardrail_pass = as.integer(any(guard)), legal_change = 0L,
                cent_delta_rev = NA_real_, delta_rev = NA_real_,
                unit_ratio = NA_real_))
  }
  delta_rev <- pred_rev_candidate - pred_rev_current
  legal_idx <- which(legal)
  best_idx  <- legal_idx[which.max(delta_rev[legal_idx])]
  best_pc   <- candidate_prices[best_idx]
  action <- if (best_pc > current_price) "raise" else if (best_pc < current_price) "cut" else "unchanged"
  list(action = action, candidate_price = best_pc,
       guardrail_pass = 1L, legal_change = 1L,
       cent_delta_rev = cdr[best_idx], delta_rev = delta_rev[best_idx],
       unit_ratio = rho[best_idx])
}

# ---------------------------------------------------------------------------
# Backtest collapse (v5.2 §17.R8)
# ---------------------------------------------------------------------------
apply_backtest_collapse <- function(action, trust_eligible, backtest_accept) {
  if (isTRUE(backtest_accept == 0L)) {
    return(ifelse(trust_eligible, "hold_ne", action))
  }
  action
}

# ---------------------------------------------------------------------------
# Ranking and capacity (v5.2 §17.R9, OC-4)
# ---------------------------------------------------------------------------
rank_qualifiers <- function(df, n_cap = 25L) {
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
