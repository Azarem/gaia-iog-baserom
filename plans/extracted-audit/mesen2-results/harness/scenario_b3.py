#!/usr/bin/env python3
"""Scenario B3: movement trace on natural terrain (step B3, 2026-10-30).

Loads a state (default S13 = Itory Village slope field, ROM O), runs one scripted-input case per `run_script` with
kit/lib/b3_kit.lua (exec hooks with register + stack snapshots, memory watches with PC, scripted input, per-frame rows),
checks the positive control ($36 writes), repeats every case (rows must be identical) and writes the raw rows to
raw/B3/<suite>_<tag>_<date>.json. Suites are functions returning cases; `--only` filters by case name.

A case: name, frames, input [[frames, [buttons]], ...], hooks [{off: "Name" | int, name, full}], watches [{name, lo, hi, kind}],
pokes [[wramOffset, value, width(1|2)], ...] applied once at the first frame, maxEvents, state (optional override).

usage: scenario_b3.py --suite NAME [--state PATH] [--only TEXT] [--repeat 2] [--show TEXT] [--rom PATH] [--tag O]
"""
import argparse
import bisect
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

TRIAL = r"""
local case = CASE
local PRGT = emu.memType.snesPrgRom
local origCurve, curveBase = {}, nil
local hooks = {}
for _, h in ipairs(case.hooks or {}) do
  local off = h.off
  if type(off) == "string" then off = b3.off[off] end
  if off == nil then error("unknown hook offset " .. tostring(h.off)) end
  hooks[#hooks + 1] = { name = h.name or h.off, off = off, full = h.full }
end
local extra = case.extraWatch or {}
b3.run{
  frames = case.frames, input = b3.schedule(case.input), hooks = hooks, watches = case.watches, maxEvents = case.maxEvents or 1200,
  setup = function()
    local A = gaia.addr
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
    if case.actor then
      local a = case.actor
      kit.w16(a.slot + 0x14, a.x); kit.w16(a.slot + 0x16, a.y)
      if a.set10 then kit.w16(a.slot + 0x10, kit.r16(a.slot + 0x10) | a.set10) end
      if a.clr10 then kit.w16(a.slot + 0x10, kit.r16(a.slot + 0x10) & ~a.clr10) end
    end
    if case.cop then
      local c = case.cop
      local WRm = emu.memType.snesWorkRam
      for i, b in ipairs(c.bytes) do emu.write(0x18000 + i - 1, b, WRm) end
      emu.write(0x18200, 0, WRm)
      kit.w16(c.slot, 0x8000); kit.w16(c.slot + 2, 0x007F)        -- entry word and bank: $7F:8000 (decompressStaging, free after the scene load)
      kit.w16(c.slot + 0x14, c.x); kit.w16(c.slot + 0x16, c.y); kit.w16(c.slot + 8, 0)
      if c.hitbox then
        for i, b in ipairs(c.hitbox) do emu.write(0x8100 + i - 1, b, WRm) end        -- $7E:8100 (tile staging, free after load): the hitbox bank must be $7E, MarkCollisionRect loads DBR from it and reads mapRowStrideL0 absolute
        kit.w16(0x1000C + c.slot, 0x8100); kit.w8(0x10008 + c.slot, 0x7E)
      end
      if c.region then
        local r = c.region
        for ty = r[2], r[4] do for tx = r[1], r[3] do gaia.coll.set(tx, ty, 0) end end
      end
    end
    for _, p in ipairs(case.pokes or {}) do
      local op = p[4]
      if p[3] == 1 then kit.w8(p[1], p[2])
      elseif op == "or" then kit.w16(p[1], kit.r16(p[1]) | p[2])
      elseif op == "andn" then kit.w16(p[1], kit.r16(p[1]) & ~p[2])
      else kit.w16(p[1], p[2]) end
    end
    if case.curvePatch then
      -- decelCurvePtr ($09C2) is a CPU address in bank $81: file offset = 0x10000 + ptr (HiROM); patch the 16 words
      local base = 0x10000 + kit.r16(0x09C2)
      curveBase = base
      for i = 0, 15 do
        origCurve[#origCurve + 1] = { base + i * 2, emu.read(base + i * 2, PRGT), emu.read(base + i * 2 + 1, PRGT) }
        emu.write(base + i * 2, case.curvePatch & 0xFF, PRGT); emu.write(base + i * 2 + 1, case.curvePatch >> 8, PRGT)
      end
    end
  end,
  perFrame = function(n)
    if case.actor and case.actor.move then
      kit.w16(0x1002C + case.actor.slot, case.actor.move[1] & 0xFFFF)
      kit.w16(0x1002E + case.actor.slot, case.actor.move[2] & 0xFFFF)
    end
    if #extra == 0 then return nil end
    local t = {}
    for i, a in ipairs(extra) do t[i] = kit.r16(a) end
    return t
  end,
  final = function()
    for _, o in ipairs(origCurve) do emu.write(o[1], o[2], PRGT); emu.write(o[1] + 1, o[3], PRGT) end
    local allok = true
    for _, o in ipairs(origCurve) do
      if emu.read(o[1], PRGT) ~= o[2] or emu.read(o[1] + 1, PRGT) ~= o[3] then allok = false end
    end
    local out = { scene = kit.r16(0x0644), stride = kit.r8(0x0693), form = kit.r16(0x0AD4), curveBase = curveBase,
                  curveRestored = allok }
    if case.cop then
      local c = case.cop
      out.marker = kit.r8(0x18200)
      local cells = {}
      if c.region then
        local r = c.region
        for ty = r[2], r[4] do for tx = r[1], r[3] do
          local v = gaia.coll.get(tx, ty)
          if v ~= 0 then cells[#cells + 1] = { tx, ty, v } end
        end end
      end
      out.cells = cells
      local ptr, bank = kit.r16(0x1000C + c.slot), kit.r8(0x10008 + c.slot)
      out.hitboxPtr = { bank, ptr }
      if not c.hitbox then
        local hb = {}
        for i = 0, 3 do hb[#hb + 1] = emu.read((bank << 16) | (ptr + i), emu.memType.snesMemory) end
        out.hitbox = hb
      end
      out.entry = { kit.r16(c.slot), kit.r16(c.slot + 2) }
      out.pos = { kit.r16(c.slot + 0x14), kit.r16(c.slot + 0x16) }
    end
    return out
  end,
}
"""

