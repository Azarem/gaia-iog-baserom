#!/usr/bin/env python3
"""FR40 classification of the 228 scenes from raw/FR40_rows.jsonl (rows of the sweeps a, c, b, n, g, g2). Pure data processing: no emulator.
usage: fr40_cls.py            prints one line per scene and writes raw/FR40_classes.json
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
import fr40_an as A  # noqa: E402

DRAFT = fr40.draft()
OUT = os.path.join(fr40.RAW, "FR40_classes.json")
WD = json.load(open(fr40.WARP_DEST, encoding="utf-8"))


def lock_intervals(r):
    """Intervals (start n, end n or None) of the direction lock (mask & 0x0F00 == 0x0F00) in the watch, game over (playerFlags $0200) excluded."""
    out, start = [], None
    for t in r.get("tl", []):
        lk = (t["mask"] & 0x0F00) == 0x0F00 and not (t["pf"] & 0x0200) and t.get("sc") == r["scene"]
        if lk and start is None:
            start = t["n"]
        if not lk and start is not None:
            out.append((start, t["n"]))
            start = None
    if start is not None:
        out.append((start, None))
    return out


def game_over(r):
    return any(t["pf"] & 0x0200 for t in r.get("tl", [])) or bool(r.get("pf1", 0) & 0x0200)


def blocked(r):
    """The arrival (no flags) holds the player: direction lock, dialogue, scene left by itself, or a lock interval of 20 frames or more."""
    st = A.st0(r)
    if st in ("locked", "dialog", "left"):
        return True
    if st == "gameover":
        return False
    return any(b is None or b - a >= 20 for a, b in lock_intervals(r))


def fmt_dest(d):
    return None if not d else {"x": d[0], "y": d[1], "facing": d[2], "scroll": d[3]}


def entries(sid):
    """No-flag natural entries: variants n*, one per distinct scene-warp destination (a destination (0,0) and a destination that ends in game over at
    arrival are dropped)."""
    out = []
    for k, r in A.rows[sid].items():
        if not (k.startswith("n") and k[1:].isdigit()) or r["flags"]:
            continue
        d = r.get("dest")
        if not d or (d[0] == 0 and d[1] == 0):
            continue
        if A.st0(r) == "gameover" or (r["tl"] and r["tl"][0]["n"] == 0 and r["tl"][0]["pf"] & 0x0200):
            continue
        out.append((k, r))
    return sorted(out, key=lambda kr: int(kr[0][1:]))


def classify(sid):
    v = A.rows[sid]
    d = DRAFT[str(sid)]
    a = v["a"]
    ents = entries(sid)
    info = {"scene": sid, "draftEntry": d["entry"], "draftFlags": d["flags"], "aState": A.st0(a), "aGameOver": game_over(a),
            "entries": {k: A.st0(r) + ("*" if blocked(r) and A.st0(r) not in ("locked", "dialog", "left") else "") for k, r in ents}}
    quick_bad = A.st0(a) in ("still", "gameover")
    info["quickBad"] = bool(quick_bad)
    pool = ents or [("a", a)]
    blk = [(k, r) for k, r in pool if blocked(r)]
    info["blockedEntries"] = [k for k, _ in blk]
    gn, gm, gd = v.get("g_none"), v.get("g_mash"), v.get("g_draft")
    selfrel = [k for k in ("long_none", "g_none") if k in v and v[k].get("sceneEnd") == sid and v[k].get("releaseN") not in (None, 1)]
    info["selfRelease"] = selfrel
    if blk:
        info["class"] = "cutscene"
        info["refEntry"] = blk[0][0]
    elif selfrel and not ents:
        info["class"] = "cutscene"
        info["refEntry"] = "a"
    elif quick_bad and ents:
        free = [(k, r) for k, r in ents if A.st0(r) in ("free", "pocket")]
        if free:
            info["class"] = "needs-spawn-position"
            info["refEntry"] = free[0][0]
        else:
            info["class"] = "free"
            info["refEntry"] = ents[0][0]
    else:
        info["class"] = "free"
        info["refEntry"] = (ents[0][0] if ents else "a")
    ref = (v.get(info["refEntry"]) if info["refEntry"] in v else a)
    info["dest"] = fmt_dest(ref.get("dest")) if ref.get("dest") else None
    return info


def main():
    res = {}
    for sid in sorted(A.rows):
        res[sid] = classify(sid)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({str(k): v for k, v in res.items()}, f, indent=1)
    import collections
    print(collections.Counter(v["class"] for v in res.values()))
    for sid, i in res.items():
        print(f"{sid:02X} {i['class']:<21} draft={i['draftEntry'][:4]:<5}{str(i['draftFlags']):<14} a={i['aState']}{'/GO' if i['aGameOver'] else ''}"
              f" ref={i['refEntry']} blk={i['blockedEntries'][:6]} ents={ {k: v for k, v in list(i['entries'].items())[:8]} }")


if __name__ == "__main__":
    main()
