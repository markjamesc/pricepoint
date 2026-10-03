#!/usr/bin/env Rscript
# PRICEPOINT-001 SQL Source Gate — file-side checker
# Repair r1: item 8 keyed row equality; item 22 trim on varchar categoricals;
# na.strings = "NULL" only (§20.3 / AI3-XR-06).
# R 4.6.1; packages: base, data.table, digest. NO DB packages.
# Exit 0 iff every §21 item is PASS; otherwise exit 1.

suppressPackageStartupMessages({
  library(data.table)
  library(digest)
})

`%||%` <- function(a, b) if (is.null(a) || is.na(a) || identical(a, "")) b else a

args <- commandArgs(trailingOnly = TRUE)
kv <- list()
if (length(args) >= 1L) {
  i <- 1L
  while (i <= length(args)) {
    key <- sub("^--", "", args[[i]])
    if (i < length(args) && !startsWith(args[[i + 1L]], "--")) {
      kv[[key]] <- args[[i + 1L]]
      i <- i + 2L
    } else {
      kv[[key]] <- TRUE
      i <- i + 1L
    }
  }
}

extract_dir <- kv[["extract-dir"]] %||% "extract"
raw_dir     <- kv[["raw-dir"]]     %||% "validation/source-gate"
out_dir     <- kv[["out-dir"]]     %||% "validation/source-gate"
manifest    <- kv[["manifest"]]    %||% file.path(extract_dir, "extract_manifest.txt")
freeze      <- kv[["freeze-record"]] %||% file.path(extract_dir, "extract_freeze_record.txt")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

sha256_file <- function(path) digest::digest(file = path, algo = "sha256")
file_size <- function(path) as.numeric(file.info(path)$size)

# §20.3: mysql --batch writes the token NULL for SQL NULL. Blank events are
# NULLIF(TRIM(...)), so a delivered empty field is not a legal NULL. A literal
# "NA" string is a categorical value. Neither may be coerced to missing
# (AI3-XR-06). "" is intentionally not an NA token.
read_mysql_tsv <- function(path) {
  data.table::fread(
    file = path, sep = "\t", header = TRUE,
    na.strings = "NULL",
    colClasses = "character", quote = "", encoding = "UTF-8",
    data.table = TRUE, showProgress = FALSE
  )
}

# Integer cents from a DECIMAL(10,2) text token. Avoids R banker-round and
# binary float. Matches SQL CAST(ROUND(CAST(TRIM(x) AS DECIMAL(10,2)) * 100) AS SIGNED)
# for the two-decimal tokens the extract delivers.
cents_from_decimal_text <- function(x) {
  txt <- as.character(x)
  out <- rep(NA_integer_, length(txt))
  ok <- !is.na(txt) & nzchar(txt)
  if (!any(ok)) return(out)
  piece <- txt[ok]
  neg <- startsWith(piece, "-")
  piece <- sub("^-", "", piece)
  if (any(grepl("[^0-9.]", piece))) stop("Non-decimal sell_price token in prices.tsv")
  parts <- strsplit(piece, ".", fixed = TRUE)
  cents <- vapply(parts, function(p) {
    whole <- if (!nzchar(p[[1L]])) 0L else as.integer(p[[1L]])
    frac <- if (length(p) < 2L) "00" else substr(paste0(p[[2L]], "00"), 1L, 2L)
    whole * 100L + as.integer(frac)
  }, integer(1))
  cents[neg] <- -cents[neg]
  out[ok] <- cents
  out
}

n_untrimmed <- function(dt, cols) {
  n <- 0L
  for (cn in intersect(cols, names(dt))) {
    v <- dt[[cn]]
    n <- n + sum(!is.na(v) & v != trimws(v))
  }
  as.integer(n)
}

parse_kv_file <- function(path) {
  if (!file.exists(path)) return(list())
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  out <- list()
  for (ln in lines) {
    if (!grepl("=", ln, fixed = TRUE)) next
    out[[trimws(sub("=.*$", "", ln))]] <- trimws(sub("^[^=]*=", "", ln))
  }
  out
}

