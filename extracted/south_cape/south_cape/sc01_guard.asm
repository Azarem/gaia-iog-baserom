; South Cape gate guard who blocks town exit before the castle summons.
; 
; Three dialog states gated by flags: blocks exit initially (flag $27=0),
; allows passage after Edward Castle summons (flag $35), and has a
; brief farewell after (flag $27=1). Animates walking to open/close
; the gate path.
---------------------------------------------

!playerYPos                     09A4

---------------------------------------------

sc01_guard [
  actor-def < #02, #00, #10, {

  code_048534:
    COP [BranchIfFlagByte] ( #27, #01, &code_04859B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDA $playerYPos
    CMP #$00B0
    BCS loc_048573
    COP [ClearLowHere]
    COP [SolidHighOffset] ( #FF, #FF )
    COP [SolidHighOffset] ( #FE, #FF )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #35, #01, &code_048574 )
    COP [SetOnInteract] ( &code_0485A4 )
    COP [SetEntryContinue]

  loc_048573:
    RTL 
} >
]

code_048574 {
    COP [SetOnInteract] ( &code_0485A9 )
    COP [ExitIfFlagByte] ( #27, #01 )
    COP [ClearLowAbs] ( #17, #06 )
    COP [ClearLowAbs] ( #18, #06 )
    COP [StageSpriteMoveX] ( #09, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
}

code_04859B {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0485B1 )
    COP [SetEntryContinue]
    RTL 
}

code_0485A4 {
    COP [PrintDialogString] ( &dialogstring_0485B6 )
    RTL 
}

code_0485A9 {
    COP [PrintDialogString] ( &dialogstring_048612 )
    COP [SetFlagByte] ( #27 )
    RTL 
}

code_0485B1 {
    COP [PrintDialogString] ( &dialogstring_048647 )
    RTL 
}

dialogstring_0485B6 `[DEF]Hold it! Many demons [N]are prowling around [N]outside the town. [FIN]Didn't your teacher warn[N]you not to leave town[N]without your parents?[END]`

dialogstring_048612 `[DEF]King Edward has summoned[N]you to the castle?[N]Well, just be careful.[END]`

dialogstring_048647 `[DEF]Be careful.[END]`