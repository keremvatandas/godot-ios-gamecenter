#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	printf 'usage: %s <godot-executable>\n' "$0" >&2
	exit 2
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
godot_bin="$1"
debug_root="$repo_root/build/ios-debug"
release_root="$repo_root/build/ios-release"

fail() {
	printf 'error: %s\n' "$1" >&2
	exit 1
}

require_file() {
	local path="$1"
	[[ -f "$path" ]] || fail "missing required file: $path"
}

require_match() {
	local pattern="$1"
	local path="$2"
	local description="$3"
	rg --quiet "$pattern" "$path" || fail "missing $description in $path"
}

rm -rf "$debug_root" "$release_root"
mkdir -p "$debug_root" "$release_root"

printf 'using Apple toolchain:\n'
xcodebuild -version
printf 'iOS simulator SDK: %s\n' "$(xcrun --sdk iphonesimulator --show-sdk-version)"

"$godot_bin" --headless --editor --path "$repo_root/example" \
	--export-debug "iOS" "$debug_root/GameCenterKit.xcodeproj"
"$godot_bin" --headless --editor --path "$repo_root/example" \
	--export-release "iOS" "$release_root/GameCenterKit.xcodeproj"

for export_root in "$debug_root" "$release_root"; do
	project="$export_root/GameCenterKit.xcodeproj/project.pbxproj"
	entitlements="$export_root/GameCenterKit/GameCenterKit.entitlements"
	require_file "$project"
	require_file "$entitlements"
	require_match 'GameKit\.framework' "$project" 'GameKit framework reference'
	require_match 'libgamecenter\.ios\.xcframework' "$project" 'GameCenterKit XCFramework reference'
	# Human-readable `plutil -p` renders booleans differently across macOS
	# versions. Extract the typed value, escaping dots in the literal key.
	game_center_enabled="$(plutil -extract 'com\.apple\.developer\.game-center' raw -expect bool "$entitlements")" || \
		fail "missing or invalid Game Center entitlement in $entitlements"
	[[ "$game_center_enabled" == true ]] || \
		fail "missing Game Center entitlement in $entitlements"
done

# Godot 4.5.2's official simulator engine archive contains x86_64 objects even
# though its XCFramework metadata also advertises arm64. Link x86_64 explicitly
# so this gate tests the engine and GameCenterKit slices they actually share.
xcodebuild_log="$debug_root/xcodebuild.log"
if ! xcodebuild \
	-project "$debug_root/GameCenterKit.xcodeproj" \
	-scheme GameCenterKit \
	-configuration Debug \
	-sdk iphonesimulator \
	-destination 'generic/platform=iOS Simulator' \
	-derivedDataPath "$debug_root/DerivedData" \
	CODE_SIGNING_ALLOWED=NO \
	ARCHS=x86_64 \
	ONLY_ACTIVE_ARCH=YES \
	build >"$xcodebuild_log" 2>&1; then
	printf 'error: unsigned x86_64 simulator link failed; xcodebuild log follows\n' >&2
	cat "$xcodebuild_log" >&2
	exit 1
fi

printf 'validated iOS debug/release exports and unsigned x86_64 simulator link\n'
