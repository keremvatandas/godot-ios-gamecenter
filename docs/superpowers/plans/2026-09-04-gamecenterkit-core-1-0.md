# GameCenterKit Core 1.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a hardened, reproducible, tested, and Godot Asset Store-ready GameCenterKit Core 1.0 add-on.

**Architecture:** Preserve the existing `GameCenterKit` Engine singleton and signal-first API, but move reusable request/lifetime rules into a dependency-free C++ contract helper and replace application-global UIKit presentation with an active-scene presenter. A deterministic Apple build feeds one package script; contract tests, Godot smoke checks, and CI validate the exact ZIP that will later be released.

**Tech Stack:** Godot 4.5 godot-cpp GDExtension, C++17, Objective-C++/GameKit/UIKit/AppKit, GDScript editor/export plug-ins, SCons, Bash, Python 3 `unittest`, GitHub Actions, Xcode command-line tools.

**Spec:** `docs/specs/2026-09-04-market-ready-game-center-plugin/design.md`

## Global Constraints

- Support official single-precision Godot 4.5 through 4.7; build the GDExtension against pinned godot-cpp 4.5.
- Set minimum deployment versions to iOS 14.0 and macOS 11.0.
- Preserve every existing public method and signal signature.
- Add only `panel_closed(panel: String)` and `panel_failed(panel: String, error: String)` to Core 1.0.
- Keep Game Center entitlement generation in Godot's `entitlements/game_center` export option.
- Do not add iOS 12/13 `GKScore` fallback code.
- Use English Conventional Commit messages with no AI label, AI co-author, or generated-by trailer.
- Keep required AI-use disclosure only in Store submission copy; do not add AI repository topics or release labels.
- Do not change repository visibility, push a tag, publish a release, or submit to the Store without a final explicit maintainer approval.
- Update `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md` after every task.

---

## File Responsibility Map

- `.gitignore`: ignore only generated build/test/export/package files; retain Godot source metadata such as `.uid` files.
- `src/game_center_contract.h`: dependency-free identifier, percentage, and callback-lifetime rules.
- `src/game_center_kit.h`: stable Godot API plus approved signals and lifecycle state.
- `src/game_center_kit.mm`: GameKit calls, error formatting, active-scene presentation, delegates, and signal delivery.
- `src/register_types.cpp`: singleton registration/unregistration only.
- `SConstruct`: compiler/linker policy and add-on artifact destinations.
- `tools/run_cpp_tests.sh`: compile/run dependency-free native contract tests in a temporary directory.
- `tools/build_xcframework.sh`: deterministic Apple artifact build.
- `tools/package_addon.sh`: stage and zip the installable add-on.
- `tools/validate_release.py`: manifest-driven binary/package/version validation.
- `tools/download_godot_macos.sh`: fetch pinned official Godot smoke-test binaries.
- `tools/run_godot_smoke.sh`: run runtime contract checks against a supplied Godot executable.
- `tests/test_game_center_contract.cpp`: native contract unit tests.
- `tests/test_repository_contract.py`: repository/build/package policy tests.
- `example/tests/runtime_contract.gd`: black-box singleton/signal/input contract smoke test.
- `example/addons/gamecenter/*`: exact installed add-on source tree before binary staging.
- `example/main.gd`: interactive Core 1.0 example.
- `.github/workflows/build.yml`: clean CI build, validation, smoke, artifact, and draft release.
- `README.md`, `CHANGELOG.md`: public documentation and release history.
- `marketing/store-listing.md`, `marketing/release-checklist.md`, `marketing/media/*`: Store upload copy and media.

---

### Task 1: Repository hygiene and executable contract-test harness

**Files:**

- Modify: `.gitignore`
- Create: `tests/test_repository_contract.py`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: current ignored build roots `bin/`, `build/`, `dist/`, SCons outputs, and `example/.godot/`.
- Produces: `python3 -m unittest tests.test_repository_contract` as the repository-policy test entry point.

- [ ] **Step 1: Write the failing repository hygiene test**

Create `tests/test_repository_contract.py` with an initial `.gitignore` contract:

