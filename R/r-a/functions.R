# PRICEPOINT-001 Stage 4 R-A production functions
# Independent judged path. No database connectivity.

PP <- list(
  run_role = "R-A",
  departments = c("FOODS_1", "FOODS_2", "FOODS_3", "HOUSEHOLD_1", "HOUSEHOLD_2"),
  origin_d = 1941L,
  current_week = 11617L,
  twin_week = 11616L,
  horizon_d = 1942:1969,
  backtest_origin_d = 1913L,
  backtest_current_week = 11613L,
  stability_origin_d = 1885L,
  stability_current_week = 11609L,
  rho_min = 0.90,
  candidate_cap = 5L,
  capacity_cap = 25L,
  seed = 20160522L,
  penalty_grid = 10^seq(-4, 1, length.out = 50),
  expected_manifest_sha256 = "13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68",
  expected_freeze_record_sha256 = "51db6b850c222731929b9fb7402fb3c4c7bf536c7b01229a63fd0493cebc7954",
  expected_lineage = c(
    snapshot_id = "121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38",
    source_version = "M5 raw tables in MySQL schema pricepoint (server 8.0.46), snapshot record sha256 121341c12616c808643ca7a6bff48d7346963050dbee81fd4762cd7500666a38",
    observation_boundary_d = "1941",
    observation_boundary_date = "2016-05-22",
    design_id = "PRICEPOINT-001-S3-v1",
    ml_mode = "A",
    fixture_pack_sha256 = "da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2",
    sql_extract_sha256 = "13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68",
    capacity_stance = "hard_attention_budget"
  )
)

parse_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  out <- list(
    extract_dir = "C:/Users/Mark/Documents/R Working Directory/pricepoint-stage4-work/extract",
    out_dir = "C:/Users/Mark/Documents/R Working Directory/pricepoint-stage4-work/out/r-a",
    fixture_out = "validation/fixtures/r_a_fixture_results.csv"
  )
  i <- 1L
  while (i <= length(args)) {
    arg <- args[[i]]
    if (!startsWith(arg, "--")) stop("Unknown positional argument: ", arg)
    if (grepl("=", arg, fixed = TRUE)) {
      pair <- strsplit(sub("^--", "", arg), "=", fixed = TRUE)[[1]]
      key <- gsub("-", "_", pair[[1]], fixed = TRUE)
      value <- paste(pair[-1], collapse = "=")
      i <- i + 1L
    } else {
      key <- gsub("-", "_", sub("^--", "", arg), fixed = TRUE)
      if (i == length(args)) stop("Missing value for ", arg)
      value <- args[[i + 1L]]
      i <- i + 2L
    }
    if (!key %in% names(out)) stop("Unknown option --", gsub("_", "-", key, fixed = TRUE))
    out[[key]] <- value
  }
  out
}

sha256_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

read_key_value_file <- function(path) {
  x <- readLines(path, warn = FALSE, encoding = "UTF-8")
  x <- x[nzchar(x)]
  pos <- regexpr("=", x, fixed = TRUE)
  if (any(pos < 1L)) stop("Malformed key=value line in ", path)
  keys <- substr(x, 1L, pos - 1L)
  vals <- substring(x, pos + 1L)
  stats::setNames(vals, keys)
}

# M2:Lineage field mapping
verify_extract_integrity <- function(extract_dir) {
  manifest_path <- file.path(extract_dir, "extract_manifest.txt")
  freeze_path <- file.path(extract_dir, "extract_freeze_record.txt")
  if (!file.exists(manifest_path)) stop("Missing extract_manifest.txt")
  if (!file.exists(freeze_path)) stop("Missing extract_freeze_record.txt")

  manifest_hash <- sha256_file(manifest_path)
  if (!identical(manifest_hash, PP$expected_manifest_sha256)) {
    stop("extract_manifest.txt sha256 mismatch: ", manifest_hash)
  }
  freeze_hash <- sha256_file(freeze_path)
  if (!identical(freeze_hash, PP$expected_freeze_record_sha256)) {
    stop("extract_freeze_record.txt sha256 mismatch: ", freeze_hash)
  }

  lines <- readLines(manifest_path, warn = FALSE, encoding = "UTF-8")
  if (length(lines) != 3L || any(!nzchar(lines))) stop("Manifest must contain exactly three nonblank lines")
  parts <- strsplit(lines, "\\s*\\|\\s*", perl = TRUE)
  if (any(lengths(parts) != 3L)) stop("Malformed extract manifest")
  entries <- tibble::tibble(
    rel_path = vapply(parts, `[[`, character(1), 1L),
    expected_bytes = as.numeric(vapply(parts, `[[`, character(1), 2L)),
    expected_sha256 = tolower(vapply(parts, `[[`, character(1), 3L))
  )
  if (!identical(entries$rel_path, sort(entries$rel_path))) stop("Manifest paths are not lexicographically sorted")
  expected_names <- c("calendar.tsv", "prices.tsv", "sales_long.tsv")
  if (!setequal(basename(entries$rel_path), expected_names)) stop("Manifest does not identify the three locked extract data files")

  purrr::pwalk(entries, function(rel_path, expected_bytes, expected_sha256) {
    p <- file.path(extract_dir, rel_path)
    if (!file.exists(p)) stop("Missing extract file: ", p)
    actual_bytes <- unname(file.info(p)$size)
    if (!identical(as.numeric(actual_bytes), expected_bytes)) {
      stop("Byte-length mismatch for ", rel_path, ": expected ", expected_bytes, ", got ", actual_bytes)
    }
    actual_sha <- sha256_file(p)
    if (!identical(actual_sha, expected_sha256)) stop("sha256 mismatch for ", rel_path)
  })

  lineage <- read_key_value_file(freeze_path)
  missing_keys <- setdiff(names(PP$expected_lineage), names(lineage))
  if (length(missing_keys)) stop("Freeze record missing lineage keys: ", paste(missing_keys, collapse = ", "))
  bad <- names(PP$expected_lineage)[lineage[names(PP$expected_lineage)] != PP$expected_lineage]
  if (length(bad)) stop("Freeze-record lineage mismatch for: ", paste(bad, collapse = ", "))
  lineage[names(PP$expected_lineage)]
}

