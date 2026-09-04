#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	printf 'usage: %s <godot-executable>\n' "$0" >&2
	exit 2
fi

cd "$(dirname "$0")/.."
godot_bin="$1"
"$godot_bin" --headless --editor --path example --quit-after 120
"$godot_bin" --headless --path example --script res://tests/runtime_contract.gd
