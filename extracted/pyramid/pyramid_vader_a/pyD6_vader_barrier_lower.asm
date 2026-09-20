; Lower Vader barrier in Pyramid — Shadow form gate (~96 lines).
; 
; Barrier that requires Shadow form to pass. Detects player
; form and opens only for Shadow's low-profile ability.
; Part of the form-switching puzzle design.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

pyD6_vader_barrier_lower [
  actor-def < #0F, #01, #01, {

  code_08C400:
    LDA #$0031
    TSB $12
    COP [ClearTypeAbs] ( #34, #4B )
    COP [ClearTypeAbs] ( #35, #4B )
    COP [ClearTypeAbs] ( #36, #4B )
    COP [ClearTypeAbs] ( #37, #4B )
    COP [ClearTypeAbs] ( #38, #4B )
    COP [ClearTypeAbs] ( #39, #4B )
    COP [ClearTypeAbs] ( #34, #4C )
    COP [ClearTypeAbs] ( #35, #4C )
    COP [ClearTypeAbs] ( #36, #4C )
    COP [ClearTypeAbs] ( #37, #4C )
    COP [ClearTypeAbs] ( #38, #4C )
    COP [ClearTypeAbs] ( #39, #4C )
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]

  code_08C448:
    COP [SetHitCallback] ( &code_08C456 )
    COP [SetEntryHere]
    LDA #$7FFF
    STA $currentHp, X
    RTL 
} >
]

code_08C456 {
    COP [BranchOnFlagByte] ( #0F, #00, &code_08C461 )
    COP [JumpNextFrame] ( @code_08C448 )
}

code_08C461 {
    COP [SetFlagByte] ( #0F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
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
    COP [SetEntryHere]
    LDY #$1060
    LDA $0026, Y
    CMP #$FE00
    BEQ loc_08C4AB
    DEC 
    STA $0026, Y
    RTL 

  loc_08C4AB:
    COP [ClearSolidAbs] ( #34, #4B )
    COP [ClearSolidAbs] ( #35, #4B )
    COP [ClearSolidAbs] ( #36, #4B )
    COP [ClearSolidAbs] ( #37, #4B )
    COP [ClearSolidAbs] ( #38, #4B )
    COP [ClearSolidAbs] ( #39, #4B )
    COP [ClearSolidAbs] ( #34, #4C )
    COP [ClearSolidAbs] ( #35, #4C )
    COP [ClearSolidAbs] ( #36, #4C )
    COP [ClearSolidAbs] ( #37, #4C )
    COP [ClearSolidAbs] ( #38, #4C )
    COP [ClearSolidAbs] ( #39, #4C )
    COP [PlaySoundBoth] ( #$1515 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    JMP $&code_08C448
}