eq_num <- function(obs, locked) {
  if (is.na(obs) || is.na(locked)) return(FALSE)
  abs(as.numeric(obs) - as.numeric(locked)) < 1e-9
}
eq_chr <- function(obs, locked) identical(as.character(obs), as.character(locked))

LOCKED <- list(
  n_sales = 4821444, n_items = 2484, d_min = 1, d_max = 1941,
  n_prices = 568783, n_prices_le_11617 = 558847, n_prices_11618_11621 = 9936,
  n_calendar = 1969, n_weeks = 282, n_days_11621 = 2, wday_2016_05_21 = 1,
  date_d_1941 = "2016-05-22",
  dept_list = "FOODS_1,FOODS_2,FOODS_3,HOUSEHOLD_1,HOUSEHOLD_2",
  fixture_pack_sha256 = "da25c258cc434d169f6f960e6d4d8d8ed08cdabaf7a9004df1dff687c94b95d2",
  design_id = "PRICEPOINT-001-S3-v1", ml_mode = "A",
  capacity_stance = "hard_attention_budget",
  observation_boundary_d = "1941", observation_boundary_date = "2016-05-22"
)

sales_path    <- file.path(extract_dir, "sales_long.tsv")
cal_path      <- file.path(extract_dir, "calendar.tsv")
prices_path   <- file.path(extract_dir, "prices.tsv")
raw_agg_path  <- file.path(raw_dir, "raw_gate_aggregates.tsv")
raw_item_path <- file.path(raw_dir, "raw_item_json.tsv")
raw_att_path  <- file.path(raw_dir, "raw_price_attach_cardinality.tsv")
raw_price_path <- file.path(raw_dir, "raw_price_rowkeys.tsv")

missing_files <- c(sales_path, cal_path, prices_path, raw_agg_path, raw_item_path, raw_att_path, raw_price_path)
missing_files <- missing_files[!file.exists(missing_files)]

report <- data.table(item_no = integer(), item = character(), locked_value = character(),
                     observed_value = character(), result = character(), method = character())
add <- function(item_no, item, locked_value, observed_value, pass, method) {
  report <<- rbind(report, data.table(
    item_no = as.integer(item_no), item = as.character(item),
    locked_value = as.character(locked_value), observed_value = as.character(observed_value),
    result = if (isTRUE(pass)) "PASS" else "FAIL", method = as.character(method)
  ))
}

if (length(missing_files)) {
  add(0L, "prerequisite_files", "all extract + raw-side outputs present",
      paste(missing_files, collapse = "; "), FALSE, "file.exists")
}

sales <- prices <- cal <- raw_agg <- raw_item <- raw_att <- raw_price <- NULL
price_cents_chr <- NULL
if (!length(missing_files)) {
  sales     <- read_mysql_tsv(sales_path)
  prices    <- read_mysql_tsv(prices_path)
  cal       <- read_mysql_tsv(cal_path)
  raw_agg   <- read_mysql_tsv(raw_agg_path)
  raw_item  <- read_mysql_tsv(raw_item_path)
  raw_att   <- read_mysql_tsv(raw_att_path)
  raw_price <- read_mysql_tsv(raw_price_path)
  price_cents_chr <- cents_from_decimal_text(prices$sell_price)
  num_cols <- function(dt, cols) {
    for (cn in intersect(cols, names(dt))) dt[, (cn) := suppressWarnings(as.numeric(get(cn)))]
    dt
  }
  sales  <- num_cols(sales,  c("d", "units", "wm_yr_wk"))
  prices <- num_cols(prices, c("wm_yr_wk", "sell_price"))
  cal    <- num_cols(cal,    c("d", "wm_yr_wk", "wday", "month", "year", "snap_CA", "snap_TX", "snap_WI"))
  raw_item <- num_cols(raw_item, c("json_units_sum", "min_pos", "max_pos", "n_pos", "u_pos1", "u_pos1941"))
  raw_price <- num_cols(raw_price, c("wm_yr_wk", "sell_price_cents"))
}

