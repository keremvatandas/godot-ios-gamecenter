// Include the production helper so this exercises its actual Objective-C block
// captures. No Godot engine, authentication, player data or GameKit requests run.
#include "../src/game_center_kit.mm"
#include <cassert>

__attribute__((noinline)) static void enqueue_then_destroy_owner() {
	gamecenter::CallbackLifetime lifetime;
	auto requests = std::make_shared<gamecenter::PanelRequestGate>();
	gck_load_and_present_panel(nullptr, lifetime.token(), requests, @"leaderboard",
			^(void (^completion)(BOOL, NSError *)) {
		(void)completion;
		abort(); // An expired owner must never start a GameKit request.
	}, ^GKGameCenterViewController *{
		abort();
		return nil;
	});
	lifetime.invalidate();
}

int main() {
	@autoreleasepool {
		enqueue_then_destroy_owner();
		__block BOOL drained = NO;
		dispatch_async(dispatch_get_main_queue(), ^{ drained = YES; });
		NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:2.0];
		while (!drained && [deadline timeIntervalSinceNow] > 0) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
		}
		assert(drained);
		puts("panel callback lifetime: expired owner safely ignored");
	}
}