ROUTINES = None


def load_routines():
    global ROUTINES
    with open(os.path.join(BASEROM, "db-us", "names", "bank02.json"), encoding="utf-8") as f:
        d = json.load(f)
    keys = sorted(int(k) for k in d)
    ROUTINES = (keys, [d[str(k)] for k in keys])


def routine_of(off):
    """'Name+0xNN' for a ROM offset (bank-02 names file; nearest key at or below)."""
    if ROUTINES is None:
        load_routines()
    keys, names = ROUTINES
    i = bisect.bisect_right(keys, off) - 1
    if i < 0:
        return f"?{off}"
    return f"{names[i]}+{off - keys[i]:#x}"


def ret_to_off(word):
    """The stack word of a JSR is the address of its last byte (bank 02): the instruction after it is word + 1."""
    return 0x20000 + word + 1


def case(name, frames, input_, hooks, **kw):
    c = {"name": name, "frames": frames, "input": input_, "hooks": hooks}
    c.update(kw)
    return c


# Numeric hook sites (decimal ROM offsets of O, verified as instruction starts by byte read on 2026-10-30)
SITES = {
    "MovProbeJSR": 177251,    # JSR TileProbeMain, moving probe ($1A/$1E just set from actor X, Y - 8)
    "MovType": 177254,        # first instruction after it: A low byte = collision type of the probe cell
    "MovBelowJSR": 177283,    # loc_02B483: JSR MapCellDown ($06/$09 probe cell)
    "MovBelowType": 177293,   # AND #$00FF after ReadCollisionNibble: A low byte = type one row below
    "MovAboveJSR": 177312,    # loc_02B4A0: JSR MapCellUp
    "MovAboveType": 177322,   # A low byte = type one row above
    "StopProbeJSR": 177382,   # JSR TileProbeMain, stopped-latch probe at ($09A2, $09A4)
    "StopType": 177385,
    "EWSnap": 177804,         # STZ playerSpeedEw (|speed| < 3)
    "EWReset": 177869,        # DecelResetCounterEW: STZ decelStepCounter
    "NSSnap": 177963,         # STZ playerSpeedNs (|speed| < 3)
    "NSReset": 178028,        # loc_02B76C: STZ slopeStepCounter
    "FSEast_AfterTR": 176574,   # FindSlopeForEastMove: after JSR ProbeCurrentTR ($1A/$1E = the TR corner pixel)
    "FSEast_Probe2": 176586,    # JSR TileProbeMain, after $1A -= 8
    "FSEast_Type": 176589,      # after it: A low byte = type at the left sample
    "FSWest_AfterTL": 176491,
    "FSWest_Probe2": 176503,    # after $1A += 8
    "FSWest_Type": 176506,
    "WallSlidePushUp": 188512, "WallSlidePushDown": 188587, "AutoAlignYToGrid": 188327, "EastWallPushDown": 186267,
    "EastWallPushUp": 186351, "AutoAlignEW_North": 185023, "AutoAlignNS_East": 187085, "ComputeWallSlidePush": 188406,
    "SnapYNorthCollision": 184508, "SnapYSouthCollision": 185335, "DiagRedirectToNorth": 188313,
    "EastAfter": 186081,      # DispatchEastMove: instruction after JSR FindSlopeForEastMove (flags = probe result)
    "WestAfter": 187273,      # DispatchWestMove: instruction after JSR FindSlopeForWestMove
}


def H(*names, full=False):
    out = []
    for n in names:
        if n in SITES:
            out.append({"off": SITES[n], "name": n, "full": full})
        else:
            out.append({"off": n, "full": full})
    return out


WALK_HOOKS = H("PlayerMovementTick", "DispatchWestMove", "DispatchEastMove", "DispatchNorthMove", "DispatchSouthMove",
               "FindSlopeForWestMove", "FindSlopeForEastMove", "WestRampDescend", "WestRampAscend", "EastRampDown",
               "EastRampUp", "WestRampUp", "WestRampDown", "CancelVerticalPhase", "SlopePhysicsEntry", "SlopeType05Handler",
               "SlopeType0AHandler", "SlopeFlatExit", "ClampSpeeds", "DecelerateEW", "DecelerateNS")


DIR_HOOKS = (H("PlayerMovementTick", "DispatchWestMove", "DispatchEastMove", "DispatchNorthMove", "DispatchSouthMove",
               "FindSlopeForWestMove", "FindSlopeForEastMove", "WestRampDescend", "WestRampAscend", "EastRampDown",
               "EastRampUp", "WestRampUp", "WestRampDown", "SlopePhysicsEntry", "SlopeType05Handler",
               "SlopeType0AHandler", "SlopeFlatExit", "ClampSpeeds", "DecelerateEW", "DecelerateNS")
             + H("EastAfter", "WestAfter", "CancelVerticalPhase", "MovType", "StopType", full=True))


