---------------------------------------------

wa7B_competitor_right [
  actor-def < #24, #00, #10, {

  code_07A149:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_07A192, #$FFEE, #$FFF4, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_07A192, #$FFF4, #$0008, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_07A192, #$FFE8, #$0000, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_07A192, #$FFE0, #$FFF6, #$1000 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A183 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A183 {
    COP [PrintWideString] ( &widestring_07A188 )
    RTL 
}

widestring_07A188 `[TPL:A]Uhnn...[END]`

code_07A192 {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}