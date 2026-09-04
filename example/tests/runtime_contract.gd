extends SceneTree

var failures: Array[String] = []
var score_answered := false
var achievement_answered := false
var panel_answered := false


func _initialize() -> void:
	if not Engine.has_singleton("GameCenterKit"):
		_finish(["GameCenterKit singleton is unavailable"])
		return

	var game_center := Engine.get_singleton("GameCenterKit")
	game_center.score_submitted.connect(func(ok: bool, board: String, _error: String) -> void:
		if ok or not board.strip_edges().is_empty():
			failures.append("empty leaderboard identifier was not rejected")
		score_answered = true)
	game_center.achievement_reported.connect(func(ok: bool, achievement: String, _error: String) -> void:
		if ok or achievement != "invalid.percent":
			failures.append("invalid achievement percentage was not rejected")
		achievement_answered = true)
	game_center.panel_failed.connect(func(panel: String, _error: String) -> void:
		if panel != "achievements":
			failures.append("unexpected panel failure name: %s" % panel)
		panel_answered = true)

	game_center.submit_score("   ", 1)
	game_center.report_achievement("invalid.percent", 101.0)
	if OS.get_name() == "macOS":
		game_center.show_achievements()
	await process_frame
	await process_frame

	if not score_answered:
		failures.append("score failure signal was not emitted")
	if not achievement_answered:
		failures.append("achievement failure signal was not emitted")
	if OS.get_name() == "macOS" and not panel_answered:
		failures.append("macOS panel failure signal was not emitted")
	_finish(failures)


func _finish(errors: Array[String]) -> void:
	for error in errors:
		push_error(error)
	quit(0 if errors.is_empty() else 1)
