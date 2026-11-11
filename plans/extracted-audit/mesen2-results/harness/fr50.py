#!/usr/bin/env python3
"""FR50 preset replay (server 0.6.0, ROM O). One atomic run_script per trial from the standing state S01r; the preset bytes are written
with write_memory (work RAM) and read back before the script starts.

usage (from this folder, under a process timeout):
  fr50.py h1                       identity + H1 validity test of S01r (twice) + standing control (scene 0A without and with flag 63)
  fr50.py preset 0 1 2 ...         per preset index: control run C (no preset), preset run P, positive control K (preset + the scene skip flags), all
                                   with the same warp, input and watch; rows go to raw/FR50_rows.jsonl, a one-line brief is printed
  fr50.py state 0 1 ...            preset run with watch 1 (arrival), screenshot, save rebuilt/states/orig_P<nn>_<name>.mss (+ sidecar meta), H1 twice
  fr50.py inv 2 14                 inventory screen (Select held) after writing the preset items, screenshot
  fr50.py form                     form trial (write characterForm and compare with the natural transform)

Writes only under mesen2-results/ (raw/, raw/screenshots/) and rebuilt/states/ (orig_P*.mss). Flag convention: global index n = WRAM byte
0x0A00 + (n >> 3), bit n & 7.
"""
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr20_lib as L  # noqa: E402
import flag_census as fc  # noqa: E402
from a_common import BASEROM, RAW, S01R, STATE_DIR, open_session, stamp  # noqa: E402
from mcp_client import ScriptRunError  # noqa: E402

PREFIX = "FR50"
O_SHA1 = "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
ROWS = os.path.join(RAW, "FR50_rows.jsonl")
PRESETS = os.path.join(BASEROM, "plans", "flags", "results", "specs", "FL32_presets.json")
SCENEFLAGS = os.path.join(BASEROM, "plans", "flags", "results", "specs", "FL32_scene-flags.json")

ABILITY_BIT = {"Psycho Dash": 0, "Psycho Slider": 1, "Spin Dash": 2, "Dark Friar": 4, "Aura Barrier": 5, "Earthquaker": 6}

# Natural arrival of each verification scene (FR40 scene table, "Entry used": warpDestX, warpDestY, warpFacing, warpScrollParams).
# None = quick warp (the scene has no incoming scene-warp row, or FR40 used the quick warp position).
DEST = {
    8: (440, 128, 0, 0x1200), 10: (96, 880, 3, 0x4430), 28: (416, 208, 3, 0x2200), 41: (120, 192, 0, 0x1100), 62: (80, 64, 3, 0x4200),
    88: None, 85: (112, 480, 0, 0x2200), 90: (960, 144, 6, 0x1400), 96: (16, 144, 7, 0x4400), 103: (376, 464, 0, 0x2201),
    130: (2000, 144, 6, 0x1800), 138: (80, 144, 135, 0x3300), 160: (16, 64, 7, 0x2300), 176: (504, 144, 3, 0x5400),
    205: (128, 192, 128, 0x1100), 221: None, 222: (120, 128, 3, 0x1100), 231: None, 232: None,
}
# frames watched after the banner (mash A pulses, stop after 40 free frames); $58 never releases (loads $5A at frame 3631 by itself), $E7 loads $E8 at 969
WATCH = {88: 600, 231: 1100}
DEFAULT_WATCH = 1500


def lit(x):
    return L.lit(x)


def load_presets():
    with open(PRESETS, encoding="utf-8") as f:
        data = json.load(f)
    out = []
    for i, (name, p) in enumerate(data.items()):
        mt = re.search(r"Verify in scene \$([0-9A-F]+)", p["note"])
        p = dict(p)
        p["name"] = name
        p["idx"] = i
        p["scene"] = int(mt.group(1), 16)
        assert p["scene"] == p["verifyScene"], (name, p["scene"], p["verifyScene"])
        out.append(p)
    return out


def skip_flags(scene):
    with open(SCENEFLAGS, encoding="utf-8") as f:
        d = json.load(f)
    return list(d[str(scene)]["flags"])


def open_o():
    m, info = open_session()
    assert info["fileSha1"] == O_SHA1, f"unexpected ROM {info['fileSha1']}"
    return m, info


def log_row(row):
    with open(ROWS, "a", encoding="utf-8") as f:
        f.write(json.dumps(row) + "\n")


# ---------------------------------------------------------------------------------------------------------------
# preset writer (work RAM, read back)
# ---------------------------------------------------------------------------------------------------------------