```python
from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_generated_outputs_are_ignored(self) -> None:
        rules = (ROOT / ".gitignore").read_text(encoding="utf-8").splitlines()
        expected = {
            "bin/",
            "build/",
            "dist/",
            ".godot/",
            "example/.godot/",
            ".sconsign*.dblite",
            "compile_commands.json",
            "*.o",
            "*.os",
            "*.dSYM/",
            "*.xcarchive/",
            "*.xcresult/",
            "*.zip",
            ".DS_Store",
        }
        self.assertTrue(expected.issubset(set(rules)))

    def test_godot_uid_files_are_not_ignored(self) -> None:
        result = subprocess.run(
            ["git", "check-ignore", "--quiet", "example/main.gd.uid"],
            cwd=ROOT,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
python3 -m unittest tests.test_repository_contract -v
```

Expected: `test_generated_outputs_are_ignored` fails because the current file lacks several exact rules.

- [ ] **Step 3: Replace `.gitignore` with explicit generated-output rules**

Use this ordered content:

```gitignore
# Native build products
bin/
build/
dist/
.sconsign*.dblite
compile_commands.json
*.o
*.os
*.dSYM/
*.xcarchive/
*.xcresult/

# Packaged releases
*.zip

# Godot import/editor state
.godot/
example/.godot/

# macOS metadata
.DS_Store
```

Do not ignore `*.uid`, `export_presets.cfg`, documentation, or marketing media.

- [ ] **Step 4: Run hygiene checks**

Run:

```bash
python3 -m unittest tests.test_repository_contract -v
git check-ignore -v build/output.a dist/gamecenter-addon.zip example/.godot/editor/project_metadata.cfg
git check-ignore example/main.gd.uid
git diff --check
```

Expected: unit tests pass; generated paths show matching rules; `example/main.gd.uid` is not ignored and causes the third command to exit nonzero.

- [ ] **Step 5: Update status and commit**

Record the commands and results in `status.md`, then:

```bash
git add .gitignore tests/test_repository_contract.py docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "test: define repository hygiene contract"
```

---

### Task 2: Test-first request validation and callback lifetime

**Files:**

- Create: `src/game_center_contract.h`
- Create: `tests/test_game_center_contract.cpp`
- Create: `tools/run_cpp_tests.sh`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: UTF-8 App Store Connect identifiers and achievement percentages from `GameCenterKit`.
- Produces:
  - `gamecenter::is_valid_identifier(std::string_view) -> bool`
  - `gamecenter::is_valid_achievement_percent(double) -> bool`
  - `gamecenter::CallbackLifetime::token() -> std::weak_ptr<std::atomic_bool>`
  - `gamecenter::CallbackLifetime::is_alive(const Token &) -> bool`
  - `gamecenter::CallbackLifetime::invalidate() -> void`

- [ ] **Step 1: Write the failing C++ contract test**

Create `tests/test_game_center_contract.cpp`:

```cpp
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
}
```

Create `tools/run_cpp_tests.sh` so the binary never lands in the repository:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/gamecenter-contract.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT

${CXX:-clang++} -std=c++17 -Wall -Wextra -Werror \
  -Isrc tests/test_game_center_contract.cpp \
  -o "$test_dir/game_center_contract_test"
"$test_dir/game_center_contract_test"
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
chmod +x tools/run_cpp_tests.sh
tools/run_cpp_tests.sh
```

Expected: compile failure because `game_center_contract.h` does not exist.

- [ ] **Step 3: Implement the dependency-free contract helper**

Create `src/game_center_contract.h` as a header-only helper:

```cpp
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
```

- [ ] **Step 4: Run the native contract test**

Run:

```bash
tools/run_cpp_tests.sh
python3 -m unittest tests.test_repository_contract -v
git diff --check
```

Expected: all checks pass and no test binary is left in the worktree.

- [ ] **Step 5: Update status and commit**

```bash
git add src/game_center_contract.h tests/test_game_center_contract.cpp tools/run_cpp_tests.sh docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "test: add Game Center contract coverage"
```

---

### Task 3: Harden the native GameKit bridge

**Files:**

- Modify: `src/game_center_kit.h`
- Modify: `src/game_center_kit.mm`
- Create: `tests/test_native_surface.py`
- Modify: `example/main.gd`
- Create: `example/tests/runtime_contract.gd`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: Task 2's validation functions and callback token.
- Produces: existing singleton methods/signals plus `panel_closed(String)` and `panel_failed(String, String)`.

- [ ] **Step 1: Write failing native-surface tests**

Create `tests/test_native_surface.py`:

```python
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
IMPLEMENTATION = ROOT / "src" / "game_center_kit.mm"


