from pathlib import Path
from struct import unpack
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MarketingMediaTests(unittest.TestCase):
    def test_store_thumbnail_is_16_by_9_png(self) -> None:
        image = ROOT / "marketing" / "media" / "gamecenterkit-store-thumbnail.png"
        data = image.read_bytes()
        self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
        width, height = unpack(">II", data[16:24])
        self.assertGreaterEqual(width, 1280)
        self.assertEqual(width * 9, height * 16)


if __name__ == "__main__":
    unittest.main()
