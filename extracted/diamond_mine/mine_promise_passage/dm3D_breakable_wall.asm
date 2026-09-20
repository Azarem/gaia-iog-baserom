; Breakable wall in Promise Passage — opens path when destroyed.
; 
; Displays as a solid sprite (frame #00) with stat entry 0 and $FF HP.
; HP resets each frame so it requires Freedan's Dark Friar (playerFlags
; bit $0002) to actually break it. Tracks player proximity in an 8×14
; to 7×7 tile rectangle and sets a proximity flag. When broken: spawns
; debris burst VFX, applies BG change #33 to remove the wall tiles,
; clears the proximity flag, and sets flag word $0133.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'spriteset_enemies'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dm3D_breakable_wall [
  actor-def < #00, #00, #01, {

  code_0AA9EF:
    COP [BranchIfFlagWord] ( #$0133, #01, &code_0AAA52 )
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    LDA #$0031
    TSB $12

  loc_0AAA10:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0AAA32
    COP [BranchIfPlayerInAbsTiles] ( #05, #03, #07, #07, &code_0AAA2E )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_0AAA2E {
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_0AAA32:
    LDA $playerFlags
    BIT #$0002
    BNE loc_0AAA3F
    DEC $24
    BMI loc_0AAA10
    RTL 

  loc_0AAA3F:
    COP [SpawnAfterFlags] ( @SpawnDebrisBurst, #$2000 )
    COP [StageBgChange] ( #33 )
    COP [ApplyBgChange]
    COP [ClearFlagByte] ( #00 )
    COP [SetFlagWord] ( #$0133 )
}

code_0AAA52 {
    COP [Die]
}