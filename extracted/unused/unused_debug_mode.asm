; Unused debug initialization actor.
; 
; Sets player stats (HP=19, STR=32, DEF=33), character form to Shadow,
; unlocks all abilities ($FF), sets MEMSEL fast ROM, flags the player
; as dead ($0200), then enters the same sprite viewer loop as
; unused_debug_input_test.
---------------------------------------------

!joypadCurrent                  0656
!joypadHeld                     0658
!playerActor                    09AA
!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!playerDef                      0ADC
!playerStr                      0ADE
!MEMSEL                         420D

---------------------------------------------

unused_debug_mode [
  actor-def < #00, #00, #03, {

  code_09BA83:
    LDA #$0013
    STA $playerMaxHp
    STA $playerHp
    LDA #$0020
    STA $playerStr
    INC 
    STA $playerDef
    SEP #$20
    LDA #$01
    STA $MEMSEL
    REP #$20
    LDA #$0002
    STA $characterForm
    LDA #$00FF
    STA $abilityBitmask
    LDY $playerActor
    LDA #$0200
    ORA $0010, Y
    STA $0010, Y
    LDA #$0000
    STA $28

  loc_09BABC:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $joypadCurrent
    BIT #$0080
    BNE loc_09BAC9
    RTL 

  loc_09BAC9:
    LDA $28
    INC 
    CMP #$0042
    BCC loc_09BAD4
    LDA #$0000

  loc_09BAD4:
    STA $28
    STZ $2A
    LDA #$0080
    TSB $joypadHeld
    COP [SetEntryExit]
    BRA loc_09BABC

  loc_09BAE2:
    RTL 
} >
]