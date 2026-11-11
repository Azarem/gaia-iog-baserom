#!/usr/bin/env python3
"""FR00 flag instrumentation: one atomic run_script per experiment, control run and forced run from the same state.

usage: timeout 900 python flag_census.py [identity] [helpers] [jar] [lifecycle] [allff] [overlay] [scene0a] [mcpwrite] [h4]   (default: all)

Every experiment opens a fresh server session (plan hazard 26), loads ROM O, checks its SHA-1, loads the state
`orig_S01r_south-cape-ready.mss`, runs the Lua text given here (it is stored verbatim in raw/FR00_<name>_<date>.json
together with the ROM identity) and prints a compact summary. Nothing here edits the baserom; writes go to
mesen2-results/raw/ only. Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.

Registry names: `flag_index(name)` reads artifacts/flags.json once it lists flag names (the file of 2026-10-31 has only the
domains, so a name cannot be resolved yet: the helper raises instead of guessing) and passes the number into Lua.
"""
import bisect
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import BASEROM, RAW, S01R, open_session, stamp  # noqa: E402
from mcp_client import ScriptRunError  # noqa: E402

PREFIX = "FR00"
O_SHA1 = "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"

# ---------------------------------------------------------------------------------------------------------------
# registry names and tag lookup (Python side; the Lua kit only knows indices)
# ---------------------------------------------------------------------------------------------------------------


def flag_index(name):
    """Global flag index of a registry name from artifacts/flags.json (never guesses)."""
    with open(os.path.join(BASEROM, "artifacts", "flags.json"), encoding="utf-8") as f:
        data = json.load(f)
    for key, rec in (data.get("flags") or {}).items():
        for mean in rec.get("meanings", []) if isinstance(rec, dict) else []:
            if mean.get("name") == name:
                return int(key)
    raise KeyError(f"flag name {name!r} not in artifacts/flags.json (keys: {sorted(data)})")


_TAGS = None


def tags():
    """Sorted list of (decimal offset, file:line, text) of every `; {n}` tag of extracted/ (needs the tagged tree)."""
    global _TAGS
    if _TAGS is None:
        rows = []
        rx = re.compile(r"; \{(\d+)\}")
        for path in glob.glob(os.path.join(BASEROM, "extracted", "**", "*.asm"), recursive=True):
            rel = os.path.relpath(path, os.path.join(BASEROM, "extracted")).replace("\\", "/")
            with open(path, encoding="utf-8", errors="replace") as f:
                for i, line in enumerate(f, 1):
                    mt = rx.search(line)
                    if mt:
                        rows.append((int(mt.group(1)), f"{rel}:{i}", line.strip()[:110]))
        rows.sort()
        _TAGS = rows
    return _TAGS


def tag_at(offset):
    """The `; {n}` line whose tag equals `offset` (exact), or None."""
    t = tags()
    keys = [r[0] for r in t]
    i = bisect.bisect_left(keys, offset)
    return t[i] if i < len(t) and t[i][0] == offset else None


def tag_ending_at(end_offset):
    """The tagged instruction that ends at `end_offset`: the greatest tag below it (instructions are contiguous)."""
    t = tags()
    keys = [r[0] for r in t]
    i = bisect.bisect_left(keys, end_offset) - 1
    return t[i] if i >= 0 else None


def explain_rows(rows):
    """Add `src` (file:line text of the instruction that ends at the callback PC) to flagwatch rows."""
    out = []
    for r in rows:
        end = r.get("end")
        hit = tag_ending_at(end) if end else None
        d = dict(r)
        if hit:
            d["src"] = f"{hit[1]} [{hit[0]}] {hit[2]}"
        out.append(d)
    return out


# ---------------------------------------------------------------------------------------------------------------
# session helpers
# ---------------------------------------------------------------------------------------------------------------


def session():
    m, info = open_session()
    assert info["fileSha1"] == O_SHA1, f"unexpected ROM {info['fileSha1']}"
    return m, info


def label(m, name):
    r = m.call("get_label_address", label=name)
    return r["address"], r["cpuAddress"]


