#!/bin/bash
# Builds every artifact example/addons/gamecenter/bin declares — names must
# match the .gdextension exactly; a declared path with no file is a silent
# no-load on export. macOS dylibs land there straight from SCons; iOS static
# libs are intermediates in build/ that get folded into the xcframework.
set -euo pipefail
cd "$(dirname "$0")/.."
ADDON_BIN=example/addons/gamecenter/bin
PACKAGE_DIR=build/xcframework
IOS_MIN_VERSION=14.0
MACOS_MIN_VERSION=11.0
scons platform=ios target=template_release arch=arm64 ios_min_version="$IOS_MIN_VERSION" -j8
scons platform=ios target=template_release ios_simulator=yes arch=universal ios_min_version="$IOS_MIN_VERSION" -j8
scons platform=macos target=template_debug macos_deployment_target="$MACOS_MIN_VERSION" -j8
scons platform=macos target=template_release macos_deployment_target="$MACOS_MIN_VERSION" -j8

# A static GDExtension must carry the godot-cpp implementation objects it was
# compiled against. SCons links those objects into shared libraries, but an
# archive produced from only `sources` contains unresolved godot::* symbols.
# Merge into separate packaging outputs so repeated builds remain idempotent.
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
xcrun libtool -static \
  -o "$PACKAGE_DIR/libgamecenter.ios.template_release.arm64.a" \
  build/libgamecenter.ios.template_release.arm64.a \
  godot-cpp/bin/libgodot-cpp.ios.template_release.arm64.a
xcrun libtool -static \
  -o "$PACKAGE_DIR/libgamecenter.ios.template_release.universal.simulator.a" \
  build/libgamecenter.ios.template_release.universal.simulator.a \
  godot-cpp/bin/libgodot-cpp.ios.template_release.universal.simulator.a

rm -rf "$ADDON_BIN/libgamecenter.ios.xcframework"
xcodebuild -create-xcframework \
  -library "$PACKAGE_DIR/libgamecenter.ios.template_release.arm64.a" \
  -library "$PACKAGE_DIR/libgamecenter.ios.template_release.universal.simulator.a" \
  -output "$ADDON_BIN/libgamecenter.ios.xcframework"
echo "artifacts:"
ls "$ADDON_BIN"