class NativeSurfaceTests(unittest.TestCase):
    def test_additive_panel_signals_are_bound(self) -> None:
        source = IMPLEMENTATION.read_text(encoding="utf-8")
        self.assertIn('ADD_SIGNAL(MethodInfo("panel_closed"', source)
        self.assertIn('ADD_SIGNAL(MethodInfo("panel_failed"', source)

    def test_deprecated_application_windows_api_is_absent(self) -> None:
        source = IMPLEMENTATION.read_text(encoding="utf-8")
        self.assertNotIn("[UIApplication sharedApplication] windows", source)
        self.assertIn("connectedScenes", source)

    def test_request_contract_is_used(self) -> None:
        source = IMPLEMENTATION.read_text(encoding="utf-8")
        self.assertIn("is_valid_identifier", source)
        self.assertIn("is_valid_achievement_percent", source)
        self.assertIn("CallbackLifetime::is_alive", source)


if __name__ == "__main__":
    unittest.main()
```

Create `example/tests/runtime_contract.gd` with black-box checks that do not require a Game Center account:

```gdscript
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
```

- [ ] **Step 2: Run tests to verify the red state**

Run:

```bash
python3 -m unittest tests.test_native_surface -v
```

Expected: all three tests fail against the current bridge.

- [ ] **Step 3: Add lifecycle state and approved signals to the header/bindings**

In `src/game_center_kit.h`, include the helper, own a `CallbackLifetime`, add a destructor,
and keep every current signature:

```cpp
#include "game_center_contract.h"

class GameCenterKit : public Object {
    GDCLASS(GameCenterKit, Object)

    gamecenter::CallbackLifetime callback_lifetime;

protected:
    static void _bind_methods();

public:
    ~GameCenterKit();
    // Existing methods remain unchanged.
};
```

Bind the two signals in `_bind_methods()`:

```cpp
ADD_SIGNAL(MethodInfo("panel_closed", PropertyInfo(Variant::STRING, "panel")));
ADD_SIGNAL(MethodInfo("panel_failed",
        PropertyInfo(Variant::STRING, "panel"),
        PropertyInfo(Variant::STRING, "error")));
```

- [ ] **Step 4: Replace UIKit presentation with active-scene resolution**

In `src/game_center_kit.mm`:

- import `<objc/runtime.h>` on iOS;
- select a foreground-active `UIWindowScene` from `UIApplication.sharedApplication.connectedScenes`;
- choose its key window or first visible normal-level window;
- walk presented, navigation, and tab controllers;
- reject missing presenters and an already-presented `GKGameCenterViewController` through `panel_failed`;
- retain one delegate per Game Center controller with `objc_setAssociatedObject`;
- emit `panel_closed` from the delegate after dismissal.

The top-controller helper must have this shape:

```objective-c++
static UIViewController *gck_top_controller(UIViewController *controller) {
    if (controller.presentedViewController && !controller.presentedViewController.isBeingDismissed) {
        return gck_top_controller(controller.presentedViewController);
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return gck_top_controller(((UINavigationController *)controller).visibleViewController);
    }
    if ([controller isKindOfClass:[UITabBarController class]]) {
        return gck_top_controller(((UITabBarController *)controller).selectedViewController);
    }
    return controller;
}
```

The scene loop must prefer `UISceneActivationStateForegroundActive`, then a visible
fallback scene; it must never call deprecated `UIApplication.windows` or `keyWindow`.

- [ ] **Step 5: Integrate validation and callback lifetime**

Before a GameKit call, convert the stripped identifier to UTF-8 and use Task 2's helper.
For invalid input, emit existing failure signals with deterministic English messages:

```cpp
const String normalized_id = leaderboard_id.strip_edges();
const CharString utf8_id = normalized_id.utf8();
if (!gamecenter::is_valid_identifier(utf8_id.get_data())) {
    call_deferred("emit_signal", "score_submitted", false, leaderboard_id,
            "leaderboard_id must not be empty");
    return;
}
```

Every native block captures both `GameCenterKit *self_ptr` and
`gamecenter::CallbackLifetime::Token token`. The first block statement must be:

```cpp
if (!gamecenter::CallbackLifetime::is_alive(token)) {
    return;
}
```

The destructor invalidates first and clears the authentication handler:

```objective-c++
GameCenterKit::~GameCenterKit() {
    callback_lifetime.invalidate();
    [GKLocalPlayer localPlayer].authenticateHandler = nil;
}
```

- [ ] **Step 6: Update the example for panel results**

Connect and display both additive signals in `example/main.gd`:

```gdscript
_gc.panel_closed.connect(func(panel: String) -> void:
    _say("panel_closed panel=%s" % panel))
