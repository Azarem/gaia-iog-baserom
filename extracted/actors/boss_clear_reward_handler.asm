; Post-boss stat catch-up actor (Bank 00, 49854-50070), spawned from scene_actors in the five boss arenas (Castoth, Viper, the Mu vampires, Sand Fanger, the Mummy Queen). Once the boss is dead it grants, in one go, the stat reward of every room of that dungeon whose clear reward the player has not yet taken.
; 
; === FLOW ===
; 
; 1. BossRewardCheckInit: find sceneCurrent in boss_reward_range_table (4-byte rows: scene, first scene, last scene, pad; the first match wins). The row's byte offset is kept in $20, offset / 4 is the boss number. If wramFlags $0100 + boss number (event flags $0500-$0507) is already set the actor only idles.
; 2. Every frame (SetEntryHere): wait for playerFlags bit $0020 (boss defeated). Then BossClearApplyStatReward walks enemy_clear_reward_table over the scenes [first, last): each scene with a nonzero tier whose scene flag $0300 + scene is clear gets the flag set and its stat raised (1 = Max HP, 2 = STR, 3 = DEF, +1 each). It is the same flag that the per-room clear reward (reward_actors, field_reveal_object) tests, so a room cannot pay twice.
; 3. hpToHeal := maxHp - hp (UpdateHUD refills the bar at 1 HP per 8 frames, which also covers the extra max HP), the boss flag is set, and the actor idles for the rest of the scene.
; 
; === QUIRKS ===
; 
; - The scene search has no end-of-table test; it relies on the actor existing only in the five boss arenas. Rows 5-10 are placeholders (scene $F8 and $29 with an empty range); the first $29 row is the real one.
; - The range end is compared only after a zero tier. In the shipped table the entry at the end index (the boss scene itself) is zero in all five ranges, which ends the walk, so a nonzero run past the end cannot happen.
; - The entry stores the range word in the actor's $04 and the apply routine uses $04 and $0E as scratch. wram-memory-map lists $04 as prevActorLink (the actor list predecessor); whether anything reads that link while the actor lives is not traced.
; - $0B22 is the heal counter hpToHeal. The flag index is the scene id (not an enemy).
---------------------------------------------

?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'flag_helpers'

!sceneCurrent                   0644
!playerFlags                    09AE
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE
!hpToHeal                       0B22

---------------------------------------------

; Actor-def: sprite 0, flags 0, header byte $20. Invisible; see the block note.

boss_clear_reward_handler [
  actor-def < #00, #00, #20, {

; Init: locate this scene in the boss table, test the boss's reward flag, then poll playerFlags bit $0020 every frame.

  BossRewardCheckInit:
    PHX 
    SEP #$20              ; 8-bit for scene ID comparison
    LDX #$0000
    LDA $sceneCurrent     ; A = current scene id (8-bit); this actor only exists in the boss arenas

; Scene search: compare the 8-bit scene id with each 4-byte row; there is no end test.

  BossRewardFindScene:
    CMP $@boss_reward_range_table, X ; Match scene ID in boss table
    BEQ BossRewardCheckClaimed
    INX                   ; Next table entry (4 bytes each)
    INX 
    INX 
    INX 
    BRA BossRewardFindScene

; Row found: $20 := its byte offset, boss number := offset / 4, TestWramFlag_Offset100: already rewarded -> idle.

  BossRewardCheckClaimed:
    REP #$20
    TXA                   ; Table index → boss ID for WRAM flag
    STX $20               ; $20 := byte offset of the matching row (kept for the range lookup and the flag)
    PLX                   ; Restore actor pointer
    LSR                   ; Index / 4 = boss number
    LSR 
    JSL $@flag_helpers.TestWramFlag_Offset100 ; Already rewarded this boss?
    BCS BossRewardIdle    ; Yes → skip to idle
    COP [SetEntryHere]
    LDA $playerFlags
    BIT #$0020            ; playerFlags bit $0020 = boss defeated; polled every frame
    BNE BossRewardGrant
    RTL                   ; Not yet — wait

; Boss dead: load the row's range word (first scene in the low byte, last scene in the high byte) into $04, apply the rewards, refill HP, set the boss flag.

  BossRewardGrant:
    PHX 
    LDX $20
    LDA $@boss_reward_range_table+1, X ; A = first scene (low byte) and last scene (high byte) of the row
    STA $0004             ; Range word into actor $04 (also the list predecessor link)
    JSR $&BossClearApplyStatReward ; Apply HP/STR/DEF boosts
    PLX 
    LDA $playerMaxHp      ; hpToHeal := maxHp - hp: UpdateHUD refills the bar, 1 HP per 8 frames
    SEC 
    SBC $playerHp
    STA $hpToHeal
    LDA $20
    LSR 
    LSR 
    JSL $@flag_helpers.SetWramFlag_Offset100 ; Set wramFlags $0100 + boss number: rewards taken (event flags $0500-$0507)

; Idle for the rest of the scene: SetEntryHere + RTL each frame (the NOPs are padding).

  BossRewardIdle:
    COP [SetEntryHere]    ; Idle loop after rewards granted
    NOP 
    NOP 
    NOP 
    RTL 
} >
]