def cell(cx, cy):
    return (cx * 16 + 8, cy * 16 + 16)


def suite_dir():
    """OQ-I024-5, OQ-I029-2 (first half), OQ-I032-3: walk onto/off the $05 and $0A stairs in each direction, stop mid-slope, run."""
    cs = []
    p = cell(63, 24)   # open floor at the foot of the $05 stair (west side)
    cs.append(case("W down $05 (left)", 36, [[36, ["left"]]], DIR_HOOKS, maxEvents=1400))
    cs.append(case("E up $05 (right)", 40, [[40, ["right"]]], DIR_HOOKS, place=p, maxEvents=1400))
    cs.append(case("E up $05 then release", 46, [[16, ["right"]], [30, []]], DIR_HOOKS, place=p, maxEvents=1400))
    cs.append(case("W down $05 then release", 52, [[12, ["left"]], [40, []]], DIR_HOOKS, maxEvents=1400))
    q = cell(6, 31)    # open floor left of the $0A stair
    cs.append(case("E down $0A (right)", 46, [[46, ["right"]]], DIR_HOOKS, place=q, maxEvents=1400))
    r = cell(14, 36)   # open floor at the foot of the $0A stair
    cs.append(case("W up $0A (left)", 46, [[46, ["left"]]], DIR_HOOKS, place=r, maxEvents=1400))
    cs.append(case("E up $05 run", 40, [[2, ["right"]], [3, []], [35, ["right"]]], DIR_HOOKS, place=cell(60, 24), maxEvents=1400))
    cs.append(case("W down $05 run", 40, [[2, ["left"]], [3, []], [35, ["left"]]], DIR_HOOKS, maxEvents=1400))
    return cs


def suite_probe():
    """OQ-I024-5: FindSlopeFor{East,West}Move internals (probe pixels, types, result flags) on slope and flat ground."""
    hk = (H("DispatchEastMove", "DispatchWestMove", "FindSlopeForEastMove", "FindSlopeForWestMove", "EastRampDown", "EastRampUp",
            "WestRampUp", "WestRampDown", "WestRampDescend", "WestRampAscend")
          + H("FSEast_AfterTR", "FSEast_Probe2", "FSEast_Type", "FSWest_AfterTL", "FSWest_Probe2", "FSWest_Type", "EastAfter",
              "WestAfter", full=True))
    cs = []
    cs.append(case("P E onto $05", 12, [[12, ["right"]]], hk, place=cell(63, 24), maxEvents=1000))
    cs.append(case("P E onto $0A", 14, [[14, ["right"]]], hk, place=cell(6, 31), maxEvents=1000))
    cs.append(case("P E flat", 8, [[8, ["right"]]], hk, place=cell(58, 28), maxEvents=1000))
    cs.append(case("P W onto $05", 10, [[10, ["left"]]], hk, maxEvents=1000))
    cs.append(case("P W onto $0A", 14, [[14, ["left"]]], hk, place=cell(14, 36), maxEvents=1000))
    cs.append(case("P W flat", 8, [[8, ["left"]]], hk, place=cell(58, 28), maxEvents=1000))
    return cs


S01R = os.path.join(STATE_DIR, "orig_S01r_south-cape-ready.mss")
OPEN = [19, 7, 27, 13]


def suite_diag():
    """OQ-I029-2: the stack word at $05,S in CancelVerticalPhase vs the $24 parked by PlayerMovementTick; the push / align routines."""
    hk = (H("DispatchNorthMove", "DispatchSouthMove", "DispatchEastMove", "DispatchWestMove", "WestRampDescend", "WestRampUp",
            "EastRampDown", "EastRampUp", "WestRampAscend", "WestRampDown")
          + H("PlayerMovementTick", "CancelVerticalPhase", "WallSlidePushUp", "WallSlidePushDown", "AutoAlignYToGrid",
              "EastWallPushDown", "EastWallPushUp", "AutoAlignEW_North", "AutoAlignNS_East", "ComputeWallSlidePush",
              "DiagRedirectToNorth", "SnapYNorthCollision", "SnapYSouthCollision", full=True))
    cs = []
    cs.append(case("D ramp W+down $05", 14, [[14, ["left", "down"]]], hk, maxEvents=900))
    cs.append(case("D ramp W+up $05", 14, [[14, ["left", "up"]]], hk, maxEvents=900))
    cs.append(case("D ramp E+down $0A", 16, [[16, ["right", "down"]]], hk, place=cell(6, 31), maxEvents=900))
    cs.append(case("D ramp E+up $0A", 16, [[16, ["right", "up"]]], hk, place=cell(6, 31), maxEvents=900))
    cs.append(case("D flat W+down", 8, [[8, ["left", "down"]]], hk, place=cell(58, 28), maxEvents=900))
    cs.append(case("D flat W+up", 8, [[8, ["left", "up"]]], hk, place=cell(58, 28), maxEvents=900))
    base = dict(state=S01R, clear=OPEN, place=(344, 176), maxEvents=900)
    for nm, hold, paint in (("E+down $09(24,10)", ["right", "down"], col(24, 0x09)),
                            ("E+up $09(24,10)", ["right", "up"], col(24, 0x09)),
                            ("E+down $06(24,10)", ["right", "down"], col(24, 0x06)),
                            ("E+up $06(24,10)", ["right", "up"], col(24, 0x06)),
                            ("E+down open", ["right", "down"], []),
                            ("E+down $0F(24,10)", ["right", "down"], col(24, 0x0F)),
                            ("E+up $0F(24,10)", ["right", "up"], col(24, 0x0F))):
        cs.append(case("D room " + nm, 44, [[44, hold]], hk, paint=paint, **base))
    wb = dict(state=S01R, clear=OPEN, place=(X(26), Y(10)), maxEvents=900)
    for nm, hold, paint in (("W+down $06(22,10)", ["left", "down"], col(22, 0x06)),
                            ("W+up $06(22,10)", ["left", "up"], col(22, 0x06)),
                            ("W+down $09(22,10)", ["left", "down"], col(22, 0x09)),
                            ("W+up $09(22,10)", ["left", "up"], col(22, 0x09)),
                            ("W+down $0F(22,10)", ["left", "down"], col(22, 0x0F))):
        cs.append(case("D room " + nm, 44, [[44, hold]], hk, paint=paint, **wb))
    return cs


