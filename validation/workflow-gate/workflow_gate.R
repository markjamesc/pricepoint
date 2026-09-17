#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(jsonlite))

args <- commandArgs(trailingOnly = TRUE)
project_root <- if (length(args) >= 1) normalizePath(args[[1]], mustWork = FALSE) else getwd()

paths <- list(
  stage1 = file.path(project_root, "docs", "stage-01-02-start-framing", "stage1_decision.json"),
  stage2 = file.path(project_root, "docs", "stage-01-02-start-framing", "stage2_framing.json"),
  stage3 = file.path(project_root, "docs", "stage-03-measurement-design", "stage3_locked_design.json"),
  stage4 = file.path(project_root, "docs", "stage-04-execution-validation", "stage4_validation_status.json"),
  gate = file.path(project_root, "validation", "workflow-gate", "workflow_gate_status.json")
)

checks <- list()
add_check <- function(name, pass, detail) {
  checks[[length(checks) + 1]] <<- list(
    check = name,
    result = if (isTRUE(pass)) "PASS" else "FAIL",
    detail = detail
  )
}

read_json_safe <- function(path, label) {
  if (!file.exists(path)) {
    add_check(paste(label, "artifact exists"), FALSE, paste("Missing:", path))
    return(NULL)
  }
  out <- tryCatch(fromJSON(path, simplifyVector = TRUE), error = function(e) e)
  if (inherits(out, "error")) {
    add_check(paste(label, "artifact parses"), FALSE, conditionMessage(out))
    return(NULL)
  }
  add_check(paste(label, "artifact exists"), TRUE, path)
  add_check(paste(label, "artifact parses"), TRUE, "Valid JSON")
  out
}

has_fields <- function(x, fields) !is.null(x) && all(fields %in% names(x))
is_value <- function(x, field, expected) {
  !is.null(x) && field %in% names(x) && identical(as.character(x[[field]]), as.character(expected))
}

stage1 <- read_json_safe(paths$stage1, "Stage 1")
stage2 <- read_json_safe(paths$stage2, "Stage 2")
stage3 <- read_json_safe(paths$stage3, "Stage 3")
stage4 <- read_json_safe(paths$stage4, "Stage 4")

required_stage1 <- c("stage", "status", "decision_statement", "decision_owner")
add_check("Stage 1 required fields", has_fields(stage1, required_stage1), paste("Required:", paste(required_stage1, collapse = ", ")))
add_check("Stage 1 locked", is_value(stage1, "status", "LOCKED"), "status must equal LOCKED")

required_stage2 <- c("stage", "status", "analytical_question")
add_check("Stage 2 required fields", has_fields(stage2, required_stage2), paste("Required:", paste(required_stage2, collapse = ", ")))
add_check("Stage 2 locked", is_value(stage2, "status", "LOCKED"), "status must equal LOCKED")

required_stage3 <- c(
  "stage", "status", "design_version", "decision_statement", "analytical_question",
  "grain", "population", "decision_horizon", "historical_lookback",
  "price_definition", "unit_sales_definition", "revenue_definition",
  "action_classes", "uncertainty_rule", "claim_strength_ceiling",
  "source_delivery_contract", "fixture_version", "reconciliation_critical_fields",
  "required_outputs"
)
add_check("Stage 3 required fields", has_fields(stage3, required_stage3), paste("Required:", paste(required_stage3, collapse = ", ")))
add_check("Stage 3 locked", is_value(stage3, "status", "LOCKED"), "status must equal LOCKED")

required_stage4 <- c(
  "stage", "status", "design_version_used", "fixture_version_used",
  "sql_source_gate", "r_a_fixtures", "r_b_fixtures", "r_a_status", "r_b_status",
  "reconciliation", "structural_cross_review", "lineage_attestation",
  "validated_data_freeze", "validation_gate", "unresolved_issues",
  "decision_critical_model_required", "decision_critical_model_validation",
  "artifact_paths"
)
add_check("Stage 4 required fields", has_fields(stage4, required_stage4), paste("Required:", paste(required_stage4, collapse = ", ")))

