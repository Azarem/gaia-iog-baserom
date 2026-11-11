; Neil's mother at the Rolek mansion (scene $95).
; 
; $A8 set: the actor dies at spawn. Otherwise it stands solid with 'We've made money and wish to spend our remaining years enjoying life. Why don't you succeed us...' and waits for $A8 (the Teapot use); then it clears its solidity, walks off, moves toward (0268,0060), the same target as Neil's father, and dies when the walk ends (the actor definition falls through into code_07E314, COP Die).
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

eu95_neils_mother [
  actor-def < #0D, #00, #10, {

  code_07E2DA:
    COP [BranchOnFlagByte] ( #A8, #01, &code_07E314 )
    LDA #$1200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07E316 )
    COP [WaitOnFlagByte] ( #A8, #01 )
    COP [ClearSolidHere]
    COP [NudgePosition] ( #00, #F0 )
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
    COP [PrintDialogString] ( &dialogstring_07E31B )
    RTL 
}

dialogstring_07E31B `[TPL:B]Neil's mother: We've [N]made money and wish [N]to spend our remaining [N]years enjoying life. [FIN]Why don't you[N]succeed us...[END]`