add_lineage <- function(df, lineage) {
  for (nm in names(PP$expected_lineage)) df[[nm]] <- unname(lineage[[nm]])
  df$observation_boundary_d <- as.integer(df$observation_boundary_d)
  df
}

read_sources <- function(extract_dir) {
  sales <- readr::read_tsv(
    file.path(extract_dir, "sales_long.tsv"),
    na = "NULL", quote = "", progress = FALSE, show_col_types = FALSE,
    col_select = c(item_id, dept_id, cat_id, store_id, d, units, wm_yr_wk),
    col_types = readr::cols(
      item_id = readr::col_character(), dept_id = readr::col_character(),
      cat_id = readr::col_character(), store_id = readr::col_character(),
      d = readr::col_integer(), units = readr::col_integer(), wm_yr_wk = readr::col_integer()
    )
  )
  prices <- readr::read_tsv(
    file.path(extract_dir, "prices.tsv"),
    na = "NULL", quote = "", progress = FALSE, show_col_types = FALSE,
    col_types = readr::cols(
      store_id = readr::col_character(), item_id = readr::col_character(),
      wm_yr_wk = readr::col_integer(), sell_price = readr::col_double()
    )
  )
  calendar <- readr::read_tsv(
    file.path(extract_dir, "calendar.tsv"),
    na = "NULL", quote = "", progress = FALSE, show_col_types = FALSE,
    col_select = c(date, wm_yr_wk, wday, month, year, d, event_name_1, event_type_1, event_name_2, event_type_2, snap_CA),
    col_types = readr::cols(
      date = readr::col_date(format = "%Y-%m-%d"), wm_yr_wk = readr::col_integer(),
      wday = readr::col_integer(), month = readr::col_integer(), year = readr::col_integer(),
      d = readr::col_integer(), event_name_1 = readr::col_character(), event_type_1 = readr::col_character(),
      event_name_2 = readr::col_character(), event_type_2 = readr::col_character(), snap_CA = readr::col_integer()
    )
  )
  if (nrow(readr::problems(sales)) || nrow(readr::problems(prices)) || nrow(readr::problems(calendar))) {
    stop("readr parsing problems found in frozen extract")
  }
  list(sales = sales, prices = prices, calendar = calendar)
}

clean_chr <- function(x) {
  x <- trimws(x)
  x[is.na(x) | x == ""] <- NA_character_
  x
}

calendar_features <- function(calendar) {
  c0 <- calendar %>%
    dplyr::mutate(
      event_name_1 = clean_chr(event_name_1), event_type_1 = clean_chr(event_type_1),
      event_name_2 = clean_chr(event_name_2), event_type_2 = clean_chr(event_type_2),
      event_type_1 = tidyr::replace_na(event_type_1, "none"),
      event_any = as.integer(!is.na(event_name_1) | !is.na(event_name_2)),
      nba_start = event_name_1 == "NBAFinalsStart" | event_name_2 == "NBAFinalsStart",
      nba_end = event_name_1 == "NBAFinalsEnd" | event_name_2 == "NBAFinalsEnd",
      memorial = event_name_1 == "MemorialDay" | event_name_2 == "MemorialDay"
    )

  memorial_dates <- c0 %>%
    dplyr::filter(memorial %in% TRUE) %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(memorial_date = min(date), .groups = "drop")

  nba_bounds <- c0 %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(
      nba_start_date = if (any(nba_start %in% TRUE)) min(date[nba_start %in% TRUE]) else as.Date(NA),
      nba_end_date = if (any(nba_end %in% TRUE)) max(date[nba_end %in% TRUE]) else as.Date(NA),
      .groups = "drop"
    )

  c0 %>%
    dplyr::left_join(memorial_dates, by = "year") %>%
    dplyr::left_join(nba_bounds, by = "year") %>%
    dplyr::mutate(
      is_memorial_day_window = as.integer(!is.na(memorial_date) & abs(as.integer(date - memorial_date)) <= 1L),
      is_nba_finals = as.integer(
        nba_start %in% TRUE | nba_end %in% TRUE |
          (!is.na(nba_start_date) & !is.na(nba_end_date) & date >= nba_start_date & date <= nba_end_date)
      )
    ) %>%
    dplyr::select(d, date, wm_yr_wk, wday, month, year, event_name_1, event_type_1, event_name_2, event_type_2,
                  snap_CA, event_any, is_memorial_day_window, is_nba_finals)
}

# M2:leakage
build_panel <- function(sales, prices, calendar_f) {
  if (any(sales$d > PP$origin_d)) stop("Sales leakage: d > 1941 present")
  prices_judged <- prices %>%
    dplyr::filter(wm_yr_wk <= PP$current_week, sell_price > 0) %>%
    dplyr::mutate(price_cents = as.integer(round(sell_price * 100)))
  if (any(prices_judged$wm_yr_wk >= 11618L)) stop("Internal leakage quarantine failed")

  before <- nrow(sales)
  panel <- sales %>%
    dplyr::left_join(calendar_f, by = "d", suffix = c("_sales", "_cal"))
  if (nrow(panel) != before) stop("Calendar join changed SALES_LONG row count")
  if (any(panel$wm_yr_wk_sales != panel$wm_yr_wk_cal, na.rm = TRUE)) stop("Calendar week mismatch against SALES_LONG")
  panel <- panel %>%
    dplyr::select(-wm_yr_wk_cal) %>%
    dplyr::rename(wm_yr_wk = wm_yr_wk_sales) %>%
    dplyr::left_join(
      prices_judged %>% dplyr::select(store_id, item_id, wm_yr_wk, sell_price, price_cents),
      by = c("store_id", "item_id", "wm_yr_wk")
    )
  if (nrow(panel) != before) stop("Price join changed item-day row count")
  panel
}


# M2:E_A conjuncts
apply_ea_flags <- function(df) {
  df %>%
    dplyr::mutate(
      e_chg3 = as.integer(n_price_changes_pre >= 3L),
      e_u180 = as.integer(units_365 >= 180),
      e_z182 = as.integer(zero_days_365 <= 182L)
    )
}

# M2:priced_weeks
apply_pw52_flag <- function(df) {
  df %>% dplyr::mutate(e_pw52 = as.integer(priced_weeks_pre >= 52L))
}