---------------------------------------------
; boss-reward-range rows: scene id, first scene, last scene (exclusive: it equals the boss scene), pad byte (not shown). Five real rows ($29, $55, $67, $8A, $DD); rows 5-10 are placeholders that never match first. The row index (0-4) is the boss number = bit n of wramFlags $0100 (event flag $0500 + n).

boss_reward_range_table [
  boss-reward-range < #29, #0C, #29 >   ;00
  boss-reward-range < #55, #3D, #55 >   ;01
  boss-reward-range < #67, #5A, #67 >   ;02
  boss-reward-range < #8A, #6D, #8A >   ;03
  boss-reward-range < #DD, #A0, #DD >   ;04
  boss-reward-range < #F8, #00, #00 >   ;05
  boss-reward-range < #29, #00, #00 >   ;06
  boss-reward-range < #29, #00, #00 >   ;07
  boss-reward-range < #29, #00, #00 >   ;08
  boss-reward-range < #29, #00, #00 >   ;09
  boss-reward-range < #29, #00, #00 >   ;0A
]

---------------------------------------------
; Walk enemy_clear_reward_table from the first to the last scene of the range ($04 low / high byte). Tier 0: skip. A nonzero tier whose scene flag $0300 + scene is clear: set the flag, then 1 = Max HP + 1, 2 = STR + 1, 3 = DEF + 1 (larger values: flag set, no stat; none in the table). PEA pushes BossRewardNextScene as the return address so each stat RTS goes back to the loop. The end is compared only after a zero tier.

BossClearApplyStatReward {
    XBA                   ; Extract end offset from high byte
    AND #$00FF
    STA $000E             ; End index in reward table
    LDA $0004             ; Extract start offset from low byte
    AND #$00FF
    TAY                   ; Y = current index in reward table
    SEP #$20
    BRA BossRewardReadTier

; Next scene index (8-bit accumulator).

  BossRewardNextScene:
    SEP #$20
    INY                   ; Next enemy in table

; Read the tier of scene Y: nonzero -> reward; zero -> advance and stop when Y reaches the last scene.

  BossRewardReadTier:
    LDA $&enemy_clear_reward_table, Y ; Tier of scene Y (0 none, 1 Max HP, 2 STR, 3 DEF)
    BNE BossRewardClaimScene ; Non-zero → has reward
    INY                   ; Zero → skip, check if past end
    CPY $000E
    BCC BossRewardReadTier
    BRA BossRewardDone    ; Past end → done

; Tier found: keep it in $04, test and set scene flag $0300 + Y (claimed), then dispatch by DEC chain.

  BossRewardClaimScene:
    REP #$20
    AND #$00FF
    STA $0004             ; Reward type: 1=HP, 2=STR, 3=DEF
    TYA 
    PHY 
    JSL $@flag_helpers.TestFlag_0300 ; Scene flag $0300 + Y: this scene's clear reward already taken?
    PLY 
    BCS BossRewardNextScene ; Already flagged → skip
    PHY 
    TYA 
    JSL $@flag_helpers.SetFlag_0300 ; Claim it now: the room's own clear reward will not pay again
    PLY 
    LDA $0004             ; Dispatch reward type via DEC cascade
    PEA $&BossRewardNextScene-1 ; Push return to loop (RTS trick)
    DEC 
    BNE BossRewardTryStr
    INC $playerMaxHp      ; Type 1: MaxHP +1
    RTS 

; Tier 2 or more: STR for exactly 2, otherwise continue the chain.

  BossRewardTryStr:
    DEC 
    BNE BossRewardTryDef
    INC $playerStr        ; Type 2: STR +1
    RTS 

; Tier 3 or more: DEF only for exactly 3, larger values give nothing.

  BossRewardTryDef:
    DEC 
    BEQ BossRewardAddDef
    RTS                   ; Unknown type → no reward

; Tier 3: DEF + 1.

  BossRewardAddDef:
    INC $playerDef        ; Type 3: DEF +1
    RTS 

; Done: 16-bit accumulator again, return to the caller.

  BossRewardDone:
    REP #$20
    RTS 
}