#!/usr/bin/env python3
"""FR10 timeline builder (read-only): raw/FR10_chain_log.txt (the flagwatch rows of the continuous run) -> raw/FR10_timeline.json + raw/FR10_timeline.md.

Each flag change becomes a row {frame, scene, flag, op, store (the decimal offset of the SetEventFlag/ClearEventFlag store), actor (D = the actor slot
inside the COP handler, entry = the slot's entry address as a decimal ROM offset), src (file:line of the tagged line at that offset), registry (the
records of every registry fragment for the flag whose scope names the scene, or none)}.
"""
import bisect
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from flag_census import tags  # noqa: E402

RES = os.path.dirname(HERE)
RAW = os.path.join(RES, "raw")
BASE = os.path.dirname(os.path.dirname(os.path.dirname(RES)))
REGDIR = os.path.join(BASE, "plans", "flags", "results", "registry")

ROW = re.compile(r"^f=(\d+) sc=([0-9A-F]{2}) ([0-9A-F]{2}):([0-9A-F]{4}) end=(\d+) ins=(\S+) \$([0-9A-F]{4}) ([0-9A-F]{2})>([0-9A-F]{2}) (.*?)\s*D=([0-9A-F]{4}) entry=([0-9A-F]{2}):([0-9A-F]{4}) P=(\d+),(\d+)\s*$")


def entry_offset(bank, pc):
    return ((bank & 0x3F) << 16) | pc


def load_registry():
    recs = {}  # flag -> [(fragment, kind, record)]
    for path in sorted(glob.glob(os.path.join(REGDIR, "FL*_registry.json"))):
        frag = os.path.basename(path).split("_")[0]
        with open(path, encoding="utf-8") as f:
            r = json.load(f)
        for k, v in (r.get("flags") or {}).items():
            for mng in v.get("meanings", []):
                recs.setdefault(int(k), []).append((frag, "flag", mng))
        for k, v in (r.get("proposals") or {}).items():
            for mng in (v if isinstance(v, list) else [v]):
                recs.setdefault(int(k), []).append((frag, "proposal", mng))
    return recs


def scenes_of(rec):
    sc = (rec.get("scope") or {}).get("scenes")
    return set(sc) if sc else None


SETTER = re.compile(r"COP \[(Set|Clear)FlagByte\] \( #([0-9A-F]{2}) \)(?: ; \{(\d+)\})?")
_FILES = {}


def file_lines(rel):
    if rel not in _FILES:
        with open(os.path.join(BASE, "extracted", rel), encoding="utf-8", errors="replace") as f:
            _FILES[rel] = f.read().splitlines()
    return _FILES[rel]


def find_setter(entry, flag, op):
    """The SetFlagByte / ClearFlagByte line with operand `flag` that follows the actor's entry line (up to 80 lines), else the nearest one in the file."""
    if not entry:
        return None
    rel, line = entry["src"].rsplit(":", 1)
    lines = file_lines(rel)
    want = "Set" if op == "set" else "Clear"
    hits = []
    for i, text in enumerate(lines, 1):
        mt = SETTER.search(text)
        if mt and mt.group(1) == want and int(mt.group(2), 16) == flag and mt.group(3):
            hits.append((i, int(mt.group(3)), text.strip()))
    if not hits:
        return None
    after = [h for h in hits if int(line) <= h[0] <= int(line) + 80]
    pick = after[0] if after else min(hits, key=lambda h: abs(h[0] - int(line)))
    return {"src": f"{rel}:{pick[0]}", "offset": pick[1], "text": pick[2], "afterEntry": bool(after)}


def main():
    tg = tags()
    keys = [t[0] for t in tg]

    def tag_for(off):
        i = bisect.bisect_right(keys, off) - 1
        if i < 0:
            return None
        t = tg[i]
        return {"offset": t[0], "src": t[1], "exact": t[0] == off, "text": t[2]}

    reg = load_registry()
    rows, scene_rows = [], []
    with open(os.path.join(RAW, "FR10_chain_log.txt"), encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("SCENE "):
                scene_rows.append(line)
                continue
            m = ROW.match(line)
            if not m:
                continue
            frame, sc, k, pc, end, ins, addr, old, new, chg, d, ebank, epc, px, py = m.groups()
            sc = int(sc, 16)
            for tok in chg.split():
                op = "set" if tok[0] == "+" else "clear"
                try:
                    flag = int(tok[1:], 16)
                except ValueError:
                    continue
                eo = entry_offset(int(ebank, 16), int(epc, 16))
                rows.append({"frame": int(frame), "scene": sc, "flag": flag, "op": op, "store": int(end) - 3 if False else int(ins.split("|")[0]),
                             "actorSlot": int(d, 16), "player": [int(px), int(py)], "entryOffset": eo, "entry": tag_for(eo) if int(ebank, 16) else None})
    for r in rows:
        r["setter"] = find_setter(r["entry"], r["flag"], r["op"]) if r["flag"] != 255 else None
        r["registry"] = []
        for frag, kind, rec in reg.get(r["flag"], []):
            sc = scenes_of(rec)
            if sc is None or r["scene"] in sc:
                text = json.dumps(rec)
                files = sorted(set(re.findall(r"([\w/]+\.asm):\d+", text)))
                offs = sorted(set(int(x) for x in re.findall(r"\{(\d+)\}", text)))
                r["registry"].append({"fragment": frag, "kind": kind, "name": rec.get("name"), "grade": rec.get("grade"), "scenes": sorted(sc) if sc else None,
                                      "files": files, "offsets": offs, "effects": rec.get("effects")})
    with open(os.path.join(RAW, "FR10_timeline.json"), "w", encoding="utf-8") as f:
        json.dump({"rows": rows, "sceneRows": scene_rows}, f, indent=1)
    print(len(rows), "flag-change rows")


if __name__ == "__main__":
    main()
