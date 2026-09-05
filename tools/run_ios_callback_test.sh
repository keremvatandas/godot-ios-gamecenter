#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 ]]; then
	printf 'usage: %s <booted-simulator-udid>\n' "$0" >&2
	exit 2
fi
cd "$(dirname "$0")/.."
test_root=$(mktemp -d "${TMPDIR:-/tmp/}gamecenter-callback.XXXXXX")
trap 'rm -rf "$test_root"' EXIT
test_arch=$(uname -m)
xcrun --sdk iphonesimulator clang++ -std=c++17 -fobjc-arc \
	-fsanitize=address -fno-omit-frame-pointer -g \
	-target "${test_arch}-apple-ios14.0-simulator" \
	-Igodot-cpp/include -Igodot-cpp/gen/include -Igodot-cpp/gdextension -Isrc \
	tests/test_panel_callback_lifetime.mm \
	godot-cpp/bin/libgodot-cpp.ios.template_release.universal.simulator.a \
	-framework Foundation -framework UIKit -framework GameKit \
	-o "$test_root/callback_test"
SIMCTL_CHILD_ASAN_OPTIONS=detect_stack_use_after_return=1 \
	xcrun simctl spawn "$1" "$test_root/callback_test"
