#!/usr/bin/env python3
"""FR24 area-trial helpers (server 0.6.0, ROM O): reuses fr23_lib / fr22_lib / fr21_lib / fr20_lib with the result prefix FR24 and the Lua include
fr24_kit (which pulls fr23_kit, fr22_kit, fr21_kit, fr20_kit, gaia_kit).

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR24_*` states). Nothing here edits the baserom.
Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr20_lib as L  # noqa: E402
import fr23_lib as L23  # noqa: E402
from fr23_lib import *  # noqa: E402,F401,F403
from a_common import RAW, BASEROM, STATE_DIR, stamp  # noqa: E402,F401

L.PREFIX = "FR24"
PREFIX = "FR24"


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR24_{name}.mss")


def run(m, info, name, state, lua, frames, shot=None, pre=None):
    return L.run(m, info, name, state, lua, frames, includes=("fr24_kit",), shot=shot, pre=pre)


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state` with the fr24 kit loaded. P as in fr20_kit.lua; `hooks` is raw Lua appended into the table
    (for example `onSample=fr22.drive{...}`); `extra` is Lua text placed before the visit call."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={L.lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def rec_lua(items):
    """items: list of (name, addr, bit_or_None, size) -> Lua table text for fr22.drive rec."""
    out = []
    for name, addr, bit, size in items:
        s = f"{{name='{name}',addr=0x{addr:04X}"
        if bit:
            s += f",bit=0x{bit:X}"
        if size == 2:
            s += ",size=2"
        out.append(s + "}")
    return "{" + ",".join(out) + "}"


def flagrec(n, name=None):
    return (name or f"f{n:02X}", 0x0A00 + (n >> 3), 1 << (n & 7), 1)


STD_REC = [("mask", 0x065A, None, 2), ("dlg", 0x09EC, 0x2000, 2), ("sc", 0x0644, None, 2)]


def trial(m, info, name, scene, state=None, set_=None, pre=None, post=None, tp=None, settle=300, shot=None, snaps=(), execs=None,
          rec=None, every=None, adv=True, at=None, use=None, **kw):
    """One scene visit from `state` (default S01r). rec: list of flagrec/STD tuples; every: raw Lua `function(R, n) ... end`;
    at: raw Lua text of a table body `[n]=function(R,n) ... end,...`; use: raw Lua table text for fr22.drive `use`."""
    state = state or S01R
    items = list(STD_REC) + list(rec or [])
    parts = [f"rec={rec_lua(items)}", f"snaps={L.lit(list(snaps))}", f"adv={'true' if adv else 'false'}"]
    if every:
        parts.append(f"every={every}")
    if at:
        parts.append(f"at={{{at}}}")
    if use:
        parts.append(f"use={use}")
    hooks = "onSample=fr22.drive{ " + ", ".join(parts) + " }"
    return visit(m, info, name, state, scene=scene, set=set_ or [], pre=pre, post=post, teleport=tp, settle=settle, watch=False, hooks=hooks,
                 shot=shot, execs=execs, frames=settle + 1400, **kw)


def show(r, rec_limit=30):
    print(summarize(r))
    print("   actors0 files:", dict(count_files(r, "actors0")))
    if [a["file"] for a in (r.get("actors0_named") or [])] != [a["file"] for a in (r.get("actors1_named") or [])]:
        print("   actors1 files:", dict(count_files(r, "actors1")))
    if r.get("execs"):
        print("   execs", json.dumps({k: v for k, v in r["execs"].items()}, separators=(",", ":")))
    print("   REC", json.dumps((r.get("rec") or [])[:rec_limit], separators=(",", ":")))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"] not in SKIP))
