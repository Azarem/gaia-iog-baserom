#!/usr/bin/env python3
"""A1 (flag write census) and A2 (flag read census): actor Flags10 / Flags12 writers and readers, ROM O.

usage: scenario_a1_flag_census.py [--reads] [--only name,name] [--out DIR]

Every session loads the same South Cape state (S01r), pokes the form / ability bits / HP, then runs ONE atomic
run_script: the census (kit/lib/a_census.lua) records every change of a bit of actor +$10 / +$12 by (word, bit,
direction, K:PC) and, with --reads, every read of those four bytes by (field, K:PC). A scene is entered by the
script itself (`sceneNext` write at frame 2), so the spawn writes are part of the census. Results are written to
raw/A1_<session>_<date>.json (or A2_ with --reads); decode_flag_census.py merges and decodes them.
"""
import argparse
import json
import os
import time

from a_common import (ROM_O, RAW, S01R, open_session, player_slot, stamp)

BASE_BOT = dict(seed=11, pAct=60, act=["a", "b"], pressLens=[3, 3, 10])
MELEE = dict(seed=21, pAct=75, act=["b", "b", "a"], pressLens=[3, 3, 3, 60, 110], alt=["l", "r"])

SESSIONS = [
    dict(name="sc_will_walk", scene=None, form=0, frames=1800, bot=BASE_BOT, note="South Cape, walk, talk, doors"),
    dict(name="mine_will", scene=0x3F, form=0, abil=True, frames=3600, bot=MELEE, note="Diamond Mine main, Will, attack"),
    dict(name="mine_freedan", scene=0x3F, form=1, abil=True, frames=3600, bot=dict(MELEE, seed=22), note="Diamond Mine main, Freedan"),
    dict(name="mine_shadow", scene=0x3F, form=2, abil=True, frames=3600, bot=dict(MELEE, seed=23), note="Diamond Mine main, Shadow"),
    dict(name="mine_will_die", scene=0x3F, form=0, abil=True, hp=1, frames=2400, bot=dict(MELEE, seed=24), note="Will with 1 HP"),
    dict(name="castoth_will", scene=0x29, form=0, abil=True, frames=3000, bot=dict(MELEE, seed=25), note="Castoth lair, Will"),
    dict(name="hideout_cutscene", scene=0x02, form=0, frames=1500, bot=dict(seed=5, pAct=60, act=["a"], pressLens=[3]), note="hideout cutscene dialogue"),
    dict(name="church_cutscene", scene=0x08, form=0, frames=1500, bot=dict(seed=6, pAct=60, act=["a"], pressLens=[3]), note="church scene, new-game opening"),
]

def hold(n, *b):
    return (n, list(b))


WILL_ABIL = [hold(40), hold(180, "b"), hold(40),                                  # Psycho Dash (40 + 120 frame charge, release)
             hold(170, "b"), hold(6, "b", "l"), hold(4, "b"), hold(6, "b", "r"), hold(4, "b"), hold(6, "b", "l"),
             hold(4, "b"), hold(6, "b", "r"), hold(50, "b", "right"), hold(40),   # Spin Dash (L/R after 45 frames)
             hold(3, "right"), hold(3), hold(40, "right"), hold(3, "right", "b"), hold(60, "right"), hold(40),  # run + attack
             hold(3, "b"), hold(30), hold(3, "b"), hold(30)]
FREEDAN_ABIL = [hold(40), hold(150, "b"), hold(40),                                 # Dark Friar (40 + 100 frame charge, release)
                hold(150, "b"), hold(8, "b", "l"), hold(120, "b"), hold(40),       # Aura Barrier (L after the charge, hold, release)
                hold(150, "b"), hold(8, "b", "r"), hold(120, "b"), hold(40),
                hold(3, "b"), hold(30), hold(3, "b"), hold(30)]
SESSIONS += [
    dict(name="mine_will_abil", sample=10, scene=0x3F, form=0, abil=True, frames=1500, bot=BASE_BOT,
         timeline=dict(start=340, steps=WILL_ABIL), note="Diamond Mine main, Will, scripted charge/ability inputs"),
    dict(name="mine_freedan_abil", sample=10, scene=0x3F, form=1, abil=True, frames=1500, bot=BASE_BOT,
         timeline=dict(start=340, steps=FREEDAN_ABIL), note="Diamond Mine main, Freedan, scripted charge/ability inputs"),
]