# M2:candidate-exists
# M2:TE6
apply_trust_flags <- function(df) {
  df %>%
    dplyr::mutate(
      e_cand = tidyr::replace_na(e_cand, 0L),
      te6 = tidyr::replace_na(te6, 0L),
      trust_eligible = as.integer(e_chg3 == 1L & e_u180 == 1L & e_z182 == 1L & e_pw52 == 1L & e_cand == 1L & te6 == 1L)
    )
}

compute_training_trails <- function(panel) {
  panel %>%
    dplyr::arrange(item_id, d) %>%
    dplyr::group_by(item_id) %>%
    dplyr::mutate(
      .cu = cumsum(as.double(units)),
      .cp = cumsum(tidyr::replace_na(sell_price, 0)),
      .cn = cumsum(!is.na(sell_price)),
      .u1 = dplyr::lag(.cu, 1L, default = 0),
      .u29 = dplyr::lag(.cu, 29L, default = 0),
      .u85 = dplyr::lag(.cu, 85L, default = 0),
      .p1 = dplyr::lag(.cp, 1L, default = 0),
      .p29 = dplyr::lag(.cp, 29L, default = 0),
      .n1 = dplyr::lag(.cn, 1L, default = 0),
      .n29 = dplyr::lag(.cn, 29L, default = 0),
      trailing_28d_units = dplyr::if_else(d >= 29L, .u1 - .u29, NA_real_),
      trailing_84d_units = dplyr::if_else(d >= 85L, .u1 - .u85, NA_real_),
      .price_sum_28 = .p1 - .p29,
      .price_n_28 = .n1 - .n29,
      trailing_28d_mean_price = dplyr::if_else(d >= 29L & .price_n_28 > 0, .price_sum_28 / .price_n_28, NA_real_)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-dplyr::starts_with("."))
}

week_order <- function(calendar_f) {
  calendar_f %>%
    dplyr::distinct(wm_yr_wk) %>%
    dplyr::arrange(wm_yr_wk) %>%
    dplyr::mutate(week_ordinal = dplyr::row_number())
}

# M2:week-ordinal rule
last_n_week_ids <- function(calendar_f, end_week, n) {
  w <- week_order(calendar_f)
  end_ord <- w$week_ordinal[match(end_week, w$wm_yr_wk)]
  if (length(end_ord) != 1L || is.na(end_ord)) stop("End week not in calendar")
  lo <- end_ord - as.integer(n) + 1L
  if (lo < 1L) stop("Requested week window precedes calendar")
  w$wm_yr_wk[w$week_ordinal >= lo & w$week_ordinal <= end_ord]
}

compute_eligibility_metrics <- function(sales, prices, calendar_f, origin_d, current_week) {
  p <- prices %>%
    dplyr::filter(wm_yr_wk <= current_week, sell_price > 0) %>%
    dplyr::mutate(price_cents = as.integer(round(sell_price * 100))) %>%
    dplyr::left_join(week_order(calendar_f), by = "wm_yr_wk") %>%
    dplyr::arrange(item_id, week_ordinal)
  p_stats <- p %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(
      n_price_changes_pre = sum(price_cents != dplyr::lag(price_cents), na.rm = TRUE),
      n_distinct_prices_pre = dplyr::n_distinct(price_cents),
      priced_weeks_pre = dplyr::n(),
      first_priced_wk = wm_yr_wk[which.min(week_ordinal)],
      .groups = "drop"
    )
  s_stats <- sales %>%
    dplyr::group_by(store_id, item_id, dept_id, cat_id) %>%
    dplyr::summarise(
      units_365 = sum(units[d >= origin_d - 364L & d <= origin_d]),
      zero_days_365 = sum(units[d >= origin_d - 364L & d <= origin_d] == 0L),
      first_positive_d = if (any(units > 0L)) min(d[units > 0L]) else NA_integer_,
      .groups = "drop"
    )
  first_list <- sales %>%
    dplyr::filter(d <= origin_d) %>%
    dplyr::left_join(
      p %>% dplyr::select(store_id, item_id, wm_yr_wk) %>% dplyr::distinct() %>% dplyr::mutate(.priced = TRUE),
      by = c("store_id", "item_id", "wm_yr_wk")
    ) %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(list_start_d = if (any(.priced %in% TRUE)) min(d[.priced %in% TRUE]) else NA_integer_, .groups = "drop")

  s_stats %>%
    dplyr::left_join(p_stats, by = c("store_id", "item_id")) %>%
    dplyr::left_join(first_list, by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      n_price_changes_pre = tidyr::replace_na(n_price_changes_pre, 0L),
      n_distinct_prices_pre = tidyr::replace_na(n_distinct_prices_pre, 0L),
      priced_weeks_pre = tidyr::replace_na(priced_weeks_pre, 0L)
    ) %>%
    apply_ea_flags() %>%
    apply_pw52_flag()
}

# M2:current price
current_price_fields <- function(prices, current_week = PP$current_week, twin_week = PP$twin_week) {
  p0 <- prices %>%
    dplyr::filter(wm_yr_wk == current_week, sell_price > 0) %>%
    dplyr::transmute(store_id, item_id, current_price = sell_price)
  pt <- prices %>%
    dplyr::filter(wm_yr_wk == twin_week, sell_price > 0) %>%
    dplyr::transmute(store_id, item_id, current_price_11616 = sell_price)
  dplyr::full_join(p0, pt, by = c("store_id", "item_id")) %>%
    dplyr::mutate(straddle_flag = as.integer(!is.na(current_price) & !is.na(current_price_11616) & current_price != current_price_11616))
}

item_week_event_evidence <- function(panel, origin_d) {
  panel %>%
    dplyr::filter(d <= origin_d, !is.na(sell_price)) %>%
    dplyr::group_by(store_id, item_id, wm_yr_wk, price_cents) %>%
    dplyr::summarise(
      event_week = any(event_type_1 %in% c("National", "Religious", "Sporting", "Cultural")),
      .groups = "drop"
    )
}