def run(m, info, name, code, frames, state=S01R, pre=None):
    """Load `state`, run the Lua `code` atomically (checked), store result + log rows + Lua + ROM identity in raw/."""
    m.call("load_state_file", path=state)
    if pre:
        pre(m)
    try:
        r = m.run_script_checked(code, name=f"{PREFIX}_{name}", includes=["gaia_kit"], frames=frames + 20, turbo=True, timeoutMs=900000)
    except ScriptRunError as e:
        print("SCRIPT ERROR", name, e)
        raise
    res = r["result"]
    res["log"] = [e.get("text", "") for e in (r.get("log") or {}).get("entries", [])]
    res["stopReason"], res["framesAdvanced"] = r.get("stopReason"), r.get("framesAdvanced")
    res["experiment"] = name
    res["rom"] = {k: info[k] for k in ("path", "fileSizeBytes", "fileSha1", "fileCrc32")}
    res["state"] = os.path.basename(state)
    res["lua"] = code
    with open(os.path.join(RAW, f"{PREFIX}_{name}_{stamp()}.json"), "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def dump_u8(m, addr, n, mt="workRam"):
    return list(m.mem(addr, n, mt))


def save_summary(name, obj):
    path = os.path.join(RAW, f"{PREFIX}_{name}_summary_{stamp()}.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=1)
    return path


# ---------------------------------------------------------------------------------------------------------------
# Lua texts (verbatim in the raw files and in the result file)
# ---------------------------------------------------------------------------------------------------------------

LUA_HELPERS = r"""
-- FR00 helpers: unit test of gaia.flags.* and gaia.flagwatch with the NMI controls (O, state S01r)
local WR = emu.memType.snesWorkRam
local NMI = @@NMI@@
local c = { w36 = 0, nmi = 0 }
emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then c.w36 = c.w36 + 1 end end,
  emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
emu.addMemoryCallback(function() c.nmi = c.nmi + 1 end,
  emu.callbackType.exec, NMI, NMI, emu.cpuType.snes, emu.memType.snesPrgRom)
local fw = gaia.flagwatch{ control = false }
local R = { tests = {} }
local function T(name, ok, detail)
  R.tests[#R.tests + 1] = { name = name, ok = ok, detail = detail }
  gaia.log("%s %s %s", ok and "PASS" or "FAIL", name, tostring(detail or ""))
end
local frames = 0
kit.onFrame(function()
  frames = frames + 1
  if frames == 2 then
    local d0 = gaia.flags.dump()
    R.d0head = d0:sub(1, 16)
    T("dump length", #d0 == 360, #d0)
    local a, b = gaia.flags.loc(0x11)
    T("loc(0x11)", a == 0x0A02 and b == 1, string.format("%04X.%d", a, b))
    a, b = gaia.flags.loc(1439)
    T("loc(1439)", a == 0x0AB3 and b == 7, string.format("%04X.%d", a, b))
    T("loc(1440) raises", not pcall(gaia.flags.loc, 1440), "assert")
    -- scratch flag in $0A00 and a persistent flag in $0A02, the last flag of the dump in $0AB3
    for _, n in ipairs { 3, 0x11, 1439 } do
      local addr, bit = gaia.flags.loc(n)
      local before = gaia.flags.get(n)
      local rb = gaia.flags.set(n)
      local byte = kit.r8(addr)
      local d1 = gaia.flags.dump()
      local ch, det = gaia.flags.diff(d0, d1)
      T(string.format("set(%X)", n), rb == 1 and ((byte >> bit) & 1) == 1 and #ch == (before == 0 and 1 or 0),
        string.format("before=%d readback=%d byte=%02X diff=%s", before, rb, byte, table.concat(det, ",")))
      local rc = gaia.flags.clear(n)
      local d2 = gaia.flags.dump()
      T(string.format("clear(%X)", n), rc == 0 and ((kit.r8(addr) >> bit) & 1) == 0, string.format("readback=%d byte=%02X", rc, kit.r8(addr)))
      -- restore the original bit
      if before == 1 then gaia.flags.set(n) end
    end
    -- word write of the scratch word and a multi-bit diff
    local w0 = kit.r16(0x0A00)
    kit.w16(0x0A00, 0x0005)
    local d3 = gaia.flags.dump()
    local ch, det = gaia.flags.diff(d0, d3)
    T("w16 0A00=0005 in dump", d3:sub(1, 4) == "0500", d3:sub(1, 8))
    local expect, x = 0, w0 ~ 0x0005
    while x ~= 0 do expect = expect + (x & 1); x = x >> 1 end
    T("diff of 0A00=0005", #ch == expect, string.format("expected %d changed bits, got %s", expect, table.concat(det, ",")))
    kit.w16(0x0A00, w0)
    -- do script writes reach the write callback? (expected: no)
    local h0 = fw.hits
    kit.w8(0x0A02, kit.r8(0x0A02) ~ 0x01)
    kit.w8(0x0A02, kit.r8(0x0A02) ~ 0x01)
    R.luaWriteHits = fw.hits - h0
    gaia.log("emu.write hits seen by flagwatch: %d", R.luaWriteHits)
  elseif frames == 122 then
    local s = fw:summary()
    kit.finish({ tests = R.tests, d0head = R.d0head, luaWriteHits = R.luaWriteHits, nmiExec = c.nmi, w36 = c.w36,
                 frames = frames, fw = s, dumpEnd = gaia.flags.dump():sub(1, 16) })
  end
end)
"""

LUA_JAR = r"""
-- FR00 firing control for flagwatch: the jar door of South Cape (scene 01) sets flag $11 (COP SetFlagByte #11,
-- $0A02 bit 1) when the player actor stands exactly on (#$0078, #$025E) (COP BranchIfPlayerAt, actor +14/+16).
local FORCE = @@FORCE@@
local fw = gaia.flagwatch{}
local d0
local f = 0
kit.onFrame(function()
  f = f + 1
  if f == 2 then
    d0 = gaia.flags.dump()
    if FORCE then kit.w16(0x1014, 0x0078); kit.w16(0x1016, 0x025E) end
  elseif f == 100 then
    local d1 = gaia.flags.dump()
    local ch, det = gaia.flags.diff(d0, d1)
    kit.finish({ force = FORCE, scene = kit.r16(0x0644), changed = ch, detail = det, flag11 = gaia.flags.get(0x11),
                 mask = kit.r16(0x065A), actor = { kit.r16(0x1014), kit.r16(0x1016) }, fw = fw:summary() })
  end
end)
"""

LUA_WARP = r"""
-- FR00 lifecycle: write bytes of the flag array, quick warp, read after the scene loaded (flag-analysis addendum 2)
local TARGET = @@TARGET@@
local POKES = @@POKES@@      -- { {wram offset, byte}, ... }
local fw = gaia.flagwatch{}
-- 253564 = COP SetFlagByte #FF of ClearSceneState, 253423 = its clearing STA, 253294 = end of its STX $eventFlags (253291)
local marks = gaia.execMarks{ setFF_ClearSceneState = 253564, clearFF_ClearSceneState = 253423, stx_eventFlags = 253291 }
local R = { target = TARGET, track = {} }
local lastKey
kit.onFrame(function()
  local key = string.format("%04X %04X %02X", kit.r16(0x0A00), kit.r16(0x0A02), kit.r8(0x0A1F))
  if key ~= lastKey then
    lastKey = key
    if #R.track < 30 then
      R.track[#R.track + 1] = { f = emu.getState().frameCount, sc = kit.r16(0x0644), next = kit.r16(0x0642), w0A00 = kit.r16(0x0A00),
                                w0A02 = kit.r16(0x0A02), b0A1F = kit.r8(0x0A1F) }
    end
  end
end)
local pulsing = false
kit.machine{ start = "poke", states = {
  poke = function(m)
    if m:elapsed() >= 2 and kit.r16(0x0642) == 0 then
      for _, p in ipairs(POKES) do kit.w8(p[1], p[2]) end
      R.pre = gaia.flags.dump()
      R.preWords = { kit.r16(0x0A00), kit.r16(0x0A02) }
      R.sceneBefore = kit.r16(0x0644)
      kit.w16(0x0642, TARGET)
      m:go("warping")
    end
  end,
  warping = function(m)
    if kit.r16(0x0644) == TARGET and kit.r16(0x0642) == 0 then
      R.arrivalWords = { kit.r16(0x0A00), kit.r16(0x0A02) }
      R.arr36 = kit.r16(0x0036)       -- the NMI runs again only when the scene setup has finished
      m:go("banner")
    elseif m:elapsed() > 900 then
      R.error = "warp_timeout"; m:go("done")
    end
  end,
  banner = function(m)
    local d = (kit.r16(0x0036) - R.arr36) & 0xFFFF
    if kit.r8(0x00B4) ~= 0 then
      if not pulsing then kit.pulse({ "a" }, 3, 3); pulsing = true; R.bannerSeen = true end
    elseif pulsing then
      kit.stopPulse(); pulsing = false; R.set36 = kit.r16(0x0036); m:go("settle")
    elseif d >= 90 then
      R.set36 = kit.r16(0x0036); m:go("settle")
    end
    if m:elapsed() > 900 then R.error = "banner_timeout"; kit.stopPulse(); m:go("done") end
  end,
  settle = function(m)
    if ((kit.r16(0x0036) - R.set36) & 0xFFFF) >= 30 then m:go("done")
    elseif m:elapsed() > 900 then R.error = "settle_timeout"; m:go("done") end
  end,
  done = function(m)
    R.post = gaia.flags.dump()
    R.postWords = { kit.r16(0x0A00), kit.r16(0x0A02), kit.r16(0x0A80) }
    R.changed, R.detail = gaia.flags.diff(R.pre or R.post, R.post)
    R.scene, R.mask, R.banner = kit.r16(0x0644), kit.r16(0x065A), kit.r8(0x00B4)
    R.fw = fw:summary()
    R.marks = marks
    kit.finish(R)
  end,
} }
"""

LUA_OVERLAY = r"""
-- FR00 inventory overlay: write $0A00, open the inventory with Select (logical $2000, physical Select), wait inside,
-- close with the cancel button, read $0A00 and bit 7 of $0A1F (flag $FF) through the whole sequence
local PRE = @@PRE@@          -- word written to $0A00 before opening, or -1
local CLOSE = @@CLOSE@@      -- buttons that close the overlay; an empty list closes by writing flag $0000 (bit 0 of $0A00) instead
local fw = gaia.flagwatch{}
-- 191792 = STZ $eventFlags (open), 192094 = STA $eventFlags (close), 192190 = COP SetFlagByte #FF (close), 191678 = menu's COP SetFlagByte #00
local marks = gaia.execMarks{ open_STZ = 191792, close_STA = 192094, close_setFF = 192190, menu_setExit = 191678 }
local R = { timeline = {} }
local function snap(tag)
  local row = { tag = tag, f = emu.getState().frameCount, sc = kit.r16(0x0644), w0A00 = kit.r16(0x0A00), b0A1F = kit.r8(0x0A1F) }
  if #R.timeline < 40 then R.timeline[#R.timeline + 1] = row end
  gaia.log("%s f=%d sc=%04X $0A00=%04X $0A1F=%02X", tag, row.f, row.sc, row.w0A00, row.b0A1F)
end
local last
kit.onFrame(function()
  local key = string.format("%04X %02X %04X", kit.r16(0x0A00), kit.r8(0x0A1F), kit.r16(0x0644))
  if key ~= last then last = key; snap("chg") end
end)
kit.machine{ start = "poke", states = {
  poke = function(m)
    if m:elapsed() >= 3 then
      if PRE >= 0 then kit.w16(0x0A00, PRE) end
      R.pre = { w0A00 = kit.r16(0x0A00), b0A1F = kit.r8(0x0A1F), scene = kit.r16(0x0644) }
      kit.pulse({ "select" }, 12, 60)
      m:go("waitopen")
    end
  end,
  waitopen = function(m)
    if kit.r16(0x0644) == 0x00FF then
      kit.stopPulse(); snap("open"); R.open = { w0A00 = kit.r16(0x0A00), b0A1F = kit.r8(0x0A1F) }
      m:go("inside")
    elseif m:elapsed() > 300 then R.error = "open_timeout"; m:go("done") end
  end,
  inside = function(m)
    if m:elapsed() == 60 then
      snap("inside60"); R.inside = { w0A00 = kit.r16(0x0A00), b0A1F = kit.r8(0x0A1F) }
      if #CLOSE > 0 then kit.pulse(CLOSE, 3, 3) else kit.w16(0x0A00, kit.r16(0x0A00) | 1); R.pokedExit = emu.getState().frameCount end
      m:go("closing")
    end
  end,
  closing = function(m)
    if kit.r16(0x0644) ~= 0x00FF then
      kit.stopPulse(); snap("closed"); R.closedAt = emu.getState().frameCount
      m:go("settle")
    elseif m:elapsed() > 400 then R.error = "close_timeout"; kit.stopPulse(); m:go("done") end
  end,
  settle = function(m) if m:elapsed() >= 40 then m:go("done") end end,
  done = function(m)
    R.after = { w0A00 = kit.r16(0x0A00), b0A1F = kit.r8(0x0A1F), scene = kit.r16(0x0644), mask = kit.r16(0x065A) }
    R.fw = fw:summary()
    R.marks = marks
    kit.finish(R)
  end,
} }
"""

def lua_lit(v):
    """Lua source text of a Python value: ints, bools, strings, lists as `{...}` (a JSON `[[1,2]]` would open a Lua long string)."""
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, str):
        return json.dumps(v)
    if isinstance(v, (list, tuple)):
        return "{" + ", ".join(lua_lit(x) for x in v) + "}"
    raise TypeError(f"no Lua literal for {v!r}")


def lua(text, **kw):
    for k, v in kw.items():
        text = text.replace(f"@@{k}@@", lua_lit(v))
    return text


# ---------------------------------------------------------------------------------------------------------------
# experiments
# ---------------------------------------------------------------------------------------------------------------


def exp_identity():
    out = {}
    m, info = session()
    try:
        out["rom"] = info
        out["romInfo"] = m.call("get_rom_info")
        out["capabilities"] = {k: v for k, v in m.call("get_capabilities").items() if k in ("serverVersion", "mesenVersion", "libDirs", "resultsDir", "flags")}
        out["status"] = m.call("get_server_status")
        out["selfTest"] = m.call("self_test")
        out["nmi"] = label(m, "NmiHandler")
        out["clearSceneState"] = label(m, "ClearSceneState")
        # H1 validity test, twice: load, 120 frames, k, sp, scene
        out["h1"] = []
        for i in range(2):
            m.call("load_state_file", path=S01R)
            code = ("local n=0 emu.addMemoryCallback(function(a) if (a&0xFFFF)==0x36 then n=n+1 end end,emu.callbackType.write,0x36,0x36,emu.cpuType.snes,emu.memType.snesWorkRam)"
                    " local f=0 kit.onFrame(function() f=f+1 if f==120 then local s=emu.getState() kit.finish({k=s['cpu.k'],sp=s['cpu.sp'],pc=s['cpu.pc'],scene=kit.r16(0x644),w36=n,frame=s.frameCount,mask=kit.r16(0x65A),flags=gaia.flags.dump():sub(1,24)}) end end)")
            r = m.run_script_checked(code, includes=["gaia_kit"], frames=125, turbo=True, name="FR00_h1")
            out["h1"].append(r["result"])
    finally:
        m.close()
    save_summary("identity", out)
    return out


def exp_helpers():
    m, info = session()
    try:
        nmi, _ = label(m, "NmiHandler")
        res = run(m, info, "helpers", lua(LUA_HELPERS, NMI=nmi), 130)
        # second path: MCP write_memory / read_memory of the same scratch bit, after the state is reloaded
        m.call("load_state_file", path=S01R)
        before = m.mem(0x0A00, 2)
        w = m.call("write_memory", address=0x0A00, data=[before[0] | 0x08], type="workRam")
        back = m.mem(0x0A00, 2)
        m.call("write_memory", address=0x0A00, data=[before[0]], type="workRam")
        res["mcpWriteReadback"] = {"before": before.hex(), "written": w, "after": back.hex(), "restored": m.mem(0x0A00, 2).hex()}
    finally:
        m.close()
    save_summary("helpers", res)
    return res


def exp_jar(force):
    m, info = session()
    try:
        res = run(m, info, f"jar_{'forced' if force else 'control'}", lua(LUA_JAR, FORCE=force), 110)
        res["fw_rows_explained"] = explain_rows(res["fw"].get("rows", []))
    finally:
        m.close()
    save_summary(f"jar_{'forced' if force else 'control'}", res)
    return res


def exp_warp(name, target, pokes):
    m, info = session()
    try:
        res = run(m, info, name, lua(LUA_WARP, TARGET=target, POKES=pokes), 1500)
        res["fw_rows_explained"] = explain_rows(res["fw"].get("rows", []))
    finally:
        m.close()
    save_summary(name, res)
    return res


def exp_overlay(name, pre, close):
    m, info = session()
    try:
        res = run(m, info, name, lua(LUA_OVERLAY, PRE=pre, CLOSE=close), 900)
        res["fw_rows_explained"] = explain_rows(res["fw"].get("rows", []))
    finally:
        m.close()
    save_summary(name, res)
    return res


def exp_scene0a():
    """Standing positive control: scene $0A with flag 63 (the mask must reach 0000) and without (stays CFF0)."""
    out = {}
    for tag, flags in (("with63", [63]), ("without", [])):
        m, info = session()
        try:
            m.call("load_state_file", path=S01R)
            r = m.call("run_recipe", name="warp", args={"scene": 10, "flags": flags}, frames=1500)
            res = r.get("result")
            m.call("advance_frame", frames=60)
            mask = m.u16(0x065A)
            scene = m.u16(0x0644)
            byte = m.mem(0x0A00, 0x10).hex()
            shot = m.shot(f"FR00_scene0A_{tag}")
            out[tag] = {"recipe": res, "stop": r.get("stopReason"), "framesAdvanced": r.get("framesAdvanced"), "maskAfter60": mask,
                        "scene": scene, "flags0A00": byte, "flag63": (m.u8(0x0A07) >> 7) & 1, "shot": shot.get("path") if isinstance(shot, dict) else shot}
        finally:
            m.close()
    save_summary("scene0a", out)
    return out


def exp_mcpwrite():
    """Does the MCP write_memory tool reach the write callback of gaia.flagwatch? (emu.write does not, see the helpers run.)"""
    m, info = session()
    try:
        m.call("load_state_file", path=S01R)
        code = """
local fw = gaia.flagwatch{ control = false }
local n = 0
kit.onFrame(function() n = n + 1; gaia.log('frame %d hits=%d noop=%d logged=%d', n, fw.hits, fw.noop, fw.logged) end)
"""
        m.call("load_script", code=code, name="FR00_mcpwrite", includes=["gaia_kit"])
        m.call("advance_frame", frames=3)
        w1 = m.call("write_memory", address=0x0A02, data=[0x01], type="workRam")
        m.call("advance_frame", frames=3)
        w2 = m.call("write_memory", address=0x0A02, data=[0x00], type="workRam")
        m.call("advance_frame", frames=3)
        log = [e["text"] for e in m.call("get_script_log", name="FR00_mcpwrite")["entries"]]
        m.call("unload_script", name="FR00_mcpwrite")
    finally:
        m.close()
    out = {"log": log, "write1": w1, "write2": w2}
    save_summary("mcpwrite", out)
    return out


def exp_h4():
    """H4 native count controls on O from S01r: write $36, read $656-$657, exec at NmiHandler (33528), exec at the R ROM's NMI offset (38524, must be 0)."""
    m, info = session()
    try:
        nmi, _ = label(m, "NmiHandler")
        m.call("load_state_file", path=S01R)
        m.call("set_breakpoints", breakpoints=[
            {"callbackType": "write", "startAddress": 54, "endAddress": 54, "memType": "snesWorkRam", "action": "count", "name": "w36"},
            {"callbackType": "read", "startAddress": 1622, "endAddress": 1623, "memType": "snesWorkRam", "action": "count", "name": "r656"},
            {"callbackType": "exec", "startAddress": nmi, "endAddress": nmi, "memType": "snesPrgRom", "action": "count", "name": "nmi"},
            {"callbackType": "exec", "startAddress": 38524, "endAddress": 38524, "memType": "snesPrgRom", "action": "count", "name": "nmiOtherRom"}])
        adv = m.call("advance_frame", frames=120)
        hits = m.call("get_breakpoint_hits")
        m.call("clear_breakpoints")
    finally:
        m.close()
    out = {"nmiOffset": nmi, "advance": {k: adv.get(k) for k in ("stopReason", "framesAdvanced", "frame")}, "hits": hits}
    save_summary("h4", out)
    return out


def main():
    todo = sys.argv[1:] or ["identity", "helpers", "jar", "lifecycle", "allff", "overlay", "scene0a", "mcpwrite", "h4"]
    if "identity" in todo:
        r = exp_identity()
        print(json.dumps(r, indent=1)[:3000])
    if "helpers" in todo:
        r = exp_helpers()
        for t in r["tests"]:
            print(("PASS" if t["ok"] else "FAIL"), t["name"], t["detail"])
        print({k: r[k] for k in ("luaWriteHits", "nmiExec", "w36", "frames", "mcpWriteReadback")})
        print("fw", {k: v for k, v in r["fw"].items() if k not in ("byIns", "rows")}, r["fw"]["byIns"])
        for row in explain_rows(r["fw"].get("rows", [])):
            print("   ", row)
    if "jar" in todo:
        for force in (False, True):
            r = exp_jar(force)
            print("== jar force" if force else "== jar control", {k: r[k] for k in ("scene", "changed", "detail", "flag11", "mask", "actor")})
            print("  fw", {k: v for k, v in r["fw"].items() if k not in ("rows", "byIns")}, r["fw"]["byIns"])
            for row in r["fw_rows_explained"]:
                print("   ", row)
    if "lifecycle" in todo:
        # control: 0A02/0A03 = FF only; forced: 0A00-0A03 = FFFFFFFF ; two destinations with no natural D1 flags expected
        for target in (0x15, 0x24, 0x08):
            for tag, pokes in (("control", [[0x0A02, 0xFF], [0x0A03, 0xFF]]),
                               ("forced", [[0x0A00, 0xFF], [0x0A01, 0xFF], [0x0A02, 0xFF], [0x0A03, 0xFF]])):
                r = exp_warp(f"warp{target:02X}_{tag}", target, pokes)
                print(f"== warp {target:02X} {tag}", {k: r.get(k) for k in ("scene", "mask", "banner", "bannerSeen", "preWords", "arrivalWords", "postWords", "error", "marks")})
                print("   changed", r.get("changed"), r.get("detail"))
                print("   clear", r["fw"]["clear"], "ctl36", r["fw"]["control36Writes"], "hits", r["fw"]["hits"], "logged", r["fw"]["logged"])
                for row in r["fw_rows_explained"][:6]:
                    print("    ", row)
                print("   track", r["track"][:6])
    if "allff" in todo:
        # whole array 0A00-0AB3 = FF before an ordinary warp: only 0A00-0A01 may read 00 afterwards (plus what the scene sets)
        for target in (0x24, 0x15):
            r = exp_warp(f"warp{target:02X}_allFF", target, [[0x0A00 + i, 0xFF] for i in range(180)])
            post = r["post"]
            print(f"== warp {target:02X} all FF", {k: r.get(k) for k in ("scene", "mask", "banner", "error", "preWords", "postWords")})
            print("   post dump", post)
            print("   clear", r["fw"]["clear"], "hits", r["fw"]["hits"], "logged", r["fw"]["logged"])
            print("   changed", r.get("changed"), r.get("detail"))
            for row in r["fw_rows_explained"]:
                print("    ", row)
    if "overlay" in todo:
        for name, pre, close in (("overlay_control", -1, ["y"]), ("overlay_forced", 0x0005, ["y"]), ("overlay_pokeexit", 0x0005, [])):
            r = exp_overlay(name, pre, close)
            print("==", name, {k: r.get(k) for k in ("pre", "open", "inside", "after", "error", "closedAt", "pokedExit", "marks")})
            print("   timeline", r["timeline"])
            print("   fw", {k: v for k, v in r["fw"].items() if k not in ("rows", "byIns")}, r["fw"]["byIns"])
            for row in r["fw_rows_explained"]:
                print("    ", row)
    if "scene0a" in todo:
        r = exp_scene0a()
        print(json.dumps(r, indent=1)[:2500])
    if "mcpwrite" in todo:
        r = exp_mcpwrite()
        print(json.dumps(r, indent=1)[:2500])
    if "h4" in todo:
        r = exp_h4()
        print(json.dumps(r, indent=1)[:2500])


if __name__ == "__main__":
    main()
