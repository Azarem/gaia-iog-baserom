#!/usr/bin/env python3
"""Server 0.5.0 probe: the new features (watchdog, rewind, JSON shapes, events, quick warp, lib dirs)
and edge cases for defect hunting.  Run under a process timeout:

    cd plans/extracted-audit/mesen2-results/harness
    timeout 300 python probe_050.py [--out ../raw]

Writes raw/probe_050_<yyyymmdd>.json. Every row is {status, ms, value|error}.  Only writes under mesen2-results/
and rebuilt/states/ (a throwaway state in rebuilt/states/probe_*.mss is created and deleted).
"""
import argparse
import base64
import datetime
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mcp_client import Mesen, McpError  # noqa: E402

ROOT = r"C:\Work\gaia-iog-baserom"
RES = ROOT + r"\plans\extracted-audit\mesen2-results"
O = ROOT + r"\rebuilt\Illusion of Gaia.smc"
R = ROOT + r"\rebuilt\Illusion of Gaia - Rebuilt.smc"
ST_O = ROOT + r"\rebuilt\states\orig_S01r_south-cape-ready.mss"
ST_R = ROOT + r"\rebuilt\states\R-plain_S01r_south-cape-ready.mss"
ap = argparse.ArgumentParser()
ap.add_argument("--out", default=RES + r"\raw")
ap.add_argument("--sessions", default="12345", help="1 shapes/events/rewind, 2 watchdog, 3 startup flags")
ap.add_argument("--tag", default="", help="suffix of the result file (partial runs)")
args = ap.parse_args()
stamp = datetime.date.today().strftime("%Y%m%d")
out = {}
FLAGS = ["--mcp-lib-dir=" + RES + r"\kit\lib", "--mcp-results-dir=" + args.out]


def short(v, n=400):
    s = json.dumps(v, default=str)
    return s if len(s) <= n else s[:n] + "..."


def rec(sec, key, fn):
    t = time.time()
    try:
        v = fn()
        row = {"status": "ok", "ms": round((time.time() - t) * 1000), "value": v}
    except McpError as e:
        row = {"status": "tool_error", "ms": round((time.time() - t) * 1000), "error": e.payload}
    except Exception as e:  # noqa: BLE001
        row = {"status": "exception", "ms": round((time.time() - t) * 1000), "error": f"{type(e).__name__}: {e}"}
    out.setdefault(sec, {})[key] = row
    print(f"[{row['status']:<10} {row['ms']:>6}ms] {sec}/{key}: {short(row.get('value', row.get('error')), 260)}", flush=True)
    return row


def raw(m, tool, **a):
    """Return the parsed payload even when the server flags an error (for error-shape checks)."""
    err, text, _ = m.raw(tool, **a)
    try:
        data = json.loads(text)
    except Exception:  # noqa: BLE001
        data = text
    return {"isError": err, "data": data}


def boot(m, rom=O, state=ST_O):
    m.call("load_rom", path=rom)
    m.call("pause")
    m.call("load_labels", path=ROOT + (r"\artifacts\labels\iog-original.mlb" if rom == O else r"\artifacts\labels\iog-rebuilt.mlb"), replace=True)
    if state:
        m.call("load_state_file", path=state)


def u16(m, a):
    return m.u16(a)


