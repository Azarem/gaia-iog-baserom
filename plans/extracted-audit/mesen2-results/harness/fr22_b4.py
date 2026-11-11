#!/usr/bin/env python3
"""FR22 batch 4: FL25-10 / FL25-03 (scene $66 Rama altar room). usage: fr22_b4.py probe | T..."""
import json
import sys
from fr22_lib import *  # noqa: F401,F403

SKIP = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")
REC = ("{ {name='f01',addr=0x0A00,bit=0x02},{name='f00',addr=0x0A00,bit=0x01},{name='lo',addr=0x0A00},{name='f0F',addr=0x0A01,bit=0x80},{name='mask',addr=0x065A,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2},{name='inv0',addr=0x0AB4},{name='pf',addr=0x09AE,size=2},{name='dmf',addr=0x09EC,size=2},{name='f80',addr=0x0A10,bit=0x01},{name='f81',addr=0x0A10,bit=0x02},"
       "{name='en',addr=0x0AEC,size=2},{name='f146',addr=0x0A28,bit=0x40},{name='f147',addr=0x0A28,bit=0x80},{name='f60',addr=0x0A0C,bit=0x01},{name='f61',addr=0x0A0C,bit=0x02},{name='f62',addr=0x0A0C,bit=0x04},{name='f63',addr=0x0A0C,bit=0x08},{name='f5B',addr=0x0A0B,bit=0x08},{name='f5C',addr=0x0A0B,bit=0x10},{name='f17A',addr=0x0A2F,bit=0x04},{name='s04',addr=0x0A00,bit=0x10},{name='cnt',addr=0x0A01},{name='f121',addr=0x0A24,bit=0x02},{name='f86',addr=0x0A10,bit=0x40},{name='f87',addr=0x0A10,bit=0x80},{name='f138',addr=0x0A27,bit=0x01},{name='f139',addr=0x0A27,bit=0x02},{name='px',addr=0x09A2,size=2},{name='py',addr=0x09A4,size=2} }")


def show(r, snaps=True, full=None):
    print(summarize(r).splitlines()[0][:230])
    print("   REC", json.dumps((r.get("rec") or [])[:40], separators=(",", ":")))
    if r.get("useRows"):
        print("   useRows", json.dumps(r.get("useRows")))
    if snaps:
        for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
            nm = L.actor_names(v)
            cnt = {}
            for a, b in zip(nm, v):
                if full and full in a["file"]:
                    print(f"      {a['file']}@{a['line']} ({a['x']},{a['y']}) pc{b['pc']:04X} f10={b['f10']:04X} f12={b['f12']:04X}")
                if a["file"] not in SKIP:
                    key = f"{a['file']}@{a['line']}:pc{b['pc']:04X}/chat{b['chat']:04X}"
                    cnt[key] = cnt.get(key, 0) + 1
            print(f"   snap n={k}: " + "; ".join(f"{k2}x{c}" if c > 1 else k2 for k2, c in cnt.items() if not k2.startswith("mu66_altar")))


HITLUA = """function hit(lo, hi, i, v)
  return function(R, n)
    local t = {}
    for _, a in ipairs(fr20.actors()) do if a.pc >= lo and a.pc <= hi then t[#t + 1] = a end end
    table.sort(t, function(p, q) return p.slot < q.slot end)
    R.nsw = #t
    local d = t[i]
    if d then emu.write16(0x10026 + d.slot, v or 0x00FA, emu.memType.snesWorkRam); R.hits = (R.hits or 0) + 1 end
  end
end"""


def trial(m, info, name, at="", snaps=(), settle=300, scene=0x66, shot=None, use=None, rec=None, **kw):
    uses = ",".join("{n=%d,x=%d,y=%d,item=%d}" % u for u in (use or []))
    hooks = f"onSample=fr22.drive{{ rec={rec or REC}, snaps={L.lit(list(snaps))}, at={{{at}}}, use={{{uses}}} }}"
    return visit(m, info, name, S01R, scene=scene, settle=settle, watch=False, hooks=hooks, shot=shot, frames=settle + 400, **kw)


def seq(frames, btn):
    return "".join("[%d]=function(R,n) fr21.press(R,{'%s'}) end," % (f, btn) for f in frames)


