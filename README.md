# godot-ios-gamecenter

iOS Game Center for Godot 4.x, as a GDExtension. The official iOS plugins
repo last shipped for Godot 3.5; this fills the gap for 4.x with a small,
signal-driven GameKit bridge.

- Authentication, leaderboards, achievements, the Game Center panels and
  the floating access point.
- Every async call answers with a **signal on the main thread**; nothing
  blocks and nothing calls back on a GameKit worker thread.
- Registered as an Engine singleton, so feature-gating looks like every
  other platform channel:

```gdscript
if Engine.has_singleton("GameCenterKit"):
    var gc := Engine.get_singleton("GameCenterKit")
    gc.authenticated.connect(_on_gc_auth)
    gc.authenticate()
```

## API

| Call | Answer |
|---|---|
| `authenticate()` | signal `authenticated(ok: bool, error: String)` |
| `is_authenticated() -> bool` | — |
| `player_display_name() -> String` | empty until authenticated |
| `submit_score(leaderboard_id: String, score: int)` | signal `score_submitted(ok, leaderboard_id, error)` |
| `show_leaderboard(leaderboard_id: String)` | presents the Game Center panel |
| `report_achievement(achievement_id: String, percent: float)` | signal `achievement_reported(ok, achievement_id, error)` |
| `show_achievements()` | presents the panel |
| `set_access_point_visible(visible: bool)` | GKAccessPoint, top trailing |

## Install

1. Download `gamecenter-addon.zip` from Releases and unzip it into your
   project root — it merges in as `addons/gamecenter`. (Building from
   source instead? Copy `example/addons/gamecenter` into your project.)
2. Enable **Game Center Export** under Project Settings → Plugins. This adds
   the GameKit system framework to every generated iOS project.
3. Open the project once (the editor's scan registers the extension).
4. In the Godot iOS export preset, enable **Entitlements → Game Center**
   (`entitlements/game_center=true`). The generated Xcode project inherits the
   entitlement, so do not patch generated project files. No Info.plist keys
   are required.
5. Create your leaderboards/achievements in App Store Connect; the ids you
   pass to `submit_score`/`report_achievement` are the ASC ids.

macOS builds of the library exist so the extension loads in the editor
during development: auth state and score submission run real GameKit
there, the two panel presenters are iOS-only and log that instead.

## Build from source

```bash
git clone --recurse-submodules git@github.com:keremvatandas/godot-ios-gamecenter.git
cd godot-ios-gamecenter
tools/build_xcframework.sh   # needs Xcode + SCons
```

Artifacts land directly in `example/addons/gamecenter/bin/` — the addon
under the example project is the single source of truth, and the example
consumes it exactly like a user project would.

Built against godot-cpp `godot-4.5-stable` with `compatibility_minimum = "4.5"`;
exercised on Godot 4.7.1. Device and simulator archives merge the matching
godot-cpp implementation objects before XCFramework packaging; the companion
export plugin links GameKit persistently instead of patching generated Xcode
projects.

## License

MIT — see [LICENSE](LICENSE).
