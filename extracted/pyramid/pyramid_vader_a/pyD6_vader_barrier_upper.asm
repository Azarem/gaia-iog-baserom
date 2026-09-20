; Upper Vader barrier in Pyramid — Shadow form gate (~110 lines).
; 
; Similar to lower barrier but in the upper Pyramid area.
; More complex timing or additional conditions for passage.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

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
    COP [SetMetasprite] ( @spriteset_enemies )
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