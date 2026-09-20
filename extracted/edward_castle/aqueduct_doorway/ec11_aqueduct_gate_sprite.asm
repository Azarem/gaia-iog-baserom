; Aqueduct doorway gate sprite actor.
; 
; Visual gate sprite that animates open/closed states.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

ec11_aqueduct_gate_sprite [
  actor-def < #15, #00, #10, {

  code_09AA43:
    COP [BranchOnFlagByte] ( #DF, #01, &code_09AA6C )
    COP [SetFlagByte] ( #DF )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteLoop] ( #33, #02 )
    COP [AnimLoop]
    LDA #$0048
    STA $moveXAlt, X
    LDA #$0050
    STA $moveYAlt, X
    COP [StageMove] ( #33, #02, #FF )
    COP [TickMove]
} >
]

code_09AA6C {
    COP [Die]
}