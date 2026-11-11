#!/usr/bin/env python3
"""FR40 scene entry sweep (server 0.6.0, ROM O). Drives kit/lib/fr40_kit.lua, one atomic run_script per trial from the standing state S01r.

usage (from this folder, under a process timeout):
  fr40.py h1                      identity + H1 validity test of S01r (twice) + standing control (scene 0A with and without flag 63)
  fr40.py a 1 2 3 ...             step (a): quick warp with no flags, banner, 60 frames, 20-frame hold of each direction, screenshot
  fr40.py a --batch 0 20          the scenes at positions 0..19 of the sorted id list (a positive control closes the batch)
  fr40.py c [ids]                 step (c): scenes that land in a wall or pocket: retry with the scene-warp destinations
  fr40.py b 8 10 ...              step (b): the long watch (no input, then A mashed) and the draft flags, then every subset of the draft flags
  fr40.py t SCENE [flag ...]      one arrival with the given flags (watch 60) plus the direction test, printed

Writes only under mesen2-results/ (raw/, raw/screenshots/). Rows: raw/FR40_rows.jsonl (one JSON object per trial; the last row per
(variant, scene) wins). Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7.
"""
import itertools
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr20_lib as L  # noqa: E402
from a_common import BASEROM, RAW, S01R, open_session, stamp  # noqa: E402
from mcp_client import ScriptRunError  # noqa: E402

PREFIX = "FR40"
O_SHA1 = "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
ROWS = os.path.join(RAW, "FR40_rows.jsonl")
DRAFT = os.path.join(BASEROM, "plans", "flags", "results", "specs", "FL32_scene-flags.json")
SCENES = os.path.join(BASEROM, "artifacts", "scenes.json")


def scene_ids():
    with open(SCENES, encoding="utf-8") as f:
        return sorted(json.load(f)["ids"])


def draft():
    with open(DRAFT, encoding="utf-8") as f:
        return json.load(f)


def open_o():
    m, info = open_session()
    assert info["fileSha1"] == O_SHA1, f"unexpected ROM {info['fileSha1']}"
    return m, info


def run(m, name, lua, frames, state=S01R):
    m.call("load_state_file", path=state)
    m.call("advance_frame", frames=1)
    r = m.run_script_checked(lua, name=f"{PREFIX}_{name}", includes=["fr40_kit"], frames=frames, turbo=True, timeoutMs=900000, maxLog=300)
    res = r["result"]
    res["stopReason"], res["framesAdvanced"] = r.get("stopReason"), r.get("framesAdvanced")
    return res


def lit(x):
    return L.lit(x)


def log_row(row):
    with open(ROWS, "a", encoding="utf-8") as f:
        f.write(json.dumps(row) + "\n")


def trial(m, info, sid, variant, flags=(), watch=60, inp="none", stop_free=None, shot=True, move=True, dest=None):
    """Arrival of scene `sid` with `flags` set before the warp, a watch window, a screenshot at its end and the direction test."""
    t0 = time.time()
    tag = f"s{sid:02X}_{variant}"
    extra = (f",stopFree={stop_free}" if stop_free else "") + (f",dest={lit(list(dest))}" if dest else "")
    lua = f"fr40.arrive{{scene={sid},set={lit(list(flags))},watch={watch},input={lit(inp)},tag={lit(tag)}{extra}}}"
    frames = 2600 + watch
    res = run(m, tag, lua, frames)
    row = {"scene": sid, "variant": variant, "flags": list(flags), "watch": watch, "input": inp, "dest": list(dest) if dest else None, "lua": lua}
    row.update({k: v for k, v in res.items() if k not in ("actors0", "actors1")})
    row["actors0"], row["actors1"] = res.get("actors0"), res.get("actors1")
    if res.get("flagsPre") and res.get("flags1"):
        row["flagDiffPreEnd"] = L.flag_diff(res["flagsPre"], res["flags1"])
    if res.get("flags0") and res.get("flags1"):
        row["flagDiffArrEnd"] = L.flag_diff(res["flags0"], res["flags1"])
    if shot:
        s = m.shot(f"{PREFIX}_{tag}")
        row["screenshot"] = os.path.relpath(s["path"], BASEROM).replace("\\", "/")
    if move and not res.get("error") and res.get("sceneEnd") == sid:
        mv = m.run_script_checked("fr40.move{}", name=f"{PREFIX}_move", includes=["fr40_kit"], frames=120, turbo=True, timeoutMs=300000,
                                  maxLog=100)["result"]
        row["move"] = mv
    elif move and not res.get("error"):
        row["moveSkipped"] = f"scene changed to {res.get('sceneEnd')}"
    row["seconds"] = round(time.time() - t0, 1)
    row["date"] = stamp()
    log_row(row)
    return row


