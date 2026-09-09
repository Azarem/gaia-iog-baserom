?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

pyD6_actor_08C2DA [
  actor-def < #0F, #01, #01, {

  code_08C2DD:
    LDA #$0031
    TSB $12
    COP [ClearHighAbs] ( #34, #2B )
    COP [ClearHighAbs] ( #35, #2B )
    COP [ClearHighAbs] ( #36, #2B )
    COP [ClearHighAbs] ( #37, #2B )
    COP [ClearHighAbs] ( #38, #2B )
    COP [ClearHighAbs] ( #39, #2B )
    COP [ClearHighAbs] ( #34, #2C )
    COP [ClearHighAbs] ( #35, #2C )
    COP [ClearHighAbs] ( #36, #2C )
    COP [ClearHighAbs] ( #37, #2C )
    COP [ClearHighAbs] ( #38, #2C )
    COP [ClearHighAbs] ( #39, #2C )
    LDY #$1060
    LDA #$FE00
    STA $0026, Y
    LDA #$&stats_01ABF0+118
    STA $statsPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighAbs] ( #34, #2B )
    COP [SolidHighAbs] ( #35, #2B )
    COP [SolidHighAbs] ( #36, #2B )
    COP [SolidHighAbs] ( #37, #2B )
    COP [SolidHighAbs] ( #38, #2B )
    COP [SolidHighAbs] ( #39, #2B )
    COP [SolidHighAbs] ( #34, #2C )
    COP [SolidHighAbs] ( #35, #2C )
    COP [SolidHighAbs] ( #36, #2C )
    COP [SolidHighAbs] ( #37, #2C )
    COP [SolidHighAbs] ( #38, #2C )
    COP [SolidHighAbs] ( #39, #2C )

  code_08C35E:
    COP [SetHitCallback] ( &code_08C36C )
    COP [SetEntryContinue]
    LDA #$7FFF
    STA $currentHp, X
    RTL 
} >
]

code_08C36C {
    COP [BranchIfFlagByte] ( #0F, #00, &code_08C377 )
    COP [SetEntryExitNow] ( @code_08C35E )
}

code_08C377 {
    COP [SetFlagByte] ( #0F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [SolidHighAbs] ( #34, #4B )
    COP [SolidHighAbs] ( #35, #4B )
    COP [SolidHighAbs] ( #36, #4B )
    COP [SolidHighAbs] ( #37, #4B )
    COP [SolidHighAbs] ( #38, #4B )
    COP [SolidHighAbs] ( #39, #4B )
    COP [SolidHighAbs] ( #34, #4C )
    COP [SolidHighAbs] ( #35, #4C )
    COP [SolidHighAbs] ( #36, #4C )
    COP [SolidHighAbs] ( #37, #4C )
    COP [SolidHighAbs] ( #38, #4C )
    COP [SolidHighAbs] ( #39, #4C )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    BEQ loc_08C3BE
    INC 
    STA $0026, Y
    RTL 

  loc_08C3BE:
    COP [ClearLowAbs] ( #34, #2B )
    COP [ClearLowAbs] ( #35, #2B )
    COP [ClearLowAbs] ( #36, #2B )
    COP [ClearLowAbs] ( #37, #2B )
    COP [ClearLowAbs] ( #38, #2B )
    COP [ClearLowAbs] ( #39, #2B )
    COP [ClearLowAbs] ( #34, #2C )
    COP [ClearLowAbs] ( #35, #2C )
    COP [ClearLowAbs] ( #36, #2C )
    COP [ClearLowAbs] ( #37, #2C )
    COP [ClearLowAbs] ( #38, #2C )
    COP [ClearLowAbs] ( #39, #2C )
    COP [PlaySoundBoth] ( #$1515 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    JMP $&code_08C35E
}