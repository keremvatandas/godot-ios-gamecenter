# Research: Market Ready Game Center Plugin

## Request summary

- Task: turn the working GameCenterKit package into a complete, publishable Godot
  add-on and prepare it for the current Godot Asset Store.
- Desired outcome: a reproducible release ZIP, hardened GameKit bridge, verified Godot
  compatibility, useful documentation, and Store-ready listing/media material.
- Product direction approved by the maintainer: **Market-ready Core 1.0**. Keep the
  focused authentication, score, achievement, dashboard, and access-point surface;
  do not expand 1.0 into a comprehensive GameKit binding.

## Current behavior

- `GameCenterKit` is a godot-cpp GDExtension singleton targeting Godot 4.5 and later.
- The current public API supports authentication, player display name, score
  submission, achievement reporting, the leaderboard/achievement dashboards, and
  `GKAccessPoint` visibility.
- Asynchronous score, achievement, and authentication results are emitted as Godot
  signals through deferred calls.
- The example project owns the distributable add-on layout under
  `example/addons/gamecenter`; CI copies it into `dist/addons/gamecenter` and builds a
  release ZIP.
- CI successfully builds an iOS XCFramework plus universal macOS debug/release
  dylibs. The latest successful workflow artifact contained all binary paths declared
  by `gamecenter.gdextension`.
- The integration has been exercised successfully in the maintainer's Gridlord app.

## Relevant files and modules

- `src/game_center_kit.mm`: Objective-C++ GameKit implementation and UIKit
  presentation.
- `src/game_center_kit.h`: Godot-visible API.
- `src/register_types.cpp`: GDExtension entry point and singleton lifecycle.
- `SConstruct`: Apple compilation/link settings and output paths.
- `tools/build_xcframework.sh`: device, simulator, and macOS artifact build.
- `example/addons/gamecenter/gamecenter.gdextension`: compatibility and library
  manifest.
- `example/addons/gamecenter/plugin.gd`: iOS export hook that links GameKit.
- `example/addons/gamecenter/plugin.cfg`: editor plug-in metadata and version.
- `example/main.gd`: interactive example.
- `.github/workflows/build.yml`: build, package, artifact, and draft-release workflow.
- `README.md` and `LICENSE`: repository-level documentation and licensing.

## Dependencies and external constraints

- `godot-cpp` is pinned as a non-runtime build submodule at commit
  `e83fd0904c13356ed1d4c3d09f8bb9132bdc6b77` (`godot-4.5-stable`). Godot documents
  earlier-minor GDExtensions as forward-compatible with later Godot 4 minor releases.
- The add-on uses the official single-precision Godot API. Custom double-precision
  engine builds are outside the 1.0 binary compatibility contract.
- The selected modern `GKLeaderboard.submitScore` API is available on iOS 14 and
  macOS 11. Core 1.0 will make those versions explicit minimums instead of retaining
  a deprecated API fallback.
- Godot's iOS exporter already owns the Game Center entitlement through
  `entitlements/game_center`; the add-on must not patch generated Xcode projects.
- The current Godot Asset Store succeeds the legacy Asset Library. It accepts uploaded
  version archives, requires plug-ins to install under `addons/<name>/`, requires all
  libraries declared by a `.gdextension`, and requires a 16:9 listing thumbnail.
- The Store currently accepts free assets and optional donation links. AI use must be
  disclosed in the listing.
- The distributable binary statically links godot-cpp, so its MIT notice must remain
  in the downloaded add-on.

## Competitor and positioning notes

- Godot's official documentation links to the maintained iOS plug-ins source tree,
  which includes GameCenter, although its latest prebuilt GitHub release is still the
  3.5 release.
- The new Store already contains `Godot Apple Plugins`, a much broader Apple binding
  covering Game Center, StoreKit, Sign in with Apple, ARKit, CoreMotion, saved games,
  and multiplayer features.
- GameCenterKit should therefore be positioned as a small, focused, signal-driven
  Game Center bridge with a prebuilt Godot 4 add-on, not as the only available Godot 4
  Game Center integration.

## Risks and edge cases

- `submit_score()` currently builds for iOS 12 while calling an iOS 14 API. CI emits
  `-Wunguarded-availability-new`; an iOS 12/13 process may receive an unsupported
  selector.
- The macOS deployment target is inherited from the build host. The same source
  produced a macOS 14 minimum in CI and macOS 26 locally.
- UIKit presentation currently uses `UIApplication.windows.firstObject.rootViewController`,
  which is deprecated and can select the wrong window/controller in scene-based or
  modal applications.
- Native completion blocks capture a raw singleton pointer. Pending callbacks must not
  call into a deleted GDExtension object during shutdown/reload.
- Dashboard methods cannot report presentation failure and do not signal dismissal.
- Empty leaderboard/achievement identifiers and out-of-range achievement percentages
  currently reach GameKit without local validation.
- The editor plug-in has only been exercised on Apple-hosted editors. Its platform
  detection should avoid referencing platform classes that may not exist in other
  editor builds.
- CI compiles but does not currently open the project with Godot, validate the release
  archive, generate an iOS Xcode project, or link the exported project.
- The workflow lacks explicit `contents: write` permission for tag-driven GitHub
  releases.
- The repository is private, has no tags/releases, and has no GitHub description or
  topics. Publication actions are external and will require a separate final approval.

## Unknowns and assumptions

- Core 1.0 will support official Godot 4.5 through 4.7, with 4.5 used as the binary
  build baseline and 4.7 used as the current compatibility smoke target.
- iOS 14 and macOS 11 are acceptable minimum platform versions for this release.
- Gridlord may be mentioned in public marketing only after the maintainer approves the
  final listing copy.
- A generated, trademark-safe thumbnail may use generic trophy/controller imagery but
  will not use Apple or Game Center logos.
- Full GameKit coverage (friends, saved games, identity verification, matchmaking,
  challenges, leaderboard queries) is a post-1.0 roadmap and is not an acceptance
  requirement here.

## Baseline checks

Commands and inspections completed:

- `git status --short`, `git log`, `git archive HEAD`, and repository file inventory.
- Source and manifest inspection across the bridge, example, export plug-in, build
  script, and workflow.
- `gh repo view`, `gh release list`, `gh run list`, and successful workflow artifact
  download/inspection.
- `gh run view 33784994008 --log` warning audit.
- `file`, `plutil`, `nm`, and `vtool` checks on local and CI-produced binaries.
- Official Godot 4.7 Asset Store guidelines, GDExtension compatibility docs, iOS
  plug-in docs, current Store listings, and Apple GameKit/UIKit docs were reviewed on
  2026-09-04.
- Independent read-only Codex-Fugu audit returned `REQUEST CHANGES` and corroborated
  the availability, packaging, lifecycle, CI, documentation, and publication gaps.

Current results:

- Worktree was clean before this spec package was created.
- Core build and XCFramework packaging succeed.
- Device slice: arm64. Simulator slices: arm64 and x86_64. macOS dylibs: arm64 and
  x86_64.
- `gamecenter_library_init` is exported and godot-cpp implementation objects are
  included in the static archive.
- CI distribution contains the required libraries and combined MIT notices, but lacks
  an add-on README and is not yet published as a tagged release.
