#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(jsonlite))

full_args <- commandArgs(trailingOnly = FALSE)
file_arg <- full_args[grepl("^--file=", full_args)]
script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = TRUE)
repo_root <- normalizePath(file.path(dirname(script_path), "..", ".."), mustWork = TRUE)
gate_script <- file.path(repo_root, "validation", "workflow-gate", "workflow_gate.R")

write_receipts <- function(root, reconciliation = "PASS", model_required = FALSE, model_validation = "NOT_REQUIRED") {
  dirs <- c(
    file.path(root, "docs", "stage-01-02-start-framing"),
    file.path(root, "docs", "stage-03-measurement-design"),
    file.path(root, "docs", "stage-04-execution-validation"),
    file.path(root, "validation", "workflow-gate"),
    file.path(root, "evidence")
  )
  invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

  artifacts <- c(
    "evidence/source_gate.txt",
    "evidence/r_a.txt",
    "evidence/r_b.txt",
    "evidence/reconciliation.txt",
    "evidence/cross_review.txt",
    "evidence/validated_data_manifest.txt"
  )
  for (path in artifacts) writeLines("test evidence", file.path(root, path))

  write_json(list(
    stage = 1, status = "LOCKED", decision_statement = "test pricing decision", decision_owner = "test owner"
  ), file.path(root, "docs", "stage-01-02-start-framing", "stage1_decision.json"), auto_unbox = TRUE, pretty = TRUE)

  write_json(list(
    stage = 2, status = "LOCKED", analytical_question = "test pricing question"
  ), file.path(root, "docs", "stage-01-02-start-framing", "stage2_framing.json"), auto_unbox = TRUE, pretty = TRUE)

  write_json(list(
    stage = 3,
    status = "LOCKED",
    design_version = "stage3-v1",
    decision_statement = "test pricing decision",
    analytical_question = "test pricing question",
    grain = "item-store",
    population = "test population",
    decision_horizon = "28 days",
    historical_lookback = "1 year",
    price_definition = "test price",
    unit_sales_definition = "test units",
    revenue_definition = "price * units",
    action_classes = c("INCREASE", "DISCOUNT", "HOLD"),
    uncertainty_rule = "test uncertainty rule",
    claim_strength_ceiling = "prediction/scenario only",
    source_delivery_contract = "test source contract",
    fixture_version = "fixtures-v1",
    reconciliation_critical_fields = c("id", "action"),
    decision_critical_model_required = model_required,
    model_validation_plan = if (model_required) "test model validation" else "NOT_REQUIRED",
    required_outputs = c("validated action table")
  ), file.path(root, "docs", "stage-03-measurement-design", "stage3_locked_design.json"), auto_unbox = TRUE, pretty = TRUE)

  write_json(list(
    stage = 4,
    status = if (reconciliation == "PASS" && (!model_required || model_validation == "PASS")) "PASS" else "FAIL",
    design_version_used = "stage3-v1",
    fixture_version_used = "fixtures-v1",
    sql_source_gate = "PASS",
    r_a_fixtures = "PASS",
    r_b_fixtures = "PASS",
    r_a_status = "PASS",
    r_b_status = "PASS",
    reconciliation = reconciliation,
    structural_cross_review = "PASS",
    lineage_attestation = "PASS",
    validated_data_freeze = "PASS",
    validation_gate = if (reconciliation == "PASS" && (!model_required || model_validation == "PASS")) "PASS" else "FAIL",
    unresolved_issues = if (reconciliation == "PASS" && (!model_required || model_validation == "PASS")) 0 else 1,
    decision_critical_model_required = model_required,
    decision_critical_model_validation = model_validation,
    artifact_paths = artifacts
  ), file.path(root, "docs", "stage-04-execution-validation", "stage4_validation_status.json"), auto_unbox = TRUE, pretty = TRUE)
}

# PASS without decision-critical model.

