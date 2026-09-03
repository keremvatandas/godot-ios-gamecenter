#pragma once

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace godot {

// iOS Game Center bridge. Every async call answers with a signal on the
// main thread; nothing blocks. Registered as the "GameCenterKit" Engine
// singleton so GDScript can gate on Engine.has_singleton("GameCenterKit")
// exactly like the other platform channels.
class GameCenterKit : public Object {
	GDCLASS(GameCenterKit, Object)

protected:
	static void _bind_methods();

public:
	void authenticate();
	bool is_authenticated() const;
	String player_display_name() const;
	void submit_score(const String &leaderboard_id, int64_t score);
	void show_leaderboard(const String &leaderboard_id);
	void report_achievement(const String &achievement_id, double percent);
	void show_achievements();
	void set_access_point_visible(bool visible);
};

} // namespace godot
