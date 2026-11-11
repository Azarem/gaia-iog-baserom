#!/usr/bin/env python3
"""FR20 batch 6: FL21-04 jeweler gem in the six scenes with $E8 clear vs set; scene EA intro ($E8 write time)."""
from fr20_lib import *
m, info = open_o()
try:
    for sc in (0x01, 0x32, 0x6B, 0x78, 0x9B, 0xC3):
        row = {}
        for fl, kw in (("clear", dict(clear=[232])), ("set", dict(set=[232]))):
            r = visit(m, info, f"FL21-04_s{sc:02X}_E8{fl}", N03, scene=sc, settle=30, watch=False, **kw)
            row[fl] = sum(1 for x in r["actors0_named"] if "jeweler_gem" in (x.get("file") or "")), r["sceneEnd"]
        print(f"scene {sc:02X}: gem count E8 clear={row['clear'][0]} E8 set={row['set'][0]} (end scene {row['clear'][1]:02X}/{row['set'][1]:02X})")
    r = visit(m, info, "FL21-04_sEA_E8clear_intro", N03, scene=0xEA, clear=[232], settle=1500, watch=True, maskwatch=True, execs=[587571], sampleEvery=100, shot="FL21-04_sEA_E8clear_intro")
    print(summarize(r)[:3000])
finally:
    m.close()
