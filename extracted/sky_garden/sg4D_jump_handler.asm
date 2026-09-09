?INCLUDE 'player_transition_handlers'

!sceneCurrent                   0644
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

sg4D_jump_handler [
  actor-def < #00, #00, #20, {

  code_05F76E:
    PHX 
    LDX #$0000

  loc_05F772:
    LDA $@spawn_trigger_05F7BB, X
    CMP #$FFFF
    BEQ loc_05F7B8
    CMP $sceneCurrent
    BNE loc_05F792
    LDA $@spawn_trigger_05F7BB+2, X
    CMP $playerXPos
    BNE loc_05F792
    LDA $@spawn_trigger_05F7BB+4, X
    CMP $playerYPos
    BEQ loc_05F79A

  loc_05F792:
    TXA 
    CLC 
    ADC #$0006
    TAX 
    BRA loc_05F772

  loc_05F79A:
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C4D1
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C4D1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $playerFlags

  loc_05F7B8:
    PLX 
    COP [Die]
} >
]

spawn_trigger_05F7BB [
  spawn-trigger < #$004D, #$0308, #$0290 >   ;00
  spawn-trigger < #$004D, #$0258, #$03D0 >   ;01
  spawn-trigger < #$004D, #$0098, #$03D0 >   ;02
  spawn-trigger < #$004E, #$00E8, #$0280 >   ;03
  spawn-trigger < #$004E, #$0198, #$03C0 >   ;04
  spawn-trigger < #$004E, #$0358, #$03C0 >   ;05
  spawn-trigger < #$004F, #$0338, #$0110 >   ;06
  spawn-trigger < #$004F, #$0158, #$00F0 >   ;07
  spawn-trigger < #$004F, #$01F8, #$0280 >   ;08
  spawn-trigger < #$0050, #$00B8, #$0100 >   ;09
  spawn-trigger < #$0050, #$0298, #$00E0 >   ;0A
  spawn-trigger < #$0050, #$01F8, #$0270 >   ;0B
  spawn-trigger < #$0051, #$02A8, #$0140 >   ;0C
  spawn-trigger < #$0051, #$00E8, #$0100 >   ;0D
  spawn-trigger < #$0051, #$0358, #$03C0 >   ;0E
  spawn-trigger < #$0052, #$0148, #$0130 >   ;0F
  spawn-trigger < #$0052, #$0308, #$00F0 >   ;10
  spawn-trigger < #$0052, #$0098, #$03B0 >   ;11
  spawn-trigger < #$0053, #$0208, #$0290 >   ;12
  spawn-trigger < #$0053, #$0068, #$03E0 >   ;13
  spawn-trigger < #$0053, #$02E8, #$02E0 >   ;14
  spawn-trigger < #$0053, #$00A8, #$0100 >   ;15
  spawn-trigger < #$0054, #$01E8, #$0270 >   ;16
  spawn-trigger < #$0054, #$0388, #$03D0 >   ;17
  spawn-trigger < #$0054, #$0108, #$02F0 >   ;18
  spawn-trigger < #$0054, #$0348, #$00F0 >   ;19
]