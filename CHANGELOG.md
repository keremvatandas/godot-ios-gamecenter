# Changelog

All notable changes to GameCenterKit are documented in this file.

## [1.0.0] - 2026-09-04

### Added

- Prebuilt iOS arm64 device and arm64/x86_64 simulator XCFramework.
- Universal macOS 11+ debug and release editor binaries.
- Authentication, player display name, leaderboard score submission, achievement
  progress, native iOS panels, and Game Center access point controls.
- `panel_closed` and `panel_failed` lifecycle signals.
- Installable `addons/gamecenter/` release archive with combined MIT notices.

### Changed

- Set deterministic iOS 14 and macOS 11 deployment targets.
- Present Game Center UI from the active scene's topmost view controller.
- Keep all asynchronous Godot signal delivery on the main loop.
- Enable the example export plug-in and Game Center entitlement preset.

### Fixed

- Reject empty leaderboard and achievement identifiers before calling GameKit.
- Reject non-finite and out-of-range achievement percentages.
- Prevent pending native callbacks from using the singleton after shutdown.
- Report unavailable or conflicting native panel presentation through `panel_failed`.
- Treat unguarded Apple API availability warnings as build errors.

### Validation

- Verified package paths, semantic version, exported entry symbol, architectures, and
  Apple deployment metadata.
- Passed native contract and repository/package tests.
- Passed editor/runtime smoke tests with official Godot 4.5.2 and 4.7.2.
- Generated debug and release iOS Xcode projects and completed an unsigned simulator
  link smoke test.
