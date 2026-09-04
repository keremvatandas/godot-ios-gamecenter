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

rm -rf "$debug_root" "$release_root"
mkdir -p "$debug_root" "$release_root"

"$godot_bin" --headless --editor --path "$repo_root/example" \
	--export-debug "iOS" "$debug_root/GameCenterKit.xcodeproj"
"$godot_bin" --headless --editor --path "$repo_root/example" \
	--export-release "iOS" "$release_root/GameCenterKit.xcodeproj"

for export_root in "$debug_root" "$release_root"; do
	project="$export_root/GameCenterKit.xcodeproj/project.pbxproj"
	entitlements="$export_root/GameCenterKit/GameCenterKit.entitlements"
	test -f "$project"
	test -f "$entitlements"
	rg --quiet 'GameKit\.framework' "$project"
	rg --quiet 'libgamecenter\.ios\.xcframework' "$project"
	plutil -p "$entitlements" | rg --quiet '"com\.apple\.developer\.game-center" => true'
done

# Godot 4.5.2's official simulator engine archive contains x86_64 objects even
# though its XCFramework metadata also advertises arm64. Link x86_64 explicitly
# so this gate tests the engine and GameCenterKit slices they actually share.
xcodebuild \
	-project "$debug_root/GameCenterKit.xcodeproj" \
	-scheme GameCenterKit \
	-configuration Debug \
	-sdk iphonesimulator \
	-destination 'generic/platform=iOS Simulator' \
	-derivedDataPath "$debug_root/DerivedData" \
	CODE_SIGNING_ALLOWED=NO \
	ARCHS=x86_64 \
	ONLY_ACTIVE_ARCH=YES \
	build \
	-quiet

printf 'validated iOS debug/release exports and unsigned x86_64 simulator link\n'
