#!/usr/bin/env bash

# =========================================================
# QA RUNNER — BASH CI VALIDATION GATE
# FILE: QA/runners/run_qa.sh
# =========================================================
# PURPOSE:
#   Executes the complete QA validation pipeline using a
#   lightweight Bash-based orchestration layer intended for
#   Docker, Linux and CI execution environments.
#
# RESPONSIBILITIES:
#   • Wait for PostgreSQL availability
#   • Load QA contracts and fixtures
#   • Execute bootstrap validation
#   • Execute integrity validation suites
#   • Detect FAIL / FATAL conditions
#   • Propagate CI-compatible exit codes
#
# EXECUTION PROFILE:
#   • Lightweight CI orchestration
#   • Docker-oriented execution
#   • Linux-compatible validation
#   • GitHub Actions compatible
#
# VALIDATION DOMAINS:
#   • Authentication and employee integrity
#   • Animal and ownership integrity
#   • Commercial and product integrity
#   • Appointment and clinical integrity
#
# PREREQUISITES:
#   • init_qa bootstrap initialized
#   • PostgreSQL container available
#   • Docker environment available
#   • QA SQL scripts available
#
# DEPENDENCIES:
#   • contracts/*
#   • fixtures/*
#   • 00_Bootstrap/*
#   • 01_Integrity/*
#
# EXPECTED RESULT:
#   Validation succeeds only if all QA scripts complete
#   successfully without FAIL notices, SQL runtime errors
#   or fatal execution conditions.
# =========================================================

# =========================================================
# STRICT EXECUTION MODE
# =========================================================
# set -e:
#   Abort immediately on command failure.
#
# set -u:
#   Treat unset variables as errors.
#
# set -o pipefail:
#   Propagate pipeline execution failures correctly.
# =========================================================
set -euo pipefail

# =========================================================
# RUNTIME CONFIGURATION
# =========================================================
# Environment variables may override default execution
# values during CI or containerized execution.
#
# QA_CONTAINER:
#   Target PostgreSQL Docker container.
#
# QA_DB:
#   Target database name.
#
# QA_USER:
#   PostgreSQL execution user.
# =========================================================
CONTAINER="${QA_CONTAINER:-miacaomigo-db}"

DB="${QA_DB:-miacaomigo}"

USER="${QA_USER:-postgres}"

# Root QA tests directory
TESTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# =========================================================
# SQL EXECUTION WRAPPER
# =========================================================
# Executes a SQL script against the target PostgreSQL
# container and validates execution output.
#
# Validation behavior:
#   • Detect FAIL notices
#   • Detect FATAL execution conditions
#   • Detect SQL runtime failures
#   • Propagate execution errors
#
# PARAMETERS:
#   rel:
#     Relative SQL file path.
# =========================================================
run_sql() {

  local rel="$1"

  local path="${TESTS_ROOT}/${rel}"

  echo ""

  echo ">>> ${rel}"

  local out

  # =======================================================
  # EXECUTE SQL SCRIPT
  # =======================================================
  out="$(
    docker exec -i "${CONTAINER}" \
      psql \
        -U "${USER}" \
        -d "${DB}" \
        -v ON_ERROR_STOP=1 \
      < "${path}" 2>&1
  )" || {

    echo "${out}"

    return 1
  }

  # Display SQL execution output
  echo "${out}"

  # =======================================================
  # FAIL NOTICE DETECTION
  # =======================================================
  # Detects validation FAIL notices emitted by QA scripts.
  # =======================================================
  if echo "${out}" | grep -Eiq '(^|[[:space:]:])FAIL:'; then

    return 1
  fi

  # =======================================================
  # FATAL EXECUTION DETECTION
  # =======================================================
  # Detects fatal runtime conditions emitted by SQL scripts.
  # =======================================================
  if echo "${out}" | grep -Eiq '^FATAL:'; then

    return 1
  fi

  return 0
}

# =========================================================
# POSTGRESQL AVAILABILITY WAIT
# =========================================================
# Waits for PostgreSQL readiness before starting QA
# execution.
#
# Retry strategy:
#   • 60 attempts
#   • 2 seconds interval
# =========================================================
echo "Waiting for PostgreSQL..."

for _ in $(seq 1 60); do

  docker exec "${CONTAINER}" \
    pg_isready \
      -U "${USER}" \
      -d "${DB}" >/dev/null 2>&1 && break

  sleep 2
done

