#include "game_center_kit.h"

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#endif

using namespace godot;

#if TARGET_OS_IOS
static char gck_panel_delegate_key;

@interface GCKPanelDelegate : NSObject <GKGameCenterControllerDelegate> {
@private
	GameCenterKit *_owner;
	gamecenter::CallbackLifetime::Token _token;
	NSString *_panel;
}

- (instancetype)initWithOwner:(GameCenterKit *)owner
		token:(const gamecenter::CallbackLifetime::Token &)token
		panel:(NSString *)panel;
@end

@implementation GCKPanelDelegate
- (instancetype)initWithOwner:(GameCenterKit *)owner
		token:(const gamecenter::CallbackLifetime::Token &)token
		panel:(NSString *)panel {
	self = [super init];
	if (self != nil) {
		_owner = owner;
		_token = token;
		_panel = [panel copy];
	}
	return self;
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)controller {
	GameCenterKit *owner = _owner;
	const gamecenter::CallbackLifetime::Token token = _token;
	NSString *panel = _panel;
	[controller dismissViewControllerAnimated:YES completion:^{
		if (!gamecenter::CallbackLifetime::is_alive(token)) {
			return;
		}
		owner->call_deferred("emit_signal", "panel_closed", String([panel UTF8String]));
	}];
}
@end

static UIViewController *gck_top_controller(UIViewController *controller) {
	// Game Center is itself a navigation controller. Keep its identity for
	// the duplicate-panel guard, even when GameKit has not populated its stack.
	if ([controller isKindOfClass:[GKGameCenterViewController class]]) {
		return controller;
	}
	if (controller.presentedViewController && !controller.presentedViewController.isBeingDismissed) {
		return gck_top_controller(controller.presentedViewController);
	}
	if ([controller isKindOfClass:[UINavigationController class]]) {
		UIViewController *child = ((UINavigationController *)controller).visibleViewController;
		return child == nil ? controller : gck_top_controller(child);
	}
	if ([controller isKindOfClass:[UITabBarController class]]) {
		UIViewController *child = ((UITabBarController *)controller).selectedViewController;
		return child == nil ? controller : gck_top_controller(child);
	}
	return controller;
}

static UIWindow *gck_window_for_scene(UIWindowScene *scene) {
	UIWindow *fallback = nil;
	for (UIWindow *window in scene.windows) {
		if (window.isKeyWindow) {
			return window;
		}
		if (fallback == nil && !window.isHidden && window.alpha > 0.0 &&
				window.windowLevel == UIWindowLevelNormal) {
			fallback = window;
		}
	}
	return fallback;
}

static UIViewController *gck_presenting_controller() {
	UIWindowScene *fallback_scene = nil;
	for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
		if (![scene isKindOfClass:[UIWindowScene class]]) {
			continue;
		}
		UIWindowScene *window_scene = (UIWindowScene *)scene;
		if (gck_window_for_scene(window_scene) == nil) {
			continue;
		}
		if (scene.activationState == UISceneActivationStateForegroundActive) {
			return gck_top_controller(gck_window_for_scene(window_scene).rootViewController);
		}
		if (fallback_scene == nil && scene.activationState == UISceneActivationStateForegroundInactive) {
			fallback_scene = window_scene;
		}
	}

	UIWindow *window = fallback_scene == nil ? nil : gck_window_for_scene(fallback_scene);
	return window == nil ? nil : gck_top_controller(window.rootViewController);
}

static void gck_emit_panel_failed(GameCenterKit *owner, const char *panel, const char *error) {
	owner->call_deferred("emit_signal", "panel_failed", String(panel), String(error));
}

