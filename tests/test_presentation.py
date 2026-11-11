"""Run actual font, audio-reset, and title-input code without CMM2 hardware."""

from pathlib import Path
import unittest

from basic_runner import Basic, split


ROOT = Path(__file__).resolve().parents[1]


class Cmm2Exit(Exception):
    pass


class TitleBasic(Basic):
    def __init__(self, keys):
        super().__init__(ROOT, set())
        self.keys = keys
        self.frames = 0
        self.globals.update(kb=32, retro=0)
        self.builtins["keydown"] = self.keydown

    def keydown(self, index):
        if self.frames >= len(self.keys):
            raise AssertionError("Title did not accept the scripted fresh Space press")
        return self.keys[self.frames] if index == 1 else 0

    def statement(self, statement, local):
        low = statement.strip().lower()
        if low == "page copy 7 to 0,i":
            self.frames += 1
        if low.startswith("mode "):
            self.calls.append(statement)
            return
        if low == "end":
            raise Cmm2Exit()
        return super().statement(statement, local)

    def run_title(self):
        source = (ROOT / "INTRO.INC").read_text()
        source = "co=1" + source.split("co=1", 1)[1]
        source = source.split("if retro=1 then UnloadVGM", 1)[0]
        self.snippet(source)


class PresentationTests(unittest.TestCase):
    def test_font_row_boundary_draws_t_u_v_from_valid_glyphs(self):
        class GlyphBasic(Basic):
            def statement(self, statement, local):
                if statement.lower().startswith("blit "):
                    self.calls.append(tuple(self.expression(arg, local)
                                            for arg in split(statement[5:])))
                    return
                return super().statement(statement, local)

        basic = GlyphBasic(ROOT, {"printg"})
        basic.builtins.update({"len": len, "asc": ord,
                               "mid$": lambda text, start, size: text[start - 1:start - 1 + size]})
        basic.call("PrintG", 0, 0, "TUV")
        self.assertEqual([call[:2] for call in basic.calls],
                         [(312, 170), (0, 178), (6, 178)])

    def test_music_restart_clears_interrupted_voice_priority(self):
        class MusicBasic(Basic):
            def statement(self, statement, local):
                if statement.lower().startswith("play modfile "):
                    self.calls.append(statement)
                    return
                return super().statement(statement, local)

        basic = MusicBasic(ROOT, {"playmod", "stopwav"})
        basic.globals["prwav"] = 999
        basic.arrays["modmus$"].set((13, 0), "title")
        basic.call("PlayMOD", 13)
        self.assertEqual(basic.globals["prwav"], 0)
        self.assertEqual(basic.calls[0].lower(), "play stop")
        self.assertTrue(basic.calls[1].lower().startswith("play modfile "))

    def test_title_ignores_stale_key_and_held_space_until_release(self):
        basic = TitleBasic([32, 32, 0, 32])
        basic.run_title()
        self.assertEqual(basic.frames, 4)
        self.assertEqual(basic.globals["kb"], 32)

    def test_title_accepts_fresh_space_after_unheld_frame(self):
        basic = TitleBasic([0, 32])
        basic.run_title()
        self.assertEqual(basic.frames, 2)

    def test_title_escape_restores_basic_even_before_space_release(self):
        basic = TitleBasic([32, 27])
        with self.assertRaises(Cmm2Exit):
            basic.run_title()
        self.assertEqual(basic.frames, 1)
        self.assertIn("mode 1", [call.lower() for call in basic.calls])


if __name__ == "__main__":
    unittest.main()
