#!/usr/bin/env python3
"""R1 coverage session driver (ROM O). One server session, many legs; native counters are summed per leg (they are cleared by every
load_state_file), the CDL is cumulative over the whole session and archived after every leg.

usage (own process, under a timeout; never from a Cursor-registered long call):
    python r1_run.py --list
    python r1_run.py --fresh --legs boot,natural            # start a new accumulation (reset_cdl, empty accumulator)
    python r1_run.py --legs sessions                        # continue: accumulator and CDL union are reloaded
    python r1_run.py --legs sweep_will,sweep_freedan,sweep_shadow
Output: raw/R1_acc.json (per range sums), raw/R1_legs.json (one record per leg: frames, NMI execs = positive control, scene at the end,
warnings), raw/R1_cdl_union.cdl (save_cdl of the union), raw/R1_cdl_<leg>.cdl is NOT written (one union file only, plus R1_cdl_stats.json).
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import ROM_O, RAW, STATE_DIR, S01R, RESULTS, open_session  # noqa: E402
import w1a_session as W  # noqa: E402

REQ = os.path.join(RAW, "R1_ranges_req.json")
RANGES = json.load(open(os.path.join(RAW, "R1_ranges.json")))
ROWS = RANGES["rows"]
ACC = os.path.join(RAW, "R1_acc.json")
LEGS = os.path.join(RAW, "R1_legs.json")
CDLU = os.path.join(RAW, "R1_cdl_union.cdl")
NMI_ROW = [r for r in ROWS if r["id"] == "CTRL"][0]["req"]


def st(n):
    return os.path.join(STATE_DIR, n)


def jload(p, d):
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else d


class Run:
    def __init__(self, m, info, fresh):
        self.m, self.info = m, info
        self.acc = {} if fresh else jload(ACC, {})
        self.legs = [] if fresh else jload(LEGS, [])
        self.frames = sum(l.get("frames", 0) for l in self.legs)
        if fresh:
            m.call("reset_cdl")
        elif os.path.exists(CDLU):
            m.call("load_cdl", path=CDLU, merge=True)

    def dump(self, leg):
        """Add the counters of the current load to the accumulator; returns the NMI exec count of this load (positive control)."""
        a = self.m.call("get_access_summary", type="prgRom", rangesPath=REQ, cdl=True)
        nmi = 0
        for r in a["rows"]:
            e = self.acc.setdefault(r["name"], dict(exec=0, read=0, write=0, execFirstByte=0, execBytes=0, bytesTouched=0, hottest=None, cdlFlags=0, legs={}))
            e["exec"] += r["exec"]
            e["read"] += r["read"]
            e["write"] += r["write"]
            e["execFirstByte"] += r["execFirstByte"]
            e["execBytes"] = max(e["execBytes"], r["execBytes"])
            e["bytesTouched"] = max(e["bytesTouched"], r["bytesTouched"])
            e["cdlFlags"] = r["cdlFlags"]
            e["cdlCodeBytes"] = r.get("cdlCodeBytes", 0)
            e["cdlDataBytes"] = r.get("cdlDataBytes", 0)
            h = r.get("hottest")
            if h and (not e["hottest"] or h["exec"] > e["hottest"]["exec"]):
                e["hottest"] = h
            if r["exec"] or r["read"] or r["write"]:
                e["legs"][leg] = e["legs"].get(leg, 0) + r["exec"] + r["read"] + r["write"]
            if r["name"] == NMI_ROW:
                nmi = r["execFirstByte"]
        return nmi

    def save(self):
        json.dump(self.acc, open(ACC, "w"))
        json.dump(self.legs, open(LEGS, "w"), indent=1)
        self.m.call("save_cdl", path=CDLU)
        stt = self.m.call("get_cdl_statistics")
        json.dump(stt, open(os.path.join(RAW, "R1_cdl_stats.json"), "w"), indent=1)

    def record(self, **kw):
        self.frames += kw.get("frames", 0)
        self.legs.append(kw)
        self.save()
        print("LEG", {k: v for k, v in kw.items() if k not in ("lua", "warnings")}, "total frames", self.frames, flush=True)

    def h1(self, path):
        rec = W.h1(self.m, path)
        rec["nmi"] = self.dump("h1:" + os.path.basename(path))
        if not rec["ok"]:
            raise RuntimeError(f"H1 failed {rec}")
        return rec


# ---------------------------------------------------------------------------------------------------------------- legs
def lean_lua(s):
    ats = []
    if s.get("scene") is not None:
        ats.append(f"[2]=function() kit.w16(0x0642, {s['scene']}) end")
    for fr, sc in s.get("chain", []):
        ats.append(f"[{fr}]=function() kit.w16(0x0642, {sc}) end")
    for fr, code_ in s.get("atcode", []):
        ats.append(f"[{fr}]=function() {code_} end")
    head, extra = "", ""
    drive = s["drive"]
    if drive == "pattern":
        head += W.DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = f"bot={W.bot_lua(s['bot'])}, "
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=%d,loop=%s,steps={%s}}, " % (s.get("tlstart", 1), "true" if s.get("loop") else "false", steps)
    if s.get("lua_head"):
        head += s["lua_head"] + chr(10)
    if s.get("input_fn"):
        extra += "input=%s, " % s["input_fn"]
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    return head + f"acen.run{{frames={s['frames']}, writes=false, reads=false, refill={s.get('refill', 10)}, {extra}{at}}}"


def leg_session(R, s):
    m = R.m
    rec = R.h1(s["state"])
    m.call("load_state_file", path=s["state"])
    for addr, val, size in s.get("pokes", []):
        m.poke(addr, val)
    code = lean_lua(s)
    t = time.time()
    r = m.run_script_checked(code, ok_stop=("script_done",), name="r1_run", includes=["gaia_kit", "a_census"], frames=s["frames"] + 20, turbo=True, timeoutMs=900000)
    res = r["result"]
    nmi = R.dump(s["name"])
    R.record(leg=s["name"], kind="session", state=os.path.basename(s["state"]), frames=res.get("frames"), nmi=nmi, ctl36=res.get("control36Writes"), scene=res.get("scene"),
             form=res.get("form"), h1=rec, seconds=round(time.time() - t, 1), lua=code, warnings=r.get("__warnings__", []), note=s["note"])


def leg_boot(R, frames=9000):
    m = R.m
    code = f"acen.run{{frames={frames}, writes=false, reads=false}}"
    t = time.time()
    r = m.run_script_checked(code, ok_stop=("script_done",), name="r1_run", includes=["gaia_kit", "a_census"], frames=frames + 20, turbo=True, timeoutMs=900000, fromReset="power")
    res = r["result"]
    nmi = R.dump("boot")
    R.record(leg="boot", kind="cold boot (fromReset power), no input", state="(power)", frames=res.get("frames"), nmi=nmi, ctl36=res.get("control36Writes"), scene=res.get("scene"),
             seconds=round(time.time() - t, 1), lua=code, warnings=r.get("__warnings__", []))


def leg_natural(R):
    m = R.m
    nat = W.NATURAL
    rec = R.h1(nat["state"])
    m.call("load_state_file", path=nat["state"])
    doc = json.load(open(nat["input"], encoding="utf-8"))
    total = 0
    t = time.time()
    for part in W.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
    m.call("advance_frame", frames=70, turbo=True)
    nmi = R.dump("natural")
    R.record(leg="natural", kind="recorded input FR10_early_game.input (title to the castle gate)", state=os.path.basename(nat["state"]), frames=total + 70, nmi=nmi, scene=m.u16(0x0644),
             h1=rec, seconds=round(time.time() - t, 1))


SWEEP_LUA = r"""
local FORM, POST = %(form)d, %(post)d
local PAT = { {'right'},{'down','right'},{'down'},{'down','left'},{'left'},{'up','left'},{'up'},{'up','right'} }
local S = { nev = 0 }
e2.sweep({ scenes = {%(ids)s}, post = POST, noBanner = {[254] = true, [255] = true},
  beforeWarp = function(sc) if FORM > 0 then kit.w16(0x0AD4, FORM); kit.w16(0x0AA2, 0x7777) end end,
  tick = function(sc, t, nf)
    kit.w16(0x0ACE, kit.r16(0x0ACA))
    if kit.r8(0xB4) == 0 then
      local b = {}
      for _, x in ipairs(PAT[(t // 45) %% 8 + 1]) do b[#b + 1] = x end
      if t %% 90 < 3 then b[#b + 1] = 'b' end
      if t %% 130 < 3 then b[#b + 1] = 'a' end
      gaia.hold(b)
    end
  end,
  done = function(S2, per)
    local to, ends = {}, {}
    for _, r in ipairs(per) do if r.timeout then to[#to + 1] = string.format('%%02X', r.scene) end end
    kit.finish({ scenes = #per, timeouts = table.concat(to, ','), form = FORM })
  end }, S)
"""


def scene_ids():
    d = json.load(open(os.path.join(os.path.dirname(os.path.dirname(RESULTS)), "..", "artifacts", "scenes.json")))
    return [s["id"] for s in d["scenes"]]


def leg_sweep(R, form, post, per_chunk, only=None):
    m = R.m
    ids = scene_ids()
    if only:
        ids = [i for i in ids if i in only]
    name = {0: "will", 1: "freedan", 2: "shadow"}[form]
    for k in range(0, len(ids), per_chunk):
        ch = ids[k:k + per_chunk]
        tag = f"sweep_{name}_{post}_{k // per_chunk:02d}"
        if any(l.get("leg") == tag for l in R.legs):
            continue
        rec = R.h1(S01R)
        m.call("load_state_file", path=S01R)
        code = SWEEP_LUA % dict(form=form, post=post, ids=",".join(str(i) for i in ch))
        t = time.time()
        r = m.run_script_checked(code, frames=400000, includes=["e2_palette"], turbo=True, timeoutMs=900000, maxLog=5, name="r1_sweep")
        res = r["result"]
        nmi = R.dump(tag)
        R.record(leg=tag, kind="scene sweep", state="orig_S01r_south-cape-ready.mss", frames=nmi, nmi=nmi, scenes=ch, scenesDone=res.get("scenes"), timeouts=res.get("timeouts"), form=form,
                 h1=rec, seconds=round(time.time() - t, 1), warnings=r.get("__warnings__", []))


RICH = dict(seed=77, pAct=70, act=["b", "a", "y", "x", "b"], pressLens=[3, 3, 10, 30], alt=["l", "r"])


ABILITY_NAMES = ["f_will_dash", "f_will_slider", "f_freedan_aura", "f_freedan_melee", "f_shadow_aura", "f_goldship", "f_darkspace", "f_transform_forced"]


def ability_sessions():
    """The W1-f sessions that exercise the abilities, the Dark Space statues, the forced Transform_* routines and the Gold Ship cutscenes (defined in w1f_extra.py)."""
    import w1f_session as F  # noqa: F401  (registers the W1-b and W1-f rows into the shared session list)
    by = {s["name"]: s for s in F.S}
    return [by[n] for n in ABILITY_NAMES]


FORM_BASE = ["slope_s13", "slope_s14", "slope_s14b", "slope_s14c", "slope_s14d", "slope_s14e", "slope_s14f", "slope_s14g", "slope_s14i", "chest_0E", "chest_1D", "warp_misc",
             "p02_1C", "p04_3E", "p10_82", "p16_DE", "mine_melee"]


def form_sessions(base):
    """The Will sessions of the W1 table replayed in the Freedan (form 1) and Shadow (form 2) forms: $0AD4 = form and all ability bits in the disposable loaded state."""
    by = {x["name"]: x for x in base}
    out = []
    for form, tag in ((1, "f1"), (2, "f2")):
        for n in FORM_BASE:
            x = dict(by[n])
            x["name"] = f"{n}_{tag}"
            x["pokes"] = list(x.get("pokes", [])) + [(0x0AD4, form, 2), (0x0AA2, 0x77, 2)]
            x["note"] = x["note"] + f" (replayed with $0AD4 = {form}, $0AA2 = $0077)"
            out.append(x)
    return out


def extra_sessions():
    out = []

    def add(name, state, frames, note, **kw):
        out.append(dict(name=name, state=state, frames=frames, note=note, **kw))
    for nm, fn, sc in [("s10_will", "orig_S10_combat-room-will.mss", "0C"), ("s11_freedan", "orig_S11_combat-room-freedan.mss", "0C"), ("s12_shadow", "orig_S12_combat-room-shadow.mss", "0C"),
                       ("g3_s83_freedan", "orig_G3_s83_freedan.mss", "83"), ("g3_s83_shadow", "orig_G3_s83_shadow.mss", "83"), ("s12b_83_will", "orig_S12b_great-wall-83-will.mss", "83"),
                       ("g2_s22_will", "orig_G2_s22_gem3_will.mss", "22"), ("g2_s6d_will", "orig_G2_s6D_dispatch_will.mss", "6D"), ("p18s_shadow", "orig_P18_before_dark_gaia_shadow.mss", "E8"),
                       ("p03_castoth_rich", "orig_P03_before_castoth.mss", "29"), ("p15_mummy_rich", "orig_P15_before_mummy_queen.mss", "DD"), ("p18_gaia_rich", "orig_P18_before_dark_gaia.mss", "E8")]:
        add("x_" + nm, st(fn), 2400, f"{fn} (scene ${sc}) with the rich bot (B/A/Y/X, L/R)", drive="bot", bot=dict(RICH, seed=100 + len(out)), pokes=[(0x0AA2, 0x77, 2)])
    # game over: HP 0 in the combat room, no refill
    add("x_gameover", st("orig_S16_comet-lair-e8-records.mss"), 1500, "HP poked to 0 in the Dark Gaia arena: game over screen, no refill", drive="bot",
        bot=dict(seed=5, pAct=0, act=["a"], pressLens=[3]), pokes=[(0x0ACE, 0, 2)], refill=100000)
    add("x_credits", st("orig_E4_credits.mss"), 5200, "credits scene $F7 from the load, no input", drive="bot", bot=dict(seed=5, pAct=0, act=["a"], pressLens=[3]))
    add("x_diary_seeded", st("orig_M2_diary_seeded.mss"), 1200, "diary menu with two saved slots: cursor down / A / cancel", drive="timeline",
        steps=[(30, []), (3, ["down"]), (30, []), (3, ["up"]), (30, []), (3, ["a"]), (120, []), (3, ["y"]), (60, []), (3, ["down"]), (20, []), (3, ["a"]), (200, [])])
    add("x_s09_inventory_rich", st("orig_S09_inventory.mss"), 900, "inventory overlay: all four directions, A, cancel", drive="timeline",
        steps=[(30, []), (3, ["left"]), (10, []), (3, ["up"]), (10, []), (3, ["right"]), (10, []), (3, ["right"]), (10, []), (3, ["down"]), (10, []), (3, ["down"]), (10, []),
               (3, ["a"]), (40, []), (3, ["y"]), (60, [])])
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--legs", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--fresh", action="store_true")
    ap.add_argument("--only", default="")
    a = ap.parse_args()
    base = list(W.S)            # ability_sessions() imports w1f_session, which appends its rows to the shared W.S list
    ex = extra_sessions()
    ab = ability_sessions()
    fm = form_sessions(base)
    allsess = base + ex + ab + fm
    if a.list:
        print("boot natural sessions(%d) extra(%d) ability(%d) sweep_will sweep_freedan sweep_shadow" % (len(base), len(ex), len(ab)))
        for s in allsess:
            print(s["name"], s["frames"])
        return
    legs = [x for x in a.legs.split(",") if x]
    only = set(x for x in a.only.split(",") if x)
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"], flush=True)
    R = Run(m, info, a.fresh)
    try:
        for lg in legs:
            if lg == "boot":
                leg_boot(R)
            elif lg == "natural":
                leg_natural(R)
            elif lg in ("sessions", "extra", "ability", "forms"):
                for s in (base if lg == "sessions" else ex if lg == "extra" else ab if lg == "ability" else fm):
                    if only and s["name"] not in only:
                        continue
                    if any(l.get("leg") == s["name"] for l in R.legs):
                        continue
                    try:
                        leg_session(R, s)
                    except Exception as e:
                        print("FAILED", s["name"], repr(e)[:400], flush=True)
            elif lg == "sweep_will":
                leg_sweep(R, 0, 600, 12)
            elif lg == "sweep_freedan":
                leg_sweep(R, 1, 150, 40)
            elif lg == "sweep_shadow":
                leg_sweep(R, 2, 150, 40)
            else:
                raise SystemExit("unknown leg " + lg)
    finally:
        R.save()
        m.close()


if __name__ == "__main__":
    main()
