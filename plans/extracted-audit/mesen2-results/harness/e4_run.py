#!/usr/bin/env python3
"""E4 (HDMA, windows, parallax, credits) driver: one private server session, ROM O (kit/lib/e4_kit.lua).

usage (from this folder, under a process timeout):
    python e4_run.py ident                 # ROM identity, H1 on the existing states used
    python e4_run.py build NAME [NAME...]  # build + H1-validate S19 states by quick warp (names in WARP)
    python e4_run.py sample NAME [NAME...] # 300-frame sampling (every 30) + screenshots on a state (names in SAMPLE)
    python e4_run.py sweep                 # OQ-32 bind census over all scenes (chunks)
    python e4_run.py chain                 # OQ-I035-3 accumulator carry-over across scene changes
Everything it writes goes to ../raw/ (E4_*.json / E4_*.txt) and ../screenshots/ (by the server).
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
RES = os.path.join(REPO, "plans", "extracted-audit", "mesen2-results")
RAW = os.path.join(RES, "raw")
ROM = os.path.join(REPO, "rebuilt", "Illusion of Gaia.smc")
LABELS = os.path.join(REPO, "artifacts", "labels", "iog-original.mlb")
STATES = os.path.join(REPO, "rebuilt", "states")
S01R = os.path.join(STATES, "orig_S01r_south-cape-ready.mss")
ARGS = [f"--mcp-lib-dir={os.path.join(RES, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"]
INC = ["gaia_kit", "e1_display", "e4_kit"]


def sp(name):
    return os.path.join(STATES, name)


# name -> (state file written by build, scene, flags from sidecar of another state, noBanner, note)
WARP = {
    "dream":   dict(scene=0x2A, note="Gold Ship dream (Shira) scene $2A, quick warp from S01r"),
    "s32":     dict(scene=0x32, note="scene $32, quick warp from S01r"),
    "se9":     dict(scene=0xE9, note="scene $E9, quick warp from S01r"),
    "sea":     dict(scene=0xEA, note="scene $EA, quick warp from S01r"),
    "dao":     dict(scene=0xC3, note="Dao scene $C3, quick warp from S01r"),
    "credits": dict(scene=0xF7, noBanner=True, note="credits scene $F7, quick warp from S01r"),
    "sc03":    dict(scene=0x03, note="scene $03 (parallax $02), quick warp from S01r"),
    "sc2b":    dict(scene=0x2B, note="scene $2B (parallax $06,$05), quick warp from S01r"),
    "sc2d":    dict(scene=0x2D, note="scene $2D (parallax $07,$06,$08,$05), quick warp from S01r"),
    "se5":     dict(scene=0xE5, note="scene $E5 (parallax $24 and others), quick warp from S01r"),
    "mu":      dict(scene=0x67, flagsFrom="orig_P09_before_vampires.mss", note="Mu vampire lair $67 with the flags of orig_P09_before_vampires, quick warp from S01r"),
}
# name -> (state to load, extra lua opts, label)
SAMPLE = {
    "dream":   dict(state="orig_E4_dream.mss", opts="circ=true", at="{[1]=function() iog.setEventFlag(0x0E) end}", note="flag $0E set at the first frame (Shira's talk handler sets it first)"),
    "dream_fine": dict(state="orig_E4_dream.mss", opts="circ=true", at="{[1]=function() iog.setEventFlag(0x0E) end}", every=6, total=66, note="flag $0E set at the first frame; every 6 frames"),
    "credits_circle": dict(state="orig_E4_credits_circle.mss", opts="circ=true"),
    "credits_circle_fine": dict(state="orig_E4_credits_circle.mss", opts="circ=true,maxRuns=100", every=8, total=96),
    "diary_copy": dict(state="orig_S07_diary.mss", opts="", every=1, total=10, at="{[1]=function() emu.write16(0x0D92, 0, emu.memType.snesWorkRam); emu.write16(0x0D96, 2, emu.memType.snesWorkRam) end}", note="slot cursor $0D92 forced to 0 and copy target $0D96 forced to 2 (not a natural copy flow)"),
    "dream_noflag": dict(state="orig_E4_dream.mss", opts="", note="no flag poke: control for the dream scene idle"),
    "s32":     dict(state="orig_E4_s32.mss", opts="cam=true"),
    "se9":     dict(state="orig_E4_se9.mss", opts="cam=true"),
    "sea":     dict(state="orig_E4_sea.mss", opts="cam=true"),
    "dao":     dict(state="orig_E4_dao.mss", opts="acc=true"),
    "credits": dict(state="orig_E4_credits.mss", opts="circ=true"),
    "title":   dict(state="orig_S06_title.mss"),
    "diary":   dict(state="orig_S07_diary.mss"),
    "sc03":    dict(state="orig_E4_sc03.mss", opts="acc=true"),
    "sc2b":    dict(state="orig_E4_sc2b.mss", opts="acc=true"),
    "sc2d":    dict(state="orig_E4_sc2d.mss", opts="acc=true"),
    "se5":     dict(state="orig_E4_se5.mss", opts="acc=true"),
    "mu":      dict(state="orig_E4_mu.mss", opts="circ=true"),
    "mu_poke": dict(state="orig_E4_mu.mss", opts="circ=true", every=1, total=6, at="{[1]=function() emu.write16(0xF6, 0x80, emu.memType.snesWorkRam); emu.write16(0xFA, 0x70, emu.memType.snesWorkRam); emu.write16(0xFE, 0x30, emu.memType.snesWorkRam); emu.write(0x2132, 0x3F, emu.memType.snesMemory) end}", note="forced test: circle parameters $F6/$FA/$FE poked to (128,112,48) and COLDATA red 31 written once; the vampire actors were not triggered"),
}


def scene_ids():
    d = json.load(open(os.path.join(REPO, "artifacts", "scenes.json")))
    return [s["id"] for s in d["scenes"]]


def open_session():
    m = Mesen(args=ARGS)
    info = {"server": m.server_info}
    info["status0"] = m.call("get_server_status")
    r = m.call("load_rom", path=ROM)
    info["rom"] = r["rom"]
    m.call("pause")
    info["labels"] = m.call("load_labels", path=LABELS, replace=True)["labelsNow"]
    return m, info


def h1(m, path, scene=None):
    ls = m.call("load_state_file", path=path)
    adv = m.call("advance_frame", frames=120)
    cpu = adv["cpu"]
    sc = m.u16(0x0644)
    ok = ls["romCheck"] == "match" and 0x80 <= cpu["k"] <= 0xCF and 0x100 <= cpu["sp"] <= 0x1FF and (scene is None or sc == scene)
    return {"state": os.path.basename(path), "romCheck": ls["romCheck"], "stateSha1": ls.get("stateRomSha1"), "k": cpu["k"], "sp": cpu["sp"], "scene": sc, "ok": ok}


def dump(name, obj):
    p = os.path.join(RAW, name)
    json.dump(obj, open(p, "w"), indent=1)
    return p


def cmd_ident():
    m, info = open_session()
    try:
        rom = m.call("get_rom_info")
        info["romInfo"] = {k: rom.get(k) for k in rom if k in ("fileSha1", "fileCrc32", "fileSizeBytes", "path", "name", "romSha1", "crc32", "sha1", "sizeBytes", "headerlessSizeBytes")} or rom
        info["h1"] = []
        for n, sc in (("orig_S01r_south-cape-ready.mss", 1), ("orig_S06_title.mss", 0xFC), ("orig_S07_diary.mss", 0xFA), ("orig_P09_before_vampires.mss", 0x67)):
            info["h1"].append(h1(m, sp(n), sc))
        print(json.dumps(info, indent=1)[:3500])
        dump("E4_ident.json", info)
    finally:
        m.close()


def build_one(m, name):
    w = WARP[name]
    flags = []
    if "flagsFrom" in w:
        flags = json.load(open(sp(w["flagsFrom"]) + ".json"))["meta"]["flagsWritten"]
    m.call("load_state_file", path=S01R)
    opts = f"scene={w['scene']}, flags={{{','.join(str(f) for f in flags)}}}, post=20, tag='build_{name}'"
    if w.get("noBanner"):
        opts += ", noBanner=true"
    r = m.run_script_checked(f"e4.warp{{{opts}}}", frames=6000, includes=INC, turbo=True, timeoutMs=80000, maxLog=5, name="e4_warp")
    res = r.get("result", {})
    path = sp(f"orig_E4_{name}.mss")
    meta = {"scene": w["scene"], "preset": f"E4 quick warp from S01r", "flagsWritten": flags, "banner": res.get("banner"), "arriveFrame": res.get("arriveFrame")}
    m.call("save_state_file", path=path, note=f"E4 {w['note']}; saved 20 frames after the banner/arrival", meta=meta)
    # per-scene arrival census into raw
    dump(f"E4_build_{name}.json", {"result": {k: res.get(k) for k in res if k != "census"}, "census": res.get("census")})
    v = h1(m, path, w["scene"])
    return {"name": name, "scene": res.get("scene"), "arrive": res.get("arriveFrame"), "banner": res.get("banner"), "ncensus": res.get("ncensus"), "h1": v, "binds": res.get("binds"),
            "w36": res.get("w36"), "nmi": res.get("nmi")}


def build_credits_circle(m):
    """Run the credits state forward until the V1 circle thinker has started ($FE leaves $FFFF), save that frame."""
    m.call("load_state_file", path=sp("orig_E4_credits.mss"))
    code = """local WR = emu.memType.snesWorkRam
