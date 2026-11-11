#!/usr/bin/env python3
"""FR20 area-trial helpers (server 0.6.0, ROM O): session, state validity test (H1), Lua literals, one atomic trial per run_script,
actor list decoding (entry bank/pc -> ROM offset -> `; {n}` tag -> file), compact printing, raw result storage.

Writes only under mesen2-results/ (raw/, screenshots/) and rebuilt/states/ (disposable `tmp_FR20_*` states). Nothing here edits the baserom.
Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import BASEROM, RAW, STATE_DIR, open_session, stamp  # noqa: E402
from mcp_client import ScriptRunError  # noqa: E402
import flag_census as fc  # noqa: E402  (tags(), tag_ending_at())

O_SHA1 = "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
PREFIX = "FR20"
N01 = os.path.join(STATE_DIR, "orig_N01_sc_first_free.mss")
N02 = os.path.join(STATE_DIR, "orig_N02_wills_house_after_feast.mss")
N03 = os.path.join(STATE_DIR, "orig_N03_castle_gate.mss")
S01R = os.path.join(STATE_DIR, "orig_S01r_south-cape-ready.mss")
TITLE = os.path.join(STATE_DIR, "orig_S06_title.mss")


def tmp_state(name):
    return os.path.join(STATE_DIR, f"tmp_FR20_{name}.mss")


def lit(x):
    """Python value -> Lua literal."""
    if x is None:
        return "nil"
    if isinstance(x, bool):
        return "true" if x else "false"
    if isinstance(x, int):
        return str(x)
    if isinstance(x, str):
        return json.dumps(x)
    if isinstance(x, dict):
        return "{" + ",".join(f"[{lit(k)}]={lit(v)}" if not isinstance(k, str) or not k.isidentifier() else f"{k}={lit(v)}" for k, v in x.items()) + "}"
    if isinstance(x, (list, tuple)):
        return "{" + ",".join(lit(v) for v in x) + "}"
    raise TypeError(x)


def open_o():
    m, info = open_session()
    assert info["fileSha1"] == O_SHA1, f"unexpected ROM {info['fileSha1']}"
    return m, info


def flag_bits(hexs):
    """hex string of $0A00.. -> sorted list of set global flag indices."""
    out = []
    for i in range(len(hexs) // 2):
        b = int(hexs[i * 2:i * 2 + 2], 16)
        for bit in range(8):
            if (b >> bit) & 1:
                out.append(i * 8 + bit)
    return out


def flag_diff(a, b):
    sa, sb = set(flag_bits(a)), set(flag_bits(b))
    return {"set": sorted(sb - sa), "clear": sorted(sa - sb)}


def hx(v):
    return "$%04X" % v if v > 0xFF else "$%02X" % v


def actor_names(actors):
    """Decode a fr20.actors() list: entry (bank mirror, pc) -> ROM offset -> the file of the `; {n}` line that contains it."""
    out = []
    for a in actors or []:
        off = (((a["bank"] & 0x3F) << 16) | a["pc"])
        hit = fc.tag_ending_at(off + 1)
        f = hit[1].split(":")[0].split("/")[-1].replace(".asm", "") if hit and abs(hit[0] - off) < 4000 else "?"
        line = hit[1].split(":")[1] if hit and f != "?" else "?"
        out.append({"slot": a["slot"], "off": off, "file": f, "line": line, "x": a["x"], "y": a["y"], "f10": a["f10"], "f12": a["f12"], "chat": a.get("chat"), "raw": a.get("raw")})
    return out


def run(m, info, name, state, lua, frames, includes=("fr20_kit",), shot=None, pre=None):
    """Load `state`, run the Lua `lua` atomically, store result + Lua + ROM identity in raw/FR20_<name>_<date>.json, optional screenshot."""
    m.call("load_state_file", path=state)
    m.call("advance_frame", frames=1)
    if pre:
        pre(m)
    try:
        r = m.run_script_checked(lua, name=f"{PREFIX}_{name}", includes=list(includes), frames=frames, turbo=True, timeoutMs=900000, maxLog=300)
    except ScriptRunError as e:
        print("SCRIPT ERROR", name, e)
        raise
    res = r["result"]
    res["log"] = [e.get("text", "") for e in (r.get("log") or {}).get("entries", []) if not e.get("text", "").startswith(("Loading script", "Registered memory", "Script loaded"))]
    res["stopReason"], res["framesAdvanced"] = r.get("stopReason"), r.get("framesAdvanced")
    res["experiment"] = name
    res["rom"] = {k: info[k] for k in ("path", "fileSizeBytes", "fileSha1", "fileCrc32")}
    res["state"] = os.path.basename(state)
    res["lua"] = lua
    res["actors0_named"] = actor_names(res.get("actors0"))
    res["actors1_named"] = actor_names(res.get("actors1"))
    if shot:
        s = m.shot(f"{PREFIX}_{shot}")
        res["screenshot"] = os.path.relpath(s["path"], BASEROM).replace("\\", "/")
    with open(os.path.join(RAW, f"{PREFIX}_{name}_{stamp()}.json"), "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def visit(m, info, name, state, shot=None, frames=None, extra="", **P):
    """One fr20.visit trial from `state`. P: scene, set, clear, pre, post, settle, mash, hold, watch, tag (see kit/lib/fr20_kit.lua).
    `extra` is Lua text placed before the visit call (it may define P_hooks); returns the result dict."""
    P.setdefault("tag", name)
    P.setdefault("settle", 60)
    hooks = P.pop("hooks", "")
    body = "fr20.visit{" + ",".join(f"{k}={lit(v)}" for k, v in P.items()) + (("," + hooks) if hooks else "") + "}"
    lua = (extra + "\n" if extra else "") + body
    res = run(m, info, name, state, lua, frames or (P["settle"] + 1500), shot=shot)
    res["P"] = {k: v for k, v in P.items()}
    return res


def summarize(res, brief=True):
    """One compact block of text for a visit result."""
    ex = res.get("experiment")
    fl0 = flag_bits(res.get("flags0", "")) if res.get("flags0") else []
    fl1 = flag_bits(res.get("flags1", "")) if res.get("flags1") else []
    pre = res.get("flagsPre")
    lines = [f"== {ex} state={res.get('state')} scene={res.get('scene')} end={res.get('sceneEnd')} err={res.get('error')} "
             f"mask0={res.get('mask0', 0):04X} mask1={res.get('mask1', 0):04X} dmf0={res.get('dmf0', 0):04X} dmf1={res.get('dmf1', 0):04X} "
             f"banner={res.get('bannerSeen')} d36={res.get('d36')} ctl36={res.get('ctl36')} pos={res.get('pos')} p09A2={res.get('p09A2')} shot={res.get('screenshot')}"]
    if res.get("flags0") and res.get("flags1"):
        lines.append("   flag diff arrival>end: " + json.dumps(flag_diff(res["flags0"], res["flags1"])))
    if res.get("flagsPre") and res.get("flags0"):
        lines.append("   flag diff pre>arrival: " + json.dumps(flag_diff(res["flagsPre"], res["flags0"])))
    a0 = res.get("actors0_named") or []
    a1 = res.get("actors1_named") or []
    names0 = sorted(a["file"] for a in a0)
    skip = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")
    lines.append(f"   actors0 ({len(a0)}): " + ", ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']})" for a in a0 if a["file"] not in skip))
    if [a["file"] for a in a0] != [a["file"] for a in a1] or len(a0) != len(a1):
        lines.append(f"   actors1 ({len(a1)}): " + ", ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']})" for a in a1 if a["file"] not in skip))
    tl = res.get("timeline") or []
    ch = []
    last = None
    for t in tl:
        k = (t["mask"], t["dmf"], t["ban"])
        if k != last:
            ch.append(f"n={t['n']} mask={t['mask']:04X} dmf={t['dmf']:04X} ban={t['ban']}")
            last = k
    lines.append("   timeline changes: " + "; ".join(ch[:12]))
    for r in (res.get("maskRows") or [])[:16]:
        hit = fc.tag_ending_at(r["end"]) if r.get("end") else None
        lines.append(f"   MASK f={r['f']} sc={r['sc']:02X} ${r['a']:04X} {r['old']:02X}>{r['new']:02X} n={r.get('n')} f36={r.get('f36')} D={r.get('d', 0):04X} ins={r.get('ins')} {hit[1] if hit else '?'}")
    for r in (res.get("fw") or {}).get("rows", [])[:12]:
        if brief and r["ins"] in ("253423", "45265") and r["a"] == 0x0A1F:
            continue
        lines.append(f"   FW f={r['f']} sc={r['sc']:02X} end={r.get('end')} ins={r.get('ins')} ${r['a']:04X} {r['old']:02X}>{r['new']:02X} +{r['set']} -{r['clr']}")
    for sc in (res.get("scenes") or [])[:30]:
        lines.append(f"   SCENE n={sc['n']} {sc['from']:02X}>{sc['to']:02X} $0A1E={sc['b1E']:02X} $0A2F={sc['b2F']:02X} mask={sc['mask']:04X}")
    if res.get("cells0") or res.get("cells1"):
        lines.append(f"   cells0={res.get('cells0')} cells1={res.get('cells1')}")
    cg = [k for k in res if k.startswith("cgram")]
    if cg:
        ks = sorted(cg, key=lambda k: int(k[5:]))
        lines.append("   cgram palettes that change between " + ks[0] + " and " + ks[-1] + ": " + str([i for i in range(16) if res[ks[0]][i] != res[ks[-1]][i]]))
    if res.get("vram"):
        lines.append("   vram sum " + str(sum(res["vram"]) % 1000003))
    if not brief:
        for l in (res.get("log") or [])[:40]:
            lines.append("   LOG " + l)
    return "\n".join(lines)


def h1(m, state, tag=None):
    """Plan H1 validity test: load the state, run 120 frames, count `$36` writes and read k, sp, scene. Runs twice and compares."""
    code = r"""