# M2:band
# M2:event filter
# M2:cap/tie
build_candidates <- function(prices, panel, universe_prices, origin_d, current_week, cap = PP$candidate_cap) {
  hist <- prices %>%
    dplyr::filter(wm_yr_wk <= current_week, sell_price > 0) %>%
    dplyr::mutate(price_cents = as.integer(round(sell_price * 100)))
  events <- item_week_event_evidence(panel, origin_d)
  hist_weeks <- hist %>%
    dplyr::left_join(events, by = c("store_id", "item_id", "wm_yr_wk", "price_cents")) %>%
    dplyr::mutate(event_week = tidyr::replace_na(event_week, FALSE))

  level_stats <- hist_weeks %>%
    dplyr::group_by(store_id, item_id, price_cents) %>%
    dplyr::summarise(
      candidate_price = dplyr::first(sell_price),
      n_weeks_at_price = dplyr::n_distinct(wm_yr_wk),
      sole_week_event = n_weeks_at_price == 1L && any(event_week),
      .groups = "drop"
    )

  pre_event <- level_stats %>%
    dplyr::inner_join(
      universe_prices %>% dplyr::select(store_id, item_id, current_price),
      by = c("store_id", "item_id")
    ) %>%
    dplyr::mutate(
      current_cents = as.integer(round(current_price * 100)),
      in_band = 100L * price_cents >= 75L * current_cents & 100L * price_cents <= 125L * current_cents
    ) %>%
    dplyr::filter(price_cents > 0L, price_cents != current_cents, in_band)

  counts_pre <- pre_event %>%
    dplyr::count(store_id, item_id, name = "n_candidates_pre_event_filter")
  filtered_counts <- pre_event %>%
    dplyr::filter(sole_week_event) %>%
    dplyr::count(store_id, item_id, name = "n_candidates_event_filtered")

  capped <- pre_event %>%
    dplyr::filter(!sole_week_event) %>%
    dplyr::mutate(abs_log_dist = round(abs(log(candidate_price / current_price)), 10)) %>%
    dplyr::arrange(store_id, item_id, abs_log_dist, candidate_price) %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::mutate(rank_in_cap = dplyr::row_number()) %>%
    dplyr::filter(rank_in_cap <= cap) %>%
    dplyr::ungroup() %>%
    dplyr::select(store_id, item_id, candidate_price, abs_log_dist, rank_in_cap)

  per_item <- universe_prices %>%
    dplyr::select(store_id, item_id) %>%
    dplyr::left_join(counts_pre, by = c("store_id", "item_id")) %>%
    dplyr::left_join(filtered_counts, by = c("store_id", "item_id")) %>%
    dplyr::left_join(capped %>% dplyr::count(store_id, item_id, name = "n_candidates"), by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      n_candidates_pre_event_filter = tidyr::replace_na(n_candidates_pre_event_filter, 0L),
      n_candidates_event_filtered = tidyr::replace_na(n_candidates_event_filtered, 0L),
      n_candidates = tidyr::replace_na(n_candidates, 0L),
      e_cand = as.integer(n_candidates >= 1L)
    )
  list(candidates = capped, per_item = per_item)
}

te6_slice_flags <- function(ea_reanchored, stable_price, realized_units) {
  as.integer(ea_reanchored %in% TRUE & stable_price %in% TRUE & realized_units > 0)
}

compute_live_te6_inputs <- function(sales, prices, calendar_f, panel) {
  metrics_1913 <- compute_eligibility_metrics(sales, prices, calendar_f, 1913L, 11613L) %>%
    dplyr::mutate(ea_reanchored = e_chg3 == 1L & e_u180 == 1L & e_z182 == 1L)
  stable <- prices %>%
    dplyr::filter(wm_yr_wk %in% 11613:11617, sell_price > 0) %>%
    dplyr::mutate(price_cents = as.integer(round(sell_price * 100))) %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(stable_price = dplyr::n_distinct(wm_yr_wk) == 5L && dplyr::n_distinct(price_cents) == 1L, .groups = "drop")
  realized <- sales %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(realized_units_1914_1941 = sum(units[d >= 1914L & d <= 1941L]), .groups = "drop")
  metrics_1913 %>%
    dplyr::select(store_id, item_id, dept_id, ea_reanchored) %>%
    dplyr::left_join(stable, by = c("store_id", "item_id")) %>%
    dplyr::left_join(realized, by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      stable_price = tidyr::replace_na(stable_price, FALSE),
      te6_usable_slice = te6_slice_flags(ea_reanchored, stable_price, realized_units_1914_1941),
      te6 = te6_usable_slice
    )
}

# M2:Full analytical-unit universe
# M2:Non-enrolling actions
# M2:Capacity / simulation labels
build_universe_base <- function(sales, prices, calendar_f, panel) {
  ids <- sales %>%
    dplyr::filter(store_id == "CA_1", dept_id %in% PP$departments) %>%
    dplyr::distinct(store_id, item_id, dept_id, cat_id)
  eligibility <- compute_eligibility_metrics(sales, prices, calendar_f, PP$origin_d, PP$current_week)
  current <- current_price_fields(prices)
  base <- ids %>%
    dplyr::left_join(eligibility, by = c("store_id", "item_id", "dept_id", "cat_id")) %>%
    dplyr::left_join(current, by = c("store_id", "item_id")) %>%
    dplyr::mutate(in_universe = 1L)
  cand <- build_candidates(prices, panel, base, PP$origin_d, PP$current_week)
  te6 <- compute_live_te6_inputs(sales, prices, calendar_f, panel)
  base <- base %>%
    dplyr::left_join(cand$per_item, by = c("store_id", "item_id")) %>%
    dplyr::left_join(te6 %>% dplyr::select(store_id, item_id, te6_usable_slice, te6), by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      e_cand = tidyr::replace_na(e_cand, 0L),
      te6_usable_slice = tidyr::replace_na(te6_usable_slice, 0L),
      te6 = tidyr::replace_na(te6, 0L)
    ) %>%
    apply_trust_flags()
  list(universe = base, candidates = cand$candidates, candidate_audit = cand$per_item)
}

factor_levels_from_calendar <- function(calendar_f) {
  list(
    wday = as.character(1:7),
    month = as.character(1:12),
    dept_id = c("FOODS_3", setdiff(PP$departments, "FOODS_3")),
    event_type_1 = c("none", sort(setdiff(unique(calendar_f$event_type_1), "none")))
  )
}

factorize_frame <- function(df, levels) {
  df %>%
    dplyr::mutate(
      wday = factor(as.character(wday), levels = levels$wday),
      month = factor(as.character(month), levels = levels$month),
      dept_id = factor(as.character(dept_id), levels = levels$dept_id),
      event_type_1 = factor(as.character(event_type_1), levels = levels$event_type_1)
    )
}

