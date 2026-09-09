?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

h_ec12_actor_04F98A [
  actor-def < #0F, #01, #01, {

  code_04F98D:
    COP [AddPosition] ( #02, #00 )
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$00FF
    STA $currentHp, X

  code_04F9A9:
    COP [SetHitCallback] ( &code_04F9B7 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_04F9A9 )
} >
]

code_04F9B7 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [BranchIfFlagWord] ( #$0114, #01, &code_04F9D9 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #14 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0114 )
    COP [StageBgChange] ( #15 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0115 )
}

code_04F9D9 {
    COP [SetEntryContinue]
    RTL 
}