_gc.panel_failed.connect(func(panel: String, error: String) -> void:
    _say("panel_failed panel=%s err=%s" % [panel, error]))
```

- [ ] **Step 7: Run focused and compile validation**

Run:

```bash
tools/run_cpp_tests.sh
python3 -m unittest tests.test_native_surface tests.test_repository_contract -v
scons platform=macos target=template_debug macos_deployment_target=11.0 -j8
scons platform=ios target=template_release arch=arm64 ios_min_version=14.0 -j8
git diff --check
```

Expected: tests pass and both Apple targets compile without unguarded availability warnings.

- [ ] **Step 8: Update status and commit**

```bash
git add src/game_center_kit.h src/game_center_kit.mm tests/test_native_surface.py example/main.gd example/tests/runtime_contract.gd docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "feat: harden Game Center runtime lifecycle"
```

---

### Task 4: Deterministic build and Store-ready package

**Files:**

- Modify: `SConstruct`
- Modify: `tools/build_xcframework.sh`
- Create: `tools/package_addon.sh`
- Create: `tools/validate_release.py`
- Modify: `tests/test_repository_contract.py`
- Create: `example/addons/gamecenter/README.md`
- Modify: `example/addons/gamecenter/plugin.cfg`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: Task 3 bridge; version `1.0.0`; build outputs under `example/addons/gamecenter/bin`.
- Produces: `dist/gamecenter-addon.zip` rooted at `addons/gamecenter/` and validated by `python3 tools/validate_release.py`.

- [ ] **Step 1: Extend failing repository/package tests**

Add these checks to `tests/test_repository_contract.py`:

```python
    def test_build_script_pins_apple_minimums(self) -> None:
        script = (ROOT / "tools" / "build_xcframework.sh").read_text(encoding="utf-8")
        self.assertIn("ios_min_version=14.0", script)
        self.assertIn("macos_deployment_target=11.0", script)

    def test_addon_contains_self_contained_readme(self) -> None:
        readme = ROOT / "example" / "addons" / "gamecenter" / "README.md"
        self.assertTrue(readme.is_file())
        self.assertIn("GameCenterKit", readme.read_text(encoding="utf-8"))

    def test_plugin_version_is_core_1_0(self) -> None:
        config = (ROOT / "example" / "addons" / "gamecenter" / "plugin.cfg").read_text(encoding="utf-8")
        self.assertIn('version="1.0.0"', config)
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
python3 -m unittest tests.test_repository_contract -v
```

Expected: the new minimum-version, add-on README, and version tests fail.

- [ ] **Step 3: Make Apple builds deterministic and warnings strict**

In `SConstruct`, append the availability warning policy only for Apple platforms:

```python
if env["platform"] in ("ios", "macos"):
    env.Append(LINKFLAGS=["-framework", "GameKit", "-framework", "Foundation"])
    env.Append(CCFLAGS=["-fobjc-arc", "-Werror=unguarded-availability-new"])