n_dup_sales <- NA_real_; n_null_units <- NA_real_
if (!is.null(sales)) {
  n_sales <- nrow(sales)
  n_items <- uniqueN(sales$item_id)
  by_item <- sales[, .(n = .N, dmin = min(d), dmax = max(d), nd = uniqueN(d)), by = item_id]
  n_incomplete <- by_item[n != 1941L | dmin != 1 | dmax != 1941 | nd != 1941L, .N]
  n_dup_sales <- sales[, .N, by = .(store_id, item_id, d)][N > 1L, .N]
  n_null_units <- sales[is.na(units), .N]
  n_units_bad <- sales[!is.na(units) & (units < 0 | units != floor(units)), .N]
  dept_obs <- paste(sort(unique(sales$dept_id)), collapse = ",")
  extra_dept <- setdiff(unique(sales$dept_id),
                        c("FOODS_1", "FOODS_2", "FOODS_3", "HOUSEHOLD_1", "HOUSEHOLD_2"))
  add(1L, "SALES_LONG row count = 4,821,444", LOCKED$n_sales, n_sales,
      eq_num(n_sales, LOCKED$n_sales), "nrow(sales_long.tsv)")
  add(2L, "SALES_LONG item count = 2,484", LOCKED$n_items, n_items,
      eq_num(n_items, LOCKED$n_items), "uniqueN(item_id)")
  add(3L, "Each SALES_LONG item has d 1..1941", "0 incomplete items", n_incomplete,
      eq_num(n_incomplete, 0), "per-item n==1941 & min(d)==1 & max(d)==1941 & uniqueN(d)==1941")
  add(13L, "units integer >= 0", "0 violating rows", n_units_bad,
      eq_num(n_units_bad, 0), "units numeric; reject negative or non-integer")
  add(17L, "Recorded department list = five approved departments", LOCKED$dept_list, dept_obs,
      eq_chr(dept_obs, LOCKED$dept_list) && length(extra_dept) == 0L,
      "sort(unique(dept_id)) vs OC-1 (a)")
}

n_dup_p <- NA_real_; n_null_p <- NA_real_
if (!is.null(prices)) {
  n_prices <- nrow(prices)
  n_le <- prices[wm_yr_wk <= 11617, .N]
  n_post <- prices[wm_yr_wk >= 11618 & wm_yr_wk <= 11621, .N]
  n_le0 <- prices[!is.na(sell_price) & sell_price <= 0, .N]
  n_null_p <- prices[is.na(sell_price), .N]
  n_dup_p <- prices[, .N, by = .(store_id, item_id, wm_yr_wk)][N > 1L, .N]
  add(5L, "PRICES row count = 568,783", LOCKED$n_prices, n_prices,
      eq_num(n_prices, LOCKED$n_prices), "nrow(prices.tsv)")
  add(6L, "PRICES rows at weeks <= 11617 = 558,847", LOCKED$n_prices_le_11617, n_le,
      eq_num(n_le, LOCKED$n_prices_le_11617), "wm_yr_wk<=11617")
  add(7L, "PRICES rows in weeks 11618-11621 = 9,936", LOCKED$n_prices_11618_11621, n_post,
      eq_num(n_post, LOCKED$n_prices_11618_11621), "deliver-and-quarantine count")
  add(14L, "sell_price > 0", "0 rows with sell_price<=0", n_le0,
      eq_num(n_le0, 0), "sell_price numeric > 0")
}

