#!/usr/bin/env python3
"""R2 scene sweep driver (one server session, one `run_script` per scene).

For each scene id: `load_state_file` of the ready state (S01r of the ROM under test), then ONE checked `run_script` with
`includes ["gaia_kit"]` whose Lua is `r2.run{scene=..., pcs={...}}` (kit/lib/r2_kit.lua): the script writes sceneNext `$0642`, watches
the load, takes the 180-NMI sample and the sample `post` NMIs after the arrival, and returns one result row. This script appends
the row to raw/R2_<tag>.jsonl (resumable: ids already in the file are skipped) and one line per scene to raw/R2_<tag>.md.

usage (from this folder, under a process timeout):
    timeout 1500 python r2_sweep.py --rom O --tag O_sweep [--scenes 0-255 | 9,74,...] [--post 180] [--flagpoke 65535]
    timeout 1500 python r2_sweep.py --rom R --tag R_sweep --scenes 9,72,...
"""
import argparse
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
ARGS = [f"--mcp-lib-dir={os.path.join(RES, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"]

ROMS = {
    "O": {
        "rom": os.path.join(REPO, "rebuilt", "Illusion of Gaia.smc"),
        "labels": os.path.join(REPO, "artifacts", "labels", "iog-original.mlb"),
        "state": os.path.join(REPO, "rebuilt", "states", "orig_S01r_south-cape-ready.mss"),
    },
    "R": {
        "rom": os.path.join(REPO, "rebuilt", "Illusion of Gaia - Rebuilt.smc"),
        "labels": os.path.join(REPO, "artifacts", "labels", "iog-rebuilt.mlb"),
        "state": os.path.join(REPO, "rebuilt", "states", "R-0cfcb558_S01r_south-cape-ready.mss"),
    },
}

# hook = (label, delta from the label to the instruction); the O offsets are the decimal keys of db-us/names
#  SceneCmd_ConfigDisplay 166509 -> ASL after the operand read 166518 (+9)
HOOKS = {
    "nmi": ("NmiHandler", 0),
    "cfg": ("SceneCmd_ConfigDisplay", 9),
    "m3": ("SceneCmd_LoadBgTiles", 165107 - 164957),
    "l4": ("Load4bppPage", 0),
    "fgj": ("SceneCmd_LoadLayerMaps", 165943 - 165820),
    "lowv": ("DmaLowVramTileset", 0),
    "fcs": ("FindCurrentScene", 0),
    "ldpg": ("LoadPlayerGraphics", 0),
    "par": ("ParallaxThinkerEntry", 0),
    "copspawn": ("SpawnThinkerParam", 37910 - 37888),
    "tefidx": ("TestEventFlag", 45311 - 45307),
}
O_OFFSETS = {"NmiHandler": 33528, "SceneCmd_ConfigDisplay": 166509, "SceneCmd_LoadBgTiles": 164957, "Load4bppPage": 165266,
             "SceneCmd_LoadLayerMaps": 165820, "DmaLowVramTileset": 166182, "FindCurrentScene": 167154, "LoadPlayerGraphics": 253944,
             "ParallaxThinkerEntry": 47245, "SpawnThinkerParam": 37888, "TestEventFlag": 45307}


def parse_ids(s):
    out = []
    for part in s.split(","):
        if "-" in part:
            a, b = part.split("-")
            out.extend(range(int(a, 0), int(b, 0) + 1))
        else:
            out.append(int(part, 0))
    return out


def resolve_pcs(m, which):
    pcs = {}
    info = {}
    for key, (label, delta) in HOOKS.items():
        if which == "O":
            base = O_OFFSETS[label]
        else:
            r = m.call("get_label_address", label=label)
            base = int(r["address"])
        pcs[key] = base + delta
        info[key] = (label, base, delta, pcs[key])
    # the word of ParallaxThinkerEntry as the COP spawn stores it (offset in the bank: ROM offset & 0xFFFF)
    pcs["parw"] = pcs["par"] & 0xFFFF
    return pcs, info


def lua_table(d):
    return "{" + ", ".join(f"{k}={v}" for k, v in d.items()) + "}"


def fmt_line(r):
    s180 = r.get("sample180") or {}
    coll = r.get("coll") or {}
    hist = coll.get("hist") or {}
    hs = " ".join(f"{k}:{v}" for k, v in hist.items() if v)
    cpu = r.get("cpu") or {}
    cov = r.get("cov") or {}
    cv = " ".join(f"{k}{v}" for k, v in cov.items() if v)
    changed = "yes" if (r.get("endScene") != r.get("base")) else "no"
    seen = ">".join(f"{x:02X}" for x in r.get("seen", []))
    par = ",".join(r.get("par", [])) or "-"
    fields = [
        "%02X" % r["scene"],
        (("arr@%d load%s" % (r["arriveN"], r.get("loadFrames", "?"))) if r.get("arrived") else "NO(%s)" % r.get("why")),
        ("%02X" % s180["scene"]) if s180 else "-",
        "%02X/%02X" % (r.get("endScene", 0), r.get("endNext", 0)),
        changed, seen,
        str(cpu.get("bgMode", "-")), "%02X" % r.get("bgm", 0),
        ",".join(r.get("presets", [])) or "-",
        str(r.get("actors", 0)),
        ("%dx%d" % (coll.get("w", 0), coll.get("h", 0))) if coll else "-",
        hs or "-",
        par,
        "%d/%d/%d" % (r.get("nmi", 0), r.get("w36", 0), r.get("frames", 0)),
        "%02X:%04X sp%04X" % (cpu.get("k", 0), cpu.get("pc", 0), cpu.get("sp", 0)),
        cv or "-",
        "ff%s" % json.dumps(r.get("ffTests"), separators=(",", ":")),
    ]
    return "| " + " | ".join(fields) + " |"