```

In `tools/build_xcframework.sh`, define and pass:

```bash
IOS_MIN_VERSION=14.0
MACOS_MIN_VERSION=11.0
scons platform=ios target=template_release arch=arm64 ios_min_version="$IOS_MIN_VERSION" -j8
scons platform=ios target=template_release ios_simulator=yes arch=universal ios_min_version="$IOS_MIN_VERSION" -j8
scons platform=macos target=template_debug macos_deployment_target="$MACOS_MIN_VERSION" -j8
scons platform=macos target=template_release macos_deployment_target="$MACOS_MIN_VERSION" -j8
```

- [ ] **Step 4: Add the self-contained add-on README and version**

Write `example/addons/gamecenter/README.md` with:

- compatibility matrix: Godot 4.5-4.7, iOS 14+, macOS 11+;
- installation and editor plug-in enablement;
- `entitlements/game_center=true` instructions;
- exact API/signal table, including panel signals;
- main-thread asynchronous contract;
- App Store Connect configuration requirements;
- limitations and troubleshooting;
- GameCenterKit and bundled godot-cpp MIT notices.

Set `plugin.cfg` to `version="1.0.0"`.

- [ ] **Step 5: Implement one package command**

Create `tools/package_addon.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
stage_dir="build/package-stage"
addon_dir="$stage_dir/addons/gamecenter"
archive="dist/gamecenter-addon.zip"

rm -rf "$stage_dir"
mkdir -p "$addon_dir" dist
cp -R example/addons/gamecenter/. "$addon_dir/"
cp LICENSE "$addon_dir/LICENSE"
printf '\n----------------------------------------\n\nThe bundled binaries statically link godot-cpp:\n\n' >> "$addon_dir/LICENSE"
cat godot-cpp/LICENSE.md >> "$addon_dir/LICENSE"
rm -f "$archive"
(cd "$stage_dir" && zip -qry "../../$archive" addons)
python3 tools/validate_release.py "$archive"
printf '%s\n' "$archive"
```

The explicit `build/package-stage` and `dist/gamecenter-addon.zip` targets are safe,
ignored, and never derived from an untrusted input.

- [ ] **Step 6: Implement manifest-driven release validation**

Create `tools/validate_release.py` using only the Python standard library. It must:

- accept exactly one ZIP path;
- reject absolute or `..` archive paths;
- require all entries under `addons/gamecenter/`;
- read `gamecenter.gdextension` and extract every quoted `res://addons/gamecenter/...`
  library path;
- verify each declared file/directory exists in the ZIP;
- require `README.md`, `LICENSE`, `plugin.cfg`, and `plugin.gd`;
- parse `plugin.cfg` and require semantic version `1.0.0`;
- extract binaries into a `tempfile.TemporaryDirectory`;
- run `file`, `plutil`, `nm`, and `vtool` to assert architectures, entry symbol, iOS 14,
  and macOS 11;
- print one concise success summary and exit nonzero on any mismatch.

The validator entry point must be:

```python
if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: validate_release.py <gamecenter-addon.zip>")
    validate(Path(sys.argv[1]).resolve())
```

- [ ] **Step 7: Build, package, and verify the green state**

Run:

```bash
tools/build_xcframework.sh
chmod +x tools/package_addon.sh
tools/package_addon.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
unzip -l dist/gamecenter-addon.zip
git diff --check
```

Expected: all tests pass; the ZIP root is `addons/gamecenter`; validator reports the exact architectures and minimum deployment versions.

- [ ] **Step 8: Update status and commit**

```bash
git add SConstruct tools/build_xcframework.sh tools/package_addon.sh tools/validate_release.py tests/test_repository_contract.py example/addons/gamecenter/README.md example/addons/gamecenter/plugin.cfg docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "build: create reproducible plugin package"
```

---

### Task 5: Godot compatibility smoke tests and CI release gates

**Files:**