local n = 0
kit.onFrame(function()
  n = n + 1
  local fe = emu.read16(0xFE, WR, false)
  if fe ~= 0xFFFF and fe < 0x8000 then kit.finish({ n = n, n36 = emu.read16(0x36, WR, false), fe = fe, cx = emu.read16(0xF6, WR, false), cy = emu.read16(0xFA, WR, false) }) end
end)"""
    r = m.run_script_checked(code, frames=30000, includes=["gaia_kit"], turbo=True, timeoutMs=170000, maxLog=20, name="e4_until")
    res = r.get("result", {})
    path = sp("orig_E4_credits_circle.mss")
    m.call("save_state_file", path=path, note="E4 credits scene $F7 at the frame the V1 circle thinker sets its radius word ($FE leaves $FFFF); from orig_E4_credits.mss", meta={"scene": 0xF7, "preset": "E4 credits_circle", "runFrames": res.get("n"), "fe": res.get("fe")})
    v = h1(m, path, 0xF7)
    return {"name": "credits_circle", "until": res, "h1": v}


def cmd_build(names):
    m, info = open_session()
    out = []
    try:
        for n in names:
            t0 = time.time()
            try:
                row = build_credits_circle(m) if n == "credits_circle" else build_one(m, n)
            except Exception as e:  # report and go on, a failed build is a data point
                row = {"name": n, "error": str(e)[:600]}
            row["elapsed"] = round(time.time() - t0, 1)
            print(json.dumps(row)[:1200])
            out.append(row)
        dump(f"E4_build_{'_'.join(names)[:40]}.json", out)
    finally:
        m.close()


def sample_one(m, name, every=30, total=300):
    s = SAMPLE[name]
    every, total = s.get("every", every), s.get("total", total)
    path = sp(s["state"])
    v = h1(m, path)
    m.call("load_state_file", path=path)
    at = s.get("at", "nil")
    opts = f"every={every}, total={total}, tag='{name}', at={at}"
    if s.get("opts"):
        opts += ", " + s["opts"]
    code = f"local S = e4.install{{census=true}}\ne4.sampler(S, {{{opts}}})"
    m.call("load_script", code=code, name="e4_sample", includes=INC)
    shots = []
    stop = None
    for k in range(total // every):
        adv = m.call("advance_frame", frames=every, turbo=True)
        stop = adv.get("stopReason") if isinstance(adv, dict) else None
        sh = m.shot(f"E4_{name}_t{(k + 1) * every:03d}")
        shots.append(sh.get("path") or sh.get("file") or sh)
    res = m.call("get_script_result", name="e4_sample").get("result") or {}
    log = m.call("get_script_log", name="e4_sample", max=5000)
    log["entries"] = [e for e in log.get("entries", []) if not e.get("text", "").startswith("Registered memory callback")][:60]
    m.call("unload_script", name="e4_sample")
    dump(f"E4_sample_{name}.json", {"h1": v, "result": res, "shots": shots, "log": log, "stop": stop})
    return v, res, shots, log


def cmd_sample(names):
    m, info = open_session()
    try:
        for n in names:
            t0 = time.time()
            try:
                v, res, shots, log = sample_one(m, n)
                print(n, "h1", json.dumps(v), "elapsed", round(time.time() - t0, 1))
                print("\n".join(res.get("lines", [])) if isinstance(res, dict) else res)
                print("binds", json.dumps(res.get("binds")), "w36", res.get("w36"), "nmi", res.get("nmi"), "maxPF", res.get("maxPF"))
                print("LOG", [e["text"][:300] for e in log.get("entries", [])][:8])
            except Exception as e:
                print(n, "ERROR", str(e)[:800])
    finally:
        m.close()


def cmd_sweep(chunk=29):
    ids = scene_ids()
    m, info = open_session()
    try:
        outs = []
        for k in range(0, len(ids), chunk):
            sc = ids[k:k + chunk]
            m.call("load_state_file", path=S01R)
            t0 = time.time()
            code = (f"e4.bindSweep{{scenes={{{','.join(str(i) for i in sc)}}}, post=90, tag='sw{k // chunk}', noBanner={{[254]=true,[255]=true}}}}")
            r = m.run_script_checked(code, frames=200000, includes=INC + ["e2_palette"], turbo=True, timeoutMs=170000, maxLog=5, name="e4_sweep")
            res = r.get("result", {})
            print(k // chunk, len(sc), res, round(time.time() - t0, 1))
            outs.append({"chunk": k // chunk, "scenes": sc, "result": res, "files": [(f["name"], f["bytes"], f["sha1"]) for f in r.get("filesWritten", [])]})
        dump("E4_run_sweep.json", outs)
    finally:
        m.close()


def cmd_chain():
    m, info = open_session()
    try:
        m.call("load_state_file", path=S01R)
        code = "e4.chain{tag='chain', scenes={{0x2B,150},{0xE5,150},{0x2B,100},{0x2D,60}}}"
        r = m.run_script_checked(code, frames=20000, includes=INC, turbo=True, timeoutMs=120000, maxLog=5, name="e4_chain")
        res = r.get("result", {})
        print("\n".join(res.get("log", [])))
        print("\n".join(res.get("par", [])))
        dump("E4_chain.json", res)
    finally:
        m.close()


if __name__ == "__main__":
    c, a = sys.argv[1], sys.argv[2:]
    if c == "ident":
        cmd_ident()
    elif c == "build":
        cmd_build(a)
    elif c == "sample":
        cmd_sample(a)
    elif c == "sweep":
        cmd_sweep()
    elif c == "chain":
        cmd_chain()
