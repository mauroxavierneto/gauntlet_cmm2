# CMM2 validation record and hardware checklist

## Automated source checks — 11 November 2026

Command, from this source folder with Python 3.10 or later:

```text
python -m unittest discover -s tests -v
```

Final reported result: **49 tests passed**, exit code 0. Capture stdout/stderr as bytes and pass that file to `python tools/package_cmm2.py --test-results PATH`; the package copies the exact output to `dist/cmm2/TEST-RESULTS.txt` and appends the pending-hardware status. No measured result is inferred from the package being created.

Tests execute selected routines and main-loop excerpts from the actual `.BAS`/`.INC` source using `tests/basic_runner.py`. Collision, exits, demon fire, enemy/generator allocation, sound-priority state, title input and font coordinates are checked. Original map bytes are protected. This branch supplies the original nine maps without expansion or ending checks.

The Python runner is a strict, small MMBasic language subset. Unsupported statements fail; graphics/audio calls are recorded, randomness is controlled and keyboard/controller values are scripted. It does not execute the complete game in native MMBasic and does not emulate a CMM2. Map reachability assumes combat can clear enemies; it does not prove survivability, fairness or difficulty.

## Hardware validation — PENDING

Record the CMM2 model, exact firmware version, SD-card contents and SHA-256 manifest, controller model/port and relevant options. The original author requires firmware 5.05.05 or later. These items are a checklist, not claims that testing has occurred.

- Start from the complete extracted folder on an SD card. Load all required includes and media; inspect title, options, character selection, fonts, status panels, scrolling and page/framebuffer restoration.
- Start one-player and two-player sessions using the original keyboard/numpad layouts and Wii Classic controllers in both player ports. Check movement, fire, magic, selection, options and Escape. Record keyboard rollover and controller behavior.
- Approach walls/doors diagonally, slide along boundaries, collect a pickup at multiple character corners, open connected doors with exactly one key, and approach treasure/exits behind walls.
- Have players enter different exits while the other scrolls. Confirm exact exit centering, safe waiting, no repeat exit, one room transition after every living player finishes, and correct behavior when one/all players die.
- Exercise demon shots in every direction against each player and walls. Check independent player fire, enemy compaction, generator returns and crowded enemy pools.
- **Issue #2 / StopWAV:** after narration in rooms 3 and 5 and treasure rooms, start the next stage and trigger exit, slime and death effects. Confirm the stage-start `StopWAV` call clears interrupted priority and that subsequent effects/music play. Source assertions alone do not establish audible playback.
- Test music on/off, option sound tests, interrupted narration, death/exit sounds and stage transitions. Measure performance during heavy scrolling/enemy activity and listen for audio glitches.
- Confirm rooms 1–9 retain their existing layouts. Record the original missing-next-map behavior after room nine; this fixes branch does not supply an ending or ROOM10.
- Check framebuffer PEEK/POKE boundary handling on real hardware and Escape returning to MODE 1. A headless test cannot validate address arithmetic against physical video memory.

Report failures with the release checksum, room, player state, inputs and firmware version. Physical hardware, visual/audio output, timing and original-room gameplay remain unverified until this checklist is executed.

## Reproducible package verification

```text
python tools/package_cmm2.py --test-results PATH_TO_CAPTURED_OUTPUT
```

The script verifies every original media/map blob against upstream `dc76eab5620afd6efc3511e7880d2316918dfdc9`, checks the exact required include/map set, normalizes only release `.BAS`/`.INC` text to CRLF, and excludes unrelated files. It writes full game/source ZIPs, a binary-capable upstream patch, a direct `GAUNTLET.BAS`, notes, captured results, build information and SHA-256 sums under `dist/cmm2`. ZIP timestamps/order/permissions are fixed, so identical inputs produce identical archives. The direct BASIC bytes must equal `Gauntlet/GAUNTLET.BAS` in the game ZIP. Both ZIPs include internal SHA-256 manifests.
