# CI entitlement validation mini-spec

## Research

- Runs 33904577923 and 33907922738 fail after both Godot exports, without
  compiler diagnostics. The script checks entitlements before invoking Xcode.
- The check parses `plutil -p` and requires the display text `=> true`.
  Local `plutil -help` explicitly says this format is unstable and unsuitable
  for machine parsing. Older macOS output can represent boolean true as `1`.
- Run 33915527026 adds diagnostics and pins Xcode 26.2 but retains this check.
  Its completed log confirms failure at the debug entitlement check before link.
- Baseline: seven Python tests and native C++ contract tests pass locally.

## Requirements and design

- Accept the boolean true Game Center entitlement in both debug/release exports
  regardless of the human-readable plist output format.
- Reject missing, false, non-boolean, or malformed entitlement values before link.
- Use `plutil -extract` with `raw -expect bool`; escape dots in the literal key.
- Retain the existing Xcode version, runner, export and simulator link gates.
- No API, package, or release changes. Rollback is reverting this narrow check.

## Milestones and validation

1. Reproduce the valid-plist failure using legacy-style `plutil -p` output.
2. Replace display parsing with typed extraction; run behavioral regression tests
   including invalid values and both export configurations.
3. Run all Python/native tests, actionlint, shell syntax checks, and the real
   local iOS export/link smoke test. Inspect the remote run's new diagnostics.

## Live status

- Regression reproduced before the fix: valid XML and binary plists both failed
  with the legacy boolean display, reporting a missing Game Center entitlement.
- Typed extraction implemented. All nine Python tests pass, including rejection
  of missing/false/integer/string/malformed values in each export configuration.
- Native C++ contract tests, actionlint, shell syntax, and `git diff --check` pass.
- Real Godot 4.5.2 debug/release iOS exports and unsigned x86_64 simulator link
  pass locally on Xcode 26.6/macOS 26. Log: `/tmp/gamecenter-ci-entitlement-smoke.log`.
- 2026-09-05: confirmed failed hosted run 33915527026 used old commit 6102a8b,
  without this fix. All nine Python tests, C++ tests, actionlint, shell syntax,
  and diff checks passed again before committing the patch.
- Hosted run 33920836650 passed on corrected commit 2d2e8dd, including real
  iOS exports and simulator link. The workflow fix is verified on GitHub Actions.
