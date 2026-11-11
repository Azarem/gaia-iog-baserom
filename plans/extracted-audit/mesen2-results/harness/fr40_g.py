#!/usr/bin/env python3
"""FR40 follow-up at the natural entry: for scenes whose entry is blocked (or whose draft flags were tested at a wall landing), repeat the long watch
(no input, then A mashed), the draft flags and every subset of them at the destination of a scene-warp row that leads into the scene (full warp).
Variants g_none, g_mash, g_draft, g_sub<flags>, g_pre<...> (scene $06). usage: fr40_g.py [ids ...]  (default: the computed set)"""
import itertools
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
import fr40_an as A  # noqa: E402


def natural(sid):
    v = A.rows.get(sid, {})
    nat = [(k, r) for k, r in v.items() if k.startswith("n") and not r["flags"] and r.get("dest") and (r["dest"][0] or r["dest"][1])]
    for want in (("locked", "dialog"), ("free", "pocket"), ("still",)):
        for k, r in sorted(nat, key=lambda kr: int(kr[0][1:])):
            if A.st0(r) in want:
                return tuple(r["dest"])
    sp = fr40.spawn_map().get(sid)
    return tuple(sp) if sp else None


def target_set():
    draft = fr40.draft()
    out = []
    for sid in sorted(A.rows):
        v = A.rows[sid]
        flags = draft[str(sid)]["flags"]
        blocked = any(A.st0(r) in ("locked", "dialog", "left") for k, r in v.items() if not r["flags"] and not k.startswith(("ctl", "long")))
        dr = v.get("draft")
        bad_draft = flags and (dr is None or A.st0(dr) != "free")
        if blocked or bad_draft:
            out.append(sid)
    return out


def main():
    ids = [int(a, 0) for a in sys.argv[1:]] or target_set()
    draft = fr40.draft()
    m, info = fr40.open_o()
    try:
        for sid in ids:
            flags = draft[str(sid)]["flags"]
            dest = natural(sid)
            r0 = fr40.trial(m, info, sid, "g_none", [], watch=1500, inp="none", stop_free=40, shot=False, move=False, dest=dest)
            print(fr40.brief(r0), "dest", dest, flush=True)
            if not r0.get("releaseN"):
                r1 = fr40.trial(m, info, sid, "g_mash", [], watch=1500, inp="mashA", stop_free=40, shot=False, move=False, dest=dest)
                print(fr40.brief(r1), flush=True)
            if flags:
                pre = [22] if sid == 6 else []
                rd = fr40.trial(m, info, sid, "g_draft", pre + flags, dest=dest)
                print(fr40.brief(rd), flush=True)
                if pre:
                    rc = fr40.trial(m, info, sid, "g_pre", pre, dest=dest)
                    print(fr40.brief(rc), flush=True)
                if len(flags) > 1:
                    for k in range(1, len(flags)):
                        for sub in itertools.combinations(flags, k):
                            rs = fr40.trial(m, info, sid, "g_sub" + "+".join(map(str, sub)), pre + list(sub), dest=dest)
                            print(fr40.brief(rs), flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