# Item 8: exact key-set and exact cent-value equality. Not count+sum. Not CRC32.
if (is.null(prices) || is.null(raw_price) || is.null(price_cents_chr)) {
  add(8L, "PRICES values equal raw values for every row",
      "0 key-only rows; 0 value mismatches; keys equal",
      "raw_price_rowkeys.tsv or prices.tsv missing",
      FALSE,
      "keyed (store_id, item_id, wm_yr_wk, sell_price_cents) vs 04_raw_price_rowkeys.sql")
} else {
  need <- c("store_id", "item_id", "wm_yr_wk", "sell_price_cents")
  if (!all(need %in% names(raw_price))) {
    add(8L, "PRICES values equal raw values for every row",
        "0 key-only rows; 0 value mismatches; keys equal",
        paste("raw columns", paste(names(raw_price), collapse = ",")),
        FALSE,
        "keyed (store_id, item_id, wm_yr_wk, sell_price_cents) vs 04_raw_price_rowkeys.sql")
  } else {
    ext <- prices[, .(store_id, item_id, wm_yr_wk = as.integer(wm_yr_wk),
                      sell_price_cents = price_cents_chr)]
    rawk <- raw_price[, .(store_id, item_id, wm_yr_wk = as.integer(wm_yr_wk),
                          sell_price_cents = as.integer(sell_price_cents))]
    n_dup_ext <- ext[, .N, by = .(store_id, item_id, wm_yr_wk)][N > 1L, .N]
    n_dup_raw <- rawk[, .N, by = .(store_id, item_id, wm_yr_wk)][N > 1L, .N]
    only_ext <- fsetdiff(ext[, .(store_id, item_id, wm_yr_wk)], rawk[, .(store_id, item_id, wm_yr_wk)])
    only_raw <- fsetdiff(rawk[, .(store_id, item_id, wm_yr_wk)], ext[, .(store_id, item_id, wm_yr_wk)])
    both <- merge(ext, rawk, by = c("store_id", "item_id", "wm_yr_wk"),
                  all = FALSE, suffixes = c("_ext", "_raw"))
    n_val <- both[is.na(sell_price_cents_ext) | is.na(sell_price_cents_raw) |
                    sell_price_cents_ext != sell_price_cents_raw, .N]
    n_na_ext <- ext[is.na(sell_price_cents), .N]
    pass8 <- n_dup_ext == 0L && n_dup_raw == 0L &&
      nrow(only_ext) == 0L && nrow(only_raw) == 0L &&
      n_val == 0L && n_na_ext == 0L &&
      nrow(ext) == nrow(rawk) && nrow(both) == nrow(ext)
    add(8L, "PRICES values equal raw values for every row",
        "0 key-only rows; 0 value mismatches; keys equal",
        sprintf("ext=%s raw=%s only_ext=%s only_raw=%s value_mismatch=%s dup_ext=%s dup_raw=%s na_cents=%s",
                nrow(ext), nrow(rawk), nrow(only_ext), nrow(only_raw), n_val, n_dup_ext, n_dup_raw, n_na_ext),
        pass8,
        "keyed (store_id, item_id, wm_yr_wk, integer cents) prices.tsv vs raw_price_rowkeys.tsv; prices_crc32_sum unused")
  }
}

add(23L, "Delivered key uniqueness SALES_LONG and PRICES",
    "0 duplicate keys on either table",
    sprintf("sales_dups=%s prices_dups=%s", n_dup_sales, n_dup_p),
    eq_num(n_dup_sales, 0) && eq_num(n_dup_p, 0),
    "unique (store_id,item_id,d) and (store_id,item_id,wm_yr_wk)")
add(24L, "No NULL units in SALES_LONG and no NULL sell_price in PRICES",
    "0 NULL units and 0 NULL sell_price",
    sprintf("null_units=%s null_price=%s", n_null_units, n_null_p),
    eq_num(n_null_units, 0) && eq_num(n_null_p, 0),
    "is.na(units)+is.na(sell_price)")

