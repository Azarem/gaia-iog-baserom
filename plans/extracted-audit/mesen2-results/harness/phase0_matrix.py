"""Phase 0 matrix (plan H0, H1, H3, H4): runs against both ROMs and writes raw/phase0_matrix_<date>.json.

usage: python phase0_matrix.py [--out DIR]
Uses the same flags the Cursor entry `mesen2-mcp-dev` uses. Read-only for the baserom: writes only under
mesen2-results/raw and rebuilt/states (screenshots, traces, one scratch state).
"""
import argparse, datetime, json, os, re, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mcp_client import Mesen

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
RES = os.path.join(ROOT, "plans", "extracted-audit", "mesen2-results")
LIB = os.path.join(RES, "kit", "lib")
ROMS = {
    "O": os.path.join(ROOT, "rebuilt", "Illusion of Gaia.smc"),
    "R": os.path.join(ROOT, "rebuilt", "Illusion of Gaia - Rebuilt.smc"),
}
LABELS = {"O": os.path.join(ROOT, "artifacts", "labels", "iog-original.mlb"),
          "R": os.path.join(ROOT, "artifacts", "labels", "iog-rebuilt.mlb")}
STATES = {"O": os.path.join(ROOT, "rebuilt", "states", "orig_S01r_south-cape-ready.mss"),
          "R": os.path.join(ROOT, "rebuilt", "states", "R-plain_S01r_south-cape-ready.mss")}
NOSIDE = os.path.join(ROOT, "rebuilt", "states", "orig_S01_south-cape-start.mss")

ap = argparse.ArgumentParser()
ap.add_argument("--out", default=os.path.join(RES, "raw"))
args = ap.parse_args()
OUT = {}


def rec(section, key, fn):
    """Run fn, store the value (or the error) under OUT[section][key], print one line."""
    t0 = time.time()
    try:
        v = fn()
        status = "ok"
    except Exception as e:  # noqa: BLE001 - a probe: any failure is data
        v, status = str(e)[:400], "ERR"
    OUT.setdefault(section, {})[key] = {"status": status, "value": v}
    s = json.dumps(v)
    print(f"[{status:3} {time.time()-t0:5.2f}s] {section}/{key}: {s[:230]}")
    return v if status == "ok" else None


def scene(m):
    return m.u16(0x644)


def dismiss_banner(m, tries=12):
    for _ in range(tries):
        if m.u8(0xB4) == 0:
            return True
        m.call("set_input", buttons=["a"], frames=2)
        m.call("advance_frame", frames=4)
    return m.u8(0xB4) == 0


