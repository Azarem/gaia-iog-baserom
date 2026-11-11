#!/usr/bin/env python3
"""FR30 batch 8: event-block flags $0100+n (D3). Each trial loads the block's scene from S01r twice (flag clear = control, flag set = forced) and records the
destination and the source rectangle of the event_block_table entry (read from the extracted table, entry n = flag - $0100). Prediction: only the forced load shows the
destination equal to the control's source rectangle; the source rectangle is unchanged; the control destination differs from the source.
Layer 0: mapLayerTilemap + collisionLayer; layer 1: effectLayerTilemap (collision through the tile-id lookup, not recorded).
Subcommands: names of the trials; `rl` = FL11-04 reload sequence (set, load; clear, reload)."""
import json
import re
import sys
from fr30_lib import *  # noqa: F401,F403

TABLE = os.path.join(BASEROM, "extracted", "system", "event_block_table.asm")


def entries():
    out = {}
    for line in open(TABLE, encoding="utf-8"):
        mm = re.search(r"event-block-def < ((?:#[0-9A-F]{2}(?:, )?){8}) >\s+;([0-9A-F]{2})", line)
        if mm:
            v = [int(x[1:], 16) for x in mm.group(1).split(", ")]
            out[int(mm.group(2), 16)] = dict(scene=v[0], sx=v[1], sy=v[2], w=v[3], h=v[4], dx=v[5], dy=v[6], layer=v[7])
    return out


E = entries()


def load(m, info, name, n, setf, shot=None, settle=40, extra_at=""):
    e = E[n]
    rects = ("R.dst=fr30.rect(%d,%d,%d,%d,%d); R.src=fr30.rect(%d,%d,%d,%d,%d); R.dst0=fr30.rect(%d,%d,%d,%d,0)" %
             (e["dx"], e["dy"], e["w"], e["h"], e["layer"], e["sx"], e["sy"], e["w"], e["h"], e["layer"], e["dx"], e["dy"], e["w"], e["h"]))
    at = "[%d]=function(R,k) %s end" % (3, rects)
    hooks = drive(at=at, adv=False) + ",final=function(R) R.dstEnd=fr30.rect(%d,%d,%d,%d,%d); R.fl=fr30.bytes(0x0A20,8) end" % (e["dx"], e["dy"], e["w"], e["h"], e["layer"])
    return visit(m, info, name, S01R, shot=shot, scene=e["scene"], set=setf, settle=settle, watch=False, hooks=hooks)


def cmp_rect(a, b):
    ma, mb = a["map"].replace("/", " ").split(), b["map"].replace("/", " ").split()
    d = sum(1 for x, y in zip(ma, mb) if x != y)
    dc = None
    if a.get("col") is not None and b.get("col") is not None:
        ca, cb = a["col"].replace("/", " ").split(), b["col"].replace("/", " ").split()
        dc = sum(1 for x, y in zip(ca, cb) if x != y)
    return d, dc, len(ma)


def trial(m, info, tag, n):
    e = E[n]
    flag = 0x100 + n
    ctl = load(m, info, f"eb{n:02X}_{tag}_control", n, [], shot=f"eb{n:02X}_control")
    frc = load(m, info, f"eb{n:02X}_{tag}_forced", n, [flag], shot=f"eb{n:02X}_forced")
    ctl2 = load(m, info, f"eb{n:02X}_{tag}_control_repeat", n, [])
    frc2 = load(m, info, f"eb{n:02X}_{tag}_forced_repeat", n, [flag])
    print("== block", hex(n), "flag", flag, e)
    for r in (ctl, frc):
        print("  ", r["experiment"], "scene", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"), "ctl36", r.get("ctl36"), "fl", r.get("fl"))
    print("  forced dst vs control src: (map diff, col diff, cells)", cmp_rect(frc["dst"], ctl["src"]))
    print("  control dst vs control src:", cmp_rect(ctl["dst"], ctl["src"]))
    print("  forced src vs control src:", cmp_rect(frc["src"], ctl["src"]))
    print("  forced dst vs control dst:", cmp_rect(frc["dst"], ctl["dst"]))
    if e["layer"]:
        print("  layer0 forced dst vs control dst (must be unchanged):", cmp_rect(frc["dst0"], ctl["dst0"]))
    print("  repeat equal: control", ctl["dst"] == ctl2["dst"], "forced", frc["dst"] == frc2["dst"])
    if e["w"] * e["h"] <= 16:
        print("  ctl dst", ctl["dst"]["map"], "| col", ctl["dst"].get("col"))
        print("  frc dst", frc["dst"]["map"], "| col", frc["dst"].get("col"))
        print("  src    ", ctl["src"]["map"], "| col", ctl["src"].get("col"))


if __name__ == "__main__":
    m, info = open_o()
    try:
        for k in sys.argv[1:] or ["06", "13", "19", "20", "38"]:
            n = int(k, 16)
            trial(m, info, "t", n)
    finally:
        m.close()
