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