# M2:recipe
make_model_recipe <- function(data) {
  recipes::recipe(
    target ~ sell_price + wday + month + snap_CA + event_type_1 + event_any +
      is_memorial_day_window + is_nba_finals + trailing_28d_units + trailing_84d_units +
      trailing_28d_mean_price + dept_id + item_mean_log1p_units,
    data = data
  ) %>%
    recipes::step_mutate(log_sell_price = log(sell_price)) %>%
    recipes::step_rm(sell_price) %>%
    recipes::step_dummy(wday, month, dept_id, event_type_1, one_hot = FALSE) %>%
    recipes::step_normalize(log_sell_price, trailing_28d_units, trailing_84d_units,
                            trailing_28d_mean_price, item_mean_log1p_units) %>%
    recipes::step_interact(terms = ~ log_sell_price:snap_CA)
}

prepare_model_data <- function(panel_with_trails, origin_d, levels) {
  priced <- panel_with_trails %>%
    dplyr::filter(d <= origin_d, !is.na(sell_price), sell_price > 0)
  item_stats <- priced %>%
    dplyr::group_by(item_id) %>%
    dplyr::summarise(
      item_mean_log1p_units = mean(log1p(units)),
      n_positive = sum(units > 0L),
      p99_units = if (any(units > 0L)) stats::quantile(units[units > 0L], probs = 0.99, type = 7, names = FALSE) else NA_real_,
      .groups = "drop"
    )
  if (any(is.na(item_stats$p99_units))) stop("At least one priced training item has no positive training day; §15.1 does not specify its p99 target cap")
  dat <- priced %>%
    dplyr::left_join(item_stats, by = "item_id") %>%
    dplyr::mutate(target = pmin(as.double(units), p99_units))
  feature_cols <- c("sell_price", "wday", "month", "snap_CA", "event_type_1", "event_any",
                    "is_memorial_day_window", "is_nba_finals", "trailing_28d_units", "trailing_84d_units",
                    "trailing_28d_mean_price", "dept_id", "item_mean_log1p_units")
  na_flag <- !stats::complete.cases(dat[, feature_cols])
  n_feature_na_rows <- sum(na_flag)
  dat <- dat[!na_flag, , drop = FALSE] %>% factorize_frame(levels)
  list(data = dat, item_stats = item_stats %>% dplyr::select(item_id, item_mean_log1p_units), n_feature_na_rows = n_feature_na_rows,
       n_training_rows = nrow(dat))
}

locked_fold_cuts <- function(D) {
  if (D == 1941L) return(list(c(1L, 388L), c(389L, 776L), c(777L, 1164L), c(1165L, 1552L), c(1553L, 1941L)))
  if (D == 1913L) return(list(c(1L, 382L), c(383L, 765L), c(766L, 1147L), c(1148L, 1530L), c(1531L, 1913L)))
  if (D == 1885L) return(list(c(1L, 377L), c(378L, 754L), c(755L, 1131L), c(1132L, 1508L), c(1509L, 1885L)))
  stop("No locked fold cuts for D=", D)
}

make_contiguous_rset <- function(data, D) {
  fold_id <- ceiling(5 * data$d / D)
  fold_id[fold_id < 1L] <- 1L
  fold_id[fold_id > 5L] <- 5L
  expected <- locked_fold_cuts(D)
  for (k in 1:5) {
    ds <- sort(unique(data$d[fold_id == k]))
    if (length(ds) && (min(ds) < expected[[k]][1] || max(ds) > expected[[k]][2])) stop("Fold construction violated locked d cuts")
  }
  splits <- purrr::map(1:5, function(k) {
    rsample::make_splits(list(analysis = which(fold_id != k), assessment = which(fold_id == k)), data)
  })
  rsample::manual_rset(splits, ids = paste0("Fold", 1:5))
}

# M2:Mode A scoring
fit_mode_a <- function(panel_with_trails, origin_d, levels) {
  prepared <- prepare_model_data(panel_with_trails, origin_d, levels)
  dat <- prepared$data
  set.seed(PP$seed)
  rec <- make_model_recipe(dat)
  spec <- parsnip::linear_reg(mode = "regression", penalty = tune::tune(), mixture = 0.5) %>%
    parsnip::set_engine("glmnet", standardize = FALSE)
  wf <- workflows::workflow() %>% workflows::add_recipe(rec) %>% workflows::add_model(spec)
  rset <- make_contiguous_rset(dat, origin_d)
  grid <- tibble::tibble(penalty = PP$penalty_grid)
  tuned <- tune::tune_grid(
    wf, resamples = rset, grid = grid,
    metrics = yardstick::metric_set(yardstick::rmse),
    control = tune::control_grid(save_pred = FALSE, verbose = TRUE, allow_par = FALSE)
  )
  metrics <- tune::collect_metrics(tuned, summarize = TRUE) %>%
    dplyr::filter(.metric == "rmse")
  best_mean <- min(metrics$mean, na.rm = TRUE)
  best <- metrics %>%
    dplyr::filter(mean == best_mean) %>%
    dplyr::arrange(dplyr::desc(penalty)) %>%
    dplyr::slice(1)
  selected <- best$penalty[[1]]
  grid_index <- match(selected, PP$penalty_grid)
  if (is.na(grid_index)) stop("Selected penalty is not one of the locked 50 grid values")
  final_wf <- tune::finalize_workflow(wf, tibble::tibble(penalty = selected))
  set.seed(PP$seed)
  fit <- parsnip::fit(final_wf, data = dat)
  list(
    fit = fit, penalty_selected = selected, penalty_grid_index = as.integer(grid_index),
    fold_cuts = locked_fold_cuts(origin_d), n_feature_na_rows = prepared$n_feature_na_rows,
    n_training_rows = prepared$n_training_rows, item_stats = prepared$item_stats, tuning_metrics = metrics
  )
}

# M2:trailing anchoring
origin_anchors <- function(panel, origin_d, item_stats) {
  a <- panel %>%
    dplyr::filter(d <= origin_d) %>%
    dplyr::group_by(store_id, item_id, dept_id) %>%
    dplyr::summarise(
      trailing_28d_units = sum(units[d >= origin_d - 27L & d <= origin_d]),
      trailing_84d_units = sum(units[d >= origin_d - 83L & d <= origin_d]),
      trailing_28d_mean_price = {
        x <- sell_price[d >= origin_d - 27L & d <= origin_d]
        if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
      },
      .groups = "drop"
    ) %>%
    dplyr::left_join(item_stats, by = "item_id")
  a
}