def talk(lo, tx=256, ty=180, t0=60):
    """write the low flag byte, teleport south of Rama (actor (256,114)), walk up into her solid block, press A (interact) in pulses."""
    return (f"[{t0}]=function(R,n) kit.w8(0x0A00,{lo}) end,[{t0+5}]=function(R,n) fr21.pos({tx},{ty}) end," + seq(range(t0 + 8, t0 + 90), "up")
            + seq([t0 + 95, t0 + 96, t0 + 97, t0 + 110, t0 + 111, t0 + 112], "a"))


which = sys.argv[1:] or ["probe"]
m, info = open_o()
try:
    if "probe" in which:
        show(trial(m, info, "FL25-10_probe", snaps=(5, 60), settle=100, shot="FL25-10_probe"))
    if "D2" in which:
        pos = [(256, 134, "up"), (256, 94, "down"), (232, 114, "right"), (280, 114, "left"), (256, 150, "up"), (240, 128, "up"), (272, 128, "up")]
        at = f"[60]=function(R,n) kit.w8(0x0A00,0xFC) end,"
        for k, (x, y, d) in enumerate(pos):
            b = 80 + k * 60
            at += f"[{b}]=function(R,n) fr21.pos({x},{y}) end," + seq(range(b + 3, b + 8), d) + seq([b + 12, b + 13, b + 14, b + 28, b + 29, b + 30], "a")
        show(trial(m, info, "FL25-10_D2_scan", at=at, snaps=(), settle=560, shot="FL25-10_D2"))
    if "D3" in which:
        pos = [(256, 90, "down"), (256, 98, "down"), (256, 106, "down"), (256, 122, "up"), (256, 130, "up"), (240, 114, "right"), (236, 106, "right"),
               (236, 122, "right"), (272, 114, "left"), (276, 106, "left"), (276, 122, "left"), (256, 114, "up"), (256, 114, "down")]
        at = f"[60]=function(R,n) kit.w8(0x0A00,0xFC) end,"
        for k, (x, y, d) in enumerate(pos):
            b = 80 + k * 30
            at += f"[{b}]=function(R,n) fr21.pos({x},{y}) end," + seq(range(b + 3, b + 6), d) + seq([b + 9, b + 10, b + 11], "a")
        show(trial(m, info, "FL25-10_D3_scan2", at=at, snaps=(), settle=520, shot="FL25-10_D3"))
    if any(w.startswith("A") for w in which):
        S81 = "[60]=function(R,n) kit.w8(0x0A10, kit.r8(0x0A10)|2) end,"
        OUT = "[40]=function(R,n) fr21.pos(600,150) end,"
        cfg = {"A1": ("C1_80_out", [128], OUT), "A2": ("F1_80_in_then81", [128], S81), "A3": ("F2_80_out_then81", [128], OUT + S81), "A4": ("F3_81only_out", [129], OUT + S81.replace("|2", "|0"))}
        for k, (nm, setf, at) in cfg.items():
            if k in which:
                show(trial(m, info, f"FL25-03_{nm}", at=at, set=setf, snaps=(100, 300), settle=400, shot=f"FL25-03_{k}"))
    P1 = (0x24 * 16 + 12, 9 * 16 + 20)
    P2 = (0x2B * 16 + 12, 9 * 16 + 20)
    if "I1" in which:
        show(trial(m, info, "FL25-03_I1_pedestal1_then2", use=[(40, P1[0], P1[1], 0x13), (140, P2[0], P2[1], 0x13)], settle=500, shot="FL25-03_I1"))
    if "I2" in which:
        show(trial(m, info, "FL25-03_I2_pedestal2_then1_then1again", use=[(40, P2[0], P2[1], 0x13), (140, P1[0], P1[1], 0x13), (400, P1[0], P1[1], 0x13)], settle=600, shot="FL25-03_I2"))
    K_IN = (9 * 16 + 12, 7 * 16 + 20)
    K_OUT = (5 * 16 + 12, 12 * 16 + 20)
    CELLS = [[8, 3], [9, 3], [10, 3], [8, 4], [9, 4], [10, 4], [9, 5], [9, 6], [9, 7]]
    for k, (nm, pos) in {"K1": ("in_box", K_IN), "K0": ("outside_box", K_OUT)}.items():
        if k in which:
            r = trial(m, info, f"FL25-08_{nm}", use=[(40, pos[0], pos[1], 0x10), (300, pos[0], pos[1], 0x10)], settle=600, scene=0x5A, cells=CELLS, vram=True, shot=f"FL25-08_{k}")
            show(r, snaps=False)
            print("   cells0", r.get("cells0")); print("   cells1", r.get("cells1")); store(f"FL25-08_{k}_vram", r.get("vram"))
    if "K2" in which:
        r = trial(m, info, "FL25-08_K2_open_then_walk", at=seq(range(260, 520), "up"), use=[(100, K_IN[0], K_IN[1], 0x10)], settle=560, scene=0x5A, cells=CELLS, shot="FL25-08_K2")
        show(r, snaps=False)
        print("   cells0", r.get("cells0")); print("   cells1", r.get("cells1")); print("   scenes", r.get("scenes"))
    if "K3" in which:
        r = trial(m, info, "FL25-08_K3_nokey_walk", at="[100]=function(R,n) fr21.pos(%d,%d) end," % K_IN + seq(range(260, 520), "up"), settle=560, scene=0x5A, cells=CELLS, shot="FL25-08_K3")
        show(r, snaps=False)
        print("   scenes", r.get("scenes"))
    BOX = (8 * 16 + 12, 20 * 16 + 20)
    for k, (nm, setf) in {"V1": ("0502_only", [1282]), "V0": ("0502_86_87", [1282, 134, 135]), "V2": ("none", [])}.items():
        if k in which:
            r = trial(m, info, f"FL25-09_{k}_{nm}", at=f"[60]=function(R,n) fr21.pos({BOX[0]},{BOX[1]}) end," + seq(range(900, 960), "right"), set=setf, scene=0x67,
                      snaps=(30, 100, 400, 899), settle=1000, shot=f"FL25-09_{k}")
            show(r)
    if "B0" in which or "B1" in which:
        BC = [[7, 19], [7, 14], [7, 13], [7, 15], [6, 19], [8, 19]]
        for k, nm, at in (("B0", "control_nokill", ""), ("B1", "kill_zero_enemies", "[300]=function(R,n) kit.w16(0x0AEC,0) kit.w16(0x0AEE,0) end,")):
            if k in which:
                r = trial(m, info, f"FL25-06_{k}_{nm}", at=at, scene=0x67, snaps=(30, 200, 600), settle=700, cells=BC, shot=f"FL25-06_{k}")
                show(r)
                print("   cells0", r.get("cells0")); print("   cells1", r.get("cells1"))
    BX = {"60": (380, 228), "61": (380, 292), "62": (156, 196), "63": (156, 260)}
    if "J1" in which:
        r = trial(m, info, "FL24-03_J1_uses", scene=0x4C, use=[(60, *BX["60"], 0x0E), (200, *BX["61"], 0x0E), (340, *BX["62"], 0x0E), (480, *BX["63"], 0x0E), (620, *BX["60"], 0x0E)],
                  snaps=(30, 190, 330, 470, 610, 790), settle=800, cells=[[23, 13], [23, 17], [9, 11], [9, 15]], shot="FL24-03_J1")
        show(r, full="sg4C")
        print("   cells0", r.get("cells0")); print("   cells1", r.get("cells1"))
    if "J0" in which:
        r = trial(m, info, "FL24-03_J0_control", scene=0x4C, snaps=(30, 790), settle=800, shot="FL24-03_J0")
        show(r, full="sg4C")
    if "J2" in which:
        r = trial(m, info, "FL24-03_J2_flags_preset", scene=0x4C, set=[96, 97, 98, 99], snaps=(30, 790), settle=800, shot="FL24-03_J2")
        show(r, full="sg4C")
    H = lambda i, v="nil": f"hit(0xD023,0xD068,{i},{v})"
    HC = [("H1", "one_switch_4x", "[100]=%s,[160]=%s,[220]=%s,[280]=%s,[340]=%s," % tuple([H(1)] * 5)),
          ("H2", "four_switches_then_5th", "[100]=%s,[160]=%s,[220]=%s,[280]=%s,[340]=%s," % (H(1), H(2), H(3), H(4), H(1))),
          ("H3", "poke_cnt3_then_hit", "[100]=function(R,n) kit.w8(0x0A01,3) end,[140]=%s," % H(1))]
    for k, nm, at in HC:
        if k in which:
            r = trial(m, info, f"FL24-01_{k}_{nm}", at=at, scene=0x3F, snaps=(), settle=460, execs=[381015, 381054], extra=HITLUA, shot=f"FL24-01_{k}")
            show(r, snaps=False)
            print("   execs", r.get("execs"), " nsw", r.get("nsw"), "hits", r.get("hits"))
    if "HP" in which:
        r = trial(m, info, "FL24-01_HP_probe", scene=0x3F, snaps=(30,), settle=60, shot="FL24-01_HP")
        show(r, full="dm3F")
    def swing(frames, d="up", b="a"):
        return "".join("[%d]=function(R,n) fr21.press(R,{'%s','%s'}) end,[%d]=function(R,n) fr21.press(R,{'%s','%s'}) end," % (f, b, d, f + 1, b, d) for f in frames)

    if "R1" in which:
        at = "[60]=function(R,n) fr21.pos(490,262) end," + seq(range(62, 72), "right") + swing(range(80, 400, 20), "right")
        r = trial(m, info, "FL24-01_R1_real_hits_switch1", at=at, scene=0x3F, settle=460, execs=[381015, 381054], shot="FL24-01_R1")
        show(r, snaps=False)
        print("   execs", r.get("execs"))
    for kb, bb in (("R2", "x"), ("R3", "b"), ("R4", "y")):
        if kb in which:
            at = "[60]=function(R,n) fr21.pos(490,262) end," + seq(range(62, 72), "right") + swing(range(80, 300, 20), "right", bb)
            r = trial(m, info, f"FL24-01_{kb}_real_hits_button_{bb}", at=at, scene=0x3F, settle=340, execs=[381015, 381054], shot=f"FL24-01_{kb}")
            print(summarize(r).splitlines()[0][:100]); print("   rec", [x for x in r["rec"] if "pf" in x or "cnt" in x][:12]); print("   execs", r.get("execs"))
    if "R5" in which:
        at = "[60]=function(R,n) fr21.pos(490,262) end," + seq(range(62, 72), "right") + swing(range(80, 1000, 20), "right", "b")
        r = trial(m, info, "FL24-01_R5_real_hits_long", at=at, scene=0x3F, settle=1060, execs=[381015, 381054], shot="FL24-01_R5")
        print(summarize(r).splitlines()[0][:100]); print("   rec", [x for x in r["rec"] if "cnt" in x or "f121" in x][1:12]); print("   execs", r.get("execs"))
    if "M1" in which:
        at = ""
        stands = [(490, 262), (298, 502), (698, 454), (490, 774)]
        for i, (x, y) in enumerate(stands):
            b = 60 + i * 340
            at += f"[{b}]=function(R,n) fr21.pos({x},{y}) end," + seq(range(b + 2, b + 12), "right") + swing(range(b + 20, b + 330, 20), "right", "b")
        r = trial(m, info, "FL24-01_M1_four_switches_real", at=at, scene=0x3F, settle=1440, execs=[381015, 381054], snaps=(), shot="FL24-01_M1", rec="{ {name='cnt',addr=0x0A01},{name='f121',addr=0x0A24,bit=0x02} }")
        print(summarize(r).splitlines()[0][:100]); print("   rec", [x for x in r["rec"] if "cnt" in x or "f121" in x][1:12]); print("   execs", r.get("execs"))
    if "M2" in which:
        at = ""
        stands = [(490, 774), (490, 262), (298, 502), (698, 454), (490, 774)]
        for i, (x, y) in enumerate(stands):
            b = 60 + i * 520
            at += f"[{b}]=function(R,n) fr21.pos({x},{y}) end," + seq(range(b + 2, b + 12), "right") + swing(range(b + 20, b + 510, 14), "right", "b")
        r = trial(m, info, "FL24-01_M2_order_S4_S1_S2_S3_S4", at=at, scene=0x3F, settle=2700, execs=[381015, 381054], snaps=(), shot="FL24-01_M2", rec="{ {name='cnt',addr=0x0A01},{name='f121',addr=0x0A24,bit=0x02} }")
        print(summarize(r).splitlines()[0][:100]); print("   rec", r["rec"][1:14]); print("   execs", r.get("execs"))
    if "H4" in which or "H5" in which:
        for k, v in (("H4", 3), ("H5", 2)):
            if k in which:
                at = f"[75]=function(R,n) kit.w8(0x0A01,{v}) end,[60]=function(R,n) fr21.pos(490,262) end," + seq(range(62, 72), "right") + swing(range(80, 400, 20), "right", "b")
                r = trial(m, info, f"FL24-01_{k}_poke{v}_then_real_hit", at=at, scene=0x3F, settle=460, execs=[381015, 381054], snaps=(), shot=f"FL24-01_{k}", rec="{ {name='cnt',addr=0x0A01},{name='f121',addr=0x0A24,bit=0x02} }")
                print(summarize(r).splitlines()[0][:100]); print("   rec", r["rec"][:14]); print("   execs", r.get("execs"))
    if "SP0" in which or "SP1" in which:
        for k, at in (("SP0", ""), ("SP1", "[100]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00)|0x10) end,")):
            if k in which:
                r = trial(m, info, f"FL24-11_{k}", at=at, scene=0x85, settle=300, snaps=(98, 110, 140, 290), rec="{ {name='s04',addr=0x0A00,bit=0x10} }", shot=f"FL24-11_{k}")
                print(summarize(r).splitlines()[0][:100]); print("   rec", r["rec"][:14])
                for kk, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
                    nm = L.actor_names(v)
                    print(f"   n={kk}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X} f10={b['f10']:04X}" for a, b in zip(nm, v) if "spear" in a["file"] or "switch" in a["file"]))
    if "S58" in which:
        r = trial(m, info, "FL24-12_S58_observe", scene=0x58, settle=3600, snaps=(30, 600, 1800, 3500), rec="{ {name='lo',addr=0x0A00},{name='dlg',addr=0x09EC,bit=0x2000},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }", shot="FL24-12_S58")
        print(summarize(r).splitlines()[0][:130]); print("   rec", json.dumps(r["rec"][:60], separators=(",", ":")))
        for kk, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
            nm = L.actor_names(v)
            print(f"   n={kk}: " + "; ".join(f"{a['file']}@{a['line']}:pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"].startswith("sp58") or a["file"].startswith("sg58")))
    if "C44" in which:
        R44 = "{ {name='f5B',addr=0x0A0B,bit=0x08},{name='f5C',addr=0x0A0B,bit=0x10},{name='f17A',addr=0x0A2F,bit=0x04},{name='dlg',addr=0x09EC,bit=0x2000},{name='mask',addr=0x065A,size=2} }"
        for k, at in (("C0", ""), ("C1", "[100]=function(R,n) kit.w8(0x0A0B, kit.r8(0x0A0B)|0x08) end,"),
                      ("C2", "[100]=function(R,n) kit.w8(0x0A0B, kit.r8(0x0A0B)|0x08) end,[300]=function(R,n) kit.w8(0x0A0B, kit.r8(0x0A0B)|0x10) end,"),
                      ("C3", "[100]=function(R,n) kit.w8(0x0A0B, kit.r8(0x0A0B)|0x10) end,")):
            r = trial(m, info, f"FL24-04_{k}", at=at, scene=0x44, settle=500, snaps=(90, 290, 490), rec=R44, vram=True, shot=f"FL24-04_{k}")
            print(summarize(r).splitlines()[0][:100]); print("   rec", json.dumps(r["rec"][:20], separators=(",", ":")))
            for kk, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
                nm = L.actor_names(v)
                print(f"   n={kk}: " + "; ".join(f"{a['file']}@{a['line']}:pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"].startswith("dm44")))
            print("   vram", r.get("vram"))
    if "I61" in which or "I64" in which:
        for sc, kk, box in ((0x3D, "I61", (6 * 16 + 12, 5 * 16 + 20)), (0x40, "I64", (9 * 16 + 12, 0x15 * 16 + 20))):
            if kk not in which:
                continue
            R2 = "{ {name='b0',addr=0x0A00,bit=0x01},{name='mask',addr=0x065A,size=2},{name='dlg',addr=0x09EC,bit=0x2000} }"
            for tag, at in (("C", ""), ("F", "[60]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00)|0x01) end,"),
                            ("B", f"[60]=function(R,n) fr21.pos({box[0]},{box[1]}) end,"), ("T", f"[60]=function(R,n) fr21.pos({box[0]},{box[1]}) end,[120]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00)|0x01) end,")):
                r = trial(m, info, f"FL24-02_{kk}_{tag}", at=at, scene=sc, settle=240, snaps=(), rec=R2, readwatch=[0x0A00], shot=f"FL24-02_{kk}_{tag}")
                rr = r.get("readRows") or []
                cnt = {}
                for x in rr:
                    key = f"{x.get('ins')}|d={x.get('d')}"
                    cnt[key] = cnt.get(key, 0) + 1
                print(f"   {kk}_{tag} rec", json.dumps(r["rec"][:8], separators=(",", ":")), "reads", r.get("readCount"), dict(list(cnt.items())[:6]), r.get("shot") or "")
    if "I61" in which or "I64" in which:
        for sc, kk, box in ((0x3D, "I61", (6 * 16 + 12, 5 * 16 + 20)), (0x40, "I64", (9 * 16 + 12, 0x15 * 16 + 20))):
            if kk not in which:
                continue
            R2 = "{ {name='b0',addr=0x0A00,bit=0x01},{name='mask',addr=0x065A,size=2},{name='dlg',addr=0x09EC,bit=0x2000} }"
            for tag, at in (("C", ""), ("F", "[60]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00)|0x01) end,"),
                            ("B", f"[60]=function(R,n) fr21.pos({box[0]},{box[1]}) end,"), ("T", f"[60]=function(R,n) fr21.pos({box[0]},{box[1]}) end,[120]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00)|0x01) end,")):
                r = trial(m, info, f"FL24-02_{kk}_{tag}", at=at, scene=sc, settle=240, snaps=(), rec=R2, readwatch=[0x0A00], shot=f"FL24-02_{kk}_{tag}")
                rr = r.get("readRows") or []
                cnt = {}
                for x in rr:
                    key = f"{x.get('ins')}|d={x.get('d')}"
                    cnt[key] = cnt.get(key, 0) + 1
                print(f"   {kk}_{tag} rec", json.dumps(r["rec"][:8], separators=(",", ":")), "reads", r.get("readCount"), dict(list(cnt.items())[:6]), r.get("shot") or "")
    if "FF" in which:
        for sc in (0x5F, 0x5C, 0x5D, 0x60):
            r = trial(m, info, f"FL25-04_FF_s{sc:02X}", scene=sc, settle=40, snaps=(), rec="{ {name='ff',addr=0x0A1F,bit=0x80},{name='sc',addr=0x0644,size=2} }", shot=None, execs=[48591])
            f0 = r.get("flags0") or ""
            print(f"   scene {sc:02X} flags0[0x1F]={f0[0x1F*2:0x1F*2+2]} flags1[0x1F]={(r.get('flags1') or '')[0x1F*2:0x1F*2+2]} rec={json.dumps(r['rec'][:4], separators=(',', ':'))} loop-exec={r.get('execs')}")
    if "D1" in which:
        show(trial(m, info, "FL25-10_D1_mash", at=talk(0xFC), snaps=(100, 400), settle=500, shot="FL25-10_D1", mash={"button": "a", "from": 150, "to": 450, "down": 2, "gap": 6}))
    if "T1" in which:
        show(trial(m, info, "FL25-10_T1_FC", at=talk(0xFC), snaps=(100, 400), settle=500, shot="FL25-10_T1"))
    if "T2" in which:
        show(trial(m, info, "FL25-10_T2_FE", at=talk(0xFE), snaps=(100, 400, 700), settle=800, shot="FL25-10_T2"))
    if "T3" in which:
        show(trial(m, info, "FL25-10_T3_FF", at=talk(0xFF), snaps=(100, 400), settle=500, shot="FL25-10_T3"))
finally:
    m.close()
