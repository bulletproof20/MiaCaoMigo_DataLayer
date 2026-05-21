#!/usr/bin/env bash
# CI gate: bootstrap + fixtures + integrity (init_qa).
set -euo pipefail

CONTAINER="${QA_CONTAINER:-miacaomigo-db}"
DB="${QA_DB:-miacaomigo}"
USER="${QA_USER:-postgres}"
TESTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_sql() {
  local rel="$1"
  local path="${TESTS_ROOT}/${rel}"
  echo ""
  echo ">>> ${rel}"
  local out
  out="$(docker exec -i "${CONTAINER}" psql -U "${USER}" -d "${DB}" -v ON_ERROR_STOP=1 < "${path}" 2>&1)" || {
    echo "${out}"
    return 1
  }
  echo "${out}"
  if echo "${out}" | grep -Eiq '(^|[[:space:]:])FAIL:'; then return 1; fi
  if echo "${out}" | grep -Eiq '^FATAL:'; then return 1; fi
  return 0
}

echo "Waiting for PostgreSQL..."
for _ in $(seq 1 60); do
  docker exec "${CONTAINER}" pg_isready -U "${USER}" -d "${DB}" >/dev/null 2>&1 && break
  sleep 2
done

CORE=(
  "contracts/01_QA_Functions.sql"
  "fixtures/00_Reset_QA_State.sql"
  "fixtures/01_Module1/01_Core_Context.sql"
  "fixtures/02_Module2/01_Animals_Ownership.sql"
  "fixtures/03_Module3/01_Commercial_Product.sql"
  "fixtures/04_Module4/01_Appointment_Slots.sql"
)

for f in "${CORE[@]}"; do run_sql "${f}" || exit 1; done
run_sql "00_Bootstrap/01_Master_Contract.sql" || exit 1

INTEGRITY=(
  "01_Integrity/01_Module1/01_Email_Nif_Uniqueness.sql"
  "01_Integrity/01_Module1/02_Login_Session_Rules.sql"
  "01_Integrity/01_Module1/03_Clocking_Rules.sql"
  "01_Integrity/01_Module1/04_Absence_Overlap.sql"
  "01_Integrity/01_Module1/05_Role_Disjunction.sql"
  "01_Integrity/01_Module1/06_Schedule_Exclusion.sql"
  "01_Integrity/02_Module2/01_Duplicate_Ownership.sql"
  "01_Integrity/02_Module2/02_Ownership_Lifecycle.sql"
  "01_Integrity/02_Module2/03_Breed_Species_Consistency.sql"
  "01_Integrity/02_Module2/04_Delivery_Date_Consistency.sql"
  "01_Integrity/02_Module2/05_Concession_And_Inactive.sql"
  "01_Integrity/03_Module3/01_Stock_Before_Sale.sql"
  "01_Integrity/03_Module3/02_Inactive_Product_Sale.sql"
  "01_Integrity/03_Module3/03_Return_Quantity.sql"
  "01_Integrity/03_Module3/04_Invoice_Total_Update.sql"
  "01_Integrity/04_Module4/01_Appointment_Scheduling.sql"
  "01_Integrity/04_Module4/02_Appointment_Overlap.sql"
  "01_Integrity/04_Module4/03_Vet_Absence.sql"
  "01_Integrity/04_Module4/04_Appointment_Lifecycle.sql"
  "01_Integrity/04_Module4/05_Prescription_Timing.sql"
  "01_Integrity/04_Module4/06_Notifications.sql"
)

run_sql "fixtures/cleanup/02_Reset_Module2_Animal1.sql" || true
for f in "${INTEGRITY[@]}"; do
  if [[ "${f}" == "01_Integrity/02_Module2/01_Duplicate_Ownership.sql" ]]; then
    run_sql "fixtures/cleanup/02_Reset_Module2_Animal1.sql" || exit 1
  fi
  run_sql "${f}" || exit 1
done

echo ""
echo "QA CI (bash): PASSED"
