; Fall trigger in Angkor Wat — floor collapse event.
; 
; Invisible trigger (~65 lines) that detects player position
; over weak floor sections. When triggered, the floor
; collapses and the player falls to a lower area. One-way
; progression mechanic.
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