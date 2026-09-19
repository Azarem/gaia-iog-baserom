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

  code_00C2BE:
    PHX 
    SEP #$20
    LDX #$0000
    LDA $sceneCurrent

  loc_00C2C7:
    CMP $@boss_reward_range_00C312, X
    BEQ loc_00C2D3
    INX 
    INX 
    INX 
    INX 
    BRA loc_00C2C7

  loc_00C2D3:
    REP #$20
    TXA 
    STX $20
    PLX 
    LSR 
    LSR 
    JSL $@cop_handlers_flags.TestWramFlag_Offset100
    BCS loc_00C30C
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0020
    BNE loc_00C2EC
    RTL 

  loc_00C2EC:
    PHX 
    LDX $20
    LDA $@boss_reward_range_00C312+1, X
    STA $0004
    JSR $&BossClearApplyStatReward
    PLX 
    LDA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDA $20
    LSR 
    LSR 
    JSL $@cop_handlers_flags.SetWramFlag_Offset100

  loc_00C30C:
    COP [SetEntryContinue]
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

BossClearApplyStatReward {
    XBA                   ; BossClearApplyStatReward
    AND #$00FF
    STA $000E
    LDA $0004
    AND #$00FF
    TAY 
    SEP #$20
    BRA loc_00C353

  code_00C350:
    SEP #$20
    INY 

  loc_00C353:
    LDA $&enemy_clear_reward_table, Y
    BNE loc_00C360
    INY 
    CPY $000E
    BCC loc_00C353
    BRA loc_00C394

  loc_00C360:
    REP #$20
    AND #$00FF
    STA $0004
    TYA 
    PHY 
    JSL $@cop_handlers_flags.TestFlag_0300
    PLY 
    BCS code_00C350
    PHY 
    TYA 
    JSL $@cop_handlers_flags.SetFlag_0300
    PLY 
    LDA $0004
    PEA $&code_00C350-1
    DEC 
    BNE loc_00C385
    INC $playerMaxHp
    RTS 

  loc_00C385:
    DEC 
    BNE loc_00C38C
    INC $playerStr
    RTS 

  loc_00C38C:
    DEC 
    BEQ loc_00C390
    RTS 

  loc_00C390:
    INC $playerDef
    RTS 

  loc_00C394:
    REP #$20
    RTS 
}