#!/usr/bin/env python3
"""C2 (NMITIMEN callers): one fresh server session per scenario, ROM O, module kit/lib/c2_nmitimen.lua.

usage: python scenario_c2.py [--only boot,main,...] [--list]
Writes raw/C2_<scenario>_<yyyymmdd>.json (reply, Lua text, ROM identity, state check). Edits nothing outside mesen2-results/.
"""
import argparse
import datetime
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
LABELS_O = os.path.join(BASEROM, "artifacts", "labels", "iog-original.mlb")
ST = os.path.join(BASEROM, "rebuilt", "states")
RAW = os.path.join(RESULTS, "raw")
DATE = datetime.date.today().strftime("%Y%m%d")
NMI = 33528

S01R = os.path.join(ST, "orig_S01r_south-cape-ready.mss")
S14 = os.path.join(ST, "orig_S14_ramp-scene.mss")
CH0E = os.path.join(ST, "orig_C1_chest-0E.mss")
CH1D = os.path.join(ST, "orig_C1_chest-1D-fanfare.mss")

# NMI state is sampled at the entry of these routines (decimal PRG offsets, db-us/names keys)
AT = ("{RunActors_Normal=248565, RunActors_CutsceneOnly=249087, RunActors_OverlayOnly=249198, AdhocVramDma=39096, "
      "RadarScreenSetup=229567, GlobalInputHandler=229376, CheckWarpAndChest=173533, CheckSceneTransition=252392}")

# Input helper shared by the Lua bodies: pulse(n, first, period, buttons, hold_frames, ...) -> table or nil
PRESS = """
D = {}
local function press(n, first, period, btn, len)
  if n < first then return nil end
  local m = (n - first) % period
  if m < len then return btn end
  if m == len then return {} end
  return nil
end
"""

# name -> dict(state=None for a cold boot, frames, lua=<c2.run options as Lua text>, desc)
SCEN = {
    # cold boot, no input: boot logos, title screen
    "boot": dict(state=None, frames=700, desc="cold boot (power), no input: boot logos and title",
                 opts="probe=true"),
    # cold boot, then Start pulses at the title (title start handler, diary scene)
    "boot_start": dict(state=None, frames=1500, desc="cold boot, Start pulses from frame 480: title start handler, diary scene",
                       opts="probe=true, input=function(n) return press(n, 480, 60, {'start'}, 2) end"),
    # same boot again: determinism
    "boot_repeat": dict(state=None, frames=700, desc="cold boot repeat (determinism)", opts="probe=true"),
    "main": dict(state=S01R, frames=600, desc="South Cape, main loop, walk right/left",
                 opts="probe=true, input=function(n) if n>=30 and n<130 then return {'right'} elseif n>=130 and n<230 then return {'left'} elseif n==230 then return {} end end"),
    "warp_itory": dict(state=S01R, frames=500, desc="scene change $01 -> $15 (sceneNext poke at frame 2)",
                       opts="probe=true, tick=function(n) if n==2 then kit.w16(0x0642,0x15) end end"),
    "warp_church": dict(state=S01R, frames=500, desc="scene change to $08 (church; dialogue box opens at once)",
                        opts="probe=true, tick=function(n) if n==2 then kit.w16(0x0642,0x08) end end"),
    "warp_diary": dict(state=S01R, frames=500, desc="scene change to $FA (diary menu)",
                       opts="probe=true, tick=function(n) if n==2 then kit.w16(0x0642,0xFA) end end"),
    "warp_worldmap": dict(state=S01R, frames=500, desc="scene change to $FE (world map, Mode 7)",
                          opts="probe=true, tick=function(n) if n==2 then kit.w16(0x0642,0xFE) end end"),
    "warp_credits": dict(state=S01R, frames=1200, desc="scene change to $F7 (credits, COP adhoc DMA writer)",
                         opts="probe=true, tick=function(n) if n==2 then kit.w16(0x0642,0xF7) end end"),
    "radar": dict(state=S14, frames=700, desc="radar / map screen, Start pulses (logical $1000, physical Start)",
                  opts="input=function(n) if n<10 then return nil end local m=(n-10)%67; if m==0 or m==1 or m==33 or m==34 then return {'start'} elseif m==2 or m==35 then return {} end end"),
    "pause_town": dict(state=S01R, frames=400, desc="South Cape (non-combat scene, playerFlags bit 3): Start opens the PAUSE overlay",
                       opts="input=function(n) if n<10 then return nil end local m=(n-10)%67; if m==0 or m==1 or m==33 or m==34 then return {'start'} elseif m==2 or m==35 then return {} end end"),
    "pause_town_diag": dict(state=S01R, frames=120, desc="diagnostic: why Start does not open the pause overlay in South Cape",
                            opts="input=function(n) if n==12 or n==13 then return {'start'} elseif n==14 then return {} end end, tick=function(n,S) if n>=11 and n<=17 then D[#D+1]=string.format('n=%d cur=%04X held=%04X mask=%04X pflags=%04X sceneNext=%04X', n, kit.r16(0x0656), kit.r16(0x0658), kit.r16(0x065A), kit.r16(0x09AE), kit.r16(0x0642)) end end"),
    "inventory": dict(state=S14, frames=520, desc="inventory, Select pulses (logical $2000, physical Select)",
                      opts="input=function(n) if n<10 then return nil end local m=(n-10)%130; if m==0 or m==1 or m==70 or m==71 then return {'select'} elseif m==2 or m==72 then return {} end end"),
    "darkspace": dict(state=S01R, frames=500, desc="Dark Space entry $01 -> $E6",
                      opts="probe=true, tick=function(n) if n==2 then kit.w16(0x1014,232); kit.w16(0x1016,128) end end, input=function(n) if n==40 then return {'up'} end end"),
    "chest_herb": dict(state=CH0E, frames=420, desc="Herb chest, scene $0E, no fanfare",
                       opts="tick=function(n) if n==15 then kit.w16(0x1014,80); kit.w16(0x1016,456) end end, input=function(n) if n==30 then return {'up'} elseif n==250 then return {} end end"),
    "chest_fanfare": dict(state=CH1D, frames=700, desc="Blue Block chest, scene $1D, fanfare (music change in game)",
                          opts="tick=function(n) if n==15 then kit.w16(0x1014,112); kit.w16(0x1016,136) end end, input=function(n) if n>=200 and n<260 then return {'up'} elseif n%20==5 or n%20==6 then return {'a'} else return {} end end"),
}