def col(cx, v):
    return [[cx, r, v] for r in range(7, 14)]


def X(cx):
    return cx * 16 + 8


def Y(cy):
    return cy * 16 + 16


def suite_decel():
    """OQ-I032-1 / OQ-I032-2: decel reset paths and ClampSpeeds, flat ground (S13 open floor, cells 49..63 x 24..27)."""
    hk = H("SlopeFlatExit", "ClampSpeeds", "DecelerateEW", "DecelerateNS", "EWSnap", "EWReset", "NSSnap", "NSReset", full=True)
    f = cell(57, 26)
    cs = []
    for nm, key in (("N", "up"), ("S", "down"), ("W", "left"), ("E", "right")):
        pl = cell(57, 26) if key in ("left", "right") else cell(57, 25 if key == "down" else 27)
        cs.append(case("run " + nm + " then release", 52, [[2, [key]], [3, []], [14, [key]], [33, []]], hk, place=pl, maxEvents=1000))
    # poked speeds, no input: default curve (value 1 at steps 7 and 15), then a patched curve (3 at every step)
    for nm, ew, ns in (("EW=+5", 5, 0), ("EW=-5", -5 & 0xFFFF, 0), ("NS=+5", 0, 5), ("NS=-5", 0, -5 & 0xFFFF)):
        cs.append(case("poke " + nm + " default curve", 34, [[34, []]], hk, place=f, pokes=[[0x09B2, ew, 2], [0x09B4, ns, 2], [0x09B6, 5, 2]], maxEvents=600))
    for nm, ew, ns in (("EW=+3", 3, 0), ("EW=-3", -3 & 0xFFFF, 0), ("NS=+3", 0, 3), ("NS=-3", 0, -3 & 0xFFFF)):
        cs.append(case("poke " + nm + " curve=3", 6, [[6, []]], hk, place=f, curvePatch=3,
                       pokes=[[0x09B2, ew, 2], [0x09B4, ns, 2], [0x09B6, 5, 2], [0x09B8, 4, 2]], maxEvents=300))
    # ClampSpeeds: NS above the maximum with EW nonzero / zero (max 9: clamp to 8)
    for nm, ew, ns in (("EW=+5 NS=+12", 5, 12), ("EW=0 NS=+12", 0, 12), ("EW=+5 NS=-12", 5, -12 & 0xFFFF), ("EW=0 NS=-12", 0, -12 & 0xFFFF),
                       ("EW=+12 NS=+12", 12, 12)):
        cs.append(case("clamp " + nm, 12, [[12, []]], hk, place=f, pokes=[[0x09B2, ew, 2], [0x09B4, ns, 2]], maxEvents=300))
    return cs


def suite_pub():
    """OQ-I045-3: writes to the player actor's $14/$16 (WRAM $1014-$1017) with PCs during diagonal and straight moves."""
    hk = H("PlayerMovementTick", "DispatchWestMove", "DispatchEastMove", "DispatchNorthMove", "DispatchSouthMove", "CancelVerticalPhase")
    w = [{"name": "W14", "lo": 0x1014, "hi": 0x1017, "kind": "write"}]
    f = cell(57, 26)
    cs = []
    for nm, hold in (("W+down", ["left", "down"]), ("E+up", ["right", "up"]), ("W", ["left"]), ("S", ["down"])):
        cs.append(case("pub flat " + nm, 6, [[6, hold]], hk, place=f, watches=w, maxEvents=400))
    cs.append(case("pub ramp W+down $05", 6, [[6, ["left", "down"]]], hk, watches=w, maxEvents=400))
    cs.append(case("pub idle", 4, [[4, []]], hk, place=f, watches=w, maxEvents=400))
    # readers of $14/$16 between the publish (D00E / D015) and the controller rewrite (B3A9 / B3B3): do the vertical probes read the published value?
    wr = w + [{"name": "R14", "lo": 0x1014, "hi": 0x1017, "kind": "read"}]
    cs.append(case("pub reads flat W+down", 3, [[3, ["left", "down"]]], hk, place=f, watches=wr, maxEvents=800))
    cs.append(case("pub reads flat E+up", 3, [[3, ["right", "up"]]], hk, place=f, watches=wr, maxEvents=800))
    cs.append(case("pub reads flat S", 3, [[3, ["down"]]], hk, place=f, watches=wr, maxEvents=800))
    cs.append(case("pub reads flat N", 3, [[3, ["up"]]], hk, place=f, watches=wr, maxEvents=800))
    cs.append(case("pub reads ramp W+down $05", 3, [[3, ["left", "down"]]], hk, watches=wr, maxEvents=800))
    return cs


