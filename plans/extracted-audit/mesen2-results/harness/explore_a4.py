#!/usr/bin/env python3
"""List the LIVE actors (walked from the list head $56, in list order) with HP, stats pointer and extended flags after entering a scene.

usage: explore_a4.py [scene_hex] [frames]       (default scene 3F, 346 frames from the South Cape state)
Read the extracted source first (scene_actors, enemy_stats_table); use this only to confirm what a slot holds at runtime."""
import sys

from a_common import S01R, open_session, actor_table

scene = int(sys.argv[1], 16) if len(sys.argv) > 1 else 0x3F
frames = int(sys.argv[2]) if len(sys.argv) > 2 else 346

m, info = open_session()
try:
    m.call("load_state_file", path=S01R)
    m.poke(0x0AA2, 0x77)
    m.poke(0x0AA3, 0x77)
    m.poke(0x0642, scene)
    m.call("advance_frame", frames=frames)
    print("scene", hex(m.u16(0x644)), "px,py", m.u16(0x1014), m.u16(0x1016), "hp", m.u16(0x0ACE), "scroll", m.u16(0x09A2), m.u16(0x09A4))
    for a in actor_table(m):
        s = a["slot"]
        hp = m.u16(0x10026 + s)
        stp = m.u16(0x10020 + s)
        ext = m.u16(0x1002A + s)
        ondeath = m.u16(0x11004 + s)
        print(f"slot {s:04X} entry {a['entry']:06X} f10 {a['f10']:04X} f12 {a['f12']:04X} x {a['x']:4d} y {a['y']:4d} hp {hp:3d} stats {stp:04X} ext {ext:04X} onDeath {ondeath:04X} spr {a['spr']:04X}")
finally:
    m.close()