# M2:horizon-28
make_horizon_rows <- function(item_prices, calendar_f, panel, origin_d, item_stats, levels) {
  hdays <- (origin_d + 1L):(origin_d + 28L)
  hcal <- calendar_f %>% dplyr::filter(d %in% hdays)
  if (nrow(hcal) != 28L || !identical(sort(hcal$d), hdays)) stop("Horizon calendar is not exactly 28 daily rows")
  anchors <- origin_anchors(panel, origin_d, item_stats)
  item_prices %>%
    dplyr::mutate(.join_key = 1L) %>%
    dplyr::inner_join(hcal %>% dplyr::mutate(.join_key = 1L), by = ".join_key") %>%
    dplyr::select(-.join_key) %>%
    dplyr::left_join(anchors, by = c("store_id", "item_id", "dept_id")) %>%
    dplyr::mutate(sell_price = scenario_price, target = NA_real_) %>%
    factorize_frame(levels)
}

score_scenarios <- function(model_fit, item_prices, calendar_f, panel, origin_d, item_stats, levels) {
  if (!nrow(item_prices)) return(tibble::tibble())
  rows <- make_horizon_rows(item_prices, calendar_f, panel, origin_d, item_stats, levels)
  raw <- predict(model_fit, new_data = rows)$.pred
  rows$.pred_raw <- raw
  rows$.pred_day <- pmax(0, raw)
  rows$.floored <- as.integer(raw < 0)
  rows %>%
    dplyr::group_by(store_id, item_id, scenario_price) %>%
    dplyr::summarise(
      pred_units = sum(.pred_day),
      pred_rev = pred_units * dplyr::first(scenario_price),
      n_horizon_days_scored = dplyr::n(),
      n_floored_days = sum(.floored),
      .groups = "drop"
    )
}

# M2:legal test
# M2:guardrail
# M2:ΔR̂ > 0 cent rounding
legalize_candidates <- function(cand_scores, current_scores, rho_min = PP$rho_min) {
  cand_scores %>%
    dplyr::left_join(
      current_scores %>% dplyr::select(store_id, item_id, .pred_units_current = pred_units, .pred_rev_current = pred_rev),
      by = c("store_id", "item_id")
    ) %>%
    dplyr::mutate(
      .pred_units_candidate = pred_units,
      .pred_rev_candidate = pred_rev,
      delta_rev = .pred_rev_candidate - .pred_rev_current,
      unit_ratio = dplyr::if_else(.pred_units_current > 0, .pred_units_candidate / .pred_units_current, NA_real_),
      guardrail_pass = as.integer(!is.na(unit_ratio) & unit_ratio >= rho_min),
      cent_delta_rev = round(.pred_rev_candidate, 2) - round(.pred_rev_current, 2),
      legal_change = as.integer(guardrail_pass == 1L & cent_delta_rev > 0)
    ) %>%
    dplyr::select(-pred_units, -pred_rev)
}