def lua_text(sc):
    return PRESS + "\n" + f"c2.run{{frames={sc['frames']}, nmi={NMI}, at={AT}, adhoc=true, {sc['opts']}, "\
        "final=function(S) local st=emu.getState(); return {k=st['cpu.k'], pc=st['cpu.pc'], sp=st['cpu.sp'], scene=kit.r16(0x0644), frame=st['frameCount'], dbr=st['cpu.dbr'], diag=D} end}"


def run(name):
    sc = SCEN[name]
    m = Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"])
    out = {"scenario": name, "desc": sc["desc"], "date": DATE}
    try:
        out["serverInfo"] = m.server_info
        out["status"] = m.call("get_server_status")
        cold = sc["state"] is None
        r = m.call("load_rom", path=ROM_O, **({"paused": True} if cold else {}))
        out["rom"] = r.get("rom")
        if cold:
            out["boot"] = r.get("boot")
        else:
            m.call("pause")
        m.call("load_labels", path=LABELS_O, replace=True)
        out["nmiLabel"] = m.call("get_label_address", label="NmiHandler")
        if not cold:
            out["stateFile"] = os.path.basename(sc["state"])
            out["stateLoad"] = m.call("load_state_file", path=sc["state"])
            emu = m.call("get_emulator_state")
            out["stateAtLoad"] = emu.get("cpu") if isinstance(emu, dict) else emu
        code = lua_text(sc)
        out["lua"] = code
        kw = dict(frames=sc["frames"], includes=["gaia_kit", "c2_nmitimen"], turbo=True, maxLog=300, name="c2_nmitimen")
        if cold:
            kw["fromReset"] = "power"
        reply = m.run_script_checked(code, **kw)
        out["reply"] = reply
    finally:
        m.close()
    path = os.path.join(RAW, f"C2_{name}_{DATE}.json")
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1)
    return out, path


def summary(out):
    rep = out["reply"]
    res = rep.get("result") or {}
    print(f"== {out['scenario']}: {out['desc']}")
    print("  stop", rep.get("stopReason"), "frames", rep.get("framesAdvanced"), "control", res.get("control"), "final", res.get("final"))
    for k, e in sorted((res.get("writes") or {}).items()):
        print("  W", k, {x: e[x] for x in ("n", "first", "last", "scene", "pc24", "alias", "hw0", "hw1", "prev") if x in e})
    for k, e in sorted((res.get("entries") or {}).items()):
        print("  E", k, {x: e[x] for x in ("n", "first", "last", "scene", "retBank") if x in e})
    for p in res.get("probes") or []:
        print("  P", p)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    if a.list:
        for k, v in SCEN.items():
            print(k, "-", v["desc"])
        sys.exit(0)
    names = [n for n in (a.only.split(",") if a.only else SCEN) if n]
    for n in names:
        o, p = run(n)
        summary(o)
        print("  ->", p)