NPC_SPOTS = [(136, 330), (634, 346), (666, 599), (108, 776), (568, 408)]   # 24 px south of South Cape NPC-like slots (4816, 4864, 4912, 5200, 5008)


def talk_block():
    steps = [hold(4, "up"), hold(3, "b"), hold(30)]
    for _ in range(3):
        steps += [hold(3, "a"), hold(30), hold(3, "b"), hold(30)]
    return steps + [hold(5)]


def tp(x, y):
    return f"kit.w16(0x1014,{x}); kit.w16(0x1016,{y}); kit.w16(0x09A2,{x}-8); kit.w16(0x09A4,{y}-16)"


SESSIONS += [
    dict(name="sc_npc_talk", exec_labels=["GlobalAmbientTargetInRange", "GlobalAmbientTalkWithSnapshot", "GlobalAmbientDeferToScript", "GlobalAmbientTargetAtOrBehind", "GlobalAmbientInvokeLinkedScript", "GlobalAmbientTalkRestoreActor"], scene=None, form=0, frames=6 + len(NPC_SPOTS) * 240 + 20, bot=BASE_BOT, sample=20,
         at={6 + i * 240: tp(x, y) for i, (x, y) in enumerate(NPC_SPOTS)},
         timeline=dict(start=6, steps=sum([talk_block() for _ in NPC_SPOTS], [])), note="South Cape: teleport next to NPCs and press interact"),
]

DS_SPOTS = [(56, 480), (56, 488), (56, 496), (56, 504), (48, 488), (64, 488), (56, 472), (56, 512)]
SESSIONS += [
    dict(name="sc_darkspace", scene=None, form=0, frames=40 + 8 * 70 + 500, bot=BASE_BOT, sample=10,
         at={6 + k * 70: tp(x, y) for k, (x, y) in enumerate(DS_SPOTS)},
         timeline=dict(start=8, steps=sum([[hold(3, "up"), hold(7), hold(3, "up"), hold(7), hold(3, "up"), hold(47)] for _ in DS_SPOTS], []) + [hold(500)]),
         note="South Cape: stand below the Dark Space portal at several offsets and press Up"),
]

SESSIONS += [
    dict(name="sc_npc_talk_clear0200", exec_labels=["GlobalAmbientTargetInRange", "GlobalAmbientTalkWithSnapshot", "GlobalAmbientDeferToScript", "GlobalAmbientTalkRestoreActor"],
         scene=None, form=0, frames=6 + len(NPC_SPOTS) * 240 + 20, bot=BASE_BOT, sample=20,
         at={**{6 + i * 240: tp(x, y) for i, (x, y) in enumerate(NPC_SPOTS)}, 728: "kit.w16(0x1462, kit.r16(0x1462) & 0xFDFF)"},
         timeline=dict(start=6, steps=sum([talk_block() for _ in NPC_SPOTS], [])),
         note="as sc_npc_talk, but Flags12 bit $0200 of the talked-to slot $1450 is cleared at frame 728 (forced-bit control for OQ-I044-2)"),
]

SESSIONS += [
    dict(name="mine_exit_warp", exec_labels=["ForcedWalkSouth", "ForcedWalkNorth", "ForcedWalkWest", "ForcedWalkEast", "SyncPlayerToCamera", "StartForcedWalk"],
         scene=0x3F, form=0, abil=True, frames=346 + 600, bot=BASE_BOT, sample=20,
         timeline=dict(start=346, steps=[hold(50, "left"), hold(130, "down"), hold(420)]),
         note="Diamond Mine main: walk into the south exit warp and keep the census running through the scene change"),
]


def bot_lua(b):
    def lst(v):
        return "{" + ",".join(json.dumps(x) for x in v) + "}"
    parts = [f"seed={b['seed']}", f"pAct={b['pAct']}"]
    for k in ("act", "dirs", "alt", "pressLens"):
        if k in b:
            parts.append(f"{k}={lst(b[k])}")
    if b.get("stand"):
        parts.append("stand=true")
    return "{" + ",".join(parts) + "}"


EXECS = dict(LaunchPsychoDash=0x82B855, LaunchSpinDash=0x82B861, LaunchDarkFriar=0x82B8D6, LaunchAuraBarrier=0x82B8E7,
             AttackInit=0x82CEEE, SpinDashRelease=0x82C17C, AuraBarrierMain=0x82B97F, DarkFriarMain=0x82BB3B, PsychoDashMain=0x82BEA0)


