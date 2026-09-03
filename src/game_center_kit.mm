#include "game_center_kit.h"

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

using namespace godot;

#if TARGET_OS_IOS
// Dismisses whichever Game Center panel is up. GameKit hands the delegate
// the controller, so one shared dismisser serves every presentation.
@interface GCKDismisser : NSObject <GKGameCenterControllerDelegate>
+ (instancetype)shared;
@end

@implementation GCKDismisser
+ (instancetype)shared {
	static GCKDismisser *instance = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{ instance = [GCKDismisser new]; });
	return instance;
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)controller {
	[controller dismissViewControllerAnimated:YES completion:nil];
}
@end

static UIViewController *gck_root_controller() {
	return [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
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
}

void GameCenterKit::authenticate() {
	GKLocalPlayer *player = [GKLocalPlayer localPlayer];
	GameCenterKit *self_ptr = this;
#if TARGET_OS_IOS
	player.authenticateHandler = ^(UIViewController *view_controller, NSError *error) {
		if (view_controller != nil) {
			// GameKit wants its sign-in sheet shown; the handler fires again
			// with the outcome once the sheet is done.
			[gck_root_controller() presentViewController:view_controller animated:YES completion:nil];
			return;
		}
		bool ok = [GKLocalPlayer localPlayer].isAuthenticated;
		self_ptr->call_deferred("emit_signal", "authenticated", ok, gck_error_text(error));
	};
#else
	player.authenticateHandler = ^(NSViewController *view_controller, NSError *error) {
		// macOS builds exist for editor-side development; the sign-in UI is
		// not presented here, so an unauthenticated editor answers false.
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
	GameCenterKit *self_ptr = this;
	String board_copy = leaderboard_id;
	[GKLeaderboard submitScore:(NSInteger)score
			context:0
			player:[GKLocalPlayer localPlayer]
			leaderboardIDs:@[ gck_to_ns(leaderboard_id) ]
			completionHandler:^(NSError *error) {
		self_ptr->call_deferred("emit_signal", "score_submitted",
				error == nil, board_copy, gck_error_text(error));
	}];
}

void GameCenterKit::show_leaderboard(const String &leaderboard_id) {
#if TARGET_OS_IOS
	GKGameCenterViewController *vc;
	if (@available(iOS 14.0, *)) {
		vc = [[GKGameCenterViewController alloc]
				initWithLeaderboardID:gck_to_ns(leaderboard_id)
				playerScope:GKLeaderboardPlayerScopeGlobal
				timeScope:GKLeaderboardTimeScopeAllTime];
	} else {
		vc = [[GKGameCenterViewController alloc] init];
	}
	vc.gameCenterDelegate = [GCKDismisser shared];
	[gck_root_controller() presentViewController:vc animated:YES completion:nil];
#else
	(void)leaderboard_id;
	NSLog(@"GameCenterKit: show_leaderboard is iOS-only; macOS build is for editor development.");
#endif
}

void GameCenterKit::report_achievement(const String &achievement_id, double percent) {
	GameCenterKit *self_ptr = this;
	String id_copy = achievement_id;
	GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:gck_to_ns(achievement_id)];
	achievement.percentComplete = percent;
	achievement.showsCompletionBanner = YES;
	[GKAchievement reportAchievements:@[ achievement ] withCompletionHandler:^(NSError *error) {
		self_ptr->call_deferred("emit_signal", "achievement_reported",
				error == nil, id_copy, gck_error_text(error));
	}];
}

void GameCenterKit::show_achievements() {
#if TARGET_OS_IOS
	GKGameCenterViewController *vc;
	if (@available(iOS 14.0, *)) {
		vc = [[GKGameCenterViewController alloc] initWithState:GKGameCenterViewControllerStateAchievements];
	} else {
		vc = [[GKGameCenterViewController alloc] init];
	}
	vc.gameCenterDelegate = [GCKDismisser shared];
	[gck_root_controller() presentViewController:vc animated:YES completion:nil];
#else
	NSLog(@"GameCenterKit: show_achievements is iOS-only; macOS build is for editor development.");
#endif
}

void GameCenterKit::set_access_point_visible(bool visible) {
	if (@available(iOS 14.0, macOS 11.0, *)) {
		GKAccessPoint.shared.location = GKAccessPointLocationTopTrailing;
		GKAccessPoint.shared.active = visible;
	}
}
