#!/usr/bin/env python3
"""Shared helpers for the B5 sessions (B addendum, 2026-10-30): open the server on ROM O, run a Lua snippet from a state, dump collision maps.

All runs: ROM O only, `run_script` with includes gaia_kit (+ b3_kit, b4_kit when asked). Raw files go to raw/B5/.
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
STATE_DIR = os.path.join(BASEROM, "rebuilt", "states")
RAW5 = os.path.join(RESULTS, "raw", "B5")
os.makedirs(RAW5, exist_ok=True)


def st(name):
    return os.path.join(STATE_DIR, name)


S01R = st("orig_S01r_south-cape-ready.mss")
S13 = st("orig_S13_slope-field.mss")
S14 = st("orig_S14_ramp-scene.mss")
S14B = st("orig_S14b_ir21-ns-ramps.mss")
S14C = st("orig_S14c_ir22-booster.mss")
S14D = st("orig_S14d_dm41-boosters.mss")
S14E = st("orig_S14e_mu62-glide.mss")
S14F = st("orig_S14f_mtA1-ns-ramps.mss")
S14G = st("orig_S14g_scB5-glide.mss")


def open_session():
    lib = os.path.join(RESULTS, "kit", "lib")
    m = Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"])
    info = m.call("load_rom", path=ROM_O)["rom"]
    m.call("pause")
    print("ROM sha1", info["fileSha1"], "crc32", info["fileCrc32"], "size", info["fileSizeBytes"])
    return m


def lua(m, code, state=None, frames=6, includes=("gaia_kit",), name="b5"):
    if state:
        m.call("load_state_file", path=state)
    r = m.call("run_script", code=code, name=name, includes=list(includes), frames=frames, turbo=True, maxLog=60)
    if r.get("stopReason") != "script_done":
        raise RuntimeError(f"script did not finish: {r.get('stopReason')} {r.get('log')}")
    return r["result"], r


def save(name, obj):
    stamp = time.strftime("%Y%m%d")
    p = os.path.join(RAW5, f"{name}_{stamp}.json")
    with open(p, "w", encoding="utf-8") as f:
        json.dump(obj, f, separators=(",", ":"))
    print("wrote", p)
    return p


MAP_DUMP = r"""
local n = 0
kit.onFrame(function()
  n = n + 1
  if n < 2 then return end
  local A = gaia.addr
  local stride, rows = kit.r8(A.collStride), kit.r8(0x0697)
  local w, h = stride * 16, rows * 16
  local out = {}
  for ty = %(y0)d, math.min(%(y1)d, h - 1) do
    local line = {}
    for tx = %(x0)d, math.min(%(x1)d, w - 1) do line[#line + 1] = string.format("%%X", gaia.coll.get(tx, ty) & 15) end
    out[#out + 1] = table.concat(line)
  end
  kit.finish({ rows = out, w = w, h = h, scene = kit.r16(A.sceneCur), f06EF = kit.r16(0x06EF), px = kit.r16(0x1014), py = kit.r16(0x1016) })
end)
"""


def map_dump(m, state, x0, x1, y0, y1):
    r, _ = lua(m, MAP_DUMP % dict(x0=x0, x1=x1, y0=y0, y1=y1), state=state, name="b5_map")
    return r


def shot(m, state, name, frames=30, pre=None):
    """Load state, advance frames, screenshot to raw/screenshots/B5_<name>.png (returns the path)."""
    m.call("load_state_file", path=state)
    if pre:
        pre(m)
    m.call("advance_frame", frames=frames, turbo=True)
    p = os.path.join(RESULTS, "raw", "screenshots", f"B5_{name}.png")
    r = m.call("take_screenshot", path=p)
    print("shot", p, r.get("sizeBytes"))
    return p


def warp_scene(m, scene, flags=(), state=None):
    """Quick warp from S01r with event flags set first (flag n = byte 0x0A00 + (n >> 3), bit n & 7). Returns scenario_b1_census.warp's dict."""
    from scenario_b1_census import warp, set_flag
    m.call("load_state_file", path=state or S01R)
    for n in flags:
        set_flag(m, n)
    return warp(m, scene)


def make_state(m, name, scene, flags, note):
    """Warp (flags first), 30 more frames, save with sidecar, H1 twice (k in $80-$CF, sp in $0100-$01FF, scene unchanged)."""
    path = st(name)
    w = warp_scene(m, scene, flags)
    m.call("advance_frame", frames=30)
    m.call("save_state_file", path=path, note=note, meta={"scene": scene, "flags": list(flags), "form": "Will"})
    checks = []
    for i in range(2):
        m.call("load_state_file", path=path)
        a = m.call("advance_frame", frames=120, turbo=True)
        cpu = a["cpu"]
        ok = (0x80 <= cpu["k"] <= 0xCF) and (0x0100 <= cpu["sp"] <= 0x01FF) and m.u16(0x644) == scene
        checks.append({"run": i + 1, "k": cpu["k"], "sp": cpu["sp"], "scene": m.u16(0x644), "actor": [m.u16(0x1014), m.u16(0x1016)], "ok": ok})
    print(name, "warp", w, "H1", [c["ok"] for c in checks], [c["actor"] for c in checks])
    return {"state": name, "scene": scene, "flags": list(flags), "warp": w, "checks": checks}

S14H = st("orig_S14h_mu62-drained.mss")
S14I = st("orig_S14i_av72-statue-tunnel.mss")
