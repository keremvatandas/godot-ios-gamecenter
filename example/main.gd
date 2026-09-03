extends VBoxContainer

## Minimal GameCenterKit tour: authenticate, submit, open the panels.
## The addon lives in this project's addons/ and its binaries come from
## tools/build_xcframework.sh; run that once, then export for iOS.

var _log: Label
var _gc: Object


func _ready() -> void:
	_log = Label.new()
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not Engine.has_singleton("GameCenterKit"):
		_log.text = "GameCenterKit yok — iOS/macOS build gerekir."
		add_child(_log)
		return
	_gc = Engine.get_singleton("GameCenterKit")
	_gc.authenticated.connect(func(ok: bool, error: String) -> void:
		_say("authenticated ok=%s err=%s name=%s" % [ok, error, _gc.player_display_name()]))
	_gc.score_submitted.connect(func(ok: bool, board: String, error: String) -> void:
		_say("score_submitted ok=%s board=%s err=%s" % [ok, board, error]))
	_gc.achievement_reported.connect(func(ok: bool, id: String, error: String) -> void:
		_say("achievement ok=%s id=%s err=%s" % [ok, id, error]))
	_button("Authenticate", func() -> void: _gc.authenticate())
	_button("Submit 1234 to example.board", func() -> void: _gc.submit_score("example.board", 1234))
	_button("Report example.achievement 100%", func() -> void: _gc.report_achievement("example.achievement", 100.0))
	_button("Show leaderboard", func() -> void: _gc.show_leaderboard("example.board"))
	_button("Show achievements", func() -> void: _gc.show_achievements())
	_button("Toggle access point", func() -> void:
		_gc.set_access_point_visible(not _access_point_on)
		_access_point_on = not _access_point_on)
	add_child(_log)


var _access_point_on: bool = false


func _button(text: String, on_press: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(on_press)
	add_child(b)


func _say(line: String) -> void:
	print(line)
	_log.text = line
