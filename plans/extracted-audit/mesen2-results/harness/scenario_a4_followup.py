#!/usr/bin/env python3
"""Campaign A follow-up (A4): enemy kill, drop, last-enemy reward, damage-number child, laborer hit, forced bits.

usage: scenario_a4_followup.py [--only prefix,prefix]

Same method as A3: atomic run_script runs from the South Cape state (scene $3F entered by writing sceneNext, no input
until frame 346), deterministic pairs (control / forced) where a bit or counter is forced with a Lua memory write into an
actor slot or into the enemy counters (never into low direct page). Results: raw/A4_<name>_<date>.json (+ .txt census).
"""
import argparse
import json
from a_common import label_addresses, open_session, run_experiment, stamp

PRELUDE = r"""
-- helpers come from kit/lib/a_actors.lua (aact): live-list walk, forced-bit helpers, change tracker, motion counter
local KILL_FROM = 346
local log = {}
local function L(s) if #log < 3500 then log[#log + 1] = s end end
local ent, hp, setf, clrf, inList = aact.ent, aact.hp, aact.setf, aact.clrf, aact.inList
local tracker = aact.tracker(KILL_FROM, L)
local motion = aact.motion()
local function glob(n)
  local mv, fl, lv, mnf = motion()
  return string.format('%d rem=%d bcd=%04X gems=%d dm=%04X pf=%04X php=%d px=%d py=%d pf12=%04X moved=%d filt=%d live=%d movedNF=%d pent=%06X', n, kit.r16(0x0AEC), kit.r16(0x0AEE), kit.r16(0x0AD6), kit.r16(0x09EC), kit.r16(0x09AE), kit.r16(0x0ACE), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1012), mv, fl, lv, mnf, ent(0x1000))
end
-- a drop gem: live actor, ChatPtr $83-$86, flag $0020, entry bank $80 (HiROM mirror of ROM bank $00)
local function findGem()
  for _, s in ipairs(aact.live()) do
    local c = kit.r16(0x1000A + s)
    if s ~= 0x1000 and c >= 0x83 and c <= 0x86 and (kit.r16(s + 0x10) & 0x0020) ~= 0 and kit.r8(s + 2) == 0x80 then return s end
  end
  return nil
end
local function findDigits() return aact.findEntry(0x80DCB4, 0x80DD40) end
local galive, talive = nil, nil
"""


def lua_kill(p):
    """Per-frame session: Will is teleported next to the target slot T (until it is dead), faces it and swings B.

    Hooks (Lua text): decl (before acen.run), pre (frame KILL_FROM+1), extra_tick (every frame after KILL_FROM, after scan),
    extra_input (returns a button table or nil, evaluated first), after_dead_input (table, default {}), swing (condition).
    """
    execs = ",".join(f"{k}={v}" for k, v in p["execs"].items())
    census = p.get("census", False)
    return f"""
{PRELUDE}
local T = {p['target']:#x}
local dead_at, gem, gem_at, dn, dn_at = nil, nil, nil, nil, nil
local sampled = {{}}
{p.get('decl', '')}
acen.run{{
  frames = {p['frames']}, writes = {'true' if census else 'false'}, reads = false, {('outFile = ' + json.dumps(p['outfile']) + ',') if census else ''}
  {('refill = ' + str(p.get('refill', 10)) + ',') if p.get('refill', 10) else ''}
  at = {{ [2] = function() kit.w16(0x0642, {p['scene']}) end }},
  execs = {{ {execs} }},
  input = function(n)
    if n <= KILL_FROM then return nil end
    {p.get('extra_input', '')}
    if dead_at and n > dead_at then return {p.get('after_dead_input', '{}')} end
    if n - KILL_FROM < 4 then return {{right = true}} end
    if {p.get('swing', '(n - KILL_FROM) % 6 < 3')} then return {{b = true}} end
    return {{}}
  end,
  tick = function(n)
    if n == KILL_FROM then
      tracker.snapshot()
      tracker.watch(T)
    end
    if n > KILL_FROM then
      tracker.scan(n)
      local ex, ey = kit.r16(T + 0x14), kit.r16(T + 0x16)
      local f10 = kit.r16(T + 0x10)
      if not dead_at and (f10 & 0x0040) ~= 0 then dead_at = n; L(string.format('%d DEAD target f10=%04X', n, f10)) end
      if not gem then gem = findGem(); if gem then gem_at = n; L(string.format('%d GEM slot=%04X f10=%04X f12=%04X x=%d y=%d', n, gem, kit.r16(gem + 0x10), kit.r16(gem + 0x12), kit.r16(gem + 0x14), kit.r16(gem + 0x16))) end end
      if not dn then dn = findDigits(); if dn then dn_at = n; L(string.format('%d DIGITS slot=%04X ent=%06X f10=%04X f12=%04X x=%d y=%d', n, dn, ent(dn), kit.r16(dn + 0x10), kit.r16(dn + 0x12), kit.r16(dn + 0x14), kit.r16(dn + 0x16))) end end
      if gem then
        local al = inList(gem)
        if al ~= galive then galive = al; L(string.format('%d GEMLIST slot=%04X inList=%s ent=%06X f10=%04X', n, gem, tostring(al), ent(gem), kit.r16(gem + 0x10))) end
      end
      if dead_at then
        local al = inList(T)
        if al ~= talive then talive = al; L(string.format('%d TLIST slot=%04X inList=%s ent=%06X f10=%04X', n, T, tostring(al), ent(T), kit.r16(T + 0x10))) end
      end
      if n == KILL_FROM + 1 then {p.get('pre', '')} end
      if not dead_at and not NO_TP then
        kit.w16(0x1014, ex - {p.get('tp_dx', 18)}); kit.w16(0x1016, ey); kit.w16(0x09A2, ex - 26); kit.w16(0x09A4, ey - 16)
      end
      {p.get('extra_tick', '')}
      if n % {p.get('glob_every', 2)} == 0 then
        local extra = ''
        if dn then extra = string.format(' DN ent=%06X f10=%04X f12=%04X x=%d y=%d wt=%d spr=%04X', ent(dn), kit.r16(dn + 0x10), kit.r16(dn + 0x12), kit.r16(dn + 0x14), kit.r16(dn + 0x16), kit.r16(dn + 8), kit.r16(dn + 0x28)) end
        if gem then extra = extra .. string.format(' GEM ent=%06X f10=%04X x=%d y=%d', ent(gem), kit.r16(gem + 0x10), kit.r16(gem + 0x14), kit.r16(gem + 0x16)) end
        sampled[#sampled + 1] = glob(n) .. string.format(' T f10=%04X f12=%04X hp=%d ent=%06X wt=%d', f10, kit.r16(T + 0x12), hp(T), ent(T), kit.r16(T + 8)) .. extra
      end
    end
  end,
  final = function() return {{log = log, sampled = sampled, deadAt = dead_at, gemAt = gem_at, dnAt = dn_at}} end,
}}
"""


