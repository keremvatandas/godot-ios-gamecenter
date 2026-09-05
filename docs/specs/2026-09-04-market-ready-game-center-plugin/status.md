# Status: Market Ready Game Center Plugin

## Current status

- Tasks 1-7 are complete: hardened runtime binaries now feed one validated,
  installable Core 1.0 add-on ZIP with combined license notices, add-on docs,
  Godot 4.5/4.7 smoke coverage, iOS export checks, and CI release gates.
- Public documentation, Store copy, release notes/checklist, and a verified 1280 x 720
  trademark-safe Store thumbnail are ready for review.
- The automated release candidate is ready for the maintainer's post-change physical
  device sandbox test and publication decisions. No external publication was performed.

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
- 2026-09-04: final release-candidate verification passed the native contract test,
  all four Python tests, full Apple artifact build, package creation plus an independent
  validation pass, `actionlint`, `git diff --check`, official Godot 4.5.2 and 4.7.2
  editor/runtime smoke checks, debug/release iOS exports, and an unsigned x86_64
  simulator link. The example Xcode link emitted only the official template's three
  empty privacy-description warnings. The ZIP contains 17 entries rooted exclusively
  at `addons/gamecenter/`; its SHA-256 is
  `26dc8682fa1c07669ed2d3bae382e4dea489e5bf8c99cc8cb2fec10991346bb0`.
- 2026-09-04: every commit subject from the approved baseline through the release
  candidate matches the English Conventional Commits pattern. Commit bodies contain
  no co-author, generated-by, or AI-assistance trailers.

## Blockers and open questions

- Gridlord proved the pre-hardening package worked, but the post-change release
  candidate has not yet completed the physical-device sandbox checklist. Authentication,
  score, achievement, both panels, access point, modal presentation, and entitlement
  must be rerun before claiming device validation for this exact candidate.
- Public Gridlord wording, repository visibility, GitHub description/topics, tag
  `v1.0.0`, draft release publication, and Store upload/submission remain explicit
  maintainer decisions.

## Next step

- Run the physical-device checklist in Gridlord or the example app, review the Store
  draft, then explicitly approve whichever external publication actions should proceed.


## Publication: 2026-09-05

- Maintainer confirmed the preceding device-test question and requested the necessary
  GitHub release and Godot Asset Store publication steps. This supersedes the earlier
  pending publication decision. Device confirmation is maintainer-reported.
- Plan: independently validate the successful CI archive; publish v1.0.0 pointing at
  that exact tested commit; verify the public download; submit the same ZIP to Store.
- Successful run: 33920836650, commit 2d2e8dd683f143f15fc0452f4e2a4564575b1c28.
- CI archive downloaded to dist/release-1.0.0/gamecenter-addon.zip and independently
  validated with tools/validate_release.py. Package SHA-256:
  d16bbdc7e78bb651c01e90ca45968e84de660187d2da2f76648bd963cc1a9e83.
- Repository is already public. Store login is required; sign-in page opened and
  maintainer asked to log in while GitHub publication proceeds.
- Keep the optional public Gridlord proof line omitted from the listing. Publish
  the prepared technical description, MIT license, and factual AI disclosure.

- Published https://github.com/keremvatandas/godot-ios-gamecenter/releases/tag/v1.0.0
  with the verified CI ZIP and SHA256SUMS. GitHub created the tag at the exact
  tested commit through the release API; no redundant tag build was started.
- Public unauthenticated ZIP download is byte-identical to the validated CI archive.
- Repository description and Godot/iOS/GameKit topics are configured. Source/support
  URLs in the Store listing now reflect the existing public repository.
- GitHub publication is complete. Store submission is pending only the maintainer's
  account login; no Store asset has been created or submitted yet.

### Store submission resumed

- Maintainer logged in. Asset creation form is filled with publisher Kerem Vatandas
  (`keremvatandas`), asset GameCenterKit for Godot (`gamecenterkit`).
- The form requires explicit agreement to the Store Terms of Service before its
  metadata/version/media pages become available. Requested the required at-action
  confirmation; the checkbox remains unchecked until the maintainer answers.
- Rechecked the release ZIP SHA-256 and the 1280 x 720 thumbnail. AI disclosure
  describes implementation, review, tests, CI, documentation, and promotional art
  assistance without claiming an unobserved live GameKit device result.
- Maintainer explicitly approved Terms acceptance ("onayliyorum"). Accepted the
  terms and created the asset at
  https://store.godotengine.org/asset/keremvatandas/gamecenterkit/.
- Saved the description, MIT license, source link, five tags, and AI disclosure.
  Converted the existing 1280 x 720 PNG to JPEG (194,740 bytes) to meet the Store's
  600 KB image limit, and saved it as the thumbnail. Original artwork is retained.
- Uploaded the exact verified release ZIP as stable version `1.0.0`, minimum
  Godot `4.5`, maximum `4.7.x`. Store shows 28.38 MB and version Pending Approval.
- Reviewed the rendered description, code example, links, license, AI notice,
  and thumbnail. All required publication fields were marked complete.
- Submitted the asset for moderator review. Dashboard now explicitly reports
  **Asset Status: Pending** and says the page becomes public after team review.
  Store submission is complete; moderator approval remains external and pending.
