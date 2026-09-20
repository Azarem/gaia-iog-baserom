; Phantom Ribber in the Seaside Palace — harmless ghost.
; 
; Ghost NPC. Will: "That's odd. Even if I touch it no damage
; occurs..." A phantom version of the Edward Castle enemy
; that is intangible. Establishes the palace's supernatural
; nature where normal threats don't apply.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'ToggleActorVisibilityFlag'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sp5A_phantom_ribber [
  actor-def < #00, #00, #01, {

  code_0689A6:
    COP [BranchOnFlagByte] ( #70, #01, &code_068A14 )
    LDA #$00FF
    STA $currentHp, X
    LDA #$&enemy_stats_table+44
    STA $statsPtr, X
    LDA #$0020
    TSB $12
    COP [SetHitCallback] ( &code_0689F3 )

  loc_0689C3:
    COP [LoopStart] ( #04 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [LoopEnd]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    COP [LoopStart] ( #04 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #88, #11 )
    COP [AnimOnce]
    COP [LoopEnd]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    BRA loc_0689C3
} >
]

code_0689F3 {
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$1000
    TSB $10
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_068A16 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_068A14 {
    COP [Die]
}

code_068A16 {
    COP [PrintDialogString] ( &dialogstring_068A1B )
    RTL 
}

dialogstring_068A1B `[TPL:A][TPL:0]Will: That's odd. [N]Even if I touch it [N]no damage occurs...[PAL:0][END]`