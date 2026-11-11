; Upper Vader barrier of Pyramid scene $D6: the hit target that swaps the solid row pair y $2B-$2C (tiles $34-$39) for y $4B-$4C.
; 
; Idle state: solid rows y $2B-$2C are marked, y $4B-$4C are open, a hit callback (code_08C36C) is armed and the counter word at slot $1060 + $26 is $FE00. A sword hit (physical B, Will form works) runs the callback: with scratch flag $0F clear it sets $0F, marks the lower row pair y $4B-$4C solid and counts the slot word up from $FE00; when it reaches 0 (513 frames) it clears the upper row pair y $2B-$2C, plays the sound, clears $0F and re-arms the callback (the hit callback is not armed while the counter runs, so further swings in that window do not reach it). A callback entered with $0F already set (set by a lower barrier, or forced) only jumps back to the idle state and nothing changes; the lower barriers share the same flag. The actor never tests characterForm or any other form state.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_pickups_effects'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

pyD6_vader_barrier_upper [
  actor-def < #0F, #01, #01, {

  code_08C2DD:
    LDA #$0031
    TSB $12
    COP [ClearTypeAbs] ( #34, #2B )
    COP [ClearTypeAbs] ( #35, #2B )
    COP [ClearTypeAbs] ( #36, #2B )
    COP [ClearTypeAbs] ( #37, #2B )
    COP [ClearTypeAbs] ( #38, #2B )
    COP [ClearTypeAbs] ( #39, #2B )
    COP [ClearTypeAbs] ( #34, #2C )
    COP [ClearTypeAbs] ( #35, #2C )
    COP [ClearTypeAbs] ( #36, #2C )
    COP [ClearTypeAbs] ( #37, #2C )
    COP [ClearTypeAbs] ( #38, #2C )
    COP [ClearTypeAbs] ( #39, #2C )
    LDY #$1060
    LDA #$FE00
    STA $0026, Y
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [MarkSolidAbs] ( #34, #2B )
    COP [MarkSolidAbs] ( #35, #2B )
    COP [MarkSolidAbs] ( #36, #2B )
    COP [MarkSolidAbs] ( #37, #2B )
    COP [MarkSolidAbs] ( #38, #2B )
    COP [MarkSolidAbs] ( #39, #2B )
    COP [MarkSolidAbs] ( #34, #2C )
    COP [MarkSolidAbs] ( #35, #2C )
    COP [MarkSolidAbs] ( #36, #2C )
    COP [MarkSolidAbs] ( #37, #2C )
    COP [MarkSolidAbs] ( #38, #2C )
    COP [MarkSolidAbs] ( #39, #2C )

  code_08C35E:
    COP [SetHitCallback] ( &code_08C36C )
    COP [SetEntryHere]
    LDA #$7FFF
    STA $currentHp, X
    RTL 
} >
]

code_08C36C {
    COP [BranchOnFlagByte] ( #0F, #00, &code_08C377 )
    COP [JumpNextFrame] ( @code_08C35E )
}

code_08C377 {
    COP [SetFlagByte] ( #0F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [MarkSolidAbs] ( #34, #4B )
    COP [MarkSolidAbs] ( #35, #4B )
    COP [MarkSolidAbs] ( #36, #4B )
    COP [MarkSolidAbs] ( #37, #4B )
    COP [MarkSolidAbs] ( #38, #4B )
    COP [MarkSolidAbs] ( #39, #4B )
    COP [MarkSolidAbs] ( #34, #4C )
    COP [MarkSolidAbs] ( #35, #4C )
    COP [MarkSolidAbs] ( #36, #4C )
    COP [MarkSolidAbs] ( #37, #4C )
    COP [MarkSolidAbs] ( #38, #4C )
    COP [MarkSolidAbs] ( #39, #4C )
    COP [SetEntryHere]
    LDY #$1060
    LDA $0026, Y
    BEQ loc_08C3BE
    INC 
    STA $0026, Y
    RTL 

  loc_08C3BE:
    COP [ClearSolidAbs] ( #34, #2B )
    COP [ClearSolidAbs] ( #35, #2B )
    COP [ClearSolidAbs] ( #36, #2B )
    COP [ClearSolidAbs] ( #37, #2B )
    COP [ClearSolidAbs] ( #38, #2B )
    COP [ClearSolidAbs] ( #39, #2B )
    COP [ClearSolidAbs] ( #34, #2C )
    COP [ClearSolidAbs] ( #35, #2C )
    COP [ClearSolidAbs] ( #36, #2C )
    COP [ClearSolidAbs] ( #37, #2C )
    COP [ClearSolidAbs] ( #38, #2C )
    COP [ClearSolidAbs] ( #39, #2C )
    COP [PlaySoundBoth] ( #$1515 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    JMP $&code_08C35E
}