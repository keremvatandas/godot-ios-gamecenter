#pragma once

#include <atomic>
#include <cmath>
#include <cctype>
#include <memory>
#include <string_view>

namespace gamecenter {

inline bool is_valid_identifier(std::string_view value) {
    for (const unsigned char character : value) {
        if (!std::isspace(character)) {
            return true;
        }
    }
    return false;
}

inline bool is_valid_achievement_percent(double percent) {
    return std::isfinite(percent) && percent >= 0.0 && percent <= 100.0;
}

class CallbackLifetime {
public:
    using State = std::shared_ptr<std::atomic_bool>;
    using Token = std::weak_ptr<std::atomic_bool>;

    CallbackLifetime() : state(std::make_shared<std::atomic_bool>(true)) {}

    Token token() const { return state; }

    void invalidate() { state->store(false, std::memory_order_release); }

    static bool is_alive(const Token &token) {
        const State current = token.lock();
        return current && current->load(std::memory_order_acquire);
    }

private:
    State state;
};

} // namespace gamecenter
