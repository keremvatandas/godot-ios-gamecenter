# Design: Market Ready Game Center Plugin

## Overview

Core 1.0 will harden the existing GameCenterKit singleton instead of turning the project
into a general Apple SDK binding. The release remains one GDExtension plus a small Godot
editor export plug-in:

1. GDScript calls the `GameCenterKit` Engine singleton.
2. The Objective-C++ bridge validates inputs and invokes GameKit.
3. Native completion handlers cross back to Godot through deferred signals.
4. iOS dashboard/authentication UI is presented from the active scene's topmost view
   controller.
5. The editor export plug-in links GameKit; Godot's existing export preset creates the
   entitlement.
6. CI builds deterministic Apple binaries, validates the package contract, and produces
   exactly one Store-ready ZIP.

The architecture intentionally keeps GameKit-specific state inside the native bridge and
keeps packaging/marketing concerns outside runtime code.

## Files likely to change

Runtime and build:

- `src/game_center_kit.h`
- `src/game_center_kit.mm`
- `src/register_types.cpp`
- `SConstruct`
- `tools/build_xcframework.sh`
- new validation scripts under `tools/`

Add-on and example:

- `example/addons/gamecenter/gamecenter.gdextension`
- `example/addons/gamecenter/plugin.gd`
- `example/addons/gamecenter/plugin.cfg`
- new `example/addons/gamecenter/README.md`
- add-on license/notice material generated or copied during packaging
- `example/main.gd`
- optional export preset/fixtures used only for CI smoke checks

Automation and public documentation:

- `.github/workflows/build.yml`
- `README.md`
- new `CHANGELOG.md`
- new Store listing material under `marketing/`
- new 16:9 thumbnail/banner under `marketing/media/`
- this spec package's `status.md`

## Architecture and data flow

### Native singleton lifecycle

- `register_types.cpp` continues to own the one `GameCenterKit` instance.
- The native object owns a callback-lifetime token that outlives pending Objective-C
  blocks. Destruction marks the token inactive before memory is released.
- Every completion block checks the token before dereferencing the singleton pointer.
- Destruction also clears `GKLocalPlayer.authenticateHandler` and disconnects the
  dashboard delegate from the bridge.
- Deferred Godot calls remain the final signal-delivery mechanism so the public
  main-thread contract is preserved.

### Authentication

- `authenticate()` installs the local player's handler once for the current request.
- A supplied authentication controller is sent to the scene-aware presenter.
- Controller presentation is executed on the Apple main queue.
- The terminal callback emits `authenticated(isAuthenticated, formatted_error)`.
- Repeated intermediate callbacks that only supply a controller do not emit a terminal
  authentication result.

### Scene-aware UI presentation

The presenter will:

1. inspect connected `UIWindowScene` instances;
2. prefer a foreground-active scene;
3. prefer that scene's key window, falling back to a visible normal-level window;
4. start from its root view controller;
5. walk presented controllers plus visible navigation/tab children;
6. present only from the resolved topmost controller.

If no valid presenter exists or another Game Center panel is already active, the bridge
emits `panel_failed(panel, error)`. A dashboard delegate dismisses the Game Center
controller and emits `panel_closed(panel)`. The same lifecycle guard used by completion
handlers protects delegate callbacks.

### Score and achievement operations

- Identifiers are trimmed/validated before conversion to `NSString`.
- Achievement percentage must be finite and within 0...100.
- Invalid values emit the existing operation-specific failure signal without touching
  GameKit.
- Valid score submission uses the modern iOS 14/macOS 11 `GKLeaderboard` API.
- Native errors are formatted consistently while retaining the existing String signal
  fields.

### Access point

- `set_access_point_visible()` remains synchronous and uses `GKAccessPoint` on the
  declared minimum platforms.
- It does not introduce a new signal in 1.0.

### Editor export plug-in

- The editor plug-in continues adding `GameKit.framework` through
  `add_apple_embedded_platform_framework`.
- Platform support detection will use a generic platform property/name check so loading
  the script does not require an iOS-only editor class on unsupported hosts.
- Entitlement creation remains documented as the user's export-preset responsibility.

### Reproducible build and package

- Build commands always pass `ios_min_version=14.0` and
  `macos_deployment_target=11.0`.
- Apple compilation treats new unguarded availability as an error.
- `tools/build_xcframework.sh` remains the artifact producer.
- A separate package/validation script stages:

  ```text
  addons/gamecenter/
    README.md
    LICENSE
    gamecenter.gdextension
    plugin.cfg
    plugin.gd
    bin/
      libgamecenter.ios.xcframework/...
      libgamecenter.macos.template_debug.universal.dylib
      libgamecenter.macos.template_release.universal.dylib
  ```

- The staged `LICENSE` contains GameCenterKit's MIT text and the godot-cpp MIT notice.
- The validator parses declared library paths instead of maintaining a second hardcoded
  list, checks file presence, architectures, entry symbol, deployment versions, root
  layout, required docs, and version/tag agreement.
