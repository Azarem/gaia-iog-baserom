#!/usr/bin/env python3
"""FR40 report generator: reads raw/FR40_rows.jsonl (and the draft FL32_scene-flags.json) and writes, under mesen2-results/ only:
  specs/FR40_scene-flags.json, specs/FR40_flag_verdicts.json, raw/FR40_scene_table.json (per-scene evidence used by the result file)
No emulator access. The result file FR40_20261106.md is written by hand from raw/FR40_scene_table.json and this script's printed tables."""
import collections
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
import fr40_an as A  # noqa: E402
import fr40_cls as C  # noqa: E402

RES = os.path.abspath(os.path.join(HERE, ".."))
BASE = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
SPECS = os.path.join(RES, "specs")
DRAFT = fr40.draft()
QUEUE = json.load(open(os.path.join(BASE, "plans", "flags", "results", "queue", "FL32_queue.json"), encoding="utf-8"))
SHIPPED = json.load(open(os.path.join(BASE, "db-us", "scene-flags.json"), encoding="utf-8"))
DIRS = ("down", "up", "left", "right")


def hx(v, w=4):
    return f"${v:0{w}X}"


def sc(s):
    return f"${s:02X}"


def row_of(v, *names):
    for n in names:
        if n in v:
            return v[n]
    return None


def left_at(r):
    """(scene, frame index of the watch) of the last scene change in the run, or None."""
    h = r.get("hist") or []
    if len(h) >= 2 or (h and r.get("sceneEnd") != r["scene"]):
        last = h[-1]
        if last["to"] != r["scene"]:
            return last["to"], last["f"] - r.get("frame0", 0)
    return None


def moves(r):
    mv = r.get("move") or {}
    out = {s["dir"]: (s["dx"], s["dy"]) for s in mv.get("seg", []) if "dx" in s}
    return out


def moves_txt(r):
    m = moves(r)
    if not m:
        return "-"
    return " ".join(f"{d[0]}{dx:+d}{dy:+d}" for d, (dx, dy) in m.items())


def first_lock(r):
    """(start, end) of the first direction-lock interval of the run (frames of the watch); end None when it lasts to the end."""
    iv = C.lock_intervals(r)
    return iv[0] if iv else None


def run_txt(r, label):
    """One sentence fragment for a long run."""
    if r is None:
        return None
    sid = r["scene"]
    lf = left_at(r)
    n = r.get("n", r.get("watch"))
    if lf:
        return f"{label}: loads scene {sc(lf[0])} by itself at frame {lf[1]}"
    if r.get("releaseN"):
        return f"{label}: free from frame {r['releaseN']}"
    if r.get("dmf1", 0) & 0x2000:
        return f"{label}: a message box (displayModeFlags bit $2000) is still open at frame {n}"
    return f"{label}: not free at frame {n} (mask {hx(r['mask1'])})"


def entry_dest_txt(d):
    return "quick warp" if not d else f"x={d[0]} y={d[1]} facing={d[2]} scroll=${d[3]:04X}"


def reg_grade(flag, scenes):
    best = None
    for f in sorted(glob.glob(os.path.join(BASE, "plans", "flags", "results", "registry", "FL*_registry.json"))):
        try:
            d = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        e = (d.get("flags") or {}).get(str(flag))
        if not e:
            continue
        for m in e.get("meanings", []):
            if "grade" not in m:
                continue
            msc = (m.get("scope") or {}).get("scenes")
            if msc is None or any(s in msc for s in scenes):
                best = m["grade"]
    return best


def queue_id(flag, scene):
    for q in QUEUE:
        qs = (q.get("scope") or {}).get("scenes") or []
        if q.get("flag") == flag and scene in qs:
            return q["id"]
    for q in QUEUE:
        qs = (q.get("scope") or {}).get("scenes") or []
        if q["id"].startswith(("FL32-2", "FL32-3")) and q.get("flag") is None and scene in qs and "Scene entry" in q["claim"]:
            return q["id"]
    return None


