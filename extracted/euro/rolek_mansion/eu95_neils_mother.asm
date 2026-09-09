!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

eu95_neils_mother [
  actor-def < #0D, #00, #10, {

  code_07E2DA:
    COP [BranchIfFlagByte] ( #A8, #01, &code_07E314 )
    LDA #$1200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07E316 )
    COP [ExitIfFlagByte] ( #A8, #01 )
    COP [ClearLowHere]
    COP [AddPosition] ( #00, #F0 )
    COP [StageSpriteLoopMoveY] ( #2F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2F, #06 )
    COP [AnimLoop]
    LDA #$0268
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #01 )
} >
]

code_07E314 {
    COP [Die]
}

code_07E316 {
    COP [PrintWideString] ( &widestring_07E31B )
    RTL 
}

widestring_07E31B `[TPL:B]Neil's mother: We've [N]made money and wish [N]to spend our remaining [N]years enjoying life. [FIN]Why don't you[N]succeed us...[END]`