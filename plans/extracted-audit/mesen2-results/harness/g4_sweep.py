#!/usr/bin/env python3
"""G4 scene sweep: warp to every scene id from the S10 state and watch the stores to statsPtr ($7F0020,X) and the knockback tier ($7F101C,X).

Runs the kit function g4.sweep (kit/lib/g4_kit.lua) in chunks of CHUNK scenes (one run_script per chunk, state reloaded before each chunk; inside a chunk every
scene starts from the same savestate). A scene that derails the CPU ends the chunk (`crashedAt`); the next chunk starts after it. Then the exec counters of
every `STA $statsPtr,X` site of extracted/ (decimal tags of `rg "STA \\$statsPtr"`) are read from the server; they accumulate over the whole session.
The per-chunk replies are merged into raw/G4_sweep_all.json.

usage: python g4_sweep.py [first last]     (default 0 254; scene ids in decimal)
output: raw/G4_sweep_<first>.json per chunk, raw/G4_sweep_sites.json, raw/G4_sweep_all.json, raw/G4_sweep_<first>.txt (written by the Lua side)
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from a_common import open_session, RAW  # noqa: E402

STATE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "rebuilt", "states", "orig_S10_combat-room-will.mss"))
CHUNK = 32
INCLUDES = ["gaia_kit", "a_census", "a_actors", "g1_kit", "g2_kit", "g4_kit"]

# every `STA $statsPtr, X` of extracted/ (the `; {n}` tag of the instruction)
SITES = {
    45614: "CopyActorState restore of the destination pointer", 249703: "InitActorFromSceneData raw index", 249854: "InitActorFromSceneData resolve",
    51722: "hit_switch row 46", 53392: "slider_glide counter", 53811: "slider_glide counter", 53857: "slider_glide counter",
    53903: "slider_glide counter", 53949: "slider_glide counter", 54432: "ramps counter",
    847810: "sE8_dark_gaia row 55", 848489: "sE8_dark_gaia row 58", 848743: "sE8_dark_gaia row 56", 848960: "sE8_dark_gaia row 57",
    770795: "pyD2_haunt row 4D", 767431: "awB0_zombie row 47", 767739: "awB0_zombie row 48", 767861: "awB0_zombie row 48",
    757738: "gw82_archer row 33", 755955: "gw8A_sand_fanger row 37", 718172: "mu67_vampires row 31", 718181: "mu67_vampires row 69",
    715085: "mu60_plasma_chain row 00", 698887: "dm3D_breakable_wall row 00", 697360: "EnemyInitBasic row 00",
    694919: "ir29_castoth row 64", 696712: "ir29_castoth row 64", 692268: "ir21_switch row 46", 690868: "ec0E_spiney row 08",
    690487: "ec0E_switch row 46", 690410: "ir20_statue row 00", 690332: "ir26_statue row 00", 689521: "ec12_skull_chaser row 11",
    638755: "ec12_aqueduct_enemy row 46", 638167: "ec11_button_voice row 46", 638097: "ec11_aqueduct_blocker row 46",
    633949: "unused_mode7_boss row 57", 634207: "unused_mode7_boss row 56", 637479: "unused_mode7_boss row 55",
    633257: "ec0E_lily row 64", 587869: "sEA_solid_arm row 60", 587886: "sEA_solid_arm row 5F", 587909: "sEA_solid_arm row 60",
    587926: "sEA_solid_arm row 5F", 574520: "pyD6_vader_barrier_lower row 46", 574238: "pyD6_vader_barrier_upper row 46",
    569559: "daC6_snake_panic row 00", 433445: "mu64_switch_spikes row 00", 433395: "mu60_floor_spikes row 00",
    428470: "sp5A_phantom_ribber row 11", 391366: "sg51_statue row 00", 390747: "sg52_blocker_enemy_b row 46",
    390628: "sg52_blocker_enemy_a row 46", 382807: "dm40_trapped_slave row 46", 380966: "dm3F_switch row 46",
    366608: "dc2F_adrift row 01", 324577: "it19_breakable_wall row 00",
}


def main():
    first = int(sys.argv[1]) if len(sys.argv) > 2 else 0
    last = int(sys.argv[2]) if len(sys.argv) > 2 else 254
    m, info = open_session()
    print("rom", info["fileSha1"], info["fileSizeBytes"], info["fileCrc32"])
    st = m.call("load_state_file", path=STATE)
    print("state romCheck", st.get("romCheck"))
    h1 = m.run_script_checked(
        "local c=0 emu.addMemoryCallback(function(a) if (a & 0xFFFF)==0x36 then c=c+1 end end, emu.callbackType.write,0x36,0x36,emu.cpuType.snes,emu.memType.snesWorkRam)"
        " local n=0 kit.onFrame(function() n=n+1 if n==120 then local s=emu.getState() kit.finish({k=s['cpu.k'],sp=s['cpu.sp'],scene=kit.r16(0x644),c36=c}) end end)",
        frames=130, turbo=True, includes=["gaia_kit"], name="g4_h1", maxLog=2)
    print("H1", h1["result"])
    m.call("reset_access_counters")
    merged = {"rows": {}, "other": {}, "tier": {}, "arrived": [], "fails": [], "mismatch": [], "crashed": [], "runs": []}
    start = first
    while start <= last:
        hi = min(start + CHUNK - 1, last)
        m.call("load_state_file", path=STATE)
        code = f"local L={{}} for s={start},{hi} do L[#L+1]=s end\ng4.sweep{{ scenes = L, cap = 60, file = 'G4_sweep_{start:03d}.txt' }}"
        r = m.run_script_checked(code, frames=200000, turbo=True, includes=INCLUDES, name="g4_sweep", maxLog=1, timeoutMs=1500000)
        res = r["result"]
        with open(os.path.join(RAW, f"G4_sweep_{start:03d}.json"), "w") as f:
            json.dump({"lo": start, "hi": hi, "result": res, "stop": r.get("stopReason")}, f, indent=1)
        print(f"chunk {start:3d}-{hi:3d} arrived {res.get('nArrived')} fails [{res.get('fails')}] rows {len(res.get('rowTable', []))} mismatch {res.get('sceneMismatch')} ctl36 {res.get('control36')} resolveExec {res.get('resolveExec')} writesRow {res.get('writesRow')} crashedAt {res.get('crashedAt')}")
        merged["runs"].append({"lo": start, "hi": hi, "arrived": res.get("arrived"), "fails": res.get("fails"), "crashedAt": res.get("crashedAt"),
                               "control36": res.get("control36"), "resolveExec": res.get("resolveExec"), "writesRow": res.get("writesRow")})
        merged["rows"][str(start)] = res.get("rowTable", [])
        merged["other"][str(start)] = res.get("other", [])
        merged["tier"][str(start)] = res.get("tier", [])
        merged["mismatch"] += res.get("sceneMismatch", [])
        if res.get("crashedAt") is not None:
            merged["crashed"].append(res["crashedAt"])
            start = res["crashedAt"] + 1
        else:
            start = hi + 1
    ranges = [{"name": f"{n}:{d}", "start": n, "end": n} for n, d in sorted(SITES.items())]
    sites = m.call("get_access_summary", type="prgRom", ranges=ranges, cdl=False)
    with open(os.path.join(RAW, "G4_sweep_sites.json"), "w") as f:
        json.dump(sites, f, indent=1)
    with open(os.path.join(RAW, "G4_sweep_all.json"), "w") as f:
        json.dump(merged, f, indent=1)
    print("done")
    m.close()


if __name__ == "__main__":
    main()