if (!is.null(cal)) {
  n_cal <- nrow(cal); n_wk <- uniqueN(cal$wm_yr_wk)
  n_11621 <- cal[wm_yr_wk == 11621, .N]
  wday_521 <- cal[as.character(date) == "2016-05-21", wday]
  wday_521 <- if (length(wday_521)) wday_521[1] else NA_real_
  n_wday_bad <- cal[is.na(wday) | wday < 1 | wday > 7, .N]
  n_snap_bad <- cal[is.na(snap_CA) | !(snap_CA %in% c(0, 1)), .N]
  ev <- c("event_name_1", "event_type_1", "event_name_2", "event_type_2")
  n_blank_event <- 0L
  for (cn in ev) if (cn %in% names(cal))
    n_blank_event <- n_blank_event + cal[!is.na(get(cn)) & trimws(get(cn)) == "", .N]
  # §20.3 varchar categoricals actually delivered. Numeric casts are not trim-checked.
  trim_cal <- n_untrimmed(cal, c("weekday", "event_name_1", "event_type_1", "event_name_2", "event_type_2"))
  trim_prices <- if (!is.null(prices)) n_untrimmed(prices, c("store_id", "item_id")) else NA_integer_
  trim_sales <- if (!is.null(sales)) n_untrimmed(sales, c("item_id", "dept_id", "cat_id", "store_id", "state_id", "id")) else NA_integer_
  add(9L, "Calendar row count = 1,969", LOCKED$n_calendar, n_cal,
      eq_num(n_cal, LOCKED$n_calendar), "nrow(calendar.tsv)")
  add(10L, "Calendar week count = 282", LOCKED$n_weeks, n_wk,
      eq_num(n_wk, LOCKED$n_weeks), "uniqueN(wm_yr_wk)")
  add(11L, "Week 11621 = 2 days", LOCKED$n_days_11621, n_11621,
      eq_num(n_11621, LOCKED$n_days_11621), "wm_yr_wk==11621")
  add(12L, "wday(2016-05-21) = 1", LOCKED$wday_2016_05_21, wday_521,
      eq_num(wday_521, LOCKED$wday_2016_05_21), "calendar.tsv date==2016-05-21")
  add(15L, "wday in 1..7", "0 out-of-domain rows", n_wday_bad,
      eq_num(n_wday_bad, 0), "wday domain")
  add(16L, "snap_CA in {0,1}", "0 out-of-domain rows", n_snap_bad,
      eq_num(n_snap_bad, 0), "snap_CA domain")
  add(22L, "TRIM applied; blank events → NULL; wday/snap domains",
      "0 untrimmed varchar categoricals; 0 blank event strings; domains hold",
      sprintf("untrimmed_cal=%s untrimmed_prices=%s untrimmed_sales=%s blank_events=%s wday_bad=%s snap_bad=%s",
              trim_cal, trim_prices, trim_sales, n_blank_event, n_wday_bad, n_snap_bad),
      eq_num(trim_cal, 0) && eq_num(trim_prices, 0) && eq_num(trim_sales, 0) &&
        eq_num(n_blank_event, 0) && eq_num(n_wday_bad, 0) && eq_num(n_snap_bad, 0),
      "x==trimws(x) on delivered varchar categoricals; blank events; items 15/16")
} else {
  add(22L, "TRIM applied; blank events → NULL; wday/snap domains",
      "0 untrimmed varchar categoricals; 0 blank event strings; domains hold",
      "calendar.tsv missing", FALSE,
      "x==trimws(x) on delivered varchar categoricals; blank events; items 15/16")
}

if (!is.null(sales) && !is.null(raw_item) && !is.null(cal)) {
  sl_sum <- sales[, .(del_sum = sum(units), u_d1 = units[d == 1][1],
                      u_d1941 = units[d == 1941][1]), by = item_id]
  sl_hash <- sales[order(item_id, d),
                   .(del_sha256 = digest(
                       paste0(sprintf("pos=%d;u=%d\n", as.integer(d), as.integer(units)), collapse = ""),
                       algo = "sha256", serialize = FALSE)),
                   by = item_id]
  cmp <- merge(merge(raw_item, sl_sum, by = "item_id", all = TRUE), sl_hash, by = "item_id", all = TRUE)
  n_cmp <- nrow(cmp)
  n_sum_mismatch <- cmp[is.na(json_units_sum) | is.na(del_sum) |
                          as.numeric(json_units_sum) != as.numeric(del_sum), .N]
  n_hash_mismatch <- cmp[is.na(json_pos_sha256) | is.na(del_sha256) |
                           json_pos_sha256 != del_sha256, .N]
  n_spot1 <- cmp[as.numeric(u_pos1) != as.numeric(u_d1), .N]
  n_spot1941 <- cmp[as.numeric(u_pos1941) != as.numeric(u_d1941), .N]
  date_ok <- identical(as.character(cal[d == 1941, date][1]), "2016-05-22")
  add(4L, "Per-item unit sums equal JSON sums for all 2,484 items",
      "0 mismatches; 2484 items compared",
      sprintf("compared=%s sum_mismatch=%s", n_cmp, n_sum_mismatch),
      eq_num(n_cmp, LOCKED$n_items) && eq_num(n_sum_mismatch, 0),
      "SUM(JSON_TABLE units) vs SUM(sales_long.units) by item_id; all items")
  add(19L, "Position mapping full check + spot 0→d_1 and 1940→d_1941=2016-05-22",
      "0 hash mismatches; spot units equal; d_1941 date=2016-05-22",
      sprintf("hash_mismatch=%s spot1=%s spot1941=%s date_ok=%s",
              n_hash_mismatch, n_spot1, n_spot1941, date_ok),
      eq_num(n_hash_mismatch, 0) && eq_num(n_spot1, 0) && eq_num(n_spot1941, 0) &&
        isTRUE(date_ok) && eq_num(n_cmp, LOCKED$n_items),
      "per-item SHA-256 of pos=<d>;u=<units>\\n vs raw JSON_TABLE ordinality")
}

