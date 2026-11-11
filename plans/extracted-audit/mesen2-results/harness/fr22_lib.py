#!/usr/bin/env python3
"""FR22 area-trial helpers (server 0.6.0, ROM O): reuses fr21_lib / fr20_lib with the result prefix FR22 and the Lua include fr22_kit
(which pulls fr21_kit and fr20_kit).

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR22_*` states). Nothing here edits the baserom.
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

L.PREFIX = "FR22"
PREFIX = "FR22"


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR22_{name}.mss")


def run(m, info, name, state, lua, frames, shot=None, pre=None):
    return L.run(m, info, name, state, lua, frames, includes=("fr22_kit",), shot=shot, pre=pre)


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state` with the fr22 kit loaded. P as in fr20_kit.lua; `hooks` is raw Lua appended into the table
    (for example `onSample=fr21.drive{...}`); `extra` is Lua text placed before the visit call."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={L.lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def save_tmp(m, name, meta=None, note="FR22 disposable trial state"):
    p = tmp_state(name)
    m.call("save_state_file", path=p, note=note, meta=meta or {})
    return p


def show_rec(res, limit=40):
    rows = res.get("rec") or []
    return "\n".join("   REC " + json.dumps(r, separators=(",", ":")) for r in rows[:limit])
