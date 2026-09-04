from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_generated_outputs_are_ignored(self) -> None:
        expected = {
            ".worktrees/probe",
            "bin/probe.dylib",
            "build/probe.a",
            "dist/gamecenter-addon.zip",
            ".godot/",
            "example/.godot/",
            ".sconsign.dblite",
            "compile_commands.json",
            "src/probe.o",
            "src/probe.os",
            "Game.dSYM/Contents/Info.plist",
            "Game.xcarchive/Info.plist",
            "Tests.xcresult/Info.plist",
            "release.zip",
            "tests/__pycache__/test_contract.cpython-314.pyc",
            ".pytest_cache/v/cache/nodeids",
            ".coverage",
            ".DS_Store",
        }
        for path in expected:
            with self.subTest(path=path):
                result = subprocess.run(
                    ["git", "check-ignore", "--quiet", path],
                    cwd=ROOT,
                    check=False,
                )
                self.assertEqual(result.returncode, 0)

    def test_godot_uid_files_are_not_ignored(self) -> None:
        result = subprocess.run(
            ["git", "check-ignore", "--quiet", "example/main.gd.uid"],
            cwd=ROOT,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)

    def test_ci_uses_intel_macos_runner_for_x86_64_simulator_gate(self) -> None:
        workflow = (ROOT / ".github/workflows/build.yml").read_text()
        self.assertIn("runs-on: macos-15-intel", workflow)

    def test_ci_pins_xcode_26_for_apple_builds(self) -> None:
        workflow = (ROOT / ".github/workflows/build.yml").read_text()
        self.assertIn(
            "DEVELOPER_DIR: /Applications/Xcode_26.2.app/Contents/Developer",
            workflow,
        )

    def test_ios_export_smoke_preserves_xcodebuild_diagnostics(self) -> None:
        script = (ROOT / "tools/run_ios_export_smoke.sh").read_text()
        self.assertNotIn("\n\t-quiet\n", script)
        self.assertIn("require_file()", script)
        self.assertIn("require_match()", script)
        self.assertIn('xcodebuild_log=', script)
        self.assertIn('cat "$xcodebuild_log" >&2', script)


if __name__ == "__main__":
    unittest.main()