def moved(row):
    mv = row.get("move")
    if not mv:
        return None
    return {s["dir"]: (s["dx"], s["dy"]) for s in mv["seg"] if "dx" in s}


def state(row):
    """Observed state at the end of the watch window: error | left (scene changed) | locked (mask or player flag $0800) | dialog (dmf $2000)
    | still (mask 0, no dialog, no movement in any direction: a wall landing or a blocked spawn) | free."""
    if row.get("error"):
        return "error"
    if row.get("sceneEnd") != row["scene"]:
        return "left"
    mv = moved(row)
    mvd = (row.get("move") or {}).get("dmf1", 0) | row.get("dmf1", 0)
    if row.get("mask1") or (row.get("pf1", 0) & 0x0800):
        return "locked"
    if mvd & 0x2000:
        return "dialog"
    if mv is None or not any(abs(dx) + abs(dy) >= 2 for dx, dy in mv.values()):
        return "still"
    return "free"


def is_free(row):
    return state(row) == "free"


def brief(row):
    mv = moved(row)
    mvs = "-" if mv is None else " ".join(f"{d[0]}{dx:+d}{dy:+d}" for d, (dx, dy) in mv.items())
    return (f"s{row['scene']:02X} {row['variant']:<10} flags={row['flags']} err={row.get('error')} end={row.get('sceneEnd', 0):02X} "
            f"mask0={row.get('mask0', 0):04X} mask1={row.get('mask1', 0):04X} dmf1={row.get('dmf1', 0):04X} pf1={row.get('pf1', 0):04X} act={row.get('act0')}/{row.get('act1')} "
            f"ban={row.get('banner')} rel={row.get('releaseN')} ctl36={row.get('ctl36')}/{row.get('frames')} d36={row.get('d36')} "
            f"pos={row.get('pos0')} mv[{mvs}] {state(row)} {row.get('seconds')}s")


def control(m, info):
    """Standing positive control: scene 0A without and with flag 63 (quick warp from S01r)."""
    a = trial(m, info, 10, "ctl_without63", [])
    b = trial(m, info, 10, "ctl_with63", [63])
    ok = a.get("mask1") == 0xCFF0 and b.get("mask1") == 0 and is_free(b) and not is_free(a)
    print("CONTROL 0A:", "PASS" if ok else "FAIL")
    print("  ", brief(a))
    print("  ", brief(b))
    return ok


def cmd_h1(m, info):
    ok, out = L.h1(m, S01R)
    print("H1 S01r:", ok, out["k"], out["sp"], out["scene"], out["w36"])
    c = control(m, info)
    print("STANDING CONTROL", c)


def cmd_a(m, info, ids):
    for sid in ids:
        try:
            row = trial(m, info, sid, "a", [])
        except ScriptRunError as e:
            print(f"s{sid:02X} SCRIPT ERROR {e}")
            raise
        print(brief(row), flush=True)


SPAWN = os.path.join(RAW, "FR40_spawn.json")
WARP_DEST = os.path.join(RAW, "FR40_warp_dest.json")


def spawn_map():
    if os.path.exists(SPAWN):
        with open(SPAWN, encoding="utf-8") as f:
            return {int(k): v for k, v in json.load(f).items()}
    return {}


def last_rows(variant_prefix):
    out = {}
    if not os.path.exists(ROWS):
        return out
    with open(ROWS, encoding="utf-8") as f:
        for line in f:
            r = json.loads(line)
            if r["variant"].startswith(variant_prefix):
                out[(r["variant"], r["scene"])] = r
    return out