def suite_iframe():
    """OQ-I047-1: iframeCounter ($7F:1028 = WRAM $11028) and Flags10 bit $0080 vs movement."""
    hk = H("PlayerMovementTick", "DispatchEastMove")
    f = cell(52, 26)
    ex = [0x11028, 0x1010]
    cs = []
    cs.append(case("iframe control (none)", 16, [[16, ["right"]]], hk, place=f, extraWatch=ex))
    for nm, cnt, bit in (("+30 bit80", 30, True), ("0 bit80", 0, True), ("-1 bit80", 0xFFFF, True), ("-5 bit80", 0xFFFB, True),
                         ("+30 bitclear", 30, False)):
        pk = [[0x11028, cnt, 2]]
        pk.append([0x1010, 0x0080, 2, "or"] if bit else [0x1010, 0x0080, 2, "andn"])
        cs.append(case("iframe " + nm, 16, [[16, ["right"]]], hk, place=f, pokes=pk, extraWatch=ex))
    for cnt, fr in ((3, 24), (30, 44)):
        pk = [[0x11028, cnt, 2], [0x1010, 0x0080, 2, "or"]]
        cs.append(case(f"iframe +{cnt} bit80 long", fr, [[fr, ["right"]]], hk, place=f, pokes=pk, extraWatch=ex))
    # who reads / writes the counter, with PCs: the controller gate read (LDA iframeCounter,X) versus the decrement
    wc = [{"name": "WC", "lo": 0x11028, "hi": 0x11029, "kind": "write"}, {"name": "RC", "lo": 0x11028, "hi": 0x11029, "kind": "read"}]
    hk2 = H("PlayerMovementTick", "DispatchEastMove", 176798)
    for cnt in (3, 0):
        pk = [[0x11028, cnt, 2], [0x1010, 0x0080, 2, "or"]]
        cs.append(case(f"iframe +{cnt} bit80 gate watch", 6, [[6, ["right"]]], hk2, place=f, pokes=pk, extraWatch=ex, watches=wc, maxEvents=600))
    return cs


def suite_speeds():
    """OQ-I048-5: writers of playerSpeedEw / Ns ($09B2-$09B5) with PCs: flat walks, slopes, runs."""
    hk = H("PlayerMovementTick", "SlopePhysicsEntry", "SlopeFlatExit")
    w = [{"name": "W9B", "lo": 0x09B2, "hi": 0x09B5, "kind": "write"}]
    f = cell(57, 26)
    cs = []
    for nm, key in (("W", "left"), ("E", "right"), ("N", "up"), ("S", "down")):
        cs.append(case("walk flat " + nm, 14, [[14, [key]]], hk, place=f, watches=w, maxEvents=500))
    cs.append(case("walk flat W+down", 14, [[14, ["left", "down"]]], hk, place=f, watches=w, maxEvents=500))
    cs.append(case("walk $05 W", 20, [[20, ["left"]]], hk, watches=w, maxEvents=500))
    cs.append(case("walk $05 E up", 24, [[24, ["right"]]], hk, place=cell(63, 24), watches=w, maxEvents=500))
    cs.append(case("walk $0A E", 24, [[24, ["right"]]], hk, place=cell(6, 31), watches=w, maxEvents=500))
    for nm, key in (("W", "left"), ("E", "right"), ("N", "up"), ("S", "down")):
        pl = f if key in ("left", "right") else cell(57, 25 if key == "down" else 27)
        cs.append(case("run flat " + nm, 22, [[2, [key]], [3, []], [17, [key]]], hk, place=pl, watches=w, maxEvents=500))
    return cs


def suite_fall():
    """OQ-I052-3: PlayerFallFromHeight entered the way awBD_fall_trigger enters it (the trigger writes the player actor's entry
    $00/$02 = &/#* PlayerFallFromHeight and clears $08 / $2A); player Y before the nudge vs after the last pass."""
    hk = H(50297)
    cs = []
    for nm, pl in (("flat (57,26)", cell(57, 26)), ("S13 landing (71,17)", None)):
        pk = [[0x1000, 50297 & 0xFFFF, 2], [0x1002, 50297 >> 16, 2], [0x1008, 0, 2], [0x102A, 0, 2]]
        cs.append(case("fall " + nm, 150, [[150, []]], hk, place=pl, pokes=pk, extraWatch=[0x1010, 0x09AE, 0x10008 + 0x2, 0x065A],
                       maxEvents=50))
    return cs


def suite_shadow():
    """OQ-I048-5: Shadow form (characterForm 2 set before the scene load so PlayerCharacterDef spawns the shimmer actor): Idle / Active
    entries of the shimmer companion while walking flat, running, sliding on a slope, in the scene with form 0 (control)."""
    hk = H(176654, 176671, 176705, 176788, 176781, "SlopePhysicsEntry")
    hk[0]["name"] = "ShimmerInit"; hk[1]["name"] = "ShimmerIdle"; hk[2]["name"] = "ShimmerActive"
    hk[3]["name"] = "FastStrips"; hk[4]["name"] = "SlowStrips"
    w = [{"name": "W9B", "lo": 0x09B2, "hi": 0x09B5, "kind": "write"}]
    f = cell(57, 26)
    base = dict(state=S01R, warp=0x15, maxEvents=800, watches=w, extraWatch=[0x0AD4, 0x0A00])
    cs = []
    cs.append(case("shadow flat walk E (flag #00 as loaded)", 20, [[20, ["right"]]], hk, place=f, form=2, **base))
    base["pokes"] = [[0x0A00, 1, 2, "andn"]]   # per-scene flag #00 cleared (WRAM $0A00 bit 0)
    cs.append(case("shadow flat walk E, flag #00 clear", 20, [[20, ["right"]]], hk, place=f, form=2, **base))
    cs.append(case("shadow flat run E, flag #00 clear", 40, [[2, ["right"]], [3, []], [35, ["right"]]], hk, place=f, form=2, **base))
    cs.append(case("shadow slope W, flag #00 clear", 30, [[30, ["left"]]], hk, place=cell(71, 17), form=2, **base))
    cs.append(case("shadow slope W then release, flag #00 clear", 190, [[20, ["left"]], [170, []]], hk, place=cell(71, 17), form=2, **base))
    cs.append(case("shadow idle, flag #00 clear", 20, [[20, []]], hk, place=f, form=2, **base))
    cs.append(case("will slope W, flag #00 clear (control, form 0)", 30, [[30, ["left"]]], hk, place=cell(71, 17), form=0, **base))
    return cs


