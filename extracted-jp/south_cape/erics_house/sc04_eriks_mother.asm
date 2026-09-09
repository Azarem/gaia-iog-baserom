---------------------------------------------

h_sc04_eriks_mother [
  actor-def < #14, #00, #10, {

  code_048F48:
    COP [SpawnAfterRelFlags] ( @code_048F61, #$0009, #$FFF8, #$1002 )
    COP [SetOnInteract] ( &code_048F69 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048F61 {
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_048F69 {
    COP [PrintWideString] ( &widestring_048F6E )
    RTL 
}

widestring_048F6E `[DEF]エリックの母:[N]别に せなかに 火がついている[N]わけじゃないんだよ(芺)[N]これは おきゅうっていうのさ.[FIN]大きな家だと そうじをするだけで[N]かたがこって しょうがないよ···[END]`