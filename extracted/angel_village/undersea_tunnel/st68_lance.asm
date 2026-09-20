; Lance in the undersea tunnel — wonders about the distance.
; 
; NPC. Says: "I wonder how far this tunnel goes..." Reflects
; the party's uncertainty during the long underground trek.
---------------------------------------------

---------------------------------------------

st68_lance [
  actor-def < #05, #00, #10, {

  code_06AEB3:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AEBF )
} >
]

code_list_06AEBF [
  &code_06AEC5   ;00
  &code_06AEF0   ;01
  &code_06AEF2   ;02
]

code_06AEC5 {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06AEFE )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06AEF0 {
    COP [Die]
}

code_06AEF2 {
    COP [SetTilePos] ( #18, #1D )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06AEFE {
    COP [PrintDialogString] ( &dialogstring_06AF03 )
    RTL 
}

dialogstring_06AF03 `[TPL:A][TPL:4]Lance: [N]I wonder how far this [N]tunnel goes...[PAL:0][END]`