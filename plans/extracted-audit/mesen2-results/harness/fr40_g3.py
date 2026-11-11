#!/usr/bin/env python3
"""FR40 follow-up: scenes whose lock did not end within 1500 frames with A mashed: watch up to 7000 frames with A mashed (stop after 40 free frames).
Variant g3_mash, same destination as the g_ run. usage: fr40_g3.py ids ..."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
import fr40_an as A  # noqa: E402

def main():
    m, info = fr40.open_o()
    try:
        for a in sys.argv[1:]:
            sid = int(a, 0)
            g = A.rows[sid]["g_mash"]
            dest = tuple(g["dest"]) if g.get("dest") else None
            r = fr40.trial(m, info, sid, "g3_mash", [], watch=7000, inp="mashA", stop_free=40, shot=True, move=False, dest=dest)
            print(fr40.brief(r), "dest", dest, [(t["n"], hex(t["mask"]), hex(t["pf"])) for t in r["tl"]][:6], hex(r.get("dmf1", 0)), flush=True)
    finally:
        m.close()
main()
