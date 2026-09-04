import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
KEY = "com.apple.developer.game-center"


@unittest.skipUnless(sys.platform == "darwin", "requires Apple's plutil")
class IOSExportSmokeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="gamecenter smoke ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.tools = self.root / "tools"
        self.tools.mkdir()
        shutil.copy2(ROOT / "tools/run_ios_export_smoke.sh", self.tools)
        self.fixture = self.root / "fixture"
        self.fixture.mkdir()
        (self.fixture / "project.pbxproj").write_text(
            "GameKit.framework libgamecenter.ios.xcframework\n"
        )
        self.write_tool("godot", '''#!/bin/bash
set -eu
for output in "$@"; do :; done
mkdir -p "$output" "$(dirname "$output")/GameCenterKit"
cp "$FIXTURE/project.pbxproj" "$output/project.pbxproj"
mode=debug
[[ "$*" != *--export-release* ]] || mode=release
cp "$FIXTURE/$mode.plist" "$(dirname "$output")/GameCenterKit/GameCenterKit.entitlements"
''')
        self.write_tool("xcrun", "#!/bin/bash\necho 26.2\n")
        self.write_tool("xcodebuild", '''#!/bin/bash
if [[ "$1" == -version ]]; then echo 'Xcode 26.2'; exit 0; fi
echo 'simulator linker invoked'
''')
        # Reproduce older macOS display formatting; keep actual typed plist
        # extraction real so wrong key escaping or types cannot pass the test.
        self.write_tool("plutil", '''#!/bin/bash
set -euo pipefail
if [[ "$1" == -p ]]; then
  /usr/bin/plutil "$@" | sed 's/=> true/=> 1/g; s/=> false/=> 0/g'
else
  exec /usr/bin/plutil "$@"
fi
''')

    def write_tool(self, name: str, source: str) -> None:
        path = self.tools / name
        path.write_text(source)
        path.chmod(0o755)

    def run_smoke(self, data: bytes, mode: str = "debug") -> subprocess.CompletedProcess:
        for configuration in ("debug", "release"):
            (self.fixture / (configuration + ".plist")).write_bytes(
                data if configuration == mode else plistlib.dumps({KEY: True})
            )
        return subprocess.run(
            ["bash", str(self.tools / "run_ios_export_smoke.sh"), str(self.tools / "godot")],
            env={**os.environ, "PATH": str(self.tools) + os.pathsep + os.environ["PATH"],
                 "FIXTURE": str(self.fixture)},
            capture_output=True, text=True, check=False,
        )

    def test_true_entitlement_passes_with_legacy_display_format(self) -> None:
        for fmt in (plistlib.FMT_XML, plistlib.FMT_BINARY):
            with self.subTest(format=fmt):
                result = self.run_smoke(plistlib.dumps({KEY: True}, fmt=fmt))
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("validated iOS debug/release exports", result.stdout)

    def test_invalid_entitlement_stops_before_simulator_link(self) -> None:
        cases = [{}, {KEY: False}, {KEY: 1}, {KEY: "true"}]
        for mode in ("debug", "release"):
            for data in [plistlib.dumps(case) for case in cases] + [b"not a plist"]:
                with self.subTest(mode=mode, data=data):
                    result = self.run_smoke(data, mode)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("entitlement", result.stderr.lower())
                    self.assertFalse((self.root / "build/ios-debug/xcodebuild.log").exists())


if __name__ == "__main__":
    unittest.main()
