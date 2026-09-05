## Code Review

**Verdict:** REQUEST CHANGES  
**Confidence:** HIGH  
**P0 findings:** None

| Priority | Issue | Location |
|---|---|---|
| P1 | A repeated tap can report failure for the second request while the first request remains active and may successfully present. | `gridlord-godot/scripts/autoload/game_center.gd:95-103,130-137`; `scripts/ui/game_center_feedback.gd:24-33`; `godot-ios-gamecenter/src/game_center_kit.mm:145-148` |
| P2 | Leaderboard preflight treats matching metadata as displayable even when iOS reports that the leaderboard is hidden from Game Center views. | `godot-ios-gamecenter/src/game_center_kit.mm:309-317` |
| P2 | The tests bypass the actual asynchronous native gate/signal ordering, so they cannot detect the P1 behavior or deferred stale-result cases. | `godot-ios-gamecenter/tests/test_game_center_contract.cpp:29-40`; `gridlord-godot/scripts/dev/game_center_input_check.gd:57-81` |

### P1 — Overlapping requests corrupt the feedback state

GridLord emits `panel_requested` and calls native code for every tap. While the first metadata request is pending, the native gate rejects a second request with `panel_failed("…already pending")`. `GameCenterFeedback` cannot distinguish that rejection from failure of the original request.

Example:

1. First leaderboard tap starts metadata loading and shows “Opening Game Center…”.
2. Second tap reaches native code while the first request is pending.
3. Native emits `panel_failed` for the second request.
4. Feedback switches to “Game Center couldn’t open.”
5. The first request can still complete successfully and present the panel.

Because the native gate is shared across leaderboard and achievement requests, application-side serialization should also be shared.

**Suggested fix:** Track one pending panel in `GameCenter`:

- Set it before emitting `panel_requested` and invoking `_ios`.
- Suppress additional panel calls while it is set.
- Clear it only on the matching `panel_failed` or `panel_closed`.
- Ignore callbacks that do not match the pending panel.

Keeping the request pending until its result is forwarded also prevents an older deferred failure from overwriting the opening state of a newly accepted retry.

### P2 — Metadata existence does not always mean visible content

The leaderboard loader marks the request available solely when `baseLeaderboardID` matches. In the current iOS SDK, `GKLeaderboard.isHidden` explicitly denotes a leaderboard that is not visible in Game Center views. Such a leaderboard can pass this preflight and still produce a contentless panel.

When the property is available, hidden leaderboards should fail preflight. Older supported iOS versions, where visibility cannot be inspected this way, should remain a documented/device-test limitation.

### P2 — Tests miss the native/integration ordering

The C++ test validates `PanelRequestGate` independently. The GridLord test manually emits `panel_requested` and directly calls `_on_ios_panel_failed`/`_on_ios_panel_closed`; it never exercises:

- Two `show_*` calls while one request is pending.
- Native rejection of the second call.
- Deferred delivery of an older failure after a retry.
- Shared exclusion between leaderboard and achievements.

Add a fake native adapter or an app-level pending-state regression that verifies repeated calls do not reach native code and that retry becomes available only after failure/closure.

## Reviewed behavior and limitations

- The new preflight’s UIKit traversal, controller construction, and presentation are dispatched to the main queue. Metadata callbacks redispatch to the main queue before presentation.
- The ticket comparison correctly prevents a late GameKit metadata callback from releasing a newer request.
- Lifetime tokens protect callbacks after bridge destruction.
- I did not edit files, run device operations, or include the separate `macos-shutdown-crash` investigation.
- Reported compilation, contract, export, and smoke-test passes are **not device-success evidence**. Missing App Store Connect metadata is measured; successful leaderboard open/close/reopen and achievements UI after valid configuration remain unproven.