def suite_wcorner():
    """Extra scope: reach the WestRampUp both-corners-solid branch (loc_02DA3F = 186943, mirror of EastRampDown's loc_02D8F4) with a
    $05 stair rising to the east against a $0F wall. Search over stair length, wall column and start phase."""
    hk = H("WestRampUp", 186943, 187002, 187010, "PlayerMovementTick", 188782)
    hk[1]["name"] = "WCorner"; hk[2]["name"] = "SnapWestSouthBrWall"; hk[3]["name"] = "SnapWestNorthTrWall"; hk[5]["name"] = "ApplyMovementDeltas"
    hk[1]["full"] = True; hk[5]["full"] = True
    clear = [14, 3, 34, 17]
    cs = []

    def wall(cx, r0=3, r1=16):
        return [[cx, r, 0x0F] for r in range(r0, r1)]

    stairs = {
        "up3 (24,12)(25,11)(26,10)": [[24, 12, 5], [25, 11, 5], [26, 10, 5]],
        "up2 (25,11)(26,10)": [[25, 11, 5], [26, 10, 5]],
        "up1 (26,10)": [[26, 10, 5]],
        "flat3 (24..26,10)": [[24, 10, 5], [25, 10, 5], [26, 10, 5]],
        "up5 (22,14)(23,13)(24,12)(25,11)(26,10)": [[22, 14, 5], [23, 13, 5], [24, 12, 5], [25, 11, 5], [26, 10, 5]],
    }
    for sn, cells in stairs.items():
        top = min(c[1] for c in cells)
        for wc in (27, 28):
            for (x0, y0) in ((344, 192), (345, 194), (344, 200), (350, 180), (360, 176)):
                if sn.startswith("up5"):
                    x0 -= 40
                    y0 += 32
                cs.append(case(f"WC {sn} wall{wc} X{x0} Y{y0}", 60, [[60, ["right"]]], hk, state=S01R, clear=clear, place=(x0, y0),
                               paint=cells + wall(wc), maxEvents=300, ctlOptional=True))
    return cs


def suite_wcorner2():
    """Phase sweep for the WestRampUp corner branch: a single $05 at (24,10) (or a short stair) with a $0F wall column right behind it,
    start X 340..347, start Y 168..191 (the geometry that reaches EastRampDown's corner for $0A in B2)."""
    hk = H("WestRampUp", 186943, 187002, 187010)
    hk[1]["name"] = "WCorner"; hk[2]["name"] = "SnapWestSouthBrWall"; hk[3]["name"] = "SnapWestNorthTrWall"
    cs = []
    for wc in (25, 26):
        wall = [[wc, r, 0x0F] for r in range(6, 14)]
        for x0 in (340, 342, 344, 346):
            for y0 in range(168, 192, 2):
                cs.append(case(f"WC2 $05(24,10) wall{wc} X{x0} Y{y0}", 30, [[30, ["right"]]], hk, state=S01R, clear=OPEN, place=(x0, y0),
                               paint=[[24, 10, 5]] + wall, maxEvents=120, ctlOptional=True))
    return cs


def suite_pair():
    """OQ-16, OQ-I029-5, OQ-I033-4: the $06 / $09 pair patterns of CheckActorOnSpecialTile (tile_collision_physics) with a NON-PLAYER actor.
    Actor: an existing NPC (slot $10C0) with Flags10 bit $0008 forced and a movement delta written to moveScratch1/2 ($7F:002C/$002E + slot)
    before every frame. Exits of CheckActorOnSpecialTile are traced (SEC = pattern matched, CLC = no pattern)."""
    hk = H(250486, 250357, 251656, 251776, 251784)
    for h, nm in zip(hk, ("AMWC", "AM", "CheckSpecial", "SpecialSEC", "SpecialCLC")):
        h["name"] = nm
    slot = 0x10C0
    P = (76, 15)
    ax, ay = P[0] * 16 + 9, P[1] * 16 + 17        # probe pixel (ax - 8, ay - 16) = (1217, 241): not tile aligned, cell (76, 15)
    pats = {
        "none": [],
        "$06 P + diag (1,1)": [[76, 15, 6], [77, 16, 6]],
        "$06 P only": [[76, 15, 6]],
        "$06 P + right": [[76, 15, 6], [77, 15, 6]],
        "$06 P + below": [[76, 15, 6], [76, 16, 6]],
        "$06 P + anti-diag (1,-1)": [[76, 15, 6], [77, 14, 6]],
        "$00 P, $09 right+below": [[77, 15, 9], [76, 16, 9]],
        "$00 P, $09 right only": [[77, 15, 9]],
        "$00 P, $09 below only": [[76, 16, 9]],
        "$09 P + right+below": [[76, 15, 9], [77, 15, 9], [76, 16, 9]],
        "$00 P, $06 right+below": [[77, 15, 6], [76, 16, 6]],
    }
    moves = {"E": (2, 0), "W": (-2, 0), "S": (0, 2), "N": (0, -2), "E+S": (2, 2)}
    cs = []
    for pn, paint in pats.items():
        for mn, mv in moves.items():
            cs.append(case(f"pair [{pn}] move {mn}", 12, [[12, []]], hk, clear=[74, 12, 80, 19], paint=paint,
                           actor=dict(slot=slot, x=ax, y=ay, set10=0x0008, move=list(mv)),
                           extraWatch=[slot + 0x14, slot + 0x16, slot + 0x10, 0x1002C + slot, 0x1002E + slot], maxEvents=200))
    # control: bit $0008 NOT set (ApplyMovement, no collision, no special-tile test)
    cs.append(case("pair control bit0008 clear [$06 P + diag] move E+S", 12, [[12, []]], hk, clear=[74, 12, 80, 19],
                   paint=pats["$06 P + diag (1,1)"], actor=dict(slot=slot, x=ax, y=ay, clr10=0x0008, move=[2, 2]),
                   extraWatch=[slot + 0x14, slot + 0x16, slot + 0x10, 0x1002C + slot, 0x1002E + slot], maxEvents=200))
    return cs


