#!/usr/bin/env python3
"""FR30 batch 3 (exploration, not a verdict run): scene $71 (angel_tunnel_wind): enemy rows, enemiesRemaining ($0AEC), kill block, player stats."""
import json
from fr30_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    final = ("final=function(R) R.en=fr30.enemies(); R.rem=kit.r16(0x0AEC); R.bcd=kit.r16(0x0AEE); R.kill=fr30.bytes(0x0A80,32); R.rew=fr30.bytes(0x0A60,32);"
             " R.stats={maxhp=kit.r16(0x0ACA),hp=kit.r16(0x0ACE),str=kit.r16(0x0ADE),def=kit.r16(0x0ADC),form=kit.r16(0x0AD4)} end")
    r = visit(m, info, "explore71", S01R, shot="explore71", scene=113, settle=120, watch=False, hooks=drive(adv=False) + "," + final)
    print(json.dumps({k: r.get(k) for k in ("scene", "rem", "bcd", "stats", "kill", "rew", "pos", "p09A2")}))
    for e in r["en"]:
        print(e)
    print(summarize(r))
finally:
    m.close()
