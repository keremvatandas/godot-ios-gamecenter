#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
	printf 'usage: %s <tag> <godot-destination>\n' "$0" >&2
	exit 2
fi

tag="$1"
destination="$2"
asset="Godot_v${tag}_export_templates.tpz"
archive="$destination/$asset"
url="https://github.com/godotengine/godot-builds/releases/download/${tag}/${asset}"
template_version="${tag%-stable}.stable"
template_dir="$destination/editor_data/export_templates/$template_version"

mkdir -p "$template_dir"
if [[ ! -f "$template_dir/ios.zip" ]]; then
	curl --fail --location --retry 3 --output "$archive" "$url"
	unzip -jo "$archive" 'templates/ios.zip' -d "$template_dir"
	rm -f "$archive"
fi
printf '%s\n' "$template_dir/ios.zip"