def preset_bytes(p, extra_flags=()):
    """The bytes a preset adds to the loaded state: flag bits (OR), inventory slots, form, gems, ability byte. Returns (flags list, dict of writes)."""
    flags = sorted(set(p.get("flags", [])) | set(extra_flags))
    abil = 0
    for a in p.get("abilities", []):
        abil |= 1 << ABILITY_BIT[a]
    inv = [0] * 16
    for it in p.get("items", []):
        assert inv[it["slot"]] == 0
        inv[it["slot"]] = it["id"]
    return flags, {"abil": abil, "inv": inv, "form": {"Will": 0, "Freedan": 1, "Shadow": 2}[p.get("form", "Will")], "gems": p.get("gems", 0)}


def apply_preset(m, p, extra_flags=()):
    """Write flags (global indices, OR into $0A00-$0AB3), abilities ($0AA2 OR), items ($0AB4-$0AC3), form ($0AD4), gems ($0AD6) and read all
    back. Returns a dict with the read-back verdict (never writes the low direct page)."""
    flags, w = preset_bytes(p, extra_flags)
    cur = bytearray(m.mem(0x0A00, 180))
    before = bytes(cur)
    for n in flags:
        assert 0 <= n < 180 * 8, n
        cur[n >> 3] |= 1 << (n & 7)
    cur[0xA2] |= w["abil"] & 0xFF
    cur[0xA3] |= (w["abil"] >> 8) & 0xFF
    r1 = m.call("write_memory", address=0x0A00, data=list(cur), type="workRam")
    r2 = m.call("write_memory", address=0x0AB4, data=w["inv"], type="workRam")
    r3 = m.call("write_memory", address=0x0AD4, data=[w["form"], 0], type="workRam")
    r4 = m.call("write_memory", address=0x0AD6, data=[w["gems"] & 0xFF, (w["gems"] >> 8) & 0xFF], type="workRam")
    back = m.mem(0x0A00, 180)
    inv_back = list(m.mem(0x0AB4, 16))
    form_back = m.u16(0x0AD4)
    gems_back = m.u16(0x0AD6)
    ok = back == bytes(cur) and inv_back == w["inv"] and form_back == w["form"] and gems_back == w["gems"]
    added = [n for n in range(180 * 8) if (back[n >> 3] >> (n & 7)) & 1 and not (before[n >> 3] >> (n & 7)) & 1]
    return {"ok": ok, "verified": [r1.get("verified"), r2.get("verified"), r3.get("verified"), r4.get("verified")], "flagsWritten": len(flags),
            "flagsAdded": len(added), "inv": inv_back, "form": form_back, "gems": gems_back, "abil": back[0xA2] | (back[0xA3] << 8)}


# ---------------------------------------------------------------------------------------------------------------
# trial
# ---------------------------------------------------------------------------------------------------------------

def run_lua(m, name, lua, frames, state=S01R, pre=None):
    m.call("load_state_file", path=state)
    m.call("advance_frame", frames=1)
    w = pre(m) if pre else None
    r = m.run_script_checked(lua, name=f"{PREFIX}_{name}", includes=["fr50_kit"], frames=frames, turbo=True, timeoutMs=900000, maxLog=300)
    res = r["result"]
    res["stopReason"], res["framesAdvanced"] = r.get("stopReason"), r.get("framesAdvanced")
    return res, w


def flag_list(hexs):
    return L.flag_bits(hexs)


def named_actors(compact):
    """'bank:pc@slot,...' -> list of {slot, off, file, line}."""
    out = []
    for item in (compact or "").split(","):
        if not item:
            continue
        a, slot = item.split("@")
        bank, pc = a.split(":")
        off = ((int(bank, 16) & 0x3F) << 16) | int(pc, 16)
        hit = fc.tag_ending_at(off + 1)
        f, ln = "?", "?"
        if hit and abs(hit[0] - off) < 4000:
            f = hit[1].split(":")[0].split("/")[-1].replace(".asm", "")
            ln = hit[1].split(":")[1]
        out.append({"slot": int(slot, 16), "off": off, "file": f, "line": ln})
    return out


def writer_of(end):
    if not end:
        return None
    hit = fc.tag_ending_at(end)
    return f"{hit[1]} {{{hit[0]}}}" if hit else f"offset {end}"


def entry_name(entry):
    bank, pc = entry.split(":")
    off = ((int(bank, 16) & 0x3F) << 16) | int(pc, 16)
    hit = fc.tag_ending_at(off + 1)
    if hit and abs(hit[0] - off) < 4000:
        return hit[1].split(":")[0].split("/")[-1].replace(".asm", "")
    return "?"


