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

1. Copy `addon/gamecenter` into your project as `addons/gamecenter`.
2. Open the project once (the editor's scan registers the extension).
3. In your iOS export: enable the **Game Center capability** on the Xcode
   project Godot generates (Signing & Capabilities → + Capability → Game
   Center). No Info.plist keys are required.
4. Create your leaderboards/achievements in App Store Connect; the ids you
   pass to `submit_score`/`report_achievement` are the ASC ids.

macOS builds of the library exist so the extension loads in the editor
during development: auth state and score submission run real GameKit
there, the two panel presenters are iOS-only and log that instead.

## Build from source

```bash
git clone --recurse-submodules git@github.com:keremvatandas/godot-ios-gamecenter.git
cd godot-ios-gamecenter
tools/build_xcframework.sh   # needs Xcode + SCons
tools/sync_example.sh        # refresh the example's addon copy
```

Built against godot-cpp `godot-4.5-stable` with `compatibility_minimum = "4.5"`;
exercised on Godot 4.7.1. The API surface used (Object, signals, Engine
singleton registration) has been stable since 4.1.

## License

MIT — see [LICENSE](LICENSE).