# =========================================================
# CORE INITIALIZATION PIPELINE
# =========================================================
# Base QA initialization layer.
#
# Includes:
#   • QA semantic contracts
#   • QA runtime reset
#   • Deterministic QA fixtures
# =========================================================
CORE=(

  "contracts/01_QA_Functions.sql"

  "fixtures/00_Reset_QA_State.sql"


  # =======================================================
  # MODULE 1 — AUTHENTICATION / EMPLOYEE FIXTURES
  # =======================================================

  "fixtures/01_Module1/01_Core_Context.sql"


  # =======================================================
  # MODULE 2 — ANIMAL / OWNERSHIP FIXTURES
  # =======================================================

  "fixtures/02_Module2/01_Animals_Ownership.sql"


  # =======================================================
  # MODULE 3 — COMMERCIAL / PRODUCT FIXTURES
  # =======================================================

  "fixtures/03_Module3/01_Commercial_Product.sql"


  # =======================================================
  # MODULE 4 — APPOINTMENT / CLINICAL FIXTURES
  # =======================================================

  "fixtures/04_Module4/01_Appointment_Slots.sql"
)

# =========================================================
# EXECUTE CORE INITIALIZATION
# =========================================================
for f in "${CORE[@]}"; do

  run_sql "${f}" || exit 1
done

# =========================================================
# BOOTSTRAP CONTRACT VALIDATION
# =========================================================
run_sql "00_Bootstrap/01_Master_Contract.sql" || exit 1

# =========================================================
# FULL INTEGRITY VALIDATION REGISTRY
# =========================================================
# Ordered integrity validation execution pipeline.
# =========================================================
INTEGRITY=(

  # =======================================================
  # MODULE 1 — AUTHENTICATION / EMPLOYEE INTEGRITY
  # =======================================================

  "01_Integrity/01_Module1/01_Email_Nif_Uniqueness.sql"

  "01_Integrity/01_Module1/02_Login_Session_Rules.sql"

  "01_Integrity/01_Module1/03_Clocking_Rules.sql"

  "01_Integrity/01_Module1/04_Absence_Overlap.sql"

  "01_Integrity/01_Module1/05_Role_Disjunction.sql"

  "01_Integrity/01_Module1/06_Schedule_Exclusion.sql"


  # =======================================================
  # MODULE 2 — ANIMAL / OWNERSHIP INTEGRITY
  # =======================================================

  "01_Integrity/02_Module2/01_Duplicate_Ownership.sql"

  "01_Integrity/02_Module2/02_Ownership_Lifecycle.sql"

  "01_Integrity/02_Module2/03_Breed_Species_Consistency.sql"

  "01_Integrity/02_Module2/04_Delivery_Date_Consistency.sql"

  "01_Integrity/02_Module2/05_Concession_And_Inactive.sql"


  # =======================================================
  # MODULE 3 — COMMERCIAL / PRODUCT INTEGRITY
  # =======================================================

  "01_Integrity/03_Module3/01_Stock_Before_Sale.sql"

  "01_Integrity/03_Module3/02_Inactive_Product_Sale.sql"

  "01_Integrity/03_Module3/03_Return_Quantity.sql"

  "01_Integrity/03_Module3/04_Invoice_Total_Update.sql"


  # =======================================================
  # MODULE 4 — APPOINTMENT / CLINICAL INTEGRITY
  # =======================================================

  "01_Integrity/04_Module4/01_Appointment_Scheduling.sql"

  "01_Integrity/04_Module4/02_Appointment_Overlap.sql"

  "01_Integrity/04_Module4/03_Vet_Absence.sql"

  "01_Integrity/04_Module4/04_Appointment_Lifecycle.sql"

  "01_Integrity/04_Module4/05_Prescription_Timing.sql"

  "01_Integrity/04_Module4/06_Notifications.sql"
)

# =========================================================
# PRE-FLIGHT CLEANUP
# =========================================================
# Resets deterministic ownership state before integrity
# execution.
#
# Cleanup failures are intentionally ignored here because
# the target state may already be clean.
# =========================================================
run_sql "fixtures/cleanup/02_Reset_Module2_Animal1.sql" || true

# =========================================================
# EXECUTE FULL INTEGRITY SUITE
# =========================================================
for f in "${INTEGRITY[@]}"; do

  # =======================================================
  # DETERMINISTIC CLEANUP — MODULE 2
  # =======================================================
  # Prevents ownership state contamination between repeated
  # validation executions.
  # =======================================================
  if [[ "${f}" == "01_Integrity/02_Module2/01_Duplicate_Ownership.sql" ]]; then

    run_sql "fixtures/cleanup/02_Reset_Module2_Animal1.sql" || exit 1
  fi

  run_sql "${f}" || exit 1
done

# =========================================================
# FINAL EXECUTION STATUS
# =========================================================
echo ""

echo "QA CI (bash): PASSED"