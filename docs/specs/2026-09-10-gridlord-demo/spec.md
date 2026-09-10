# GridLord integration demo and configuration repair

## Research and correction

User approved real-device MP4, screenshots and README example, then authorized
necessary integration fixes on 2026-09-10. iPhone11/iOS26.4.2 runs GridLord
0.12.0 build30. Its vendored native source e2e4798 already includes panel preflight
and lifetime fixes. Latest GridLord main has no newer Game Center fix.

The initial conclusion that leaderboards were broken was incorrect: the user
confirmed the physical panel appears. XCTest/mirrored screenshots omit Apple's
GameOverlayUI; an absent image is not proof of presentation failure.

App Store Connect's current Game Center page has one main leaderboard and zero
achievements. The achievements button correctly reports a failure for missing
metadata. Existing gameplay catalogue and translations are the configuration
source of truth; preserve saved player progress and avoid synthetic score writes.

## Requirements and design

1. Configure missing achievement definitions using existing bundle-scoped IDs,
   gameplay descriptions and existing badge assets; verify through GameKit UI.
2. Check required leaderboard IDs against service configuration.
3. Do not change native presentation based on a capture limitation. Make code
   changes only for a separately demonstrated defect and test the affected flow.
4. Capture real device navigation, native panel and return in a short silent video;
   verify actual file streams and visible frames before publishing.
5. Insert a compact README demo section after the introduction, with real capture
   provenance and an authenticated, platform-guarded code example.

## Milestones and validation

- M1: service configuration audit/repair; verify saved IDs, localization and device.
- M2: native/consumer changes only if required; run relevant regression and E2E.
- M3: USB capture and media verification (ffprobe + visual frame inspection).
- M4: README links/media checks, scoped commit, main integration, remote check,
  task branch cleanup. Do not stage unrelated shutdown-crash or MCPRuntime edits.

No App Store review submission or new public app release is required for this
work. Existing production metadata and player state must be preserved.
