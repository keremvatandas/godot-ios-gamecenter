# GameCenterKit 1.0 Release Checklist

## Repository and metadata

- [ ] Approve or remove the optional public Gridlord proof line.
- [ ] Make the GitHub repository public.
- [ ] Set the GitHub description and topics.
- [ ] Confirm the Store source and support URLs resolve publicly.
- [ ] Review Store name, summary, description, tags, compatibility, and MIT license.
- [ ] Include the required AI use disclosure in the Store field.

## Release candidate

- [ ] Pull the approved release branch and initialize submodules.
- [ ] Run native, Python, build, package, Godot 4.5/4.7, and iOS export/link gates.
- [ ] Confirm `gamecenter-addon.zip` contains only the `addons/gamecenter/` root.
- [ ] Record and independently verify the SHA-256 checksum.
- [ ] Confirm `v1.0.0` matches `plugin.cfg` version `1.0.0`.
- [ ] Push the approved commits and signed or annotated `v1.0.0` tag.
- [ ] Review the automatically created draft GitHub release and attached ZIP.

## Physical-device sandbox test

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
