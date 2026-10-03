# PRICEPOINT-001 run-control helper: verbatim section 17 setup of the PricePoint master
# orchestration prompt (f9a4897) with only the two path placeholders filled. Lives outside
# both repositories. Usage: Rscript pp_gate.R <action> [step]
project_name <- "PricePoint"
run_id <- "PRICEPOINT-001"
workflow_repo <- "C:/Users/Mark/Documents/R Working Directory/ai-augmented-analyst-workflow-pricepoint"
project_root <- "C:/Users/Mark/Documents/R Working Directory/pricepoint"

settings <- c(project_name, run_id, workflow_repo, project_root)
stopifnot(all(nzchar(trimws(settings))), !any(grepl("{{", settings, fixed = TRUE)))

workflow_repo <- normalizePath(workflow_repo, mustWork = TRUE)
project_root <- normalizePath(project_root, mustWork = TRUE)
stopifnot(dir.exists(workflow_repo), dir.exists(project_root))

# CC-S3-01: re-pinned from f388be8c2379ac6a8959516b486af31c99423bb0 to the merged commit that adds
# procedure_gate.R `amend`. Replace the placeholder with the full 40-character merge commit SHA.
adopted_workflow_commit <- "6ad1e202db986d5c96482f903a7519df747768cd"
workflow_commit <- system2("git", c("-C", shQuote(workflow_repo), "rev-parse", "HEAD"), stdout = TRUE)
stopifnot(identical(trimws(workflow_commit), adopted_workflow_commit))
workflow_changes <- system2("git", c("-C", shQuote(workflow_repo), "status", "--porcelain"), stdout = TRUE)
stopifnot(is.null(attr(workflow_changes, "status")), length(workflow_changes) == 0L)

gate_script <- normalizePath(
  file.path(workflow_repo, "procedure-gate", "procedure_gate.R"),
  mustWork = TRUE
)

pricepoint_receipt_paths <- c(
  start = "docs/stage-01-02-start-framing/stage1_decision.json",
  framing = "docs/stage-01-02-start-framing/stage2_framing.json",
  design = "docs/stage-03-measurement-design/stage3_locked_design.json",
  execution = "docs/stage-04-execution-validation/stage4_validation_status.json"
)

sync_pricepoint_receipts <- function(step) {
  source_paths <- pricepoint_receipt_paths
  for (id in names(source_paths)[seq_len(match(step, names(source_paths)))]) {
    source <- file.path(project_root, source_paths[[id]])
    target <- file.path(project_root, "artifacts", basename(source))
    if (!file.exists(source) && !file.exists(target)) stop("Missing receipt: ", id)
    if (!file.exists(source)) {
      dir.create(dirname(source), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(target, source, overwrite = FALSE))
    }
    if (!file.exists(target)) {
      dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(source, target, overwrite = FALSE))
    }
    stopifnot(identical(
      digest::digest(file = source, algo = "sha256"),
      digest::digest(file = target, algo = "sha256")
    ))
  }
}

# After an AMENDED result the gate has archived the old artifacts/ copy and installed the new
# receipt there. Keep the docs/ copy identical: archive its old bytes, then mirror the new receipt.
mirror_amended_receipt <- function(step, response) {
  sha <- function(path) digest::digest(file = path, algo = "sha256")
  source <- file.path(project_root, pricepoint_receipt_paths[[step]])
  target <- file.path(project_root, "artifacts", basename(source))
  archive <- file.path(dirname(source), "archive",
    paste0(sub("\\.json$", "", basename(source)), ".superseded-", response$superseded_sha256, ".json"))
  stopifnot(identical(sha(source), response$superseded_sha256), identical(sha(target), response$new_sha256))
  dir.create(dirname(archive), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(archive)) stopifnot(file.copy(source, archive, overwrite = FALSE))
  stopifnot(identical(sha(archive), response$superseded_sha256))
  stopifnot(file.copy(target, source, overwrite = TRUE), identical(sha(source), sha(target)))
}

run_procedure_gate <- function(action, step = NULL, extra = character()) {
  if (action == "complete" && step %in% c("start", "framing", "design", "execution")) {
    sync_pricepoint_receipts(step)
  }
  if (action == "amend") {
    stopifnot(step %in% names(pricepoint_receipt_paths), length(extra) == 2L)
    sync_pricepoint_receipts(step)
  }
  if (action == "complete" && identical(step, "execution")) {
    local_gate <- file.path(project_root, "validation", "workflow-gate", "workflow_gate.R")
    stopifnot(file.exists(local_gate))
    local_exit <- system2(file.path(R.home("bin"), "Rscript"),
                         c(shQuote(local_gate), shQuote(project_root)))
    stopifnot(identical(as.integer(local_exit), 0L))
    local_report <- jsonlite::read_json(
      file.path(project_root, "validation", "workflow-gate", "workflow_gate_status.json")
    )
    stopifnot(identical(local_report$result, "PASS"), isTRUE(local_report$stage5_allowed))
  }
  arguments <- c(gate_script, action, project_root, step, if (action == "amend") extra)
  error_log <- tempfile("procedure-gate-stderr-")
  on.exit(unlink(error_log), add = TRUE)
  output <- system2(
    file.path(R.home("bin"), "Rscript"),
    args = vapply(arguments, shQuote, character(1)),
    stdout = TRUE,
    stderr = error_log
  )
  exit_status <- attr(output, "status")
  if (is.null(exit_status)) exit_status <- 0L
  cat(output, sep = "\n")
  if (file.exists(error_log)) cat(readLines(error_log, warn = FALSE), sep = "\n")
  if (exit_status != 0L) stop("Procedure Gate failed; stop progression and inspect the output.")
  response <- jsonlite::fromJSON(paste(output, collapse = "\n"), simplifyVector = FALSE)
  expected <- switch(action,
    start = "STARTED", begin = "AUTHORIZED", complete = "PASS",
    finalize = "PASS", status = NULL, amend = "AMENDED",
    stop("Unknown gate action")
  )
  actual <- if (action == "finalize") response$result else response$status
  if (!is.null(expected) && !identical(actual, expected)) {
    stop("Unexpected gate result; stop progression.")
  }
  if (action == "finalize" && !isTRUE(response$certified)) {
    stop("Final certification was not granted.")
  }
  if (action == "amend") mirror_amended_receipt(step, response)
  invisible(response)
}

cat("R_VERSION=", R.version.string, "\n", sep = "")
a <- commandArgs(trailingOnly = TRUE)
if (length(a) >= 1L) {
  if (identical(a[[1]], "start")) run_procedure_gate("start", run_id)
  else if (length(a) >= 2L) run_procedure_gate(a[[1]], a[[2]], a[-(1:2)])
  else run_procedure_gate(a[[1]])
}
