#!/bin/bash
# Builds every artifact addon/gamecenter/bin declares — names must match
# the .gdextension exactly; a declared path with no file is a silent
# no-load on export.
set -euo pipefail
cd "$(dirname "$0")/.."
scons platform=ios target=template_release arch=arm64 -j8
scons platform=ios target=template_release ios_simulator=yes arch=universal -j8
scons platform=macos target=template_debug -j8
scons platform=macos target=template_release -j8
rm -rf addon/gamecenter/bin/libgamecenter.ios.xcframework
xcodebuild -create-xcframework \
  -library bin/libgamecenter.ios.template_release.arm64.a \
  -library bin/libgamecenter.ios.template_release.universal.simulator.a \
  -output addon/gamecenter/bin/libgamecenter.ios.xcframework
cp bin/libgamecenter.macos.template_debug.universal.dylib addon/gamecenter/bin/
cp bin/libgamecenter.macos.template_release.universal.dylib addon/gamecenter/bin/
echo "artifacts:"
ls addon/gamecenter/bin/