# Synthetic receipts exercise the gate contract, not any real project outcome.
upgrade_fixture <- function(root, files) {
  values <- lapply(files, function(p) fromJSON(file.path(root, p), simplifyVector = TRUE))
  values[[2]]$capacity_stance <- "unordered_ok"
  values[[3]]$ml_mode <- if (isTRUE(values[[4]]$decision_critical_model_required)) "A" else "None"
  values[[3]]$fixture_version <- "fixtures-v1"
  values[[3]]$fixture_ids <- c("F01", "F02")
  values[[3]]$reconciliation_critical_fields <- c("id", "action")
  values[[4]]$fixture_version_used <- "fixtures-v1"
  values[[4]]$structural_cross_review <- "PASS"
  values[[4]]$decision_critical_model_required <- identical(values[[3]]$ml_mode, "A")
  values[[4]]$decision_critical_model_validation <- if (identical(values[[3]]$ml_mode, "A")) "PASS" else "NOT_REQUIRED"
  roles <- c("source", "fixtures", "reconciliation", "structural", "validation", "lineage")
  if (identical(values[[3]]$ml_mode, "A")) roles <- c(roles, "model")
  dir.create(file.path(root, "evidence-v2"), showWarnings = FALSE)
  receipts <- list()
  for (role in roles) {
    v <- list(status = "PASS", design_version = values[[3]]$design_version,
      fixture_version = "fixtures-v1", checked_at_utc = "2026-09-20T00:00:00Z")
    if (role == "fixtures") v$cases <- data.frame(id = c("F01", "F02"), expected = c("A", "B"), observed_a = c("A", "B"), observed_b = c("A", "B"))
    if (role == "reconciliation") {
      v$fields <- c("id", "action"); v$mismatch_count <- 0; v$row_count <- 2
    }
    if (role == "lineage") {
      v$source_snapshot <- "synthetic-source-v1"; v$extract_identity <- "synthetic-extract-v1"
      v$script_versions <- c("builder-a:test", "builder-b:test")
    }
    path <- paste0("evidence-v2/", role, ".json")
    write_json(v, file.path(root, path), auto_unbox = TRUE, pretty = TRUE)
    receipts[[role]] <- list(path = path, sha256 = digest::digest(file = file.path(root, path), algo = "sha256"))
  }
  values[[4]]$evidence_receipts <- receipts
  for (i in seq_along(files)) write_json(values[[i]], file.path(root, files[[i]]), auto_unbox = TRUE, pretty = TRUE)
}

fixture_files <- c("docs/stage-01-02-start-framing/stage1_decision.json", "docs/stage-01-02-start-framing/stage2_framing.json", "docs/stage-03-measurement-design/stage3_locked_design.json", "docs/stage-04-execution-validation/stage4_validation_status.json")
report_path <- "validation/workflow-gate/workflow_gate_status.json"
original_fixture <- write_receipts
write_receipts <- function(root, ...) { original_fixture(root, ...); upgrade_fixture(root, fixture_files) }
make_fixture <- function(root) write_receipts(root)

pass_root <- tempfile("pricepoint_gate_pass_")
dir.create(pass_root)
write_receipts(pass_root)
pass_status <- system2("Rscript", c(shQuote(gate_script), shQuote(pass_root)), stdout = FALSE, stderr = FALSE)
stopifnot(identical(pass_status, 0L))
pass_report <- fromJSON(file.path(pass_root, "validation", "workflow-gate", "workflow_gate_status.json"))
stopifnot(identical(pass_report$result, "PASS"), isTRUE(pass_report$stage5_allowed))

# Deliberate reconciliation FAIL.
fail_root <- tempfile("pricepoint_gate_fail_")
dir.create(fail_root)
write_receipts(fail_root, reconciliation = "FAIL")
fail_status <- system2("Rscript", c(shQuote(gate_script), shQuote(fail_root)), stdout = FALSE, stderr = FALSE)
stopifnot(!identical(fail_status, 0L))
fail_report <- fromJSON(file.path(fail_root, "validation", "workflow-gate", "workflow_gate_status.json"))
stopifnot(identical(fail_report$result, "FAIL"), !isTRUE(fail_report$stage5_allowed))

# PASS with a required model only when its validation passes.
model_root <- tempfile("pricepoint_gate_model_")
dir.create(model_root)
write_receipts(model_root, model_required = TRUE, model_validation = "PASS")
model_status <- system2("Rscript", c(shQuote(gate_script), shQuote(model_root)), stdout = FALSE, stderr = FALSE)
stopifnot(identical(model_status, 0L))

cat("PricePoint workflow-gate tests passed.\n")