def run_one(m, info, name, code, frames):
    def pre(mm):
        mm.poke(0x0AD4, 0)
        mm.poke(0x0AA2, 0x77)
        mm.poke(0x0AA3, 0x77)

    res = run_experiment(m, info, name, code, frames, "A4", pre=pre)
    fin = res.get("final") or {}
    ec = {k: v for k, v in (res.get("execCounts") or {}).items() if v}
    print(f"{name:34s} {res['__seconds__']:5.1f}s deadAt={fin.get('deadAt')} gemAt={fin.get('gemAt')} dnAt={fin.get('dnAt')} hp={res['hp']} scene={res['scene']:02X} execs={ec}")
    return res


EXEC_LABELS = ["StandardEnemyDefeatHandler", "EnemyDefeatFlashAndDrop", "EnemyGemDropRouter", "EnemyStatBonusReward", "HitInvincibleVictim",
               "FormatDamageDigits", "PlayerAttackHitTest", "ApplyHitDamageToVictim", "EnemyDefeatBossCleanup", "InteractionDamage_NPCChat",
               "ApplyInteractionDamage", "RewardNone", "RewardStrPickup", "DefeatGemPath", "DefeatHideAndRelease", "HitStaggerMain", "HitStaggerResolveHit",
               "CombatCollision_EnemyLoop", "RunInteractionCollision", "NpcDespawnStub", "Die", "UnlinkChildrenCascade", "GiveItemToPlayer"]


