# GameCenterKit 1.0.0

GameCenterKit 1.0 is a focused Game Center bridge for official single-precision Godot
4.5 through 4.7 builds.

Highlights:

- Installable `addons/gamecenter/` package with prebuilt iOS device/simulator and
  universal macOS binaries.
- Authentication, leaderboard score submission, achievement progress, native iOS
  panels, and Game Center access point visibility.
- Signal-driven asynchronous results on Godot's main loop.
- Scene-aware iOS presentation, deterministic input validation, panel lifecycle
  signals, and shutdown-safe native callbacks.
- Verified iOS 14/macOS 11 deployment targets, package contents, symbols,
  architectures, Godot 4.5.2/4.7.2 loading, and iOS Xcode export/link behavior.

Install by extracting `gamecenter-addon.zip` into the root of a Godot project, enabling
**Game Center Export**, and enabling the Game Center entitlement in the iOS export
preset. See the bundled README for Apple Developer and App Store Connect setup.
