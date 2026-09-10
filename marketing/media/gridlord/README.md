# GridLord device capture

Captured on 2026-09-10 from a USB-connected iPhone 11 running iOS 26.4.2 and
GridLord 0.12.0 (build 30), using QuickTime Player's **New Movie Recording >
Screen > iPhone** input.

- `gridlord-gamecenter-demo.mp4`: 21 seconds, H.264, 540 × 1168, 30 fps, no audio.
- `gridlord-main-menu.png`: frame at 0.5 seconds from the edited video.
- `gridlord-gamecenter-leaderboard.png`: frame at 15 seconds from the edited video.

The sequence shows the Godot main menu, statistics screen, native Game Center
leaderboard and return to statistics through Apple's Play button. Idle intervals
were removed with cuts; playback speed is unchanged. Player avatar/name details
are blurred. Scores, game UI and Apple's prerelease notice are unchanged. No
scores or achievement progress were synthesized for this recording.

The original 57.98-second USB recording remains outside the public repository.
This is an actual device recording, not a mockup or generated image. GridLord
artwork belongs to DEBIVA; this showcase does not change ownership of game assets
or Apple's interface. No music is included.

XCTest screenshots on this device omitted Apple's GameOverlayUI despite the
panel being visible on the phone. Use USB video capture when collecting evidence
of native panels; a missing overlay in an XCTest screenshot does not prove a
presentation failure.

SHA-256 checksums are recorded in `SHA256SUMS`.
