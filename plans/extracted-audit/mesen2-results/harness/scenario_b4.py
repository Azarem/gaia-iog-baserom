#!/usr/bin/env python3
"""Scenario B4: ramps, glide, booster (step B4, 2026-10-30).

One case = one `run_script` (includes gaia_kit, b3_kit, b4_kit) from a loaded state: the case applies an optional placement and pokes at the
first frame, plays a scripted input schedule, hooks ROM offsets (exec) with an actor-slot filter, watches WRAM writes with PC and samples word
columns every frame. Every case runs twice (rows must be identical), the positive control is the write count of $36 (>= frames - 2).
Raw rows: raw/B4/<suite>_<tag>_<date>.json.

A case: name, state (optional), frames, input [[frames, [buttons]], ...], place [x, y] (actor position $1014/$1016, speeds zeroed),
pokes [[wramOffset, value, width(1|2), op(None|"or"|"andn")]], hooks [{name, off, slot, cols}], cols [...], watches [...], clear/paint
(collision cells), maxEvents.

usage: scenario_b4.py --suite NAME [--only TEXT] [--repeat 2] [--show TEXT] [--rom PATH] [--tag O] [--state PATH]
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b2_special_tiles import lua_literal  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
DEFAULT_ROM = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
STATE_DIR = os.path.join(BASEROM, "rebuilt", "states")
S13 = os.path.join(STATE_DIR, "orig_S13_slope-field.mss")
S14 = os.path.join(STATE_DIR, "orig_S14_ramp-scene.mss")
S01R = os.path.join(STATE_DIR, "orig_S01r_south-cape-ready.mss")

TRIAL = r"""
local case = CASE
local A = gaia.addr
b4.run{
  frames = case.frames, input = b3.schedule(case.input or {}), hooks = case.hooks, cols = case.cols, watches = case.watches,
  maxEvents = case.maxEvents or 1500,
  setup = function()
    if case.clear then
      local c = case.clear
      for ty = c[2], c[4] do for tx = c[1], c[3] do gaia.coll.set(tx, ty, 0) end end
    end
    for _, p in ipairs(case.paint or {}) do gaia.coll.set(p[1], p[2], p[3]) end
    if case.place then
      kit.w16(A.playerX, case.place[1]); kit.w16(A.playerY, case.place[2])
      kit.w16(A.speedEw, 0); kit.w16(A.speedNs, 0)
      kit.w16(0x09C6, 0)
      kit.w16(0x09AE, kit.r16(0x09AE) & ~0x1000)
    end
    for _, p in ipairs(case.pokes or {}) do
      local op = p[4]
      if p[3] == 1 then kit.w8(p[1], p[2])
      elseif op == "or" then kit.w16(p[1], kit.r16(p[1]) | p[2])
      elseif op == "andn" then kit.w16(p[1], kit.r16(p[1]) & ~p[2])
      else kit.w16(p[1], p[2]) end
    end
  end,
  final = function()
    local out = { scene = kit.r16(0x0644), stride = kit.r8(0x0693), form = kit.r16(0x0AD4), ability = kit.r16(0x0AA2),
                  px = kit.r16(0x1014), py = kit.r16(0x1016) }
    for _, a in ipairs(case.finalWords or {}) do out[#out + 1] = kit.r16(a) end
    return out
  end,
}
"""

# ---- decimal ROM offsets of O (db-us/names/bank00.json keys unless marked; verified as instruction starts by byte read) ----
OFF = {
    "RampEastWatch": 53973, "RampEastArmed": 54038, "RampEastS2": 54040, "RampEastDisarm": 54063, "RampEastLaunch": 54068,
    "RampWestWatch": 54093, "RampWestArmed": 54152, "RampWestS2": 54154, "RampWestDisarm": 54177, "RampWestLaunch": 54182,
    "RampNorthWatch": 54207, "RampNorthArmed": 54262, "RampNorthS2": 54264, "RampNorthDisarm": 54287, "RampNorthLaunch": 54292,
    "RampSouthWatch": 54317, "RampSouthArmed": 54372, "RampSouthS2": 54374, "RampSouthDisarm": 54397, "RampSouthLaunch": 54402,
    "RampClimbNorthStep": 54577, "RampClimbSouthStep": 54635,
    "RampBeginPlayerControl": 54422, "RampPlayerClimbEast": 54482, "RampPlayerClimbWest": 54517,
    "RampArcDriver": 54720, "RampArcStep": 54769,
    "RestorePlayerControl": 54666,
    "BoosterGate": 51558, "BoosterNear": 51567, "BoostEW": 51575, "BoosterIdle": 51597, "BoosterAfter": 51584,
}

# columns: player actor X, Y, speedEw, speedNs, playerFlags
PCOLS = [0x1014, 0x1016, [0x09B2, True], [0x09B4, True], 0x09AE]
# per-frame columns: X, Y, sEw, sNs, actor flags $10, playerFlags, player entry word, player entry bank, joypad mask, statsPtr, joypadCurrent
FCOLS = [0x1014, 0x1016, [0x09B2, True], [0x09B4, True], 0x1010, 0x09AE, 0x1000, 0x1002, 0x065A, 0x10020, 0x0656]


def case(name, frames, input_, **kw):
    c = {"name": name, "frames": frames, "input": input_}
    c.update(kw)
    return c


def ramp_hooks(side, slot):
    """Hooks of one ramp actor (slot = WRAM offset of the actor = X register value)."""
    s = {"E": "East", "W": "West", "N": "North", "S": "South"}[side]
    out = []
    for nm in ("Watch", "Armed", "S2", "Disarm", "Launch"):
        out.append({"name": f"{side}{nm}", "off": OFF[f"Ramp{s}{nm}"], "slot": slot, "cols": PCOLS + [slot + 0x14]})
    return out


RUN_R = [[2, ["right"]], [3, []]]
RUN_L = [[2, ["left"]], [3, []]]

SCAN = r"""
local ctl = 0
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
local want = { [0xD2D5] = "E", [0xD34D] = "W", [0xD3BF] = "N", [0xD42D] = "S", [0xC966] = "B", [0xD11C] = "GE", [0xD0D4] = "GW", [0xD16D] = "GN", [0xD1B8] = "GS" }
local n = 0
kit.onFrame(function()
  n = n + 1
  if n < 2 then return end
  local rows = {}
  for k = 0, 83 do
    local b = 0x1000 + 0x30 * k
    local e = kit.r16(b)
    local kind = want[e]
    if kind and kit.r8(b + 2) == 0x80 then rows[#rows + 1] = { kind, b, kit.r16(b + 0x14), kit.r16(b + 0x16), kit.r16(b + 0x0E) } end
  end
  kit.finish({ rows = rows, scene = kit.r16(0x0644), ctl = ctl, px = kit.r16(0x1014), py = kit.r16(0x1016) })
end)
"""

_SCAN_CACHE = {}


def scan_slots(m, state):
    """Ramp / booster actors of a state: {kind: [(slotOffset, x, y, $0E)]} (entry words RampEastWatch / RampWestWatch / ... / booster gate)."""
    if state not in _SCAN_CACHE:
        m.call("load_state_file", path=state)
        r = m.call("run_script", code=SCAN, name="b4_scan", includes=["gaia_kit"], frames=4, turbo=True, maxLog=10)["result"]
        out = {}
        for kind, b, x, y, t in r["rows"]:
            out.setdefault(kind, []).append((b, x, y, t))
        out["scene"] = r["scene"]
        _SCAN_CACHE[state] = out
    return _SCAN_CACHE[state]


CELLS = r"""
local rows = {}
local n = 0
kit.onFrame(function()
  n = n + 1
  if n < 2 then return end
  for ty = %d, %d do
    local line = {}
    for tx = %d, %d do line[#line + 1] = string.format("%%02X", gaia.coll.get(tx, ty)) end
    rows[#rows + 1] = string.format("ty%%02d: ", ty) .. table.concat(line, " ")
  end
  kit.finish({ rows = rows })
end)
"""


def dump_cells(m, state, tx0, tx1, ty0, ty1):
    m.call("load_state_file", path=state)
    r = m.call("run_script", code=CELLS % (ty0, ty1, tx0, tx1), name="b4_cells", includes=["gaia_kit"], frames=4, turbo=True, maxLog=10)["result"]
    print(f"collision cells tx {tx0}..{tx1}:")
    for ln in r["rows"]:
        print("  " + ln)


S14b = os.path.join(STATE_DIR, "orig_S14b_ir21-ns-ramps.mss")
S14c = os.path.join(STATE_DIR, "orig_S14c_ir22-booster.mss")
S14d = os.path.join(STATE_DIR, "orig_S14d_dm41-boosters.mss")
S14e = os.path.join(STATE_DIR, "orig_S14e_mu62-glide.mss")
S14f = os.path.join(STATE_DIR, "orig_S14f_mtA1-ns-ramps.mss")
S14g = os.path.join(STATE_DIR, "orig_S14g_scB5-glide.mss")


def suite_cells(m):
    dump_cells(m, S14g, 3, 11, 11, 24)
    return []


def suite_itory(m):
    """Natural run of the Itory slope band to ramp_east (scene $15, type 1): hold left from S13 for 330 frames."""
    sl = scan_slots(m, S13)
    print("S13 ramp actors", sl)
    e = sl["E"][0]
    hk = ramp_hooks("E", e[0])
    cs = [case("I walk left", 330, [[330, ["left"]]], state=S13, hooks=hk, cols=FCOLS, maxEvents=700)]
    return cs


def suite_sweep(m):
    """S14: every ramp_east / ramp_west actor, arrival speed 6, 7, 8 and eight start phases (start X = ramp X -/+ 100 - phase)."""
    sl = scan_slots(m, S14)
    print("S14 ramp actors", {k: v for k, v in sl.items() if k in "EW"})
    cs = []
    for side in "EW":
        for (slot, x, y, t) in sl.get(side, []):
            hk = ramp_hooks(side, slot)
            for sp in (6, 7, 8):
                for ph in range(8):
                    dist = 56 if slot in (0x1120, 0x11B0) else 100
                    sx = x - dist - ph if side == "W" else x + dist + ph
                    sv = sp if side == "W" else (-sp) & 0xFFFF
                    cs.append(case(f"{side}{slot:04X} s{sp} p{ph}", 70, [[70, ["right" if side == "W" else "left"]]], hooks=hk, cols=FCOLS,
                                   place=[sx, y + 16], pokes=[[0x09B2, sv, 2]], maxEvents=200, ctlOptional=False))
    return cs


def suite_ns(m):
    """S14b (scene $21): ramp_south (600, 336, 5 loops) running south from the open rows above the wall, ramp_north (600, 416, 1 loop) running north."""
    sl = scan_slots(m, S14b)
    print("S14b ramp actors", {k: v for k, v in sl.items() if k in "NS"})
    cs = []
    for (slot, x, y, t) in sl.get("S", []):
        hk = ramp_hooks("S", slot) + [{"name": "SStep", "off": OFF["RampClimbSouthStep"], "slot": 0x1000, "cols": PCOLS}]
        for sp in (6, 8):
            cs.append(case(f"S{slot:04X} s{sp}", 90, [[90, ["down"]]], state=S14b, hooks=hk, cols=FCOLS, place=[x, y - 56], pokes=[[0x09B4, sp, 2]], maxEvents=300))
    for (slot, x, y, t) in sl.get("N", []):
        hk = ramp_hooks("N", slot) + [{"name": "NStep", "off": OFF["RampClimbNorthStep"], "slot": 0x1000, "cols": PCOLS}]
        for sp in (6, 8):
            cs.append(case(f"N{slot:04X} s{sp}", 90, [[90, ["up"]]], state=S14b, hooks=hk, cols=FCOLS, place=[x, y + 40], pokes=[[0x09B4, (-sp) & 0xFFFF, 2]], maxEvents=300))
    return cs


def suite_nsclear(m):
    """S14b with the wall cells (36..39, 20..24) cleared in RAM (counterfactual: the loaded layout blocks the player at Y 320, 16 px short of ramp_south).
    Start phases 0..7 at Y 288 + phase, speed 8 down: which phases reach Y == 336 exactly; loop timing of the 5-loop south climb."""
    sl = scan_slots(m, S14b)
    (slot, x, y, t) = sl["S"][0]
    hk = ramp_hooks("S", slot) + [{"name": "SStep", "off": OFF["RampClimbSouthStep"], "slot": 0x1000, "cols": PCOLS}]
    cs = []
    for sp in (6, 8):
        for ph in range(8):
            cs.append(case(f"S{slot:04X} s{sp} p{ph}", 100, [[100, ["down"]]], state=S14b, hooks=hk, cols=FCOLS, clear=[36, 20, 39, 24],
                           place=[x, 288 + ph], pokes=[[0x09B4, sp, 2]], maxEvents=300))
    return cs


def suite_nsa1(m):
    """S14f (scene $A1): ramp_north type 9 (872, 624; 4 loops) from just below, ramp_south type $11 (424, 560; 8 loops) from above, phases 0..7."""
    sl = scan_slots(m, S14f)
    cs = []
    (slot, x, y, t) = sl["N"][0]
    hk = ramp_hooks("N", slot) + [{"name": "NStep", "off": OFF["RampClimbNorthStep"], "slot": 0x1000, "cols": PCOLS}]
    for sp in (6, 8):
        for ph in range(8):
            cs.append(case(f"N{slot:04X} s{sp} p{ph}", 120, [[120, ["up"]]], state=S14f, hooks=hk, cols=FCOLS, place=[x, y + 17 + ph],
                           pokes=[[0x09B4, (-sp) & 0xFFFF, 2]], maxEvents=300))
    (slot, x, y, t) = sl["S"][0]
    hk = ramp_hooks("S", slot) + [{"name": "SStep", "off": OFF["RampClimbSouthStep"], "slot": 0x1000, "cols": PCOLS}]
    for sp in (6, 8):
        for ph in range(8):
            cs.append(case(f"S{slot:04X} s{sp} p{ph}", 120, [[120, ["down"]]], state=S14f, hooks=hk, cols=FCOLS, place=[x, y - 60 - ph],
                           pokes=[[0x09B4, sp, 2]], maxEvents=300))
    return cs


def booster_hooks(slot):
    return [{"name": nm, "off": OFF[k], "slot": slot, "cols": PCOLS} for nm, k in
            (("BGate", "BoosterGate"), ("BNear", "BoosterNear"), ("BBoost", "BoostEW"), ("BIdle", "BoosterIdle"))]


def suite_booster(m):
    """S14c (scene $22): large_ramp_booster at (264, 176). Walk / run west from the east, straight north / south through its column, leave the 48-px box and re-enter."""
    sl = scan_slots(m, S14c)
    print("S14c booster actors", sl.get("B"))
    slot = sl["B"][0][0]
    hk = booster_hooks(slot)
    w = [{"name": "wEw", "lo": 0x09B2, "hi": 0x09B3, "kind": "write", "cols": []}, {"name": "wNs", "lo": 0x09B4, "hi": 0x09B5, "kind": "write", "cols": []}]
    cs = []
    cs.append(case("B walk W", 130, [[130, ["left"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[372, 192], maxEvents=1400))
    cs.append(case("B run W", 110, [[2, ["left"]], [3, []], [105, ["left"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[372, 192], maxEvents=1400))
    cs.append(case("B walk N", 80, [[80, ["up"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[264, 224], maxEvents=1400))
    cs.append(case("B walk S", 80, [[80, ["down"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[264, 150], maxEvents=1400))
    cs.append(case("B run N", 70, [[2, ["up"]], [3, []], [65, ["up"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[264, 224], maxEvents=1400))
    cs.append(case("B run S", 70, [[2, ["down"]], [3, []], [65, ["down"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w, place=[264, 150], maxEvents=1400))
    cs.append(case("B reenter", 260, [[70, ["left"]], [50, ["right"]], [70, ["left"]], [70, ["right"]]], state=S14c, hooks=hk, cols=FCOLS, watches=w,
                   place=[372, 192], maxEvents=1400))
    return cs


GCOLS = FCOLS + [0x1028, 0x10008]


def glide_hooks(side, slot):
    """Trigger hooks: the Y-window passed (compare of the slide axis), X equal, sprite bank ok, animation ok = fire; UnlockPlayerAfterClimb (finish)."""
    o = {"E": (53557, 53565, 53571, 53585), "W": (53485, 53493, 53499, 53513), "S": (53713, 53722, 53731, 53748)}[side]
    out = [{"name": nm, "off": off, "slot": slot, "cols": PCOLS + [0x1028]} for nm, off in zip((side + "Win", side + "Eq", side + "Bank", side + "Fire"), o)]
    out.append({"name": "GUnlock", "off": 53422, "slot": 0x1000, "cols": PCOLS + [0x1028]})
    return out


def suite_gprobe(m):
    sl = scan_slots(m, S14g)
    print("S14g glide triggers", {k: v for k, v in sl.items() if k[0] == "G"})
    gs = {x: sl["GS"][i] for i, x in enumerate(("a", "b", "c"))}
    hk = glide_hooks("S", gs["a"][0])
    cs = []
    slide = [[2, ["down"]], [3, []], [8, ["down"]], [2, ["down", "b"]], [90, ["down"]]]
    cs.append(case("G south slide", 110, slide, state=S14g, hooks=hk, cols=GCOLS, place=[112, 154], pokes=[[0x0AA2, 2, 2, "or"]], maxEvents=400))
    return cs


def suite_gsweep(m):
    """S14g: South triggers (6,14) (8,14), North (6,21) (8,21): lateral X x start-phase sweep with a Psycho Slide through each; controls: walk only, no ability."""
    sl = scan_slots(m, S14g)
    gs = sl["GS"]
    hks = {}
    for (slot, x, y, t) in gs[:2]:
        hks[x] = glide_hooks("S", slot)
    cs = []
    pk = [[0x0AA2, 2, 2, "or"]]
    slideS = [[2, ["down"]], [3, []], [8, ["down"]], [2, ["down", "b"]], [90, ["down"]]]
    for (slot, x, y, t) in gs[:2]:
        for dx in (-4, 4, 12, 20):
            for ph in range(4):
                cs.append(case(f"GS{x} dx{dx:+d} p{ph}", 110, slideS, state=S14g, hooks=hks[x], cols=GCOLS, place=[x + dx, 150 + ph], pokes=pk, maxEvents=400))
    cs.append(case("GS104 control walk", 110, [[110, ["down"]]], state=S14g, hooks=hks[104], cols=GCOLS, place=[112, 154], pokes=pk, maxEvents=400))
    cs.append(case("GS104 control noability", 110, slideS, state=S14g, hooks=hks[104], cols=GCOLS, place=[112, 154], maxEvents=400))
    return cs


def suite_gnorth(m):
    """S14g: North triggers (6,21) (8,21) from below: slide north; fire detected from the player entry bank and the script lock."""
    cs = []
    pk = [[0x0AA2, 2, 2, "or"]]
    slideN = [[2, ["up"]], [3, []], [8, ["up"]], [2, ["up", "b"]], [90, ["up"]]]
    for tx in (6, 8):
        x = tx * 16 + 8
        for dx in (-4, 4, 12):
            for ph in range(4):
                cs.append(case(f"GN{x} dx{dx:+d} p{ph}", 110, slideN, state=S14g, hooks=[{"name": "GUnlock", "off": 53422, "slot": 0x1000, "cols": PCOLS + [0x1028]}],
                               cols=GCOLS, place=[x + dx, 420 + ph], pokes=pk, maxEvents=400))
    return cs


def suite_i030(m):
    """S13 natural stair band (hold left from (1144, 288), 120 frames): MapCellDown / MapCellUp probes of slope_ramp_physics. Column: DP $00 (probe index)."""
    names = [("MovBelowJSR", 177283), ("MovBelowType", 177293), ("MovAboveJSR", 177312), ("MovAboveType", 177322),
             ("Slope05", 177469), ("Slope0A", 177474), ("SlopeFlat", 177488), ("SlopeEntry", 177195)]
    hk = [{"name": n, "off": o, "slot": None, "cols": [0x0000, 0x1014, 0x1016, 0x09B2]} for n, o in names]
    cs = [case("S13 stair left", 120, [[120, ["left"]]], state=S13, hooks=hk, cols=FCOLS, maxEvents=1500)]
    for nm, pl, inp in (("S13 foot walk right", [1000, 432], ["right"]), ("S13 foot walk right-up", [1000, 432], ["right", "up"]),
                        ("S13 top walk down-left", [1144, 288], ["left", "down"]), ("S13 foot run right", [1000, 432], None)):
        sched = [[120, inp]] if inp else [[2, ["right"]], [3, []], [115, ["right", "up"]]]
        cs.append(case(nm, 120, sched, state=S13, hooks=hk, cols=FCOLS, place=pl, maxEvents=1500))
    return cs


def suite_itoryw(m):
    """S13 Itory ramp_west (248, 592, type 1) in its 3-cell pocket: start X 216 + phase, arrival speed 6 and 8 east, 100 frames."""
    sl = scan_slots(m, S13)
    (slot, x, y, t) = sl["W"][0]
    hk = ramp_hooks("W", slot)
    cs = []
    for sp in (6, 8):
        for ph in range(8):
            cs.append(case(f"W{slot:04X} s{sp} p{ph}", 100, [[100, ["right"]]], state=S13, hooks=hk, cols=FCOLS, place=[216 + ph, y + 16],
                           pokes=[[0x09B2, sp, 2]], maxEvents=300))
    return cs


def suite_wspeed(m):
    """ramp_west slot $1090 (x 1000, y 176) in S14: arrival at |speedEw| 6, 7 and 8 (speed poked after placement at X 900, right held)."""
    hk = ramp_hooks("W", 0x1090)
    cs = []
    for sp in (6, 7, 8):
        cs.append(case(f"W speed{sp}", 90, [[90, ["right"]]], hooks=hk, cols=FCOLS, place=[900, 192], pokes=[[0x09B2, sp, 2]], maxEvents=900))
    return cs


def suite_wprobe(m):
    """First look: ramp_west slot $1090 (x 1000, y 176) in S14 from (936, 192): walk and run, 150 frames."""
    hk = ramp_hooks("W", 0x1090)
    cs = []
    cs.append(case("W walk", 150, [[150, ["right"]]], hooks=hk, cols=FCOLS, place=[936, 192], maxEvents=900))
    cs.append(case("W run", 150, RUN_R + [[145, ["right"]]], hooks=hk, cols=FCOLS, place=[936, 192], maxEvents=900))
    return cs


def suite_anim(m):
    """Player animation index ($7F:0028 = 0x1028) and sprite bank ($7F:0008) per frame across one launch of each ramp direction (arrival speed 8)."""
    ac = FCOLS + [0x1028, 0x10008]
    cs = []
    cs.append(case("anim W t3", 90, [[90, ["right"]]], hooks=ramp_hooks("W", 0x1090), cols=ac, place=[900, 192], pokes=[[0x09B2, 8, 2]], maxEvents=300))
    cs.append(case("anim E t3", 90, [[90, ["left"]]], hooks=ramp_hooks("E", 0x1150), cols=ac, place=[1132, 192], pokes=[[0x09B2, (-8) & 0xFFFF, 2]], maxEvents=300))
    sl = scan_slots(m, S14f)
    (slot, x, y, t) = sl["N"][0]
    cs.append(case("anim N t9", 60, [[60, ["up"]]], state=S14f, hooks=ramp_hooks("N", slot), cols=ac, place=[x, y + 17], pokes=[[0x09B4, (-8) & 0xFFFF, 2]], maxEvents=300))
    (slot, x, y, t) = sl["S"][0]
    cs.append(case("anim S t11", 60, [[60, ["down"]]], state=S14f, hooks=ramp_hooks("S", slot), cols=ac, place=[x, y - 60], pokes=[[0x09B4, 8, 2]], maxEvents=300))
    return cs


SUITES = {k[6:]: v for k, v in list(globals().items()) if k.startswith("suite_")}


def run_case(m, c, state):
    m.call("load_state_file", path=c.get("state", state))
    code = TRIAL.replace("CASE", lua_literal(c))
    r = m.call("run_script", code=code, name="b4_trace", includes=["gaia_kit", "b3_kit", "b4_kit"], frames=c["frames"] + 8,
               turbo=True, maxLog=40)
    if r.get("stopReason") != "script_done":
        raise RuntimeError(f"case did not finish: {r.get('stopReason')} {r.get('log')}")
    res = r["result"]
    res["controlOk"] = res.get("ctl36", 0) >= c["frames"] - 2
    if not res["controlOk"] and not c.get("ctlOptional"):
        raise RuntimeError(f"positive control failed: $36 writes {res.get('ctl36')} < {c['frames']}")
    return res


def counts(res):
    out = {}
    for e in res["events"]:
        out[e[1]] = out.get(e[1], 0) + 1
    return out


def landings(res):
    """One summary per launch: launch frame / X / Y, first later frame with $0800 clear (land), travel, arc frames and peak rise."""
    out = []
    fr = res["frames"]
    for e in res["events"]:
        if not e[1].endswith("Launch"):
            continue
        n0 = e[0]
        row0 = next((r for r in fr if r[0] == n0 + 1), None)
        if row0 is None:
            continue
        land = next((r for r in fr if r[0] > n0 + 1 and not r[6] & 0x0800), None)
        arc = [r for r in fr if row0[0] <= r[0] < (land[0] if land else 10 ** 9)]
        out.append({"launch": [e[0], e[3], e[4]], "land": [land[0], land[1], land[2], land[3]] if land else None,
                    "frames": (land[0] - row0[0]) if land else None, "dx": (land[1] - e[3]) if land else None,
                    "dy": (land[2] - e[4]) if land else None, "peakRise": e[4] - min(r[2] for r in arc)})
    return out


def nssummary(res):
    """N/S ramp case: launch frame / X / Y, number of climb-loop iterations seen, locked frames, first free row and travel on Y."""
    fr = res["frames"]
    ls = [e for e in res["events"] if e[1].endswith("Launch")]
    if not ls:
        dis = [e for e in res["events"] if e[1].endswith("Disarm")]
        return f"no launch (disarm events {len(dis)})"
    e = ls[0]
    steps = [x for x in res["events"] if x[1].endswith("Step") and x[0] > e[0]]
    locked = []
    for x in fr:
        if x[0] <= e[0]:
            continue
        if x[6] & 0x800:
            locked.append(x)
        else:
            break
    first = next((x for x in fr if locked and x[0] > locked[-1][0]), None)
    movers = [x for i, x in enumerate(locked) if i and x[2] != locked[i - 1][2]]
    stepf = [x[0] for x in steps]
    gaps = sorted(set(b - a for a, b in zip(stepf, stepf[1:])))
    return (f"launch f{e[0]} ({e[3]},{e[4]}) iterations={len(steps)} lockedFrames={len(locked)} movingFrames={len(movers)} "
            f"stepGaps={gaps} firstFree={(first[1], first[2], first[3], first[4]) if first else None} "
            f"dy={(first[2] - e[4]) if first else None}")


def glidesummary(res):
    """Glide case: frame of the trigger fire (first frame with the script lock and the glide entry bank $80), the position at the fire, the locked
    frames (from the fire to the unlock), the first free frame and the travel."""
    fr = res["frames"]
    fire = next((x for x in fr if x[6] & 0x800 and (x[8] & 255) == 0x80), None)
    if not fire:
        slide = [x for x in fr if x[12] in (0x0C, 0x0D, 0x0F, 0x10, 0x12, 0x13, 0x15, 0x16)]
        return f"no glide (slide anim frames seen {len(slide)}; end {fr[-1][1]},{fr[-1][2]})"
    locked = [x for x in fr if x[0] >= fire[0] and x[6] & 0x800]
    last = locked[-1]
    nxt = next((x for x in fr if x[0] > last[0]), None)
    unl = [e for e in res["events"] if e[1] == "GUnlock"]
    fe = [e for e in res["events"] if e[1].endswith("Fire")]
    return (f"fire f{fire[0]} at ({fire[1]},{fire[2]}) fireHook={'f%d (%d,%d)' % (fe[0][0], fe[0][3], fe[0][4]) if fe else None} "
            f"lockedFrames={len(locked)} last=({last[1]},{last[2]}) unlock={'f%d' % unl[0][0] if unl else None} after=({nxt[1] if nxt else None},{nxt[2] if nxt else None}) "
            f"travel=({last[1] - fire[1]},{last[2] - fire[2]})")


def show_rows(res, c, rng=None, step=1):
    """Per-frame rows of the frames in rng ("a:b"), default the frames that ran a hook other than a plain `*Watch`."""
    ev_by_n = {}
    for e in res["events"]:
        ev_by_n.setdefault(e[0], []).append(e)
    lo, hi = (None, None) if not rng else [int(v) for v in rng.split(":")]
    shown = 0
    for fr in res["frames"]:
        n = fr[0]
        evs = ev_by_n.get(n - 1, [])
        if lo is None:
            if not any(not e[1].endswith("Watch") for e in evs):
                continue
        elif not lo <= n <= hi or (n - lo) % step:
            continue
        shown += 1
        if shown > 70:
            print("  ... (more rows not shown)")
            break
        names = ",".join(f"{e[1]}(x={e[3]})" for e in evs if not e[1].endswith("Watch"))
        print(f"  f{n:03d} x={fr[1]:5d} y={fr[2]:4d} sEw={fr[3]:3d} sNs={fr[4]:3d} f10={fr[5]:04X} f9AE={fr[6]:04X} "
              f"ent={fr[8] & 255:02X}:{fr[7]:04X} msk={fr[9]:04X} sp={fr[10]:5d}"
              + (f" an={fr[12]:02X} bk={fr[13] & 255:02X}" if len(fr) > 13 else "") + f" | {names}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--suite", required=True)
    ap.add_argument("--rom", default=DEFAULT_ROM)
    ap.add_argument("--tag", default="O")
    ap.add_argument("--state", default=S14)
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    ap.add_argument("--repeat", type=int, default=2)
    ap.add_argument("--only", default=None)
    ap.add_argument("--show", default=None, help="print per-frame rows of the cases whose name contains this text")
    ap.add_argument("--range", default=None, help="frames a:b for --show")
    ap.add_argument("--step", type=int, default=1)
    ap.add_argument("--land", action="store_true")
    ap.add_argument("--ns", action="store_true")
    ap.add_argument("--i030", action="store_true")
    ap.add_argument("--gl", action="store_true")
    ap.add_argument("--bst", action="store_true")
    ap.add_argument("--sub", default="B4", help="raw subfolder (B5 sessions use B5)")
    ap.add_argument("--quiet", action="store_true", help="only the grouped summary (group = name before ' p')")
    ap.add_argument("--events", action="store_true", help="print the hook events other than *Watch (first 14 per case)")
    args = ap.parse_args()
    lib = os.path.join(RESULTS, "kit", "lib")
    os.makedirs(os.path.join(args.out, args.sub), exist_ok=True)
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=args.rom)["rom"]
        m.call("pause")
        print("ROM", info["path"], "sha1", info["fileSha1"], "crc32", info["fileCrc32"], "size", info["fileSizeBytes"])
        cases = SUITES[args.suite](m)
        if args.only:
            cases = [c for c in cases if args.only in c["name"]]
        out_cases, reference = [], {}
        for c in cases * args.repeat:
            res = run_case(m, c, args.state)
            key = json.dumps([res["frames"], res["events"]], separators=(",", ":"))
            if c["name"] in reference:
                if reference[c["name"]] != key:
                    raise AssertionError(f"not deterministic: {c['name']}")
                continue
            reference[c["name"]] = key
            fr = res["frames"]
            if not args.quiet:
              print(f"{c['name']:40s} start=({fr[0][1]},{fr[0][2]}) end=({fr[-1][1]},{fr[-1][2]}) ctl36={res['ctl36']} "
                  f"events={len(res['events'])}{' TRUNC' if res.get('truncated') else ''} counts={counts(res)}")
            if args.bst:
                for e in res["events"]:
                    if e[1] in ("BBoost",) or (e[1] in ("wEw", "wNs") and 0xC96F <= (e[4] & 0xFFFF) <= 0xC998):
                        print(f"    f{e[0]:03d} {e[1]:6s} {e[2:] if e[1][0] == 'w' else e[3:8]}")
            if args.i030:
                ev = res["events"]
                rows = [e for e in ev if e[1] in ("MovBelowJSR", "MovBelowType", "MovAboveJSR", "MovAboveType")]
                print("    counts", counts(res))
                for e in rows[:16]:
                    print(f"    f{e[0]:03d} {e[1]:13s} X-reg={e[2]:04X} dp00={e[3]:04X} px={e[4]} py={e[5]}")
                pairs = set()
                last = None
                for e in ev:
                    if e[1] == "MovBelowJSR": last = ("D", e[3])
                    elif e[1] == "MovAboveJSR": last = ("U", e[3])
                    elif e[1] in ("MovBelowType", "MovAboveType") and last:
                        pairs.add((last[0], (e[2] - last[1]) & 0xFFFF)); last = None
                print("    index change after call (dir, X-reg minus $00 before):", sorted((a, f"{b:04X}") for a, b in pairs))
            if args.gl:
                print("    ", glidesummary(res))
            if args.ns:
                print("    ", nssummary(res))
            if args.land:
                for l in landings(res):
                    print("    land", l)
            if args.events:
                for e in [e for e in res["events"] if not e[1].endswith("Watch")][:14]:
                    print(f"    ev f{e[0]:03d} {e[1]:8s} x={e[3]:5d} y={e[4]:4d} sEw={e[5]:3d} f9AE={e[7]:04X}")
            if args.show and args.show in c["name"]:
                show_rows(res, c, args.range, args.step)
            out_cases.append({"case": c, "result": res})
        if args.quiet:
            groups = {}
            for oc in out_cases:
                g = oc["case"]["name"].rsplit(" p", 1)[0]
                res = oc["result"]
                ls = landings(res)
                d = groups.setdefault(g, {"n": 0, "launched": 0, "lx": set(), "land": set(), "arcf": set(), "disarm": 0, "ctl": True})
                d["n"] += 1
                d["launched"] += 1 if ls else 0
                d["disarm"] += counts(res).get(g[0] + "Disarm", 0)
                d["ctl"] &= res["controlOk"]
                for l in ls[:1]:
                    d["lx"].add(l["launch"][1])
                    if l["land"]:
                        d["land"].add((l["land"][1] - l["launch"][1], l["dy"]))
                        d["arcf"].add(l["frames"])
            for g, d in groups.items():
                print(f"{g:16s} cases={d['n']:2d} launched={d['launched']:2d} launchX={sorted(d['lx'])} (dx,dy)first-land={sorted(d['land'])} arcFrames={sorted(d['arcf'])} disarmEvents={d['disarm']} ctl={d['ctl']}")
        stamp = time.strftime("%Y%m%d")
        sfx = "" if not args.only else "_only_" + "".join(ch for ch in args.only if ch.isalnum())
        out = os.path.join(args.out, args.sub, f"{args.suite}_{args.tag}_{stamp}{sfx}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump({"tag": args.tag, "rom": info, "state": args.state, "repeat": args.repeat, "suite": args.suite,
                       "cases": out_cases}, f, separators=(",", ":"))
        print("wrote", out)
        errs = [l for l in m.stderr_lines if "rror" in l]
        if errs:
            print("stderr errors:", errs[:3])


if __name__ == "__main__":
    main()