if (!is.null(sales) && !is.null(prices) && !is.null(raw_att)) {
  att <- merge(sales[, .(store_id, item_id, d, wm_yr_wk)],
               prices[, .(store_id, item_id, wm_yr_wk, sell_price)],
               by = c("store_id", "item_id", "wm_yr_wk"),
               all.x = TRUE, allow.cartesian = TRUE)
  n_att <- nrow(att)
  max_p <- att[, .N, by = .(store_id, item_id, d)][, max(N)]
  raw_n_att <- as.numeric(raw_att$n_rows_after_attach[1])
  raw_max <- as.numeric(raw_att$max_prices_per_itemday[1])
  add(20L, "<=1 price row per item-day after mechanical attachment; 4,821,444 rows",
      "4821444 rows; max prices per item-day <=1",
      sprintf("extract_join_rows=%s extract_max=%s raw_join_rows=%s raw_max=%s",
              n_att, max_p, raw_n_att, raw_max),
      eq_num(n_att, LOCKED$n_sales) && (is.na(max_p) || max_p <= 1) &&
        eq_num(raw_n_att, LOCKED$n_sales) && (is.na(raw_max) || raw_max <= 1),
      "LEFT JOIN sales_long.tsv to prices.tsv + raw attach query")
}

man_ok <- file.exists(manifest)
frz <- parse_kv_file(freeze)
man_lines <- if (man_ok) readLines(manifest, warn = FALSE, encoding = "UTF-8") else character()
man_lines <- man_lines[nzchar(man_lines)]
parsed <- list(); layout_ok <- TRUE
if (man_ok && length(man_lines)) {
  raw_bytes <- readBin(manifest, what = "raw", n = file.info(manifest)$size)
  if (length(raw_bytes) == 0L || raw_bytes[length(raw_bytes)] != as.raw(10)) layout_ok <- FALSE
  prev <- ""
  for (ln in man_lines) {
    if (grepl("[[:space:]]$", ln)) layout_ok <- FALSE
    parts <- strsplit(ln, " \\| ", fixed = FALSE)[[1]]
    if (length(parts) != 3L) { layout_ok <- FALSE; next }
    rec <- list(path = parts[1], byte_length = as.numeric(parts[2]), file_sha256 = parts[3])
    parsed[[rec$path]] <- rec
    if (nzchar(prev) && rec$path < prev) layout_ok <- FALSE
    prev <- rec$path
  }
}
req_rel <- c("calendar.tsv", "prices.tsv", "sales_long.tsv")
file_match <- TRUE; obs_bits <- character()
if (length(parsed)) {
  for (rel in req_rel) {
    rec <- parsed[[rel]]; fp <- file.path(extract_dir, rel)
    if (is.null(rec) || !file.exists(fp)) {
      file_match <- FALSE; obs_bits <- c(obs_bits, paste0(rel, "=MISSING")); next
    }
    got_n <- file_size(fp); got_h <- sha256_file(fp)
    ok <- eq_num(got_n, rec$byte_length) && eq_chr(got_h, rec$file_sha256)
    file_match <- file_match && ok
    obs_bits <- c(obs_bits, sprintf("%s:%s:%s", rel, got_n, got_h))
  }
} else { file_match <- FALSE; obs_bits <- "manifest unreadable" }
man_hash <- if (man_ok) sha256_file(manifest) else NA_character_
rec_hash <- frz[["sql_extract_sha256"]] %||% NA_character_
item21_pass <- isTRUE(man_ok) && isTRUE(layout_ok) && isTRUE(file_match) &&
  !is.na(rec_hash) && identical(man_hash, rec_hash)
