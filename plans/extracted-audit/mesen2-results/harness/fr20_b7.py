#!/usr/bin/env python3
"""FR20 batch 7: FL20-13 read watch of $0A01 through the prologue; FL20-11 scratch $00 in scene 1."""
from fr20_lib import *
m, info = open_o()
try:
    r = visit(m, info, "FL20-13_prologue_readwatch", TITLE, scene=0x8C, set=[244], settle=6500, watch=True, readwatch=[0x0A01], sampleEvery=1000)
    print(summarize(r)[:1500])
    print("reads of byte $0A01:", r["readCount"])
    for x in r["readRows"][:40]: print("  READ", x)
    s1 = dict(scene=1, settle=40, peek=[0x1010, 0x1012, 0x1028, 0x102A], watch=True)
    for nm, kw in (("lowY", dict(teleport=[0x70, 0x120])), ("highY", dict(teleport=[0x70, 0x270])),
                   ("lowY_force_set", dict(teleport=[0x70, 0x120], post=dict(set=[0]))), ("highY_force_clear", dict(teleport=[0x70, 0x270], post=dict(clear=[0])))):
        r = visit(m, info, f"FL20-11_{nm}", N01, shot=f"FL20-11_{nm}", **s1, **kw)
        fw = [(x['f'], x['old'], x['new']) for x in r['fw']['rows'] if x['a'] == 0x0A00]
        print(nm, "bit0 at end:", r["flags1"][:2], "flags after post", (r.get("flagsPost") or "")[:2], "peek", r["peek"], "pos", r["pos"], "FW $0A00 rows", fw[:8])
finally:
    m.close()
