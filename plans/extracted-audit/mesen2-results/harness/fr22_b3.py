#!/usr/bin/env python3
"""FR22 batch 3: FL25-02 ($7B / $7E in the Mu scenes $5F $60 $61 $62 $64 $65): four flag variants per scene from S01r, VRAM chunk checksums,
fixed colour (get_ppu_state), tint thinker exec marks (48599 = LDA #$2A path, 48615 = MuTintAndWaveInit LDA #$28 path), one screenshot per run."""
import json
import sys
from fr22_lib import *  # noqa: F401,F403

SCENES = [0x5F, 0x60, 0x61, 0x62, 0x64, 0x65]
VARS = [("none", []), ("7B", [123]), ("7E", [126]), ("both", [123, 126])]
want = [int(x, 16) for x in sys.argv[1:]] or SCENES
m, info = open_o()
out = {}
try:
    for sc in want:
        base = None
        rows = {}
        for nm, setf in VARS:
            r = visit(m, info, f"FL25-02_s{sc:02X}_{nm}", S01R, scene=sc, set=setf, settle=90, watch=False, vram=True, cgram=True,
                      execs=[48591, 48599, 48615], shot=f"FL25-02_s{sc:02X}_{nm}", frames=1500)
            ppu = m.call("get_ppu_state")
            fc = ppu["derived"]["colorMath"]["fixedColor"]
            cm = ppu["derived"]["colorMath"]
            rows[nm] = {"vram": r["vram"], "fixed": fc, "execs": r["execs"], "scene": r["scene"], "mask1": r["mask1"], "shot": r.get("screenshot"),
                        "cgram": r.get("cgram1"), "cm": {k: cm[k] for k in ("layers", "mode", "halve", "useSubscreen")},
                        "flags1": r["flags1"][:36]}
        c = rows["none"]["vram"]
        print(f"== scene ${sc:02X}")
        for nm, _ in VARS:
            d = [i for i in range(64) if rows[nm]["vram"][i] != c[i]]
            e = rows[nm]["execs"]
            print(f"   {nm:5s} fixed={rows[nm]['fixed']} chunks!=none {d}  exec #2A path {e['48599'][0]} #28 path {e['48615'][0]} loop {e['48591'][0]} mask1={rows[nm]['mask1']:04X} shot={rows[nm]['shot'].split('/')[-1]}")
        eq = lambda a, b: rows[a]["vram"] == rows[b]["vram"]
        print(f"   vram equal: none==7B {eq('none', '7B')}, 7E==both {eq('7E', 'both')}, 7B==7E {eq('7B', '7E')}, none==7E {eq('none', '7E')}")
        out[f"{sc:02X}"] = rows
finally:
    m.close()
store("FL25-02_summary", out)