static void gck_present_panel(
		GameCenterKit *owner,
		const gamecenter::CallbackLifetime::Token &token,
		GKGameCenterViewController *controller,
		NSString *panel) {
	UIViewController *presenter = gck_presenting_controller();
	if (presenter == nil) {
		gck_emit_panel_failed(owner, [panel UTF8String], "no active window can present Game Center");
		return;
	}
	if ([presenter isKindOfClass:[GKGameCenterViewController class]]) {
		gck_emit_panel_failed(owner, [panel UTF8String], "a Game Center panel is already presented");
		return;
	}

	GCKPanelDelegate *delegate = [[GCKPanelDelegate alloc]
			initWithOwner:owner token:token panel:panel];
	controller.gameCenterDelegate = delegate;
	objc_setAssociatedObject(
			controller, &gck_panel_delegate_key, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[presenter presentViewController:controller animated:YES completion:nil];
}

// GameKit can return an empty metadata array without NSError for an identifier
// absent from App Store Connect. Presenting anyway can leave an invisible modal.
static void gck_load_and_present_panel(
		GameCenterKit *owner,
		gamecenter::CallbackLifetime::Token lifetime,
		std::shared_ptr<gamecenter::PanelRequestGate> requests,
		NSString *panel,
		void (^load_metadata)(void (^completion)(BOOL, NSError *)),
		GKGameCenterViewController *(^make_controller)(void)) {
	// Blocks capture C++ reference parameters as references. Own these values
	// before enqueueing so a temporary token cannot dangle after this returns.
	const auto ticket = requests->begin();
	if (ticket == 0) {
		gck_emit_panel_failed(owner, [panel UTF8String], "a Game Center panel request is already pending");
		return;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!gamecenter::CallbackLifetime::is_alive(lifetime)) {
			return;
		}
		if (![GKLocalPlayer localPlayer].isAuthenticated) {
			requests->finish(ticket);
			gck_emit_panel_failed(owner, [panel UTF8String], "Game Center player is not authenticated");
			return;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if (gamecenter::CallbackLifetime::is_alive(lifetime) && requests->finish(ticket)) {
				gck_emit_panel_failed(owner, [panel UTF8String], "Game Center metadata request timed out; try again");
			}
		});
		load_metadata(^(BOOL available, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!gamecenter::CallbackLifetime::is_alive(lifetime) || !requests->finish(ticket)) {
					return;
				}
				if (error != nil) {
					gck_emit_panel_failed(owner, [panel UTF8String], [error.localizedDescription UTF8String]);
					return;
				}
				if (!available) {
					gck_emit_panel_failed(owner, [panel UTF8String], "Game Center metadata is unavailable; check App Store Connect configuration");
					return;
				}
				if (![GKLocalPlayer localPlayer].isAuthenticated) {
					gck_emit_panel_failed(owner, [panel UTF8String], "Game Center player is not authenticated");
					return;
				}
				gck_present_panel(owner, lifetime, make_controller(), panel);
			});
		});
	});
}
#endif

static NSString *gck_to_ns(const String &s) {
	return [NSString stringWithUTF8String:s.utf8().get_data()];
}

static String gck_error_text(NSError *error) {
	if (error == nil) {
		return String();
	}
	return String([error.localizedDescription UTF8String]);
}

