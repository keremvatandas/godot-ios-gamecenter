#!/bin/bash
# The example consumes the addon exactly like a user project would: a copy
# under addons/. Run after tools/build_xcframework.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf example/addons/gamecenter
mkdir -p example/addons
cp -R addon/gamecenter example/addons/gamecenter
echo "example/addons/gamecenter synced"