def scenarios(ex):
    S = {}
    base = dict(scene=0x3F, target=0x1210, execs=ex, frames=700)

    # K1: control kill of one eye stalker (HP set to 1 so one hit kills); full write census
    S["K1_kill_eye_stalker"] = lua_kill(dict(base, pre="kit.w16(0x10026 + T, 1)", census=True, outfile=f"A4_K1_kill_eye_stalker_{stamp()}.txt", frames=560))

    # K1b / K1c: walk Will onto the dropped gem 40 frames after it appears. K1c: $0400 is re-forced on the gem every frame
    pick = "if gem and n >= gem_at + 40 then NO_TP = true; kit.w16(0x1014, kit.r16(gem + 0x14)); kit.w16(0x1016, kit.r16(gem + 0x16)); kit.w16(0x09A2, kit.r16(gem + 0x14) - 8); kit.w16(0x09A4, kit.r16(gem + 0x16) - 16) end"
    S["K1b_gem_pickup_control"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)", extra_tick=pick, frames=520))
    S["K1c_gem_pickup_0400_forced"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)",
                                                      extra_tick="if gem then setf(gem, 0x10, 0x0400) end\n" + pick, frames=520))
    # K1e: swing at the gem while it lies there (control: no $0400 forced; forced: $0400 re-forced): does the sword hit it?
    swing_gem = "if gem and n >= gem_at + 10 then NO_TP = true; kit.w16(0x1014, kit.r16(gem + 0x14) - 18); kit.w16(0x1016, kit.r16(gem + 0x16)); kit.w16(0x09A2, kit.r16(gem + 0x14) - 26); kit.w16(0x09A4, kit.r16(gem + 0x16) - 16) end"
    S["K1e_swing_at_gem_control"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)", extra_tick=swing_gem,
                                                   after_dead_input="((n - dead_at) % 6 < 3) and {b = true} or {}", frames=480))
    S["K1g_gem_pickup_long"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)", extra_tick=pick, frames=700, glob_every=1))
    # K1d: inline lethal path: playerFlags $0010 (terrain shake) forced every frame, so ApplyHitDamageToVictim resolves the death inline
    S["K1d_inline_death_shake_forced"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)",
                                                         extra_tick="kit.w16(0x09AE, kit.r16(0x09AE) | 0x0010)", frames=520, census=True,
                                                         outfile=f"A4_K1d_inline_death_shake_forced_{stamp()}.txt"))
    S["K1f_inline_death_shake_control"] = lua_kill(dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)", frames=520))

    # K2: last enemy of the scene: counters forced to 1, so the kill takes the EnemyStatBonusReward path; Right is held after the kill
    k2 = dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1); kit.w16(0x0AEC, 1); kit.w16(0x0AEE, 1)",
              after_dead_input="(n < dead_at + 140) and {right = true} or ((n % 40 < 3) and {a = true} or ((n % 40 >= 20 and n % 40 < 23) and {b = true} or {}))",
              frames=700, glob_every=1)
    S["K2_last_enemy_reward"] = lua_kill(k2)
    # K2c: control: same inputs after the kill, but not the last enemy
    S["K2c_not_last_right_held"] = lua_kill(dict(k2, pre="kit.w16(0x10026 + T, 1)"))
    # K2f: forced: the flash child loses $12 $1000 the frame after it spawns (before displayModeFlags $0080 is set)
    S["K2f_flash_without_1000"] = lua_kill(dict(k2, extra_tick="local fl = nil; for s = 0x1030, 0x1F90, 0x30 do if ent(s) >= 0x80DF20 and ent(s) <= 0x80DF28 then clrf(s, 0x12, 0x1000) end end"))
    # K2g: forced: the reward pickup loses $12 $1000 (it should then never run while $0080 is set)
    S["K2g_reward_without_1000"] = lua_kill(dict(k2, extra_tick="for s = 0x1030, 0x1F90, 0x30 do local e = ent(s); if e >= 0x80E100 and e <= 0x80E150 then clrf(s, 0x12, 0x1000) end end"))

    # K3: damage-number child while pausing (Start for 3 frames at hit+3, again 40 frames later) and the control without Start
    k3 = dict(base, decl="NO_TP = false", pre="kit.w16(0x10026 + T, 1)", frames=470, glob_every=1)
    S["K3_digits_control"] = lua_kill(k3)
    S["K3_digits_pause"] = lua_kill(dict(k3, extra_input="if dn_at and ((n >= dn_at + 3 and n < dn_at + 6) or (n >= dn_at + 43 and n < dn_at + 46)) then return {start = true} end"))

    # K4: Diamond Mine laborer (slot 1750: HP 1, $12 $0230, extendedFlags $0080, first stats entry)
    for tgt in (0x1750, 0x1780):
        S[f"K4_laborer_{tgt:X}"] = lua_kill(dict(base, target=tgt, decl="NO_TP = false", frames=520, glob_every=2))

    # K5: OQ-I025-1: player $10 bit $0100 forced next to an enemy, no swing, no HP refill (Will HP 8, enemy ATK 7)
    k5 = dict(base, decl="NO_TP = false", refill=0, swing="false", tp_dx=6, frames=346 + 160)
    S["K5_player_0100_control"] = lua_kill(k5)
    S["K5_player_0100_forced"] = lua_kill(dict(k5, extra_tick="setf(0x1000, 0x10, 0x0100)"))
    # K5c: the same with $0100 cleared on the player every frame (it is set by PlayerIdleEntry at each idle entry)
    S["K5_player_0100_cleared"] = lua_kill(dict(k5, extra_tick="clrf(0x1000, 0x10, 0x0100)"))
    return S


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = [x for x in args.only.split(",") if x]
    m, info = open_session()
    print("ROM", info["fileSha1"])
    try:
        ex = label_addresses(m, EXEC_LABELS)
        for name, code in scenarios(ex).items():
            if only and not any(name.startswith(o) for o in only):
                continue
            frames = int(code.split("frames = ")[1].split(",")[0])
            run_one(m, info, name, code, frames)
    finally:
        m.close()


if __name__ == "__main__":
    main()
