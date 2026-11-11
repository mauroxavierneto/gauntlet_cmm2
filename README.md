# Gauntlet for Colour Maximite 2 — Gameplay fixes with the original nine rooms

This is a **CMM2 hardware game** based on Mauro Xavier's Gauntlet port. The original arcade game was designed by Ed Logg for Atari Games. This maintenance branch preserves the original project attribution, media and historical README below. The fixes and expansion are community maintenance work on the GremlinMo fork; they do not replace the original authorship or imply endorsement by the original authors.

This branch keeps the original nine room maps unchanged and focuses on gameplay corrections. It does not add rooms or a campaign ending. The original advancement after room nine is retained: no ROOM10 map is supplied, so the next-map behavior remains an upstream limitation. The separate campaign branch supplies a defined 39-room campaign and ending.

## Download and run on a CMM2

After publication, the [fork's releases page](https://github.com/GremlinMo/gauntlet_cmm2/releases) provides **Gauntlet-CMM2-Fixes.zip**, a complete SD-card game folder; **GAUNTLET.BAS** as a separate direct download; a complete source ZIP; a patch against upstream `dc76eab5620afd6efc3511e7880d2316918dfdc9`; release notes, test results and SHA-256 checksums. The source branch is [`cmm2-gameplay-fixes`](https://github.com/GremlinMo/gauntlet_cmm2/tree/cmm2-gameplay-fixes).

Extract the complete `Gauntlet` folder to your CMM2's SD card. At the MMBasic prompt, change into that folder and run `RUN "GAUNTLET.BAS"`. Keep every included `.INC` file and the `FONTS`, `IMAGES`, `MAPS`, `MOD` and `SOUND` directories together. **The separate GAUNTLET.BAS download is not a complete game:** use it only with the matching includes and assets from the same release.

The original author specifies **CMM2 firmware 5.05.05 or later** for v0.4a. Firmware and physical-hardware compatibility of this maintenance release remain pending; the program's older numeric firmware guard is not evidence that earlier firmware is supported.

Choose the original keyboard/numpad or Wii Classic controller options in the game. The original alternate keyboard option remains available. The historical Nunchuk option is not claimed as verified support. These packages contain no Windows launcher, emulator, executable or desktop control adaptation.

## Changes dated 11 November 2026

- Center players on the exit they actually enter, including during scrolling; advance a room once every living player has finished exiting.
- Restore independent demon projectiles, with wall/player collision and one movement step per frame.
- Bound tile access and improve player/enemy collision, diagonal approaches, door opening and pickup handling.
- Correct enemy targeting, slime/generator handling and enemy-pool limits.
- Call `StopWAV` explicitly at stage start and clear interrupted sound priority, addressing upstream issue #2; retain music restart behavior.
- Correct the font-row boundary and require a released-then-fresh Space press at the title screen.

- Keep the original nine maps and original post-room-nine behavior; no expansion content or completion screen is added.

See [CHANGELOG-CMM2.md](CHANGELOG-CMM2.md) for this branch's scope and [TESTING-CMM2.md](TESTING-CMM2.md) for evidence and hardware checks.

## Verification and limits

The final source check on 11 November 2026 passed **49 Python tests**. The tests execute selected real BASIC routines through a focused Python language subset ; packaging separately verifies the original asset bytes. They do **not** validate the CMM2 framebuffer, actual MMBasic parsing/execution of the whole game, Wii devices, audio playback, frame rate or campaign balance. Physical CMM2 testing is **pending**. Use the captured `TEST-RESULTS.txt` release asset for exact output.

Run `python -m unittest discover -s tests -v` with Python 3.10 or later. Build the deterministic CMM2 packages with `python tools/package_cmm2.py --test-results PATH_TO_CAPTURED_OUTPUT`; no third-party Python packages are needed. Packaging preserves every original media/map byte, converts BASIC/include release text to CRLF, and makes the direct BASIC asset byte-for-byte identical to its ZIP entry. Maps use fixed-width binary records and must not undergo text/newline conversion.

Gauntlet names, artwork and audio retain their existing ownership notices. The upstream project describes itself as a noncommercial fan/homebrew port; this maintenance work does not add a new permission grant for third-party materials. Original in-game credits and historical notices remain included.

---

## Original project README and historical changelog (retained)

The following is the original author's description and historical v0.4a bug list. It is retained for attribution/history; current maintenance changes and remaining validation limits are described above.

# gauntlet_cmm2
Gauntlet port for the Colour Maximite 2
(I RECOMMEND YOU USE THE LAST BETA FIRMWARE FOR CMM2)

This is a version of Gauntlet to Colour Maximite 2.
I don´t own any rights about Gauntlet trademark, this is only a homebrew project made by me in my free time, and for sure in the current state, it has lots of bugs.
Keep in mind I´m only a Gauntlet fan with some basic developing skills and my target is only to challenge myself to port it to CMM2, it´s not a project with profit intentions.

Changelog:

v0.4a - 2020-08-06
- Need at least the 5.05.05 firmware or it doesn´t run!
- Two players support.
- 320x240 resolution.
- Smoother scroll.
- Removed 8-bit sound style for speed sake (sorry!).
- The player's characteristics were rebalanced.
- Some speed optimizations.
- Source code separated in INC files.
- Four-channel sound effects support thanks to the last update on the firmware.
- Sound test with music and voices in the options screen.
- Some arts was redone to 320x240 resolution.
- Wii Classic Controller support (not Wii Nunchuk yet).
- The copyright screen was disabled until the next release.

Known bugs:
- Players sometimes don´t centralize in the exit.
- Demon´s fire stopped working.
- When someone goes to the exit, the game will change level even if another player is still playing.
- Many collision bugs.


v0.3a - 2020-05-06
- Made for the first CMM2 Gauntlet video on my Youtube channel.
- Some little optimizations

v0.1a - 2020-04-20
- Initial port from CMM1 to CMM2 - very unoptimized
- One player only.
- Only keyboard.
- Credits not working on the options menu.
- Many credits for the music are absent yet.
- Severe slow down when the screen is full of enemies.
- When demons have a shoot the player´s weapon can disappear for a moment (this is because they share the same code).