def analyse(sid, cls):
    v = A.rows[sid]
    d = DRAFT[str(sid)]
    ref = v.get(cls["refEntry"]) or v["a"]
    gn = row_of(v, "g_none", "long_none")
    gm = row_of(v, "g3_mash", "g_mash", "long_mash")
    gd = row_of(v, "g_draft", "draft")
    info = {"scene": sid, "class": cls["class"], "draftEntry": d["entry"], "draftFlags": d["flags"], "refEntry": cls["refEntry"],
            "dest": ref.get("dest"), "arrival": {"mask0": ref["mask0"], "pf0": ref["pf0"], "dmf0": ref["dmf0"]}, "moves": moves_txt(ref),
            "entries": cls["entries"], "blockedEntries": cls["blockedEntries"], "aState": cls["aState"]}
    # flag evidence
    fl = {"tested": None}
    if d["flags"]:
        pre = [22] if sid == 6 else []
        fl["draftRow"] = None
        if gd is not None:
            fl["tested"] = d["flags"]
            fl["forcedState"] = A.st0(gd)
            fl["forcedMask"] = gd["mask0"]
            fl["forcedDmf"] = gd.get("dmf1", 0)
            fl["forcedMoves"] = moves_txt(gd)
        subs = {k[5:]: A.st0(r) for k, r in v.items() if k.startswith("g_sub")}
        fl["subs"] = subs
        ctl_blocked = bool(cls["blockedEntries"]) or (sid == 6 and A.st0(v["g_pre"]) in ("locked", "dialog"))
        fl["controlBlocked"] = ctl_blocked
        if sid == 6:
            fl["pre"] = [22]
    info["flag"] = fl
    # runs
    info["noInput"] = run_txt(gn, "no input")
    info["mash"] = run_txt(gm, "A pulses")
    info["gnone"] = {"releaseN": gn.get("releaseN") if gn else None, "left": left_at(gn) if gn else None, "dmf1": gn.get("dmf1") if gn else None,
                     "n": gn.get("n") if gn else None}
    info["gmash"] = {"releaseN": gm.get("releaseN") if gm else None, "left": left_at(gm) if gm else None, "n": gm.get("n") if gm else None,
                     "variant": "g3_mash" if "g3_mash" in v else ("g_mash" if "g_mash" in v else ("long_mash" if "long_mash" in v else None))}
    fl0 = first_lock(gn) if gn else None
    info["firstLock"] = fl0
    return info


def minimal_flags(sid, info):
    """Minimal draft flags that free the arrival (None: not verified)."""
    fl = info["flag"]
    d = DRAFT[str(sid)]
    if not d["flags"] or fl.get("tested") is None:
        return None
    flags = d["flags"]
    if sid == 6:
        free = [k for k, st in fl["subs"].items() if st in ("free", "pocket")]
        sets = [tuple(int(x) for x in k.split("+")) for k in free]
        return sorted(min(sets, key=len)) if sets else None
    if fl["forcedState"] not in ("free", "pocket"):
        return None
    if len(flags) == 1:
        return flags
    free = [k for k, st in fl["subs"].items() if st in ("free", "pocket")]
    if free:
        sets = [tuple(int(x) for x in k.split("+")) for k in free]
        return sorted(min(sets, key=len))
    return flags


OVERRIDE_NOTE = {
    0x0E: ("cutscene", "Entered from the scene-warp destination x=88 y=64 facing=3 the player is free for 56 frames, then locks of joypadMaskStd $0F00 (17 frames each) repeat, "
                       "the player's HP reaches 0 (playerFlags $0200) at frame 197 and the scene loads scene $20 at frame 437; the other scene-warp destination gives a free arrival."),
    0x13: ("cutscene", "Entered from the scene-warp destination x=120 y=80 facing=3 the player is free for 59 frames, then a script locks the joypad (joypadMaskStd $CFF0) and opens a "
                       "message box (displayModeFlags $2001) that stays open without input for 600 frames; with A pulses a further lock starts at frame 146 and the joypad is locked again at frame 600."),
    0xFF: ("cutscene", "The inventory scene is a menu overlay: joypadMaskStd $065A is $0000 at arrival and the player does not move in the direction test."),
}
INCONCLUSIVE_SCENES = {
    0xE0: "the draft lock needs flag $D4 set: with flag 212 set the arrival is free (actor list 21 to 23 entries, mask $0000, the player moves in four directions); the other conditions of the draft lock are not reached from the S01r story state",
    0x06: "from the S01r story state the arrival is free; with flag 22 set the Hamlet script locks the joypad ($CFF0) and flag 61 frees it, while flags 29 and 37 do not; the other two arrival scripts of the draft need story states that are not reached",
}


