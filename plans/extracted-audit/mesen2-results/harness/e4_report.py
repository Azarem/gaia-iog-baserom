#!/usr/bin/env python3
"""E4 report builder (harness only): reads raw/E4_sample_<name>.json and the arrival census files, writes the per-scene tables into
raw/E4_scene_tables.md. Nothing outside mesen2-results/raw is touched; the verdict text is written by hand in E4_20261108.md."""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")

# name -> (title, scene id text, state file, note)
SCENES = [
    ("credits", "Credits (scene $F7)", "orig_E4_credits.mss", "first 300 frames after the scene load; the circle stays off ($FE = $FFFF)"),
    ("credits_circle_fine", "Credits, oval phase (scene $F7)", "orig_E4_credits_circle.mss", "every 8 frames for 96 frames from the frame the radius word leaves $FFFF"),
    ("dream", "Will's Dream (scene $2A), event flag $0E set at the first frame", "orig_E4_dream.mss", "flag $0E poked (Shira's talk handler is not run)"),
    ("dream_noflag", "Will's Dream (scene $2A), no poke", "orig_E4_dream.mss", "control: scene idle, window parameters as gs2A_shira leaves them"),
    ("mu", "Mu vampire lair (scene $67)", "orig_E4_mu.mss", "flags of orig_P09_before_vampires; the vampire actors never started the circle in 300 frames"),
    ("s32", "Freejia (scene $32)", "orig_E4_s32.mss", ""),
    ("se9", "Mansion (scene $E9)", "orig_E4_se9.mss", ""),
    ("sea", "Mansion - Solid Arm's Lair (scene $EA)", "orig_E4_sea.mss", ""),
    ("dao", "Dao (scene $C3)", "orig_E4_dao.mss", "player stays at the spawn; the window rectangle is off screen"),
    ("title", "Title (scene $FC)", "orig_S06_title.mss", ""),
    ("diary", "Diary menu (scene $FA)", "orig_S07_diary.mss", "idle, cursors $0D92 = $0D96 = $FFFF, $0D98 = 0"),
    ("sc03", "Parallax: scene $03 (type $02)", "orig_E4_sc03.mss", ""),
    ("sc2b", "Parallax: scene $2B (types $06, $05)", "orig_E4_sc2b.mss", ""),
    ("sc2d", "Parallax: scene $2D (types $07, $06, $08, $05)", "orig_E4_sc2d.mss", ""),
    ("se5", "Parallax: scene $E5 (type $24 and others)", "orig_E4_se5.mss", ""),
]
CENSUS = {"credits": "credits", "credits_circle_fine": "credits", "dream": "dream", "dream_noflag": "dream", "mu": "mu", "s32": "s32", "se9": "se9",
          "sea": "sea", "dao": "dao", "sc03": "sc03", "sc2b": "sc2b", "sc2d": "sc2d", "se5": "se5"}


def census_cgwsel(tag):
    p = os.path.join(RAW, f"E4_build_{tag}_census.txt")
    if not os.path.exists(p):
        return None
    last = None
    for l in open(p):
        m = re.search(r"CGWSEL=(\w\w) .*\((\w\w:\w{4})\)", l)
        if m:
            last = (m.group(1), m.group(2))
    return last


def parse(block):
    ls = block.split("\n")
    h = ls[0]
    d = {}
    d["t"] = h.split()[0]
    d["n36"] = re.search(r"n36=(\d+)", h).group(1)
    for k in ("W12SEL", "W34SEL", "WOBJSEL", "TMW", "TSW", "CGADSUB", "TM", "TS"):
        m = re.search(r"PPU now:.*?\b" + k + r"=(\w\w)\b", h)
        d[k] = m.group(1) if m else "?"
    m = re.search(r"CGWSEL\.b1\(sub screen\)=(\d)", h)
    d["sub"] = m.group(1) if m else "?"
    m = re.search(r"WH0-3=([\d,]+)", h)
    d["wh"] = m.group(1) if m else "?"
    m = re.search(r"\$66=(\w\w)", h)
    d["m66"] = m.group(1) if m else "?"
    m = re.search(r"last write seen:(.*?)\| \$66", h)
    lw = {}
    if m:
        for kv in m.group(1).split():
            k, _, v = kv.partition("=")
            lw[k] = v
    d["lw"] = lw
    chans = []
    for l in ls[1:]:
        m = re.match(r"\s+ch(\d) dest=(\w+) mode=(\d) (DIR|IND) src=(\w\w:\w{4}) tbl16=([0-9A-F ]+?)(?: \| data@(\S+)\(first entry cnt=(\w+)\): ([0-9A-F ]+))?$", l)
        if m:
            tb = m.group(6).strip().split()[:16]
            s = f"ch{m.group(1)} ${m.group(2)} {m.group(4)} {m.group(5)}: " + " ".join(tb)
            if m.group(7):
                s += f" | data {m.group(7)}: {m.group(9).strip()}"
            chans.append(s)
    d["ch"] = chans
    return d


