#!/usr/bin/env python3
"""FR22 batch 3b: FL25-02 follow-up. Compare the whole decompressed layer maps in WRAM ($7E:A000 layer 0, $7E:C000 layer 1, 8 KB each)
between the four flag variants, because the VRAM window at the spawn point can hide differences."""
import hashlib
import re
import json
import sys
from fr22_lib import *  # noqa: F401,F403

SCENES = [0x5F, 0x60, 0x61, 0x62, 0x64, 0x65]
VARS = [("none", []), ("7B", [123]), ("7E", [126]), ("both", [123, 126])]
want = [int(x, 16) for x in sys.argv[1:]] or SCENES
m, info = open_o()
out = {}


def rd(addr, n):
    r = m.call("read_memory", address=addr, length=n, type="workRam", format="hex")
    out = bytearray()
    for ln in str(r).splitlines()[1:]:
        if ":" not in ln:
            continue
        toks = ln.split(":", 1)[1].split()[:16]
        out += bytes(int(t, 16) for t in toks)
    assert len(out) == n, (len(out), n)
    return bytes(out)


REG = [("7E:A000", 0xA000), ("7E:C000", 0xC000), ("7F:A000", 0x1A000), ("7F:C000", 0x1C000)]
try:
    for sc in want:
        rows = {}
        for nm, setf in VARS:
            visit(m, info, f"FL25-02b_s{sc:02X}_{nm}", S01R, scene=sc, set=setf, settle=90, watch=False, frames=1500)
            rows[nm] = [rd(a, 0x2000) for _, a in REG]
        base = rows["none"]
        print(f"== scene ${sc:02X}")
        for nm, _ in VARS:
            parts = []
            for k, (rn, _) in enumerate(REG):
                d = sum(1 for x in range(0x2000) if rows[nm][k][x] != base[k][x])
                parts.append(f"{rn} {hashlib.sha1(rows[nm][k]).hexdigest()[:6]} d={d:4d}")
            print(f"   {nm:5s} " + " | ".join(parts))
        out[f"{sc:02X}"] = {k: [hashlib.sha1(x).hexdigest() for x in v] for k, v in rows.items()}
finally:
    m.close()
store("FL25-02b_summary", out)