add(21L, "Extract manifest exists with §20.5 layout; sql_extract_sha256 equals SHA-256(manifest)",
    rec_hash %||% "<missing freeze sql_extract_sha256>",
    sprintf("manifest_sha256=%s layout_ok=%s file_match=%s", man_hash, layout_ok, file_match),
    isTRUE(item21_pass),
    "parse extract_manifest.txt; hash files the gate read; sha256(manifest)==freeze.sql_extract_sha256")

lineage_ok <- TRUE; lin_obs <- character()
req_lin <- list(
  observation_boundary_d = LOCKED$observation_boundary_d,
  observation_boundary_date = LOCKED$observation_boundary_date,
  design_id = LOCKED$design_id, ml_mode = LOCKED$ml_mode,
  fixture_pack_sha256 = LOCKED$fixture_pack_sha256,
  capacity_stance = LOCKED$capacity_stance
)
for (nm in names(req_lin)) {
  got <- frz[[nm]] %||% NA_character_
  lineage_ok <- lineage_ok && identical(got, req_lin[[nm]])
  lin_obs <- c(lin_obs, sprintf("%s=%s", nm, got))
}
snap_ok <- nzchar(frz[["snapshot_id"]] %||% "") && nzchar(frz[["source_version"]] %||% "")
add(18L, "Lineage equality",
    "manifest files=hashed files; manifest hash=sql_extract_sha256; freeze constants match §24.4",
    paste(c(obs_bits, lin_obs,
            sprintf("snapshot_id=%s", frz[["snapshot_id"]] %||% NA),
            sprintf("source_version=%s", frz[["source_version"]] %||% NA)), collapse = " | "),
    isTRUE(item21_pass) && isTRUE(lineage_ok) && isTRUE(snap_ok),
    "sha256(extract files)==manifest rows; sha256(manifest)==freeze.sql_extract_sha256; freeze §24.4 constants")

report <- report[order(item_no)][, .SD[.N], by = item_no]
csv_path <- file.path(out_dir, "source_gate_report.csv")
md_path  <- file.path(out_dir, "source_gate_summary.md")
data.table::fwrite(report, csv_path, quote = TRUE)
n_fail <- report[result == "FAIL", .N]; n_pass <- report[result == "PASS", .N]
verdict <- if (n_fail == 0L && nrow(report) >= 24L) "PASS" else "FAIL"
md <- c(
  "# PRICEPOINT-001 SQL Source Gate summary", "",
  sprintf("- items scored: %s (PASS %s / FAIL %s)", nrow(report), n_pass, n_fail),
  sprintf("- verdict: **%s**", verdict), "",
  "Any single FAIL = Gate Fail (design §21).", "",
  "| item_no | item | locked_value | observed_value | result | method |",
  "|---|---|---|---|---|---|"
)
for (i in seq_len(nrow(report))) {
  md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s |",
                      report$item_no[i],
                      gsub("|", "/", report$item[i], fixed = TRUE),
                      gsub("|", "/", report$locked_value[i], fixed = TRUE),
                      gsub("|", "/", report$observed_value[i], fixed = TRUE),
                      report$result[i],
                      gsub("|", "/", report$method[i], fixed = TRUE)))
}
writeLines(md, md_path, useBytes = TRUE)
cat(sprintf("SQL Source Gate %s (%s PASS / %s FAIL of %s items)\n",
            verdict, n_pass, n_fail, nrow(report)))
if (verdict != "PASS") quit(status = 1L) else quit(status = 0L)