def main():
    out = []
    for name, title, st, note in SCENES:
        p = os.path.join(RAW, f"E4_sample_{name}.json")
        if not os.path.exists(p):
            continue
        j = json.load(open(p))
        res = j["result"]
        h1 = j["h1"]
        rows = [parse(b) for b in res["lines"]]
        shots = [os.path.basename(s) for s in j["shots"]]
        out.append(f"### {title}")
        out.append("")
        cg = census_cgwsel(CENSUS.get(name, ""))
        cgtxt = f"last CGWSEL write at the arrival: ${cg[0]} at {cg[1]}" if cg else "CGWSEL: no arrival census for this state (state loaded from the library)"
        out.append(f"State `{st}` (H1: romCheck {h1.get('romCheck')}, k=`${h1.get('k'):02X}`, sp=`${h1.get('sp'):04X}`, scene `${h1.get('scene'):02X}`). Controls: `$36` writes {res.get('w36')}, NMI execs {res.get('nmi')}. {note + '. ' if note else ''}{cgtxt}. The column 'writes seen in the run' lists every write to W12SEL..TSW, CGWSEL, CGADSUB, COLDATA, TM, TS and WH0-WH3 seen during the frames since the previous sample (last value kept); '-' means none.")
        out.append("")
        out.append("| t | `$36` | W12SEL | WOBJSEL | TMW | TSW | CGWSEL b1 | CGADSUB | TM / TS | WH0-WH3 | `$66` | writes seen in the run | shot |")
        out.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        bytag = {}
        for sname in shots:
            mt = re.search(r"_t(\d{3})_", sname)
            if mt:
                bytag[int(mt.group(1))] = sname
        for r in rows:
            s = bytag.get(int(r["t"][2:]))
            shotcell = f"[png](raw/screenshots/{s})" if s else "(none: the row is the state as loaded)"
            w = " ".join(f"{k}={v}" for k, v in r["lw"].items() if v != "--" and k not in ("COLDATA",))
            out.append(f"| {r['t']} | {r['n36']} | {r['W12SEL']} | {r['WOBJSEL']} | {r['TMW']} | {r['TSW']} | {r['sub']} | {r['CGADSUB']} | {r['TM']} / {r['TS']} | {r['wh']} | {r['m66']} | {w or '-'} | {shotcell} |")
        out.append("")
        out.append("HDMA tables (first 16 bytes of each active channel; identical consecutive samples are merged):")
        out.append("")
        out.append("```text")
        prev = None
        start = None
        buf = []
        for r in rows + [None]:
            cur = "\n".join(r["ch"]) if r else None
            if prev is not None and cur != prev[1]:
                span = prev[0] if prev[0] == start else f"{start}..{prev[0]}"
                buf.append((span, prev[1]))
                start = None
            if r:
                if start is None:
                    start = r["t"]
                prev = (r["t"], cur)
        for span, c in buf:
            out.append(f"[{span}]")
            out.append(c if c else "(no active channel)")
        out.append("```")
        out.append("")
        ts = sorted(bytag)
        pick = [ts[0], ts[len(ts) // 2], ts[-1]] if ts else []
        keys = [bytag[x] for x in pick]
        out.append(" ".join(f"![{k}](raw/screenshots/{k})" for k in keys))
        out.append("")
    open(os.path.join(RAW, "E4_scene_tables.md"), "w", encoding="utf-8").write("\n".join(out))
    print(len(out), "lines")


if __name__ == "__main__":
    main()
