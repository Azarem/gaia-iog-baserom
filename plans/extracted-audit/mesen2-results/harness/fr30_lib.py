#!/usr/bin/env python3
"""FR30 trial helpers (server 0.6.0, ROM O): reuses fr24_lib / fr20_lib with the result prefix FR30 and the Lua include fr30_kit
(which pulls fr24_kit and the earlier kits).

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR30_*` states). Nothing here edits the baserom.
Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr20_lib as L  # noqa: E402
import fr24_lib as L24  # noqa: E402
from fr24_lib import *  # noqa: E402,F401,F403
from a_common import RAW, BASEROM, STATE_DIR, stamp  # noqa: E402,F401

L.PREFIX = "FR30"
PREFIX = "FR30"
CH0E = os.path.join(STATE_DIR, "orig_C1_chest-0E.mss")
CH1D = os.path.join(STATE_DIR, "orig_C1_chest-1D-fanfare.mss")


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR30_{name}.mss")


def run(m, info, name, state, lua, frames, shot=None, pre=None):
    return L.run(m, info, name, state, lua, frames, includes=("fr30_kit",), shot=shot, pre=pre)


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state` with the fr30 kit loaded. P as in fr20_kit.lua; `hooks` is raw Lua appended into the table
    (for example `onSample=fr22.drive{...}`, `final=function(R) ... end`); `extra` is Lua text placed before the visit call."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={L.lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def drive(rec=None, at=None, every=None, snaps=(), use=None, adv=True, gap=None):
    """Lua text of `onSample=fr22.drive{...}`: rec = list of (name, addr, bit, size) tuples, at = raw Lua table body, every = raw Lua function."""
    items = list(L24.STD_REC) + list(rec or [])
    parts = [f"rec={L24.rec_lua(items)}", f"snaps={L.lit(list(snaps))}", f"adv={'true' if adv else 'false'}"]
    if gap:
        parts.append(f"gap={gap}")
    if every:
        parts.append(f"every={every}")
    if at:
        parts.append(f"at={{{at}}}")
    if use:
        parts.append(f"use={use}")
    return "onSample=fr22.drive{ " + ", ".join(parts) + " }"


def flag_of(res, n, key="flags1"):
    """1 or 0 for global flag n in the 40-byte flag hex string `key` of a result."""
    h = res.get(key)
    if not h:
        return None
    return (int(h[(n >> 3) * 2:(n >> 3) * 2 + 2], 16) >> (n & 7)) & 1


def hexbyte(res, addr, key="flags1"):
    h = res.get(key)
    return int(h[(addr - 0x0A00) * 2:(addr - 0x0A00) * 2 + 2], 16) if h else None
