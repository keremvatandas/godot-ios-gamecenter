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


if __name__ == "__main__":
    unittest.main()
