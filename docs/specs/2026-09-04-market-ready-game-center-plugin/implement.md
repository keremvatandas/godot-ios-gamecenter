# Implement: Market Ready Game Center Plugin

- `tasks.md` is the source of truth for execution order.
- Do not begin implementation until the maintainer approves this written spec and the
  detailed plan produced by the writing-plans workflow.
- Complete one milestone at a time.
- Do not expand scope without recording why in `status.md`.
- After each milestone:
  - run the listed validation commands
  - fix failures before moving on
  - update `status.md`
- Preserve the current public method/signal shapes; only the two approved panel signals
  are additive in Core 1.0.
- Keep Godot 4.5, iOS 14, and macOS 11 as the compatibility baselines unless the spec is
  explicitly revised.
- Treat device-only Game Center behavior as a manual release gate, not as evidence that
  CI validation may be skipped.
- Do not change repository visibility, push tags, publish releases, or submit Store
  content without a separate final approval.
- Keep diffs small and reviewable.
- Do not mark work complete unless acceptance criteria from `requirements.md` are satisfied.
