from pathlib import Path
import subprocess
import unittest
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]


class PackageContractTests(unittest.TestCase):
    def test_packager_produces_installable_core_1_0_zip(self) -> None:
        result = subprocess.run(
            ["bash", "tools/package_addon.sh"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        archive = ROOT / "dist" / "gamecenter-addon.zip"
        with ZipFile(archive) as package:
            names = set(package.namelist())
            self.assertTrue(names)
            self.assertTrue(all(name.startswith("addons/gamecenter/") for name in names))
            self.assertIn("addons/gamecenter/README.md", names)
            self.assertIn("addons/gamecenter/LICENSE", names)
            plugin_cfg = package.read("addons/gamecenter/plugin.cfg").decode("utf-8")
            self.assertIn('version="1.0.0"', plugin_cfg)


if __name__ == "__main__":
    unittest.main()
