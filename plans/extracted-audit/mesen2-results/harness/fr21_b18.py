#!/usr/bin/env python3
"""FR21 batch 18: FL22-11 ($0175 = flag 373, byte $0A2E bit 5): Castoth scene $29 vs Babel rematch scene $F2. SIMULATED defeat: enemiesRemaining ($0AEC) poked to 0 (the fight itself is not played)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f373',addr=0x0A2E,bit=0x20},{name='sc',addr=0x0644,size=2},{name='form',addr=0x0AD4,size=2},{name='mask',addr=0x065A,size=2} }"
EX = [694746, 694851, 694870, 694969, 695015, 695031, 695046]
try:
    for nm, sc, poke in (("sF2_poke_late", 0xF2, 900),):
        at = "{}" if poke is None else "{ [%d]=function(R,n) kit.w16(0x0AEC,0); kit.w16(0x0AEE,0); R.poked=n end }" % poke
        r = visit(m, info, f"FL22-11_{nm}", S01R, scene=sc, settle=1500, watch=False, execs=EX,
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + " }", shot=f"FL22-11_{nm}")
        print(brief(r, limit=10), "poked", r.get("poked"))
finally:
    m.close()