if (!is.null(stage3) && !is.null(stage4) && "design_version" %in% names(stage3) && "design_version_used" %in% names(stage4)) {
  same_version <- identical(as.character(stage3$design_version), as.character(stage4$design_version_used))
  add_check("Stage 4 used locked Stage 3 version", same_version, paste0("Stage 3=", stage3$design_version, "; Stage 4=", stage4$design_version_used))
} else {
  add_check("Stage 4 used locked Stage 3 version", FALSE, "Version fields unavailable")
}

if (!is.null(stage3) && !is.null(stage4) && "fixture_version" %in% names(stage3) && "fixture_version_used" %in% names(stage4)) {
  same_fixture <- identical(as.character(stage3$fixture_version), as.character(stage4$fixture_version_used))
  add_check("Stage 4 used frozen fixture version", same_fixture, paste0("Stage 3=", stage3$fixture_version, "; Stage 4=", stage4$fixture_version_used))
} else {
  add_check("Stage 4 used frozen fixture version", FALSE, "Fixture version fields unavailable")
}

for (field in c(
  "sql_source_gate", "r_a_fixtures", "r_b_fixtures", "r_a_status", "r_b_status",
  "reconciliation", "structural_cross_review", "lineage_attestation",
  "validated_data_freeze", "validation_gate"
)) {
  add_check(paste("Stage 4", field), is_value(stage4, field, "PASS"), paste(field, "must equal PASS"))
}

issues_ok <- !is.null(stage4) && "unresolved_issues" %in% names(stage4) &&
  !is.na(suppressWarnings(as.numeric(stage4$unresolved_issues))) && as.numeric(stage4$unresolved_issues) == 0
add_check("Stage 4 unresolved issues", issues_ok, "unresolved_issues must equal 0")

model_ok <- FALSE
model_detail <- "model requirement fields unavailable"
if (!is.null(stage4) && all(c("decision_critical_model_required", "decision_critical_model_validation") %in% names(stage4))) {
  model_required <- isTRUE(stage4$decision_critical_model_required)
  model_status <- as.character(stage4$decision_critical_model_validation)
  model_ok <- if (model_required) identical(model_status, "PASS") else model_status %in% c("NOT_REQUIRED", "PASS")
  model_detail <- if (model_required) "decision-critical model requires PASS" else "NOT_REQUIRED or PASS permitted"
}
add_check("Decision-critical model validation", model_ok, model_detail)

artifact_ok <- FALSE
artifact_detail <- "artifact_paths unavailable"
if (!is.null(stage4) && "artifact_paths" %in% names(stage4)) {
  declared <- as.character(unlist(stage4$artifact_paths, use.names = FALSE))
  declared <- declared[nzchar(declared)]
  if (length(declared) > 0) {
    missing <- declared[!file.exists(file.path(project_root, declared))]
    artifact_ok <- length(missing) == 0
    artifact_detail <- if (artifact_ok) "All declared evidence files exist" else paste("Missing:", paste(missing, collapse = ", "))
  } else {
    artifact_detail <- "No evidence files declared"
  }
}
add_check("Declared Stage 4 evidence files exist", artifact_ok, artifact_detail)
add_check("Stage 4 overall status", is_value(stage4, "status", "PASS"), "status must equal PASS")

all_pass <- length(checks) > 0 && all(vapply(checks, function(x) identical(x$result, "PASS"), logical(1)))
dir.create(dirname(paths$gate), recursive = TRUE, showWarnings = FALSE)

gate_output <- list(
  gate = "pricepoint_five_stage_workflow_gate",
  result = if (all_pass) "PASS" else "FAIL",
  stage5_allowed = all_pass,
  checked_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
  project_root = project_root,
  checks = checks
)

write_json(gate_output, paths$gate, pretty = TRUE, auto_unbox = TRUE, null = "null")

cat("\nPricePoint Five-Stage Workflow Gate\n")
cat("===================================\n")
for (x in checks) cat(sprintf("%-52s %s\n", x$check, x$result))
cat("-----------------------------------\n")
cat("OVERALL:", gate_output$result, "\n")
cat("STAGE 5 ALLOWED:", if (gate_output$stage5_allowed) "YES" else "NO", "\n")
cat("REPORT:", paths$gate, "\n\n")

if (!all_pass) quit(status = 1, save = "no")
quit(status = 0, save = "no")
