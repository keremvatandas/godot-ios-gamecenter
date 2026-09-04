#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/gamecenter-contract.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT

${CXX:-clang++} -std=c++17 -Wall -Wextra -Werror \
  -Isrc tests/test_game_center_contract.cpp \
  -o "$test_dir/game_center_contract_test"
"$test_dir/game_center_contract_test"
