#!/usr/bin/env Rscript
# R-B preflight: version, packages, no DB driver, extract hash verification.
# Per R_PACKET §1 rules 3, 4 and R_PACKET §2 file-format rules.
# Reads only files; no judged logic; halts on any failure.

suppressPackageStartupMessages({ })

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

fail <- function(...) stop(sprintf(...), call. = FALSE)

# 1. R version strictly 4.6.1
actual_r <- paste(R.version$major, R.version$minor, sep = ".")
if (!identical(actual_r, "4.6.1")) fail("R version mismatch: expected 4.6.1 got %s", actual_r)

# 2. Required packages present (no installs)
required <- c("tidyverse","parsnip","recipes","glmnet","Matrix",
              "workflows","tune","rsample","yardstick","jsonlite","digest")
for (p in required) {
  if (!requireNamespace(p, quietly = TRUE)) fail("Missing required package: %s", p)
}

# 3. No database driver attached
forbidden <- c("DBI","RMariaDB","RMySQL","odbc")
loaded <- loadedNamespaces()
bad    <- intersect(forbidden, loaded)
if (length(bad) > 0L) fail("Forbidden DB connector loaded: %s",
                           paste(bad, collapse = ", "))

# 4. Extract hash verification
manifest_path <- file.path(extract_dir, "extract_manifest.txt")
if (!file.exists(manifest_path)) fail("Extract manifest not found: %s", manifest_path)
manifest_lines <- readLines(manifest_path, warn = FALSE)
manifest_lines <- manifest_lines[nzchar(manifest_lines)]
parsed <- lapply(manifest_lines, function(ln) {
  p <- strsplit(ln, "|", fixed = TRUE)[[1]]
  data.frame(path = trimws(p[1]),
             byte_length = as.numeric(trimws(p[2])),
             sha256 = trimws(p[3]),
             stringsAsFactors = FALSE)
})
manifest <- do.call(rbind, parsed)
for (i in seq_len(nrow(manifest))) {
  fp <- file.path(extract_dir, basename(manifest$path[i]))
  if (!file.exists(fp)) fail("Extract file missing: %s", fp)
  sha  <- digest::digest(file = fp, algo = "sha256")
  if (!identical(sha, manifest$sha256[i]))
    fail("SHA-256 mismatch for %s", fp)
  blen <- as.numeric(file.info(fp)$size)
  if (!isTRUE(all.equal(blen, manifest$byte_length[i])))
    fail("Byte-length mismatch for %s: %d vs %d", fp, blen, manifest$byte_length[i])
}
expected_extract_sha <- "13d037efc758e5e2913d9ffed0dd5e2b003e1656092b8547d8a97283e03f1b68"
manifest_sha <- digest::digest(file = manifest_path, algo = "sha256")
if (!identical(manifest_sha, expected_extract_sha))
  fail("Manifest sha mismatch: expected %s got %s", expected_extract_sha, manifest_sha)

sink(file.path(out_dir, "session_info.txt"))
cat("R-B preflight OK\n\n"); print(sessionInfo())
sink()
cat("R-B preflight OK\n")
