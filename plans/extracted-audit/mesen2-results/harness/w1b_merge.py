#!/usr/bin/env python3
"""Merged W1-b report (called by w1b_report.py without --static): raw/W1b_*_<date>.json -> raw/W1b_report.md and raw/W1b_merged.json.

Maps every logged K:PC to the instruction that ENDS at the PC (tags `; {n}` of extracted/), names the routine, classifies the access
(static = the operand names a watched address; indexed/indirect; DMA/HDMA-attributed otherwise), merges counts, scenes, values, actor context,
exec marks and value probes over all sessions, and lists the static sites with their runtime hit counts.
"""
import glob
import json
import os
import re
import time
from collections import defaultdict

import w1a_report as R
import w1b_report as B

RAW = R.RAW


def load_sessions(date):
    out = []
    for p in sorted(glob.glob(os.path.join(RAW, f"W1b_*_{date}.json"))):
        base = os.path.basename(p)
        if base.startswith(("W1b_merged", "W1b_report", "W1b_static", "W1b_run")):
            continue
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        if "census" in d:
            c = d["census"]
            if isinstance(c, str):
                c = json.loads(c)
            if not isinstance(c, dict) or "rows" not in c:
                raise SystemExit(f"{base}: census has no rows (truncated or failed run); the file is not merged")
            out.append(dict(name="natural_fr10", final=c, frames=d.get("inputFrames"), h1=d["h1"], scene=d.get("endScene"), rom=d.get("rom")))
        else:
            if not d.get("final"):
                continue
            out.append(dict(name=d["session"]["name"], final=d["final"], frames=d.get("frames"), h1=d["h1"], scene=d.get("scene") or d["final"].get("endScene"),
                            rom=d.get("rom"), seconds=d.get("seconds")))
    return out


def addto(dst, src_list):
    for k, v in src_list:
        dst[k] = dst.get(k, 0) + v


