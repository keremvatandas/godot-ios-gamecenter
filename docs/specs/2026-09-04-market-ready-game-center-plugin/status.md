# Status: Market Ready Game Center Plugin

## Current status

- Written specification and detailed test-first implementation plan are approved/ready.
- Implementation is starting with repository hygiene and contract-test scaffolding.

## Decisions

- Product scope: focused Core 1.0, not full GameKit bindings.
- Compatibility: Godot 4.5-4.7 official single precision, iOS 14+, macOS 11+.
- Existing API remains stable; `panel_closed` and `panel_failed` are additive.
- Modern `GKLeaderboard` API is retained; no deprecated iOS 12/13 fallback.
- Current Godot Asset Store with direct version ZIP upload is the primary publication
  channel; no legacy Asset Library dist branch is planned.
- External publication actions require a separate final approval.

## Validation history

- 2026-09-04: repository, source, build, workflow, package, and binary baseline audited.
- 2026-09-04: latest CI run confirmed successful build with three iOS availability
  warnings that Core 1.0 must eliminate.
- 2026-09-04: CI artifact verified to contain all declared binaries and combined MIT
  notices; missing add-on README confirmed.
- 2026-09-04: CI macOS minimum observed as 14.0; local build minimum observed as 26.0;
  nondeterministic deployment target confirmed.
- 2026-09-04: Godot/Apple/Asset Store primary documentation and existing Store
  competition reviewed.
- 2026-09-04: independent Codex-Fugu read-only audit completed with `REQUEST CHANGES`.
- 2026-09-04: spec self-review completed for placeholders, contradictions, scope, and
  ambiguity.
- 2026-09-04: maintainer approved the written spec and requested implementation/testing,
  corrected `.gitignore` rules, English Conventional Commits, and no AI labels/trailers.
- 2026-09-04: detailed implementation plan written and self-reviewed at
  `docs/superpowers/plans/2026-09-04-gamecenterkit-core-1-0.md`.

## Blockers and open questions

- Gridlord name usage, repository visibility, public version/tag, release publication,
  and Store submission remain release-stage decisions.

## Next step

- Execute Task 1 from the implementation plan with a red/green test cycle.
