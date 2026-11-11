#!/usr/bin/env python3
"""FR30 batch 10: scene-meta gates (FL10-09 .. FL10-17). For each (scene, flag set) a control load (the gate flags clear) and a forced load; the run records VRAM 1 KB chunk checksums
(64 chunks), CGRAM palette sums at the first and middle settle frame and a screenshot. A difference between control and forced (and equality of the repeated runs) is the observation;
equal VRAM and CGRAM means INCONCLUSIVE (the gated art may be off screen or not uploaded)."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

CASES = {
    "T09": [(6, [], "ctl"), (6, [33], "f33"), (6, [33, 76], "f33_76")],
    "T10": [(6, [], "ctl"), (6, [76], "f76")],
    "T11": [(90, [], "ctl"), (90, [112], "f112"), (92, [], "ctl"), (92, [112], "f112")],
    "T12": [(s, f, k) for s in (95, 96, 97, 98) for f, k in (([], "ctl"), ([123], "f123"))],
    "T13": [(s, f, k) for s in (95, 96, 97, 98, 100, 101) for f, k in (([], "ctl"), ([126], "f126"))],
    "T14": [(103, [], "ctl"), (103, [136], "f136")],
    "T15": [(120, [], "ctl"), (120, [150], "f150")],
    "T17": [(140, [], "ctl"), (140, [244], "f244")],
}


def one(m, info, tag, scene, setf, k, rep=""):
    name = f"{tag}_s{scene:02X}_{k}{rep}"
    r = visit(m, info, name, S01R, shot=(name if not rep else None), scene=scene, set=setf, settle=60, watch=False, vram=True, cgram=True)
    return r


def diff(a, b):
    v = [i for i, (x, y) in enumerate(zip(a["vram"], b["vram"])) if x != y]
    c1 = [i for i, (x, y) in enumerate(zip(a["cgram30"], b["cgram30"])) if x != y]
    c0 = [i for i, (x, y) in enumerate(zip(a["cgram1"], b["cgram1"])) if x != y]
    return v, c0, c1


if __name__ == "__main__":
    m, info = open_o()
    try:
        for tag in sys.argv[1:] or list(CASES):
            res = {}
            for scene, setf, k in CASES[tag]:
                r = one(m, info, tag, scene, setf, k)
                res[(scene, k)] = r
                print(tag, "scene", hex(scene), k, "scene@", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"), "shot", (r.get("screenshot") or "")[-40:])
            for scene in sorted({s for s, _, _ in CASES[tag]}):
                ctl = res.get((scene, "ctl"))
                for (s2, k), r in res.items():
                    if s2 == scene and k != "ctl" and ctl:
                        v, c0, c1 = diff(ctl, r)
                        print(f"  {tag} scene {scene:#x} {k} vs ctl: vram chunks differ {v}  cgram@1 palettes {c0}  cgram@30 palettes {c1}")
                # repeat of the forced runs for determinism
            for scene, setf, k in CASES[tag]:
                if k != "ctl":
                    r2 = one(m, info, tag, scene, setf, k, rep="_repeat")
                    r = res[(scene, k)]
                    print(f"  repeat {scene:#x} {k}: vram equal {r['vram'] == r2['vram']} cgram equal {r['cgram30'] == r2['cgram30']}")
    finally:
        m.close()
