# Status: Market Ready Game Center Plugin

## Current status

- Tasks 1-6 are complete: hardened runtime binaries now feed one validated,
  installable Core 1.0 add-on ZIP with combined license notices, add-on docs,
  Godot 4.5/4.7 smoke coverage, iOS export checks, and CI release gates.
- Public documentation, Store copy, release notes/checklist, and a verified 1280 x 720
  trademark-safe Store thumbnail are ready for review.
- Task 7 is next: run the complete release-candidate verification and stop before any
  external publication.

## Decisions

- Product scope: focused Core 1.0, not full GameKit bindings.
- Compatibility: Godot 4.5-4.7 official single precision, iOS 14+, macOS 11+.
- Existing API remains stable; `panel_closed` and `panel_failed` are additive.
- Modern `GKLeaderboard` API is retained; no deprecated iOS 12/13 fallback.
- Current Godot Asset Store with direct version ZIP upload is the primary publication
  channel; no legacy Asset Library dist branch is planned.
- External publication actions require a separate final approval.

## Validation history

- 2026-09-04: repository, source, build, workflow, package, and binary baseline audited.
- 2026-09-04: latest CI run confirmed successful build with three iOS availability
  warnings that Core 1.0 must eliminate.
- 2026-09-04: CI artifact verified to contain all declared binaries and combined MIT
  notices; missing add-on README confirmed.
- 2026-09-04: CI macOS minimum observed as 14.0; local build minimum observed as 26.0;
  nondeterministic deployment target confirmed.
- 2026-09-04: Godot/Apple/Asset Store primary documentation and existing Store
  competition reviewed.
- 2026-09-04: independent Codex-Fugu read-only audit completed with `REQUEST CHANGES`.
- 2026-09-04: spec self-review completed for placeholders, contradictions, scope, and
  ambiguity.
- 2026-09-04: maintainer approved the written spec and requested implementation/testing,
  corrected `.gitignore` rules, English Conventional Commits, and no AI labels/trailers.
- 2026-09-04: detailed implementation plan written and self-reviewed at
  `docs/superpowers/plans/2026-09-04-gamecenterkit-core-1-0.md`.
- 2026-09-04: repository hygiene contract first failed for six missing ignore cases,
  then passed both tests after `.gitignore` was made explicit. `git diff --check`
  passed and `example/main.gd.uid` remained unignored.
- 2026-09-04: native contract test first failed because the helper did not exist,
  then passed under C++17 with warnings treated as errors. Repository contract tests
  and `git diff --check` also passed, with no test binary left in the worktree.
- 2026-09-04: official Godot 4.5.2 runtime contract first failed on the missing
  `panel_failed` signal, then passed after bridge hardening. The macOS 11 debug and
  iOS 14 arm64 release targets compiled successfully; deprecated application-global
  UIKit window lookup is no longer present.
- 2026-09-04: package contract first failed because no packager existed, then passed
  against the generated Store-ready ZIP. The release validator confirmed iOS 14
  arm64 device, iOS 14 arm64/x86_64 simulator, macOS 11 arm64/x86_64 debug/release,
  the exported entry symbol, package root, manifest paths, Core 1.0 version, README,
  and combined MIT notices. Native plus all three Python tests passed.
- 2026-09-04: package integration also verified Python 3.8 compatibility and fat
  simulator archive inspection per architecture. Python cache/coverage paths were
  added to the repository hygiene contract.
- 2026-09-04: official Godot 4.5.2 and 4.7.2 editor/runtime smoke tests passed
  with the plug-in enabled. The official 4.5.2 iOS export template produced both
  debug and release Xcode projects with GameKit, the GameCenterKit XCFramework,
  and the Game Center entitlement. An unsigned x86_64 simulator link passed; the
  explicit architecture works around the official 4.5.2 template's simulator
  archive containing x86_64 objects while advertising arm64 as well.
- 2026-09-04: the Store media contract first failed because no thumbnail existed,
  then passed after a generated banner was reviewed and resampled to exactly
  1280 x 720. Repository documentation, Core 1.0 changelog, Store fields, release
  notes, and the publication/device checklist were prepared without publishing them.

## Blockers and open questions

- Gridlord name usage, repository visibility, public version/tag, release publication,
  and Store submission remain release-stage decisions.

## Next step

- Execute Task 7 from the implementation plan, record the exact release-candidate
  results, and hand off the external publication decisions to the maintainer.