HEADER = ("| id | arrival (NMIs after write) | at 180: scene | end scene/next | changed | scenes seen | PPU mode | BGM $06F2 | preset idx | actors $0DBC | cells | B1 low-nibble counts | parallax types | NMI/w36/frames | cpu at end | coverage hooks | flag $FF tests |\n"
          "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default="O", choices=["O", "R"])
    ap.add_argument("--tag", default="O_sweep")
    ap.add_argument("--scenes", default="0-255")
    ap.add_argument("--post", type=int, default=180)
    ap.add_argument("--maxwait", type=int, default=700)
    ap.add_argument("--flagpoke", type=int, default=None)
    ap.add_argument("--nocoll", action="store_true")
    ap.add_argument("--shots", default="", help="scene ids that get a screenshot after the run (label R2_<tag>_<id>)")
    ap.add_argument("--force", action="store_true", help="ignore rows already stored")
    a = ap.parse_args()
    cfg = ROMS[a.rom]
    jl = os.path.join(RAW, f"R2_{a.tag}.jsonl")
    md = os.path.join(RAW, f"R2_{a.tag}.md")
    done = {}
    if os.path.exists(jl) and not a.force:
        for line in open(jl):
            line = line.strip()
            if line:
                r = json.loads(line)
                done[r["scene"]] = r
    ids = parse_ids(a.scenes)
    shots = set(parse_ids(a.shots)) if a.shots else set()
    todo = [i for i in ids if i not in done]
    m = Mesen(args=ARGS)
    meta = {}
    try:
        st = m.call("get_server_status")
        meta["server"] = st["serverVersion"]
        r = m.call("load_rom", path=cfg["rom"])
        meta["rom"] = r["rom"]
        m.call("pause")
        lb = m.call("load_labels", path=cfg["labels"], replace=True)
        meta["labels"] = lb.get("labelsNow")
        pcs, pinfo = resolve_pcs(m, a.rom)
        meta["pcs"] = pinfo
        # H1 validity of the state
        ls = m.call("load_state_file", path=cfg["state"])
        adv = m.call("advance_frame", frames=120)
        cpu = adv["cpu"]
        sc = m.u16(0x0644)
        h1 = {"romCheck": ls.get("romCheck"), "stateSha1": ls.get("stateRomSha1"), "k": cpu["k"], "sp": cpu["sp"], "scene": sc,
              "ok": ls.get("romCheck") == "match" and (0x80 <= cpu["k"] <= 0xBF or 0xC0 <= cpu["k"] <= 0xCF) and 0x100 <= cpu["sp"] <= 0x1FF and sc == 1}
        meta["h1"] = h1
        print("H1", h1, flush=True)
        if not h1["ok"]:
            print("H1 failed: stop", flush=True)
            return 2
        print("ROM", meta["rom"]["fileSha1"], meta["rom"]["fileSizeBytes"], "pcs", pcs, flush=True)
        json.dump(meta, open(os.path.join(RAW, f"R2_{a.tag}_meta.json"), "w"), indent=1)
        newfile = not os.path.exists(md) or a.force
        with open(md, "w" if newfile else "a") as fmd, open(jl, "w" if a.force else "a") as fjl:
            if newfile:
                fmd.write(HEADER + "\n")
            for sid in todo:
                t0 = time.time()
                m.call("load_state_file", path=cfg["state"])
                o = {"scene": sid, "post": a.post, "maxWait": a.maxwait, "pcs": lua_table(pcs)}
                code = "r2.run{scene=%d, post=%d, maxWait=%d, pcs=%s%s%s%s}" % (
                    sid, a.post, a.maxwait, lua_table(pcs),
                    (", flagPoke=%d" % a.flagpoke) if a.flagpoke is not None else "",
                    ", noBanner=true" if sid in (0xFE, 0xFF) else "",
                    ", coll=false" if a.nocoll else "")
                try:
                    res = m.run_script_checked(code, frames=a.maxwait + 400, includes=["gaia_kit", "r2_kit"], turbo=True, timeoutMs=120000, maxLog=3, name="r2")
                    row = res.get("result", {})
                except Exception as e:  # noqa: BLE001
                    row = {"scene": sid, "why": "error: %s" % str(e)[:200], "arrived": False}
                    print("scene %02X: ERROR %s" % (sid, e), flush=True)
                row["scene"] = sid
                if sid in shots:
                    try:
                        sh = m.call("take_screenshot", label="R2_%s_%02X" % (a.tag, sid), returnImage=False)
                        row["shot"] = sh.get("path")
                    except Exception as e:  # noqa: BLE001
                        row["shot"] = "error %s" % str(e)[:80]
                row["elapsed"] = round(time.time() - t0, 1)
                fjl.write(json.dumps(row) + "\n")
                fjl.flush()
                if "endScene" in row:
                    fmd.write(fmt_line(row) + "\n")
                else:
                    fmd.write("| %02X | ERROR %s |\n" % (sid, row.get("why")))
                fmd.flush()
                print("scene %02X %s arrN=%s end=%s bg=%s pre=%s act=%s %.1fs" % (
                    sid, "ok" if row.get("arrived") else "NO", row.get("arriveN"), "%02X" % row.get("endScene", 0), (row.get("cpu") or {}).get("bgMode"),
                    ",".join(row.get("presets", [])), row.get("actors"), row["elapsed"]), flush=True)
    finally:
        m.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