SKIP_FILES = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")


def trial(m, info, p, variant, kind, extra=(), watch=None, inp="mashA", stop_free=40, shot=True, cg=False, save_arrival=False, walk=None, dest_xy=None):
    """kind: "C" control (no preset writes), "P" preset, "K" preset + extra flags. Returns the stored row."""
    sid = p["scene"]
    dest = DEST[sid]
    if dest_xy:
        dest = (dest_xy[0], dest_xy[1], dest[2] if dest else 0, dest[3] if dest else 0x1100)
    wch = watch if watch is not None else WATCH.get(sid, DEFAULT_WATCH)
    tag = f"p{p['idx']:02d}_{variant}"
    lua = (f"fr50.arrive{{scene={sid},watch={wch},input={lit(inp)},tag={lit(tag)},stopFree={stop_free}"
           + (f",dest={lit(list(dest))}" if dest else "") + (",cg=true" if cg else "")
           + (",walk={" + ",".join(f'{{"{d}",{a},{b}}}' for d, a, b in walk) + "}" if walk else "") + "}")
    t0 = time.time()
    pre = None
    if kind in ("P", "K"):
        pre = lambda mm: apply_preset(mm, p, extra)  # noqa: E731
    res, w = run_lua(m, tag, lua, 2600 + wch, pre=pre)
    row = {"preset": p["name"], "idx": p["idx"], "scene": sid, "variant": variant, "kind": kind, "extraFlags": list(extra), "watch": wch,
           "walk": walk, "input": inp, "dest": list(dest) if dest else None, "lua": lua, "writes": w}
    row.update({k: v for k, v in res.items() if k not in ("actors0", "actors1")})
    row["actors0"], row["actors1"] = res.get("actors0"), res.get("actors1")
    row["a0n"] = [a for a in named_actors(res.get("actors0")) if a["file"] not in SKIP_FILES]
    row["a1n"] = [a for a in named_actors(res.get("actors1")) if a["file"] not in SKIP_FILES]
    row["maskW"] = [{"f": r["f"], "sc": r["sc"], "a": r["a"], "old": r["old"], "new": r["new"], "writer": writer_of(r.get("end")),
                     "actor": entry_name(r["entry"]) if r.get("entry") else None, "d": r.get("d")} for r in res.get("maskRows", [])]
    if res.get("s0") and res.get("s1"):
        row["flagDiffPreEnd"] = L.flag_diff(res["s0"]["dump"], res["s1"]["dump"])
        if res.get("sA"):
            row["flagDiffPreArr"] = L.flag_diff(res["s0"]["dump"], res["sA"]["dump"])
    if shot:
        s = m.shot(f"{PREFIX}_{tag}")
        row["screenshot"] = os.path.relpath(s["path"], BASEROM).replace("\\", "/")
    row["seconds"] = round(time.time() - t0, 1)
    row["date"] = stamp()
    log_row(row)
    return row


def brief(row):
    s0, sA, s1 = row.get("s0") or {}, row.get("sA") or {}, row.get("s1") or {}
    fd = row.get("flagDiffPreEnd", {})
    files = sorted({a["file"] for a in row.get("a0n", [])})
    mw = "; ".join(f"f{r['f']} {r['old']:02X}>{r['new']:02X} {r['actor']}" for r in row.get("maskW", [])[:4])
    return (f"p{row['idx']:02d} {row['kind']} {row['variant']:<8} sc={row['scene']:02X}->{row.get('sceneEnd', 0):02X} err={row.get('error')} "
            f"mask0={row.get('mask0', 0):04X} mask1={row.get('mask1', 0):04X} pf0={row.get('pf0', 0):04X} dmf1={row.get('dmf1', 0):04X} "
            f"rel={row.get('releaseN')} act={row.get('act0')}/{row.get('act1')} form={s0.get('form')}>{sA.get('form')}>{s1.get('form')} "
            f"formH={[(h['f'] - (row.get('frame0') or 0), h['form']) for h in row.get('formHist', [])][:4]} "
            f"flags +{len(fd.get('set', []))}/-{len(fd.get('clear', []))} ctl36={row.get('ctl36')}/{row.get('frames')} d36={row.get('d36')} "
            f"maskW[{mw}] {row.get('seconds')}s\n     actors0: {files}")


