#!/usr/bin/env python3
"""FR20 batch 5: FL21-01 scene 0A and 0E with $21 clear vs set (base N03)."""
import sys
from fr20_lib import *  # noqa: F401,F403
m, info = open_o()
def W(name, st, **k):
    r = visit(m, info, name, st, shot=name, **k)
    a = r.get("actors0_named") or []
    from collections import Counter
    c = Counter(x.get("file", "?").split("/")[-1] for x in a)
    print(summarize(r)[:2500] if False else "")
    return r
try:
    for sc in (0x0A, 0x0E):
        for fl in ("clear", "set"):
            kw = dict(set=[33]) if fl == "set" else dict(clear=[33])
            r = visit(m, info, f"FL21-01_s{sc:02X}_21{fl}", N03, scene=sc, settle=300, watch=True, maskwatch=True, cgram=True, shot=f"FL21-01_s{sc:02X}_21{fl}", **kw)
            a = r.get("actors0_named") or []
            from collections import Counter
            c = Counter((x.get("file") or "?").split("/")[-1].replace(".asm", "") for x in a)
            print(f"== scene {sc:02X} $21 {fl} mask0={r['mask0']:04X} mask1={r['mask1']:04X} actors={len(a)} end={r['sceneEnd']}")
            print("   ", dict(c))
            cg = [k for k in r if k.startswith("cgram")]
            ks = sorted(cg, key=lambda k: int(k[5:]))
            print("    animated palettes:", [i for i in range(16) if r[ks[0]][i] != r[ks[-1]][i]], "| flags diff", r.get("flagsPre") == r.get("flags1"))
            for ln in summarize(r).splitlines():
                if ln.lstrip().startswith(("MASK", "FW", "SCENE")): print(ln[:260])
finally:
    m.close()
