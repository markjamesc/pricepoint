#!/usr/bin/env Rscript
args_raw <- commandArgs(trailingOnly = TRUE)

# Minimal local parser so the first script can resolve paths before sourcing judged helpers.
parse_preflight_args <- function(args) {
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
    if (!key %in% names(out)) stop("Unknown option: ", key)
    out[[key]] <- value
  }
  out
}

args <- parse_preflight_args(args_raw)
dir.create(args$out_dir, recursive = TRUE, showWarnings = FALSE)

if (!identical(paste(R.version$major, R.version$minor, sep = "."), "4.6.1")) {
  stop("R version must be exactly 4.6.1; found ", getRversion())
}

# Database packages must not be attached before or after the toolchain load.
forbidden_attached <- c("package:DBI", "package:RMariaDB", "package:RMySQL", "package:odbc")
if (any(forbidden_attached %in% search())) stop("Database connector is attached before preflight")

required_versions <- c(
  tidyverse = "2.0.0", parsnip = "1.6.0", recipes = "1.4.0", glmnet = "5.1",
  Matrix = "1.7.5", workflows = "1.3.0", tune = "2.1.0", rsample = "1.3.2",
  yardstick = "1.4.0", jsonlite = "2.0.0", digest = "0.6.39"
)
for (pkg in names(required_versions)) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Required package unavailable: ", pkg)
  actual <- as.character(utils::packageVersion(pkg))
  if (!identical(actual, required_versions[[pkg]])) {
    stop("Package version mismatch for ", pkg, ": expected ", required_versions[[pkg]], ", found ", actual)
  }
}

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
if (any(forbidden_attached %in% search())) stop("Database connector became attached during preflight")

source("R/r-a/functions.R", local = FALSE)
lineage <- verify_extract_integrity(args$extract_dir)

# Confirm manifest identity also equals frozen lineage identity before any judged script can run.
if (!identical(unname(lineage[["sql_extract_sha256"]]), PP$expected_manifest_sha256)) {
  stop("Frozen lineage sql_extract_sha256 does not equal verified manifest hash")
}

sink(file.path(args$out_dir, "session_info.txt"))
cat("PRICEPOINT-001 Stage 4 R-A preflight PASS\n")
cat("Verified sql_extract_sha256:", lineage[["sql_extract_sha256"]], "\n\n")
print(sessionInfo())
sink()

message("R-A preflight PASS")
