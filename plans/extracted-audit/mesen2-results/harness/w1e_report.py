#!/usr/bin/env python3
"""Merged W1-e report: raw/W1e_*_<date>.json -> raw/W1e_report.md and raw/W1e_merged.json.

Maps every logged K:PC to the instruction that ENDS at the PC (tags `; {n}` of extracted/), names the routine, merges counts, scenes, addresses, values,
exec marks and the decompressor / depth-sort ordering probe over all sessions, and compares the runtime hits per watch with the static list of w1e_static.py.

usage: w1e_report.py [--date YYYYMMDD ...] [--out path]
"""
import argparse
import glob
import json
import os
import sys
import time
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import w1a_report as R  # noqa: E402
import w1d_merge as M  # noqa: E402
import w1e_static as ST  # noqa: E402

RAW = R.RAW
WATCH_ORDER = ["0B14-0B15", "0648-0649", "090E-0911", "09BA-09BD", "09BE-09C5", "0200-02FF", "0200-021F", "09EC-09ED"]
STATIC_GROUP = {"0B14-0B15": "0B14", "0648-0649": "0648", "090E-0911": "090E-0911", "09BA-09BD": "09BA-09BD", "09BE-09C5": "09BE-09C5", "0200-02FF": "0200-02FF",
                "0200-021F": "0200-02FF", "09EC-09ED": "09EC-09ED"}
STATIC_RANGE = {"0B14-0B15": (0x0B14, 0x0B15), "0648-0649": (0x0648, 0x0649), "090E-0911": (0x090E, 0x0911), "09BA-09BD": (0x09BA, 0x09BD), "09BE-09C5": (0x09BE, 0x09C5),
                "0200-02FF": (0x0200, 0x02FF), "0200-021F": (0x0200, 0x021F), "09EC-09ED": (0x09EC, 0x09ED)}


def load_sessions(dates, dm=False):
    out = []
    for date in dates:
        for p in sorted(glob.glob(os.path.join(RAW, "W1e_*_%s.json" % date))):
            base = os.path.basename(p)
            if base.startswith(("W1e_merged", "W1e_report", "W1e_run", "W1e_static")):
                continue
            if ("_dm_" in base) != dm:    # the displayModeFlags runs (_dm) are reported separately
                continue
            with open(p, encoding="utf-8") as f:
                d = json.load(f)
            if "census" in d:
                c = d["census"]
                if isinstance(c, str):
                    c = json.loads(c)
                if not isinstance(c, dict) or "rows" not in c:
                    raise SystemExit("%s: census has no rows (truncated or failed run); the file is not merged" % base)
                out.append(dict(name="natural_fr10", final=c, frames=d.get("inputFrames"), h1=d["h1"], scene=d.get("endScene"), rom=d.get("rom"), seconds=d.get("seconds"),
                                session={}))
            else:
                if not d.get("final"):
                    continue
                out.append(dict(name=d["session"]["name"], final=d["final"], frames=d.get("frames"), h1=d["h1"], scene=d.get("scene") or d["final"].get("endScene"),
                                rom=d.get("rom"), seconds=d.get("seconds"), session=d["session"]))
    return out


def merge_order(sessions):
    callers = {}
    tot = dict(sorts=0, clears=0, builds=0, dirtyBuilds=0, decCalls=0, overlap=0)
    hist = defaultdict(int)
    dirty = []
    pending_end = []
    for s in sessions:
        o = s["final"].get("order")
        if not o:
            continue
        for k in tot:
            tot[k] += o.get(k, 0) or 0
        for nz, c in o.get("nzHist", []):
            hist[int(nz)] += c
        for x in o.get("dirtySamples", []) or []:
            dirty.append("%s: %s" % (s["name"], x))
        for x in o.get("pendingAtEnd", []) or []:
            pending_end.append("%s: %s" % (s["name"], x))
        for c in o.get("callers", []):
            e = callers.setdefault(c["name"], dict(off=c["off"], n=0, clearedFirst=0, sortFirst=0, superseded=0, late=[], scenes={}, sessions={}, samples=[]))
            e["n"] += c["n"]
            e["clearedFirst"] += c["clearedFirst"]
            e["sortFirst"] += c["sortFirst"]
            e["superseded"] += c.get("superseded", 0)
            e["late"] += ["%s: %s" % (s["name"], x) for x in c.get("lateClear", [])]
            e["samples"] += ["%s: %s" % (s["name"], x) for x in c.get("samples", [])]
            for sc, n in c.get("scenes", []):
                e["scenes"][sc] = e["scenes"].get(sc, 0) + n
            if c["n"]:
                e["sessions"][s["name"]] = c["n"]
    return callers, tot, hist, dirty, pending_end


