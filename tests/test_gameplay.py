"""Run with: python -m unittest discover -s tests -v"""

from pathlib import Path
import re
import unittest

from basic_runner import Basic


ROOT = Path(__file__).resolve().parents[1]
ROUTINES = {"safetile", "stageblocked", "actorcollision", "moveplayer",
            "beginexit", "checkstageexit", "you", "stopwav", "addenemy",
            "sortenemies", "retenemy", "opendoor", "putenemies"}


class GameplayTests(unittest.TestCase):
    def setUp(self):
        self.basic = Basic(ROOT, ROUTINES)
        self.basic.noops.add("fast_mapclear")  # Framebuffer refresh after real door mutation.
        self.basic.globals.update(pln=1, plq=2, maxg=80, cntg=0, room=1)
        for player in (1, 2):
            self.set_array("energy", player, 100)
            self.set_array("x", player, 176 + player * 16)
            self.set_array("y", player, 192)

    def set_array(self, name, index, value):
        indices = index if isinstance(index, tuple) else (index,)
        self.basic.arrays[name.lower()].set(indices, value)

    def array(self, name, *indices):
        return self.basic.arrays[name.lower()](*indices)

    def projectile_tick(self, player=1):
        source = (ROOT / "GAUNTLET.BAS").read_text()
        excerpt = source.split("' DEFINE IF THE SHOT IS TOO FAST", 1)[1]
        excerpt = excerpt.split("'RESET VARIABLES FOR SCROLL", 1)[0]
        # Preserve the complete source loop, excluding its first comment line.
        self.basic.globals["pl"] = player
        self.basic.snippet(excerpt.split("\n", 1)[1])

    def player_collision_tick(self, target_x, target_y):
        source = (ROOT / "GAUNTLET.BAS").read_text()
        excerpt = source.split("Collided=0\n", 1)[1]
        excerpt = excerpt.split("' DEFINE PLAYER SPRITE", 1)[0]
        self.basic.globals["pl"] = 1
        self.set_array("x", 1, target_x)
        self.set_array("y", 1, target_y)
        self.basic.snippet(excerpt)

    def test_tile_bounds_and_fractional_coordinates(self):
        self.set_array("st", (2, 3), 455)
        self.assertEqual(self.basic.call("SafeTile", 3.9, 2.9), 455)
        for x, y in ((-1, 2), (2, -1), (36, 2), (2, 36)):
            self.assertEqual(self.basic.call("SafeTile", x, y), 600)

    def test_wall_contact_uses_floor_at_pixel_boundary(self):
        self.set_array("st", (1, 2), 600)
        self.assertEqual(self.basic.call("StageBlocked", 2.99, 0), 0)
        self.assertEqual(self.basic.call("StageBlocked", 3, 0), 1)

    def test_collision_follows_world_scroll(self):
        self.basic.globals.update(px=4, py=3, scx=7.5, scy=3.25)
        self.set_array("st", (4, 6), 600)
        self.assertEqual(self.basic.call("StageBlocked", -4.51, 0), 0)
        self.assertEqual(self.basic.call("StageBlocked", -4.5, 0), 1)

    def test_walkable_tiles_and_active_enemy_markers(self):
        for tile in (0, -1, -3, 434, 617, 5200, 6397):
            with self.subTest(tile=tile):
                self.set_array("st", (1, 1), tile)
                self.assertEqual(self.basic.call("StageBlocked", 0, 0), 0)

    def test_solid_objects_and_all_monster_levels(self):
        for tile in (426, 427, 444, 455, 459, 490, 600, 799, 1023,
                     200, 1200, 2200, 1392, 2392, 2595, 2697):
            with self.subTest(tile=tile):
                self.set_array("st", (1, 1), tile)
                self.assertEqual(self.basic.call("StageBlocked", 0, 0), 1)

    def test_actor_collision_ignores_dead_and_exiting_players(self):
        self.set_array("x", 2, 8)
        self.set_array("y", 2, 0)
        self.assertEqual(self.basic.call("ActorCollision", 0, 0, 0, 1), 2)
        for state in (1, 30, 31, 100):
            self.set_array("start", 2, state)
            self.assertEqual(self.basic.call("ActorCollision", 0, 0, 0, 1), 0)
        self.set_array("start", 2, 0)
        self.set_array("energy", 2, 0)
        self.assertEqual(self.basic.call("ActorCollision", 0, 0, 0, 1), 0)

    def test_actor_collision_uses_active_enemy_position(self):
        self.set_array("ae", 1, 1)
        self.set_array("en", 1, 5)
        self.set_array("xe", 1, 8)
        self.set_array("ye", 1, 0)
        self.assertEqual(self.basic.call("ActorCollision", 0, 0, 0, 1), -1)
        self.assertEqual(self.basic.call("ActorCollision", 0, 0, 1, 1), 0)
        self.set_array("en", 1, 0)
        self.assertEqual(self.basic.call("ActorCollision", 0, 0, 0, 1), 0)

    def test_swept_player_movement_stops_at_wall_and_slides(self):
        self.set_array("st", (1, 2), 600)
        self.set_array("xx", 1, 0)
        self.set_array("yy", 1, 0)
        self.basic.call("MovePlayer", 1, 32, 8)
        self.assertEqual((self.array("x", 1), self.array("y", 1)), (2, 8))

    def test_swept_player_movement_handles_fractional_step(self):
        self.set_array("xx", 1, 0.25)
        self.set_array("yy", 1, 0.5)
        self.basic.call("MovePlayer", 1, 1.75, 2.25)
        self.assertEqual((self.array("x", 1), self.array("y", 1)), (1.75, 2.25))

    def test_player_cannot_walk_through_another_player(self):
        self.set_array("x", 2, 16)
        self.set_array("y", 2, 0)
        self.basic.call("MovePlayer", 1, 32, 0)
        self.assertEqual(self.array("x", 1), 4)

    def test_diagonal_exit_behind_wall_cannot_trigger(self):
        self.set_array("st", (1, 2), 600)
        self.set_array("st", (2, 2), 434)
        self.player_collision_tick(8, 8)
        self.assertEqual(self.array("start", 1), 0)
        self.assertEqual((self.array("x", 1), self.array("y", 1)), (2, 8))

    def test_treasure_behind_wall_cannot_be_collected(self):
        self.set_array("st", (1, 2), 600)
        self.set_array("st", (1, 3), 455)
        self.player_collision_tick(32, 0)
        self.assertEqual(self.array("score", 1), 0)
        self.assertEqual(self.array("st", 1, 3), 455)

    def test_reachable_treasure_collected_only_once_for_multiple_corners(self):
        self.set_array("st", (1, 2), 455)
        self.player_collision_tick(8, 0)
        self.assertEqual(self.array("score", 1), 100)
        self.assertEqual(self.array("st", 1, 2), -3)
        self.assertEqual(self.array("x", 1), 8)

    def test_full_inventory_does_not_exceed_key_or_bag_limit(self):
        for keys, bombs in ((9, 0), (8, 5)):
            with self.subTest(keys=keys, bombs=bombs):
                self.set_array("st", (1, 2), 444)
                self.set_array("key", 1, keys)
                self.set_array("bomb", 1, bombs)
                self.player_collision_tick(8, 0)
                self.assertEqual(self.array("key", 1), keys)
                self.assertEqual(self.array("st", 1, 2), 444)
                self.assertEqual(self.array("x", 1), 8)

    def test_connected_door_consumes_one_key_and_clears_all_tiles(self):
        self.set_array("key", 1, 2)
        for y in (1, 2, 3):
            self.set_array("st", (y, 2), 490)
        self.player_collision_tick(8, 0)
        self.assertEqual(self.array("key", 1), 1)
        for y in (1, 2, 3):
            self.assertEqual(self.array("st", y, 2), 0)

    def test_locked_door_blocks_player_without_key(self):
        self.set_array("st", (1, 2), 490)
        self.player_collision_tick(8, 0)
        self.assertEqual(self.array("x", 1), 2)
        self.assertEqual(self.array("st", 1, 2), 490)

    def test_begin_exit_centers_and_cancels_player_shot(self):
        self.basic.globals.update(px=4, py=2, scx=3.75, scy=5.5)
        self.set_array("fire", 1, 1)
        self.basic.call("BeginExit", 1, 10, 8)
        self.assertEqual(self.array("start", 1), 100)
        self.assertEqual((self.array("x", 1), self.array("y", 1)), (76.25, 74.5))
        self.assertEqual(self.array("fire", 1), 0)
        self.assertEqual(self.array("xf", 1), -64)
        self.assertEqual(self.array("exitx", 1), 10)

    def test_exit_anchor_tracks_entered_tile_during_scroll(self):
        self.basic.call("BeginExit", 1, 10, 8)
        self.basic.globals.update(px=5, py=3, scx=6.5, scy=2.75)
        self.basic.call("YOU", 0, 1)
        self.assertEqual((self.array("x", 1), self.array("y", 1)), (57.5, 61.25))
        self.assertEqual(self.array("start", 1), 99)

    def test_exit_animation_finishes_once_and_waits(self):
        self.basic.call("BeginExit", 1, 10, 8)
        for tick in range(70):
            self.basic.call("YOU", 0, 1)
            self.assertEqual(self.array("start", 1), 99 - tick)
        for _ in range(5):
            self.basic.call("YOU", 0, 1)
        self.assertEqual(self.array("start", 1), 30)
        self.assertEqual(self.basic.globals["room"], 1)

    def test_exit_does_not_advance_while_other_player_is_playing(self):
        self.set_array("start", 1, 30)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["nextroom"], 0)
        self.assertEqual(self.basic.globals["room"], 1)

    def test_exit_waits_until_both_animations_finish(self):
        self.set_array("start", 1, 30)
        self.set_array("start", 2, 31)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["nextroom"], 0)
        self.basic.call("YOU", 0, 2)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["nextroom"], 1)
        self.assertEqual(self.basic.globals["room"], 2)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["room"], 2)

    def test_dead_player_does_not_block_exit(self):
        self.set_array("start", 1, 30)
        self.set_array("energy", 2, 0)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["nextroom"], 1)

    def test_solo_player_can_exit(self):
        self.basic.globals["plq"] = 1
        self.set_array("start", 1, 30)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["nextroom"], 1)

    def test_all_dead_does_not_advance_room(self):
        for player in (1, 2):
            self.set_array("energy", player, 0)
        self.basic.call("CheckStageExit")
        self.assertEqual(self.basic.globals["gameover"], 1)
        self.assertEqual(self.basic.globals["nextroom"], 0)
        self.assertEqual(self.basic.globals["room"], 1)

    def test_dead_or_already_exiting_player_cannot_restart_exit(self):
        self.set_array("energy", 1, 0)
        self.basic.call("BeginExit", 1, 10, 8)
        self.assertEqual(self.array("start", 1), 0)
        self.set_array("energy", 1, 100)
        self.set_array("start", 1, 30)
        self.basic.call("BeginExit", 1, 10, 8)
        self.assertEqual(self.array("start", 1), 30)

    def test_stopwav_resets_effect_priority(self):
        self.basic.globals["prwav"] = 999
        self.basic.call("StopWAV")
        self.assertEqual(self.basic.globals["prwav"], 0)

    def test_demon_fire_initializes_all_eight_directions(self):
        directions = ((0, -8), (8, -8), (8, 0), (8, 8),
                      (0, 8), (-8, 8), (-8, 0), (-8, -8))
        for sprite, direction in enumerate(directions, 446):
            with self.subTest(sprite=sprite):
                self.basic.globals["dfire"] = 0
                self.basic.call("AddEnemy", 64, 64, 13, sprite, 1)
                self.assertEqual(self.basic.globals["dfire"], 1)
                self.assertEqual(self.array("fire", 0), 1)
                self.assertEqual(self.array("xs", 0), sprite)
                self.assertEqual((self.array("xfs", 0), self.array("yfs", 0)), direction)
                self.assertEqual((self.array("xf", 0), self.array("yf", 0)), (64, 64))

    def test_demon_fire_does_not_launch_into_wall(self):
        self.set_array("st", (5, 6), 600)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.assertEqual(self.basic.globals["dfire"], 0)
        self.assertEqual(self.array("fire", 0), 0)

    def test_firing_demon_marker_does_not_block_launch(self):
        self.set_array("st", (5, 5), 5248)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.assertEqual(self.basic.globals["dfire"], 1)

    def test_existing_demon_fire_is_not_reinitialized(self):
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.basic.call("AddEnemy", 128, 128, 13, 446, 1)
        self.assertEqual((self.array("xf", 0), self.array("yf", 0)), (64, 64))
        self.assertEqual((self.array("xfs", 0), self.array("yfs", 0)), (8, 0))

    def test_demon_fire_moves_once_per_frame_in_two_player_game(self):
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.projectile_tick(1)
        self.projectile_tick(2)
        self.assertEqual(self.array("xf", 0), 72)
        self.assertEqual(self.array("yf", 0), 64)

    def test_demon_fire_damages_active_player_and_stops(self):
        self.set_array("x", 2, 72)
        self.set_array("y", 2, 64)
        self.set_array("carm", 2, 2)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.projectile_tick()
        self.assertEqual(self.array("energy", 2), 82)
        self.assertEqual(self.array("fire", 0), 2)

    def test_demon_fire_ignores_exiting_player(self):
        self.set_array("x", 2, 72)
        self.set_array("y", 2, 64)
        self.set_array("start", 2, 100)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.projectile_tick()
        self.assertEqual(self.array("energy", 2), 100)
        self.assertEqual(self.array("fire", 0), 1)

    def test_demon_fire_stops_on_wall_before_hitting_player(self):
        self.set_array("st", (5, 7), 600)
        self.set_array("x", 2, 96)
        self.set_array("y", 2, 64)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        for _ in range(3):
            self.projectile_tick()
        self.assertEqual(self.array("fire", 0), 2)
        self.assertEqual(self.array("energy", 2), 100)

    def test_player_shot_continues_independently_of_demon_fire(self):
        self.set_array("fire", 1, 1)
        self.set_array("xf", 1, 120)
        self.set_array("yf", 1, 120)
        self.set_array("xfs", 1, 8)
        self.set_array("cshs", 1, 8)
        self.basic.call("AddEnemy", 64, 64, 13, 448, 1)
        self.projectile_tick()
        self.assertEqual(self.array("xf", 0), 72)
        self.assertEqual(self.array("xf", 1), 128)
        self.assertEqual(self.array("fire", 1), 1)

    def test_inactive_stale_enemy_data_does_not_prevent_spawn(self):
        self.set_array("en", 2, 5)
        self.set_array("xe", 2, 64)
        self.set_array("ye", 2, 64)
        self.basic.call("AddEnemy", 64, 64, 1, 200, 1)
        self.assertEqual(self.basic.globals["addedenemy"], 1)

    def test_returning_generator_preserves_its_native_type(self):
        for sprite, kind in ((595, 4), (695, 6)):
            with self.subTest(sprite=sprite):
                self.basic.call("AddEnemy", 64, 64, 0, sprite, 1)
                enemy = self.basic.globals["addedenemy"]
                self.assertEqual(self.array("te", enemy), kind)
                self.basic.call("RetEnemy", enemy, 1)
                self.assertEqual(self.array("st", 5, 5), sprite + 2000)
                self.set_array("st", (5, 5), 0)

    def test_full_enemy_pool_does_not_allocate_out_of_range(self):
        for enemy in range(1, 81):
            self.set_array("ae", enemy, 1)
        self.basic.call("AddEnemy", 64, 64, 1, 200, 1)
        self.assertEqual(self.basic.globals["addedenemy"], 0)
        self.assertEqual(self.array("ae", 81), 0)

    def test_demon_and_sorcerer_generators_have_positive_health(self):
        for sprite, kind in ((595, 4), (596, 4), (597, 4),
                             (695, 6), (696, 6), (697, 6)):
            with self.subTest(sprite=sprite):
                self.set_array("ae", 1, 0)
                self.basic.call("AddEnemy", 64, 64, 0, sprite, 1)
                self.assertEqual(self.array("te", 1), kind)
                self.assertGreater(self.array("en", 1), 0)
                self.assertIn(self.array("lv", 1), (0, 1, 2))

    def test_enemy_compaction_preserves_projectile_owner(self):
        self.basic.globals.update(cntg=4, dnfire=4)
        for enemy in (2, 4):
            self.set_array("ae", enemy, 1)
            self.set_array("en", enemy, enemy + 10)
            self.set_array("xe", enemy, enemy * 16)
        self.basic.call("SortEnemies")
        self.assertEqual(self.basic.globals["dnfire"], 2)
        self.assertEqual(self.array("xe", 2), 64)
        self.assertEqual(self.array("en", 2), 14)
        self.assertEqual(self.array("ae", 4), 0)

    def test_enemies_ignore_exited_player_and_chase_living_player(self):
        self.basic.globals.update(cntg=1, eini=1, stp=1)
        self.set_array("x", 1, 64)
        self.set_array("y", 1, 80)
        self.set_array("x", 2, 104)
        self.set_array("y", 2, 80)
        self.set_array("start", 2, 30)
        for name, value in (("xe", 96), ("ye", 80), ("ae", 1), ("en", 20),
                            ("te", 3), ("ce", 224)):
            self.set_array(name, 1, value)
        self.basic.call("PutEnemies")
        self.assertEqual(self.array("xe", 1), 88)
        self.assertEqual(self.array("energy", 2), 100)

    def test_enemies_respect_wall_geometry(self):
        self.basic.globals.update(cntg=1, eini=1, stp=1)
        self.set_array("x", 1, 64)
        self.set_array("y", 1, 80)
        self.set_array("start", 2, 30)
        self.set_array("st", (6, 6), 600)
        for name, value in (("xe", 96), ("ye", 80), ("ae", 1), ("en", 20),
                            ("te", 3), ("ce", 224)):
            self.set_array(name, 1, value)
        self.basic.call("PutEnemies")
        self.assertEqual(self.array("xe", 1), 96)

    def test_no_active_player_leaves_enemies_idle(self):
        self.basic.globals.update(cntg=1, eini=1, stp=1)
        self.set_array("start", 1, 30)
        self.set_array("energy", 2, 0)
        for name, value in (("xe", 96), ("ye", 80), ("ae", 1), ("en", 20),
                            ("te", 3), ("ce", 224)):
            self.set_array(name, 1, value)
        self.basic.call("PutEnemies")
        self.assertEqual((self.array("xe", 1), self.array("ye", 1)), (96, 80))

    def test_stage_start_invokes_stopwav_instead_of_defining_label(self):
        stage = (ROOT / "GAUNTLET.BAS").read_text().split("START_STAGE:\n", 1)[1]
        self.assertNotRegex(stage, r"(?im)^\s*StopWAV\s*:")
        self.assertGreaterEqual(len(re.findall(r"(?im)^\s*StopWAV\s*$", stage)), 2)


if __name__ == "__main__":
    unittest.main()
