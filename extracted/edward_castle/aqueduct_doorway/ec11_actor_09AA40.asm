?INCLUDE 'table_0EE000'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

ec11_actor_09AA40 [
  actor-def < #15, #00, #10, {

  code_09AA43:
    COP [BranchIfFlagByte] ( #DF, #01, &code_09AA6C )
    COP [SetFlagByte] ( #DF )
    COP [SetMetasprite] ( @table_0EE000 )
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