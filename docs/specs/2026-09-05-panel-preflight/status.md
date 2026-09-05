# Status

- Research complete; native/UI device evidence in GridLord's
  docs/specs/2026-09-05-gamecenter-release-device-test/ and ignored test_output.
- Baseline C++ contracts, 9 Python tests and Godot 4.7.1 smoke pass.
- Request gate regression first failed to compile against baseline (missing gate),
  then passed after implementation. Covers pending exclusion, one completion,
  retry and a stale callback attempting to release the retry.
- Native patch: metadata preflight, 15-second timeout, main-queue UIKit, retained
  Game Center container during presenter traversal; no public API change.
- Full xcframework build passed for arm64 iOS, universal simulator, both universal
  macOS configurations. Nine Python tests, Godot 4.7.1 runtime smoke and package
  validation pass. iOS debug/release exports and unsigned x86_64 simulator link pass.
- GridLord feedback/input check: 19 checks, zero failures, EN/TR failure, retry,
  dismissal, unrelated-panel filtering, narrow wrapping, freed-page callbacks.
  First invocation used /tmp instead of macOS's OS temp directory and was correctly
  refused by save isolation; rerun used TMPDIR and passed. No real save fallback.
- Current: signed device candidate archive and independent Fugu review.
- Live successful panel appearance/dismissal remains unverified.
- First signed candidate failed on device: EXC_BAD_ACCESS in the queued preflight
  block reading CallbackLifetime. C++ reference parameters were captured by
  reference; the temporary lifetime token had already expired as a stack object.
  Changed helper arguments to owning value parameters for both weak token and
  shared request gate. This candidate was never merged. Rebuild/device retest
  required; initial build/smoke passes did not cover this asynchronous iOS path.
- Configured main leaderboard now loads on the real iPhone: count 1, correct
  baseLeaderboardID, no NSError. Authentication remains YES.
- Candidate 2 (owning callback arguments) no longer crashed on a real leaderboard
  tap; metadata completed and legacy GKGameCenterViewController presented, but
  its content was still absent in Mirroring. It was dismissed with LLDB.
- Fugu review 1 requested changes: shared GridLord pending-state serialization,
  iOS 26 isHidden rejection and real show_* ordering tests. All three implemented;
  31 GridLord checks now pass with FakeNative and deferred results. Review 2 runs.
- Candidate 3 builds all native slices, passes 9 Python tests, Godot smoke and
  release validator, and signed device archive; installed over existing app.
- Apple testing guide explicitly requires enabling a version for Game Center.
  Created GridLord 0.12.0 App Store Connect draft and enabled Game Center (checked,
  autosaved). Published 0.9.0 remains unchanged; no review submission or build upload.
- Modern access-point probe after metadata configuration was issued, but Mirroring
  switched to iPhone in Use before visual verification. Later LLDB property query
  was interrupted by candidate replacement; no successful AP result is claimed.
- Final device run and missing-achievements failure/retry remain pending.
- Added a native AddressSanitizer regression that includes the actual production
  helper, queues its block, destroys the lifetime owner and drains the main queue.
  No GameKit request or player data is involved. On the booted arm64 iOS simulator:
  old reference parameters reproduced stack-use-after-return (exit134); current
  owning parameters passed (exit0). The test is now in the Apple CI workflow.
- Fugu second review: APPROVE/HIGH, no P0/P1/P2. It verifies the three fixes and
  owning block captures; successful live presentation is explicitly not claimed.
- Candidate source is being committed on the feature branch so GridLord can
  provenance-lock its tested binaries. Main merge remains pending device closure.
- Separate macOS shutdown investigation is untouched.

## Final device evidence — 2026-09-05

- Native code e2e4798 is in GridLord's provenance-checked addon and signed iPhone
  candidate3. GridLord final gate passed129/129 E2E,31 panel/input checks,254 script
  parses,46 layouts with zero overflow,19 overlays and all other required checks.
  Firebase live social explicitly skipped without emulator;16 standard checks pass.
- Missing achievement definitions fail gracefully on the actual iPhone twice;
  the game remains navigable back to the main menu.
- A diagnostic UIKit alert from the same window rendered and closed in Mirroring.
  Apple's Games app profile also rendered. Access-point active/visible flags were
  true, but its dashboard was absent from the mirrored image. No migration made.
- Crucial correction: the user confirmed that the leaderboard opens on the
  physical phone ("telefonda aciliyor"). An empty legacy navigation stack and
  absent mirrored image do not establish failed Game Center presentation on
  iOS26. The mirrored overlay observation must not be reported as a plugin defect.
  Direct-device close/reopen/navigation confirmation remains pending.
- No synthetic score/achievement writes, player reset, App Store review, upload
  or publication. The separate macOS shutdown investigation remains untouched.
- Binary provenance cross-check: all1023 arm64 object payloads match byte-for-byte
  between GridLord's e2e4798 vendor archive and the candidate3 Xcode link input.
  Archive-container metadata differs; compiled object code does not.
