# GameCenterKit Release Checklist

## Current Store submission — 1.0.1 (2026-09-05)

- [x] Maintainer confirmed the live-app test used the current GridLord addon.
- [x] Verify all 12 input files against GridLord UPSTREAM.json at native source e2e4798.
- [x] Package the same files, changing only plugin.cfg version metadata to 1.0.1.
- [x] Pass native contracts, all 9 Python tests and the exact upload ZIP validator.
- [x] Upload stable 1.0.1 (25.85 MB), Godot 4.5 through 4.7.x.
- [x] Submit the asset and observe **Asset Status: Pending** in the Store UI.
- [ ] Receive moderator approval.

The existing thumbnail satisfies the mandatory media requirement. No additional
screenshot was needed. Detailed provenance: `docs/specs/2026-09-05-store-1-0-1/`.
The granular original device checklist below is historical; the current live-app
acceptance is user-reported and does not imply a fresh agent-run check of every item.

## Original 1.0.0 release record

## Repository and metadata

- [x] Omit the optional public Gridlord proof line from Store copy.
- [x] Make the GitHub repository public.
- [x] Set the GitHub description and topics.
- [x] Confirm the Store source and support URLs resolve publicly.
- [x] Review Store name, summary, description, tags, compatibility, and MIT license.
- [x] Include the required AI use disclosure in the Store field.

## Release candidate

- [x] Select the successful CI artifact from tested commit `2d2e8dd`.
- [x] Run native, Python, build, package, Godot 4.5/4.7, and iOS export/link gates.
- [x] Confirm `gamecenter-addon.zip` contains only the `addons/gamecenter/` root.
- [x] Record and independently verify the SHA-256 checksum.
- [x] Confirm `v1.0.0` matches `plugin.cfg` version `1.0.0`.
- [x] Publish `v1.0.0` at tested commit `2d2e8dd` via the GitHub release API.
- [x] Review and publish the GitHub release with the exact CI ZIP and SHA256SUMS.

## Physical-device sandbox test

The exact public release was installed in GridLord on 2026-09-05. Its isolated
quick verification suite, signed iOS archive/export, and device installation passed.
The initial device launch was blocked by the locked iPhone. Later direct-device
evidence and the maintainer acceptance above supersede that initial blocker;
the individual operations below were not rechecked during Store submission. See GridLord's `docs/specs/2026-09-05-gamecenter-release-device-test/status.md`.

- [x] Install the release-candidate ZIP into Gridlord or the example project.
- [x] Confirm the exported app contains the Game Center entitlement.
- [ ] Authenticate a sandbox Game Center account.
- [ ] Submit and observe a leaderboard score.
- [ ] Report and observe achievement progress.
- [ ] Open, dismiss, and reopen both native panels.
- [ ] Show and hide the Game Center access point.
- [ ] Exercise presentation while another modal has been shown and dismissed.
- [ ] Confirm failure signals contain useful errors and the app remains stable.

## Godot Asset Store

- [x] Upload the exact verified release ZIP.
- [x] Upload `marketing/media/gamecenterkit-store-thumbnail.jpg` (1280 x 720,
  194,740 bytes; converted from the original PNG for the Store's 600 KB limit).
- [x] Enter the reviewed Store fields and required disclosure.
- [x] Preview the listing and confirm thumbnail cropping and text readability.
- [x] Submit after maintainer publication approval and explicit Terms acceptance.
- [ ] Receive moderator approval; listing is currently **Pending**, not public.

Submitted on 2026-09-05:
https://store.godotengine.org/asset/keremvatandas/gamecenterkit/
Version `1.0.0`, stable, Godot `4.5` through `4.7.x`, MIT, free.
