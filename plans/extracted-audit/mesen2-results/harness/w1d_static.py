#!/usr/bin/env python3
"""W1-d static prelude: every tagged instruction of extracted/ whose operand names a `$7F` address (long literal `$7Fxxxx`, or a `$name` defined as `!name 7Fxxxx`)
in the watched ranges of batch d, plus the block moves with bank `$7F`.

usage: w1d_static.py [--group NAME] [--md out.md]

Read-only. Needs the `; {n}` tags of extracted/ (npm run extract:lt output); it stops when there are none.
Groups (WRAM offsets: `$7F:xxxx` = 0x10000 + xxxx):
  7F0000-01FF   literal / non-indexed accesses to $7F:0000-$7F:01FF; indexed forms with a name in this range are slot-relative (see below)
  slot+xx       indexed (,X / ,Y) forms of a name or literal in $7F:0000-$7F:00FF: the actor slot id (or thinker slot id) is the index, so the effective address is
                $7F:1000+slot (actors) or $7F:0F00+slot (thinkers); the field is the operand
  7F0200-09FF   BG3 tilemap staging ($7F0200 bg3TilemapBuffer) and everything up to the palette staging $7F0A00
  7F0A00-0BFF   palette staging buffer (cgramPalette): $7F0B22 / $7F0B24 are colours $91 / $92
  7F0C00-0CFF   backdropColors (COLDATA triplet) and the adhoc DMA block $7F0C03-$7F0C09
  7F0E00-0FFF   $7F0E00 page (zeroed by InitActorPool) and the thinker extended-data page $7F0F00
  7F3000-31FF   $7F3000 (zeroed by InitActorPool) and the OAM compose buffer $7F3100
"""
import argparse
import bisect
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import w1a_report as R  # noqa: E402

LIT = re.compile(r"\$7F([0-9A-Fa-f]{4})\b")
NAMEREF = re.compile(r"\$([A-Za-z_]\w*)((?:\+[0-9A-Fa-f]+)?)")
STORES = ("STA", "STX", "STY", "STZ")
RMW = ("INC", "DEC", "ASL", "LSR", "ROL", "ROR", "TSB", "TRB")

GROUPS = [
    ("7F0000-01FF", 0x0000, 0x01FF),
    ("7F0200-09FF", 0x0200, 0x09FF),
    ("7F0A00-0BFF", 0x0A00, 0x0BFF),
    ("7F0C00-0CFF", 0x0C00, 0x0CFF),
    ("7F0E00-0FFF", 0x0E00, 0x0FFF),
    ("7F3000-31FF", 0x3000, 0x31FF),
]


def group_of(v):
    for n, lo, hi in GROUPS:
        if lo <= v <= hi:
            return n
    return None


def operands(text, defs):
    """[(address_in_7F, indexed, how)] named by the instruction's operand (immediates and branch targets excluded)."""
    parts = text.split(None, 1)
    if not parts or parts[0].upper() in R.NOOP_MNEMONICS or len(parts) < 2:
        return []
    op = parts[1]
    if op.startswith("#"):
        return []
    out = []
    idx = bool(re.search(r",\s*[XY]\b", op))
    for m in LIT.finditer(op):
        out.append((int(m.group(1), 16), idx, "literal"))
    for m in NAMEREF.finditer(op):
        n = m.group(1)
        if n in defs and 0x7F0000 <= defs[n] <= 0x7FFFFF:
            add = int(m.group(2)[1:], 16) if m.group(2) else 0
            out.append(((defs[n] & 0xFFFF) + add, idx, "name " + n))
    return out


def scan():
    tags = R.load_tags()
    if not tags:
        raise SystemExit("no `; {n}` tags in extracted/: ask the user to run npm run extract:lt (not run in an investigation step)")
    names, nkeys = R.load_names()
    rows = []
    for off in sorted(tags):
        t = tags[off]
        mn = t["text"].split(None, 1)[0].upper() if t["text"] else ""
        acc = "write" if mn in STORES else ("read+write" if mn in RMW and len(t["text"].split()) > 1 else "read")
        for addr, idx, how in operands(t["text"], t["defs"]):
            g = group_of(addr)
            if g is None:
                continue
            rows.append(dict(group=g, off=off, where="%s:%d" % (t["file"], t["line"]), text=t["text"], routine=R.routine(names, nkeys, off), access=acc,
                             addr=addr, indexed=idx, how=how))
    return rows, tags, names, nkeys


def blockmoves(tags, names, nkeys):
    out = []
    for off in sorted(tags):
        t = tags[off]
        if re.match(r"MV[NP]\b", t["text"], re.I) and re.search(r"\$7F\b|#\$7F\b|\$7F,", t["text"]):
            out.append(dict(off=off, where="%s:%d" % (t["file"], t["line"]), text=t["text"], routine=R.routine(names, nkeys, off)))
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--group", default=None)
    ap.add_argument("--md", default=None)
    a = ap.parse_args()
    rows, tags, names, nkeys = scan()
    lines = []
    for g, _, _ in GROUPS:
        if a.group and g != a.group:
            continue
        lines.append("### %s\n" % g)
        lines.append("| offset | file:line | instruction | routine | access | indexed | operand |")
        lines.append("|---|---|---|---|---|---|---|")
        for r in [x for x in rows if x["group"] == g]:
            lines.append("| %d | %s | %s | %s | %s | %s | %s $7F%04X |" % (r["off"], r["where"], r["text"], r["routine"], r["access"], "yes" if r["indexed"] else "no", r["how"], r["addr"]))
        lines.append("")
    if not a.group:
        lines.append("### block moves with bank $7F\n")
        for r in blockmoves(tags, names, nkeys):
            lines.append("- %d %s `%s` %s" % (r["off"], r["where"], r["text"], r["routine"]))
    txt = "\n".join(lines)
    if a.md:
        with open(a.md, "w", encoding="utf-8") as f:
            f.write(txt + "\n")
    print(txt)