def main(args):
    dates = args.date or [time.strftime("%Y%m%d")]
    out = args.out or os.path.join(RAW, "W1e_dm_report.md" if args.dm else "W1e_report.md")
    sessions = load_sessions(dates, args.dm)
    srows, tags, tag_keys, names, nkeys = ST.scan()
    dec = M.Decoder(tags, tag_keys, names, nkeys)
    rows, pairs, execs, probes, ctl, scenes_seen = M.merge(sessions)

    L = ["# W1-e merged census (%s)\n" % ", ".join(dates)]
    L.append("sessions: %d; frames (sum of per-session frame counters): %d; $36 write control: %d; NMI exec control: %d\n" % (len(sessions), ctl["frames"], ctl["ctl36"], ctl["nmi"]))
    L.append("## Sessions\n")
    L.append("| session | frames | end scene | H1 (k, sp, scene) | $0200 watch | hits | $36 writes | NMI execs | seconds |")
    L.append("|---|---|---|---|---|---|---|---|---|")
    for s in sessions:
        h = s["h1"]
        names_w = sorted(set(r["name"] for r in s["final"]["rows"] if r["name"].startswith("0200")))
        L.append("| %s | %s | %02X | %02X %04X %02X | %s | %s | %s | %s | %s |" % (s["name"], s["frames"], (s["scene"] or 0), h.get("k") or 0, h.get("sp") or 0, h.get("scene") or 0,
                                                                                  ",".join(names_w) or "-", s["final"].get("hits"), s["final"].get("control36Writes"),
                                                                                  s["final"].get("nmiExecs"), s.get("seconds")))
    L.append("")
    L.append("## Scenes visited (frames, sum)\n")
    L.append(" ".join("%02X:%d" % (int(k), v) for k, v in sorted(scenes_seen.items(), key=lambda kv: int(kv[0]))) + "\n")
    L.append("## Scene sequences (per session)\n")
    for s in sessions:
        L.append("- %s: %s" % (s["name"], " ".join(s["final"].get("sceneSeq") or [])))
    L.append("")

    merged = dict(ctl=ctl, rows=[], pairs=[], execs=execs, sessions=[s["name"] for s in sessions], scenes=dict(scenes_seen), static=[], compare=[], order={})
    watch_names = []
    for r in rows.values():
        if r["name"] not in watch_names:
            watch_names.append(r["name"])
    watch_names.sort(key=lambda n: WATCH_ORDER.index(n) if n in WATCH_ORDER else 99)

    runtime_offs = defaultdict(lambda: defaultdict(int))
    for wname in watch_names:
        L.append("## %s\n" % wname)
        L.append("| kind | offset | file:line | instruction | routine | count | sessions | scenes | addrs (distinct, first 12) | values (max 8) | DMA? |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|")
        agg = {}
        for key, e in rows.items():
            if e["name"] != wname:
                continue
            r = dec.resolve_pc(e["pc"])
            g = agg.setdefault((e["kind"], r.get("off"), e["pc"] if r.get("off") is None else ""), dict(r=r, n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}, kind=e["kind"],
                                                                                                         amin=e["amin"], amax=e["amax"]))
            g["n"] += e["n"]
            g["amin"], g["amax"] = min(g["amin"], e["amin"]), max(g["amax"], e["amax"])
            for src, dst in ((e["sessions"], g["sessions"]), (e["scenes"], g["scenes"]), (e["addrs"], g["addrs"]), (e["vals"], g["vals"]), (e["ctx"], g["ctx"])):
                for k_, v_ in src.items():
                    dst[k_] = dst.get(k_, 0) + v_
        ctx_blocks = []
        for key, g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0)):
            r = g["r"]
            ad = sorted(g["addrs"].items(), key=lambda kv: int(kv[0]))
            addrs = ",".join("%05X:%d" % (int(a), c) for a, c in ad[:12]) + (" ..(%d..%05X)" % (len(ad), g["amax"]) if len(ad) > 12 else "")
            vals = ",".join("%02X:%d" % (int(v), c) for v, c in sorted(g["vals"].items(), key=lambda kv: int(kv[0]))[:8])
            dma = "DMA" if r.get("dma") else ""
            L.append("| %s | %s | %s | %s | %s | %d | %s | %s | %s | %s | %s |" % (g["kind"], r.get("off"), r["where"], r["text"], r["routine"], g["n"], M.fmt_sessions(g["sessions"]),
                                                                               M.fmt_scenes(g["scenes"]), addrs, vals[:80], dma))
            merged["rows"].append(dict(watch=wname, kind=g["kind"], pc=key[2], off=r.get("off"), where=r["where"], text=r["text"], routine=r["routine"], n=g["n"], sessions=g["sessions"],
                                       scenes=g["scenes"], addrs=g["addrs"], vals=g["vals"], ctx=g["ctx"], dma=bool(dma)))
            if r.get("off") is not None:
                runtime_offs[wname][r["off"]] += g["n"]
            if g["ctx"]:
                ctx_blocks.append((g, r))
        L.append("")
        for g, r in ctx_blocks:
            top = sorted(g["ctx"].items(), key=lambda kv: -kv[1])[:8]
            L.append("- %s at offset %s (%s): %s" % (g["kind"], r.get("off"), r["routine"], "; ".join("%s x%d" % (k, c) for k, c in top)))
        L.append("")

    L.append("## Static list versus runtime\n")
    L.append("Static rows: tagged instructions whose operand names an address of the watch (`w1e_static.py`; an indexed form counts by its base). Runtime: the instruction that ends at the logged PC. "
             "`0200-021F` sessions only see a 32-byte window of the page, so a static site that touches only higher buckets can miss there; the `0200-02FF` sessions are the full page.\n")
    all_static = defaultdict(list)
    for sr in srows:
        all_static[sr["group"]].append(sr)
    for wname in WATCH_ORDER:
        if wname not in STATIC_GROUP:
            continue
        lo, hi = STATIC_RANGE[wname]
        slist = [x for x in all_static[STATIC_GROUP[wname]] if lo - 1 <= x["addr"] <= hi]
        rt = runtime_offs.get(wname, {})
        soffs = set(x["off"] for x in slist)
        miss = [x for x in slist if x["off"] not in rt]
        new = sorted(o for o in rt if o not in soffs)
        L.append("### %s\n" % wname)
        L.append("static sites: %d; hit at runtime: %d; not hit: %d; runtime sites not in the static list: %d\n" % (len(slist), len(slist) - len(miss), len(miss), len(new)))
        merged["compare"].append(dict(watch=wname, static=len(slist), hit=len(slist) - len(miss), missed=[x["off"] for x in miss], new=new))
        if miss:
            L.append("| static offset | file:line | instruction | routine | access |")
            L.append("|---|---|---|---|---|")
            for x in miss[:60]:
                L.append("| %d | %s | %s | %s | %s |" % (x["off"], x["where"], x["text"], x["routine"], x["access"]))
            L.append("")
        if new:
            L.append("Runtime sites not in the static list:\n")
            L.append("| offset | file:line | instruction | routine | count |")
            L.append("|---|---|---|---|---|")
            for o in new:
                t = tags[o]
                L.append("| %d | %s:%d | %s | %s | %d |" % (o, t["file"], t["line"], t["text"], dec.routine(o), rt[o]))
            L.append("")
        for x in slist:
            merged["static"].append(dict(watch=wname, off=x["off"], where=x["where"], text=x["text"], routine=x["routine"], access=x["access"], runtime=rt.get(x["off"], 0)))

    L.append("## Read <- last writer pairs\n")
    L.append("| watch | reader off | reader instruction | writer off (or init) | writer instruction | count | sessions |")
    L.append("|---|---|---|---|---|---|---|")
    agg = {}
    for key, e in pairs.items():
        wname, _, rest = key.partition(" read ")
        rpc, _, wpc = rest.partition(" <- ")
        rr = dec.resolve_pc(rpc)
        if wpc.startswith("init") or ":" not in wpc:
            wr = dict(off="init", text="(initial value of the state, no write seen)")
        else:
            wr = dec.resolve_pc(wpc)
        g = agg.setdefault((wname, rr.get("off"), wr.get("off")), dict(rr=rr, wr=wr, n=0, sessions={}))
        g["n"] += e["n"]
        for k_, v_ in e["sessions"].items():
            g["sessions"][k_] = g["sessions"].get(k_, 0) + v_
    for (wname, ro, wo), g in sorted(agg.items(), key=lambda kv: (WATCH_ORDER.index(kv[0][0]) if kv[0][0] in WATCH_ORDER else 99, kv[0][1] or 0, str(kv[0][2]))):
        L.append("| %s | %s | %s | %s | %s | %d | %s |" % (wname, ro, g["rr"]["text"], wo, g["wr"]["text"], g["n"], M.fmt_sessions(g["sessions"])))
        merged["pairs"].append(dict(watch=wname, reader=ro, writer=wo, n=g["n"]))
    L.append("")

    L.append("## Exec marks\n")
    L.append("| name | offset | count | first scenes | sessions |")
    L.append("|---|---|---|---|---|")
    for name, e in sorted(execs.items(), key=lambda kv: kv[1]["off"]):
        L.append("| %s | %d | %d | %s | %s |" % (name, e["off"], e["n"], M.fmt_scenes(e["scenes"]) if e["scenes"] else "-", M.fmt_sessions(e["sessions"], 5)))
    L.append("")

    callers, tot, hist, dirty, pending_end = merge_order(sessions)
    merged["order"] = dict(callers=callers, tot=tot, hist=dict(hist))
    L.append("## Decompressor versus depth-sort ordering probe\n")
    L.append("At each call of `QuintetLzDecompress` (per call site) the probe notes which comes first: `ClearActorRenderList` (the bucket page is re-zeroed before the next sort) or "
             "`SortActorsByDepth` (the sort would read the dictionary garbage). At every `SortActors_BuildFinalList` entry the 256 words `$0200-$03FE` are scanned; a nonzero word is garbage.\n")
    L.append("totals: decompress calls %(decCalls)d; clears %(clears)d; sorts %(sorts)d; BuildFinalList entries %(builds)d; entries with a nonzero bucket word %(dirtyBuilds)d; "
             "same call site called again before any clear or sort %(overlap)d\n" % tot)
    L.append("| call site | offset | calls | clear first | sort first | superseded by a later call | scenes | sessions |")
    L.append("|---|---|---|---|---|---|---|---|")
    for name, e in sorted(callers.items(), key=lambda kv: kv[1]["off"]):
        L.append("| %s | %d | %d | %d | %d | %d | %s | %s |" % (name, e["off"], e["n"], e["clearedFirst"], e["sortFirst"], e["superseded"], M.fmt_scenes(e["scenes"]) if e["scenes"] else "-",
                                                                M.fmt_sessions(e["sessions"], 4)))
    L.append("")
    L.append("nonzero bucket words per BuildFinalList entry (nz words: entries): " + ", ".join("%d: %d" % (k, v) for k, v in sorted(hist.items())) + "\n")
    for name, e in sorted(callers.items(), key=lambda kv: kv[1]["off"]):
        for x in e["late"][:6]:
            L.append("- late clear after %s: %s" % (name, x))
        for x in e["samples"][:6]:
            L.append("- sort-first sample after %s: %s" % (name, x))
    for x in dirty[:20]:
        L.append("- dirty build: %s" % x)
    for x in pending_end[:20]:
        L.append("- pending at end: %s" % x)
    L.append("")

    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1e_dm_merged.json" if args.dm else "W1e_merged.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=1, default=str)
    print("wrote", out, len(L), "lines")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", nargs="*", default=None)
    ap.add_argument("--out", default=None)
    ap.add_argument("--dm", action="store_true", help="report the _dm runs (extra $09EC-$09ED watch) instead of the main table")
    main(ap.parse_args())
