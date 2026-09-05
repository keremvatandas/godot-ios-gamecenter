# GameCenterKit 1.0 Release Checklist

## Repository and metadata

- [x] Omit the optional public Gridlord proof line from Store copy.
- [x] Make the GitHub repository public.
- [x] Set the GitHub description and topics.
- [x] Confirm the Store source and support URLs resolve publicly.
- [x] Review Store name, summary, description, tags, compatibility, and MIT license.
- [ ] Include the required AI use disclosure in the Store field.

## Release candidate

- [x] Select the successful CI artifact from tested commit `2d2e8dd`.
- [x] Run native, Python, build, package, Godot 4.5/4.7, and iOS export/link gates.
- [x] Confirm `gamecenter-addon.zip` contains only the `addons/gamecenter/` root.
- [x] Record and independently verify the SHA-256 checksum.
- [x] Confirm `v1.0.0` matches `plugin.cfg` version `1.0.0`.
- [x] Publish `v1.0.0` at tested commit `2d2e8dd` via the GitHub release API.
- [x] Review and publish the GitHub release with the exact CI ZIP and SHA256SUMS.

## Physical-device sandbox test

Maintainer confirmed the device-test question on 2026-09-05. Individual steps below
remain a manual checklist; no per-step execution evidence was captured by CI.

- [ ] Install the release-candidate ZIP into Gridlord or the example project.
- [ ] Confirm the exported app contains the Game Center entitlement.
- [ ] Authenticate a sandbox Game Center account.
- [ ] Submit and observe a leaderboard score.
- [ ] Report and observe achievement progress.
- [ ] Open, dismiss, and reopen both native panels.
- [ ] Show and hide the Game Center access point.
- [ ] Exercise presentation while another modal has been shown and dismissed.
- [ ] Confirm failure signals contain useful errors and the app remains stable.

## Godot Asset Store

- [ ] Upload the exact verified release ZIP.
- [ ] Upload `marketing/media/gamecenterkit-store-thumbnail.png`.
- [ ] Enter the reviewed Store fields and required disclosure.
- [ ] Preview the listing and confirm thumbnail cropping and text readability.
- [ ] Submit only after final maintainer approval.
