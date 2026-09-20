; Neil's mother at the Rolek mansion — questions their lifestyle.
; 
; NPC: "We've made money and wish to spend our remaining years
; enjoying life. Why does Neil still want to travel?" Shows
; the gap between Neil's adventurous spirit and his parents'
; comfortable retirement.
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