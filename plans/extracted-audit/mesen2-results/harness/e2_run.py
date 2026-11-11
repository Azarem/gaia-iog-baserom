#!/usr/bin/env python3
"""E2 (palette bundles) driver: one server session, ROM O, scene sweep in chunks (kit/lib/e2_palette.lua), native R1 counters.

usage (from this folder, under a process timeout):
    timeout 1500 python e2_run.py sweep          # 8 chunks of the 228 scene ids, native counters kept for the whole session
    timeout 600  python e2_run.py r1             # not standalone: the sweep subcommand also runs the R1 summary at its end

Everything it writes goes to ../raw/ (E2_sw<k>.txt from the Lua side, E2_run_<cmd>.json from here).
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
STATE = os.path.join(REPO, "rebuilt", "states", "orig_S01r_south-cape-ready.mss")
ARGS = [f"--mcp-lib-dir={os.path.join(RES, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"]

SCENES = [int(x) for x in json.load(open(os.path.join(REPO, "artifacts", "scenes.json")))["ids"]] \
    if False else None


def scene_ids():
    d = json.load(open(os.path.join(REPO, "artifacts", "scenes.json")))
    return [s["id"] for s in d["scenes"]]


def open_session():
    m = Mesen(args=ARGS)
    info = {"server": m.server_info}
    st = m.call("get_server_status")
    info["status0"] = st
    r = m.call("load_rom", path=ROM)
    info["rom"] = r["rom"]
    m.call("pause")
    info["labels"] = m.call("load_labels", path=LABELS, replace=True)["labelsNow"]
    return m, info


def h1(m):
    ls = m.call("load_state_file", path=STATE)
    adv = m.call("advance_frame", frames=120)
    cpu = adv["cpu"]
    scene = m.u16(0x0644)
    ok = ls["romCheck"] == "match" and 0x80 <= cpu["k"] <= 0xBF and 0x100 <= cpu["sp"] <= 0x1FF and scene == 1
    return {"romCheck": ls["romCheck"], "stateSha1": ls["stateRomSha1"], "k": cpu["k"], "sp": cpu["sp"], "scene": scene, "ok": ok}


def run_chunk(m, scenes, fname, tag, post=150, extra=""):
    m.call("load_state_file", path=STATE)
    ids = ",".join(str(i) for i in scenes)
    code = f"e2.run({{{ids}}}, '{fname}', {{post={post}, tag='{tag}', noBanner={{[254]=true,[255]=true}}{extra}}})"
    t0 = time.time()
    r = m.run_script_checked(code, frames=200000, includes=["e2_palette"], turbo=True, timeoutMs=170000, maxLog=5, name="e2_sweep")
    res = r.get("result", {})
    return {"tag": tag, "scenes": len(scenes), "elapsed": round(time.time() - t0, 1), "result": {k: res.get(k) for k in ("scenes", "w36", "nmi", "nev", "bytes", "caps", "timeouts")},
            "files": [(f["name"], f["bytes"], f["sha1"]) for f in r.get("filesWritten", [])]}


def static_rows():
    rows = []
    for line in open(os.path.join(RAW, "E2_static.txt")):
        f = line.rstrip("\n").split("|")
        if len(f) < 14:
            continue
        rows.append({"id": int(f[0]), "off": int(f[2]), "term": int(f[3]), "lo": int(f[7]), "hi": int(f[8])})
    return rows


def r1(m, tag):
    """Native read counters over every bundle: table entry (2 bytes), sub-entry list, frame data (R1, plan 6.2)."""
    ranges = []
    for b in static_rows():
        ranges.append({"name": f"tbl{b['id']:02X}", "start": 1474560 + 2 * b["id"], "end": 1474560 + 2 * b["id"] + 1})
        ranges.append({"name": f"list{b['id']:02X}", "start": b["off"], "end": b["term"]})
        if b["lo"] >= 0:
            ranges.append({"name": f"data{b['id']:02X}", "start": b["lo"], "end": b["hi"]})
    rows = []
    for i in range(0, len(ranges), 120):
        r = m.call("get_access_summary", type="prgRom", ranges=ranges[i:i + 120], cdl=False)
        rows += r.get("ranges", r.get("rows", r if isinstance(r, list) else []))
    json.dump(rows, open(os.path.join(RAW, f"E2_r1_{tag}.json"), "w"))
    return len(rows)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "sweep"
    out = {"cmd": cmd, "date": time.strftime("%Y-%m-%d %H:%M:%S")}
    m, info = open_session()
    out["session"] = info
    try:
        out["h1"] = h1(m)
        print("H1", out["h1"], flush=True)
        if not out["h1"]["ok"]:
            raise SystemExit("H1 failed")
        if cmd == "sweep":
            ids = scene_ids()
            n = 29
            chunks = [ids[i:i + n] for i in range(0, len(ids), n)]
            m.call("reset_access_counters")
            for old in ("E2_r1_sweep.json",):
                if os.path.exists(os.path.join(RAW, old)):
                    os.remove(os.path.join(RAW, old))
            out["chunks"] = []
            for k, ch in enumerate(chunks, 1):
                res = run_chunk(m, ch, f"E2_sw{k}.txt", f"sw{k}")
                out["chunks"].append(res)
                print(res, flush=True)
                out["r1rows"] = r1(m, f"sw{k}")   # native counters are cleared by every load_state_file: one dump per chunk
    finally:
        path = os.path.join(RAW, f"E2_run_{cmd}.json")
        json.dump(out, open(path, "w"), indent=1)
        m.close()


if __name__ == "__main__":
    main()
