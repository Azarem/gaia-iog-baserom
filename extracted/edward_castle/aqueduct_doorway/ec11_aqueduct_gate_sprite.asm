; One-shot orb sprite of the aqueduct doorway (scene $11, tile (0B,0B)).
; 
; Flag $DF set: dies at spawn. Otherwise it sets $DF, plays frame #33 of spriteset_pickups_effects for #02 steps and moves with StageMove / TickMove toward moveXAlt $0048, moveYAlt $0050. It has no open or closed gate state; the doorway door is the BG change #13 applied by ec11_button_voice.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

ec11_aqueduct_gate_sprite [
  actor-def < #15, #00, #10, {

  code_09AA43:
    COP [BranchOnFlagByte] ( #DF, #01, &code_09AA6C )
    COP [SetFlagByte] ( #DF )
    COP [SetMetasprite] ( @spriteset_pickups_effects )
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