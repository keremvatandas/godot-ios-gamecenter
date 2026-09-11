# GitHub 1.0.1 publication

## Scope

The maintainer authorized GitHub publication on 2026-09-11. Publish the existing
Store 1.0.1 ZIP without rebuilding or changing runtime code. Add the missing
changelog entry, attach the ZIP and SHA256SUMS, mark v1.0.1 as latest, and verify
the downloaded public assets. Preserve v1.0.0 and unrelated working-tree files.

## Evidence

- Package: `dist/release-1.0.1/gamecenter-addon.zip` (25,846,245 bytes).
- SHA-256: `b27db4e3192d6fa07ec33b6af8d109d6ee4dab5a0b4b0895d23dd5f26e50b92f`.
- File provenance: `docs/specs/2026-09-05-store-1-0-1/provenance.json`.
- Historical CI run 33979592991 at `b66f549` is confirmed successful through
  GitHub's API: Apple build, ASan callback check, native/Python tests, Godot
  compatibility smoke tests, and iOS export/simulator link. Runtime, tools,
  tests, example and CI configuration have not changed since that commit.
- Physical-device acceptance is the maintainer's previously recorded live-app
  test, not a new device test performed during this publication.

## Live status

- PASS (2026-09-11): native contract tests and all 9 Python tests.
- PASS (2026-09-11): exact release ZIP validation (version, architectures, entry
  symbols and deployment targets); all 12 packaged files and SHA256SUMS match
  the recorded Store provenance.
- SKIP: a new native build and physical-device suite; this release distributes
  the unchanged, previously accepted Store package. Historical CI is supporting
  evidence, not a fresh test run or proof of CI/device-binary byte identity.
- PASS: published stable v1.0.1 as Latest at 2026-09-11T15:25:12Z:
  https://github.com/keremvatandas/godot-ios-gamecenter/releases/tag/v1.0.1
- PASS: public tag resolves to release documentation commit
  `65274996c3cb8a432947faed155713df94d2e5fe`, verified on remote main.
- PASS: anonymous GitHub API and asset downloads confirm latest/non-draft status,
  the 25,846,245-byte ZIP, and the exact expected SHA-256/SHA256SUMS contents.
- Release was created through GitHub's release API using the existing verified
  package; no new tag-push build was triggered. v1.0.0 remains published.
- No task branch/worktree was created. The existing untracked
  `docs/specs/2026-09-05-macos-shutdown-crash/` directory remains untouched.
