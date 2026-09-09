---------------------------------------------

h_ec11_flower [
  actor-def < #3F, #00, #18, {

  code_04F6DA:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_04F6EF )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3F )
    COP [AnimOnce]
    RTL 
} >
]

code_04F6EF {
    COP [PrintWideString] ( &widestring_04F6F4 )
    RTL 
}

widestring_04F6F4 `[DEF]片すみにさく花:[N]笛を ふいてごらん···[N]あのメロディを ふいてごらん···[END]`