#!/usr/bin/env bash
# tfpolicy validate + test on sibling example tfpolicy-mock-guards (policytest resources). See README.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
POL="${ROOT}/../tfpolicy-mock-guards"
POLICIES="${POL}/policies"
TESTS="${POL}/tests"

if ! command -v tfpolicy >/dev/null 2>&1; then
  echo "tfpolicy not in PATH — install: brew tap hashicorp/tap && brew install hashicorp/tap/tfpolicy" >&2
  exit 1
fi

[[ -d "${POLICIES}" ]] || { echo "missing ${POLICIES}" >&2; exit 1; }

tfpolicy validate --policies="${POLICIES}"
tfpolicy test --policies="${POLICIES}" --tests="${TESTS}"