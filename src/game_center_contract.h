#pragma once

#include <atomic>
#include <cmath>
#include <cctype>
#include <cstdint>
#include <memory>
#include <string_view>

namespace gamecenter {

// A timeout and a metadata callback may race. Only the current ticket may
// complete; a callback arriving after retry must not release the new request.
class PanelRequestGate {
public:
    using Ticket = uint64_t;

    Ticket begin() {
        const Ticket ticket = next.fetch_add(1);
        Ticket idle = 0;
        return current.compare_exchange_strong(idle, ticket) ? ticket : 0;
    }

    bool finish(Ticket ticket) {
        return ticket != 0 && current.compare_exchange_strong(ticket, 0);
    }

private:
    std::atomic<Ticket> next{1};
    std::atomic<Ticket> current{0};
};

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
