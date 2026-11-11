#!/usr/bin/env python3
"""FR21 area-trial helpers (server 0.6.0, ROM O): reuses fr20_lib (session, H1, visit, summarize, actor decoding) with the result prefix FR21
and the Lua include fr21_kit (item pokes, tile read, change-only recorder).

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR21_*` states). Nothing here edits the baserom.
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

L.PREFIX = "FR21"
PREFIX = "FR21"


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR21_{name}.mss")


def run(m, info, name, state, lua, frames, shot=None, pre=None):
    return L.run(m, info, name, state, lua, frames, includes=("fr21_kit",), shot=shot, pre=pre)


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state` with the fr21 kit loaded. P as in fr20_kit.lua; `hooks` is raw Lua appended into the table
    (for example `onSample=fr21.drive{...}`); `extra` is Lua text placed before the visit call."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={L.lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def save_tmp(m, name, meta=None, note="FR21 disposable trial state"):
    """Save the current emulator state as a disposable `tmp_FR21_<name>.mss` (with sidecar)."""
    p = tmp_state(name)
    m.call("save_state_file", path=p, note=note, meta=meta or {})
    return p


def brief(r, files=(), keys=None, limit=14):
    """Compact result: end scene, flag diff, execs, masks, change rows without dmf-only noise, snap summaries for the named actor files."""
    out = [f"== {r['tag']} scene={r['scene']}->{r['sceneEnd']} d36={r['d36']} ctl36={r.get('ctl36')} mask0={r['mask0']:04X} mask1={r['mask1']:04X} dmf1={r['dmf1']:04X} pos={r['pos']}"]
    out.append("   flags arrival>end " + json.dumps(L.flag_diff(r["flags0"], r["flags1"])) + "  execs " + json.dumps(r.get("execs")))
    rows = []
    for x in r.get("rec") or []:
        ks = [k for k in x if k != "n" and (keys is None or k in keys)]
        if ks:
            rows.append({k: x[k] for k in ["n"] + ks})
    out.append("   REC " + json.dumps(rows[:limit], separators=(",", ":")) + (f" (+{len(rows) - limit} more)" if len(rows) > limit else ""))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        out.append(f"   snap n={k}: " + "; ".join(f"{a['file']}@({a['x']},{a['y']}) w{b['wait']} f{b['f10']:04X}" for a, b in zip(nm, v) if a["file"] in files))
    return "\n".join(out)


def show_rec(res, limit=40):
    rows = res.get("rec") or []
    return "\n".join("   REC " + json.dumps(r, separators=(",", ":")) for r in rows[:limit])