- Create: `tools/download_godot_macos.sh`
- Create: `tools/run_godot_smoke.sh`
- Modify: `example/project.godot`
- Create or modify after validating generated format: `example/export_presets.cfg`
- Modify: `.github/workflows/build.yml`
- Modify: `tests/test_repository_contract.py`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: official Godot `4.5.2-stable` and `4.7.2-stable` macOS universal archives; Task 4 ZIP.
- Produces: repeatable Godot runtime smoke command and CI artifact `gamecenter-addon.zip`.

- [ ] **Step 1: Add failing CI-policy tests**

Add to `tests/test_repository_contract.py`:

```python
    def test_ci_has_release_permissions_and_smoke_matrix(self) -> None:
        workflow = (ROOT / ".github" / "workflows" / "build.yml").read_text(encoding="utf-8")
        self.assertIn("contents: write", workflow)
        self.assertIn("4.5.2-stable", workflow)
        self.assertIn("4.7.2-stable", workflow)
        self.assertIn("tools/run_godot_smoke.sh", workflow)
        self.assertIn("dist/gamecenter-addon.zip", workflow)
```

- [ ] **Step 2: Run the CI-policy test to verify it fails**

Run:

```bash
python3 -m unittest tests.test_repository_contract.RepositoryContractTests.test_ci_has_release_permissions_and_smoke_matrix -v
```

Expected: failure because the current workflow has none of the required gates.

- [ ] **Step 3: Add pinned Godot downloader and smoke runner**

Create `tools/download_godot_macos.sh` with arguments `<tag> <destination>` and this URL contract:

```bash
version="${tag%-stable}"
asset="Godot_v${tag}_macos.universal.zip"
url="https://github.com/godotengine/godot-builds/releases/download/${tag}/${asset}"
curl --fail --location --retry 3 --output "$archive" "$url"
unzip -q "$archive" -d "$destination"
find "$destination" -type f -path '*/Godot.app/Contents/MacOS/Godot' -print -quit
```

Create `tools/run_godot_smoke.sh` with arguments `<godot-executable>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
godot_bin="$1"
"$godot_bin" --headless --editor --path example --quit-after 2
"$godot_bin" --headless --path example --script res://tests/runtime_contract.gd
```

- [ ] **Step 4: Enable the editor plug-in in the example**

Add to `example/project.godot`:

```ini
[editor_plugins]

enabled=PackedStringArray("res://addons/gamecenter/plugin.cfg")
```

Run the smoke script on macOS with 4.5.2 and 4.7.2. If the `EditorExportPlatformIOS`
type reference prevents parsing, replace it in `plugin.gd` with a platform-name check:

```gdscript
func _supports_platform(platform: EditorExportPlatform) -> bool:
    return platform.get_os_name() == "iOS"
```

- [ ] **Step 5: Validate and add an iOS export preset**

Use Godot 4.5.2 to create or validate `example/export_presets.cfg` with preset name
`iOS`, bundle identifier `org.godotengine.gamecenterkit.example`, arm64 enabled, and:

```ini
entitlements/game_center=true
```

Never add signing identities or provisioning-profile secrets. Confirm the file parses by
listing/exporting presets headlessly before committing it.

- [ ] **Step 6: Upgrade CI to build, test, package, smoke, and upload the ZIP**

Revise `.github/workflows/build.yml` to:

- set top-level `permissions: contents: read`;
- give only the release job/step `contents: write` where GitHub Actions syntax permits;
- use current non-Node-20 action majors available in the repository marketplace;
- build artifacts once;
- run native/Python tests;
- package and validate `dist/gamecenter-addon.zip`;
- download/run Godot 4.5.2 and 4.7.2 smoke tests in a matrix or sequentially;
- generate iOS debug and release Xcode exports;
- run an unsigned simulator `xcodebuild` link smoke when the generated project permits;
- upload the ZIP itself, not `dist/addons/gamecenter/`;
- on `v*` tags, fail if tag/version mismatch and create a draft release with that ZIP.

The release command remains English and conventional:

