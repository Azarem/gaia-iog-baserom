---------------------------------------------

av6B_musician [
  actor-def < #18, #00, #10, {

  code_06D0AE:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06D0C1 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    RTL 
} >
]

code_06D0C1 {
    COP [PrintDialogString] ( &dialogstring_06D0C6 )
    RTL 
}

dialogstring_06D0C6 `[TPL:A]Woman Playing Harp:[N]Music is the best[N]medicine for the soul.[FIN]The right song will cure[N]any disease.[END]`