?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!characterForm                  0AD4
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec12_actor_09BF0F [
  actor-def < #0F, #01, #01, {

  code_09BF12:
    LDA $characterForm
    BNE loc_09BF1C
    LDA #$0200
    TSB $10

  loc_09BF1C:
    COP [AddPosition] ( #02, #00 )
    LDA #$&stats_01ABF0+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$00FF
    STA $currentHp, X

  code_09BF38:
    COP [SetHitCallback] ( &code_09BF46 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_09BF38 )
} >
]

code_09BF46 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [BranchIfFlagWord] ( #$0114, #01, &code_09BF68 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #14 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0114 )
    COP [StageBgChange] ( #15 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0115 )
}

code_09BF68 {
    COP [SetEntryContinue]
    RTL 
}