COP_PAINT = [0x02, 0x0B]                                  # COP #$0B MarkSolidHere (no operands)
COP_RTL_STORE = lambda v: [0xA9, v, 0x00, 0x8F, 0x00, 0x82, 0x7F, 0x6B]   # LDA #v (m=0); STA $7F8200; RTL


def cop_program(paint, probe):
    """$7F:8000: [COP #$0B] [COP #$13 &taken] LDA #1 STA $7F8200 RTL ; taken: LDA #2 STA $7F8200 RTL  (probe) or just the paint + RTL."""
    prog = list(COP_PAINT) if paint else []
    if probe:
        taken = 0x8000 + len(prog) + 4 + len(COP_RTL_STORE(1))
        prog += [0x02, 0x13, taken & 0xFF, taken >> 8] + COP_RTL_STORE(1) + COP_RTL_STORE(2)
    else:
        prog += [0x6B]
    return prog


def suite_cop():
    """OQ-24 / OQ-25 with real COP execution: a forged actor script in WRAM ($7F:8000, free after the scene load) is entered as the actor's
    entry (the ops are COP #$0B MarkSolidHere and COP #$13 BranchIfSolidHere, operand formats from db-us/copdef.json and
    docs/cop/families/collision_paint.md). X = D = slot is set by the actor dispatcher. Slot $10C0 is an existing NPC."""
    hk = H(34934, 35244, 45727, 45867, 46139)
    for h, nm in zip(hk, ("MarkSolidHere", "BranchIfSolidHere", "MarkCollisionRect", "AdvanceMapY", "TileCollisionQuery")):
        h["name"] = nm
    slot = 0x10C0
    cs = []
    # OQ-25: a 2 x 2 rectangle (hitbox [-8, -16, 2, 2]: X offset byte F8, Y offset byte F0) whose first tile is (tx0, ty0)
    def rect_case(name, tx0, ty0, region):
        x = tx0 * 16 + 8 + 8       # actor X + (-8) = left edge of tile tx0 + 8 ... first tile column tx0
        y = ty0 * 16 + 16 + 0      # actor Y + (-16) = top edge of tile row ty0
        return case(name, 3, [[3, []]], hk, state=S13, cop=dict(slot=slot, bytes=cop_program(True, False), x=x, y=y,
                    hitbox=[0xF8, 0xF0, 2, 2], region=region), maxEvents=100)
    cs.append(rect_case("cop paint 2x2 at page corner (15,15)", 15, 15, [0, 0, 79, 63]))
    cs.append(rect_case("cop paint 2x2 vertical page edge only (8,15)", 8, 15, [4, 12, 40, 20]))
    cs.append(rect_case("cop paint 2x2 horizontal page edge only (15,3)", 15, 3, [0, 0, 79, 63]))
    cs.append(rect_case("cop paint 2x2 interior (4,4)", 4, 4, [0, 0, 12, 8]))
    cs.append(rect_case("cop paint 2x2 page corner (31,31)", 31, 31, [0, 0, 79, 63]))
    # OQ-24: the actor's own hitbox (natural, from its metasprite header); paint then probe at the same position, Y phase sweep
    for k in range(0, 16, 1):
        cs.append(case(f"cop own-hitbox paint+probe y+{k}", 3, [[3, []]], hk, state=S13,
                       cop=dict(slot=slot, bytes=cop_program(True, True), x=1160, y=304 + k, region=[68, 14, 78, 24]), maxEvents=100))
    for k in range(0, 16, 1):
        cs.append(case(f"cop hitbox-yoff-8 paint+probe y+{k}", 3, [[3, []]], hk, state=S13,
                       cop=dict(slot=slot, bytes=cop_program(True, True), x=1160, y=304 + k, hitbox=[0xF8, 0xF8, 1, 1], region=[68, 14, 78, 24]), maxEvents=100))
    for k in range(0, 16, 1):
        cs.append(case(f"cop own-hitbox paint+probe x+{k}", 3, [[3, []]], hk, state=S13,
                       cop=dict(slot=slot, bytes=cop_program(True, True), x=1160 + k, y=304, region=[68, 14, 78, 24]), maxEvents=100))
    cs.append(case("cop own-hitbox probe only y+0 (control)", 3, [[3, []]], hk, state=S13,
                   cop=dict(slot=slot, bytes=cop_program(False, True), x=1160, y=304, region=[68, 14, 78, 24]), maxEvents=100))
    return cs


