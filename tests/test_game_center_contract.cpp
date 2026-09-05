#include "game_center_contract.h"

#include <cassert>
#include <limits>

int main() {
    using gamecenter::CallbackLifetime;
    using gamecenter::is_valid_achievement_percent;
    using gamecenter::is_valid_identifier;

    assert(!is_valid_identifier(""));
    assert(!is_valid_identifier(" \t\n"));
    assert(is_valid_identifier("leaderboard.best_time"));
    assert(is_valid_identifier(" achievement.first_win "));

    assert(is_valid_achievement_percent(0.0));
    assert(is_valid_achievement_percent(100.0));
    assert(!is_valid_achievement_percent(-0.01));
    assert(!is_valid_achievement_percent(100.01));
    assert(!is_valid_achievement_percent(std::numeric_limits<double>::infinity()));
    assert(!is_valid_achievement_percent(std::numeric_limits<double>::quiet_NaN()));

    CallbackLifetime lifetime;
    const CallbackLifetime::Token token = lifetime.token();
    assert(CallbackLifetime::is_alive(token));
    lifetime.invalidate();
    assert(!CallbackLifetime::is_alive(token));

    gamecenter::PanelRequestGate gate;
    const auto first = gate.begin();
    assert(first != 0);
    assert(gate.begin() == 0); // leaderboard and achievements share the gate
    assert(gate.finish(first)); // success, error or timeout releases the request
    assert(!gate.finish(first)); // completion is delivered once
    const auto retry = gate.begin();
    assert(retry != 0 && retry != first);
    assert(!gate.finish(first)); // late callback cannot release a newer request
    assert(gate.begin() == 0);
    assert(gate.finish(retry));
    assert(gate.begin() != 0);
}