def control(m, info):
    """Standing positive control: scene 0A from S01r, without and with flag 63."""
    a = trial(m, info, {"idx": 99, "name": "standing", "scene": 10, "flags": []}, "ctl_without63", "C", watch=60, inp="none", stop_free=None, shot=False)
    b = trial(m, info, {"idx": 99, "name": "standing", "scene": 10, "flags": [63]}, "ctl_with63", "P", watch=60, inp="none", stop_free=None, shot=False)
    ok = a.get("mask1") == 0xCFF0 and b.get("mask1") == 0 and a.get("releaseN") is None and b.get("releaseN") == 1
    print("STANDING CONTROL 0A:", "PASS" if ok else "FAIL", f"without63 mask1={a.get('mask1', 0):04X} rel={a.get('releaseN')}; with63 mask1={b.get('mask1', 0):04X} rel={b.get('releaseN')}")
    return ok


def cmd_h1(m, info):
    ok, out = L.h1(m, S01R)
    print("H1 S01r:", ok, out["k"], out["sp"], out["scene"], out["w36"])
    c = control(m, info)
    print("STANDING CONTROL", c)
    return ok and c


def cmd_preset(m, info, ids):
    ps = load_presets()
    for i in ids:
        p = ps[i]
        print(f"=== preset {i} {p['name']} scene ${p['scene']:02X}: {len(p['flags'])} flags, items {p.get('items')}, abilities {p.get('abilities')}", flush=True)
        c = trial(m, info, p, "C", "C")
        print(brief(c), flush=True)
        r = trial(m, info, p, "P", "P")
        w = r["writes"]
        print("   writes:", {k: (v if k != "inv" else v[:8]) for k, v in w.items()}, flush=True)
        print(brief(r), flush=True)
        sk = skip_flags(p["scene"])
        if sk:
            k = trial(m, info, p, "K", "K", extra=sk)
            print(brief(k), flush=True)


