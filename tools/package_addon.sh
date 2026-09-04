#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
stage_dir="build/package-stage"
addon_dir="$stage_dir/addons/gamecenter"
archive="dist/gamecenter-addon.zip"

rm -rf "$stage_dir"
mkdir -p "$addon_dir" dist
cp -R example/addons/gamecenter/. "$addon_dir/"
cp LICENSE "$addon_dir/LICENSE"
printf '\n----------------------------------------\n\nThe bundled binaries statically link godot-cpp:\n\n' >> "$addon_dir/LICENSE"
cat godot-cpp/LICENSE.md >> "$addon_dir/LICENSE"
rm -f "$archive"
(cd "$stage_dir" && zip -qry -X "../../$archive" addons/gamecenter)
python3 tools/validate_release.py "$archive"
printf '%s\n' "$archive"
