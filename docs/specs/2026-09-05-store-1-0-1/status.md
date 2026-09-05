# Store 1.0.1 release

## Contract and plan

The user confirmed on 2026-09-05 that the live test used GridLord's current
GameCenterKit addon (native source e2e4798), and authorized Store review submission.
Ship the exact provenance-verified addon files as 1.0.1, changing only plugin.cfg
version metadata. Do not replace the public 1.0.0 release or change runtime code.
Existing thumbnail is sufficient; gameplay screenshots are optional.

1. Validate every GridLord addon file against UPSTREAM.json; verify packaged native
   files remain byte-identical. Bump source version, validator and package assertion.
2. Run native contracts, Python tests and the release validator on the upload ZIP.
3. Upload 1.0.1 with changelog and current compatibility; submit the asset for review.
4. Verify Pending in the Store UI, record ZIP hash and integrate metadata into main.

Rollback: retain the old public 1.0.0 release. Store submission can return to Draft.

## Live status

- Research: Store currently contains original 1.0.0, not GridLord's tested binaries.
- User-reported live validation accepted; no additional device test claimed.
- Preparing metadata and exact-file package; upload and submission pending.

- PASS: all 12 GridLord input files matched UPSTREAM.json. Packaged files remain
  byte-identical except plugin.cfg version 1.0.0 -> 1.0.1.
- PASS: native contract tests, all 9 Python tests, and release validation of the
  exact upload ZIP (architectures, symbols, deployment targets, contents/license).
- Upload ZIP: 25,846,245 bytes; SHA-256
  `b27db4e3192d6fa07ec33b6af8d109d6ee4dab5a0b4b0895d23dd5f26e50b92f`.
- Store upload form prepared; submission pending.
