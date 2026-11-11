#!/usr/bin/env python3
"""FR23 batch 9: FL27-06 ($A7 = byte $0A14 bit 7, scene $9A): actor list with the flag clear and set; FL31-11 ($A5 = byte $0A14 bit 5): Watermia scenes $79 / $7A with and without $A5."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

which = sys.argv[1:] or ["A7"]
m, info = open_o()


def lst(r, key, pref=None):
    out = []
    for a in L.actor_names(r.get(key)):
        if a["file"] in ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics"):
            continue
        out.append(f"{a['file']}@{a['line']}({a['x']},{a['y']})")
    return out


try:
    if "A7" in which:
        for nm, st in (("ctl", []), ("fA7", [167])):
            hooks = "onSample=fr22.drive{ rec={ {name='fA7',addr=0x0A14,bit=0x80},{name='mask',addr=0x065A,size=2} }, snaps={30}, adv=false }"
            r = visit(m, info, f"FL27-06_{nm}", S01R, scene=0x9A, set=st, settle=200, watch=False, hooks=hooks, shot=f"FL27-06_{nm}", frames=600)
            print(nm, summarize(r).split(chr(10))[0][:170])
            print("   actors0", lst(r, "actors0"))
            print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:300])
    if "P79" in which:   # probe: actor list of scene $79 / $7A
        for sc in (0x79, 0x7A):
            hooks = "onSample=fr22.drive{ rec={}, snaps={30}, adv=false }"
            r = visit(m, info, f"FL31-11_probe_{sc:02X}", S01R, scene=sc, set=[151, 145], settle=100, watch=False, hooks=hooks, frames=400)
            print(f"scene {sc:02X}", [f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(L.actor_names(r['snap']['30']), r['snap']['30']) if a['file'].startswith(('wa79', 'wa7A'))])
    if "W" in which:   # FL31-11: Watermia actors with $A5 clear / set
        REC = "{ {name='fA5',addr=0x0A14,bit=0x20},{name='fE2',addr=0x0A1C,bit=0x04},{name='inv0',addr=0x0AB4},{name='jw',addr=0x0AB0,size=2},{name='mask',addr=0x065A,size=2} }"
        def talk(lo, hi, dy, rep):
            return ",".join("{wait=function() return R.n>=60 end, find={0x%X,0x%X}, dy=%d, nodlg=true, max=40}" % (lo, hi, dy) for _ in range(rep))
        cfg = {
            0x79: ("{" + talk(0xA900, 0xA91F, 8, 3) + "," + talk(0xACEC, 0xAD06, 8, 4) + "}", [502047, 502053, 502058, 503047, 503053, 503061, 503067, 503076, 503084]),
            0x7A: ("{" + talk(0xB390, 0xB3AE, 16, 3) + "}", [504751, 504757, 504765]),
        }
        for sc, (steps, ex) in cfg.items():
            for nm, st in (("ctl", [145, 151]), ("fA5", [145, 151, 165])):
                ev = "every=function(R,n) R.n=n if not R.sq then R.sq=fr23.seq(" + steps + ") end R.sq(R,n) end"
                hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{}}, adv=false, {ev} }}"
                r = visit(m, info, f"FL31-11_W{sc:02X}_{nm}", S01R, scene=sc, set=st, settle=600, watch=False, hooks=hooks, execs=ex, shot=f"FL31-11_{sc:02X}_{nm}", frames=1500)
                print(f"scene {sc:02X} {nm}", summarize(r).split(chr(10))[0][:120])
                print("   seq", [(q.get("step"), q.get("how"), q.get("n")) for q in r.get("seq") or []])
                print("   execs", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
                print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:500])
    if "E91" in which:   # FL31-11: Euro intro with $A5 clear (plays, sets $A5, queues scene $96) and set (skipped)
        for nm, st in (("ctl", []), ("fA5", [165])):
            hooks = "onSample=fr22.drive{ rec={ {name='fA5',addr=0x0A14,bit=0x20},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }, snaps={}, adv=true }"
            r = visit(m, info, f"FL31-11_E91_{nm}", S01R, scene=0x91, set=st, settle=2400, watch=False, hooks=hooks, execs=[507429, 507527, 507538, 507551], shot=f"FL31-11_E91_{nm}", frames=3000)
            print(nm, summarize(r).split(chr(10))[0][:200])
            print("   execs(507429 test A5, 507527 SetFlag A5, 507538 text, 507551 QueueMapChange $96)", json.dumps(r.get("execs")))
            print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:500])
    if "A96" in which:   # FL27-08: scene $96 actor list with $AC clear / set ($AA $AB set)
        for nm, st in (("ctl", [170, 171]), ("fAC", [170, 171, 172])):
            hooks = "onSample=fr22.drive{ rec={ {name='fAC',addr=0x0A15,bit=0x10},{name='mask',addr=0x065A,size=2} }, snaps={30}, adv=false }"
            r = visit(m, info, f"FL27-08_A96_{nm}", S01R, scene=0x96, set=st, settle=200, watch=False, hooks=hooks, shot=f"FL27-08_A96_{nm}", frames=600)
            print(nm, summarize(r).split(chr(10))[0][:150])
            print("   actors0", lst(r, "actors0"))
    if "J" in which:   # FL27-12 / FL40-10: fireplace_journal (scene $7A, entry pc $B4BE-$B4D5), free slot vs full inventory, then leave and re-enter
        REC = "{ {name='f8F',addr=0x0A11,bit=0x80},{name='inv0',addr=0x0AB4},{name='inv15',addr=0x0AC3},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }"
        steps = ",".join("{wait=function() return R.n>=60 and (kit.r8(0x0A11)&0x80)==0 and (not R.reent or R.ph=='ready') end, find={0xB4BE,0xB4D5}, dy=%d, nodlg=true, max=30}" % d for d in (16, 16, 16, 8, 8, 8, 12, 12, 20, 20))
        for nm, full, reent in (("free", False, False), ("full", True, False), ("full_reenter", True, True)):
            pre = [[0x0AB4 + i, 0x16 + i] for i in range(16)] if full else []
            ph = ""
            if reent:
                ph = ("if (kit.r8(0x0A11)&0x80)~=0 and not R.ph and n>R.nset+120 then kit.w16(0x0642,0x79); R.ph='out'; R.tout=n end "
                      "if R.ph=='out' and kit.r16(0x0644)==0x79 and n>R.tout+70 then kit.w16(0x0642,0x7A); R.ph='in' end "
                      "if R.ph=='in' and kit.r16(0x0644)==0x7A and kit.r8(0xB4)==0 then R.ph='ready'; R.nready=n end ")
            ev = ("every=function(R,n) R.n=n if (kit.r8(0x0A11)&0x80)~=0 and not R.nset then R.nset=n end if not R.sq then R.sq=fr23.seq({" + steps + "}) end "
                  + ph + "if kit.r8(0xB4)~=0 and n%6<2 then fr21.press(R,{'a'}) end R.sq(R,n) end")
            if reent:
                ev = ev.replace("R.reent", "true")
            hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{30,700}}, adv=false, {ev} }}"
            r = visit(m, info, f"FL27-12_J_{nm}", S01R, scene=0x7A, pre=pre, set=[], settle=1100, watch=False, hooks=hooks, execs=[505046, 505050, 505053, 505058, 505060], shot=f"FL27-12_J_{nm}", frames=1900)
            print(nm, summarize(r).split(chr(10))[0][:130])
            print("   seq", [(q.get("step"), q.get("how"), q.get("n")) for q in r.get("seq") or []][:12])
            print("   execs", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
            print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:600])
            for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
                print("   snap", k, "; ".join(f"{a['file']}({a['x']},{a['y']})" for a in L.actor_names(v) if a["file"].startswith(("fireplace", "wa7A"))))
    if "F7A" in which:   # FL27-12: is fireplace_journal ever in the actor list of scene $7A?
        for nm, st in (("none", []), ("many", [141, 145, 148, 150, 151, 165, 226, 143]), ("A5_91_97_E2", [145, 151, 165, 226])):
            hooks = "onSample=fr22.drive{ rec={}, snaps={30,300}, adv=false }"
            r = visit(m, info, f"FL27-12_F7A_{nm}", S01R, scene=0x7A, set=st, settle=320, watch=False, hooks=hooks, shot=None, frames=700)
            for k in ("30", "300"):
                print(nm, k, [f"{a['file']}({a['x']},{a['y']})" for a in L.actor_names(r["snap"][k]) if a["file"] not in ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")])
finally:
    m.close()
