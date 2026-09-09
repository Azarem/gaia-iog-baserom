?INCLUDE 'table_0EDA00'

---------------------------------------------

nvAC_bones [
  actor-def < #00, #01, #10, {

  code_088003:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08801B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08801B {
    COP [PrintWideString] ( &widestring_088020 )
    RTL 
}

widestring_088020 `[DEF][TPL:0]They're not weathered[N]yet... Only recently[N]bleached white.[PAL:0][END]`