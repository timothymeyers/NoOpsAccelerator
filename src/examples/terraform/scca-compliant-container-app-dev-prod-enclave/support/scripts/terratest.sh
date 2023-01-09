#! /usr/bin/env bash
set -eu -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly DIR

if ! command -v go > /dev/null; then
  echo "go is missing."
  exit 1
fi

if ! command -v terraform > /dev/null; then
  echo "terraform is missing."
  exit 1
fi

if [[ "${TT_VERBOSE:-}" == "1" ]]; then
  go test -v -short -count 1 -timeout ${TT_TIMEOUT:-15m} "${DIR}/../test/..."
else
  go test -short -count 1 -timeout ${TT_TIMEOUT:-15m} "${DIR}/../test/..."
fi