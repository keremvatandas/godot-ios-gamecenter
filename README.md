# GameCenterKit for Godot

A focused, signal-driven Game Center bridge for Godot 4.5-4.7 on iOS 14+.
Prebuilt device and simulator binaries install as a regular `addons/gamecenter`
plug-in, with macOS 11+ editor binaries for development.

GameCenterKit keeps the integration deliberately small: authenticate the local player,
submit leaderboard scores, report achievement progress, open native Game Center panels,
and control the access point through one `Engine` singleton. Asynchronous results return
as signals on Godot's main loop.

## Features

- Prebuilt arm64 device and arm64/x86_64 simulator XCFramework.
- Authentication, display name, score submission, and achievement reporting.
- Native leaderboard and achievement panels on iOS/iPadOS.
- Game Center access point visibility on supported Apple platforms.
- Scene-aware iOS presentation and safe shutdown of pending callbacks.
- Deterministic input failures and panel lifecycle signals.
- Reproducible package, binary, Godot compatibility, export, and CI checks.

## Compatibility

| Component | Supported versions |
| --- | --- |
| Godot | Official single-precision builds, 4.5 through 4.7 |
| iOS / iPadOS | 14.0 or newer; arm64 device and arm64/x86_64 simulator |
| macOS | 11.0 or newer; universal editor/development binaries |
| Build host | macOS with Xcode and SCons |

The release binary is built against `godot-cpp` `godot-4.5-stable` and declares
`compatibility_minimum = "4.5"`. Custom double-precision Godot builds are not part of
the Core 1.0 compatibility contract.

## Install

1. Download `gamecenter-addon.zip` from the GitHub release and extract it into the root
   of your Godot project. The installed path must be
   `res://addons/gamecenter/`.
2. Open **Project > Project Settings > Plugins** and enable
   **Game Center Export**. The export plug-in links GameKit in generated iOS projects.
3. Create or edit an iOS export preset and enable **Entitlements > Game Center**. The
   equivalent preset setting is `entitlements/game_center=true`.
4. Enable Game Center for the matching app identifier in Apple Developer and App Store
   Connect, then configure every leaderboard and achievement identifier used by the
   game.
5. Export with an Apple team and provisioning profile that include the Game Center
   capability. Generated Xcode projects should not need manual plug-in patches.

Use a platform guard so the same project can run where no GameCenterKit binary is
declared:

```gdscript
if Engine.has_singleton("GameCenterKit"):
	var game_center := Engine.get_singleton("GameCenterKit")
	game_center.authenticated.connect(_on_authenticated)
	game_center.authenticate()
```

The runnable [`example`](example) project demonstrates every Core 1.0 operation and
signal.

## API

All operations should be called from the Godot main thread. GameKit completion handlers
are forwarded with deferred signals on the main loop; the bridge does not block while
waiting for Apple services.

| Method | Result |
| --- | --- |
| `authenticate()` | Starts local-player authentication; emits `authenticated`. |
| `is_authenticated() -> bool` | Returns the current local-player authentication state. |
| `player_display_name() -> String` | Returns the authenticated player's display name, otherwise an empty string. |
| `submit_score(leaderboard_id: String, score: int)` | Submits an integer score; emits `score_submitted`. |
| `show_leaderboard(leaderboard_id: String)` | Presents the requested leaderboard on iOS; otherwise emits `panel_failed`. |
| `report_achievement(achievement_id: String, percent: float)` | Reports finite progress from 0 through 100; emits `achievement_reported`. |
| `show_achievements()` | Presents achievements on iOS; otherwise emits `panel_failed`. |
| `set_access_point_visible(visible: bool)` | Shows or hides the top-trailing native access point. |

| Signal | Arguments |
| --- | --- |
| `authenticated` | `ok: bool, error: String` |
| `score_submitted` | `ok: bool, leaderboard_id: String, error: String` |
| `achievement_reported` | `ok: bool, achievement_id: String, error: String` |
| `panel_closed` | `panel: String` (`leaderboard` or `achievements`) |
| `panel_failed` | `panel: String, error: String` |

Empty identifiers and invalid achievement percentages are rejected before GameKit is
called. On macOS, authentication, scores, achievements, and the access point use the
native GameKit APIs; leaderboard and achievement panels are iOS-only and return a
deterministic `panel_failed` signal.

## App Store Connect setup

- Use the same bundle identifier in the Godot export preset, Apple Developer, and App
  Store Connect.
- Enable the Game Center capability for the app identifier and provisioning profile.
- Create leaderboard and achievement records before using their case-sensitive IDs.
- Test authentication, score submission, achievement reporting, both panels, and the
  access point with a sandbox account on a physical device before release.

Apple's [Game Center documentation](https://developer.apple.com/documentation/gamekit/enabling-and-configuring-game-center)
describes the service-side configuration.

## Build and test from source

```bash
git clone --recurse-submodules git@github.com:keremvatandas/godot-ios-gamecenter.git
cd godot-ios-gamecenter
tools/run_cpp_tests.sh
tools/build_xcframework.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
tools/package_addon.sh
```

Xcode, command-line developer tools, SCons, Bash, Python 3, and `ripgrep` are required.
Native artifacts land in `example/addons/gamecenter/bin/`; the Store-ready archive is
`dist/gamecenter-addon.zip`. `tools/validate_release.py` checks package paths, versions,
entry symbols, architectures, and deployment targets. CI additionally opens the add-on
with Godot 4.5.2 and 4.7.2 and generates debug/release iOS projects.

## Troubleshooting

- **`GameCenterKit` is unavailable:** confirm the add-on path, matching Apple binary,
  and enabled editor plug-in. The singleton is intentionally absent on unsupported
  platforms.
- **Authentication UI does not appear:** verify an active foreground window scene,
  network access, Game Center entitlement, signing team, and provisioning profile.
- **A score or achievement fails:** compare the identifier exactly with App Store
  Connect and log the emitted error string.
- **A panel emits `panel_failed`:** avoid presenting over another Game Center panel and
  wait until the application has an active scene. Panels are not available on macOS.
- **The iOS export cannot link the bridge:** re-enable **Game Center Export**, rebuild
  from source if using a custom binary, and confirm the exported project contains
  `libgamecenter.ios.xcframework` and GameKit.

## Scope and alternatives

Core 1.0 does not bind saved games, friends, challenges, leaderboard queries,
matchmaking, multiplayer, or turn-based matches. Godot's official iOS plug-in sources
and broader community Apple bindings may be a better fit when a game needs a larger API
surface. GameCenterKit is intended for teams that prefer a small prebuilt bridge and a
signal-first GDScript contract.

## Privacy

GameCenterKit adds no analytics, advertising SDK, account database, or independent
network service. Requested player operations go through Apple's GameKit APIs. The game
developer remains responsible for App Store privacy answers, player-facing disclosures,
and any surrounding data handling performed by the game.

## Contributing and support

Bug reports and focused pull requests are welcome through
[GitHub Issues](https://github.com/keremvatandas/godot-ios-gamecenter/issues). Include
the Godot version, Apple OS version, device or simulator architecture, export mode, and
the complete emitted error string. Security-sensitive reports should avoid posting
credentials, signing material, or personal player data.

## License

GameCenterKit is distributed under the [MIT License](LICENSE). Release packages include
a combined `LICENSE` containing the GameCenterKit notice and the MIT notice for the
statically linked `godot-cpp` runtime.