def session1():
    with Mesen(args=FLAGS) as m:
        boot(m)
        # ---------------- A. JSON shapes (MCP-24, MCP-25, MCP-30)
        rec("A", "read_word", lambda: m.call("read_word", address=0x644, type="workRam"))
        rec("A", "write_word", lambda: m.call("write_word", address=0x0ACE, value=5, type="workRam"))
        rec("A", "write_memory_2", lambda: m.call("write_memory", address=0x0ACE, data=[8, 0], type="workRam"))
        rec("A", "write_memory_6", lambda: m.call("write_memory", address=0x0AB4, data=[1, 2, 3, 4, 5, 6], type="workRam"))
        rec("A", "read_memory_bytes", lambda: m.call("read_memory", address=0x644, length=4, type="workRam", format="bytes"))
        rec("A", "read_memory_hex", lambda: m.call("read_memory", address=0x644, length=4, type="workRam", format="hex"))
        rec("A", "read_memory_words", lambda: m.call("read_memory", address=0x644, length=4, type="workRam", format="words_le"))
        rec("A", "get_label_address", lambda: m.call("get_label_address", label="NmiHandler"))
        rec("A", "get_label_address_unknown", lambda: raw(m, "get_label_address", label="NoSuchLabelXyz"))
        rec("A", "resolve_address", lambda: m.call("resolve_address", address=0x8082F8, type="snesMemory"))
        # ---------------- A2. edge cases of memory tools
        rec("A2", "read_memory_over_limit", lambda: (lambda r: {"isError": r["isError"], "chars": len(str(r["data"])), "head": str(r["data"])[:60]})(raw(m, "read_memory", address=0, length=65537, type="workRam", format="hex")))
        rec("A2", "read_memory_past_end", lambda: raw(m, "read_memory", address=0x1FFFF, length=16, type="workRam", format="bytes"))
        rec("A2", "read_memory_negative", lambda: raw(m, "read_memory", address=-1, length=4, type="workRam", format="bytes"))
        rec("A2", "read_memory_bad_type", lambda: raw(m, "read_memory", address=0, length=4, type="noSuchType", format="bytes"))
        rec("A2", "read_memory_zero_len", lambda: raw(m, "read_memory", address=0, length=0, type="workRam", format="bytes"))
        rec("A2", "write_word_too_big", lambda: raw(m, "write_word", address=0x0ACE, value=70000, type="workRam"))
        rec("A2", "write_memory_empty", lambda: raw(m, "write_memory", address=0x0ACE, data=[], type="workRam"))
        rec("A2", "write_memory_byte_300", lambda: raw(m, "write_memory", address=0x0ACE, data=[300], type="workRam"))
        m.call("revert_rom_changes")
        m.poke(0x0ACE, 0x0007)
        rec("A2", "revert_undoes_wram_write", lambda: (m.call("revert_rom_changes"), f"{m.u16(0x0ACE):04X}")[1])
        rec("A2", "write_word_negative", lambda: raw(m, "write_word", address=0x0ACE, value=-1, type="workRam"))
        rec("A2", "write_prgrom", lambda: raw(m, "write_memory", address=0x8000, data=[0xEA], type="snesPrgRom"))
        rec("A2", "read_after_prgrom_write", lambda: m.call("read_memory", address=0x8000, length=1, type="snesPrgRom", format="bytes"))
        rec("A2", "revert_after_prgrom_write", lambda: m.call("revert_rom_changes"))
        rec("A2", "read_after_revert", lambda: m.call("read_memory", address=0x8000, length=1, type="snesPrgRom", format="bytes"))
        rec("A2", "dump_memory_traversal", lambda: raw(m, "dump_memory", type="workRam", start=0, length=16, path="..\\escape_probe.bin"))
        rec("A2", "dump_memory_absolute", lambda: raw(m, "dump_memory", type="workRam", start=0, length=16, path="C:\\Work\\escape_probe.bin"))
        rec("A2", "screenshot_outside", lambda: raw(m, "take_screenshot", path="C:\\Work\\escape_probe.png", returnImage=False))
        rec("A2", "save_state_outside", lambda: raw(m, "save_state_file", path="C:\\Work\\escape_probe.mss"))
        # ---------------- A3. protocol edge cases
        rec("A3", "unknown_tool", lambda: raw(m, "no_such_tool"))
        rec("A3", "missing_required", lambda: raw(m, "read_memory"))
        rec("A3", "wrong_type_arg", lambda: raw(m, "advance_frame", frames="ten"))
        rec("A3", "negative_frames", lambda: raw(m, "advance_frame", frames=-5))
        rec("A3", "zero_frames", lambda: raw(m, "advance_frame", frames=0))
        rec("A3", "load_rom_missing", lambda: raw(m, "load_rom", path=ROOT + r"\rebuilt\nope.smc"))
        rec("A3", "load_state_missing", lambda: raw(m, "load_state_file", path=ROOT + r"\rebuilt\states\nope.mss"))
        rec("A3", "state_after_failed_load", lambda: m.call("get_emulator_state")["cpu"]["PC"])
        rec("A3", "get_server_status", lambda: m.call("get_server_status"))

        # ---------------- B. breakpoints and events
        rec("B", "halt_alias", lambda: m.call("set_breakpoints", breakpoints=[{"callbackType": "exec", "startAddress": 33528, "endAddress": 33528, "memType": "snesPrgRom", "action": "halt", "name": "nmi_halt"}]))
        rec("B", "halt_alias_advance", lambda: {k: v for k, v in m.call("advance_frame", frames=10).items() if k in ("stopReason", "framesAdvanced", "break")})
        m.call("clear_breakpoints")
        m.call("load_state_file", path=ST_O)
        m.notifications.clear()
        m.call("subscribe_events", types=["breakpointHit", "frameEnd", "stateLoaded", "gamePaused", "gameResumed"], frameEvery=20)
        m.call("set_breakpoints", breakpoints=[
            {"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "count", "name": "w36"},
            {"callbackType": "write", "startAddress": 0x09EC, "endAddress": 0x09EC, "memType": "snesWorkRam", "action": "log", "name": "l09ec", "maxLogged": 3}])
        rec("B", "advance_60_with_count_and_log", lambda: {k: v for k, v in m.call("advance_frame", frames=60).items() if k in ("stopReason", "framesAdvanced")})
        time.sleep(0.3)
        kinds = {}
        for n in m.notifications:
            k = n.get("params", {}).get("event")
            kinds[k] = kinds.get(k, 0) + 1
        rec("B", "event_kinds_count_and_log", lambda: kinds)
        rec("B", "event_samples", lambda: [n["params"] for n in m.notifications if n.get("params", {}).get("event") == "breakpoint_hit"][:3])
        rec("B", "frameEnd_samples", lambda: [n["params"] for n in m.notifications if n.get("params", {}).get("event") == "frame_end"][:3])
        rec("B", "hits", lambda: m.call("get_breakpoint_hits"))
        rec("B", "hits_reset", lambda: m.call("get_breakpoint_hits", reset=True)["counts"] if isinstance(m.call("get_breakpoint_hits", max=1), dict) else None)
        rec("B", "hits_after_reset", lambda: m.call("get_breakpoint_hits"))
        m.call("clear_breakpoints")
        m.notifications.clear()
        rec("B", "bad_memtype", lambda: raw(m, "set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0, "endAddress": 0, "memType": "bogus", "action": "count"}]))
        rec("B", "start_gt_end", lambda: raw(m, "set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 10, "endAddress": 5, "memType": "snesWorkRam", "action": "count"}]))
        rec("B", "bad_condition_count", lambda: raw(m, "set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "count", "condition": "value ==== 5"}]))
        rec("B", "bad_condition_break", lambda: raw(m, "set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "break", "condition": "value ==== 5"}]))
        m.call("clear_breakpoints")
        rec("B", "bad_action", lambda: raw(m, "set_breakpoints", breakpoints=[{"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "explode"}]))
        rec("B", "empty_list", lambda: raw(m, "set_breakpoints", breakpoints=[]))
        # halting breakpoint + event
        m.call("load_state_file", path=ST_O)
        m.notifications.clear()
        m.call("set_breakpoints", breakpoints=[{"callbackType": "exec", "startAddress": 33528, "endAddress": 33528, "memType": "snesPrgRom", "action": "break", "name": "nmi_halt"}])
        rec("B", "halt_advance", lambda: {k: v for k, v in m.call("advance_frame", frames=5).items() if k in ("stopReason", "framesAdvanced", "break")})
        time.sleep(0.3)
        rec("B", "halt_events", lambda: [n["params"] for n in m.notifications])
        rec("B", "hits_after_halt", lambda: m.call("get_breakpoint_hits"))
        m.notifications.clear()
        rec("B", "step_instruction_events", lambda: (m.call("step_instruction", count=3), time.sleep(0.2), [n["params"].get("event") for n in m.notifications])[2])
        m.call("clear_breakpoints")

        # ---------------- C. step tools
        m.call("load_state_file", path=ST_O)
        rec("C", "step_scanline_1", lambda: m.call("step_scanline", count=1))
        rec("C", "step_scanline_300", lambda: m.call("step_scanline", count=300))
        rec("C", "step_scanline_0", lambda: raw(m, "step_scanline", count=0))
        rec("C", "step_scanline_neg", lambda: raw(m, "step_scanline", count=-3))
        rec("C", "step_cpu_cycles_0", lambda: raw(m, "step_cpu_cycles", count=0))
        rec("C", "step_instruction_over", lambda: m.call("step_instruction", count=5, over=True))
        rec("C", "set_cpu_state_flags", lambda: m.call("set_cpu_state", state={"cpu": {"a": 0x1234, "sp": 0x1FF, "ps": 0x24}}))
        rec("C", "set_cpu_state_bad_key", lambda: raw(m, "set_cpu_state", state={"cpu": {"bogus": 1}}))
        m.call("load_state_file", path=ST_O)

        # ---------------- D. access summary and CDL
        m.call("reset_access_counters")
        m.call("advance_frame", frames=60)
        rec("D", "access_summary", lambda: m.call("get_access_summary", type="prgRom", ranges=[
            {"name": "nmi16", "label": "NmiHandler", "length": 16},
            {"name": "nmi_whole", "start": 33528, "end": 33528 + 300},
            {"name": "dead", "start": 0x1F0000, "length": 32}]))
        rec("D", "access_summary_nonzero", lambda: m.call("get_access_summary", type="prgRom", nonzeroOnly=True, ranges=[{"name": "r", "start": 0x8000, "end": 0x9000}]))
        rec("D", "access_summary_bad_label", lambda: raw(m, "get_access_summary", type="prgRom", ranges=[{"name": "x", "label": "NoSuchLabel"}]))
        rec("D", "access_summary_bad_type", lambda: raw(m, "get_access_summary", type="bogus", ranges=[{"name": "x", "start": 0, "length": 4}]))
        rec("D", "access_summary_rangesPath", lambda: raw(m, "get_access_summary", type="prgRom", rangesPath="nonexistent.json"))

        # ---------------- E. scripts
        rec("E", "done_at_load", lambda: m.call("run_script", name="done_load", code="emu.mcp.result({hi=1}); emu.mcp.done()", frames=5))
        rec("E", "kit_finish_at_load", lambda: m.call("run_script", name="kf", includes=["mesen_kit"], code="kit.finish({x=2})", frames=5))
        rec("E", "wramOffset", lambda: m.call("run_script", name="wo", includes=["mesen_kit"], code="kit.finish({a=kit.wramOffset(0x81065A), b=kit.wramOffset(0x7F0001), c=kit.wramOffset(0x7E1234), d=kit.wramOffset(0x80C000), e=kit.wramOffset(0x000036)})", frames=2))
        rec("E", "syntax_error", lambda: raw(m, "run_script", name="se", code="this is not lua", frames=2))
        rec("E", "syntax_error_log", lambda: m.call("get_script_log", name="se", max=10))
        rec("E", "runtime_error", lambda: raw(m, "run_script", name="re", code="kit.onFrame(function() error('boom') end)", includes=["mesen_kit"], frames=3))
        rec("E", "runtime_error_log", lambda: m.call("get_script_log", name="re", max=10))
        rec("E", "unknown_include", lambda: raw(m, "run_script", name="ui", code="emu.mcp.done()", includes=["no_such_module"], frames=2))
        rec("E", "gaia_kit_include", lambda: m.call("run_script", name="gk", includes=["gaia_kit"], code="kit.onFrame(function(f) if f>=2 then kit.finish({scene=iog.state().scene, coll=gaia.coll.get(24,10)}) end end)", frames=6))
        rec("E", "io_os_require", lambda: m.call("run_script", name="ios", code="emu.mcp.result({io=tostring(io), os=tostring(os), req=tostring(require), dofile=tostring(dofile), load=tostring(load), loadstring=tostring(loadstring)}); emu.mcp.done()", frames=2))
        rec("E", "writeFile_traversal", lambda: m.call("run_script", name="wft", code="local a,b=emu.mcp.writeFile('../escape_probe.txt','x'); local c,d=emu.mcp.writeFile('C:/escape_probe.txt','x'); local e,f=emu.mcp.writeFile('sub/dir/ok.txt','y'); emu.mcp.result({a=tostring(a),b=tostring(b),c=tostring(c),d=tostring(d),e=tostring(e),f=tostring(f)}); emu.mcp.done()", frames=2))
        rec("E", "run_until_includes_top", lambda: m.call("run_until", condition={"type": "lua", "expr": "kit.r16(0x36) > 0"}, includes=["mesen_kit"], maxFrames=60))
        rec("E", "run_until_memoryEquals_timeout", lambda: m.call("run_until", condition={"type": "memoryEquals", "address": 0x0ACE, "value": 0xDEAD, "size": 2}, maxFrames=30))
        rec("E", "list_scripts_after", lambda: m.call("list_scripts"))
        rec("E", "load_script_dup", lambda: (m.call("load_script", name="dup", code="x=1"), raw(m, "load_script", name="dup", code="x=2"), m.call("unload_script", name="dup"), raw(m, "unload_script", name="dup"))[1:])
        rec("E", "list_recipes", lambda: [(r["name"], r.get("dir", "")[-30:]) for r in m.call("list_recipes")["recipes"]] if "recipes" in m.call("list_recipes") else m.call("list_recipes"))
        rec("E", "recipe_unknown", lambda: raw(m, "run_recipe", name="no_such_recipe"))

        # ---------------- F. quick warp recipe
        m.call("load_state_file", path=ST_O)
        rec("F", "quick_true_0x15", lambda: m.call("run_recipe", name="warp", args={"scene": 0x15, "quick": True}))
        m.call("load_state_file", path=ST_O)
        rec("F", "auto_quick_0x08", lambda: m.call("run_recipe", name="warp", args={"scene": 0x08}))
        m.call("load_state_file", path=ST_O)
        rec("F", "castle_default", lambda: m.call("run_recipe", name="warp", args={"scene": 0x0A, "flags": [63]}))
        m.call("load_state_file", path=ST_O)
        rec("F", "quick_with_flag63_0A", lambda: m.call("run_recipe", name="warp", args={"scene": 0x0A, "quick": True, "flags": [63]}))
        # from the title
        boot(m, O, None)
        m.call("advance_frame", frames=420)
        rec("F", "title_scene", lambda: f"{u16(m, 0x644):04X}")
        rec("F", "quick_from_title", lambda: m.call("run_recipe", name="warp", args={"scene": 0x01, "quick": True}))

        # ---------------- G. rewind
        boot(m)
        rec("G", "rewind_no_history", lambda: raw(m, "rewind", seconds=2))
        m.call("advance_frame", frames=400)
        rec("G", "rewind_frames_30", lambda: m.call("rewind", frames=30))
        rec("G", "rewind_seconds_1", lambda: m.call("rewind", seconds=1))
        rec("G", "rewind_both_args", lambda: raw(m, "rewind", seconds=1, frames=30))
        rec("G", "rewind_neither", lambda: raw(m, "rewind"))
        rec("G", "rewind_zero", lambda: raw(m, "rewind", frames=0))
        rec("G", "rewind_negative", lambda: raw(m, "rewind", frames=-10))
        rec("G", "rewind_insufficient", lambda: raw(m, "rewind", seconds=1000))
        rec("G", "rewind_insufficient_partial", lambda: raw(m, "rewind", seconds=1000, allowPartial=True))
        rec("G", "rewind_too_far", lambda: raw(m, "rewind", seconds=3600))
        rec("G", "rewind_too_far_partial", lambda: raw(m, "rewind", seconds=3600, allowPartial=True))
        rec("G", "rewind_then_spc", lambda: m.call("run_script", name="spcr", includes=["mesen_kit"], code="local n=0; emu.addMemoryCallback(function() n=n+1 end, emu.callbackType.exec, 0, 0xFFFF, emu.cpuType.spc, emu.memType.spcRam); kit.onFrame(function(f) if f>=3 then kit.finish({spc=n}) end end)", frames=8, turbo=True))
        rec("G", "rewind_then_frame_rate", lambda: {k: v for k, v in m.call("advance_frame", frames=120).items() if k in ("framesAdvanced", "framesPerSecond")})
        rec("G", "rewind_then_state_roundtrip", lambda: (m.call("save_state_file", path=ROOT + r"\rebuilt\states\probe_rw.mss"), m.call("advance_frame", frames=30), m.call("load_state_file", path=ROOT + r"\rebuilt\states\probe_rw.mss"), "ok")[3])
        for ext in (".mss", ".mss.json"):
            try:
                os.remove(ROOT + r"\rebuilt\states\probe_rw" + ext)
            except OSError:
                pass

        # ---------------- H. misc tools
        boot(m)
        rec("H", "get_capabilities", lambda: {k: v for k, v in m.call("get_capabilities").items() if k not in ("tools", "luaFunctions", "lua")})
        rec("H", "capabilities_tool_status", lambda: [t for t in m.call("get_capabilities").get("tools", [])][:5])
        rec("H", "play_input_fps", lambda: {k: v for k, v in m.call("play_input", sequence=[{"frames": 120, "buttons": []}], turbo=True).items() if k in ("framesAdvanced", "framesPerSecond", "stopReason")})
        rec("H", "list_states", lambda: m.call("list_states", dir=ROOT + r"\rebuilt\states"))
        rec("H", "compare_runs_same_rom_slot", lambda: raw(m, "compare_runs", inputFile="nonexistent.json", watch=[{"address": 0x36, "size": 2, "name": "w"}]))
        rec("H", "trace_between_missing_args", lambda: raw(m, "trace_between", startPc=0x8082F8, stopPc=0x808300))
        rec("H", "trace_between", lambda: m.call("trace_between", startPc=0x8082F8, stopPc=0x80831C, path="probe_tb.txt", maxFrames=3, maxLines=20))
        rec("H", "screenshot_returnImage_size", lambda: len(m.raw("take_screenshot", returnImage=True)[1]))
        rec("H", "get_palette_info", lambda: str(m.call("get_palette_info", first=0, count=4))[:200])
        rec("H", "reset_tool", lambda: (m.call("reset"), m.call("advance_frame", frames=5), f"{u16(m, 0x644):04X}")[2])
        rec("H", "self_test", lambda: m.call("self_test"))
        rec("H", "server_status_end", lambda: m.call("get_server_status"))
        for f in ("escape_probe.bin", "escape_probe.png", "escape_probe.mss", "escape_probe.mss.json"):
            try:
                os.remove(os.path.join("C:\\Work", f))
            except OSError:
                pass

def session2():
    with Mesen(args=FLAGS) as m:
        boot(m)
        rec("W", "advance_huge_small_timeout", lambda: raw(m, "advance_frame", frames=200000, timeoutMs=800))
        rec("W", "status_after", lambda: m.call("get_server_status"))
        rec("W", "paused_after_timeout", lambda: m.call("get_emulator_state").get("paused", "n/a"))
        m.call("load_state_file", path=ST_O)
        rec("W", "lua_infinite_loop", lambda: raw(m, "run_script", name="inf", code="while true do end", frames=5, timeoutMs=1000))
        rec("W", "status_after_lua_loop", lambda: m.call("get_server_status"))
        rec("W", "next_call_after_lua_loop", lambda: raw(m, "get_emulator_state"))
        rec("W", "recover_load_state", lambda: raw(m, "load_state_file", path=ST_O))
        rec("W", "advance_after_recover", lambda: {k: v for k, v in raw(m, "advance_frame", frames=10)["data"].items() if k in ("stopReason", "framesAdvanced", "error")} if isinstance(raw(m, "advance_frame", frames=1)["data"], dict) else "n/a")
        rec("W", "lua_slow_callback", lambda: raw(m, "run_script", name="slow", code="local n=0; emu.addMemoryCallback(function() for i=1,20000 do n=n+i end end, emu.callbackType.exec, 0x8000, 0xFFFF, emu.cpuType.snes, emu.memType.snesMemory)", frames=60, timeoutMs=1500))
        rec("W", "status_after_slow", lambda: m.call("get_server_status"))
        rec("W", "step_scanline_huge", lambda: raw(m, "step_scanline", count=1000000, timeoutMs=800))
        rec("W", "status_after_scanline", lambda: m.call("get_server_status"))
        rec("W", "run_until_never", lambda: raw(m, "run_until", condition={"type": "memoryEquals", "address": 0x0ACE, "value": 0xBEEF, "size": 2}, maxFrames=200000, timeoutMs=700))
        rec("W", "status_end", lambda: m.call("get_server_status"))

def session3():
    def flagged(extra, fn_key, fn):
        try:
            with Mesen(args=extra) as mm:
                rec("S", fn_key, lambda: fn(mm))
        except Exception as e:  # noqa: BLE001
            out.setdefault("S", {})[fn_key] = {"status": "exception", "error": f"{type(e).__name__}: {e}"}
            print("S/" + fn_key, "exception", e)


    flagged(["--mcp-rom=" + O], "mcp_rom", lambda mm: {"sha1": mm.call("get_rom_info")["fileSha1"], "status": mm.call("get_server_status")["romLoaded"]})
    flagged(["--mcp-rom=" + O, "--mcp-savestatepath=" + ST_O], "savestatepath", lambda mm: {"frame": mm.call("get_emulator_state").get("frame", mm.call("get_timing_info")["frameCount"]), "pos": f"{mm.u16(0x1014):04X}"})
    flagged(["--mcp-rom=" + R, "--mcp-savestatepath=" + ST_O], "savestatepath_wrong_rom", lambda mm: {"status": mm.call("get_server_status")["romLoaded"], "caps_startupWarning": mm.call("get_capabilities").get("startupWarning")})
    flagged(["--mcp-rom=" + O, "--mcp-savestateslot=3"], "savestateslot_missing", lambda mm: mm.call("get_capabilities").get("startupWarning"))
    flagged(["--mcp-rom=" + O, "--mcp-savestatepath=" + ST_O, "--mcp-savestateslot=3"], "both_flags", lambda mm: mm.call("get_capabilities").get("startupWarning"))
    flagged([], "default_results_dir", lambda mm: {k: mm.call("get_capabilities").get(k) for k in ("resultsDir", "resultsDirCloudSynced", "libDir", "libDirs")})
    flagged(["--mcp-lib-dir=" + RES + r"\kit\lib;C:\Work\mesen2-mcp\tools\lua\lib", "--mcp-results-dir=" + args.out], "lib_dirs_semicolon", lambda mm: mm.call("get_capabilities").get("libDirs"))
    flagged(["--mcp-lib-dir=" + RES + r"\kit\lib", "--mcp-lib-dir=C:\\Work\\mesen2-mcp\\tools\\lua\\lib", "--mcp-results-dir=" + args.out], "lib_dirs_repeated", lambda mm: mm.call("get_capabilities").get("libDirs"))
    flagged(["--mcp-lib-dir=C:\\Work\\does_not_exist", "--mcp-results-dir=" + args.out], "lib_dir_missing", lambda mm: {"libDirs": mm.call("get_capabilities").get("libDirs"), "recipes": len(mm.call("list_recipes").get("recipes", []))})
    flagged(["--mcp-results-dir=" + args.out + r"\new_sub_dir_probe"], "results_dir_created", lambda mm: {"exists": os.path.isdir(args.out + r"\new_sub_dir_probe"), "caps": mm.call("get_capabilities").get("resultsDir")})
    try:
        os.rmdir(args.out + r"\new_sub_dir_probe")
    except OSError:
        pass



def session4():
    """Targeted follow-ups: offsets in breakpoint hits, startup warnings, concurrency, compare_runs, resolve_address."""
    with Mesen(args=FLAGS) as m:
        boot(m)
        m.call("set_breakpoints", breakpoints=[
            {"callbackType": "write", "startAddress": 0x36, "endAddress": 0x36, "memType": "snesWorkRam", "action": "log", "name": "w36", "maxLogged": 2},
            {"callbackType": "read", "startAddress": 0x656, "endAddress": 0x657, "memType": "snesWorkRam", "action": "log", "name": "r656", "maxLogged": 2},
            {"callbackType": "exec", "startAddress": 33528, "endAddress": 33528, "memType": "snesPrgRom", "action": "log", "name": "nmi", "maxLogged": 2}])
        m.call("advance_frame", frames=3)
        h = m.call("get_breakpoint_hits")
        keep = ("id", "kind", "address", "pcHex", "memType", "absType", "absOffset", "wramOffset", "prgOffset", "pcAbsOffset", "pcPrgOffset", "pcWramOffset")
        rec("X", "hit_offsets", lambda: [{k: r.get(k) for k in keep if k in r} for r in h["hits"]])
        m.call("clear_breakpoints")
        rec("X", "resolve_address_variants", lambda: {
            "cpu": raw(m, "resolve_address", cpu=0x8082F8),
            "prgOffset": raw(m, "resolve_address", prgOffset=33528),
            "wram": raw(m, "resolve_address", wram=0x36),
            "label": raw(m, "resolve_address", label="NmiHandler")})
        # concurrency: a long call and a status call on the same pipe
        def concurrent():
            t0 = time.time()
            m._id += 1
            long_id = m._id
            m._send({"jsonrpc": "2.0", "id": long_id, "method": "tools/call", "params": {"name": "advance_frame", "arguments": {"frames": 200000, "timeoutMs": 2500}}})
            time.sleep(0.4)
            m._id += 1
            st_id = m._id
            m._send({"jsonrpc": "2.0", "id": st_id, "method": "tools/call", "params": {"name": "get_server_status", "arguments": {}}})
            m._send({"jsonrpc": "2.0", "id": st_id + 1000, "method": "tools/call", "params": {"name": "get_emulator_state", "arguments": {}}})
            got = {}
            while len(got) < 3 and time.time() - t0 < 15:
                line = m._lines.get(timeout=15)
                for p in m._objects(line.decode()):
                    pid = p.get("id")
                    if pid in (long_id, st_id, st_id + 1000):
                        got[pid] = round(time.time() - t0, 2)
                        if pid == st_id:
                            got["status_busy"] = json.loads(p["result"]["content"][0]["text"]).get("busy")
                        if pid == st_id + 1000:
                            got["state_reply"] = p["result"]["content"][0]["text"][:80]
            return {"longDone_s": got.get(long_id), "statusReply_s": got.get(st_id), "statusBusy": got.get("status_busy"), "stateReply_s": got.get(st_id + 1000), "stateText": got.get("state_reply")}
        rec("X", "concurrent_status_during_long_call", concurrent)
        # compare_runs regression with a short recording
        m.call("load_state_file", path=ST_O)
        rec("X", "record_input", lambda: m.call("record_input", action="start", path="probe_rec.json") if False else "see compare below")
    try:
        with Mesen(args=FLAGS) as m:
            m.call("load_rom", path=O, slot="O"); m.call("pause")
            m.call("load_rom", path=R, slot="R"); m.call("pause")
            rec("X", "list_slots", lambda: m.call("list_slots"))
            rec("X", "slots_get_rom_info_sha", lambda: {"R": m.call("get_rom_info", slot="R")["fileSha1"][:8], "O": m.call("get_rom_info", slot="O")["fileSha1"][:8]})
            rec("X", "per_slot_state_load", lambda: (m.call("load_state_file", path=ST_O, slot="O"), m.call("load_state_file", path=ST_R, slot="R"), [m.u16(0x644) if False else None])[2])
            rec("X", "per_slot_read", lambda: {"O": m.call("read_word", address=0x644, type="workRam", slot="O")["hex"], "R": m.call("read_word", address=0x644, type="workRam", slot="R")["hex"]})
            rec("X", "get_capabilities_slots", lambda: m.call("get_capabilities").get("slots"))
    except Exception as e:  # noqa: BLE001
        print("slots session failed", e)
    # startup warning on a wrong-ROM state
    try:
        with Mesen(args=["--mcp-rom=" + R, "--mcp-savestatepath=" + ST_O]) as mm:
            rec("X", "startup_wrong_rom_state_rom_info", lambda: {k: v for k, v in mm.call("get_rom_info").items() if k in ("fileSha1", "startupWarning")})
    except Exception as e:  # noqa: BLE001
        print("startup session failed", e)


def session5():
    """Regression of the 0.4.0 features on 0.5.0: recording, replay, compare_runs, snapshots, CDL, PPU tools, input."""
    with Mesen(args=FLAGS) as m:
        boot(m)
        rec("R", "set_input_hold", lambda: (m.call("set_input", buttons=["right"], frames=30), m.call("advance_frame", frames=30), m.u16(0x1014))[2])
        rec("R", "get_input", lambda: m.call("get_input"))
        rec("R", "clear_input", lambda: m.call("clear_input"))
        m.call("load_state_file", path=ST_O)
        rec("R", "record_start", lambda: m.call("record_input", action="start", path="probe_rec.json", startState=True))
        m.call("play_input", sequence=[{"frames": 20, "buttons": ["right"]}, {"frames": 10, "buttons": ["down"]}, {"frames": 20, "buttons": []}])
        rec("R", "record_stop", lambda: m.call("record_input", action="stop"))
        pos1 = (m.u16(0x1014), m.u16(0x1016))
        rec("R", "play_input_file", lambda: {k: v for k, v in m.call("play_input_file", path="probe_rec.json", loadStartState=True).items() if k in ("stopReason", "framesAdvanced", "segmentsPlayed")})
        rec("R", "replay_identical", lambda: {"recorded": pos1, "replayed": (m.u16(0x1014), m.u16(0x1016)), "same": pos1 == (m.u16(0x1014), m.u16(0x1016))})
        m.call("load_state_file", path=ST_O)
        m.call("snapshot_memory", name="a", type="workRam", start=0, length=0x2000)
        m.call("advance_frame", frames=10)
        m.call("snapshot_memory", name="b", type="workRam", start=0, length=0x2000)
        rec("R", "diff_snapshots", lambda: {k: v for k, v in m.call("diff_snapshots", a="a", b="b", maxRows=3).items() if k in ("changedBytes", "rangeCount", "ranges", "rows", "identical")})
        m.call("delete_snapshot", name="a"); m.call("delete_snapshot", name="b")
        rec("R", "cdl_summary", lambda: m.call("get_cdl_data", type="prgRom", format="summary"))
        rec("R", "ppu_state_bgmode", lambda: m.call("get_ppu_state").get("derived", {}).get("bgMode"))
        rec("R", "oam_count", lambda: len(m.call("get_oam", onlyOnScreen=True, first=0, count=128).get("sprites", [])))
        rec("R", "dma_state_keys", lambda: sorted(m.call("get_dma_state").keys())[:8])
        rec("R", "screenshot_layer_obj", lambda: {k: v for k, v in m.call("take_screenshot", layers=["obj"], label="probe_obj", returnImage=False).items() if k in ("path", "sizeBytes", "layers")})
    with Mesen(args=FLAGS) as m:
        m.call("load_rom", path=O, slot="O"); m.call("pause")
        m.call("load_rom", path=R, slot="R"); m.call("pause")
        rec("R", "compare_runs_O_vs_R", lambda: m.call("compare_runs", inputFile="probe_rec.json", slots=["O", "R"], startStates=[ST_O, ST_R], frames=60, watch=[{"address": 0x1014, "size": 2, "name": "posX"}, {"address": 0x1016, "size": 2, "name": "posY"}, {"address": 0x0036, "size": 2, "name": "frameCtr"}], maxDivergences=3))

ORDER = "12345"
SESSIONS = {'1': session1, '2': session2, '3': session3, '4': session4, '5': session5}
for k in args.sessions:
    SESSIONS[k]()

path = os.path.join(args.out, f"probe_050_{stamp}{args.tag}.json")
with open(path, "w", encoding="utf-8") as f:
    json.dump(out, f, indent=1, default=str)
print("wrote", path)
