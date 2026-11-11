; Fall trigger of Angkor Wat (scenes $BB and $BD). The actor compares the player's X and Y pixel position with the five entries of spawn_trigger_0898A8 (scene, X, Y; scene $BB: (00A0,0120), (0110,0120), (0280,01A0), (00F0,0210); scene $BD: (0248,01F0)). On an exact match it writes player_transition_handlers.PlayerFallFromHeight into the player's entry word and zeroes the player's $08 and $2A, then dies. No flag and no floor change is involved.
---------------------------------------------

?INCLUDE 'player_transition_handlers'

!sceneCurrent                   0644
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA

---------------------------------------------

awBD_fall_trigger [
  actor-def < #00, #00, #20, {

  code_089861:
    PHX 
    LDX #$0000

  loc_089865:
    LDA $@spawn_trigger_0898A8, X
    CMP #$FFFF
    BEQ loc_0898A5
    CMP $sceneCurrent
    BNE loc_089885
    LDA $@spawn_trigger_0898A8+2, X
    CMP $playerXPos
    BNE loc_089885
    LDA $@spawn_trigger_0898A8+4, X
    CMP $playerYPos
    BEQ loc_08988D

  loc_089885:
    TXA 
    CLC 
    ADC #$0006
    TAX 
    BRA loc_089865

  loc_08988D:
    LDY $playerActor
    LDA #$*player_transition_handlers.PlayerFallFromHeight
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerFallFromHeight
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y

  loc_0898A5:
    PLX 
    COP [Die]
} >
]

spawn_trigger_0898A8 [
  spawn-trigger < #$00BB, #$00A0, #$0120 >   ;00
  spawn-trigger < #$00BB, #$0110, #$0120 >   ;01
  spawn-trigger < #$00BB, #$0280, #$01A0 >   ;02
  spawn-trigger < #$00BB, #$00F0, #$0210 >   ;03
  spawn-trigger < #$00BD, #$0248, #$01F0 >   ;04
]