void GameCenterKit::_bind_methods() {
	ClassDB::bind_method(D_METHOD("authenticate"), &GameCenterKit::authenticate);
	ClassDB::bind_method(D_METHOD("is_authenticated"), &GameCenterKit::is_authenticated);
	ClassDB::bind_method(D_METHOD("player_display_name"), &GameCenterKit::player_display_name);
	ClassDB::bind_method(D_METHOD("submit_score", "leaderboard_id", "score"), &GameCenterKit::submit_score);
	ClassDB::bind_method(D_METHOD("show_leaderboard", "leaderboard_id"), &GameCenterKit::show_leaderboard);
	ClassDB::bind_method(D_METHOD("report_achievement", "achievement_id", "percent"), &GameCenterKit::report_achievement);
	ClassDB::bind_method(D_METHOD("show_achievements"), &GameCenterKit::show_achievements);
	ClassDB::bind_method(D_METHOD("set_access_point_visible", "visible"), &GameCenterKit::set_access_point_visible);
	ADD_SIGNAL(MethodInfo("authenticated",
			PropertyInfo(Variant::BOOL, "ok"), PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("score_submitted",
			PropertyInfo(Variant::BOOL, "ok"), PropertyInfo(Variant::STRING, "leaderboard_id"),
			PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("achievement_reported",
			PropertyInfo(Variant::BOOL, "ok"), PropertyInfo(Variant::STRING, "achievement_id"),
			PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("panel_closed", PropertyInfo(Variant::STRING, "panel")));
	ADD_SIGNAL(MethodInfo("panel_failed",
			PropertyInfo(Variant::STRING, "panel"), PropertyInfo(Variant::STRING, "error")));
}

GameCenterKit::~GameCenterKit() {
	callback_lifetime.invalidate();
	[GKLocalPlayer localPlayer].authenticateHandler = nil;
}

void GameCenterKit::authenticate() {
	GKLocalPlayer *player = [GKLocalPlayer localPlayer];
	GameCenterKit *self_ptr = this;
	const gamecenter::CallbackLifetime::Token token = callback_lifetime.token();
#if TARGET_OS_IOS
	player.authenticateHandler = ^(UIViewController *view_controller, NSError *error) {
		if (!gamecenter::CallbackLifetime::is_alive(token)) {
			return;
		}
		if (view_controller != nil) {
			UIViewController *presenter = gck_presenting_controller();
			if (presenter == nil) {
				self_ptr->call_deferred("emit_signal", "authenticated", false,
						"no active window can present Game Center authentication");
				return;
			}
			[presenter presentViewController:view_controller animated:YES completion:nil];
			return;
		}
		bool ok = [GKLocalPlayer localPlayer].isAuthenticated;
		self_ptr->call_deferred("emit_signal", "authenticated", ok, gck_error_text(error));
	};
#else
	player.authenticateHandler = ^(NSViewController *view_controller, NSError *error) {
		if (!gamecenter::CallbackLifetime::is_alive(token)) {
			return;
		}
		(void)view_controller;
		bool ok = [GKLocalPlayer localPlayer].isAuthenticated;
		self_ptr->call_deferred("emit_signal", "authenticated", ok, gck_error_text(error));
	};
#endif
}

bool GameCenterKit::is_authenticated() const {
	return [GKLocalPlayer localPlayer].isAuthenticated;
}

String GameCenterKit::player_display_name() const {
	if (!is_authenticated()) {
		return String();
	}
	return String([[GKLocalPlayer localPlayer].displayName UTF8String]);
}

void GameCenterKit::submit_score(const String &leaderboard_id, int64_t score) {
	const String normalized_id = leaderboard_id.strip_edges();
	const CharString utf8_id = normalized_id.utf8();
	if (!gamecenter::is_valid_identifier(utf8_id.get_data())) {
		call_deferred("emit_signal", "score_submitted", false, leaderboard_id,
				"leaderboard_id must not be empty");
		return;
	}

	GameCenterKit *self_ptr = this;
	const gamecenter::CallbackLifetime::Token token = callback_lifetime.token();
	const String board_copy = leaderboard_id;
	[GKLeaderboard submitScore:(NSInteger)score
			context:0
			player:[GKLocalPlayer localPlayer]
			leaderboardIDs:@[ gck_to_ns(normalized_id) ]
			completionHandler:^(NSError *error) {
		if (!gamecenter::CallbackLifetime::is_alive(token)) {
			return;
		}
		self_ptr->call_deferred("emit_signal", "score_submitted",
				error == nil, board_copy, gck_error_text(error));
	}];
}

void GameCenterKit::show_leaderboard(const String &leaderboard_id) {
	const String normalized_id = leaderboard_id.strip_edges();
	const CharString utf8_id = normalized_id.utf8();
	if (!gamecenter::is_valid_identifier(utf8_id.get_data())) {
		call_deferred("emit_signal", "panel_failed", "leaderboard",
				"leaderboard_id must not be empty");
		return;
	}

#if TARGET_OS_IOS
	NSString *identifier = gck_to_ns(normalized_id);
	gck_load_and_present_panel(this, callback_lifetime.token(), panel_requests, @"leaderboard",
			^(void (^completion)(BOOL, NSError *)) {
		[GKLeaderboard loadLeaderboardsWithIDs:@[identifier] completionHandler:^(NSArray<GKLeaderboard *> *boards, NSError *error) {
			BOOL found = NO;
			for (GKLeaderboard *board in boards) {
				if ([board.baseLeaderboardID isEqualToString:identifier]) {
					found = YES;
					if (@available(iOS 26.0, *)) {
						found = !board.isHidden;
					}
					break;
				}
			}
			completion(found, error);
		}];
	}, ^GKGameCenterViewController *{
		return [[GKGameCenterViewController alloc] initWithLeaderboardID:identifier
				playerScope:GKLeaderboardPlayerScopeGlobal timeScope:GKLeaderboardTimeScopeAllTime];
	});
#else
	call_deferred("emit_signal", "panel_failed", "leaderboard",
			"leaderboard panels are available only on iOS");
#endif
}

void GameCenterKit::report_achievement(const String &achievement_id, double percent) {
	const String normalized_id = achievement_id.strip_edges();
	const CharString utf8_id = normalized_id.utf8();
	if (!gamecenter::is_valid_identifier(utf8_id.get_data())) {
		call_deferred("emit_signal", "achievement_reported", false, achievement_id,
				"achievement_id must not be empty");
		return;
	}
	if (!gamecenter::is_valid_achievement_percent(percent)) {
		call_deferred("emit_signal", "achievement_reported", false, achievement_id,
				"percent must be finite and between 0 and 100");
		return;
	}

	GameCenterKit *self_ptr = this;
	const gamecenter::CallbackLifetime::Token token = callback_lifetime.token();
	const String id_copy = achievement_id;
	GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:gck_to_ns(normalized_id)];
	achievement.percentComplete = percent;
	achievement.showsCompletionBanner = YES;
	[GKAchievement reportAchievements:@[ achievement ] withCompletionHandler:^(NSError *error) {
		if (!gamecenter::CallbackLifetime::is_alive(token)) {
			return;
		}
		self_ptr->call_deferred("emit_signal", "achievement_reported",
				error == nil, id_copy, gck_error_text(error));
	}];
}

void GameCenterKit::show_achievements() {
#if TARGET_OS_IOS
	gck_load_and_present_panel(this, callback_lifetime.token(), panel_requests, @"achievements",
			^(void (^completion)(BOOL, NSError *)) {
		[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray<GKAchievementDescription *> *descriptions, NSError *error) {
			completion(descriptions.count > 0, error);
		}];
	}, ^GKGameCenterViewController *{
		return [[GKGameCenterViewController alloc] initWithState:GKGameCenterViewControllerStateAchievements];
	});
#else
	call_deferred("emit_signal", "panel_failed", "achievements",
			"achievement panels are available only on iOS");
#endif
}

void GameCenterKit::set_access_point_visible(bool visible) {
	if (@available(iOS 14.0, macOS 11.0, *)) {
		GKAccessPoint.shared.location = GKAccessPointLocationTopTrailing;
		GKAccessPoint.shared.active = visible;
	}
}