def gameover_entries(sid):
    out = []
    for k, r in A.rows[sid].items():
        if k.startswith("n") and k[1:].isdigit() and not r["flags"] and r.get("dest"):
            go = next((t["n"] for t in r.get("tl", []) if t["pf"] & 0x0200), None)
            if go is not None:
                d = r["dest"]
                out.append(f" Entered from the scene-warp destination x={d[0]} y={d[1]} facing={d[2]} the arrival ends in game over (playerFlags $0200 set, HP 0) at frame {go}.")
    return "".join(out)


def inscene_lock(sid, i):
    r = A.rows[sid].get(i["refEntry"]) or A.rows[sid]["a"]
    mv = r.get("move") or {}
    hit = [x for x in mv.get("seg", []) if x.get("mask", 0) & 0x0F00 and x.get("sc") == sid]
    if hit and mv.get("exitAt") is None and mv.get("sc1") == sid:
        return f" Walking from the entry position starts a lock (joypadMaskStd {hx(hit[0]['mask'])}) in the direction test."
    return ""


def build():
    classes = {sid: C.classify(sid) for sid in sorted(A.rows)}
    out = {}
    for sid, cls in classes.items():
        out[sid] = analyse(sid, cls)
    return classes, out


def note_text(sid, i):
    """Present-tense note of the spec entry."""
    cls = i["class"]
    d = i["dest"]
    parts = []
    mf = i.get("minFlags")
    if cls == "free":
        n_ent = len(i["entries"])
        parts.append("The arrival is free: joypadMaskStd $065A is $0000, no message box is open and the player moves in the direction test")
        if i["blockedEntries"]:
            pass
        parts[-1] += "."
    elif cls == "needs-spawn-position":
        parts.append("The arrival is free. A quick warp (default position x=88 y=160) lands in a wall, a pocket or a hazard; "
                     f"a warp with {entry_dest_txt(d)} places the player on free ground")
        parts[-1] += "."
    else:
        pass
    return parts


def lock_sentence(sid, i):
    """Observed arrival lock (cutscene class) in present tense."""
    v = A.rows[sid]
    gn = row_of(v, "g_none", "long_none")
    gm = row_of(v, "g3_mash", "g_mash", "long_mash")
    s = []
    a0 = i["arrival"]["mask0"]
    fl0 = i["firstLock"]
    if gn is None:
        return ""
    lf = left_at(gn)
    pf_only = (gn["pf0"] & 0x0800) and (a0 & 0x0F00) != 0x0F00
    if (a0 & 0x0F00) == 0x0F00:
        s.append(f"The arrival locks the joypad (joypadMaskStd $065A = {hx(a0)})" + (f" for {fl0[1]} frames" if fl0 and fl0[1] else ""))
    elif pf_only:
        s.append("The arrival sets playerFlags bit $0800 (script lock)")
    elif fl0:
        s.append(f"The joypad is locked from frame {fl0[0]}" + (f" to frame {fl0[1]}" if fl0[1] else ""))
    else:
        s.append("The arrival holds the player")
    if lf:
        s[-1] += f"; the scene loads scene {sc(lf[0])} by itself at frame {lf[1]} after the banner"
    elif gn.get("releaseN") and gn["releaseN"] > 1:
        s[-1] += f"; the player is free from frame {gn['releaseN']} without input"
    elif gn.get("dmf1", 0) & 0x2000 and gn.get("releaseN") is None:
        s[-1] += f"; a message box ($09EC bit $2000) then holds the player and does not close by itself within {gn.get('n')} frames"
        if gm is not None:
            lm = left_at(gm)
            if lm:
                s[-1] += f"; with A pulses the scene loads scene {sc(lm[0])} at frame {lm[1]}"
            elif gm.get("releaseN"):
                s[-1] += f"; with A pulses (physical A, 2 frames of every 12) the player is free from frame {gm['releaseN']}"
            else:
                s[-1] += f"; the player is still held after {gm.get('n')} frames with A pulses"
    elif gn.get("releaseN") is None and gn.get("dmf1", 0) & 0x2000 == 0:
        s[-1] += f"; the player is still held after {gn.get('n')} frames without input"
        if gm is not None:
            lm = left_at(gm)
            if lm:
                s[-1] += f"; with A pulses the scene loads scene {sc(lm[0])} at frame {lm[1]}"
            elif gm.get("releaseN"):
                s[-1] += f"; with A pulses the player is free from frame {gm['releaseN']}"
    return s[0] + "."