# Forward-contract regressions: each defect must block Stage 5.
change_json <- function(root, index, fn) {
  path <- file.path(root, fixture_files[[index]])
  x <- fromJSON(path, simplifyVector = TRUE)
  write_json(fn(x), path, pretty = TRUE, auto_unbox = TRUE)
}
change_receipt <- function(root, role, fn) {
  path4 <- file.path(root, fixture_files[[4]])
  s4 <- fromJSON(path4, simplifyVector = TRUE)
  path <- file.path(root, s4$evidence_receipts[[role]]$path)
  x <- fromJSON(path, simplifyVector = TRUE)
  write_json(fn(x), path, pretty = TRUE, auto_unbox = TRUE)
  s4$evidence_receipts[[role]]$sha256 <- digest::digest(file = path, algo = "sha256")
  write_json(s4, path4, pretty = TRUE, auto_unbox = TRUE)
}
cases <- list(
  missing_capacity = function(r) change_json(r, 2, function(x) { x$capacity_stance <- NULL; x }),
  invalid_capacity = function(r) change_json(r, 2, function(x) { x$capacity_stance <- "TBD"; x }),
  missing_mode = function(r) change_json(r, 3, function(x) { x$ml_mode <- NULL; x }),
  invalid_mode = function(r) change_json(r, 3, function(x) { x$ml_mode <- ""; x }),
  missing_ranking = function(r) change_json(r, 2, function(x) { x$capacity_stance <- "hard_attention_budget"; x }),
  missing_receipt = function(r) unlink(file.path(r, "evidence-v2/source.json")),
  tampered_receipt = function(r) cat("tampered", file = file.path(r, "evidence-v2/source.json"), append = TRUE),
  empty_receipt = function(r) writeLines(character(), file.path(r, "evidence-v2/source.json")),
  wrong_version = function(r) change_receipt(r, "source", function(x) { x$design_version <- "wrong"; x }),
  failed_receipt = function(r) change_receipt(r, "validation", function(x) { x$status <- "FAIL"; x }),
  mismatch = function(r) change_receipt(r, "reconciliation", function(x) { x$mismatch_count <- 1; x }),
  missing_field = function(r) change_receipt(r, "reconciliation", function(x) { x$fields <- "id"; x }),
  wrong_fixture = function(r) change_receipt(r, "fixtures", function(x) { x$cases$observed_b[[1]] <- "WRONG"; x }),
  missing_fixture = function(r) change_receipt(r, "fixtures", function(x) { x$cases <- x$cases[1,,drop=FALSE]; x }),
  missing_lineage = function(r) change_receipt(r, "lineage", function(x) { x$script_versions <- NULL; x }),
  mode_a_without_validation = function(r) change_json(r, 3, function(x) { x$ml_mode <- "A"; x }),
  missing_structural = function(r) change_json(r, 4, function(x) { x$structural_cross_review <- NULL; x })
)
for (name in names(cases)) {
  root <- tempfile(paste0("gate-", name, "-")); dir.create(root); make_fixture(root)
  cases[[name]](root)
  status <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(gate_script), shQuote(root)), stdout = FALSE, stderr = FALSE)
  if (identical(status, 0L)) stop("Defect incorrectly accepted: ", name)
  report <- fromJSON(file.path(root, report_path))
  stopifnot(identical(report$result, "FAIL"), identical(report$stage5_allowed, FALSE))
  unlink(root, recursive = TRUE)
}
for (mode in c("None", "B")) {
  root <- tempfile("gate-valid-budget-"); dir.create(root); make_fixture(root)
  change_json(root, 2, function(x) { x$capacity_stance <- "hard_attention_budget"; x })
  change_json(root, 3, function(x) {
    x$ml_mode <- mode
    x$ranking_contract <- list(key = "locked-rule-score", tie_break = "id", capacity_unit = "cases",
      membership_first = TRUE, padding_allowed = FALSE, owner_n_deferred = TRUE)
    x
  })
  status <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(gate_script), shQuote(root)), stdout = FALSE, stderr = FALSE)
  stopifnot(identical(status, 0L))
  unlink(root, recursive = TRUE)
}
cat("Forward regression tests passed: 17 defects rejected; explicit modes and deferred budget accepted.\n")
