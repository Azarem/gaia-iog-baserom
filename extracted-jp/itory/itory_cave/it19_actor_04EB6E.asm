?INCLUDE 'chunk_008000'
?INCLUDE 'table_0EE000'

!slopeCurvePtrB                 09BC
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

h_it19_actor_04EB6E [
  actor-def < #00, #00, #01, {

  code_04EB71:
    COP [BranchIfFlagWord] ( #$011A, #01, &code_04EB9F )
    COP [SpawnAfterFlags] ( @code_04EBA1, #$2000 )
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$0030
    TSB $12
    COP [SetEntryContinue]
    RTL 
} >
]

code_04EB9F {
    COP [Die]
}

code_04EBA1 {
    PHX 
    LDX $04
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_04EBB3
    PLX 
    COP [SetEntryExitNow] ( @code_04EBA1 )

  loc_04EBB3:
    PLX 
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_04EBCC
    PHX 
    LDX $04
    LDA #$00FF
    STA $currentHp, X
    PLX 
    COP [SetEntryExitNow] ( @code_04EBA1 )

  loc_04EBCC:
    COP [SpawnAfterAbsFlags] ( @chunk_008000.widestring_00CB00, #$0098, #$0060, #$2000 )
    COP [StageBgChange] ( #1A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011A )
    COP [Die]
}