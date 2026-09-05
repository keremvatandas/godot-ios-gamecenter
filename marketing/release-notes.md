# GameCenterKit 1.0.1

- Validate leaderboard and achievement metadata before presenting native panels.
- Report unavailable metadata and presentation timeouts through failure signals.
- Prevent overlapping native panel requests and safely own queued callback state.
- Keep the existing public API and Apple platform support.

The shipped native binaries are byte-identical to GridLord's provenance-verified
addon from source e2e4798. The maintainer confirmed successful live-app testing.
Only the package version metadata changes from that tested addon.

Supports official single-precision Godot 4.5–4.7, iOS/iPadOS 14+, and macOS 11+
editor use. Native Game Center panels are iOS-only.

Extract `gamecenter-addon.zip` into the Godot project root, enable **Game Center
Export**, and enable the Game Center entitlement in the iOS export preset.
See the bundled README for Apple Developer and App Store Connect setup.
