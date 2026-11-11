# CMM2 maintenance changelog

## 11 November 2026 — Gameplay fixes with the original nine rooms

Base: `mauroxavierneto/gauntlet_cmm2` commit `dc76eab5620afd6efc3511e7880d2316918dfdc9`. Proposed publication branch: `cmm2-gameplay-fixes` on the GremlinMo fork.

Original CMM2 port: **Mauro Xavier**. Original arcade design: **Ed Logg / Atari Games**. Original media, game credits and the historical README are retained.

- Anchor exits to the entered tile, center exiting players and wait for every living player's animation before one room transition. Exited/dead players no longer obstruct active players.
- Restore demon fire in all eight directions, preserve projectile ownership through enemy compaction, move each projectile once per frame, and stop it at walls or an active player.
- Use bounded source-tile access and consistent collision geometry; prevent pickups/exits through blocked corners, allow wall sliding and consume one key per connected door group.
- Correct enemy pursuit, slime movement, stale-slot spawning, native generator type/health and full-pool allocation.
- Invoke `StopWAV` as a statement at stage start, reset interrupted effect priority, and preserve music restart behavior (upstream issue #2).
- Correct the bitmap-font row boundary and require a fresh title-screen Space press after release.

- Keep the original nine maps and original post-room-nine behavior; no expansion content or completion screen is added.

The release is CMM2-only. It retains hardware framebuffer and Wii controller paths and includes no Windows runtime or PC adaptation.

Validation: **49 source-driven Python checks passed** on 11 November 2026. Hardware validation remains pending. These checks do not certify rendering, audio, controllers, performance or combat balance; see TESTING-CMM2.md and the captured release test output.
