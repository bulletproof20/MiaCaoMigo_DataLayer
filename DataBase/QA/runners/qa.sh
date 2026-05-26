#!/usr/bin/env bash
# qa.sh — Linux/CI entrypoint (waits for Postgres, then runs ci.ps1 via PowerShell)
# Usage: ./qa.sh   or   QA_INCLUDE_STRESS=1 ./qa.sh -IncludeStress
# Prerequisite: init_qa (docker-compose.qa.yml) + pwsh on PATH

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONTAINER="${QA_CONTAINER:-miacaomigo-db}"
DB="${QA_DB:-miacaomigo}"
USER="${QA_USER:-postgres}"

echo "Waiting for PostgreSQL (${CONTAINER})..."

ready=0
for _ in $(seq 1 60); do
  if docker exec "${CONTAINER}" pg_isready -U "${USER}" -d "${DB}" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "${ready}" -ne 1 ]]; then
  echo "ERROR: PostgreSQL not ready after 120s"
  exit 1
fi

if ! command -v pwsh >/dev/null 2>&1; then
  echo "ERROR: pwsh (PowerShell) is required. Install PowerShell or run stages manually on Windows."
  exit 1
fi

exec pwsh -NoProfile -File "${DIR}/ci.ps1" "$@"
