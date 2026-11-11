#!/usr/bin/env python3
"""FR23 area-trial helpers (server 0.6.0, ROM O): reuses fr22_lib / fr21_lib / fr20_lib with the result prefix FR23 and the Lua include fr23_kit
(which pulls fr22_kit, fr21_kit and fr20_kit).

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR23_*` states). Nothing here edits the baserom.
Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr20_lib as L  # noqa: E402
from fr20_lib import *  # noqa: E402,F401,F403
from a_common import RAW, BASEROM, STATE_DIR, stamp  # noqa: E402,F401

L.PREFIX = "FR23"
PREFIX = "FR23"

SKIP = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR23_{name}.mss")


def run(m, info, name, state, lua, frames, shot=None, pre=None):
    return L.run(m, info, name, state, lua, frames, includes=("fr23_kit",), shot=shot, pre=pre)


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state` with the fr23 kit loaded. P as in fr20_kit.lua; `hooks` is raw Lua appended into the table
    (for example `onSample=fr22.drive{...}`); `extra` is Lua text placed before the visit call."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={L.lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def spawn(tx, ty):
    """warpDestX/Y bytes for a spawn on player tile (tx, ty): the override stores x,y + (8, 16) as the actor position."""
    x, y = tx * 16, ty * 16
    return [[0x64C, x & 255], [0x64D, x >> 8], [0x64E, y & 255], [0x64F, y >> 8]]


def spawn_px(x, y):
    """warpDestX/Y bytes for a spawn at pixel (x, y) (the value the scene's warp row would store)."""
    return [[0x64C, x & 255], [0x64D, x >> 8], [0x64E, y & 255], [0x64F, y >> 8]]


def short_actors(res, key="actors0", names=None):
    nm = res.get(key + "_named") or []
    raw = res.get(key) or []
    out = []
    for a, b in zip(nm, raw):
        if a["file"] in SKIP:
            continue
        out.append(f"{a['file']}@{a['line']}({a['x']},{a['y']})pc{b['pc']:04X}")
    return out


def count_files(res, key="actors0"):
    from collections import Counter
    nm = res.get(key + "_named") or []
    return Counter(a["file"] for a in nm if a["file"] not in SKIP)


def show_rec(res, limit=40):
    rows = res.get("rec") or []
    return "\n".join("   REC " + json.dumps(r, separators=(",", ":")) for r in rows[:limit])
