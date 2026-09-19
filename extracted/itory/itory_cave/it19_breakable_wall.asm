?INCLUDE 'enemy_stats_table'
?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'table_0EE000'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

it19_breakable_wall [
  actor-def < #00, #00, #01, {

  code_04F3D0:
    COP [BranchIfFlagWord] ( #$011A, #01, &code_04F3FE )
    COP [SpawnAfterFlags] ( @code_04F400, #$2000 )
    LDA #$&enemy_stats_table
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

code_04F3FE {
    COP [Die]
}

code_04F400 {
    PHX 
    LDX $04
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_04F412
    PLX 
    COP [SetEntryExitNow] ( @code_04F400 )

  loc_04F412:
    PLX 
    LDA $playerFlags
    BIT #$0002
    BNE loc_04F42B
    PHX 
    LDX $04
    LDA #$00FF
    STA $currentHp, X
    PLX 
    COP [SetEntryExitNow] ( @code_04F400 )

  loc_04F42B:
    COP [SpawnAfterAbsFlags] ( @SpawnDebrisBurst, #$0098, #$0060, #$2000 )
    COP [StageBgChange] ( #1A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011A )
    COP [Die]
}