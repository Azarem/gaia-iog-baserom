?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'table_0EE000'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw83_switch [
  actor-def < #00, #00, #30, {

  code_07BDA7:
    COP [BranchIfFlagWord] ( #$0152, #01, &code_07BDE6 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    LDA #$2000
    TRB $10
    LDA #$0278
    STA $moveXAlt, X
    LDA #$0190
    STA $moveYAlt, X
    COP [StageMove] ( #29, #04, #FF )
    COP [TickMove]
    COP [SpawnAfterFlags] ( @SpawnDebrisBurst, #$2000 )
    COP [StageBgChange] ( #52 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0152 )
} >
]

code_07BDE6 {
    COP [Die]
}