def main():
    classes, info = build()
    # minimal flags and flag verdict rows
    verd = []
    spec = {}
    table = {}
    S01 = A.rows[10]["ctl_without63"]["flagsPre"] if "ctl_without63" in A.rows[10] else None
    for sid in sorted(info):
        i = info[sid]
        d = DRAFT[str(sid)]
        mf = minimal_flags(sid, i)
        i["minFlags"] = mf
        cls = i["class"]
        fl = i["flag"]
        verdict_scene = "VERIFIED-RUNTIME"
        reason = ""
        # flag verdicts
        if d["flags"]:
            if fl.get("tested") is None:
                reason = "draft flags not tested"
                verdict_scene = "INCONCLUSIVE"
            elif not fl["controlBlocked"]:
                verdict_scene = "INCONCLUSIVE"
                reason = "no arrival lock from the S01r story state: the flags cannot show a difference"
            elif mf is None:
                reason = "the draft flags do not free the arrival"
        if sid in INCONCLUSIVE_SCENES:
            verdict_scene, reason = "INCONCLUSIVE", INCONCLUSIVE_SCENES[sid]
        if sid in OVERRIDE_NOTE:
            i["class"] = OVERRIDE_NOTE[sid][0]
        i["reason"] = reason
        i["sceneVerdict"] = verdict_scene
    # flag verdicts: one row per (flag, verdict, scenes)
    byflag = collections.defaultdict(list)
    for sid, i in info.items():
        d = DRAFT[str(sid)]
        for f in d["flags"]:
            byflag[f].append(sid)
    for f, scs in sorted(byflag.items()):
        groups = collections.defaultdict(list)
        for sid in scs:
            i = info[sid]
            fl = i["flag"]
            if sid == 6:
                if f == 61:
                    verdict = "VERIFIED-RUNTIME"
                else:
                    verdict = "INCONCLUSIVE"
            elif fl.get("tested") is None:
                verdict = "INCONCLUSIVE"
            elif not fl["controlBlocked"]:
                verdict = "INCONCLUSIVE"
            elif i["minFlags"] is not None and f in i["minFlags"]:
                verdict = "VERIFIED-RUNTIME"
            elif i["minFlags"] is not None:
                verdict = "INCONCLUSIVE"
            else:
                verdict = "CONTRADICTED"
            groups[verdict].append(sid)
        for verdict, ss in groups.items():
            ev_set, ev_clear = [], []
            for sid in ss:
                i = info[sid]
                fl = i["flag"]
                if sid == 6:
                    pr = A.rows[6]["g_pre"]
                    clear_txt = (f"with flag 22 set and the draft flags clear the Hamlet script locks the joypad (joypadMaskStd {hx(pr['mask1'])}) at arrival and the player "
                                 f"does not move in the direction test ({moves_txt(pr)})")
                    s61 = A.rows[6]["g_sub61"]
                    set_txt = f"Scene $06 with flag 22 and flag 61 set: arrival free (mask {hx(s61['mask0'])}); flags 29 and 37 alone leave the lock in place"
                    ev_set.append(set_txt)
                    ev_clear.append(f"Scene $06: {clear_txt}.")
                    continue
                clear_txt = lock_sentence(sid, i) if i["blockedEntries"] else "The arrival is free from the S01r story state (no lock reproduced)."
                set_txt = (f"Scene {sc(sid)}: arrival free (mask {hx(fl.get('forcedMask', 0))}, moves {fl.get('forcedMoves')})" if fl.get("forcedState") in ("free", "pocket")
                           else f"Scene {sc(sid)}: state {fl.get('forcedState')} (mask {hx(fl.get('forcedMask', 0))}, displayModeFlags {hx(fl.get('forcedDmf', 0))})")
                ev_set.append(set_txt)
                ev_clear.append(f"Scene {sc(sid)}: {clear_txt}")
            qid = None
            for sid in ss:
                qid = qid or queue_id(f, sid)
            if f == 63:
                qid = "FL32-40"
            if f == 134:
                qid = "FL32-41"
            verd.append({"flag": f, "scope": {"scenes": sorted(ss)}, "queueId": qid, "verdict": verdict, "grade": "VERIFIED-RUNTIME" if verdict == "VERIFIED-RUNTIME" else reg_grade(f, ss),
                         "effects": {"set": " ".join(ev_set), "clear": " ".join(ev_clear)},
                         "expectGrade": reg_grade(f, ss), "evidence": "FR40_20261106.md section Verdicts, scene rows " + ", ".join(sc(s) for s in sorted(ss))})
    # spec entries
    for sid in sorted(info):
        i = info[sid]
        d = DRAFT[str(sid)]
        cls = i["class"]
        mf = i["minFlags"]
        if i["sceneVerdict"] != "VERIFIED-RUNTIME" or sid == 6:
            continue
        cls = i["class"]
        entry = "cutscene" if cls == "cutscene" else "free"
        flags = mf or []
        if cls == "cutscene":
            note = lock_sentence(sid, i)
            if mf:
                note += f" With flag {', '.join(hx(f, 2) for f in mf)} set the arrival is free (mask $0000, no message box, the player moves)."
            elif d["flags"] and not mf:
                pass
        elif cls == "needs-spawn-position":
            a_r = A.rows[sid]["a"]
            go = next((t["n"] for t in a_r.get("tl", []) if t["pf"] & 0x0200), None)
            why = (f"ends in game over (playerFlags $0200 set, HP 0) at frame {go}" if i["aState"] == "gameover" or go is not None
                   else "puts the player in a wall (no movement in four directions, collision cells solid)")
            note = (f"The arrival is free. A quick warp (default position x=88 y=160) {why}; "
                    f"a full warp with {entry_dest_txt(i['dest'])} places the player on free ground.")
        else:
            note = "The arrival is free: joypadMaskStd $065A is $0000, no message box is open and the player moves in the direction test." + inscene_lock(sid, i)
        note += gameover_entries(sid)
        if sid in OVERRIDE_NOTE:
            note = OVERRIDE_NOTE[sid][1]
        if i["blockedEntries"] and cls == "cutscene" and len(i["entries"]) > 1 and sid not in OVERRIDE_NOTE:
            free_e = [k for k, st in i["entries"].items() if k not in i["blockedEntries"]]
            if free_e:
                note += f" Entered from {len(free_e)} of {len(i['entries'])} scene-warp destinations the arrival is free."
        e = {"flags": flags, "entry": entry, "note": note, "source": "Mesen2 FR40", "grade": "VERIFIED-RUNTIME"}
        if d.get("names") and mf:
            e["names"] = [n for f, n in zip(d["flags"], d["names"]) if f in mf]
        if str(sid) in SHIPPED:
            e["expectOld"] = "stays nonzero"
        spec[str(sid)] = e
    with open(os.path.join(SPECS, "FR40_scene-flags.json"), "w", encoding="utf-8") as f:
        json.dump(spec, f, indent=1)
    with open(os.path.join(SPECS, "FR40_flag_verdicts.json"), "w", encoding="utf-8") as f:
        json.dump(verd, f, indent=1)
    with open(os.path.join(fr40.RAW, "FR40_scene_table.json"), "w", encoding="utf-8") as f:
        json.dump({str(k): v for k, v in info.items()}, f, indent=1, default=str)
    print("classes", collections.Counter(i["class"] for i in info.values()))
    print("scene verdicts", collections.Counter(i["sceneVerdict"] for i in info.values()))
    print("spec entries", len(spec), "flag verdict rows", len(verd), collections.Counter(v["verdict"] for v in verd))


if __name__ == "__main__":
    main()
