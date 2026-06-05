#!/usr/bin/env bash
# This is called by the scheduled run (no manual inputs).
# Add or remove queries here to control what gets fetched daily.
set -e

run_query() {
  export ENDPOINT="$1"; shift
  while [[ "$#" -gt 0 ]]; do export "$1"; shift; done
  bash scripts/fetch.sh
  unset ENDPOINT YEAR COUNTRY ORG EMERGENCY PLAN
}

# Examples — uncomment and edit as needed:
# run_query flow YEAR=2025
# run_query flow YEAR=2025 COUNTRY=SDN
# run_query flow YEAR=2025 ORG=WFP
# run_query emergency

# Default: fetch current year global flows
run_query flow YEAR=$(date +%Y)