def timeline_lua(tl):
    steps = ",".join("{n=%d,b={%s}}" % (st[0], ",".join(json.dumps(b) for b in st[1])) for st in tl["steps"])
    return "timeline={start=%d,loop=%s,steps={%s}}, " % (tl["start"], "true" if tl.get("loop") else "false", steps)


def script(s, reads, outfile, execs=None):
    ats = {}
    if s.get("scene") is not None:
        ats[2] = f"kit.w16(0x0642, {s['scene']})"
    for fr, code in s.get("at", {}).items():
        ats[fr] = (ats[fr] + "; " + code) if fr in ats else code
    at = ("at={" + ",".join(f"[{fr}]=function() {code} end" for fr, code in ats.items()) + "}, ") if ats else ""
    if s.get("sample"):
        at += ("sampleEvery=%d, sample=function(n) return string.format('%%d f10=%%04X f12=%%04X pf=%%04X x=%%d y=%%d mk=%%04X b4=%%d dm=%%04X ent=%%04X', n, "
               "kit.r16(0x1010), kit.r16(0x1012), kit.r16(0x09AE), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x065A), kit.r16(0xB4), kit.r16(0x09EC), kit.r16(0x1000)) end, " % s["sample"])
    at += "execs={" + ",".join(f"{k}={v}" for k, v in (execs or EXECS).items()) + "}, "
    at += timeline_lua(s["timeline"]) if s.get("timeline") else ""
    refill = "" if s.get("hp") else "refill=10, "
    stop = (f"stop=(function() local d=nil; return function() if kit.r16(0x0AD4) ~= {s['form']} then return true end; "
            f"if kit.r16(0x09AE) & 0x0200 ~= 0 then d=(d or 0)+1 end; return d ~= nil and d >= {150 if s.get('hp') else 20} end end)(), ")
    return (f"acen.run{{frames={s['frames']}, outFile={json.dumps(outfile)}, writes=true, reads={'true' if reads else 'false'}, bot={bot_lua(s['bot'])}, {at}{refill}{stop}"
            f"final=function() return {{x=kit.r16(0x1014), y=kit.r16(0x1016), f10=kit.r16(0x1010), f12=kit.r16(0x1012), "
            f"hp=kit.r16(0x0ACE), flags=kit.r16(0x09AE), abil=kit.r16(0x0AA2), mask=kit.r16(0x065A)}} end}}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--reads", action="store_true")
    ap.add_argument("--only", default="")
    ap.add_argument("--out", default=RAW)
    args = ap.parse_args()
    only = set(x for x in args.only.split(",") if x)
    tag = "A2" if args.reads else "A1"
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"])
    try:
        for s in SESSIONS:
            if only and s["name"] not in only:
                continue
            m.call("load_state_file", path=S01R)
            m.poke(0x0AD4, s["form"])
            if s.get("abil"):
                m.poke(0x0AA2, 0x77)
                m.poke(0x0AA3, 0x77)
            if s.get("hp"):
                m.poke(0x0ACE, s["hp"])
            t = time.time()
            outfile = f"{tag}_{s['name']}_{stamp()}.txt"
            execs = dict(EXECS)
            for lab in s.get("exec_labels", []):
                execs[lab] = m.call("get_label_address", label=lab)["cpuAddress"]
            r = m.call("run_script", code=script(s, args.reads, outfile, execs), name=f"acen_{s['name']}", includes=["a_census"],
                       frames=s["frames"] + 20, turbo=True, timeoutMs=600000)
            if r.get("stopReason") != "script_done":
                print("NOT FINISHED", s["name"], r.get("stopReason"), r.get("log"))
                continue
            res = r["result"]
            shot = m.shot(f"{tag}_{s['name']}_end")
            res["session"] = s
            res["rom"] = info
            res["screenshot"] = shot
            out = os.path.join(args.out, f"{tag}_{s['name']}_{stamp()}.json")
            with open(out, "w", encoding="utf-8") as f:
                json.dump(res, f, indent=1)
            print(res.get('execCounts'));print(f"{s['name']:18s} {time.time()-t:5.1f}s stopped={res.get('stoppedAt')} ctl36={res['control36Writes']} writes={res['stats']['writes']} "
                  f"changes={res['stats']['writeChanges']} counts={res.get('counts')} "
                  f"scene={res['scene']:02X} form={res['form']} hp={res['hp']} final={res.get('final')}")
    finally:
        m.close()


if __name__ == "__main__":
    main()