def merge(sessions):
    rows, pairs, execs, probes = {}, {}, {}, {}
    ctl = dict(ctl36=0, nmi=0, frames=0)
    scenes_seen = defaultdict(int)
    for s in sessions:
        f = s["final"]
        ctl["ctl36"] += f.get("control36Writes", 0)
        ctl["nmi"] += f.get("nmiExecs", 0)
        ctl["frames"] += f.get("frames", 0) or 0
        for k, v in f.get("sceneFrames", []):
            scenes_seen[k] += v
        for r in f["rows"]:
            e = rows.setdefault(r["key"], dict(key=r["key"], name=r["name"], kind=r["kind"], pc=r["pc"], n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
            addto(e["scenes"], r.get("scenes", []))
            addto(e["addrs"], r.get("addrs", []))
            addto(e["vals"], r.get("vals", []))
            addto(e["ctx"], r.get("ctx", []))
        for r in f.get("pairs", []):
            e = pairs.setdefault(r["key"], dict(key=r["key"], n=0, sessions={}, scenes={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
        for x in f.get("execs", []):
            e = execs.setdefault(x["name"], dict(off=x["off"], n=0, sessions={}, scenes={}))
            e["n"] += x.get("n", 0)
            if x.get("n"):
                e["sessions"][s["name"]] = x["n"]
            addto(e["scenes"], x.get("scenes", []))
        for x in f.get("probes", []):
            e = probes.setdefault(x["name"], dict(off=x["off"], addr=x["addr"], size=x["size"], n=0, vals={}, scenes={}))
            e["n"] += x.get("n", 0)
            addto(e["vals"], x.get("vals", []))
            addto(e["scenes"], x.get("scenes", []))
    return rows, pairs, execs, probes, ctl, scenes_seen


def fmt_sessions(d, top=4):
    items = sorted(d.items(), key=lambda kv: -kv[1])
    s = ", ".join(f"{k} {v}" for k, v in items[:top])
    return s + (f" (+{len(items) - top})" if len(items) > top else "")


def fmt_scenes(d, top=10):
    items = sorted(d.items(), key=lambda kv: kv[0])
    s = " ".join(f"{int(k):02X}" for k, _ in items[:top])
    return f"{len(items)}: {s}" + (" ..." if len(items) > top else "")


def main(args):
    date = args.date or time.strftime("%Y%m%d")
    out = args.out or os.path.join(RAW, "W1b_report.md")
    sessions = load_sessions(date)
    tags = R.load_tags()
    tag_keys = sorted(tags)
    names, nkeys = R.load_names()
    rows, pairs, execs, probes, ctl, scenes_seen = merge(sessions)
    resolved = {}

    def resolve(pc):
        if pc in resolved:
            return resolved[pc]
        k, p = (int(x, 16) for x in pc.split(":"))
        end = R.rom_offset(k, p)
        if end is None:
            r = dict(off=None, text="(not ROM: bank %02X pc %04X)" % (k, p), where="", routine="?")
        else:
            off = R.instr_ending_at(tag_keys, end)
            if off is None:
                r = dict(off=None, end=end, text="(no tagged instruction ends at %d)" % end, where="", routine=R.routine(names, nkeys, end))
            else:
                t = tags[off]
                r = dict(off=off, end=end, text=t["text"], where=f"{t['file']}:{t['line']}", routine=R.routine(names, nkeys, off), tag=t)
        resolved[pc] = r
        return r

    def access_class(r, wname):
        tag = r.get("tag")
        if tag is None:
            return "unmapped"
        wname = {"06EF bit4(0x10)": "06EE-06EF", "0A1F bit7 change": "0A1F flag FF bit7"}.get(wname, wname)
        if wname in B.STATIC_NAMES and R.static_hit(tag, wname):
            return "static"
        if re.search(r"[,\[\(]|^MV[NP]", tag["text"]):
            return "indexed/indirect"
        return "DMA/HDMA-attributed"

    L = [f"# W1-b merged census ({date})\n"]
    L.append(f"sessions: {len(sessions)}; frames (sum of per-session frame counters): {ctl['frames']}; $36 write control: {ctl['ctl36']}; NMI exec control: {ctl['nmi']}\n")
    L.append("## Sessions\n")
    L.append("| session | frames | end scene | H1 (k, sp, scene) | hits | seconds |")
    L.append("|---|---|---|---|---|---|")
    for s in sessions:
        h = s["h1"]
        L.append(f"| {s['name']} | {s['frames']} | {(s['scene'] or 0):02X} | {h.get('k'):02X} {h.get('sp'):04X} {h.get('scene'):02X} | {s['final'].get('hits')} | {s.get('seconds')} |")
    L.append("")
    L.append("## Scenes visited (frames, sum)\n")
    L.append(" ".join(f"{int(k):02X}:{v}" for k, v in sorted(scenes_seen.items(), key=lambda kv: int(kv[0]))) + "\n")
    L.append("## Scene sequences (per session, first 80 changes)\n")
    for s in sessions:
        seq = s["final"].get("sceneSeq") or []
        L.append(f"- {s['name']}: {' '.join(seq)}")
    L.append("")

    merged = dict(ctl=ctl, rows=[], pairs=[], execs=execs, probes=probes)
    wnames = [w["name"] for w in B_watch_names()]
    for wname in wnames:
        L.append(f"## {wname}\n")
        L.append("| kind | offset | file:line | instruction | routine | count | class | sessions | scenes | addrs | values | actor ctx |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|---|")
        agg, dma = {}, {}
        for key, e in rows.items():
            if e["name"] != wname:
                continue
            r = resolve(e["pc"])
            cls = access_class(r, wname)
            merged["rows"].append(dict(watch=wname, kind=e["kind"], pc=e["pc"], off=r.get("off"), where=r["where"], text=r["text"], routine=r["routine"],
                                       n=e["n"], cls=cls, sessions=e["sessions"], scenes=e["scenes"], addrs=e["addrs"], vals=e["vals"], ctx=e["ctx"]))
            if cls == "DMA/HDMA-attributed":
                d = dma.setdefault(e["kind"], dict(n=0, pcs=set(), addrs={}, sessions={}))
                d["n"] += e["n"]
                d["pcs"].add(e["pc"])
                for a_, c_ in e["addrs"].items():
                    d["addrs"][a_] = d["addrs"].get(a_, 0) + c_
                for k_, v_ in e["sessions"].items():
                    d["sessions"][k_] = d["sessions"].get(k_, 0) + v_
                continue
            g = agg.setdefault((e["kind"], r.get("off"), e["pc"] if r.get("off") is None else ""), dict(r=r, cls=cls, n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}, kind=e["kind"]))
            g["n"] += e["n"]
            for src, dst in ((e["sessions"], g["sessions"]), (e["scenes"], g["scenes"]), (e["addrs"], g["addrs"]), (e["vals"], g["vals"]), (e["ctx"], g["ctx"])):
                for k_, v_ in src.items():
                    dst[k_] = dst.get(k_, 0) + v_
        for key, g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0)):
            r = g["r"]
            addrs = ",".join(f"{int(a):04X}:{c}" for a, c in sorted(g["addrs"].items()))
            vals = ",".join(f"{int(v):02X}:{c}" for v, c in sorted(g["vals"].items()))
            ctx = "; ".join(f"{k}:{c}" for k, c in sorted(g["ctx"].items(), key=lambda kv: -kv[1])[:6])
            L.append(f"| {g['kind']} | {r.get('off')} | {r['where']} | {r['text']} | {r['routine']} | {g['n']} | {g['cls']} | {fmt_sessions(g['sessions'])} | "
                     f"{fmt_scenes(g['scenes'])} | {addrs[:120]} | {vals[:100]} | {ctx} |")
        for kind, d in dma.items():
            addrs = ",".join(f"{int(a):04X}:{c}" for a, c in sorted(d["addrs"].items()))
            L.append(f"| {kind} | - | - | (callbacks attributed to {len(d['pcs'])} different PCs that cannot access the watched byte: DMA/HDMA, or a DMA write after its trigger) | - | {d['n']} | DMA/HDMA-attributed | {fmt_sessions(d['sessions'])} | - | {addrs[:160]} | | |")
        L.append("")

    # static census with runtime counts
    rt = defaultdict(int)
    for e in rows.values():
        r = resolve(e["pc"])
        if r.get("off") is not None:
            for wn in B.STATIC_NAMES:
                if e["name"] == wn:
                    rt[(wn, r["off"])] += e["n"]
    L.append("## Static census (operand names a watched address) with runtime count\n")
    t, static_rows = B.static_table(tags, tag_keys, names, nkeys, rt)
    for ln in t:
        L.append(ln)
    merged["static"] = static_rows

    L.append("## Read <- last writer pairs\n")
    L.append("| watch | reader off | reader instr | <- last writer off | writer instr | count | sessions |")
    L.append("|---|---|---|---|---|---|---|")
    pagg = {}
    for key, e in sorted(pairs.items()):
        m = re.match(r"(.+?) read (\S+) <- (\S+)$", key)
        if not m:
            continue
        rd = resolve(m.group(2))
        wr = resolve(m.group(3)) if m.group(3) != "init" else dict(off="init", text="(no write seen in this run)")
        g = pagg.setdefault((m.group(1), rd.get("off"), wr.get("off")), dict(rd=rd, wr=wr, n=0, sessions={}))
        g["n"] += e["n"]
        for k_, v_ in e["sessions"].items():
            g["sessions"][k_] = g["sessions"].get(k_, 0) + v_
    for (wn, ro, wo), g in sorted(pagg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0, str(kv[0][2]))):
        L.append(f"| {wn} | {ro} | {g['rd']['text']} | {wo} | {g['wr']['text']} | {g['n']} | {fmt_sessions(g['sessions'], 3)} |")
        merged["pairs"].append(dict(watch=wn, n=g["n"], reader=ro, writer=wo))
    L.append("")

    L.append("## Exec marks\n")
    L.append("| name | offset | count | sessions | scenes |")
    L.append("|---|---|---|---|---|")
    for name, e in sorted(execs.items()):
        L.append(f"| {name} | {e.get('off')} | {e['n']} | {fmt_sessions(e['sessions'], 4)} | {fmt_scenes(e['scenes'], 14)} |")
    L.append("")
    L.append("## Value probes (value at each execution of the instruction, as value@scene:count)\n")
    for name, e in sorted(probes.items()):
        if not e["n"]:
            L.append(f"- {name} (off {e['off']}, WRAM {e['addr']:04X}): 0 executions")
            continue
        vs = ", ".join(f"{int(k.split('@')[0]):0{4 if e['size'] == 2 else 2}X}@{k.split('@')[1]}:{c}" for k, c in sorted(e["vals"].items(), key=lambda kv: -kv[1])[:24])
        L.append(f"- {name} (off {e['off']}, WRAM {e['addr']:04X}, size {e['size']}): {e['n']} executions: {vs}")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1b_merged.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=1, default=str)
    print("wrote", out, len(L), "lines")


def B_watch_names():
    """Watch names in the order of kit/lib/w1b_kit.lua (read from the Lua text so that report and run cannot drift)."""
    path = os.path.join(R.RESULTS, "kit", "lib", "w1b_kit.lua")
    txt = open(path, encoding="utf-8").read()
    seg = txt.split("w1b.batchB = {", 1)[1].split("exec = {", 1)[0]
    return [dict(name=m) for m in re.findall(r'name = "([^"]+)"', seg)]
