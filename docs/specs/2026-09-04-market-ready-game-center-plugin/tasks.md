# Tasks: Market Ready Game Center Plugin

This is the milestone-level source of truth. A detailed implementation plan will be
written after the spec review gate.

## Milestone 1: Runtime safety and compatibility

Outcome:

- Current API remains compatible.
- iOS/macOS minimums are deterministic.
- Scene-aware UI presentation, panel result signals, input validation, and callback
  lifetime protection are implemented.

Files affected:

- `src/game_center_kit.h`
- `src/game_center_kit.mm`
- `src/register_types.cpp`
- `SConstruct`
- `tools/build_xcframework.sh`
- focused test files/seams introduced by the implementation plan

Validation:

- Focused validation/input/lifecycle tests.
- Full Apple artifact build with availability warnings treated as errors.
- Binary deployment-target, architecture, and entry-symbol inspection.

Rollback note:

- Revert native bridge and build-argument commits together; no persistent data changes.

## Milestone 2: Add-on contract, example, and self-contained docs

Outcome:

- Export plug-in is safe to parse across editor hosts.
- Example demonstrates every Core 1.0 signal.
- Installed add-on contains complete install/API/troubleshooting/license documentation.

Files affected:

- `example/addons/gamecenter/plugin.gd`
- `example/addons/gamecenter/plugin.cfg`
- `example/addons/gamecenter/gamecenter.gdextension`
- `example/addons/gamecenter/README.md`
- `example/main.gd`
- `README.md`
- `CHANGELOG.md`

Validation:

- Godot 4.5 and 4.7 headless import/load checks.
- Example invalid-input checks.
- Documentation/API/version consistency checks.

Rollback note:

- Revert add-on/example/docs changes without affecting the native build from Milestone 1.

## Milestone 3: Reproducible Store-ready packaging and CI

Outcome:

- One command and CI produce/validate the same installable ZIP.
- CI covers binaries, Godot smoke tests, package layout, and iOS export/link behavior.
- Tag/version mismatch fails; draft-release permission is explicit.

Files affected:

- `tools/build_xcframework.sh`
- new package and validation scripts under `tools/`
- `.github/workflows/build.yml`
- optional example export fixtures

Validation:

- Local packaging validation.
- Clean-project install smoke test.
- CI-equivalent Godot 4.5/4.7 checks.
- iOS debug/release export and simulator link smoke test where supported.

Rollback note:

- Runtime artifacts remain usable even if new CI steps are reverted; retain the last
  known-good release workflow until replacement checks pass.

## Milestone 4: Store listing and media kit

Outcome:

- Store copy, version notes, tags, AI disclosure, release checklist, and a compliant
  trademark-safe 16:9 thumbnail are ready for review.

Files affected:

- `marketing/store-listing.md`
- `marketing/release-checklist.md`
- `marketing/media/*`
- `README.md`

Validation:

- Image dimensions/format check.
- Listing requirement checklist against current Store guidelines.
- Link/copy review and explicit Gridlord attribution decision.

Rollback note:

- Marketing assets are independent of code and can be replaced without rebuilding the
  plug-in.

## Milestone 5: Release-candidate verification and publication handoff

Outcome:

- All acceptance criteria and manual device checks are summarized.
- A release ZIP, checksums, suggested GitHub metadata, tag/version, and Store upload
  fields are ready.
- External publication awaits a final explicit maintainer approval.

Files affected:

- `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`
- release notes/checksums produced by the packaging workflow
- no GitHub visibility/tag/Store mutation during this milestone without approval

Validation:

- Complete acceptance-criteria audit.
- Re-run full local/CI validation from a clean checkout or equivalent staging tree.
- Manual Gridlord/example device checklist recorded.

Rollback note:

- No external state is changed before approval; discard the release candidate and fix
  locally if any gate fails.
