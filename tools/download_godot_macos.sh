#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
	printf 'usage: %s <tag> <destination>\n' "$0" >&2
	exit 2
fi

tag="$1"
destination="$2"
asset="Godot_v${tag}_macos.universal.zip"
archive="$destination/$asset"
url="https://github.com/godotengine/godot-builds/releases/download/${tag}/${asset}"

mkdir -p "$destination"
curl --fail --location --retry 3 --output "$archive" "$url"
unzip -qo "$archive" -d "$destination"
touch "$destination/._sc_"
godot_bin="$(find "$destination" -type f -path '*/Godot.app/Contents/MacOS/Godot' -print -quit)"
if [[ -z "$godot_bin" ]]; then
	printf 'Godot executable not found after extracting %s\n' "$asset" >&2
	exit 1
fi
printf '%s\n' "$godot_bin"