with Mesen(args=[f"--mcp-lib-dir={LIB}", f"--mcp-results-dir={args.out}"]) as m:
    m.call("load_rom", path=ROMS["O"]); m.call("pause")
    rec("H0", "capabilities", lambda: {k: v for k, v in m.call("get_capabilities").items()
                                       if k in ("serverVersion", "mesenVersion", "resultsDir", "libDir", "flags", "limits")})
    rec("H0", "toolCount", lambda: len(m.tools()))
    rec("H0", "self_test", lambda: {k: v for k, v in m.call("self_test").items() if k != "results"})

    nmi = {}
    for tag in ("O", "R"):
        info = rec("H0", f"{tag}.load_rom", lambda: m.call("load_rom", path=ROMS[tag])["rom"]); m.call("pause")
        m.call("load_labels", path=LABELS[tag], replace=True)
        rec("H0", f"{tag}.labelNmi", lambda: m.call("get_label_address", label="NmiHandler"))
        m.call("advance_frame", frames=120)
        rec("H0", f"{tag}.scene@121", lambda: f"{scene(m):04X}")
        # boot-logo -> title switch: first 10-frame step where the scene is $FC
        sw = None
        for _ in range(60):
            r = m.call("advance_frame", frames=10)
            if scene(m) == 0xFC:
                sw = r["frame"]
                break
        rec("H0", f"{tag}.titleReached", lambda: {"scene": f"{scene(m):04X}", "frameWithin10": sw})

    # ---------------- H1 state validity ----------------
    m.call("load_rom", path=ROMS["O"]); m.call("pause")
    rec("H1", "O.state_on_O", lambda: m.call("load_state_file", path=STATES["O"])["romCheck"])
    m.call("advance_frame", frames=120)
    rec("H1", "O.validity", lambda: {"scene": f"{scene(m):04X}", "cpu": {k: v for k, v in m.call("get_emulator_state")["cpu"].items() if k in ("K", "SP", "PC")}})
    rec("H1", "Rstate_on_O", lambda: m.call("load_state_file", path=STATES["R"]))
    rec("H1", "nosidecar_on_O", lambda: {k: v for k, v in m.call("load_state_file", path=NOSIDE).items() if k in ("loaded", "hasSidecar", "romCheck")})
    m.call("advance_frame", frames=120)
    rec("H1", "nosidecar.validity", lambda: {"scene": f"{scene(m):04X}"})
    rec("H1", "list_states", lambda: [{k: s.get(k) for k in ("path", "valid", "romSha1")} for s in (m.call("list_states", dir=os.path.join(ROOT, "rebuilt", "states")).get("states") or [])][:8])
    m.call("load_rom", path=ROMS["R"]); m.call("pause")
    rec("H1", "R.state_on_R", lambda: m.call("load_state_file", path=STATES["R"])["romCheck"])
    rec("H1", "Ostate_on_R", lambda: m.call("load_state_file", path=STATES["O"]))

    # ---------------- H3 warps (O) ----------------
    m.call("load_rom", path=ROMS["O"]); m.call("pause")
    for sc in (0x08, 0x15, 0x24, 0xE8, 0xFD, 0xFE, 0x0A):
        m.call("load_state_file", path=STATES["O"])
        m.poke(0x642, sc)
        m.call("advance_frame", frames=300)
        got = scene(m)
        row = {"want": f"{sc:02X}", "got": f"{got:04X}", "next": m.u16(0x642), "x": m.u16(0x1014), "y": m.u16(0x1016),
               "mask": f"{m.u16(0x65A):04X}", "banner": f"{m.u8(0xB4):02X}"}
        row["bannerDismissed"] = dismiss_banner(m)
        m.call("advance_frame", frames=30)
        row["maskAfter"] = f"{m.u16(0x65A):04X}"
        try:
            row["shot"] = m.shot(f"H3_scene_{sc:02X}")
        except Exception as e:  # noqa: BLE001
            row["shot"] = f"ERR {str(e)[:80]}"
        OUT.setdefault("H3", {})[f"quick_{sc:02X}"] = row
        print("H3 quick", row)
    # quick warp from the title screen at several frames
    for fr in (450, 700, 1200):
        m.call("load_rom", path=ROMS["O"]); m.call("pause")
        m.call("advance_frame", frames=fr)
        t_scene, t_mask = scene(m), m.u16(0x65A)
        m.poke(0x642, 1); m.call("advance_frame", frames=300)
        OUT.setdefault("H3", {})[f"quick_from_title@{fr}"] = {"before": f"{t_scene:04X}", "maskBefore": f"{t_mask:04X}", "after": f"{scene(m):04X}"}
        print("H3 quick_from_title", fr, OUT["H3"][f"quick_from_title@{fr}"])
    # recipe on both ROMs from the S01r state
    for tag in ("O", "R"):
        m.call("load_rom", path=ROMS[tag]); m.call("pause")
        m.call("load_state_file", path=STATES[tag])
        rec("H3", f"{tag}.recipe_warp_0A", lambda: {k: v for k, v in m.call("run_recipe", name="warp", args={"scene": 10, "flags": [63]}, frames=1500).items() if k in ("stopReason", "framesAdvanced", "result")})
        rec("H3", f"{tag}.mask_after_recipe", lambda: f"{m.u16(0x65A):04X}")
    m.call("load_rom", path=ROMS["O"]); m.call("pause")
    m.call("load_state_file", path=STATES["O"])
    rec("H3", "O.recipe_warp_0A_noflag", lambda: {k: v for k, v in m.call("run_recipe", name="warp", args={"scene": 10, "flags": []}, frames=900).items() if k in ("stopReason", "framesAdvanced", "result")})
    rec("H3", "O.mask_noflag", lambda: f"{m.u16(0x65A):04X}")
    m.call("advance_frame", frames=60)
    rec("H3", "O.mask_noflag+60", lambda: f"{m.u16(0x65A):04X}")

    # ---------------- H4 controls on both ROMs ----------------
    for tag, other in (("O", "R"), ("R", "O")):
        m.call("load_rom", path=ROMS[tag]); m.call("pause")
        m.call("load_labels", path=LABELS[tag], replace=True)
        m.call("load_state_file", path=STATES[tag])
        nmi_here = m.call("get_label_address", label="NmiHandler")["address"]
        rec("H4", f"{tag}.nmiOffset", lambda: nmi_here)
        other_off = {"O": 33528, "R": 0x967C}[other]
        bps = [
            {"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "count", "name": "w36"},
            {"callbackType": "read", "startAddress": 0x656, "endAddress": 0x657, "memType": "snesWorkRam", "action": "count", "name": "r656"},
            {"callbackType": "exec", "startAddress": nmi_here, "endAddress": nmi_here, "memType": "snesPrgRom", "action": "count", "name": "nmi"},
            {"callbackType": "exec", "startAddress": other_off, "endAddress": other_off, "memType": "snesPrgRom", "action": "count", "name": "otherRomNmiOffset"},
        ]
        m.call("set_breakpoints", breakpoints=bps)
        fa = m.call("advance_frame", frames=120)
        hits = m.call("get_breakpoint_hits")
        rec("H4", f"{tag}.native_counts_120f", lambda: {c["name"]: c["count"] for c in hits["counts"]})
        m.call("clear_breakpoints")
        # access summary calibration
        m.call("load_state_file", path=STATES[tag]); m.call("reset_access_counters")
        m.call("advance_frame", frames=60)
        rec("H4", f"{tag}.access_summary_60f", lambda: [{k: r[k] for k in ("name", "exec", "execBytes", "execFirstByte", "bytesTouched", "verdict")} for r in m.call("get_access_summary", type="prgRom", ranges=[{"name": "nmiFirstByte", "start": nmi_here, "length": 1}, {"name": "nmi16", "start": nmi_here, "end": nmi_here + 15}])["rows"]])
        # Lua controls
        m.call("load_state_file", path=STATES[tag])
        code = f"""
local c = {{w36=0, r656=0, nmi=0, ev=0}}
emu.addMemoryCallback(function() c.w36 = c.w36 + 1 end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
emu.addMemoryCallback(function() c.r656 = c.r656 + 1 end, emu.callbackType.read, 0x656, 0x657, emu.cpuType.snes, emu.memType.snesWorkRam)
emu.addMemoryCallback(function() c.nmi = c.nmi + 1 end, emu.callbackType.exec, {nmi_here}, {nmi_here}, emu.cpuType.snes, emu.memType.snesPrgRom)
emu.addEventCallback(function() c.ev = c.ev + 1 end, emu.eventType.nmi)
kit.onFrame(function(f) if kit.r16(0x36) % 120 == 0 and f > 0 then kit.finish(c) end end)
"""
        rec("H4", f"{tag}.lua_counts", lambda: m.call("run_script", name="h4", includes=["gaia_kit"], code=code, frames=130, turbo=True).get("result"))

    # ---------------- H4 matrix rows on O ----------------
    m.call("load_rom", path=ROMS["O"]); m.call("pause")
    m.call("load_labels", path=LABELS["O"], replace=True)
    m.call("load_state_file", path=STATES["O"])
    rec("H4", "write_word_hp", lambda: (m.poke(0x0ACE, 5), m.u16(0x0ACE))[1])
    rec("H4", "set_cpu_state_XY", lambda: (m.call("set_cpu_state", state={"cpu": {"x": 0x1234, "y": 0x0042}}), {k: m.call("get_emulator_state")["cpu"][k] for k in ("X", "Y")})[1])
    m.call("load_state_file", path=STATES["O"])
    rec("H4", "step_scanline", lambda: {k: v for k, v in m.call("step_scanline", count=10, timeoutMs=3000).items() if k in ("stopReason", "framesAdvanced")})
    rec("H4", "step_cpu_cycles", lambda: {k: v for k, v in m.call("step_cpu_cycles", count=100).items() if k in ("stopReason", "cpu")})
    rec("H4", "get_timing_info", lambda: m.call("get_timing_info"))
    rec("H4", "get_tilemap_size", lambda: m.call("get_tilemap_size", layer=0))
    rec("H4", "get_profiler_data", lambda: str(m.call("get_profiler_data"))[:300])
    rec("H4", "get_execution_trace", lambda: str(m.call("get_execution_trace", maxRowCount=3))[:300])
    rec("H4", "dump_memory_collision", lambda: m.call("dump_memory", type="workRam", start=0x1C000, length=8192, path="H4_collision_layer.bin"))
    rec("H4", "start_trace", lambda: m.call("start_trace", path="H4_trace.txt", pcRanges=[["80:82F8", "80:8380"]], maxLines=40, useLabels=True))
    m.call("advance_frame", frames=2)
    rec("H4", "stop_trace", lambda: m.call("stop_trace"))
    rec("H4", "revert_rom_changes", lambda: m.call("revert_rom_changes"))
    # writeFile + SPC exec callback + events
    m.call("load_state_file", path=STATES["O"])
    code = """
local n, pcs = 0, {}
emu.addMemoryCallback(function(a, v)
  n = n + 1
  if n <= 3 then local st = emu.getState(); pcs[#pcs+1] = string.format('%04X', st['spc.pc'] or -1) end
end, emu.callbackType.exec, 0x0000, 0xFFFF, emu.cpuType.spc, emu.memType.spcRam)
local ok, err = pcall(function() emu.mcp.writeFile('H4_writefile.txt', 'hello\\n', false) end)
kit.onFrame(function(f) if f >= 3 then kit.finish({spcExec = n, pcs = pcs, writeFileOk = ok, writeFileErr = tostring(err), io = tostring(io), os = tostring(os)}) end end)
"""
    rec("H4", "spc_exec+writeFile", lambda: m.call("run_script", name="h4spc", includes=["mesen_kit"], code=code, frames=6, turbo=True).get("result"))
    rec("H4", "writeFile_exists", lambda: os.path.exists(os.path.join(args.out, "H4_writefile.txt")))
    rec("H4", "subscribe_events", lambda: m.call("subscribe_events", types=["breakpointHit", "frameEnd"], frameEvery=30))
    m.call("set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "count", "name": "w36"}])
    m.call("advance_frame", frames=65)
    time.sleep(0.3)
    rec("H4", "event_notifications", lambda: {"count": len(m.notifications), "sample": m.notifications[:3]})
    m.call("clear_breakpoints")
    rec("H4", "screenshots_1frame_apart", lambda: [m.call("take_screenshot", label="H4_a", returnImage=False)["frame"], (m.call("advance_frame", frames=1), m.call("take_screenshot", label="H4_b", returnImage=False)["frame"])[1]])
    # breakpoint conditions (count/log translated to Lua; halting native)
    m.call("load_state_file", path=STATES["O"])
    m.call("set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "count", "name": "w36_even", "condition": "(value & 1) == 0"}])
    m.call("advance_frame", frames=100)
    rec("H4", "count_condition_even", lambda: [(c["name"], c["count"]) for c in m.call("get_breakpoint_hits")["counts"]])
    m.call("clear_breakpoints")
    m.call("set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "break", "condition": "value == 0x55"}])
    rec("H4", "halt_condition_value55", lambda: {k: v for k, v in m.call("advance_frame", frames=400).items() if k in ("stopReason", "framesAdvanced", "frame")})
    rec("H4", "frame36_after_halt", lambda: f"{m.u16(0x36):04X}")
    m.call("clear_breakpoints")
    # rewind LAST: it breaks Lua SPC callbacks for the rest of the session (T-13)
    m.call("load_state_file", path=STATES["O"])
    rec("H4", "rewind_3s", lambda: {"before": (m.call("advance_frame", frames=240), m.u16(0x36))[1], "rewind": str(m.call("rewind", seconds=2))[:200], "after": m.u16(0x36)})
    spc_code = """
local n = 0
emu.addMemoryCallback(function() n = n + 1 end, emu.callbackType.exec, 0x0000, 0xFFFF, emu.cpuType.spc, emu.memType.spcRam)
kit.onFrame(function(f) if f >= 3 then kit.finish({spcExec = n}) end end)
"""
    rec("H4", "spc_exec_after_rewind", lambda: m.call("run_script", name="h4spc2", includes=["mesen_kit"], code=spc_code, frames=8, turbo=True).get("result"))

os.makedirs(args.out, exist_ok=True)
path = os.path.join(args.out, f"phase0_matrix_{datetime.date.today():%Y%m%d}.json")
with open(path, "w", encoding="utf-8") as f:
    json.dump(OUT, f, indent=1, default=str)
print("wrote", path)
