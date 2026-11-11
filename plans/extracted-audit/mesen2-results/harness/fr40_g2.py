#!/usr/bin/env python3
"""FR40 follow-up: scenes whose lock starts after the 40-frame stop of the g_ run (delayed lock): watch 600 frames with no early stop, then the same with A mashed.
Variants g2_none, g2_mash. usage: fr40_g2.py SCENE X Y FACE SCROLL ..."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402

def main():
    a = sys.argv[1:]
    m, info = fr40.open_o()
    try:
        for i in range(0, len(a), 5):
            sid, x, y, f, sc = (int(t, 0) for t in a[i:i + 5])
            dest = (x, y, f, sc)
            for var, inp in (("g2_none", "none"), ("g2_mash", "mashA")):
                r = fr40.trial(m, info, sid, var, [], watch=600, inp=inp, shot=False, move=False, dest=dest)
                print(fr40.brief(r), "dest", dest, [(t["n"], hex(t["mask"]), hex(t["pf"])) for t in r["tl"]][:6], hex(r.get("dmf1", 0)), flush=True)
    finally:
        m.close()
main()
