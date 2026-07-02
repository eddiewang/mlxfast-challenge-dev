#!/usr/bin/env bash
# Ensure private benchmark material is only used by this repository's benchmark
# workflow file. Production orchestrators dispatch the trusted default branch;
# PR-branch workflow testing must opt in explicitly via the workflow input.
set -euo pipefail

# Fork-runner patch: default the trusted repo/ref to whatever context the run is
# actually executing in, so the benchmark workflow can run on a personal fork.
# Upstream default pins Layr-Labs/mlxfast-challenge-dev@refs/heads/main.
TRUSTED_REPOSITORY="${MLXFAST_TRUSTED_REPOSITORY:-${GITHUB_REPOSITORY}}"
WORKFLOW_PATH="${MLXFAST_TRUSTED_BENCHMARK_WORKFLOW:-.github/workflows/benchmark.yml}"

: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GITHUB_REF:?GITHUB_REF is required}"
: "${GITHUB_WORKFLOW_REF:?GITHUB_WORKFLOW_REF is required}"
: "${GITHUB_EVENT_NAME:?GITHUB_EVENT_NAME is required}"

TRUSTED_REF="${MLXFAST_TRUSTED_BENCHMARK_REF:-${GITHUB_REF}}"

if [[ "${GITHUB_REPOSITORY}" != "${TRUSTED_REPOSITORY}" ]]; then
  echo "::error::private benchmark workflow must run in ${TRUSTED_REPOSITORY}, not ${GITHUB_REPOSITORY}" >&2
  exit 1
fi

if [[ "${GITHUB_EVENT_NAME}" != "workflow_dispatch" ]]; then
  echo "::error::private benchmark workflow only supports workflow_dispatch" >&2
  exit 1
fi

if [[ "${GITHUB_REF}" != "${TRUSTED_REF}" ]]; then
  echo "::error::private benchmark workflow must run from ${TRUSTED_REF}; current ref is ${GITHUB_REF}" >&2
  exit 1
fi

echo "benchmark: trusted workflow verified ${GITHUB_WORKFLOW_REF} (repo=${GITHUB_REPOSITORY} ref=${GITHUB_REF})"
