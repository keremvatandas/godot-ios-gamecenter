# Requirements: Market Ready Game Center Plugin

## Goal

Ship GameCenterKit Core 1.0 as a reliable, reproducible, documented Godot add-on that
can be uploaded to the current Godot Asset Store after a separate publication approval.

## Non-goals

- Comprehensive GameKit bindings for friends, saved games, matchmaking, challenges,
  turn-based play, or leaderboard/achievement queries.
- Android, Windows, Linux, web, tvOS, or visionOS runtime implementations.
- Compatibility with Godot 3, Godot 4.0-4.4, custom double-precision builds, or custom
  Godot APIs.
- Paid distribution, donation-account setup, App Store Connect entity creation, code
  signing, provisioning, or editing generated Xcode projects.
- Changing GitHub visibility, pushing tags, publishing releases, or submitting to the
  Store without a final explicit approval.

## Functional requirements

### Runtime and API

- WHEN a project runs with a compatible binary, THE SYSTEM SHALL register exactly one
  `GameCenterKit` Engine singleton and unregister it safely during shutdown.
- WHEN existing clients call any current method or connect to any current signal, THE
  SYSTEM SHALL preserve the current method names, parameter types, and signal argument
  order.
- WHEN authentication completes, fails, or is declined, THE SYSTEM SHALL emit
  `authenticated(ok, error)` once for the terminal authentication callback on Godot's
  main thread.
- WHEN GameKit supplies an authentication view controller on iOS, THE SYSTEM SHALL
  present it from the active foreground scene's topmost view controller.
- WHEN a valid score submission completes, THE SYSTEM SHALL emit
  `score_submitted(ok, leaderboard_id, error)` on Godot's main thread.
- WHEN a valid achievement report completes, THE SYSTEM SHALL emit
  `achievement_reported(ok, achievement_id, error)` on Godot's main thread.
- WHEN a dashboard is dismissed, THE SYSTEM SHALL emit an additive
  `panel_closed(panel)` signal, where `panel` is `leaderboard` or `achievements`.
- WHEN a dashboard cannot be presented, THE SYSTEM SHALL emit an additive
  `panel_failed(panel, error)` signal rather than failing silently.
- WHEN a leaderboard or achievement identifier is empty, THE SYSTEM SHALL reject the
  call locally and answer through the corresponding existing failure signal.
- WHEN achievement percentage is outside 0 through 100 inclusive, THE SYSTEM SHALL
  reject the call locally and answer through `achievement_reported(false, ...)`.
- WHEN a UI action is requested outside iOS, THE SYSTEM SHALL avoid a crash and provide
  a useful log or failure signal consistent with the action's contract.
- WHEN the extension begins shutdown, THE SYSTEM SHALL prevent pending native blocks
  and the authentication handler from calling a deleted Godot object.

### Compatibility and build

- WHEN release artifacts are built, THE SYSTEM SHALL target iOS 14.0 or later and
  macOS 11.0 or later deterministically on every build host.
- WHEN a newly introduced Apple API is used without an availability guarantee, THE
  BUILD SHALL fail through `-Werror=unguarded-availability-new`.
- WHEN the add-on is opened with official Godot 4.5 and 4.7 single-precision editors,
  THE SYSTEM SHALL load without missing-library, parse, or GDExtension initialization
  errors on supported macOS hosts.
- WHEN an iOS debug or release export is generated, THE SYSTEM SHALL include the
  GameCenterKit XCFramework, link GameKit, and include the Game Center entitlement when
  the documented export option is enabled.

### Packaging and release

- WHEN a release package is created, THE SYSTEM SHALL produce one ZIP whose install
  root is `addons/gamecenter/`.
- WHEN the ZIP is inspected, THE SYSTEM SHALL contain every library path declared by
  `gamecenter.gdextension`, the editor export plug-in, add-on README, GameCenterKit MIT
  license, and godot-cpp MIT notice.
- WHEN CI uploads a workflow artifact or creates a draft tag release, THE SYSTEM SHALL
  use that same Store-ready ZIP rather than a differently rooted raw directory.
- WHEN a release is built from tag `vX.Y.Z`, THE BUILD SHALL fail if the add-on version
  is not `X.Y.Z`.
- WHEN tag release automation runs, THE WORKFLOW SHALL have explicit least-privilege
  permission to create the draft release.

### Documentation and marketing

- WHEN a user reads the repository or add-on README, THE DOCUMENTATION SHALL state the
  Godot/iOS/macOS compatibility matrix, installation and entitlement steps, complete
  Core 1.0 API, main-thread signal contract, limitations, troubleshooting, source-build
  steps, privacy behavior, and license notices.
- WHEN the project is positioned publicly, THE COPY SHALL describe it as a focused,
  prebuilt, signal-driven Game Center bridge and SHALL NOT claim that no other Godot 4
  Game Center solution exists.
- WHEN Store material is prepared, THE REPOSITORY SHALL include editable listing copy,
  a changelog, an AI-use disclosure, suitable tags, and a trademark-safe 16:9 thumbnail.
- WHEN marketing copy refers to Gridlord by name, THE MAINTAINER SHALL have approved
  that exact public wording.

### Validation

- WHEN a pull request or main-branch build runs, THE SYSTEM SHALL build all artifacts,
  validate binary architectures/deployment targets/exported entry symbol, validate
  package contents, and run Godot 4.5/4.7 smoke checks.
- WHEN implementation is declared complete, THE CURRENT WORKTREE SHALL pass the same
  local checks available on the maintainer's macOS/Xcode host.
- WHEN a release candidate is ready, THE MAINTAINER SHALL receive a short manual device
  checklist for final Game Center sandbox validation in Gridlord or the example app.

## Constraints

- Preserve the current GDScript API; only additive signals and documentation are
  allowed in Core 1.0.
- Keep `godot-cpp` pinned to Godot 4.5 for the 1.0 compatibility baseline.
- Continue using Godot's native `entitlements/game_center` export option.
- Do not add a deprecated iOS 12/13 score-submission fallback.
- Keep the add-on focused and avoid unrelated refactors.
- Use official Godot/Apple documentation and first-party Store rules for compatibility
  and publication decisions.
- Keep build artifacts reproducible from source; generated binaries remain ignored in
  normal development and enter the distributable only through packaging.

## Acceptance criteria

- No unguarded-availability warnings remain, and deployment targets read iOS 14.0 and
  macOS 11.0 from the produced binaries.
- Scene-safe presentation replaces application-global window selection.
- All current API calls remain source-compatible, and the two additive panel signals
  are documented and exercised.
- Invalid inputs return deterministic failure signals without calling GameKit.
- Shutdown/reload does not leave an authentication handler capable of using a deleted
  singleton.
- Godot 4.5 and 4.7 macOS smoke tests pass; iOS debug/release export/link validation
  passes in CI or any unautomatable signing limitation is explicitly documented.
- The Store-ready ZIP has the correct `addons/gamecenter` root, required binaries,
  README, combined notices, and version.
- CI builds and validates that ZIP and can create a draft release on a matching tag.
- Store listing copy, changelog, AI disclosure, and a compliant 16:9 thumbnail exist
  and have been reviewed.
- The worktree is clean after committed milestones, with all validation outcomes
  recorded in `status.md`.

## Open questions

- Whether the final public listing may say “tested in Gridlord” will be decided during
  copy review; it does not block implementation.
- Repository visibility, the first public version number, release publication, and
  Store submission remain final-release decisions requiring explicit approval.
