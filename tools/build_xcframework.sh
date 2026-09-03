#!/bin/bash
# Builds every artifact example/addons/gamecenter/bin declares — names must
# match the .gdextension exactly; a declared path with no file is a silent
# no-load on export. macOS dylibs land there straight from SCons; iOS static
# libs are intermediates in build/ that get folded into the xcframework.
set -euo pipefail
cd "$(dirname "$0")/.."
ADDON_BIN=example/addons/gamecenter/bin
scons platform=ios target=template_release arch=arm64 -j8
scons platform=ios target=template_release ios_simulator=yes arch=universal -j8
scons platform=macos target=template_debug -j8
scons platform=macos target=template_release -j8
rm -rf "$ADDON_BIN/libgamecenter.ios.xcframework"
xcodebuild -create-xcframework \
  -library build/libgamecenter.ios.template_release.arm64.a \
  -library build/libgamecenter.ios.template_release.universal.simulator.a \
  -output "$ADDON_BIN/libgamecenter.ios.xcframework"
echo "artifacts:"
ls "$ADDON_BIN"