```bash
gh release create "${GITHUB_REF_NAME}" dist/gamecenter-addon.zip \
  --draft \
  --title "${GITHUB_REF_NAME}" \
  --notes-file marketing/release-notes.md
```

- [ ] **Step 7: Run the full local equivalent**

Run:

```bash
tools/run_cpp_tests.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
tools/build_xcframework.sh
tools/package_addon.sh
godot_dir="$(mktemp -d "${TMPDIR:-/tmp}/gamecenter-godot.XXXXXX")"
godot_45="$(tools/download_godot_macos.sh 4.5.2-stable "$godot_dir/4.5.2")"
godot_47="$(tools/download_godot_macos.sh 4.7.2-stable "$godot_dir/4.7.2")"
tools/run_godot_smoke.sh "$godot_45"
tools/run_godot_smoke.sh "$godot_47"
git diff --check
```

Expected: all checks pass. If unsigned iOS export/link cannot run locally because export templates are not installed, install the official matching template packages and rerun; document any remaining signing-only limitation in `status.md`.

- [ ] **Step 8: Update status and commit**

```bash
git add tools/download_godot_macos.sh tools/run_godot_smoke.sh example/project.godot example/export_presets.cfg .github/workflows/build.yml tests/test_repository_contract.py docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "ci: verify Godot plugin release artifacts"
```

---

### Task 6: Public documentation and Store media kit

**Files:**

- Modify: `README.md`
- Create: `CHANGELOG.md`
- Create: `marketing/store-listing.md`
- Create: `marketing/release-notes.md`
- Create: `marketing/release-checklist.md`
- Create: `marketing/media/gamecenterkit-store-thumbnail.png`
- Create: `marketing/media/README.md`
- Modify: `tests/test_repository_contract.py`
- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`

**Interfaces:**

- Consumes: verified Core 1.0 contract and package details from Tasks 3-5.
- Produces: reviewable Store fields and a 16:9 PNG; no external publication.

- [ ] **Step 1: Add failing documentation/media tests**

Add to `tests/test_repository_contract.py`:

```python
    def test_store_material_is_complete(self) -> None:
        listing = (ROOT / "marketing" / "store-listing.md").read_text(encoding="utf-8")
        for heading in ("Asset name", "Summary", "Description", "Tags", "AI use disclosure"):
            self.assertIn(heading, listing)
        self.assertTrue((ROOT / "CHANGELOG.md").is_file())

    def test_store_thumbnail_is_16_by_9(self) -> None:
        from struct import unpack
        image = ROOT / "marketing" / "media" / "gamecenterkit-store-thumbnail.png"
        data = image.read_bytes()
        self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
        width, height = unpack(">II", data[16:24])
        self.assertGreaterEqual(width, 1280)
        self.assertEqual(width * 9, height * 16)
```

- [ ] **Step 2: Run tests to verify the red state**

Run:

```bash
python3 -m unittest tests.test_repository_contract -v
```

Expected: missing documentation/media tests fail.

- [ ] **Step 3: Rewrite repository documentation around verified positioning**

Update `README.md` to lead with:

```markdown
# GameCenterKit for Godot