- CI uploads the finished ZIP and attaches that exact file to a tag-triggered draft
  release.

### Documentation and Store material

- Repository README: product position, quick start, API, compatibility, build, and links.
- Add-on README: self-contained install/API/troubleshooting/license material retained in
  user projects.
- `CHANGELOG.md`: Keep a Changelog-style release history beginning with Core 1.0.
- `marketing/store-listing.md`: Store name, summary, full description, tags, version
  notes, AI disclosure, support/source links, and a final copy-review checklist.
- `marketing/media/`: trademark-safe 16:9 thumbnail and source notes. No Apple/Game
  Center logo is embedded.
- Gridlord attribution is a replaceable draft line until explicitly approved.

## API or contract impact

Existing API remains unchanged:

- `authenticate()`
- `is_authenticated() -> bool`
- `player_display_name() -> String`
- `submit_score(leaderboard_id, score)`
- `show_leaderboard(leaderboard_id)`
- `report_achievement(achievement_id, percent)`
- `show_achievements()`
- `set_access_point_visible(visible)`
- `authenticated(ok, error)`
- `score_submitted(ok, leaderboard_id, error)`
- `achievement_reported(ok, achievement_id, error)`

Additive Core 1.0 signals:

- `panel_closed(panel: String)`
- `panel_failed(panel: String, error: String)`

Compatibility contract:

- Godot 4.5-4.7, official single-precision builds.
- iOS 14.0+ runtime.
- macOS 11.0+ editor/runtime support.
- Other platforms may safely gate usage with `Engine.has_singleton`; no runtime binary is
  promised for them.

## Data model or migration notes

- No saved data or project migration is required.
- Existing GDScript continues to compile and run.
- Projects that previously exported with deployment target 12/13 must raise their iOS
  deployment target to 14 for Core 1.0.
- The package version becomes the canonical semantic version and must match the release
  tag.
- The add-on directory name and singleton name remain stable.

## Risks and tradeoffs

- Raising iOS to 14 drops iOS 12/13 rather than carrying deprecated `GKScore` code. This
  removes the runtime hazard and keeps the bridge modern at the cost of legacy devices.
- macOS 11 is chosen because the same modern leaderboard/access-point API is available
  there. It may exclude older machines that Godot 4.5 itself could otherwise run on.
- A lifetime token reduces callback-after-free risk without introducing a larger native
  event queue. Its thread behavior must be covered by focused native tests or a small
  test seam.
- Full App Store/Game Center authentication cannot be made deterministic in CI. CI will
  cover binary/link/export behavior; a sandbox-device checklist remains required.
- Godot 4.7 Store integration is current, while 4.5/4.6 users may still discover assets
  through older channels. The release ZIP remains installable manually for those users;
  no legacy Asset Library dist branch is part of Core 1.0.
- Marketing imagery produced with generative tooling requires explicit Store disclosure.

## Test plan

### Focused tests

- Add test seams for identifier/percentage validation and error formatting where
  practical without mocking all of GameKit.
- Exercise scene/presenter selection with deterministic helper tests where UIKit permits;
  otherwise compile-test the helper and cover failure branches through the example.
- Verify all signal names and argument shapes from the example script.

### Binary validation

- Build iOS device arm64 and simulator arm64+x86_64 slices.
- Build macOS debug/release arm64+x86_64 dylibs.
- Inspect `LC_BUILD_VERSION`, XCFramework plist, entry symbol, and static archive content.
- Fail on compiler warnings related to API availability.

### Godot smoke validation

- Open/import the example headlessly with official Godot 4.5 and 4.7 on macOS.
- Assert the editor plug-in parses and `GameCenterKit` registers.
- Exercise invalid-input paths without a Game Center account.
- Generate iOS debug and release Xcode exports with the entitlement enabled.
- Build at least the simulator target with code signing disabled to catch missing symbols
  and framework linkage.

### Package validation

- Inspect the final ZIP root and compare manifest library paths against actual entries.
- Confirm README and combined license notices exist in the installed add-on.
- Install the ZIP into a clean temporary Godot project and repeat the macOS smoke check.

### Manual release-candidate validation

- Authenticate with a Game Center sandbox account.
- Submit a score and confirm `score_submitted`.
- Report an achievement and confirm `achievement_reported`.
- Present/dismiss both dashboards and confirm close signals.
- Toggle the access point.
- Repeat from a scene with an existing modal to validate topmost presentation.
- Confirm an export with the entitlement disabled fails clearly/documentedly and an
  enabled export works.

## Rollback notes

- Runtime hardening is isolated to `GameCenterKit`; the previous bridge can be restored
  without changing the add-on layout.
- New panel signals are additive and can remain even if the presenter implementation is
  reverted.
- Deployment target changes are build arguments and can be adjusted independently, but
  lowering below iOS 14/macOS 11 would require a designed API fallback.
- Packaging and marketing changes do not affect runtime and can be reverted separately.
- No external publication mutation occurs until the release candidate is validated and
  separately approved.