def cmd_walk(m, info, idx, kinds, path, watch, dest_xy=None):
    """walk <idx> <kinds PK> <dir:from:to,...> <watch>: preset (P) and preset + skip flags (K) with the player walking through the watch window."""
    ps = load_presets()
    p = ps[idx]
    walk = [(d, int(a), int(b)) for d, a, b in (seg.split(":") for seg in path.split(","))]
    for k in kinds:
        extra = skip_flags(p["scene"]) if k == "K" else ()
        r = trial(m, info, p, "W" + k, "K" if k == "K" else "P", extra=extra, watch=watch, inp="mashA", stop_free=None, walk=walk, dest_xy=dest_xy)
        print(brief(r), flush=True)
        tr = r.get("track") or []
        print("   track:", " ".join(f"{t['w']}:{t['x']},{t['y']}:{t['m']:04X}" for t in tr[:: max(1, len(tr) // 24)]), flush=True)


def cmd_form(m, info):
    """Form trial at $E8 (the natural arrival from $E7 leaves characterForm = 2 and spawns the shimmer actors): the preset with form Will / Shadow /
    Freedan written as a word, 60 frames after the banner, palette checksums and actor lists, against the natural E7 -> E8 run at the same scene."""
    ps = load_presets()
    p18, p17 = ps[18], ps[17]
    out = {}
    for tag, form in (("F0", "Will"), ("F2", "Shadow"), ("F1", "Freedan")):
        r = trial(m, info, dict(p18, form=form), tag, "P", watch=60, inp="none", stop_free=None, cg=True)
        out[tag] = r
    n = trial(m, info, p17, "FN", "P", watch=1100, inp="mashA", stop_free=None, cg=True)
    out["FN"] = n
    for tag, r in out.items():
        s1 = r.get("s1") or {}
        print(tag, "sc", r.get("sceneEnd"), "form", (r.get("s0") or {}).get("form"), ">", s1.get("form"), "pf1", f"{r.get('pf1', 0):04X}", "mask1", f"{r.get('mask1', 0):04X}",
              "act", r.get("act1"), sorted({a["file"] for a in r.get("a1n", [])}), "hp", s1.get("hp"), s1.get("hpMax"), "p1010", f"{s1.get('p1010', 0):04X}", flush=True)
        print("   cg", r.get("cg"), r.get("screenshot"), flush=True)
    base = out["F0"].get("cg") or []
    for tag in ("F2", "F1", "FN"):
        cg = out[tag].get("cg") or []
        print(tag, "palettes differing from F0:", [i for i, (a, b) in enumerate(zip(base, cg)) if a != b], flush=True)
    print("FN vs F2 palettes differing:", [i for i, (a, b) in enumerate(zip(out["F2"].get("cg") or [], out["FN"].get("cg") or [])) if a != b], flush=True)


def save_state_for(m, info, p):
    """Preset run with watch 1 (the first frame after the banner), then save the library state and run the H1 test twice."""
    row = trial(m, info, p, "S" + p.get("suffix", ""), "P", watch=1, inp="none", stop_free=None, shot=True)
    path = os.path.join(STATE_DIR, f"orig_P{p['idx']:02d}_{p['name']}{p.get('suffix', '')}.mss")
    flags = sorted(set(p["flags"]))
    meta = {"scene": p["scene"], "form": p.get("form", "Will"), "preset": p["name"], "flagsWritten": flags, "items": p.get("items", []),
            "abilities": p.get("abilities", []), "gems": p.get("gems", 0)}
    sv = m.call("save_state_file", path=path, note=f"FR50 preset {p['name']} replayed, arrival scene ${p['scene']:02X}, 1 frame after the banner", meta=meta)
    ok, out = L.h1(m, path)
    row2 = {"preset": p["name"], "idx": p["idx"], "state": os.path.basename(path), "h1": ok, "h1out": {k: out[k] for k in ("k", "sp", "scene", "w36", "mask")},
            "saveReply": sv if isinstance(sv, dict) else str(sv)[:200], "arrival": {k: row.get(k) for k in ("mask0", "pf0", "dmf0", "sceneEnd")},
            "screenshot": row.get("screenshot")}
    ok2, out2 = L.h1(m, path)
    row2["h1b"] = ok2
    row2["h1bout"] = {k: out2[k] for k in ("k", "sp", "scene", "w36", "mask")}
    row2["kind"] = "state"
    row2["date"] = stamp()
    log_row(row2)
    return row2


def cmd_state(m, info, ids):
    ps = load_presets()
    for i in ids:
        shadow = isinstance(i, str)
        n = int(i.rstrip("s")) if shadow else i
        p = dict(ps[n], form="Shadow", suffix="_shadow") if shadow else ps[n]
        r = save_state_for(m, info, p)
        print(f"p{n:02d} {r['state']} h1={r['h1']} {r['h1out']} h1b={r['h1b']} {r['h1bout']} arrival={r['arrival']}", flush=True)


def cmd_inv(m, info, ids):
    ps = load_presets()
    hold = "{" + ",".join(f'[{n}]={{"select"}}' for n in range(10, 17)) + "}"
    for i in ids:
        p = ps[i]
        for kind in ("C", "P"):
            lua = f"fr20.visit{{settle=320,hold={hold},tag='inv_{kind}'}}"
            pre = (lambda mm: apply_preset(mm, p)) if kind == "P" else None
            m.call("load_state_file", path=S01R)
            m.call("advance_frame", frames=1)
            w = pre(m) if pre else None
            r = m.run_script_checked(lua, name=f"{PREFIX}_inv", includes=["fr50_kit"], frames=400, turbo=True, timeoutMs=300000, maxLog=100)["result"]
            s = m.shot(f"{PREFIX}_inv_p{i:02d}_{kind}")
            inv = list(m.mem(0x0AB4, 16))
            print(f"p{i:02d} {kind} scene={r.get('sceneEnd')} dmf={r.get('dmf1', 0):04X} mask={r.get('mask1', 0):04X} inv={inv} shot={os.path.relpath(s['path'], BASEROM)}", flush=True)
            log_row({"kind": "inv", "idx": i, "variant": kind, "sceneEnd": r.get("sceneEnd"), "dmf1": r.get("dmf1"), "inv": inv, "writes": w,
                     "screenshot": os.path.relpath(s["path"], BASEROM).replace("\\", "/"), "date": stamp()})


def main():
    cmd = sys.argv[1]
    args = sys.argv[2:]
    m, info = open_o()
    try:
        if cmd == "h1":
            cmd_h1(m, info)
        elif cmd == "preset":
            cmd_preset(m, info, [int(a) for a in args])
        elif cmd == "state":
            cmd_state(m, info, [a if a.endswith("s") else int(a) for a in args])
        elif cmd == "walk":
            cmd_walk(m, info, int(args[0]), args[1], args[2], int(args[3]), tuple(int(v) for v in args[4].split(",")) if len(args) > 4 else None)
        elif cmd == "form":
            cmd_form(m, info)
        elif cmd == "inv":
            cmd_inv(m, info, [int(a) for a in args])
        else:
            raise SystemExit("unknown command " + cmd)
    finally:
        m.close()


if __name__ == "__main__":
    main()
