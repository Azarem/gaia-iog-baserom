?INCLUDE 'table_0EDA00'

---------------------------------------------

gs2B_bones [
  actor-def < #02, #00, #10, {

  code_058BB6:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_058BD2 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #04 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058BD2 {
    COP [PrintWideString] ( &widestring_058BD7 )
    RTL 
}

widestring_058BD7 `[TPL:A][TPL:0]Will: [N]This is where the Inca [N]were standing...[PAL:0][END]`