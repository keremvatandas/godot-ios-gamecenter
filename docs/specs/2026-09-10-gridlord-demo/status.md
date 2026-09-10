# Status — 2026-09-10

Follow-up: the user preferred a simple game reference over the demo. README now
has a **Games using GameCenterKit** section linking to GridLord's verified App
Store listing. The original media remains archived under `marketing/media/gridlord/`.
The delivery details below describe the initial demo work.

## Delivered changes

- README: real GridLord iPhone demo, two frame captures and guarded GDScript example.
- Media: 21-second silent H.264 MP4, 540 × 1168 at 30 fps; capture provenance and
  SHA-256 checksums under `marketing/media/gridlord/`.
- App Store Connect: created all 23 existing GridLord achievement IDs (10 points
  each, EN-US/TR, non-repeatable; only Duelist hidden), plus missing daily
  leaderboard. GridLord `docs/game-center/` records the configuration and limitations.
- Native/runtime code unchanged. Physical user confirmation and QuickTime USB
  capture disproved the original inference that leaderboards could not present.

## Validation

PASS: physical iPhone 11 / iOS 26.4.2 / GridLord 0.12.0 build 30 opens the main
leaderboard and returns to statistics via Apple's Play button. Video shows this
actual sequence; idle intervals are cut, player identity blurred, audio removed.

PASS: ffprobe stream/duration check, full FFmpeg decode, visual frame review and
SHA-256 verification. Existing marketing media unit test passes. `git diff --check`
passes. GridLord manifest matches all 23 catalogue IDs, both locales, total points,
visibility/repeatability policy and the existing icon's hash.

PASS: ASC list contains all 23 IDs and 10 points each; both languages saved for
all records. Sample reopened records First Light, Triple Threat and Codex Complete
have two processed icon uploads. Daily has EN-US/TR names and the exact client ID.
Version 0.12.0 has Game Center enabled. Records remain Prepare for Submission.

PARTIAL: native achievements now opens but still shows one hidden First Light
entry after relaunch. Full 23-entry physical catalogue visibility remains unverified;
service/device caching is suspected, not proven. Daily uses a single classic best
score leaderboard across challenges, matching the current client ID mapping; it
has no daily reset contract. These limits are documented in GridLord.

SKIP: artificial score/progress writes, progress reset, new app build, native
compilation and App Review submission. Only documentation/media and service
configuration changed. Documentation delivery uses `[skip ci]` to avoid rebuilding
unchanged Apple binaries; local relevant checks are recorded above.

## Preservation and delivery

Unrelated shutdown-crash notes in this repository and GridLord's existing
MCPRuntime change are excluded. GridLord documentation is isolated in the
`gamecenter-config` worktree. Delivery uses scoped commits and main integration;
remote verification and task-branch cleanup are reported in the task handoff.
