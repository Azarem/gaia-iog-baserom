; Invisible scene actor that grants post-boss stat rewards after victory.
; 
; Matches current scene ID against a boss_reward_range table (scenes for Castoth, Viper, Mu vampires, Sand Fanger, Mummy Queen), checks a per-boss WRAM flag, and distributes HP/STR/DEF increases from enemy_clear_reward_table when player flag $0020 is set. Sets the boss-cleared flag and triggers damage-flash timer to show the HP recovery animation. Spawned as a background actor in each major boss arena.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'enemy_clear_reward_table'

!sceneCurrent                   0644
!playerFlags                    09AE
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

boss_clear_reward_handler [
  actor-def < #00, #00, #20, {

  BossRewardCheckInit:
    PHX 
    SEP #$20              ; 8-bit for scene ID comparison
    LDX #$0000
    LDA $sceneCurrent

  loc_00C2C7:
    CMP $@boss_reward_range_00C312, X ; Match scene ID in boss table
    BEQ loc_00C2D3
    INX                   ; Next table entry (4 bytes each)
    INX 
    INX 
    INX 
    BRA loc_00C2C7

  loc_00C2D3:
    REP #$20
    TXA                   ; Table index → boss ID for WRAM flag
    STX $20
    PLX                   ; Restore actor pointer
    LSR                   ; Index / 4 = boss number
    LSR 
    JSL $@cop_handlers_flags.TestWramFlag_Offset100 ; Already rewarded this boss?
    BCS loc_00C30C        ; Yes → skip to idle
    COP [SetEntryHere]
    LDA $playerFlags
    BIT #$0020            ; Boss defeated flag set?
    BNE loc_00C2EC
    RTL                   ; Not yet — wait

  loc_00C2EC:
    PHX 
    LDX $20
    LDA $@boss_reward_range_00C312+1, X ; Load reward table range (start, end)
    STA $0004
    JSR $&BossClearApplyStatReward ; Apply HP/STR/DEF boosts
    PLX 
    LDA $playerMaxHp      ; Flash HP bar: timer = maxHP - currentHP
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDA $20
    LSR 
    LSR 
    JSL $@cop_handlers_flags.SetWramFlag_Offset100 ; Mark this boss as rewarded

  loc_00C30C:
    COP [SetEntryHere]    ; Idle loop after rewards granted
    NOP 
    NOP 
    NOP 
    RTL 
} >
]

boss_reward_range_00C312 [
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
; Iterates enemy_clear_reward_table entries in the boss's range [$04.lo .. $0E].
; Each entry byte is a reward type: 1=MaxHP+1, 2=STR+1, 3=DEF+1, 0=skip.
; Uses per-enemy flags ($0300 range) to avoid granting the same reward twice.

BossClearApplyStatReward {
    XBA                   ; Extract end offset from high byte
    AND #$00FF
    STA $000E             ; End index in reward table
    LDA $0004             ; Extract start offset from low byte
    AND #$00FF
    TAY                   ; Y = current index in reward table
    SEP #$20
    BRA loc_00C353

  code_00C350:
    SEP #$20
    INY                   ; Next enemy in table

  loc_00C353:
    LDA $&enemy_clear_reward_table, Y ; Load reward type for this enemy
    BNE loc_00C360        ; Non-zero → has reward
    INY                   ; Zero → skip, check if past end
    CPY $000E
    BCC loc_00C353
    BRA loc_00C394        ; Past end → done

  loc_00C360:
    REP #$20
    AND #$00FF
    STA $0004             ; Reward type: 1=HP, 2=STR, 3=DEF
    TYA 
    PHY 
    JSL $@cop_handlers_flags.TestFlag_0300 ; Already killed this enemy?
    PLY 
    BCS code_00C350       ; Already flagged → skip
    PHY 
    TYA 
    JSL $@cop_handlers_flags.SetFlag_0300 ; Mark enemy as killed
    PLY 
    LDA $0004             ; Dispatch reward type via DEC cascade
    PEA $&code_00C350-1   ; Push return to loop (RTS trick)
    DEC 
    BNE loc_00C385
    INC $playerMaxHp      ; Type 1: MaxHP +1
    RTS 

  loc_00C385:
    DEC 
    BNE loc_00C38C
    INC $playerStr        ; Type 2: STR +1
    RTS 

  loc_00C38C:
    DEC 
    BEQ loc_00C390
    RTS                   ; Unknown type → no reward

  loc_00C390:
    INC $playerDef        ; Type 3: DEF +1
    RTS 

  loc_00C394:
    REP #$20
    RTS 
}