#!/usr/bin/env python3
"""FR30 batch 13: FL13-CATCHUP (boss_clear_reward_handler, Castoth arena scene $29). The handler polls playerFlags bit $0020 ("boss defeated"); the trial sets that bit with a script write
(surrogate for the kill; the real kill is not run). Runs: A no poke, B poke with the room flags $030C-$0328 clear, C poke with the flags of rooms $0C-$12 ($030C-$0312) pre-set.
Expected deltas from enemy_clear_reward_table over [$0C,$29): tier counts of the unclaimed rooms."""
import json
import re
import sys
from fr30_lib import *  # noqa: F401,F403

tiers = {}
for line in open(os.path.join(BASEROM, "extracted", "tables", "enemy_clear_reward_table.asm"), encoding="utf-8"):
    mm = re.match(r"\s+#([0-9A-F]{2})\s+;([0-9A-F]{2})\s*$", line)
    if mm:
        tiers[int(mm.group(2), 16)] = int(mm.group(1), 16)


def expect(skip):
    d = {1: 0, 2: 0, 3: 0}
    for s in range(0x0C, 0x29):
        t = tiers[s]
        if t and s not in skip:
            d[t] += 1
    return d


def run1(m, info, name, poke, setf):
    at = "[5]=function(R,n) R.base={maxhp=kit.r16(0x0ACA),hp=kit.r16(0x0ACE),str=kit.r16(0x0ADE),def=kit.r16(0x0ADC),fl=fr30.bytes(0x0A60,6),a0=kit.r8(0x0AA0)} %s end" % (
        "kit.w16(0x09AE, kit.r16(0x09AE)|0x0020)" if poke else "")
    rec = [("maxhp", 0x0ACA, None, 2), ("hp", 0x0ACE, None, 2), ("str", 0x0ADE, None, 2), ("def", 0x0ADC, None, 2), ("heal", 0x0B22, None, 2), ("b61", 0x0A61, None, 1), ("a0", 0x0AA0, None, 1)]
    final = "final=function(R) R.fin={maxhp=kit.r16(0x0ACA),hp=kit.r16(0x0ACE),str=kit.r16(0x0ADE),def=kit.r16(0x0ADC),heal=kit.r16(0x0B22),fl=fr30.bytes(0x0A60,6),a0=kit.r8(0x0AA0)} end"
    hooks = drive(rec=rec, at=at, adv=False) + "," + final
    return visit(m, info, name, S01R, shot=name, scene=41, set=setf, settle=80, watch=False, hooks=hooks)


if __name__ == "__main__":
    m, info = open_o()
    try:
        skipC = {0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12}
        print("expected B", expect(set()), "expected C", expect(skipC))
        for nm, poke, setf in (("A_nopoke", False, []), ("B_poke", True, []), ("B_poke_repeat", True, []), ("C_poke_rooms0C_12_set", True, [780 + i for i in range(7)]), ("C_repeat", True, [780 + i for i in range(7)])):
            r = run1(m, info, "catchup_" + nm, poke, setf)
            b, e = r.get("base"), r.get("fin")
            print(nm, "err", r.get("error"), "d36", r.get("d36"))
            print("   base", b)
            print("   end ", e)
            print("   delta maxhp/str/def", e["maxhp"] - b["maxhp"], e["str"] - b["str"], e["def"] - b["def"])
            print("   shot", r.get("screenshot"))
            if nm == "B_poke":
                rec = r.get("rec") or []
                print("   rec rows", json.dumps(rec[:12], separators=(",", ":")))
    finally:
        m.close()