A focused, signal-driven Game Center bridge for Godot 4.5-4.7 on iOS 14+.
Prebuilt device and simulator binaries install as a regular `addons/gamecenter`
plug-in, with macOS 11+ editor binaries for development.
```

Include the complete verified API, compatibility matrix, installation, entitlement,
App Store Connect, build, troubleshooting, limitations, privacy, contributing/support,
and license sections. Explain that official and broader community Apple bindings also
exist; differentiate on small scope and signal-first use rather than exclusivity.

Create `CHANGELOG.md` with `1.0.0` entries for Added, Changed, Fixed, and Validation.

- [ ] **Step 4: Prepare Store and release copy**

Create `marketing/store-listing.md` with:

- Asset name: `GameCenterKit for Godot`;
- one-sentence English summary;
- focused description and feature list;
- tags selected from existing Store vocabulary: `iOS`, `Mobile`, `Apple`, `C++`, and
  `GDExtension`;
- minimum Godot `4.5`, maximum Godot `4.7`, version `1.0.0`, license `MIT`;
- source/support links pointing to the repository URL, marked pending-publication while
  the repo is private;
- AI use disclosure limited to the Store-required field: Codex assisted code review,
  test/CI design, documentation, and marketing-image generation; the maintainer reviewed
  results and validated GameKit behavior;
- a bracketed Gridlord proof line excluded from final copy unless explicitly approved.

Create English `marketing/release-notes.md` and a checklist covering repository
visibility, metadata, tag, draft release, checksums, device test, Store form, thumbnail,
AI disclosure, and final submit action.

- [ ] **Step 5: Generate and verify the Store thumbnail**

Use the `imagegen` skill to create a 1280x720 or larger PNG with:

- a clean dark-blue developer-tool aesthetic;
- a generic trophy/leaderboard and signal-wave motif;
- the text `GameCenterKit for Godot` and `Signal-driven iOS Game Center`;
- no Apple logo, Game Center logo, Godot logo, app-store badge, or unlicensed trademark;
- enough empty margin for Store cropping.

Save the selected output as `marketing/media/gamecenterkit-store-thumbnail.png`. In
`marketing/media/README.md`, record dimensions, intended Store field, and that the image
was generated with an AI image tool so the mandatory disclosure remains accurate.

- [ ] **Step 6: Run documentation/media/package validation**

Run:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
tools/package_addon.sh
python3 tools/validate_release.py dist/gamecenter-addon.zip
git diff --check
```

Expected: all checks pass and the add-on ZIP remains unaffected by repository-only media.

- [ ] **Step 7: Update status and commit**

```bash
git add README.md CHANGELOG.md marketing tests/test_repository_contract.py docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "docs: prepare GameCenterKit 1.0 release"
```

---

### Task 7: Final verification and publication handoff

**Files:**

- Modify: `docs/specs/2026-09-04-market-ready-game-center-plugin/status.md`
- Modify only if validation finds a defect: files owned by Tasks 1-6

**Interfaces:**

- Consumes: all prior task outputs.
- Produces: verified release candidate plus a concise list of external actions awaiting approval.

- [ ] **Step 1: Run every automated gate from a clean state**

Run:

```bash
git status --short
tools/run_cpp_tests.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
tools/build_xcframework.sh
tools/package_addon.sh
python3 tools/validate_release.py dist/gamecenter-addon.zip
git diff --check
```

Then run Godot 4.5.2 and 4.7.2 smoke tests using Task 5's scripts.

- [ ] **Step 2: Inspect the release candidate manually**

Verify:

```bash
unzip -l dist/gamecenter-addon.zip
shasum -a 256 dist/gamecenter-addon.zip
git log --format='%h %s' 6742c15..HEAD
git status --short
```

Expected: correct root/files, stable checksum, only English Conventional Commit subjects,
no AI commit labels/trailers, and a clean tracked worktree.

- [ ] **Step 3: Record device-only checklist status**

Record prior Gridlord success separately from the post-change release-candidate device
check. Do not claim post-change device validation until authentication, score,
achievement, panels, access point, modal presentation, and entitlement have been rerun on
an iOS device.

- [ ] **Step 4: Fix any failures and rerun the affected gate**

For each failure, add a focused regression assertion before the fix, rerun the smallest
affected check, then rerun the full gate. Use an English Conventional Commit such as:

```bash
git commit -m "fix: correct release validation mismatch"
```

Do not squash away the red/green evidence unless the maintainer requests history cleanup.

- [ ] **Step 5: Complete status and stop before external publication**

Mark automated acceptance criteria with exact commands/results. List these pending user
decisions/actions:

- allow or omit the public Gridlord reference;
- make the GitHub repository public;
- set GitHub description/topics;
- push commits and tag `v1.0.0`;
- publish the draft GitHub release;
- upload/submit the Store listing.

Commit only the final status update if it changes tracked content:

```bash
git add docs/specs/2026-09-04-market-ready-game-center-plugin/status.md
git commit -m "docs: record GameCenterKit release verification"
```

Do not perform any pending external action without explicit approval.