# M2:action map
choose_actions <- function(universe, legal_candidates, current_scores, backtest_accept) {
  u <- universe %>%
    dplyr::left_join(
      current_scores %>% dplyr::select(store_id, item_id, .pred_units_current = pred_units, .pred_rev_current = pred_rev,
                                       n_horizon_days_scored, n_floored_days_current = n_floored_days),
      by = c("store_id", "item_id")
    )
  legal <- legal_candidates %>% dplyr::filter(legal_change == 1L)
  ties <- legal %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::filter(delta_rev == max(delta_rev)) %>%
    dplyr::summarise(n_max = dplyr::n(), .groups = "drop") %>%
    dplyr::filter(n_max > 1L)
  if (nrow(ties)) stop("§17.R7 does not specify an argmax tie-break for exactly equal unrounded delta_rev; refusing to guess")
  chosen <- legal %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::slice_max(delta_rev, n = 1L, with_ties = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::select(store_id, item_id, candidate_price = scenario_price,
                  .pred_units_candidate, .pred_rev_candidate, delta_rev, unit_ratio, guardrail_pass,
                  legal_change, n_floored_days_candidate = n_floored_days)

  any_legal <- legal %>% dplyr::distinct(store_id, item_id) %>% dplyr::mutate(.has_legal = TRUE)
  out <- u %>%
    dplyr::left_join(any_legal, by = c("store_id", "item_id")) %>%
    dplyr::left_join(chosen, by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      .has_legal = tidyr::replace_na(.has_legal, FALSE),
      action = dplyr::case_when(
        trust_eligible != 1L ~ "hold_ne",
        is.na(.pred_units_current) | .pred_units_current == 0 ~ "hold_ne",
        backtest_accept == 0L ~ "hold_ne",
        .has_legal & candidate_price > current_price ~ "raise",
        .has_legal & candidate_price < current_price ~ "cut",
        TRUE ~ "unchanged"
      ),
      candidate_price = dplyr::case_when(
        action %in% c("raise", "cut") ~ candidate_price,
        action == "unchanged" ~ current_price,
        TRUE ~ NA_real_
      ),
      .pred_units_candidate = dplyr::case_when(
        action %in% c("raise", "cut") ~ .pred_units_candidate,
        action == "unchanged" ~ .pred_units_current,
        TRUE ~ NA_real_
      ),
      .pred_rev_candidate = dplyr::case_when(
        action %in% c("raise", "cut") ~ .pred_rev_candidate,
        action == "unchanged" ~ .pred_rev_current,
        TRUE ~ NA_real_
      ),
      delta_rev = dplyr::case_when(action %in% c("raise", "cut") ~ delta_rev, action == "unchanged" ~ 0, TRUE ~ NA_real_),
      unit_ratio = dplyr::case_when(action %in% c("raise", "cut") ~ unit_ratio, action == "unchanged" ~ 1, TRUE ~ NA_real_),
      guardrail_pass = dplyr::case_when(action %in% c("raise", "cut") ~ guardrail_pass, action == "unchanged" ~ 1L, TRUE ~ 0L),
      legal_change = as.integer(action %in% c("raise", "cut")),
      n_floored_days = dplyr::case_when(
        action %in% c("raise", "cut") ~ n_floored_days_candidate,
        TRUE ~ n_floored_days_current
      )
    ) %>%
    dplyr::select(-.has_legal, -n_floored_days_current, -n_floored_days_candidate)
  out
}

# M2:backtest collapse
backtest_accept_flag <- function(A1_median_ape, A2_mean_signed_error) {
  as.integer(!is.na(A1_median_ape) && !is.na(A2_mean_signed_error) &&
               A1_median_ape <= 0.40 && A2_mean_signed_error >= -0.20 && A2_mean_signed_error <= 0.20)
}

# M2:ranking/tie-break
# M2:Membership-first + capacity + no-pad
rank_capacity <- function(universe, cap = PP$capacity_cap) {
  ranked <- universe %>%
    dplyr::filter(action %in% c("raise", "cut")) %>%
    dplyr::arrange(dplyr::desc(delta_rev), dplyr::desc(.pred_units_current), dplyr::desc(n_price_changes_pre), item_id) %>%
    dplyr::mutate(
      rank_among_qualifiers = dplyr::row_number(),
      package_flag = as.integer(rank_among_qualifiers <= cap),
      below_line_flag = as.integer(rank_among_qualifiers > cap)
    ) %>%
    dplyr::select(store_id, item_id, rank_among_qualifiers, package_flag, below_line_flag)
  universe %>%
    dplyr::left_join(ranked, by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      package_flag = tidyr::replace_na(package_flag, 0L),
      below_line_flag = tidyr::replace_na(below_line_flag, 0L)
    )
}

compute_backtest_slice <- function(sales, prices, calendar_f, panel, candidate_builder_base, origin_d, current_week) {
  metrics <- compute_eligibility_metrics(sales, prices, calendar_f, origin_d, current_week)
  current <- current_price_fields(prices, current_week = current_week, twin_week = current_week) %>%
    dplyr::select(store_id, item_id, current_price)
  base <- metrics %>% dplyr::left_join(current, by = c("store_id", "item_id"))
  cand <- build_candidates(prices, panel, base, origin_d, current_week)
  base <- base %>%
    dplyr::left_join(cand$per_item %>% dplyr::select(store_id, item_id, e_cand, n_candidates), by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      e_cand = tidyr::replace_na(e_cand, 0L),
      base_trust_at_o = e_chg3 == 1L & e_u180 == 1L & e_z182 == 1L & e_pw52 == 1L & e_cand == 1L
    )
  horizon_end_d <- origin_d + 28L
  weeks_required <- calendar_f %>%
    dplyr::filter(d >= origin_d & d <= horizon_end_d) %>%
    dplyr::distinct(wm_yr_wk) %>%
    dplyr::arrange(wm_yr_wk) %>%
    dplyr::pull(wm_yr_wk)
  stable <- prices %>%
    dplyr::filter(wm_yr_wk %in% weeks_required, sell_price > 0) %>%
    dplyr::mutate(price_cents = as.integer(round(sell_price * 100))) %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(stable_price = dplyr::n_distinct(wm_yr_wk) == length(weeks_required) && dplyr::n_distinct(price_cents) == 1L,
                     .groups = "drop")
  realized <- sales %>%
    dplyr::group_by(store_id, item_id) %>%
    dplyr::summarise(realized_units = sum(units[d >= origin_d + 1L & d <= origin_d + 28L]), .groups = "drop")
  base %>%
    dplyr::left_join(stable, by = c("store_id", "item_id")) %>%
    dplyr::left_join(realized, by = c("store_id", "item_id")) %>%
    dplyr::mutate(stable_price = tidyr::replace_na(stable_price, FALSE))
}

run_backtest_origin <- function(sales, prices, calendar_f, panel, panel_with_trails, origin_d, current_week, levels) {
  fitted <- fit_mode_a(panel_with_trails, origin_d, levels)
  slice <- compute_backtest_slice(sales, prices, calendar_f, panel, NULL, origin_d, current_week)
  item_prices <- slice %>%
    dplyr::filter(!is.na(current_price)) %>%
    dplyr::transmute(store_id, item_id, dept_id, scenario_price = current_price)
  scored <- score_scenarios(fitted$fit, item_prices, calendar_f, panel, origin_d, fitted$item_stats, levels) %>%
    dplyr::rename(.pred_units = pred_units, .pred_rev = pred_rev)
  eval <- slice %>%
    dplyr::left_join(scored %>% dplyr::select(store_id, item_id, .pred_units, .pred_rev), by = c("store_id", "item_id")) %>%
    dplyr::mutate(
      acceptance_pre_u = base_trust_at_o & stable_price,
      usable = acceptance_pre_u & realized_units > 0,
      ape = dplyr::if_else(usable, abs(.pred_units - realized_units) / realized_units, NA_real_),
      signed_error = dplyr::if_else(usable, (.pred_units - realized_units) / realized_units, NA_real_),
      realized_rev = dplyr::if_else(stable_price, realized_units * current_price, NA_real_),
      abs_revenue_error = dplyr::if_else(usable, abs(.pred_rev - realized_rev), NA_real_)
    )
  A1 <- if (any(eval$usable)) stats::median(eval$ape[eval$usable], na.rm = TRUE) else NA_real_
  A2 <- if (any(eval$usable)) mean(eval$signed_error[eval$usable], na.rm = TRUE) else NA_real_
  accept <- backtest_accept_flag(A1, A2)
  dept_mae <- eval %>%
    dplyr::filter(usable) %>%
    dplyr::group_by(dept_id) %>%
    dplyr::summarise(dept_backtest_MAE_revenue = mean(abs_revenue_error), .groups = "drop")
  list(
    fit = fitted, eval = eval, backtest_accept = accept,
    A1_median_ape = A1, A2_mean_signed_error = A2,
    backtest_n_usable_items = sum(eval$usable),
    backtest_n_U0_excluded = sum(eval$acceptance_pre_u & eval$realized_units == 0),
    dept_mae = dept_mae
  )
}

# M2:Minimum-gain diagnostic (non-judged)
add_min_gain_diagnostic <- function(universe, dept_mae) {
  universe %>%
    dplyr::left_join(dept_mae, by = "dept_id") %>%
    dplyr::mutate(
      gain_below_half_mae = dplyr::case_when(
        !action %in% c("raise", "cut") ~ NA_integer_,
        is.na(dept_backtest_MAE_revenue) ~ NA_integer_,
        TRUE ~ as.integer(!(delta_rev > 0.5 * dept_backtest_MAE_revenue))
      )
    )
}

build_te6_diagnostics <- function(live_te6_inputs, primary_backtest_eval) {
  x <- live_te6_inputs %>%
    dplyr::left_join(
      primary_backtest_eval %>% dplyr::select(store_id, item_id, .pred_units, realized_units),
      by = c("store_id", "item_id")
    ) %>%
    dplyr::mutate(te6_ape_i = dplyr::if_else(te6_usable_slice == 1L & realized_units > 0,
                                             abs(.pred_units - realized_units) / realized_units, NA_real_))
  med <- x %>%
    dplyr::filter(te6_usable_slice == 1L, !is.na(te6_ape_i)) %>%
    dplyr::group_by(dept_id) %>%
    dplyr::summarise(te6_dept_median_ape = stats::median(te6_ape_i), .groups = "drop")
  list(items = x, dept = med)
}

# M2:Half-window / persistence -- intentionally unused by locked design.
# M2:Dual-clock / twin action-override -- intentionally unused; twins are diagnostic only.

write_m2_attestation <- function(path, functions_path = "R/r-a/functions.R") {
  rows <- tibble::tribble(
    ~gate, ~used, ~clause_cite, ~fixture_ids, ~marker,
    "E_A conjuncts", "Yes", "§7.3; §17.R2, §17.R5", "FX-ELIG-BOUNDARY, FX-HOLD-NE-PRICES", "M2:E_A conjuncts",
    "priced_weeks", "Yes", "§7.3; §17.R2, §17.R5", "FX-PW52, FX-WEEK-ORDINAL", "M2:priced_weeks",
    "candidate-exists", "Yes", "§17.R4, §17.R5", "FX-NOCAND", "M2:candidate-exists",
    "TE6", "Yes — OC-5 Option A", "§7.7; §17.R5", "FX-TE6-SLICE", "M2:TE6",
    "current price", "Yes", "§17.R3", "FX-CURRENT-11617", "M2:current price",
    "band", "Yes", "§17.R4", "FX-BAND25", "M2:band",
    "event filter", "Yes", "§17.R4", "FX-EVENT-SINGLE", "M2:event filter",
    "cap/tie", "Yes", "§17.R4", "FX-CAP5-TIE", "M2:cap/tie",
    "legal test", "Yes", "§17.R7", "FX-GUARD-10, FX-CUT-OK, FX-UP0-ZERO, FX-CENT-ROUND", "M2:legal test",
    "guardrail", "Yes — OC-3 0.90 hard", "§17.R7", "FX-GUARD-10", "M2:guardrail",
    "ΔR̂ > 0 cent rounding", "Yes", "§17.R7; §23", "FX-CENT-ROUND", "M2:ΔR̂ > 0 cent rounding",
    "action map", "Yes", "§17.R5, §17.R7", "FX-HOLD-NE-PRICES, FX-CUT-OK, FX-ARGMAX, FX-UP0-ZERO, FX-MINGAIN-DIAG", "M2:action map",
    "backtest collapse", "Yes", "§16.4; §17.R8", "FX-BACKTEST-COLLAPSE", "M2:backtest collapse",
    "ranking/tie-break", "Yes", "§17.R9", "FX-TIE, FX-ARGMAX", "M2:ranking/tie-break",
    "Membership-first + capacity + no-pad", "Yes — OC-4 N_CAP 25 hard", "§17.R9", "FX-NOPAD, FX-CAP25, FX-MEMBER", "M2:Membership-first + capacity + no-pad",
    "leakage", "Yes", "§8.3; §17.R4; §17A.5–17A.6; §20.4", "FX-LEAK-11618", "M2:leakage",
    "horizon-28", "Yes", "§8.2; §17.R6", "FX-HORIZON-28", "M2:horizon-28",
    "week-ordinal rule", "Yes", "§8.5; §17.R2", "FX-WEEK-ORDINAL", "M2:week-ordinal rule",
    "trailing anchoring", "Yes", "§17.R6; §17A.6", "FX-TRAIL-ANCHOR", "M2:trailing anchoring",
    "recipe", "Yes", "§8.6; §17.R6; §17A.3", "FX-WDAY-SNAP, FX-INTERACT", "M2:recipe",
    "Half-window / persistence", "N/A — attest unused", "§16", "N/A", "M2:Half-window / persistence",
    "Dual-clock / twin action-override", "N/A — attest unused", "§11.2", "N/A", "M2:Dual-clock / twin action-override",
    "Full analytical-unit universe", "Yes", "§7.1; §17.R1", "FX-MEMBER", "M2:Full analytical-unit universe",
    "Non-enrolling actions", "Yes", "§17.R5, §17.R7, §17.R9", "FX-NOPAD, FX-HOLD-NE-PRICES, FX-NOCAND, FX-UP0-ZERO", "M2:Non-enrolling actions",
    "Lineage field mapping", "Yes", "§24.4; §20.5", "N/A", "M2:Lineage field mapping",
    "Capacity / simulation labels", "Capacity yes; simulation N/A", "§17.R9; §22.1; §22.4; §24.4", "FX-NOPAD, FX-CAP25", "M2:Capacity / simulation labels",
    "Mode A scoring", "Yes — independent fit", "§17A; §17.R6; §22.3", "FX-INTERACT, FX-TRAIL-ANCHOR", "M2:Mode A scoring",
    "Minimum-gain diagnostic (non-judged)", "Yes", "§11.3", "FX-MINGAIN-DIAG", "M2:Minimum-gain diagnostic (non-judged)"
  )
  src <- readLines(functions_path, warn = FALSE, encoding = "UTF-8")
  locate <- function(marker) {
    hit <- grep(paste0("# ", marker), src, fixed = TRUE)
    if (length(hit) != 1L) stop("Expected exactly one implementation marker for ", marker)
    paste0(functions_path, ":", hit)
  }
  rows <- rows %>%
    dplyr::mutate(attestation = "ATTESTED", implemented_at = vapply(marker, locate, character(1))) %>%
    dplyr::select(gate, used, clause_cite, fixture_ids, attestation, implemented_at)
  readr::write_csv(rows, path, na = "")
  invisible(rows)
}
