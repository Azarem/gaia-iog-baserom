#!/usr/bin/env python3
"""W1-e static prelude: every tagged instruction of extracted/ whose operand names a watched WRAM address of batch e
($0B14, $0648, $090E/$0910, $09BA-$09C5, $0200-$02FF) with its access class and the routine.

usage: w1e_static.py [--md out.md]

Read-only. Needs the `; {n}` tags of extracted/ (npm run extract:lt output); it stops when there are none.
A name defined as `!name hex` in the same file resolves (`$name`, `$name+2`, `$name, X`); a literal `$0200,X` resolves too.
Indexed/indirect forms whose base is outside the ranges (a pointer into $7E:0200, the stack at $0200 after TCS) cannot be found by an operand search:
the census (runtime) finds them. Block moves (MVN/MVP) with bank $7E and the S-relative / stack forms are listed separately for the $0200 group.
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import w1a_report as R  # noqa: E402

GROUPS = [
    ("0B14", 0x0B14, 0x0B15),
    ("0648", 0x0648, 0x0649),
    ("090E-0911", 0x090E, 0x0911),
    ("09BA-09BD", 0x09BA, 0x09BD),
    ("09BE-09C5", 0x09BE, 0x09C5),
    ("0200-02FF", 0x0200, 0x02FF),
    ("09EC-09ED", 0x09EC, 0x09ED),
]
STORES = ("STA", "STX", "STY", "STZ")
RMW = ("INC", "DEC", "ASL", "LSR", "ROL", "ROR", "TSB", "TRB")
HEX = re.compile(r"\$([0-9A-Fa-f]{4,6})\b(?:\+([0-9A-Fa-f]+))?")
NAME = re.compile(r"\$([A-Za-z_]\w*)(?:\+([0-9A-Fa-f]+))?")


def addrs(text, defs):
    parts = text.split(None, 1)
    if not parts or parts[0].upper() in R.NOOP_MNEMONICS or len(parts) < 2:
        return []
    op = parts[1]
    if op.startswith("#"):
        return []
    out = []
    for m in HEX.finditer(op):
        h = m.group(1)
        add = int(m.group(2), 16) if m.group(2) else 0
        if len(h) == 4:
            out.append((int(h, 16) + add, "literal"))
        elif len(h) == 6 and (int(h[:2], 16) == 0x7E or int(h[:2], 16) <= 0x3F or 0x80 <= int(h[:2], 16) <= 0xBF) and int(h[2:], 16) < 0x2000:
            out.append((int(h[2:], 16) + add, "literal"))
    for m in NAME.finditer(op):
        n = m.group(1)
        if n in defs and defs[n] < 0x10000:
            add = int(m.group(2), 16) if m.group(2) else 0
            out.append((defs[n] + add, "name " + n))
    return out


def scan():
    """-> (rows, tags, keys, names, nkeys): the tagged instructions naming a watched address."""
    tags = R.load_tags()
    if not tags:
        raise SystemExit("no `; {n}` tags in extracted/: ask the user to run npm run extract:lt (not run in an investigation step)")
    names, nkeys = R.load_names()
    keys = sorted(tags)
    rows = []
    for off in keys:
        t = tags[off]
        mn = t["text"].split(None, 1)[0].upper() if t["text"] else ""
        if mn == "COP" or len(mn) != 3:   # COP operands are script parameters, not CPU accesses
            continue
        acc = "write" if mn in STORES else ("read+write" if mn in RMW and len(t["text"].split()) > 1 else "read")
        idx = bool(re.search(r",\s*[XY]\b|\(|\[", t["text"]))
        for v, how in addrs(t["text"], t["defs"]):
            for g, lo, hi in GROUPS:
                # a word access at v also touches v+1: v = lo - 1 counts; for the 0200 group only direct names/literals (the base of an indexed form is the array start)
                if lo - 1 <= v <= hi:
                    rows.append(dict(group=g, off=off, where="%s:%d" % (t["file"], t["line"]), text=t["text"], routine=R.routine(names, nkeys, off),
                                     access=acc, idx=idx, addr=v, how=how))
                    break
    return rows, tags, keys, names, nkeys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", default=None)
    a = ap.parse_args()
    rows, tags, keys, names, nkeys = scan()
    L = []
    for g, lo, hi in GROUPS:
        L.append("### %s ($%04X-$%04X)\n" % (g, lo, hi))
        L.append("| offset | file:line | instruction | routine | access | indexed/indirect | operand |")
        L.append("|---|---|---|---|---|---|---|")
        sel = [r for r in rows if r["group"] == g]
        for r in sel:
            L.append("| %d | %s | %s | %s | %s | %s | %s ($%04X) |" % (r["off"], r["where"], r["text"], r["routine"], r["access"], "yes" if r["idx"] else "no", r["how"], r["addr"]))
        if not sel:
            L.append("| (none) | | | | | | |")
        L.append("")
    L.append("### block moves (MVN / MVP) naming bank $7E, and S-relative / stack-pointer writes (TCS) near the $0200 group\n")
    for off in keys:
        t = tags[off]
        if re.match(r"MV[NP]\b", t["text"], re.I) and re.search(r"7E", t["text"], re.I):
            L.append("- %d %s:%d `%s` %s" % (off, t["file"], t["line"], t["text"], R.routine(names, nkeys, off)))
    L.append("")
    txt = "\n".join(L)
    if a.md:
        with open(a.md, "w", encoding="utf-8") as f:
            f.write(txt + "\n")
    print(txt)


if __name__ == "__main__":
    main()
