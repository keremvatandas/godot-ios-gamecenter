# Game Center panel preflight

## Evidence
GridLord on iPhone 11, iOS 26.4.2, authenticates successfully. A real leaderboard
tap reaches GKGameCenterViewController construction and presentation on the main
thread through the correct active key window. Its navigation stack is empty and
the overlay is absent in iPhone Mirroring. Later direct-device user confirmation
shows that the leaderboard does open on the physical phone; the mirrored image
and empty navigation stack are not proof of failed native presentation. Read-only GameKit metadata calls return
zero leaderboards and achievement descriptions without NSError. App Store Connect
also contains no definitions. A main leaderboard draft was added for diagnosis;
no release submitted and no scores or achievements fabricated.

Code review also found that presenter traversal descends through
GKGameCenterViewController (a UINavigationController) before the existing duplicate
panel guard can recognize it. Empty navigation controllers return nil.

## Requirements and design
- Load the requested leaderboard / achievement descriptions before opening UI.
- Missing metadata, API error, unauthenticated player or 15-second timeout emits
  existing panel_failed(panel, error); it must not present an empty modal.
- Perform UIKit traversal, construction and presentation on the main queue.
- Permit only one metadata request at a time across both panel types. Completion
  or timeout releases its ticket; a late callback must not affect a later request.
- Existing panel detection retains the Game Center container, including when
  its navigation stack is empty. Ordinary empty containers remain valid fallback.
- Keep callback lifetime checks and the existing public method/signal surface.
- Preserve score submission, achievement reporting and player data.
- No speculative GKAccessPoint migration: the device experiment also showed no
  content, so it has not been proven to resolve this case.

## Milestones and validation
1. Regression for pending request completion/timeout/stale callbacks, then native
   preflight and presenter fix. Run tools/run_cpp_tests.sh and full Apple build.
2. Run Python package contracts and Godot runtime smoke. Add integration feedback
   in GridLord; validate missing metadata leaves game navigable.
3. Install signed candidate preserving save. Verify missing board error, valid
   leaderboard open/close/reopen and achievements behavior on device. Record
   configuration limitations accurately; only merge verified changes.

Rollback: revert source commit and restore prior addon provenance/binaries.