def cmd_c(m, info, ids=None):
    """Scenes whose quick warp lands in a wall (state `still`) or in a pocket (free in one direction only): retry with the destinations of
    the scene-warp table rows that lead into the scene (full warp: warpDestX/Y, facing, scroll)."""
    a = {sid: r for (v, sid), r in last_rows("a").items() if v == "a"}
    if ids is None:
        ids = []
        for sid in sorted(a):
            r = a[sid]
            st = state(r)
            if st == "still" and sid != 0xFF:
                ids.append(sid)
            elif st == "free":
                tot = sorted(abs(dx) + abs(dy) for dx, dy in moved(r).values())
                if tot[-1] < 30 or tot[-2] < 8:
                    ids.append(sid)
    with open(WARP_DEST, encoding="utf-8") as f:
        wd = json.load(f)
    sm = spawn_map()
    for sid in ids:
        cands = []
        for c in wd.get(str(sid), []):
            t = (c["x"], c["y"], c["face"], c["scroll"])
            if t not in cands:
                cands.append(t)
        if not cands:
            print(f"s{sid:02X} no scene-warp row leads into this scene", flush=True)
            sm[sid] = None
            continue
        for i, t in enumerate(cands):
            r = trial(m, info, sid, f"spawn{i}", [], dest=t)
            print(brief(r), "dest", t, flush=True)
            if state(r) != "still":
                sm[sid] = list(t)
                break
        else:
            sm[sid] = None
        with open(SPAWN, "w", encoding="utf-8") as f:
            json.dump({str(k): v for k, v in sm.items()}, f, indent=0)


def cmd_b(m, info, ids):
    d = draft()
    sm = spawn_map()
    for sid in ids:
        flags = d[str(sid)]["flags"]
        dest = sm.get(sid)
        r0 = trial(m, info, sid, "long_none", [], watch=1500, inp="none", stop_free=40, shot=False, move=False, dest=dest)
        print(brief(r0), flush=True)
        if not (r0.get("releaseN")):
            r1 = trial(m, info, sid, "long_mash", [], watch=1500, inp="mashA", stop_free=40, shot=False, move=False, dest=dest)
            print(brief(r1), flush=True)
        if flags:
            r2 = trial(m, info, sid, "draft", flags, dest=dest)
            print(brief(r2), flush=True)
            if is_free(r2) and len(flags) > 1:
                for k in range(1, len(flags)):
                    done = False
                    for sub in itertools.combinations(flags, k):
                        r3 = trial(m, info, sid, "sub" + "+".join(map(str, sub)), list(sub), dest=dest)
                        print(brief(r3), flush=True)
                        if is_free(r3):
                            done = True
                    if done:
                        break


def main():
    cmd = sys.argv[1]
    args = sys.argv[2:]
    m, info = open_o()
    try:
        if cmd == "h1":
            cmd_h1(m, info)
        elif cmd == "a":
            if args and args[0] == "--batch":
                lo, hi = int(args[1]), int(args[2])
                ids = scene_ids()[lo:hi]
                print("scenes", [f"{s:02X}" for s in ids])
                ok1 = control(m, info)
                cmd_a(m, info, ids)
                ok2 = control(m, info)
                print("BATCH CONTROL", ok1, ok2)
            else:
                cmd_a(m, info, [int(a, 0) for a in args])
        elif cmd == "b":
            cmd_b(m, info, [int(a, 0) for a in args])
        elif cmd == "c":
            cmd_c(m, info, [int(a, 0) for a in args] or None)
        elif cmd == "t":
            sid = int(args[0], 0)
            row = trial(m, info, sid, "t_" + "+".join(args[1:]) if len(args) > 1 else "t", [int(a, 0) for a in args[1:]])
            print(brief(row))
            print(json.dumps({k: v for k, v in row.items() if k in ("tl", "hist", "cells0", "cells1", "actors0", "bgm", "bounds")}, indent=1))
    finally:
        m.close()


if __name__ == "__main__":
    main()