def suite_cells():
    """OQ-I032-4: the moving probe of SlopePhysicsEntry on a $06 / $09 cell: which neighbouring cell (below, then above) decides the slope handler.
    A column x = 24 is painted (rows 10, 11, 12 = above, probe cell, below; the probe pixel (392, 176) reads row 11), the EW speed word is forced to 2 so that the moving branch runs."""
    hk = H("SlopePhysicsEntry", "MovType", "MovBelowJSR", "MovBelowType", "MovAboveJSR", "MovAboveType", "SlopeType05Handler",
           "SlopeType0AHandler", "SlopeFlatExit", full=True)
    cs = []
    vals = {"0": 0x00, "5": 0x05, "A": 0x0A, "F": 0x0F}
    for t in (0x06, 0x09):
        for above, below in (("0", "0"), ("5", "0"), ("0", "5"), ("A", "0"), ("0", "A"), ("5", "A"), ("A", "5"), ("5", "5"), ("A", "A"),
                             ("F", "5"), ("5", "F")):
            paint = [[24, 10, vals[above]], [24, 11, t], [24, 12, vals[below]]]
            cs.append(case(f"cells ${t:02X} above={above} below={below}", 2, [[2, []]], hk, state=S01R, clear=OPEN, place=(X(24), Y(10) + 8),
                           paint=paint, pokes=[[0x09B2, 2, 2]], maxEvents=60))
    return cs


def suite_explore():
    """Plain walks from S13: which routines run per action (hold direction N frames)."""
    cs = []
    for name, seq in (("left40", [[40, ["left"]]]), ("down30", [[30, ["down"]]]), ("up20", [[20, ["up"]]]),
                      ("right30", [[30, ["right"]]])):
        cs.append(case("S13 " + name, sum(f for f, _ in seq) + 6, seq, WALK_HOOKS, maxEvents=1500))
    return cs


SUITES = {k[6:]: v for k, v in list(globals().items()) if k.startswith("suite_")}


def run_case(m, c, state):
    m.call("load_state_file", path=c.get("state", state))
    if c.get("form") is not None:
        m.poke(0x0AD4, c["form"])
    if c.get("warp"):
        from scenario_b1_census import warp
        w = warp(m, c["warp"])
        if not w["ok"]:
            raise RuntimeError(f"warp to {c['warp']:#x} failed: {w}")
    code = TRIAL.replace("CASE", lua_literal(c))
    r = m.call("run_script", code=code, name="b3_trace", includes=["gaia_kit", "b3_kit"], frames=c["frames"] + 8,
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


def show_rows(res):
    ev_by_n = {}
    for e in res["events"]:
        ev_by_n.setdefault(e[0], []).append(e)
    for fr in res["frames"]:
        n = fr[0]
        # events tagged n-1 ran in the frame whose end state is row n
        names = ">".join(e[1] for e in ev_by_n.get(n - 1, []))
        print(f"  f{n:03d} x={fr[1]:5d} y={fr[2]:4d} sEw={fr[3]:3d} sNs={fr[4]:3d} f10={fr[5]:04X} f9AE={fr[6]:04X} "
              f"c6={fr[7]} c8={fr[8]} c6C6={fr[9]:04X} | {names}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--suite", required=True)
    ap.add_argument("--rom", default=DEFAULT_ROM)
    ap.add_argument("--tag", default="O")
    ap.add_argument("--state", default=S13)
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    ap.add_argument("--repeat", type=int, default=2)
    ap.add_argument("--only", default=None)
    ap.add_argument("--hits", default=None, help="print only the cases that logged this event name")
    ap.add_argument("--show", default=None, help="print per-frame rows of the cases whose name contains this text")
    args = ap.parse_args()
    lib = os.path.join(RESULTS, "kit", "lib")
    cases = SUITES[args.suite]()
    if args.only:
        cases = [c for c in cases if args.only in c["name"]]
    os.makedirs(os.path.join(args.out, "B3"), exist_ok=True)
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=args.rom)["rom"]
        m.call("pause")
        print("ROM", info["path"], "sha1", info["fileSha1"], "crc32", info["fileCrc32"], "size", info["fileSizeBytes"])
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
            if args.hits and not any(e[1] == args.hits for e in res["events"]):
                out_cases.append({"case": c, "result": res})
                continue
            print(f"{c['name']:40s} start=({fr[0][1]},{fr[0][2]}) end=({fr[-1][1]},{fr[-1][2]}) ctl36={res['ctl36']} "
                  f"events={len(res['events'])}{' TRUNC' if res.get('truncated') else ''} counts={counts(res)}")
            if args.show and args.show in c["name"]:
                show_rows(res)
            out_cases.append({"case": c, "result": res})
        stamp = time.strftime("%Y%m%d")
        out = os.path.join(args.out, "B3", f"{args.suite}_{args.tag}_{stamp}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump({"tag": args.tag, "rom": info, "state": args.state, "repeat": args.repeat, "suite": args.suite,
                       "cases": out_cases}, f, separators=(",", ":"))
        print("wrote", out)
        errs = [l for l in m.stderr_lines if "rror" in l]
        if errs:
            print("stderr errors:", errs[:3])


if __name__ == "__main__":
    main()