local c = 0
emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then c = c + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
local f = 0
kit.onFrame(function()
  f = f + 1
  if f == 120 then local s = emu.getState(); kit.finish({ w36 = c, k = s["cpu.k"], sp = s["cpu.sp"], scene = kit.r16(0x0644), mask = kit.r16(0x065A), flags = fr20.flagBytes(40) }) end
end)
"""
    outs = []
    for _ in range(2):
        m.call("load_state_file", path=state)
        r = m.run_script_checked(code, name="FR20_h1", includes=["fr20_kit"], frames=125, turbo=True, timeoutMs=120000)
        outs.append(r["result"])
    ok = outs[0] == outs[1] and 0x80 <= outs[0]["k"] <= 0xCF and 0x100 <= outs[0]["sp"] <= 0x1FF and 118 <= outs[0]["w36"] <= 121
    return ok, outs[0]


def standing_control(m, info, tag=""):
    """Scene 0A without and with flag 63 from N02 (flag 63 clear there): joypadMaskStd after the banner and 60 frames."""
    out = {}
    for label, setf in (("without63", []), ("with63", [63])):
        lua = "fr20.visit{scene=10, set=%s, settle=60, tag=%s}" % (lit(setf), lit(label))
        res = run(m, info, f"standing_{label}{tag}", N02, lua, 700, shot=f"standing_{label}{tag}")
        out[label] = {"mask1": res.get("mask1"), "mask0": res.get("mask0"), "flag63": (flag_bits(res["flags1"]).count(63) if res.get("flags1") else None),
                      "scene": res.get("scene"), "d36": res.get("d36"), "shot": res.get("screenshot")}
    ok = out["without63"]["mask1"] == 0xCFF0 and out["with63"]["mask1"] == 0
    return ok, out


def store(name, obj):
    with open(os.path.join(RAW, f"{PREFIX}_{name}_{stamp()}.json"), "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=1)
